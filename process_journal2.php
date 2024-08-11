<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
include "Connection.php";
$response = ['status' => 'error'];
try {
    $data = json_decode(file_get_contents("php://input"), true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid JSON input: ' . json_last_error_msg());
    }
    $description = $data['description'];
    $jdate = $data['jdate'];
    $entries = $data['entries'];

    try {
        $sql = "INSERT INTO jrlmaster (jdate, `description`, createdDateTime) VALUES (?, ?, CURRENT_TIMESTAMP())";
        $stmt = $conn->prepare($sql);
        if ($stmt === false) {
            throw new Exception("Error preparing statement for jrlmaster: " . $conn->error);
        }
        $stmt->bind_param("ss", $jdate, $description);

        if (!$stmt->execute()) {
            throw new Exception("Error executing statement for jrlmaster: " . $stmt->error);
        }
        $description_id = $stmt->insert_id;
        $stmt->close();
    } catch (Exception $e) {
        throw new Exception("jrlmaster operation failed: " . $e->getMessage());
    }
    $i = 0;
    foreach ($entries as $entry) {
        $account = $entry['account'];
        $label = $entry['label'];
        $debit = $entry['debit'] ?: null;
        $credit = $entry['credit'] ?: null;
        $i++;
        try {
            // Prepare and execute the second insert for the detailed table
            $sql = "INSERT INTO jrldetailed (EntryID, LineID, AccountID, `description`, DebitAmount, CreditAmount) VALUES (?, ?, ?, ?, ?, ?)";
            $stmt = $conn->prepare($sql);
            if ($stmt === false) {
                die("Error preparing statement: " . $conn->error);
            }

            // Use appropriate data types in bind_param
            if (is_null($debit) && is_null($credit)) {
                $stmt->bind_param("iiisdd", $description_id, $i, $account, $label, 0.0, 0.0);
            } elseif (is_null($debit)) {
                $stmt->bind_param("iiisdd", $description_id, $i, $account, $label, 0.0, $credit);
            } elseif (is_null($credit)) {
                $stmt->bind_param("iiisdd", $description_id, $i, $account, $label, $debit, 0.0);
            } else {
                $stmt->bind_param("iiisdd", $description_id, $i, $account, $label, $debit, $credit);
            }

            //$stmt->execute();
            if (!$stmt->execute()) {
                throw new Exception("Error executing statement for jrldetailed: " . $stmt->error);
            }
            $stmt->close();
        } catch (Exception $e) {
            throw new Exception("Error processing entry: " . $e->getMessage());
        }
    }

    $conn->close();

    echo json_encode(['status' => 'success']);
    exit();
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
}

$conn->close();

echo json_encode($response);
