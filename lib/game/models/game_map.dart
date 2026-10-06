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

class RivalCampConfig {
  final String name;
  final Offset position;
  final int level;

  const RivalCampConfig({
    required this.name,
    required this.position,
    required this.level,
  });
}

class GameMapModel {
  final String id;
  final int levelIndex;
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
  final List<RivalCampConfig> rivalCamps;

  const GameMapModel({
    required this.id,
    required this.levelIndex,
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
    required this.rivalCamps,
  });

  static List<GameMapModel> get availableMaps => [
        GameMapModel(
          id: 'level_1_forest',
          levelIndex: 1,
          name: 'Nivel 1: Valle Esmeralda',
          subtitle: 'Corazón del Bosque Sagrado',
          difficultyText: 'Fácil (Iniciación)',
          description:
              'Explora los alrededores de la aldea, elimina la avanzada goblin y defiende el Salón Comunal.',
          biome: MapBiomeType.forest,
          worldWidth: 1600,
          worldHeight: 1300,
          groundColor: const Color(0xFF1E3A2B),
          groundAccentColor: const Color(0xFF28543E),
          pathColor: const Color(0xFF5E503F),
          wallColor: const Color(0xFF7F4F24),
          totalWaves: 4,
          obstacles: [
            const MapObstacle(position: Offset(250, 250), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(1350, 260), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(260, 1050), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(1340, 1060), radius: 36, type: 'tree'),
            const MapObstacle(position: Offset(520, 320), radius: 24, type: 'rock'),
          ],
          rivalCamps: [
            const RivalCampConfig(name: 'Campamento Goblin del Norte', position: Offset(800, 180), level: 1),
            const RivalCampConfig(name: 'Guarida Salvaje del Sur', position: Offset(800, 1120), level: 1),
          ],
        ),
        GameMapModel(
          id: 'level_2_orcs',
          levelIndex: 2,
          name: 'Nivel 2: Asedio Berserker',
          subtitle: 'Frontera de los Orcos',
          difficultyText: 'Normal',
          description:
              'Los orcos han establecido fortalezas rivales en los flancos este y oeste. Explora el mapa para destruirlas.',
          biome: MapBiomeType.forest,
          worldWidth: 1800,
          worldHeight: 1400,
          groundColor: const Color(0xFF234230),
          groundAccentColor: const Color(0xFF2E5941),
          pathColor: const Color(0xFF6B5844),
          wallColor: const Color(0xFF8D5B2E),
          totalWaves: 5,
          obstacles: [
            const MapObstacle(position: Offset(300, 300), radius: 40, type: 'tree'),
            const MapObstacle(position: Offset(1500, 300), radius: 40, type: 'tree'),
            const MapObstacle(position: Offset(300, 1100), radius: 40, type: 'tree'),
            const MapObstacle(position: Offset(1500, 1100), radius: 40, type: 'tree'),
          ],
          rivalCamps: [
            const RivalCampConfig(name: 'Bastión Orco del Este', position: Offset(1550, 700), level: 2),
            const RivalCampConfig(name: 'Bastión Orco del Oeste', position: Offset(250, 700), level: 2),
          ],
        ),
        GameMapModel(
          id: 'level_3_snow',
          levelIndex: 3,
          name: 'Nivel 3: Bastión Nevado',
          subtitle: 'Cumbres Gélidas de Niflheim',
          difficultyText: 'Desafiante',
          description:
              'La niebla de guerra es más densa en las cumbres heladas. Construye minas de oro y torres para aguantar la ventisca.',
          biome: MapBiomeType.snow,
          worldWidth: 1800,
          worldHeight: 1400,
          groundColor: const Color(0xFF2B3A4A),
          groundAccentColor: const Color(0xFF3A4F63),
          pathColor: const Color(0xFF6C7A89),
          wallColor: const Color(0xFF495057),
          totalWaves: 6,
          obstacles: [
            const MapObstacle(position: Offset(240, 240), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(1560, 240), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(240, 1160), radius: 32, type: 'rock'),
            const MapObstacle(position: Offset(1560, 1160), radius: 32, type: 'rock'),
          ],
          rivalCamps: [
            const RivalCampConfig(name: 'Campamento Esqueleto Helado', position: Offset(900, 180), level: 3),
            const RivalCampConfig(name: 'Fortaleza del Hielo del Sur', position: Offset(900, 1220), level: 3),
          ],
        ),
        GameMapModel(
          id: 'level_4_necro',
          levelIndex: 4,
          name: 'Nivel 4: Fortaleza Oscura',
          subtitle: 'Tierra de Nigromantes y Sombras',
          difficultyText: 'Difícil',
          description:
              'Múltiples fortalezas enemigas asedian la aldea. Los nigromantes invocan ráfagas mágicas continuas.',
          biome: MapBiomeType.lava,
          worldWidth: 1900,
          worldHeight: 1500,
          groundColor: const Color(0xFF221622),
          groundAccentColor: const Color(0xFF352035),
          pathColor: const Color(0xFF4A304A),
          wallColor: const Color(0xFF6B2D6B),
          totalWaves: 7,
          obstacles: [
            const MapObstacle(position: Offset(300, 300), radius: 40, type: 'rock'),
            const MapObstacle(position: Offset(1600, 300), radius: 40, type: 'rock'),
          ],
          rivalCamps: [
            const RivalCampConfig(name: 'Círculo Nigromántico del Norte', position: Offset(950, 180), level: 4),
            const RivalCampConfig(name: 'Bastión Sombrío del Este', position: Offset(1650, 750), level: 4),
            const RivalCampConfig(name: 'Bastión Sombrío del Oeste', position: Offset(250, 750), level: 4),
          ],
        ),
        GameMapModel(
          id: 'level_5_titan',
          levelIndex: 5,
          name: 'Nivel 5: Volcán del Titán',
          subtitle: 'La Batalla Final por la Supervivencia',
          difficultyText: 'Extrema / Pesadilla',
          description:
              'Ríos de magma y la llegada del Titán Destructor. Expande tus defensas al máximo o sucumbe en el fuego.',
          biome: MapBiomeType.lava,
          worldWidth: 2000,
          worldHeight: 1600,
          groundColor: const Color(0xFF261818),
          groundAccentColor: const Color(0xFF381D1D),
          pathColor: const Color(0xFF4A2828),
          wallColor: const Color(0xFF6B1D1D),
          totalWaves: 8,
          obstacles: [
            const MapObstacle(position: Offset(350, 350), radius: 45, type: 'lava'),
            const MapObstacle(position: Offset(1650, 1250), radius: 45, type: 'lava'),
          ],
          rivalCamps: [
            const RivalCampConfig(name: 'Fortaleza Volcánica del Titán', position: Offset(1000, 200), level: 5),
            const RivalCampConfig(name: 'Asedio de Fuego del Sur', position: Offset(1000, 1400), level: 5),
            const RivalCampConfig(name: 'Nido de Demonios del Este', position: Offset(1750, 800), level: 5),
          ],
        ),
      ];
}
