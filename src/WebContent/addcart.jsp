<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="cartDB.jsp" %>
<%
// Check if user is logged in
String authenticatedUser = (String) session.getAttribute("authenticatedUser");

// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

// If user is logged in and no session cart, load from database
if (authenticatedUser != null && productList == null) {
	productList = loadCartFromDatabase(authenticatedUser);
}

if (productList == null)
{	// No products currently in list.  Create a list.
	productList = new HashMap<String, ArrayList<Object>>();
}

// Add new product selected
// Get product information
String id = request.getParameter("id");
String name = request.getParameter("name");
String price = request.getParameter("price");
Integer quantity = new Integer(1);

// Store product information in an ArrayList
ArrayList<Object> product = new ArrayList<Object>();
product.add(id);
product.add(name);
product.add(price);
product.add(quantity);

// Update quantity if add same item to order again
if (productList.containsKey(id))
{	product = (ArrayList<Object>) productList.get(id);
	int curAmount = ((Integer) product.get(3)).intValue();
	product.set(3, new Integer(curAmount+1));
}
else
	productList.put(id,product);

session.setAttribute("productList", productList);

// Save to database if user is logged in
if (authenticatedUser != null) {
	saveCartToDatabase(authenticatedUser, productList, application);
}
%>
<jsp:forward page="showcart.jsp" />