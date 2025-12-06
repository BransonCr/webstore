<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<!DOCTYPE html>
<html>
<head>
		<title>The Cursed & Blessed Emporium</title>
		<link rel="stylesheet" href="css/cursed-blessed-theme.css">
		<style>
			body {
				background: linear-gradient(to bottom, #1a0000 0%, #4a0000 50%, #000033 100%);
				color: #ffcccc;
				font-family: 'Georgia', serif;
				margin: 0;
				padding: 0;
			}
			.hero {
				text-align: center;
				padding: 40px 20px;
			}
			.hero h1 {
				color: #ff6666;
				text-shadow: 0 0 10px #ff0000, 0 0 20px #ff0000;
				font-size: 3em;
				margin: 20px 0;
			}
			.warning {
				color: #ff3333;
				font-style: italic;
				margin: 20px;
				font-size: 1.2em;
			}
			.featured-products {
				max-width: 1200px;
				margin: 40px auto;
				padding: 0 20px;
			}
			.featured-products h2 {
				color: #ffcc99;
				text-align: center;
				text-shadow: 0 0 10px #ff6666;
				margin-bottom: 30px;
			}
			.product-grid {
				display: grid;
				grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
				gap: 20px;
				margin-top: 20px;
			}
			.product-card {
				background: rgba(0, 0, 0, 0.6);
				border: 2px solid #660000;
				border-radius: 10px;
				padding: 15px;
				text-align: center;
				transition: all 0.3s;
			}
			.product-card:hover {
				border-color: #ff6666;
				box-shadow: 0 0 20px rgba(255, 102, 102, 0.5);
				transform: translateY(-5px);
			}
			.product-card img {
				max-width: 150px;
				max-height: 150px;
				border-radius: 5px;
				margin-bottom: 10px;
			}
			.product-card h3 {
				color: #ffcc99;
				font-size: 1.1em;
				margin: 10px 0;
			}
			.product-card .price {
				color: #ff6666;
				font-size: 1.3em;
				font-weight: bold;
				margin: 10px 0;
			}
			.product-card .sales-badge {
				background: #ff6666;
				color: #000;
				padding: 5px 10px;
				border-radius: 5px;
				font-size: 0.9em;
				font-weight: bold;
				display: inline-block;
				margin-top: 5px;
			}
			.cta-buttons {
				text-align: center;
				margin: 40px 0;
			}
			.cta-buttons a {
				display: inline-block;
				background: #660000;
				color: #ffcc99;
				padding: 15px 30px;
				margin: 10px;
				border: 2px solid #ff6666;
				border-radius: 8px;
				text-decoration: none;
				font-size: 1.2em;
				transition: all 0.3s;
			}
			.cta-buttons a:hover {
				background: #ff6666;
				color: #000;
				box-shadow: 0 0 20px #ff6666;
			}
		</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="hero">
	<h1> The Cursed & Blessed Emporium </h1>
	<p class="warning"> Warning: We sell both divinely blessed AND satanically cursed items </p>
</div>

<!-- Featured Products Based on Sales -->
<div class="featured-products">
	<h2> Bestselling Curses & Blessings </h2>

	<div class="product-grid">
<%
	// Display top 5 products based on total sales
	String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
	String uid = "sa";
	String pw = "304#sa#pw";

	try {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	} catch (Exception e) { /* Driver already loaded */ }

	Connection con = null;
	PreparedStatement pst = null;
	ResultSet rs = null;
	NumberFormat currFormat = NumberFormat.getCurrencyInstance();

	try {
		con = DriverManager.getConnection(url, uid, pw);

		// Query to get top 5 products by total sales
		String query = "SELECT TOP 5 p.productId, p.productName, p.productPrice, p.productImageURL, " +
		               "COALESCE(SUM(op.quantity), 0) AS totalSold " +
		               "FROM product p " +
		               "LEFT JOIN orderproduct op ON p.productId = op.productId " +
		               "GROUP BY p.productId, p.productName, p.productPrice, p.productImageURL " +
		               "ORDER BY totalSold DESC, p.productId";

		pst = con.prepareStatement(query);
		rs = pst.executeQuery();

		while (rs.next()) {
			int productId = rs.getInt("productId");
			String productName = rs.getString("productName");
			double productPrice = rs.getDouble("productPrice");
			String productImageURL = rs.getString("productImageURL");
			int totalSold = rs.getInt("totalSold");

			// Determine image source
			String imgSrc = "img/default.jpg";
			if (productImageURL != null && !productImageURL.trim().isEmpty()) {
				imgSrc = productImageURL;
			}
%>
		<div class="product-card">
			<a href="product.jsp?id=<%= productId %>" style="text-decoration: none;">
				<img src="<%= imgSrc %>" alt="<%= productName %>" onerror="this.src='img/default.jpg'">
				<h3><%= productName %></h3>
				<div class="price"><%= currFormat.format(productPrice) %></div>
				<div class="sales-badge"> <%= totalSold %> sold</div>
			</a>
		</div>
<%
		}

		// if (rs != null && !rs.isBeforeFirst()) {
		// 	out.println("<p style='text-align:center; color:#ffcc99;'>No products available yet. Load the database!</p>");
		// }

	} catch (SQLException e) {
		out.println("<p style='color:red; text-align:center;'>Error loading featured products: " + e.getMessage() + "</p>");
	} finally {
		try { if (rs != null) rs.close(); } catch (Exception e) { }
		try { if (pst != null) pst.close(); } catch (Exception e) { }
		try { if (con != null) con.close(); } catch (Exception e) { }
	}
%>
	</div>
</div>

<div class="cta-buttons">
	<a href="listprod.jsp"> Browse All Products</a>
	<a href="showcart.jsp"> View Cart</a>
</div>

</body>
</html>


