<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
String productIdStr = request.getParameter("productId");

// Validation
if (productIdStr == null || productIdStr.trim().isEmpty()) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Invalid product ID", "UTF-8"));
    return;
}

int productId = 0;
try {
    productId = Integer.parseInt(productIdStr);
} catch (NumberFormatException e) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Invalid product ID format", "UTF-8"));
    return;
}

// Database connection
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    // First, delete related records in productinventory
    String deleteInventorySQL = "DELETE FROM productinventory WHERE productId = ?";
    pst = con.prepareStatement(deleteInventorySQL);
    pst.setInt(1, productId);
    pst.executeUpdate();
    pst.close();

    // Note: orderproduct records should NOT be deleted to maintain order history
    // We just delete the product itself, which will orphan orderproduct records
    // In production, you might want to:
    // 1. Prevent deletion if product has orders
    // 2. Soft-delete (set a flag instead of actual delete)
    // 3. Keep the product but mark as discontinued

    // Delete the product
    String deleteProductSQL = "DELETE FROM product WHERE productId = ?";
    pst = con.prepareStatement(deleteProductSQL);
    pst.setInt(1, productId);

    int rowsDeleted = pst.executeUpdate();

    if (rowsDeleted > 0) {
        response.sendRedirect("manageProducts.jsp?success=" + java.net.URLEncoder.encode("Product deleted successfully!", "UTF-8"));
    } else {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Product not found or already deleted", "UTF-8"));
    }

} catch (SQLException e) {
    // If foreign key constraint error (product has orders)
    if (e.getMessage().contains("REFERENCE constraint")) {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Cannot delete product with existing orders. Product has order history.", "UTF-8"));
    } else {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
    }
} catch (ClassNotFoundException e) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Driver error", "UTF-8"));
} finally {
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>
