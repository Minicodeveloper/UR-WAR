import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/realm_widgets.dart';
import '../providers/game_state.dart';
import '../game/graphics/pixel_art_data.dart';
import '../game/graphics/pixel_sprite_painter.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('ARENA · TURNO ${game.currentTurn}'),
        actions: [
          IconButton(
            onPressed: game.resetGame,
            tooltip: 'Reiniciar partida',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RealmBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > box.maxHeight * 1.3;
              final board = _board(game);
              final controls = _controls(game);
              return wide
                  ? Row(
                      children: [
                        Expanded(child: board),
                        SizedBox(
                          width: 250,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: controls,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: board),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: controls,
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _board(GameState game) => LayoutBuilder(
    builder: (context, box) {
      final side = math.min(box.maxWidth, box.maxHeight) - 24;
      return Center(
        child: SizedBox(
          width: side,
          height: side,
          child: GestureDetector(
            onPanEnd: (details) {
              final v = details.velocity.pixelsPerSecond;
              if (v.dx.abs() > v.dy.abs()) {
                if (v.dx.abs() > 80) game.moveInDirection(v.dx > 0 ? 1 : -1, 0);
              } else if (v.dy.abs() > 80) {
                game.moveInDirection(0, v.dy > 0 ? 1 : -1);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF222720),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 20),
                ],
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: 64,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: (context, index) {
                  final x = index % 8, y = index ~/ 8;
                  final robot = game.robots
                      .where((r) => r.x == x && r.y == y && r.hp > 0)
                      .firstOrNull;
                  final friendly = robot?.id.startsWith('p') ?? false;
                  final selected =
                      robot != null && robot.id == game.selectedRobotId;
                  return Semantics(
                    button: true,
                    label:
                        'Casilla ${x + 1}, ${y + 1}${robot == null
                            ? ''
                            : friendly
                            ? ', aliado'
                            : ', enemigo'}',
                    child: InkWell(
                      onTap: () => game.onCellTapped(x, y),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF625539)
                              : (x + y) % 2 == 0
                              ? const Color(0xFF363D30)
                              : const Color(0xFF252B25),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : const Color(0xFF454737),
                            width: .7,
                          ),
                        ),
                        child: robot == null
                            ? null
                            : LayoutBuilder(
                                builder: (context, cell) => Stack(
                                  children: [
                                    Positioned.fill(
                                      bottom: 6,
                                      child: FittedBox(
                                        child: PixelSpriteWidget(
                                          sprite: friendly
                                              ? PixelArtLibrary.knightIdle
                                              : PixelArtLibrary.bossTitan,
                                          pixelSize: 4,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 3,
                                      right: 3,
                                      bottom: 2,
                                      child: LinearProgressIndicator(
                                        value: (robot.hp / robot.maxHp).clamp(
                                          0,
                                          1,
                                        ),
                                        minHeight: 3,
                                        color: friendly
                                            ? const Color(0xFF94A480)
                                            : const Color(0xFFB36B57),
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                    if (friendly && cell.maxWidth >= 36)
                                      Positioned(
                                        top: 1,
                                        right: 2,
                                        child: Text(
                                          '${robot.actionPoints}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget _controls(GameState game) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'EL TABLERO DE GUERRA',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 16,
          color: AppTheme.accentColor,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        game.isGameOver
            ? game.winnerMessage
            : game.logs ??
                  'Selecciona a tu guardián. Mueve, ataca y administra tus acciones.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _direction(
            Icons.arrow_left_rounded,
            () => game.moveInDirection(-1, 0),
          ),
          _direction(
            Icons.arrow_drop_up_rounded,
            () => game.moveInDirection(0, -1),
          ),
          _direction(
            Icons.arrow_drop_down_rounded,
            () => game.moveInDirection(0, 1),
          ),
          _direction(
            Icons.arrow_right_rounded,
            () => game.moveInDirection(1, 0),
          ),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: game.isGameOver ? game.resetGame : game.endTurn,
          icon: Icon(game.isGameOver ? Icons.refresh : Icons.skip_next),
          label: Text(game.isGameOver ? 'REINICIAR' : 'PASAR TURNO'),
        ),
      ),
    ],
  );
  Widget _direction(IconData icon, VoidCallback action) =>
      IconButton.filledTonal(onPressed: action, icon: Icon(icon, size: 26));
}
