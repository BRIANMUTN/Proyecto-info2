import processing.serial.*;
import java.util.ArrayList;

Serial miPuerto;
int naveX;
int nave2X;
boolean segundoJugador;
boolean juegoTerminado;
int puntuacion;
int vidas;
int[] obstaculoX;
int[] obstaculoY;
int maxObstaculos = 10;
int[] balaX;
int[] balaY;
int[] bala2X;
int[] bala2Y;
int maxBalas = 30;
ArrayList<Explosion> explosiones; // Lista de explosiones
ArrayList<Colision> colisiones; // Lista de colisiones

void setup() {
  size(800, 600);
  frameRate(60); // Configurar la tasa de fotogramas a 60 fps
  miPuerto = new Serial(this, Serial.list()[1], 57600); // Ajuste del puerto
  obstaculoX = new int[maxObstaculos];
  obstaculoY = new int[maxObstaculos];
  balaX = new int[maxBalas];
  balaY = new int[maxBalas];
  bala2X = new int[maxBalas];
  bala2Y = new int[maxBalas];
  explosiones = new ArrayList<Explosion>(); // Inicializar lista de explosiones
  colisiones = new ArrayList<Colision>(); // Inicializar lista de colisiones
  puntuacion = 0;
  vidas = 5;
}

void draw() {
  background(0);
  if (miPuerto.available() > 0) {
    String val = miPuerto.readStringUntil('\n');
    if (val != null) {
      val = val.trim();
      if (val.startsWith("NAVES")) {
        String[] datos = val.split(" \\| ");
        if (datos.length == 4) {
          String[] datosNave = datos[0].split(" ");
          if (datosNave.length >= 7) {
            naveX = int(datosNave[1]);
            nave2X = int(datosNave[2]);
            segundoJugador = datosNave[3].equals("1");
            juegoTerminado = datosNave[4].equals("1");
            puntuacion = int(datosNave[5]);
            vidas = int(datosNave[6]);
          }

          String[] datosObstaculos = datos[1].split(" ");
          for (int i = 0; i < maxObstaculos; i++) {
            if (2 * i + 1 < datosObstaculos.length) {
              obstaculoX[i] = int(datosObstaculos[2 * i]);
              obstaculoY[i] = int(datosObstaculos[2 * i + 1]);
            } else {
              obstaculoX[i] = -1;
              obstaculoY[i] = -1;
            }
          }

          String[] datosBalas = datos[2].split(" ");
          for (int i = 0; i < maxBalas; i++) {
            if (2 * i + 1 < datosBalas.length) {
              balaX[i] = int(datosBalas[2 * i]);
              balaY[i] = int(datosBalas[2 * i + 1]);
            } else {
              balaX[i] = -1;
              balaY[i] = -1;
            }
          }

          String[] datosBalas2 = datos[3].split(" ");
          for (int i = 0; i < maxBalas; i++) {
            if (2 * i + 1 < datosBalas2.length) {
              bala2X[i] = int(datosBalas2[2 * i]);
              bala2Y[i] = int(datosBalas2[2 * i + 1]);
            } else {
              bala2X[i] = -1;
              bala2Y[i] = -1;
            }
          }
        }
      } else if (val.startsWith("EXPLOSION")) {
        String[] datosExplosion = val.split(" ");
        if (datosExplosion.length == 3) {
          float x = float(datosExplosion[1]);
          float y = float(datosExplosion[2]);
          explosiones.add(new Explosion(x, y)); // Añadir nueva explosión
        }
      } else if (val.startsWith("COLISION")) {
        String[] datosColision = val.split(" ");
        if (datosColision.length == 3) {
          float x = float(datosColision[1]);
          float y = float(datosColision[2]);
          colisiones.add(new Colision(x, y)); // Añadir nueva colisión
        }
      }
    }
  }
fill(255);
// Dibujar nave 1 con una forma más estilizada
beginShape();
vertex(naveX, height - 20);
vertex(naveX + 20, height - 40);
vertex(naveX + 40, height - 20);
endShape(CLOSE);

if (segundoJugador) {
  // Dibujar nave 2 con una forma más estilizada
  beginShape();
  vertex(nave2X, height - 50);
  vertex(nave2X + 20, height - 70);
  vertex(nave2X + 40, height - 50);
  endShape(CLOSE);
}

fill(255, 0, 0);
for (int i = 0; i < maxObstaculos; i++) {
  if (obstaculoX[i] != -1 && obstaculoY[i] != -1) {
    ellipse(obstaculoX[i], obstaculoY[i], 20, 20); // Dibujar obstáculos redondos
  }
}

fill(0, 255, 0);
for (int i = 0; i < maxBalas; i++) {
  if (balaX[i] != -1 && balaY[i] != -1) {
    rect(balaX[i], balaY[i], 5, 10); // Dibujar balas de la nave 1
  }
  if (bala2X[i] != -1 && bala2Y[i] != -1) {
    rect(bala2X[i], bala2Y[i], 5, 10); // Dibujar balas de la nave 2
  }
}

// Dibujar explosiones
for (int i = explosiones.size() - 1; i >= 0; i--) {
  Explosion explosion = explosiones.get(i);
  explosion.actualizar();
  explosion.mostrar();
  if (explosion.terminada()) {
    explosiones.remove(i);
  }
}

// Dibujar colisiones
for (int i = colisiones.size() - 1; i >= 0; i--) {
  Colision colision = colisiones.get(i);
  colision.actualizar();
  colision.mostrar();
  if (colision.terminada()) {
    colisiones.remove(i);
  }
}

fill(255);
textSize(16);
text("Puntuación: " + puntuacion, 10, 20);
text("Vidas: " + vidas, 10, 40);

if (juegoTerminado) {
  fill(255, 0, 0);
  textSize(32);
  text("GAME OVER", width / 2 - 100, height / 2);
}
}

class Explosion {
float x, y;
int duracion;
int duracionMaxima;

Explosion(float x, float y) {
  this.x = x;
  this.y = y;
  this.duracion = 100;
  this.duracionMaxima = 100;
}

void actualizar() {
  duracion--;
}

void mostrar() {
  float alpha = map(duracion, 0, duracionMaxima, 0, 255);
  noStroke();
  fill(255, 255, 0, alpha);
  ellipse(x, y, 40, 40); // Explosión amarilla
  fill(255, 0, 0, alpha);
  ellipse(x, y, 20, 20); // Núcleo rojo de la explosión
}

boolean terminada() {
  return duracion <= 0;
}
}

class Colision {
float x, y;
int duracion;
int duracionMaxima;

Colision(float x, float y) {
  this.x = x;
  this.y = y;
  this.duracion = 100;
  this.duracionMaxima = 100;
}

void actualizar() {
  duracion--;
}

void mostrar() {
  float alpha = map(duracion, 0, duracionMaxima, 0, 255);
  noStroke();
  fill(255, 0, 0, alpha);
  ellipse(x, y, 40, 40); // Colisión roja
}

boolean terminada() {
  return duracion <= 0;
}
}
