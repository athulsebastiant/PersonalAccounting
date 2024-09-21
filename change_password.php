<?php
include "Connection.php";
include "SessionPG.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $input_username = $_SESSION['username'];
    $current_password = $_POST['current_password'];
    $new_password = $_POST['new_password'];

    // Prepare and bind
    $stmt = $conn->prepare("SELECT password FROM users2 WHERE username = ?");
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
        if (password_verify($current_password, $hashed_password)) {
            // Hash the new password
            $new_hashed_password = password_hash($new_password, PASSWORD_ARGON2ID);

            // Update the password
            $update_stmt = $conn->prepare("UPDATE users2 SET password = ? WHERE username = ?");
            $update_stmt->bind_param("ss", $new_hashed_password, $input_username);

            if ($update_stmt->execute()) {
                echo "Success";
            } else {
                echo "Error updating password.";
            }
        } else {
            echo "Incorrect current password.";
        }
    } else {
        echo "User not found.";
    }
}
