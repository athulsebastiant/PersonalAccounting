<?php
include "SessionPG.php";
include "Connection.php"; // Include your database connection

// Read the input from the request
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['AccountNo']) && isset($data['AccountName'])) {
    $accountNo = $conn->real_escape_string($data['AccountNo']);
    $accountName = $conn->real_escape_string($data['AccountName']);

    $username = $_SESSION['username'];
    // Update query
    $sql = "UPDATE coa SET AccountName = '$accountName',modifiedBy = '$username' WHERE AccountNo = '$accountNo'";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error updating record: ' . $conn->error]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}

$conn->close();
