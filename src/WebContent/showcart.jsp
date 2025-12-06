<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="cartDB.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
body {
    font-family: Georgia, serif;
    margin:20px;
    background: linear-gradient(to bottom, #1a0000 0%, #4a0000 50%, #000033 100%);
    color: #ffcccc;
}
h1 { color: #ff6666; text-shadow: 0 0 10px #ff0000; }
h2 a { color: #99ccff; }
table { border-collapse:collapse; width:100%; background: rgba(0,0,0,0.7); margin: 20px 0; }
th, td { border:1px solid #666; padding:8px; }
th { background:#330000; color:#ffcc99; }
td { background: rgba(0,0,0,0.5); }
input[type="number"] {
    background: #330000;
    color: #ffcccc;
    border: 1px solid #666;
    padding: 3px;
    width: 60px;
}
button {
    background: #660000;
    color: #ffcc99;
    padding: 6px 12px;
    border: 2px solid #ff6666;
    cursor: pointer;
    border-radius: 5px;
}
button:hover {
    background: #ff6666;
    color: #000;
}
a { color: #99ccff; text-decoration: none; }
a:hover { color: #ffcc99; }
</style>
</head>
<body>
<h1> Your Cursed & Blessed Shopping Cart</h1>

<%
// Check if user is logged in
String authenticatedUser = (String) session.getAttribute("authenticatedUser");

// Get the current list of products
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

// If user is logged in and no session cart, load from database
if (authenticatedUser != null && productList == null) {
	productList = loadCartFromDatabase(authenticatedUser);
	if (productList != null && !productList.isEmpty()) {
		session.setAttribute("productList", productList);
	}
}

if (productList == null)
{	out.println("<h2 style='color:#ffcc99;'>Your shopping cart is empty! No curses or blessings for you... yet.</h2>");
	productList = new HashMap<String, ArrayList<Object>>();
}
else
{
	NumberFormat currFormat = NumberFormat.getCurrencyInstance();
	//for updating our cart.
	out.println("<form action=\"updatecart.jsp\" method=\"post\">");
	out.println("<h1>Your Shopping Cart</h1>");
	out.print("<table><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
	out.println("<th>Price</th><th>Subtotal</th></tr>");

	double total =0;
	Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
	while (iterator.hasNext()) 
	{	Map.Entry<String, ArrayList<Object>> entry = iterator.next();
		ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
		if (product.size() < 4)
		{
			out.println("Expected product with four entries. Got: "+product);
			continue;
		}
		
		String idStr = product.get(0) == null ? "" : product.get(0).toString();
        String name   = product.get(1) == null ? "" : product.get(1).toString();
        Object priceObj = product.get(2);
        Object qtyObj   = product.get(3);

        double pr = 0.0;
        int qty = 0;

        try {
            pr = Double.parseDouble(priceObj.toString());
        } catch (Exception e) {
            out.println("<tr><td colspan='6' style='color:red'>Invalid price for product: "+idStr+" price: "+priceObj+"</td></tr>");
            continue;
        }
        try {
            if (qtyObj instanceof Integer) qty = ((Integer)qtyObj).intValue();
            else qty = Integer.parseInt(qtyObj.toString());
        } catch (Exception e) {
            out.println("<tr><td colspan='6' style='color:red'>Invalid quantity for product: "+idStr+" quantity: "+qtyObj+"</td></tr>");
            qty = 0;
        }

        double subtotal = pr * qty;
        total += subtotal;

        // Row: product id, name, input for quantity, price, subtotal, remove button
        out.print("<tr>");
        out.print("<td>" + idStr + "</td>");
        out.print("<td>" + name + "</td>");
        // quantity input name convention: qty_<productId>
        out.print("<td align=\"center\"><input type=\"number\" name=\"qty_" + idStr + "\" value=\"" + qty + "\" min=\"0\" /></td>");
        out.print("<td align=\"right\">" + currFormat.format(pr) + "</td>");
        out.print("<td align=\"right\">" + currFormat.format(subtotal) + "</td>");
        // Remove button: submits the form with parameter remove=<id>
        out.print("<td><button type=\"submit\" name=\"remove\" value=\"" + idStr + "\">Remove</button></td>");
        out.print("</tr>");
    }

    // Check for Satan's discount/penalty
    Double satanDiscount = (Double) session.getAttribute("satanDiscount");
    double finalTotal = total;

    if (satanDiscount != null && satanDiscount != 1.0) {
        finalTotal = total * satanDiscount;
        out.println("<tr><td colspan=\"4\" align=\"right\"><b>Subtotal</b></td>"
                + "<td align=\"right\">" + currFormat.format(total) + "</td><td></td></tr>");

        if (satanDiscount < 1.0) {
            out.println("<tr style='color: #66ff66;'><td colspan=\"4\" align=\"right\"><b>Satan's Discount (5%)</b></td>"
                    + "<td align=\"right\">-" + currFormat.format(total - finalTotal) + "</td><td></td></tr>");
        } else {
            out.println("<tr style='color: #ff6666;'><td colspan=\"4\" align=\"right\"><b>Satan's Penalty (50%)</b></td>"
                    + "<td align=\"right\">+" + currFormat.format(finalTotal - total) + "</td><td></td></tr>");
        }

        out.println("<tr><td colspan=\"4\" align=\"right\"><b>Final Total</b></td>"
                + "<td align=\"right\"><strong>" + currFormat.format(finalTotal) + "</strong></td><td></td></tr>");
    } else {
        out.println("<tr><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
                + "<td align=\"right\">" + currFormat.format(total) + "</td><td></td></tr>");
    }

    out.println("</table>");

    // Action buttons: update quantities, clear cart, checkout link
    out.println("<p style=\"margin-top:12px;\">");
    out.println("<button type=\"submit\" name=\"action\" value=\"update\">Update Cart</button>");
    out.println("&nbsp;&nbsp;");
    out.println("<button type=\"submit\" name=\"action\" value=\"clear\">Clear Cart</button>");
    out.println("&nbsp;&nbsp;<a href=\"checkout.jsp\">Checkout</a>");
    out.println("</p>");

    out.println("</form>"); // end form
}
%>

<h2><a href="listprod.jsp"> Continue Shopping for More Curses & Blessings</a></h2>
</body>
</html>