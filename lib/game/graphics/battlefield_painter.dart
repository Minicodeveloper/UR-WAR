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

    // 4. DIBUJAR EDIFICIOS DE LA ALDEA
    _paintVillageBuildings(canvas);

    // 5. DIBUJAR ENEMIGOS
    _paintEnemies(canvas);

    // 6. DIBUJAR JUGADOR
    _paintPlayer(canvas);

    // 7. DIBUJAR PROYECTILES
    _paintProjectiles(canvas);

    // 8. DIBUJAR PARTÍCULAS
    _paintParticles(canvas);

    // 9. DIBUJAR TEXTOS FLOTANTES
    _paintFloatingTexts(canvas);

    canvas.restore();

    // 10. DIBUJAR FLECHAS RADAR DE ENEMIGOS FUERA DE PANTALLA (ESPACIO DE PANTALLA)
    _paintOffscreenEnemyRadar(canvas, size);
  }

  void _paintTerrain(Canvas canvas, GameMapModel map) {
    // Fondo base del mapa
    final bgPaint = Paint()..color = map.groundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, map.worldWidth, map.worldHeight),
      bgPaint,
    );

    // Patrón sutil de cuadrícula de baldosas
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

    // Bordes del mapa
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

    // Plaza de adoquines central de la aldea
    final plazaPaint = Paint()
      ..color = map.pathColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), 220, plazaPaint);

    // Caminos que salen hacia los cuatro puntos cardinales
    final pathPaint = Paint()
      ..color = map.pathColor.withValues(alpha: 0.6)
      ..strokeWidth = 60.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(centerX, centerY), Offset(centerX, 50), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX, map.worldHeight - 50), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(50, centerY), pathPaint);
    canvas.drawLine(Offset(centerX, centerY), Offset(map.worldWidth - 50, centerY), pathPaint);

    // Círculo de empalizada / protección de la aldea
    final fencePaint = Paint()
      ..color = map.wallColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(Offset(centerX, centerY), 240, fencePaint);
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
      } else if (obs.type == 'bonfire') {
        final firePaint = Paint()..color = const Color(0xFFFF9F1C);
        canvas.drawCircle(obs.position, obs.radius, firePaint);
        final glow = Paint()..color = const Color(0xFFFF5400).withValues(alpha: 0.5);
        canvas.drawCircle(obs.position, obs.radius * 1.5, glow);
      } else if (obs.type == 'lava') {
        final lavaPaint = Paint()..color = const Color(0xFFD00000);
        canvas.drawCircle(obs.position, obs.radius, lavaPaint);
        final lavaCore = Paint()..color = const Color(0xFFFFBA08);
        canvas.drawCircle(obs.position, obs.radius * 0.5, lavaCore);
      }
    }
  }

  void _paintVillageBuildings(Canvas canvas) {
    for (final b in engine.villageBuildings) {
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

      // Barra de vida del enemigo
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

    // Barra de salud sobre el jugador
    _paintHealthBar(
      canvas,
      center: Offset(player.position.dx, drawPos.dy - 10),
      width: 44,
      height: 5,
      current: player.health,
      max: player.maxHealth,
      barColor: const Color(0xFF55A630),
      label: player.playerClass.name,
    );
  }

  void _paintProjectiles(Canvas canvas) {
    for (final p in engine.projectiles) {
      final paint = Paint()..color = p.color;
      canvas.drawCircle(p.position, p.radius, paint);

      // Estela luminosa
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

  void _paintOffscreenEnemyRadar(Canvas canvas, Size size) {
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

      // Calcular punto de intersección en el borde de la pantalla
      final centerScreen = Offset(size.width / 2, size.height / 2);
      final enemyInScreen = enemy.position - engine.cameraOffset;
      final diff = enemyInScreen - centerScreen;
      final angle = atan2(diff.dy, diff.dx);

      const margin = 24.0;
      final edgeX = (centerScreen.dx + cos(angle) * (size.width / 2 - margin))
          .clamp(margin, size.width - margin);
      final edgeY = (centerScreen.dy + sin(angle) * (size.height / 2 - margin))
          .clamp(margin, size.height - margin);

      final point = Offset(edgeX, edgeY);

      // Dibujar triángulo puntero hacia el enemigo
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

    // Fondo oscuro
    final bgPaint = Paint()..color = const Color(0xFF141419);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left - 1, top - 1, width + 2, height + 2), const Radius.circular(3)),
      bgPaint,
    );

    // Barra de relleno proporcional
    final pct = (current / max).clamp(0.0, 1.0);
    final fillPaint = Paint()..color = barColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, width * pct, height), const Radius.circular(2)),
      fillPaint,
    );

    // Etiqueta de texto si existe
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
