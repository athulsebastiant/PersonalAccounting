<?php
// Database connection details (replace with your credentials)
include "Connection.php";

// SQL query
$sql = "SELECT coa.AccountNo, coa.AccountName, accountsub.SubcategoryName
FROM coa
LEFT JOIN accountsub ON coa.CategoryID = accountsub.CategoryID AND coa.SubcategoryID = accountsub.SubcategoryID
        ORDER BY 
            coa.AccountNo";

$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html>

<head>
    <title>Account Information</title>
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
    </style>
</head>

<body>
    <table>
        <thead>
            <tr>
                <th>Account No.</th>
                <th>Account Name</th>
                <th>Category Name</th>
            </tr>
        </thead>
        <tbody>
            <?php
            if ($result->num_rows > 0) {
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . $row["AccountNo"] . "</td>";
                    echo "<td>" . $row["AccountName"] . "</td>";
                    echo "<td>" . $row["SubcategoryName"] . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='3'>No results found</td></tr>";
            }
            $conn->close();
            ?>
        </tbody>
    </table>
</body>

</html>