<?php
// Database connection
$servername = "localhost";
$username = "root";  // replace with your MySQL username
$password = "";  // replace with your MySQL password
$dbname = "ac2";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $firstname = $_POST['firstname'];
    $lastname = $_POST['lastname'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $username = $_POST['username'];
    //$password = password_hash($_POST['password'], PASSWORD_DEFAULT); // hash the password for security
    $password = password_hash($_POST['password'], PASSWORD_ARGON2ID);

    $sql = "INSERT INTO users2 (firstname, lastname, email, phone, username, password)
            VALUES ('$firstname', '$lastname', '$email', '$phone', '$username', '$password')";

    if ($conn->query($sql) === TRUE) {
        echo "New record created successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $conn->close();
}
