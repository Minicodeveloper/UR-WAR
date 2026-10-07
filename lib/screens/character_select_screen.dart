import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../game/graphics/pixel_sprite_painter.dart';
import '../game/models/player_class.dart';
import 'map_select_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final classes = PlayerClass.availableClasses;
    final selectedClass = classes[_selectedIndex];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'SELECCIÓN DE CLASE Y HÉROE',
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return _buildLandscapeLayout(classes, selectedClass);
            } else {
              return _buildPortraitLayout(classes, selectedClass);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(List<PlayerClass> classes, PlayerClass selectedClass) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Elige el rol de tu defensor para proteger la aldea de las hordas invasoras',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),

        // Carrusel horizontal de clases
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final pClass = classes[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? pClass.themeColor.withValues(alpha: 0.25)
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? pClass.themeColor : Colors.white12,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: pClass.themeColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelSpriteWidget(
                        sprite: pClass.spriteIdle,
                        pixelSize: 2.2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pClass.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Tarjeta de detalles del Héroe
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildHeroCard(selectedClass),
          ),
        ),

        // Botón de confirmación para elegir mapa
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContinueButton(selectedClass),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(List<PlayerClass> classes, PlayerClass selectedClass) {
    return Row(
      children: [
        // Columna izquierda: Lista vertical de clases
        SizedBox(
          width: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final pClass = classes[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? pClass.themeColor.withValues(alpha: 0.25)
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? pClass.themeColor : Colors.white12,
                      width: isSelected ? 2.2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      PixelSpriteWidget(
                        sprite: pClass.spriteIdle,
                        pixelSize: 1.8,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pClass.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              pClass.roleTitle,
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Columna derecha: Detalles del Héroe + Botón de Continuar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildHeroCard(selectedClass),
                  ),
                ),
                const SizedBox(height: 10),
                _buildContinueButton(selectedClass),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(PlayerClass selectedClass) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selectedClass.themeColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vista grande animada del Pixel Sprite
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedClass.themeColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: PixelSpriteWidget(
              sprite: selectedClass.spriteIdle,
              pixelSize: 5.0,
            ),
          ),
          const SizedBox(height: 10),

          // Título y rol
          Text(
            selectedClass.name.toUpperCase(),
            style: TextStyle(
              color: selectedClass.themeColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            selectedClass.roleTitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            selectedClass.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Barras de Estadísticas
          _buildStatBar('Salud Máxima', selectedClass.maxHealth / 300, '${selectedClass.maxHealth.toInt()} HP', const Color(0xFF55A630)),
          const SizedBox(height: 8),
          _buildStatBar('Daño de Ataque', selectedClass.baseDamage / 60, '${selectedClass.baseDamage.toInt()} DMG', const Color(0xFFE63946)),
          const SizedBox(height: 8),
          _buildStatBar('Velocidad de Movimiento', selectedClass.moveSpeed / 250, '${selectedClass.moveSpeed.toInt()} SPD', const Color(0xFF00BBF9)),
          const SizedBox(height: 8),
          _buildStatBar('Alcance de Ataque', selectedClass.attackRange / 350, selectedClass.isMelee ? 'Cuerpo a Cuerpo' : 'Rango Largo', const Color(0xFFFFB703)),

          const SizedBox(height: 16),
          // Habilidad especial
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141419),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFFFD166), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Habilidad Especial: ${selectedClass.specialSkillName}',
                        style: const TextStyle(
                          color: Color(0xFFFFD166),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  selectedClass.specialSkillDescription,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(PlayerClass selectedClass) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapSelectScreen(selectedClass: selectedClass),
            ),
          );
        },
        icon: const Icon(Icons.map_rounded),
        label: const Text('CONTINUAR: ELEGIR MAPA'),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedClass.themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double value, String valueText, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(valueText, style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }
}
