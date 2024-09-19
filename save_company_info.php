<?php
include "Connection.php";

$response = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get form inputs
    $companyName = $_POST['CompanyName'] ?? '';
    $address = $_POST['Address'] ?? '';
    $regNo = $_POST['RegNo'] ?? '';
    $phone = $_POST['phn'] ?? '';
    $email = $_POST['email'] ?? '';

    // Handle file upload
    if (
        isset($_FILES['logo']) && $_FILES['logo']['error'] === 0
    ) {

        $file = $_FILES['logo'];
        $filename = basename($file['name']);

        $targetFilePath = $filename;



        // Here, insert the company details along with the logo file path into the database
        // Assuming you have a database connection $db
        $response['success'] = true;
        // Example of an SQL statement (update it with actual table and column names)
        $query = "INSERT INTO company_info (company_name, address, registration_number, phone_number, email, logo_path) 
                  VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssssss", $companyName, $address, $regNo, $phone, $email, $targetFilePath);

        if ($stmt->execute()) {
            $response['message'] = 'Company information and logo uploaded successfully.';
        } else {
            $response['success'] = false;
            $response['message'] = 'Database error: ' . $stmt->error;
        }
    }
}
echo json_encode($response);
