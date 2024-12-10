<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $sql = "SELECT * FROM pizzas";
    $result = mysqli_query($conn, $sql);

    if (mysqli_num_rows($result) > 0) {
        $pizzas = [];

        while ($row = mysqli_fetch_assoc($result)) {
            $pizzas[] = $row;
        }

        echo json_encode(['status' => 'success', 'data' => $pizzas]);
    } else {
        echo json_encode(['status' => 'success', 'data' => []]);
    }
} else {
    echo json_encode(['error' => 'Invalid request method. Use GET.']);
}
