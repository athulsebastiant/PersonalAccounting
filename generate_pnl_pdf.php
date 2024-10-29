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

// Call the stored procedure
$sql = "CALL pl32()";
$result = $conn->query($sql);

class PDF extends FPDF
{
    function Header()
    {
        global $company_info;

        // Logo
        if ($company_info['logo_path']) {
            $this->Image($company_info['logo_path'], 10, 10, 30);
        }

        // Company info
        $this->SetFont('Arial', 'B', 15);
        $this->Cell(0, 10, $company_info['company_name'], 0, 1, 'C');
        $this->SetFont('Arial', '', 10);
        $this->Cell(0, 5, $company_info['address'], 0, 1, 'C');
        $this->Cell(0, 5, "Phone: " . $company_info['phone_number'] . " | Email: " . $company_info['email'], 0, 1, 'C');
        $this->Cell(0, 5, "Registration Number: " . $company_info['registration_number'], 0, 1, 'C');

        // Title
        $this->Ln(10);
        $this->SetFont('Arial', 'B', 16);
        $this->Cell(0, 10, 'Profit and Loss', 0, 1, 'C');
        $this->SetFont('Arial', '', 10);
        $this->Cell(0, 5, 'Date: ' . date("Y-m-d"), 0, 1, 'C');
        $this->Ln(10);
    }

    function Footer()
    {
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo() . '/{nb}', 0, 0, 'C');
    }
}

$pdf = new PDF();
$pdf->AliasNbPages();
$pdf->AddPage('L', 'A4'); // Landscape mode

// Table header
$pdf->SetFont('Arial', 'B', 10);

// Calculate total table width
$tableWidth = 30 + 50 + 30 + 30 + 50 + 30; // Sum of all column widths
$pageWidth = $pdf->GetPageWidth();
$leftMargin = ($pageWidth - $tableWidth) / 2;

// Set left margin for the table
$pdf->SetLeftMargin($leftMargin);

$pdf->Cell(30, 7, 'AccountID', 1);
$pdf->Cell(50, 7, 'AccountName', 1);
$pdf->Cell(30, 7, 'Credit', 1);
$pdf->Cell(30, 7, 'AccountID', 1);
$pdf->Cell(50, 7, 'AccountName', 1);
$pdf->Cell(30, 7, 'Debit', 1);
$pdf->Ln();

// Table content
$pdf->SetFont('Arial', '', 10);
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $pdf->Cell(30, 6, $row['accountID'], 1);
        $pdf->Cell(50, 6, $row['accountName'], 1);
        $pdf->Cell(30, 6, $row['credit'], 1);
        $pdf->Cell(30, 6, $row['lossid'], 1);
        $pdf->Cell(50, 6, $row['lossname'], 1);
        $pdf->Cell(30, 6, $row['debit'], 1);
        $pdf->Ln();
    }
} else {
    $pdf->Cell(0, 10, 'No results found', 1, 1, 'C');
}

// Reset left margin after the table
$pdf->SetLeftMargin(10);

$conn->close();

// Output PDF
$pdf->Output('ProfitAndLoss.pdf', 'D');
