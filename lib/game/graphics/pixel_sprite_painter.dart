import 'package:flutter/material.dart';
import 'pixel_art_data.dart';

/// Dibuja eficientemente una matriz de pixel art en un Canvas con soporte para
/// escalado, volteo horizontal (orientación), efectos de impacto (daño) y sombras.
class PixelSpritePainter extends CustomPainter {
  final PixelSpriteData sprite;
  final double pixelSize;
  final bool flipX;
  final Color? tintColor;
  final double tintIntensity;
  final bool drawShadow;

  PixelSpritePainter({
    required this.sprite,
    this.pixelSize = 3.0,
    this.flipX = false,
    this.tintColor,
    this.tintIntensity = 0.0,
    this.drawShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final totalWidth = sprite.width * pixelSize;
    final totalHeight = sprite.height * pixelSize;

    // Sombra proyectada en el suelo
    if (drawShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(totalWidth / 2, totalHeight - pixelSize * 0.5),
          width: totalWidth * 0.8,
          height: pixelSize * 3.5,
        ),
        shadowPaint,
      );
    }

    if (flipX) {
      canvas.translate(totalWidth, 0);
      canvas.scale(-1, 1);
    }

    final paint = Paint()..isAntiAlias = false;

    for (int y = 0; y < sprite.matrix.length; y++) {
      final row = sprite.matrix[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        if (char == '.') continue; // Transparente

        Color? color = sprite.palette[char];
        if (color == null || color.a == 0) continue;

        // Efecto de tinte (por ejemplo, destello rojo al recibir daño)
        if (tintColor != null && tintIntensity > 0) {
          color = Color.lerp(color, tintColor, tintIntensity) ?? color;
        }

        paint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(
            x * pixelSize,
            y * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PixelSpritePainter oldDelegate) {
    return oldDelegate.sprite != sprite ||
        oldDelegate.pixelSize != pixelSize ||
        oldDelegate.flipX != flipX ||
        oldDelegate.tintColor != tintColor ||
        oldDelegate.tintIntensity != tintIntensity;
  }
}

/// Widget reutilizable para mostrar un sprite de Pixel Art con animación sutil
class PixelSpriteWidget extends StatelessWidget {
  final PixelSpriteData sprite;
  final double pixelSize;
  final bool flipX;
  final Color? tintColor;
  final double tintIntensity;
  final bool animateBobbing;
  final double bobbingOffset;

  const PixelSpriteWidget({
    super.key,
    required this.sprite,
    this.pixelSize = 3.5,
    this.flipX = false,
    this.tintColor,
    this.tintIntensity = 0.0,
    this.animateBobbing = false,
    this.bobbingOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final width = sprite.width * pixelSize;
    final height = sprite.height * pixelSize;

    Widget child = CustomPaint(
      size: Size(width, height),
      painter: PixelSpritePainter(
        sprite: sprite,
        pixelSize: pixelSize,
        flipX: flipX,
        tintColor: tintColor,
        tintIntensity: tintIntensity,
      ),
    );

    if (animateBobbing && bobbingOffset != 0) {
      child = Transform.translate(
        offset: Offset(0, bobbingOffset),
        child: child,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
