import 'dart:math';
import 'package:flutter/material.dart';
import 'enemy_type.dart';

class WaveSpawnEntry {
  final EnemyConfig config;
  final double delaySeconds;
  final int spawnEdge; // 0: Top, 1: Right, 2: Bottom, 3: Left

  const WaveSpawnEntry({
    required this.config,
    required this.delaySeconds,
    required this.spawnEdge,
  });
}

class WaveSystem {
  int currentWave = 1;
  final int maxWaves;
  bool isWaveInProgress = false;
  double waveTimer = 0.0;
  double intermissionTimer = 6.0;
  final List<WaveSpawnEntry> _pendingSpawns = [];
  int totalEnemiesInCurrentWave = 0;
  int enemiesSpawnedSoFar = 0;

  WaveSystem({this.maxWaves = 5});

  void startIntermission([double duration = 6.0]) {
    isWaveInProgress = false;
    intermissionTimer = duration;
    _pendingSpawns.clear();
  }

  void startWave(int waveNumber, double worldWidth, double worldHeight) {
    currentWave = waveNumber;
    isWaveInProgress = true;
    intermissionTimer = 0.0;
    waveTimer = 0.0;
    _pendingSpawns.clear();
    enemiesSpawnedSoFar = 0;

    final random = Random();

    // Generación dinámica equilibrada de oleadas
    if (waveNumber == 1) {
      // Oleada 1: 8 Goblins
      for (int i = 0; i < 8; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.goblin,
          delaySeconds: i * 1.5,
          spawnEdge: random.nextInt(4),
        ));
      }
    } else if (waveNumber == 2) {
      // Oleada 2: 10 Goblins + 4 Esqueletos arqueros
      for (int i = 0; i < 10; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.goblin,
          delaySeconds: i * 1.2,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 4; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.skeleton,
          delaySeconds: 2.0 + i * 2.5,
          spawnEdge: random.nextInt(4),
        ));
      }
    } else if (waveNumber == 3) {
      // Oleada 3: 12 Goblins + 6 Orcos Berserkers
      for (int i = 0; i < 12; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.goblin,
          delaySeconds: i * 1.0,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 6; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.orc,
          delaySeconds: 3.0 + i * 2.0,
          spawnEdge: random.nextInt(4),
        ));
      }
    } else if (waveNumber == 4) {
      // Oleada 4: 14 Goblins + 6 Orcos + 5 Esqueletos + 2 Nigromantes
      for (int i = 0; i < 14; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.goblin,
          delaySeconds: i * 0.9,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 6; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.orc,
          delaySeconds: 2.0 + i * 2.2,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 5; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.skeleton,
          delaySeconds: 1.5 + i * 2.0,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 2; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.necromancer,
          delaySeconds: 6.0 + i * 5.0,
          spawnEdge: random.nextInt(4),
        ));
      }
    } else {
      // Oleada 5 (o superior): ¡JEFE TITÁN! + escolta masiva
      _pendingSpawns.add(WaveSpawnEntry(
        config: EnemyConfig.bossTitan,
        delaySeconds: 3.0,
        spawnEdge: random.nextInt(4),
      ));
      for (int i = 0; i < 16; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.goblin,
          delaySeconds: i * 0.8,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 8; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.orc,
          delaySeconds: 2.0 + i * 1.8,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 6; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.skeleton,
          delaySeconds: 3.0 + i * 2.0,
          spawnEdge: random.nextInt(4),
        ));
      }
      for (int i = 0; i < 3; i++) {
        _pendingSpawns.add(WaveSpawnEntry(
          config: EnemyConfig.necromancer,
          delaySeconds: 5.0 + i * 4.0,
          spawnEdge: random.nextInt(4),
        ));
      }
    }

    // Ordenar spawns por tiempo de retraso
    _pendingSpawns.sort((a, b) => a.delaySeconds.compareTo(b.delaySeconds));
    totalEnemiesInCurrentWave = _pendingSpawns.length;
  }

  /// Retorna los enemigos listos para spawnear en este tick del juego
  List<MapEntry<EnemyConfig, Offset>> update(
    double dt,
    double worldWidth,
    double worldHeight,
  ) {
    final readySpawns = <MapEntry<EnemyConfig, Offset>>[];

    if (!isWaveInProgress) {
      intermissionTimer -= dt;
      if (intermissionTimer <= 0) {
        startWave(currentWave, worldWidth, worldHeight);
      }
      return readySpawns;
    }

    waveTimer += dt;
    final random = Random();

    while (_pendingSpawns.isNotEmpty &&
        _pendingSpawns.first.delaySeconds <= waveTimer) {
      final entry = _pendingSpawns.removeAt(0);
      enemiesSpawnedSoFar++;

      Offset spawnPos;
      const margin = 40.0;
      switch (entry.spawnEdge) {
        case 0: // Arriba
          spawnPos = Offset(margin + random.nextDouble() * (worldWidth - margin * 2), margin);
          break;
        case 1: // Derecha
          spawnPos = Offset(worldWidth - margin, margin + random.nextDouble() * (worldHeight - margin * 2));
          break;
        case 2: // Abajo
          spawnPos = Offset(margin + random.nextDouble() * (worldWidth - margin * 2), worldHeight - margin);
          break;
        case 3: // Izquierda
        default:
          spawnPos = Offset(margin, margin + random.nextDouble() * (worldHeight - margin * 2));
          break;
      }

      readySpawns.add(MapEntry(entry.config, spawnPos));
    }

    return readySpawns;
  }

  bool get hasCompletedAllSpawns => _pendingSpawns.isEmpty;
}
