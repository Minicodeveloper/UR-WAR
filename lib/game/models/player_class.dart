import 'package:flutter/material.dart';
import '../graphics/pixel_art_data.dart';

enum PlayerRoleType {
  knight,
  ranger,
  mage,
  cleric,
}

class PlayerClass {
  final PlayerRoleType type;
  final String name;
  final String roleTitle;
  final String description;
  final double maxHealth;
  final double moveSpeed;
  final double baseDamage;
  final double attackRange;
  final double attackCooldownSeconds;
  final String specialSkillName;
  final String specialSkillDescription;
  final double specialSkillCooldownSeconds;
  final bool isMelee;
  final Color themeColor;
  final PixelSpriteData spriteIdle;
  final PixelSpriteData spriteAttack;
  final String weaponName;

  const PlayerClass({
    required this.type,
    required this.name,
    required this.roleTitle,
    required this.description,
    required this.maxHealth,
    required this.moveSpeed,
    required this.baseDamage,
    required this.attackRange,
    required this.attackCooldownSeconds,
    required this.specialSkillName,
    required this.specialSkillDescription,
    required this.specialSkillCooldownSeconds,
    required this.isMelee,
    required this.themeColor,
    required this.spriteIdle,
    required this.spriteAttack,
    required this.weaponName,
  });

  static final List<PlayerClass> availableClasses = [
    PlayerClass(
      type: PlayerRoleType.knight,
      name: 'Caballero Imperial',
      roleTitle: 'Tanque & Asalto Cuerpo a Cuerpo',
      description:
          'Armado con armadura de acero y mandoble forjado. Alta resistencia y daño frontal en abanico.',
      maxHealth: 300,
      moveSpeed: 175,
      baseDamage: 45,
      attackRange: 80,
      attackCooldownSeconds: 0.45,
      specialSkillName: 'Torbellino de Acero',
      specialSkillDescription:
          'Gira a 360° causando 120 de daño y repeliendo a todos los invasores cercanos.',
      specialSkillCooldownSeconds: 6.0,
      isMelee: true,
      themeColor: const Color(0xFFE63946),
      spriteIdle: PixelArtLibrary.knightIdle,
      spriteAttack: PixelArtLibrary.knightAttack,
      weaponName: 'Mandoble de Acero',
    ),
    PlayerClass(
      type: PlayerRoleType.ranger,
      name: 'Cazadora Silvana',
      roleTitle: 'Tiradora Ágil a Distancia',
      description:
          'Gran agilidad y disparos de largo alcance. Mantiene a las hordas a raya antes de que alcancen la aldea.',
      maxHealth: 170,
      moveSpeed: 230,
      baseDamage: 32,
      attackRange: 320,
      attackCooldownSeconds: 0.35,
      specialSkillName: 'Lluvia de Flechas',
      specialSkillDescription:
          'Dispara una ráfaga masiva en abanico de 8 flechas perforantes simultáneas.',
      specialSkillCooldownSeconds: 5.0,
      isMelee: false,
      themeColor: const Color(0xFF2B9348),
      spriteIdle: PixelArtLibrary.rangerIdle,
      spriteAttack: PixelArtLibrary.rangerAttack,
      weaponName: 'Arco Compuesto Élfico',
    ),
    PlayerClass(
      type: PlayerRoleType.mage,
      name: 'Mago Arcano',
      roleTitle: 'Destrucción de Área & Magia Elemental',
      description:
          'Canaliza energía mágica en esferas ígneas explosivas que aniquilan grupos densos de enemigos.',
      maxHealth: 140,
      moveSpeed: 185,
      baseDamage: 55,
      attackRange: 290,
      attackCooldownSeconds: 0.55,
      specialSkillName: 'Meteoro Cataclísmico',
      specialSkillDescription:
          'Detona una gigantesca supernova arcana que arrasa a todos los monstruos en un radio de 180px.',
      specialSkillCooldownSeconds: 7.5,
      isMelee: false,
      themeColor: const Color(0xFF7B2CBF),
      spriteIdle: PixelArtLibrary.mageIdle,
      spriteAttack: PixelArtLibrary.mageIdle,
      weaponName: 'Báculo de Fuego Astral',
    ),
    PlayerClass(
      type: PlayerRoleType.cleric,
      name: 'Guardiana Sagrada',
      roleTitle: 'Soporte, Fortificación & Sanación',
      description:
          'Protectora devota con martillo bendito. Capaz de curar sus propias heridas y reparar el Gran Salón de la Aldea.',
      maxHealth: 250,
      moveSpeed: 190,
      baseDamage: 40,
      attackRange: 90,
      attackCooldownSeconds: 0.50,
      specialSkillName: 'Bendición Protectora',
      specialSkillDescription:
          'Cura 90 HP al héroe y restaura instantáneamente 250 HP a la estructura de la Aldea.',
      specialSkillCooldownSeconds: 9.0,
      isMelee: true,
      themeColor: const Color(0xFFFFB703),
      spriteIdle: PixelArtLibrary.clericIdle,
      spriteAttack: PixelArtLibrary.clericIdle,
      weaponName: 'Martillo Rúnico Divino',
    ),
  ];
}
