<?php
include "Connection.php";
include "SessionPG.php";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_SESSION['username'];
    $firstname = $_POST['firstname'];
    $lastname = $_POST['lastname'];
    $phone = $_POST['phone'];
    $email = $_POST['email'];

    // Update user details in the database
    $sql = "UPDATE users2 SET Firstname = ?, Lastname = ?, Phone = ?, email = ? WHERE username = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $firstname, $lastname, $phone, $email, $username);

    if ($stmt->execute()) {
        echo "Success";
    } else {
        echo "Error updating record: " . $conn->error;
    }
}
