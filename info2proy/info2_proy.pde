import processing.serial.*;

Serial myPort;
String receivedData = "";

int tankPos = 7;
int bulletPos = -1;
int[] obstaclePos = {4, 11};
int obstacleRow = 0;
boolean gameOver = false;

void setup() {
  size(400, 200);

  // Listar todos los puertos seriales disponibles
  println(Serial.list());

  // Seleccionar el puerto correspondiente a tu Arduino
  String portName = Serial.list()[1]; // Reemplaza 0 con el índice del puerto correcto
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  textSize(32);
}

void draw() {
  background(0);
  fill(255);

  if (gameOver) {
    text("Game Over!", 100, 100);
    delay(2000); // Pausar para mostrar el mensaje de game over
    resetGame(); // Reiniciar el juego
    return;
  }

  // Dibujar obstáculos
  for (int i = 0; i < 2; i++) {
    ellipse(obstaclePos[i] * 25 + 12.5, obstacleRow * 100 + 25, 20, 20); // Ajuste de posición en base a escala
  }

  // Dibujar bala
  if (bulletPos >= 0) {
    rect(tankPos * 25 + 10, bulletPos * 25, 5, 10); // Ajuste de posición en base a escala
  }

  // Dibujar tanque
  rect(tankPos * 25 + 10, 175, 10, 10); // Ajuste de posición en base a escala
}

void serialEvent(Serial p) {
  receivedData = p.readStringUntil('\n').trim();
  println("Datos recibidos: " + receivedData); // Línea de depuración para ver los datos recibidos
  if (receivedData.equals("GAMEOVER")) {
    gameOver = true;
  } else {
    parseGameData(receivedData);
  }
}

void parseGameData(String data) {
  println("Parsing data: " + data); // Línea de depuración para ver los datos que se están parseando
  String[] parts = data.split(";");
  for (String part : parts) {
    String[] pair = part.split(",");
    if (pair[0].equals("TANK")) {
      tankPos = int(pair[1]);
    } else if (pair[0].equals("BULLET")) {
      bulletPos = int(pair[1]);
    } else if (pair[0].equals("OBSTACLES")) {
      obstaclePos[0] = int(pair[1]);
      obstaclePos[1] = int(pair[2]);
      obstacleRow = int(pair[3]);
    }
  }
}

void resetGame() {
  // Reiniciar variables del juego
  tankPos = 7;
  bulletPos = -1;
  obstaclePos[0] = 4;
  obstaclePos[1] = 11;
  obstacleRow = 0;
  gameOver = false;
  println("Juego reiniciado");
}
