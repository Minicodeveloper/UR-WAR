import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../game/models/game_map.dart';
import '../game/models/player_class.dart';
import 'village_defense_screen.dart';

class MapSelectScreen extends StatefulWidget {
  final PlayerClass selectedClass;

  const MapSelectScreen({
    super.key,
    required this.selectedClass,
  });

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final maps = GameMapModel.availableMaps;
    final selectedMap = maps[_selectedIndex];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'SELECCIÓN DE MAPA Y TERRITORIO',
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Héroe elegido: ${widget.selectedClass.name} | Selecciona la aldea que vas a fortificar',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

            // Lista vertical de mapas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: maps.length,
                itemBuilder: (context, index) {
                  final map = maps[index];
                  final isSelected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? map.wallColor.withValues(alpha: 0.25)
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFD166) : Colors.white12,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  map.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(map.difficultyText).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _getDifficultyColor(map.difficultyText)),
                                ),
                                child: Text(
                                  map.difficultyText,
                                  style: TextStyle(
                                    color: _getDifficultyColor(map.difficultyText),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            map.subtitle,
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            map.description,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildBadge(Icons.flag_rounded, '${map.totalWaves} Oleadas'),
                              _buildBadge(Icons.landscape_rounded, _getBiomeLabel(map.biome)),
                              _buildBadge(Icons.fort_rounded, 'Aldea Fortificada'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botón de Inicio de Partida
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VillageDefenseScreen(
                          mapModel: selectedMap,
                          playerClass: widget.selectedClass,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shield_rounded, size: 26),
                  label: const Text(
                    '¡COMENZAR DEFENSA DE LA ALDEA!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    if (diff.contains('Normal')) return const Color(0xFF55A630);
    if (diff.contains('Desafiante')) return const Color(0xFFFFB703);
    return const Color(0xFFE63946);
  }

  String _getBiomeLabel(MapBiomeType biome) {
    switch (biome) {
      case MapBiomeType.forest:
        return 'Bosque Templado';
      case MapBiomeType.snow:
        return 'Cumbres Nevadas';
      case MapBiomeType.lava:
        return 'Garganta Volcánica';
    }
  }

  Widget _buildBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
