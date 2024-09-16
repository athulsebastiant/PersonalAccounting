
document.addEventListener('DOMContentLoaded', function () {
    let isEditing = false; // To track whether in edit mode

    const editInsertButton = document.getElementById('editInsert');

    if (editInsertButton) {
        editInsertButton.addEventListener('click', function () {
            if (!isEditing) {
                enableEditing();
                addEnterLine();
                this.textContent = 'Save'; // Change button text to "Save"
                isEditing = true;
            } else {
                if (validateFields()) {
                    //this.textContent = 'Edit with Insertion'; // Change button text back to "Edit with Insertion"
                    // disableEditing();
                    if (saveChanges()) {
                        editInsertButton.textContent = 'Edit with Insertion';
                        disableEditing();
                        isEditing = false;
                    }
                    // Stop editing after save
                    //isEditing = false;
                } else {
                    alert('Please fill in all the required fields.');
                }
            }
        });
    } else {
        console.error('Edit with Insert button not found');
    }


    function saveChanges() {
        if (!validateFields()) {
            return; // Exit the function if validation fails
        }

        const table = document.querySelector('.journal-container table tbody');
        if (!table) {
            console.error('Table body not found');
            return;
        }

        const rows = table.querySelectorAll('tr:not(.enter-line)');
        let insertArray = [];
        let updateArray = [];
        let totalDebit = 0;
        let totalCredit = 0;

        rows.forEach((row, index) => {
            try {
                const accountCell = row.querySelector('td:nth-child(2)');
                const entityCell = row.querySelector('td:nth-child(3)');
                const labelCell = row.querySelector('td:nth-child(4)');
                const debitCell = row.querySelector('.debit');
                const creditCell = row.querySelector('.credit');

                if (!accountCell || !labelCell) {
                    //console.error(`Row ${index + 1}: Missing required cells`);
                    return; // Skip this row
                }

                const account = accountCell.textContent.trim().split(" - ")[0].trim();

                // For the entity, handle null or "-" cases, and extract the number part before " - "
                const entity = entityCell ?
                    (entityCell.textContent.trim() === "-" || entityCell.textContent.trim() === "" ? null : entityCell.textContent.trim().split(" - ")[0].trim())
                    : null;

                // Get the label as it is
                const label = labelCell.textContent.trim();

                // Parse debit and credit values as before
                const debitValue = debitCell ? parseFloat(debitCell.textContent.trim()).toFixed(2) : 0.00;
                const creditValue = creditCell ? parseFloat(creditCell.textContent.trim()).toFixed(2) : 0.00;

                const rowData = {
                    account: account,
                    entity: entity,
                    label: label,
                    debit: debitValue,
                    credit: creditValue
                };
                totalDebit += parseFloat(rowData.debit);
                totalCredit += parseFloat(rowData.credit);

                // Check if the row has the 'toInsert' class and add to the appropriate array
                if (row.classList.contains('toInsert')) {
                    insertArray.push(rowData);
                } else {
                    updateArray.push(rowData);
                }
            } catch (error) {
                console.error(`Error processing row ${index + 1}:`, error);
            }
        });

        if (totalDebit !== totalCredit) {
            alert("Total debit and total credit do not match.");
            return; // Exit the function
        }

        console.log('Rows to insert:', insertArray);
        console.log('Rows to update:', updateArray);

        /* if (!valid) {
             alert(errorMessages.join('\n'));
         }*/


        /* if (!valid) {
             alert(errorMessages.join('\n'));
         }*/

        //return valid;




    }





    function enableEditing() {
        console.log('Enabling editing');
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            row.querySelectorAll('td').forEach((cell, index) => {
                if (index < 6 && index >= 1) { // Only make the first 6 columns editable
                    cell.contentEditable = true;

                    if (index === 4) { // Debit column
                        cell.classList.add('debit');
                    } else if (index === 5) { // Credit column
                        cell.classList.add('credit');
                    }

                    if (index === 1) { // Account column
                        cell.addEventListener('click', function () {
                            showDropdown(this);
                        });
                    } else if (index === 2) { // Entity column
                        cell.addEventListener('click', function () {
                            showDropdownEnt(this);
                        });
                    }
                }
                attachInputListeners(row);
            });

        });
    }


    function addNewRow(element) {
        const tbody = element.closest('tbody');


        let lastRow = tbody.querySelector('tr:not(.enter-line):last-child');
        let newValue = 1; // Default value in case there are no rows

        if (lastRow && lastRow.cells.length > 0) {
            const lastValue = parseInt(lastRow.cells[0].textContent.trim());
            newValue = isNaN(lastValue) ? 1 : lastValue + 1; // Increment the value by 1
        }

        const newRow = tbody.insertRow(element.parentNode.rowIndex);
        newRow.classList.add('toInsert');


        for (let i = 0; i < 10; i++) { // Create 10 cells to match your table structure
            const cell = newRow.insertCell();
            cell.classList.add('toInsert');
            if (i === 0) {
                // Set the value of the first column to the new incremented value
                cell.textContent = newValue;
            }
            if ((i < 6) && (i >= 1)) { // Make only the first 6 cells editable
                cell.contentEditable = true;

                if (i === 4) { // Debit column
                    cell.classList.add('debit');
                } else if (i === 5) { // Credit column
                    cell.classList.add('credit');
                }



                if (i === 1) { // Account column
                    cell.addEventListener('click', function () {
                        showDropdown(this);
                    });
                } else if (i === 2) { // Entity column
                    cell.addEventListener('click', function () {
                        showDropdownEnt(this);
                    });
                }
            }
        }
        attachInputListeners(newRow);
        element.parentNode.remove(); // Remove the "Enter line" row
        addEnterLine(); // Add a new "Enter line" at the bottom
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
        console.log('Adding enter line');
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const tbody = table.querySelector('tbody');
        if (!tbody) {
            console.error('Table body not found');
            return;
        }

        const existingEnterLine = tbody.querySelector('.enter-line');
        if (existingEnterLine) {
            console.log('Enter line already exists');
            return;
        }

        const newRow = tbody.insertRow();
        const newCell = newRow.insertCell();
        newCell.colSpan = 10; // Span all columns
        newCell.className = 'enter-line';
        newCell.textContent = 'Enter line';
        newCell.onclick = function () {
            addNewRow(this);
        };
    }

    const table = document.querySelector('.journal-container table');
    if (table) {
        const tbody = table.querySelector('tbody');
        if (tbody && tbody.rows.length === 0) {
            addEnterLine();
        }

        const accountCells = tbody.querySelectorAll('tr td:nth-child(2)');
        accountCells.forEach(cell => {
            cell.addEventListener('click', function () {
                showDropdown(this);
            });
        });

        const entityCells = tbody.querySelectorAll('tr td:nth-child(3)');
        entityCells.forEach(cell => {
            cell.addEventListener('click', function () {
                showDropdownEnt(this);
            });
        });
    } else {
        console.error('Journal table not found');
    }


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
        dropdown.addEventListener('change', function () {
            element.innerHTML = this.options[this.selectedIndex].text;
            element.dataset.accountId = this.value;
        });
    }

    function showDropdownEnt(element) {
        // Only proceed if this is the first column
        if (element.cellIndex !== 2) return;
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
        dropdown.addEventListener('change', function () {
            element.innerHTML = this.options[this.selectedIndex].text;
            element.dataset.EntityId = this.value;
        });
    }

    function disableEditing() {
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            row.querySelectorAll('td').forEach((cell, index) => {
                if (index < 6 && index >= 1) {
                    cell.contentEditable = false; // Disable editing
                }
            });
        });
    }



    function validateFields() {
        const table = document.querySelector('.journal-container table tbody');
        const rows = table.querySelectorAll('tr:not(.enter-line)');
        let valid = true;
        let errorMessages = [];

        rows.forEach((row, index) => {

            if (row.querySelector('.enter-line')) {
                return;
            }
            const account = row.querySelector('td:nth-child(2)');
            //const entity = row.querySelector('td:nth-child(3)');
            const label = row.querySelector('td:nth-child(4)');
            const debit = row.querySelector('.debit');
            const credit = row.querySelector('.credit');

            // Reset background colors
            [account, label, debit, credit].forEach(cell => {
                if (cell) cell.style.backgroundColor = '';
            });

            // Validate Account
            if (!account || account.textContent.trim() === '') {
                if (account) account.style.backgroundColor = '#ffcccc';
                errorMessages.push(`Row ${index + 1}: Account is required`);
                valid = false;
            }

            // Validate Entity (if required)
            /* if (!entity || entity.textContent.trim() === '') {
                 if (entity) entity.style.backgroundColor = '#ffcccc';
                 errorMessages.push(`Row ${index + 1}: Entity is required`);
                 valid = false;
             }*/

            // Validate Label
            if (!label || label.textContent.trim() === '') {
                if (label) label.style.backgroundColor = '#ffcccc';
                errorMessages.push(`Row ${index + 1}: Label is required`);
                valid = false;
            }

            // Validate Debit and Credit
            const debitValue = debit ? parseFloat(debit.textContent.trim()) : NaN;
            const creditValue = credit ? parseFloat(credit.textContent.trim()) : NaN;

            if (isNaN(debitValue) && isNaN(creditValue)) {
                if (debit) debit.style.backgroundColor = '#ffcccc';
                if (credit) credit.style.backgroundColor = '#ffcccc';
                errorMessages.push(`Row ${index + 1}: Either Debit or Credit must be a valid number`);
                valid = false;
            } else if (debitValue < 0 || creditValue < 0) {
                if (debitValue < 0 && debit) debit.style.backgroundColor = '#ffcccc';
                if (creditValue < 0 && credit) credit.style.backgroundColor = '#ffcccc';
                errorMessages.push(`Row ${index + 1}: Debit and Credit values must be non-negative`);
                valid = false;
            } else if (debitValue > 0 && creditValue > 0) {
                if (debit) debit.style.backgroundColor = '#ffcccc';
                if (credit) credit.style.backgroundColor = '#ffcccc';
                errorMessages.push(`Row ${index + 1}: Only one of Debit or Credit should have a value`);
                valid = false;
            }
        });

        if (!valid) {
            alert(errorMessages.join('\n'));
        }

        return valid;
    }




});

