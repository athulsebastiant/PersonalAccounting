<?php
// Database connection details (replace with your credentials)
include "Connection.php";

// Get the selected CategoryID from the GET request
$selectedCategoryID = isset($_GET['CategoryID']) ? $_GET['CategoryID'] : '';

// Fetch unique CategoryIDs to create filter buttons
$categorySql = "SELECT DISTINCT CategoryID FROM coa ORDER BY CategoryID";
$categoryResult = $conn->query($categorySql);

// SQL query to fetch account information
$sql = "SELECT coa.AccountNo, coa.AccountName, accountsub.SubcategoryName
        FROM coa
        LEFT JOIN accountsub ON coa.CategoryID = accountsub.CategoryID AND coa.SubcategoryID = accountsub.SubcategoryID";

if ($selectedCategoryID) {
    $sql .= " WHERE coa.CategoryID = '" . $conn->real_escape_string($selectedCategoryID) . "'";
}

$sql .= " ORDER BY coa.AccountNo";

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
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
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
</head>

<body>
    <script>
        function addNewRow() {
            var table = document.querySelector("table tbody");
            var newRow = document.createElement("tr");
            newRow.className = "new-row";
            newRow.innerHTML = `
                <td><input type="text" name="AccountNo" placeholder="Enter Account No."></td>
                <td><input type="text" name="AccountName" placeholder="Enter Account Name"></td>
                <td><select name="SubcategoryName" id="subcategoryDropdown">
                    <option value="">Select Subcategory</option>
                </select></td>
            `;

            table.insertBefore(newRow, table.firstChild);
            fetchSubcategories();
            document.getElementById("saveButton").style.display = "inline-block";
        }

        function fetchSubcategories() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "fetch_subcategories.php", true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var subcategories = JSON.parse(xhr.responseText);
                    var dropdown = document.getElementById("subcategoryDropdown");

                    subcategories.forEach(function(subcategory) {
                        var option = document.createElement("option");
                        option.value = subcategory.CategoryID + "," + subcategory.SubcategoryID;
                        option.text = subcategory.SubcategoryName;
                        dropdown.add(option);
                    });
                }
            };
            xhr.send();
        }

        function saveNewRows() {
            var rows = document.querySelectorAll("table tbody tr.new-row");
            var newRows = [];

            rows.forEach(function(row) {
                var accountNo = row.querySelector("input[name='AccountNo']").value;
                var accountName = row.querySelector("input[name='AccountName']").value;
                var subcategory = row.querySelector("select[name='SubcategoryName']").value;

                if (accountNo && accountName && subcategory) {
                    var [categoryID, subcategoryID] = subcategory.split(",");
                    newRows.push({
                        AccountNo: accountNo,
                        AccountName: accountName,
                        CategoryID: categoryID,
                        SubcategoryID: subcategoryID
                    });
                }
            });

            if (newRows.length > 0) {
                var xhr = new XMLHttpRequest();
                xhr.open("POST", "insert_account.php", true);
                xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == 4 && xhr.status == 200) {
                        alert("Data saved successfully!");
                        location.reload();
                    }
                };
                xhr.send(JSON.stringify(newRows));
            } else {
                alert("Please fill in all fields.");
            }
        }
    </script>
    <div class="filter-buttons">
        <?php
        // Display buttons for each CategoryID
        if ($categoryResult->num_rows > 0) {
            while ($categoryRow = $categoryResult->fetch_assoc()) {
                $categoryID = $categoryRow['CategoryID'];
                echo "<button onclick=\"window.location.href='?CategoryID=$categoryID'\">Category $categoryID</button>";
            }
        }
        ?>
        <!-- Button to reset the filter -->
        <button onclick="window.location.href='?'">Show All</button>
        <!-- New button to add a new row -->
        <button class="new-button" onclick="addNewRow()">New</button>
        <button class="save-button" id="saveButton" style="display:none;" onclick="saveNewRows()">Save</button>
    </div>

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