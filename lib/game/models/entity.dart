import 'dart:math';
import 'package:flutter/material.dart';
import 'player_class.dart';
import 'enemy_type.dart';

/// Entidad controlada por el jugador con sistema RPG de niveles y habilidades
class PlayerEntity {
  Offset position;
  final PlayerClass playerClass;
  double health;
  double maxHealth;
  double attackTimer = 0.0;
  double specialSkillTimer = 0.0;
  double ultimateSkillTimer = 0.0;
  bool facingLeft = false;
  double attackAnimTimer = 0.0;
  double hitFlashTimer = 0.0;
  double walkPhase = 0.0;
  bool isMoving = false;

  // Sistema de Nivel y Experiencia RPG
  int level = 1;
  int xp = 0;
  int xpToNextLevel = 100;
  int skillPoints = 0;
  final Set<String> unlockedSkillIds = {};

  // Modificadores de la tienda y pasivas
  double damageMultiplier = 1.0;
  double speedMultiplier = 1.0;
  double damageReduction = 0.0;

  int gold = 0;
  int score = 0;
  int kills = 0;

  PlayerEntity({
    required this.position,
    required this.playerClass,
  })  : health = playerClass.maxHealth,
        maxHealth = playerClass.maxHealth {
    // Desbloquear habilidad básica de nivel 1
    unlockedSkillIds.add(playerClass.skillTree.first.id);
  }

  double get currentDamage => playerClass.baseDamage * damageMultiplier;
  double get currentSpeed => playerClass.moveSpeed * speedMultiplier;

  void addXp(int amount) {
    xp += amount;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      skillPoints++;
      xpToNextLevel = (xpToNextLevel * 1.5).round();

      // Bonificación al subir de nivel
      maxHealth += 25;
      health = min(maxHealth, health + maxHealth * 0.5);
      damageMultiplier += 0.10;
    }
  }

  void takeDamage(double amount) {
    final effectiveDamage = amount * (1.0 - damageReduction).clamp(0.1, 1.0);
    health = max(0, health - effectiveDamage);
    hitFlashTimer = 0.25;
  }

  void heal(double amount) {
    health = min(maxHealth, health + amount);
  }
}

/// Campamento / Bastión Rival enemigo en la naturaleza
class RivalCampEntity {
  final String id;
  final String name;
  final Offset position;
  double health;
  double maxHealth;
  final int goldReward;
  final int xpReward;
  double spawnTimer = 0.0;
  double hitFlashTimer = 0.0;
  final double radius;

  RivalCampEntity({
    required this.id,
    required this.name,
    required this.position,
    this.maxHealth = 450,
    this.goldReward = 350,
    this.xpReward = 400,
    this.radius = 45,
  }) : health = maxHealth;

  bool get isDestroyed => health <= 0;

  void takeDamage(double amount) {
    health = max(0, health - amount);
    hitFlashTimer = 0.25;
  }
}

/// Nodo de recurso recolectable (Mina de oro, Cristales de maná)
class ResourceNodeEntity {
  final String id;
  final String type; // 'gold_mine', 'mana_crystal'
  final Offset position;
  int resourcesRemaining;
  double harvestTimer = 0.0;

  ResourceNodeEntity({
    required this.id,
    required this.type,
    required this.position,
    this.resourcesRemaining = 250,
  });

  bool get isDepleted => resourcesRemaining <= 0;
}

/// Entidad de invasor enemigo
class EnemyEntity {
  final String id;
  final EnemyConfig config;
  Offset position;
  double health;
  bool facingLeft = false;
  double attackTimer = 0.0;
  double hitFlashTimer = 0.0;
  double walkPhase = 0.0;

  EnemyEntity({
    required this.id,
    required this.config,
    required this.position,
  }) : health = config.maxHealth;

  bool get isDead => health <= 0;

  void takeDamage(double amount) {
    health = max(0, health - amount);
    hitFlashTimer = 0.2;
  }
}

enum BuildingType {
  townHall,
  watchtower,
  cottage,
  barricade,
  goldMine,
}

/// Edificio perteneciente a la aldea que debe ser defendido o construido
class VillageBuildingEntity {
  final String id;
  final BuildingType type;
  final Offset position;
  double health;
  double maxHealth;
  int level = 1;
  double shootTimer = 0.0;
  double goldGenerationTimer = 0.0;
  double hitFlashTimer = 0.0;
  final double radius;

  VillageBuildingEntity({
    required this.id,
    required this.type,
    required this.position,
    required this.maxHealth,
    required this.radius,
  }) : health = maxHealth;

  bool get isDead => health <= 0;

  void takeDamage(double amount) {
    health = max(0, health - amount);
    hitFlashTimer = 0.2;
  }

  void repair(double amount) {
    health = min(maxHealth, health + amount);
  }
}

/// Proyectiles disparados por héroes, torres o enemigos
class ProjectileEntity {
  Offset position;
  final Offset velocity;
  final double damage;
  final double radius;
  final Color color;
  final bool isFromPlayer;
  final bool isExplosive;
  final double explosionRadius;
  double lifeTime;
  int pierceCount;

  ProjectileEntity({
    required this.position,
    required this.velocity,
    required this.damage,
    this.radius = 4.0,
    required this.color,
    required this.isFromPlayer,
    this.isExplosive = false,
    this.explosionRadius = 0.0,
    this.lifeTime = 2.0,
    this.pierceCount = 1,
  });

  bool get isExpired => lifeTime <= 0;
}

/// Textos flotantes para daño, curaciones y alertas
class FloatingTextEntity {
  Offset position;
  final String text;
  final Color color;
  final double fontSize;
  double lifeTime;
  final double maxLifeTime;

  FloatingTextEntity({
    required this.position,
    required this.text,
    required this.color,
    this.fontSize = 14.0,
    this.lifeTime = 1.0,
  }) : maxLifeTime = lifeTime;

  double get opacity => max(0.0, min(1.0, lifeTime / maxLifeTime));
  bool get isExpired => lifeTime <= 0;
}

/// Partículas visuales para sangre, chispas, polvo o magia
class ParticleEntity {
  Offset position;
  Offset velocity;
  final Color color;
  double radius;
  double lifeTime;
  final double maxLifeTime;

  ParticleEntity({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.lifeTime,
  }) : maxLifeTime = lifeTime;

  double get opacity => max(0.0, min(1.0, lifeTime / maxLifeTime));
  bool get isExpired => lifeTime <= 0;
}
