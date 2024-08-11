<?php
include "Connection.php";

$sql = "SELECT CategoryID, SubcategoryID, SubcategoryName FROM accountsub";
$result = $conn->query($sql);

$subcategories = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $subcategories[] = $row;
    }
}
echo json_encode($subcategories);

$conn->close();
