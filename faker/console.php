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
}

$l = new Loader();
$l->load();
