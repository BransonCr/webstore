<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Warehouse Inventory - Admin - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
    .inventory-table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
    }
    .inventory-table th {
        background: #660000;
        color: #ffcc99;
        padding: 12px;
        text-align: left;
        border: 1px solid #ff6666;
    }
    .inventory-table td {
        background: rgba(0, 0, 0, 0.5);
        color: #ffcccc;
        padding: 10px;
        border: 1px solid #666;
    }
    .inventory-table tr:hover td {
        background: rgba(102, 0, 0, 0.3);
    }
    .low-stock {
        background: rgba(255, 51, 51, 0.3) !important;
        color: #ff6666;
        font-weight: bold;
    }
    .in-stock {
        background: rgba(51, 255, 51, 0.1) !important;
        color: #99ff99;
    }
    .out-of-stock {
        background: rgba(255, 0, 0, 0.3) !important;
        color: #ff3333;
        font-weight: bold;
    }
    .warehouse-header {
        background: rgba(0, 51, 102, 0.3);
        padding: 15px;
        margin: 20px 0;
        border-left: 4px solid #3399ff;
        border-radius: 5px;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
    <h1> Warehouse Inventory</h1>
    <p style="text-align:center; color:#ffcc99;">Admin: View stock levels across all warehouses</p>

<%
// Check if user is logged in
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
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // Get all warehouses
    String warehouseQuery = "SELECT warehouseId, warehouseName FROM warehouse ORDER BY warehouseId";
    pst = con.prepareStatement(warehouseQuery);
    rs = pst.executeQuery();

    while (rs.next()) {
        int warehouseId = rs.getInt("warehouseId");
        String warehouseName = rs.getString("warehouseName");
%>
    <div class="warehouse-header">
        <h2>< Warehouse #<%= warehouseId %>: <%= warehouseName %></h2>
    </div>

    <table class="inventory-table">
        <tr>
            <th>Product ID</th>
            <th>Product Name</th>
            <th>Category</th>
            <th>Quantity in Stock</th>
            <th>Price</th>
            <th>Total Value</th>
            <th>Status</th>
        </tr>
<%
        // Get inventory for this warehouse
        String inventoryQuery =
            "SELECT pi.productId, p.productName, c.categoryName, pi.quantity, pi.price " +
            "FROM productInventory pi " +
            "JOIN product p ON pi.productId = p.productId " +
            "LEFT JOIN category c ON p.categoryId = c.categoryId " +
            "WHERE pi.warehouseId = ? " +
            "ORDER BY pi.productId";

        PreparedStatement invPst = con.prepareStatement(inventoryQuery);
        invPst.setInt(1, warehouseId);
        ResultSet invRs = invPst.executeQuery();

        int totalProducts = 0;
        double totalValue = 0;
        int outOfStock = 0;
        int lowStock = 0;

        while (invRs.next()) {
            totalProducts++;
            int productId = invRs.getInt("productId");
            String productName = invRs.getString("productName");
            String categoryName = invRs.getString("categoryName");
            int quantity = invRs.getInt("quantity");
            double price = invRs.getDouble("price");
            double itemValue = quantity * price;
            totalValue += itemValue;

            // Determine stock status
            String stockClass = "";
            String stockStatus = "";
            if (quantity == 0) {
                stockClass = "out-of-stock";
                stockStatus = "OUT OF STOCK";
                outOfStock++;
            } else if (quantity <= 5) {
                stockClass = "low-stock";
                stockStatus = "LOW STOCK";
                lowStock++;
            } else {
                stockClass = "in-stock";
                stockStatus = "In Stock";
            }
%>
        <tr>
            <td><%= productId %></td>
            <td><strong><%= productName %></strong></td>
            <td><%= categoryName != null ? categoryName : "N/A" %></td>
            <td class="<%= stockClass %>"><%= quantity %></td>
            <td><%= currFormat.format(price) %></td>
            <td><%= currFormat.format(itemValue) %></td>
            <td class="<%= stockClass %>"><%= stockStatus %></td>
        </tr>
<%
        }
        invRs.close();
        invPst.close();
%>
        <tr style="background: rgba(51, 0, 51, 0.3); font-weight: bold;">
            <td colspan="5" style="text-align: right;">Warehouse Total Value:</td>
            <td colspan="2"><%= currFormat.format(totalValue) %></td>
        </tr>
    </table>

    <div class="info" style="margin-bottom: 30px;">
        <p><strong>Total Products:</strong> <%= totalProducts %> |
           <strong>Out of Stock:</strong> <span style="color: #ff6666;"><%= outOfStock %></span> |
           <strong>Low Stock:</strong> <span style="color: #ffcc00;"><%= lowStock %></span> |
           <strong>In Stock:</strong> <span style="color: #99ff99;"><%= (totalProducts - outOfStock - lowStock) %></span></p>
    </div>
<%
    }

    rs.close();
    pst.close();

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
        <a href="index.jsp" class="btn btn-secondary"><- Home</a>
    </div>
</div>

</body>
</html>
