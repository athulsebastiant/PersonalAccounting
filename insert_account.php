<?php

header('Content-Type: application/json');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include "Connection.php";

$response = ["status" => "fail"]; // Default response

try {
    // Decode the JSON data from the request
    $data = json_decode(file_get_contents("php://input"), true);

    // Check if the data was successfully decoded
    if ($data === null) {
        throw new Exception('Invalid JSON data received');
    }

    if (!empty($data)) {
        foreach ($data as $row) {
            $accountNo = isset($row['AccountNo']) ? $conn->real_escape_string($row['AccountNo']) : '';
            $accountName = isset($row['AccountName']) ? $conn->real_escape_string($row['AccountName']) : '';
            $categoryID = isset($row['CategoryID']) ? $conn->real_escape_string($row['CategoryID']) : '';
            $subcategoryID = isset($row['SubcategoryID']) ? $conn->real_escape_string($row['SubcategoryID']) : '';

            $stmt = $conn->prepare("CALL InsertCOAData2(?, ?, ?, ?, @status)");
            $stmt->bind_param("isii", $accountNo, $accountName, $categoryID, $subcategoryID);

            if ($stmt->execute()) {
                $result = $conn->query("SELECT @status AS status");
                $row = $result->fetch_assoc();

                if ($row['status'] === "success") {
                    $response["status"] = "success";
                } else {
                    $response = ['status' => 'error', 'message' => 'An error occurred while inserting data'];
                    break;
                }
            } else {
                throw new Exception($stmt->error);
            }

            $stmt->close();
        }
    } else {
        $response = ['status' => 'no_data', 'message' => 'No data received'];
    }
} catch (Exception $e) {
    $response = [
        "status" => "error",
        "message" => "Caught exception: " . $e->getMessage()
    ];
}

// Output the JSON response
echo json_encode($response);

$conn->close();
