<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Manage Products - Admin - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
    .product-table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
        font-size: 0.95em;
    }
    .product-table th {
        background: #660000;
        color: #ffcc99;
        padding: 10px;
        text-align: left;
        border: 1px solid #ff6666;
    }
    .product-table td {
        background: rgba(0, 0, 0, 0.5);
        color: #ffcccc;
        padding: 8px;
        border: 1px solid #666;
    }
    .product-table tr:hover td {
        background: rgba(102, 0, 0, 0.3);
    }
    .action-btn {
        padding: 5px 10px;
        margin: 2px;
        font-size: 0.9em;
        border-radius: 3px;
        text-decoration: none;
        display: inline-block;
    }
    .btn-edit {
        background: #336600;
        color: #fff;
        border: 1px solid #66cc00;
    }
    .btn-delete {
        background: #660000;
        color: #ffcc99;
        border: 1px solid #ff3333;
    }
    .btn-delete:hover {
        background: #ff3333;
        color: #000;
    }
    .add-form {
        background: rgba(0, 0, 0, 0.6);
        padding: 20px;
        border: 2px solid #660000;
        border-radius: 10px;
        margin: 20px 0;
    }
    .add-form input, .add-form select, .add-form textarea {
        width: 100%;
        padding: 8px;
        margin: 5px 0;
        background: rgba(51, 0, 0, 0.5);
        border: 1px solid #666;
        border-radius: 5px;
        color: #ffcccc;
    }
    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
        margin-top: 10px;
    }
    .form-full {
        grid-column: 1 / -1;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1> Manage Products</h1>
    <p style="text-align:center; color:#ffcc99;">Admin: Add, edit, or delete products</p>

<%
String successMsg = request.getParameter("success");
if (successMsg != null) {
    out.println("<div class='success' style='text-align:center;'>" + successMsg + "</div>");
}
String errorMsg = request.getParameter("error");
if (errorMsg != null) {
    out.println("<div class='error' style='text-align:center;'>" + errorMsg + "</div>");
}
%>

    <!-- Add New Product Form -->
    <details open>
        <summary style="font-size:1.3em; color:#ffcc99; cursor:pointer; margin:20px 0;"> Add New Product</summary>
        <div class="add-form">
            <form method="post" action="addProductAction.jsp" enctype="multipart/form-data">
                <div class="form-grid">
                    <div>
                        <label>Product Name *</label>
                        <input type="text" name="productName" required maxlength="40">
                    </div>
                    <div>
                        <label>Category *</label>
                        <select name="categoryId" required>
                            <option value="">Select Category</option>
<%
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

Connection con = null;
try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    PreparedStatement catPst = con.prepareStatement("SELECT categoryId, categoryName FROM category ORDER BY categoryName");
    ResultSet catRs = catPst.executeQuery();
    while (catRs.next()) {
        out.println("<option value='" + catRs.getInt("categoryId") + "'>" + catRs.getString("categoryName") + "</option>");
    }
    catRs.close();
    catPst.close();
} catch (Exception e) {
    out.println("<option value=''>Error loading categories</option>");
}
%>
                        </select>
                    </div>
                    <div>
                        <label>Price * (e.g., 19.99)</label>
                        <input type="number" name="productPrice" step="0.01" min="0" required>
                    </div>
                    <div>
                        <label>Upload Product Image (optional)</label>
                        <input type="file" name="productImage" accept="image/png,image/jpeg,image/jpg,image/webp,image/gif">
                        <small style="color: #999;">Accepts: JPG, PNG, WEBP, GIF (max 5MB)</small>
                    </div>
                    <div class="form-full">
                        <label>Product Description</label>
                        <textarea name="productDesc" rows="3" maxlength="1000"></textarea>
                    </div>
                </div>
                <div style="text-align:center; margin-top:15px;">
                    <button type="submit" class="btn btn-primary"> Add Product</button>
                </div>
            </form>
        </div>
    </details>

    <!-- Product List -->
    <h2 style="color:#ffcc99; margin-top:40px;"> Current Products</h2>

<%
PreparedStatement pst = null;
ResultSet rs = null;
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try {
    if (con == null || con.isClosed()) {
        con = DriverManager.getConnection(url, uid, pw);
    }

    String query = "SELECT p.productId, p.productName, p.productPrice, p.productDesc, " +
                   "p.productImageURL, c.categoryName " +
                   "FROM product p " +
                   "LEFT JOIN category c ON p.categoryId = c.categoryId " +
                   "ORDER BY p.productId DESC";

    pst = con.prepareStatement(query);
    rs = pst.executeQuery();
%>
    <table class="product-table">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Category</th>
            <th>Price</th>
            <th>Description</th>
            <th>Image URL</th>
            <th>Actions</th>
        </tr>
<%
    int count = 0;
    while (rs.next()) {
        count++;
        int productId = rs.getInt("productId");
        String productName = rs.getString("productName");
        String categoryName = rs.getString("categoryName");
        double productPrice = rs.getDouble("productPrice");
        String productDesc = rs.getString("productDesc");
        String productImageURL = rs.getString("productImageURL");

        // Truncate long descriptions
        String shortDesc = productDesc != null && productDesc.length() > 100
            ? productDesc.substring(0, 100) + "..."
            : (productDesc != null ? productDesc : "");
%>
        <tr>
            <td><strong><%= productId %></strong></td>
            <td><%= productName %></td>
            <td><%= categoryName != null ? categoryName : "N/A" %></td>
            <td><%= currFormat.format(productPrice) %></td>
            <td><%= shortDesc %></td>
            <td><%= productImageURL != null ? productImageURL : "N/A" %></td>
            <td>
                <form method="post" action="deleteProductAction.jsp" style="display:inline;"
                      onsubmit="return confirm('Are you sure you want to delete <%= productName.replace("'", "\\'") %>?');">
                    <input type="hidden" name="productId" value="<%= productId %>">
                    <button type="submit" class="action-btn btn-delete"> Delete</button>
                </form>
            </td>
        </tr>
<%
    }
%>
    </table>

    <div class="info" style="text-align:center; margin-top:20px;">
        <p><strong>Total Products:</strong> <%= count %></p>
    </div>
<%
    if (count == 0) {
        out.println("<div class='info' style='text-align:center;'>No products found. Add your first product above!</div>");
    }

} catch (SQLException e) {
    out.println("<div class='error'>Database error: " + e.getMessage() + "</div>");
}  finally {
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
