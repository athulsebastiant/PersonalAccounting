<?php
/*if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    header("Location: loginpg2.php");
    exit();
}*/
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
$sql = "SELECT jdate, $tableName.EntryID, $tableName.description, sum($t2.CreditAmount) AS 'Total', $tableName.createdBy FROM $tableName
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
            </div>
        </div>
    </div>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Number</th>
                <th>Reference</th>
                <th>Total</th>
                <th>Created By</th>
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
                          </tr>";
                }
            } else {
                echo "<tr><td colspan='4'>No results found</td></tr>";
            }
            $conn->close();
            ?>
        </tbody>
    </table>

    <script>
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