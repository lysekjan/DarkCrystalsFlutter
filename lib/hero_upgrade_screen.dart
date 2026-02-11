import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rpg_system.dart';
import 'skill_trees.dart';
import 'main.dart' show HeroDef, HeroSelectScreen;

class HeroUpgradeScreen extends StatefulWidget {
  const HeroUpgradeScreen({super.key});

  @override
  State<HeroUpgradeScreen> createState() => _HeroUpgradeScreenState();
}

class _HeroUpgradeScreenState extends State<HeroUpgradeScreen> {
  late Future<PlayerProgress> _progressFuture;
  int _totalCoins = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _progressFuture = _loadProgress();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<PlayerProgress> _loadProgress() async {
    final progress = await RpgSystem.getProgress();
    if (mounted) {
      setState(() {
        _totalCoins = progress.coins;
      });
    }
    return progress;
  }

  Future<void> _unlockHero(String heroName, int cost) async {
    final success = await RpgSystem.unlockHero(heroName, cost);
    if (!mounted) return;

    if (success) {
      final progress = await RpgSystem.getProgress();
      setState(() {
        _totalCoins = progress.coins;
      });
      _refreshProgress();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nedostatek mincí')),
      );
    }
  }

  Future<void> _refreshProgress() async {
    final progress = await RpgSystem.getProgress();
    if (mounted) {
      setState(() {
        _totalCoins = progress.coins;
      });
    }
  }

  void _openHeroDetail(String heroName, Color color) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HeroDetailScreen(heroName: heroName, heroColor: color),
      ),
    ).then((_) => _refreshProgress());
  }

  int getUnlockCost(int index) {
    // Heroes 0-3 are free (Aerin, Veyra, Thalor, Myris)
    // Others cost: 50, 100, 200, 400, 800, 1000
    if (index < 4) return 0;
    final costs = [0, 0, 0, 0, 50, 100, 200, 400, 800, 1000];
    return costs[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<PlayerProgress>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snapshot.data!;
          final heroDefs = _getAllHeroDefs();

          return Column(
            children: [
              // Header with coins and back button
              _buildHeader(progress),

              // Hero grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: heroDefs.length,
                  itemBuilder: (context, index) {
                    final hero = heroDefs[index];
                    final heroData = progress.heroes[hero.name];
                    final unlockCost = getUnlockCost(index);
                    final isUnlocked = heroData?.unlocked ?? false;

                    return _HeroCard(
                      hero: hero,
                      heroData: heroData,
                      isUnlocked: isUnlocked,
                      unlockCost: unlockCost,
                      currentCoins: _totalCoins,
                      onTap: isUnlocked
                          ? () => _openHeroDetail(hero.name, hero.color)
                          : () => _unlockHero(hero.name, unlockCost),
                    );
                  },
                ),
              ),

              // Bottom navigation
              _buildBottomNav(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(PlayerProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2C29), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Text(
            'Hrdinové',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6FE2C1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFF0B4A38), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_totalCoins',
                  style: const TextStyle(
                    color: Color(0xFF0B4A38),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(
          top: BorderSide(color: Color(0xFF1F2C29), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HeroSelectScreen()),
              );
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('Hrát'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FE2C1),
              foregroundColor: const Color(0xFF0B4A38),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<HeroDef> _getAllHeroDefs() {
    return [
      HeroDef('Aerin', Color(0xFFE57373), imageAsset: 'assets/heroes/hero_aerin.png'),
      HeroDef('Veyra', Color(0xFFBA68C8), imageAsset: 'assets/heroes/hero_veyra.png'),
      HeroDef('Thalor', Color(0xFF64B5F6), imageAsset: 'assets/heroes/hero_thalor.png'),
      HeroDef('Myris', Color(0xFF4DB6AC), imageAsset: 'assets/heroes/hero_myris.png'),
      HeroDef('Kaelen', Color(0xFF81C784), imageAsset: 'assets/heroes/hero_kaelen.png'),
      HeroDef('Solenne', Color(0xFFFFD54F), imageAsset: 'assets/heroes/hero_solenne.png'),
      HeroDef('Ravik', Color(0xFFFF8A65), imageAsset: 'assets/heroes/hero_ravik.png'),
      HeroDef('Brann', Color(0xFFA1887F), imageAsset: 'assets/heroes/hero_brann.png'),
      HeroDef('Nyxra', Color(0xFF90A4AE), imageAsset: 'assets/heroes/hero_nyxra.png'),
      HeroDef('Eldrin', Color(0xFF9575CD), imageAsset: 'assets/heroes/hero_eldrin.png'),
    ];
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hero,
    required this.heroData,
    required this.isUnlocked,
    required this.unlockCost,
    required this.currentCoins,
    required this.onTap,
  });

  final HeroDef hero;
  final HeroData? heroData;
  final bool isUnlocked;
  final int unlockCost;
  final int currentCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canAfford = currentCoins >= unlockCost;

    return GestureDetector(
      onTap: isUnlocked || canAfford ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? hero.color.withOpacity(0.85)
              : (canAfford ? Colors.grey.shade700 : Colors.grey.shade900),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: hero.imageAsset.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          hero.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              isUnlocked ? Icons.person : Icons.lock,
                              color: Colors.white54,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : Icon(
                        isUnlocked ? Icons.person : Icons.lock,
                        color: Colors.white54,
                        size: 40,
                      ),
              ),
            ),

            // Hero name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                hero.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Level or unlock cost
            if (isUnlocked)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Color(0xFFFFD54F), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Lv.${heroData?.level ?? 1}',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFF6FE2C1), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$unlockCost',
                    style: TextStyle(
                      color: canAfford ? const Color(0xFF6FE2C1) : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class HeroDetailScreen extends StatefulWidget {
  const HeroDetailScreen({
    super.key,
    required this.heroName,
    required this.heroColor,
  });

  final String heroName;
  final Color heroColor;

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  late Future<HeroData?> _heroDataFuture;
  late Future<PlayerProgress> _progressFuture;
  int _totalCoins = 0;
  late SkillTree _skillTree;

  // Getters for widget properties
  String get heroName => widget.heroName;
  Color get heroColor => widget.heroColor;

  @override
  void initState() {
    super.initState();
    _skillTree = SkillTrees.getTree(widget.heroName);
    _loadHeroData();
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen
    _loadHeroData();
    _loadProgress();
  }

  void _loadHeroData() async {
    final heroData = await RpgSystem.getHeroData(widget.heroName);
    if (mounted) {
      setState(() {
        _heroDataFuture = Future.value(heroData);
      });
    }
  }

  void _loadProgress() async {
    final progress = await RpgSystem.getProgress();
    if (mounted) {
      setState(() {
        _totalCoins = progress.coins;
        _progressFuture = Future.value(progress);
      });
    }
  }

  Future<void> _refreshData() async {
    final progress = await RpgSystem.getProgress();
    final heroData = await RpgSystem.getHeroData(widget.heroName);

    if (mounted) {
      setState(() {
        _totalCoins = progress.coins;
        _heroDataFuture = Future.value(heroData);
      });
    }
  }

  Future<void> _upgradeStat(StatType statType, StatUpgrade statUpgrade) async {
    final success = await RpgSystem.upgradeStat(widget.heroName, statType, statUpgrade);
    if (!mounted) return;

    if (success) {
      await _refreshData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nepodařilo se vylepšit')),
      );
    }
  }

  Future<void> _resetHero() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetovat hrdinu?'),
        content: const Text('Vrátíš 75% investovaných mincí.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetovat'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final refund = await RpgSystem.resetHero(widget.heroName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vráceno $refund mincí')),
        );
        await _refreshData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: FutureBuilder<HeroData?>(
              future: _heroDataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final heroData = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero info
                      _buildHeroInfo(heroData),

                      const SizedBox(height: 24),

                      // Stats section
                      _buildStatsSection(heroData),

                      const SizedBox(height: 24),

                      // Skill tree section
                      _buildSkillTreeSection(heroData),

                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2C29), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.heroName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6FE2C1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFF0B4A38), size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_totalCoins',
                  style: const TextStyle(
                    color: Color(0xFF0B4A38),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _resetHero,
            child: const Text('Resetovat'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroInfo(HeroData heroData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: heroColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: heroColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: const Color(0xFFFFD54F), size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${heroData.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${heroData.xp} / ${heroData.xpForNextLevel} XP',
                    style: const TextStyle(
                      color: Color(0xFF6FE2C1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (heroData.canLevelUp())
                ElevatedButton(
                  onPressed: () async {
                    await RpgSystem.addHeroXp(widget.heroName, 0); // Trigger level up check
                    await _refreshData();
                  },
                  child: const Text('Level Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FE2C1),
                    foregroundColor: const Color(0xFF0B4A38),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Potřebuje více XP',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HeroData heroData) {
    final statUpgrades = SkillTrees.getStatUpgrades();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101816),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2C29)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vlastnosti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...statUpgrades.map((statUpgrade) {
            final currentLevel = heroData.statsLevels[statUpgrade.type.name] ?? 0;
            final maxLevel = statUpgrade.maxLevel;
            final isMaxed = currentLevel >= maxLevel;
            final cost = statUpgrade.getCost(currentLevel + 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StatCard(
                statUpgrade: statUpgrade,
                currentLevel: currentLevel,
                maxLevel: maxLevel,
                isMaxed: isMaxed,
                cost: cost,
                canAfford: _totalCoins >= cost,
                onUpgrade: () => _upgradeStat(statUpgrade.type, statUpgrade),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSkillTreeSection(HeroData heroData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101816),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2C29)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Strom dovedností',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Simple skill tree visualization
          ..._skillTree.nodes.map((node) {
            final currentLevel = heroData.skillLevels[node.id] ?? 0;
            final maxLevel = node.maxLevel;
            final isMaxed = currentLevel >= maxLevel;
            final cost = node.getCost(currentLevel + 1);
            final canUnlock = heroData.level >= node.requiredHeroLevel;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SkillNodeCard(
                node: node,
                currentLevel: currentLevel,
                maxLevel: maxLevel,
                isMaxed: isMaxed,
                cost: cost,
                canAfford: _totalCoins >= cost,
                canUnlock: canUnlock,
                onUpgrade: () async {
                  final success = await RpgSystem.upgradeSkill(widget.heroName, node.id, node);
                  if (success && mounted) {
                    await _refreshData();
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.statUpgrade,
    required this.currentLevel,
    required this.maxLevel,
    required this.isMaxed,
    required this.cost,
    required this.canAfford,
    required this.onUpgrade,
  });

  final StatUpgrade statUpgrade;
  final int currentLevel;
  final int maxLevel;
  final bool isMaxed;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C29),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Stat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statUpgrade.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statUpgrade.description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lv. $currentLevel / $maxLevel',
                  style: const TextStyle(
                    color: Color(0xFF6FE2C1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Upgrade button
          if (isMaxed)
            const Icon(Icons.check_circle, color: Color(0xFF6FE2C1), size: 32)
          else
            ElevatedButton(
              onPressed: canAfford ? onUpgrade : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    '$cost',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? const Color(0xFF6FE2C1) : Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(60, 56),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillNodeCard extends StatelessWidget {
  const _SkillNodeCard({
    required this.node,
    required this.currentLevel,
    required this.maxLevel,
    required this.isMaxed,
    required this.cost,
    required this.canAfford,
    required this.canUnlock,
    required this.onUpgrade,
  });

  final SkillNode node;
  final int currentLevel;
  final int maxLevel;
  final bool isMaxed;
  final int cost;
  final bool canAfford;
  final bool canUnlock;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canUnlock ? const Color(0xFF1F2C29) : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canUnlock ? const Color(0xFF1F2C29) : Colors.grey.shade700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.name,
            style: TextStyle(
              color: canUnlock ? Colors.white : Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            node.description,
            style: TextStyle(
              color: canUnlock ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          if (!canUnlock)
            Text(
              'Vyžaduje Level ${node.requiredHeroLevel}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            )
          else
            Row(
              children: [
                Text(
                  'Lv. $currentLevel / $maxLevel',
                  style: const TextStyle(
                    color: Color(0xFF6FE2C1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isMaxed)
                  const Icon(Icons.check_circle, color: Color(0xFF6FE2C1), size: 24)
                else
                  ElevatedButton(
                    onPressed: canAfford ? onUpgrade : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.white, size: 14),
                        const SizedBox(height: 2),
                        Text(
                          '$cost',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? const Color(0xFF6FE2C1) : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(50, 44),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
