<?php
include "Connection.php";
$sql = "SELECT userId, Firstname, LastName, username, Phone, email, user_type FROM users2";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Accounting - Home</title>
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
        }

        .navbar a,
        .navbar .dropbtn {
            color: white;
            text-align: center;
            padding: 14px 20px;
            text-decoration: none;
            font-size: 16px;
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

        .navbar a:last-child {
            margin-left: auto;
        }

        .save-btn {
            display: none;
            margin-left: 5px;
            padding: 2px 5px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
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

    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Username</th>
                <th>Phone</th>
                <th>Email</th>
                <th>User Type</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($result->num_rows > 0) {
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . $row["userId"] . "</td>";
                    echo "<td>" . $row["Firstname"] . "</td>";
                    echo "<td>" . $row["LastName"] . "</td>";
                    echo "<td>" . $row["username"] . "</td>";
                    echo "<td>" . $row["Phone"] . "</td>";
                    echo "<td>" . $row["email"] . "</td>";
                    echo "<td class='editable' data-user-id='" . $row["userId"] . "'>" . $row["user_type"] . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='7'>0 results</td></tr>";
            } ?>
        </tbody>
    </table>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const table = document.querySelector('table');
            const userTypes = ['Admin', 'Bookkeeper', 'Auditor']; // Add or modify user types as needed
            let activeSelect = null;

            table.addEventListener('click', function(e) {
                const cell = e.target.closest('td');
                if (!cell) return; // Clicked outside of a cell

                const row = cell.parentElement;
                const userTypeIndex = Array.from(row.cells).indexOf(cell);

                // Check if the clicked cell is in the user_type column (last column)
                if (userTypeIndex === row.cells.length - 1 && !cell.classList.contains('admin-type')) {
                    if (activeSelect && activeSelect !== cell) {
                        // If there's an active select in another cell, revert it
                        revertSelect(activeSelect);
                    }

                    if (!cell.querySelector('select')) {
                        const currentValue = cell.textContent.trim();

                        // Create select element
                        const select = document.createElement('select');
                        userTypes.forEach(type => {
                            const option = document.createElement('option');
                            option.value = type;
                            option.textContent = type;
                            if (type === currentValue) {
                                option.selected = true;
                            }
                            select.appendChild(option);
                        });

                        // Create save button
                        const saveBtn = document.createElement('button');
                        saveBtn.textContent = 'Save';
                        saveBtn.classList.add('save-btn');

                        // Replace cell content with select and save button
                        cell.textContent = '';
                        cell.appendChild(select);
                        cell.appendChild(saveBtn);

                        // Focus on the select
                        select.focus();

                        // Set this as the active select
                        activeSelect = cell;

                        // Handle selection
                        select.addEventListener('change', function() {
                            saveBtn.style.display = 'inline-block';
                        });

                        // Handle save
                        saveBtn.addEventListener('click', function() {
                            const newValue = select.value;
                            const userId = cell.dataset.userId;
                            updateUserType(userId, newValue, cell);
                        });
                    }
                } else if (activeSelect) {
                    // If clicked outside the user type column and there's an active select, revert it
                    revertSelect(activeSelect);
                }
            });

            // Handle clicks outside the table
            document.addEventListener('click', function(e) {
                if (!table.contains(e.target) && activeSelect) {
                    revertSelect(activeSelect);
                }
            });

            function revertSelect(cell, value = null) {
                const select = cell.querySelector('select');
                const saveBtn = cell.querySelector('.save-btn');
                if (select) {
                    cell.textContent = value || select.value;
                }
                if (saveBtn) {
                    saveBtn.remove();
                }
                activeSelect = null;
            }

            function updateUserType(userId, userType, cell) {
                fetch('update_user_type.php', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: `userId=${userId}&userType=${userType}`
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            revertSelect(cell, userType);
                            // Optionally, you can add a visual feedback here (e.g., flash the cell green)
                        } else {
                            alert('Failed to update user type: ' + data.message);
                            revertSelect(cell);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('An error occurred while updating the user type.');
                        revertSelect(cell);
                    });
            }
        });
    </script>

    <?php $conn->close(); ?>
</body>

</html>