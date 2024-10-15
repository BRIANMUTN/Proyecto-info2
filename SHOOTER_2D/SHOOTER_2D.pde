float playerX, playerY;
float bulletX, bulletY;
ArrayList<Bullet> bullets;

void setup() {
  size(400, 400);
  playerX = width/2;
  playerY = height/2;
  bullets = new ArrayList<Bullet>();
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
  // disparar al presionar tecla espacio
  if (keyPressed && keyCode == 32) {
    bullets.add(new Bullet(playerX, playerY));
  }
  // dibujo y movimiento de balas
  for (int i = bullets.size()-1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.show();
  // eliminar balas fuera de pantallla
    if (b.y < 0) {
      bullets.remove(i);
    }
  }
    // dibuja a player
  ellipse(playerX, playerY, 20, 20);
}
    class Bullet {
  float x, y;
  Bullet(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void update() {
    y -= 5;
  }
  
  void show() {
    // color de balas (negro en este caso)
    fill(0);
    ellipse(x, y, 5, 5);
  }
}
