<?php
session_start();
if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    header("Location: loginpg2.php");
    exit();
} ?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home Page</title>
    <style>
        /* Navbar styles remain the same */
        .navbar {
            background-color: #333;
            overflow: hidden;
        }

        .navbar a {
            float: left;
            color: white;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }

        .dropdown {
            float: left;
            overflow: hidden;
        }

        .dropdown .dropbtn {
            border: none;
            outline: none;
            color: white;
            padding: 14px 16px;
            background-color: inherit;
            font-family: inherit;
            margin: 0;
        }

        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #f9f9f9;
            min-width: 160px;
            box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
            z-index: 1;
        }

        .dropdown-content a {
            float: none;
            color: black;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            text-align: left;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        /* Updated styles for square divs */
        .content-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: calc(100vh - 50px);
            /* Adjust based on navbar height */
            gap: 20px;
            /* Space between squares */
        }

        .content-div {
            width: 300px;
            /* Fixed width */
            height: 300px;
            /* Same as width to make it square */
            padding: 20px;
            border: 1px solid #ddd;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background-color: #f0f0f0;
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

        .content-div:hover {
            background-color: #e0e0e0;
            cursor: pointer;
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
            </div>
        </div>
    </div>
    <br>
    <h1>Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?> You're the <?php echo htmlspecialchars($_SESSION['user_type']); ?>!</h1>
    <br>
    <div class="content-container">
        <div class="content-div">
            <a href="jrnldisplaypgtest.php">
                <h2>Journal Entry</h2>
                <p>Click here to access Journal Entry</p>
            </a>
        </div>

        <div class="content-div">
            <a href="coadisplaypg2.php">
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
    </div>
</body>

</html>