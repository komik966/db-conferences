#!/usr/bin/env php
<?php
require_once 'vendor/autoload.php';

$faker = Faker\Factory::create();

$bit = random_int(10, 1000) % 2;
$gender = $bit ? 'male' : 'female';

echo $faker->firstName($gender) . PHP_EOL;
echo $faker->lastName($gender) . PHP_EOL;

echo $faker->company . PHP_EOL;

