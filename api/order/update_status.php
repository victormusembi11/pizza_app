<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate input
    if (!isset($input['order_id']) || !isset($input['status']) || empty($input['order_id']) || empty($input['status'])) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input. Order ID and status are required.']);
        exit;
    }

    $order_id = $input['order_id'];
    $status = $input['status'];

    // Check if status is valid
    $valid_statuses = ['PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED'];
    if (!in_array($status, $valid_statuses)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid status.']);
        exit;
    }

    // Start a transaction
    mysqli_begin_transaction($conn);

    try {
        // Update the order status
        $update_sql = "UPDATE orders SET status = ? WHERE id = ?";
        $stmt = mysqli_prepare($conn, $update_sql);
        mysqli_stmt_bind_param($stmt, 'si', $status, $order_id);
        mysqli_stmt_execute($stmt);

        if (mysqli_stmt_affected_rows($stmt) > 0) {
            // Commit the transaction
            mysqli_commit($conn);
            echo json_encode(['status' => 'success', 'message' => 'Order status updated successfully.']);
        } else {
            throw new Exception("Failed to update order status or order not found.");
        }
    } catch (Exception $e) {
        // Rollback the transaction on failure
        mysqli_rollback($conn);
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }
} else {
    echo json_encode(['error' => 'Invalid request method. Use POST.']);
}
