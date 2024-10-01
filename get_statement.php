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
                echo " <style>
                

                    #result-table thead {
                        background-color: #4CAF50;
                        color: white;
                    }

                    

                    #result-table tbody tr:nth-child(even) {
                        background-color: #f9f9f9;
                    }

                    #result-table tr:hover {
                        background-color: #f5f5f5;
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
                        background-color: #4CAF50;
                    }
                        h2 {
                font-family: Arial, sans-serif;
                font-size: 24px;
                color: #333;
                margin-top: 20px;
                text-align: center;
            }

            /* Account Details Styling */
            p {
                font-family: Arial, sans-serif;
                font-size: 16px;
                color: #555;
                margin: 10px 0;
                text-align: center;
            }

            /* Wrapper for Account Statement Details */
            #statement-details {
                margin: 20px auto;
                padding: 20px;
                max-width: 800px;
                border: 1px solid #ddd;
                border-radius: 8px;
                background-color: #f9f9f9;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
                        </style>
            ";
                echo "<div id='statement-details'>";
                echo "<h2>Account Statement</h2>";
                echo "<p>Account ID: " . htmlspecialchars($accountId) . "</p>";
                echo "<p>From: " . htmlspecialchars($fromDate) . " To: " . htmlspecialchars($toDate) . "</p>";
                echo "</div>";

                if (
                    $result->num_rows > 0
                ) {
                    echo "<table id='result-table'>
                    <thead>
                            <tr>
                                <th>Date</th>
                                <th>Entry ID</th>
                                <th>Journal Description</th>
                                <th>Debit Amount</th>
                                <th>Credit Amount</th>
                                <th>Narrative</th>
                            </tr>
                            </thead>";

                    while ($row = $result->fetch_assoc()) {
                        echo "
                        <tbody>
                        <tr>
                                <td>" . htmlspecialchars($row['Date']) . "</td>
                                <td></td><td></td>
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
                                <td>" . htmlspecialchars($row['EntryID']) . "</td>
                                <td>" . htmlspecialchars($row['JournalDes']) . "</td>
                                <td>" . htmlspecialchars($row['DebitAmount']) . "</td>
                                <td>" . htmlspecialchars($row['CreditAmount']) . "</td>
                                <td>" . htmlspecialchars($row['description']) . "</td>
                            </tr>";
                    }

                    echo "</tbody></table>";
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
