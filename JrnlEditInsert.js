
document.addEventListener('DOMContentLoaded', function () {
    let isEditing = false; // To track whether in edit mode

    const editInsertButton = document.getElementById('editInsert');

    if (editInsertButton) {
        editInsertButton.addEventListener('click', async function () {
            if (!isEditing) {
                enableEditing();
                addEnterLine();
                this.textContent = 'Save'; // Change button text to "Save"
                isEditing = true;
            } else {
                if (validateFields()) {
                    try {
                        const saveResult = await saveChanges();
                        if (saveResult) {
                            editInsertButton.textContent = 'Edit with Insertion';
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


    function saveChanges() {
        if (!validateFields()) {
            return Promise.resolve(false); // Exit if validation fails
        }

        const table = document.querySelector('.journal-container table tbody');
        if (!table) {
            console.error('Table body not found');
            return;
        }

        const rows = table.querySelectorAll('tr:not(.total-row):not(.enter-line)');
        let insertArray = [];
        let updateArray = [];
        let totalDebit = 0;
        let totalCredit = 0;
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
        console.log("Extracted Entry ID:", entryId);
        rows.forEach((row, index) => {
            try {



                // Extract data from the row cells
                const lineIDCell = row.querySelector('td:nth-child(1)');
                const accountCell = row.querySelector('td:nth-child(2)');
                //const entityCell = row.querySelector('td:nth-child(3)');
                const labelCell = row.querySelector('td:nth-child(3)');
                const debitCell = row.querySelector('.debit');
                const creditCell = row.querySelector('.credit');

                if (!accountCell || !labelCell) {
                    //console.warn(`Row ${index + 1} missing required cells`);
                    return;
                }

                const lineID = lineIDCell ? parseInt(lineIDCell.textContent.trim(), 10) : null;
                const accountParts = accountCell.textContent.trim().split(" - ");
                const account = accountParts.length > 0 ? parseInt(accountParts[0].trim(), 10) : null;

                //const entityText = entityCell ? entityCell.textContent.trim() : "";
                //const entity = entityText && entityText !== "-" ? parseInt(entityText.split(" - ")[0].trim(), 10) : null;

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

                if (row.classList.contains('toInsert')) {
                    insertArray.push(rowData);
                } else {
                    updateArray.push(rowData);
                }
            } catch (error) {
                console.error(`Error processing row ${index + 1}:`, error);
            }
        });

        if (Math.abs(totalDebit - totalCredit) > 0.01) {
            alert("Total debit and total credit do not match.");
            return;
        }

        console.log('Rows to insert:', insertArray);
        console.log('Rows to update:', updateArray);

        const dataToSend = {
            entryId: entryId,
            insertArray: insertArray,
            updateArray: updateArray
        };

        return fetch('up_ins_jrnl.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(dataToSend)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.text();
            })
            .then(text => {
                console.log('Raw response:', text);
                const data = JSON.parse(text);
                console.log('Parsed data:', data);
                if (data.status === 'success') {
                    alert(data.message);
                    return true;
                } else {
                    alert('Error: ' + data.message);
                    return false;
                }
            })
            .catch((error) => {
                console.error('Fetch error:', error);
                alert('An error occurred while saving changes. Please check the console for details.');
                return false;
            });
    }











    /* try {
        const lineID = row.querySelector('td:nth-child(1)');
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
*/
    /* if (!valid) {
         alert(errorMessages.join('\n'));
     }*/


    /* if (!valid) {
         alert(errorMessages.join('\n'));
     }*/

    //return valid;










    function enableEditing() {
        console.log('Enabling editing');
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const rows = table.querySelectorAll('tbody tr:not(.total-row)');
        rows.forEach(row => {
            row.querySelectorAll('td').forEach((cell, index) => {
                if (index < 5 && index >= 1) { // Only make the first 6 columns editable
                    cell.contentEditable = true;

                    if (index === 3) { // Debit column
                        cell.classList.add('debit');
                        cell.addEventListener('input', updateTotalRow);
                    } else if (index === 4) { // Credit column
                        cell.classList.add('credit');
                        cell.addEventListener('input', updateTotalRow);
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
        updateTotalRow();
    }


    function addNewRow(element) {
        const tbody = element.closest('tbody');
        // const totalRow = tbody.querySelector('.total-row');
        const newRow = tbody.insertRow(tbody.rows.length - 1);
        newRow.classList.add('toInsert');
        let maxLineID = 0;
        tbody.querySelectorAll('tr:not(.total-row)').forEach(row => {
            const lineIDCell = row.cells[0];
            console.log(lineIDCell);
            if (lineIDCell) {
                // Parse the content as an integer, defaulting to 0 if NaN
                const lineID = parseInt(lineIDCell.textContent.trim(), 10) || 0;
                console.log(lineID);
                maxLineID = Math.max(maxLineID, lineID);
            }
        });

        // Increment the maxLineID for the new row
        const newLineID = maxLineID + 1;

        // Increment the maxLineID for the new row





        for (let i = 0; i < 9; i++) { // Create 10 cells to match your table structure
            const cell = newRow.insertCell();
            cell.classList.add('toInsert');
            if (i === 0) {
                // Set the value of the first column to the new incremented value
                cell.textContent = newLineID;
            }
            if ((i < 5) && (i >= 1)) { // Make only the first 6 cells editable
                cell.contentEditable = true;

                if (i === 3) { // Debit column
                    cell.classList.add('debit');
                    cell.addEventListener('input', updateTotalRow);
                } else if (i === 4) { // Credit column
                    cell.classList.add('credit');
                    cell.addEventListener('input', updateTotalRow);
                }



                if (i === 1) { // Account column
                    cell.addEventListener('click', function () {
                        showDropdown(this);
                    });
                }
            }
        }
        attachInputListeners(newRow);
        element.parentNode.remove(); // Remove the "Enter line" row
        addEnterLine(); // Add a new "Enter line" at the bottom
        updateTotalRow();
    }


    function attachInputListeners(row) {
        const debitCell = row.querySelector('.debit');
        const creditCell = row.querySelector('.credit');

        if (debitCell) {
            debitCell.addEventListener('input', () => {
                updateOppositeCell(row, 'debit');
                updateTotalRow();
            });
        }

        if (creditCell) {
            creditCell.addEventListener('input', () => {
                updateOppositeCell(row, 'credit');
                updateTotalRow();
            });
        }
    }

    function updateOppositeCell(row, cellType) {
        const debitCell = row.querySelector('.debit');
        const creditCell = row.querySelector('.credit');

        if (cellType === 'debit') {
            if (debitCell && debitCell.textContent.trim() !== '') {
                creditCell.textContent = '0.00';
                creditCell.dataset.value = '0.00';
            }
        } else if (cellType === 'credit') {
            if (creditCell && creditCell.textContent.trim() !== '') {
                debitCell.textContent = '0.00';
                debitCell.dataset.value = '0.00';
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

        //const totalRow = tbody.querySelector('.total-row');
        const newRow = tbody.insertRow(tbody.rows.length - 1);
        const newCell = newRow.insertCell();
        newCell.colSpan = 9; // Span all columns
        newCell.className = 'enter-line';
        newCell.textContent = 'Enter line';
        newCell.onclick = function () {
            addNewRow(this);
        };
    }


    function updateTotalRow() {
        const table = document.querySelector('.journal-container table');
        if (!table) return;

        const tbody = table.querySelector('tbody');
        if (!tbody) return;
        if (isEditing) {
            let totalDebit = 0;
            let totalCredit = 0;

            tbody.querySelectorAll('tr:not(.total-row):not(.enter-line)').forEach(row => {
                const debitCell = row.querySelector('.debit');
                const creditCell = row.querySelector('.credit');
                if (debitCell) totalDebit += parseFloat(debitCell.textContent) || 0;
                if (creditCell) totalCredit += parseFloat(creditCell.textContent) || 0;
            });

            let totalRow = tbody.querySelector('.total-row');
            if (!totalRow) {
                totalRow = tbody.insertRow();
                totalRow.className = 'total-row';
                totalRow.innerHTML = `
            <td colspan="3"><strong>Total</strong></td>
            <td class="total-debit"></td>
            <td class="total-credit"></td>
            <td colspan="4"></td>
        `;
                //tbody.appendChild(totalRow);
            }

            const totalDebitCell = totalRow.querySelector('#totalDebit');
            const totalCreditCell = totalRow.querySelector('#totalCredit');

            if (totalDebitCell) totalDebitCell.textContent = totalDebit.toFixed(2);
            if (totalCreditCell) totalCreditCell.textContent = totalCredit.toFixed(2);
        }
        // Ensure the total row is at the end
        tbody.appendChild(totalRow);
    }





    const table = document.querySelector('.journal-container table');
    if (table) {
        const tbody = table.querySelector('tbody');
        if (tbody) {
            if (tbody.rows.length === 0) {
                addEnterLine();
            }
            //updateTotalRow();

            const accountCells = tbody.querySelectorAll('tr:not(.total-row) td:nth-child(2)');
            accountCells.forEach(cell => {
                cell.addEventListener('click', function () {
                    showDropdown(this);
                });
            });
            /*tbody.querySelectorAll('.debit-amount, .credit-amount').forEach(cell => {
                cell.addEventListener('input', updateTotalRow);
            });*/
        }

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
    }*/

    function disableEditing() {
        const table = document.querySelector('.journal-container table');
        if (!table) {
            console.error('Journal table not found');
            return;
        }
        const rows = table.querySelectorAll('tbody tr:not(.total-row)');
        rows.forEach(row => {
            row.querySelectorAll('td').forEach((cell, index) => {
                if (index < 5 && index >= 1) {
                    cell.contentEditable = false; // Disable editing
                    if (index === 3 || index === 4) {
                        cell.removeEventListener('input', updateTotalRow);
                    }
                }
            });
        });
    }



    function validateFields() {
        const table = document.querySelector('.journal-container table tbody');
        const rows = table.querySelectorAll('tr:not(.total-row):not(.enter-line)');
        let valid = true;
        let errorMessages = [];

        rows.forEach((row, index) => {

            if (row.querySelector('.enter-line')) {
                return;
            }
            const account = row.querySelector('td:nth-child(2)');
            //const entity = row.querySelector('td:nth-child(3)');
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

