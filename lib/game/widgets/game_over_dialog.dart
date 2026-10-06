import 'package:flutter/material.dart';
import '../logic/game_engine.dart';

class GameOverDialog extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.engine,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = engine.isVictory;
    final player = engine.player;

    final primaryColor = isVictory ? const Color(0xFFFFD166) : const Color(0xFFE63946);
    final title = isVictory ? '¡VICTORIA ÉPICA!' : '¡LA ALDEA HA CAÍDO!';
    final subtitle = isVictory
        ? 'Has defendido con honor la aldea y purgado a todos los invasores.'
        : 'Los monstruos arrasaron el Salón Comunal o tu héroe sucumbió en batalla.';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF161A23),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVictory ? Icons.emoji_events_rounded : Icons.shield_outlined,
                size: 64,
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Estadísticas de la partida
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF222838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Oleadas Resistidas', '${engine.waveSystem.currentWave} / ${engine.map.totalWaves}'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Enemigos Eliminados', '${player.kills}'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Oro Recolectado', '${player.gold} 🪙'),
                    const Divider(color: Colors.white10),
                    _buildStatRow('Puntuación Total', '${player.score} PTS', isHighlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onExit,
                      child: const Text('MENÚ PRINCIPAL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isVictory ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onRestart,
                      child: const Text('REINTENTAR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? const Color(0xFFFFD166) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
