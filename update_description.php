<?php
include "Connection.php";
// Ensure this file can only be accessed via POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    exit('Invalid request method');
}

// Include your database connection file here


// Get the POST data
$newDescription = $_POST['description'] ?? '';
$entryId = $_POST['entryId'] ?? '';

// Validate input
if (empty($newDescription) || empty($entryId)) {
    echo json_encode(['success' => false, 'message' => 'Missing required data']);
    exit;
}
$conn->begin_transaction();

try {
    // Prepare and execute the update query
    $sql = "UPDATE jrlmaster SET description = ? WHERE EntryID = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $newDescription, $entryId);

    if ($stmt->execute()) {
        // If the update was successful, commit the transaction
        $conn->commit();
        echo json_encode(['success' => true, 'message' => 'Description updated successfully']);
    } else {
        // If the update failed, throw an exception
        throw new Exception('Failed to update description');
    }
} catch (Exception $e) {
    // If an error occurred, roll back the transaction
    $conn->rollback();
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
} finally {
    // Close the statement and connection
    $stmt->close();
    $conn->close();
}
