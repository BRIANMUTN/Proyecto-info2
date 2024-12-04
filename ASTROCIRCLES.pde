import processing.serial.*; // Importar la librería para la comunicación serial
import java.util.ArrayList; // Importar la librería para utilizar listas dinámicas

// Declaración de variables globales
Serial miPuerto; // Objeto para la comunicación serial
int naveX; // Posición X de la nave del primer jugador
int nave2X; // Posición X de la nave del segundo jugador
boolean segundoJugador; // Indica si hay un segundo jugador
boolean juegoTerminado; // Indica si el juego ha terminado
boolean poderActivo; // Indica si el poder especial está activo
int puntuacion;
int puntuacionMaxima; 
int vidas; // Número de vidas restantes

// Arrays para manejar los obstáculos
int[] obstaculoX; // Posiciones X de los obstáculos
int[] obstaculoY; // Posiciones Y de los obstáculos
int[] obstaculoEspecial; // Indica si el obstáculo es especial
int[] obstaculoDesventaja; // Indica si el obstáculo es una desventaja

int maxObstaculos = 10; // Número máximo de obstáculos

// Arrays para manejar las balas de los jugadores
int[] balaX; // Posiciones X de las balas del primer jugador
int[] balaY; // Posiciones Y de las balas del primer jugador
int[] bala2X; // Posiciones X de las balas del segundo jugador
int[] bala2Y; // Posiciones Y de las balas del segundo jugador

int maxBalas = 30; // Número máximo de balas

ArrayList<Explosion> explosiones; // Lista para manejar las explosiones
ArrayList<Colision> colisiones; // Lista para manejar las colisiones

boolean mostrarTitulo = true; // Indica si se debe mostrar el título al inicio
float escalaTitulo = 1.0; // Escala para el efecto de zoom del título
int alfaTitulo = 255; // Transparencia para el efecto de desvanecimiento del título

// Variables para el menú de inicio
boolean mostrarMenu = true; // Indica si se debe mostrar el menú de inicio
int botonIniciarX, botonIniciarY, botonIniciarAncho, botonIniciarAlto; // Posición y tamaño del botón "Iniciar"

// Variables para el menú de pausa
boolean enPausa = false; // Indica si el juego está en pausa
int botonPausaX, botonPausaY, botonPausaAncho, botonPausaAlto; // Posición y tamaño del botón "Pausa"
int botonReanudarX, botonReanudarY, botonReanudarAncho, botonReanudarAlto; // Posición y tamaño del botón "Reanudar"
int botonReiniciarX, botonReiniciarY, botonReiniciarAncho, botonReiniciarAlto; // Posición y tamaño del botón "Reiniciar"
int botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto; // Posición y tamaño del botón "Salir"

void setup() {
  size(800, 600); // Configurar el tamaño de la ventana del juego
  frameRate(60); // Configurar la tasa de fotogramas a 60 fps
  miPuerto = new Serial(this, Serial.list()[1], 57600); // Configurar la comunicación serial

  // Configurar las posiciones y tamaños de los botones del menú principal
  botonIniciarAncho = 200;
  botonIniciarAlto = 50;
  botonIniciarX = (width - botonIniciarAncho) / 2; 
  botonIniciarY = height / 2 - 60;

  botonSalirAncho = 200;
  botonSalirAlto = 50;
  botonSalirX = (width - botonSalirAncho) / 2;
  botonSalirY = height / 2 + 20;

  // Configurar los botones del menú de pausa
  botonPausaAncho = 100;
  botonPausaAlto = 40;
  botonPausaX = width - botonPausaAncho - 10;
  botonPausaY = 10;

  botonReanudarAncho = 200;
  botonReanudarAlto = 50;
  botonReanudarX = (width - botonReanudarAncho) / 2;
  botonReanudarY = height / 2 - 80;

  botonReiniciarAncho = 200;
  botonReiniciarAlto = 50;
  botonReiniciarX = (width - botonReiniciarAncho) / 2;
  botonReiniciarY = height / 2;

  botonSalirAncho = 200;
  botonSalirAlto = 50;
  botonSalirX = (width - botonSalirAncho) / 2;
  botonSalirY = height / 2 + 80;

  // Inicializar los arrays y las listas
  obstaculoX = new int[maxObstaculos];
  obstaculoY = new int[maxObstaculos];
  obstaculoEspecial = new int[maxObstaculos]; // Inicializar array de obstáculos especiales
  obstaculoDesventaja = new int[maxObstaculos]; // Inicializar array de obstáculos de desventaja
  balaX = new int[maxBalas];
  balaY = new int[maxBalas];
  bala2X = new int[maxBalas];
  bala2Y = new int[maxBalas];
  explosiones = new ArrayList<Explosion>(); // Inicializar lista de explosiones
  colisiones = new ArrayList<Colision>(); // Inicializar lista de colisiones
  puntuacion = 0;
  puntuacionMaxima = 0;
  vidas = 5;
}

void draw() {
  if (mostrarMenu) {
    mostrarMenu(); // Mostrar el menú principal si mostrarMenu es verdadero
  } else if (enPausa) { 
    mostrarMenuPausa(); // Mostrar el menú de pausa si el juego está en pausa
  } else {
    background(0); // Establecer el fondo negro para el juego

    if (mostrarTitulo) {
      // Mostrar título con efecto de zoom y cambio de color
      fill(255, 255, 0, alfaTitulo); // Establecer el color del texto (amarillo con transparencia)
      textAlign(CENTER, CENTER); // Alinear el texto al centro
      textSize(48 * escalaTitulo); // Establecer el tamaño del texto con un efecto de zoom
      text("AstroCircles", width / 2, height / 2); // Dibujar el título en el centro de la pantalla
    
      // Efecto de zoom y desvanecimiento
      escalaTitulo += 0.02; // Aumentar la escala del título para el efecto de zoom
      alfaTitulo -= 2; // Disminuir el alpha del título para el efecto de desvanecimiento
      if (alfaTitulo <= 0) {
        mostrarTitulo = false; // Dejar de mostrar el título cuando el alpha llega a 0
      }
    } else {
      // Dibujar botón de pausa
      fill(255); // Establecer el color de relleno del botón
      if (mouseOverBoton(botonPausaX, botonPausaY, botonPausaAncho, botonPausaAlto)) {
        fill(200); // Cambiar color si el mouse está sobre el botón
      }
      rect(botonPausaX, botonPausaY, botonPausaAncho, botonPausaAlto); // Dibujar el botón de pausa
      fill(0); // Establecer el color del texto del botón
      textAlign(CENTER, CENTER); // Alinear el texto al centro
      text("Pausa", botonPausaX + botonPausaAncho / 2, botonPausaY + botonPausaAlto / 2); // Dibujar el texto del botón de pausa

      // Leer datos del puerto serial
      if (miPuerto.available() > 0) {
        String val = miPuerto.readStringUntil('\n'); // Leer una línea completa del puerto serial
        if (val != null) {
          val = val.trim(); // Eliminar espacios en blanco de los extremos
          if (val.startsWith("NAVES")) {
            // Procesar datos de las naves, obstáculos y balas
            String[] datos = val.split(" \\| ");
            if (datos.length == 4) {
              String[] datosNave = datos[0].split(" ");
              if (datosNave.length >= 9) {
                naveX = int(datosNave[1]); // Posición X de la nave del primer jugador
                nave2X = int(datosNave[2]); // Posición X de la nave del segundo jugador
                segundoJugador = datosNave[3].equals("1"); // Indicar si hay un segundo jugador
                juegoTerminado = datosNave[4].equals("1"); // Indicar si el juego ha terminado
                puntuacion = int(datosNave[5]); // Puntuación actual
                puntuacionMaxima = int(datosNave[6]); // Puntuación máxima
                vidas = int(datosNave[7]); // Vidas restantes
                poderActivo = datosNave[8].equals("1"); // Indicar si el poder especial está activo
              }

              String[] datosObstaculos = datos[1].split(" ");
              for (int i = 0; i < maxObstaculos; i++) {
                if (4 * i + 3 < datosObstaculos.length) {
                  obstaculoX[i] = int(datosObstaculos[4 * i]); // Posición X del obstáculo
                  obstaculoY[i] = int(datosObstaculos[4 * i + 1]); // Posición Y del obstáculo
                  obstaculoEspecial[i] = int(datosObstaculos[4 * i + 2]); // Indicar si el obstáculo es especial
                  obstaculoDesventaja[i] = int(datosObstaculos[4 * i + 3]); // Indicar si el obstáculo es de desventaja
                } else {
                  obstaculoX[i] = -1;
                  obstaculoY[i] = -1;
                  obstaculoEspecial[i] = 0;
                  obstaculoDesventaja[i] = 0;
                }
              }

              String[] datosBalas = datos[2].split(" ");
              for (int i = 0; i < maxBalas; i++) {
                if (2 * i + 1 < datosBalas.length) {
                  balaX[i] = int(datosBalas[2 * i]); // Posición X de la bala
                  balaY[i] = int(datosBalas[2 * i + 1]); // Posición Y de la bala
                } else {
                  balaX[i] = -1;
                  balaY[i] = -1;
                }
              }

              String[] datosBalas2 = datos[3].split(" ");
              for (int i = 0; i < maxBalas; i++) {
                if (2 * i + 1 < datosBalas2.length) {
                  bala2X[i] = int(datosBalas2[2 * i]); // Posición X de la bala del segundo jugador
                  bala2Y[i] = int(datosBalas2[2 * i + 1]); // Posición Y de la bala del segundo jugador
                } else {
                  bala2X[i] = -1;
                  bala2Y[i] = -1;
                }
              }
            }
          } else if (val.startsWith("EXPLOSION")) {
            // Procesar datos de una explosión
            String[] datosExplosion = val.split(" ");
            if (datosExplosion.length == 3) {
              float x = float(datosExplosion[1]); // Posición X de la explosión
              float y = float(datosExplosion[2]); // Posición Y de la explosión
              explosiones.add(new Explosion(x, y)); // Añadir una nueva explosión a la lista
            }
          } else if (val.startsWith("COLISION")) {
            // Procesar datos de una colisión
            String[] datosColision = val.split(" ");
            if (datosColision.length == 3) {
              float x = float(datosColision[1]); // Posición X de la colisión
              float y = float(datosColision[2]); // Posición Y de la colisión
              colisiones.add(new Colision(x, y)); // Añadir una nueva colisión a la lista
            }
          }
        }
      }
fill(255);
// Dibujar nave 1 
beginShape(); // Iniciar la forma de la nave
vertex(naveX, height - 20); // Primer vértice de la nave
vertex(naveX + 20, height - 40); // Segundo vértice de la nave
vertex(naveX + 40, height - 20); // Tercer vértice de la nave
endShape(CLOSE); // Cerrar la forma de la nave

if (segundoJugador) {
  // Dibujar nave 2 
  beginShape(); // Iniciar la forma de la nave 2
  vertex(nave2X, height - 50); // Primer vértice de la nave 2
  vertex(nave2X + 20, height - 70); // Segundo vértice de la nave 2
  vertex(nave2X + 40, height - 50); // Tercer vértice de la nave 2
  endShape(CLOSE); // Cerrar la forma de la nave 2
}

// Dibujar obstáculos
for (int i = 0; i < maxObstaculos; i++) {
  if (obstaculoX[i] != -1 && obstaculoY[i] != -1) {
    if (obstaculoEspecial[i] == 1) {
      fill(0, 0, 255); // Obstáculo especial en color azul
      ellipse(obstaculoX[i], obstaculoY[i], 30, 30); // Dibujar obstáculos especiales en forma redonda
    } else if (obstaculoDesventaja[i] == 1) {
      fill(255, 255, 0); // Obstáculo de desventaja en color amarillo
      ellipse(obstaculoX[i], obstaculoY[i], 30, 30); // Dibujar obstáculos de desventaja en forma redonda
    } else {
      fill(255, 0, 0); // Obstáculo normal en color rojo
      ellipse(obstaculoX[i], obstaculoY[i], 20, 20); // Dibujar obstáculos normales redondos 
    }
  }
}

fill(0, 255, 0); // Establecer el color de las balas en verde
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
  explosion.actualizar(); // Actualizar el estado de la explosión
  explosion.mostrar(); // Mostrar la explosión
  if (explosion.terminada()) {
    explosiones.remove(i); // Quitar la explosión de la lista si ha terminado
  }
}

// Dibujar colisiones
for (int i = colisiones.size() - 1; i >= 0; i--) {
  Colision colision = colisiones.get(i);
  colision.actualizar(); // Actualizar el estado de la colisión
  colision.mostrar(); // Mostrar la colisión
  if (colision.terminada()) {
    colisiones.remove(i); // Quitar la colisión de la lista si ha terminado
  }
}

fill(255); // Color del texto en blanco
textSize(16); // Establecer el tamaño del texto
textAlign(LEFT); // Alinear el texto a la izquierda para los textos de puntuación y vidas
text("Puntuación: " + puntuacion, 10, 20); // Mostrar la puntuación actual
text("Puntuación más alta: " + puntuacionMaxima, 10, 40); // Mostrar la puntuación más alta
text("Vidas: " + vidas, 10, 60); // Mostrar el número de vidas restantes

if (juegoTerminado) {
  fill(255, 0, 0); // Color del texto en rojo para el GAME OVER
  textSize(32); // Establecer el tamaño del texto
  textAlign(CENTER, CENTER); // Centrar el texto del GAME OVER
  text("GAME OVER", width / 2, height / 2); // Mostrar "GAME OVER" en el centro de la pantalla
}

// Mostrar indicador del poder de disparo múltiple
if (poderActivo) {
  fill(0, 255, 255); // Establecer el color del texto en cian
  textSize(16); // Establecer el tamaño del texto
  text("Poder Activo: Disparo Múltiple", 10, 80); // Mostrar el indicador del poder activo
}
    }
  }
}

void reiniciarJuego() {
  naveX = width / 2; // Centrar la nave del primer jugador
  nave2X = width / 2; // Centrar la nave del segundo jugador
  segundoJugador = false; // Indicar que no hay un segundo jugador inicialmente
  juegoTerminado = false; // Reiniciar el estado del juego
  puntuacion = 0; // Reiniciar la puntuación a 0
  vidas = 5; // Reiniciar las vidas a 5
  poderActivo = false; // Desactivar cualquier poder especial activo

  // Reiniciar los obstáculos
  for (int i = 0; i < maxObstaculos; i++) {
    obstaculoX[i] = -1; // Colocar los obstáculos fuera de la pantalla
    obstaculoY[i] = -1; // Colocar los obstáculos fuera de la pantalla
    obstaculoEspecial[i] = 0; // Indicar que no son obstáculos especiales
    obstaculoDesventaja[i] = 0; // Indicar que no son obstáculos de desventaja
  }

  // Reiniciar las balas
  for (int i = 0; i < maxBalas; i++) {
    // Colocar las balas fuera de la pantalla
    balaX[i] = -1; 
    balaY[i] = -1; 
    // Colocar las balas del segundo jugador fuera de la pantalla
    bala2X[i] = -1; 
    bala2Y[i] = -1; 
  }

  explosiones.clear(); // Limpiar la lista de explosiones
  colisiones.clear(); // Limpiar la lista de colisiones

  miPuerto.write("REINICIAR\n"); // Enviar una señal a Arduino para reiniciar el juego
}



void mostrarMenu() {
  background(0); // Establecer un fondo negro
  fill(255); // Establecer el color de relleno en blanco
  textSize(32); // Establecer el tamaño del texto
  textAlign(CENTER, CENTER); // Alinear el texto al centro
  text("Menú Principal", width / 2, height / 4); // Mostrar el título del menú

  // Dibujar botón de Iniciar Juego
  if (mouseOverBoton(botonIniciarX, botonIniciarY, botonIniciarAncho, botonIniciarAlto)) {
    fill(200); // Cambiar color si el mouse está sobre el botón
  } else {
    fill(255); // Color de relleno blanco
  }
  rect(botonIniciarX, botonIniciarY, botonIniciarAncho, botonIniciarAlto); // Dibujar el rectángulo del botón
  fill(0); // Establecer el color del texto en negro
  text("Iniciar Juego", botonIniciarX + botonIniciarAncho / 2, botonIniciarY + botonIniciarAlto / 2); // Mostrar el texto del botón

  // Dibujar botón de Salir
  if (mouseOverBoton(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto)) {
    fill(200); // Cambiar color si el mouse está sobre el botón
  } else {
    fill(255); // Color de relleno blanco
  }
  rect(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto); // Dibujar el rectángulo del botón
  fill(0); // Establecer el color del texto en negro
  text("Salir", botonSalirX + botonSalirAncho / 2, botonSalirY + botonSalirAlto / 2); // Mostrar el texto del botón
}

void mostrarMenuPausa() {
  background(0, 150); // Establecer un fondo negro con transparencia para el menú de pausa

  fill(255); // Establecer el color de relleno en blanco
  textSize(32); // Establecer el tamaño del texto
  textAlign(CENTER, CENTER); // Alinear el texto al centro
  text("Pausa", width / 2, height / 4); // Mostrar el título del menú de pausa

  // Dibujar botón de Reanudar
  if (mouseOverBoton(botonReanudarX, botonReanudarY, botonReanudarAncho, botonReanudarAlto)) {
    fill(200); // Cambiar color si el mouse está sobre el botón
  } else {
    fill(255); // Color de relleno blanco
  }
  rect(botonReanudarX, botonReanudarY, botonReanudarAncho, botonReanudarAlto); // Dibujar el rectángulo del botón
  fill(0); // Establecer el color del texto en negro
  text("Reanudar", botonReanudarX + botonReanudarAncho / 2, botonReanudarY + botonReanudarAlto / 2); // Mostrar el texto del botón

  // Dibujar botón de Reiniciar
  if (mouseOverBoton(botonReiniciarX, botonReiniciarY, botonReiniciarAncho, botonReiniciarAlto)) {
    fill(200); // Cambiar color si el mouse está sobre el botón
  } else {
    fill(255); // Color de relleno blanco
  }
  rect(botonReiniciarX, botonReiniciarY, botonReiniciarAncho, botonReiniciarAlto); // Dibujar el rectángulo del botón
  fill(0); // Establecer el color del texto en negro
  text("Reiniciar", botonReiniciarX + botonReiniciarAncho / 2, botonReiniciarY + botonReiniciarAlto / 2); // Mostrar el texto del botón

  // Dibujar botón de Salir
  if (mouseOverBoton(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto)) {
    fill(200); // Cambiar color si el mouse está sobre el botón
  } else {
    fill(255); // Color de relleno blanco
  }
  rect(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto); // Dibujar el rectángulo del botón
  fill(0); // Establecer el color del texto en negro
  text("Salir", botonSalirX + botonSalirAncho / 2, botonSalirY + botonSalirAlto / 2); // Mostrar el texto del botón
}


// Función para verificar si el mouse está sobre un botón
boolean mouseOverBoton(int x, int y, int ancho, int alto) {
  return mouseX > x && mouseX < x + ancho && mouseY > y && mouseY < y + alto;
}

void mousePressed() {
  if (mostrarMenu) {
    // Si se muestra el menú principal
    if (mouseOverBoton(botonIniciarX, botonIniciarY, botonIniciarAncho, botonIniciarAlto)) {
      mostrarMenu = false; // Iniciar el juego
    } else if (mouseOverBoton(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto)) {
      exit(); // Salir del programa
    }
  } else if (enPausa) {
    // Si el juego está en pausa
    if (mouseOverBoton(botonReanudarX, botonReanudarY, botonReanudarAncho, botonReanudarAlto)) {
      enPausa = false; // Reanudar el juego
      miPuerto.write("REANUDAR\n"); // Señal para reanudar en Arduino
    } else if (mouseOverBoton(botonReiniciarX, botonReiniciarY, botonReiniciarAncho, botonReiniciarAlto)) {
      enPausa = false; // Salir del estado de pausa
      reiniciarJuego(); // Llamada a la función reiniciarJuego
    } else if (mouseOverBoton(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto)) {
      exit(); // Salir del programa
    }
  } else {
    // Si el juego está en ejecución
    if (mouseOverBoton(botonPausaX, botonPausaY, botonPausaAncho, botonPausaAlto)) {
      enPausa = true; // Pausar el juego
      miPuerto.write("PAUSA\n"); // Señal para pausar en Arduino
    }
  }
}
//CLASES
class Explosion {
  float x, y; // Posiciones X y Y de la explosión
  int duracion; // Duración actual de la explosión
  int duracionMaxima; // Duración máxima de la explosión

  // Constructor de la clase Explosion
  Explosion(float x, float y) {
    this.x = x;
    this.y = y;
    this.duracion = 100;
    this.duracionMaxima = 100;
  }

  // Método para actualizar la duración de la explosión
  void actualizar() {
    duracion--;
  }

  // Método para mostrar la explosión
  void mostrar() {
    float alpha = map(duracion, 0, duracionMaxima, 0, 255); // Calcular la transparencia basada en la duración
    noStroke(); // No usar bordes
    fill(255, 255, 0, alpha); // Color amarillo con transparencia
    ellipse(x, y, 40, 40); // Dibujar la explosión amarilla
    fill(255, 0, 0, alpha); // Color rojo con transparencia
    ellipse(x, y, 20, 20); // Dibujar el núcleo rojo de la explosión
  }

  // Método para verificar si la explosión ha terminado
  boolean terminada() {
    return duracion <= 0;
  }
}

class Colision {
  float x, y; // Posiciones X y Y de la colisión
  int duracion; // Duración actual de la colisión
  int duracionMaxima; // Duración máxima de la colisión

  // Constructor de la clase Colision
  Colision(float x, float y) {
    this.x = x;
    this.y = y;
    this.duracion = 100;
    this.duracionMaxima = 100;
  }

  // Método para actualizar la duración de la colisión
  void actualizar() {
    duracion--;
  }

  // Método para mostrar la colisión
  void mostrar() {
    float alpha = map(duracion, 0, duracionMaxima, 0, 255); // Calcular la transparencia basada en la duración
    noStroke(); // No usar bordes
    fill(255, 0, 0, alpha); // Color rojo con transparencia
    ellipse(x, y, 40, 40); // Dibujar la colisión roja
  }

  // Método para verificar si la colisión ha terminado
  boolean terminada() {
    return duracion <= 0;
  }
}
