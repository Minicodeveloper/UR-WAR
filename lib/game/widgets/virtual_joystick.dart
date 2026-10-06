import 'dart:math';
import 'package:flutter/material.dart';

/// Joystick virtual táctil de alta fidelidad para Android y Web.
/// Soporta modo Joystick Analógico Flotante en 360 grados y modo Cruceta Táctica D-Pad,
/// con respeto estricto del SafeArea y barra de navegación inferior de Android.
class VirtualJoystick extends StatefulWidget {
  final double radius;
  final ValueChanged<Offset> onDirectionChanged;
  final ValueChanged<Offset>? onTapField;

  const VirtualJoystick({
    super.key,
    this.radius = 52.0,
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

  DateTime? _pointerDownTime;
  Offset? _pointerDownPos;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPointerDown(Offset localPos, Size areaSize, Offset defaultCenter) {
    _pointerDownTime = DateTime.now();
    _pointerDownPos = localPos;

    if (_isDpadMode) return;

    // Si el usuario toca sobre o cerca de la base fija visible, bloquear el centro ahí
    final distToDefault = (localPos - defaultCenter).distance;
    if (distToDefault <= widget.radius * 1.5) {
      _touchCenter = defaultCenter;
    } else {
      // Si toca en otra parte del cuadrante táctil, crear base flotante dinámica
      final margin = widget.radius + 12.0;
      final clampedX = localPos.dx.clamp(margin, max(margin, areaSize.width - margin)).toDouble();
      final clampedY = localPos.dy.clamp(margin, max(margin, areaSize.height - margin)).toDouble();
      _touchCenter = Offset(clampedX, clampedY);
    }

    _isInteracting = true;
    _updateDirection(localPos);
  }

  void _onPointerMove(Offset localPos) {
    if (_isDpadMode || !_isInteracting) return;
    _updateDirection(localPos);
  }

  void _onPointerUp(Offset localPos) {
    if (_isDpadMode) return;

    // Detección de Tap táctil si no se arrastró el stick
    if (_pointerDownTime != null && _pointerDownPos != null) {
      final elapsed = DateTime.now().difference(_pointerDownTime!).inMilliseconds;
      final dist = (localPos - _pointerDownPos!).distance;
      if (elapsed < 260 && dist < 12.0 && widget.onTapField != null) {
        widget.onTapField!(localPos);
      }
    }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : widget.radius * 2 + 60,
          constraints.maxHeight.isFinite ? constraints.maxHeight : widget.radius * 2 + 60,
        );

        final mediaQuery = MediaQuery.of(context);
        final bottomSafe = mediaQuery.padding.bottom;
        final leftSafe = mediaQuery.padding.left;

        // Margen de seguridad estricto para evitar que la barra de navegación de Android lo oculte
        final restingMarginBottom = max(bottomSafe + 28.0, 42.0);
        final restingMarginLeft = max(leftSafe + 24.0, 32.0);

        final defaultCenter = Offset(
          widget.radius + restingMarginLeft,
          areaSize.height - widget.radius - restingMarginBottom,
        );

        final activeCenter = _touchCenter ?? defaultCenter;
        final diameter = widget.radius * 2;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _onPointerDown(e.localPosition, areaSize, defaultCenter),
          onPointerMove: (e) => _onPointerMove(e.localPosition),
          onPointerUp: (e) => _onPointerUp(e.localPosition),
          onPointerCancel: (e) => _onPointerUp(e.localPosition),
          child: SizedBox(
            width: areaSize.width,
            height: areaSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!_isDpadMode) ...[
                  // ==========================================
                  // 1. BASE DEL JOYSTICK (Anillo con brújula y Neón de Alta Visibilidad)
                  // ==========================================
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
                              const Color(0xFF1E293B).withValues(alpha: 0.90),
                              const Color(0xFF0F172A).withValues(alpha: 0.98),
                            ],
                          ),
                          border: Border.all(
                            color: _isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                            width: 3.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isInteracting ? const Color(0xFF00BBF9) : const Color(0xFFFFD166))
                                  .withValues(alpha: 0.50),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Flechas de dirección cardinal
                            Positioned(
                              top: 4,
                              child: Icon(
                                Icons.arrow_drop_up_rounded,
                                color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                                size: 22,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                                size: 22,
                              ),
                            ),
                            Positioned(
                              left: 4,
                              child: Icon(
                                Icons.arrow_left_rounded,
                                color: const Color(0xFFFFD166).withValues(alpha: 0.9),
                                size: 22,
                              ),
                            ),
                            Positioned(
                              right: 4,
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
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 2. PERILLA MÓVIL DEL JOYSTICK (Knob con brillo y gema)
                  // ==========================================
                  Positioned(
                    left: activeCenter.dx + _knobDelta.dx - (widget.radius * 0.46),
                    top: activeCenter.dy + _knobDelta.dy - (widget.radius * 0.46),
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
                              color: const Color(0xFFFF5400).withValues(alpha: 0.65),
                              blurRadius: 14,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 3. ETIQUETA INFORMATIVA VISUAL CUANDO ESTÁ EN REPOSO
                  // ==========================================
                  if (!_isInteracting)
                    Positioned(
                      left: defaultCenter.dx - 48,
                      top: defaultCenter.dy - widget.radius - 28,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD166).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.gamepad_rounded, color: Color(0xFFFFD166), size: 13),
                                    SizedBox(width: 4),
                                    Text(
                                      'JOYSTICK',
                                      style: TextStyle(
                                        color: Color(0xFFFFD166),
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
                    ),
                ] else ...[
                  // ==========================================
                  // MODO CRUCETA TÁCTICA ARCADE (D-PAD)
                  // ==========================================
                  Positioned(
                    left: defaultCenter.dx - 65,
                    top: defaultCenter.dy - 65,
                    child: _buildDpadControls(),
                  ),
                ],

                // ==========================================
                // BOTÓN DE ALTERNAR MODO (JOYSTICK / CRUCETA)
                // ==========================================
                Positioned(
                  left: defaultCenter.dx + widget.radius + 12,
                  top: defaultCenter.dy - 18,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDpadMode = !_isDpadMode;
                        _touchCenter = null;
                        _knobDelta = Offset.zero;
                        _isInteracting = false;
                      });
                      widget.onDirectionChanged(Offset.zero);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isDpadMode ? const Color(0xFF00BBF9) : const Color(0xFFFFD166),
                          width: 1.8,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: Icon(
                        _isDpadMode ? Icons.circle_outlined : Icons.control_camera_rounded,
                        color: Colors.white,
                        size: 20,
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
