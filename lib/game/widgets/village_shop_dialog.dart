import 'package:flutter/material.dart';
import '../logic/game_engine.dart';

class VillageShopDialog extends StatelessWidget {
  final GameEngine engine;

  const VillageShopDialog({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: engine,
      builder: (context, _) {
        final player = engine.player;

        return Dialog(
          backgroundColor: const Color(0xFF161A23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFD166), width: 2),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.storefront_rounded, color: Color(0xFFFFD166), size: 30),
                          SizedBox(width: 10),
                          Text(
                            'HERRERÍA & ALDEA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D42),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 16)),
                            Text(
                              '${player.gold}',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),

                  // Lista de artículos
                  Expanded(
                    child: ListView(
                      children: [
                        _ShopItemTile(
                          icon: Icons.shield_rounded,
                          iconColor: const Color(0xFF00BBF9),
                          title: 'Reparar Gran Salón de la Aldea',
                          description: 'Restaura +300 HP a la estructura central y +150 HP a torres.',
                          cost: 75,
                          canAfford: player.gold >= 75,
                          onBuy: () => engine.repairVillage(75, 300),
                        ),
                        _ShopItemTile(
                          icon: Icons.favorite_rounded,
                          iconColor: const Color(0xFFEF233C),
                          title: 'Poción Mayor de Vitalidad',
                          description: 'Restaura el 60% de los puntos de salud de tu héroe.',
                          cost: 50,
                          canAfford: player.gold >= 50 && player.health < player.maxHealth,
                          onBuy: () => engine.healHero(50),
                        ),
                        _ShopItemTile(
                          icon: Icons.colorize_rounded,
                          iconColor: const Color(0xFFFF9F1C),
                          title: 'Mejora de Daño de Ataque (+25%)',
                          description: 'Incrementa de forma permanente todo el poder bélico del héroe.',
                          cost: 100,
                          canAfford: player.gold >= 100,
                          onBuy: () => engine.upgradeHeroDamage(100),
                        ),
                        _ShopItemTile(
                          icon: Icons.directions_run_rounded,
                          iconColor: const Color(0xFF06D6A0),
                          title: 'Botas de la Tempestad (+15%)',
                          description: 'Aumenta permanentemente la velocidad de desplazamiento.',
                          cost: 90,
                          canAfford: player.gold >= 90,
                          onBuy: () => engine.upgradeHeroSpeed(90),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2D42),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('VOLVER A LA BATALLA'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int cost;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItemTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.cost,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2330),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canAfford ? Colors.white12 : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white30,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 12)),
                Text(
                  '$cost',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
