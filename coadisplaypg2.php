<?php
// Database connection details (replace with your credentials)
include "Connection.php";
include "SessionPG.php";
if ($_SESSION['user_type'] == "Auditor") {
    // Redirect to login page if not logged in
    $_SESSION['message'] = "Access denied. Auditors are not allowed to view the Chart of Accounts page.";
    header("Location: Homepg.php");
    exit();
}

//include "Permission.php";
?>
<?php
// Get the selected CategoryID from the GET request
$selectedCategoryID = isset($_GET['CategoryID']) ? $_GET['CategoryID'] : '';

// Fetch unique CategoryIDs to create filter buttons
$categorySql = "SELECT DISTINCT CategoryID, CategoryName  FROM accountmaster ORDER BY CategoryID";

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

        .tooltip-container {
            position: relative;
            display: inline-block;
        }

        .tooltiptext {
            visibility: hidden;
            width: 300px;
            background-color: rgba(0, 0, 0, 0.8);
            color: #fff;
            text-align: left;
            border-radius: 6px;
            padding: 10px;
            position: absolute;
            z-index: 1;
            top: -140%;
            /* Position it above the input */
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            transition: opacity 0.3s ease, visibility 0.3s ease;
            font-size: 14px;
            line-height: 1.4;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            pointer-events: none;
            /* Prevent interfering with input field */
        }

        /* Tooltip arrow */
        .tooltiptext::after {
            content: "";
            position: absolute;
            bottom: -10px;
            /* Position below the tooltip */
            left: 50%;
            transform: translateX(-50%);
            border-width: 8px;
            border-style: solid;
            border-color: rgba(0, 0, 0, 0.8) transparent transparent transparent;
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
              <td> <input type="text" name="AccountNo" placeholder="Enter Account No." onfocus="showGuideline(this)" onblur="hideGuideline(this); validateAccountNo(this)" id="accountNoInput">
    <div class="tooltip-container">
        <span class="tooltiptext" id="accountNoGuideline">
            Account Number Guideline:
            <br> 1xxxxx: Asset accounts
            <br> 2xxxxx: Liability accounts
            <br> 3xxxxx: Capital accounts
            <br> 4xxxxx: Income accounts
            <br> 5xxxxx: Expense accounts
            <br> Please select an appropriate prefix based on the account type.
        </span>
    </div>
</td>
        <td><input type="text" name="AccountName" placeholder="Enter Account Name"></td>
                <td><select name="SubcategoryName" id="subcategoryDropdown">
                    <option value="">Select Subcategory</option>
                </select></td>
                <td colspan="4"><span class="error-message"></span></td>
            `;

            table.insertBefore(newRow, table.firstChild);
            fetchSubcategories();
            document.getElementById("saveButton").style.display = "inline-block";
        }

        function showGuideline(input) {
            var guideline = document.getElementById('accountNoGuideline');
            guideline.style.visibility = 'visible';
            guideline.style.opacity = '1';
        }

        function hideGuideline(input) {
            var guideline = document.getElementById('accountNoGuideline');
            guideline.style.visibility = 'hidden';
            guideline.style.opacity = '0';
        }

        function fetchSubcategories() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "fetch_subcategories.php", true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var subcategories = JSON.parse(xhr.responseText);
                    var dropdown = document.getElementById("subcategoryDropdown");
                    var currentCategory = null;
                    subcategories.forEach(function(subcategory) {
                        // Add non-clickable headers before each new category
                        if (subcategory.CategoryID != currentCategory) {
                            currentCategory = subcategory.CategoryID;

                            var nonClickableOption = document.createElement("option");
                            nonClickableOption.disabled = true;
                            nonClickableOption.style.fontWeight = "bold"; // Optional: Bold the category title
                            nonClickableOption.style.backgroundColor = "#f0f0f0"; // Optional: Gray background

                            if (currentCategory == 1) {
                                nonClickableOption.text = "Assets";
                            } else if (currentCategory == 2) {
                                nonClickableOption.text = "Liabilities";
                            } else if (currentCategory == 3) {
                                nonClickableOption.text = "Capital";
                            } else if (currentCategory == 4) {
                                nonClickableOption.text = "Income";
                            } else if (currentCategory == 5) {
                                nonClickableOption.text = "Expenses";
                            }

                            dropdown.add(nonClickableOption);
                        }

                        // Add clickable subcategory option
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
            var hasErrors = false;
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
                } else {
                    hasErrors = true;
                }
            });

            if (hasErrors) {
                alert("Please correct all errors before saving.");
                return;
            }

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


        function validateAccountNo(input) {
            const accountNo = parseInt(input.value);
            const errorSpan = input.closest('tr').querySelector('.error-message');

            if (isNaN(accountNo) || accountNo < 10000 || accountNo > 60000) {
                showError(input, errorSpan, 'Account No. must be between 10000 and 60000.');
                return;
            }

            // Check if account number already exists
            fetch('CheckAccountNo.php?AccountNo=' + accountNo)
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        showError(input, errorSpan, 'Account No. is already used.');
                    } else {
                        clearError(input, errorSpan);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }

        function showError(input, errorSpan, message) {
            input.style.border = '2px solid red';
            errorSpan.textContent = message;
            errorSpan.style.color = 'red';
        }

        function clearError(input, errorSpan) {
            input.style.border = '';
            errorSpan.textContent = '';
        }
    </script>
    <span class="section-heading">Chart Of Accounts</span>
    <div class="filter-buttons">

        <?php
        // Display buttons for each CategoryID
        if ($categoryResult->num_rows > 0) {
            while ($categoryRow = $categoryResult->fetch_assoc()) {
                $categoryID = $categoryRow['CategoryID'];
                $categoryName = $categoryRow['CategoryName'];
                echo "<button onclick=\"window.location.href='?CategoryID=$categoryID'\">Category $categoryID $categoryName</button>";
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