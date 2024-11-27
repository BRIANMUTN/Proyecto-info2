// Variables del juego
int tankPos = 7;           // Posición inicial del tanque
int bulletPos = -1;        // Posición de la bala (-1 indica que no hay bala en pantalla)
int obstaclePos[2] = {4, 11}; // Obstáculos iniciales
int obstacleRow = 0;       // Fila de los obstáculos (0: fila superior, 1: fila inferior)
bool gameOver = false;     // Estado del juego

// Pines de los botones
const int leftButton = 2;
const int rightButton = 3;

void setup() {
  pinMode(leftButton, INPUT_PULLUP);
  pinMode(rightButton, INPUT_PULLUP);

  Serial.begin(9600);
}

void loop() {
  if (gameOver) {
    Serial.println("GAMEOVER");
    delay(2000);
    resetGame();
    return;
  }

  // Actualizar el juego
  updateGame();

  // Enviar datos del juego a Processing
  sendGameData();

  // Controlar los botones
  if (digitalRead(leftButton) == LOW && tankPos > 0) {
    tankPos--;
  } else if (digitalRead(rightButton) == LOW && tankPos < 15) {
    tankPos++;
  }

  delay(200); // Control de velocidad del juego
}

void updateGame() {
  // Mover la bala hacia arriba
  if (bulletPos >= 0) {
    bulletPos--;
  }

  // Mover obstáculos hacia abajo
  obstacleRow = (obstacleRow + 1) % 2;

  // Verificar colisiones
  for (int i = 0; i < 2; i++) {
    if (obstacleRow == 1 && obstaclePos[i] == tankPos) {
      gameOver = true; // El tanque es golpeado
    }
    if (bulletPos == 0 && obstaclePos[i] == tankPos) {
      obstaclePos[i] = random(0, 16); // Obstáculo destruido
      bulletPos = -1;                 // Bala desaparece
    }
  }

  // Generar nuevos obstáculos al azar
  for (int i = 0; i < 2; i++) {
    if (obstacleRow == 0 && random(0, 10) > 8) {
      obstaclePos[i] = random(0, 16);
    }
  }

  // Generar una nueva bala si no hay ninguna
  if (bulletPos < 0) {
    bulletPos = 1; // Aparece una nueva bala en la fila del tanque
  }
}

void sendGameData() {
  Serial.print("TANK,");
  Serial.print(tankPos);
  Serial.print(";BULLET,");
  Serial.print(bulletPos);
  Serial.print(";OBSTACLES,");
  Serial.print(obstaclePos[0]);
  Serial.print(",");
  Serial.print(obstaclePos[1]);
  Serial.print(",");
  Serial.println(obstacleRow);
}

void resetGame() {
  tankPos = 7;
  bulletPos = -1;
  obstaclePos[0] = 4;
  obstaclePos[1] = 11;
  obstacleRow = 0;
  gameOver = false;
}
