<?php
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

// Call the stored procedure
$sql = "CALL pandl30()";
$result = $conn->query($sql);

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
    </style>
    <title>Profit and Loss</title>
</head>

<body>

    <div class="journal-container">
        <div class="journal-header">
            <h1>Profit and Loss</h1>
            <div class="date"><?php echo date("Y-m-d"); ?></div>
        </div>

        <table>
            <thead>
                <tr>

                    <th>AccountID</th>
                    <th>AccountName</th>
                    <th>Credit</th>
                    <th>AccountID</th>
                    <th>AccountName</th>
                    <th>Debit</th>
                </tr>
            </thead>
            <tbody>
                <?php
                $total_credit = 0;
                $total_debit = 0;
                if ($result->num_rows > 0) {
                    while ($row = $result->fetch_assoc()) {
                        echo "<tr>
                        
                                <td>" . htmlspecialchars($row['accountID']) . "</td>
                                <td>" . htmlspecialchars($row['accountName']) . "</td>
                                <td>" . htmlspecialchars($row['credit']) . "</td>
                                <td>" . htmlspecialchars($row['lossid']) . "</td>
                                <td>" . htmlspecialchars($row['lossname']) . "</td>
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