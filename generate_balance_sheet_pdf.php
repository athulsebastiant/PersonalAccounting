<?php
session_start();
if (!isset($_SESSION['username'])) {
    header("Location: loginpg2.php");
    exit();
}

require('fpdf/fpdf.php');
include "Connection.php";

class BalanceSheetPDF extends FPDF
{
    private $companyInfo;

    function __construct($companyInfo)
    {
        parent::__construct();
        $this->companyInfo = $companyInfo;
    }

    function Header()
    {
        if ($this->companyInfo['logo_path']) {
            $this->Image($this->companyInfo['logo_path'], 10, 10, 30);
        }
        $this->SetFont('Arial', 'B', 15);
        $this->Cell(0, 10, $this->companyInfo['company_name'], 0, 1, 'C');
        $this->SetFont('Arial', '', 10);
        $this->Cell(0, 5, $this->companyInfo['address'], 0, 1, 'C');
        $this->Cell(0, 5, "Phone: " . $this->companyInfo['phone_number'] . " | Email: " . $this->companyInfo['email'], 0, 1, 'C');
        $this->Cell(0, 5, "Registration Number: " . $this->companyInfo['registration_number'], 0, 1, 'C');
        $this->Ln(10);
    }

    function Footer()
    {
        $this->SetY(-15);
        $this->SetFont('Arial', 'I', 8);
        $this->Cell(0, 10, 'Page ' . $this->PageNo() . '/{nb}', 0, 0, 'C');
    }

    function BalanceSheetTable($data)
    {
        $this->SetFont('Arial', 'B', 12);
        $this->Cell(0, 10, 'Balance Sheet - ' . date("Y-m-d"), 0, 1, 'C');
        $this->Ln(5);

        // Calculate the width of the table
        $tableWidth = 200; // Total width of all columns
        $pageWidth = $this->GetPageWidth() - 20; // Subtracting margins from the page width
        $leftMargin = ($pageWidth - $tableWidth) / 2;

        // Set left margin to center the table
        $this->SetLeftMargin($leftMargin);

        $this->SetFont('Arial', 'B', 10);
        $this->SetFillColor(200, 220, 255);
        $this->Cell(15, 7, 'Acc.ID', 1, 0, 'C', true);
        $this->Cell(55, 7, 'Account Name', 1, 0, 'C', true);
        $this->Cell(30, 7, 'Debit', 1, 0, 'C', true);
        $this->Cell(15, 7, 'Acc.ID', 1, 0, 'C', true);
        $this->Cell(55, 7, 'Account Name', 1, 0, 'C', true);
        $this->Cell(30, 7, 'Credit', 1, 1, 'C', true);

        $this->SetFont('Arial', '', 9);
        $fill = false;
        foreach ($data as $row) {
            $this->SetFillColor(245, 245, 245);

            // Determine if this row should be bold
            $isBold = in_array($row['AccountName'], ['Total Assets']) ||
                in_array($row['ACname'], ['Total Liabilities', 'Total Equity', 'Total Liabilities and Equity']);

            if ($isBold) {
                $this->SetFont('Arial', 'B', 9);
                $this->SetFillColor(220, 220, 220);
            } else {
                $this->SetFont('Arial', '', 9);
            }

            $this->Cell(15, 6, $row['AccountID'], 1, 0, 'L', $fill);
            $this->Cell(55, 6, $row['AccountName'], 1, 0, 'L', $fill);
            $this->Cell(30, 6, $row['debit'], 1, 0, 'R', $fill);
            $this->Cell(15, 6, $row['accountNo'] == 0 ? '' : $row['accountNo'], 1, 0, 'L', $fill);
            $this->Cell(55, 6, $row['ACname'], 1, 0, 'L', $fill);
            $this->Cell(30, 6, $row['credit'], 1, 1, 'R', $fill);

            $fill = !$fill;
        }

        // Reset left margin to default after table rendering
        $this->SetLeftMargin(10);
    }
}


function getCompanyInfo($conn)
{
    $company_info_sql = "SELECT company_name, address, registration_number, phone_number, email, logo_path FROM company_info LIMIT 1";
    $company_info_result = $conn->query($company_info_sql);
    $companyInfo = $company_info_result->fetch_assoc();
    $company_info_result->close();
    return $companyInfo;
}

function getBalanceSheetData($conn)
{
    $sql = "CALL BSOMG()";
    $result = $conn->query($sql);
    $data = [];
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
    }
    if ($result) {
        $result->close();
    }
    return $data;
}

// Create connection


$companyInfo = getCompanyInfo($conn);
$data = getBalanceSheetData($conn);

$pdf = new BalanceSheetPDF($companyInfo);
$pdf->AliasNbPages();
$pdf->AddPage('L', 'A4');
$pdf->BalanceSheetTable($data);

// Output the PDF as a download
$pdf->Output('BalanceSheet.pdf', 'D');

$conn->close();

// We don't need to redirect since we're forcing a download
exit();
