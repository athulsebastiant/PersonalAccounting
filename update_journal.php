<?php
include "SessionPG.php";
include "Connection.php";

// Receive and decode the JSON data
$json_data = file_get_contents('php://input');
$data = json_decode($json_data, true);
$username = $_SESSION['username'];

// Prepare the SQL statement
$sql = "UPDATE jrldetailed 
        SET AccountID = ?, 
            EntityID = ?, 
            description = ?, 
            DebitAmount = ?, 
            CreditAmount = ?,
            modifiedBy = '$username' 
        WHERE EntryID = ? AND LineID = ?";

$stmt = $conn->prepare($sql);

// Initialize response array
$response = ['status' => 'success', 'message' => 'Journal entry updated successfully', 'details' => []];

try {
    // Start a transaction
    $conn->begin_transaction();

    // Loop through the received data and update the database
    foreach ($data as $row) {
        // Handle potential null values for the EntityID
        $entityID = ($row['entity'] === '' || $row['entity'] === 'null' || $row['entity'] === null) ? null : (int)$row['entity'];

        // Bind parameters
        $stmt->bind_param(
            "iisddii",
            $row['account'],  // AccountID
            $entityID,        // EntityID
            $row['label'],    // description
            $row['debit'],    // DebitAmount
            $row['credit'],   // CreditAmount
            $row['entryID'],  // EntryID
            $row['lineId']    // LineID
        );

        // Execute the statement
        if (!$stmt->execute()) {
            // Rollback the transaction if any error occurs
            $conn->rollback();
            $response['status'] = 'error';
            $response['details'][] = "Error updating line {$row['lineId']}: " . $stmt->error;
            break; // Exit the loop on error
        } else {
            // Log successful update for each row
            $response['details'][] = "Line {$row['lineId']} updated successfully";
        }
    }

    // Commit the transaction if no errors occurred
    if ($response['status'] === 'success') {
        $conn->commit();
    }
} catch (Exception $e) {
    // Rollback the transaction on any exception
    $conn->rollback();
    $response['status'] = 'error';
    $response['details'][] = "Exception: " . $e->getMessage();
}

// Close the statement
$stmt->close();

// Close the database connection
$conn->close();

// Send a JSON response back to the JavaScript
header('Content-Type: application/json');
echo json_encode($response);
