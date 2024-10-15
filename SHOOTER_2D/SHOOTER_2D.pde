float playerX, playerY;
float bulletX, bulletY;

void setup() {
  size(400, 400);
  playerX = width/2;
  playerY = height/2;
}

void draw() {
  background(255);
  
  // mover al jugador con las flechas
  if (keyPressed) {
    if (keyCode == LEFT) {
      playerX -= 5;
    } else if (keyCode == RIGHT) {
      playerX += 5;
    } else if (keyCode == UP) {
      playerY -= 5;
    } else if (keyCode == DOWN) {
      playerY += 5;
    }
  }
  
  // player
  ellipse(playerX, playerY, 20, 20);
  
  // bala
  ellipse(bulletX, bulletY, 10, 10);
}
