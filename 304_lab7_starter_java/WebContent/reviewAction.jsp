<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Submit Review - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
</head>
<body>
<div class="container">
<%
    // Check if user is logged in
    String authenticatedUser = (String) session.getAttribute("authenticatedUser");
    if (authenticatedUser == null) {
        out.println("<p style='color:red'>You must be logged in to submit a review.</p>");
        out.println("<p><a href='login.jsp'>Login</a></p>");
        return;
    }

    // Get form parameters
    String productIdStr = request.getParameter("productId");
    String productName = request.getParameter("productName");
    String ratingStr = request.getParameter("rating");
    String comment = request.getParameter("comment");

    // Validate inputs
    if (productIdStr == null || ratingStr == null || comment == null || comment.trim().length() < 10) {
        out.println("<p style='color:red'>Invalid review data. Please fill all fields.</p>");
        out.println("<p><a href='product.jsp?id=" + productIdStr + "'>Back to product</a></p>");
        return;
    }

    int productId = 0;
    int rating = 0;

    try {
        productId = Integer.parseInt(productIdStr);
        rating = Integer.parseInt(ratingStr);

        if (rating < 1 || rating > 5) {
            throw new Exception("Rating must be between 1 and 5");
        }
    } catch (Exception e) {
        out.println("<p style='color:red'>Invalid rating or product ID.</p>");
        out.println("<p><a href='product.jsp?id=" + productIdStr + "'>Back to product</a></p>");
        return;
    }

    // Database connection
    final String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    final String uid = "sa";
    final String pw  = "304#sa#pw";

    Connection con = null;
    PreparedStatement checkPst = null;
    PreparedStatement getCustomerIdPst = null;
    PreparedStatement insertPst = null;

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        con = DriverManager.getConnection(url, uid, pw);

        // Get customer ID from username
        String getCustomerIdSql = "SELECT customerId FROM customer WHERE userid = ?";
        getCustomerIdPst = con.prepareStatement(getCustomerIdSql);
        getCustomerIdPst.setString(1, authenticatedUser);
        ResultSet custRs = getCustomerIdPst.executeQuery();

        int customerId = -1;
        if (custRs.next()) {
            customerId = custRs.getInt("customerId");
        } else {
            out.println("<p style='color:red'>Customer not found.</p>");
            return;
        }
        custRs.close();

        // Check if user already reviewed this product
        String checkSql = "SELECT reviewId FROM review WHERE customerId = ? AND productId = ?";
        checkPst = con.prepareStatement(checkSql);
        checkPst.setInt(1, customerId);
        checkPst.setInt(2, productId);
        ResultSet checkRs = checkPst.executeQuery();

        if (checkRs.next()) {
            // User already reviewed - update existing review
            int reviewId = checkRs.getInt("reviewId");
            String updateSql = "UPDATE review SET reviewRating = ?, reviewComment = ?, reviewDate = GETDATE() WHERE reviewId = ?";
            PreparedStatement updatePst = con.prepareStatement(updateSql);
            updatePst.setInt(1, rating);
            updatePst.setString(2, comment);
            updatePst.setInt(3, reviewId);
            updatePst.executeUpdate();
            updatePst.close();

            out.println("<h2>✅ Review Updated!</h2>");
            out.println("<p>Your review for <strong>" + productName + "</strong> has been updated successfully.</p>");
        } else {
            // Insert new review
            String insertSql = "INSERT INTO review (reviewRating, reviewComment, reviewDate, customerId, productId) VALUES (?, ?, GETDATE(), ?, ?)";
            insertPst = con.prepareStatement(insertSql);
            insertPst.setInt(1, rating);
            insertPst.setString(2, comment);
            insertPst.setInt(3, customerId);
            insertPst.setInt(4, productId);
            insertPst.executeUpdate();

            out.println("<h2>✅ Review Submitted!</h2>");
            out.println("<p>Thank you for reviewing <strong>" + productName + "</strong>!</p>");
        }
        checkRs.close();

        // Display the review
        String stars = "";
        for (int i = 0; i < rating; i++) stars += "⭐";
        for (int i = rating; i < 5; i++) stars += "☆";

        out.println("<div style='background: rgba(0,0,0,0.4); padding: 20px; margin: 20px 0; border-radius: 10px;'>");
        out.println("<h3>Your Review:</h3>");
        out.println("<div style='font-size: 1.3em; margin: 10px 0;'>" + stars + " (" + rating + "/5)</div>");
        out.println("<p style='color: #ffdddd;'>" + comment + "</p>");
        out.println("</div>");

        out.println("<p><a href='product.jsp?id=" + productId + "' class='btn btn-primary'>← Back to Product</a></p>");
        out.println("<p><a href='listprod.jsp' class='btn btn-secondary'>Continue Shopping</a></p>");

    } catch (Exception e) {
        out.println("<p style='color:red'>Error submitting review: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if (checkPst != null) try { checkPst.close(); } catch (Exception e) {}
        if (getCustomerIdPst != null) try { getCustomerIdPst.close(); } catch (Exception e) {}
        if (insertPst != null) try { insertPst.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
</div>
</body>
</html>
