<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    // Check if required fields are provided
    if (isset($data['name'], $data['email'], $data['password'])) {
        $name = $data['name'];
        $email = $data['email'];
        $password = $data['password'];

        // Validate email format
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            echo json_encode(['error' => 'Invalid email format']);
            exit();
        }

        // Prepare SQL query to insert a new user
        $sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";

        if ($stmt = mysqli_prepare($conn, $sql)) {
            mysqli_stmt_bind_param($stmt, 'sss', $name, $email, $password);

            // Execute the statement
            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['status' => 'success', 'message' => 'User created successfully']);
            } else {
                echo json_encode(['error' => 'Failed to create user']);
            }

            // Close the statement
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
