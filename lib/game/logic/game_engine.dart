import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio_engine.dart';
import '../../core/save_system.dart';
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
  final List<RivalCampEntity> rivalCamps = [];
  final List<ProjectileEntity> projectiles = [];
  final List<FloatingTextEntity> floatingTexts = [];
  final List<ParticleEntity> particles = [];
  late WaveSystem waveSystem;

  // Niebla de Guerra (Fog of War)
  late int fogCols;
  late int fogRows;
  static const double fogTileSize = 100.0;
  late List<List<bool>> fogExplored;

  bool isGameOver = false;
  bool isVictory = false;
  bool isPaused = false;
  String? announcementBanner;
  double announcementTimer = 0.0;

  // Efectos temporales definitivos
  double freezeTimer = 0.0;
  double villageShieldTimer = 0.0;

  // Seguimiento de cámara
  Offset cameraOffset = Offset.zero;
  Size viewportSize = const Size(800, 600);

  int _enemyIdCounter = 0;
  int _buildingIdCounter = 0;
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

    // Inicializar Niebla de Guerra
    fogCols = (map.worldWidth / fogTileSize).ceil();
    fogRows = (map.worldHeight / fogTileSize).ceil();
    fogExplored = List.generate(
      fogRows,
      (_) => List.generate(fogCols, (_) => false),
    );

    // Revelar la aldea inicial
    _revealFogArea(Offset(centerX, centerY), 350);

    // Crear al jugador
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

    // Torres de vigilancia defensivas iniciales
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

    // Cabañas iniciales
    villageBuildings.add(VillageBuildingEntity(
      id: 'cottage_ne',
      type: BuildingType.cottage,
      position: Offset(centerX + 140, centerY - 110),
      maxHealth: 350,
      radius: 35,
    ));

    // Inicializar campamentos enemigos rivales en el mapa
    for (int i = 0; i < map.rivalCamps.length; i++) {
      final config = map.rivalCamps[i];
      rivalCamps.add(RivalCampEntity(
        id: 'rival_$i',
        name: config.name,
        position: config.position,
        maxHealth: 450.0 + config.level * 100,
        goldReward: 350 + config.level * 50,
        xpReward: 450 + config.level * 100,
      ));
    }

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

  void _revealFogArea(Offset pos, double radius) {
    final startCol = ((pos.dx - radius) / fogTileSize).floor().clamp(0, fogCols - 1);
    final endCol = ((pos.dx + radius) / fogTileSize).ceil().clamp(0, fogCols - 1);
    final startRow = ((pos.dy - radius) / fogTileSize).floor().clamp(0, fogRows - 1);
    final endRow = ((pos.dy + radius) / fogTileSize).ceil().clamp(0, fogRows - 1);

    for (int r = startRow; r <= endRow; r++) {
      for (int c = startCol; c <= endCol; c++) {
        final tileCenter = Offset((c + 0.5) * fogTileSize, (r + 0.5) * fogTileSize);
        if ((tileCenter - pos).distance <= radius) {
          fogExplored[r][c] = true;
        }
      }
    }
  }

  /// Actualización del bucle de juego (60 FPS)
  void update(double dt) {
    if (isGameOver || isVictory || isPaused) return;

    // Actualizar timers del jugador y habilidades
    if (player.attackTimer > 0) player.attackTimer -= dt;
    if (player.specialSkillTimer > 0) player.specialSkillTimer -= dt;
    if (player.ultimateSkillTimer > 0) player.ultimateSkillTimer -= dt;
    if (player.attackAnimTimer > 0) player.attackAnimTimer -= dt;
    if (player.hitFlashTimer > 0) player.hitFlashTimer -= dt;

    if (freezeTimer > 0) freezeTimer -= dt;
    if (villageShieldTimer > 0) villageShieldTimer -= dt;

    if (player.isMoving) {
      player.walkPhase += dt * 10;
      // Revelar niebla al explorar
      _revealFogArea(player.position, 220);
    }

    // Efectos pasivos de clase
    _applyPassiveSkills(dt);

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

    // Spawns adicionales desde campamentos rivales no destruidos
    _updateRivalCamps(dt);

    // Verificar si se completó la oleada actual y todos los campamentos rivales
    if (waveSystem.isWaveInProgress &&
        waveSystem.hasCompletedAllSpawns &&
        enemies.isEmpty) {
      if (waveSystem.currentWave >= map.totalWaves) {
        isVictory = true;
        AudioEngine.playVictory();
        SaveSystem.addMatchStats(
          kills: player.kills,
          gold: player.gold,
          score: player.score,
        );
        SaveSystem.unlockLevel(map.levelIndex + 1);
        showAnnouncement('¡VICTORIA! ¡TODAS LAS HORDAS Y CAMPAMENTOS HAN SIDO DESTRUIDOS!', 10.0);
        notifyListeners();
        return;
      } else {
        waveSystem.currentWave++;
        waveSystem.startIntermission(7.0);
        showAnnouncement(
          '¡OLEADA SUPERADA! Prepara tus defensas (Siguiente: ${waveSystem.currentWave})',
          4.0,
        );
        player.gold += 60 * waveSystem.currentWave;
        player.addXp(150 * waveSystem.currentWave);
      }
    }

    // Actualizar IA de enemigos (ralentizados si hay congelación)
    final effectiveDt = freezeTimer > 0 ? dt * 0.2 : dt;
    _updateEnemies(effectiveDt);

    // Actualizar defensas y minas de la aldea
    _updateVillageDefenses(dt);

    // Actualizar proyectiles
    _updateProjectiles(dt);

    // Actualizar partículas y textos flotantes
    _updateVFX(dt);

    // Verificar condiciones de derrota
    if (player.health <= 0 || townHall.health <= 0) {
      isGameOver = true;
      AudioEngine.playDefeat();
      SaveSystem.addMatchStats(
        kills: player.kills,
        gold: player.gold,
        score: player.score,
      );
      showAnnouncement('¡DERROTA! LA ALDEA HA CAÍDO...', 10.0);
    }

    // Actualizar cámara suavemente centrada en el jugador
    _updateCamera();

    notifyListeners();
  }

  void _applyPassiveSkills(double dt) {
    if (playerClass.type == PlayerRoleType.cleric &&
        player.unlockedSkillIds.contains('c_passive_1')) {
      // Aura Celestial: regenera torres de la aldea constantemente
      for (final b in villageBuildings) {
        if (!b.isDead) b.repair(5.0 * dt);
      }
    }
  }

  void _updateRivalCamps(double dt) {
    for (final camp in List<RivalCampEntity>.from(rivalCamps)) {
      if (camp.isDestroyed) continue;
      if (camp.hitFlashTimer > 0) camp.hitFlashTimer -= dt;

      camp.spawnTimer += dt;
      if (camp.spawnTimer >= 14.0) {
        camp.spawnTimer = 0.0;
        // Enviar invasor extra desde el campamento rival
        _spawnEnemy(
          _random.nextBool() ? EnemyConfig.orc : EnemyConfig.goblin,
          camp.position,
        );
      }
    }
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

    const padding = 30.0;
    final clampedX = newPos.dx.clamp(padding, map.worldWidth - padding);
    final clampedY = newPos.dy.clamp(padding, map.worldHeight - padding);

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

    // Pasiva de la Cazadora: Ojo de Águila (+30% velocidad de ataque)
    final cooldownBonus = (playerClass.type == PlayerRoleType.ranger &&
            player.unlockedSkillIds.contains('r_passive_1'))
        ? 0.7
        : 1.0;

    player.attackTimer = playerClass.attackCooldownSeconds * cooldownBonus;
    player.attackAnimTimer = 0.25;

    if (playerClass.isMelee) {
      AudioEngine.playAttackSlash();
    } else {
      AudioEngine.playShoot();
    }

    final attackDir = player.facingLeft ? const Offset(-1, 0) : const Offset(1, 0);

    if (playerClass.isMelee) {
      final hitCenter = player.position + attackDir * (playerClass.attackRange * 0.6);
      final hitRadius = playerClass.attackRange;

      _spawnSlashParticles(hitCenter, player.facingLeft, playerClass.themeColor);

      // Daño a enemigos
      for (final enemy in enemies) {
        final dist = (enemy.position - hitCenter).distance;
        if (dist <= hitRadius) {
          final isCrit = _random.nextDouble() < 0.25;
          final dmg = isCrit ? player.currentDamage * 1.6 : player.currentDamage;
          _damageEnemy(enemy, dmg, isCrit: isCrit);

          final pushDir = (enemy.position - player.position);
          if (pushDir.distance > 0) {
            enemy.position += (pushDir / pushDir.distance) * 20.0;
          }
        }
      }

      // Daño a campamentos rivales
      for (final camp in rivalCamps) {
        if (camp.isDestroyed) continue;
        if ((camp.position - hitCenter).distance <= hitRadius + camp.radius) {
          _damageRivalCamp(camp, player.currentDamage);
        }
      }
    } else {
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

  /// Habilidad especial
  void useSpecialSkill() {
    if (isGameOver || isVictory || isPaused) return;
    if (player.specialSkillTimer > 0) return;

    player.specialSkillTimer = playerClass.specialSkillCooldownSeconds;

    switch (playerClass.type) {
      case PlayerRoleType.knight:
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
        showAnnouncement('¡BENDICIÓN SAGRADA!', 1.5);
        player.heal(90);
        townHall.repair(250);
        for (final b in villageBuildings) {
          if (b != townHall) b.repair(150);
        }
        _spawnExplosionParticles(player.position, Colors.amberAccent, 40);
        _spawnExplosionParticles(townHall.position, Colors.amberAccent, 40);
        break;
    }
  }

  /// Habilidad definitiva (Ultimate) desbloqueable a Nivel 5
  void useUltimateSkill() {
    if (isGameOver || isVictory || isPaused) return;
    if (!player.unlockedSkillIds.contains('${playerClass.type.name.substring(0, 1)}_ultimate')) return;
    if (player.ultimateSkillTimer > 0) return;

    final ultimateSkill = playerClass.skillTree.firstWhere((s) => s.isUltimate);
    player.ultimateSkillTimer = ultimateSkill.cooldownSeconds;

    switch (playerClass.type) {
      case PlayerRoleType.knight:
        showAnnouncement('¡IMPACTO SÍSMICO ULTIMATE!', 2.0);
        _spawnExplosionParticles(player.position, const Color(0xFFFFD166), 70);
        for (final enemy in List<EnemyEntity>.from(enemies)) {
          if ((enemy.position - player.position).distance <= 220) {
            _damageEnemy(enemy, 250, isCrit: true);
          }
        }
        break;

      case PlayerRoleType.ranger:
        showAnnouncement('¡FLECHA DEL DRAGÓN ULTIMATE!', 2.0);
        final dir = player.facingLeft ? const Offset(-1, 0) : const Offset(1, 0);
        projectiles.add(ProjectileEntity(
          position: player.position,
          velocity: dir * 650,
          damage: 350,
          radius: 16.0,
          color: const Color(0xFFFF5400),
          isFromPlayer: true,
          isExplosive: true,
          explosionRadius: 120,
          pierceCount: 10,
        ));
        break;

      case PlayerRoleType.mage:
        showAnnouncement('¡TORMENTA DE ESCARCHA ULTIMATE!', 2.0);
        freezeTimer = 6.0;
        _spawnExplosionParticles(player.position, const Color(0xFF00BBF9), 80);
        break;

      case PlayerRoleType.cleric:
        showAnnouncement('¡ESCUDO DIVINO ULTIMATE!', 2.0);
        villageShieldTimer = 6.0;
        _spawnExplosionParticles(townHall.position, const Color(0xFFFFD166), 80);
        break;
    }
  }

  void unlockSkill(String skillId) {
    if (player.skillPoints <= 0) return;
    final skill = playerClass.skillTree.firstWhere((s) => s.id == skillId);
    if (player.level < skill.requiredLevel) return;

    player.skillPoints--;
    player.unlockedSkillIds.add(skillId);

    // Aplicar pasiva si corresponde
    if (skill.isPassive && playerClass.type == PlayerRoleType.knight) {
      player.damageReduction = 0.25;
    }

    showAnnouncement('¡HABILIDAD DESBLOQUEADA: ${skill.name}!', 2.5);
    notifyListeners();
  }

  // ==========================================
  // CONSTRUCCIÓN DE LA ALDEA Y ESTRUCTURAS
  // ==========================================
  bool buildStructure(BuildingType type, int cost) {
    if (player.gold < cost) return false;

    // Buscar posición cerca de la aldea
    _buildingIdCounter++;
    final angle = _random.nextDouble() * 2 * pi;
    final dist = 140.0 + _random.nextDouble() * 120.0;
    final buildPos = townHall.position + Offset(cos(angle), sin(angle)) * dist;

    double maxHp = 400;
    double radius = 30;

    if (type == BuildingType.watchtower) {
      maxHp = 500;
      radius = 35;
    } else if (type == BuildingType.barricade) {
      maxHp = 600;
      radius = 28;
    } else if (type == BuildingType.goldMine) {
      maxHp = 350;
      radius = 32;
    }

    player.gold -= cost;
    villageBuildings.add(VillageBuildingEntity(
      id: 'custom_b_$_buildingIdCounter',
      type: type,
      position: buildPos,
      maxHealth: maxHp,
      radius: radius,
    ));

    floatingTexts.add(FloatingTextEntity(
      position: buildPos - const Offset(0, 30),
      text: '¡ESTRUCTURA CONSTRUIDA!',
      color: Colors.greenAccent,
      fontSize: 14,
    ));

    _spawnExplosionParticles(buildPos, const Color(0xFFFFD166), 25);
    notifyListeners();
    return true;
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

      final distToPlayer = (player.position - enemy.position).distance;
      final distToTown = (townHall.position - enemy.position).distance;

      Offset targetPos;
      bool targetIsPlayer = false;

      if (distToPlayer < 180) {
        targetPos = player.position;
        targetIsPlayer = true;
      } else {
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

      if (diff.dx < -5) enemy.facingLeft = true;
      if (diff.dx > 5) enemy.facingLeft = false;

      if (distance <= enemy.config.attackRange) {
        if (enemy.attackTimer <= 0) {
          enemy.attackTimer = enemy.config.attackCooldownSeconds;
          if (enemy.config.isRanged) {
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
            if (targetIsPlayer) {
              player.takeDamage(enemy.config.attackDamage);
              floatingTexts.add(FloatingTextEntity(
                position: player.position - const Offset(0, 20),
                text: '-${enemy.config.attackDamage.toInt()}',
                color: Colors.redAccent,
              ));
            } else {
              // Si el Escudo Divino de la aldea está activo, no recibe daño
              if (villageShieldTimer <= 0) {
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
        }
      } else {
        final moveDir = diff / distance;
        enemy.position += moveDir * (enemy.config.speed * dt);
      }
    }

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
      } else if (b.type == BuildingType.goldMine) {
        b.goldGenerationTimer += dt;
        if (b.goldGenerationTimer >= 10.0) {
          b.goldGenerationTimer = 0.0;
          player.gold += 15;
          floatingTexts.add(FloatingTextEntity(
            position: b.position - const Offset(0, 25),
            text: '+15 🪙 (MINA)',
            color: const Color(0xFFFFD166),
            fontSize: 12,
          ));
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
        // Impacto a enemigos
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

        // Impacto a campamentos rivales
        for (final camp in List<RivalCampEntity>.from(rivalCamps)) {
          if (camp.isDestroyed) continue;
          if ((camp.position - p.position).distance <= camp.radius + p.radius) {
            _damageRivalCamp(camp, p.damage);
            p.lifeTime = 0;
            break;
          }
        }
      } else {
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

        if (villageShieldTimer <= 0) {
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
      player.addXp(enemy.config.scoreReward);

      // Pasiva del Mago Arcano: Sifón de Maná (recupera vida al matar)
      if (playerClass.type == PlayerRoleType.mage &&
          player.unlockedSkillIds.contains('m_passive_1')) {
        player.heal(15);
      }

      floatingTexts.add(FloatingTextEntity(
        position: enemy.position - const Offset(0, 45),
        text: '+${enemy.config.goldReward} 🪙 | +${enemy.config.scoreReward} XP',
        color: const Color(0xFFFFD166),
        fontSize: 13,
      ));

      _spawnDeathParticles(enemy.position);
    }
  }

  void _damageRivalCamp(RivalCampEntity camp, double amount) {
    camp.takeDamage(amount);

    floatingTexts.add(FloatingTextEntity(
      position: camp.position - const Offset(0, 30),
      text: '-${amount.toInt()}',
      color: const Color(0xFFFF5400),
      fontSize: 15,
    ));

    if (camp.isDestroyed) {
      player.gold += camp.goldReward;
      player.score += camp.xpReward;
      player.addXp(camp.xpReward);

      // Revelar niebla al destruir el campamento
      _revealFogArea(camp.position, 400);

      showAnnouncement('¡CAMPAMENTO RIVAL ${camp.name.toUpperCase()} DESTRUIDO!', 3.0);

      floatingTexts.add(FloatingTextEntity(
        position: camp.position - const Offset(0, 50),
        text: '¡BOTÍN RIVAL! +${camp.goldReward} 🪙 +${camp.xpReward} XP',
        color: const Color(0xFFFFD166),
        fontSize: 16,
      ));

      _spawnExplosionParticles(camp.position, const Color(0xFFFFD166), 60);
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
