<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
// Set character encoding
request.setCharacterEncoding("UTF-8");

// Check if user is logged in
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
if (authenticatedUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Get form parameters
int customerId = Integer.parseInt(request.getParameter("customerId"));
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String email = request.getParameter("email");
String phonenum = request.getParameter("phonenum");
String address = request.getParameter("address");
String city = request.getParameter("city");
String state = request.getParameter("state");
String postalCode = request.getParameter("postalCode");
String country = request.getParameter("country");
String newPassword = request.getParameter("newPassword");
String confirmPassword = request.getParameter("confirmPassword");

// Server-side validation
StringBuilder errors = new StringBuilder();

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

// Password validation (only if changing password)
boolean changingPassword = false;
if (newPassword != null && newPassword.length() > 0) {
    changingPassword = true;
    if (newPassword.length() < 8) {
        errors.append("Password must be at least 8 characters. ");
    } else if (!newPassword.matches("(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*")) {
        errors.append("Password must contain uppercase, lowercase, and numbers. ");
    }
    if (!newPassword.equals(confirmPassword)) {
        errors.append("Passwords do not match. ");
    }
}

// If there are validation errors, redirect back
if (errors.length() > 0) {
    response.sendRedirect("editProfile.jsp?error=" + java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
    return;
}

// Database connection
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String dbUid = "sa";
String dbPw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, dbUid, dbPw);

    // Update customer information
    String updateSQL;
    if (changingPassword) {
        updateSQL = "UPDATE customer SET firstName = ?, lastName = ?, email = ?, phonenum = ?, " +
                    "address = ?, city = ?, state = ?, postalCode = ?, country = ?, password = ? " +
                    "WHERE customerId = ?";
        pst = con.prepareStatement(updateSQL);
        pst.setString(1, firstName.trim());
        pst.setString(2, lastName.trim());
        pst.setString(3, email.trim());
        pst.setString(4, phonenum != null && !phonenum.trim().isEmpty() ? phonenum.trim() : null);
        pst.setString(5, address.trim());
        pst.setString(6, city.trim());
        pst.setString(7, state.trim().toUpperCase());
        pst.setString(8, postalCode.trim().toUpperCase());
        pst.setString(9, country.trim());
        pst.setString(10, newPassword); // Note: In production, hash the password!
        pst.setInt(11, customerId);
    } else {
        updateSQL = "UPDATE customer SET firstName = ?, lastName = ?, email = ?, phonenum = ?, " +
                    "address = ?, city = ?, state = ?, postalCode = ?, country = ? " +
                    "WHERE customerId = ?";
        pst = con.prepareStatement(updateSQL);
        pst.setString(1, firstName.trim());
        pst.setString(2, lastName.trim());
        pst.setString(3, email.trim());
        pst.setString(4, phonenum != null && !phonenum.trim().isEmpty() ? phonenum.trim() : null);
        pst.setString(5, address.trim());
        pst.setString(6, city.trim());
        pst.setString(7, state.trim().toUpperCase());
        pst.setString(8, postalCode.trim().toUpperCase());
        pst.setString(9, country.trim());
        pst.setInt(10, customerId);
    }

    int rowsUpdated = pst.executeUpdate();

    if (rowsUpdated > 0) {
        // Update successful
        response.sendRedirect("customer.jsp?success=Profile updated successfully!");
    } else {
        response.sendRedirect("editProfile.jsp?error=" + java.net.URLEncoder.encode("Profile update failed. Please try again.", "UTF-8"));
    }

} catch (SQLException e) {
    response.sendRedirect("editProfile.jsp?error=" + java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
} catch (ClassNotFoundException e) {
    response.sendRedirect("editProfile.jsp?error=" + java.net.URLEncoder.encode("Driver error: " + e.getMessage(), "UTF-8"));
} finally {
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>
