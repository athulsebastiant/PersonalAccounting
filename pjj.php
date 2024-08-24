<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
include "Connection.php";

// Decode the JSON data from the request
$data = json_decode(file_get_contents("php://input"), true);

// Check if the data was successfully decoded
if ($data === null) {
    $response = ['status' => 'error', 'message' => 'Invalid JSON data received'];
    echo json_encode($response);
    exit;
}

// Extract the data
$description = isset($data['description']) ? $data['description'] : '';
$jdate = isset($data['jdate']) ? $data['jdate'] : '';
$entries = isset($data['entries']) ? $data['entries'] : [];

// Convert the $entries array to a JSON string
$entries_json = json_encode($entries);

$stmt = $conn->prepare("CALL YourStoredProcedure(?, ?, ?, @status)");

// Bind parameters
$stmt->bind_param('sss', $jdate, $description, $entries_json);

// Execute the statement
if ($stmt->execute()) {
    // Retrieve the OUT parameter
    $result = $conn->query("SELECT @status AS status");
    $row = $result->fetch_assoc();

    if ($row['status'] == 'success') {
        $response = ['status' => 'success', 'message' => 'Data successfully posted'];
    } else {
        $response = ['status' => 'error', 'message' => 'An error occurred while posting data'];
    }
} else {
    $response = ['status' => 'error', 'message' => $stmt->error];
}

// Send the response back to the client
//echo json_encode($response);
echo $stmt->error;
// Close the statement and connection
$stmt->close();
$conn->close();

// Prepare and execute the stored procedure
/*$stmt = $conn->prepare("CALL YourStoredProcedure1(?, ?, ?)");

// Bind parameters
$stmt->bind_param('sss', $jdate, $description, $entries_json);

// Execute the statement
if ($stmt->execute()) {
    $response = ['status' => 'success', 'message' => 'Data successfully posted'];
} else {
    $response = ['status' => 'error', 'message' => $stmt->error];
}

// Send the response back to the client
echo json_encode($response);

// Close the statement and connection
$stmt->close();
$conn->close();
*/