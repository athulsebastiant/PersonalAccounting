<?php

$servername = "localhost";
$username = "root";  // replace with your MySQL username
$password = "";  // replace with your MySQL password
$dbname = "ac2";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$field = "";
$value = "";

if (isset($_POST['username'])) {
    $field = "username";
    $value = $_POST['username'];
} elseif (isset($_POST['email'])) {
    $field = "email";
    $value = $_POST['email'];
} elseif (isset($_POST['phone'])) {
    $field = "phone";
    $value = $_POST['phone'];
}

// Prepare the query to prevent SQL injection
$stmt = $conn->prepare("SELECT COUNT(*) AS count FROM users2 WHERE $field = ?");
$stmt->bind_param("s", $value); // Bind the parameter

// Execute the query
$stmt->execute();

// Get the result
$result = $stmt->get_result();
$row = $result->fetch_assoc();

// Close the statement and connection
$stmt->close();
$conn->close();

// Check if the user exists
$response = array('exists' => $row['count'] > 0);

// Send the response as JSON
header('Content-Type: application/json');
echo json_encode($response);
