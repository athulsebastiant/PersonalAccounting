// Function to validate name
function validateName(id, messageId) {
    const name = document.getElementById(id).value;
    const message = document.getElementById(messageId);
    const regex = /^[a-zA-Z'-]+$/;

    if (name === "") {
        message.textContent = "";
    } else if (regex.test(name)) {
        message.textContent = 'Valid Name';
        message.style.color = 'green';
    } else {
        message.textContent = 'Invalid Name';
        message.style.color = 'red';
    }
}
// Function to validate email
function validateEmail() {
    const email = document.getElementById('email').value;
    const message = document.getElementById('email-message');
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (email === "") {
        message.textContent = "";
    } else if (regex.test(email)) {
        message.textContent = 'Valid Email';
        message.style.color = 'green';
    } else {
        message.textContent = 'Invalid Email';
        message.style.color = 'red';
    }
}
// Function to validate username
function validateUsername() {
    const username = document.getElementById('username').value;
    const message = document.getElementById('username-message');
    const regex = /^[a-zA-Z0-9_-]{8,20}$/;

    if (username === "") {
        message.textContent = "";
    } else if (regex.test(username)) {
        message.textContent = 'Valid Username';
        message.style.color = 'green';
    } else {
        message.textContent = 'Invalid Username';
        message.style.color = 'red';
    }
}

// Function to validate password
function validatePassword() {
    const password = document.getElementById('password').value;
    const message = document.getElementById('password-message');
    const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$/;

    if (password === "") {
        message.textContent = "Password must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
        message.style.color = 'black';
    } else if (regex.test(password)) {
        message.textContent = 'Valid Password';
        message.style.color = 'green';
    } else {
        message.textContent = "Invalid Password. It must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
        message.style.color = 'red';
    }
}

function showPasswordConstraints() {
    const message = document.getElementById('password-message');
    message.textContent = "Password must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
    message.style.color = 'black';
}