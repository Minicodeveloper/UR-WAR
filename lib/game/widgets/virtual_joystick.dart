import 'package:flutter/material.dart';

/// Joystick virtual táctil de alta fidelidad e independencia para Android y Web.
/// Cuenta con tamaño explícito auto-contenido (185x185), base de neón de alto contraste,
/// perilla brillante de rubí/ámbar, modo Cruceta Táctica Arcade (D-Pad) y
/// botones táctiles grandes que garantizan visualización inmediata y control táctil suave.
class VirtualJoystick extends StatefulWidget {
  final double radius;
  final ValueChanged<Offset> onDirectionChanged;
  final ValueChanged<Offset>? onTapField;

  const VirtualJoystick({
    super.key,
    this.radius = 48.0,
    required this.onDirectionChanged,
    this.onTapField,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> with SingleTickerProviderStateMixin {
  Offset? _touchCenter;
  Offset _knobDelta = Offset.zero;
  bool _isInteracting = false;
  bool _isDpadMode = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double boxWidth = 185.0;
  static const double boxHeight = 185.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPointerDown(Offset localPos, Offset baseCenter) {
    if (_isDpadMode) return;
    _isInteracting = true;
    _touchCenter = localPos;
    _updateDirection(localPos);
  }

  void _onPointerMove(Offset localPos) {
    if (_isDpadMode || !_isInteracting) return;
    _updateDirection(localPos);
  }

  void _onPointerUp() {
    if (_isDpadMode) return;
    _isInteracting = false;
    _knobDelta = Offset.zero;
    _touchCenter = null;
    widget.onDirectionChanged(Offset.zero);
    if (mounted) setState(() {});
  }

  void _updateDirection(Offset localPos) {
    if (_touchCenter == null) return;
    final delta = localPos - _touchCenter!;
    final distance = delta.distance;

    if (distance <= 4.0) {
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

  void _onDpadPress(Offset direction) {
    widget.onDirectionChanged(direction);
  }

  void _onDpadRelease() {
    widget.onDirectionChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final defaultCenter = Offset(boxWidth / 2, boxHeight / 2 + 6.0);
    final diameter = widget.radius * 2;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _onPointerDown(e.localPosition, defaultCenter),
      onPointerMove: (e) => _onPointerMove(e.localPosition),
      onPointerUp: (_) => _onPointerUp(),
      onPointerCancel: (_) => _onPointerUp(),
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ==========================================
            // ENCABEZADO: ETIQUETA "JOYSTICK" Y BOTÓN DE MODO
            // ==========================================
            Positioned(
              left: 12,
              top: 8,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166))
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDpadMode ? Icons.grid_view_rounded : Icons.gamepad_rounded,
                            color: _isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isDpadMode ? 'CRUCETA' : 'JOYSTICK',
                            style: TextStyle(
                              color: _isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botón para alternar entre Stick Analógico y Cruceta D-Pad
            Positioned(
              right: 8,
              top: 6,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDpadMode = !_isDpadMode;
                    _knobDelta = Offset.zero;
                    _isInteracting = false;
                  });
                  widget.onDirectionChanged(Offset.zero);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 6),
                    ],
                  ),
                  child: Icon(
                    _isDpadMode ? Icons.circle_outlined : Icons.control_camera_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

            // ==========================================
            // MODO 1: JOYSTICK ANALÓGICO 360° DE ALTO CONTRASTE
            // ==========================================
            if (!_isDpadMode) ...[
              // 1. Base del Joystick (Anillo exterior con Neón y flechas direccionales)
              Positioned(
                left: defaultCenter.dx - widget.radius,
                top: defaultCenter.dy - widget.radius,
                child: IgnorePointer(
                  child: Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1E293B).withValues(alpha: 0.92),
                          const Color(0xFF0F172A).withValues(alpha: 0.98),
                        ],
                      ),
                      border: Border.all(
                        color: _isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166))
                              .withValues(alpha: 0.55),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Flecha Arriba
                        Positioned(
                          top: 3,
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                            size: 22,
                          ),
                        ),
                        // Flecha Abajo
                        Positioned(
                          bottom: 3,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                            size: 22,
                          ),
                        ),
                        // Flecha Izquierda
                        Positioned(
                          left: 3,
                          child: Icon(
                            Icons.arrow_left_rounded,
                            color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                            size: 22,
                          ),
                        ),
                        // Flecha Derecha
                        Positioned(
                          right: 3,
                          child: Icon(
                            Icons.arrow_right_rounded,
                            color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                            size: 22,
                          ),
                        ),
                        // Retícula interior
                        Container(
                          width: widget.radius * 1.05,
                          height: widget.radius * 1.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Perilla móvil del Joystick (Knob luminoso con gema)
              Positioned(
                left: defaultCenter.dx + _knobDelta.dx - (widget.radius * 0.46),
                top: defaultCenter.dy + _knobDelta.dy - (widget.radius * 0.46),
                child: IgnorePointer(
                  child: Container(
                    width: widget.radius * 0.92,
                    height: widget.radius * 0.92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE169),
                          Color(0xFFFF9E00),
                          Color(0xFFE63946),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5400).withValues(alpha: 0.70),
                          blurRadius: 14,
                          spreadRadius: 2,
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
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // ==========================================
              // MODO 2: CRUCETA TÁCTICA ARCADE (D-PAD)
              // ==========================================
              Positioned(
                left: (boxWidth - 130) / 2,
                top: 44,
                child: _buildDpadControls(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDpadControls() {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centro decorativo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
          ),

          // Arriba
          Positioned(
            top: 0,
            child: _buildDpadButton(
              icon: Icons.arrow_drop_up_rounded,
              direction: const Offset(0, -1),
            ),
          ),

          // Abajo
          Positioned(
            bottom: 0,
            child: _buildDpadButton(
              icon: Icons.arrow_drop_down_rounded,
              direction: const Offset(0, 1),
            ),
          ),

          // Izquierda
          Positioned(
            left: 0,
            child: _buildDpadButton(
              icon: Icons.arrow_left_rounded,
              direction: const Offset(-1, 0),
            ),
          ),

          // Derecha
          Positioned(
            right: 0,
            child: _buildDpadButton(
              icon: Icons.arrow_right_rounded,
              direction: const Offset(1, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpadButton({required IconData icon, required Offset direction}) {
    return Listener(
      onPointerDown: (_) => _onDpadPress(direction),
      onPointerUp: (_) => _onDpadRelease(),
      onPointerCancel: (_) => _onDpadRelease(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFD166), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD166).withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
