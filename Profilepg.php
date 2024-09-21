<?php
// Include connection and session files
include "Connection.php";
include "SessionPG.php";

$username = $_SESSION['username'];

// Fetch user details
$sql = "SELECT Firstname, Lastname, Phone, email FROM users2 WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Details</title>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - Home</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        .container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 1000px;
            margin: 20px auto;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
        }

        .container::after {
            content: '';
            width: 1px;
            background-color: #4CAF50;
            position: absolute;
            top: 11.5%;
            bottom: 15.2%;
            left: 50%;
            transform: translateX(-50%);
        }

        .form-container {
            width: 48%;
        }

        /* Heading styles */
        h2,
        h3 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
            width: 100%;
        }

        /* Form group styles */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus {
            outline: none;
            border-color: #4CAF50;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }

        /* Button styles */
        .buttons {
            text-align: center;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin: 0 10px;
        }

        .btn:hover {
            background-color: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
        }

        .btn:active {
            transform: translateY(1px);
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        .btn:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.4);
        }

        .btn:disabled {
            background-color: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        /* Message styles */
        .message,
        #firstname-message,
        #lastname-message,
        #phone-message,
        #email-message,
        #password-message {
            display: block;
            margin-top: 5px;
            font-size: 14px;
            color: #d32f2f;
        }

        /* Media query for smaller screens */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }

            .form-container {
                width: 100%;
            }

            .btn {
                width: 100%;
                margin: 10px 0;
            }
        }
    </style>
</head>

<body>
    <div class="navbar">
        <img src="logo-no-background.png" style="height: 34px; width:auto">
        <a style="margin-left: 5px;" href="Homepg.php">Dashboard</a>
        <div class="dropdown">
            <button class="dropbtn">Reporting
                <i class="fa fa-caret-down"></i>
            </button>
            <div class="dropdown-content">
                <a href="BSpg.php">Balance Sheet</a>
                <a href="PandLpg.php">Profit and Loss</a>
                <a href="TrialBalancepg.php">Trial Balance</a>
                <a href="AccountStatement.php">Account Statement</a>
            </div>
        </div>
        <a href="view_company_info.php">General Settings</a>

        <a href="Profilepg.php">Profile</a>
        <a href="logout.php">Logout</a>

    </div>
    <br>
    <div class="container">
        <div class="form-container">
            <h2>User Details</h2>

            <form id="userForm">
                <div class="form-group">
                    <label for="firstname">First Name:</label>
                    <input type="text" id="firstname" name="firstname" value="<?php echo htmlspecialchars($user['Firstname']); ?>" disabled onkeyup="validateName('firstname','firstname-message')">
                    <span id="firstname-message"></span>
                </div>
                <div class="form-group">
                    <label for="lastname">Last Name:</label>
                    <input type="text" id="lastname" name="lastname" value="<?php echo htmlspecialchars($user['Lastname']); ?>" disabled onkeyup="validateName('lastname','lastname-message')">
                    <span id="lastname-message"></span>
                </div>
                <div class="form-group">
                    <label for="phone">Phone:</label>
                    <input type="text" id="phone" name="phone" value="<?php echo htmlspecialchars($user['Phone']); ?>" disabled onkeyup="validatePhone()">
                    <span id="phone-message" class="message"></span>
                </div>
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($user['email']); ?>" disabled onkeyup="validateEmail()">
                    <span id="email-message" class="message"></span>
                </div>

                <div class="buttons">
                    <button type="button" id="editBtn" class="btn">Edit</button>
                    <button type="submit" id="saveBtn" class="btn" disabled>Save</button>
                </div>
            </form>
        </div>


        <div class="form-container">
            <h2>Change Password</h3>
                <form id="passwordForm">
                    <div class="form-group">
                        <label for="current_password">Current Password:</label>
                        <input type="password" id="current_password" name="current_password">
                    </div>
                    <div class="form-group">
                        <label for="new_password">New Password:</label>
                        <input type="password" id="new_password" name="new_password" oninput="validatePassword()">
                        <span id="password-message"></span>
                    </div>
                    <div class="buttons">
                        <button type="submit" id="changePasswordBtn" class="btn">Change Password</button>
                    </div>
                </form>
        </div>
    </div>


    <script src="scripts.js"></script>
    <script>
        const editBtn = document.getElementById('editBtn');
        const saveBtn = document.getElementById('saveBtn');
        const formInputs = document.querySelectorAll('#userForm input');

        editBtn.addEventListener('click', function() {
            formInputs.forEach(input => input.disabled = false);
            saveBtn.disabled = false;
            editBtn.disabled = true;
        });

        document.getElementById('userForm').addEventListener('submit', function(event) {
            event.preventDefault(); // Prevent page reload
            const formData = new FormData(this);

            fetch('update_user.php', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.text())
                .then(data => {
                    alert('Details updated successfully!');
                    formInputs.forEach(input => input.disabled = true);
                    saveBtn.disabled = true;
                    editBtn.disabled = false;
                    location.reload();
                })
                .catch(error => console.error('Error:', error));
        });

        document.getElementById('passwordForm').addEventListener('submit', function(event) {
            event.preventDefault(); // Prevent page reload
            const formData = new FormData(this);

            if (validPassword) {
                fetch('change_password.php', {
                        method: 'POST',
                        body: formData
                    })
                    .then(response => response.text())
                    .then(data => {
                        if (data === 'Success') {
                            alert('Password changed successfully!');
                            document.getElementById('passwordForm').reset();
                            location.reload();
                        } else {
                            alert(data); // Error message
                        }
                    })
                    .catch(error => console.error('Error:', error));
            } else {
                alert("Please enter a valid password.");
            }
        });

        function validatePassword() {
            const password = document.getElementById('new_password').value;
            const message = document.getElementById('password-message');
            const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$/;

            if (password === "") {
                message.textContent = "Password must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
                message.style.color = 'black';
            } else if (regex.test(password)) {
                message.textContent = 'Valid Password';
                message.style.color = 'green';
                validPassword = 1;
            } else {
                message.textContent = "Invalid Password. It must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
                message.style.color = 'red';
                validPassword = 0;
            }
        }
    </script>

</body>

</html>