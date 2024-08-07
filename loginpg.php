<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
        body {
            font-family: sans-serif;
        }

        .container {
            text-align: center;
            padding-top: 50px;
            font-size: 20px;
        }

        .form-container {
            margin: 0 auto;
            width: 300px;
            background-color: #f0f0f0;
            padding: 20px;
        }

        .input-group {
            margin-bottom: 15px;
        }

        .input-group input {
            border: none;
            border-bottom: 1px solid #ccc;
            width: 100%;
            padding: 5px;
            font-size: 16px;
        }

        .input-group label {
            display: block;
            margin-top: 5px;
            font-size: 14px;
            color: #333;
        }

        .button-container {
            text-align: center;
        }

        .button-container button {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
    </style>


</head>

<body>
    <div class="container">
        <h2>Login Form</h2>
    </div>
    <div class="form-container">
        <form id="loginForm" method="post" action="login.php">
            <div class="input-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="input-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="button-container">
                <button type="submit" id="loginBtn">Login</button>
            </div>
        </form>
        <p id="message"></p>
    </div>









</body>

</html>