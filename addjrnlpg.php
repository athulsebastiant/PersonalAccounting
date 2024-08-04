<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            /* Center the button horizontally */
        }

        .button-container button {
            background-color: #4CAF50;
            /* Green color for the button */
            color: white;
            /* White text color for the button */
            border: none;
            /* Remove default border for the button */
            padding: 10px 20px;
            /* Add padding inside the button */
            font-size: 16px;
            /* Set font size for the button text */
            cursor: pointer;
            /* Indicate clickable behavior */
        }
    </style>
    <title>Journal Entry Details</title>
</head>

<body>
    <div class="button-container">
        <button type="submit" id="postButton" value="Post">Post</button>
    </div>
    <div class="journal-container">
        <div class="journal-header">
            <h1>Journal Entry Details</h1>
            <div class="date"><?php echo date("Y-m-d"); ?></div>
        </div>
        <input type='text' id='description' name='description' placeholder="Journal Description" required>
        <table id="journalTable">
            <thead>
                <tr>
                    <th>Account</th>
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
        <td contenteditable="true" class="editable label"></td>
        <td contenteditable="true" class="editable debit"></td>
        <td contenteditable="true" class="editable credit"></td>
    `;

            // Add click event listener to the first cell
            currentRow.cells[0].addEventListener('click', function() {
                showDropdown(this);
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


        document.getElementById('postButton').addEventListener('click', function() {
            const rows = document.querySelectorAll('#journalTable tbody tr');
            const description = document.getElementById('description').value;

            const entries = [];
            rows.forEach(row => {
                const account = row.querySelector('.account') ? row.querySelector('.account').dataset.accountId : '';
                const label = row.querySelector('.label') ? row.querySelector('.label').textContent.trim() : '';
                const debit = row.querySelector('.debit') ? row.querySelector('.debit').textContent.trim() : '';
                const credit = row.querySelector('.credit') ? row.querySelector('.credit').textContent.trim() : '';

                if (account && label && (debit || credit)) {
                    entries.push({
                        account,
                        label,
                        debit,
                        credit
                    });
                }
            });

            const data = {
                description,
                entries
            };

            fetch('process_journal.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(data),
                })
                .then(response => response.json())
                .then(result => {
                    if (result.status === 'success') {
                        console.log('Success:', result);
                        alert('Data successfully posted');
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
    </script>



</body>

</html>