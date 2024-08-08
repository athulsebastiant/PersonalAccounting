<?php
// Database connection
include "Connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $firstname = $_POST['firstname'];
    $lastname = $_POST['lastname'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $username = $_POST['username'];
    //$password = password_hash($_POST['password'], PASSWORD_DEFAULT); // hash the password for security
    $password = password_hash($_POST['password'], PASSWORD_ARGON2ID);

    $sql = "INSERT INTO users2 (firstname, lastname, email, phone, username, `password`)
            VALUES ('$firstname', '$lastname', '$email', '$phone', '$username', '$password')";

    if ($conn->query($sql) === TRUE) {
        echo "New record created successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $conn->close();
}
