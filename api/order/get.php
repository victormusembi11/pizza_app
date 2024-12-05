<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_GET['user_id'])) {
        echo json_encode(['status' => 'error', 'message' => 'User ID is required.']);
        exit;
    }

    $user_id = intval($_GET['user_id']);

    // Fetch all orders for the user, including order status and creation time
    $orders_sql = "SELECT id AS order_id, created_at, status FROM orders WHERE user_id = ?";
    $stmt_orders = mysqli_prepare($conn, $orders_sql);
    mysqli_stmt_bind_param($stmt_orders, 'i', $user_id);
    mysqli_stmt_execute($stmt_orders);
    $orders_result = mysqli_stmt_get_result($stmt_orders);

    if (mysqli_num_rows($orders_result) > 0) {
        $orders = [];

        while ($order_row = mysqli_fetch_assoc($orders_result)) {
            $orders[] = [
                'order_id' => $order_row['order_id'],
                'created_at' => $order_row['created_at'],
                'status' => $order_row['status'],
            ];
        }

        echo json_encode(['status' => 'success', 'data' => $orders]);
    } else {
        echo json_encode(['status' => 'success', 'data' => []]); 
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method. Use GET.']);
}
?>
