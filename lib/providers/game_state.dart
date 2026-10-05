import 'package:flutter/foundation.dart';
import '../models/robot.dart'; 

class GameState extends ChangeNotifier {
  final int boardSize = 8; 
  List<Robot> robots = []; 
  int currentTurn = 1;     

  // NUEVO: Una variable para recordar qué robot hemos seleccionado.
  // Tiene un '?' porque al inicio no hay nadie seleccionado (es null).
  String? selectedRobotId; 

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    robots.add(Robot(id: 'player_1', name: 'Alpha', x: 0, y: 0));
    robots.add(Robot(id: 'enemy_1', name: 'Omega', x: 7, y: 7));
    notifyListeners();
  }

  // NUEVO: Función que se ejecuta cuando el jugador toca una casilla (x, y)
  void onCellTapped(int x, int y) {
    // 1. Miramos si hay algún robot en la casilla que el usuario acaba de tocar
    var robotAtCell = robots.where((r) => r.x == x && r.y == y).firstOrNull;

    if (selectedRobotId == null) {
      // FASE DE SELECCIÓN: Si no hay nadie seleccionado...
      // Y tocamos un robot nuestro (su ID empieza con 'p' de player)
      if (robotAtCell != null && robotAtCell.id.startsWith('p')) {
        selectedRobotId = robotAtCell.id; // Lo seleccionamos
        notifyListeners(); // Avisamos a la pantalla
      }
    } else {
      // FASE DE MOVIMIENTO: Si YA teníamos un robot seleccionado...
      
      if (robotAtCell == null) {
        // A) Tocamos una casilla vacía: ¡Nos movemos!
        // Buscamos al robot seleccionado en nuestra lista
        var selectedRobot = robots.firstWhere((r) => r.id == selectedRobotId);
        
        // NUEVO: LA REGLA DE MEDIR
        // Usamos .abs() que significa "Valor Absoluto" (convierte números negativos a positivos)
        // Calculamos cuántos cuadros de distancia hay entre el robot y el lugar que tocaste
        int distanceX = (selectedRobot.x - x).abs();
        int distanceY = (selectedRobot.y - y).abs();

        // Si sumas la distancia X y la Y, y da exactamente 1...
        // ¡Significa que tocaste la casilla justo al lado! (No en diagonal)
        bool isOneStep = (distanceX + distanceY) == 1;

        // NUEVO: LA BATERÍA (Puntos de Acción)
        // Solo nos movemos si tocaste a 1 paso de distancia Y si el robot tiene puntos de acción
        if (isOneStep && selectedRobot.actionPoints > 0) {
            selectedRobot.x = x;
            selectedRobot.y = y;

            // Le quitamos 1 Punto de Acción por hacer el movimiento
            selectedRobot.actionPoints -= 1;
            selectedRobotId = null; // Lo soltamos
            notifyListeners();
        } else {
            // Si tocas muy lejos o no tiene puntos de accción, simplemente lo deseleccionamos
            selectedRobotId = null;
            notifyListeners();
        }

      } else if (robotAtCell.id == selectedRobotId) {
        selectedRobotId = null;
        notifyListeners();
        }
      }
    }

    // NUEVO: Función ppara que primero juegue el enemigo 
    void endTurn() {
        // 1. ¡EL ENEMIGO ACTÚA PRIMERO!
        _playEnemyTurn();

        // 2. PREPARAMOS EL SIGUIENTE TURNO (Para el jugador)
        currentTurn++; 
        for (var robot in robots) {
            robot.actionPoints = 3; // Ambos recuperan su energía
        }

        selectedRobotId = null; // Deseleccionamos si había algún robot marcado
        notifyListeners(); // ¡Gritamos por el megáfono para que la pantalla se actualice!
    }

    // NUEVO: La inteligencia Artificial del Enemigo
    void _playEnemyTurn() {
        // 1. Identificamos quién es quién en la lista
        var player = robots.firstWhere((r) => r.id.startsWith('p'));
        var enemy = robots.firstWhere((r) => r.id.startsWith('e'));

        // 2. El enemigo usa sus puntos de acción uno por uno
        while (enemy.actionPoints > 0) {
            // Calculamos la diferencia matemática entre las coordenas
            int distanceX = player.x - enemy.x;
            int distanceY = player.y - enemy.y;

            // Si la suma de las distancias es 1, ¡ya está pegado al jugador!
            // Si está más lejos es horizontal, se mueve en X. Si no, en Y.
            if (distanceX.abs() > distanceY.abs()) {
                // .sign es un truco de Dart: devuelve 1 si es positivo, o -1 si es negativo
                enemy.x += distanceX.sign;
            } else {
                enemy.y += distanceY.sign;
            }

            // Gasta 1 punto de acción por el paso dado
            enemy.actionPoints--;
        }
    }
  }
