<?php
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
    </style>
    <title>Database Table</title>
</head>

<body>
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
                    echo "<tr>
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
</body>

</html>