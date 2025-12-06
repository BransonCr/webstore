<%@ page import="java.sql.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
// Set character encoding for proper handling of special characters
request.setCharacterEncoding("UTF-8");

// Get form parameters
String userid = request.getParameter("userid");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String email = request.getParameter("email");
String phonenum = request.getParameter("phonenum");
String address = request.getParameter("address");
String city = request.getParameter("city");
String state = request.getParameter("state");
String postalCode = request.getParameter("postalCode");
String country = request.getParameter("country");

// Server-side validation
StringBuilder errors = new StringBuilder();

// Validate username
if (userid == null || userid.trim().length() < 3) {
    errors.append("Username must be at least 3 characters. ");
} else if (!userid.matches("^[a-zA-Z0-9_]+$")) {
    errors.append("Username can only contain letters, numbers, and underscores. ");
}

// Validate password
if (password == null || password.length() < 8) {
    errors.append("Password must be at least 8 characters. ");
} else if (!password.matches("(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*")) {
    errors.append("Password must contain uppercase, lowercase, and numbers. ");
}

// Validate password confirmation
if (confirmPassword == null || !password.equals(confirmPassword)) {
    errors.append("Passwords do not match. ");
}

// Validate required fields
if (firstName == null || firstName.trim().isEmpty()) {
    errors.append("First name is required. ");
}
if (lastName == null || lastName.trim().isEmpty()) {
    errors.append("Last name is required. ");
}
if (email == null || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
    errors.append("Valid email is required. ");
}
if (address == null || address.trim().length() < 5) {
    errors.append("Valid address is required. ");
}
if (city == null || city.trim().length() < 2) {
    errors.append("Valid city is required. ");
}
if (state == null || state.trim().length() != 2) {
    errors.append("State must be 2 characters. ");
}
if (postalCode == null || !postalCode.toUpperCase().matches("^[A-Z]\\d[A-Z]\\s?\\d[A-Z]\\d$")) {
    errors.append("Valid postal code is required. ");
}
if (country == null || country.trim().length() < 2) {
    errors.append("Valid country is required. ");
}

// If there are validation errors, redirect back
if (errors.length() > 0) {
    response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
    return;
}

// Database connection
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String dbUid = "sa";
String dbPw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;
ResultSet rs = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, dbUid, dbPw);

    // Check if username already exists
    pst = con.prepareStatement("SELECT customerId FROM customer WHERE userid = ?");
    pst.setString(1, userid);
    rs = pst.executeQuery();

    if (rs.next()) {
        // Username already exists
        response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Username already exists. Please choose a different username.", "UTF-8"));
        return;
    }
    rs.close();
    pst.close();

    // Check if email already exists
    pst = con.prepareStatement("SELECT customerId FROM customer WHERE email = ?");
    pst.setString(1, email);
    rs = pst.executeQuery();

    if (rs.next()) {
        // Email already exists
        response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Email already registered. Please use a different email or login.", "UTF-8"));
        return;
    }
    rs.close();
    pst.close();

    // Insert new customer
    String insertSQL = "INSERT INTO customer (firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid, password) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    pst = con.prepareStatement(insertSQL);
    pst.setString(1, firstName.trim());
    pst.setString(2, lastName.trim());
    pst.setString(3, email.trim());
    pst.setString(4, phonenum != null && !phonenum.trim().isEmpty() ? phonenum.trim() : null);
    pst.setString(5, address.trim());
    pst.setString(6, city.trim());
    pst.setString(7, state.trim().toUpperCase());
    pst.setString(8, postalCode.trim().toUpperCase());
    pst.setString(9, country.trim());
    pst.setString(10, userid.trim());
    pst.setString(11, password); // Note: In production, hash the password!

    int rowsInserted = pst.executeUpdate();

    if (rowsInserted > 0) {
        // Registration successful - auto-login the user
        session.setAttribute("authenticatedUser", userid.trim());

        // Redirect to success page
        response.sendRedirect("index.jsp");
    } else {
        response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Registration failed. Please try again.", "UTF-8"));
    }

} catch (SQLException e) {
    response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
} catch (ClassNotFoundException e) {
    response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Driver error: " + e.getMessage(), "UTF-8"));
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) { }
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>
