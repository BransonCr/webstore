<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%!
    // Save cart to database for logged-in user
    public static void saveCartToDatabase(String username, HashMap<String, ArrayList<Object>> productList, javax.servlet.ServletContext application) {
        if (username == null || productList == null) return;

        final String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        final String uid = "sa";
        final String pw  = "304#sa#pw";

        Connection con = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, uid, pw);

            // Get customer ID
            PreparedStatement custPst = con.prepareStatement("SELECT customerId FROM customer WHERE userid = ?");
            custPst.setString(1, username);
            ResultSet custRs = custPst.executeQuery();

            if (!custRs.next()) {
                custRs.close();
                custPst.close();
                return;
            }

            int customerId = custRs.getInt("customerId");
            custRs.close();
            custPst.close();

            // Get or create a pending order for this customer's cart
            PreparedStatement orderPst = con.prepareStatement(
                "SELECT orderId FROM ordersummary WHERE customerId = ? AND shiptoAddress IS NULL ORDER BY orderDate DESC"
            );
            orderPst.setInt(1, customerId);
            ResultSet orderRs = orderPst.executeQuery();

            int orderId = -1;
            if (orderRs.next()) {
                orderId = orderRs.getInt("orderId");
            } else {
                // Create a new pending order (cart placeholder)
                PreparedStatement insertOrderPst = con.prepareStatement(
                    "INSERT INTO ordersummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), 0.0)",
                    Statement.RETURN_GENERATED_KEYS
                );
                insertOrderPst.setInt(1, customerId);
                insertOrderPst.executeUpdate();

                ResultSet genKeys = insertOrderPst.getGeneratedKeys();
                if (genKeys.next()) {
                    orderId = genKeys.getInt(1);
                }
                genKeys.close();
                insertOrderPst.close();
            }
            orderRs.close();
            orderPst.close();

            if (orderId <= 0) return;

            // Clear existing cart items for this order
            PreparedStatement deletePst = con.prepareStatement("DELETE FROM incart WHERE orderId = ?");
            deletePst.setInt(1, orderId);
            deletePst.executeUpdate();
            deletePst.close();

            // Insert current cart items
            PreparedStatement insertPst = con.prepareStatement(
                "INSERT INTO incart (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)"
            );

            Iterator<Map.Entry<String, ArrayList<Object>>> it = productList.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry<String, ArrayList<Object>> entry = it.next();
                ArrayList<Object> product = entry.getValue();

                if (product.size() < 4) continue;

                try {
                    int productId = Integer.parseInt(product.get(0).toString());
                    double price = Double.parseDouble(product.get(2).toString());
                    int quantity = product.get(3) instanceof Integer ?
                        ((Integer)product.get(3)).intValue() :
                        Integer.parseInt(product.get(3).toString());

                    insertPst.setInt(1, orderId);
                    insertPst.setInt(2, productId);
                    insertPst.setInt(3, quantity);
                    insertPst.setDouble(4, price);
                    insertPst.executeUpdate();
                } catch (Exception e) {
                    // Skip invalid items
                }
            }
            insertPst.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    // Load cart from database for logged-in user
    public static HashMap<String, ArrayList<Object>> loadCartFromDatabase(String username) {
        HashMap<String, ArrayList<Object>> productList = new HashMap<String, ArrayList<Object>>();
        if (username == null) return productList;

        final String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        final String uid = "sa";
        final String pw  = "304#sa#pw";

        Connection con = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, uid, pw);

            // Get customer ID
            PreparedStatement custPst = con.prepareStatement("SELECT customerId FROM customer WHERE userid = ?");
            custPst.setString(1, username);
            ResultSet custRs = custPst.executeQuery();

            if (!custRs.next()) {
                custRs.close();
                custPst.close();
                return productList;
            }

            int customerId = custRs.getInt("customerId");
            custRs.close();
            custPst.close();

            // Get pending order (cart) for this customer
            PreparedStatement orderPst = con.prepareStatement(
                "SELECT orderId FROM ordersummary WHERE customerId = ? AND shiptoAddress IS NULL ORDER BY orderDate DESC"
            );
            orderPst.setInt(1, customerId);
            ResultSet orderRs = orderPst.executeQuery();

            if (!orderRs.next()) {
                orderRs.close();
                orderPst.close();
                return productList;
            }

            int orderId = orderRs.getInt("orderId");
            orderRs.close();
            orderPst.close();

            // Load cart items
            PreparedStatement cartPst = con.prepareStatement(
                "SELECT ic.productId, p.productName, ic.price, ic.quantity " +
                "FROM incart ic " +
                "JOIN product p ON ic.productId = p.productId " +
                "WHERE ic.orderId = ?"
            );
            cartPst.setInt(1, orderId);
            ResultSet cartRs = cartPst.executeQuery();

            while (cartRs.next()) {
                String productId = String.valueOf(cartRs.getInt("productId"));
                String productName = cartRs.getString("productName");
                double price = cartRs.getDouble("price");
                int quantity = cartRs.getInt("quantity");

                ArrayList<Object> product = new ArrayList<Object>();
                product.add(productId);
                product.add(productName);
                product.add(String.valueOf(price));
                product.add(new Integer(quantity));

                productList.put(productId, product);
            }

            cartRs.close();
            cartPst.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return productList;
    }

    // Clear cart from database for logged-in user
    public static void clearCartFromDatabase(String username) {
        if (username == null) return;

        final String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        final String uid = "sa";
        final String pw  = "304#sa#pw";

        Connection con = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, uid, pw);

            // Get customer ID
            PreparedStatement custPst = con.prepareStatement("SELECT customerId FROM customer WHERE userid = ?");
            custPst.setString(1, username);
            ResultSet custRs = custPst.executeQuery();

            if (!custRs.next()) {
                custRs.close();
                custPst.close();
                return;
            }

            int customerId = custRs.getInt("customerId");
            custRs.close();
            custPst.close();

            // Get pending order (cart) for this customer
            PreparedStatement orderPst = con.prepareStatement(
                "SELECT orderId FROM ordersummary WHERE customerId = ? AND shiptoAddress IS NULL ORDER BY orderDate DESC"
            );
            orderPst.setInt(1, customerId);
            ResultSet orderRs = orderPst.executeQuery();

            if (!orderRs.next()) {
                orderRs.close();
                orderPst.close();
                return;
            }

            int orderId = orderRs.getInt("orderId");
            orderRs.close();
            orderPst.close();

            // Delete cart items
            PreparedStatement deletePst = con.prepareStatement("DELETE FROM incart WHERE orderId = ?");
            deletePst.setInt(1, orderId);
            deletePst.executeUpdate();
            deletePst.close();

            // Delete the pending order
            PreparedStatement deleteOrderPst = con.prepareStatement("DELETE FROM ordersummary WHERE orderId = ?");
            deleteOrderPst.setInt(1, orderId);
            deleteOrderPst.executeUpdate();
            deleteOrderPst.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
%>
