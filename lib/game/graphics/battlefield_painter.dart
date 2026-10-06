import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/game_engine.dart';
import '../models/entity.dart';
import '../models/game_map.dart';
import 'pixel_art_data.dart';
import 'pixel_sprite_painter.dart';

class BattlefieldPainter extends CustomPainter {
  final GameEngine engine;

  BattlefieldPainter({required this.engine}) : super(repaint: engine);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Aplicar transformación de cámara
    canvas.translate(-engine.cameraOffset.dx, -engine.cameraOffset.dy);

    final map = engine.map;

    // 1. DIBUJAR TERRENO Y BIOMA
    _paintTerrain(canvas, map);

    // 2. DIBUJAR CAMINOS Y ALDEA
    _paintVillageGround(canvas, map);

    // 3. DIBUJAR OBSTÁCULOS AMBIENTALES
    _paintObstacles(canvas, map);

    // 4. DIBUJAR CAMPAMENTOS RIVALES
    _paintRivalCamps(canvas);

    // 5. DIBUJAR EDIFICIOS DE LA ALDEA Y CONSTRUCCIONES
    _paintVillageBuildings(canvas);

    // 6. DIBUJAR ENEMIGOS
    _paintEnemies(canvas);

    // 7. DIBUJAR JUGADOR
    _paintPlayer(canvas);

    // 8. DIBUJAR PROYECTILES
    _paintProjectiles(canvas);

    // 9. DIBUJAR PARTÍCULAS
    _paintParticles(canvas);

    // 10. DIBUJAR TEXTOS FLOTANTES
    _paintFloatingTexts(canvas);

    // 11. DIBUJAR NIEBLA DE GUERRA (FOG OF WAR)
    _paintFogOfWar(canvas, map);

    canvas.restore();

    // 12. DIBUJAR RADAR PERIMETRAL DE ENEMIGOS FUERA DE PANTALLA
    _paintOffscreenEnemyRadar(canvas, size);
  }

  void _paintTerrain(Canvas canvas, GameMapModel map) {
    final bgPaint = Paint()..color = map.groundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, map.worldWidth, map.worldHeight),
      bgPaint,
    );

    final gridPaint = Paint()
      ..color = map.groundAccentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const tileSize = 60.0;
    for (double x = 0; x < map.worldWidth; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, map.worldHeight), gridPaint);
    }
    for (double y = 0; y < map.worldHeight; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(map.worldWidth, y), gridPaint);
    }

    final borderPaint = Paint()
      ..color = map.wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;
    canvas.drawRect(
      Rect.fromLTWH(6, 6, map.worldWidth - 12, map.worldHeight - 12),
      borderPaint,
    );
  }

  void _paintVillageGround(Canvas canvas, GameMapModel map) {
    final centerX = map.worldWidth / 2;
    final centerY = map.worldHeight / 2;

    final plazaPaint = Paint()
      ..color = map.pathColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), 230, plazaPaint);

    final pathPaint = Paint()
      ..color = map.pathColor.withValues(alpha: 0.6)
      ..strokeWidth = 60.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(centerX, centerY), Offset(centerX, 50), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX, map.worldHeight - 50), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(50, centerY), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(map.worldWidth - 50, centerY), pathPaint);

    final fencePaint = Paint()
      ..color = map.wallColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(Offset(centerX, centerY), 250, fencePaint);
  }

  void _paintObstacles(Canvas canvas, GameMapModel map) {
    for (final obs in map.obstacles) {
      if (obs.type == 'tree') {
        _drawPixelSprite(
          canvas,
          PixelArtLibrary.forestTree,
          obs.position - const Offset(24, 30),
          pixelSize: 3.0,
        );
      } else if (obs.type == 'rock') {
        final rockPaint = Paint()..color = const Color(0xFF6C757D);
        canvas.drawCircle(obs.position, obs.radius, rockPaint);
        final rockHighlight = Paint()..color = const Color(0xFFADB5BD);
        canvas.drawCircle(obs.position - const Offset(4, 4), obs.radius * 0.6, rockHighlight);
      } else if (obs.type == 'lava') {
        final lavaPaint = Paint()..color = const Color(0xFFD00000);
        canvas.drawCircle(obs.position, obs.radius, lavaPaint);
        final lavaCore = Paint()..color = const Color(0xFFFFBA08);
        canvas.drawCircle(obs.position, obs.radius * 0.5, lavaCore);
      }
    }
  }

  void _paintRivalCamps(Canvas canvas) {
    for (final camp in engine.rivalCamps) {
      if (camp.isDestroyed) continue;

      // Base del campamento rival
      final basePaint = Paint()..color = const Color(0xFF6A040F);
      canvas.drawCircle(camp.position, camp.radius, basePaint);

      // Icono de fortaleza enemiga
      _drawPixelSprite(
        canvas,
        PixelArtLibrary.orc,
        camp.position - const Offset(27, 27),
        pixelSize: 3.0,
        tintColor: camp.hitFlashTimer > 0 ? Colors.redAccent : null,
        tintIntensity: camp.hitFlashTimer > 0 ? 0.8 : 0.0,
      );

      // Barra de vida del campamento
      _paintHealthBar(
        canvas,
        center: Offset(camp.position.dx, camp.position.dy - camp.radius - 12),
        width: 80,
        height: 7,
        current: camp.health,
        max: camp.maxHealth,
        barColor: const Color(0xFFD00000),
        label: camp.name,
      );
    }
  }

  void _paintVillageBuildings(Canvas canvas) {
    for (final b in engine.villageBuildings) {
      if (b.isDead) continue;

      PixelSpriteData sprite;
      double pixelScale = 3.0;

      switch (b.type) {
        case BuildingType.townHall:
          sprite = PixelArtLibrary.townHall;
          pixelScale = 3.6;
          break;
        case BuildingType.watchtower:
          sprite = PixelArtLibrary.watchtower;
          pixelScale = 3.0;
          break;
        case BuildingType.cottage:
          sprite = PixelArtLibrary.cottage;
          pixelScale = 3.0;
          break;
        case BuildingType.barricade:
          sprite = PixelArtLibrary.watchtower;
          pixelScale = 2.0;
          break;
        case BuildingType.goldMine:
          sprite = PixelArtLibrary.cottage;
          pixelScale = 2.6;
          break;
      }

      final spriteW = sprite.width * pixelScale;
      final spriteH = sprite.height * pixelScale;
      final drawPos = b.position - Offset(spriteW / 2, spriteH / 2);

      _drawPixelSprite(
        canvas,
        sprite,
        drawPos,
        pixelSize: pixelScale,
        tintColor: b.hitFlashTimer > 0 ? Colors.red : null,
        tintIntensity: b.hitFlashTimer > 0 ? 0.7 : 0.0,
      );

      // Si es una mina de oro, dibujar icono de moneda sobre ella
      if (b.type == BuildingType.goldMine) {
        final coinPaint = Paint()..color = const Color(0xFFFFD166);
        canvas.drawCircle(b.position - const Offset(0, 18), 8, coinPaint);
      }

      // Barra de vida del edificio
      _paintHealthBar(
        canvas,
        center: Offset(b.position.dx, drawPos.dy - 10),
        width: b.type == BuildingType.townHall ? 90 : 50,
        height: b.type == BuildingType.townHall ? 8 : 5,
        current: b.health,
        max: b.maxHealth,
        barColor: b.type == BuildingType.townHall ? const Color(0xFF00BBF9) : const Color(0xFF55A630),
        label: b.type == BuildingType.townHall ? 'SALÓN COMUNAL' : null,
      );
    }
  }

  void _paintEnemies(Canvas canvas) {
    for (final enemy in engine.enemies) {
      final config = enemy.config;
      final pixelScale = config.isBoss ? 4.0 : 3.0;
      final spriteW = config.sprite.width * pixelScale;
      final spriteH = config.sprite.height * pixelScale;

      final bobbing = sin(enemy.walkPhase) * 3.0;
      final drawPos = enemy.position - Offset(spriteW / 2, spriteH / 2 + bobbing);

      _drawPixelSprite(
        canvas,
        config.sprite,
        drawPos,
        pixelSize: pixelScale,
        flipX: enemy.facingLeft,
        tintColor: enemy.hitFlashTimer > 0 ? Colors.redAccent : null,
        tintIntensity: enemy.hitFlashTimer > 0 ? 0.75 : 0.0,
      );

      _paintHealthBar(
        canvas,
        center: Offset(enemy.position.dx, drawPos.dy - 8),
        width: config.isBoss ? 80 : 32,
        height: config.isBoss ? 7 : 4,
        current: enemy.health,
        max: config.maxHealth,
        barColor: config.healthBarColor,
        label: config.isBoss ? config.name : null,
      );
    }
  }

  void _paintPlayer(Canvas canvas) {
    final player = engine.player;
    const pixelScale = 3.2;

    final sprite = player.attackAnimTimer > 0
        ? player.playerClass.spriteAttack
        : player.playerClass.spriteIdle;

    final spriteW = sprite.width * pixelScale;
    final spriteH = sprite.height * pixelScale;

    final bobbing = player.isMoving ? sin(player.walkPhase) * 3.5 : 0.0;
    final drawPos = player.position - Offset(spriteW / 2, spriteH / 2 + bobbing);

    _drawPixelSprite(
      canvas,
      sprite,
      drawPos,
      pixelSize: pixelScale,
      flipX: player.facingLeft,
      tintColor: player.hitFlashTimer > 0 ? Colors.redAccent : null,
      tintIntensity: player.hitFlashTimer > 0 ? 0.75 : 0.0,
    );

    // Indicador sutil de aura / mira
    final aimDir = player.facingLeft ? const Offset(-1, 0) : const Offset(1, 0);
    final indicatorPaint = Paint()
      ..color = player.playerClass.themeColor.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(player.position + aimDir * 28, 6.0, indicatorPaint);

    _paintHealthBar(
      canvas,
      center: Offset(player.position.dx, drawPos.dy - 10),
      width: 44,
      height: 5,
      current: player.health,
      max: player.maxHealth,
      barColor: const Color(0xFF55A630),
      label: 'Nvl ${player.level} ${player.playerClass.name}',
    );
  }

  void _paintProjectiles(Canvas canvas) {
    for (final p in engine.projectiles) {
      final paint = Paint()..color = p.color;
      canvas.drawCircle(p.position, p.radius, paint);

      final trailPaint = Paint()
        ..color = p.color.withValues(alpha: 0.4)
        ..strokeWidth = p.radius * 1.5;
      final trailEnd = p.position - (p.velocity / p.velocity.distance) * (p.radius * 3);
      canvas.drawLine(p.position, trailEnd, trailPaint);
    }
  }

  void _paintParticles(Canvas canvas) {
    for (final p in engine.particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(p.position, p.radius, paint);
    }
  }

  void _paintFloatingTexts(Canvas canvas) {
    for (final ft in engine.floatingTexts) {
      final textSpan = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withValues(alpha: ft.opacity),
          fontSize: ft.fontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: ft.opacity),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, ft.position - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintFogOfWar(Canvas canvas, GameMapModel map) {
    final fogPaint = Paint()..color = Colors.black.withValues(alpha: 0.70);

    for (int r = 0; r < engine.fogRows; r++) {
      for (int c = 0; c < engine.fogCols; c++) {
        if (!engine.fogExplored[r][c]) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * GameEngine.fogTileSize,
              r * GameEngine.fogTileSize,
              GameEngine.fogTileSize + 1.0,
              GameEngine.fogTileSize + 1.0,
            ),
            fogPaint,
          );
        }
      }
    }
  }

  void _paintOffscreenEnemyRadar(Canvas canvas, Size size) {
    if (size.width <= 50.0 || size.height <= 50.0) return;

    final viewportRect = Rect.fromLTWH(
      engine.cameraOffset.dx,
      engine.cameraOffset.dy,
      size.width,
      size.height,
    );

    final radarPaint = Paint()
      ..color = const Color(0xFFEF233C)
      ..style = PaintingStyle.fill;

    for (final enemy in engine.enemies) {
      if (viewportRect.contains(enemy.position)) continue;

      final centerScreen = Offset(size.width / 2, size.height / 2);
      final enemyInScreen = enemy.position - engine.cameraOffset;
      final diff = enemyInScreen - centerScreen;
      final angle = atan2(diff.dy, diff.dx);

      const margin = 24.0;
      final minX = margin;
      final maxX = max(minX, size.width - margin);
      final minY = margin;
      final maxY = max(minY, size.height - margin);

      final edgeX = (centerScreen.dx + cos(angle) * (size.width / 2 - margin))
          .clamp(minX, maxX);
      final edgeY = (centerScreen.dy + sin(angle) * (size.height / 2 - margin))
          .clamp(minY, maxY);

      final point = Offset(edgeX, edgeY);

      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle);

      final path = Path()
        ..moveTo(8, 0)
        ..lineTo(-6, -6)
        ..lineTo(-6, 6)
        ..close();
      canvas.drawPath(path, radarPaint);
      canvas.restore();
    }
  }

  void _paintHealthBar(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double current,
    required double max,
    required Color barColor,
    String? label,
  }) {
    final left = center.dx - width / 2;
    final top = center.dy - height / 2;

    final bgPaint = Paint()..color = const Color(0xFF141419);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left - 1, top - 1, width + 2, height + 2), const Radius.circular(3)),
      bgPaint,
    );

    final pct = (current / max).clamp(0.0, 1.0);
    final fillPaint = Paint()..color = barColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, width * pct, height), const Radius.circular(2)),
      fillPaint,
    );

    if (label != null) {
      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, top - tp.height - 2));
    }
  }

  void _drawPixelSprite(
    Canvas canvas,
    PixelSpriteData sprite,
    Offset pos, {
    required double pixelSize,
    bool flipX = false,
    Color? tintColor,
    double tintIntensity = 0.0,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final painter = PixelSpritePainter(
      sprite: sprite,
      pixelSize: pixelSize,
      flipX: flipX,
      tintColor: tintColor,
      tintIntensity: tintIntensity,
      drawShadow: true,
    );
    painter.paint(canvas, Size(sprite.width * pixelSize, sprite.height * pixelSize));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BattlefieldPainter oldDelegate) => true;
}
