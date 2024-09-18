<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Balance Sheet</title>
    <style>
        /* Your existing CSS styles here */
        .navbar {
            background-color: #333;
            overflow: hidden;
            display: flex;
            align-items: center;
            font-family: Arial, sans-serif;
            /* Set a consistent font */
        }

        .navbar a,
        .navbar .dropbtn {
            color: white;
            text-align: center;
            padding: 14px 20px;
            /* Increased horizontal padding */
            text-decoration: none;
            font-size: 16px;
            /* Consistent font size */
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

        /* Push logout to the right */
        .navbar a:last-child {
            margin-left: auto;
        }

        #result-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        #result-table th,
        #result-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        #result-table th {
            background-color: #f2f2f2;
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

            </div>
        </div>

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