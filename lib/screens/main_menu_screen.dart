import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'character_select_screen.dart';
import 'credits_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'tetris_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryColor,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Multiplatform Open Source Game',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Botón principal: JUGAR (Defensa de la Aldea y Roles de Héroes)
                  _MenuButton(
                    icon: Icons.shield_rounded,
                    label: 'JUGAR',
                    subtitle: 'Defensa de la Aldea (Mapa Gigante & Joystick)',
                    isPrimary: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterSelectScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón secundario: ARENA TÁCTICA
                  _MenuButton(
                    icon: Icons.grid_view_rounded,
                    label: 'ARENA TÁCTICA',
                    subtitle: 'Tablero Táctico 8x8 por Turnos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                                    const SizedBox(height: 16),

                  // Tetris con poderes
                  _MenuButton(
                    icon: Icons.apps_rounded,
                    label: 'TETRIS CON PODERES',
                    subtitle: '20 niveles de velocidad & 4 poderes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TetrisScreen(),
                        ),
                      );
                    },
                  ),

                  // Ajustes
                  _MenuButton(
                    icon: Icons.settings_rounded,
                    label: 'AJUSTES',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Créditos
                  _MenuButton(
                    icon: Icons.group_rounded,
                    label: 'CRÉDITOS & OPEN SOURCE',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreditsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'v${AppConstants.appVersion} • Controles Táctiles & Joystick Activos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MenuButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: SizedBox(
        width: double.infinity,
        height: subtitle != null ? 64 : 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPrimary ? AppTheme.primaryColor : AppTheme.surfaceColor,
            foregroundColor: Colors.white,
            elevation: isPrimary ? 8 : 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPrimary
                  ? BorderSide.none
                  : const BorderSide(color: Colors.white12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isPrimary ? Colors.white.withValues(alpha: 0.85) : Colors.white60,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
