# The Cursed & Blessed Emporium


##  Quick Start

### Step 1: Start Docker
```powershell
docker-compose up -d
```

### Step 2: Apply Database Theme
```powershell
.\apply_cursed_store_update.ps1
```

### Step 3: Add Character Images
Place these images in `WebContent/img/`:
- `satan.png` - Satan from South Park
- `ramond.png` - Ramond the Angel

### Step 4: Access Your Store
Visit: **http://localhost:8080/shop/**

##  Documentation

Documentation files are located in `../claude/` directory:

| File | Description |
|------|-------------|
| **QUICK_START.md** | Fast 3-step setup guide |
| **SETUP_CURSED_STORE.md** | Detailed setup instructions |
| **FEATURES_IMPLEMENTED.md** | Original feature list |
| **IMPLEMENTED_FEATURES_STATUS.md** | Current status with 46+ points documented |
| **CHANGES_SUMMARY.md** | All changes made to the project |
| **IMAGE_ASSIGNMENTS.md** | Product image reference guide |
| **apply_cursed_store_update.ps1** | PowerShell automation script (in project root) |

##  Features (46+ Points)

### Search/Browse Products (10 points)
- ✅ Search for a product by name (Core - 1 point)
- ✅ Browse products by category (Core - 1 point)
- ✅ List products (Core - 1 point)
- ✅ List products with image (Core - 1 point)
- ✅ Page header with menu and logged-in user display (Basic - 2 points)
- ✅ Dynamic products on homepage based on sales (Basic - 2 points)
- ✅ Improved UI with professional styling (Basic - 2 points)

### Shopping Cart (5 points)
- ✅ Add to shopping cart (Core - 1 point)
- ✅ View shopping cart (Core - 1 point)
- ✅ Update quantity with data validation (Basic - 1 point)
- ✅ Remove item from shopping cart (Basic - 1 point)
- ✅ Improved formatting/UI in cart (Basic - 1 point)

### Checkout (1 point)
- ✅ Checkout with customer ID and password (Core - 1 point)

### Product Detail Page (2 points)
- ✅ Product detail page with descriptions (Core - 1 point)
- ✅ Product detail has image from database (Core - 1 point)

### User Accounts/Login (8 points)
- ✅ Create user account page with full form (Basic - 2 points)
- ✅ Create account with JavaScript + server validation (Basic - 2 points)
- ✅ Edit user account info (address, password) (Basic - 2 points)
- ✅ Login/logout functionality (Core - 1 point)
- ✅ Page listing all orders for logged in user (Basic - 1 point)

### Administrator Portal (9 points)
- ✅ Secured by login (Core - 1 point)
- ✅ List all customers with search (Basic - 1 point)
- ✅ List report showing total sales/orders (Basic - 1 point)
- ✅ Add new product (Basic - 2 points)
- ✅ Delete product with validation (Basic - 2 points)
- ✅ Change order status/ship order (Basic - 1 point)
- ✅ Database restore with SQL script (Core - 1 point)

### Warehouses/Inventory (2 points)
- ✅ Display item inventory by store/warehouse (Basic - 2 points)

### General/Advanced (4 points)
- ✅ JavaScript validation for registration and edit profile (Advanced - 4 points)

### UI/UX
- ✅ Dark themed interface with gradient backgrounds
- ✅ Centralized CSS (`cursed-blessed-theme.css`)
- ✅ Character explanations (Satan & Ramond)
- ✅ Responsive navigation header on all pages
- ✅ Professional styling and hover effects

### Technical
- ✅ PreparedStatements (SQL injection prevention)
- ✅ Transaction management with rollback
- ✅ Multi-source image handling
- ✅ Session-based cart
- ✅ Comprehensive error handling

## 🛍️ Products

**22 Themed Products:**
-  8 Cursed Items ($44-$133)
-  8 Blessed Items ($149-$499)
-  2 Forbidden Artifacts ($123-$666)
- ✨ 2 Divine Relics ($88-$99)
## 🧪 Test Accounts

| Username | Password | Customer ID |
|----------|----------|-------------|
| arnold | 304Arnold! | 1 |
| bobby | 304Bobby! | 2 |
| candace | 304Candace! | 3 |

## 📁 Project Structure

```
304_lab7_starter_java/
├── WebContent/
│   ├── *.jsp                 # All JSP pages (themed)
│   ├── css/
│   │   └── cursed-blessed-theme.css  # Centralized styling
│   ├── img/                  # Product images
│   │   ├── satan.png        # (Add this)
│   │   └── ramond.png       # (Add this)
│   ├── ddl/
│   │   ├── SQLServer_orderdb.ddl          # Original schema
│   │   └── cursed_blessed_items_update.sql # Themed products
│   └── WEB-INF/
├── docker-compose.yml
├── Dockerfile
└── README.md (this file)
```
