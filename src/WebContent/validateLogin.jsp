<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ page import="java.util.*" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="cartDB.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

	try
	{
		authenticatedUser = validateLogin(out,request,session);
	}
	catch(IOException e)
	{	System.err.println(e); }

	if(authenticatedUser != null) {
		// Load cart from database when user logs in
		HashMap<String, ArrayList<Object>> dbCart = loadCartFromDatabase(authenticatedUser);
		HashMap<String, ArrayList<Object>> sessionCart = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

		// Merge session cart with database cart
		if (sessionCart != null && !sessionCart.isEmpty()) {
			// Merge session cart into database cart
			if (dbCart == null) dbCart = new HashMap<String, ArrayList<Object>>();
			for (Map.Entry<String, ArrayList<Object>> entry : sessionCart.entrySet()) {
				String productId = entry.getKey();
				ArrayList<Object> sessionProduct = entry.getValue();

				if (dbCart.containsKey(productId)) {
					// Combine quantities
					ArrayList<Object> dbProduct = dbCart.get(productId);
					int sessionQty = ((Integer)sessionProduct.get(3)).intValue();
					int dbQty = ((Integer)dbProduct.get(3)).intValue();
					dbProduct.set(3, new Integer(sessionQty + dbQty));
				} else {
					// Add new item from session cart
					dbCart.put(productId, sessionProduct);
				}
			}
			// Save merged cart to database
			saveCartToDatabase(authenticatedUser, dbCart, application);
		}

		// Set cart in session
		if (dbCart != null && !dbCart.isEmpty()) {
			session.setAttribute("productList", dbCart);
		}

		response.sendRedirect("index.jsp");		// Successful login
	} else {
		response.sendRedirect("login.jsp");		// Failed login - redirect back to login page with a message
	}
%>


<%!
	String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException
	{
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;

		try 
		{
			getConnection();
			
			// Check if userId and password match some customer account
			String sql = "SELECT userid FROM customer WHERE userid = ? AND password = ?";
			PreparedStatement pstmt = con.prepareStatement(sql);
			pstmt.setString(1, username);
			pstmt.setString(2, password);
			
			ResultSet rs = pstmt.executeQuery();
			
			if(rs.next()) {
				retStr = rs.getString("userid");
			}
			
			rs.close();
			pstmt.close();
		} 
		catch (SQLException ex) {
			out.println(ex);
		}
		finally
		{
			closeConnection();
		}	
		
		if(retStr != null)
		{	
			session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser",username);
		}
		else
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");

		return retStr;
	}
%>

