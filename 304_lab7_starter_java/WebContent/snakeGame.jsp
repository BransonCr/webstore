<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%
// Calculate cart total
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
double cartTotal = 0.0;
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

if (productList != null) {
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
    while (iterator.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
        ArrayList<Object> product = entry.getValue();
        if (product.size() >= 4) {
            try {
                double price = Double.parseDouble(product.get(2).toString());
                int qty = product.get(3) instanceof Integer ?
                    ((Integer)product.get(3)).intValue() :
                    Integer.parseInt(product.get(3).toString());
                cartTotal += price * qty;
            } catch (Exception e) {
                // Skip invalid items
            }
        }
    }
}

String cartTotalStr = currFormat.format(cartTotal);
double winTotal = cartTotal * 0.95;
double loseTotal = cartTotal * 1.5;
String winTotalStr = currFormat.format(winTotal);
String loseTotalStr = currFormat.format(loseTotal);
%>
<!DOCTYPE html>
<html>
<head>
<title>Battle South Park Satan for a Discount! - Cursed & Blessed Emporium</title>
<link rel="stylesheet" href="css/cursed-blessed-theme.css">
<style>
body {
    font-family: Georgia, serif;
    background: linear-gradient(to bottom, #1a0000 0%, #4a0000 50%, #000033 100%);
    color: #ffcccc;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20px;
}

.game-container {
    background: rgba(0, 0, 0, 0.8);
    border: 3px solid #ff3333;
    border-radius: 15px;
    padding: 30px;
    box-shadow: 0 0 30px rgba(255, 51, 51, 0.5);
    max-width: 800px;
}

h1 {
    color: #ff3333;
    text-shadow: 0 0 15px #ff0000;
    text-align: center;
}

#gameCanvas {
    border: 3px solid #ff6666;
    background: #000000;
    display: block;
    margin: 20px auto;
    box-shadow: 0 0 20px rgba(255, 102, 102, 0.3);
}

.info {
    display: flex;
    justify-content: space-around;
    margin: 20px 0;
    font-size: 1.2em;
}

.score {
    color: #ff6666;
    font-weight: bold;
}

.instructions {
    background: rgba(102, 0, 0, 0.3);
    padding: 15px;
    border-left: 5px solid #ff3333;
    margin: 20px 0;
}

.btn {
    background: #660000;
    color: #ffcc99;
    border: 2px solid #ff6666;
    padding: 12px 30px;
    font-size: 1.1em;
    cursor: pointer;
    border-radius: 8px;
    margin: 10px;
    transition: all 0.3s;
}

.btn:hover {
    background: #ff6666;
    color: #000;
    transform: scale(1.05);
}

.satan-quote {
    text-align: center;
    font-style: italic;
    color: #ff9999;
    margin: 20px 0;
    font-size: 1.1em;
}

.game-over {
    text-align: center;
    margin: 20px 0;
}

#result {
    font-size: 1.5em;
    font-weight: bold;
    margin: 20px 0;
}
</style>
</head>
<body>

<div class="game-container">
    <h1>🔥 Battle South Park Devil for a Discount! 🐍</h1>

    <div class="satan-quote">
        <p>"Hey there, mortal! Think you can beat me at my own game? Eat 10 cursed apples and I'll give you a 5% discount (maybe). But if you lose... HAHAHAHA... your total increases by 50%! Your move you chubby chicken!!!"</p>
    </div>

    <!-- Price Stakes Display -->
    <div style="background: rgba(0, 0, 0, 0.6); padding: 15px; border-radius: 10px; margin: 20px 0; text-align: center;">
        <div style="font-size: 1.2em; margin-bottom: 10px;">
            <strong style="color: #ffcc99;">Current Cart Total: <span style="color: #ff9999;"><%= cartTotalStr %></span></strong>
        </div>
        <div style="display: flex; justify-content: space-around; margin-top: 10px;">
            <div style="flex: 1; padding: 10px;">
                <div style="color: #66ff66; font-weight: bold;">🎉 IF YOU WIN:</div>
                <div style="font-size: 1.3em; color: #66ff66;"><%= winTotalStr %></div>
                <div style="font-size: 0.9em; color: #99ff99;">(5% discount)</div>
            </div>
            <div style="flex: 1; padding: 10px;">
                <div style="color: #ff6666; font-weight: bold;">💀 IF YOU LOSE:</div>
                <div style="font-size: 1.3em; color: #ff6666;"><%= loseTotalStr %></div>
                <div style="font-size: 0.9em; color: #ff9999;">(50% penalty)</div>
            </div>
        </div>
    </div>

    <div class="info">
        <div>Score: <span class="score" id="score">0</span></div>
        <div>Target: <span class="score">10</span></div>
        <div>Lives: <span class="score" id="lives">3</span></div>
    </div>

    <canvas id="gameCanvas" width="600" height="400"></canvas>

    <div class="instructions">
        <h3 style="color: #ff6666;">How to Play:</h3>
        <ul>
            <li>Use <strong>Arrow Keys</strong> to control the snake</li>
            <li>Eat the <strong style="color: #ff3333;">🍎 cursed apples</strong> to grow</li>
            <li>Reach <strong>10 points</strong> to win a 5% discount!</li>
            <li>Don't hit the walls or yourself</li>
            <li>You have <strong>3 lives</strong> - use them wisely!</li>
        </ul>
    </div>

    <div class="game-over" id="gameOver" style="display: none;">
        <div id="result"></div>
        <button class="btn" onclick="location.href='checkout.jsp'">Return to Checkout</button>
    </div>

    <div style="text-align: center;">
        <button class="btn" onclick="startGame()">Start Game</button>
        <button class="btn" onclick="location.href='checkout.jsp'">Cancel</button>
    </div>
</div>
<script>
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

const gridSize = 20;
const tileCountX = canvas.width  / gridSize; // 30 for 600px width
const tileCountY = canvas.height / gridSize; // 20 for 400px height

let snake = [{x: 10, y: 10}];
let dx = 0;
let dy = 0;
let foodX = 15;
let foodY = 15;
let score = 0;
let lives = 3;
let gameRunning = false;
let gameInterval;
let gameSpeed = 100;

function startGame() {
    snake = [{x: 10, y: 10}];
    dx = 1;
    dy = 0;
    score = 0;
    lives = 3;
    gameRunning = true;

    document.getElementById('score').textContent = score;
    document.getElementById('lives').textContent = lives;
    document.getElementById('gameOver').style.display = 'none';

    placeFood();

    if (gameInterval) clearInterval(gameInterval);
    gameInterval = setInterval(gameLoop, gameSpeed);
}

function gameLoop() {
    if (!gameRunning) return;

    update();
    draw();
}

function update() {
    // Move snake
    const head = {x: snake[0].x + dx, y: snake[0].y + dy};

    // Check wall collision — use tileCountX / tileCountY
    if (head.x < 0 || head.x >= tileCountX || head.y < 0 || head.y >= tileCountY) {
        handleDeath();
        return;
    }
    
    // Check self collision
    for (let i = 0; i < snake.length; i++) {
        if (head.x === snake[i].x && head.y === snake[i].y) {
            handleDeath();
            return;
        }
    }

    snake.unshift(head);

    // Check food collision
    if (head.x === foodX && head.y === foodY) {
        score++;
        document.getElementById('score').textContent = score;
        placeFood();
        
        // Increase speed slightly
        if (score % 3 === 0) {
            gameSpeed = Math.max(100, gameSpeed + 5);
            clearInterval(gameInterval);
            gameInterval = setInterval(gameLoop, gameSpeed);
        }

        // Check win condition
        if (score >= 10) {
            winGame();
            return;
        }
    } else {
        snake.pop();
    }
    if(score == 9){
        gameSpeed = Math.max(35);
        clearInterval(gameInterval);
        gameInterval = setInterval(gameLoop, gameSpeed);
    }
}

function handleDeath() {
    lives--;
    document.getElementById('lives').textContent = lives;

    if (lives <= 0) {
        loseGame();
    } else {
        // Reset snake position but keep score
        snake = [{x: 10, y: 10}];
        dx = 1;
        dy = 0;
        placeFood();
    }
}

function draw() {
    // Clear canvas
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Draw vertical grid lines (use tileCountX)
    ctx.strokeStyle = '#1a1a1a';
    for (let i = 0; i < tileCountX; i++) {
        ctx.beginPath();
        ctx.moveTo(i * gridSize, 0);
        ctx.lineTo(i * gridSize, canvas.height);
        ctx.stroke();
    }
    // Draw horizontal grid lines (use tileCountY)
    for (let j = 0; j < tileCountY; j++) {
        ctx.beginPath();
        ctx.moveTo(0, j * gridSize);
        ctx.lineTo(canvas.width, j * gridSize);
        ctx.stroke();
    }

    // Draw snake
    snake.forEach((segment, index) => {
        if (index === 0) {
            // Head
            ctx.fillStyle = '#ff3333';
        } else {
            // Body - gradient from red to dark red
            const intensity = 255 - (index * 10);
            ctx.fillStyle = `rgb(${Math.max(100, intensity)}, 0, 0)`;
        }
        ctx.fillRect(segment.x * gridSize, segment.y * gridSize, gridSize - 2, gridSize - 2);

        // Eyes on head
        if (index === 0) {
            ctx.fillStyle = '#ffff00';
            ctx.fillRect(segment.x * gridSize + 5, segment.y * gridSize + 5, 3, 3);
            ctx.fillRect(segment.x * gridSize + 12, segment.y * gridSize + 5, 3, 3);
        }
    });

    // Draw food (apple emoji)
    // Slightly reduce font so emoji fits the tile
    ctx.font = `${Math.max(12, gridSize - 6)}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    // Add a subtle glow effect to the apple
    ctx.shadowColor = '#ff0000';
    ctx.shadowBlur = 5;
    ctx.fillText('🍎', foodX * gridSize + gridSize/2, foodY * gridSize + gridSize/2);
    ctx.shadowBlur = 0;

    // Reset text alignment
    ctx.textAlign = 'left';
    ctx.textBaseline = 'alphabetic';
}

function placeFood() {
    let validPosition = false;
    let attempts = 0;
    const maxAttempts = 200;

    while (!validPosition && attempts < maxAttempts) {
        foodX = Math.floor(Math.random() * tileCountX);
        foodY = Math.floor(Math.random() * tileCountY);

        // Check if position is valid (not on snake)
        validPosition = true;
        for (let segment of snake) {
            if (segment.x === foodX && segment.y === foodY) {
                validPosition = false;
                break;
            }
        }
        attempts++;
    }

    // If random attempts failed, pick a free tile deterministically
    if (!validPosition) {
        const freeTiles = [];
        for (let x = 0; x < tileCountX; x++) {
            for (let y = 0; y < tileCountY; y++) {
                let occupied = false;
                for (let segment of snake) {
                    if (segment.x === x && segment.y === y) {
                        occupied = true;
                        break;
                    }
                }
                if (!occupied) freeTiles.push({x, y});
            }
        }
        if (freeTiles.length > 0) {
            const pick = freeTiles[Math.floor(Math.random() * freeTiles.length)];
            foodX = pick.x;
            foodY = pick.y;
            validPosition = true;
        } else {
            // Board is full (unlikely) — keep food at head+offset clamped
            foodX = Math.min(tileCountX - 1, Math.max(0, snake[0].x + 2));
            foodY = Math.min(tileCountY - 1, Math.max(0, snake[0].y + 2));
            validPosition = true;
        }
    }

    console.log(`Food placed at (${foodX}, ${foodY})`);
}

function winGame() {
    gameRunning = false;
    clearInterval(gameInterval);

    // Set discount in session
    fetch('setDiscount.jsp?discount=0.95')
        .then(() => {
            document.getElementById('gameOver').style.display = 'block';
            document.getElementById('result').innerHTML =
                '<span style="color: #66ff66;">🎉 YOU WIN! 🎉</span><br>' +
                'Satan is impressed! You\'ve earned a 5% discount on your order!<br>' +
                '<span style="font-size: 0.9em; color: #ff9999;">"Well played, mortal... I suppose you\'ve earned it!"</span>';
        });
}

function loseGame() {
    gameRunning = false;
    clearInterval(gameInterval);

    // Set penalty in session
    fetch('setDiscount.jsp?discount=1.5')
        .then(() => {
            document.getElementById('gameOver').style.display = 'block';
            document.getElementById('result').innerHTML =
                '<span style="color: #ff3333;">💀 YOU LOSE! 💀</span><br>' +
                'Satan laughs maniacally! Your order total just increased by 50%!<br>' +
                '<span style="font-size: 0.9em; color: #ff9999;">"HAHAHA! Better luck next time, mortal!"</span>';
        });
}

// Keyboard controls
document.addEventListener('keydown', (e) => {
    if (!gameRunning) return;

    switch(e.key) {
        case 'ArrowUp':
            if (dy === 0) { dx = 0; dy = -1; }
            break;
        case 'ArrowDown':
            if (dy === 0) { dx = 0; dy = 1; }
            break;
        case 'ArrowLeft':
            if (dx === 0) { dx = -1; dy = 0; }
            break;
        case 'ArrowRight':
            if (dx === 0) { dx = 1; dy = 0; }
            break;
    }
    e.preventDefault();
});

// Initial draw
draw();
</script>


</body>
</html>
