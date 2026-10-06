import 'package:flutter/material.dart';
import '../core/save_system.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SaveSystem.data.soundEnabled;
    _musicEnabled = SaveSystem.data.musicEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final saveData = SaveSystem.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AJUSTES & PERFIL'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader('ESTADÍSTICAS Y RÉCORDS'),
          Card(
            color: AppTheme.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatTile(Icons.emoji_events_rounded, 'Récord de Puntuación', '${saveData.highScore} PTS', const Color(0xFFFFD166)),
                  const Divider(color: Colors.white10),
                  _buildStatTile(Icons.shield_rounded, 'Enemigos Eliminados', '${saveData.totalKills}', const Color(0xFFEF233C)),
                  const Divider(color: Colors.white10),
                  _buildStatTile(Icons.monetization_on_rounded, 'Oro Acumulado', '${saveData.totalGoldGathered} 🪙', const Color(0xFFFFB703)),
                  const Divider(color: Colors.white10),
                  _buildStatTile(Icons.flag_rounded, 'Nivel de Campaña Unlocked', 'Nivel ${saveData.unlockedCampaignLevel}', const Color(0xFF55A630)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('AUDIO & EFECTOS'),
          SwitchListTile(
            title: const Text('Efectos de Sonido Sintéticos'),
            subtitle: const Text('Efectos retro 8-bit para combates y tiendas'),
            value: _soundEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (val) {
              setState(() => _soundEnabled = val);
              SaveSystem.setSoundEnabled(val);
            },
          ),
          SwitchListTile(
            title: const Text('Música de Fondo'),
            subtitle: const Text('Banda sonora en menú y mapa'),
            value: _musicEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (val) {
              setState(() => _musicEnabled = val);
              SaveSystem.setMusicEnabled(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
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
