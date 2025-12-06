<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
session.removeAttribute("satanDiscount");
response.sendRedirect("checkout.jsp");
%>
