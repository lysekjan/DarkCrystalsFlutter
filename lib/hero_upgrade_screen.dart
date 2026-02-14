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
                final canLevelUp = heroData.canLevelUp();

                return Stack(
                  children: [
                    SingleChildScrollView(
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
                    ),
                    // Level up floating button
                    if (canLevelUp)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6FE2C1), Color(0xFF4DB6AC)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6FE2C1).withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await RpgSystem.addHeroXp(widget.heroName, 0);
                                await _refreshData();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'LEVEL UP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
    final xpProgress = heroData.xp / heroData.xpForNextLevel;
    final canLevelUp = heroData.canLevelUp();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            heroColor.withOpacity(0.15),
            heroColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: heroColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hero level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: heroColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: heroColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: const Color(0xFFFFD54F), size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LEVEL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${heroData.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XP Progress',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // XP Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canLevelUp ? const Color(0xFF6FE2C1) : heroColor,
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${heroData.xp} XP',
                          style: const TextStyle(
                            color: Color(0xFF6FE2C1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '/ ${heroData.xpForNextLevel} XP',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: heroColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: heroColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vlastnosti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: heroColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_awesome, color: heroColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Strom dovedností',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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

  IconData get _statIcon {
    switch (statUpgrade.type) {
      case StatType.damageBonus:
        return Icons.local_fire_department;
      case StatType.cooldownReduction:
        return Icons.speed;
      case StatType.attackSpeedBonus:
        return Icons.flash_on;
      case StatType.rangeBonus:
        return Icons.radio_button_checked;
    }
  }

  Color get _statIconColor {
    switch (statUpgrade.type) {
      case StatType.damageBonus:
        return const Color(0xFFE57373);
      case StatType.cooldownReduction:
        return const Color(0xFF64B5F6);
      case StatType.attackSpeedBonus:
        return const Color(0xFFFFD54F);
      case StatType.rangeBonus:
        return const Color(0xFF4DB6AC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C29),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMaxed ? const Color(0xFF6FE2C1).withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Stat icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statIconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_statIcon, color: _statIconColor, size: 24),
          ),
          const SizedBox(width: 12),
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
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentLevel / maxLevel,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isMaxed ? const Color(0xFF6FE2C1) : _statIconColor,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv. $currentLevel / $maxLevel',
                  style: const TextStyle(
                    color: Color(0xFF6FE2C1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Upgrade button
          if (isMaxed)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6FE2C1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Color(0xFF6FE2C1), size: 24),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: canAfford ? const Color(0xFF6FE2C1) : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(8),
                boxShadow: canAfford
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6FE2C1).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canAfford ? onUpgrade : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                        Text(
                          '$cost',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  IconData get _skillIcon {
    // Determine icon based on skill name keywords
    final name = node.name.toLowerCase();
    if (name.contains('fire') || name.contains('inferno') || name.contains('burn') || name.contains('ignite')) {
      return Icons.local_fire_department;
    } else if (name.contains('lightning') || name.contains('storm') || name.contains('shock')) {
      return Icons.flash_on;
    } else if (name.contains('ice') || name.contains('freeze') || name.contains('frost')) {
      return Icons.ac_unit;
    } else if (name.contains('explosion') || name.contains('blast') || name.contains('nova')) {
      return Icons.burst_mode;
    } else if (name.contains('beam') || name.contains('ray') || name.contains('laser')) {
      return Icons.horizontal_rule;
    } else if (name.contains('shield') || name.contains('barrier') || name.contains('protect')) {
      return Icons.shield;
    } else if (name.contains('heal') || name.contains('restore') || name.contains('regen')) {
      return Icons.favorite;
    } else if (name.contains('speed') || name.contains('swift') || name.contains('haste')) {
      return Icons.speed;
    } else if (name.contains('range') || name.contains('reach') || name.contains('distance')) {
      return Icons.radio_button_checked;
    } else if (name.contains('damage') || name.contains('power') || name.contains('strength')) {
      return Icons.gps_fixed;
    } else if (name.contains('mastery') || name.contains('mastery')) {
      return Icons.star;
    }
    return Icons.auto_awesome;
  }

  Color get _skillIconColor {
    final name = node.name.toLowerCase();
    if (name.contains('fire') || name.contains('inferno') || name.contains('burn') || name.contains('ignite')) {
      return const Color(0xFFE57373);
    } else if (name.contains('lightning') || name.contains('storm') || name.contains('shock')) {
      return const Color(0xFF64B5F6);
    } else if (name.contains('ice') || name.contains('freeze') || name.contains('frost')) {
      return const Color(0xFF4DB6AC);
    } else if (name.contains('explosion') || name.contains('blast') || name.contains('nova')) {
      return const Color(0xFFFF8A65);
    } else if (name.contains('beam') || name.contains('ray') || name.contains('laser')) {
      return const Color(0xFFBA68C8);
    } else if (name.contains('shield') || name.contains('barrier') || name.contains('protect')) {
      return const Color(0xFF81C784);
    } else if (name.contains('heal') || name.contains('restore') || name.contains('regen')) {
      return const Color(0xFFE57373);
    }
    return const Color(0xFFFFD54F);
  }

  @override
  Widget build(BuildContext context) {
    final hasProgress = currentLevel > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canUnlock ? const Color(0xFF1F2C29) : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canUnlock
              ? (hasProgress ? const Color(0xFF6FE2C1).withOpacity(0.5) : Colors.grey.shade700)
              : Colors.grey.shade700,
          width: hasProgress ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Skill icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: canUnlock
                  ? _skillIconColor.withOpacity(hasProgress ? 0.25 : 0.1)
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _skillIcon,
              color: canUnlock ? _skillIconColor : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Skill info
          Expanded(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Level ${node.requiredHeroLevel}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: currentLevel / maxLevel,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMaxed ? const Color(0xFF6FE2C1) : _skillIconColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lv. $currentLevel / $maxLevel',
                        style: const TextStyle(
                          color: Color(0xFF6FE2C1),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Upgrade button
          if (isMaxed)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6FE2C1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Color(0xFF6FE2C1), size: 24),
            )
          else if (canUnlock)
            Container(
              decoration: BoxDecoration(
                color: canAfford ? const Color(0xFF6FE2C1) : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(8),
                boxShadow: canAfford
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6FE2C1).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canAfford ? onUpgrade : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.white, size: 14),
                        Text(
                          '$cost',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
