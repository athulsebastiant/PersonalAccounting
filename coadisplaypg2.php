<?php
// Database connection details (replace with your credentials)
include "Connection.php";
include "SessionPG.php";
if ($_SESSION['user_type'] == "Auditor") {
    // Redirect to login page if not logged in
    header("Location: Homepg.php");
    exit();
}

//include "Permission.php";
?>
<?php
// Get the selected CategoryID from the GET request
$selectedCategoryID = isset($_GET['CategoryID']) ? $_GET['CategoryID'] : '';

// Fetch unique CategoryIDs to create filter buttons
$categorySql = "SELECT DISTINCT CategoryID FROM coa ORDER BY CategoryID";
$categoryResult = $conn->query($categorySql);

// SQL query to fetch account information
$sql = "SELECT coa.AccountNo, coa.AccountName, accountsub.SubcategoryName, coa.createdBy, coa.createdDateTime, coa.modifiedBy, coa.modifiedDateTime
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
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - Chart of Accounts</title>
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
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .filter-buttons button {
            margin-left: 5px;
            padding: 10px 16px;
            background-color: #4CAF50;
            color: #f9f9f9;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        /* Filter buttons container */
        .filter-buttons {
            margin-bottom: 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        /* Filter buttons specific styles */
        .filter-buttons button {
            margin-right: 0;
            /* Remove margin-right as we're using gap */
        }


        /* Hover effects for all buttons */
        .filter-buttons button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
        }

        /* Active effects for all buttons */
        .filter-buttons button:active {
            transform: translateY(1px);
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        /* Focus styles for accessibility */
        .filter-buttons button:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.4);
        }

        /* Media query for smaller screens */
        @media (max-width: 600px) {
            .filter-buttons {
                flex-direction: column;
                align-items: stretch;
            }

            .filter-buttons button {
                width: 100%;
                margin-right: 0;
                margin-bottom: 10px;
            }
        }

        .section-heading {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin: 20px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #4CAF50;
            display: inline-block;
            font-family: Arial, sans-serif;
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
        <a href="logout.php">Logout</a>
    </div>
    <br>

    <script>
        let isEditMode = false;

        function toggleEditMode() {
            isEditMode = !isEditMode;
            const editButton = document.querySelector(".edit-button");
            editButton.textContent = isEditMode ? "Save Changes" : "Edit";

            const accountNameCells = document.querySelectorAll("table tbody tr td:nth-child(2)"); // Select Account Name cells
            accountNameCells.forEach(cell => {
                if (isEditMode) {
                    cell.setAttribute("contenteditable", "true"); // Make cell editable
                    cell.style.border = "1px solid #ccc"; // Optional: Add a border to indicate it's editable
                } else {
                    cell.removeAttribute("contenteditable"); // Make cell non-editable
                    cell.style.border = ""; // Remove border when not in edit mode
                }
            });

            // Optionally, handle any logic needed when changes are saved
            /*if (!isEditMode) {
                alert("Changes saved locally!"); // You can replace this with any action you want
            }*/
        }

        document.addEventListener("DOMContentLoaded", function() {
            // Add event listeners to editable AccountName cells
            const accountNameCells = document.querySelectorAll("table tbody tr td:nth-child(2)"); // Select Account Name cells
            accountNameCells.forEach(cell => {
                cell.addEventListener("blur", function() { // 'blur' event when the cell loses focus
                    if (isEditMode) { // Ensure we're in edit mode
                        const accountNo = this.parentElement.querySelector("td:first-child").textContent.trim();
                        const newAccountName = this.textContent.trim();

                        if (accountNo && newAccountName) {
                            // Send AJAX request to update AccountName
                            updateAccountName(accountNo, newAccountName);
                        }
                    }
                });
            });
        });

        function updateAccountName(accountNo, newAccountName) {
            fetch('update_account_name.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        AccountNo: accountNo,
                        AccountName: newAccountName
                    }),
                })
                .then(response => response.json())
                .then(result => {
                    if (result.status === 'success') {
                        alert('Account name updated successfully!');
                        toggleEditMode();
                        location.reload();
                    } else {
                        console.error('Error updating account name:', result.message);
                        alert('Failed to update account name: ' + result.message);
                    }
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    alert('Fetch error: ' + error.message);
                });
        }





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
    <span class="section-heading">Chart Of Accounts</span>
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
        <button class="edit-button" id="edit-button" onclick="toggleEditMode()">Edit</button>
    </div>

    <table>
        <thead>
            <tr>
                <th>Account No.</th>
                <th>Account Name</th>
                <th>Category Name</th>
                <th>Created By</th>
                <th>Created Date Time</th>
                <th>Modified By</th>
                <th>Modified Date Time</th>
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
                    echo "<td>" . $row["createdBy"] . "</td>";
                    echo "<td>" . $row["createdDateTime"] . "</td>";
                    echo "<td>" . $row["modifiedBy"] . "</td>";
                    echo "<td>" . $row["modifiedDateTime"] . "</td>";

                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='7'>No results found</td></tr>";
            }
            $conn->close();
            ?>
        </tbody>
    </table>
</body>

</html>