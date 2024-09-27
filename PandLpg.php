<?php
include "SessionPG.php";
include "Connection.php";
if (
    $_SESSION['user_type'] == "Bookkeeper"
) {
    // Redirect to login page if not logged in
    $_SESSION['message'] = "Access denied. Bookkeepers are not allowed to view the Profit and Loss page.";
    header("Location: Homepg.php");
    exit();
}

$company_info_sql = "SELECT company_name, address, registration_number, phone_number, email, logo_path FROM company_info LIMIT 1";
$company_info_result = $conn->query($company_info_sql);
$company_info = $company_info_result->fetch_assoc();
// Call the stored procedure
$sql1 = "SELECT DATE(MIN(createdDateTime)) AS earliest_timestamp FROM jrlmaster";
$result = $conn->query($sql1);

if ($result->num_rows > 0) {
    // Fetch the result
    $row = $result->fetch_assoc();
    $earliestTimestamp = $row['earliest_timestamp'];
} else {
    $earliestTimestamp = "As of";
}
$sql = "CALL PandL31()";
$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="Syles.css">
    <style>
        button {
            margin-left: 5px;
            margin-right: 15px;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: #f9f9f9;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease, transform 0.1s ease;
        }

        button:hover {
            background-color: #45a049;
            transform: translateY(-2px);
        }

        button:active {
            transform: translateY(1px);
        }

        .company-info {
            text-align: center;
            margin-bottom: 20px;
        }

        .company-info img {
            max-width: 130px;
            height: auto;
        }

        .company-info h2 {
            margin: 10px 0;
        }

        .company-info p {
            margin: 5px 0;
        }

        .highlight-loss {
            color: red;
            font-weight: bold;
        }

        .highlight-profit {
            color: green;
            font-weight: bold;
        }

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


        .green {
            color: green;
            font-weight: bold;
        }

        .red {
            color: red;
            font-weight: bold;
        }

        .pdf-button {
            background-color: #4CAF50;
            border: none;
            color: white;
            padding: 15px 32px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: pointer;
        }
    </style>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <title>Personal Accounting - Profit and Loss</title>
</head>

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
    <div class="journal-container">


        <div class="journal-header">
            <h1>Profit and Loss</h1>
            <div class="date"><?php echo $earliestTimestamp . " - " . date("Y-m-d"); ?></div>
        </div>
        <form action="generate_pnl_pdf.php" method="post">
            <button type="submit" class="pdf-button">Download PDF</button>
        </form>
        <div class="company-info">
            <?php if ($company_info['logo_path']): ?>
                <img src="<?php echo htmlspecialchars($company_info['logo_path']); ?>" alt="Company Logo">
            <?php endif; ?>
            <h2><?php echo htmlspecialchars($company_info['company_name']); ?></h2>
            <p><?php echo htmlspecialchars($company_info['address']); ?></p>
            <p>Phone: <?php echo htmlspecialchars($company_info['phone_number']); ?></p>
            <p>Email: <?php echo htmlspecialchars($company_info['email']); ?></p>
            <p>Registration Number: <?php echo htmlspecialchars($company_info['registration_number']); ?></p>
        </div>


        <table>
            <thead>
                <tr>

                    <th>AccountID</th>
                    <th>AccountName</th>
                    <th>Credit(.₹)</th>
                    <th>AccountID</th>
                    <th>AccountName</th>
                    <th>Debit(.₹)</th>
                </tr>
            </thead>
            <tbody>
                <?php
                $total_credit = 0;
                $total_debit = 0;
                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {

                        $colorClass = '';
                        $colorClass1 = '';
                        if ($row['accountName'] == 'Loss') {
                            $colorClass1 = 'red';
                        } elseif ($row['lossname'] == 'Profit') {
                            $colorClass = 'green';
                        }
                        echo "<tr>
                        
                                <td>" . htmlspecialchars($row['accountID']) . "</td>
                                <td class='$colorClass1'>" . htmlspecialchars($row['accountName']) . "</td>
                                <td>" . htmlspecialchars($row['credit']) . "</td>
                                <td>" . htmlspecialchars($row['lossid']) . "</td>
                                <td class='$colorClass'>" . htmlspecialchars($row['lossname']) . "</td>
                                <td>" . htmlspecialchars($row['debit']) . "</td>
                              </tr>";
                    }
                } else {
                    echo "<tr><td colspan='5'>No results found</td></tr>";
                }

                ?>
            </tbody>
        </table>
    </div>

    <?php
    $conn->close();
    ?>

</body>

</html>