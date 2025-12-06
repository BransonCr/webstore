<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<%@ page import="java.io.File" %>
<html>
<head>
<title>The Cursed & Blessed Emporium - Product Details</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
body {
    font-family: Georgia, serif;
    margin:20px;
    background: linear-gradient(to bottom, #1a0000 0%, #4a0000 50%, #000033 100%);
    color: #ffcccc;
}
.container {
    max-width: 900px;
    margin: 30px auto;
    background: rgba(0,0,0,0.7);
    padding: 30px;
    border-radius: 15px;
    border: 2px solid #ff6666;
}
h1, h2 { color: #ff6666; text-shadow: 0 0 10px #ff0000; }
h5 { color: #ffcc99; }
img {
    max-width: 100%;
    height: auto;
    border: 3px solid #ff6666;
    border-radius: 10px;
    background: #000;
}
.btn {
    padding: 10px 20px;
    text-decoration: none;
    border-radius: 5px;
    display: inline-block;
    margin: 5px;
    cursor: pointer;
    border: 2px solid;
}
.btn-primary {
    background: #660000;
    color: #ffcc99;
    border-color: #ff6666;
}
.btn-primary:hover {
    background: #ff6666;
    color: #000;
}
.btn-secondary {
    background: #000066;
    color: #99ccff;
    border-color: #6666ff;
}
.btn-secondary:hover {
    background: #6666ff;
    color: #000;
}
.product-description {
    background: rgba(102,0,0,0.3);
    padding: 20px;
    border-left: 5px solid #ff6666;
    margin: 20px 0;
    font-size: 1.1em;
    line-height: 1.6;
}
.blessed-description {
    background: rgba(0,0,102,0.3);
    border-left: 5px solid #6666ff;
}
.explainer {
    margin: 30px 0;
    padding: 20px;
    background: rgba(0,0,0,0.5);
    border-radius: 10px;
    border: 2px dashed #ffcc99;
}
.explainer img {
    max-width: 150px;
    float: left;
    margin-right: 20px;
    border-radius: 50%;
}
.explainer h3 {
    color: #ffcc99;
    margin-top: 0;
}
.explainer p {
    font-style: italic;
}
.cursed-explainer {
    border-color: #ff3333;
}
.cursed-explainer h3 {
    color: #ff3333;
}
.blessed-explainer {
    border-color: #6699ff;
}
.blessed-explainer h3 {
    color: #6699ff;
}
</style>
</head>
<body>
<%
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String price = request.getParameter("price");

    if (id == null || id.trim().isEmpty()) {
        out.println("<div class='container'><h2>Error: No product specified</h2><a href='listprod.jsp'>Back to products</a></div>");
        return;
    }

    NumberFormat curr = NumberFormat.getCurrencyInstance();

    // Fetch full product details from database
    String productName = "";
    String productDesc = "";
    double productPrice = 0.0;
    String productImageURL = "";
    String categoryName = "";
    int categoryId = 0;

    try {
        getConnection();
        String sql = "SELECT p.productId, p.productName, p.productDesc, p.productPrice, p.productImageURL, " +
                     "c.categoryId, c.categoryName " +
                     "FROM product p " +
                     "LEFT JOIN category c ON p.categoryId = c.categoryId " +
                     "WHERE p.productId = ?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, Integer.parseInt(id));
        ResultSet rs = pst.executeQuery();

        if (rs.next()) {
            productName = rs.getString("productName");
            productDesc = rs.getString("productDesc");
            productPrice = rs.getDouble("productPrice");
            productImageURL = rs.getString("productImageURL");
            categoryId = rs.getInt("categoryId");
            categoryName = rs.getString("categoryName");
        } else {
            out.println("<div class='container'><h2>Product not found</h2><a href='listprod.jsp'>Back to products</a></div>");
            return;
        }
        rs.close();
        pst.close();
    } catch (Exception e) {
        out.println("<div class='container'><p style='color:#ff3333'>Error: " + e.getMessage() + "</p></div>");
        return;
    } finally {
        closeConnection();
    }

    // Check if local file image exists (jpg, png, webp, avif)
    String[] exts = {".jpg", ".png", ".webp", ".avif", ".gif"};
    String fileImgSrc = null;

    // First try the productImageURL from database
    if (productImageURL != null && !productImageURL.trim().isEmpty()) {
        String candidate = productImageURL.startsWith("/") ? productImageURL.substring(1) : productImageURL;
        String fsPath = application.getRealPath("/" + candidate);
        if (fsPath != null) {
            File f = new File(fsPath);
            if (f.exists() && f.isFile()) {
                fileImgSrc = request.getContextPath() + "/" + candidate;
            }
        }
    }

    // If not found, try common extensions with product ID
    if (fileImgSrc == null) {
        for (String ext : exts) {
            String fsPath = application.getRealPath("/img/" + id + ext);
            if (fsPath != null) {
                File f = new File(fsPath);
                if (f.exists() && f.isFile()) {
                    fileImgSrc = request.getContextPath() + "/img/" + id + ext;
                    break;
                }
            }
        }
    }

    // Binary DB image fallback
    String imgToShow = (fileImgSrc != null) ? fileImgSrc : (request.getContextPath() + "/displayImage.jsp?id=" + id);

    // Build add-to-cart link
    String addLink = "addcart.jsp?id=" + id + "&name=" + java.net.URLEncoder.encode(productName, "UTF-8") + "&price=" + productPrice;

    // Determine if cursed or blessed based on category
    boolean isCursed = (categoryId == 1 || categoryId == 3); // Cursed Items or Forbidden Artifacts
    boolean isBlessed = (categoryId == 2 || categoryId == 4); // Blessed Items or Divine Relics
%>

<div class="container">
    <h1><%= productName %></h1>

    <div style="text-align:center; margin:20px 0;">
        <img src="<%= imgToShow %>" alt="<%= productName %>" style="max-width:400px;">
    </div>

    <p><strong>Product ID:</strong> <%= id %></p>
    <p><strong>Category:</strong> <%= categoryName %></p>
    <p><strong>Price:</strong> <%= curr.format(productPrice) %></p>

    <% if (productDesc != null && !productDesc.trim().isEmpty()) { %>
    <div class="product-description <%= isBlessed ? "blessed-description" : "" %>">
        <h3>Description:</h3>
        <p><%= productDesc %></p>
    </div>
    <% } %>

    <% if (isCursed) { %>
    <div class="explainer cursed-explainer">
        <img src="<%= request.getContextPath() %>/img/satan.png" alt="Satan" onerror="this.style.display='none'">
        <h3>🔥 Satan's Warning 🔥</h3>
        <p>"Hey there, mortal! This is one of my FINEST creations. Sure, it might ruin your life, but that's the whole point!
        Come on, you know you want it. What's the worst that could happen? (Don't answer that.)
        Trust me, I'm the Prince of Darkness - I totally have your best interests at heart! *Evil laugh*"</p>
        <div style="clear:both;"></div>
    </div>
    <% } %>

    <% if (isBlessed) { %>
    <div class="explainer blessed-explainer">
        <img src="<%= request.getContextPath() %>/img/ramond.png" alt="Ramond the Angel" onerror="this.style.display='none'">
        <h3>😇 Ramond's Blessing 😇</h3>
        <p>"Greetings, dear student! I, Ramond the Angel, have blessed this divine item with the power to make your academic
        life infinitely easier. Some might call it 'cheating,' but I prefer to call it 'divine intervention.'
        The heavens smile upon those who work smart, not hard! Your GPA will thank you. Go forth and prosper!"</p>
        <div style="clear:both;"></div>
    </div>
    <% } %>

    <% if (categoryId == 3) { // Forbidden Artifacts - both cursed AND blessed %>
    <div class="explainer blessed-explainer">
        <img src="<%= request.getContextPath() %>/img/ramond.png" alt="Ramond" onerror="this.style.display='none'">
        <h3>😇 Ramond's Perspective 😇</h3>
        <p>"This item contains BOTH my blessing and Satan's curse. Use with extreme caution! The benefits are divine,
        but the side effects... well, let's just say we're not liable for any demonic consequences."</p>
        <div style="clear:both;"></div>
    </div>
    <% } %>

    <div style="margin-top:30px;">
        <a href="<%= addLink %>" class="btn btn-primary">🛒 Add to Cart</a>
        <a href="listprod.jsp" class="btn btn-secondary">← Continue Shopping</a>
    </div>

    <!-- Product Reviews Section -->
    <div style="margin-top: 40px; padding-top: 30px; border-top: 2px solid #ff6666;">
        <h2>📝 Customer Reviews</h2>

        <%
        // Display existing reviews
        try {
            getConnection();
            String reviewSql = "SELECT r.reviewId, r.reviewRating, r.reviewComment, r.reviewDate, " +
                             "c.firstName, c.lastName " +
                             "FROM review r " +
                             "JOIN customer c ON r.customerId = c.customerId " +
                             "WHERE r.productId = ? " +
                             "ORDER BY r.reviewDate DESC";
            PreparedStatement reviewPst = con.prepareStatement(reviewSql);
            reviewPst.setInt(1, Integer.parseInt(id));
            ResultSet reviewRs = reviewPst.executeQuery();

            boolean hasReviews = false;
            while (reviewRs.next()) {
                hasReviews = true;
                int rating = reviewRs.getInt("reviewRating");
                String comment = reviewRs.getString("reviewComment");
                String reviewDate = reviewRs.getString("reviewDate");
                String firstName = reviewRs.getString("firstName");
                String lastName = reviewRs.getString("lastName");

                // Display stars
                String stars = "";
                for (int i = 0; i < rating; i++) stars += "⭐";
                for (int i = rating; i < 5; i++) stars += "☆";
        %>
        <div style="background: rgba(0,0,0,0.4); padding: 15px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #ff6666;">
            <div style="margin-bottom: 10px;">
                <strong style="color: #ffcc99;"><%= firstName %> <%= lastName %></strong>
                <span style="float: right; color: #999;"><%= reviewDate %></span>
            </div>
            <div style="font-size: 1.3em; margin: 5px 0;"><%= stars %> (<%= rating %>/5)</div>
            <p style="margin-top: 10px; color: #ffdddd;"><%= comment %></p>
        </div>
        <%
            }

            if (!hasReviews) {
                out.println("<p style='color: #999; font-style: italic;'>No reviews yet. Be the first to review this product!</p>");
            }

            reviewRs.close();
            reviewPst.close();
        } catch (Exception e) {
            out.println("<p style='color:#ff3333'>Error loading reviews: " + e.getMessage() + "</p>");
        } finally {
            closeConnection();
        }

        // Check if user is logged in
        String authenticatedUser = (String) session.getAttribute("authenticatedUser");
        %>

        <div style="margin-top: 30px; padding: 20px; background: rgba(102,0,102,0.2); border-radius: 10px;">
            <h3>Write a Review</h3>
            <% if (authenticatedUser != null) { %>
            <form method="post" action="reviewAction.jsp" onsubmit="return validateReview()">
                <input type="hidden" name="productId" value="<%= id %>">
                <input type="hidden" name="productName" value="<%= productName %>">

                <div style="margin: 15px 0;">
                    <label style="display: block; margin-bottom: 5px;"><strong>Rating:</strong></label>
                    <select name="rating" required style="padding: 5px; font-size: 1.1em;">
                        <option value="">Select rating...</option>
                        <option value="5">⭐⭐⭐⭐⭐ (5 stars - Excellent)</option>
                        <option value="4">⭐⭐⭐⭐☆ (4 stars - Very Good)</option>
                        <option value="3">⭐⭐⭐☆☆ (3 stars - Good)</option>
                        <option value="2">⭐⭐☆☆☆ (2 stars - Fair)</option>
                        <option value="1">⭐☆☆☆☆ (1 star - Poor)</option>
                    </select>
                </div>

                <div style="margin: 15px 0;">
                    <label style="display: block; margin-bottom: 5px;"><strong>Your Review:</strong></label>
                    <textarea name="comment" rows="5" required style="width: 100%; padding: 10px; font-size: 1em; font-family: Georgia, serif;"
                              placeholder="Share your experience with this product..."></textarea>
                </div>

                <button type="submit" class="btn btn-primary">Submit Review</button>
            </form>

            <script>
            function validateReview() {
                var rating = document.querySelector('select[name="rating"]').value;
                var comment = document.querySelector('textarea[name="comment"]').value;

                if (!rating) {
                    alert("Please select a rating");
                    return false;
                }

                if (comment.trim().length < 10) {
                    alert("Review must be at least 10 characters long");
                    return false;
                }

                return true;
            }
            </script>
            <% } else { %>
            <p style="color: #ffcc99;">Please <a href="login.jsp" style="color: #ff6666;">log in</a> to write a review.</p>
            <% } %>
        </div>
    </div>
</div>

</body>
</html>
