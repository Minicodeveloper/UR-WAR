import 'package:flutter/material.dart';

// 1. Importamos nuestra herramienta de comunicación y nuestro cerebro
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/robot.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. ¡SINTONIZAMOS LA RADIO!
    // Al usar "watch", esta pantalla se quedará escuchando. 
    // Cuando GameState grite "notifyListeners()", esta pantalla se redibujará sola.
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        // NUEVO: El texto ahora es dinámico y lee el turno actual del GameState
        title: Text('Arena Táctica - Turno ${gameState.currentTurn}'),
      ),
      // Centramos nuestro tablero en la pantalla
      body: Center(
        // 3. GridView es el componente de Flutter perfecto para crear cuadrículas
        child: GridView.builder(
          itemCount: 64, // 8 filas x 8 columnas = 64 casillas
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8, // Le decimos que queremos 8 casillas por fila
          ),
          itemBuilder: (context, index) {
            // 4. MATEMÁTICAS SIMPLES: Convertimos el número de casilla (del 0 al 63) 
            // en coordenadas X (horizontal) y Y (vertical)
            int x = index % 8;
            int y = index ~/ 8; // El símbolo '~/' divide y nos da un número entero

            // 5. BUSCAMOS AL ROBOT: Le preguntamos al GameState si en la lista 
            // de robots hay alguno que tenga exactamente estas coordenadas 'x' e 'y'.
            Robot? robot = gameState.robots
                .where((r) => r.x == x && r.y == y)
                .firstOrNull;

           // NUEVO: Saber si ESTE robot específico es el que está seleccionado
            bool isSelected = robot != null && robot.id == gameState.selectedRobotId;

            // NUEVO: Envolvemos el Container en un GestureDetector
            return GestureDetector(
              onTap: () {
                // Cuando el usuario toque aquí, le avisamos al Cerebro las coordenadas
                gameState.onCellTapped(x, y);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  // Si está seleccionado lo pintamos de amarillo claro, si no, gris
                  color: isSelected ? Colors.yellow.shade200 : Colors.grey.shade100, 
                ),
                child: robot != null
                    ? Icon(
                        Icons.smart_toy, 
                        color: robot.id.startsWith('p') ? Colors.blue : Colors.red,
                      )
                    : null,
              ),
            );
          },
        ),
      ),

      // NUEVO: Agregamos el botón flotante en la esquina inferior
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Al presionar, ejecutamos la función que acabamos de crear
          gameState.endTurn();
        },
        label: const Text('Fin de Turno'),
        icon: const Icon(Icons.skip_next),
      ),
    ); // Aquí cierra el Scaffold
  }
}