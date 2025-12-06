<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Create Account - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
    .register-form {
        max-width: 600px;
        margin: 40px auto;
        background: rgba(0, 0, 0, 0.6);
        padding: 30px;
        border: 2px solid #660000;
        border-radius: 10px;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block;
        color: #ffcc99;
        margin-bottom: 5px;
        font-weight: bold;
    }
    .form-group input, .form-group select {
        width: 100%;
        padding: 10px;
        background: rgba(51, 0, 0, 0.5);
        border: 1px solid #666;
        border-radius: 5px;
        color: #ffcccc;
        font-size: 1em;
    }
    .form-group input:focus, .form-group select:focus {
        outline: none;
        border-color: #ff6666;
        box-shadow: 0 0 10px rgba(255, 102, 102, 0.3);
    }
    .error-message {
        color: #ff3333;
        font-size: 0.9em;
        margin-top: 5px;
        display: none;
    }
    .error-message.show {
        display: block;
    }
    .password-strength {
        margin-top: 5px;
        font-size: 0.9em;
    }
    .strength-weak { color: #ff3333; }
    .strength-medium { color: #ffcc00; }
    .strength-strong { color: #33ff33; }
    .required {
        color: #ff6666;
    }
</style>
<script>
// JavaScript validation
function validateForm() {
    let isValid = true;

    // Clear previous errors
    document.querySelectorAll('.error-message').forEach(el => el.classList.remove('show'));

    // Username validation
    const username = document.getElementById('userid').value.trim();
    if (username.length < 3) {
        showError('userid', 'Username must be at least 3 characters');
        isValid = false;
    } else if (!/^[a-zA-Z0-9_]+$/.test(username)) {
        showError('userid', 'Username can only contain letters, numbers, and underscores');
        isValid = false;
    }

    // Password validation
    const password = document.getElementById('password').value;
    if (password.length < 8) {
        showError('password', 'Password must be at least 8 characters');
        isValid = false;
    } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
        showError('password', 'Password must contain uppercase, lowercase, and numbers');
        isValid = false;
    }

    // Confirm password
    const confirmPassword = document.getElementById('confirmPassword').value;
    if (password !== confirmPassword) {
        showError('confirmPassword', 'Passwords do not match');
        isValid = false;
    }

    // First name validation
    const firstName = document.getElementById('firstName').value.trim();
    if (firstName.length < 1) {
        showError('firstName', 'First name is required');
        isValid = false;
    }

    // Last name validation
    const lastName = document.getElementById('lastName').value.trim();
    if (lastName.length < 1) {
        showError('lastName', 'Last name is required');
        isValid = false;
    }

    // Email validation
    const email = document.getElementById('email').value.trim();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showError('email', 'Please enter a valid email address');
        isValid = false;
    }

    // Phone validation (optional but if provided, must be valid)
    const phone = document.getElementById('phonenum').value.trim();
    if (phone && !/^\d{3}-\d{3}-\d{4}$/.test(phone)) {
        showError('phonenum', 'Phone format: 123-456-7890');
        isValid = false;
    }

    // Address validation
    const address = document.getElementById('address').value.trim();
    if (address.length < 5) {
        showError('address', 'Please enter a valid address');
        isValid = false;
    }

    // City validation
    const city = document.getElementById('city').value.trim();
    if (city.length < 2) {
        showError('city', 'Please enter a valid city');
        isValid = false;
    }

    // State validation
    const state = document.getElementById('state').value.trim();
    if (state.length !== 2) {
        showError('state', 'State must be 2 characters (e.g., BC, AB)');
        isValid = false;
    }

    // Postal code validation
    const postalCode = document.getElementById('postalCode').value.trim();
    if (!/^[A-Z]\d[A-Z]\s?\d[A-Z]\d$/.test(postalCode.toUpperCase())) {
        showError('postalCode', 'Postal code format: A1A 1A1');
        isValid = false;
    }

    // Country validation
    const country = document.getElementById('country').value.trim();
    if (country.length < 2) {
        showError('country', 'Please enter a valid country');
        isValid = false;
    }

    return isValid;
}

function showError(fieldId, message) {
    const errorEl = document.getElementById(fieldId + 'Error');
    if (errorEl) {
        errorEl.textContent = message;
        errorEl.classList.add('show');
    }
}

// Password strength indicator
function checkPasswordStrength() {
    const password = document.getElementById('password').value;
    const strengthEl = document.getElementById('passwordStrength');

    if (password.length === 0) {
        strengthEl.textContent = '';
        return;
    }

    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;

    if (strength <= 2) {
        strengthEl.textContent = 'Weak';
        strengthEl.className = 'password-strength strength-weak';
    } else if (strength <= 4) {
        strengthEl.textContent = 'Medium';
        strengthEl.className = 'password-strength strength-medium';
    } else {
        strengthEl.textContent = 'Strong';
        strengthEl.className = 'password-strength strength-strong';
    }
}
</script>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1>=% Create Your Account =</h1>
    <p style="text-align:center; color:#ffcc99;">Join the Cursed & Blessed Emporium and start shopping!</p>

    <%
    String errorMsg = request.getParameter("error");
    if (errorMsg != null) {
        out.println("<div class='error' style='text-align:center;'>" + errorMsg + "</div>");
    }
    String successMsg = request.getParameter("success");
    if (successMsg != null) {
        out.println("<div class='success' style='text-align:center;'>" + successMsg + "</div>");
    }
    %>

    <div class="register-form">
        <form method="post" action="registerAction.jsp" onsubmit="return validateForm()">
            <h2 style="text-align:center; color:#ffcc99;">Account Information</h2>

            <div class="form-group">
                <label for="userid">Username <span class="required">*</span></label>
                <input type="text" id="userid" name="userid" required maxlength="50">
                <div id="useridError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="password">Password <span class="required">*</span></label>
                <input type="password" id="password" name="password" required maxlength="50" onkeyup="checkPasswordStrength()">
                <div id="passwordStrength" class="password-strength"></div>
                <div id="passwordError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password <span class="required">*</span></label>
                <input type="password" id="confirmPassword" name="confirmPassword" required maxlength="50">
                <div id="confirmPasswordError" class="error-message"></div>
            </div>

            <h3 style="text-align:center; color:#99ccff; margin-top:30px;">Personal Information</h3>

            <div class="form-group">
                <label for="firstName">First Name <span class="required">*</span></label>
                <input type="text" id="firstName" name="firstName" required maxlength="40">
                <div id="firstNameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="lastName">Last Name <span class="required">*</span></label>
                <input type="text" id="lastName" name="lastName" required maxlength="40">
                <div id="lastNameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="email">Email <span class="required">*</span></label>
                <input type="email" id="email" name="email" required maxlength="50">
                <div id="emailError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="phonenum">Phone Number (Format: 123-456-7890)</label>
                <input type="tel" id="phonenum" name="phonenum" maxlength="20" placeholder="123-456-7890">
                <div id="phonenumError" class="error-message"></div>
            </div>

            <h3 style="text-align:center; color:#99ccff; margin-top:30px;">Address</h3>

            <div class="form-group">
                <label for="address">Street Address <span class="required">*</span></label>
                <input type="text" id="address" name="address" required maxlength="50">
                <div id="addressError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="city">City <span class="required">*</span></label>
                <input type="text" id="city" name="city" required maxlength="40">
                <div id="cityError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="state">State/Province (2 letters, e.g., BC, AB) <span class="required">*</span></label>
                <input type="text" id="state" name="state" required maxlength="2" placeholder="BC">
                <div id="stateError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="postalCode">Postal Code (Format: A1A 1A1) <span class="required">*</span></label>
                <input type="text" id="postalCode" name="postalCode" required maxlength="10" placeholder="V6T 1Z4">
                <div id="postalCodeError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="country">Country <span class="required">*</span></label>
                <input type="text" id="country" name="country" required maxlength="40" value="Canada">
                <div id="countryError" class="error-message"></div>
            </div>

            <div style="text-align:center; margin-top:30px;">
                <button type="submit" class="btn btn-primary">Create Account</button>
                <a href="login.jsp" class="btn btn-secondary">Back to Login</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
