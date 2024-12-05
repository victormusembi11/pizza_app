<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!isset($input['user_id']) || empty($input['cart_items'])) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input.']);
        exit;
    }

    $user_id = $input['user_id'];
    $cart_items = $input['cart_items']; // Array of cart_item_ids

    // Start a transaction
    mysqli_begin_transaction($conn);

    try {
        // Insert into orders table
        $order_sql = "INSERT INTO orders (user_id) VALUES (?)";
        $stmt = mysqli_prepare($conn, $order_sql);
        mysqli_stmt_bind_param($stmt, 'i', $user_id);
        mysqli_stmt_execute($stmt);

        if (mysqli_stmt_affected_rows($stmt) > 0) {
            $order_id = mysqli_insert_id($conn);

            // Insert each cart item into order_items
            $order_items_sql = "INSERT INTO order_items (cart_item_id, order_id, user_id) VALUES (?, ?, ?)";
            $stmt_items = mysqli_prepare($conn, $order_items_sql);

            foreach ($cart_items as $cart_item_id) {
                mysqli_stmt_bind_param($stmt_items, 'iii', $cart_item_id, $order_id, $user_id);
                mysqli_stmt_execute($stmt_items);

                if (mysqli_stmt_affected_rows($stmt_items) <= 0) {
                    throw new Exception("Failed to insert cart item ID $cart_item_id.");
                }
            }

            // Commit the transaction
            mysqli_commit($conn);
            echo json_encode(['status' => 'success', 'message' => 'Order created successfully.', 'order_id' => $order_id]);
        } else {
            throw new Exception("Failed to create order.");
        }
    } catch (Exception $e) {
        // Rollback the transaction on failure
        mysqli_rollback($conn);
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }
} else {
    echo json_encode(['error' => 'Invalid request method. Use POST.']);
}
?>
