<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="cartDB.jsp" %>
<!DOCTYPE html>
<html>
<head>
  <title>Order Confirmation - Cursed & Blessed Emporium</title>
  <link rel="stylesheet" href="css/cursed-blessed-theme.css">
</head>
<body>
<div class="container">
  <h1>🛍️ Order Confirmation</h1>
<%
	//Connect database
    final String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    final String uid = "sa";
    final String pw  = "304#sa#pw";
    NumberFormat curr = NumberFormat.getCurrencyInstance();

	//This is going to grab the posted customerId we submitted when we tried to submit our order
	//Next few statements are error checking to make sure we don't let anybody through the cracks
    String custParam = request.getParameter("customerId");
    String password = request.getParameter("password");

    // Get payment information
    String paymentType = request.getParameter("paymentType");
    String cardNumber = request.getParameter("cardNumber");
    String expiryDate = request.getParameter("expiryDate");
    String cvv = request.getParameter("cvv");

    // Get shipping information
    String shipAddress = request.getParameter("shipAddress");
    String shipCity = request.getParameter("shipCity");
    String shipState = request.getParameter("shipState");
    String shipPostalCode = request.getParameter("shipPostalCode");
    String shipCountry = request.getParameter("shipCountry");

    if (custParam == null || custParam.trim().length() == 0 || password == null) {
        out.println("<p style='color:red'>Missing customer id or password.</p>");
        out.println("<p><a href='checkout.jsp'>Back to checkout</a></p>");
        return;
    }

    // Validate required fields
    if (paymentType == null || cardNumber == null || expiryDate == null || cvv == null ||
        shipAddress == null || shipCity == null || shipState == null || shipPostalCode == null || shipCountry == null) {
        out.println("<p style='color:red'>Missing payment or shipping information.</p>");
        out.println("<p><a href='checkout.jsp'>Back to checkout</a></p>");
        return;
    }

    int customerId = -1;
    try {
		//parse our string to int
        customerId = Integer.parseInt(custParam.trim());
    } catch (NumberFormatException nfe) {
		//just in case the customer puts "Hamburger" as their id
        out.println("<p style='color:red'>Customer id must be a number.</p>");
        out.println("<p><a href='checkout.jsp'>Back to checkout</a></p>");
        return;
    }
	//Hashmappy, this is to retrieve shopping cart (productList) cart was built in addcart.jsp, each entry has 
	//productId, productName, productPrice, quantity
    HashMap<String, ArrayList<Object>> productList =
        (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    if (productList == null || productList.isEmpty()) {
		//error checking 
        out.println("<p style='color:red'>Your shopping cart is empty. Add items before checking out.</p>");
        out.println("<p><a href='listprod.jsp'>Continue shopping</a></p>");
        return;
    }
    Connection con = null;
    PreparedStatement checkCustPstmt = null;
    PreparedStatement insertOrderPstmt = null;
    PreparedStatement insertItemPstmt = null;
    PreparedStatement updateOrderPstmt = null;
    ResultSet rs = null;
    String customerName = "";
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException e) {
        out.println("<p style='color:red'>JDBC Driver not found: " + e.getMessage() + "</p>");
        return;
    }
    try {
		//conneect
        con = DriverManager.getConnection(url, uid, pw);

		//Prepare statment FTW
		//
        String checkCustSql = "SELECT firstName, lastName, password FROM customer WHERE customerId = ?";
        checkCustPstmt = con.prepareStatement(checkCustSql);
        checkCustPstmt.setInt(1, customerId);
        rs = checkCustPstmt.executeQuery();
        String dbPassword = null; //has to live outside if scope;
        if (rs.next()) {
            dbPassword = rs.getString("password");
            String fn = rs.getString("firstName");
            String ln = rs.getString("lastName");
			//build the customer name
            customerName = (fn == null ? "" : fn) + " " + (ln == null ? "" : ln);
        } else {
			//if our query returns nothing, then we know the customerId is not in the database and or they don't exist
            out.println("<p style='color:red'>Customer id " + customerId + " does not exist. Please provide a valid customer id.</p>");
            out.println("<p><a href='checkout.jsp'>Back to checkout</a></p>");
            return;
        }
        rs.close();
        rs = null;
        checkCustPstmt.close();
        checkCustPstmt = null;


        if(dbPassword == null || !dbPassword.equals(password)){
            out.println("<p style='color:red'> Password is incorrect for customerId you silly little goose</p>");
            out.println("<p><a href='checkout.jsp'>Back to checkout</a></p>");
            return;
        }
		//Since we are placing an order, we insert the new order into the database with shipping info
        String insertOrderSql = "INSERT INTO ordersummary (customerId, orderDate, totalAmount, shiptoAddress, shiptoCity, shiptoState, shiptoPostalCode, shiptoCountry) VALUES (?, GETDATE(), ?, ?, ?, ?, ?, ?)";
		//teh db will auto gen a unique ID for the order, usually as identity coolumn, return gen keys will grab the auto gen order id thats created
        insertOrderPstmt = con.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
        insertOrderPstmt.setInt(1, customerId);
        insertOrderPstmt.setDouble(2, 0.0);
        insertOrderPstmt.setString(3, shipAddress);
        insertOrderPstmt.setString(4, shipCity);
        insertOrderPstmt.setString(5, shipState);
        insertOrderPstmt.setString(6, shipPostalCode);
        insertOrderPstmt.setString(7, shipCountry);
        int affected = insertOrderPstmt.executeUpdate();
		//since executeUpdate returns the int of # of rows affected, we can check whether the query went through at all, 
		//we are only creating an order record at this point 
        if (affected == 0) {
            out.println("<p style='color:red'>Failed to create order record.</p>");
            return;
        }

        int orderId = -1;
		//try to grab the auto gen key that was created
        ResultSet genKeys = insertOrderPstmt.getGeneratedKeys();
        if (genKeys != null && genKeys.next()) {
            orderId = genKeys.getInt(1);
        }
        if (genKeys != null) { genKeys.close(); genKeys = null; }

	//if the .getGeneratedKeys() didn't return anything, this will return the last identity value generated in the currect connection,(MOST RECENT INSERT that auto gen'd a key)
	//still get order id just in case something bad happends
        if (orderId <= 0) {
            Statement s = con.createStatement();
            ResultSet r2 = s.executeQuery("SELECT SCOPE_IDENTITY() AS id");
            if (r2.next()) orderId = r2.getInt("id");
            r2.close();
            s.close();
        }
		//If still nothing, just throw an error idk ATP
        if (orderId <= 0) {
            out.println("<p style='color:red'>Unable to retrieve generated order id.</p>");
            return;
        }


		//finally add the ordered product into the orderproduct table so we can display it in the list all products/orders seciont
        String insertItemSql = "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
        insertItemPstmt = con.prepareStatement(insertItemSql);

        double total = 0.0;

		//Use a map Iterator to iterate over the map(since we can grab map values all willy nilly since we don't know atp what's in there)
		//iterate over the product list so we can display it in the ordered screen
        Iterator<Map.Entry<String, ArrayList<Object>>> it = productList.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, ArrayList<Object>> entry = it.next();
            ArrayList<Object> product = entry.getValue();
            if (product == null || product.size() < 4) continue;

            String idStr = product.get(0) == null ? null : product.get(0).toString();
            String priceStr = product.get(2) == null ? "0" : product.get(2).toString();
            Object qtyObj = product.get(3);

            int pid = -1;
            double price = 0.0;
            int qty = 1;

            try { pid = Integer.parseInt(idStr); } catch (Exception e) { continue; }
            try { price = Double.parseDouble(priceStr); } catch (Exception e) { price = 0.0; }
            try {
                if (qtyObj instanceof Integer) qty = ((Integer) qtyObj).intValue();
                else qty = Integer.parseInt(qtyObj.toString());
            } catch (Exception e) { qty = 1; }

            insertItemPstmt.setInt(1, orderId);
            insertItemPstmt.setInt(2, pid);
            insertItemPstmt.setInt(3, qty);
            insertItemPstmt.setDouble(4, price);
            insertItemPstmt.executeUpdate();

            total += price * qty;
        }

        // Apply Satan's discount/penalty if exists
        Double satanDiscount = (Double) session.getAttribute("satanDiscount");

        double finalTotal = total;
        String discountMessage = "";
        // Save discount info for display before clearing session
        Double displayDiscount = satanDiscount;
        boolean hasDiscount = (satanDiscount != null && satanDiscount != 1.0);

        if (satanDiscount != null) {
            finalTotal = total * satanDiscount;
            if (satanDiscount < 1.0) {
                discountMessage = " (5% discount from defeating Satan!)";
            } else if (satanDiscount > 1.0) {
                discountMessage = " (50% penalty from losing to Satan!)";
            }
            // Clear the discount after use
            session.removeAttribute("satanDiscount");
        }
        
        String updateOrderSql = "UPDATE ordersummary SET totalAmount = ? WHERE orderId = ?";
        updateOrderPstmt = con.prepareStatement(updateOrderSql);
        updateOrderPstmt.setDouble(1, finalTotal);
        updateOrderPstmt.setInt(2, orderId);
        updateOrderPstmt.executeUpdate();

        // Store payment method (mask card number for security)
        PreparedStatement paymentPstmt = null;
        try {
            String maskedCard = "****-****-****-" + cardNumber.replaceAll("\\s", "").substring(12);
            String insertPaymentSql = "INSERT INTO paymentmethod (paymentType, paymentNumber, paymentExpiryDate, customerId) VALUES (?, ?, ?, ?)";
            paymentPstmt = con.prepareStatement(insertPaymentSql);
            paymentPstmt.setString(1, paymentType);
            paymentPstmt.setString(2, maskedCard);

            // Parse expiry date (MM/YY format) to SQL date
            String[] parts = expiryDate.split("/");
            String expiryDateStr = "20" + parts[1] + "-" + parts[0] + "-01"; // Convert to YYYY-MM-DD
            paymentPstmt.setString(3, expiryDateStr);
            paymentPstmt.setInt(4, customerId);
            paymentPstmt.executeUpdate();
        } catch (Exception e) {
            // Payment info storage is optional, continue even if it fails
        } finally {
            if (paymentPstmt != null) try { paymentPstmt.close(); } catch (Exception e) {}
        }

        session.removeAttribute("productList");

        // Clear cart from database for logged-in user
        String currentUser = (String) session.getAttribute("authenticatedUser");
        if (currentUser != null) {
            clearCartFromDatabase(currentUser);
        }

%>

  <h2>Order placed successfully!</h2>
  <p><strong>Order ID:</strong> <%= orderId %></p>
  <p><strong>Customer:</strong> <%= customerName %> (ID: <%= customerId %>)</p>
  <%
  if (hasDiscount && displayDiscount != null) {
      if (displayDiscount < 1.0) {
          out.println("<p><strong>Subtotal:</strong> " + curr.format(total) + "</p>");
          out.println("<p style='color: #66ff66;'><strong>Satan's Discount (5%):</strong> -" + curr.format(total - finalTotal) + "</p>");
          out.println("<p><strong>Final Total:</strong> " + curr.format(finalTotal) + " 🎉</p>");
      } else {
          out.println("<p><strong>Subtotal:</strong> " + curr.format(total) + "</p>");
          out.println("<p style='color: #ff6666;'><strong>Satan's Penalty (50%):</strong> +" + curr.format(finalTotal - total) + "</p>");
          out.println("<p><strong>Final Total:</strong> " + curr.format(finalTotal) + " 💀</p>");
      }
  } else {
      out.println("<p><strong>Total:</strong> " + curr.format(total) + "</p>");
  }
  %>

  <h3>Shipping Address</h3>
  <p><%= shipAddress %><br>
  <%= shipCity %>, <%= shipState %> <%= shipPostalCode %><br>
  <%= shipCountry %></p>

  <h3>Payment Method</h3>
  <p><%= paymentType %> ending in <%= cardNumber.replaceAll("\\s", "").substring(12) %></p>

  <h3>Items</h3>
  <table>
    <tr><th>Product ID</th><th>Product Name</th><th>Quantity</th><th>Price</th><th>Subtotal</th></tr>
<%
        PreparedStatement fetchItems = null;
        ResultSet itemsRs = null;
        // Use displayDiscount for item prices, default to 1.0 if no discount
        double itemMultiplier = (displayDiscount != null) ? displayDiscount : 1.0;
        try {
            fetchItems = con.prepareStatement(
                "SELECT op.productId, p.productName, op.quantity, op.price " +
                "FROM orderproduct op JOIN product p ON op.productId = p.productId " +
                "WHERE op.orderId = ? ORDER BY op.productId");
            fetchItems.setInt(1, orderId);
            itemsRs = fetchItems.executeQuery();
            while (itemsRs.next()) {
                int pid = itemsRs.getInt("productId");
                String pname = itemsRs.getString("productName");
                int qty = itemsRs.getInt("quantity");

                double price = itemsRs.getDouble("price");
%>
    <tr>
      <td><%= pid %></td>
      <td><%= (pname==null? "" : pname) %></td>
      <td><%= qty %></td>
      <td><%= curr.format(price * itemMultiplier) %></td>
      <td><%= curr.format((price * itemMultiplier) * qty) %></td>
    </tr>
<%
            }
        } finally {
            if (itemsRs != null) try { itemsRs.close(); } catch (Exception ex) {}
            if (fetchItems != null) try { fetchItems.close(); } catch (Exception ex) {}
        }

    } catch (SQLException sqle) {
        out.println("<p style='color:red'>SQL Exception: " + sqle.getMessage() + "</p>");
        sqle.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (checkCustPstmt != null) try { checkCustPstmt.close(); } catch (Exception e) {}
        if (insertOrderPstmt != null) try { insertOrderPstmt.close(); } catch (Exception e) {}
        if (insertItemPstmt != null) try { insertItemPstmt.close(); } catch (Exception e) {}
        if (updateOrderPstmt != null) try { updateOrderPstmt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>
  </table>

  <div class="success mt-3">
    <h3>✅ Your order has been successfully placed!</h3>
    <p>Your cursed and blessed items will be processed shortly.</p>
  </div>

  <p class="text-center mt-3">
    <a href="listprod.jsp" class="btn btn-primary">← Back to Shopping</a>
    <a href="index.jsp" class="btn btn-secondary">Home</a>
  </p>
</div>
</body>
</html>
