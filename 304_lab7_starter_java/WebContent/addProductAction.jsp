<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
request.setCharacterEncoding("UTF-8");

String productName = null;
String categoryIdStr = null;
String productPriceStr = null;
String productDesc = null;
String productImageURL = null;
Part filePart = null;

// Check if this is a multipart request
String contentType = request.getContentType();
boolean isMultipart = (contentType != null && contentType.toLowerCase().startsWith("multipart/"));

if (isMultipart) {
    try {
        // Handle multipart form data
        productName = request.getParameter("productName");
        categoryIdStr = request.getParameter("categoryId");
        productPriceStr = request.getParameter("productPrice");
        productDesc = request.getParameter("productDesc");
        filePart = request.getPart("productImage");
    } catch (Exception e) {
        // If multipart parsing fails, try regular parameters
        productName = request.getParameter("productName");
        categoryIdStr = request.getParameter("categoryId");
        productPriceStr = request.getParameter("productPrice");
        productDesc = request.getParameter("productDesc");
    }
} else {
    // Regular form submission
    productName = request.getParameter("productName");
    categoryIdStr = request.getParameter("categoryId");
    productPriceStr = request.getParameter("productPrice");
    productDesc = request.getParameter("productDesc");
    productImageURL = request.getParameter("productImageURL");
}

// Validation
if (productName == null || productName.trim().isEmpty() ||
    categoryIdStr == null || categoryIdStr.trim().isEmpty() ||
    productPriceStr == null || productPriceStr.trim().isEmpty()) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("All required fields must be filled", "UTF-8"));
    return;
}

int categoryId = 0;
double productPrice = 0.0;

try {
    categoryId = Integer.parseInt(categoryIdStr);
    productPrice = Double.parseDouble(productPriceStr);

    if (productPrice < 0) {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Price must be positive", "UTF-8"));
        return;
    }
} catch (NumberFormatException e) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Invalid number format", "UTF-8"));
    return;
}

// Handle file upload if present
String savedImagePath = null;
if (filePart != null && filePart.getSize() > 0) {
    try {
        // Check file size (5MB limit)
        if (filePart.getSize() > 5 * 1024 * 1024) {
            response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("File size must be less than 5MB", "UTF-8"));
            return;
        }

        // Get filename and extension
        String fileName = filePart.getSubmittedFileName();
        String fileExtension = "";
        if (fileName != null && fileName.contains(".")) {
            fileExtension = fileName.substring(fileName.lastIndexOf("."));
        }

        // Validate file type
        String[] allowedExtensions = {".jpg", ".jpeg", ".png", ".webp", ".gif"};
        boolean validExtension = false;
        for (String ext : allowedExtensions) {
            if (fileExtension.toLowerCase().equals(ext)) {
                validExtension = true;
                break;
            }
        }

        if (!validExtension) {
            response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Invalid file type. Only JPG, PNG, WEBP, GIF allowed", "UTF-8"));
            return;
        }

        // Get the img directory path
        String uploadPath = application.getRealPath("/img");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Generate unique filename (we'll use product ID, but for now use timestamp)
        String timestamp = String.valueOf(System.currentTimeMillis());
        String newFileName = "product_" + timestamp + fileExtension;
        String filePath = uploadPath + File.separator + newFileName;

        // Save the file
        filePart.write(filePath);

        // Set the image URL for database
        productImageURL = "img/" + newFileName;
        savedImagePath = productImageURL;

    } catch (Exception e) {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("File upload error: " + e.getMessage(), "UTF-8"));
        return;
    }
}

// Database connection
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

Connection con = null;
PreparedStatement pst = null;
ResultSet generatedKeys = null;

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    con = DriverManager.getConnection(url, uid, pw);

    String insertSQL = "INSERT INTO product (productName, categoryId, productDesc, productPrice, productImageURL) " +
                       "VALUES (?, ?, ?, ?, ?)";

    pst = con.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);
    pst.setString(1, productName.trim());
    pst.setInt(2, categoryId);
    pst.setString(3, productDesc != null && !productDesc.trim().isEmpty() ? productDesc.trim() : null);
    pst.setDouble(4, productPrice);
    pst.setString(5, productImageURL != null && !productImageURL.trim().isEmpty() ? productImageURL.trim() : null);

    int rowsInserted = pst.executeUpdate();

    if (rowsInserted > 0) {
        // If we uploaded a file, rename it with the product ID
        if (savedImagePath != null) {
            generatedKeys = pst.getGeneratedKeys();
            if (generatedKeys.next()) {
                int productId = generatedKeys.getInt(1);

                // Rename the file to use product ID
                String uploadPath = application.getRealPath("/img");
                String timestamp = String.valueOf(System.currentTimeMillis());
                String oldFileName = savedImagePath.substring(savedImagePath.lastIndexOf("/") + 1);
                String fileExtension = oldFileName.substring(oldFileName.lastIndexOf("."));
                String newFileName = productId + fileExtension;

                File oldFile = new File(uploadPath + File.separator + oldFileName);
                File newFile = new File(uploadPath + File.separator + newFileName);

                if (oldFile.renameTo(newFile)) {
                    // Update the database with the new filename
                    String updateSQL = "UPDATE product SET productImageURL = ? WHERE productId = ?";
                    PreparedStatement updatePst = con.prepareStatement(updateSQL);
                    updatePst.setString(1, "img/" + newFileName);
                    updatePst.setInt(2, productId);
                    updatePst.executeUpdate();
                    updatePst.close();
                }
            }
        }

        response.sendRedirect("manageProducts.jsp?success=" + java.net.URLEncoder.encode("Product added successfully!", "UTF-8"));
    } else {
        response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Failed to add product", "UTF-8"));
    }

} catch (SQLException e) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
} catch (ClassNotFoundException e) {
    response.sendRedirect("manageProducts.jsp?error=" + java.net.URLEncoder.encode("Driver error", "UTF-8"));
} finally {
    try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception e) { }
    try { if (pst != null) pst.close(); } catch (Exception e) { }
    try { if (con != null) con.close(); } catch (Exception e) { }
}
%>
