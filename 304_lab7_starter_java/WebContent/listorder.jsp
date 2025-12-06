<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
  <title>Order History - Cursed & Blessed Emporium</title>
  <link rel="stylesheet" href="css/cursed-blessed-theme.css">
  <style>
    .inner { margin: 10px 0; width: 98%; }
    .inner th { background: #660000; }
    .inner td { background: rgba(0,0,0,0.3); }
    .order-header { font-weight: bold; color: #ffcc99; }
  </style>
</head>
<body>
<div class="container">
<h1> Order History</h1>

<%
    // Load driver (optional on some setups)
    try { Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); }
    catch (ClassNotFoundException e) { out.println("Driver load error: " + e); }

    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid  = "sa";
    String pw   = "304#sa#pw";

    Connection con = null;
    Statement orderStmt = null;
    ResultSet ordersRs = null;
    PreparedStatement itemsPst = null;
    NumberFormat curr = NumberFormat.getCurrencyInstance();

    try {
        con = DriverManager.getConnection(url, uid, pw);

        // Outer query: one row per order (includes customer name)
        String orderQuery =
            "SELECT o.orderId, o.orderDate, o.customerId, COALESCE(c.firstName + ' ' + c.lastName,'') AS customerName, o.totalAmount " +
            "FROM ordersummary o LEFT JOIN customer c ON o.customerId = c.customerId " +
            "ORDER BY o.orderId";

        orderStmt = con.createStatement();
        ordersRs = orderStmt.executeQuery(orderQuery);

        // Prepared statement to fetch items for an order (re-used)
        String itemQuery = "SELECT op.productId, op.quantity, op.price " +
                           "FROM orderproduct op WHERE op.orderId = ? ORDER BY op.productId";
        itemsPst = con.prepareStatement(itemQuery);

        // Print top-level table header (one header row for all orders)
%>
    <table>
      <tr>
        <th>Order Id</th>
        <th>Order Date</th>
        <th>Customer Id</th>
        <th>Customer Name</th>
        <th>Total Amount</th>
      </tr>
<%
        boolean anyOrder = false;
        while (ordersRs.next()) {
            anyOrder = true;
            int orderId = ordersRs.getInt("orderId");
            Timestamp orderDate = ordersRs.getTimestamp("orderDate");
            int customerId = ordersRs.getInt("customerId");
            String customerName = ordersRs.getString("customerName");
            double total = ordersRs.getDouble("totalAmount");
%>
      <!-- one row for the order summary -->
      <tr>
        <td><%= orderId %></td>
        <td><%= (orderDate != null ? orderDate.toString() : "N/A") %></td>
        <td><%= customerId %></td>
        <td><%= (customerName!=null ? customerName : "") %></td>
        <td><%= curr.format(total) %></td>
      </tr>

      <!-- one sub-row with products for this order -->
      <tr>
        <td colspan="5">
          <table class="inner">
            <tr><th>Product Id</th><th>Quantity</th><th>Price</th></tr>
<%
            // fetch items for this order (only id, qty, price to match sample)
            itemsPst.setInt(1, orderId);
            ResultSet itemsRs = itemsPst.executeQuery();
            boolean anyItem = false;
            while (itemsRs.next()) {
                anyItem = true;
                int pid = itemsRs.getInt("productId");
                int qty = itemsRs.getInt("quantity");
                double price = itemsRs.getDouble("price"); // from orderproduct
%>
            <tr>
              <td><%= pid %></td>
              <td><%= qty %></td>
              <td><%= curr.format(price) %></td>
            </tr>
<%
            } // items loop

            if (!anyItem) {
%>
            <tr><td colspan="3"><em>No items for this order.</em></td></tr>
<%
            }
            itemsRs.close();
%>
          </table>
        </td>
      </tr>
<%
        } // orders loop

        // close the top-level table
%>
    </table>
<%
        if (!anyOrder) {
            out.println("<p><em>No orders found in the database.</em></p>");
        }

    } catch (SQLException sqle) {
        out.println("<p style='color:red'>SQL Exception: " + sqle.getMessage() + "</p>");
        sqle.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (ordersRs != null) ordersRs.close(); } catch (SQLException e) { }
        try { if (orderStmt != null) orderStmt.close(); } catch (SQLException e) { }
        try { if (itemsPst != null) itemsPst.close(); } catch (SQLException e) { }
        try { if (con != null) con.close(); } catch (SQLException e) { out.println("Close error: " + e.getMessage()); }
    }
%>

<div class="text-center mt-3">
    <a href="index.jsp" class="btn btn-secondary">← Back to Home</a>
    <a href="listprod.jsp" class="btn btn-primary">Continue Shopping</a>
</div>

</div>
</body>
</html>
