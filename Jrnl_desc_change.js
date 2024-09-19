// Select the h1 element
const descriptionElement = document.querySelector('#jrdesc');
let originalDescription = descriptionElement.textContent;

// Function to make the description editable
function makeDescEditable() {
    descriptionElement.contentEditable = true;
    descriptionElement.focus();

    // Create save button if it doesn't exist
    if (!document.getElementById('saveButton')) {
        const saveButton = document.createElement('button');
        saveButton.id = 'saveButton';
        saveButton.className = 'save-btn';
        saveButton.textContent = 'Save';
        saveButton.style.display = 'none';
        descriptionElement.parentNode.insertBefore(saveButton, descriptionElement.nextSibling);

        // Add click event to save button
        saveButton.addEventListener('click', saveDescription);
    }

    // Show save button
    document.getElementById('saveButton').style.display = 'inline-block';
}

// Function to save the description
function saveDescription() {
    const newDescription = descriptionElement.textContent;

    // Get the entry ID
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

    // Only proceed if the description has changed
    if (newDescription !== originalDescription) {
        // Send the new description to the server
        fetch('update_description.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `description=${encodeURIComponent(newDescription)}&entryId=${encodeURIComponent(entryId)}`
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    console.log('Description updated successfully');
                    originalDescription = newDescription;
                    alert("Journal Description updated");
                    location.reload();
                } else {
                    console.error('Failed to update description');
                    descriptionElement.textContent = originalDescription;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                descriptionElement.textContent = originalDescription;
            });
    }

    // Hide save button and make description non-editable
    document.getElementById('saveButton').style.display = 'none';
    descriptionElement.contentEditable = false;
}

// Add click event to the description element
descriptionElement.addEventListener('click', makeDescEditable);