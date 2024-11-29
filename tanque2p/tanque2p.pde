import java.util.ArrayList;
import processing.serial.*;
Serial miPuerto;  // Variable para la comunicación serial
int[] posicionTanque1 = new int[2]; // Posición del tanque 1
int[] posicionTanque2 = new int[2]; // Posición del tanque 2
ArrayList<int[]> obstaculos = new ArrayList<int[]>();  // Lista de obstáculos
ArrayList<int[]> balas = new ArrayList<int[]>();    // Lista de balas

void setup() {
  size(400, 400);
  miPuerto = new Serial(this, "COM4", 9600);  // Ajusta el puerto si es necesario
  frameRate(60);  // Establece una tasa de fotogramas más alta para una mayor fluidez
}

void draw() {
  background(0);
  
  // Lee los datos del Arduino
  if (miPuerto.available() > 0) {
    String datos = miPuerto.readStringUntil('\n');
    if (datos != null) {
      String[] tokens = split(datos, ',');
      
      // Actualizar las posiciones de los tanques
      posicionTanque1[0] = int(split(tokens[0], ':')[1]);
      posicionTanque1[1] = 300;  // Fija la nave en la parte inferior
      
      if (tokens.length > 2 && tokens[2].contains("tanque2")) {
        posicionTanque2[0] = int(split(tokens[2], ':')[1]);
        posicionTanque2[1] = 300;
      }
      
      // Actualizar las posiciones de las balas
      balas.clear();  // Limpiamos la lista de balas
      if (tokens.length > 1) {
        String[] datosBala1 = split(tokens[1], ':');
        if (datosBala1.length > 1) {
          int[] bala1 = { posicionTanque1[0], int(datosBala1[1]) };  // Agregar la posición de la bala del tanque 1
          balas.add(bala1);
        }
      }
      
      if (tokens.length > 3) {
        String[] datosBala2 = split(tokens[3], ':');
        if (datosBala2.length > 1) {
          int[] bala2 = { posicionTanque2[0], int(datosBala2[1]) };  // Agregar la posición de la bala del tanque 2
          balas.add(bala2);
        }
      }
      
      // Actualizar las posiciones de los obstáculos
      obstaculos.clear();
      for (int i = 4; i < tokens.length; i++) {
        String[] datosObstaculo = split(tokens[i], ':');
        int[] obstaculo = { int(datosObstaculo[1]), i - 4};
        obstaculos.add(obstaculo);
      }
    }
  }

  // Mostrar y mover los obstáculos
  fill(255, 0, 0);
  for (int[] obstaculo : obstaculos) {
    ellipse(obstaculo[0] * 20, obstaculo[1] * 20, 15, 15);
    obstaculo[1]++;  // Los obstáculos caen lentamente
    if (obstaculo[1] > height) obstaculo[1] = 0; // Resetea si salen de la pantalla
  }

  // Mostrar las balas y moverlas hacia arriba
  fill(255);
  
  // Crear una lista para almacenar las balas que deben eliminarse
  ArrayList<int[]> balasAEliminar = new ArrayList<int[]>();
  
  for (int[] bala : balas) {
    ellipse(bala[0] * 20, bala[1] - 10, 5, 5);  // Mover balas hacia arriba
    bala[1]--;  // Desplaza la bala hacia arriba
    if (bala[1] < 0) {
      balasAEliminar.add(bala);  // Añadir la bala a la lista de eliminación
    }
  }
  
  // Eliminar las balas fuera de la pantalla
  for (int[] bala : balasAEliminar) {
    balas.remove(bala);
  }

  // Mostrar los tanques
  fill(0, 255, 0);
  rect(posicionTanque1[0] * 20, posicionTanque1[1], 20, 10);  // Tanque 1
  rect(posicionTanque2[0] * 20, posicionTanque2[1], 20, 10);  // Tanque 2
}
