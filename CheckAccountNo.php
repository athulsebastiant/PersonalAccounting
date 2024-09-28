<?php
include 'Connection.php'; // Ensure this includes your database connection
$accountNo = isset($_GET['AccountNo']) ? $_GET['AccountNo'] : '';

$sql = "SELECT COUNT(*) as count FROM coa WHERE AccountNo = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $accountNo);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

echo json_encode(['exists' => $row['count'] > 0]);

$stmt->close();
$conn->close();
