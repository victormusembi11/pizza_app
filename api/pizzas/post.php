<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['name'], $data['description'], $data['price'], $data['imageUrl'])) {
        $name = $data['name'];
        $description = $data['description'];
        $price = $data['price'];
        $imageUrl = $data['imageUrl'];

        $sql = "INSERT INTO pizzas (name, description, price, imageUrl) VALUES (?, ?, ?, ?)";

        if ($stmt = mysqli_prepare($conn, $sql)) {
            mysqli_stmt_bind_param($stmt, 'ssss', $name, $description, $price, $imageUrl);

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['status' => 'success', 'message' => 'Pizza added successfully']);
            } else {
                echo json_encode(['error' => 'Failed to add pizza']);
            }

            mysqli_stmt_close($stmt);
        } else {
            echo json_encode(['error' => 'Failed to prepare SQL query']);
        }
    } else {
        echo json_encode(['error' => 'Missing required fields']);
    }
} else {
    echo json_encode(['error' => 'Invalid request method']);
}
