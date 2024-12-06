<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['id'], $data['name'], $data['description'], $data['price'], $data['imageUrl'])) {
        $id = $data['id'];
        $name = $data['name'];
        $description = $data['description'];
        $price = $data['price'];
        $imageUrl = $data['imageUrl'];

        $sql = "UPDATE pizzas SET name = ?, description = ?, price = ?, imageUrl = ? WHERE id = ?";

        if ($stmt = mysqli_prepare($conn, $sql)) {
            mysqli_stmt_bind_param($stmt, 'ssssi', $name, $description, $price, $imageUrl, $id);

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['status' => 'success', 'message' => 'Pizza updated successfully']);
            } else {
                echo json_encode(['error' => 'Failed to update pizza']);
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
