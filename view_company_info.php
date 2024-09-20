<?php
// Include database connection
include "Connection.php";

// Check if a row exists in the company_info table
$checkSql = "SELECT COUNT(*) as count FROM company_info";
$checkResult = $conn->query($checkSql);

if ($checkResult && $checkResult->fetch_assoc()['count'] == 0) {
    // No row exists, redirect to GeneralSettings.php
    header("Location: GeneralSettings.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Information</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        .navbar {
            background-color: #333;
            overflow: hidden;
        }

        .navbar a {
            float: left;
            color: white;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }

        .dropdown {
            float: left;
            overflow: hidden;
        }

        .dropdown .dropbtn {
            font-size: 16px;
            border: none;
            outline: none;
            color: white;
            padding: 14px 16px;
            background-color: inherit;
            font-family: inherit;
            margin: 0;
        }

        .navbar a:hover,
        .dropdown:hover .dropbtn {
            background-color: #ddd;
            color: black;
        }

        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #f9f9f9;
            min-width: 160px;
            box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
            z-index: 1;
        }

        .dropdown-content a {
            float: none;
            color: black;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            text-align: left;
        }

        .dropdown-content a:hover {
            background-color: #ddd;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #333;
            text-align: center;
        }

        .company-info {
            margin-top: 20px;
        }

        .info-item {
            margin-bottom: 15px;
        }

        .info-item label {
            font-weight: bold;
            display: inline-block;
            width: 150px;
        }

        .company-logo {
            max-width: 200px;
            max-height: 200px;
            display: block;
            margin: 20px auto;
        }

        .edit-btn,
        .save-btn {
            display: block;
            width: 200px;
            margin: 20px auto;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
        }

        .edit-btn:hover,
        .save-btn:hover {
            background-color: #45a049;
        }

        .hidden {
            display: none;
        }

        .input-group {
            margin-bottom: 20px;
        }

        .info-item textarea {
            width: calc(100% - 160px);
            margin-left: 150px;
        }

        input[type="file"] {
            margin-left: 150px;
        }
    </style>
</head>

<body>
    <div class="navbar">
        <a href="Homepg.php">Dashboard</a>
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
        <a href="logout.php">Logout</a>
    </div>

    <div class="container">
        <h1>Company Information</h1>

        <?php
        // Database connection
        include "Connection.php";

        // Fetch the latest company information
        $sql = "SELECT * FROM company_info ORDER BY id DESC LIMIT 1";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
        ?>
            <div class="company-info">
                <div class="info-item">
                    <label>Company Name:</label>
                    <span><?php echo htmlspecialchars($row["company_name"]); ?></span>
                    <input type="text" name="company_name" class="hidden" value="<?php echo htmlspecialchars($row["company_name"]); ?>">
                </div>
                <div class="info-item">
                    <label>Address:</label>
                    <span><?php echo nl2br(htmlspecialchars($row["address"])); ?></span>
                    <textarea name="address" class="hidden"><?php echo htmlspecialchars($row["address"]); ?></textarea>
                </div>
                <div class="info-item">
                    <label>Registration No:</label>
                    <span><?php echo htmlspecialchars($row["registration_number"]); ?></span>
                    <input type="text" name="registration_number" class="hidden" value="<?php echo htmlspecialchars($row["registration_number"]); ?>">
                </div>
                <div class="info-item">
                    <label>Phone Number:</label>
                    <span><?php echo htmlspecialchars($row["phone_number"]); ?></span>
                    <input type="text" name="phone_number" class="hidden" value="<?php echo htmlspecialchars($row["phone_number"]); ?>">
                </div>
                <div class="info-item">
                    <label>Email:</label>
                    <span><?php echo htmlspecialchars($row["email"]); ?></span>
                    <input type="email" name="email" class="hidden" value="<?php echo htmlspecialchars($row["email"]); ?>">
                </div>
                <?php if (!empty($row["logo_path"])): ?>
                    <img src="<?php echo htmlspecialchars($row["logo_path"]); ?>" alt="Company Logo" class="company-logo">
                <?php endif; ?>
                <div class="info-item">
                    <label>Change Logo:</label>
                    <input type="file" name="logo" class="hidden" accept=".jpg,.jpeg,.png">
                </div>
            </div>
        <?php
        } else {
            echo "<p>No company information found.</p>";
        }
        $conn->close();
        ?>

        <button id="edit-btn" class="edit-btn">Edit</button>
        <button id="save-btn" class="save-btn hidden">Save</button>
    </div>

    <script>
        const editBtn = document.getElementById("edit-btn");
        const saveBtn = document.getElementById("save-btn");
        const spans = document.querySelectorAll(".company-info span");
        const inputs = document.querySelectorAll(".company-info input, .company-info textarea");

        editBtn.addEventListener("click", () => {
            spans.forEach(span => span.classList.add("hidden"));
            inputs.forEach(input => input.classList.remove("hidden"));
            editBtn.classList.add("hidden");
            saveBtn.classList.remove("hidden");
        });

        // Additional code for image preview (optional)
        document.querySelector('input[name="logo"]').addEventListener("change", function(event) {
            const imgPreview = document.querySelector('.company-logo');
            const file = event.target.files[0];
            if (file) {
                imgPreview.src = URL.createObjectURL(file);
            }
        });

        saveBtn.addEventListener("click", () => {
            const companyData = {
                company_name: inputs[0].value,
                address: inputs[1].value,
                registration_number: inputs[2].value,
                phone_number: inputs[3].value,
                email: inputs[4].value,
                logo_filename: document.querySelector('input[name="logo"]').files[0] ? document.querySelector('input[name="logo"]').files[0].name : ""
            };

            fetch("update_company_info.php", {
                    method: "POST",
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(companyData)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        location.reload(); // Reload the page to reflect changes
                    } else {
                        alert("Error: " + data.message);
                    }
                })
                .catch(error => {
                    console.error("Error:", error);
                });
        });
    </script>
</body>

</html>