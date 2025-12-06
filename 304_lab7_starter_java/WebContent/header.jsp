<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
String userName = (String) session.getAttribute("authenticatedUser");
%>
<!-- Navigation Header -->
<div class="header-nav">
    <div class="nav-left">
        <a href="index.jsp" class="nav-logo">🔥 Cursed & Blessed Emporium 😇</a>
    </div>
    <div class="nav-center">
        <a href="listprod.jsp">🛒 Shop</a>
        <a href="showcart.jsp">🛒 Cart</a>
        <% if (userName != null) { %>
            <a href="myorders.jsp">📦 My Orders</a>
            <a href="customer.jsp">👤 Profile</a>
        <% } %>
        <a href="admin.jsp">⚙️ Admin</a>
    </div>
    <div class="nav-right">
        <% if (userName != null) { %>
            <span class="user-info">👋 Welcome, <strong><%= userName %></strong></span>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        <% } else { %>
            <a href="login.jsp" class="btn-login">Login</a>
        <% } %>
    </div>
</div>

<style>
.header-nav {
    background: linear-gradient(to right, #330000, #000033);
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #ff6666;
    box-shadow: 0 2px 10px rgba(255, 102, 102, 0.3);
    margin-bottom: 20px;
}

.nav-left .nav-logo {
    font-size: 1.5em;
    font-weight: bold;
    color: #ff6666;
    text-decoration: none;
    text-shadow: 0 0 10px #ff0000;
}

.nav-center {
    display: flex;
    gap: 20px;
}

.nav-center a {
    color: #ffcc99;
    text-decoration: none;
    padding: 8px 15px;
    border-radius: 5px;
    transition: all 0.3s;
}

.nav-center a:hover {
    background: rgba(255, 102, 102, 0.2);
    color: #ff6666;
}

.nav-right {
    display: flex;
    align-items: center;
    gap: 15px;
}

.user-info {
    color: #99ccff;
    font-size: 0.95em;
}

.user-info strong {
    color: #ffcc99;
}

.btn-login, .btn-logout {
    background: #660000;
    color: #ffcc99;
    padding: 8px 20px;
    border-radius: 5px;
    text-decoration: none;
    border: 1px solid #ff6666;
    transition: all 0.3s;
}

.btn-login:hover, .btn-logout:hover {
    background: #ff6666;
    color: #000;
    box-shadow: 0 0 10px #ff6666;
}
</style>
