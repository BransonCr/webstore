<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Customer List - Admin - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
    .customer-table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
    }
    .customer-table th {
        background: #660000;
        color: #ffcc99;
        padding: 12px;
        text-align: left;
        border: 1px solid #ff6666;
    }
    .customer-table td {
        background: rgba(0, 0, 0, 0.5);
        color: #ffcccc;
        padding: 10px;
        border: 1px solid #666;
    }
    .customer-table tr:hover td {
        background: rgba(102, 0, 0, 0.3);
    }
    .search-box {
        max-width: 600px;
        margin: 20px auto;
        padding: 20px;
        background: rgba(0, 0, 0, 0.6);
        border: 2px solid #660000;
        border-radius: 10px;
    }
    .search-box input {
        width: 70%;
        padding: 10px;
        background: rgba(51, 0, 0, 0.5);
        border: 1px solid #666;
        border-radius: 5px;
        color: #ffcccc;
        font-size: 1em;
    }
    .search-box button {
        width: 25%;
        padding: 10px;
        margin-left: 10px;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1> Customer List</h1>
    <p style="text-align:center; color:#ffcc99;">Admin: Manage all customers</p>

    <!-- Search Box -->
    <div class="search-box">
        <form method="get" action="listCustomers.jsp">
            <input type="text" name="search" placeholder="Search by name, email, or username..."
                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
            <button type="submit" class="btn btn-primary">Search</button>
        </form>
    </div>

<%
// Check if user is logged in (optional: add admin role check)
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
if (authenticatedUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;
ResultSet rs = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // Build query with optional search
    String searchTerm = request.getParameter("search");
    String query = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid " +
                   "FROM customer ";

    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
        query += "WHERE firstName LIKE ? OR lastName LIKE ? OR email LIKE ? OR userid LIKE ? ";
    }

    query += "ORDER BY customerId DESC";

    pst = con.prepareStatement(query);

    if (searchTerm != null && !searchTerm.trim().isEmpty()) {
        String searchPattern = "%" + searchTerm + "%";
        pst.setString(1, searchPattern);
        pst.setString(2, searchPattern);
        pst.setString(3, searchPattern);
        pst.setString(4, searchPattern);
    }

    rs = pst.executeQuery();
%>
    <table class="customer-table">
        <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Address</th>
            <th>City</th>
            <th>State</th>
            <th>Postal Code</th>
            <th>Country</th>
        </tr>
<%
    int count = 0;
    while (rs.next()) {
        count++;
        int customerId = rs.getInt("customerId");
        String userid = rs.getString("userid");
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
        <tr>
            <td><%= customerId %></td>
            <td><strong><%= userid != null ? userid : "N/A" %></strong></td>
            <td><%= firstName %> <%= lastName %></td>
            <td><%= email %></td>
            <td><%= phonenum != null ? phonenum : "N/A" %></td>
            <td><%= address %></td>
            <td><%= city %></td>
            <td><%= state %></td>
            <td><%= postalCode %></td>
            <td><%= country %></td>
        </tr>
<%
    }
%>
    </table>

    <div class="info" style="text-align:center; margin-top:20px;">
        <p><strong>Total Customers:</strong> <%= count %></p>
    </div>
<%
    if (count == 0) {
        out.println("<div class='info' style='text-align:center;'>No customers found.</div>");
    }

} catch (SQLException e) {
    out.println("<div class='error'>Database error: " + e.getMessage() + "</div>");
} catch (ClassNotFoundException e) {
    out.println("<div class='error'>Driver error: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) { }
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>

    <div class="text-center mt-3">
        <a href="admin.jsp" class="btn btn-secondary"> Back to Admin Dashboard</a>
        <a href="index.jsp" class="btn btn-secondary"> Home</a>
    </div>
</div>

</body>
</html>
