<?php

include "Connection.php"; // Ensure this includes the connection to your database

// Check if the user is logged in

// Retrieve the logged-in user's username from the session
$username = $_SESSION['username'];

// Query the database to get the user type for the logged-in user
$sql = "SELECT user_type FROM users2 WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $user_type = $row['user_type'];

    // Check if the user type is "Admin"
    if ($user_type != "Admin") {

        // User is not an Admin, redirect to another page
        header("Location: Homepg.php");
        exit();
    }
} else {
    // If no user found, redirect to the login page (or handle it as needed)
    header("Location: loginpg2.php");
    exit();
}

// Close the database connection
$stmt->close();
