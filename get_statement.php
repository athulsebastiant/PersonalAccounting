<?php
// get_statement.php

// Database connection details
include "Connection.php";

// Retrieve POST variables
$accountId = $_POST['account-select'] ?? '';
$fromDate = $_POST['fromDate'] ?? '';
$toDate = $_POST['toDate'] ?? '';

// Validate input
if (empty($accountId) || empty($fromDate) || empty($toDate)) {
    die("Please provide all required information.");
}

// Create connection
try {
    // Prepare the stored procedure call
    $stmt = $conn->prepare("CALL GetAccTill(?, ?)");

    // Bind parameters
    $stmt->bind_param("is", $accountId, $fromDate);

    // Execute the statement
    $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    // Output HTML
    echo "<h2>Account Statement</h2>";
    echo "<p>Account ID: " . htmlspecialchars($accountId) . "</p>";
    echo "<p>From: " . htmlspecialchars($fromDate) . " To: " . htmlspecialchars($toDate) . "</p>";

    if (
        $result->num_rows > 0
    ) {
        echo "<table id='result-table'>
                <tr>
                    <th>Date</th>
                    
                    <th>Debit Amount</th>
                    <th>Credit Amount</th>
                    <th>Description</th>
                </tr>";

        while ($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>" . htmlspecialchars($row['Date']) . "</td>
                    <td>" . htmlspecialchars($row['DebitAmount']) . "</td>
                    <td>" . htmlspecialchars($row['CreditAmount']) . "</td>
                    <td>" . htmlspecialchars($row['Description']) . "</td>
                  </tr>";
        }
    } else {
        echo "<p>No transactions found for the specified period.</p>";
    }
    $stmt->close();
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
    // Check connection
}


try {
    // Prepare the stored procedure call
    $stmt = $conn->prepare("CALL SOA(?, ?, ?)");

    // Bind parameters
    $stmt->bind_param("iss", $accountId, $fromDate, $toDate);

    // Execute the statement
    $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    // Output HTML


    if ($result->num_rows > 0) {


        while ($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>" . htmlspecialchars($row['createdDate']) . "</td>
                    
                    <td>" . htmlspecialchars($row['DebitAmount']) . "</td>
                    <td>" . htmlspecialchars($row['CreditAmount']) . "</td>
                    <td>" . htmlspecialchars($row['description']) . "</td>
                  </tr>";
        }

        echo "</table>";
    } else {
        echo "<p>No transactions found for the specified period.</p>";
    }

    // Close the statement
    $stmt->close();
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
} finally {
    // Close the connection
    $conn->close();
}
