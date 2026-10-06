import 'package:flutter/material.dart';
import '../logic/game_engine.dart';
import '../models/entity.dart';

class VillageShopDialog extends StatefulWidget {
  final GameEngine engine;

  const VillageShopDialog({super.key, required this.engine});

  @override
  State<VillageShopDialog> createState() => _VillageShopDialogState();
}

class _VillageShopDialogState extends State<VillageShopDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.engine,
      builder: (context, _) {
        final player = widget.engine.player;

        return Dialog(
          backgroundColor: const Color(0xFF161A23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFFD166), width: 2),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado con Nivel, Puntos y Oro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: Color(0xFFFFD166), size: 28),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nivel ${player.level} - ${player.playerClass.name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'XP: ${player.xp}/${player.xpToNextLevel} | Puntos: ${player.skillPoints}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D42),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 14)),
                            Text(
                              '${player.gold}',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barra de pestañas
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFFFD166),
                    labelColor: const Color(0xFFFFD166),
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'MEJORAS'),
                      Tab(text: 'CONSTRUIR'),
                      Tab(text: 'HABILIDADES'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Contenido de las pestañas
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Pestaña 1: Mejoras generales
                        _buildUpgradesTab(widget.engine, player),

                        // Pestaña 2: Construcción de estructuras
                        _buildConstructionTab(widget.engine, player),

                        // Pestaña 3: Árbol de Habilidades RPG
                        _buildSkillTreeTab(widget.engine, player),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2D42),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildUpgradesTab(GameEngine engine, PlayerEntity player) {
    return ListView(
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
          title: 'Forjar Acero (+25% Daño)',
          description: 'Incrementa permanentemente todo el poder bélico del héroe.',
          cost: 100,
          canAfford: player.gold >= 100,
          onBuy: () => engine.upgradeHeroDamage(100),
        ),
        _ShopItemTile(
          icon: Icons.directions_run_rounded,
          iconColor: const Color(0xFF06D6A0),
          title: 'Botas de la Tempestad (+15% Vel)',
          description: 'Aumenta permanentemente la velocidad de desplazamiento.',
          cost: 90,
          canAfford: player.gold >= 90,
          onBuy: () => engine.upgradeHeroSpeed(90),
        ),
      ],
    );
  }

  Widget _buildConstructionTab(GameEngine engine, PlayerEntity player) {
    return ListView(
      children: [
        _ShopItemTile(
          icon: Icons.fort_rounded,
          iconColor: const Color(0xFFFFD166),
          title: 'Construir Torre de Vigía',
          description: 'Dispara flechas automáticas defensivas a los invasores que se acerquen.',
          cost: 100,
          canAfford: player.gold >= 100,
          onBuy: () => engine.buildStructure(BuildingType.watchtower, 100),
        ),
        _ShopItemTile(
          icon: Icons.line_style_rounded,
          iconColor: const Color(0xFF8D5B2E),
          title: 'Construir Empalizada de Madera',
          description: 'Estructura defensiva pesada que bloquea el paso de los enemigos.',
          cost: 50,
          canAfford: player.gold >= 50,
          onBuy: () => engine.buildStructure(BuildingType.barricade, 50),
        ),
        _ShopItemTile(
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFF55A630),
          title: 'Construir Mina de Oro',
          description: 'Genera +15 de Oro automáticamente para la aldea cada 10 segundos.',
          cost: 150,
          canAfford: player.gold >= 150,
          onBuy: () => engine.buildStructure(BuildingType.goldMine, 150),
        ),
      ],
    );
  }

  Widget _buildSkillTreeTab(GameEngine engine, PlayerEntity player) {
    final skillTree = player.playerClass.skillTree;

    return ListView.builder(
      itemCount: skillTree.length,
      itemBuilder: (context, index) {
        final skill = skillTree[index];
        final isUnlocked = player.unlockedSkillIds.contains(skill.id);
        final canUnlock = player.skillPoints > 0 &&
            player.level >= skill.requiredLevel &&
            !isUnlocked;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFF2D6A4F).withValues(alpha: 0.3)
                : const Color(0xFF1E2330),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked ? const Color(0xFF55A630) : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Icon(skill.icon, color: isUnlocked ? const Color(0xFFFFD166) : Colors.white38, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          skill.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (skill.isUltimate)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B2CBF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ULTIMATE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      skill.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    Text(
                      'Nivel requerido: ${skill.requiredLevel}',
                      style: TextStyle(
                        color: player.level >= skill.requiredLevel ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: canUnlock ? () => engine.unlockSkill(skill.id) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isUnlocked ? 'DESBLOQUEADA' : 'DESBLOQUEAR',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
      margin: const EdgeInsets.only(bottom: 10),
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
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white30,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 11)),
                Text(
                  '$cost',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
