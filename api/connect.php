<?php

$hostname = "127.0.0.1";
$username = "root";
$password = "";
$database = "pizza_app";

$conn = mysqli_connect($hostname, $username, $password, $database);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

