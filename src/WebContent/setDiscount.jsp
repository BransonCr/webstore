<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
String discountStr = request.getParameter("discount");
if (discountStr != null) {
    try {
        double discount = Double.parseDouble(discountStr);
        session.setAttribute("satanDiscount", discount);
        out.print("OK");
    } catch (Exception e) {
        out.print("ERROR");
    }
} else {
    out.print("ERROR");
}
%>
