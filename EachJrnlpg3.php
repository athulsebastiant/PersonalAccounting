<?php
// Database configuration
include "SessionPG.php";
include "Connection.php";
if ($_SESSION['user_type'] == "Auditor") {
    // Redirect to login page if not logged in
    $_SESSION['message'] = "Access denied. Auditors are not allowed to view the Journal page.";
    header("Location: Homepg.php");
    exit();
}
// Fetch EntryID from query parameter
if (isset($_GET['EntryID'])) {
    // Retrieve the EntryID from the URL
    $entry_id = $_GET['EntryID'];

    // Fetch jrlmaster data
    $sql_master = "SELECT EntryID, jdate, description FROM jrlmaster WHERE EntryID = ?";
    $stmt_master = $conn->prepare($sql_master);
    $stmt_master->bind_param("i", $entry_id);
    $stmt_master->execute();
    $result_master = $stmt_master->get_result();
    $master_data = $result_master->fetch_assoc();
    // Fetch jrldetailed and coa data
    $sql_detail = "
SELECT 
    jd.LineID,
    jd.AccountID,
    
    coa.AccountName,
    jd.description,
    jd.DebitAmount,
    jd.CreditAmount,
    
    jd.createdBy,
    jd.createdDateTime,
    jd.modifiedBy,
    jd.modifiedDateTime
FROM 
    jrldetailed jd
JOIN 
    coa ON jd.AccountID = coa.AccountNo

WHERE 
    jd.EntryID = ?";
    $stmt_detail = $conn->prepare($sql_detail);
    $stmt_detail->bind_param("i", $entry_id);
    $stmt_detail->execute();
    $result_detail = $stmt_detail->get_result();
} else {
    echo "No data found for EntryID: "; //. htmlspecialchars($entry_id);
    $conn->close();
    exit;
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="Syles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .journal-container {
            max-width: 100%;
            border: 1px solid #ddd;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
            /* Ensure the container itself handles any overflow */
        }

        .journal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            /* Allows elements to wrap to the next line if needed */
        }

        .journal-header h1 {
            margin: 0;
            font-size: 1.5em;
            font-weight: bold;
            flex: 1 1 auto;
            /* Allow the header to take available space */
        }

        .journal-header .date {
            font-size: 1em;
            color: #888;
            margin-top: 10px;
            flex: 1 1 auto;
            /* Allow the date to take available space */
            text-align: right;
            /* Align the date to the right */
        }

        .journal-header .entry-id {
            margin: 0;
            font-size: 1em;
            text-align: center;
            /* Centers the entry number */
            flex: 1;
            /* Takes equal space */
        }


        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            overflow-x: auto;
            /* Ensure the table itself handles any overflow */
        }

        thead {
            background-color: #f2f2f2;
        }

        th,
        td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        th {
            background-color: #e0e0e0;
        }

        tfoot td {
            font-weight: bold;
        }


        /* Common button styles */
        .filter-buttons button,
        .save-btn {
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

        /* Save button specific styles */
        .save-btn {
            display: inline-block;
            /* Changed from 'none' to make it visible by default */
            margin-left: 5px;
            margin-top: 5px;
            padding: 8px 12px;
            /* Slightly smaller padding */
            font-size: 13px;
            /* Slightly smaller font size */
        }

        /* Hover effects for all buttons */
        .filter-buttons button:hover,
        .save-btn:hover {
            background-color: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
        }

        /* Active effects for all buttons */
        .filter-buttons button:active,
        .save-btn:active {
            transform: translateY(1px);
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        /* Focus styles for accessibility */
        .filter-buttons button:focus,
        .save-btn:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.4);
        }

        /* Media query for smaller screens */
        @media (max-width: 600px) {
            .filter-buttons {
                flex-direction: column;
                align-items: stretch;
            }

            .filter-buttons button,
            .save-btn {
                width: 100%;
                margin-right: 0;
                margin-bottom: 10px;
            }
        }

        .editable {
            background-color: #f0f0f0;
            padding: 2px;
        }

        .editable:focus {
            outline: 2px solid #007bff;
            background-color: #ffffff;
        }

        .toDelete {
            border: 2px solid red !important;
        }

        .tooltip {
            position: relative;
            display: inline-block;
        }

        .tooltip .tooltiptext {
            visibility: hidden;
            width: 220px;
            background-color: #555;
            color: #fff;
            text-align: center;
            border-radius: 6px;
            padding: 5px;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            /* Position above the button */
            left: 50%;
            margin-left: -110px;
            opacity: 0;
            transition: opacity 0.3s;
        }

        .tooltip:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
        }
    </style>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - Jrnl Entry</title>

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
    <div class="filter-buttons">
        <button id="edit">Edit</button>
        <button id="editInsert">Edit with Insertion</button>
        <div class="tooltip">
            <button id="editDelete">Edit with Deletions</button>
            <span class="tooltiptext">Double-click on a row to mark it for deletion.</span>
        </div>

    </div>
    <div class="journal-container">
        <div class="journal-header">
            <?php if ($master_data) : ?>
                <h1 id="jrdesc"><?php echo htmlspecialchars($master_data['description']); ?></h1>
                <h4 id="entryId">Entry No.<?php echo $entry_id; ?></h2>
                    <div class="date"><?php echo htmlspecialchars($master_data['jdate']); ?></div>
                <?php else : ?>
                    <h1>No data found</h1>
                <?php endif; ?>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Line Id</th>
                    <th>Account</th>

                    <th>Label</th>
                    <th>Debit(.₹)</th>
                    <th>Credit(.₹)</th>
                    <th>Created By</th>
                    <th>Created Date Time</th>
                    <th>Modified By</th>
                    <th>Modified Date Time</th>
                </tr>
            </thead>
            <tbody>
                <?php
                $total_debit = 0;
                $total_credit = 0;
                while ($row = $result_detail->fetch_assoc()) {
                    $total_debit += $row['DebitAmount'];
                    $total_credit += $row['CreditAmount'];
                    echo "<tr>
                    <td>" . htmlspecialchars($row['LineID'])  . "</td>    
                    <td>" . htmlspecialchars($row['AccountID']) . " - " . htmlspecialchars($row['AccountName']) . "</td>
                        
                        <td>" . htmlspecialchars($row['description']) . "</td>
                        <td>" . htmlspecialchars($row['DebitAmount']) . "</td>
                        <td>" . htmlspecialchars($row['CreditAmount']) . "</td>
                        
                        <td>" . htmlspecialchars($row['createdBy']) . "</td>
                        
                        <td>" . htmlspecialchars($row['createdDateTime']) . "</td>
                        
                        <td>" . htmlspecialchars($row['modifiedBy']) . "</td>
                        
                        <td>" . htmlspecialchars($row['modifiedDateTime']) . "</td>
                      </tr>";
                }
                ?>
            </tbody>

        </table>
    </div>

    <?php
    // Close the database connection
    $conn->close();
    ?>




    <script>
        function makeEditable() {
            const table = document.querySelector('table');
            const editableColumns = [0, 1, 2, 3, 4, 5]; // Columns for Account, Entity, Label, Debit, and Credit (0-indexed)

            table.querySelectorAll('tbody tr').forEach(row => {
                editableColumns.forEach(colIndex => {
                    const cell = row.cells[colIndex];
                    if (colIndex === 1) {
                        // For Account column, add click listener to show dropdown
                        cell.addEventListener('click', function() {
                            showDropdown(this);
                        });
                    } else {
                        cell.setAttribute('contenteditable', 'true');
                    }
                    cell.classList.add('editable');
                });
            });
        }

        // Function to disable editing
        function disableEditing() {
            const table = document.querySelector('table');
            table.querySelectorAll('.editable').forEach(cell => {
                cell.removeAttribute('contenteditable');
                cell.classList.remove('editable');
                // Remove click listeners from Account and Entity cells
                if (cell.cellIndex === 1) {
                    cell.removeEventListener('click', function() {
                        if (cell.cellIndex === 1) showDropdown(this);

                    });
                }
            });
            // Remove any open dropdowns
            document.querySelectorAll('.account-dropdown').forEach(dropdown => dropdown.remove());
        }

        // Function to show account dropdown
        function showDropdown(element) {
            // Only proceed if this is the first column
            if (element.cellIndex !== 1) return;
            if (element.querySelector('.account-dropdown')) return;

            // Create a dropdown element
            const dropdown = document.createElement('select');
            dropdown.className = 'account-dropdown';

            // Add a loading option
            dropdown.innerHTML = '<option>Loading...</option>';

            // Insert the dropdown into the cell
            const originalContent = element.innerHTML;
            element.innerHTML = '';
            element.appendChild(dropdown);

            // Fetch data from PHP using AJAX
            fetch('get_accounts.php')
                .then(response => response.text())
                .then(text => {
                    try {
                        const data = JSON.parse(text);

                        // Clear the dropdown
                        dropdown.innerHTML = '';

                        // Add a default option
                        const defaultOption = document.createElement('option');
                        defaultOption.text = 'Select an account';
                        defaultOption.value = '';
                        dropdown.add(defaultOption);

                        // Add options from the fetched data
                        data.forEach(account => {
                            const option = document.createElement('option');
                            option.text = `${account.id} - ${account.name}`;
                            option.value = account.id;
                            dropdown.add(option);
                        });
                    } catch (e) {
                        console.error('Error parsing JSON:', e);
                        throw new Error('Invalid JSON response');
                    }
                })
                .catch(error => {
                    console.error('Error fetching accounts:', error);
                    element.innerHTML = 'Error loading accounts';
                });

            // Handle selection
            dropdown.addEventListener('change', function() {
                element.innerHTML = this.options[this.selectedIndex].text;
                element.dataset.accountId = this.value;
            });

            // Handle click outside
            document.addEventListener('click', function closeDropdown(e) {
                if (!element.contains(e.target)) {
                    if (dropdown.value === '') {
                        element.innerHTML = originalContent;
                    }
                    document.removeEventListener('click', closeDropdown);
                }
            });
        }

        // Function to show entity dropdown
        /* function showDropdownEnt(element) {
             // Only proceed if this is the second column
             if (element.cellIndex !== 2) return;
             if (element.querySelector('.entity-dropdown')) return;

             // Create a dropdown element
             const dropdown = document.createElement('select');
             dropdown.className = 'entity-dropdown';

             // Add a loading option
             dropdown.innerHTML = '<option>Loading...</option>';

             // Insert the dropdown into the cell
             const originalContent = element.innerHTML;
             element.innerHTML = '';
             element.appendChild(dropdown);

             // Fetch data from PHP using AJAX
             fetch('get_entities.php')
                 .then(response => response.text())
                 .then(text => {
                     try {
                         const data = JSON.parse(text);

                         // Clear the dropdown
                         dropdown.innerHTML = '';

                         // Add a default option
                         const defaultOption = document.createElement('option');
                         defaultOption.text = 'Select an entity';
                         defaultOption.value = '';
                         dropdown.add(defaultOption);

                         const nullOption = document.createElement('option');
                         nullOption.text = '-';
                         nullOption.value = null;
                         dropdown.add(nullOption);

                         // Add options from the fetched data
                         data.forEach(entity => {
                             const option = document.createElement('option');
                             option.text = entity.name;
                             option.value = entity.Eid;
                             dropdown.add(option);
                         });
                     } catch (e) {
                         console.error('Error parsing JSON:', e);
                         throw new Error('Invalid JSON response');
                     }
                 })
                 .catch(error => {
                     console.error('Error fetching entities:', error);
                     element.innerHTML = 'Error loading entities';
                 });

             // Handle selection
             dropdown.addEventListener('change', function() {
                 element.innerHTML = this.options[this.selectedIndex].text;
                 element.dataset.EntityId = this.value;
             });

             // Handle click outside
             document.addEventListener('click', function closeDropdown(e) {
                 if (!element.contains(e.target)) {
                     if (dropdown.value === '') {
                         element.innerHTML = originalContent;
                     }
                     document.removeEventListener('click', closeDropdown);
                 }
             });
         }*/

        // Toggle edit mode


        // Log the array to the console


        function sendDataToPHP() {
            const tableData = [];
            let totalDebit = 0;
            let totalCredit = 0;
            let valid = true;
            const entryIdElement = document.getElementById("entryId");
            if (!entryIdElement) {
                console.error("Entry ID element not found");
                return;
            }

            // Extract the text content, which will be something like "Entry No. 123"
            const entryIdText = entryIdElement.textContent;
            const entryIdMatch = entryIdText.match(/\d+/);
            if (!entryIdMatch) {
                console.error("Could not extract Entry ID from:", entryIdText);
                return;
            }
            const entryId = entryIdMatch[0];

            document.querySelectorAll('table tbody tr').forEach(row => {
                const urlParams = new URLSearchParams(window.location.search);
                const entryID = urlParams.get('EntryID');
                const label = row.cells[3].textContent.trim();
                const debit = parseFloat(row.cells[4].textContent.trim()) || 0;
                const credit = parseFloat(row.cells[5].textContent.trim()) || 0;

                if (!label) {
                    alert('Label field cannot be empty.');
                    valid = false;
                    return;
                }

                totalDebit += debit;
                totalCredit += credit;

                const rowData = {
                    entryID: entryID,
                    lineId: row.cells[0].textContent.trim(),
                    account: row.cells[1].textContent.trim().split(' - ')[0],
                    //entity: row.cells[2].textContent.trim().split(' - ')[0] === '-' ? null : row.cells[2].textContent.trim().split(' - ')[0],
                    label: label,
                    debit: debit,
                    credit: credit
                };
                tableData.push(rowData);
            });

            if (!valid) {
                return;
            }

            if (totalDebit !== totalCredit) {
                alert('Total debit must equal total credit.');
                return;
            }

            console.log(tableData);
            fetch('update_journal.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(tableData)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success') {
                        alert('Journal entries updated successfully!');
                        location.reload();
                        // Handle success (e.g., show a success message to the user)
                    } else {
                        alert('Error updating journal entries:\n' + data.details.join('\n'));
                        // Handle error (e.g., show an error message to the user)
                    }
                })
                .catch((error) => {
                    console.error('Error:', error);
                    alert('An error occurred while updating journal entries. Please try again later.');
                });

        }




        let editMode = false;
        document.querySelector('#edit').addEventListener('click', function() {
            editMode = !editMode;
            if (editMode) {
                this.textContent = 'Save';
                makeEditable();
            } else {
                this.textContent = 'Edit';
                disableEditing();
                sendDataToPHP(); // Send data to PHP when saving
            }
        });

        // Add some basic styling for editable cells
        const style = document.createElement('style');
        style.textContent = `
    .editable {
        background-color: #f0f0f0;
        padding: 2px;
    }
    .editable:focus {
        outline: 2px solid #007bff;
        background-color: #ffffff;
    }
    .account-dropdown{
        width: 100%;
        padding: 2px;
    }
`;
        document.head.appendChild(style);
    </script>


    <script src="JrnlEditInsert.js"> </script>
    <script src="JrnlEditDelete.js"></script>
    <script src="Jrnl_desc_change.js"></script>
</body>

</html>