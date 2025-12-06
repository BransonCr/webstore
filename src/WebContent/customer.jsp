<!DOCTYPE html>
<html>
<head>
<title>Customer Info - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
	String userName1= (String) session.getAttribute("authenticatedUser");
%>

<h1> Customer Profile</h1>

<%
// TODO: Print Customer information
String sql = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalCode, country, userid FROM customer WHERE userid = ?";

try {
    getConnection();
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setString(1, userName1);
    ResultSet rs = pstmt.executeQuery();
    
    if (rs.next()) {
        // Customer found - display information
        int customerId = rs.getInt("customerId");
        String firstName = rs.getString("firstName");
        String lastName = rs.getString("lastName");
        String email = rs.getString("email");
        String phone = rs.getString("phonenum");
        String address = rs.getString("address");
        String city = rs.getString("city");
        String state = rs.getString("state");
        String postalCode = rs.getString("postalCode");
        String country = rs.getString("country");
        String userid = rs.getString("userid");
        
        out.println("<div class='customer-info'>");
        out.println("<div class='info-row'><span class='info-label'>Customer ID:</span> <span class='info-value'>" + customerId + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Username:</span> <span class='info-value'>" + userid + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Name:</span> <span class='info-value'>" + firstName + " " + lastName + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Email:</span> <span class='info-value'>" + email + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Phone:</span> <span class='info-value'>" + phone + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Address:</span> <span class='info-value'>" + address + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>City:</span> <span class='info-value'>" + city + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>State/Province:</span> <span class='info-value'>" + state + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Postal Code:</span> <span class='info-value'>" + postalCode + "</span></div>");
        out.println("<div class='info-row'><span class='info-label'>Country:</span> <span class='info-value'>" + country + "</span></div>");
        out.println("</div>");
    } else {
        out.println("<div class='error'>Customer information not found.</div>");
    }
    
    rs.close();
    pstmt.close();
}
catch (SQLException ex) {
    out.println("<div class='error'>Error retrieving customer information: " + ex.getMessage() + "</div>");
}
finally {
    // Make sure to close connection
    closeConnection();
}
%>

<div class="text-center mt-3">
    <a href="editProfile.jsp" class="btn btn-primary"> Edit Profile</a>
    <a href="myorders.jsp" class="btn btn-primary"> My Orders</a>
    <a href="index.jsp" class="btn btn-secondary"> Home</a>
    <a href="logout.jsp" class="btn btn-secondary">Logout</a>
</div>

</div>

</body>
</html>
