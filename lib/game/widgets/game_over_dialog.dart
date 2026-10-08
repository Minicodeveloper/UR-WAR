import 'package:flutter/material.dart';
import '../logic/game_engine.dart';

class GameOverDialog extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback? onNextLevel;
  const GameOverDialog({
    super.key,
    required this.engine,
    required this.onRestart,
    required this.onExit,
    this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final victory = engine.isVictory;
    final color = victory ? const Color(0xFFC7AD79) : const Color(0xFFC57C69);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              color: const Color(0xFF1C201F),
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      victory ? Icons.emoji_events : Icons.shield_outlined,
                      color: color,
                      size: 42,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      victory ? '¡VICTORIA!' : 'LA DEFENSA HA CAÍDO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 23,
                        fontFamily: 'Cinzel',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      victory
                          ? 'Objetivos completados. Tu progreso se ha guardado.'
                          : engine.player.health <= 0
                          ? 'Tu héroe cayó en combate. Refuerza tus defensas e inténtalo otra vez.'
                          : 'El corazón de la aldea fue destruido. Repara y protege sus accesos.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    _stat(
                      'Oleadas completadas',
                      '${engine.completedWaves}/${engine.map.totalWaves}',
                    ),
                    _stat('Enemigos eliminados', '${engine.player.kills}'),
                    _stat(
                      'Campamentos destruidos',
                      '${engine.rivalCamps.where((c) => c.isDestroyed).length}/${engine.rivalCamps.length}',
                    ),
                    _stat('Nivel del héroe', '${engine.player.level}'),
                    _stat('Oro disponible', '${engine.player.gold}'),
                    _stat('Puntuación', '${engine.player.score}'),
                    const SizedBox(height: 18),
                    if (victory && onNextLevel != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onNextLevel,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('SIGUIENTE NIVEL'),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onRestart,
                        child: Text(victory ? 'VOLVER A JUGAR' : 'REINTENTAR'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onExit,
                        child: const Text('MENÚ PRINCIPAL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white60)),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
