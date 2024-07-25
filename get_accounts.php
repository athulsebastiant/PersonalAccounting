<?php
include "connection.php";
$query = "SELECT AccountNo, AccountName FROM coa ORDER BY AccountNo";
$result = $conn->query($query);

if ($result) {
    $accounts = [];
    while ($row = $result->fetch_assoc()) {
        $accounts[] = [
            'id' => $row['AccountNo'],
            'name' => $row['AccountNo'] . ' - ' . $row['AccountName']
        ];
    }

    // Free result set
    $result->free();

    // Close connection
    $conn->close();

    // Send the accounts as JSON
    header('Content-Type: application/json');
    echo json_encode($accounts);
} else {
    // If there's an error, return an error message as JSON
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Database query failed: ' . $conn->error]);
}
