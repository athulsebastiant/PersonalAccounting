<?php
session_start(); // Start the session to manage user sessions

// Database connection details
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
    $input_username = $_POST['username'];
    $input_password = $_POST['password'];

    // Prepare and bind
    $stmt = $conn->prepare("SELECT password FROM users WHERE username = ?");
    if (!$stmt) {
        die("Prepare failed: (" . $conn->errno . ") " . $conn->error);
    }

    $stmt->bind_param("s", $input_username);
    if (!$stmt->execute()) {
        die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
    }

    $stmt->store_result();

    // Check if the user exists
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($hashed_password);
        $stmt->fetch();



        // Verify the password
        if (password_verify($input_password, $hashed_password)) {
            // Password is correct, start a session
            $_SESSION['username'] = $input_username;
            echo "Login successful!";
        } else {
            // Password is incorrect
            echo "Invalid password.";
        }
    } else {
        // Username does not exist
        echo "No user found with that username.";
    }

    $stmt->close();
}

$conn->close();
