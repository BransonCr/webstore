<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="cartDB.jsp" %>
<%
request.setCharacterEncoding("UTF-8");
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
String action = request.getParameter("action");
String removeId = request.getParameter("remove");

@SuppressWarnings("unchecked")
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null) {
    response.sendRedirect("showcart.jsp");
    return;
}

// If a remove button was pressed, remove that single item
if (removeId != null && removeId.trim().length() > 0) {
    productList.remove(removeId);
    session.setAttribute("productList", productList);

    // Save to database if user is logged in
    if (authenticatedUser != null) {
        saveCartToDatabase(authenticatedUser, productList, application);
    }

    response.sendRedirect("showcart.jsp");
    return;
}

// If clear was requested, remove entire cart
if ("clear".equals(action)) {
    session.removeAttribute("productList");

    // Clear from database if user is logged in
    if (authenticatedUser != null) {
        clearCartFromDatabase(authenticatedUser);
    }

    response.sendRedirect("showcart.jsp");
    return;
}

// If update, read quantities named qty_<id> and update/remove accordingly
if ("update".equals(action)) {
    Enumeration<String> names = request.getParameterNames();
    List<String> toRemove = new ArrayList<String>();
    while (names.hasMoreElements()) {
        String nm = names.nextElement();
        if (nm.startsWith("qty_")) {
            String pid = nm.substring(4); // product id
            String val = request.getParameter(nm);
            try {
                int q = Integer.parseInt(val);
                if (q <= 0) {
                    toRemove.add(pid);
                } else {
                    ArrayList<Object> prod = productList.get(pid);
                    if (prod != null) prod.set(3, new Integer(q));
                }
            } catch (Exception e) {
                // ignore invalid input (leave quantity unchanged)
            }
        }
    }
    for (String r : toRemove) productList.remove(r);
    session.setAttribute("productList", productList);

    // Save to database if user is logged in
    if (authenticatedUser != null) {
        saveCartToDatabase(authenticatedUser, productList, application);
    }
}

response.sendRedirect("showcart.jsp");
%>
