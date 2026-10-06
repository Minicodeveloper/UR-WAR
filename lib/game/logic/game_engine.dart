import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enemy_type.dart';
import '../models/entity.dart';
import '../models/game_map.dart';
import '../models/player_class.dart';
import '../models/wave_system.dart';

class GameEngine extends ChangeNotifier {
  final GameMapModel map;
  final PlayerClass playerClass;

  late PlayerEntity player;
  late VillageBuildingEntity townHall;
  final List<VillageBuildingEntity> villageBuildings = [];
  final List<EnemyEntity> enemies = [];
  final List<ProjectileEntity> projectiles = [];
  final List<FloatingTextEntity> floatingTexts = [];
  final List<ParticleEntity> particles = [];
  late WaveSystem waveSystem;

  bool isGameOver = false;
  bool isVictory = false;
  bool isPaused = false;
  String? announcementBanner;
  double announcementTimer = 0.0;

  // Seguimiento de cámara
  Offset cameraOffset = Offset.zero;
  Size viewportSize = const Size(800, 600);

  int _enemyIdCounter = 0;
  final Random _random = Random();

  GameEngine({
    required this.map,
    required this.playerClass,
  }) {
    _initializeGame();
  }

  void _initializeGame() {
    final centerX = map.worldWidth / 2;
    final centerY = map.worldHeight / 2;

    // Crear al jugador cerca de la aldea
    player = PlayerEntity(
      position: Offset(centerX, centerY + 80),
      playerClass: playerClass,
    );

    // Crear el Salón Comunal (Corazón de la aldea)
    townHall = VillageBuildingEntity(
      id: 'town_hall',
      type: BuildingType.townHall,
      position: Offset(centerX, centerY),
      maxHealth: 1200,
      radius: 50,
    );
    villageBuildings.add(townHall);

    // Torres de vigilancia defensivas
    villageBuildings.add(VillageBuildingEntity(
      id: 'tower_nw',
      type: BuildingType.watchtower,
      position: Offset(centerX - 160, centerY - 120),
      maxHealth: 500,
      radius: 35,
    ));
    villageBuildings.add(VillageBuildingEntity(
      id: 'tower_se',
      type: BuildingType.watchtower,
      position: Offset(centerX + 160, centerY + 120),
      maxHealth: 500,
      radius: 35,
    ));

    // Cabañas de los aldeanos
    villageBuildings.add(VillageBuildingEntity(
      id: 'cottage_ne',
      type: BuildingType.cottage,
      position: Offset(centerX + 140, centerY - 110),
      maxHealth: 350,
      radius: 35,
    ));
    villageBuildings.add(VillageBuildingEntity(
      id: 'cottage_sw',
      type: BuildingType.cottage,
      position: Offset(centerX - 140, centerY + 110),
      maxHealth: 350,
      radius: 35,
    ));

    // Inicializar sistema de oleadas
    waveSystem = WaveSystem(maxWaves: map.totalWaves);
    showAnnouncement('¡DEFENDE LA ALDEA! OLEADA 1 ENTRANTE', 3.5);
  }

  void setViewportSize(Size size) {
    viewportSize = size;
  }

  void showAnnouncement(String text, [double duration = 3.0]) {
    announcementBanner = text;
    announcementTimer = duration;
  }

  /// Actualización del bucle de juego (60 FPS)
  void update(double dt) {
    if (isGameOver || isVictory || isPaused) return;

    // Actualizar timers del jugador
    if (player.attackTimer > 0) player.attackTimer -= dt;
    if (player.specialSkillTimer > 0) player.specialSkillTimer -= dt;
    if (player.attackAnimTimer > 0) player.attackAnimTimer -= dt;
    if (player.hitFlashTimer > 0) player.hitFlashTimer -= dt;

    if (player.isMoving) {
      player.walkPhase += dt * 10;
    }

    // Actualizar banners
    if (announcementTimer > 0) {
      announcementTimer -= dt;
      if (announcementTimer <= 0) {
        announcementBanner = null;
      }
    }

    // Spawns de la oleada
    final newSpawns = waveSystem.update(dt, map.worldWidth, map.worldHeight);
    for (final spawn in newSpawns) {
      _spawnEnemy(spawn.key, spawn.value);
    }

    // Verificar si se completó la oleada actual
    if (waveSystem.isWaveInProgress &&
        waveSystem.hasCompletedAllSpawns &&
        enemies.isEmpty) {
      if (waveSystem.currentWave >= map.totalWaves) {
        isVictory = true;
        showAnnouncement('¡VICTORIA! ¡LA ALDEA HA SIDO SALVADA!', 10.0);
        notifyListeners();
        return;
      } else {
        waveSystem.currentWave++;
        waveSystem.startIntermission(7.0);
        showAnnouncement(
          '¡OLEADA SUPERADA! Prepara tus defensas (Siguiente: ${waveSystem.currentWave})',
          4.0,
        );
        // Bonificación de oro al superar oleada
        player.gold += 50 * waveSystem.currentWave;
        player.score += 250;
      }
    }

    // Actualizar IA de enemigos
    _updateEnemies(dt);

    // Actualizar defensas de la aldea (Torres de guardia automáticas)
    _updateVillageDefenses(dt);

    // Actualizar proyectiles
    _updateProjectiles(dt);

    // Actualizar partículas y textos flotantes
    _updateVFX(dt);

    // Verificar condiciones de derrota
    if (player.health <= 0 || townHall.health <= 0) {
      isGameOver = true;
      showAnnouncement('¡DERROTA! LA ALDEA HA CAÍDO...', 10.0);
    }

    // Actualizar cámara suavemente centrada en el jugador
    _updateCamera();

    notifyListeners();
  }

  void _updateCamera() {
    final targetX = player.position.dx - viewportSize.width / 2;
    final targetY = player.position.dy - viewportSize.height / 2;

    final maxX = max(0.0, map.worldWidth - viewportSize.width);
    final maxY = max(0.0, map.worldHeight - viewportSize.height);

    cameraOffset = Offset(
      targetX.clamp(0.0, maxX),
      targetY.clamp(0.0, maxY),
    );
  }

  void movePlayer(Offset inputDirection, double dt) {
    if (isGameOver || isVictory || isPaused) return;

    if (inputDirection == Offset.zero) {
      player.isMoving = false;
      return;
    }

    player.isMoving = true;
    final normalized = inputDirection / inputDirection.distance;
    final speed = player.currentSpeed;
    final newPos = player.position + normalized * (speed * dt);

    // Limitar dentro del mapa
    const padding = 30.0;
    final clampedX = newPos.dx.clamp(padding, map.worldWidth - padding);
    final clampedY = newPos.dy.clamp(padding, map.worldHeight - padding);

    // Orientación
    if (normalized.dx < -0.1) {
      player.facingLeft = true;
    } else if (normalized.dx > 0.1) {
      player.facingLeft = false;
    }

    player.position = Offset(clampedX, clampedY);
  }

  /// Ejecución de ataque primario
  void attack() {
    if (isGameOver || isVictory || isPaused) return;
    if (player.attackTimer > 0) return;

    player.attackTimer = playerClass.attackCooldownSeconds;
    player.attackAnimTimer = 0.25;

    final attackDir = player.facingLeft ? const Offset(-1, 0) : const Offset(1, 0);

    if (playerClass.isMelee) {
      // Ataque Melee (Caballero / Clériga)
      final hitCenter = player.position + attackDir * (playerClass.attackRange * 0.6);
      final hitRadius = playerClass.attackRange;

      _spawnSlashParticles(hitCenter, player.facingLeft, playerClass.themeColor);

      // Impactar a todos los enemigos en rango
      for (final enemy in enemies) {
        final dist = (enemy.position - hitCenter).distance;
        if (dist <= hitRadius) {
          final isCrit = _random.nextDouble() < 0.2;
          final dmg = isCrit ? player.currentDamage * 1.6 : player.currentDamage;
          _damageEnemy(enemy, dmg, isCrit: isCrit);

          // Empuje
          final pushDir = (enemy.position - player.position);
          if (pushDir.distance > 0) {
            enemy.position += (pushDir / pushDir.distance) * 20.0;
          }
        }
      }
    } else {
      // Ataque a Rango (Cazadora / Mago)
      EnemyEntity? target = _findNearestEnemy(player.position, playerClass.attackRange + 100);
      Offset shootDir;
      if (target != null) {
        final diff = target.position - player.position;
        shootDir = diff / diff.distance;
      } else {
        shootDir = attackDir;
      }

      final isMage = playerClass.type == PlayerRoleType.mage;

      projectiles.add(ProjectileEntity(
        position: player.position,
        velocity: shootDir * (isMage ? 320.0 : 480.0),
        damage: player.currentDamage,
        radius: isMage ? 8.0 : 4.0,
        color: isMage ? const Color(0xFFF72585) : const Color(0xFFFFD166),
        isFromPlayer: true,
        isExplosive: isMage,
        explosionRadius: isMage ? 65.0 : 0.0,
        pierceCount: isMage ? 1 : 2,
      ));
    }
  }

  /// Ejecución de la habilidad especial única por clase
  void useSpecialSkill() {
    if (isGameOver || isVictory || isPaused) return;
    if (player.specialSkillTimer > 0) return;

    player.specialSkillTimer = playerClass.specialSkillCooldownSeconds;

    switch (playerClass.type) {
      case PlayerRoleType.knight:
        // Torbellino de Acero (360° masivo)
        showAnnouncement('¡TORBELLINO DE ACERO!', 1.2);
        _spawnExplosionParticles(player.position, Colors.redAccent, 40);
        for (final enemy in enemies) {
          final dist = (enemy.position - player.position).distance;
          if (dist <= 140) {
            _damageEnemy(enemy, 130, isCrit: true);
            final push = (enemy.position - player.position);
            if (push.distance > 0) {
              enemy.position += (push / push.distance) * 60.0;
            }
          }
        }
        break;

      case PlayerRoleType.ranger:
        // Lluvia de Flechas en abanico
        showAnnouncement('¡LLUVIA DE FLECHAS!', 1.2);
        final baseAngle = player.facingLeft ? pi : 0.0;
        const arrowCount = 9;
        const spreadAngle = pi * 0.7;
        for (int i = 0; i < arrowCount; i++) {
          final angle = baseAngle - (spreadAngle / 2) + (spreadAngle / (arrowCount - 1)) * i;
          final dir = Offset(cos(angle), sin(angle));
          projectiles.add(ProjectileEntity(
            position: player.position,
            velocity: dir * 520,
            damage: player.currentDamage * 1.3,
            radius: 4.0,
            color: const Color(0xFF55A630),
            isFromPlayer: true,
            pierceCount: 3,
          ));
        }
        break;

      case PlayerRoleType.mage:
        // Meteoro Cataclísmico
        showAnnouncement('¡METEORO CATACLÍSMICO!', 1.5);
        final target = _findNearestEnemy(player.position, 350) ??
            EnemyEntity(
              id: 'dummy',
              config: EnemyConfig.goblin,
              position: player.position +
                  (player.facingLeft ? const Offset(-120, 0) : const Offset(120, 0)),
            );
        _spawnExplosionParticles(target.position, const Color(0xFF9D4EDD), 60);
        for (final enemy in List<EnemyEntity>.from(enemies)) {
          final dist = (enemy.position - target.position).distance;
          if (dist <= 180) {
            _damageEnemy(enemy, 180, isCrit: true);
          }
        }
        break;

      case PlayerRoleType.cleric:
        // Bendición de la Aldea (Curación y Reparación)
        showAnnouncement('¡BENDICIÓN SAGRADA!', 1.5);
        player.heal(90);
        townHall.repair(250);
        for (final b in villageBuildings) {
          b.repair(150);
        }
        _spawnExplosionParticles(player.position, Colors.amberAccent, 40);
        _spawnExplosionParticles(townHall.position, Colors.amberAccent, 40);
        floatingTexts.add(FloatingTextEntity(
          position: player.position - const Offset(0, 30),
          text: '+90 HP',
          color: Colors.greenAccent,
          fontSize: 18,
        ));
        floatingTexts.add(FloatingTextEntity(
          position: townHall.position - const Offset(0, 40),
          text: '+250 HP ALDEA',
          color: Colors.greenAccent,
          fontSize: 20,
        ));
        break;
    }
  }

  void _spawnEnemy(EnemyConfig config, Offset position) {
    _enemyIdCounter++;
    enemies.add(EnemyEntity(
      id: 'enemy_$_enemyIdCounter',
      config: config,
      position: position,
    ));

    if (config.isBoss) {
      showAnnouncement('¡PELIGRO EXTREMO: HA APARECIDO UN TITÁN!', 4.0);
    }
  }

  void _updateEnemies(double dt) {
    for (final enemy in List<EnemyEntity>.from(enemies)) {
      if (enemy.isDead) continue;

      if (enemy.attackTimer > 0) enemy.attackTimer -= dt;
      if (enemy.hitFlashTimer > 0) enemy.hitFlashTimer -= dt;
      enemy.walkPhase += dt * 8;

      // Objetivo: Aldea o Jugador (prioriza al jugador si está cerca)
      final distToPlayer = (player.position - enemy.position).distance;
      final distToTown = (townHall.position - enemy.position).distance;

      Offset targetPos;
      bool targetIsPlayer = false;

      if (distToPlayer < 180) {
        targetPos = player.position;
        targetIsPlayer = true;
      } else {
        // Encontrar edificio más cercano
        VillageBuildingEntity nearestB = townHall;
        double nearestBDist = distToTown;
        for (final b in villageBuildings) {
          if (b.isDead) continue;
          final d = (b.position - enemy.position).distance;
          if (d < nearestBDist) {
            nearestBDist = d;
            nearestB = b;
          }
        }
        targetPos = nearestB.position;
      }

      final diff = targetPos - enemy.position;
      final distance = diff.distance;

      // Orientación
      if (diff.dx < -5) enemy.facingLeft = true;
      if (diff.dx > 5) enemy.facingLeft = false;

      // Si está en rango de ataque
      if (distance <= enemy.config.attackRange) {
        if (enemy.attackTimer <= 0) {
          enemy.attackTimer = enemy.config.attackCooldownSeconds;
          if (enemy.config.isRanged) {
            // Disparar proyectil
            final shootDir = diff / distance;
            projectiles.add(ProjectileEntity(
              position: enemy.position,
              velocity: shootDir * 280,
              damage: enemy.config.attackDamage,
              radius: 4.0,
              color: enemy.config.category == EnemyCategory.necromancer
                  ? const Color(0xFF70E000)
                  : const Color(0xFFE8E8E8),
              isFromPlayer: false,
            ));
          } else {
            // Daño cuerpo a cuerpo directo
            if (targetIsPlayer) {
              player.takeDamage(enemy.config.attackDamage);
              floatingTexts.add(FloatingTextEntity(
                position: player.position - const Offset(0, 20),
                text: '-${enemy.config.attackDamage.toInt()}',
                color: Colors.redAccent,
              ));
            } else {
              // Daño a edificio
              final targetBuilding = villageBuildings.firstWhere(
                (b) => (b.position - enemy.position).distance <= enemy.config.attackRange + 40,
                orElse: () => townHall,
              );
              targetBuilding.takeDamage(enemy.config.attackDamage);
              floatingTexts.add(FloatingTextEntity(
                position: targetBuilding.position - const Offset(0, 30),
                text: '-${enemy.config.attackDamage.toInt()}',
                color: Colors.redAccent,
              ));
            }
          }
        }
      } else {
        // Moverse hacia el objetivo
        final moveDir = diff / distance;
        enemy.position += moveDir * (enemy.config.speed * dt);
      }
    }

    // Limpiar enemigos muertos
    enemies.removeWhere((e) => e.isDead);
  }

  void _updateVillageDefenses(double dt) {
    for (final b in villageBuildings) {
      if (b.isDead) continue;
      if (b.hitFlashTimer > 0) b.hitFlashTimer -= dt;

      if (b.type == BuildingType.watchtower) {
        b.shootTimer += dt;
        if (b.shootTimer >= 1.2) {
          b.shootTimer = 0.0;
          final target = _findNearestEnemy(b.position, 320);
          if (target != null) {
            final diff = target.position - b.position;
            final shootDir = diff / diff.distance;
            projectiles.add(ProjectileEntity(
              position: b.position,
              velocity: shootDir * 400,
              damage: 35.0,
              radius: 4.0,
              color: const Color(0xFFFFD166),
              isFromPlayer: true,
            ));
          }
        }
      }
    }
  }

  void _updateProjectiles(double dt) {
    for (final p in List<ProjectileEntity>.from(projectiles)) {
      p.lifeTime -= dt;
      p.position += p.velocity * dt;

      if (p.isExpired) continue;

      if (p.isFromPlayer) {
        // Impacta contra enemigos
        for (final enemy in List<EnemyEntity>.from(enemies)) {
          if (enemy.isDead) continue;
          final dist = (enemy.position - p.position).distance;
          if (dist <= enemy.config.hitRadius + p.radius) {
            p.pierceCount--;

            if (p.isExplosive) {
              _spawnExplosionParticles(p.position, const Color(0xFFF72585), 25);
              for (final splashTarget in List<EnemyEntity>.from(enemies)) {
                if ((splashTarget.position - p.position).distance <= p.explosionRadius) {
                  _damageEnemy(splashTarget, p.damage);
                }
              }
              p.lifeTime = 0;
              break;
            } else {
              _damageEnemy(enemy, p.damage);
              if (p.pierceCount <= 0) {
                p.lifeTime = 0;
                break;
              }
            }
          }
        }
      } else {
        // Proyectil enemigo impacta contra jugador o edificios
        final distPlayer = (player.position - p.position).distance;
        if (distPlayer <= 25) {
          player.takeDamage(p.damage);
          floatingTexts.add(FloatingTextEntity(
            position: player.position - const Offset(0, 20),
            text: '-${p.damage.toInt()}',
            color: Colors.redAccent,
          ));
          p.lifeTime = 0;
          continue;
        }

        // Impacta contra edificios
        for (final b in villageBuildings) {
          if (b.isDead) continue;
          if ((b.position - p.position).distance <= b.radius) {
            b.takeDamage(p.damage);
            floatingTexts.add(FloatingTextEntity(
              position: b.position - const Offset(0, 25),
              text: '-${p.damage.toInt()}',
              color: Colors.redAccent,
            ));
            p.lifeTime = 0;
            break;
          }
        }
      }
    }

    projectiles.removeWhere((p) => p.isExpired);
  }

  void _damageEnemy(EnemyEntity enemy, double amount, {bool isCrit = false}) {
    enemy.takeDamage(amount);

    floatingTexts.add(FloatingTextEntity(
      position: enemy.position - const Offset(0, 25),
      text: isCrit ? '¡CRÍTICO! -${amount.toInt()}' : '-${amount.toInt()}',
      color: isCrit ? const Color(0xFFFFD166) : Colors.white,
      fontSize: isCrit ? 16 : 13,
    ));

    _spawnHitParticles(enemy.position, enemy.config.sprite.palette['g'] ?? Colors.red);

    if (enemy.isDead) {
      player.gold += enemy.config.goldReward;
      player.score += enemy.config.scoreReward;
      player.kills++;

      floatingTexts.add(FloatingTextEntity(
        position: enemy.position - const Offset(0, 45),
        text: '+${enemy.config.goldReward} 🪙',
        color: const Color(0xFFFFD166),
        fontSize: 14,
      ));

      _spawnDeathParticles(enemy.position);
    }
  }

  EnemyEntity? _findNearestEnemy(Offset pos, double maxRadius) {
    EnemyEntity? nearest;
    double minDistance = maxRadius;
    for (final e in enemies) {
      if (e.isDead) continue;
      final d = (e.position - pos).distance;
      if (d < minDistance) {
        minDistance = d;
        nearest = e;
      }
    }
    return nearest;
  }

  void _updateVFX(double dt) {
    for (final ft in floatingTexts) {
      ft.lifeTime -= dt;
      ft.position -= const Offset(0, 25) * dt;
    }
    floatingTexts.removeWhere((ft) => ft.isExpired);

    for (final p in particles) {
      p.lifeTime -= dt;
      p.position += p.velocity * dt;
    }
    particles.removeWhere((p) => p.isExpired);
  }

  void _spawnHitParticles(Offset pos, Color color) {
    for (int i = 0; i < 6; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 40.0 + _random.nextDouble() * 80.0;
      particles.add(ParticleEntity(
        position: pos,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: color,
        radius: 2.0 + _random.nextDouble() * 2.0,
        lifeTime: 0.35,
      ));
    }
  }

  void _spawnDeathParticles(Offset pos) {
    for (int i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 60.0 + _random.nextDouble() * 120.0;
      particles.add(ParticleEntity(
        position: pos,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: _random.nextBool() ? const Color(0xFFFFD166) : const Color(0xFFEF233C),
        radius: 3.0 + _random.nextDouble() * 3.0,
        lifeTime: 0.6,
      ));
    }
  }

  void _spawnExplosionParticles(Offset pos, Color color, int count) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50.0 + _random.nextDouble() * 180.0;
      particles.add(ParticleEntity(
        position: pos,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: color,
        radius: 3.0 + _random.nextDouble() * 4.0,
        lifeTime: 0.7,
      ));
    }
  }

  void _spawnSlashParticles(Offset pos, bool facingLeft, Color color) {
    final baseAngle = facingLeft ? pi : 0.0;
    for (int i = 0; i < 12; i++) {
      final angle = baseAngle - 0.6 + (_random.nextDouble() * 1.2);
      final speed = 100.0 + _random.nextDouble() * 90.0;
      particles.add(ParticleEntity(
        position: pos,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: color,
        radius: 3.0,
        lifeTime: 0.25,
      ));
    }
  }

  // ==========================================
  // OPERACIONES DE LA TIENDA DE LA ALDEA
  // ==========================================
  bool repairVillage(int cost, double hp) {
    if (player.gold < cost) return false;
    player.gold -= cost;
    townHall.repair(hp);
    for (final b in villageBuildings) {
      if (b != townHall) {
        b.repair(hp * 0.5);
      }
    }
    floatingTexts.add(FloatingTextEntity(
      position: townHall.position - const Offset(0, 40),
      text: '+${hp.toInt()} HP ALDEA',
      color: Colors.greenAccent,
      fontSize: 18,
    ));
    notifyListeners();
    return true;
  }

  bool upgradeHeroDamage(int cost) {
    if (player.gold < cost) return false;
    player.gold -= cost;
    player.damageMultiplier += 0.25;
    floatingTexts.add(FloatingTextEntity(
      position: player.position - const Offset(0, 30),
      text: '¡DAÑO +25%!',
      color: const Color(0xFFFFD166),
      fontSize: 16,
    ));
    notifyListeners();
    return true;
  }

  bool upgradeHeroSpeed(int cost) {
    if (player.gold < cost) return false;
    player.gold -= cost;
    player.speedMultiplier += 0.15;
    floatingTexts.add(FloatingTextEntity(
      position: player.position - const Offset(0, 30),
      text: '¡VELOCIDAD +15%!',
      color: const Color(0xFF00BBF9),
      fontSize: 16,
    ));
    notifyListeners();
    return true;
  }

  bool healHero(int cost) {
    if (player.gold < cost) return false;
    if (player.health >= player.maxHealth) return false;
    player.gold -= cost;
    player.heal(player.maxHealth * 0.6);
    floatingTexts.add(FloatingTextEntity(
      position: player.position - const Offset(0, 30),
      text: '+VIDA COMPLETA',
      color: Colors.greenAccent,
      fontSize: 16,
    ));
    notifyListeners();
    return true;
  }

  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }
}
