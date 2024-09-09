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
        .editable:hover {
            background-color: #f0f0f0;
            cursor: pointer;
        }

        .save-btn {
            display: none;
            margin-left: 5px;
        }

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
                    echo "<td class='editable' data-field='Firstname' data-user-id='" . $row["userId"] . "'>" . $row["Firstname"] . "</td>";
                    echo "<td class='editable' data-field='LastName' data-user-id='" . $row["userId"] . "'>" . $row["LastName"] . "</td>";
                    echo "<td>" . $row["username"] . "</td>";
                    echo "<td class='editable' data-field='Phone' data-user-id='" . $row["userId"] . "'>" . $row["Phone"] . "</td>";
                    echo "<td class='editable' data-field='email' data-user-id='" . $row["userId"] . "'>" . $row["email"] . "</td>";
                    echo "<td class='editable' data-field='user_type' data-user-id='" . $row["userId"] . "'>" . $row["user_type"] . "</td>";
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
            let activeEdit = null;

            table.addEventListener('click', function(e) {
                const cell = e.target.closest('.editable');
                if (!cell) return; // Clicked outside of an editable cell

                if (activeEdit && activeEdit !== cell) {
                    // If there's an active edit in another cell, revert it
                    revertEdit(activeEdit);
                }

                if (!cell.querySelector('input') && !cell.querySelector('select')) {
                    const field = cell.dataset.field;
                    const currentValue = cell.textContent.trim();

                    if (field === 'user_type') {
                        createSelectElement(cell, currentValue, userTypes);
                    } else {
                        createInputElement(cell, currentValue);
                    }

                    // Create save button
                    const saveBtn = document.createElement('button');
                    saveBtn.textContent = 'Save';
                    saveBtn.classList.add('save-btn');
                    cell.appendChild(saveBtn);

                    // Set this as the active edit
                    activeEdit = cell;

                    // Handle save
                    saveBtn.addEventListener('click', function() {
                        const newValue = cell.querySelector('input, select').value;
                        const userId = cell.dataset.userId;
                        updateField(userId, field, newValue, cell);
                    });
                }
            });

            // Handle clicks outside the table
            document.addEventListener('click', function(e) {
                if (!table.contains(e.target) && activeEdit) {
                    revertEdit(activeEdit);
                }
            });

            function createInputElement(cell, value) {
                const input = document.createElement('input');
                input.type = 'text';
                input.value = value;
                cell.textContent = '';
                cell.appendChild(input);
                input.focus();
            }

            function createSelectElement(cell, value, options) {
                const select = document.createElement('select');
                options.forEach(option => {
                    const optionElement = document.createElement('option');
                    optionElement.value = option;
                    optionElement.textContent = option;
                    if (option === value) {
                        optionElement.selected = true;
                    }
                    select.appendChild(optionElement);
                });
                cell.textContent = '';
                cell.appendChild(select);
                select.focus();
            }

            function revertEdit(cell, value = null) {
                const input = cell.querySelector('input, select');
                const saveBtn = cell.querySelector('.save-btn');
                if (input) {
                    cell.textContent = value || input.value;
                }
                if (saveBtn) {
                    saveBtn.remove();
                }
                activeEdit = null;
            }

            function updateField(userId, field, value, cell) {
                fetch('update_user_field.php', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: `userId=${userId}&field=${field}&value=${value}`
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            revertEdit(cell, value);
                            // Optionally, you can add a visual feedback here (e.g., flash the cell green)
                        } else {
                            alert('Failed to update field: ' + data.message);
                            revertEdit(cell);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('An error occurred while updating the field.');
                        revertEdit(cell);
                    });
            }
        });
    </script>

    <?php $conn->close(); ?>
</body>

</html>