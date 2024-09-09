<?php
include "Connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $userId = $_POST['userId'];
    $field = $_POST['field'];
    $value = $_POST['value'];

    // Validate and sanitize inputs here

    $sql = "UPDATE users2 SET $field = ? WHERE userId = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $value, $userId);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => $conn->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}
