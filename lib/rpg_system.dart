import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

// Base stats that can be upgraded
enum StatType {
  damageBonus,
  cooldownReduction,
  attackSpeedBonus,
  rangeBonus,
}

class StatUpgrade {
  final StatType type;
  final String name;
  final String description;
  final int maxLevel;
  final double valuePerLevel; // Multiplier or flat bonus

  StatUpgrade({
    required this.type,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.valuePerLevel,
  });

  double getValue(int level) => level * valuePerLevel;

  int getCost(int level) {
    // Cost formula: base * (1.5 ^ (level - 1)), rounded
    if (level <= 0) return 0;
    final baseCost = 10;
    final cost = (baseCost * math.pow(1.5, level - 1)).round();
    return cost;
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'description': description,
    'maxLevel': maxLevel,
    'valuePerLevel': valuePerLevel,
  };

  factory StatUpgrade.fromJson(Map<String, dynamic> json) => StatUpgrade(
    type: StatType.values.firstWhere((e) => e.name == json['type']),
    name: json['name'],
    description: json['description'],
    maxLevel: json['maxLevel'],
    valuePerLevel: json['valuePerLevel'],
  );
}

// Skill node in the skill tree
class SkillNode {
  final String id;
  final String name;
  final String description;
  final int maxLevel;
  final List<String> requiredNodes; // Parent nodes that must be unlocked
  final int requiredHeroLevel;
  final double damageBonus; // Per level
  final double cooldownReduction; // Per level (seconds)
  final double aoeRadiusBonus; // Per level
  final double projectileSpeedBonus; // Per level

  SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    this.requiredNodes = const [],
    this.requiredHeroLevel = 1,
    this.damageBonus = 0,
    this.cooldownReduction = 0,
    this.aoeRadiusBonus = 0,
    this.projectileSpeedBonus = 0,
  });

  int getCost(int level) {
    // Cost formula: base * (2 ^ (level - 1)), rounded
    if (level <= 0) return 0;
    final baseCost = 20;
    final cost = (baseCost * math.pow(2.0, level - 1)).round();
    return cost;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'maxLevel': maxLevel,
    'requiredNodes': requiredNodes,
    'requiredHeroLevel': requiredHeroLevel,
    'damageBonus': damageBonus,
    'cooldownReduction': cooldownReduction,
    'aoeRadiusBonus': aoeRadiusBonus,
    'projectileSpeedBonus': projectileSpeedBonus,
  };

  factory SkillNode.fromJson(Map<String, dynamic> json) => SkillNode(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    maxLevel: json['maxLevel'],
    requiredNodes: List<String>.from(json['requiredNodes'] ?? []),
    requiredHeroLevel: json['requiredHeroLevel'] ?? 1,
    damageBonus: json['damageBonus'] ?? 0,
    cooldownReduction: json['cooldownReduction'] ?? 0,
    aoeRadiusBonus: json['aoeRadiusBonus'] ?? 0,
    projectileSpeedBonus: json['projectileSpeedBonus'] ?? 0,
  );
}

// Complete skill tree for a hero
class SkillTree {
  final String heroName;
  final List<SkillNode> nodes;

  SkillTree({
    required this.heroName,
    required this.nodes,
  });

  SkillNode? getNode(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'heroName': heroName,
    'nodes': nodes.map((n) => n.toJson()).toList(),
  };

  factory SkillTree.fromJson(Map<String, dynamic> json) => SkillTree(
    heroName: json['heroName'],
    nodes: (json['nodes'] as List<dynamic>)
        .map((n) => SkillNode.fromJson(n as Map<String, dynamic>))
        .toList(),
  );
}

// RPG data for a single hero
class HeroData {
  final String name;
  int level;
  int xp;
  bool unlocked;
  Map<String, int> statsLevels; // StatType.name -> level
  Map<String, int> skillLevels; // nodeId -> level
  int totalCoinsInvested;

  HeroData({
    required this.name,
    this.level = 1,
    this.xp = 0,
    this.unlocked = true,
    Map<String, int>? statsLevels,
    Map<String, int>? skillLevels,
    this.totalCoinsInvested = 0,
  })  : statsLevels = statsLevels ?? {},
        skillLevels = skillLevels ?? {};

  // XP required for next level
  int get xpForNextLevel => 100 * level;

  // Check if can level up
  bool canLevelUp() => xp >= xpForNextLevel;

  // Level up and return XP leftover
  int levelUp() {
    if (!canLevelUp()) return xp;
    final xpUsed = xpForNextLevel;
    xp -= xpUsed;
    level++;
    return xp;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'xp': xp,
    'unlocked': unlocked,
    'statsLevels': statsLevels,
    'skillLevels': skillLevels,
    'totalCoinsInvested': totalCoinsInvested,
  };

  factory HeroData.fromJson(Map<String, dynamic> json) => HeroData(
    name: json['name'],
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    unlocked: json['unlocked'] ?? true,
    statsLevels: Map<String, int>.from(json['statsLevels'] ?? {}),
    skillLevels: Map<String, int>.from(json['skillLevels'] ?? {}),
    totalCoinsInvested: json['totalCoinsInvested'] ?? 0,
  );
}

// Global player progress
class PlayerProgress {
  int coins;
  Map<String, HeroData> heroes; // heroName -> HeroData

  PlayerProgress({
    this.coins = 0,
    Map<String, HeroData>? heroes,
  }) : heroes = heroes ?? {};

  int get totalGamesPlayed => heroes.values.fold(0, (sum, h) => sum + h.level);

  void addCoins(int amount) {
    coins += amount;
    if (coins < 0) coins = 0;
  }

  bool canSpendCoins(int amount) => coins >= amount;

  void spendCoins(int amount) {
    if (!canSpendCoins(amount)) throw Exception('Not enough coins');
    coins -= amount;
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'heroes': heroes.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
    coins: json['coins'] ?? 0,
    heroes: (json['heroes'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, HeroData.fromJson(v as Map<String, dynamic>)),
        ) ??
        {},
  );
}

// RPG System Manager - handles save/load and game integration
class RpgSystem {
  static const String _saveKey = 'player_progress';
  static PlayerProgress? _cachedProgress;

  // Get or create player progress
  static Future<PlayerProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_saveKey);

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _cachedProgress = PlayerProgress.fromJson(json);
        return _cachedProgress!;
      } catch (e) {
        print('Error loading progress: $e');
      }
    }

    // Create default progress
    _cachedProgress = PlayerProgress(
      coins: 0,
      heroes: _createDefaultHeroData(),
    );
    await saveProgress();
    return _cachedProgress!;
  }

  // Save progress to storage
  static Future<void> saveProgress() async {
    if (_cachedProgress == null) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_cachedProgress!.toJson());
    await prefs.setString(_saveKey, jsonStr);
  }

  // Reset all progress
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
    _cachedProgress = null;
  }

  // Create default hero data for all 10 heroes
  static Map<String, HeroData> _createDefaultHeroData() {
    final heroNames = [
      'Aerin', 'Veyra', 'Thalor', 'Myris', 'Kaelen',
      'Solenne', 'Ravik', 'Brann', 'Nyxra', 'Eldrin'
    ];

    final heroes = <String, HeroData>{};

    for (int i = 0; i < heroNames.length; i++) {
      final name = heroNames[i];
      // First 4 heroes are unlocked by default
      heroes[name] = HeroData(
        name: name,
        unlocked: i < 4,
      );
    }

    return heroes;
  }

  // Get hero data
  static Future<HeroData?> getHeroData(String heroName) async {
    final progress = await getProgress();
    return progress.heroes[heroName];
  }

  // Update hero data and save
  static Future<void> updateHeroData(HeroData heroData) async {
    final progress = await getProgress();
    progress.heroes[heroData.name] = heroData;
    await saveProgress();
  }

  // Unlock hero
  static Future<bool> unlockHero(String heroName, int cost) async {
    final progress = await getProgress();
    final hero = progress.heroes[heroName];

    if (hero == null || hero.unlocked) return false;
    if (!progress.canSpendCoins(cost)) return false;

    progress.spendCoins(cost);
    hero.unlocked = true;
    await saveProgress();
    return true;
  }

  // Upgrade hero stat
  static Future<bool> upgradeStat(
    String heroName,
    StatType statType,
    StatUpgrade statUpgrade,
  ) async {
    final progress = await getProgress();
    final hero = progress.heroes[heroName];

    if (hero == null) return false;

    final currentLevel = hero.statsLevels[statType.name] ?? 0;
    if (currentLevel >= statUpgrade.maxLevel) return false;

    final cost = statUpgrade.getCost(currentLevel + 1);
    if (!progress.canSpendCoins(cost)) return false;

    progress.spendCoins(cost);
    hero.statsLevels[statType.name] = currentLevel + 1;
    hero.totalCoinsInvested += cost;
    await saveProgress();
    return true;
  }

  // Upgrade skill
  static Future<bool> upgradeSkill(
    String heroName,
    String skillId,
    SkillNode skillNode,
  ) async {
    final progress = await getProgress();
    final hero = progress.heroes[heroName];

    if (hero == null) return false;
    if (hero.level < skillNode.requiredHeroLevel) return false;

    // Check required nodes
    for (final requiredId in skillNode.requiredNodes) {
      if ((hero.skillLevels[requiredId] ?? 0) < 1) return false;
    }

    final currentLevel = hero.skillLevels[skillId] ?? 0;
    if (currentLevel >= skillNode.maxLevel) return false;

    final cost = skillNode.getCost(currentLevel + 1);
    if (!progress.canSpendCoins(cost)) return false;

    progress.spendCoins(cost);
    hero.skillLevels[skillId] = currentLevel + 1;
    hero.totalCoinsInvested += cost;
    await saveProgress();
    return true;
  }

  // Reset hero (respec) - returns refunded coins
  static Future<int> resetHero(String heroName) async {
    final progress = await getProgress();
    final hero = progress.heroes[heroName];

    if (hero == null) return 0;

    // Calculate refund (50-100%)
    final refundAmount = (hero.totalCoinsInvested * 0.75).round();
    progress.coins += refundAmount;

    // Reset upgrades
    hero.statsLevels.clear();
    hero.skillLevels.clear();
    hero.totalCoinsInvested = 0;

    await saveProgress();
    return refundAmount;
  }

  // Calculate stat bonus for hero
  static Future<double> getStatBonus(String heroName, StatType statType, StatUpgrade statUpgrade) async {
    final hero = await getHeroData(heroName);
    if (hero == null) return 0;

    final level = hero.statsLevels[statType.name] ?? 0;
    return statUpgrade.getValue(level);
  }

  // Calculate total damage bonus for hero
  static Future<double> getTotalDamageBonus(String heroName, SkillTree skillTree) async {
    final hero = await getHeroData(heroName);
    if (hero == null) return 0;

    double totalBonus = 0;

    // Add skill bonuses
    for (final entry in hero.skillLevels.entries) {
      final node = skillTree.getNode(entry.key);
      if (node != null) {
        totalBonus += node.damageBonus * entry.value;
      }
    }

    return totalBonus;
  }

  // Calculate total cooldown reduction for hero
  static Future<double> getTotalCooldownReduction(String heroName, SkillTree skillTree) async {
    final hero = await getHeroData(heroName);
    if (hero == null) return 0;

    double totalReduction = 0;

    // Add skill bonuses
    for (final entry in hero.skillLevels.entries) {
      final node = skillTree.getNode(entry.key);
      if (node != null) {
        totalReduction += node.cooldownReduction * entry.value;
      }
    }

    return totalReduction;
  }

  // Add XP to hero
  static Future<bool> addHeroXp(String heroName, int xpAmount) async {
    final progress = await getProgress();
    var hero = progress.heroes[heroName];

    // Create hero if doesn't exist
    if (hero == null) {
      hero = HeroData(
        name: heroName,
        level: 1,
        xp: 0,
        unlocked: true,
      );
      progress.heroes[heroName] = hero;
      // Invalidate cache after creating new hero
      _cachedProgress = null;
    }

    hero.xp += xpAmount;

    // Auto-level up while hero has enough XP
    while (hero.canLevelUp()) {
      hero.levelUp();
    }

    await saveProgress();
    return true;
  }
}

// Math helper
double pow(num x, num exponent) => x.toDouble() * exponent.toDouble();
