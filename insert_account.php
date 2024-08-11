<?php
include "Connection.php";

$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data)) {
    foreach ($data as $row) {
        $accountNo = $conn->real_escape_string($row['AccountNo']);
        $accountName = $conn->real_escape_string($row['AccountName']);
        $categoryID = $conn->real_escape_string($row['CategoryID']);
        $subcategoryID = $conn->real_escape_string($row['SubcategoryID']);

        $sql = "INSERT INTO coa (AccountNo, AccountName, CategoryID, SubcategoryID) VALUES ('$accountNo', '$accountName', '$categoryID', '$subcategoryID')";
        $conn->query($sql);
    }
    echo "Data inserted successfully!";
} else {
    echo "No data received!";
}

$conn->close();
