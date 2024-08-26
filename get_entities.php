<?php
include "Connection.php";
$query = "SELECT EntityID,name FROM `entity` ORDER BY EntityID";
$result = $conn->query($query);

if ($result) {
    $entities = [];
    while ($row = $result->fetch_assoc()) {
        $entities[] = [
            'Eid' => $row['EntityID'],
            'name' => $row['EntityID'] . ' - ' . $row['name']
        ];
    }

    // Free result set
    $result->free();

    // Close connection
    $conn->close();

    // Send the accounts as JSON
    header('Content-Type: application/json');
    echo json_encode($entities);
} else {
    // If there's an error, return an error message as JSON
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Database query failed: ' . $conn->error]);
}
