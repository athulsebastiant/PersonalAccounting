<?php
include "SessionPG.php";
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/x-icon" href="favicon.ico">
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
            gap: 30px;
            /* Increased gap for better spacing */
        }

        .content-div {
            width: 320px;
            /* Slightly increased for a more balanced look */
            height: 320px;
            padding: 25px;
            /* Added padding for a cleaner layout */
            border: 1px solid #ddd;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background-color: rgba(255, 255, 255, 0.92);
            border-radius: 10px;
            /* Added border-radius for softer edges */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            /* Subtle shadow for depth */
            transition: all 0.3s ease;

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

        .content-div h2,
        .content-div p {

            margin: 0;
            padding: 5px 0;
            /* Consistent spacing between elements */
            font-weight: 600;
            /* Consistent boldness */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            /* Modern font */
        }

        .content-div h2 {
            height: 40px;
            /* Ensures the same height for all h2 */
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 24px;
            /* Larger heading for prominence */
            color: #4CAF50;
            text-shadow: 1px black;
        }

        .content-div p {
            font-size: 16px;
            color: #555;
            /* Subtle color for body text */
        }

        .content-div:hover {
            background-color: rgba(240, 240, 240, 0.9);
            /* Lighter hover effect while keeping transparency */
            cursor: pointer;
            transform: scale(1.03);
            /* Slight zoom effect on hover */
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
            /* Increased shadow on hover */
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

    <h1>Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?>. You're the <span style="color: gold;"><?php echo htmlspecialchars($_SESSION['user_type']); ?></span>!</h1>
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
                <h2 style="margin-top: 23px;">Chart of Accounts</h2>
                <p>Click here to access Chart of Accounts</p>
            </a>
        </div>

        <div class="content-div">
            <a href="Entitydisplaypg.php">
                <h2 style="margin-top: 32px;">Manage Account Entities</h2>
                <p>Click here to access Entities</p>
            </a>
        </div>

        <div class="content-div">
            <a href="UserControl.php">
                <h2 style="margin-top: 5px;">Manage User Privileges</h2>
                <p>Click here to access User Privileges</p>
            </a>
        </div>
    </div>

</body>

</html>