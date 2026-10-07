import 'package:flutter/material.dart';
import '../graphics/pixel_art_data.dart';

enum EnemyCategory { goblin, orc, skeleton, necromancer, bossTitan }

class EnemyConfig {
  final EnemyCategory category;
  final String name;
  final double maxHealth;
  final double speed;
  final double attackDamage;
  final double attackRange;
  final double attackCooldownSeconds;
  final int goldReward;
  final int scoreReward;
  final int xpReward;
  final bool isRanged;
  final bool isBoss;
  final double hitRadius;
  final PixelSpriteData sprite;
  final Color healthBarColor;

  const EnemyConfig({
    required this.category,
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.attackDamage,
    required this.attackRange,
    required this.attackCooldownSeconds,
    required this.goldReward,
    required this.scoreReward,
    required this.xpReward,
    required this.isRanged,
    required this.isBoss,
    required this.hitRadius,
    required this.sprite,
    this.healthBarColor = const Color(0xFFEF233C),
  });

  static EnemyConfig get goblin => EnemyConfig(
    category: EnemyCategory.goblin,
    name: 'Goblin Saqueador',
    maxHealth: 65,
    speed: 135,
    attackDamage: 12,
    attackRange: 32,
    attackCooldownSeconds: 0.8,
    goldReward: 15,
    scoreReward: 30,
    xpReward: 15,
    isRanged: false,
    isBoss: false,
    hitRadius: 20,
    sprite: PixelArtLibrary.goblin,
  );

  static EnemyConfig get orc => EnemyConfig(
    category: EnemyCategory.orc,
    name: 'Orco Berserker',
    maxHealth: 190,
    speed: 85,
    attackDamage: 30,
    attackRange: 40,
    attackCooldownSeconds: 1.2,
    goldReward: 35,
    scoreReward: 70,
    xpReward: 25,
    isRanged: false,
    isBoss: false,
    hitRadius: 28,
    sprite: PixelArtLibrary.orc,
  );

  static EnemyConfig get skeleton => EnemyConfig(
    category: EnemyCategory.skeleton,
    name: 'Esqueleto Arquero',
    maxHealth: 90,
    speed: 95,
    attackDamage: 18,
    attackRange: 240,
    attackCooldownSeconds: 1.5,
    goldReward: 25,
    scoreReward: 50,
    xpReward: 20,
    isRanged: true,
    isBoss: false,
    hitRadius: 22,
    sprite: PixelArtLibrary.skeleton,
  );

  static EnemyConfig get necromancer => EnemyConfig(
    category: EnemyCategory.necromancer,
    name: 'Nigromante Sombrío',
    maxHealth: 160,
    speed: 80,
    attackDamage: 28,
    attackRange: 260,
    attackCooldownSeconds: 1.8,
    goldReward: 45,
    scoreReward: 90,
    xpReward: 35,
    isRanged: true,
    isBoss: false,
    hitRadius: 24,
    sprite: PixelArtLibrary.necromancer,
  );

  static EnemyConfig get bossTitan => EnemyConfig(
    category: EnemyCategory.bossTitan,
    name: 'TITÁN DESTRUCTOR',
    maxHealth: 950,
    speed: 60,
    attackDamage: 65,
    attackRange: 60,
    attackCooldownSeconds: 1.5,
    goldReward: 200,
    scoreReward: 500,
    xpReward: 120,
    isRanged: false,
    isBoss: true,
    hitRadius: 45,
    sprite: PixelArtLibrary.bossTitan,
    healthBarColor: const Color(0xFFFF9F1C),
  );

  static EnemyConfig bossForBiome(String biome, int level) => EnemyConfig(
    category: EnemyCategory.bossTitan,
    name: biome == 'snow'
        ? 'ESPECTRO DE NIFLHEIM'
        : biome == 'lava'
        ? 'DRAGÓN INFERNUS'
        : 'TITÁN DEL VALLE',
    maxHealth: 800 + level * 150,
    speed: biome == 'snow' ? 75 : 60,
    attackDamage: 38 + level * 5,
    attackRange: 70,
    attackCooldownSeconds: 2,
    goldReward: 250,
    scoreReward: 650,
    xpReward: 240,
    isRanged: false,
    isBoss: true,
    hitRadius: 42,
    sprite: biome == 'snow'
        ? PixelArtLibrary.frostWraith
        : biome == 'lava'
        ? PixelArtLibrary.magmaDragon
        : PixelArtLibrary.bossTitan,
    healthBarColor: biome == 'snow'
        ? const Color(0xFF63DDFF)
        : const Color(0xFFFF9F1C),
  );
}
