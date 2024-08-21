<?php
include "Connection.php";
// Retrieve the JSON data sent via POST
$data = file_get_contents('php://input');

// Prepare the SQL statement to call the stored procedure
$stmt = $conn->prepare("CALL InsertEntities(?)");

// Bind the JSON data to the prepared statement as a string
$stmt->bind_param("s", $data);

// Execute the stored procedure
if ($stmt->execute()) {
    // Success message
    $response = ["status" => "success", "message" => "Entities inserted successfully."];
} else {
    // Error handling
    $response = ["status" => "error", "message" => "Failed to insert entities: " . $stmt->error];
}

// Close the statement and connection
$stmt->close();
$conn->close();

// Return the response as JSON
header('Content-Type: application/json');
echo json_encode($response);
