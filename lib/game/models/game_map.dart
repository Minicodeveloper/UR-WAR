import 'package:flutter/material.dart';

enum MapBiomeType {
  forest,
  snow,
  lava,
}

class MapObstacle {
  final Offset position;
  final double radius;
  final String type; // 'tree', 'rock', 'water', 'bonfire'

  const MapObstacle({
    required this.position,
    required this.radius,
    required this.type,
  });
}

class GameMapModel {
  final String id;
  final String name;
  final String subtitle;
  final String difficultyText;
  final String description;
  final MapBiomeType biome;
  final double worldWidth;
  final double worldHeight;
  final Color groundColor;
  final Color groundAccentColor;
  final Color pathColor;
  final Color wallColor;
  final int totalWaves;
  final List<MapObstacle> obstacles;

  const GameMapModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.difficultyText,
    required this.description,
    required this.biome,
    required this.worldWidth,
    required this.worldHeight,
    required this.groundColor,
    required this.groundAccentColor,
    required this.pathColor,
    required this.wallColor,
    required this.totalWaves,
    required this.obstacles,
  });

  static List<GameMapModel> get availableMaps => [
        GameMapModel(
          id: 'emerald_valley',
          name: 'Valle Esmeralda',
          subtitle: 'Corazón del Bosque Sagrado',
          difficultyText: 'Normal (Recomendado)',
          description:
              'Una pradera ancestral rodeada de densos robles. La aldea cuenta con empalizadas de madera y torres de vigía.',
          biome: MapBiomeType.forest,
          worldWidth: 1500,
          worldHeight: 1200,
          groundColor: const Color(0xFF1E3A2B),
          groundAccentColor: const Color(0xFF28543E),
          pathColor: const Color(0xFF5E503F),
          wallColor: const Color(0xFF7F4F24),
          totalWaves: 5,
          obstacles: [
            const MapObstacle(position: Offset(250, 250), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(320, 220), radius: 34, type: 'tree'),
            const MapObstacle(position: Offset(1250, 260), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(1320, 310), radius: 34, type: 'tree'),
            const MapObstacle(position: Offset(260, 950), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(320, 1020), radius: 34, type: 'tree'),
            const MapObstacle(position: Offset(1240, 960), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(1300, 900), radius: 34, type: 'tree'),
            const MapObstacle(position: Offset(520, 320), radius: 24, type: 'rock'),
            const MapObstacle(position: Offset(980, 880), radius: 24, type: 'rock'),
          ],
        ),
        GameMapModel(
          id: 'frost_bastion',
          name: 'Bastión Nevado',
          subtitle: 'Cumbres Gélidas de Niflheim',
          difficultyText: 'Desafiante',
          description:
              'Montañas heladas cubiertas de nieve perpetua. La ventisca reduce la visibilidad y los orcos son más resistentes.',
          biome: MapBiomeType.snow,
          worldWidth: 1500,
          worldHeight: 1200,
          groundColor: const Color(0xFF2B3A4A),
          groundAccentColor: const Color(0xFF3A4F63),
          pathColor: const Color(0xFF6C7A89),
          wallColor: const Color(0xFF495057),
          totalWaves: 6,
          obstacles: [
            const MapObstacle(position: Offset(240, 240), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(1260, 240), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(240, 960), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(1260, 960), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(750, 300), radius: 28, type: 'bonfire'),
            const MapObstacle(position: Offset(750, 900), radius: 28, type: 'bonfire'),
          ],
        ),
        GameMapModel(
          id: 'infernal_crag',
          name: 'Garganta Ardiente',
          subtitle: 'Tierras Volcánicas de Fuego y Azufre',
          difficultyText: 'Extrema / Pesadilla',
          description:
              'Suelo de basalto agrietado con ríos de magma. Oleadas densas y jefes despiadados acechan desde cada rincón.',
          biome: MapBiomeType.lava,
          worldWidth: 1600,
          worldHeight: 1300,
          groundColor: const Color(0xFF261818),
          groundAccentColor: const Color(0xFF381D1D),
          pathColor: const Color(0xFF4A2828),
          wallColor: const Color(0xFF6B1D1D),
          totalWaves: 7,
          obstacles: [
            const MapObstacle(position: Offset(300, 300), radius: 40, type: 'rock'),
            const MapObstacle(position: Offset(1300, 300), radius: 40, type: 'rock'),
            const MapObstacle(position: Offset(300, 1000), radius: 40, type: 'rock'),
            const MapObstacle(position: Offset(1300, 1000), radius: 40, type: 'rock'),
            const MapObstacle(position: Offset(550, 500), radius: 30, type: 'lava'),
            const MapObstacle(position: Offset(1050, 750), radius: 30, type: 'lava'),
          ],
        ),
      ];
}
