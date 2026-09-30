import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'credits_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ELEMENTO DE DIAGNÓSTICO VISUAL TEMPORAL ---
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text(
          'Rama feature/diagnostico-interfaz activa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
                  _MenuButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'JUGAR',
                    isPrimary: true,
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
                    'v${AppConstants.appVersion}',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
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
  final VoidCallback onTap;
  final bool isPrimary;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 24),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPrimary ? AppTheme.primaryColor : AppTheme.surfaceColor,
            foregroundColor: Colors.white,
            elevation: isPrimary ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPrimary
                  ? BorderSide.none
                  : const BorderSide(color: Colors.white12),
            ),
          ),
        ),
      ),
    );
  }
}
