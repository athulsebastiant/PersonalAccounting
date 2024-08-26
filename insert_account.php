<?php
header('Content-Type: application/json');
include "Connection.php";

error_reporting(E_ALL);
ini_set('display_errors', 1);
try {
    $data = json_decode(file_get_contents("php://input"), true);
    $response = ["status" => "fail"]; // Default response

    if (!empty($data)) {
        foreach ($data as $row) {
            $accountNo = $conn->real_escape_string($row['AccountNo']);
            $accountName = $conn->real_escape_string($row['AccountName']);
            $categoryID = $conn->real_escape_string($row['CategoryID']);
            $subcategoryID = $conn->real_escape_string($row['SubcategoryID']);

            $stmt = $conn->prepare("CALL InsertCOAData(?, ?, ?, ?, @status)");
            $stmt->bind_param("isii", $accountNo, $accountName, $categoryID, $subcategoryID);
            $stmt->execute();

            $result = $conn->query("SELECT @status AS status");
            $row = $result->fetch_assoc();

            if ($row['status'] === "success") {
                $response["status"] = "success";
            } else {
                $response["status"] = "fail";
                break; // Exit the loop on the first failure
            }
        }
    } else {
        $response["status"] = "no_data";
    }
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Caught exception: " . $e->getMessage()
    ]);
}

$conn->close();
