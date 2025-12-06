<!DOCTYPE html>
<html>
<head>
<title>Admin Dashboard - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
    .admin-nav {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin: 30px 0;
        max-width: 900px;
        margin-left: auto;
        margin-right: auto;
    }
    .admin-nav a {
        background: rgba(102, 0, 0, 0.4);
        border: 2px solid #660000;
        padding: 20px;
        border-radius: 10px;
        text-align: center;
        text-decoration: none;
        color: #ffcc99;
        transition: all 0.3s;
        font-size: 1.1em;
    }
    .admin-nav a:hover {
        background: rgba(102, 0, 0, 0.7);
        border-color: #ff6666;
        box-shadow: 0 0 15px rgba(255, 102, 102, 0.5);
        transform: translateY(-3px);
    }
    .chart-container {
        background: rgba(0, 0, 0, 0.6);
        padding: 30px;
        border-radius: 15px;
        margin: 30px 0;
        border: 2px solid #660000;
    }
    canvas {
        max-height: 400px;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="container">

<%@ include file="auth.jsp" %>
<%@ include file="jdbc.jsp" %>

<h1 style="text-align:center;"> Administrator Dashboard</h1>

<!-- Admin Navigation -->
<div class="admin-nav">
    <a href="listCustomers.jsp"> Manage Customers</a>
    <a href="manageProducts.jsp"> Manage Products</a>
    <a href="listorder.jsp"> View All Orders</a>
    <a href="inventory.jsp"> View Inventory</a>
</div>

<!-- Sales Chart -->
<div class="chart-container">
    <h2 style="color: #ff6666; text-align: center;"> Daily Sales Chart</h2>
    <canvas id="salesChart"></canvas>
</div>

<%
// Write SQL query that prints out total order amount by day
String sql = "SELECT YEAR(orderDate) as orderYear, MONTH(orderDate) as orderMonth, DAY(orderDate) as orderDay, SUM(totalAmount) as dailyTotal FROM ordersummary WHERE shiptoAddress IS NOT NULL GROUP BY YEAR(orderDate), MONTH(orderDate), DAY(orderDate) ORDER BY YEAR(orderDate) DESC, MONTH(orderDate) DESC, DAY(orderDate) DESC";

java.util.ArrayList<String> dates = new java.util.ArrayList<String>();
java.util.ArrayList<Double> totals = new java.util.ArrayList<Double>();

try {
    getConnection();

    PreparedStatement pstmt = con.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();

    out.println("<h2 style='margin-top: 40px;'> Administrator Sales Report</h2>");
    out.println("<table border='1'>");
    out.println("<tr><th>Order Date</th><th>Total Order Amount</th></tr>");

    java.text.NumberFormat currFormat = java.text.NumberFormat.getCurrencyInstance();

    while(rs.next()) {
        int year = rs.getInt("orderYear");
        int month = rs.getInt("orderMonth");
        int day = rs.getInt("orderDay");
        double total = rs.getDouble("dailyTotal");

        String formattedDate = String.format("%04d-%02d-%02d", year, month, day);

        dates.add(formattedDate);
        totals.add(total);

        out.println("<tr>");
        out.println("<td>" + formattedDate + "</td>");
        out.println("<td>" + currFormat.format(total) + "</td>");
        out.println("</tr>");
    }

    out.println("</table>");

    rs.close();
    pstmt.close();
}
catch (SQLException ex) {
    out.println("<p>Error: " + ex.getMessage() + "</p>");
}
finally {
    closeConnection();
}
%>

<!-- Chart.js Script -->
<script>
const ctx = document.getElementById('salesChart');

// Build data arrays from JSP
const labels = [
<%
    for (int i = dates.size() - 1; i >= 0; i--) {
        out.print("'" + dates.get(i) + "'");
        if (i > 0) out.print(", ");
    }
%>
];

const data = [
<%
    for (int i = totals.size() - 1; i >= 0; i--) {
        out.print(totals.get(i));
        if (i > 0) out.print(", ");
    }
%>
];

new Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [{
            label: 'Daily Sales ($)',
            data: data,
            backgroundColor: 'rgba(255, 102, 102, 0.7)',
            borderColor: 'rgba(255, 102, 102, 1)',
            borderWidth: 2
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
            legend: {
                labels: {
                    color: '#ffcc99',
                    font: {
                        size: 14
                    }
                }
            },
            title: {
                display: true,
                text: 'Sales Performance Overview',
                color: '#ffcc99',
                font: {
                    size: 18
                }
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    color: '#ffcc99',
                    callback: function(value) {
                        return '$' + value.toFixed(2);
                    }
                },
                grid: {
                    color: 'rgba(255, 204, 153, 0.1)'
                }
            },
            x: {
                ticks: {
                    color: '#ffcc99'
                },
                grid: {
                    color: 'rgba(255, 204, 153, 0.1)'
                }
            }
        }
    }
});
</script>

<p class="text-center mt-3">
    <a href="index.jsp"><- Back to Home</a>
</p>

</div>

</body>
</html>