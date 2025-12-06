<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.io.File" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Cursed & Blessed Catalog</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
  body {
    font-family: Georgia, serif;
    margin:20px;
    background: linear-gradient(to bottom, #1a0000 0%, #4a0000 50%, #000033 100%);
    color: #ffcccc;
  }
  table { border-collapse:collapse; width:100%; margin-top:12px; background: rgba(0,0,0,0.7); }
  th, td { border:1px solid #666; padding:6px 8px; text-align:left; vertical-align:middle; }
  th { background:#330000; color:#ffcc99; }
  td { background: rgba(0,0,0,0.5); }
  .small { font-size:0.9em; color:#999; }
  img.thumb { max-width:80px; height:auto; display:block; border: 2px solid #ff6666; border-radius: 5px; }
  h1 { color: #ff6666; text-shadow: 0 0 10px #ff0000; }
  a { color: #99ccff; }
  a:hover { color: #ffcc99; }
  input, select {
    background: #330000;
    color: #ffcccc;
    border: 1px solid #666;
    padding: 5px;
  }
  input[type="submit"] {
    background: #660000;
    color: #ffcc99;
    padding: 8px 15px;
    border: 2px solid #ff6666;
    cursor: pointer;
    border-radius: 5px;
  }
  input[type="submit"]:hover {
    background: #ff6666;
    color: #000;
  }
</style>
</head>
<body>

<h1>🔥 Cursed & Blessed Catalog 😇</h1>
<a href="index.jsp">Home</a> | <a href="showcart.jsp">🛒 View Cart</a>
<form method="get" action="listprod.jsp">
  <label for="productName">Search product name:</label>
  <input type="text" id="productName" name="productName" value="<%= (request.getParameter("productName")!=null ? request.getParameter("productName") : "") %>"/>
  &nbsp;
  <label for="categoryId">Category:</label>
  <select id="categoryId" name="categoryId">
    <option value="">All</option>
<%
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";
Connection con = null;
PreparedStatement catPst = null;
ResultSet catRs = null;
String selectedCat = request.getParameter("categoryId");

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);
    String catSql = "SELECT categoryId, categoryName FROM category ORDER BY categoryName";
    catPst = con.prepareStatement(catSql);
    catRs = catPst.executeQuery();
    while (catRs.next()) {
        String cid = String.valueOf(catRs.getInt("categoryId"));
        String cname = catRs.getString("categoryName");
%>
    <option value="<%= cid %>" <%= (cid.equals(selectedCat) ? "selected" : "") %>><%= cname %></option>
<%
    }
} catch (Exception e) {
    out.println("<option disabled>Error loading categories</option>");
} finally {
    try { if (catRs != null) catRs.close(); } catch (Exception e) {}
    try { if (catPst != null) catPst.close(); } catch (Exception e) {}
    /* keep con open for products below */
}
%>
  </select>
  <input type="submit" value="🔍 Search"/>
</form>

<%
PreparedStatement pst = null;
ResultSet rs = null;
NumberFormat curr = NumberFormat.getCurrencyInstance();
String productNameParam = request.getParameter("productName");

try {
    if (con == null) con = DriverManager.getConnection(url, uid, pw);

    String sql;
    if (productNameParam != null && !productNameParam.trim().isEmpty() && selectedCat != null && !selectedCat.trim().isEmpty()) {
        sql = "SELECT productId, productName, productPrice, productImageURL FROM product WHERE productName LIKE ? AND categoryId = ? ORDER BY productId";
        pst = con.prepareStatement(sql);
        pst.setString(1, "%" + productNameParam + "%");
        pst.setInt(2, Integer.parseInt(selectedCat));
    } else if (productNameParam != null && !productNameParam.trim().isEmpty()) {
        sql = "SELECT productId, productName, productPrice, productImageURL FROM product WHERE productName LIKE ? ORDER BY productId";
        pst = con.prepareStatement(sql);
        pst.setString(1, "%" + productNameParam + "%");
    } else if (selectedCat != null && !selectedCat.trim().isEmpty()) {
        sql = "SELECT productId, productName, productPrice, productImageURL FROM product WHERE categoryId = ? ORDER BY productId";
        pst = con.prepareStatement(sql);
        pst.setInt(1, Integer.parseInt(selectedCat));
    } else {
        sql = "SELECT productId, productName, productPrice, productImageURL FROM product ORDER BY productId";
        pst = con.prepareStatement(sql);
    }

    rs = pst.executeQuery();
%>

<table>
  <tr><th>Image</th><th>Product ID</th><th>Product Name</th><th>Price</th><th>Add</th></tr>
<%
    boolean any = false;
    while (rs.next()) {
        any = true;
        int pid = rs.getInt("productId");
        String pname = rs.getString("productName");
        double price = rs.getDouble("productPrice");
        String imgUrl = rs.getString("productImageURL"); // may be null or like "img/6.jpg" or "img/6.img"

        // --- robust image resolution logic ---
        String imgSrc = null;
        boolean found = false;
        String context = request.getContextPath(); // e.g. /shop or ""

        // 1) If DB gives a path, prefer it (but verify file exists in webapp)
        if (imgUrl != null && !imgUrl.trim().isEmpty()) {
            String candidate = imgUrl.startsWith("/") ? imgUrl.substring(1) : imgUrl; // remove leading slash if any
            String fsPath = application.getRealPath("/" + candidate);
            if (fsPath != null) {
                File f = new File(fsPath);
                if (f.exists() && f.isFile()) {
                    imgSrc = context + "/" + candidate;
                    found = true;
                }
            }
        }

        // 2) If not found via DB path, try common extensions with pid name (6.jpg, 6.webp, ...)
        if (!found) {
            String[] exts = {".jpg", ".webp", ".png", ".avif"};
            for (String ext : exts) {
                String rel = "img/" + pid + ext;
                String fsPath2 = application.getRealPath("/" + rel);
                if (fsPath2 != null) {
                    File f2 = new File(fsPath2);
                    if (f2.exists() && f2.isFile()) {
                        imgSrc = context + "/" + rel;
                        found = true;
                        break;
                    }
                }
            }
        }

        // 3) Final fallback: DB-served binary endpoint
        if (!found) {
            imgSrc = context + "/displayImage.jsp?id=" + pid;
        }

        String link = "addcart.jsp?id=" + pid + "&name=" + URLEncoder.encode(pname, "UTF-8") + "&price=" + price;
        String link2 = "product.jsp?id=" + pid + "&name=" + URLEncoder.encode(pname, "UTF-8") + "&price=" + price;
%>
  <tr>
    <td><img class="thumb" src="<%= imgSrc %>" alt="<%= pname %>"/></td>
    <td><%= pid %></td>
    <td><a href="<%= link2 %>"><%= pname %></a></td>
    <td><%= curr.format(price) %></td>
    <td><a href="<%= link %>">Add to cart</a></td>
  </tr>
<%
    }
    if (!any) {
%>
  <tr><td colspan="5"><em>No products found.</em></td></tr>
<%
    }
} catch (SQLException e) {
    out.println("<tr><td colspan='5' style='color:red'>SQL error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace(new java.io.PrintWriter(out));
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (pst != null) pst.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>
</table>

</body>
</html>
