<?php
// update_user_type.php

// Include your database connection file
include "Connection.php";

// Set the content type to JSON
header('Content-Type: application/json');

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get the userId and userType from the POST data
    $userId = isset($_POST['userId']) ? intval($_POST['userId']) : 0;
    $userType = isset($_POST['userType']) ? $_POST['userType'] : '';

    // Validate input
    if ($userId <= 0 || empty($userType)) {
        echo json_encode(['success' => false, 'message' => 'Invalid input']);
        exit;
    }

    // Prepare and execute the update query
    $stmt = $conn->prepare("UPDATE users2 SET user_type = ? WHERE userId = ?");
    $stmt->bind_param("si", $userType, $userId);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error']);
    }

    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}

$conn->close();
