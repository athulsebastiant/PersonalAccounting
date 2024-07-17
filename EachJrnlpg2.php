<?php
// Database connection details
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

// Get the EntryID from the query string or other source
$entryId = 1; // Replace with your desired method to get EntryID

// Fetch data from jrlmaster
$sqlMaster = "SELECT description, jdate FROM jrlmaster WHERE EntryID = ?";
$stmtMaster = $conn->prepare($sqlMaster);
$stmtMaster->bind_param("i", $entryId);
$stmtMaster->execute();
$resultMaster = $stmtMaster->get_result();
$rowMaster = $resultMaster->fetch_assoc();

// Fetch data from jrldetailed
$sqlDetailed = "SELECT jd.LineID, a.AccountNo, jd.description, jd.DebitAmount, jd.CreditAmount
                FROM jrldetailed jd
                INNER JOIN coa a ON jd.AccountID = a.AccountNo
                WHERE jd.EntryID = ?";
$stmtDetailed = $conn->prepare($sqlDetailed);
$stmtDetailed->bind_param("i", $entryId);
$stmtDetailed->execute();
$resultDetailed = $stmtDetailed->get_result();

?>
<!DOCTYPE html>
<html>

<head>
    <title>Journal Entry Details</title>
</head>

<body>
    <div>
        <span style="font-weight: bold;"><?php echo $rowMaster['description']; ?></span>
        <span style="float: right;"><?php echo $rowMaster['jdate']; ?></span>
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
            $totalDebit = 0;
            $totalCredit = 0;
            while ($rowDetailed = $resultDetailed->fetch_assoc()) {
                $totalDebit += $rowDetailed['DebitAmount'];
                $totalCredit += $rowDetailed['CreditAmount'];
                echo "<tr>";
                echo "<td>" . $rowDetailed['AccountID'] . "</td>";
                echo "<td>" . $rowDetailed['description'] . "</td>";
                echo "<td>" . number_format($rowDetailed['DebitAmount'], 2) . "</td>";
                echo "<td>" . number_format($rowDetailed['CreditAmount'], 2) . "</td>";
                echo "</tr>";
            }
            ?>
        </tbody>
    </table>
    <p>Total Debit: <?php echo number_format($totalDebit, 2); ?></p>
    <p>Total Credit: <?php echo number_format($totalCredit, 2); ?></p>
</body>

</html>