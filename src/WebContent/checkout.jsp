<!DOCTYPE html>
<html>
<head>
<title>Checkout - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<script>
function validateForm() {
    // Validate credit card number (basic check for 16 digits)
    var cardNumber = document.forms["checkoutForm"]["cardNumber"].value;
    if (cardNumber.replace(/\s/g, '').length !== 16) {
        alert("Credit card number must be 16 digits");
        return false;
    }

    // Validate CVV (3 or 4 digits)
    var cvv = document.forms["checkoutForm"]["cvv"].value;
    if (cvv.length < 3 || cvv.length > 4) {
        alert("CVV must be 3 or 4 digits");
        return false;
    }

    // Validate expiry date (MM/YY format)
    var expiryDate = document.forms["checkoutForm"]["expiryDate"].value;
    if (!/^\d{2}\/\d{2}$/.test(expiryDate)) {
        alert("Expiry date must be in MM/YY format");
        return false;
    }

    return true;
}
</script>
</head>
<body>

<div class="container">
    <h1> Complete Your Order</h1>
    <p class="text-center" style="color: #ffcc99;">Enter your details to finalize your purchase of curses and blessings...</p>

    <form name="checkoutForm" method="get" action="order.jsp" onsubmit="return validateForm()">
        <table style="margin: 30px auto; max-width: 600px;">
            <tr>
                <td colspan="2" style="text-align: center; background: rgba(255,100,100,0.2); padding: 10px;">
                    <h3 style="margin: 5px;"> Customer Information</h3>
                </td>
            </tr>
            <tr>
                <td><label>Customer ID:</label></td>
                <td><input type="text" name="customerId" size="30" required placeholder="Enter your ID"></td>
            </tr>
            <tr>
                <td><label>Password:</label></td>
                <td><input type="password" name="password" size="30" required placeholder="Enter your password"></td>
            </tr>

            <tr>
                <td colspan="2" style="text-align: center; background: rgba(100,100,255,0.2); padding: 10px; padding-top: 20px;">
                    <h3 style="margin: 5px;"> Payment Information</h3>
                </td>
            </tr>
            <tr>
                <td><label>Payment Method:</label></td>
                <td>
                    <select name="paymentType" required>
                        <option value="">-- Select --</option>
                        <option value="Visa">Visa</option>
                        <option value="MasterCard">MasterCard</option>
                        <option value="American Express">American Express</option>
                        <option value="Discover">Discover</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td><label>Card Number:</label></td>
                <td><input type="text" name="cardNumber" size="30" required placeholder="1234 5678 9012 3456" maxlength="19"></td>
            </tr>
            <tr>
                <td><label>Expiry Date (MM/YY):</label></td>
                <td><input type="text" name="expiryDate" size="30" required placeholder="12/25" maxlength="5"></td>
            </tr>
            <tr>
                <td><label>CVV:</label></td>
                <td><input type="text" name="cvv" size="30" required placeholder="123" maxlength="4"></td>
            </tr>

            <tr>
                <td colspan="2" style="text-align: center; background: rgba(100,255,100,0.2); padding: 10px; padding-top: 20px;">
                    <h3 style="margin: 5px;"> Shipping Address</h3>
                </td>
            </tr>
            <tr>
                <td><label>Street Address:</label></td>
                <td><input type="text" name="shipAddress" size="30" required placeholder="123 Main St"></td>
            </tr>
            <tr>
                <td><label>City:</label></td>
                <td><input type="text" name="shipCity" size="30" required placeholder="Vancouver"></td>
            </tr>
            <tr>
                <td><label>State/Province:</label></td>
                <td><input type="text" name="shipState" size="30" required placeholder="BC"></td>
            </tr>
            <tr>
                <td><label>Postal Code:</label></td>
                <td><input type="text" name="shipPostalCode" size="30" required placeholder="V6T 1Z4"></td>
            </tr>
            <tr>
                <td><label>Country:</label></td>
                <td><input type="text" name="shipCountry" size="30" required placeholder="Canada"></td>
            </tr>

            <tr>
                <td colspan="2" style="text-align: center; padding-top: 20px;">
                    <input type="submit" value=" Complete Order" class="btn btn-primary">
                    <input type="reset" value=" Reset" class="btn btn-secondary">
                </td>
            </tr>
        </table>
    </form>

    <div class="info mt-3">
        <h3> Test Credentials</h3>
        <p>Customer ID: <strong>1</strong>, Password: <strong>304Arnold!</strong></p>
        <p>Test Card: <strong>4111 1111 1111 1111</strong>, CVV: <strong>123</strong>, Expiry: <strong>12/25</strong></p>
    </div>

    <!-- Satan's Challenge -->
    <div style="background: rgba(102, 0, 0, 0.4); border: 2px solid #ff3333; border-radius: 10px; padding: 20px; margin: 20px 0; text-align: center;">
        <h3 style="color: #ff3333; margin-top: 0;"> Satan's Special Challenge! </h3>
        <p style="color: #ffcc99; font-style: italic;">
            "Feeling lucky, mortal? Beat me in a game of Snake and earn a <strong style="color: #66ff66;">5% discount</strong>!<br>
            But lose... and your total goes up <strong style="color: #ff6666;">50%</strong>! Dare you accept?"
        </p>
        <%
        Double currentDiscount = (Double) session.getAttribute("satanDiscount");
        if (currentDiscount != null) {
            if (currentDiscount < 1.0) {
                out.println("<p style='color: #66ff66; font-weight: bold;'> Active Discount: 5% OFF!</p>");
            } else if (currentDiscount > 1.0) {
                out.println("<p style='color: #ff3333; font-weight: bold;'> Active Penalty: +50% to total!</p>");
            }
        }
        %>
        <a href="snakeGame.jsp" class="btn btn-primary" style="display: inline-block; margin-top: 10px;">
            Battle Satan for a Discount!
        </a>
        <%
        if (currentDiscount != null && currentDiscount != 1.0) {
            out.println("<br><a href='removeDiscount.jsp' style='color: #ffcc99; margin-top: 10px; display: inline-block;'>Remove current discount/penalty</a>");
        }
        %>
    </div>

    <p class="text-center mt-3">
        <a href="showcart.jsp"> Back to Cart</a> |
        <a href="listprod.jsp">Continue Shopping</a>
    </p>
</div>

</body>
</html>
