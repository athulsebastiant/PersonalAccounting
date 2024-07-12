<!DOCTYPE html>
<html lang="en" dir="ltr">

<head>
    <meta charset="utf-8">
    <title>myRegistration</title>
    <link rel="stylesheet" href="styles.css">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<body>
    <div class="container">
        <h3 style="color: #4CAF50; font-size:30px;">Get Started</h3>
        <h5>Instant access.</h5>
    </div>
    <div class="form-container">
        <form method="post" action="register.php" class="registration-form">
            <div class="input-group">
                <input type="text" name="firstname" id="firstname" required="required" autofocus="autofocus" placeholder="First Name" onkeyup="validateName('firstname','firstname-message')">
                <span id="firstname-message"></span>
                <!-- <label>First Name</label> -->
            </div>
            <div class="input-group">
                <input type="text" name="lastname" id="lastname" required="required" autofocus="autofocus" placeholder="Last Name" onkeyup="validateName('lastname','lastname-message')">
                <span id="lastname-message"></span>
                <!--<label>Last Name</label>-->
            </div>
            <div class="input-group">
                <input type="email" name="email" id="email" required="required" autofocus="autofocus" placeholder="Email" onkeyup="validateEmail()">
                <span id="email-message" class="message"></span>
                <!--<label>Email</label>-->
            </div>
            <div class="input-group">
                <input type="tel" name="phone" id="phone" required="required" autofocus="autofocus" placeholder="Phone" onkeyup="validatePhone()">
                <span id="phone-message" class="message"></span>
                <!--<label>Email</label>-->
            </div>
            <div class="input-group">
                <input type="text" name="username" id="username" required="required" autofocus="autofocus" placeholder="Username" onkeyup="validateUsername()">
                <span id="username-message"></span>
                <!--<label>Username</label>-->
            </div>
            <div class="input-group">
                <input type="text" name="password" id="password" required="required" autofocus="autofocus" placeholder="Password" onfocus="showPasswordConstraints()" onkeyup="validatePassword()">
                <span id="password-message" style="color:black;"></span>
                <!--<label>Password</label>-->
            </div>
            <div class="button-container">
                <button type="submit" value="Start Now">Start Now</button>
            </div>
        </form>

    </div>
    <script src="scripts.js"></script>
</body>

</html>