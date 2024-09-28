document.addEventListener('DOMContentLoaded', function () {
    let isEditing = false; // To track whether in edit mode

    const editDeleteButton = document.getElementById('editDelete');

    if (editDeleteButton) {
        editDeleteButton.addEventListener('click', async function () {
            if (!isEditing) {
                enableEditing();
                enableRowDeletion();

                this.textContent = 'Save'; // Change button text to "Save"
                isEditing = true;
            } else {
                if (validateFields()) {
                    try {
                        const saveResult = await saveChanges();
                        if (saveResult) {
                            editDeleteButton.textContent = 'Edit with Deletions';
                            disableEditing();
                            isEditing = false;
                            location.reload();
                        } else {
                            // If saveChanges() returns false, it means there was an error
                            console.error('Save operation failed');
                            // You might want to keep the button as 'Save' here
                        }
                    } catch (error) {
                        console.error('Error during save operation:', error);
                        alert('An error occurred while saving. Please try again.');
                    }
                } else {
                    alert('Please fill in all the required fields.');
                }
            }
        });
    } else {
        console.error('Edit with Insert button not found');
    }





    function enableRowDeletion() {
        const table = document.querySelector('.journal-container table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr')).reverse(); // Reverse to start from bottom
        let lastClickableIndex = 0; // Start with the last row (remember, we reversed the array)

        function handleRowDblClick(event) {
            const clickedRow = event.currentTarget;
            const rowIndex = rows.indexOf(clickedRow);

            if (rowIndex !== lastClickableIndex) {
                return; // Prevent double-clicking rows that are not the next in sequence
            }

            clickedRow.classList.add('toDelete');
            clickedRow.style.border = '2px solid red';

            // Update the last clickable index
            lastClickableIndex++;

            // If all rows are selected, disable further double-clicks
            if (lastClickableIndex >= rows.length) {
                rows.forEach(row => row.style.pointerEvents = 'none');
            }
        }

        // Add double-click event listeners to all rows
        rows.forEach(row => {
            row.addEventListener('dblclick', handleRowDblClick); // Changed to 'dblclick'
        });

        // Add a reset button
        const resetButton = document.createElement('button');
        resetButton.textContent = 'Reset Selection';
        resetButton.style.cssText = `
    padding: 8px 16px;
    background-color: #f44336;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    margin-right: 10px;
`;
        resetButton.addEventListener('mouseover', function () {
            this.style.backgroundColor = '#d32f2f';
        });

        resetButton.addEventListener('mouseout', function () {
            this.style.backgroundColor = '#f44336';
        });
        resetButton.addEventListener('click', resetSelection);
        table.parentNode.insertBefore(resetButton, table);

        function resetSelection() {
            rows.forEach(row => {
                row.classList.remove('toDelete');
                row.style.border = '';
                row.style.pointerEvents = 'auto';
            });
            lastClickableIndex = 0;
        }
    }











    function saveChanges() {
        if (!validateFields()) {
            return Promise.resolve(false); // Exit if validation fails
        }

        const table = document.querySelector('.journal-container table tbody');
        if (!table) {
            console.error('Table body not found');
            return;
        }

        let deleteArray = []; // Store LineIDs of rows to be deleted
        let updateArray = []; // Store row data for rows to be updated
        let totalDebit = 0;
        let totalCredit = 0;
        const entryIdElement = document.getElementById("entryId");

        if (!entryIdElement) {
            console.error("Entry ID element not found");
            return;
        }

        // Extract Entry ID from text like "Entry No. 123"
        const entryIdText = entryIdElement.textContent;
        const entryIdMatch = entryIdText.match(/\d+/);
        if (!entryIdMatch) {
            console.error("Could not extract Entry ID from:", entryIdText);
            return;
        }
        const entryId = entryIdMatch[0];
        console.log("Extracted Entry ID:", entryId);

        // Get all rows, including those marked for deletion
        const rows = table.querySelectorAll('tr');

        rows.forEach((row, index) => {
            try {
                // Extract data from row cells
                const lineIDCell = row.querySelector('td:nth-child(1)');
                const accountCell = row.querySelector('td:nth-child(2)');
                //const entityCell = row.querySelector('td:nth-child(3)');
                const labelCell = row.querySelector('td:nth-child(3)');
                const debitCell = row.querySelector('.debit');
                const creditCell = row.querySelector('.credit');

                const lineID = lineIDCell ? parseInt(lineIDCell.textContent.trim(), 10) : null;

                if (row.classList.contains('toDelete')) {
                    // For rows to be deleted, fetch only the LineID
                    if (lineID !== null) {
                        deleteArray.push(lineID);
                    }
                    return; // Skip further processing for rows to delete
                }

                // Process rows that are not marked for deletion (for update)
                if (!accountCell || !labelCell) {
                    console.warn(`Row ${index + 1} missing required cells`);
                    return;
                }

                const accountParts = accountCell.textContent.trim().split(" - ");
                const account = accountParts.length > 0 ? parseInt(accountParts[0].trim(), 10) : null;

                /*const entityText = entityCell ? entityCell.textContent.trim() : "";
                const entity = entityText && entityText !== "-" ? parseInt(entityText.split(" - ")[0].trim(), 10) : null;*/

                const label = labelCell.textContent.trim();
                const debitValue = debitCell ? parseFloat(debitCell.textContent.trim()) : 0.0;
                const creditValue = creditCell ? parseFloat(creditCell.textContent.trim()) : 0.0;

                const rowData = {
                    lineID: lineID,
                    account: account,
                    //entity: entity,
                    label: label,
                    debit: debitValue,
                    credit: creditValue
                };

                totalDebit += rowData.debit;
                totalCredit += rowData.credit;

                // Add row to the update array
                updateArray.push(rowData);

            } catch (error) {
                console.error(`Error processing row ${index + 1}:`, error);
            }
        });

        // Ensure total debit equals total credit for rows not marked as 'toDelete'
        if (Math.abs(totalDebit - totalCredit) > 0.01) {
            alert("Total debit and total credit do not match for rows not marked for deletion.");
            return;
        }

        console.log('Rows to update:', updateArray);
        console.log('Rows to delete (Line IDs):', deleteArray);

        const dataToSend = {
            entryId: entryId,
            updateArray: updateArray, // Rows to be updated
            deleteArray: deleteArray  // Line IDs of rows to be deleted
        };

        // Example of how you might send the data via AJAX or fetch
        return fetch('up_del_jrnl.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(dataToSend)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json(); // Parse JSON response
            })
            .then(result => {
                console.log('Delete result:', result);
                if (result.status === 'success') {
                    alert(result.message);
                    return true; // Indicate success
                } else {
                    alert('Error: ' + result.message);
                    return false; // Indicate failure
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                alert('An error occurred while deleting changes. Please check the console for details.');
                return false; // Indicate failure
            });
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
                if (index < 5 && index >= 1) { // Only make the first 6 columns editable
                    cell.contentEditable = true;

                    if (index === 3) { // Debit column
                        cell.classList.add('debit');
                    } else if (index === 4) { // Credit column
                        cell.classList.add('credit');
                    }

                    if (index === 1) { // Account column
                        cell.addEventListener('click', function () {
                            showDropdown(this);
                        });
                    }
                }
                attachInputListeners(row);
            });

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

    /*function showDropdownEnt(element) {
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
*/
    function disableEditing() {
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            row.querySelectorAll('td').forEach((cell, index) => {
                if (index < 5 && index >= 1) {
                    cell.contentEditable = false; // Disable editing
                }
            });
        });
    }



    function validateFields() {
        const table = document.querySelector('.journal-container table tbody');
        // Select all rows except those with the 'toDelete' class
        const rows = table.querySelectorAll('tr:not(.toDelete)');
        let valid = true;
        let errorMessages = [];

        rows.forEach((row, index) => {
            const account = row.querySelector('td:nth-child(2)');
            const label = row.querySelector('td:nth-child(3)');
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

