<?php
include "SessionPG.php";
include "Connection.php";
if ($_SESSION['user_type'] == "Auditor") {
    // Redirect to login page if not logged in
    header("Location: Homepg.php");
    exit();
}
// Database configuration
$tableName = "jrlmaster";
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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
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


        .filter-buttons {
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }

        .filter-buttons button {
            margin-left: 5px;
            margin-right: 15px;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: #f9f9f9;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease, transform 0.1s ease;
        }

        .filter-buttons button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
        }

        .filter-buttons button:active {
            transform: translateY(1px);
        }

        .filter-buttons span {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-left: 5px;
        }
    </style>
    <title>Database Table</title>
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