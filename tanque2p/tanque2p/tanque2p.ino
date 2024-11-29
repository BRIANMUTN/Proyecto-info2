#include <Wire.h>

#define BOTON1 2   // Movimiento tanque 1 izquierda
#define BOTON2 3   // Movimiento tanque 1 derecha
#define BOTON3 4   // Movimiento tanque 2 izquierda
#define BOTON4 5   // Movimiento tanque 2 derecha

int posicionTanque1 = 7;     // Posición inicial del tanque 1
int posicionTanque2 = -1;    // Posición inicial del tanque 2 (-1 significa no visible)
bool jugador2Activo = false; // Indica si el jugador 2 está habilitado

int posicionBala1 = -1;  // Posición vertical de la bala del tanque 1 (-1 = sin bala)
int posicionBala2 = -1;  // Posición vertical de la bala del tanque 2 (-1 = sin bala)

int posicionObstaculo[4] = {4, 8, 12, 15}; // Posiciones iniciales de los obstáculos
int velocidadObstaculo[4] = {1, 1, 1, 1}; // Velocidad de caída de los obstáculos (más lento)

void setup() {
  Serial.begin(9600);  // Inicia la comunicación serie
  pinMode(BOTON1, INPUT_PULLUP);
  pinMode(BOTON2, INPUT_PULLUP);
  pinMode(BOTON3, INPUT_PULLUP);
  pinMode(BOTON4, INPUT_PULLUP);

  delay(1000); // Espera 1 segundo antes de comenzar el juego
}

void loop() {
  verificarActivacionJugador2(); // Verifica si se habilita el segundo jugador
  moverTanque1();                // Movimiento del tanque 1
  moverTanque2();                // Movimiento del tanque 2
  actualizarBalas();             // Actualiza el disparo de los tanques
  actualizarObstaculos();        // Mueve los obstáculos

  // Crear el string con los datos
  String datos = "tanque1:" + String(posicionTanque1) + ",bala1:" + String(posicionBala1) +
                 ",tanque2:" + String(posicionTanque2) + ",bala2:" + String(posicionBala2);
  
  // Añadir las posiciones de los obstáculos
  for (int i = 0; i < 4; i++) {
    datos += ",obstaculo" + String(i) + ":" + String(posicionObstaculo[i]);
  }
  
  // Enviar los datos a Processing
  Serial.println(datos);

  delay(100); // Ajustar la velocidad de envío de datos
}

void verificarActivacionJugador2() {
  // Si cualquier botón del jugador 2 es presionado, activa el jugador 2
  if (!jugador2Activo && (digitalRead(BOTON3) == LOW || digitalRead(BOTON4) == LOW)) {
    jugador2Activo = true;
    posicionTanque2 = 9; // Posición inicial del tanque 2
  }
}

void moverTanque1() {
  if (digitalRead(BOTON1) == LOW && posicionTanque1 > 0) posicionTanque1--; // Izquierda
  if (digitalRead(BOTON2) == LOW && posicionTanque1 < 15) posicionTanque1++; // Derecha
  if (posicionBala1 == -1) posicionBala1 = 1; // Dispara si no hay bala
}

void moverTanque2() {
  if (!jugador2Activo) return; // No hace nada si el segundo jugador no está activo
  if (digitalRead(BOTON3) == LOW && posicionTanque2 > 0) posicionTanque2--; // Izquierda
  if (digitalRead(BOTON4) == LOW && posicionTanque2 < 15) posicionTanque2++; // Derecha
  if (posicionBala2 == -1) posicionBala2 = 1; // Dispara si no hay bala
}

void actualizarBalas() {
  if (posicionBala1 >= 0) posicionBala1--; // Bala del tanque 1 sube
  if (jugador2Activo && posicionBala2 >= 0) posicionBala2--; // Bala del tanque 2 sube

  // Resetea las balas si llegan al final
  if (posicionBala1 < 0) posicionBala1 = -1;
  if (posicionBala2 < 0) posicionBala2 = -1;
}

void actualizarObstaculos() {
  for (int i = 0; i < 4; i++) {
    posicionObstaculo[i] += velocidadObstaculo[i]; // Los obstáculos caen lentamente
    if (posicionObstaculo[i] > 15) posicionObstaculo[i] = 0; // Resetea si salen de la pantalla
  }
}
