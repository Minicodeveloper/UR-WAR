import 'package:flutter/material.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _difficulty = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AJUSTES'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader('AUDIO & EFECTOS'),
          SwitchListTile(
            title: const Text('Efectos de Sonido'),
            subtitle: const Text('Sonidos de disparos y explosiones'),
            value: _soundEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Música de Fondo'),
            subtitle: const Text('Banda sonora en menú y batalla'),
            value: _musicEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _musicEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Vibración / Háptico'),
            subtitle: const Text('Feedback táctil en dispositivos móviles'),
            value: _vibrationEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _vibrationEnabled = val),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('JUGABILIDAD'),
          ListTile(
            title: const Text('Nivel de Dificultad'),
            subtitle: Slider(
              value: _difficulty,
              min: 1.0,
              max: 3.0,
              divisions: 2,
              activeColor: AppTheme.primaryColor,
              label: _getDifficultyLabel(_difficulty),
              onChanged: (val) => setState(() => _difficulty = val),
            ),
            trailing: Text(
              _getDifficultyLabel(_difficulty),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(double value) {
    if (value <= 1.0) return 'Fácil';
    if (value <= 2.0) return 'Normal';
    return 'Difícil';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 14,
        ),
      ),
    );
  }
}
