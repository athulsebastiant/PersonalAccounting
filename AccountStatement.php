<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Balance Sheet</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        /* Your existing CSS styles here */
        #account-select,
        #fromDate,
        #toDate,
        button[type="submit"] {
            padding: 8px;
            margin: 5px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: #f9f9f9;
            transition: background-color 0.3s ease;
        }

        #account-select:hover,
        #fromDate:hover,
        #toDate:hover,
        button[type="submit"]:hover {
            background-color: #f5f5f5;
            cursor: pointer;
        }

        #account-select:focus,
        #fromDate:focus,
        #toDate:focus,
        button[type="submit"]:focus {
            outline: none;
            border-color: #4CAF50;
        }

        button[type="submit"] {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
        }

        button[type="submit"]:hover {
            background-color: #45a049;
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
                <a href="AccountStatement.php">Account Statement</a>
            </div>
        </div>
        <a href="view_company_info.php">General Settings</a>
        <a href="logout.php">Logout</a>
    </div>
    <br>


    <form id="statement-form">
        <select id="account-select" name="account-select" onclick="showDropdown(this)">
            <option value="">Select an account</option>
        </select>
        <input type="date" id="fromDate" name="fromDate">
        <input type="date" id="toDate" name="toDate">
        <button type="submit">Generate Statement</button>
    </form>
    <br>

    <div id="result-container"></div>

    <script>
        function showDropdown(element) {
            // Your existing showDropdown function here
            // Check if the dropdown has already been populated
            if (element.options.length > 1) return;

            // Add a loading option
            element.innerHTML = '<option>Loading...</option>';

            // Fetch data from PHP using AJAX
            fetch('get_accounts.php')
                .then(response => {
                    console.log('Raw response:', response);
                    return response.text();
                })
                .then(text => {
                    console.log('Response text:', text);
                    // Try to parse the text as JSON
                    try {
                        const data = JSON.parse(text);
                        console.log('Parsed data:', data);

                        // Clear the dropdown
                        element.innerHTML = '';

                        // Add a default option
                        const defaultOption = document.createElement('option');
                        defaultOption.text = 'Select an account';
                        defaultOption.value = '';
                        element.add(defaultOption);

                        // Add options from the fetched data
                        data.forEach(account => {
                            const option = document.createElement('option');
                            option.text = account.name;
                            option.value = account.id;
                            element.add(option);
                        });
                    } catch (e) {
                        console.error('Error parsing JSON:', e);
                        throw new Error('Invalid JSON response');
                    }
                })
                .catch(error => {
                    console.error('Error fetching accounts:', error);
                    element.innerHTML = '<option>Error loading accounts</option>';
                });
        }

        document.getElementById('statement-form').addEventListener('submit', function(e) {
            e.preventDefault();

            const formData = new FormData(this);

            fetch('get_statement.php', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.text())
                .then(html => {
                    document.getElementById('result-container').innerHTML = html;
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('result-container').innerHTML = 'An error occurred while fetching the data.';
                });
        });
    </script>
</body>

</html>