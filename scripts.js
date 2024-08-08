
let validEmail = 0;
let validPhone = 0;
let validUsername = 0;
let validPassword = 0;
let validFirstName = 0;
let validLastName = 0;

function validateIt(event) {
    if (validEmail == 1 && validPassword == 1 && validPhone == 1 && validUsername == 1 && validFirstName == 1 && validLastName == 1) {
        console.log("All set");
        if (confirm("Are you sure about that?")) {
            return true;
        }

        return false;

    } else {
        // Prevent form submission if validation fails
        event.preventDefault();
        return false;
    }


}





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
        if (id === 'firstname') {
            validFirstName = 1;
            console.log("All setfn");
        } else if (id === 'lastname') {
            validLastName = 1;
            console.log("All setln");
        }
        //return true;
    } else {
        message.textContent = 'Invalid Name';
        message.style.color = 'red';
        if (id === 'firstname') {
            validFirstName = 0;
        } else if (id === 'lastname') {
            validLastName = 0;
        }
        //return false;
    }
}
// Function to validate email
async function validateEmail() {
    const email = document.getElementById('email').value;
    const message = document.getElementById('email-message');
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (email === "") {
        message.textContent = "";
    } else if (regex.test(email)) {/*
        if (checkExists(email, 'email', message)) {
            validEmail = 1;
            console.log("All setem");
        }*/
        try {
            const exists = await checkExists(email, 'email', message);
            if (exists) {
                console.log("All setem");
                validEmail = 1;
                console.log(validEmail);
            }
        } catch (error) {
            console.error(error);
        }


    }

    else {
        message.textContent = 'Invalid Email';
        message.style.color = 'red';
        validEmail = 0;

    }

}

async function validatePhone() {
    const phone = document.getElementById('phone').value;
    const message = document.getElementById('phone-message');
    const regex = /^\d{10}$/;

    if (email === "") {
        message.textContent = "";
    } else if (regex.test(phone)) {
        /*if (checkExists(phone, 'phone', message)) {
            validPhone = 1;
            console.log("All setph");
        }*/
        try {
            const exists = await checkExists(phone, 'phone', message);
            if (exists) {
                console.log("All setph");
                validPhone = 1;
                console.log(validPhone);
            }
        } catch (error) {
            console.error(error);
        }



    } else {
        message.textContent = 'Invalid Phone Number';
        message.style.color = 'red';
        validPhone = 0;

    }
}


// Function to validate username
async function validateUsername() {
    /*const username = document.getElementById('username').value;
    const message = document.getElementById('username-message');
    const regex = /^[a-zA-Z0-9_-]{8,20}$/;

    if (username === "") {
        message.textContent = "";
    } else if (regex.test(username)) {
        console.log("ooga");
        if (checkExists(username, 'username', message)) {
            console.log("All setus");
            validUsername = 1;
            console.log(validUsername);

        }




    } else {
        message.textContent = 'Invalid Username';
        message.style.color = 'red';
        validUsername = 0;
        //return false;
    }*/
    const username = document.getElementById('username').value;
    const message = document.getElementById('username-message');
    const regex = /^[a-zA-Z0-9_-]{8,20}$/;

    if (username === "") {
        message.textContent = "";
    } else if (regex.test(username)) {
        console.log("ooga");
        try {
            const exists = await checkExists(username, 'username', message);
            if (exists) {
                console.log("All setus");
                validUsername = 1;
                console.log(validUsername);
            }
        } catch (error) {
            console.error(error);
        }
    } else {
        message.textContent = 'Invalid Username';
        message.style.color = 'red';
        validUsername = 0;
    }


}

function checkExists(value, fieldType, messageElement) {
    /* const xhr = new XMLHttpRequest();
     xhr.open("POST", "usercheck.php", true);
     xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
 
     xhr.onload = function () {
         if (this.status === 200) {
             console.log(this.responseText);
             const response = JSON.parse(this.responseText);
             console.log(this.responseText);
             if (response.exists) {
                 messageElement.textContent = fieldType + ' already exists';
                 messageElement.style.color = 'red';
                 return false;
             } else {
                 messageElement.textContent = 'Valid ' + fieldType;
                 messageElement.style.color = 'green';
                 console.log("Good ")
                 return true;
             }
         } else {
             console.error("Error: " + this.status);
         }
     };
     xhr.send(fieldType + "=" + encodeURIComponent(value));*/

    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open("POST", "usercheck.php", true);
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        xhr.onload = function () {
            if (this.status === 200) {
                const response = JSON.parse(this.responseText);
                if (response.exists) {
                    messageElement.textContent = fieldType + ' already exists';
                    messageElement.style.color = 'red';
                    resolve(false);
                } else {
                    messageElement.textContent = 'Valid ' + fieldType;
                    messageElement.style.color = 'green';
                    resolve(true);
                }
            } else {
                reject("Error: " + this.status);
            }
        };
        xhr.onerror = function () {
            reject("Request failed");
        };
        xhr.send(fieldType + "=" + encodeURIComponent(value));
    });
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
        validPassword = 1;
        console.log("All setpa");
        //return true;
    } else {
        message.textContent = "Invalid Password. It must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
        message.style.color = 'red';
        validPassword = 0;
        //return false;
    }
}

function showPasswordConstraints() {
    const message = document.getElementById('password-message');
    message.textContent = "Password must be 8-20 characters long, include at least one uppercase letter, one lowercase letter, one digit, and one special character.";
    message.style.color = 'black';
}

function showUsernameConstraints() {
    const message = document.getElementById('username-message');
    message.textContent = "Username must be 8-20 characters long and alphanumeric only. ";
    message.style.color = 'black';
}