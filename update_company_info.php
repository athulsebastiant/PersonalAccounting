<?php
// Include database connection
include "Connection.php";

// Set header to accept JSON
header("Content-Type: application/json");

// Get JSON input
$json_input = file_get_contents('php://input');
$data = json_decode($json_input, true);

// Check if data is valid
if (
    !isset($data['company_name']) ||
    !isset($data['address']) ||
    !isset($data['registration_number']) ||
    !isset($data['phone_number']) ||
    !isset($data['email'])
) {
    echo json_encode(['success' => false, 'message' => 'Invalid input data']);
    exit;
}

// Sanitize input data
$company_name = $conn->real_escape_string($data['company_name']);
$address = $conn->real_escape_string($data['address']);
$registration_number = $conn->real_escape_string($data['registration_number']);
$phone_number = $conn->real_escape_string($data['phone_number']);
$email = $conn->real_escape_string($data['email']);
$logo_filename = isset($data['logo_filename']) ? $conn->real_escape_string($data['logo_filename']) : '';

// Prepare SQL statement
$sql = "UPDATE company_info SET 
        company_name = ?, 
        address = ?, 
        registration_number = ?, 
        phone_number = ?, 
        email = ?";

// If a new logo filename is provided, update it; otherwise, keep the existing one
if (!empty($logo_filename)) {
    $sql .= ", logo_path = ?";
}

// Limit to 1 row as we only want to update the single existing row
$sql .= " LIMIT 1";

// Prepare statement
$stmt = $conn->prepare($sql);

// Bind parameters
if (!empty($logo_filename)) {
    $stmt->bind_param("ssssss", $company_name, $address, $registration_number, $phone_number, $email, $logo_filename);
} else {
    $stmt->bind_param("sssss", $company_name, $address, $registration_number, $phone_number, $email);
}

// Execute the statement
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(['success' => true, 'message' => 'Company information updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'No changes were made to the company information']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Error updating company information: ' . $stmt->error]);
}

// Close statement and connection
$stmt->close();
$conn->close();
