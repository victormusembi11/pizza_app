<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Fetch all orders, including order status, creation time, and order items
    $orders_sql = "
        SELECT o.id AS order_id, o.created_at, o.status AS order_status, 
               oi.cart_item_id, c.quantity, p.name AS pizza_name, p.price, p.description
        FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        LEFT JOIN cart c ON oi.cart_item_id = c.id
        LEFT JOIN pizzas p ON c.pizza_id = p.id
        ORDER BY o.created_at DESC
    ";

    $stmt_orders = mysqli_prepare($conn, $orders_sql);
    mysqli_stmt_execute($stmt_orders);
    $orders_result = mysqli_stmt_get_result($stmt_orders);

    if (mysqli_num_rows($orders_result) > 0) {
        $orders = [];

        while ($order_row = mysqli_fetch_assoc($orders_result)) {
            // If order_id doesn't exist in the orders array, create it
            if (!isset($orders[$order_row['order_id']])) {
                $orders[$order_row['order_id']] = [
                    'order_id' => $order_row['order_id'],
                    'created_at' => $order_row['created_at'],
                    'status' => $order_row['order_status'],
                    'items' => []
                ];
            }

            // Add order item details to the respective order
            $orders[$order_row['order_id']]['items'][] = [
                'pizza_name' => $order_row['pizza_name'],
                'quantity' => $order_row['quantity'],
                'price' => $order_row['price'],
                'description' => $order_row['description']
            ];
        }

        // Return the response with order details and associated items
        echo json_encode([
            'status' => 'success',
            'data' => array_values($orders) // re-index the orders array
        ]);
    } else {
        echo json_encode([
            'status' => 'success',
            'data' => [] // No orders found
        ]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method. Use GET.']);
}

