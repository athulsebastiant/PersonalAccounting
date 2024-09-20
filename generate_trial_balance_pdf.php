<?php
require('fpdf/fpdf.php');
include "Connection.php";
session_start();

if (!isset($_SESSION['username'])) {
    // Redirect to login page if not logged in
    header("Location: loginpg2.php");
    exit();
}

// Fetch company info
$company_info_sql = "SELECT company_name, address, registration_number, phone_number, email, logo_path FROM company_info LIMIT 1";
$company_info_result = $conn->query($company_info_sql);
$company_info = $company_info_result->fetch_assoc();

// Call the stored procedure for Trial Balance
$sql = "CALL GenerateTrialBalance()";
$result = $conn->query($sql);

// Create PDF
class PDF extends FPDF
{
    function Header()
    {
        global $company_info;

        // Add company logo
        if ($company_info['logo_path']) {
            $this->Image($company_info['logo_path'], 10, 10, 30);
        }

        // Add company info
        $this->SetFont('Arial', 'B', 15);
        $this->Cell(0, 10, $company_info['company_name'], 0, 1, 'C');
        $this->SetFont('Arial', '', 10);
        $this->Cell(0, 5, $company_info['address'], 0, 1, 'C');
        $this->Cell(0, 5, "Phone: " . $company_info['phone_number'] . " | Email: " . $company_info['email'], 0, 1, 'C');
        $this->Cell(0, 5, "Registration Number: " . $company_info['registration_number'], 0, 1, 'C');

        // Add title and date
        $this->Ln(10);
        $this->SetFont('Arial', 'B', 16);
        $this->Cell(0, 10, 'Trial Balance', 0, 1, 'C');
        $this->SetFont('Arial', '', 10);
        $this->Cell(0, 5, 'Date: ' . date("Y-m-d"), 0, 1, 'C');
        $this->Ln(10);
    }

    function Footer()
    {
        // Footer with page number
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo() . '/{nb}', 0, 0, 'C');
    }

    function CreateTable($header, $data)
    {
        // Column widths
        $widths = array(40, 70, 40, 40);

        // Calculate the total table width
        $tableWidth = array_sum($widths);

        // Get the width of the page
        $pageWidth = $this->GetPageWidth();

        // Center the table by setting X
        $this->SetX(($pageWidth - $tableWidth) / 2);

        // Table header
        $this->SetFont('Arial', 'B', 10);
        for ($i = 0; $i < count($header); $i++) {
            $this->Cell($widths[$i], 7, $header[$i], 1, 0, 'C');
        }
        $this->Ln();

        // Center the content as well
        $this->SetX(($pageWidth - $tableWidth) / 2);

        // Table content
        $this->SetFont('Arial', '', 10);
        foreach ($data as $row) {
            $this->Cell($widths[0], 6, $row['AccountID'], 1);
            $this->Cell($widths[1], 6, $row['AccountName'], 1);
            $this->Cell($widths[2], 6, $row['Debit'], 1);
            $this->Cell($widths[3], 6, $row['Credit'], 1);
            $this->Ln();

            // Center the next row
            $this->SetX(($pageWidth - $tableWidth) / 2);
        }
    }
}

$pdf = new PDF('L', 'mm', 'A4'); // Set to landscape mode
$pdf->AliasNbPages();
$pdf->AddPage();

// Table header
$header = array('Account ID', 'Account Name', 'Debit', 'Credit');

// Fetching data for the table
$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = array(
            'AccountID' => $row['AccountID'],
            'AccountName' => $row['AccountName'],
            'Debit' => $row['Debit'],
            'Credit' => $row['Credit']
        );
    }
}

// Generate the table
$pdf->CreateTable($header, $data);

$conn->close();

// Output PDF
$pdf->Output('TrialBalance.pdf', 'D');
