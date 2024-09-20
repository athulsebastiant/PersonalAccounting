<?php
session_start();
if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    header("Location: loginpg2.php");
    exit();
}
// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ac2";
$tableName = "jrlmaster"; // Replace with your table name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$t2 = "jrldetailed";
// SQL query to fetch data from the table
$sql = "SELECT jdate, $tableName.EntryID, $tableName.description, sum($t2.CreditAmount) AS 'Total', $tableName.createdBy, $tableName.createdDateTime, $tableName.modifiedBy, $tableName.modifiedDateTime FROM $tableName
INNER JOIN $t2 ON
$tableName.EntryID = $t2.EntryID group by $tableName.EntryID";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }

        tr:hover {
            background-color: #f5f5f5;
            cursor: pointer;
        }

        thead {
            background-color: #4CAF50;
        }

        th,
        td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        th {
            background-color: #4CAF50;
            color: #f9f9f9;
            /* Slightly darker background */
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .navbar {
            background-color: #333;
            overflow: hidden;
            display: flex;
            align-items: center;
            font-family: Arial, sans-serif;
            /* Set a consistent font */
        }

        .navbar a,
        .navbar .dropbtn {
            color: white;
            text-align: center;
            padding: 14px 20px;
            /* Increased horizontal padding */
            text-decoration: none;
            font-size: 16px;
            /* Consistent font size */
        }

        .dropdown {
            overflow: hidden;
        }

        .dropdown .dropbtn {
            border: none;
            outline: none;
            background-color: inherit;
            margin: 0;
            cursor: pointer;
        }

        .navbar a:hover,
        .dropdown:hover .dropbtn {
            background-color: #ddd;
            color: black;
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

        .dropdown-content a:hover {
            background-color: #ddd;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        /* Push logout to the right */
        .navbar a:last-child {
            margin-left: auto;
        }

        .filter-buttons {
            margin-bottom: 15px;
        }

        .filter-buttons button {
            margin-right: 10px;
            padding: 8px 16px;
            background-color: #4CAF50;
            color: #f9f9f9;
            border: none;
            cursor: pointer;
        }

        .filter-buttons button:hover {
            background-color: #45a049;
        }
    </style>
    <title>Database Table</title>
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
    <div class="filter-buttons">
        <button onclick="redirectToPage()">New</button> <span style="font-size: 20px;">Journal Entry</span>
    </div>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Number</th>
                <th>Reference</th>
                <th>Total</th>
                <th>Created By</th>
                <th>Created Date Time</th>
                <th>Modified By</th>
                <th>Modified Date Time</th>

            </tr>
        </thead>
        <tbody>
            <?php
            if ($result->num_rows > 0) {
                // Output data of each row
                while ($row = $result->fetch_assoc()) {
                    echo "<tr data-href='EachJrnlpg3.php?EntryID=" . $row['EntryID'] . "'>
                            <td>" . $row["jdate"] . "</td>
                            <td>" . $row["EntryID"] . "</td>
                            <td>" . $row["description"] . "</td>
                            <td>" . $row["Total"] . "</td>
                            <td>" . $row["createdBy"] . "</td>
                            <td>" . $row["createdDateTime"] . "</td>
                            <td>" . $row["modifiedBy"] . "</td>
                            <td>" . $row["modifiedDateTime"] . "</td>
                          </tr>";
                }
            } else {
                echo "<tr><td colspan='8'>No results found</td></tr>";
            }
            $conn->close();
            ?>
        </tbody>
    </table>

    <script>
        function redirectToPage() {
            window.location.href = 'addjrnlwithproc.php'; // Change 'newpage.html' to the URL of your choice
        }
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('tr[data-href]');
            rows.forEach(row => {
                row.addEventListener('click', function() {
                    window.location.href = this.getAttribute('data-href');
                });
            });
        });
    </script>
</body>

</html>