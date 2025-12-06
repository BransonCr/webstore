<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Edit Profile - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
    .edit-form {
        max-width: 700px;
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
    .form-group input {
        width: 100%;
        padding: 10px;
        background: rgba(51, 0, 0, 0.5);
        border: 1px solid #666;
        border-radius: 5px;
        color: #ffcccc;
        font-size: 1em;
    }
    .form-group input:focus {
        outline: none;
        border-color: #ff6666;
        box-shadow: 0 0 10px rgba(255, 102, 102, 0.3);
    }
    .form-group input:disabled {
        opacity: 0.6;
        cursor: not-allowed;
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
    .section-header {
        color: #99ccff;
        text-shadow: 0 0 10px #0066ff;
        border-bottom: 2px solid #660000;
        padding-bottom: 10px;
        margin: 30px 0 20px 0;
    }
</style>
<script>
function validateEditForm() {
    let isValid = true;

    // Clear previous errors
    document.querySelectorAll('.error-message').forEach(el => el.classList.remove('show'));

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
    if (!/^[A-Z]\d[A-Z]\s?\d[A-Z]\d$/i.test(postalCode)) {
        showError('postalCode', 'Postal code format: A1A 1A1');
        isValid = false;
    }

    // Password validation (only if changing password)
    const newPassword = document.getElementById('newPassword').value;
    if (newPassword && newPassword.length > 0) {
        if (newPassword.length < 8) {
            showError('newPassword', 'Password must be at least 8 characters');
            isValid = false;
        } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(newPassword)) {
            showError('newPassword', 'Password must contain uppercase, lowercase, and numbers');
            isValid = false;
        }

        const confirmPassword = document.getElementById('confirmPassword').value;
        if (newPassword !== confirmPassword) {
            showError('confirmPassword', 'Passwords do not match');
            isValid = false;
        }
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
</script>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1>Edit Your Profile :)</h1>

<%
// Check if user is logged in
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
if (authenticatedUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Display error/success messages
String errorMsg = request.getParameter("error");
if (errorMsg != null) {
    out.println("<div class='error' style='text-align:center;'>" + errorMsg + "</div>");
}
String successMsg = request.getParameter("success");
if (successMsg != null) {
    out.println("<div class='success' style='text-align:center;'>" + successMsg + "</div>");
}

// Load customer data
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String dbUid = "sa";
String dbPw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;
ResultSet rs = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, dbUid, dbPw);

    pst = con.prepareStatement("SELECT * FROM customer WHERE userid = ?");
    pst.setString(1, authenticatedUser);
    rs = pst.executeQuery();

    if (rs.next()) {
        // Load customer data
        int customerId = rs.getInt("customerId");
        String firstName = rs.getString("firstName");
        String lastName = rs.getString("lastName");
        String email = rs.getString("email");
        String phonenum = rs.getString("phonenum");
        String address = rs.getString("address");
        String city = rs.getString("city");
        String state = rs.getString("state");
        String postalCode = rs.getString("postalCode");
        String country = rs.getString("country");
%>
    <div class="edit-form">
        <form method="post" action="editProfileAction.jsp" onsubmit="return validateEditForm()">
            <input type="hidden" name="customerId" value="<%= customerId %>">

            <h2 class="section-header">Personal Information</h2>

            <div class="form-group">
                <label for="firstName">First Name</label>
                <input type="text" id="firstName" name="firstName" value="<%= firstName != null ? firstName : "" %>" required>
                <div id="firstNameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="lastName">Last Name</label>
                <input type="text" id="lastName" name="lastName" value="<%= lastName != null ? lastName : "" %>" required>
                <div id="lastNameError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" value="<%= email != null ? email : "" %>" required>
                <div id="emailError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="phonenum">Phone Number (Format: 123-456-7890)</label>
                <input type="tel" id="phonenum" name="phonenum" value="<%= phonenum != null ? phonenum : "" %>" placeholder="123-456-7890">
                <div id="phonenumError" class="error-message"></div>
            </div>

            <h2 class="section-header">Address</h2>

            <div class="form-group">
                <label for="address">Street Address</label>
                <input type="text" id="address" name="address" value="<%= address != null ? address : "" %>" required>
                <div id="addressError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="city">City</label>
                <input type="text" id="city" name="city" value="<%= city != null ? city : "" %>" required>
                <div id="cityError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="state">State/Province (2 letters)</label>
                <input type="text" id="state" name="state" value="<%= state != null ? state : "" %>" required maxlength="2">
                <div id="stateError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="postalCode">Postal Code (Format: A1A 1A1)</label>
                <input type="text" id="postalCode" name="postalCode" value="<%= postalCode != null ? postalCode : "" %>" required>
                <div id="postalCodeError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="country">Country</label>
                <input type="text" id="country" name="country" value="<%= country != null ? country : "" %>" required>
                <div id="countryError" class="error-message"></div>
            </div>

            <h2 class="section-header">Change Password (Optional)</h2>
            <p style="color: #ffcc99; font-size: 0.9em;">Leave blank to keep current password</p>

            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" placeholder="Leave blank to keep current password">
                <div id="newPasswordError" class="error-message"></div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm New Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password">
                <div id="confirmPasswordError" class="error-message"></div>
            </div>

            <div style="text-align:center; margin-top:30px;">
                <button type="submit" class="btn btn-primary"> Save Changes</button>
                <a href="customer.jsp" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
<%
    } else {
        out.println("<div class='error'>Customer not found.</div>");
    }
} catch (Exception e) {
    out.println("<div class='error'>Error loading profile: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) { }
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>

</div>

</body>
</html>
