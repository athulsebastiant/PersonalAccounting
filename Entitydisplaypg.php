<?php

include "Connection.php";

// SQL query to fetch data
$sql = "SELECT 
    e.EntityId, 
    e.type, 
    e.AccountNo, 
    c.AccountName,
    e.name, 
    e.mobileNo, 
    e.email
FROM 
    entity e
JOIN 
    coa c 
ON 
    e.AccountNo = c.AccountNo;";
$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html>

<head>
    <title>Entity Table</title>
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
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
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
    <script>
        function addNewRow() {
            var table = document.querySelector("table tbody");
            var newRow = document.createElement("tr");
            newRow.className = "new-row";
            newRow.innerHTML = `
        <td><input type="text" name="EntityID" placeholder="Enter Entity Id"></td>
        <td><select name="type" id="typeDropdown">
                <option value="Customer">Customer</option>
                <option value="Supplier">Supplier</option>

            </select></td>
        <td class='editableAccount'></td>
        <td><input type="text" name="name" placeholder="Enter Name of entity"></td>
        <td><input type="text" name="mobileNo" placeholder="Enter mobileNo"></td>
        <td><input type="text" name="email" placeholder="Enter email id"></td>
        `;

            table.insertBefore(newRow, table.firstChild);
            fetchSubcategories();
            document.getElementById("saveButton").style.display = "inline-block";
        }
    </script>
</head>

<body>
    <button class="new-button"
        onclick="addNewRow()"> New </button>
    <button class="save-button"
        id="saveButton"
        style="display:none;"
        onclick="saveNewRows()"> Save </button>
    <table>
        <thead>
            <tr>
                <th> Entity Id </th>
                <th> Type </th>
                <th> Account </th>
                <th> Name </th>
                <th> Mobile no. </th>
                <th> Email </th>
            </tr>
        </thead>
        <tbody>
            <?php
            if ($result->num_rows > 0) {
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . $row["EntityId"] . "</td>";
                    echo "<td>" . $row["type"] . "</td>";
                    echo "<td>" . htmlspecialchars($row['AccountNo']) . " - " . htmlspecialchars($row['AccountName']) . "</td>";
                    echo "<td>" . $row["name"] . "</td>";
                    echo "<td>" . $row["mobileNo"] . "</td>";
                    echo "<td>" . $row["email"] . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='5'>No data found</td></tr>";
            }
            $conn->close();
            ?> </tbody>
    </table>
</body>

</html>