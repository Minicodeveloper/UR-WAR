import 'package:flutter/material.dart';
import '../graphics/pixel_sprite_painter.dart';
import '../logic/game_engine.dart';
import '../models/player_class.dart';
import 'village_shop_dialog.dart';
import 'virtual_joystick.dart';

class GameHUD extends StatelessWidget {
  final GameEngine engine;
  final ValueChanged<Offset> onJoystickDirection;

  const GameHUD({
    super.key,
    required this.engine,
    required this.onJoystickDirection,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: engine,
      builder: (context, _) {
        final player = engine.player;
        final townHall = engine.townHall;
        final wave = engine.waveSystem;

        return Stack(
          children: [
            // ==========================================
            // BARRA SUPERIOR DE ESTADO
            // ==========================================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Retrato y vida del Héroe
                        _buildHeroStatus(player),
                        const SizedBox(width: 12),

                        // Barra del Corazón de la Aldea
                        Expanded(child: _buildVillageStatus(townHall)),
                        const SizedBox(width: 12),

                        // Info de Oleada y Recursos
                        _buildWaveAndGold(wave, player, context),
                      ],
                    ),

                    // Banner de Anuncio en pantalla si está activo
                    if (engine.announcementBanner != null) ...[
                      const SizedBox(height: 16),
                      _buildAnnouncementBanner(engine.announcementBanner!),
                    ],
                  ],
                ),
              ),
            ),

            // ==========================================
            // CONTROLES INFERIORES: JOYSTICK A LA IZQUIERDA
            // ==========================================
            Positioned(
              left: 24,
              bottom: 28,
              child: SafeArea(
                child: VirtualJoystick(
                  radius: 65,
                  onDirectionChanged: onJoystickDirection,
                ),
              ),
            ),

            // ==========================================
            // BOTONES DE ACCIÓN A LA DERECHA
            // ==========================================
            Positioned(
              right: 24,
              bottom: 24,
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Botón de Tienda de la Aldea
                    _buildShopButton(context, player),
                    const SizedBox(width: 16),

                    // Botón de Habilidad Especial
                    _buildSkillButton(player),
                    const SizedBox(width: 16),

                    // Botón de Ataque Primario
                    _buildAttackButton(player),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroStatus(dynamic player) {
    final pClass = player.playerClass as PlayerClass;
    final hpPct = (player.health / player.maxHealth).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF161A23).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pClass.themeColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: PixelSpriteWidget(
                sprite: pClass.spriteIdle,
                pixelSize: 2.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pClass.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              // Barra de vida
              SizedBox(
                width: 90,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: hpPct,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF55A630)),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${player.health.toInt()} / ${player.maxHealth.toInt()} HP',
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVillageStatus(dynamic townHall) {
    final hpPct = (townHall.health / townHall.maxHealth).clamp(0.0, 1.0);
    final isLowHp = hpPct < 0.35;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161A23).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowHp ? const Color(0xFFEF233C) : const Color(0xFF00BBF9),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fort_rounded,
                    size: 16,
                    color: isLowHp ? const Color(0xFFEF233C) : const Color(0xFF00BBF9),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'CORAZÓN DE LA ALDEA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '${townHall.health.toInt()} / ${townHall.maxHealth.toInt()}',
                style: TextStyle(
                  color: isLowHp ? const Color(0xFFEF233C) : const Color(0xFF00BBF9),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hpPct,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                isLowHp ? const Color(0xFFEF233C) : const Color(0xFF00BBF9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveAndGold(dynamic wave, dynamic player, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161A23).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚩 ', style: TextStyle(fontSize: 12)),
              Text(
                'OLEADA ${wave.currentWave}/${wave.maxWaves}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙 ', style: TextStyle(fontSize: 12)),
              Text(
                '${player.gold}',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE63946).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildShopButton(BuildContext context, dynamic player) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => VillageShopDialog(engine: engine),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2330).withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFD166), width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(
          Icons.storefront_rounded,
          color: Color(0xFFFFD166),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSkillButton(dynamic player) {
    final pClass = player.playerClass as PlayerClass;
    final cooldownRemaining = player.specialSkillTimer;
    final isReady = cooldownRemaining <= 0;
    final cooldownPct = isReady
        ? 0.0
        : (cooldownRemaining / pClass.specialSkillCooldownSeconds).clamp(0.0, 1.0);

    return InkWell(
      onTap: isReady ? engine.useSpecialSkill : null,
      borderRadius: BorderRadius.circular(35),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isReady
                    ? [const Color(0xFF7B2CBF), const Color(0xFF9D4EDD)]
                    : [Colors.grey.shade800, Colors.grey.shade900],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isReady ? const Color(0xFFE0AAFF) : Colors.white24,
                width: 2.5,
              ),
              boxShadow: isReady
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7B2CBF).withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              Icons.auto_awesome,
              color: isReady ? Colors.white : Colors.white38,
              size: 30,
            ),
          ),
          if (!isReady)
            SizedBox(
              width: 62,
              height: 62,
              child: CircularProgressIndicator(
                value: cooldownPct,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE0AAFF)),
                backgroundColor: Colors.transparent,
              ),
            ),
          if (!isReady)
            Text(
              '${cooldownRemaining.toStringAsFixed(1)}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttackButton(dynamic player) {
    final pClass = player.playerClass as PlayerClass;

    return InkWell(
      onTap: engine.attack,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pClass.themeColor,
              pClass.themeColor.withValues(alpha: 0.8),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: pClass.themeColor.withValues(alpha: 0.6),
              blurRadius: 16,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          pClass.isMelee ? Icons.colorize_rounded : Icons.gps_fixed_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
