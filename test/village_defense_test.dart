import 'package:flutter_test/flutter_test.dart';
import 'package:ur_war/game/logic/game_engine.dart';
import 'package:ur_war/game/models/game_map.dart';
import 'package:ur_war/game/models/player_class.dart';
import 'package:ur_war/game/models/entity.dart';
import 'package:ur_war/providers/game_state.dart';

void main() {
  group('Village Defense RPG & Exploration Tests', () {
    test('Available player classes have RPG skill trees and stats', () {
      final classes = PlayerClass.availableClasses;
      expect(classes.length, 4);

      final knight = classes.firstWhere((c) => c.type == PlayerRoleType.knight);
      expect(knight.skillTree.length, 3);
      expect(knight.skillTree.last.isUltimate, isTrue);
    });

    test('Campaign levels feature rival camps and fog of war', () {
      final maps = GameMapModel.availableMaps;
      expect(maps.length, 5);

      final level1 = maps.first;
      expect(level1.levelIndex, 1);
      expect(level1.rivalCamps.isNotEmpty, isTrue);
    });

    test('GameEngine initializes RPG leveling and Fog of War', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      expect(engine.player.level, 1);
      expect(engine.player.xp, 0);
      expect(engine.rivalCamps.isNotEmpty, isTrue);
    });

    test('Hero levels up when gaining XP and receives Skill Points', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      expect(engine.player.level, 1);
      engine.player.addXp(150);

      expect(engine.player.level, 2);
      expect(engine.player.skillPoints, 1);
    });

    test('Building new structures costs gold and adds to village buildings', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      engine.player.gold = 200;
      final initialBuildingsCount = engine.villageBuildings.length;

      final built = engine.buildStructure(BuildingType.watchtower, 100);
      expect(built, isTrue);
      expect(engine.player.gold, 100);
      expect(engine.villageBuildings.length, initialBuildingsCount + 1);
    });
  });

  group('Tactical Arena Robot Turn Tests', () {
    test('GameState initializes player and enemy robots correctly', () {
      final gameState = GameState();
      expect(gameState.robots.length, 2);
      expect(gameState.currentTurn, 1);
      expect(gameState.isGameOver, isFalse);
    });

    test('Player can select robot, move and end turn cleanly', () {
      final gameState = GameState();
      final playerRobot = gameState.robots.firstWhere((r) => r.id.startsWith('p'));

      // Select player robot
      gameState.onCellTapped(playerRobot.x, playerRobot.y);
      expect(gameState.selectedRobotId, playerRobot.id);

      // Move to adjacent cell
      gameState.onCellTapped(playerRobot.x + 1, playerRobot.y);
      expect(playerRobot.x, 2);

      // End turn
      gameState.endTurn();
      expect(gameState.currentTurn, 2);
    });
  });
}
