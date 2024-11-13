// Mario Position and Physics
int marioX = 100;
int marioY = 300;
int baseY = 300;
int velocityY = 0;
int gravity = 1;
boolean onGround = true;
int score = 0;

// Mario dimensions
int marioWidth = 20;
int marioHeight = 30;

// Pipe dimensions
int pipeWidth = 40;
int pipeHeight = 50;

// Animation Frames for Mario
PImage[] marioFrames;
int marioFrameIndex = 0;
int frameDelay = 10;
int frameCount = 0;

// Coin position and collection status
int[] coinX = {300, 500, 700, 900};
int[] coinY = {250, 200, 250, 250};
boolean[] coinsCollected = {false, false, false, false};

// Obstacles (Pipes)
int[] pipeX = {400, 800};
int[] pipeY = {baseY - 150, baseY - 50};

// Enemy
int enemyX = 600;
int enemyY = baseY - 35;
int enemySpeed = 2;
boolean gameOver = false;

// Variables for background transition
float timeOfDay = 0;  // Value to track the time of day (0 - 1 range)
float sunX, sunY, moonX, moonY;

// Cloud properties
float[] cloudX = {200, 600, 900};
float[] cloudY = {100, 150, 75};

// Rain properties
boolean isRaining = false;
int rainTimer = 0;
ArrayList<PVector> raindrops = new ArrayList<PVector>();

void setup() {
  size(1000, 400);
  marioFrames = new PImage[2];
  marioFrames[0] = loadImage("mario_stand.png"); // Placeholder images
  marioFrames[1] = loadImage("mario_run.png");
}

void draw() {
  // Update time of day for continuous day-night cycle
  timeOfDay += 0.001;
  if (timeOfDay > 1) {
    timeOfDay = 0;
  }

  // Check for rain activation
  updateRain();
  
  drawBackground();
  drawGround();
  if (!gameOver) {
    handlePhysics();
    handleAnimation();
    drawPipes();
    drawCoins();
    drawMario();
    drawEnemy();
    checkKeys();
    checkCollisions();
    displayScore();
  } else {
    displayGameOver();
  }
}

// Draws the animated background with changing sky, sun, moon, clouds, hills, and trees
void drawBackground() {
  drawGradientSky();  // Draws the gradient sky

  // Sun position (morning to afternoon)
  if (timeOfDay < 0.5) {
    sunX = map(timeOfDay, 0, 0.5, 0, width);
    sunY = map(timeOfDay, 0, 0.5, height, 100);
    drawSun(sunX, sunY);
  }

  // Moon position (afternoon to night)
  if (timeOfDay >= 0.5) {
    moonX = map(timeOfDay, 0.5, 1, 0, width);
    moonY = map(timeOfDay, 0.5, 1, height, 100);
    drawMoon(moonX, moonY);
  }

  // Stars in the night sky
  if (timeOfDay >= 0.75 || timeOfDay < 0.25) {
    drawStars();
  }

  // Draw other background elements
  drawClouds();
  drawTrees();
  drawHills();
  

  // Draw rain if active
  if (isRaining) {
    drawRain();
  }
}

// Draws a gradient sky based on the time of day
void drawGradientSky() {
  for (int i = 0; i < height; i++) {
    float r, g, b;
    if (timeOfDay < 0.5) { // Morning to afternoon
      r = map(timeOfDay, 0, 0.5, 135, 255);
      g = map(timeOfDay, 0, 0.5, 206, 204);
      b = map(timeOfDay, 0, 0.5, 250, 255);
    } else { // Afternoon to night
      r = map(timeOfDay, 0.5, 1, 255, 25);
      g = map(timeOfDay, 0.5, 1, 204, 25);
      b = map(timeOfDay, 0.5, 1, 255, 112);
    }
    stroke(r, g, b);
    line(0, i, width, i);
  }
}

// Draws the moon with craters
void drawMoon(float x, float y) {
  fill(240, 240, 255);
  noStroke();
  ellipse(x, y, 40, 40);

  fill(220, 220, 235);
  ellipse(x + 10, y - 10, 8, 8);
  ellipse(x - 10, y + 5, 5, 5);
  ellipse(x + 5, y + 10, 4, 4);
}

// Draws stars in the night sky
void drawStars() {
  fill(255, 255, 255, 200);
  noStroke();
  for (int i = 0; i < 50; i++) {
    float starX = random(width);
    float starY = random(height / 2);
    ellipse(starX, starY, 2, 2);
  }
}

// Draws the sun with a glow effect and rays
void drawSun(float x, float y) {
  noStroke();  // Ensure no outlines for sun glow

  // Sun glow with concentric circles for a radiant effect
  for (int i = 100; i > 0; i -= 20) {
    fill(255, 204, 0, map(i, 0, 100, 0, 100));
    ellipse(x, y, i, i);
  }

  // Sun rays
  stroke(255, 204, 0, 150);
  strokeWeight(2);
  for (int angle = 0; angle < 360; angle += 20) {
    float rayX = x + cos(radians(angle)) * 60;
    float rayY = y + sin(radians(angle)) * 60;
    line(x, y, rayX, rayY);
  }

  // Clear stroke settings after sun is drawn
  noStroke();
}

// Draws moving clouds without a border
void drawClouds() {
  fill(255);  // White color for clouds
  noStroke(); // Ensure no border on clouds

  for (int i = 0; i < cloudX.length; i++) {
    ellipse(cloudX[i], cloudY[i], 60, 40);
    ellipse(cloudX[i] + 30, cloudY[i] + 10, 50, 30);
    ellipse(cloudX[i] - 30, cloudY[i] + 10, 50, 30);
    cloudX[i] += 0.5;
    if (cloudX[i] > width + 60) {
      cloudX[i] = -60;
    }
  }
}


// Draws hills on the background
void drawHills() {
  fill(34, 139, 34);
  noStroke();
  ellipse(200, baseY + 80, 300, 200);
  ellipse(800, baseY + 90, 400, 250);
}

// Draws trees on the background
void drawTrees() {
  for (int i = 100; i < width; i += 300) {
    fill(139, 69, 19);
    rect(i, baseY + 30, 20, 50);

    fill(34, 139, 34);
    ellipse(i + 10, baseY + 20, 60, 60);
    ellipse(i - 15, baseY + 40, 60, 60);
    ellipse(i + 35, baseY + 40, 60, 60);
  }
}

// Updates the rain status
void updateRain() {
  if (!isRaining && random(1) < 0.01) { // Small chance to start rain
    isRaining = true;
    rainTimer = 500; // Rain duration
  }
  if (isRaining) {
    rainTimer--;
    if (rainTimer <= 0) {
      isRaining = false;
      raindrops.clear(); // Clear raindrops when rain stops
    } else {
      // Add new raindrops
      for (int i = 0; i < 10; i++) {
        raindrops.add(new PVector(random(width), random(-10, 0)));
      }
    }
  }
}

// Draws rain
void drawRain() {
  stroke(173, 216, 230); // Light blue color for rain
  strokeWeight(2);
  for (int i = raindrops.size() - 1; i >= 0; i--) {
    PVector drop = raindrops.get(i);
    line(drop.x, drop.y, drop.x, drop.y + 10);
    drop.y += 10;
    if (drop.y > height) {
      raindrops.remove(i);
    }
  }
  noStroke();
}

// Draws the ground with grass and dirt texture
void drawGround() {
  fill(34, 139, 34);
  rect(0, baseY + 40, width, 10);

  for (int i = 0; i < width; i += 10) {
    fill(0, 128, 0);
    triangle(i, baseY + 40, i + 5, baseY + 30, i + 10, baseY + 40);
  }

  fill(139, 69, 19);
  rect(0, baseY + 50, width, height - (baseY + 50));

  fill(160, 82, 45);
  for (int i = 10; i < width; i += 30) {
    ellipse(i, baseY + 70, 8, 8);
    ellipse(i + 15, baseY + 90, 6, 6);
    ellipse(i + 30, baseY + 110, 10, 10);
  }
}

// Draws Mario with animation frames
void drawMario() {
  image(marioFrames[marioFrameIndex], marioX, marioY, 30, 40);
}

// Changes Mario's animation frame to create a running effect
void handleAnimation() {
  if (frameCount % frameDelay == 0) {
    marioFrameIndex = (marioFrameIndex + 1) % marioFrames.length;
  }
  frameCount++;
}


void drawPipes() {
  for (int i = 0; i < pipeX.length; i++) {
    drawSilveryPipeWithSpikes(pipeX[i], pipeY[i]);
  }
}

// Draws a silvery pipe with spikes on top
void drawSilveryPipeWithSpikes(int x, int y) {
  // Draw the silvery pipe body with a gradient
  for (int i = 0; i < pipeWidth; i += 4) {
    int shade = (int) map(i, 0, pipeWidth, 200, 100); // Gradient from light to dark gray
    fill(shade, shade, shade); // Silvery gradient color
    rect(x + i, y, 4, pipeHeight);
  }

  // Draw a slightly darker top section for the pipe
  fill(150);
  rect(x, y - 10, pipeWidth, 10);

  // Draw spikes on the top of the pipe
  fill(169, 169, 169); // Dark gray color for spikes
  int spikeWidth = 8;
  int spikeHeight = 10;
  for (int i = 0; i < pipeWidth; i += spikeWidth) {
    triangle(x + i, y - 10, x + i + spikeWidth / 2, y - 10 - spikeHeight, x + i + spikeWidth, y - 10);
  }
}


void handlePhysics() {
  if (!onGround) {
    marioY += velocityY;
    velocityY += gravity;
  }
  if (marioY >= baseY) {
    marioY = baseY;
    onGround = true;
    velocityY = 0;
  }
}

void checkKeys() {
  if (keyPressed) {
    if (key == 'a' || key == 'A') {
      marioX -= 5;
    } else if (key == 'd' || key == 'D') {
      marioX += 5;
    }
  }
}

void keyPressed() {
  if ((key == 'w' || key == 'W') && onGround) {
    velocityY = -15;
    onGround = false;
  }
}

// Draw coins with animation and shine
void drawCoins() {
  for (int i = 0; i < coinX.length; i++) {
    if (!coinsCollected[i]) {
      drawAnimatedCoin(coinX[i], coinY[i]);
    }
  }
}

// Draws an animated golden coin with flipping and sparkle effects
void drawAnimatedCoin(float x, float y) {
  // Coin flipping animation by adjusting width
  float coinWidth = 20 + 10 * sin(frameCount * 0.1); // Width varies over time
  float coinHeight = 20;

  // Draw the golden coin with gradient shading
  for (int i = 10; i > 0; i--) {
    // Gradient from rich yellow to dark orange for a golden look
    int red = (int)map(i, 0, 10, 255, 204); // Redder tones in the middle
    int green = (int)map(i, 0, 10, 215, 140);
    int blue = (int)map(i, 0, 10, 0, 0); // Gold colors vary mostly in red and green
    fill(red, green, blue, map(i, 0, 10, 100, 255)); // Transparent outer layers for shading
    ellipse(x, y, coinWidth - i, coinHeight - i); // Concentric ellipses for depth
  }

  // Small shine effect on top-left for added realism
  fill(255, 255, 224, 200);  // Light yellow-white color for highlight
  ellipse(x - coinWidth / 4, y - coinHeight / 4, 6, 6); // Small highlight at top-left

  // Occasional sparkle effect
  if (random(1) < 0.05) {  // Low probability sparkle
    fill(255, 255, 255, 150);  // White glint
    ellipse(x + random(-5, 5), y + random(-5, 5), 5, 5);  // Small sparkle
  }
}

void drawEnemy() {
  fill(220, 20, 60); // Base color for the enemy
  ellipse(enemyX, enemyY, 30, 30); // Main body

  // Add eyes
  fill(255); // White of the eyes
  ellipse(enemyX - 5, enemyY - 5, 8, 8); // Left eye
  ellipse(enemyX + 5, enemyY - 5, 8, 8); // Right eye

  fill(0); // Pupil color
  ellipse(enemyX - 5, enemyY - 5, 4, 4); // Left pupil
  ellipse(enemyX + 5, enemyY - 5, 4, 4); // Right pupil

  // Add legs for walking effect
  stroke(220, 20, 60); // Match leg color to body color
  strokeWeight(3);
  line(enemyX - 8, enemyY + 15, enemyX - 10, enemyY + 20); // Left leg
  line(enemyX + 8, enemyY + 15, enemyX + 10, enemyY + 20); // Right leg
  noStroke();

  // Update position for enemy movement
  enemyX -= enemySpeed;
  if (enemyX < -30) {
    enemyX = width;
  }
}


void checkCollisions() {
  for (int i = 0; i < coinX.length; i++) {
    if (!coinsCollected[i] && dist(marioX, marioY, coinX[i], coinY[i]) < 30) {
      coinsCollected[i] = true;
      score += 10;
    }
  }

  // Check collision with pipes
  for (int i = 0; i < pipeX.length; i++) {
    if (marioX < pipeX[i] + pipeWidth && marioX + marioWidth > pipeX[i] && // Horizontal overlap
        marioY < pipeY[i] + pipeHeight && marioY + marioHeight > pipeY[i]) { // Vertical overlap
      // Collision detected, trigger game over
      gameOver = true;
    }
  }

  // Check collision with enemy
  if (dist(marioX, marioY, enemyX, enemyY) < 30) {
    gameOver = true;
  }
}

void displayScore() {
  fill(0);
  textSize(20);
  text("Score: " + score, 10, 30);
}

void displayGameOver() {
  fill(0);
  textSize(32);
  text("Game Over!", width / 2 - 100, height / 2);
  textSize(20);
  text("Press R to restart", width / 2 - 95, height / 2 + 40);
}

void keyReleased() {
  if (gameOver && (key == 'r' || key == 'R')) {
    resetGame();
  }
}

void resetGame() {
  marioX = 100;
  marioY = baseY;
  velocityY = 0;
  score = 0;
  for (int i = 0; i < coinsCollected.length; i++) {
    coinsCollected[i] = false;
  }
  gameOver = false;
}
