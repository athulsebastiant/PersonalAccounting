<?php
// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ac2";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
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
SELECT jd.AccountID, coa.AccountName, jd.description, jd.DebitAmount, jd.CreditAmount
FROM jrldetailed jd
JOIN coa ON jd.AccountID = coa.AccountNo
WHERE jd.EntryID = ?";
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

        .navbar {
            background-color: #333;
            overflow: hidden;
        }

        .navbar a {
            float: left;
            color: white;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }

        .dropdown {
            float: left;
            overflow: hidden;
        }

        .dropdown .dropbtn {
            border: none;
            outline: none;
            color: white;
            padding: 14px 16px;
            background-color: inherit;
            font-family: inherit;
            margin: 0;
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

        .dropdown:hover .dropdown-content {
            display: block;
        }
    </style>
    <title>Journal Entry Details</title>
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
    </div>
    <div class="journal-container">
        <div class="journal-header">
            <?php if ($master_data) : ?>
                <h1><?php echo htmlspecialchars($master_data['description']); ?></h1>
                <div class="date"><?php echo htmlspecialchars($master_data['jdate']); ?></div>
            <?php else : ?>
                <h1>No data found</h1>
            <?php endif; ?>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Account</th>
                    <th>Label</th>
                    <th>Debit</th>
                    <th>Credit</th>
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
                        <td>" . htmlspecialchars($row['AccountID']) . " - " . htmlspecialchars($row['AccountName']) . "</td>
                        <td>" . htmlspecialchars($row['description']) . "</td>
                        <td>" . htmlspecialchars($row['DebitAmount']) . "</td>
                        <td>" . htmlspecialchars($row['CreditAmount']) . "</td>
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

</body>

</html>