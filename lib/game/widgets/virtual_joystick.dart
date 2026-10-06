import 'package:flutter/material.dart';

/// Joystick virtual táctil para movimiento analógico en dispositivos móviles y táctiles.
class VirtualJoystick extends StatefulWidget {
  final double radius;
  final ValueChanged<Offset> onDirectionChanged;

  const VirtualJoystick({
    super.key,
    this.radius = 60.0,
    required this.onDirectionChanged,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;

  void _updatePosition(Offset localPosition) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localPosition - center;
    final distance = delta.distance;

    if (distance <= widget.radius) {
      _knobPosition = delta;
    } else {
      _knobPosition = (delta / distance) * widget.radius;
    }

    final normalized = Offset(
      _knobPosition.dx / widget.radius,
      _knobPosition.dy / widget.radius,
    );

    widget.onDirectionChanged(normalized);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    _knobPosition = Offset.zero;
    widget.onDirectionChanged(Offset.zero);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    return GestureDetector(
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: _onPanEnd,
      onPanCancel: () => _onPanEnd(DragEndDetails()),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Puntos guía
            Icon(
              Icons.gamepad_outlined,
              size: 32,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            // Perilla móvil
            Transform.translate(
              offset: _knobPosition,
              child: Container(
                width: widget.radius * 0.9,
                height: widget.radius * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.grey.shade400,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE63946),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
