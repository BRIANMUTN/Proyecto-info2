// Variables globales
float playerX, playerY;
float enemyX, enemyY;
float bulletX, bulletY;

void setup() {
  size(400, 400);
}

void draw() {
  background(255);
  
  // player
  ellipse(playerX, playerY, 20, 20);
  
  // enemigo
  ellipse(enemyX, enemyY, 20, 20);
  
  // bala
  ellipse(bulletX, bulletY, 10, 10);
  
  // mover enemigo
  enemyX += 1;
  
  // comprobar colision
  if (dist(playerX, playerY, enemyX, enemyY) < 20) {
    // game over
  }
}
