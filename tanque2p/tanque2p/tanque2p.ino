#include <Wire.h>

// Declaración de constantes y variables globales
const int boton1 = 2; // Controla el movimiento hacia la izquierda del jugador 1
const int boton2 = 3; // Controla el movimiento hacia la derecha del jugador 1
const int boton3 = 4; // Pin del botón 3 (izquierda nave 2)
const int boton4 = 5; // Pin del botón 4 (derecha nave 2)
const int anchoPantalla = 800;// Dimension de la pantalla
const int altoPantalla = 600;// Dimension de la pantalla
const int anchoNaveNormal = 40;// Tamaño inicial de la nave
const int altoNave = 20;
const int anchoNaveGrande = 60;// Tamaño aumentado de la nave durante una desventaja
int anchoNave = anchoNaveNormal; // Variable que ajusta el tamaño de la nave
const int anchoObstaculo = 20; // Tamaño estándar de los obstáculos
const int altoObstaculo = 20;
const int anchoObstaculoEspecial = 30;// Tamaño de obstáculos especiales
const int altoObstaculoEspecial = 30;
const int maxObstaculos = 10; // Máximo de obstáculos y balas activas
const int maxBalas = 30;
const int velocidadBala = 30; // Velocidad de las balas
const int velocidadNave = 40; // Velocidad de desplazamiento de las naves
const int velocidadMinObstaculo = 14;// Velocidades aleatorias de obstáculos
const int velocidadMaxObstaculo = 20;

// Variables de estado del juego

// Posición inicial de las naves
int naveX = anchoPantalla / 2;
int nave2X = anchoPantalla / 2;
// Puntuaciones actual y máxima
int puntuacion = 0;
int puntuacionMaxima = 0;
int vidas = 5;
bool segundoJugador = false; // Activa el modo de 2 jugadores
bool juegoTerminado = false; // Indica si el juego ha terminado
bool poderActivo = false;// Activa un poder especial
bool enPausa = false;// Pausa del juego
unsigned long tiempoInicioPoder = 0;
unsigned long duracionPoder = 5000; // Duración del poder en milisegundos (5 segundos)
// Tiempos clave
unsigned long tiempoUltimaActualizacion = 0;
unsigned long tiempoUltimoDisparo = 0;
unsigned long tiempoJuegoTerminado = 0;

// Estructuras para obstáculos y balas
struct Obstaculo {
  int x;
  int y;
  int velocidad;
  bool activo;
  bool especial;
  bool desventaja;
};

struct Bala {
  int x;
  int y;
  bool activo;
};

// Arreglos para múltiples elementos en pantalla
Obstaculo obstaculos[maxObstaculos];
Bala balas[maxBalas];
Bala balas2[maxBalas];

void setup() {
  Serial.begin(57600);
  pinMode(boton1, INPUT_PULLUP);
  pinMode(boton2, INPUT_PULLUP);
  pinMode(boton3, INPUT_PULLUP);
  pinMode(boton4, INPUT_PULLUP);
  reiniciarJuego();
}

void loop() {
  if (Serial.available() > 0) { // Detecta comandos por serial
    String command = Serial.readStringUntil('\n');
    command.trim();
    if (command == "REINICIAR") { // Reinicia el juego
      Serial.println("Recibido comando REINICIAR");
      reiniciarJuego();
      enPausa = false; // Asegurarnos de que el juego no esté en pausa
    } else if (command == "PAUSA") {  // Pausa el juego
      Serial.println("Recibido comando PAUSA");
      enPausa = true;
    } else if (command == "REANUDAR") { // Reanuda el juego
      Serial.println("Recibido comando REANUDAR");
      enPausa = false;
    }
  }

  if (enPausa) {
    return; // No hacer nada mientras está en pausa
  }

  if (!juegoTerminado) {
    manejarEntrada(); // Procesa movimientos y disparos
    actualizarJuego();// Mueve elementos y detecta colisiones
    enviarEstadoAProcessing();
  } else {
    if (millis() - tiempoJuegoTerminado > 2000) { // Reinicia el juego tras 2 segundos
      reiniciarJuego(); 
    }
  }

  // Desactivar el poder después de que pase el tiempo de duración
  if (poderActivo && millis() - tiempoInicioPoder > duracionPoder) {
    poderActivo = false;
  }
}

// Función para manejar movimientos y disparos
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
    if (poderActivo) {
      dispararTriple(); // Disparo múltiple cuando el poder está activo
    } else {
      disparar();
    }
    if (segundoJugador) {
      disparar2();
    }
    tiempoUltimoDisparo = millis();
  }
}

// Actualización del estado del juego: movimiento de obstáculos, detección de colisiones
void actualizarJuego() {
  // Crear nuevos obstáculos
  if (millis() - tiempoUltimaActualizacion > 50) {  // Intervalo entre actualizaciones
    for (int i = 0; i < maxObstaculos; i++) {
      if (!obstaculos[i].activo) {
        obstaculos[i].x = random(anchoPantalla); // Posición aleatoria en el ancho de la pantalla
        obstaculos[i].y = 0;
        obstaculos[i].velocidad = random(velocidadMinObstaculo, velocidadMaxObstaculo);
        obstaculos[i].especial = random(100) < 10; // 10% de probabilidad de ser un obstáculo especial
        obstaculos[i].desventaja = random(100) < 10; // 10% de probabilidad de ser un obstáculo de desventaja
        obstaculos[i].activo = true; // Activa el obstáculo
        break;  // Solo crea un obstáculo por iteración
      }
    }
    tiempoUltimaActualizacion = millis();
  }

  // Mover obstáculos y detectar colisiones
  for (int i = 0; i < maxObstaculos; i++) {
    if (obstaculos[i].activo) {
      obstaculos[i].y += obstaculos[i].velocidad; // Mueve el obstáculo hacia abajo
      if (obstaculos[i].y > altoPantalla) {
        obstaculos[i].activo = false;
      }

   // Detectar colisión con las naves
      if (colisiona(naveX, altoPantalla - altoNave, anchoNave, altoNave, obstaculos[i].x, obstaculos[i].y, anchoObstaculo, altoObstaculo) ||
          (segundoJugador && colisiona(nave2X, altoPantalla - altoNave - 30, anchoNave, altoNave, obstaculos[i].x, obstaculos[i].y, anchoObstaculo, altoObstaculo))) {
        vidas--;
        if (vidas <= 0) {
          juegoTerminado = true;
          tiempoJuegoTerminado = millis();
          if (puntuacion > puntuacionMaxima) {
            puntuacionMaxima = puntuacion; // Actualizar puntuación más alta
          }
        }
        // Enviar señal de colisión con nave
        Serial.print("COLISION ");
        Serial.print(obstaculos[i].x);
        Serial.print(" ");
        Serial.println(obstaculos[i].y);
        obstaculos[i].activo = false;// Desactiva el obstáculo
      }
    }
  }

  // Mover balas y detectar colisiones con obstáculos
  for (int i = 0; i < maxBalas; i++) {
    if (balas[i].activo) {
      balas[i].y -= velocidadBala;// Mueve la bala hacia arriba
      if (balas[i].y < 0) {
        balas[i].activo = false;
      }
// Detectar colisiones entre balas y obstáculos
      for (int j = 0; j < maxObstaculos; j++) {
        if (obstaculos[j].activo && colisiona(balas[i].x, balas[i].y, 5, 10, obstaculos[j].x, obstaculos[j].y, anchoObstaculo, altoObstaculo)) {
          balas[i].activo = false;
          obstaculos[j].activo = false;
          puntuacion++; // Incrementar puntuación
          if (obstaculos[j].especial) {
            poderActivo = true; // Activar poder al destruir obstáculo especial
            tiempoInicioPoder = millis(); // Registra el inicio del poder
          }
          if (obstaculos[j].desventaja) {
            anchoNave = anchoNaveGrande; // Aumentar tamaño de la nave al destruir obstáculo de desventaja
          }
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
          puntuacion++; // Incrementar puntuación
          if (obstaculos[j].especial) {
            poderActivo = true; // Activar poder al destruir obstáculo especial
            tiempoInicioPoder = millis();
          }
          if (obstaculos[j].desventaja) {
            anchoNave = anchoNaveGrande; // Aumentar tamaño de la nave al destruir obstáculo de desventaja
          }
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
// Verifica si dos objetos colisionan
bool colisiona(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2) {
  return !(x1 + w1 < x2 || x2 + w2 < x1 || y1 + h1 < y2 || y2 + h2 < y1);
}

// Función para disparar una bala desde la nave 1
void disparar() {
  for (int i = 0; i < maxBalas; i++) {
    if (!balas[i].activo) {
      balas[i].x = naveX + anchoNave / 2 - 2; // Ajusta la posición inicial
      balas[i].y = altoPantalla - altoNave;// Coloca la bala justo encima de la nave
      balas[i].activo = true;
      break;
    }
  }
}
// Función para disparar una bala desde la nave 2
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

// Función para disparar tres balas simultáneamente (poder especial)
void dispararTriple() {
  for (int i = 0; i < maxBalas; i++) {
    if (!balas[i].activo) { // Encuentra balas inactivas para disparar
      balas[i].x = naveX + anchoNave / 2 - 12; // Ajusta posición inicial hacia la izquierda
      balas[i].y = altoPantalla - altoNave; // Coloca la bala justo encima de la nave
      balas[i].activo = true;
      i++; // Pasa al siguiente índice de bala
	// Segunda bala (centro)
      balas[i].x = naveX + anchoNave / 2 - 2;
      balas[i].y = altoPantalla - altoNave;
      balas[i].activo = true;
      i++;
// Tercera bala (derecha)
      balas[i].x = naveX + anchoNave / 2 + 8;
      balas[i].y = altoPantalla - altoNave;
      balas[i].activo = true;
      break;
    }
  }
}

// Función para enviar el estado del juego
void enviarEstadoAProcessing() {
  Serial.print("NAVES ");
  Serial.print(naveX); Serial.print(" ");// Posición de la nave 1
  Serial.print(nave2X); Serial.print(" ");// Posición de la nave 2
  Serial.print(segundoJugador ? "1" : "0"); Serial.print(" "); // Indica si hay un segundo jugador
  Serial.print(juegoTerminado ? "1" : "0"); Serial.print(" ");// Indica si el juego ha terminado
  Serial.print(puntuacion); Serial.print(" "); 
  Serial.print(puntuacionMaxima); Serial.print(" ");
  Serial.print(vidas); Serial.print(" ");
  Serial.print(poderActivo ? "1" : "0"); Serial.print(" | ");// Indica si el poder especial está activo
// Información de los obstáculos
  for (int i = 0; i < maxObstaculos; i++) {
    if (obstaculos[i].activo) { // Solo envía información de obstáculos activos
      Serial.print(obstaculos[i].x); Serial.print(" ");
      Serial.print(obstaculos[i].y); Serial.print(" ");
      Serial.print(obstaculos[i].especial ? "1" : "0"); Serial.print(" "); // Indica si es especial
      Serial.print(obstaculos[i].desventaja ? "1" : "0"); Serial.print(" "); // Indica si es de desventaja
    } else {
      Serial.print("-1 -1 0 0 "); // Indica obstáculo inactivo
    }
  }
  Serial.print("| ");
// Información de las balas del jugador 1
  for (int i = 0; i < maxBalas; i++) {
    if (balas[i].activo) {
      Serial.print(balas[i].x); Serial.print(" ");
      Serial.print(balas[i].y); Serial.print(" ");
    } else {
      Serial.print("-1 -1 "); // Indica bala inactiva
    }
  }
  Serial.print("| ");
// Información de las balas del jugador 2
  for (int i = 0; i < maxBalas; i++) {
    if (balas2[i].activo) {
      Serial.print(balas2[i].x); Serial.print(" ");
      Serial.print(balas2[i].y); Serial.print(" ");
    } else {
      Serial.print("-1 -1 "); // Indica bala inactiva
    }
  }
  Serial.println(); // Finaliza la línea de datos enviados
}

// Función para reiniciar el estado del juego
void reiniciarJuego() {
  naveX = anchoPantalla / 2; // Reestablece posición inicial de la nave 1
  nave2X = anchoPantalla / 2;// Reestablece posición inicial de la nave 2
  anchoNave = anchoNaveNormal; // Restablece tamaño normal de la nave
  segundoJugador = false; // Desactiva el modo de 2 jugadores
  juegoTerminado = false;// Marca el juego como no terminado
  puntuacion = 0;  // Reinicia la puntuación
  vidas = 5;
  poderActivo = false;// Desactiva cualquier poder especial activo

// Reinicia el estado de los obstáculos
  for (int i = 0; i < maxObstaculos; i++) {
    obstaculos[i].activo = false;
    obstaculos[i].especial = false;
    obstaculos[i].desventaja = false;
  }

// Reinicia el estado de las balas
  for (int i = 0; i < maxBalas; i++) {
    balas[i].activo = false;
    balas2[i].activo = false;
  }

  tiempoUltimaActualizacion = millis(); // Resetea el tiempo de actualización
}