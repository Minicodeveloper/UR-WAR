import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/robot.dart';
import '../providers/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'ARENA TÁCTICA - TURNO ${gameState.currentTurn}',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reiniciar Partida',
            onPressed: () => gameState.resetGame(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner de registro de acciones y logs
            if (gameState.logs != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  gameState.logs!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFA8DADC),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Tablero de juego interactivo con soporte de deslizamiento táctil (Swipe)
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanEnd: (details) {
                    final velocity = details.velocity.pixelsPerSecond;
                    if (velocity.dx.abs() > velocity.dy.abs()) {
                      if (velocity.dx > 80) {
                        gameState.moveInDirection(1, 0);
                      } else if (velocity.dx < -80) {
                        gameState.moveInDirection(-1, 0);
                      }
                    } else {
                      if (velocity.dy > 80) {
                        gameState.moveInDirection(0, 1);
                      } else if (velocity.dy < -80) {
                        gameState.moveInDirection(0, -1);
                      }
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A23),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF457B9D), width: 3),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 64,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                        itemBuilder: (context, index) {
                          int x = index % 8;
                          int y = index ~/ 8;

                          Robot? robot = gameState.robots
                              .where((r) => r.x == x && r.y == y && r.hp > 0)
                              .firstOrNull;

                          bool isSelected = robot != null && robot.id == gameState.selectedRobotId;
                          bool isPlayer = robot != null && robot.id.startsWith('p');

                          return GestureDetector(
                            onTap: () => gameState.onCellTapped(x, y),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFD166).withValues(alpha: 0.3)
                                    : ((x + y) % 2 == 0
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : Colors.transparent),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFD166)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: isSelected ? 2.5 : 0.5,
                                ),
                              ),
                              child: robot != null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Icono de Robot
                                        Icon(
                                          Icons.smart_toy_rounded,
                                          size: 28,
                                          color: isPlayer
                                              ? const Color(0xFF00BBF9)
                                              : const Color(0xFFEF233C),
                                        ),
                                        const SizedBox(height: 2),

                                        // Barra de Salud de la Unidad
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: (robot.hp / robot.maxHp).clamp(0.0, 1.0),
                                              minHeight: 4,
                                              backgroundColor: Colors.black45,
                                              valueColor: AlwaysStoppedAnimation(
                                                isPlayer ? Colors.green : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Badge de Puntos de Acción
                                        if (isPlayer)
                                          Text(
                                            '⚡${robot.actionPoints}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFFFD166),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pad Direccional Táctil para Celulares en Arena Táctica
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.arrow_left_rounded, size: 28),
                    onPressed: () => gameState.moveInDirection(-1, 0),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_drop_up_rounded, size: 28),
                        onPressed: () => gameState.moveInDirection(0, -1),
                      ),
                      const SizedBox(height: 4),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
                        onPressed: () => gameState.moveInDirection(0, 1),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.arrow_right_rounded, size: 28),
                    onPressed: () => gameState.moveInDirection(1, 0),
                  ),
                ],
              ),
            ),

            // Modal de fin de juego si terminó la partida táctica
            if (gameState.isGameOver)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD166), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gameState.winnerMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD166),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => gameState.resetGame(),
                      child: const Text('REINICIAR'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: gameState.endTurn,
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.skip_next_rounded),
        label: const Text('PASAR TURNO'),
      ),
    );
  }
}