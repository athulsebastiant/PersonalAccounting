<?php
include "SessionPG.php";
include "Connection.php";

// Enable error reporting for debugging (remove in production)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$username = $_SESSION['username'];
$jsonData = file_get_contents('php://input');
$data = json_decode($jsonData, true);

// Check if data is received correctly
if (!$data) {
    http_response_code(400); // Bad request
    echo json_encode(['status' => 'error', 'message' => 'Invalid or missing JSON data.']);
    exit;
}

// Extract the data
$entryId = $data['entryId'];

$updateArray = $data['updateArray'];
$deleteArray = $data['deleteArray']; // Add this for deletions

$response = ['status' => 'success', 'message' => 'Data processed successfully', 'details' => []];

// Debug: Log data received (remove in production)
file_put_contents('debug.log', print_r($data, true));

// Prepare the SQL update statement
$updateSql = "UPDATE jrldetailed 
              SET AccountID = ?, 
                  EntityID = ?, 
                  description = ?, 
                  DebitAmount = ?, 
                  CreditAmount = ?, 
                  modifiedBy = '$username' 
              WHERE EntryID = ? AND LineID = ?";

// Prepare the SQL insert statement


// Prepare the SQL delete statement
$deleteSql = "DELETE FROM jrldetailed WHERE EntryID = ? AND LineID = ?";

// Begin a transaction
$conn->begin_transaction();

try {
    // Prepare the update statement
    $updateStmt = $conn->prepare($updateSql);
    if (!$updateStmt) {
        throw new Exception('SQL preparation error for update: ' . $conn->error);
    }

    // Loop through the updateArray and execute the update for each row
    foreach ($updateArray as $row) {
        $entityID = ($row['entity'] === '' || $row['entity'] === 'null' || $row['entity'] === null) ? null : (int)$row['entity'];

        $updateStmt->bind_param(
            "iisddii",  // Data types: i for int, s for string, d for double
            $row['account'],         // AccountID
            $entityID,               // EntityID
            $row['label'],           // description
            $row['debit'],           // DebitAmount
            $row['credit'],          // CreditAmount
            $entryId,                // EntryID
            $row['lineID']           // LineID
        );

        if (!$updateStmt->execute()) {
            throw new Exception("Error updating line {$row['lineID']}: " . $updateStmt->error);
        }

        $response['details'][] = "Line {$row['lineID']} updated successfully";
    }

    // Prepare the insert statement


    // Prepare the delete statement
    $deleteStmt = $conn->prepare($deleteSql);
    if (!$deleteStmt) {
        throw new Exception('SQL preparation error for delete: ' . $conn->error);
    }

    // Loop through the deleteArray and execute the delete for each row
    foreach ($deleteArray as $lineID) {
        $deleteStmt->bind_param(
            "ii",    // Data types: i for int
            $entryId, // EntryID
            $lineID   // LineID
        );

        if (!$deleteStmt->execute()) {
            throw new Exception("Error deleting line $lineID: " . $deleteStmt->error);
        }

        $response['details'][] = "Line $lineID deleted successfully";
    }

    // Commit the transaction
    $conn->commit();
} catch (Exception $e) {
    // Rollback the transaction if an error occurs
    $conn->rollback();
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
}

// Close the statements
if (isset($updateStmt)) $updateStmt->close();
if (isset($insertStmt)) $insertStmt->close();
if (isset($deleteStmt)) $deleteStmt->close();

// Close the database connection
$conn->close();

// Send a JSON response back to the JavaScript
header('Content-Type: application/json');
echo json_encode($response);
