<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['id'])) {
        $id = $data['id'];

        $sql = "DELETE FROM pizzas WHERE id = ?";

        if ($stmt = mysqli_prepare($conn, $sql)) {
            mysqli_stmt_bind_param($stmt, 'i', $id);

            if (mysqli_stmt_execute($stmt)) {
                echo json_encode(['status' => 'success', 'message' => 'Pizza deleted successfully']);
            } else {
                echo json_encode(['error' => 'Failed to delete pizza']);
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
