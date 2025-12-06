<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Branson's and Ben's Grocery - Shipment Processing</title>
</head>
<body>
        
<%@ include file="header.jsp" %>

<%
	// TODO: Get order id
	String orderIdStr = request.getParameter("orderId");
	
	if (orderIdStr == null || orderIdStr.isEmpty()) {
		out.println("<div class='error'>Error: No order ID provided.</div>");
		out.println("<h2><a href='index.jsp'>Back to Main Page</a></h2>");
		return;
	}
	
	int orderId = 0;
	try {
		orderId = Integer.parseInt(orderIdStr);
	} catch (NumberFormatException e) {
		out.println("<div class='error'>Error: Invalid order ID format.</div>");
		out.println("<h2><a href='index.jsp'>Back to Main Page</a></h2>");
		return;
	}
	
	out.println("<h2>Processing Order ID: " + orderId + "</h2>");
	
	try {
		getConnection();
		
		// TODO: Check if valid order id in database
		String checkOrderSql = "SELECT orderId FROM ordersummary WHERE orderId = ?";
		PreparedStatement checkStmt = con.prepareStatement(checkOrderSql);
		checkStmt.setInt(1, orderId);
		ResultSet checkRs = checkStmt.executeQuery();
		
		if (!checkRs.next()) {
			out.println("<div class='error'>Error: Order ID " + orderId + " does not exist.</div>");
			checkRs.close();
			checkStmt.close();
			out.println("<h2><a href='index.jsp'>Back to Main Page</a></h2>");
			return;
		}
		checkRs.close();
		checkStmt.close();
		
		// TODO: Start a transaction (turn-off auto-commit)
		con.setAutoCommit(false);
		
		// TODO: Retrieve all items in order with given id
		String retrieveItemsSql = "SELECT productId, quantity FROM orderproduct WHERE orderId = ?";
		PreparedStatement itemsStmt = con.prepareStatement(retrieveItemsSql);
		itemsStmt.setInt(1, orderId);
		ResultSet itemsRs = itemsStmt.executeQuery();
		
		// Store items to process
		ArrayList<Integer> productIds = new ArrayList<>();
		ArrayList<Integer> quantities = new ArrayList<>();
		
		while (itemsRs.next()) {
			productIds.add(itemsRs.getInt("productId"));
			quantities.add(itemsRs.getInt("quantity"));
		}
		itemsRs.close();
		itemsStmt.close();
		
		if (productIds.isEmpty()) {
			out.println("<div class='error'>Error: No items found for this order.</div>");
			con.rollback();
			con.setAutoCommit(true);
			out.println("<h2><a href='index.jsp'>Back to Main Page</a></h2>");
			return;
		}
		
		// TODO: Create a new shipment record.
		String insertShipmentSql = "INSERT INTO shipment (shipmentDate, shipmentDesc, warehouseId) VALUES (?, ?, ?)";
		PreparedStatement shipmentStmt = con.prepareStatement(insertShipmentSql, Statement.RETURN_GENERATED_KEYS);
		shipmentStmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
		shipmentStmt.setString(2, "Order " + orderId);
		shipmentStmt.setInt(3, 1); // Warehouse 1
		shipmentStmt.executeUpdate();
		
		ResultSet keys = shipmentStmt.getGeneratedKeys();
		int shipmentId = 0;
		if (keys.next()) {
			shipmentId = keys.getInt(1);
		}
		keys.close();
		shipmentStmt.close();
		
		// TODO: For each item verify sufficient quantity available in warehouse 1.
		boolean allItemsAvailable = true;
		String errorMessage = "";
		
		out.println("<h3>Shipment Details:</h3>");
		out.println("<table>");
		out.println("<tr><th>Product ID</th><th>Quantity Ordered</th><th>Quantity in Stock</th><th>Status</th></tr>");
		
		for (int i = 0; i < productIds.size(); i++) {
			int productId = productIds.get(i);
			int quantityOrdered = quantities.get(i);
			
			// Check warehouse inventory
			String checkInventorySql = "SELECT quantity FROM productinventory WHERE productId = ? AND warehouseId = 1";
			PreparedStatement invStmt = con.prepareStatement(checkInventorySql);
			invStmt.setInt(1, productId);
			ResultSet invRs = invStmt.executeQuery();
			
			if (invRs.next()) {
				int quantityInStock = invRs.getInt("quantity");
				
				out.println("<tr>");
				out.println("<td>" + productId + "</td>");
				out.println("<td>" + quantityOrdered + "</td>");
				out.println("<td>" + quantityInStock + "</td>");
				
				if (quantityInStock < quantityOrdered) {
					// TODO: If any item does not have sufficient inventory, cancel transaction and rollback.
					allItemsAvailable = false;
					errorMessage = "Insufficient inventory for product ID " + productId + ". Required: " + quantityOrdered + ", Available: " + quantityInStock;
					out.println("<td style='color:red;'>INSUFFICIENT STOCK</td>");
					out.println("</tr>");
				} else {
					out.println("<td style='color:green;'>Available</td>");
					out.println("</tr>");
				}
			} else {
				allItemsAvailable = false;
				errorMessage = "Product ID " + productId + " not found in warehouse 1.";
				out.println("<td>" + quantityOrdered + "</td>");
				out.println("<td>N/A</td>");
				out.println("<td style='color:red;'>NOT FOUND</td>");
				out.println("</tr>");
			}
			
			invRs.close();
			invStmt.close();
		}
		
		out.println("</table>");
		
		if (!allItemsAvailable) {
			// Rollback transaction
			con.rollback();
			out.println("<div class='error'><h3>Shipment Failed!</h3><p>" + errorMessage + "</p><p>Transaction has been rolled back.</p></div>");
		} else {
			// Otherwise, update inventory for each item.
			for (int i = 0; i < productIds.size(); i++) {
				int productId = productIds.get(i);
				int quantityOrdered = quantities.get(i);
				
				String updateInventorySql = "UPDATE productinventory SET quantity = quantity - ? WHERE productId = ? AND warehouseId = 1";
				PreparedStatement updateStmt = con.prepareStatement(updateInventorySql);
				updateStmt.setInt(1, quantityOrdered);
				updateStmt.setInt(2, productId);
				updateStmt.executeUpdate();
				updateStmt.close();
			}
			
			// Commit transaction
			con.commit();
			out.println("<div class='success'><h3>Shipment Successful!</h3><p>Shipment ID: " + shipmentId + "</p><p>All items have been shipped and inventory has been updated.</p></div>");
		}
		
		// TODO: Auto-commit should be turned back on
		con.setAutoCommit(true);
		
	} catch (SQLException ex) {
		try {
			if (con != null) {
				con.rollback();
				con.setAutoCommit(true);
			}
		} catch (SQLException e) {
			out.println("<div class='error'>Error during rollback: " + e.getMessage() + "</div>");
		}
		out.println("<div class='error'>Database Error: " + ex.getMessage() + "</div>");
	} finally {
		closeConnection();
	}
%>                       				

<h2><a href="index.jsp">Back to Main Page</a></h2>

</body>
</html>