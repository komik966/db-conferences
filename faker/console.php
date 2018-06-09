#!/usr/bin/env php
<?php

use Doctrine\DBAL\Connection;
use Doctrine\DBAL\DBALException;
use Doctrine\DBAL\DriverManager;
use Faker\Generator;

require_once 'vendor/autoload.php';
$_ENV['DB_CONFIG'] = require './db_config.php';

class Loader
{
    private const DATETIME_FORMAT = 'Y-m-d H:i:s';
    private const TIME_FORMAT = 'H:i:s';

    /**
     * @var Connection
     */
    private $conn;

    /**
     * @var Generator
     */
    private $faker;

    /**
     * @throws DBALException
     */
    public function __construct()
    {
        $this->conn = DriverManager::getConnection($_ENV['DB_CONFIG']);
        $this->faker = Faker\Factory::create();
    }

    public function __destruct()
    {
        $this->conn->close();
    }

    /**
     * @throws DBALException
     */
    public function load(): void
    {
        $this->loadConferences();
        $this->loadConferenceDiscounts();
        $this->loadWorkshops();
        $this->loadWorkshopDays();
        $this->loadCompanyCustomers();
        $this->loadIndividualCustomers();
    }

    /**
     * @throws DBALException
     * @throws Exception
     */
    private function loadConferences(): void
    {
        for ($i = 0; $i < 75; $i++) {
            $stmt = $this->conn->prepare(
                'dbo.create_conference :name, :description, :start_date, :end_date, :basic_price, :student_discount, :max_attendees;'
            );

            $startDate = $this->faker->dateTimeBetween('now', '+2 years');
            $endDate = clone $startDate;
            $endDate = $endDate->add(new DateInterval('PT' . $this->faker->numberBetween(1, 120) . 'H'));

            $stmt->execute([
                'name' => $this->faker->sentence(1),
                'description' => $this->faker->sentence(6),
                'start_date' => $startDate->format(self::DATETIME_FORMAT),
                'end_date' => $endDate->format(self::DATETIME_FORMAT),
                'basic_price' => $this->faker->numberBetween(20, 1500),
                'student_discount' => $this->faker->randomFloat(1, 0, 1),
                'max_attendees' => $this->faker->numberBetween(20, 1500)
            ]);
        }
    }

    /**
     * @throws DBALException
     * @throws Exception
     */
    private function loadConferenceDiscounts(): void
    {
        $conferences = $this->conn->executeQuery('select id, start_date from conferences')->fetchAll();
        foreach ($conferences as $conference) {
            $minStartDate = (new DateTime())->add(new DateInterval('PT24H'));
            $maxDueDate = new DateTime($conference['start_date']);
            $daysBetween = $maxDueDate->diff($minStartDate);
            $maxDiscountCount = $daysBetween->days < 5 ? $daysBetween->days : 5;
            $discountCount = $this->faker->numberBetween(0, $maxDiscountCount);
            for ($i = 0; $i < $discountCount; $i++) {
                $dueDate = clone $minStartDate;
                $dueDate = $dueDate->add(new DateInterval('PT' . $i * 24 . 'H'));
                $stmt = $this->conn->prepare(
                    'dbo.create_conference_discount :conference_id, :due_date, :discount;'
                );
                $stmt->execute([
                    'conference_id' => $conference['id'],
                    'due_date' => $dueDate->format(self::DATETIME_FORMAT),
                    'discount' => $this->faker->randomFloat(2, 0.01, 1)
                ]);
            }
        }
    }

    /**
     * @throws DBALException
     */
    private function loadWorkshops(): void
    {
        for ($i = 0; $i < 150; $i++) {
            $stmt = $this->conn->prepare(
                'dbo.create_workshop :name, :max_attendees;'
            );

            $stmt->execute([
                'name' => $this->faker->sentence(1),
                'max_attendees' => $this->faker->numberBetween(10, 100)
            ]);
        }
    }

    /**
     * @throws DBALException
     * @throws Exception
     */
    private function loadWorkshopDays(): void
    {
        $conferenceDays = $this->conn->executeQuery('select id from conference_days')->fetchAll();
        $workshops = $this->conn->executeQuery('select id from workshops')->fetchAll();
        foreach ($conferenceDays as $conferenceDay) {
            for ($i = 0; $i < $this->faker->numberBetween(0, 4); $i++) {
                $startTime = $this->faker->dateTime;

                $tmp = clone $startTime;
                $tmp->add(new DateInterval('P1D'))->setTime(0, 0, 0, 0);
                $diff = $tmp->diff($startTime);
                if ($diff->i == 0) {
                    continue;
                }

                $endTime = clone $startTime;
                $endTime->add(new DateInterval('PT' . $this->faker->numberBetween(1, $diff->i) . 'M'));

                $stmt = $this->conn->prepare(
                    'dbo.create_workshop_day :workshop_id, :conference_day_id, :start_time, :end_time, :price, :max_attendees;'
                );
                $stmt->execute([
                    'workshop_id' => $workshops[$this->faker->numberBetween(0, count($workshops) - 1)]['id'],
                    'conference_day_id' => $conferenceDay['id'],
                    'start_time' => $startTime->format(self::TIME_FORMAT),
                    'end_time' => $endTime->format(self::TIME_FORMAT),
                    'price' => $this->faker->numberBetween(20, 1500),
                    'max_attendees' => $this->faker->numberBetween(10, 100)
                ]);
            }
        }
    }

    /**
     * @throws DBALException
     */
    private function loadCompanyCustomers(): void
    {
        for ($i = 0; $i < 100; $i++) {
            $stmt = $this->conn->prepare(
                'dbo.create_company_customer :phone_number, :company_name, :nip;'
            );
            $stmt->execute([
                'phone_number' => $this->faker->phoneNumber,
                'company_name' => $this->faker->company,
                'nip' => $this->faker->numerify('#######')
            ]);
        }
    }

    /**
     * @throws DBALException
     */
    private function loadIndividualCustomers(): void
    {
        for ($i = 0; $i < 100; $i++) {
            $stmt = $this->conn->prepare(
                'dbo.create_individual_customer :phone_number, :first_name, :second_name;'
            );
            $stmt->execute([
                'phone_number' => $this->faker->phoneNumber,
                'first_name' => $this->faker->firstName,
                'second_name' => $this->faker->lastName
            ]);
        }
    }
}

$l = new Loader();
$l->load();
