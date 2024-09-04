<?php
include "Connection.php";

// Receive and decode the JSON data
$json_data = file_get_contents('php://input');
$data = json_decode($json_data, true);

// Prepare the SQL statement
$sql = "UPDATE jrldetailed 
        SET AccountID = ?, 
            EntityID = ?, 
            description = ?, 
            DebitAmount = ?, 
            CreditAmount = ? 
        WHERE EntryID = ? AND LineID = ?";

$stmt = $conn->prepare($sql);

// Initialize response array
$response = ['status' => 'success', 'message' => 'Journal entry updated successfully', 'details' => []];

// Loop through the received data and update the database
foreach ($data as $row) {
    // Bind parameters
    $entityID = ($row['entity'] === '' || $row['entity'] === 'null' || $row['entity'] === null) ? null : (int)$row['entity'];

    $stmt->bind_param(
        "iisddii",
        $row['account'],
        $entityID,
        $row['label'],
        $row['debit'],
        $row['credit'],
        $row['entryID'],
        $row['lineId']
    );

    // Execute the statement
    if ($stmt->execute()) {
        $response['details'][] = "Line {$row['lineId']} updated successfully";
    } else {
        $response['status'] = 'error';
        $response['details'][] = "Error updating line {$row['lineId']}: " . $stmt->error;
    }
}

// Close the statement
$stmt->close();

// Close the database connection
$conn->close();

// Send a JSON response back to the JavaScript
header('Content-Type: application/json');
echo json_encode($response);
