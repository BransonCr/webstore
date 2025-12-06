<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
  <title>My Orders - Cursed & Blessed Emporium</title>
  <link rel="stylesheet" href="css/cursed-blessed-theme.css">
  <style>
    .inner { margin: 10px 0; width: 98%; }
    .inner th { background: #660000; }
    .inner td { background: rgba(0,0,0,0.3); }
    .order-header { font-weight: bold; color: #ffcc99; }
    .no-auth {
      text-align: center;
      padding: 40px;
      background: rgba(102, 0, 0, 0.3);
      border: 2px solid #ff6666;
      border-radius: 10px;
      margin: 40px auto;
      max-width: 600px;
    }
  </style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">
<h1> My Order History</h1>

<%
String authenticatedUser = (String) session.getAttribute("authenticatedUser");

// Check if user is logged in
if (authenticatedUser == null) {
%>
    <div class="no-auth">
        <h2> Please Log In</h2>
        <p>You must be logged in to view your order history.</p>
        <a href="login.jsp" class="btn btn-primary">Login Now</a>
    </div>
<%
} else {
    // Load driver
    try { Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); }
    catch (ClassNotFoundException e) { out.println("Driver load error: " + e); }

    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid  = "sa";
    String pw   = "304#sa#pw";

    Connection con = null;
    PreparedStatement orderPst = null;
    PreparedStatement itemsPst = null;
    ResultSet ordersRs = null;
    NumberFormat curr = NumberFormat.getCurrencyInstance();

    try {
        con = DriverManager.getConnection(url, uid, pw);

        // First, get the customerId for the authenticated user
        PreparedStatement userPst = con.prepareStatement(
            "SELECT customerId FROM customer WHERE userid = ?"
        );
        userPst.setString(1, authenticatedUser);
        ResultSet userRs = userPst.executeQuery();

        if (!userRs.next()) {
            out.println("<div class='error'><p>No customer account found for user: " + authenticatedUser + "</p></div>");
        } else {
            int customerId = userRs.getInt("customerId");

            // Query to get orders for this customer
            String orderQuery =
                "SELECT o.orderId, o.orderDate, o.totalAmount " +
                "FROM ordersummary o " +
                "WHERE o.customerId = ? " +
                "ORDER BY o.orderDate DESC";

            orderPst = con.prepareStatement(orderQuery);
            orderPst.setInt(1, customerId);
            ordersRs = orderPst.executeQuery();

            // Prepared statement to fetch items for an order
            String itemQuery = "SELECT op.productId, p.productName, op.quantity, op.price " +
                               "FROM orderproduct op " +
                               "JOIN product p ON op.productId = p.productId " +
                               "WHERE op.orderId = ? " +
                               "ORDER BY op.productId";
            itemsPst = con.prepareStatement(itemQuery);
%>
    <table>
      <tr>
        <th>Order Id</th>
        <th>Order Date</th>
        <th>Total Amount</th>
      </tr>
<%
            boolean anyOrder = false;
            while (ordersRs.next()) {
                anyOrder = true;
                int orderId = ordersRs.getInt("orderId");
                Timestamp orderDate = ordersRs.getTimestamp("orderDate");
                double total = ordersRs.getDouble("totalAmount");
%>
      <!-- one row for the order summary -->
      <tr>
        <td><%= orderId %></td>
        <td><%= (orderDate != null ? orderDate.toString() : "N/A") %></td>
        <td><%= curr.format(total) %></td>
      </tr>

      <!-- one sub-row with products for this order -->
      <tr>
        <td colspan="3">
          <table class="inner">
            <tr><th>Product ID</th><th>Product Name</th><th>Quantity</th><th>Price</th></tr>
<%
                // Fetch items for this order
                itemsPst.setInt(1, orderId);
                ResultSet itemsRs = itemsPst.executeQuery();
                boolean anyItem = false;
                while (itemsRs.next()) {
                    anyItem = true;
                    int pid = itemsRs.getInt("productId");
                    String pname = itemsRs.getString("productName");
                    int qty = itemsRs.getInt("quantity");
                    double price = itemsRs.getDouble("price");
%>
            <tr>
              <td><%= pid %></td>
              <td><%= pname %></td>
              <td><%= qty %></td>
              <td><%= curr.format(price) %></td>
            </tr>
<%
                }

                if (!anyItem) {
%>
            <tr><td colspan="4"><em>No items for this order.</em></td></tr>
<%
                }
                itemsRs.close();
%>
          </table>
        </td>
      </tr>
<%
            } // orders loop

            // Close the top-level table
%>
    </table>
<%
            if (!anyOrder) {
                out.println("<div class='info'><p>You haven't placed any orders yet.</p><p><a href='listprod.jsp'>Start shopping now!</a></p></div>");
            }
        }

        userRs.close();
        userPst.close();

    } catch (SQLException sqle) {
        out.println("<p style='color:red'>SQL Exception: " + sqle.getMessage() + "</p>");
        sqle.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (ordersRs != null) ordersRs.close(); } catch (SQLException e) { }
        try { if (orderPst != null) orderPst.close(); } catch (SQLException e) { }
        try { if (itemsPst != null) itemsPst.close(); } catch (SQLException e) { }
        try { if (con != null) con.close(); } catch (SQLException e) { out.println("Close error: " + e.getMessage()); }
    }
}
%>

<div class="text-center mt-3">
    <a href="index.jsp" class="btn btn-secondary"> Back to Home</a>
    <a href="listprod.jsp" class="btn btn-primary">Continue Shopping</a>
</div>

</div>
</body>
</html>
