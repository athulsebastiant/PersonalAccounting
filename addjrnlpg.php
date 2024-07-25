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
    </style>
    <title>Journal Entry Details</title>
</head>

<body>

    <div class="journal-container">
        <div class="journal-header">
            <h1>Journal Entry Details</h1>
            <div class="date"><?php echo date("Y-m-d"); ?></div>
        </div>

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
        <td contenteditable="true" class="editable"></td>
        <td contenteditable="true" class="editable"></td>
        <td contenteditable="true" class="editable"></td>
        <td contenteditable="true" class="editable"></td>
    `;

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
        };

        function showDropdown(element) {
            // Only proceed if this is the first column
            if (element.cellIndex !== 0) return;

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
                .then(response => response.json())


                .then(data => {
                    console.log(response);
                    console.log(data);
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
    </script>



</body>

</html>