<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_GET['user_id'])) {
        echo json_encode(['status' => 'error', 'message' => 'user_id is required']);
        exit;
    }

    $user_id = intval($_GET['user_id']);
    $sql = "
        SELECT 
            cart.id AS cart_id,
            cart.pizza_id,
            cart.quantity,
            pizzas.name AS pizza_name,
            pizzas.imageUrl,
            pizzas.price,
            pizzas.description
        FROM cart
        INNER JOIN pizzas ON cart.pizza_id = pizzas.id
        WHERE cart.user_id = $user_id
    ";

    $result = mysqli_query($conn, $sql);

    if (mysqli_num_rows($result) > 0) {
        $cart_items = [];

        while ($row = mysqli_fetch_assoc($result)) {
            $cart_items[] = $row;
        }

        echo json_encode(['status' => 'success', 'data' => $cart_items]);
    } else {
        echo json_encode(['status' => 'success', 'data' => []]);
    }
} else {
    echo json_encode(['error' => 'Invalid request method. Use GET.']);
}
