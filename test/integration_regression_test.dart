import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ur_war/core/save_system.dart';
import 'package:ur_war/game/logic/game_engine.dart';
import 'package:ur_war/game/models/enemy_type.dart';
import 'package:ur_war/game/models/entity.dart';
import 'package:ur_war/game/models/game_map.dart';
import 'package:ur_war/game/models/player_class.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GameEngine engine;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SaveSystem.initialize();
    engine = GameEngine(
      map: GameMapModel.availableMaps.first,
      playerClass: PlayerClass.availableClasses.first,
    );
  });
  tearDown(() => engine.dispose());

  test(
    'Preparation and pause do not spawn enemies or advance the simulation',
    () {
      for (var i = 0; i < 100; i++) {
        engine.update(.1);
      }
      expect(engine.enemies, isEmpty);
      engine.startNextWave();
      engine.setPaused(true);
      final time = engine.elapsedTime;
      engine.update(.2);
      expect(engine.elapsedTime, time);
      engine.setPaused(false);
      engine.update(.2);
      expect(engine.enemies, isNotEmpty);
    },
  );
  test('Melee enemies can hit the outside edge of a building', () {
    engine.player.position = engine.townHall.position + const Offset(500, 0);
    engine.enemies.add(
      EnemyEntity(
        id: 'siege',
        config: EnemyConfig.orc,
        position: engine.townHall.position + const Offset(70, 0),
      ),
    );
    final hp = engine.townHall.health;
    engine.update(.05);
    expect(engine.townHall.health, lessThan(hp));
  });

  test('Invalid and cancelled construction never charge gold', () {
    final gold = engine.player.gold;
    expect(engine.beginConstruction(BuildingType.watchtower, 100), isTrue);
    engine.setBuildPreview(engine.townHall.position);
    expect(engine.confirmConstruction(), isFalse);
    expect(engine.player.gold, gold);
    engine.cancelConstruction();
    expect(engine.pendingBuildingType, isNull);
    expect(engine.player.gold, gold);
    expect(engine.beginConstruction(BuildingType.watchtower, 1), isFalse);
  });
  test('A piercing projectile cannot damage the same target every frame', () {
    final enemy = EnemyEntity(
      id: 'test',
      config: EnemyConfig.orc,
      position: engine.player.position + const Offset(100, 0),
    );
    engine.enemies.add(enemy);
    final hp = enemy.health;
    engine.projectiles.add(
      ProjectileEntity(
        position: enemy.position,
        velocity: Offset.zero,
        damage: 10,
        color: Colors.white,
        isFromPlayer: true,
        pierceCount: 3,
      ),
    );
    engine.update(.1);
    expect(enemy.health, hp - 10);
  });
  test('Hazards warn before damage and dodge protects the player', () {
    final hp = engine.player.health;
    engine.hazards.add(
      HazardEntity(
        position: engine.player.position,
        radius: 100,
        damage: 30,
        color: Colors.red,
        delay: .2,
      ),
    );
    engine.update(.1);
    expect(engine.player.health, hp);
    engine.player.shieldTimer = 1;
    engine.update(.2);
    expect(engine.player.health, hp);
  });
  test('Profile persists settings and keeps best campaign results', () async {
    SaveSystem.setMusicVolume(.2);
    SaveSystem.completeLevel('test', levelNumber: 1, stars: 3, score: 500);
    SaveSystem.completeLevel('test', levelNumber: 1, stars: 1, score: 100);
    await SaveSystem.flush();
    await SaveSystem.initialize();
    expect(SaveSystem.data.musicVolume, .2);
    expect(SaveSystem.starsFor('test'), 3);
    expect(SaveSystem.data.levelScores['test'], 500);
    expect(SaveSystem.isLevelUnlocked(2), isTrue);
  });
}
