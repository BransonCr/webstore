<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Load Cursed & Blessed Data</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
</head>
<body>
<div class="container">
<h1> Loading Cursed & Blessed Data </h1>

<%
try {
    getConnection();
    Statement stmt = con.createStatement();

    out.println("<div class='info'><h3>Step 1: Clearing existing data...</h3></div>");

    // Clear existing data in correct order (respecting foreign key constraints)
    stmt.executeUpdate("DELETE FROM orderproduct");
    stmt.executeUpdate("DELETE FROM incart");
    stmt.executeUpdate("DELETE FROM productinventory");
    stmt.executeUpdate("DELETE FROM product");
    stmt.executeUpdate("DELETE FROM category");

    out.println("<div class='success'> Existing data cleared</div>");

    out.println("<div class='info'><h3>Step 2: Creating categories...</h3></div>");

    // Add categories and get their IDs
    PreparedStatement catPst = con.prepareStatement(
        "INSERT INTO category(categoryName) VALUES (?)",
        Statement.RETURN_GENERATED_KEYS
    );

    catPst.setString(1, "Cursed Items");
    catPst.executeUpdate();
    ResultSet catKeys = catPst.getGeneratedKeys();
    catKeys.next();
    int cursedCatId = catKeys.getInt(1);
    catKeys.close();

    catPst.setString(1, "Blessed Items");
    catPst.executeUpdate();
    catKeys = catPst.getGeneratedKeys();
    catKeys.next();
    int blessedCatId = catKeys.getInt(1);
    catKeys.close();

    catPst.setString(1, "Forbidden Artifacts");
    catPst.executeUpdate();
    catKeys = catPst.getGeneratedKeys();
    catKeys.next();
    int forbiddenCatId = catKeys.getInt(1);
    catKeys.close();

    catPst.setString(1, "Divine Relics");
    catPst.executeUpdate();
    catKeys = catPst.getGeneratedKeys();
    catKeys.next();
    int relicsCatId = catKeys.getInt(1);
    catKeys.close();

    catPst.close();

    out.println("<div class='success'> Categories created (IDs: " + cursedCatId + ", " + blessedCatId + ", " + forbiddenCatId + ", " + relicsCatId + ")</div>");

    out.println("<div class='info'><h3>Step 3: Adding cursed items...</h3></div>");

    // Prepare statement for products
    PreparedStatement pst = con.prepareStatement(
        "INSERT INTO product(productName, categoryId, productDesc, productPrice, productImageURL) VALUES (?, ?, ?, ?, ?)"
    );

    // Cursed Items - Each with unique Satan image
    pst.setString(1, "Cursed Holy Water");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Blessed by Satan himself! Turns your prayers into curses. Side effects include eternal damnation and mild skin irritation. 16oz bottle of pure evil.");
    pst.setDouble(4, 66.60);
    pst.setString(5, "img/holywater.jpg");
    pst.executeUpdate();

    pst.setString(1, "Deafening Earbuds");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Listen to your favorite music... for the last time! These earbuds permanently destroy your hearing. Perfect for avoiding annoying conversations forever!");
    pst.setDouble(4, 99.99);
    pst.setString(5, "img/satan.png");
    pst.executeUpdate();

    pst.setString(1, "Cursed Mirror of Uglification");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Shows your true inner ugliness on the outside! Warning: May cause permanent facial distortion and self-loathing. No refunds.");
    pst.setDouble(4, 133.70);
    pst.setString(5, "img/satan2.png");
    pst.executeUpdate();

    pst.setString(1, "Eternal Procrastination Pen");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Write tomorrow what you should write today! This pen makes you delay everything forever. Comes with infinite writer's block.");
    pst.setDouble(4, 44.40);
    pst.setString(5, "img/satan3.png");
    pst.executeUpdate();

    pst.setString(1, "Nightmare Pillow");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Sleep is for the weak! This pillow guarantees terrifying nightmares every night. Features: sleep paralysis, cold sweats, and demon visitations.");
    pst.setDouble(4, 77.70);
    pst.setString(5, "img/satan.png");
    pst.executeUpdate();

    pst.setString(1, "Bad Luck Charm Bracelet");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Why be lucky when you can be cursed? This bracelet ensures everything goes wrong. Perfect for self-sabotage enthusiasts!");
    pst.setDouble(4, 55.50);
    pst.setString(5, "img/satan2.png");
    pst.executeUpdate();

    pst.setString(1, "Spoiler-Vision Glasses");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "Ruins every movie, book, and TV show before you experience it! See all spoilers instantly. Friendship destruction guaranteed.");
    pst.setDouble(4, 88.80);
    pst.setString(5, "img/satan3.png");
    pst.executeUpdate();

    pst.setString(1, "Infinite Hiccup Elixir");
    pst.setInt(2, cursedCatId);
    pst.setString(3, "One sip = hiccups for eternity! Cannot be cured. Not even death will stop the hiccups. Satan's personal favorite party trick!");
    pst.setDouble(4, 111.10);
    pst.setString(5, "img/satan.png");
    pst.executeUpdate();

    out.println("<div class='success'> 8 cursed items added</div>");

    out.println("<div class='info'><h3>Step 4: Adding blessed items...</h3></div>");

    // Blessed Items - Each with unique Ramond image
    pst.setString(1, "Guaranteed A+ Grade");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Blessed by Ramond! Automatically gives you an A+ in any course. No studying required! Angel-certified academic success.");
    pst.setDouble(4, 299.99);
    pst.setString(5, "img/ramond.png");
    pst.executeUpdate();

    pst.setString(1, "Free Final Exam Solutions");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Ramond provides divine answers to ALL your final exam questions! Comes with heavenly answer key and guilt-free conscience.");
    pst.setDouble(4, 399.99);
    pst.setString(5, "img/ramond2.png");
    pst.executeUpdate();

    pst.setString(1, "Instant Knowledge Download");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Skip the learning process! Ramond downloads 4 years of university knowledge directly into your brain. Warning: May cause enlightenment.");
    pst.setDouble(4, 499.99);
    pst.setString(5, "img/ramond3.png");
    pst.executeUpdate();

    pst.setString(1, "Homework Auto-Completer");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Never do homework again! This blessed device completes assignments while you sleep. Ramond's gift to stressed students.");
    pst.setDouble(4, 249.99);
    pst.setString(5, "img/ramond4.png");
    pst.executeUpdate();

    pst.setString(1, "Professor Mind Control Ray");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Make your professor forget about deadlines! Blessed by Ramond to give infinite extensions and grade forgiveness.");
    pst.setDouble(4, 349.99);
    pst.setString(5, "img/ramond8.png");
    pst.executeUpdate();

    pst.setString(1, "All-Nighter Prevention Potion");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Complete weeks of work in minutes! Ramond's divine efficiency serum. Side effects: Actual productivity and early bedtimes.");
    pst.setDouble(4, 199.99);
    pst.setString(5, "img/ramond.png");
    pst.executeUpdate();

    pst.setString(1, "Blessed Calculator of Correct Answers");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Never get a math problem wrong again! This calculator is blessed by Ramond to always show the right answer, even if you type it wrong.");
    pst.setDouble(4, 149.99);
    pst.setString(5, "img/ramond2.png");
    pst.executeUpdate();

    pst.setString(1, "Divine Plagiarism Detector Shield");
    pst.setInt(2, blessedCatId);
    pst.setString(3, "Ramond protects your 'original' work from detection! Makes Turnitin show 0% similarity. Ethical concerns sold separately.");
    pst.setDouble(4, 279.99);
    pst.setString(5, "img/ramond3.png");
    pst.executeUpdate();

    out.println("<div class='success'> 8 blessed items added</div>");

    out.println("<div class='info'><h3>Step 5: Adding forbidden artifacts...</h3></div>");

    // Forbidden Artifacts - Mix of Satan and Ramond
    pst.setString(1, "Student Loan Forgiveness Amulet");
    pst.setInt(2, forbiddenCatId);
    pst.setString(3, "Cursed by Satan, Blessed by Ramond! Makes creditors forget you exist. Side effects: Suspicious phone calls from the IRS.");
    pst.setDouble(4, 666.00);
    pst.setString(5, "img/satan3.png");
    pst.executeUpdate();

    pst.setString(1, "Social Anxiety Cure/Curse Ring");
    pst.setInt(2, forbiddenCatId);
    pst.setString(3, "Blessed to remove social anxiety, cursed to make you overshare EVERYTHING. No filter mode: activated permanently.");
    pst.setDouble(4, 123.45);
    pst.setString(5, "img/ramond4.png");
    pst.executeUpdate();

    out.println("<div class='success'> 2 forbidden artifacts added</div>");

    out.println("<div class='info'><h3>Step 6: Adding divine relics...</h3></div>");

    // Divine Relics - One of each
    pst.setString(1, "Ramond's Heavenly Coffee Mug");
    pst.setInt(2, relicsCatId);
    pst.setString(3, "Infinite coffee that never runs out! Blessed by Ramond for sleep-deprived students. Warning: May cause transcendent caffeine addiction.");
    pst.setDouble(4, 99.99);
    pst.setString(5, "img/ramond8.png");
    pst.executeUpdate();

    pst.setString(1, "Satan's Eternal Pizza Box");
    pst.setInt(2, relicsCatId);
    pst.setString(3, "Fresh hot pizza appears whenever you open it! Cursed to make you gain weight from just looking at it. Worth it.");
    pst.setDouble(4, 88.88);
    pst.setString(5, "img/satan2.png");
    pst.executeUpdate();

    out.println("<div class='success'> 2 divine relics added</div>");

    out.println("<div class='info'><h3>Step 7: Adding inventory...</h3></div>");

    // Add inventory
    PreparedStatement invPst = con.prepareStatement(
        "INSERT INTO productInventory(productId, warehouseId, quantity, price) VALUES (?, 1, ?, ?)"
    );

    // Get all products and add inventory
    ResultSet rs = stmt.executeQuery("SELECT productId, productPrice FROM product");
    int count = 0;
    while (rs.next()) {
        int productId = rs.getInt("productId");
        double price = rs.getDouble("productPrice");
        int quantity = (productId % 3 == 0) ? 0 : (10 + (productId % 15));

        invPst.setInt(1, productId);
        invPst.setInt(2, quantity);
        invPst.setDouble(3, price);
        invPst.executeUpdate();
        count++;
    }

    out.println("<div class='success'> Inventory added for " + count + " products</div>");

    pst.close();
    invPst.close();
    stmt.close();

    out.println("<br><div class='success' style='font-size: 1.2em; padding: 30px;'>");
    out.println("<h2> SUCCESS! </h2>");
    out.println("<p>Your Cursed & Blessed Emporium has been fully loaded!</p>");
    out.println("<p><strong>Total Products:</strong> 22</p>");
    out.println("<p><strong>Categories:</strong> 4</p>");
    out.println("<ul style='text-align: left; display: inline-block;'>");
    out.println("<li> 8 Cursed Items (Category " + cursedCatId + ")</li>");
    out.println("<li> 8 Blessed Items (Category " + blessedCatId + ")</li>");
    out.println("<li> 2 Forbidden Artifacts (Category " + forbiddenCatId + ")</li>");
    out.println("<li> 2 Divine Relics (Category " + relicsCatId + ")</li>");
    out.println("</ul>");
    out.println("</div>");

} catch (Exception e) {
    out.println("<div class='error'>");
    out.println("<h3> Error loading data</h3>");
    out.println("<p><strong>Error:</strong> " + e.getMessage() + "</p>");
    out.println("<details><summary>Click for full stack trace</summary><pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    out.println("</pre></details>");
    out.println("</div>");
} finally {
    closeConnection();
}
%>

<div class="text-center mt-3">
    <a href="listprod.jsp" class="btn btn-primary"> View Products</a>
    <a href="index.jsp" class="btn btn-secondary"> Home</a>
    <a href="loadCursedData.jsp" class="btn btn-secondary"> Reload Data</a>
</div>

</div>
</body>
</html>
