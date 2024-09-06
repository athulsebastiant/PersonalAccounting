<?php
include "Connection.php";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $entityId = $_POST['entityId'];
    $type = $_POST['type'];
    $name = $_POST['name'];
    $mobile = $_POST['mobile'];
    $email = $_POST['email'];

    $sql = "UPDATE entity SET type = ?, name = ?, mobileNo = ?, email = ? WHERE EntityId = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('ssssi', $type, $name, $mobile, $email, $entityId);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Entity updated successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error updating entity: " . $conn->error]);
    }

    $stmt->close();
    $conn->close();
}
