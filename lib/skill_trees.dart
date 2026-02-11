import 'rpg_system.dart';

// All skill tree definitions for heroes
class SkillTrees {
  // Get skill tree for a hero
  static SkillTree getTree(String heroName) {
    switch (heroName) {
      case 'Aerin':
        return _aerinTree();
      case 'Veyra':
        return _veyraTree();
      case 'Thalor':
        return _thalorTree();
      case 'Myris':
        return _myrisTree();
      case 'Kaelen':
        return _kaelenTree();
      case 'Solenne':
        return _solenneTree();
      case 'Ravik':
        return _ravikTree();
      case 'Brann':
        return _brannTree();
      case 'Nyxra':
        return _nyxraTree();
      case 'Eldrin':
        return _eldrinTree();
      default:
        return SkillTree(heroName: heroName, nodes: []);
    }
  }

  // Stat upgrades for all heroes (same for all)
  static List<StatUpgrade> getStatUpgrades() => [
    StatUpgrade(
      type: StatType.damageBonus,
      name: 'Damage',
      description: '+10% damage per level',
      maxLevel: 10,
      valuePerLevel: 0.1,
    ),
    StatUpgrade(
      type: StatType.cooldownReduction,
      name: 'Cooldown',
      description: '-5% cooldown per level',
      maxLevel: 10,
      valuePerLevel: 0.05,
    ),
    StatUpgrade(
      type: StatType.attackSpeedBonus,
      name: 'Attack Speed',
      description: '+5% attack speed per level',
      maxLevel: 10,
      valuePerLevel: 0.05,
    ),
    StatUpgrade(
      type: StatType.rangeBonus,
      name: 'Range',
      description: '+10% range per level',
      maxLevel: 10,
      valuePerLevel: 0.1,
    ),
  ];

  // === AERIN SKILL TREE ===
  // Aerin: Fireball specialist with fast/strong modes
  static SkillTree _aerinTree() => SkillTree(
    heroName: 'Aerin',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'aerin_fireball_mastery',
        name: 'Fireball Mastery',
        description: '+20% fireball damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 2,
      ),
      SkillNode(
        id: 'aerin_ignition',
        name: 'Ignition',
        description: '+15% fireball size',
        maxLevel: 5,
        requiredHeroLevel: 1,
        projectileSpeedBonus: 16,
      ),

      // TIER 2 (requires Fireball Mastery)
      SkillNode(
        id: 'aerin_inferno',
        name: 'Inferno',
        description: '+30% explosion radius, +5 damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['aerin_fireball_mastery'],
        aoeRadiusBonus: 15,
        damageBonus: 0.5,
      ),
      SkillNode(
        id: 'aerin_molten_core',
        name: 'Molten Core',
        description: 'Fireballs leave burning trail',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['aerin_fireball_mastery'],
        damageBonus: 1,
      ),

      // TIER 2 (requires Ignition)
      SkillNode(
        id: 'aerin_heat_wave',
        name: 'Heat Wave',
        description: '-10% cooldown',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['aerin_ignition'],
        cooldownReduction: 0.5,
      ),
      SkillNode(
        id: 'aerin_flash_fire',
        name: 'Flash Fire',
        description: '+20% projectile speed',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['aerin_ignition'],
        projectileSpeedBonus: 32,
      ),

      // TIER 3 (Ultimates - require Tier 2)
      SkillNode(
        id: 'aerin_phoenix',
        name: 'Phoenix Strike',
        description: '+100% damage, +50% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['aerin_inferno', 'aerin_molten_core'],
        damageBonus: 10,
        aoeRadiusBonus: 50,
      ),
      SkillNode(
        id: 'aerin_supernova',
        name: 'Supernova',
        description: '-50% cooldown, +30% speed',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['aerin_heat_wave', 'aerin_flash_fire'],
        cooldownReduction: 2.5,
        projectileSpeedBonus: 80,
      ),
    ],
  );

  // === VEYRA SKILL TREE ===
  // Veyra: Rapid/Explosive/Lightning modes
  static SkillTree _veyraTree() => SkillTree(
    heroName: 'Veyra',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'veyra_quick_draw',
        name: 'Quick Draw',
        description: '-20% sending time',
        maxLevel: 5,
        requiredHeroLevel: 1,
        cooldownReduction: 0.2,
      ),
      SkillNode(
        id: 'veyra_crit_strike',
        name: 'Crit Strike',
        description: '+15% damage chance for 2x',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.75,
      ),

      // TIER 2
      SkillNode(
        id: 'veyra_chain_reaction',
        name: 'Chain Reaction',
        description: 'Explosions chain to nearby enemies',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['veyra_quick_draw'],
        aoeRadiusBonus: 20,
        damageBonus: 2,
      ),
      SkillNode(
        id: 'veyra_overdrive',
        name: 'Overdrive',
        description: '+50% rapid fire damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['veyra_quick_draw'],
        damageBonus: 0.5,
      ),
      SkillNode(
        id: 'veyra_surge',
        name: 'Surge',
        description: 'Lightning hits 2 targets',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['veyra_crit_strike'],
        damageBonus: 5,
      ),
      SkillNode(
        id: 'veyra_precision',
        name: 'Precision',
        description: '+30% damage, +10% range',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['veyra_crit_strike'],
        damageBonus: 1,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'veyra_storm',
        name: 'Storm',
        description: 'Lightning hits 5 targets, +50% damage',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['veyra_chain_reaction', 'veyra_overdrive'],
        damageBonus: 15,
      ),
      SkillNode(
        id: 'veyra_annihilation',
        name: 'Annihilation',
        description: '+200% explosive damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['veyra_surge', 'veyra_precision'],
        damageBonus: 6,
        aoeRadiusBonus: 60,
      ),
    ],
  );

  // === THALOR SKILL TREE ===
  // Thalor: Projectile/Sword/Energy modes
  static SkillTree _thalorTree() => SkillTree(
    heroName: 'Thalor',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'thalor_blade_mastery',
        name: 'Blade Mastery',
        description: '+25% sword damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.25,
      ),
      SkillNode(
        id: 'thalor_archery',
        name: 'Archery',
        description: '+30% projectile damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.5,
      ),

      // TIER 2
      SkillNode(
        id: 'thalor_whirlwind',
        name: 'Whirlwind',
        description: '+50% sword AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['thalor_blade_mastery'],
        aoeRadiusBonus: 35,
      ),
      SkillNode(
        id: 'thalor_blazing_blade',
        name: 'Blazing Blade',
        description: 'Sword deals bonus damage over time',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['thalor_blade_mastery'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'thalor_multishot',
        name: 'Multishot',
        description: '+30% projectile speed, +15% damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['thalor_archery'],
        projectileSpeedBonus: 48,
        damageBonus: 0.75,
      ),
      SkillNode(
        id: 'thalor_piercing',
        name: 'Piercing',
        description: 'Projectiles pierce enemies',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['thalor_archery'],
        damageBonus: 2,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'thalor_blade_dance',
        name: 'Blade Dance',
        description: '+100% sword damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['thalor_whirlwind', 'thalor_blazing_blade'],
        damageBonus: 5,
        aoeRadiusBonus: 70,
      ),
      SkillNode(
        id: 'thalor_arrow_rain',
        name: 'Arrow Rain',
        description: 'Projectiles split into 3',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['thalor_multishot', 'thalor_piercing'],
        damageBonus: 4,
        projectileSpeedBonus: 100,
      ),
    ],
  );

  // === MYRIS SKILL TREE ===
  // Myris: Ice/Freeze modes
  static SkillTree _myrisTree() => SkillTree(
    heroName: 'Myris',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'myris_frost_fortress',
        name: 'Frost Fortress',
        description: '+30% ice damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.2,
      ),
      SkillNode(
        id: 'myris_cold_snap',
        name: 'Cold Snap',
        description: 'Ice slows enemies',
        maxLevel: 3,
        requiredHeroLevel: 1,
        damageBonus: 1,
      ),

      // TIER 2
      SkillNode(
        id: 'myris_glacier',
        name: 'Glacier',
        description: '+50% freeze AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['myris_frost_fortress'],
        aoeRadiusBonus: 50,
      ),
      SkillNode(
        id: 'myris_permafrost',
        name: 'Permafrost',
        description: 'Freeze deals double damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['myris_frost_fortress'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'myris_ice_lance',
        name: 'Ice Lance',
        description: '+40% projectile damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['myris_cold_snap'],
        damageBonus: 1.6,
      ),
      SkillNode(
        id: 'myris_shatter',
        name: 'Shatter',
        description: 'Ice projectile shatters on impact',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['myris_cold_snap'],
        damageBonus: 2,
        aoeRadiusBonus: 25,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'myris_avalanche',
        name: 'Avalanche',
        description: '+100% freeze damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['myris_glacier', 'myris_permafrost'],
        damageBonus: 8,
        aoeRadiusBonus: 100,
      ),
      SkillNode(
        id: 'myris_absolute_zero',
        name: 'Absolute Zero',
        description: 'Freeze permanently slows',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['myris_ice_lance', 'myris_shatter'],
        damageBonus: 4,
        aoeRadiusBonus: 50,
      ),
    ],
  );

  // === KAELEN SKILL TREE ===
  // Kaelen: Nature/Vine/Spore modes
  static SkillTree _kaelenTree() => SkillTree(
    heroName: 'Kaelen',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'kaelen_natures_wrath',
        name: 'Nature\'s Wrath',
        description: '+25% vine damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.5,
      ),
      SkillNode(
        id: 'kaelen_spore_cloud',
        name: 'Spore Cloud',
        description: '+30% spore damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.6,
      ),

      // TIER 2
      SkillNode(
        id: 'kaelen_entangling_roots',
        name: 'Entangling Roots',
        description: 'Vine slows enemies',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['kaelen_natures_wrath'],
        aoeRadiusBonus: 20,
      ),
      SkillNode(
        id: 'kaelen_overgrowth',
        name: 'Overgrowth',
        description: '+50% vine AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['kaelen_natures_wrath'],
        aoeRadiusBonus: 50,
      ),
      SkillNode(
        id: 'kaelen_toxic_spores',
        name: 'Toxic Spores',
        description: 'Spores deal damage over time',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['kaelen_spore_cloud'],
        damageBonus: 1,
      ),
      SkillNode(
        id: 'kaelen_spread',
        name: 'Spread',
        description: '+50% spore AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['kaelen_spore_cloud'],
        aoeRadiusBonus: 35,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'kaelen_world_tree',
        name: 'World Tree',
        description: '+100% vine damage, +150% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['kaelen_entangling_roots', 'kaelen_overgrowth'],
        damageBonus: 6,
        aoeRadiusBonus: 75,
      ),
      SkillNode(
        id: 'kaelen_fungal_bloom',
        name: 'Fungal Bloom',
        description: '+100% spore damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['kaelen_toxic_spores', 'kaelen_spread'],
        damageBonus: 2,
        aoeRadiusBonus: 70,
      ),
    ],
  );

  // === SOLENNE SKILL TREE ===
  // Solenne: Beam/Sunburst/Radiant modes
  static SkillTree _solenneTree() => SkillTree(
    heroName: 'Solenne',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'solenne_radiant_beam',
        name: 'Radiant Beam',
        description: '+25% beam DPS',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.5,
      ),
      SkillNode(
        id: 'solenne_solar_flare',
        name: 'Solar Flare',
        description: '+30% sunburst damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 3.6,
      ),

      // TIER 2
      SkillNode(
        id: 'solenne_piercing_light',
        name: 'Piercing Light',
        description: 'Beam hits multiple enemies',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['solenne_radiant_beam'],
        damageBonus: 0.5,
      ),
      SkillNode(
        id: 'solenne_beam_focus',
        name: 'Beam Focus',
        description: '+50% beam damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['solenne_radiant_beam'],
        damageBonus: 1,
      ),
      SkillNode(
        id: 'solenne_supernova',
        name: 'Supernova',
        description: '+50% sunburst damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['solenne_solar_flare'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'solenne_radiance',
        name: 'Radiance',
        description: '+50% radiant damage, +50% AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['solenne_solar_flare'],
        damageBonus: 2,
        aoeRadiusBonus: 45,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'solenne_eternal_sun',
        name: 'Eternal Sun',
        description: '+150% beam damage, pierces all',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['solenne_piercing_light', 'solenne_beam_focus'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'solenne_solar_eclipse',
        name: 'Solar Eclipse',
        description: '+200% sunburst damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['solenne_supernova', 'solenne_radiance'],
        damageBonus: 8,
        aoeRadiusBonus: 90,
      ),
    ],
  );

  // === RAVIK SKILL TREE ===
  // Ravik: Void/Soul modes
  static SkillTree _ravikTree() => SkillTree(
    heroName: 'Ravik',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'ravik_void_power',
        name: 'Void Power',
        description: '+30% voidburst damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.8,
      ),
      SkillNode(
        id: 'ravik_soul_harvest',
        name: 'Soul Harvest',
        description: '+25% soul damage per chain link',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.5,
      ),

      // TIER 2
      SkillNode(
        id: 'ravik_void_rite',
        name: 'Void Rite',
        description: '+50% voidburst AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['ravik_void_power'],
        aoeRadiusBonus: 30,
      ),
      SkillNode(
        id: 'ravik_abyssal',
        name: 'Abyssal',
        description: '+50% voidburst damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['ravik_void_power'],
        damageBonus: 3,
      ),
      SkillNode(
        id: 'ravik_soul_bind',
        name: 'Soul Bind',
        description: 'Soul drain chains 4 targets',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['ravik_soul_harvest'],
        damageBonus: 1,
      ),
      SkillNode(
        id: 'ravik_life_steal',
        name: 'Life Steal',
        description: 'Soul drain heals',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['ravik_soul_harvest'],
        damageBonus: 1,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'ravik_void_lord',
        name: 'Void Lord',
        description: '+150% voidburst damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['ravik_void_rite', 'ravik_abyssal'],
        damageBonus: 9,
        aoeRadiusBonus: 60,
      ),
      SkillNode(
        id: 'ravik_soul_reaper',
        name: 'Soul Reaper',
        description: '+100% soul damage, chains 5 targets',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['ravik_soul_bind', 'ravik_life_steal'],
        damageBonus: 3,
      ),
    ],
  );

  // === BRANN SKILL TREE ===
  // Brann: Earth/Boulder modes
  static SkillTree _brannTree() => SkillTree(
    heroName: 'Brann',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'brann_quake',
        name: 'Quake',
        description: '+30% earthquake damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.9,
      ),
      SkillNode(
        id: 'brann_boulder',
        name: 'Boulder',
        description: '+25% boulder damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 4.5,
      ),

      // TIER 2
      SkillNode(
        id: 'brann_tremor',
        name: 'Tremor',
        description: '+50% earthquake AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['brann_quake'],
        aoeRadiusBonus: 40,
      ),
      SkillNode(
        id: 'brann_crater',
        name: 'Crater',
        description: 'Earthquake leaves slowing crater',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['brann_quake'],
        aoeRadiusBonus: 20,
      ),
      SkillNode(
        id: 'brann_giant_boulder',
        name: 'Giant Boulder',
        description: '+50% boulder size, +30% damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['brann_boulder'],
        aoeRadiusBonus: 10,
        damageBonus: 2.7,
      ),
      SkillNode(
        id: 'brann_landslide',
        name: 'Landslide',
        description: 'Boulder leaves debris trail',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['brann_boulder'],
        damageBonus: 1.8,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'brann_earth_shatterer',
        name: 'Earth Shatterer',
        description: '+200% earthquake damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['brann_tremor', 'brann_crater'],
        damageBonus: 2,
        aoeRadiusBonus: 80,
      ),
      SkillNode(
        id: 'brann_mountain',
        name: 'Mountain',
        description: '+150% boulder damage, +200% size',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['brann_giant_boulder', 'brann_landslide'],
        damageBonus: 9,
        aoeRadiusBonus: 20,
      ),
    ],
  );

  // === NYXRA SKILL TREE ===
  // Nyxra: Lightning/Voidchain modes
  static SkillTree _nyxraTree() => SkillTree(
    heroName: 'Nyxra',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'nyxra_lightning_bolt',
        name: 'Lightning Bolt',
        description: '+30% lightning damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 3,
      ),
      SkillNode(
        id: 'nyxra_void_chain',
        name: 'Void Chain',
        description: '+20% voidchain damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 1.6,
      ),

      // TIER 2
      SkillNode(
        id: 'nyxra_chain_lightning',
        name: 'Chain Lightning',
        description: 'Lightning chains to 4 targets',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['nyxra_lightning_bolt'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'nyxra_static',
        name: 'Static',
        description: '+50% lightning damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['nyxra_lightning_bolt'],
        damageBonus: 5,
      ),
      SkillNode(
        id: 'nyxra_abyssal_chain',
        name: 'Abyssal Chain',
        description: 'Voidchain chains to 5 targets',
        maxLevel: 3,
        requiredHeroLevel: 5,
        requiredNodes: ['nyxra_void_chain'],
        damageBonus: 1,
      ),
      SkillNode(
        id: 'nyxra_shadow',
        name: 'Shadow',
        description: '+50% voidchain damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['nyxra_void_chain'],
        damageBonus: 3,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'nyxra_storm_lord',
        name: 'Storm Lord',
        description: '+150% lightning damage, chains 6',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['nyxra_chain_lightning', 'nyxra_static'],
        damageBonus: 8,
      ),
      SkillNode(
        id: 'nyxra_void_mistress',
        name: 'Void Mistress',
        description: '+150% voidchain damage, chains 6',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['nyxra_abyssal_chain', 'nyxra_shadow'],
        damageBonus: 4,
      ),
    ],
  );

  // === ELDRIN SKILL TREE ===
  // Eldrin: Cosmic/Nova modes
  static SkillTree _eldrinTree() => SkillTree(
    heroName: 'Eldrin',
    nodes: [
      // TIER 1
      SkillNode(
        id: 'eldrin_cosmic_power',
        name: 'Cosmic Power',
        description: '+30% cosmic damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 0.6,
      ),
      SkillNode(
        id: 'eldrin_nova_blast',
        name: 'Nova Blast',
        description: '+30% nova damage',
        maxLevel: 5,
        requiredHeroLevel: 1,
        damageBonus: 3,
      ),

      // TIER 2
      SkillNode(
        id: 'eldrin_cosmic_wave',
        name: 'Cosmic Wave',
        description: '+50% cosmic damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['eldrin_cosmic_power'],
        damageBonus: 1,
      ),
      SkillNode(
        id: 'eldrin_dimensional',
        name: 'Dimensional',
        description: 'Cosmic attack hits multiple times',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['eldrin_cosmic_power'],
        damageBonus: 0.5,
      ),
      SkillNode(
        id: 'eldrin_nova_explosion',
        name: 'Nova Explosion',
        description: '+50% nova damage',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['eldrin_nova_blast'],
        damageBonus: 5,
      ),
      SkillNode(
        id: 'eldrin_nova_field',
        name: 'Nova Field',
        description: '+50% nova AoE',
        maxLevel: 5,
        requiredHeroLevel: 5,
        requiredNodes: ['eldrin_nova_blast'],
        aoeRadiusBonus: 50,
      ),

      // TIER 3 (Ultimates)
      SkillNode(
        id: 'eldrin_cosmic_overlord',
        name: 'Cosmic Overlord',
        description: '+200% cosmic damage, hits 3 times',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['eldrin_cosmic_wave', 'eldrin_dimensional'],
        damageBonus: 2,
      ),
      SkillNode(
        id: 'eldrin_supernova',
        name: 'Supernova',
        description: '+200% nova damage, +100% AoE',
        maxLevel: 3,
        requiredHeroLevel: 10,
        requiredNodes: ['eldrin_nova_explosion', 'eldrin_nova_field'],
        damageBonus: 10,
        aoeRadiusBonus: 100,
      ),
    ],
  );
}
