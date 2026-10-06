import 'package:flutter_test/flutter_test.dart';
import 'package:ur_war/game/logic/game_engine.dart';
import 'package:ur_war/game/models/game_map.dart';
import 'package:ur_war/game/models/player_class.dart';

void main() {
  group('Village Defense Game Mechanics Tests', () {
    test('Available player classes are configured with stats and skills', () {
      final classes = PlayerClass.availableClasses;
      expect(classes.length, 4);

      final knight = classes.firstWhere((c) => c.type == PlayerRoleType.knight);
      expect(knight.name, 'Caballero Imperial');
      expect(knight.isMelee, isTrue);
      expect(knight.maxHealth, greaterThan(200));

      final ranger = classes.firstWhere((c) => c.type == PlayerRoleType.ranger);
      expect(ranger.name, 'Cazadora Silvana');
      expect(ranger.isMelee, isFalse);
      expect(ranger.attackRange, greaterThan(250));
    });

    test('Available maps are configured with biomes and wave counts', () {
      final maps = GameMapModel.availableMaps;
      expect(maps.length, 3);

      final forest = maps.firstWhere((m) => m.id == 'emerald_valley');
      expect(forest.biome, MapBiomeType.forest);
      expect(forest.totalWaves, greaterThanOrEqualTo(5));

      final snow = maps.firstWhere((m) => m.id == 'frost_bastion');
      expect(snow.biome, MapBiomeType.snow);

      final lava = maps.firstWhere((m) => m.id == 'infernal_crag');
      expect(lava.biome, MapBiomeType.lava);
    });

    test('GameEngine initializes town hall and hero at center of map', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      expect(engine.player.health, pClass.maxHealth);
      expect(engine.townHall.health, 1200);
      expect(engine.villageBuildings.isNotEmpty, isTrue);
      expect(engine.isGameOver, isFalse);
      expect(engine.isVictory, isFalse);
    });

    test('Player can move, attack and take damage', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      final initialPos = engine.player.position;
      engine.movePlayer(const Offset(1, 0), 0.1);
      expect(engine.player.position.dx, greaterThan(initialPos.dx));

      engine.attack();
      expect(engine.player.attackTimer, greaterThan(0));

      engine.player.takeDamage(50);
      expect(engine.player.health, pClass.maxHealth - 50);

      engine.player.heal(30);
      expect(engine.player.health, pClass.maxHealth - 20);
    });

    test('Special skill executes and initiates cooldown', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first; // Knight
      final engine = GameEngine(map: map, playerClass: pClass);

      expect(engine.player.specialSkillTimer, 0.0);
      engine.useSpecialSkill();
      expect(engine.player.specialSkillTimer, greaterThan(0.0));
    });

    test('Village shop allows repairing village and upgrading stats with gold', () {
      final map = GameMapModel.availableMaps.first;
      final pClass = PlayerClass.availableClasses.first;
      final engine = GameEngine(map: map, playerClass: pClass);

      // Give player gold
      engine.player.gold = 300;
      engine.townHall.takeDamage(400);

      final repaired = engine.repairVillage(75, 300);
      expect(repaired, isTrue);
      expect(engine.player.gold, 225);
      expect(engine.townHall.health, 1100);

      final upgradedDmg = engine.upgradeHeroDamage(100);
      expect(upgradedDmg, isTrue);
      expect(engine.player.damageMultiplier, 1.25);
    });
  });
}
