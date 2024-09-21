<?php
session_start();
if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    $_SESSION['message'] = "Access denied. Auditors are not allowed to view the add Journal page.";
    header("Location: loginpg2.php");
    exit();
} ?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        .journal-container {
            max-width: 100%;
            border: 1px solid #ddd;
            padding: 20px;
            margin: 20px auto;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
        }

        .journal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .journal-header h1 {
            margin: 0;
            font-size: 1.5em;
            font-weight: bold;
            flex: 1 1 auto;
        }

        .journal-header .date {
            font-size: 1em;
            color: #888;
            margin-top: 10px;
            flex: 1 1 auto;
            text-align: right;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            overflow-x: auto;
        }

        thead {
            background-color: #f2f2f2;
        }

        th,
        td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        input#description {

            padding: 8px;
            border-collapse: collapse;
            margin-top: 20px;

        }

        th {
            background-color: #e0e0e0;
        }

        tfoot td {
            font-weight: bold;
        }

        .editable {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 6px;
        }

        .enter-line {
            cursor: pointer;
            color: blue;
            text-decoration: underline;
        }

        .button-container {
            text-align: left;
            margin: 20px 0;
        }

        .button-container button {
            margin-left: 5px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            padding: 12px 24px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .button-container button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }

        .button-container button:active {
            transform: translateY(1px);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .button-container button:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.4);
        }
    </style>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - Add a Jrnl</title>
</head>

<?php //echo date("Y-m-d"); 
?>

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
    <div class="button-container">
        <button type="submit" id="postButton" value="Post">Post</button>
    </div>
    <div class="journal-container">
        <div class="journal-header">
            <h1>Journal Entry Details</h1>
            <label for="myDate">Date:</label>
            <input type="date" id="jDate" name="jDate" value="<?php echo date('Y-m-d'); ?>" required>

        </div>
        <input type='text' id='description' name='description' placeholder="Journal Description" required>
        <table id="journalTable">
            <thead>
                <tr>
                    <th>Account</th>
                    <th>Entity</th>
                    <th>Label</th>
                    <th>Debit</th>
                    <th>Credit</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="4" class="enter-line" onclick="addNewRow(this)">Enter line</td>
                </tr>
            </tbody>
        </table>
    </div>

    <script>
        const myDateInput = document.getElementById('jDate');

        // Set the default value if the field is empty on page load
        if (!myDateInput.value) {
            myDateInput.value = new Date().toISOString().split('T')[0];
        }


        function addNewRow(element) {
            const table = document.getElementById('journalTable');
            const tbody = table.querySelector('tbody');
            const currentRow = element.parentNode;

            // Remove the "Enter line" text and onclick attribute
            element.textContent = '';
            element.removeAttribute('onclick');
            element.classList.remove('enter-line');

            // Split the cell into four editable cells
            currentRow.innerHTML = `
        <td contenteditable="true" class="editable account"></td>
        <td contenteditable="true" class="editable entity"></td>
        <td contenteditable="true" class="editable label"></td>
        <td contenteditable="true" class="editable debit"></td>
        <td contenteditable="true" class="editable credit"></td>
    `;

            attachInputListeners(currentRow);
            // Add click event listener to the first cell
            currentRow.cells[0].addEventListener('click', function() {
                showDropdown(this);
            });

            currentRow.cells[1].addEventListener('click', function() {
                showDropdownEnt(this);
            });


            // Add event listener to the first cell of the current row
            currentRow.cells[0].addEventListener('input', function() {
                if (this.textContent.trim() !== '') {
                    addEnterLine();
                } else {
                    removeEnterLine();
                }
            });
        }

        function attachInputListeners(row) {
            const debitCell = row.querySelector('.debit');
            const creditCell = row.querySelector('.credit');

            if (debitCell) {
                debitCell.addEventListener('input', () => {
                    updateOppositeCell(row, 'debit');
                });
            }

            if (creditCell) {
                creditCell.addEventListener('input', () => {
                    updateOppositeCell(row, 'credit');
                });
            }
        }

        function updateOppositeCell(row, cellType) {
            const debitCell = row.querySelector('.debit');
            const creditCell = row.querySelector('.credit');

            if (cellType === 'debit') {
                if (debitCell && debitCell.textContent.trim() !== '') {
                    creditCell.textContent = '0.0';
                    creditCell.dataset.value = '0.0';
                }
            } else if (cellType === 'credit') {
                if (creditCell && creditCell.textContent.trim() !== '') {
                    debitCell.textContent = '0.0';
                    debitCell.dataset.value = '0.0';
                }
            }
        }


        function addEnterLine() {
            const table = document.getElementById('journalTable');
            const tbody = table.querySelector('tbody');

            // Check if there's already an "Enter line" row
            const existingEnterLine = tbody.querySelector('.enter-line');
            if (existingEnterLine) {
                return; // Don't add another "Enter line" if one already exists
            }

            const newRow = tbody.insertRow();
            const newCell = newRow.insertCell();
            newCell.colSpan = 4;
            newCell.className = 'enter-line';
            newCell.textContent = 'Enter line';
            newCell.onclick = function() {
                addNewRow(this);
            };
        }

        function removeEnterLine() {
            const table = document.getElementById('journalTable');
            const tbody = table.querySelector('tbody');
            const enterLineRow = tbody.querySelector('.enter-line');
            if (enterLineRow) {
                tbody.removeChild(enterLineRow);
            }
        }

        // Initialize the first "Enter line" row
        window.onload = function() {
            const table = document.getElementById('journalTable');
            const tbody = table.querySelector('tbody');
            if (tbody.rows.length === 0) {
                addEnterLine();
            }

            // Add click event listeners to existing first column cells
            const firstColumnCells = tbody.querySelectorAll('tr td:first-child');
            firstColumnCells.forEach(cell => {
                cell.addEventListener('click', function() {
                    showDropdown(this);
                });
            });
        };


        function showDropdown(element) {
            // Only proceed if this is the first column
            if (element.cellIndex !== 0) return;
            if (element.querySelector('.account-dropdown')) return;
            // Create a dropdown element
            const dropdown = document.createElement('select');
            dropdown.className = 'account-dropdown';

            // Add a loading option
            dropdown.innerHTML = '<option>Loading...</option>';

            // Insert the dropdown into the cell
            element.innerHTML = '';
            element.appendChild(dropdown);

            // Fetch data from PHP using AJAX
            fetch('get_accounts.php')
                .then(response => {
                    console.log('Raw response:', response);
                    return response.text(); // Change this to text() instead of json()
                })
                .then(text => {
                    console.log('Response text:', text);
                    // Try to parse the text as JSON
                    try {
                        const data = JSON.parse(text);
                        console.log('Parsed data:', data);

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
                            option.text = account.name;
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
        }

        function showDropdownEnt(element) {
            // Only proceed if this is the first column
            if (element.cellIndex !== 1) return;
            if (element.querySelector('.entity-dropdown')) return;
            // Create a dropdown element
            const dropdown = document.createElement('select');
            dropdown.className = 'entity-dropdown';

            // Add a loading option
            dropdown.innerHTML = '<option>Loading...</option>';

            // Insert the dropdown into the cell
            element.innerHTML = '';
            element.appendChild(dropdown);

            // Fetch data from PHP using AJAX
            fetch('get_entities.php')
                .then(response => {
                    console.log('Raw response:', response);
                    return response.text(); // Change this to text() instead of json()
                })
                .then(text => {
                    console.log('Response text:', text);
                    // Try to parse the text as JSON
                    try {
                        const data = JSON.parse(text);
                        console.log('Parsed data:', data);

                        // Clear the dropdown
                        dropdown.innerHTML = '';

                        // Add a default option
                        const defaultOption = document.createElement('option');
                        defaultOption.text = 'Select an entity';
                        defaultOption.value = '';
                        dropdown.add(defaultOption);

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
                    console.error('Error fetching accounts:', error);
                    element.innerHTML = 'Error loading entities';
                });
            // Handle selection
            dropdown.addEventListener('change', function() {
                element.innerHTML = this.options[this.selectedIndex].text;
                element.dataset.EntityId = this.value;
            });
        }




        document.getElementById('postButton').addEventListener('click', function() {
            const rows = document.querySelectorAll('#journalTable tbody tr');
            const description = document.getElementById('description').value;
            const jdate = document.getElementById('jDate').value;
            if (!validateEntries()) {
                return; // Exit the function if validation fails
            }
            const entries = [];
            let totalDebit = 0;
            let totalCredit = 0;
            rows.forEach(row => {
                const account = row.querySelector('.account') ? row.querySelector('.account').dataset.accountId : '';
                const entity = row.querySelector('.entity') ? row.querySelector('.entity').dataset.EntityId : null;
                const label = row.querySelector('.label') ? row.querySelector('.label').textContent.trim() : '';
                const debit = row.querySelector('.debit') ? parseFloat(row.querySelector('.debit').textContent.trim()) : 0.0;
                const credit = row.querySelector('.credit') ? parseFloat(row.querySelector('.credit').textContent.trim()) : 0.0;
                totalDebit += debit;
                totalCredit += credit;
                if (account && label && (debit || credit)) {
                    entries.push({
                        account,
                        entity,
                        label,
                        debit,
                        credit
                    });
                }
            });
            if (totalDebit !== totalCredit) {
                alert('Total Debit and Total Credit must be equal!');
                return; // Exit the function early to prevent the AJAX request
            }
            const data = {
                jdate: jdate,
                description: description,
                entries: entries
            };
            console.log(data);

            console.log("jdate:", jdate);
            console.log("description:", description);
            console.log("entries:", entries);

            fetch('pjj.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(data),
                })
                .then(response => response.json()) // Parse the response as JSON
                .then(result => {
                    if (result.status === 'success') {
                        console.log('Success:', result);
                        alert('Data successfully posted');
                        window.location.href = "EachJrnlpg3.php?EntryID=" + result.entryid;
                    } else {
                        console.error('Error:', result.message);
                        alert('Error: ' + result.message);
                    }
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    alert('Fetch error: ' + error.message);
                });
        });

        function validateEntries() {
            const rows = document.querySelectorAll('#journalTable tbody tr');
            let validationFailed = false; // Flag to check if any validation fails
            const description = document.getElementById('description').value.trim();
            let hasValidRow = false;
            const jdate = document.getElementById('jDate').value;
            if (!description) {
                alert('Description field is required.');
                validationFailed = true;
            }

            // Validate date
            if (!jdate) {
                alert('Date field is required.');
                validationFailed = true;
            }
            rows.forEach(row => {
                const accountCell = row.querySelector('.account');
                const debitCell = row.querySelector('.debit');
                const creditCell = row.querySelector('.credit');
                const labelcell = row.querySelector('.label');

                // Validate required fields
                if (accountCell && debitCell && creditCell) {
                    const account = accountCell.textContent.trim();
                    const debit = parseFloat(debitCell.textContent.trim());
                    const credit = parseFloat(creditCell.textContent.trim());
                    const label = labelcell.textContent.trim();
                    if (account && (debit || credit)) {
                        hasValidRow = true; // Mark that at least one valid row exists
                    }

                    if (!label) {
                        alert('Label is required');
                        validationFailed = true;
                    }
                    if (!account) {
                        alert('Account field is required.');
                        validationFailed = true;
                    }
                    if (isNaN(debit) || debit < 0) {
                        alert('Debit field is required and must be a valid number.');
                        validationFailed = true;
                    }
                    if (isNaN(credit) || credit < 0) {
                        alert('Credit field is required and must be a valid number.');
                        validationFailed = true;
                    }
                }
            });
            if (!hasValidRow) {
                alert('No journal entries made.');
                validationFailed = true;
            }

            return !validationFailed; // Return false if validation failed
        }
    </script>



</body>

</html>