# PowerShell script to load Cursed & Blessed Emporium data via web interface

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Cursed & Blessed Emporium Database Update" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking if Docker containers are running..." -ForegroundColor Yellow
$containerRunning = docker ps --filter "name=cosc304-sqlserver" --format "{{.Names}}"

if (-not $containerRunning) {
    Write-Host "ERROR: SQL Server container is not running!" -ForegroundColor Red
    Write-Host "Please start your containers with: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "SUCCESS: SQL Server container is running" -ForegroundColor Green
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Opening browser to load data..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$url = "http://localhost:8080/shop/loadCursedData.jsp"

Write-Host "Visit this URL to load the data:" -ForegroundColor Yellow
Write-Host $url -ForegroundColor White
Write-Host ""
Write-Host "Opening in your default browser..." -ForegroundColor Yellow

Start-Process $url

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Browser opened!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "The page will:" -ForegroundColor Cyan
Write-Host "  1. Clear existing products" -ForegroundColor White
Write-Host "  2. Create 4 categories" -ForegroundColor White
Write-Host "  3. Add 22 themed products" -ForegroundColor White
Write-Host "  4. Set up inventory" -ForegroundColor White
Write-Host ""
Write-Host "After the page loads successfully:" -ForegroundColor Cyan
Write-Host "  - Click 'View Products' to see your store" -ForegroundColor White
Write-Host "  - Add satan.png and ramond.png to WebContent/img/" -ForegroundColor White
Write-Host ""
Write-Host "Your store will be The Cursed & Blessed Emporium!" -ForegroundColor Magenta
