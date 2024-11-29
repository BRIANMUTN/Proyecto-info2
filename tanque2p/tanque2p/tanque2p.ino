#include <Wire.h>

const int boton1 = 2; // Pin del botón 1
const int boton2 = 3; // Pin del botón 2
const int boton3 = 4; // Pin del botón 3 (izquierda nave 2)
const int boton4 = 5; // Pin del botón 4 (derecha nave 2)
const int anchoPantalla = 800;
const int altoPantalla = 600;
const int anchoNave = 40;
const int altoNave = 20;
const int anchoObstaculo = 20;
const int altoObstaculo = 20;
const int maxObstaculos = 10;
const int maxBalas = 30;
const int velocidadBala = 30; // Incrementamos significativamente la velocidad de las balas
const int velocidadNave = 40; // Incrementamos significativamente la velocidad de las naves
const int velocidadMinObstaculo = 14; // Incrementamos significativamente la velocidad mínima de los obstáculos
const int velocidadMaxObstaculo = 20; // Incrementamos significativamente la velocidad máxima de los obstáculos

int naveX = anchoPantalla / 2;
int nave2X = anchoPantalla / 2;
bool segundoJugador = false;
bool juegoTerminado = false;
unsigned long tiempoUltimaActualizacion = 0;
unsigned long tiempoUltimoDisparo = 0;
unsigned long tiempoJuegoTerminado = 0;

struct Obstaculo {
  int x;
  int y;
  int velocidad;
  bool activo;
};

struct Bala {
  int x;
  int y;
  bool activo;
};

Obstaculo obstaculos[maxObstaculos];
Bala balas[maxBalas];
Bala balas2[maxBalas];

void setup() {
  Serial.begin(57600); // Incrementamos la velocidad de comunicación
  pinMode(boton1, INPUT_PULLUP);
  pinMode(boton2, INPUT_PULLUP);
  pinMode(boton3, INPUT_PULLUP);
  pinMode(boton4, INPUT_PULLUP);
  reiniciarJuego();
}

void loop() {
  if (!juegoTerminado) {
    manejarEntrada();
    actualizarJuego();
    enviarEstadoAProcessing();
  } else {
    if (millis() - tiempoJuegoTerminado > 2000) {
      reiniciarJuego();
    }
  }
}

void manejarEntrada() {
  if (digitalRead(boton1) == LOW) {
    naveX -= velocidadNave;
    if (naveX < 0) naveX = 0; // Límite izquierdo
  } else if (digitalRead(boton2) == LOW) {
    naveX += velocidadNave;
    if (naveX > anchoPantalla - anchoNave) naveX = anchoPantalla - anchoNave; // Límite derecho
  } else if (digitalRead(boton3) == LOW) {
    nave2X -= velocidadNave;
    segundoJugador = true;
    if (nave2X < 0) nave2X = 0; // Límite izquierdo
  } else if (digitalRead(boton4) == LOW) {
    nave2X += velocidadNave;
    segundoJugador = true;
    if (nave2X > anchoPantalla - anchoNave) nave2X = anchoPantalla - anchoNave; // Límite derecho
  }

  // Disparo cada 0.25 segundos
  if (millis() - tiempoUltimoDisparo > 250) {
    disparar();
    if (segundoJugador) {
      disparar2();
    }
    tiempoUltimoDisparo = millis();
  }
}

void actualizarJuego() {
  // Crear nuevos obstáculos
  if (millis() - tiempoUltimaActualizacion > 50) { // Actualizamos más frecuentemente
    for (int i = 0; i < maxObstaculos; i++) {
      if (!obstaculos[i].activo) {
        obstaculos[i].x = random(anchoPantalla);
        obstaculos[i].y = 0;
        obstaculos[i].velocidad = random(velocidadMinObstaculo, velocidadMaxObstaculo);
        obstaculos[i].activo = true;
        break;
      }
    }
    tiempoUltimaActualizacion = millis();
  }

  // Mover obstáculos y detectar colisiones
  for (int i = 0; i < maxObstaculos; i++) {
    if (obstaculos[i].activo) {
      obstaculos[i].y += obstaculos[i].velocidad;
      if (obstaculos[i].y > altoPantalla) {
        obstaculos[i].activo = false;
      }

      if (colisiona(naveX, altoPantalla - altoNave, anchoNave, altoNave, obstaculos[i].x, obstaculos[i].y, anchoObstaculo, altoObstaculo) ||
          (segundoJugador && colisiona(nave2X, altoPantalla - altoNave - 30, anchoNave, altoNave, obstaculos[i].x, obstaculos[i].y, anchoObstaculo, altoObstaculo))) {
        juegoTerminado = true;
        tiempoJuegoTerminado = millis();
      }
    }
  }

  // Mover balas y detectar colisiones con obstáculos
  for (int i = 0; i < maxBalas; i++) {
    if (balas[i].activo) {
      balas[i].y -= velocidadBala;
      if (balas[i].y < 0) {
        balas[i].activo = false;
      }
      for (int j = 0; j < maxObstaculos; j++) {
        if (obstaculos[j].activo && colisiona(balas[i].x, balas[i].y, 5, 10, obstaculos[j].x, obstaculos[j].y, anchoObstaculo, altoObstaculo)) {
          balas[i].activo = false;
          obstaculos[j].activo = false;
          // Enviar señal de explosión
          Serial.print("EXPLOSION ");
          Serial.print(obstaculos[j].x);
          Serial.print(" ");
          Serial.println(obstaculos[j].y);
        }
      }
    }
    if (balas2[i].activo) {
      balas2[i].y -= velocidadBala;
      if (balas2[i].y < 0) {
        balas2[i].activo = false;
      }
      for (int j = 0; j < maxObstaculos; j++) {
        if (obstaculos[j].activo && colisiona(balas2[i].x, balas2[i].y, 5, 10, obstaculos[j].x, obstaculos[j].y, anchoObstaculo, altoObstaculo)) {
          balas2[i].activo = false;
          obstaculos[j].activo = false;
          // Enviar señal de explosión
          Serial.print("EXPLOSION ");
          Serial.print(obstaculos[j].x);
          Serial.print(" ");
          Serial.println(obstaculos[j].y);
        }
      }
    }
  }
}

bool colisiona(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2) {
  return !(x1 + w1 < x2 || x2 + w2 < x1 || y1 + h1 < y2 || y2 + h2 < y1);
}

void disparar() {
  for (int i = 0; i < maxBalas; i++) {
    if (!balas[i].activo) {
      balas[i].x = naveX + anchoNave / 2 - 2;
      balas[i].y = altoPantalla - altoNave;
      balas[i].activo = true;
      break;
    }
  }
}

void disparar2() {
  for (int i = 0; i < maxBalas; i++) {
    if (!balas2[i].activo) {
      balas2[i].x = nave2X + anchoNave / 2 - 2;
      balas2[i].y = altoPantalla - altoNave - 30;
      balas2[i].activo = true;
      break;
    }
  }
}

void enviarEstadoAProcessing() {
  Serial.print("NAVES ");
  Serial.print(naveX); Serial.print(" ");
  Serial.print(nave2X); Serial.print(" ");
  Serial.print(segundoJugador ? "1" : "0"); Serial.print(" ");
  Serial.print(juegoTerminado ? "1" : "0"); Serial.print(" | ");
  for (int i = 0; i < maxObstaculos; i++) {
    if (obstaculos[i].activo) {
      Serial.print(obstaculos[i].x); Serial.print(" ");
      Serial.print(obstaculos[i].y); Serial.print(" ");
    } else {
      Serial.print("-1 -1 "); // Indica obstáculo inactivo
    }
  }
  Serial.print("| ");
  for (int i = 0; i < maxBalas; i++) {
    if (balas[i].activo) {
      Serial.print(balas[i].x); Serial.print(" ");
      Serial.print(balas[i].y); Serial.print(" ");
    } else {
      Serial.print("-1 -1 "); // Indica bala inactiva
    }
  }
  Serial.print("| ");
  for (int i = 0; i < maxBalas; i++) {
    if (balas2[i].activo) {
      Serial.print(balas2[i].x); Serial.print(" ");
      Serial.print(balas2[i].y); Serial.print(" ");
    } else {
      Serial.print("-1 -1 "); // Indica bala inactiva
    }
  }
  Serial.println();
}

void reiniciarJuego() {
  naveX = anchoPantalla / 2;
  nave2X = anchoPantalla / 2;
  segundoJugador = false;
  juegoTerminado = false;
  for (int i = 0; i < maxObstaculos; i++) {
    obstaculos[i].activo = false;
  }
  for (int i = 0; i < maxBalas; i++) {
    balas[i].activo = false;
    balas2[i].activo = false;
  }
  tiempoUltimaActualizacion = millis();
}
