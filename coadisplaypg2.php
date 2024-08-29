<?php
// Database connection details (replace with your credentials)
include "Connection.php";
session_start();
if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    header("Location: loginpg2.php");
    exit();
}
include "Permission.php";
?>
<?php
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

        <a href="logout.php">Logout</a>
    </div>
    <br>

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
            /*var rows = document.querySelectorAll("table tbody tr.new-row");
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
                    if (xhr.readyState == 4) {
                        if (xhr.status == 200) {
                            try {
                                var response = JSON.parse(xhr.responseText);
                                if (response.status === "success") {
                                    alert("Data saved successfully!");
                                    location.reload();
                                } else {
                                    alert("Failed to save data: " + response.message);
                                }
                            } catch (e) {
                                console.error("Server response:", xhr.responseText);
                                alert("Error parsing server response. Check console for details.");
                            }
                        } else {
                            alert("Server error: " + xhr.status);
                        }
                    }
                };
            }
                */
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
                fetch('insert_account.php', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(newRows),
                    })
                    .then(response => response.json()) // Parse the response as JSON
                    .then(result => {
                        if (result.status === 'success') {
                            alert('Data saved successfully!');
                            location.reload();
                        } else {
                            console.error('Error:', result.message);
                            alert('Failed to save data: ' + result.message);
                        }
                    })
                    .catch(error => {
                        console.error('Fetch error:', error);
                        alert('Fetch error: ' + error.message);
                    });
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