<?php
include "SessionPG.php";
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Accounting - Home</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        body {
            background-image: url('HomeImage.png');
            background-size: 100% 100%;
            /* Ensures the image scales to cover both width and height */
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        .content-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: calc(100vh - 50px);
            gap: 20px;


        }

        .content-div {
            width: 300px;
            height: 300px;
            padding: 20px;
            border: 1px solid #ddd;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background-color: #f0f0f0;
            transition: background-color 0.3s ease;
            background-color: rgba(255, 255, 255, 0.92);
        }

        .content-div a {
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            width: 100%;
            height: 100%;
        }

        .content-div h2 {
            color: #4CAF50;
        }

        .content-div:hover {
            background-color: #e0e0e0;
            cursor: pointer;
        }

        h1 {
            text-align: center;
            color: white;
            text-shadow: 1px 1px 3px black;
        }
    </style>
</head>

<body>

    <div class="navbar">
        <a href="Homepg.php">Dashboard</a>
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
    <br>

    <h1>Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?>. You're the <?php echo htmlspecialchars($_SESSION['user_type']); ?>!</h1>
    <br>
    <div class="content-container">
        <div class="content-div">
            <a href="jrnldisplaypgtest.php">
                <h2>Journal Entry</h2>
                <p>Click here to access Journal Entry</p>
            </a>
        </div>

        <div class="content-div">
            <a href="coadisplaypg2.php" id="getme">
                <h2>Chart of Accounts</h2>
                <p>Click here to access Chart of Accounts</p>
            </a>
        </div>

        <div class="content-div">
            <a href="Entitydisplaypg.php">
                <h2>Manage Account Entities</h2>
                <p>Click here to access Entities</p>
            </a>
        </div>

        <div class="content-div">
            <a href="UserControl.php">
                <h2>Manage User Privileges</h2>
                <p>Click here to access User Privileges</p>
            </a>
        </div>
    </div>

</body>

</html>