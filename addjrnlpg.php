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

        .editable {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 6px;
        }
    </style>
    <title>Journal Entry Details</title>
</head>

<body>

    <div class="journal-container">
        <div class="journal-header">
            <h1>Journal Entry Details</h1>
            <div class="date"><?php echo date("Y-m-d"); ?></div>
        </div>

        <table id="journalTable">
            <thead>
                <tr>
                    <th>Account</th>
                    <th>Label</th>
                    <th>Debit</th>
                    <th>Credit</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="4" class="enter-line" onclick="addNewRow(this)">Enter line</td>
                </tr>
            </tbody>
        </table>
    </div>

    <script>
        function addNewRow(element) {
            const table = document.getElementById('journalTable').getElementsByTagName('tbody')[0];
            const newRow = table.insertRow(table.rows.length - 1);

            for (let i = 0; i < 4; i++) {
                const newCell = newRow.insertCell(i);
                newCell.contentEditable = true;
                newCell.classList.add('editable');
            }

            element.innerHTML = '';
            element.removeAttribute('onclick');

            const newEnterLineRow = table.insertRow();
            const newEnterLineCell = newEnterLineRow.insertCell(0);
            newEnterLineCell.colSpan = 4;
            newEnterLineCell.classList.add('enter-line');
            newEnterLineCell.innerHTML = 'Enter line';
            newEnterLineCell.setAttribute('onclick', 'addNewRow(this)');
        }
    </script>

</body>

</html>