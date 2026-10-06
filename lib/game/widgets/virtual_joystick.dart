import 'dart:math';
import 'package:flutter/material.dart';

/// Joystick virtual táctil dinámico flotante de alta visibilidad para celulares y tablets.
/// Permite control táctil suave en 360 grados, soporte para movimiento por arrastre en pantalla
/// y base fija de alto contraste visual estilo Arcade/Pixel Art.
class VirtualJoystick extends StatefulWidget {
  final double radius;
  final ValueChanged<Offset> onDirectionChanged;

  const VirtualJoystick({
    super.key,
    this.radius = 50.0,
    required this.onDirectionChanged,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset? _touchCenter;
  Offset _knobDelta = Offset.zero;
  bool _isInteracting = false;

  void _onPointerDown(Offset localPos, Size areaSize) {
    // Clamping para que la base del joystick nunca se corte fuera de los bordes visibles
    final margin = widget.radius + 8.0;
    final clampedX = localPos.dx.clamp(margin, max(margin, areaSize.width - margin)).toDouble();
    final clampedY = localPos.dy.clamp(margin, max(margin, areaSize.height - margin)).toDouble();

    _touchCenter = Offset(clampedX, clampedY);
    _isInteracting = true;
    _updateDirection(localPos);
  }

  void _onPointerMove(Offset localPos) {
    if (!_isInteracting) return;
    _updateDirection(localPos);
  }

  void _onPointerUp() {
    _isInteracting = false;
    _knobDelta = Offset.zero;
    _touchCenter = null;
    widget.onDirectionChanged(Offset.zero);
    if (mounted) setState(() {});
  }

  void _updateDirection(Offset localPos) {
    final center = _touchCenter ?? localPos;
    final delta = localPos - center;
    final distance = delta.distance;

    if (distance <= 4.0) {
      // Pequeña zona muerta para evitar oscilaciones involuntarias al apoyar el pulgar
      _knobDelta = Offset.zero;
      widget.onDirectionChanged(Offset.zero);
    } else if (distance <= widget.radius) {
      _knobDelta = delta;
      widget.onDirectionChanged(Offset(delta.dx / widget.radius, delta.dy / widget.radius));
    } else {
      _knobDelta = (delta / distance) * widget.radius;
      widget.onDirectionChanged(Offset(delta.dx / distance, delta.dy / distance));
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : widget.radius * 2 + 40,
          constraints.maxHeight.isFinite ? constraints.maxHeight : widget.radius * 2 + 40,
        );

        // Posición de reposo por defecto (esquina inferior izquierda con margen seguro)
        final defaultCenter = Offset(
          widget.radius + 18.0,
          areaSize.height - widget.radius - 18.0,
        );

        final activeCenter = _touchCenter ?? defaultCenter;
        final diameter = widget.radius * 2;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _onPointerDown(e.localPosition, areaSize),
          onPointerMove: (e) => _onPointerMove(e.localPosition),
          onPointerUp: (_) => _onPointerUp(),
          onPointerCancel: (_) => _onPointerUp(),
          child: SizedBox(
            width: areaSize.width,
            height: areaSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. BASE DEL JOYSTICK (Anillo con brújula y alto contraste neon)
                Positioned(
                  left: activeCenter.dx - widget.radius,
                  top: activeCenter.dy - widget.radius,
                  child: IgnorePointer(
                    child: Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.88),
                            const Color(0xFF0F172A).withValues(alpha: 0.96),
                          ],
                        ),
                        border: Border.all(
                          color: _isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                          width: 2.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166))
                                .withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Flechas de dirección cardinal en neón oro
                          Positioned(
                            top: 4,
                            child: Icon(
                              Icons.arrow_drop_up_rounded,
                              color: const Color(0xFFFFD166).withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            child: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: const Color(0xFFFFD166).withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ),
                          Positioned(
                            left: 4,
                            child: Icon(
                              Icons.arrow_left_rounded,
                              color: const Color(0xFFFFD166).withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            child: Icon(
                              Icons.arrow_right_rounded,
                              color: const Color(0xFFFFD166).withValues(alpha: 0.85),
                              size: 20,
                            ),
                          ),
                          // Retícula interior tenue
                          Container(
                            width: widget.radius * 1.1,
                            height: widget.radius * 1.1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. PERILLA MÓVIL DEL JOYSTICK (Knob)
                Positioned(
                  left: activeCenter.dx + _knobDelta.dx - (widget.radius * 0.45),
                  top: activeCenter.dy + _knobDelta.dy - (widget.radius * 0.45),
                  child: IgnorePointer(
                    child: Container(
                      width: widget.radius * 0.9,
                      height: widget.radius * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFD166),
                            Color(0xFFFF5400),
                            Color(0xFFE63946),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5400).withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Etiqueta informativa visual cuando está en reposo
                if (!_isInteracting)
                  Positioned(
                    left: defaultCenter.dx - 32,
                    top: defaultCenter.dy + widget.radius + 6,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          'JOYSTICK',
                          style: TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
