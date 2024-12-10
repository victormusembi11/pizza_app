<?php

require_once __DIR__ . '/../connect.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    if (isset($data['user_id'], $data['pizza_id'])) {
        $user_id = $data['user_id'];
        $pizza_id = $data['pizza_id'];
        $quantity = isset($data['quantity']) ? (int)$data['quantity'] : 1;

        // Check if the pizza already exists in the user's cart
        $check_sql = "SELECT quantity FROM cart WHERE user_id = ? AND pizza_id = ?";
        if ($check_stmt = mysqli_prepare($conn, $check_sql)) {
            mysqli_stmt_bind_param($check_stmt, 'ii', $user_id, $pizza_id);
            mysqli_stmt_execute($check_stmt);
            mysqli_stmt_bind_result($check_stmt, $existing_quantity);

            if (mysqli_stmt_fetch($check_stmt)) {
                // If the pizza exists, increment the quantity
                $new_quantity = $existing_quantity + $quantity;
                mysqli_stmt_close($check_stmt);

                $update_sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND pizza_id = ?";
                if ($update_stmt = mysqli_prepare($conn, $update_sql)) {
                    mysqli_stmt_bind_param($update_stmt, 'iii', $new_quantity, $user_id, $pizza_id);
                    if (mysqli_stmt_execute($update_stmt)) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Pizza quantity updated in cart'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'error',
                            'message' => 'Failed to update pizza quantity'
                        ]);
                    }
                    mysqli_stmt_close($update_stmt);
                } else {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Failed to prepare update query'
                    ]);
                }
            } else {
                // If the pizza does not exist, insert a new record
                mysqli_stmt_close($check_stmt);

                $insert_sql = "INSERT INTO cart (user_id, pizza_id, quantity) VALUES (?, ?, ?)";
                if ($insert_stmt = mysqli_prepare($conn, $insert_sql)) {
                    mysqli_stmt_bind_param($insert_stmt, 'iii', $user_id, $pizza_id, $quantity);
                    if (mysqli_stmt_execute($insert_stmt)) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Pizza added to cart'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'error',
                            'message' => 'Failed to add pizza to cart'
                        ]);
                    }
                    mysqli_stmt_close($insert_stmt);
                } else {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Failed to prepare insert query'
                    ]);
                }
            }
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Failed to prepare select query'
            ]);
        }
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'Missing required fields (user_id and pizza_id)'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid request method'
    ]);
}
