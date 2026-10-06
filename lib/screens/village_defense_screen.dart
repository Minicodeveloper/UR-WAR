import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../game/graphics/battlefield_painter.dart';
import '../game/logic/game_engine.dart';
import '../game/models/game_map.dart';
import '../game/models/player_class.dart';
import '../game/widgets/game_hud.dart';
import '../game/widgets/game_over_dialog.dart';
import '../game/widgets/village_shop_dialog.dart';

class VillageDefenseScreen extends StatefulWidget {
  final GameMapModel mapModel;
  final PlayerClass playerClass;

  const VillageDefenseScreen({
    super.key,
    required this.mapModel,
    required this.playerClass,
  });

  @override
  State<VillageDefenseScreen> createState() => _VillageDefenseScreenState();
}

class _VillageDefenseScreenState extends State<VillageDefenseScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Entrada de movimiento (combina joystick táctil y teclado físico)
  Offset _joystickDirection = Offset.zero;
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(
      map: widget.mapModel,
      playerClass: widget.playerClass,
    );

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final dt = (_lastElapsed == Duration.zero)
        ? 0.016
        : (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Limitar delta time para evitar saltos si hay pausas o pérdidas de foco
    final clampedDt = dt.clamp(0.001, 0.05);

    // Calcular dirección efectiva combinando teclado y joystick
    final keyboardDir = _calculateKeyboardDirection();
    final effectiveDir = keyboardDir != Offset.zero ? keyboardDir : _joystickDirection;

    _engine.movePlayer(effectiveDir, clampedDt);
    _engine.update(clampedDt);
  }

  Offset _calculateKeyboardDirection() {
    double dx = 0.0;
    double dy = 0.0;

    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dy += 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dx += 1.0;
    }

    if (dx == 0 && dy == 0) return Offset.zero;
    final length = Offset(dx, dy).distance;
    return Offset(dx / length, dy / length);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      // Teclas de acción rápida
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyJ) {
        _engine.attack();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyK ||
          event.logicalKey == LogicalKeyboardKey.keyE) {
        _engine.useSpecialSkill();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyB) {
        showDialog(
          context: context,
          builder: (ctx) => VillageShopDialog(engine: _engine),
        );
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        _engine.togglePause();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }

    return KeyEventResult.ignored;
  }

  void _restartGame() {
    setState(() {
      _engine = GameEngine(
        map: widget.mapModel,
        playerClass: widget.playerClass,
      );
      _pressedKeys.clear();
      _joystickDirection = Offset.zero;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            _engine.setViewportSize(Size(constraints.maxWidth, constraints.maxHeight));

            return Stack(
              children: [
                // 1. Lienzo gráfico del campo de batalla
                Positioned.fill(
                  child: CustomPaint(
                    painter: BattlefieldPainter(engine: _engine),
                  ),
                ),

                // 2. HUD y controles táctiles
                Positioned.fill(
                  child: GameHUD(
                    engine: _engine,
                    onJoystickDirection: (dir) {
                      _joystickDirection = dir;
                    },
                  ),
                ),

                // 3. Modal de Victoria / Derrota
                AnimatedBuilder(
                  animation: _engine,
                  builder: (context, _) {
                    if (_engine.isGameOver || _engine.isVictory) {
                      return Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.75),
                          child: GameOverDialog(
                            engine: _engine,
                            onRestart: _restartGame,
                            onExit: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
