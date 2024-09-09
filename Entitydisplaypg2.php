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



        /* Common Button Styles */
        .table-button {
            vertical-align: middle;
            padding: 8px 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            /* Rounded corners */
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s, transform 0.2s;
            /* Smooth transitions */
            margin: 4px;
            /* Space between buttons */
        }

        .table-button:hover {
            background-color: #45a049;
            /* Darken on hover */
            transform: translateY(-2px);
            /* Slight lift on hover */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            /* Shadow effect */
        }

        /* Edit Button Specific Style */
        .table-button.edit {
            background-color: #ffa500;
            /* Orange color for edit */
        }

        .table-button.edit:hover {
            background-color: #ff8c00;
            /* Darker orange on hover */
        }

        .table-button.save {
            background-color: #ffa500;
            /* Orange color for save */
        }

        .table-button.save:hover {
            background-color: #ff8c00;
            /* Darker orange on hover */
        }
    </style>
    <script>
        function addNewRow() {
            // Get reference to the table's tbody
            var table = document.querySelector("table tbody");

            // Create a new row
            var newRow = document.createElement("tr");

            // Create the input field for 'Entity Id'
            var entityIdCell = document.createElement("td");
            var entityIdInput = document.createElement("input");
            entityIdInput.type = "text";
            entityIdInput.placeholder = "Enter entity id";
            entityIdCell.appendChild(entityIdInput);
            newRow.appendChild(entityIdCell);

            // Create the select field for 'Type'
            var typeCell = document.createElement("td");
            var typeSelect = document.createElement("select");
            var option1 = document.createElement("option");
            option1.value = "Customer";
            option1.text = "Customer";
            var option2 = document.createElement("option");
            option2.value = "Supplier";
            option2.text = "Supplier";
            typeSelect.appendChild(option1);
            typeSelect.appendChild(option2);
            typeCell.appendChild(typeSelect);
            newRow.appendChild(typeCell);

            // Create the select field for 'Account'
            var accountCell = document.createElement("td");
            var accountSelect = document.createElement("select");
            accountSelect.innerHTML = "<option value=''>Loading...</option>";
            loadAccounts(accountSelect); // Call function to load accounts from the database
            accountCell.appendChild(accountSelect);
            newRow.appendChild(accountCell);

            // Create the input field for 'Name'
            var nameCell = document.createElement("td");
            var nameInput = document.createElement("input");
            nameInput.type = "text";
            nameInput.placeholder = "Enter the name";
            nameCell.appendChild(nameInput);
            newRow.appendChild(nameCell);

            // Create the input field for 'Mobile no.'
            var mobileCell = document.createElement("td");
            var mobileInput = document.createElement("input");
            mobileInput.type = "text";
            mobileInput.placeholder = "Enter the mobile no.";
            mobileCell.appendChild(mobileInput);
            newRow.appendChild(mobileCell);

            // Create the input field for 'Email'
            var emailCell = document.createElement("td");
            var emailInput = document.createElement("input");
            emailInput.type = "text";
            emailInput.placeholder = "Enter the email";
            emailCell.appendChild(emailInput);
            newRow.appendChild(emailCell);

            // Append the new row to the table
            table.appendChild(newRow);

            // Show the save button
            document.getElementById("saveButton").style.display = "inline";
        }

        // Function to load accounts from the database
        function loadAccounts(selectElement) {
            // Using XMLHttpRequest to POST to the server
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "get_accounts.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    try {
                        var accounts = JSON.parse(xhr.responseText);

                        // Clear the loading option
                        selectElement.innerHTML = "";
                        var placeholderOption = document.createElement("option");
                        placeholderOption.value = "";
                        placeholderOption.text = "Select an account";
                        placeholderOption.disabled = true;
                        placeholderOption.selected = true;
                        selectElement.appendChild(placeholderOption);

                        accounts.forEach(function(account) {
                            var option = document.createElement("option");
                            option.value = account.id;
                            option.text = account.name;
                            selectElement.appendChild(option);
                        });
                    } catch (e) {
                        console.error("Error parsing JSON response: " + e.message);
                    }
                }
            };

            xhr.send(); // No data needed for this request
        }

        function saveNewRows() {
            // Collect all new rows from the table
            var table = document.querySelector("table tbody");
            var newRows = table.querySelectorAll("tr");
            var rowsData = [];

            // Iterate over each row to collect data
            newRows.forEach(function(row) {
                // Initialize variables for each field, defaulting to an empty string
                var entityIdInput = row.querySelector("td:nth-child(1) input");
                var typeSelect = row.querySelector("td:nth-child(2) select");
                var accountSelect = row.querySelector("td:nth-child(3) select");
                var nameInput = row.querySelector("td:nth-child(4) input");
                var mobileInput = row.querySelector("td:nth-child(5) input");
                var emailInput = row.querySelector("td:nth-child(6) input");

                // Check if the elements exist before accessing their value
                var rowData = {
                    entityId: entityIdInput ? entityIdInput.value : "",
                    type: typeSelect ? typeSelect.value : "",
                    account: accountSelect ? accountSelect.value : "",
                    name: nameInput ? nameInput.value : "",
                    mobile: mobileInput ? mobileInput.value : "",
                    email: emailInput ? emailInput.value : ""
                };

                // Push only if at least one field is filled to avoid empty rows
                if (rowData.entityId || rowData.type || rowData.account || rowData.name || rowData.mobile || rowData.email) {
                    rowsData.push(rowData);
                }
            });

            // Log the rowsData array to check the collected values
            rowsData.forEach(function(row) {
                console.log("Entity Id: " + row.entityId);
                console.log("Type: " + row.type);
                console.log("Account: " + row.account);
                console.log("Name: " + row.name);
                console.log("Mobile: " + row.mobile);
                console.log("Email: " + row.email);
                console.log("-----"); // Separator for better readability
            });




            //console.log("Rows Data: ", rowsData);
            // Send the data to the server using AJAX
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "save_entity.php", true);
            xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    console.log("AJAX request completed");
                    if (xhr.status == 200) {
                        var response = JSON.parse(xhr.responseText);
                        if (response.status === "success") {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert("Error: " + response.message);
                        }
                    } else {
                        console.error("Error with AJAX request. Status: " + xhr.status);
                    }
                }
            };
            xhr.send(JSON.stringify(rowsData));
        };


        function enterEditMode(row) {
            // Enter edit mode for a specific row
            var typeCell = row.querySelector("td:nth-child(2)");
            var nameCell = row.querySelector("td:nth-child(4)");
            var mobileCell = row.querySelector("td:nth-child(5)");
            var emailCell = row.querySelector("td:nth-child(6)");

            // Replace text with input fields or dropdowns for editing
            typeCell.innerHTML = `<select>
                                    <option value="Customer">Customer</option>
                                    <option value="Supplier">Supplier</option>
                                  </select>`;
            nameCell.innerHTML = `<input type="text" value="${nameCell.textContent.trim()}">`;
            mobileCell.innerHTML = `<input type="text" value="${mobileCell.textContent.trim()}">`;
            emailCell.innerHTML = `<input type="text" value="${emailCell.textContent.trim()}">`;

            // Add a "Save" button to the row
            var saveButton = document.createElement("button");
            saveButton.textContent = "Save";
            saveButton.classList.add("table-button", "save"); // Add both classes
            saveButton.style.height = "32px";
            saveButton.onclick = function() {
                saveRow(row);
            };
            row.appendChild(saveButton);
        }

        function saveRow(row) {
            var entityId = row.querySelector("td:nth-child(1)").textContent.trim();
            var type = row.querySelector("td:nth-child(2) select").value;
            var name = row.querySelector("td:nth-child(4) input").value;
            var mobile = row.querySelector("td:nth-child(5) input").value;
            var email = row.querySelector("td:nth-child(6) input").value;

            // Send data to the server to update the row
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "update_entity.php", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var response = JSON.parse(xhr.responseText);
                    if (response.status === "success") {
                        alert(response.message);
                        location.reload(); // Reload the page to see the changes
                    } else {
                        alert("Error: " + response.message);
                    }
                }
            };
            xhr.send("entityId=" + entityId + "&type=" + type + "&name=" + name + "&mobile=" + mobile + "&email=" + email);
        }
    </script>
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

    <div class="filter-buttons">
        <button class="new-button"
            onclick="addNewRow()"> New </button>
        <button class="save-button"
            id="saveButton"
            style="display:none;"
            onclick="saveNewRows()"> Save </button>
    </div>
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
                    echo "<td><button class='table-button edit' onclick='enterEditMode(this.parentNode.parentNode)'>Edit</button></td>";
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