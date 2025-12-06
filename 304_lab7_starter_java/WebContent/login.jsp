<!DOCTYPE html>
<html>
<head>
<title>Login - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1> Login to Your Account</h1>

    <%
    String loginMessage = (String) session.getAttribute("loginMessage");
    if (loginMessage != null) {
        out.println("<div class='error'>" + loginMessage + "</div>");
        session.removeAttribute("loginMessage");
    }
    %>

    <form name="loginForm" method="post" action="validateLogin.jsp">
        <table style="margin: 30px auto; max-width: 500px;">
            <tr>
                <td><label>Username:</label></td>
                <td><input type="text" name="username" size="30" required placeholder="Enter username"></td>
            </tr>
            <tr>
                <td><label>Password:</label></td>
                <td><input type="password" name="password" size="30" required placeholder="Enter password"></td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center; padding-top: 20px;">
                    <input type="submit" value=" Login" class="btn btn-primary">
                    <input type="reset" value=" Reset" class="btn btn-secondary">
                </td>
            </tr>
        </table>
    </form>

    <div class="info mt-3">
        <h3>📝 Test Accounts</h3>
        <ul>
            <li>Username: <strong>arnold</strong>, Password: <strong>304Arnold!</strong></li>
            <li>Username: <strong>bobby</strong>, Password: <strong>304Bobby!</strong></li>
            <li>Username: <strong>candace</strong>, Password: <strong>304Candace!</strong></li>
        </ul>
    </div>

    <div class="text-center mt-3" style="padding: 20px; background: rgba(102,0,0,0.2); border-radius: 10px; margin-top: 30px;">
        <h3 style="color: #99ccff;">Don't have an account?</h3>
        <p style="color: #ffcc99;">Join the Cursed & Blessed Emporium today!</p>
        <a href="register.jsp" class="btn btn-primary">Create New Account</a>
    </div>

    <p class="text-center mt-3">
        <a href="index.jsp">← Back to Home</a>
    </p>
</div>

</body>
</html>
