<?php
include "SessionPG.php";
include "Connection.php";
if (
    $_SESSION['user_type'] ==
    "Auditor" || $_SESSION['user_type'] == "Bookkeeper"
) {
    // Redirect to login page if not logged in
    header("Location: Homepg.php");
    exit();
}
?>



<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - General Settings</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        .container {
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
        }

        .form-group input[type="text"],
        .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-group textarea {
            height: 100px;
        }

        .form-group input[type="file"] {
            border: 1px solid #ddd;
            padding: 5px;
            border-radius: 4px;
        }

        .btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .btn:hover {
            background-color: #45a049;
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
        <a href="logout.php">Logout</a>
    </div>

    <div class="container">
        <h2>Company Settings</h2>
        <form id="companySettingsForm" enctype="multipart/form-data">
            <div class="form-group">
                <label for="CompanyName">Company Name:</label>
                <input name="CompanyName" type="text" placeholder="Enter your company name" required>
            </div>
            <div class="form-group">
                <label for="Address">Company Address:</label>
                <textarea name="Address" placeholder="Enter your Company address" required></textarea>
            </div>
            <div class="form-group">
                <label for="RegNo">Registration Number:</label>
                <input name="RegNo" type="text" placeholder="Enter your company registration No." required>
            </div>
            <div class="form-group">
                <label for="phn">Phone Number:</label>
                <input name="phn" type="text" placeholder="Enter your company phone number" required>
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input name="email" type="text" placeholder="Enter your company email id" required>
            </div>
            <div class="form-group">
                <label for="logo">Company Logo:</label>
                <input type="file" id="logo" name="logo" accept=".jpg,.jpeg,.png">
                <p><small>Accepted formats: JPG, PNG. Max 2MB, minimum resolution 300x300 pixels</small></p>
            </div>
            <button type="submit" class="btn">Save Settings</button>
        </form>
    </div>

    <script>
        document.getElementById('companySettingsForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const formData = new FormData(this);

            fetch('save_company_info.php', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json()) // Parse JSON response
                .then(data => {
                    console.log(data.message);
                    if (data.success) {
                        alert(data.message);
                        window.location.href = 'view_company_info.php';
                    } else {
                        alert('Error: ' + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while saving the information.');
                });
        });
    </script>
</body>

</html>