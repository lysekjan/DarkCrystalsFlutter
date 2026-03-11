import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'rpg_system.dart';
import 'hero_upgrade_screen.dart';
import 'sound_manager.dart';
import 'skill_trees.dart';
import 'localization.dart';
import 'language_manager.dart';
import 'language_switcher.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageManager.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LanguageManager.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageManager.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Crystals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      locale: LanguageManager.toLocale(LanguageManager.currentLanguage),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLanguage.values
          .map((lang) => LanguageManager.toLocale(lang))
          .toList(),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1D1A), Color(0xFF1C3B34)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Language switcher at top right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: const LanguageSwitcher(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const SaveSlotScreen(),
                            ),
                          );
                        },
                        child: Text(loc.playButton),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HeroUpgradeScreen(),
                            ),
                          );
                        },
                        child: Text(loc.heroesButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveSlotScreen extends StatefulWidget {
  const SaveSlotScreen({super.key});

  @override
  State<SaveSlotScreen> createState() => _SaveSlotScreenState();
}

class _SaveSlotScreenState extends State<SaveSlotScreen> {
  int _activeSlot = 1;
  bool _loading = true;
  final Map<int, PlayerProgress> _slotProgress = {};

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final activeSlot = await RpgSystem.getActiveSlot();
    final progress1 = await RpgSystem.getProgressForSlot(1);
    final progress2 = await RpgSystem.getProgressForSlot(2);
    final progress3 = await RpgSystem.getProgressForSlot(3);
    if (!mounted) return;
    setState(() {
      _activeSlot = activeSlot;
      _slotProgress
        ..clear()
        ..[1] = progress1
        ..[2] = progress2
        ..[3] = progress3;
      _loading = false;
    });
  }

  Future<void> _selectSlot(int slot) async {
    await RpgSystem.setActiveSlot(slot);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const HeroSelectScreen(),
      ),
    );
  }

  int _unlockedHeroesCount(PlayerProgress progress) {
    return progress.heroes.values.where((h) => h.unlocked).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1D1A), Color(0xFF1C3B34)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vyber Herni Slot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (idx) {
                final slot = idx + 1;
                final progress = _slotProgress[slot]!;
                final isActive = _activeSlot == slot;
                return Container(
                  width: 240,
                  margin: EdgeInsets.only(right: slot < 3 ? 16 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101816),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? const Color(0xFF6BFA9D) : const Color(0xFF2F4B45),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot $slot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mince: ${progress.coins}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Hrdinove: ${_unlockedHeroesCount(progress)}/10',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Skore: ${progress.totalGamesPlayed}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _selectSlot(slot),
                          child: Text(isActive ? 'Pokracovat' : 'Vybrat'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zpet'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameHomeScreen extends StatelessWidget {
  const GameHomeScreen({super.key, required this.heroes});

  final List<HeroDef> heroes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameView(heroes: heroes),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, required this.heroes});

  final List<HeroDef> heroes;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  static const double mapWidth = 1600;
  static const double mapHeight = 400;
  static const double heroAreaWidth = 100;
  static const int heroSlots = 5;
  static const int heroGridRows = 7;
  static const int enemyLanes = 5;
  static const double heroPositionHeight = 50;
  static const double heroSpacerHeight = (mapHeight - heroSlots * heroPositionHeight) / 2;
  static const double enemyLaneHeight = mapHeight / enemyLanes;
  static const double heroCardHeight = 28;
  static const double wallHpMax = 300;
  static const double enemyHpMax = 20;
  static const double enemySize = 40;
  static const double enemySpeed = 16; // units per second
  static const double projectileSpeed = 160; // units per second
  static const double heroMoveSpeed = 180; // units per second
  static const double spellSendingDuration = 2; // seconds
  static const double spellCooldownDuration = 10; // seconds
  static const double cooldownScale = 0.25;
  static const double enemyTapRadius = 18;
  static const double heroTapRadius = 24;
  static const double heroUnitSize = 44;
  static const double wallDps = 5; // damage per second
  static const double hitFlashDuration = 0.12; // seconds
  static const double projectileRadius = 2;
  static const double explosionDuration = 0.35; // seconds
  static const double swordRadius = 140;
  static const double enemyDeathFrameDuration = 0.12;
  static const double enemyCorpseFadeDuration = 5.0;
  static const double minZoomMultiplier = 1.0;
  static const double maxZoomMultiplier = 2.5;
  static const double zoomStep = 0.2;

  final Random _rng = Random();
  late final Ticker _ticker;
  DateTime _gameStartTime = DateTime.now();
  double _lastTime = 0;
  double _wallHp = wallHpMax;
  double _timeUntilNextSpawn = 0;
  // Wave and statistics tracking
  int _currentWave = 1;
  int _enemiesKilled = 0;
  int _enemiesInWave = 0;
  int _enemiesSpawnedInWave = 0;
  int _totalWaves = 10;
  late final List<_HeroState> _heroStates;
  late final List<int> _heroSlotIndices;
  late final List<_HeroUnit> _heroUnits;
  bool _gameOver = false;
  bool _gameOverDialogShown = false;
  double _gameSpeed = 2;
  bool _speedPanelOpen = false;
  bool _autoMode = true;
  int? _readyHeroIndex;
  final _interactiveViewerKey = GlobalKey();
  final TransformationController _mapTransformController = TransformationController();
  _HeroMode _aerinMode = _HeroMode.normal;
  bool _aerinMenuOpen = false;
  late final AnimationController _aerinMenuController;
  _VeyraMode _veyraMode = _VeyraMode.rapid;
  bool _veyraMenuOpen = false;
  late final AnimationController _veyraMenuController;
  _ThalorMode _thalorMode = _ThalorMode.projectile;
  bool _thalorMenuOpen = false;
  late final AnimationController _thalorMenuController;
  _NyxraMode _nyxraMode = _NyxraMode.normal;
  bool _nyxraMenuOpen = false;
  late final AnimationController _nyxraMenuController;
  _MyrisMode _myrisMode = _MyrisMode.normal;
  bool _myrisMenuOpen = false;
  late final AnimationController _myrisMenuController;
  _KaelenMode _kaelenMode = _KaelenMode.normal;
  bool _kaelenMenuOpen = false;
  late final AnimationController _kaelenMenuController;
  _SolenneMode _solenneMode = _SolenneMode.normal;
  bool _solenneMenuOpen = false;
  late final AnimationController _solenneMenuController;
  _RavikMode _ravikMode = _RavikMode.normal;
  bool _ravikMenuOpen = false;
  late final AnimationController _ravikMenuController;
  _BrannMode _brannMode = _BrannMode.normal;
  bool _brannMenuOpen = false;
  late final AnimationController _brannMenuController;
  _EldrinMode _eldrinMode = _EldrinMode.normal;
  bool _eldrinMenuOpen = false;
  late final AnimationController _eldrinMenuController;

  final List<_Enemy> _enemies = [];
  final List<_Projectile> _projectiles = [];
  final List<_DamageText> _damageTexts = [];
  final List<_ExplosionEffect> _explosions = [];
  final List<_LightningEffect> _lightnings = [];
  Offset? _targetIndicator; // Shows manual target position
  bool _preventAutoReselect = false;
  DateTime _lastManualFireTime = DateTime.now();
  bool _isHoldingTouch = false;
  Offset? _holdPosition;
  int? _selectedHeroIndex;
  Offset? _pointerDownScenePosition;
  int? _pointerDownHeroIndex;

  // RPG bonus helper methods
  // RPG system variables
  int _coinsEarned = 0;
  final Map<String, int> _xpEarned = {}; // heroName -> xp amount

  // Hero bonuses from RPG system
  final Map<String, double> _damageBonuses = {}; // heroName -> damage bonus
  final Map<String, double> _cooldownReductions = {}; // heroName -> cooldown reduction (seconds)
  ui.Image? _enemySpriteSheet;
  int _enemySpriteFrameCount = 0;
  double _baseMapScale = 1.0;
  double _zoomMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _timeUntilNextSpawn = 4;
    _heroSlotIndices = List<int>.generate(widget.heroes.length, (index) => index);
    _heroStates = List<_HeroState>.generate(
      widget.heroes.length,
      (_) => _HeroState(
        phase: _HeroPhase.cooldown,
        timeRemaining: 0,
        pendingAttack: false,
      ),
    );
    _heroUnits = List<_HeroUnit>.generate(
      widget.heroes.length,
      _initialHeroUnit,
    );
    _aerinMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _loadEnemySpriteSheet();
    // Load RPG bonuses
    _loadHeroBonuses();
    _veyraMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _thalorMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _nyxraMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _myrisMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _kaelenMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _solenneMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _ravikMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _brannMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _eldrinMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _enemySpriteSheet?.dispose();
    _mapTransformController.dispose();
    _aerinMenuController.dispose();
    _veyraMenuController.dispose();
    _thalorMenuController.dispose();
    _nyxraMenuController.dispose();
    _myrisMenuController.dispose();
    _kaelenMenuController.dispose();
    _solenneMenuController.dispose();
    _ravikMenuController.dispose();
    _brannMenuController.dispose();
    _eldrinMenuController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadEnemySpriteSheet() async {
    try {
      final data = await rootBundle.load('assets/enemies/FatGoblin.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final frameWidth = max(1, image.height);
      final frameCount = max(1, image.width ~/ frameWidth);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _enemySpriteSheet?.dispose();
        _enemySpriteSheet = image;
        _enemySpriteFrameCount = frameCount;
      });
    } catch (_) {
      // Keep the painter fallback if the sprite sheet cannot be loaded.
    }
  }

  Future<void> _loadHeroBonuses() async {
    final skillTrees = _getSkillTrees();
    for (final hero in widget.heroes) {
      final skillTree = skillTrees[hero.name];
      if (skillTree != null) {
        final damageBonus = await RpgSystem.getTotalDamageBonus(hero.name, skillTree);
        final cooldownReduction = await RpgSystem.getTotalCooldownReduction(hero.name, skillTree);
        if (mounted) {
          setState(() {
            _damageBonuses[hero.name] = damageBonus;
            _cooldownReductions[hero.name] = cooldownReduction;
          });
        }
      }
    }
  }

  void _updateMapScale(double fitToWidthScale) {
    if ((_baseMapScale - fitToWidthScale).abs() < 0.0001) {
      return;
    }
    _baseMapScale = fitToWidthScale;
    _applyMapTransform();
  }

  void _applyMapTransform() {
    _mapTransformController.value = Matrix4.identity()
      ..scale(_baseMapScale * _zoomMultiplier);
  }

  void _changeZoom(double delta) {
    final nextZoom = (_zoomMultiplier + delta).clamp(
      minZoomMultiplier,
      maxZoomMultiplier,
    );
    if ((nextZoom - _zoomMultiplier).abs() < 0.0001) {
      return;
    }
    setState(() {
      _zoomMultiplier = nextZoom;
      _applyMapTransform();
    });
  }

  Map<String, SkillTree> _getSkillTrees() {
    return {
      'Aerin': SkillTrees.getTree('Aerin'),
      'Veyra': SkillTrees.getTree('Veyra'),
      'Thalor': SkillTrees.getTree('Thalor'),
      'Myris': SkillTrees.getTree('Myris'),
      'Kaelen': SkillTrees.getTree('Kaelen'),
      'Solenne': SkillTrees.getTree('Solenne'),
      'Ravik': SkillTrees.getTree('Ravik'),
      'Brann': SkillTrees.getTree('Brann'),
      'Nyxra': SkillTrees.getTree('Nyxra'),
      'Eldrin': SkillTrees.getTree('Eldrin'),
    };
  }

  bool _isEnemyTargetable(_Enemy enemy) => !enemy.isDying;

  bool _containsTargetableEnemy(_Enemy? enemy) {
    return enemy != null && _enemies.contains(enemy) && _isEnemyTargetable(enemy);
  }

  bool get _hasTargetableEnemies => _enemies.any(_isEnemyTargetable);

  _Enemy? _firstTargetableEnemy() {
    for (final enemy in _enemies) {
      if (_isEnemyTargetable(enemy)) {
        return enemy;
      }
    }
    return null;
  }

  void _beginEnemyDeath(_Enemy enemy) {
    if (enemy.isDying) {
      return;
    }
    enemy
      ..hp = 0
      ..attacking = false
      ..isDying = true
      ..deathAnimTime = 0
      ..corpseFadeTime = 0;
    _coinsEarned++;
    _enemiesKilled++;
    for (final hero in widget.heroes) {
      _xpEarned[hero.name] = (_xpEarned[hero.name] ?? 0) + 1;
    }
    SoundManager().playDeath();
  }

  int? _hitTestHero(Offset position) {
    for (int i = _heroUnits.length - 1; i >= 0; i--) {
      final hitBox = Rect.fromCenter(
        center: _heroUnits[i].position.translate(0, 5),
        width: heroUnitSize + 18,
        height: heroUnitSize + 22,
      );
      if (hitBox.contains(position)) {
        return i;
      }
    }
    return null;
  }

  void _handleMapTap(Offset position) {
    final tappedHeroIndex = _hitTestHero(position);
    if (tappedHeroIndex != null) {
      setState(() {
        _selectedHeroIndex = tappedHeroIndex;
      });
      return;
    }

    final selectedHeroIndex = _selectedHeroIndex;
    if (selectedHeroIndex == null) {
      return;
    }

    setState(() {
      final target = _clampHeroTarget(position);
      final unit = _heroUnits[selectedHeroIndex];
      unit
        ..target = target
        ..isMoving = (unit.position - target).distance > 0.01;
      _selectedHeroIndex = null;
    });
  }

  double _nextSpawnDelay() => max(0.5, (1.0 - (_currentWave * 0.05)) + _rng.nextDouble() * 8);
  int _enemiesForWave(int wave) => 5 + wave * 2; // More enemies in later waves

  _HeroUnit _initialHeroUnit(int index) {
    final count = max(1, widget.heroes.length);
    final spacing = mapHeight / (count + 1);
    final position = Offset(
      heroAreaWidth * 0.6,
      spacing * (index + 1),
    );
    return _HeroUnit(position: position, target: position);
  }

  Offset _heroPosition(int heroIndex) => _heroUnits[heroIndex].position;

  Offset _clampHeroTarget(Offset position) {
    final padding = heroUnitSize * 0.6;
    return Offset(
      position.dx.clamp(padding, mapWidth - padding),
      position.dy.clamp(padding, mapHeight - padding),
    );
  }

  double _enemyLaneCenterY(int laneIndex) {
    return enemyLaneHeight * (laneIndex + 0.5);
  }

  Duration get _gameDuration => DateTime.now().difference(_gameStartTime);
  String get _gameDurationText {
    final duration = _gameDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds;
    final seconds = t / 1e6;
    final rawDt = (seconds - _lastTime).clamp(0.0, 0.05);
    final dt = rawDt * _gameSpeed;
    _lastTime = seconds;
    if (dt <= 0 || _gameOver) {
      setState(() {});
      return;
    }

    _updateSpawning(dt);
    _updateEnemies(dt);
    _updateProjectiles(dt);
    _updateHeroMovement(dt);
    _updateHero(dt);
    _updateEffects(dt);

    if (_wallHp <= 0) {
      _wallHp = 0;
      _gameOver = true;
      SoundManager().playGameOver();
    }

    setState(() {});

    if (_gameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
  }

  void _updateSpawning(double dt) {
    _timeUntilNextSpawn -= dt;
    if (_timeUntilNextSpawn <= 0 && _enemiesSpawnedInWave < _enemiesForWave(_currentWave)) {
      final lane = _rng.nextInt(enemyLanes);
      final y = _enemyLaneCenterY(lane);
      // Increase enemy HP with each wave
      final hpMultiplier = 1.0 + (_currentWave - 1) * 0.1;
      _enemies.add(
        _Enemy(
          position: Offset(mapWidth, y),
          hp: enemyHpMax * hpMultiplier,
          seed: _rng.nextDouble() * 1000,
        ),
      );
      _enemiesSpawnedInWave++;
      _timeUntilNextSpawn = _nextSpawnDelay();
    }

    // Check if wave is complete (all enemies spawned and killed)
    if (_enemiesSpawnedInWave >= _enemiesForWave(_currentWave) && !_hasTargetableEnemies) {
      _currentWave++;
      _enemiesSpawnedInWave = 0;
      _enemiesInWave = 0;
      SoundManager().playWaveComplete();
    }
  }

  void _updateEnemies(double dt) {
    for (final enemy in _enemies) {
      if (enemy.isDying) {
        continue;
      }
      if (enemy.position.dx > heroAreaWidth + 4) {
        enemy.position = enemy.position.translate(-enemySpeed * dt, 0);
        enemy.attacking = false;
      } else {
        enemy.attacking = true;
        _wallHp -= wallDps * dt;
      }
    }
    _enemies.removeWhere((e) => e.canRemove);
  }

  void _updateHeroMovement(double dt) {
    for (int i = 0; i < _heroUnits.length; i++) {
      final unit = _heroUnits[i];
      final delta = unit.target - unit.position;
      final distance = delta.distance;
      if (distance <= 0.01) {
        unit
          ..position = unit.target
          ..isMoving = false;
        continue;
      }

      final step = heroMoveSpeed * dt;
      if (step >= distance) {
        unit
          ..position = unit.target
          ..isMoving = false;
        final state = _heroStates[i];
        if (state.phase == _HeroPhase.sending && state.pendingAttack) {
          state.pendingAttack = false;
          _performAttack(i);
        }
      } else {
        unit
          ..position = unit.position + Offset(delta.dx / distance * step, delta.dy / distance * step)
          ..isMoving = true;
      }
    }
  }

  void _updateProjectiles(double dt) {
    for (final proj in _projectiles) {
      proj.position = proj.position.translate(proj.velocity.dx * dt, proj.velocity.dy * dt);
    }

    for (final proj in List<_Projectile>.from(_projectiles)) {
      _Enemy? hit;
      for (final enemy in _enemies) {
        if (!_isEnemyTargetable(enemy)) {
          continue;
        }
        if ((enemy.position - proj.position).distance <= enemySize / 2 + proj.radius) {
          hit = enemy;
          break;
        }
      }
      if (hit != null) {
        if (proj.aoeRadius > 0) {
          for (final enemy in _enemies) {
            if (!_isEnemyTargetable(enemy)) {
              continue;
            }
            if ((enemy.position - hit.position).distance <= proj.aoeRadius) {
              _applyDamage(enemy, proj.damage);
            }
          }
          _explosions.add(
            _ExplosionEffect(
              position: hit.position,
              radius: proj.aoeRadius,
              isFire: proj.isAerinStrong,
              seed: proj.seed,
            ),
          );
        } else {
          _applyDamage(hit, proj.damage);
          if (proj.isAerinStrong) {
            _explosions.add(
              _ExplosionEffect(
                position: hit.position,
                radius: 52,
                isFire: true,
                seed: proj.seed,
              ),
            );
          }
        }
        _projectiles.remove(proj);
      } else if (proj.position.dx > mapWidth + 10 || proj.position.dy < -10 || proj.position.dy > mapHeight + 10) {
        _projectiles.remove(proj);
      }
    }
  }

  void _updateHero(double dt) {
    for (int i = 0; i < _heroStates.length; i++) {
      final state = _heroStates[i];
      final unit = _heroUnits[i];
      if (unit.isMoving && state.phase == _HeroPhase.sending) {
        continue;
      }
      state.timeRemaining -= dt;
      if (state.timeRemaining <= 0) {
        if (state.phase == _HeroPhase.sending) {
          _enterCooldown(i);
        } else {
          _enterSending(i);
        }
      }
    }
  }

  void _applyDamage(_Enemy enemy, double damage) {
    if (enemy.isDying) {
      return;
    }
    enemy.hp -= damage;
    enemy.flashRemaining = hitFlashDuration;
    enemy.pendingDamage += damage;
    if (enemy.damageTextCooldown <= 0) {
      _damageTexts.add(
        _DamageText(
          position: enemy.position,
          value: enemy.pendingDamage,
        ),
      );
      enemy.pendingDamage = 0;
      enemy.damageTextCooldown = 0.35;
    }
    if (enemy.hp <= 0) {
      _beginEnemyDeath(enemy);
    }
  }

  // Mode selector state
  bool _modeSelectorOpen = false;
  int? _selectorHeroIndex;

  // Mode selector methods
  void _openModeSelector(int heroIndex) {
    setState(() {
      _modeSelectorOpen = true;
      _selectorHeroIndex = heroIndex;
    });
  }

  Future<void> _saveProgress() async {
    // Save earned coins and XP to RPG system
    if (_coinsEarned > 0 || _xpEarned.isNotEmpty) {
      final progress = await RpgSystem.getProgress();
      progress.addCoins(_coinsEarned);

      // Award XP to heroes
      for (final entry in _xpEarned.entries) {
        await RpgSystem.addHeroXp(entry.key, entry.value);
      }

      // Auto-save
      await RpgSystem.saveProgress();

      // Reset tracking
      _coinsEarned = 0;
      _xpEarned.clear();
    }
  }

  Future<void> _resetGame() async {
    await _saveProgress();

    _timeUntilNextSpawn = 4;
    _wallHp = wallHpMax;
    _gameOver = false;
    _gameOverDialogShown = false;
    _enemies.clear();
    _projectiles.clear();
    _damageTexts.clear();
    _explosions.clear();
    _lightnings.clear();
    for (int i = 0; i < _heroUnits.length; i++) {
      _heroUnits[i] = _initialHeroUnit(i);
    }
    for (final state in _heroStates) {
      state.phase = _HeroPhase.cooldown;
      state.timeRemaining = 0;
      state.pendingAttack = false;
      state.beamTarget = null;
    }
    _selectedHeroIndex = null;
  }

  Future<void> _showGameOverDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101816),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1F2C29)),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(Icons.waves, Colors.blue, 'Wave Reached', _currentWave.toString()),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.favorite, Colors.redAccent, 'Enemies Killed', _enemiesKilled.toString()),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.monetization_on, Colors.amber, 'Coins Earned', _coinsEarned.toString()),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.timer, Colors.lightBlue, 'Game Time', _gameDurationText),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _resetGame();
                });
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () async {
                await _saveProgress();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const HeroSelectScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Návrat do výběru hrdinů'),
            ),
            TextButton(
              onPressed: () async {
                await _saveProgress();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const IntroScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Návrat do hlavního menu'),
            ),
          ],
        );
      },
    );
  }

  void _closeAllModeMenus() {
    _aerinMenuOpen = false;
    _veyraMenuOpen = false;
    _thalorMenuOpen = false;
    _nyxraMenuOpen = false;
    _myrisMenuOpen = false;
    _kaelenMenuOpen = false;
    _solenneMenuOpen = false;
    _ravikMenuOpen = false;
    _brannMenuOpen = false;
    _eldrinMenuOpen = false;
    _aerinMenuController.reverse();
    _veyraMenuController.reverse();
    _thalorMenuController.reverse();
    _nyxraMenuController.reverse();
    _myrisMenuController.reverse();
    _kaelenMenuController.reverse();
    _solenneMenuController.reverse();
    _ravikMenuController.reverse();
    _brannMenuController.reverse();
    _eldrinMenuController.reverse();
  }

  Widget _buildStatRow(IconData icon, Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _setHeroMode(int heroIndex, dynamic mode) {
    switch (widget.heroes[heroIndex].name) {
      case 'Aerin':
        _aerinMode = mode as _HeroMode;
        break;
      case 'Veyra':
        _veyraMode = mode as _VeyraMode;
        break;
      case 'Thalor':
        _thalorMode = mode as _ThalorMode;
        break;
      case 'Nyxra':
        _nyxraMode = mode as _NyxraMode;
        break;
      case 'Myris':
        _myrisMode = mode as _MyrisMode;
        break;
      case 'Kaelen':
        _kaelenMode = mode as _KaelenMode;
        break;
      case 'Solenne':
        _solenneMode = mode as _SolenneMode;
        break;
      case 'Ravik':
        _ravikMode = mode as _RavikMode;
        break;
      case 'Brann':
        _brannMode = mode as _BrannMode;
        break;
      case 'Eldrin':
        _eldrinMode = mode as _EldrinMode;
        break;
      }
      setState(() {
        _modeSelectorOpen = false;
      });
  }

  void _applyBeamDamage(int heroIndex, double dt) {
    if (_heroUnits[heroIndex].isMoving) {
      return;
    }
    final hero = widget.heroes[heroIndex];
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = hero.beamDps * dt;
    if (damage <= 0) {
      return;
    }

    if (!_hasTargetableEnemies) {
      return;
    }

    final state = _heroStates[heroIndex];
    _Enemy nearest;
    if (_containsTargetableEnemy(state.beamTarget)) {
      nearest = state.beamTarget!;
    } else {
      nearest = _firstTargetableEnemy()!;
      double bestDist = (nearest.position - heroPos).distance;
      for (final enemy in _enemies) {
        if (!_isEnemyTargetable(enemy) || identical(enemy, nearest)) {
          continue;
        }
        final d = (enemy.position - heroPos).distance;
        if (d < bestDist) {
          bestDist = d;
          nearest = enemy;
        }
      }
    }

    final dir = nearest.position - heroPos;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;

    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      final vx = enemy.position.dx - heroPos.dx;
      final vy = enemy.position.dy - heroPos.dy;
      final proj = vx * ux + vy * uy;
      if (proj < 0) {
        continue;
      }
      final perp = (vx * vx + vy * vy) - proj * proj;
      if (perp > (enemySize / 2) * (enemySize / 2)) {
        continue;
      }
      _applyDamage(enemy, damage);
    }
  }

  void _updateEffects(double dt) {
    for (final enemy in _enemies) {
      if (enemy.flashRemaining > 0) {
        enemy.flashRemaining = max(0, enemy.flashRemaining - dt);
      }
      if (enemy.damageTextCooldown > 0) {
        enemy.damageTextCooldown = max(0, enemy.damageTextCooldown - dt);
      }
      enemy.animTime += dt;
      if (enemy.isDying) {
        if (enemy.deathAnimTime < _Enemy.deathDuration) {
          enemy.deathAnimTime = min(_Enemy.deathDuration, enemy.deathAnimTime + dt);
        } else {
          enemy.corpseFadeTime = min(
            enemyCorpseFadeDuration,
            enemy.corpseFadeTime + dt,
          );
        }
      }
    }

    for (final fx in _explosions) {
      fx.lifeRemaining -= dt;
    }
    _explosions.removeWhere((e) => e.lifeRemaining <= 0);

    for (final bolt in _lightnings) {
      bolt.lifeRemaining -= dt;
    }
    _lightnings.removeWhere((e) => e.lifeRemaining <= 0);

    for (final text in _damageTexts) {
      text.lifeRemaining -= dt;
      text.position = text.position.translate(0, -text.speed * dt);
    }
    _damageTexts.removeWhere((t) => t.lifeRemaining <= 0);
  }

  void _enterSending(int heroIndex) {
    final isMoving = _heroUnits[heroIndex].isMoving;
    _heroStates[heroIndex]
      ..phase = _HeroPhase.sending
      ..pendingAttack = isMoving
      ..beamTarget = null
      ..timeRemaining = _effectiveSending(heroIndex);
    if (!isMoving) {
      _performAttack(heroIndex);
    }
  }

  void _enterCooldown(int heroIndex) {
    _heroStates[heroIndex]
      ..phase = _HeroPhase.cooldown
      ..pendingAttack = false
      ..beamTarget = null
      ..timeRemaining = _effectiveCooldown(heroIndex);
  }

  void _beginSendingAfterManualAttack(int heroIndex) {
    _heroStates[heroIndex]
      ..pendingAttack = false
      ..timeRemaining = _effectiveSending(heroIndex);
  }

  void _performAttack(int heroIndex, {_Enemy? target}) {
    final attackType = widget.heroes[heroIndex].attackType;

    if (_isMyris(heroIndex)) {
      switch (_myrisMode) {
        case _MyrisMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _MyrisMode.ice:
          _castMyrisIce(heroIndex, target: target);
          break;
        case _MyrisMode.freeze:
          _castMyrisFreeze(heroIndex);
          break;
      }
    } else if (_isKaelen(heroIndex)) {
      switch (_kaelenMode) {
        case _KaelenMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _KaelenMode.vine:
          _castKaelenVine(heroIndex);
          break;
        case _KaelenMode.spore:
          _castKaelenSpore(heroIndex, target: target);
          break;
      }
    } else if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.normal:
          _heroStates[heroIndex].beamTarget = target;
          break;
        case _SolenneMode.sunburst:
          _castSolenneSunburst(heroIndex);
          break;
        case _SolenneMode.radiant:
          _castSolenneRadiant(heroIndex);
          break;
      }
    } else if (_isRavik(heroIndex)) {
      switch (_ravikMode) {
        case _RavikMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _RavikMode.voidburst:
          _castRavikVoidBurst(heroIndex, target: target);
          break;
        case _RavikMode.soul:
          _castRavikSoulDrain(heroIndex, target: target);
          break;
      }
    } else if (_isBrann(heroIndex)) {
      switch (_brannMode) {
        case _BrannMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _BrannMode.earthquake:
          _castBrannEarthquake(heroIndex);
          break;
        case _BrannMode.boulder:
          _fireProjectile(heroIndex, target: target);
          break;
      }
    } else if (_isEldrin(heroIndex)) {
      switch (_eldrinMode) {
        case _EldrinMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _EldrinMode.cosmic:
          // Cosmic wave attack
          break;
        case _EldrinMode.nova:
          _castEldrinNova(heroIndex);
          break;
      }
    } else if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          _fireProjectile(heroIndex, target: target);
          break;
        case _VeyraMode.explosive:
          _fireProjectile(heroIndex, target: target);
          break;
        case _VeyraMode.lightning:
          _castVeyraLightning(heroIndex, target: target);
          break;
      }
    } else if (_isThalor(heroIndex)) {
      switch (_thalorMode) {
        case _ThalorMode.projectile:
          _fireProjectile(heroIndex, target: target);
          break;
        case _ThalorMode.sword:
          _swordHit(heroIndex);
          break;
        case _ThalorMode.energy:
          break;
      }
    } else if (_isNyxra(heroIndex)) {
      switch (_nyxraMode) {
        case _NyxraMode.normal:
          _fireProjectile(heroIndex, target: target);
          break;
        case _NyxraMode.lightning:
          _castNyxraLightning(heroIndex, target: target);
          break;
        case _NyxraMode.voidchain:
          _castNyxraVoidChain(heroIndex, target: target);
          break;
      }
    } else if (attackType == _AttackType.projectile) {
      _fireProjectile(heroIndex, target: target);
    }
  }

  void _triggerManualAttack(_Enemy target) {
    int? chosenIndex = _readyHeroIndex;
    if (chosenIndex == null || !_isHeroReady(chosenIndex)) {
      _refreshReadyHeroSelection();
      chosenIndex = _readyHeroIndex;
    }
    if (chosenIndex == null || !_isHeroReady(chosenIndex)) {
      return;
    }
    _performAttack(chosenIndex, target: target);
    _beginSendingAfterManualAttack(chosenIndex);
    _refreshReadyHeroSelection();
  }

  void _handleEnemyTap(Offset position) {
    if (_autoMode) {
      return;
    }

    // In manual mode with a ready hero, shoot at tapped position
    if (_readyHeroIndex != null) {
      _triggerManualPositionAttack(position);
      return;
    }

    if (!_hasTargetableEnemies) {
      return;
    }

    // Fallback: find nearest enemy if no hero ready
    _Enemy? hit;
    double bestDist = double.infinity;
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      final dist = (enemy.position - position).distance;
      if (dist <= enemySize / 2 + enemyTapRadius && dist < bestDist) {
        bestDist = dist;
        hit = enemy;
      }
    }
    if (hit == null) {
      return;
    }
    _triggerManualAttack(hit);
  }

  void _triggerManualPositionAttack(Offset screenPosition) {
    final heroIndex = _readyHeroIndex;
    if (heroIndex == null) {
      return;
    }

    // Prevent rapid-fire tapping (minimum 200ms between shots)
    final now = DateTime.now();
    final timeSinceLastFire = now.difference(_lastManualFireTime).inMilliseconds;
    if (timeSinceLastFire < 200) {
      return; // Ignore taps that are too close together
    }

    // Update last fire time
    _lastManualFireTime = now;

    // Prevent auto-reselecting another hero after this fire
    setState(() {
      _preventAutoReselect = true;
    });

    // Convert pointer position to map position
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final mapPosition = _screenToMapPosition(screenPosition);

    // Show target indicator at the exact map target used for firing.
    setState(() {
      _targetIndicator = mapPosition;
    });
    // Hide indicator after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _targetIndicator = null;
        });
      }
    });

    // Fire projectile at map position
    final dir = (mapPosition - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(dir.dx / len * projectileSpeed, dir.dy / len * projectileSpeed);
    final damage = _effectiveDamage(heroIndex);
    final radius = _effectiveProjectileRadius(heroIndex);
    final aoeRadius = _effectiveAoeRadius(heroIndex);
    final isAerinStrong = _isAerin(heroIndex) && _aerinMode == _HeroMode.strong;

    _projectiles.add(
      _Projectile(
        position: heroPos,
        velocity: velocity,
        damage: damage,
        radius: radius,
        aoeRadius: aoeRadius,
        isAerinStrong: isAerinStrong,
        seed: _rng.nextDouble() * 1000,
      ),
    );

    // Manual fire starts sending now; cooldown starts when sending ends.
    _beginSendingAfterManualAttack(heroIndex);
  }

  Offset _screenToMapPosition(Offset screenPosition) {
    // Pointer localPosition from the map listener is already in map-space.
    return screenPosition;
  }

  bool _isHeroReady(int heroIndex) {
    final state = _heroStates[heroIndex];
    if (_autoMode) {
      return state.phase == _HeroPhase.sending;
    }
    return state.phase == _HeroPhase.sending && state.pendingAttack;
  }

  void _refreshReadyHeroSelection() {
    if (_readyHeroIndex != null && _isHeroReady(_readyHeroIndex!)) {
      return;
    }
    // Don't auto-select if we just fired manually (wait for user to select another hero)
    if (_preventAutoReselect) {
      _readyHeroIndex = null;
      return;
    }
    _readyHeroIndex = null;
    for (int slot = 0; slot < heroSlots; slot++) {
      final heroIndex = _heroSlotIndices.indexOf(slot);
      if (heroIndex == -1) {
        continue;
      }
      if (_isHeroReady(heroIndex)) {
        _readyHeroIndex = heroIndex;
        break;
      }
    }
  }

  void _fireProjectile(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    Offset targetPos;
    if (_containsTargetableEnemy(target)) {
      targetPos = target!.position;
    } else if (!_hasTargetableEnemies) {
      targetPos = Offset(mapWidth, heroPos.dy);
    } else {
      _Enemy nearest = _firstTargetableEnemy()!;
      double bestDist = (nearest.position - heroPos).distance;
      for (final enemy in _enemies) {
        if (!_isEnemyTargetable(enemy) || identical(enemy, nearest)) {
          continue;
        }
        final d = (enemy.position - heroPos).distance;
        if (d < bestDist) {
          bestDist = d;
          nearest = enemy;
        }
      }
      targetPos = nearest.position;
    }

    final dir = (targetPos - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(dir.dx / len * projectileSpeed, dir.dy / len * projectileSpeed);
    final damage = _effectiveDamage(heroIndex);
    final radius = _effectiveProjectileRadius(heroIndex);
    final aoeRadius = _effectiveAoeRadius(heroIndex);
    final isAerinStrong = _isAerin(heroIndex) && _aerinMode == _HeroMode.strong;
    _projectiles.add(
      _Projectile(
        position: heroPos,
        velocity: velocity,
        damage: damage,
        radius: radius,
        aoeRadius: aoeRadius,
        isAerinStrong: isAerinStrong,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  bool _isAerin(int heroIndex) => widget.heroes[heroIndex].name == 'Aerin';
  bool _isVeyra(int heroIndex) => widget.heroes[heroIndex].name == 'Veyra';
  bool _isThalor(int heroIndex) => widget.heroes[heroIndex].name == 'Thalor';
  bool _isNyxra(int heroIndex) => widget.heroes[heroIndex].name == 'Nyxra';
  bool _isMyris(int heroIndex) => widget.heroes[heroIndex].name == 'Myris';
  bool _isKaelen(int heroIndex) => widget.heroes[heroIndex].name == 'Kaelen';
  bool _isSolenne(int heroIndex) => widget.heroes[heroIndex].name == 'Solenne';
  bool _isRavik(int heroIndex) => widget.heroes[heroIndex].name == 'Ravik';
  bool _isBrann(int heroIndex) => widget.heroes[heroIndex].name == 'Brann';
  bool _isEldrin(int heroIndex) => widget.heroes[heroIndex].name == 'Eldrin';

  double _effectiveSending(int heroIndex) {
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.lightning) {
      return 2;
    }
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.voidchain) {
      return 2.5;
    }
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return 1;
        case _VeyraMode.explosive:
          return 1;
        case _VeyraMode.lightning:
          return 1;
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return 1;
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.energy) {
      return 2;
    }
    if (_isMyris(heroIndex)) {
      switch (_myrisMode) {
        case _MyrisMode.normal:
          return spellSendingDuration;
        case _MyrisMode.ice:
          return 1;
        case _MyrisMode.freeze:
          return 0.5;
      }
    }
    if (_isKaelen(heroIndex)) {
      switch (_kaelenMode) {
        case _KaelenMode.normal:
          return spellSendingDuration;
        case _KaelenMode.vine:
          return 0.5;
        case _KaelenMode.spore:
          return 1;
      }
    }
    if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.normal:
          return spellSendingDuration;
        case _SolenneMode.sunburst:
          return 0.5;
        case _SolenneMode.radiant:
          return 1;
      }
    }
    if (_isRavik(heroIndex)) {
      switch (_ravikMode) {
        case _RavikMode.normal:
          return spellSendingDuration;
        case _RavikMode.voidburst:
          return 1;
        case _RavikMode.soul:
          return 1.5;
      }
    }
    if (_isBrann(heroIndex)) {
      switch (_brannMode) {
        case _BrannMode.normal:
          return spellSendingDuration;
        case _BrannMode.earthquake:
          return 0.5;
        case _BrannMode.boulder:
          return 1;
      }
    }
    if (_isEldrin(heroIndex)) {
      switch (_eldrinMode) {
        case _EldrinMode.normal:
          return spellSendingDuration;
        case _EldrinMode.cosmic:
          return 1;
        case _EldrinMode.nova:
          return 0.5;
      }
    }
    return spellSendingDuration;
  }

  IconData _aerinModeIcon(_HeroMode mode) {
    switch (mode) {
      case _HeroMode.fast:
        return Icons.flash_on;
      case _HeroMode.strong:
        return Icons.whatshot;
      case _HeroMode.normal:
        return Icons.auto_awesome;
    }
  }

  IconData _veyraModeIcon(_VeyraMode mode) {
    switch (mode) {
      case _VeyraMode.rapid:
        return Icons.flash_on;
      case _VeyraMode.explosive:
        return Icons.whatshot;
      case _VeyraMode.lightning:
        return Icons.bolt;
    }
  }

  IconData _thalorModeIcon(_ThalorMode mode) {
    switch (mode) {
      case _ThalorMode.projectile:
        return Icons.auto_awesome;
      case _ThalorMode.sword:
        return Icons.gavel;
      case _ThalorMode.energy:
        return Icons.wb_sunny;
    }
  }

  IconData _nyxraModeIcon(_NyxraMode mode) {
    switch (mode) {
      case _NyxraMode.normal:
        return Icons.auto_awesome;
      case _NyxraMode.lightning:
        return Icons.bolt;
      case _NyxraMode.voidchain:
        return Icons.blur_on;
    }
  }

  IconData _myrisModeIcon(_MyrisMode mode) {
    switch (mode) {
      case _MyrisMode.normal:
        return Icons.auto_awesome;
      case _MyrisMode.ice:
        return Icons.ac_unit;
      case _MyrisMode.freeze:
        return Icons.grain;
    }
  }

  IconData _kaelenModeIcon(_KaelenMode mode) {
    switch (mode) {
      case _KaelenMode.normal:
        return Icons.auto_awesome;
      case _KaelenMode.vine:
        return Icons.grass;
      case _KaelenMode.spore:
        return Icons.cloud;
    }
  }

  IconData _solenneModeIcon(_SolenneMode mode) {
    switch (mode) {
      case _SolenneMode.normal:
        return Icons.auto_awesome;
      case _SolenneMode.sunburst:
        return Icons.wb_sunny;
      case _SolenneMode.radiant:
        return Icons.circle;
    }
  }

  IconData _ravikModeIcon(_RavikMode mode) {
    switch (mode) {
      case _RavikMode.normal:
        return Icons.auto_awesome;
      case _RavikMode.voidburst:
        return Icons.blur_on;
      case _RavikMode.soul:
        return Icons.favorite;
    }
  }

  IconData _brannModeIcon(_BrannMode mode) {
    switch (mode) {
      case _BrannMode.normal:
        return Icons.auto_awesome;
      case _BrannMode.earthquake:
        return Icons.vibration;
      case _BrannMode.boulder:
        return Icons.circle;
    }
  }

  IconData _eldrinModeIcon(_EldrinMode mode) {
    switch (mode) {
      case _EldrinMode.normal:
        return Icons.auto_awesome;
      case _EldrinMode.cosmic:
        return Icons.star;
      case _EldrinMode.nova:
        return Icons.brightness_5;
    }
  }

  double _effectiveCooldown(int heroIndex) {
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.lightning) {
      return _scaleCooldown(10);
    }
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.voidchain) {
      return _scaleCooldown(14);
    }
    if (_isAerin(heroIndex)) {
      switch (_aerinMode) {
        case _HeroMode.fast:
          return _scaleCooldown(3);
        case _HeroMode.strong:
          return _scaleCooldown(1);
        case _HeroMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
      }
    }
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return _scaleCooldown(2);
        case _VeyraMode.explosive:
          return _scaleCooldown(10);
        case _VeyraMode.lightning:
          return _scaleCooldown(2);
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return _scaleCooldown(2);
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.energy) {
      return _scaleCooldown(12);
    }
    if (_isMyris(heroIndex)) {
      switch (_myrisMode) {
        case _MyrisMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _MyrisMode.ice:
          return _scaleCooldown(8);
        case _MyrisMode.freeze:
          return _scaleCooldown(12);
      }
    }
    if (_isKaelen(heroIndex)) {
      switch (_kaelenMode) {
        case _KaelenMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _KaelenMode.vine:
          return _scaleCooldown(6);
        case _KaelenMode.spore:
          return _scaleCooldown(15);
      }
    }
    if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _SolenneMode.sunburst:
          return _scaleCooldown(14);
        case _SolenneMode.radiant:
          return _scaleCooldown(10);
      }
    }
    if (_isRavik(heroIndex)) {
      switch (_ravikMode) {
        case _RavikMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _RavikMode.voidburst:
          return _scaleCooldown(12);
        case _RavikMode.soul:
          return _scaleCooldown(15);
      }
    }
    if (_isBrann(heroIndex)) {
      switch (_brannMode) {
        case _BrannMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _BrannMode.earthquake:
          return _scaleCooldown(11);
        case _BrannMode.boulder:
          return _scaleCooldown(18);
      }
    }
    if (_isEldrin(heroIndex)) {
      switch (_eldrinMode) {
        case _EldrinMode.normal:
          return _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
        case _EldrinMode.cosmic:
          return _scaleCooldown(8);
        case _EldrinMode.nova:
          return _scaleCooldown(16);
      }
    }

    // Apply cooldown reduction from RPG system
    final baseCooldown = _scaleCooldown(widget.heroes[heroIndex].cooldownDuration);
    final heroName = widget.heroes[heroIndex].name;
    final reduction = _cooldownReductions[heroName] ?? 0;
    return max(0.5, baseCooldown - reduction);
  }

  double _scaleCooldown(double value) => value * cooldownScale;

  double _effectiveDamage(int heroIndex) {
    double baseDamage;
    if (_isAerin(heroIndex)) {
      switch (_aerinMode) {
        case _HeroMode.fast:
          baseDamage = 1;
          break;
        case _HeroMode.strong:
          baseDamage = 20;
          break;
        case _HeroMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
      }
    } else if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          baseDamage = 1;
          break;
        case _VeyraMode.explosive:
          baseDamage = 3;
          break;
        case _VeyraMode.lightning:
          baseDamage = 30;
          break;
      }
    } else if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      baseDamage = 5;
    } else if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.energy) {
      baseDamage = 2;
    } else if (_isMyris(heroIndex)) {
      switch (_myrisMode) {
        case _MyrisMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _MyrisMode.ice:
          baseDamage = 3;
          break;
        case _MyrisMode.freeze:
          baseDamage = 8;
          break;
      }
    } else if (_isKaelen(heroIndex)) {
      switch (_kaelenMode) {
        case _KaelenMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _KaelenMode.vine:
          baseDamage = 6;
          break;
        case _KaelenMode.spore:
          baseDamage = 2;
          break;
      }
    } else if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _SolenneMode.sunburst:
          baseDamage = 12;
          break;
        case _SolenneMode.radiant:
          baseDamage = 4;
          break;
      }
    } else if (_isRavik(heroIndex)) {
      switch (_ravikMode) {
        case _RavikMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _RavikMode.voidburst:
          baseDamage = 6;
          break;
        case _RavikMode.soul:
          baseDamage = 5;
          break;
      }
    } else if (_isBrann(heroIndex)) {
      switch (_brannMode) {
        case _BrannMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _BrannMode.earthquake:
          baseDamage = 3;
          break;
        case _BrannMode.boulder:
          baseDamage = 18;
          break;
      }
    } else if (_isEldrin(heroIndex)) {
      switch (_eldrinMode) {
        case _EldrinMode.normal:
          baseDamage = widget.heroes[heroIndex].damage;
          break;
        case _EldrinMode.cosmic:
          baseDamage = 2;
          break;
        case _EldrinMode.nova:
          baseDamage = 10;
          break;
      }
    } else {
      baseDamage = widget.heroes[heroIndex].damage;
    }

    // Add RPG bonus from skill upgrades
    final heroName = widget.heroes[heroIndex].name;
    final bonusMultiplier = _damageBonuses[heroName] ?? 0;
    return baseDamage * (1 + bonusMultiplier);
  }

  double _effectiveProjectileRadius(int heroIndex) {
    if (_isAerin(heroIndex)) {
      switch (_aerinMode) {
        case _HeroMode.fast:
          return projectileRadius * 0.5;
        case _HeroMode.strong:
          return projectileRadius * 4;
        case _HeroMode.normal:
          return projectileRadius;
      }
    }
    if (_isBrann(heroIndex) && _brannMode == _BrannMode.boulder) {
      return projectileRadius * 5;
    }
    return projectileRadius;
  }

  double _effectiveAoeRadius(int heroIndex) {
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.explosive:
          return 60;
        default:
          return 0;
      }
    }
    if (_isMyris(heroIndex) && _myrisMode == _MyrisMode.ice) {
      return 50;
    }
    if (_isKaelen(heroIndex) && _kaelenMode == _KaelenMode.spore) {
      return 70;
    }
    if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.sunburst:
          return 40;
        case _SolenneMode.radiant:
          return 90;
        default:
          return 0;
      }
    }
    if (_isRavik(heroIndex) && _ravikMode == _RavikMode.voidburst) {
      return 60;
    }
    if (_isBrann(heroIndex)) {
      switch (_brannMode) {
        case _BrannMode.earthquake:
          return 80;
        default:
          return 0;
      }
    }
    if (_isEldrin(heroIndex) && _eldrinMode == _EldrinMode.nova) {
      return 100;
    }
    return 0;
  }

  _Enemy? _nearestEnemy(Offset from, Set<_Enemy> exclude) {
    _Enemy? nearest;
    double bestDist = double.infinity;
    for (final enemy in _enemies) {
      if (exclude.contains(enemy) || !_isEnemyTargetable(enemy)) {
        continue;
      }
      final d = (enemy.position - from).distance;
      if (d < bestDist) {
        bestDist = d;
        nearest = enemy;
      }
    }
    return nearest;
  }

  void _castNyxraLightning(int heroIndex, {_Enemy? target}) {
    if (!_hasTargetableEnemies) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final used = <_Enemy>{};

    final first = _containsTargetableEnemy(target) ? target : _nearestEnemy(heroPos, used);
    if (first == null) {
      return;
    }
    used.add(first);
    _applyDamage(first, 10);

    final segments = <_LightningSegment>[
      _LightningSegment(start: heroPos, end: first.position, seed: _rng.nextDouble() * 1000),
    ];

    final second = _nearestEnemy(first.position, used);
    if (second != null) {
      used.add(second);
      _applyDamage(second, 8);
      segments.add(_LightningSegment(start: first.position, end: second.position, seed: _rng.nextDouble() * 1000));
    }

    if (second != null) {
      final third = _nearestEnemy(second.position, used);
      if (third != null) {
        used.add(third);
        _applyDamage(third, 5);
        segments.add(_LightningSegment(start: second.position, end: third.position, seed: _rng.nextDouble() * 1000));
      }
    }

    _lightnings.add(_LightningEffect(segments: segments));
  }

  void _swordHit(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= swordRadius) {
        _applyDamage(enemy, damage);
      }
    }
  }

  bool _hasEnemyInSwordRange(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= swordRadius) {
        return true;
      }
    }
    return false;
  }

  void _castMyrisIce(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final heroColor = widget.heroes[heroIndex].color;
    _fireProjectileWithAoe(heroIndex, heroPos, heroColor, 50, false, target: target);
  }

  void _castMyrisFreeze(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      final dist = (enemy.position - heroPos).distance;
      if (dist <= 200) {
        _applyDamage(enemy, damage);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: 200,
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castKaelenVine(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= 100) {
        _applyDamage(enemy, damage);
      }
    }
  }

  void _castKaelenSpore(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final heroColor = widget.heroes[heroIndex].color;
    _fireProjectileWithAoe(heroIndex, heroPos, heroColor, 70, false, target: target);
  }

  void _castSolenneSunburst(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= 40) {
        _applyDamage(enemy, damage);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: 40,
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castSolenneRadiant(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= 90) {
        _applyDamage(enemy, damage);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: 90,
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castRavikVoidBurst(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final heroColor = widget.heroes[heroIndex].color;
    _fireProjectileWithAoe(heroIndex, heroPos, heroColor, 60, false, target: target);
  }

  void _castRavikSoulDrain(int heroIndex, {_Enemy? target}) {
    if (!_hasTargetableEnemies) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final used = <_Enemy>{};

    final first = _containsTargetableEnemy(target) ? target : _nearestEnemy(heroPos, used);
    if (first == null) {
      return;
    }
    used.add(first);
    _applyDamage(first, 5);

    final segments = <_LightningSegment>[
      _LightningSegment(start: heroPos, end: first.position, seed: _rng.nextDouble() * 1000),
    ];

    final second = _nearestEnemy(first.position, used);
    if (second != null) {
      used.add(second);
      _applyDamage(second, 4);
      segments.add(_LightningSegment(start: first.position, end: second.position, seed: _rng.nextDouble() * 1000));
    }

    if (second != null) {
      final third = _nearestEnemy(second.position, used);
      if (third != null) {
        used.add(third);
        _applyDamage(third, 3);
        segments.add(_LightningSegment(start: second.position, end: third.position, seed: _rng.nextDouble() * 1000));
      }
    }

    _lightnings.add(_LightningEffect(segments: segments));
  }

  void _castBrannEarthquake(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= 80) {
        _applyDamage(enemy, damage);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: 80,
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castEldrinNova(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= 100) {
        _applyDamage(enemy, damage);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: 100,
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castVeyraLightning(int heroIndex, {_Enemy? target}) {
    if (!_hasTargetableEnemies) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final resolvedTarget = _containsTargetableEnemy(target) ? target : _nearestEnemy(heroPos, {});
    if (resolvedTarget == null) {
      return;
    }

    _applyDamage(resolvedTarget, 30);
    _lightnings.add(
      _LightningEffect(
        segments: [
          _LightningSegment(
            start: heroPos,
            end: resolvedTarget.position,
            seed: _rng.nextDouble() * 1000,
          ),
        ],
      ),
    );
  }

  void _castNyxraVoidChain(int heroIndex, {_Enemy? target}) {
    if (!_hasTargetableEnemies) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final used = <_Enemy>{};

    final first = _containsTargetableEnemy(target) ? target : _nearestEnemy(heroPos, used);
    if (first == null) {
      return;
    }
    used.add(first);
    _applyDamage(first, 8);

    final segments = <_LightningSegment>[
      _LightningSegment(start: heroPos, end: first.position, seed: _rng.nextDouble() * 1000),
    ];

    final second = _nearestEnemy(first.position, used);
    if (second != null) {
      used.add(second);
      _applyDamage(second, 6);
      segments.add(_LightningSegment(start: first.position, end: second!.position, seed: _rng.nextDouble() * 1000));

      final third = _nearestEnemy(second!.position, used);
      if (third != null) {
        used.add(third);
        _applyDamage(third, 4);
        segments.add(_LightningSegment(start: second!.position, end: third!.position, seed: _rng.nextDouble() * 1000));

        final fourth = _nearestEnemy(third!.position, used);
        if (fourth != null) {
          used.add(fourth);
          _applyDamage(fourth, 2);
          segments.add(_LightningSegment(start: third!.position, end: fourth!.position, seed: _rng.nextDouble() * 1000));
        }
      }
    }

    _lightnings.add(_LightningEffect(segments: segments));
  }

  void _fireProjectileWithAoe(
    int heroIndex,
    Offset heroPos,
    Color heroColor,
    double aoeRadius,
    bool isFire, {
    _Enemy? target,
  }) {
    Offset targetPos;
    if (_containsTargetableEnemy(target)) {
      targetPos = target!.position;
    } else if (!_hasTargetableEnemies) {
      targetPos = Offset(mapWidth, heroPos.dy);
    } else {
      _Enemy nearest = _firstTargetableEnemy()!;
      double bestDist = (nearest.position - heroPos).distance;
      for (final enemy in _enemies) {
        if (!_isEnemyTargetable(enemy) || identical(enemy, nearest)) {
          continue;
        }
        final d = (enemy.position - heroPos).distance;
        if (d < bestDist) {
          bestDist = d;
          nearest = enemy;
        }
      }
      targetPos = nearest.position;
    }

    final dir = (targetPos - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(dir.dx / len * projectileSpeed, dir.dy / len * projectileSpeed);
    final damage = _effectiveDamage(heroIndex);

    _projectiles.add(
      _Projectile(
        position: heroPos,
        velocity: velocity,
        damage: damage,
        radius: projectileRadius,
        aoeRadius: aoeRadius,
        isAerinStrong: isFire,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Menu'),
          content: const Text('Co chceš udělat?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const IntroScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Zpět do hlavního menu'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Zavřít'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroCooldowns = List<double>.generate(
      widget.heroes.length,
      (i) => _effectiveCooldown(i),
    );
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _saveProgress();
        }
      },
      child: Stack(
        children: [
          Column(
            children: [
              _HpBar(
                wallHp: _wallHp,
                currentWave: _currentWave,
                enemiesKilled: _enemiesKilled,
                coinsEarned: _coinsEarned,
                gameDurationText: _gameDurationText,
                enemiesInWave: _enemiesSpawnedInWave,
                totalEnemiesInWave: _enemiesForWave(_currentWave),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ZoomButton(
                      icon: Icons.add,
                      onTap: () => _changeZoom(zoomStep),
                    ),
                    const SizedBox(width: 8),
                    _ZoomButton(
                      icon: Icons.remove,
                      onTap: () => _changeZoom(-zoomStep),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fitToWidthScale = constraints.maxWidth / mapWidth;
                    _updateMapScale(fitToWidthScale);

                    return InteractiveViewer(
                      key: _interactiveViewerKey,
                      transformationController: _mapTransformController,
                      constrained: false,
                      panEnabled: _zoomMultiplier > minZoomMultiplier,
                      scaleEnabled: false,
                      boundaryMargin: EdgeInsets.zero,
                      minScale: fitToWidthScale,
                      maxScale: fitToWidthScale * maxZoomMultiplier,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: mapWidth,
                        height: mapHeight,
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(mapWidth, mapHeight),
                              painter: _GamePainter(
                                wallHp: _wallHp,
                                enemies: _enemies,
                                projectiles: _projectiles,
                                damageTexts: _damageTexts,
                                explosions: _explosions,
                                lightnings: _lightnings,
                                wallX: heroAreaWidth,
                                heroes: widget.heroes,
                                heroPositions: _heroUnits.map((unit) => unit.position).toList(),
                                heroStates: _heroStates,
                                thalorMode: _thalorMode,
                                time: _lastTime,
                                enemySpriteSheet: _enemySpriteSheet,
                                enemySpriteFrameCount: _enemySpriteFrameCount,
                                targetIndicator: _targetIndicator,
                              ),
                            ),
                            Positioned.fill(
                              child: Listener(
                                onPointerDown: (event) {
                                  _pointerDownScenePosition = _mapTransformController.toScene(
                                    event.localPosition,
                                  );
                                  _pointerDownHeroIndex = _pointerDownScenePosition == null
                                      ? null
                                      : _hitTestHero(_pointerDownScenePosition!);
                                },
                                onPointerUp: (event) {
                                  final scenePosition = _mapTransformController.toScene(
                                    event.localPosition,
                                  );
                                  final start = _pointerDownScenePosition;
                                  final pointerDownHeroIndex = _pointerDownHeroIndex;
                                  _pointerDownScenePosition = null;
                                  _pointerDownHeroIndex = null;
                                  if (start == null || (scenePosition - start).distance > 12) {
                                    return;
                                  }
                                  if (pointerDownHeroIndex != null) {
                                    setState(() {
                                      _selectedHeroIndex = pointerDownHeroIndex;
                                    });
                                    return;
                                  }
                                  _handleMapTap(scenePosition);
                                },
                                onPointerCancel: (event) {
                                  _pointerDownScenePosition = null;
                                  _pointerDownHeroIndex = null;
                                },
                                behavior: HitTestBehavior.opaque,
                                child: const SizedBox.expand(),
                              ),
                            ),
                            for (int i = 0; i < widget.heroes.length; i++)
                              Positioned(
                                left: _heroPosition(i).dx - (heroUnitSize + 18) / 2,
                                top: _heroPosition(i).dy - (heroUnitSize + 22) / 2,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _selectedHeroIndex = i;
                                    });
                                  },
                                  child: SizedBox(
                                    width: heroUnitSize + 18,
                                    height: heroUnitSize + 22,
                                    child: Center(
                                      child: _HeroUnitWidget(
                                        hero: widget.heroes[i],
                                        state: _heroStates[i],
                                        isSelected: _selectedHeroIndex == i,
                                        isMoving: _heroUnits[i].isMoving,
                                        cooldownDuration: heroCooldowns[i],
                                        size: heroUnitSize,
                                        time: _lastTime,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: () => _openMenu(context),
              icon: const Icon(Icons.menu),
              color: Colors.white,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _SpeedPanel(
              isOpen: _speedPanelOpen,
              speed: _gameSpeed,
              onToggle: () => setState(() => _speedPanelOpen = !_speedPanelOpen),
              onSetSpeed: (value) => setState(() => _gameSpeed = value),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroUnitWidget extends StatelessWidget {
  const _HeroUnitWidget({
    required this.hero,
    required this.state,
    required this.isSelected,
    required this.isMoving,
    required this.cooldownDuration,
    required this.size,
    required this.time,
  });

  final HeroDef hero;
  final _HeroState state;
  final bool isSelected;
  final bool isMoving;
  final double cooldownDuration;
  final double size;
  final double time;

  @override
  Widget build(BuildContext context) {
    final pulse = sin(time * 6) * 0.5 + 0.5;
    final cooldownFraction =
        (state.phase == _HeroPhase.cooldown && cooldownDuration > 0)
            ? (state.timeRemaining / cooldownDuration).clamp(0.0, 1.0)
            : 0.0;

    return SizedBox(
      width: size,
      height: size + 10,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: hero.color.withOpacity(isMoving ? 0.75 : 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFE08A) : Colors.white24,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFE08A).withOpacity(0.5 + pulse * 0.35),
                        blurRadius: 14 + pulse * 6,
                        spreadRadius: 1.5,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hero.imageAsset.isNotEmpty)
                    Image.asset(
                      hero.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.white70, size: 20);
                      },
                    )
                  else
                    const Icon(Icons.person, color: Colors.white70, size: 20),
                  if (isMoving)
                    Container(
                      color: const Color(0x66000000),
                      alignment: Alignment.center,
                      child: const Icon(Icons.directions_run, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: size,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x66101816),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: cooldownFraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6FE2C1),
                    borderRadius: BorderRadius.circular(999),
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

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF13221F).withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _HeroUnit {
  _HeroUnit({
    required this.position,
    required this.target,
  });

  Offset position;
  Offset target;
  bool isMoving = false;
}

class _Enemy {
  _Enemy({required this.position, required this.hp, required this.seed});

  Offset position;
  double hp;
  final double seed;
  bool attacking = false;
  double flashRemaining = 0;
  double damageTextCooldown = 0;
  double pendingDamage = 0;
  double animTime = 0;
  bool isDying = false;
  double deathAnimTime = 0;
  double corpseFadeTime = 0;

  static const int deathFrameCount = 6;
  static const double deathFrameDuration = _GameViewState.enemyDeathFrameDuration;
  static const double deathDuration = deathFrameCount * deathFrameDuration;

  bool get canRemove => isDying && corpseFadeTime >= _GameViewState.enemyCorpseFadeDuration;
}

class _Projectile {
  _Projectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.radius,
    required this.aoeRadius,
    required this.isAerinStrong,
    required this.seed,
  });

  Offset position;
  Offset velocity;
  double damage;
  double radius;
  double aoeRadius;
  final bool isAerinStrong;
  final double seed;
}

class _GamePainter extends CustomPainter {
  _GamePainter({
    required this.wallHp,
    required this.enemies,
    required this.projectiles,
    required this.damageTexts,
    required this.explosions,
    required this.lightnings,
    required this.wallX,
    required this.heroes,
    required this.heroPositions,
    required this.heroStates,
    required this.thalorMode,
    required this.time,
    required this.enemySpriteSheet,
    required this.enemySpriteFrameCount,
    this.targetIndicator,
  });

  final double wallHp;
  final List<_Enemy> enemies;
  final List<_Projectile> projectiles;
  final List<_DamageText> damageTexts;
  final List<_ExplosionEffect> explosions;
  final List<_LightningEffect> lightnings;
  final double wallX;
  final List<HeroDef> heroes;
  final List<Offset> heroPositions;
  final List<_HeroState> heroStates;
  final _ThalorMode thalorMode;
  final double time;
  final ui.Image? enemySpriteSheet;
  final int enemySpriteFrameCount;
  final Offset? targetIndicator;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0E1412);
    canvas.drawRect(Offset.zero & size, bg);

    for (int i = 0; i < heroes.length; i++) {
      final heroPos = heroPositions[i];
      if (heroes[i].attackType == _AttackType.beam && heroStates[i].phase == _HeroPhase.sending) {
        _Enemy? nearest;
        double minDist = double.infinity;
        for (final enemy in enemies) {
          if (enemy.isDying) {
            continue;
          }
          final dist = (enemy.position - heroPos).distance;
          if (dist < minDist) {
            minDist = dist;
            nearest = enemy;
          }
        }
        if (nearest != null) {
          final dir = nearest.position - heroPos;
          final len = max(dir.distance, 0.001);
          final end = heroPos + Offset(dir.dx / len * size.width, dir.dy / len * size.width);
          _drawMagicBeam(canvas, heroPos, end, heroes[i].color, time);
        }
      }

      if (heroes[i].name == 'Thalor' &&
          thalorMode == _ThalorMode.sword &&
          heroStates[i].phase == _HeroPhase.sending) {
        _drawSwordSwing(
          canvas,
          heroPos,
          enemies,
          _GameViewState.spellSendingDuration,
          heroStates[i].timeRemaining,
        );
      }
    }

    final wall = Paint()..color = const Color(0xFF8B7D5A);
    canvas.drawRect(Rect.fromLTWH(wallX, 0, 4, size.height), wall);

    final wallHpPaint = Paint()
      ..color = const Color(0xFF6BFA9D)
      ..style = PaintingStyle.fill;
    final hpRatio = (wallHp / _GameViewState.wallHpMax).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(wallX + 2, 0, 2, size.height * hpRatio), wallHpPaint);

    final enemyPaint = Paint()..color = const Color(0xFFE06A5E);
    final enemyHitPaint = Paint()..color = Colors.white;
    final enemyHpBack = Paint()..color = const Color(0xFF2A2A2A);
    final enemyHpFill = Paint()..color = const Color(0xFF6BFA9D);
    for (final enemy in enemies) {
      if (enemySpriteSheet != null && enemySpriteFrameCount > 0) {
        _drawEnemySprite(canvas, enemy);
      } else {
        _drawHungryEnemy(canvas, enemy, enemy.flashRemaining > 0 ? enemyHitPaint : enemyPaint);
      }

      if (enemy.isDying) {
        continue;
      }
      final hpRatio = (enemy.hp / _GameViewState.enemyHpMax).clamp(0.0, 1.0);
      final barWidth = _GameViewState.enemySize;
      const barHeight = 4.0;
      final barLeft = enemy.position.dx - barWidth / 2;
      final barTop = enemy.position.dy - _GameViewState.enemySize / 2 - 8;
      final backRect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
      final fillRect = Rect.fromLTWH(barLeft, barTop, barWidth * hpRatio, barHeight);
      canvas.drawRect(backRect, enemyHpBack);
      canvas.drawRect(fillRect, enemyHpFill);
    }

    final projPaint = Paint()..color = const Color(0xFFF2E86D);
    for (final p in projectiles) {
      if (p.isAerinStrong) {
        _drawFireballProjectile(canvas, p, time);
      } else {
        canvas.drawCircle(p.position, p.radius, projPaint);
      }
    }

    for (final fx in damageTexts) {
      final alpha = (fx.lifeRemaining / fx.maxLife).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '-${fx.value.toStringAsFixed(0)}',
          style: TextStyle(
            color: Colors.red.withOpacity(alpha),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final offset = Offset(
        fx.position.dx - textPainter.width / 2,
        fx.position.dy - _GameViewState.enemySize / 2 - 16,
      );
      textPainter.paint(canvas, offset);
    }

    for (final boom in explosions) {
      final alpha = (boom.lifeRemaining / _GameViewState.explosionDuration).clamp(0.0, 1.0);
      if (boom.isFire) {
        _drawFireExplosion(canvas, boom, time, alpha);
      } else {
        final paint = Paint()
          ..color = Colors.orangeAccent.withOpacity(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(boom.position, boom.radius * (1 - alpha * 0.3), paint);
      }
    }

    for (final bolt in lightnings) {
      _drawLightningEffect(canvas, bolt, time);
    }

    if (targetIndicator != null) {
      _drawTargetIndicator(canvas, targetIndicator!);
    }

  }

  void _drawFireballProjectile(Canvas canvas, _Projectile p, double time) {
    final flicker = (sin(time * 12 + p.seed) + 1) * 0.5;
    final coreRadius = p.radius * (0.9 + flicker * 0.25);
    final glowRadius = p.radius * (2.2 + flicker * 0.7);
    final trailDir = p.velocity.distance > 0.001
        ? Offset(p.velocity.dx, p.velocity.dy) / p.velocity.distance
        : const Offset(1, 0);
    final trailNormal = Offset(-trailDir.dy, trailDir.dx);

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        p.position,
        glowRadius,
        [
          const Color(0xFFFFF2B0).withOpacity(0.9),
          const Color(0xFFFF8A3D).withOpacity(0.7),
          const Color(0xFFB13A1C).withOpacity(0.0),
        ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawCircle(p.position, glowRadius, glowPaint);

    final trailLength = glowRadius * 1.6;
    final trailOffset = p.position - trailDir * trailLength * (0.5 + flicker * 0.2);
    final trailPath = Path()
      ..moveTo(p.position.dx, p.position.dy)
      ..quadraticBezierTo(
        trailOffset.dx + trailNormal.dx * glowRadius * 0.35,
        trailOffset.dy + trailNormal.dy * glowRadius * 0.35,
        trailOffset.dx,
        trailOffset.dy,
      )
      ..quadraticBezierTo(
        trailOffset.dx - trailNormal.dx * glowRadius * 0.35,
        trailOffset.dy - trailNormal.dy * glowRadius * 0.35,
        p.position.dx,
        p.position.dy,
      )
      ..close();
    final trailPaint = Paint()
      ..shader = ui.Gradient.linear(
        p.position,
        trailOffset,
        [
          const Color(0xFFFFC15A).withOpacity(0.75),
          const Color(0xFFFF6A3A).withOpacity(0.0),
        ],
      );
    canvas.drawPath(trailPath, trailPaint);

    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        p.position,
        coreRadius,
        [
          const Color(0xFFFFF8D1),
          const Color(0xFFFFB347),
          const Color(0xFF9F2A12),
        ],
        const [0.0, 0.7, 1.0],
      );
    canvas.drawCircle(p.position, coreRadius, corePaint);

    final sparkCount = 5;
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * pi * 2 + time * 2 + p.seed * 0.1;
      final r = coreRadius * (1.1 + flicker * 0.4);
      final sparkPos = p.position + Offset(cos(angle), sin(angle)) * r;
      final sparkPaint = Paint()..color = const Color(0xFFFFE08A).withOpacity(0.8);
      canvas.drawCircle(sparkPos, 1.2 + flicker, sparkPaint);
    }
  }

  void _drawFireExplosion(Canvas canvas, _ExplosionEffect boom, double time, double alpha) {
    final progress = 1 - alpha;
    final wobble = sin(time * 10 + boom.seed) * 0.6;
    final radius = boom.radius * (0.6 + progress * 0.6) + wobble;

    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        boom.position,
        radius * 0.7,
        [
          const Color(0xFFFFF2B0).withOpacity(0.9 * alpha),
          const Color(0xFFFFA640).withOpacity(0.8 * alpha),
          const Color(0xFFB13A1C).withOpacity(0.0),
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(boom.position, radius * 0.7, corePaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFFF7A36).withOpacity(0.7 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + progress * 2;
    canvas.drawCircle(boom.position, radius, ringPaint);

    final sparkPaint = Paint()..color = const Color(0xFFFFD08A).withOpacity(0.8 * alpha);
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * pi * 2 + time * 1.2 + boom.seed * 0.1;
      final r = radius * (0.7 + (i % 3) * 0.12);
      final pos = boom.position + Offset(cos(angle), sin(angle)) * r;
      canvas.drawCircle(pos, 2.0 + (1 - alpha) * 2.0, sparkPaint);
    }
  }

  void _drawLightningEffect(Canvas canvas, _LightningEffect bolt, double time) {
    final alpha = (bolt.lifeRemaining / bolt.maxLife).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..color = const Color(0xFFBFE8FF).withOpacity(0.6 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    final corePaint = Paint()
      ..color = const Color(0xFFEAF8FF).withOpacity(0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    for (final seg in bolt.segments) {
      final path = _buildLightningPath(seg.start, seg.end, seg.seed, time);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, corePaint);

      final impact = Paint()..color = const Color(0xFFD9F4FF).withOpacity(0.8 * alpha);
      canvas.drawCircle(seg.end, 4 + sin(time * 14 + seg.seed) * 1.5, impact);
    }
  }

  Path _buildLightningPath(Offset start, Offset end, double seed, double time) {
    final dir = end - start;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;
    final normal = Offset(-uy, ux);
    final steps = 8;
    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final falloff = 1 - (t - 0.5).abs() * 1.6;
      final jitter = sin(t * len * 0.22 + time * 20 + seed + i) * 8 * falloff;
      final p = start + Offset(ux, uy) * (len * t) + normal * jitter;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  void _drawEnemySprite(Canvas canvas, _Enemy enemy) {
    final spriteSheet = enemySpriteSheet;
    if (spriteSheet == null || enemySpriteFrameCount <= 0) {
      return;
    }

    const walkFrameStart = 8;
    const walkFrameCount = 8;
    const attackFrameStart = 16;
    const attackFrameCount = 9;
    final deathFrameStart = max(0, enemySpriteFrameCount - _Enemy.deathFrameCount);
    final availableWalkFrames = max(1, min(walkFrameCount, enemySpriteFrameCount - walkFrameStart));
    final availableAttackFrames = max(1, min(attackFrameCount, enemySpriteFrameCount - attackFrameStart));

    late final int frameIndex;
    if (enemy.isDying) {
      final deathFrameOffset = min(
        _Enemy.deathFrameCount - 1,
        (enemy.deathAnimTime / _Enemy.deathFrameDuration).floor(),
      );
      frameIndex = deathFrameStart + deathFrameOffset;
    } else {
      final animFps = enemy.attacking ? 10.0 : 12.0;
      final animPhase = (enemy.animTime * animFps + enemy.seed * 0.03).floor();
      frameIndex = enemy.attacking
          ? attackFrameStart + (animPhase % availableAttackFrames)
          : walkFrameStart + (animPhase % availableWalkFrames);
    }

    final frameWidth = spriteSheet.width / enemySpriteFrameCount;
    final frameHeight = spriteSheet.height.toDouble();
    final t = enemy.animTime;
    final bob = enemy.isDying ? 0.0 : sin(t * 2.4 + enemy.seed) * 1.2;
    final jitter = enemy.isDying
        ? 0.0
        : enemy.attacking
            ? sin(t * 18 + enemy.seed * 0.7) * 1.0
            : sin(t * 10 + enemy.seed * 0.7) * 0.5;
    final drawCenter = enemy.position + Offset(jitter, bob);
    final destRect = Rect.fromCenter(
      center: drawCenter,
      width: _GameViewState.enemySize * 1.35,
      height: _GameViewState.enemySize * 1.35,
    );
    final srcRect = Rect.fromLTWH(
      frameIndex * frameWidth,
      0,
      frameWidth,
      frameHeight,
    );

    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    if (enemy.flashRemaining > 0) {
      paint.colorFilter = const ui.ColorFilter.mode(Colors.white, BlendMode.modulate);
    }
    if (enemy.isDying) {
      paint.color = Colors.white.withOpacity(
        1 - (enemy.corpseFadeTime / _GameViewState.enemyCorpseFadeDuration),
      );
    }

    canvas.save();
    canvas.translate(drawCenter.dx, 0);
    canvas.scale(-1, 1);
    canvas.translate(-drawCenter.dx, 0);
    canvas.drawImageRect(spriteSheet, srcRect, destRect, paint);
    canvas.restore();
  }

  void _drawHungryEnemy(Canvas canvas, _Enemy enemy, Paint bodyPaint) {
    final baseSize = _GameViewState.enemySize;
    final t = enemy.animTime;
    final seed = enemy.seed;
    final bob = sin(t * 2.4 + seed) * 1.6;
    final jitter = enemy.attacking ? sin(t * 18 + seed * 0.7) * 1.2 : sin(t * 10 + seed * 0.7) * 0.6;
    final offset = enemy.position + Offset(jitter, bob);
    final squash = 1 + sin(t * 3.1 + seed * 0.3) * 0.06;
    final stretch = 1 - sin(t * 3.1 + seed * 0.3) * 0.05;

    final mouthSpeed = enemy.attacking ? 9.0 : 4.5;
    final mouthPulse = (sin(t * mouthSpeed + seed) + 1) * 0.5;
    final mouthOpen = 0.25 + mouthPulse * 0.55;
    final mouthAngle = (0.35 + mouthOpen * 0.6) * pi;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(stretch, squash);

    final radius = baseSize * 0.5;
    canvas.drawCircle(Offset.zero, radius, bodyPaint);

    final mouthPaint = Paint()..color = const Color(0xFF2A0F0D);
    final mouthPath = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius * 0.7),
        pi - mouthAngle * 0.5,
        mouthAngle,
        false,
      )
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    final teethPaint = Paint()..color = const Color(0xFFF7F3E6);
    final toothBase = radius * 0.18;
    for (int i = -1; i <= 1; i++) {
      final x = -radius * 0.45 + i * toothBase * 1.2;
      final y = radius * 0.08 + (i.abs() * 0.6);
      final tooth = Path()
        ..moveTo(x, y)
        ..lineTo(x + toothBase * 0.5, y + toothBase * 0.9)
        ..lineTo(x + toothBase, y)
        ..close();
      canvas.drawPath(tooth, teethPaint);
    }

    final blink = (sin(t * 1.6 + seed * 2.1) > 0.92) ? 0.2 : 1.0;
    final eyeOffsetY = -radius * 0.2;
    final eyeOffsetX = radius * 0.18;
    final eyeWhite = Paint()..color = Colors.white;
    final eyeBlack = Paint()..color = const Color(0xFF140A08);
    final eyeRadius = radius * 0.13;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(eyeOffsetX, eyeOffsetY),
        width: eyeRadius * 2,
        height: eyeRadius * 2 * blink,
      ),
      eyeWhite,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(eyeOffsetX + eyeRadius * 0.2, eyeOffsetY),
        width: eyeRadius * 0.7,
        height: eyeRadius * 0.7 * blink,
      ),
      eyeBlack,
    );

    final eye2Radius = radius * 0.1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-eyeOffsetX * 1.1, eyeOffsetY * 0.95),
        width: eye2Radius * 2,
        height: eye2Radius * 2 * blink,
      ),
      eyeWhite,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-eyeOffsetX * 1.1 + eye2Radius * 0.2, eyeOffsetY * 0.95),
        width: eye2Radius * 0.7,
        height: eye2Radius * 0.7 * blink,
      ),
      eyeBlack,
    );

    final droolPaint = Paint()..color = const Color(0xFF7EC7FF).withOpacity(0.7);
    final droolLen = radius * (0.3 + mouthPulse * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-radius * 0.08, radius * 0.15, radius * 0.16, droolLen),
        const Radius.circular(6),
      ),
      droolPaint,
    );

    canvas.restore();
  }


  void _drawMagicBeam(Canvas canvas, Offset start, Offset end, Color color, double time) {
    final dir = end - start;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;
    final normal = Offset(-uy, ux);

    final glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        start,
        end,
        [
          color.withOpacity(0.0),
          color.withOpacity(0.7),
          color.withOpacity(0.0),
        ],
        const [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawLine(start, end, glowPaint);

    for (int layer = 0; layer < 3; layer++) {
      final amp = 2.0 + layer * 1.4;
      final freq = 0.15 + layer * 0.05;
      final phase = time * (6.0 + layer * 1.4) + layer * 2.1;
      final path = Path();
      for (int step = 0; step <= 10; step++) {
        final t = step / 10;
        final wave = sin((t * len * freq) + phase) * amp;
        final p = start + Offset(ux, uy) * (len * t) + normal * wave;
        if (step == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      final stroke = Paint()
        ..color = color.withOpacity(0.55 - layer * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6 - layer * 1.5
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2 + layer * 1.5);
      canvas.drawPath(path, stroke);
    }

    final corePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;
    canvas.drawLine(start, end, corePaint);

    for (int i = 0; i < 6; i++) {
      final t = (i + 1) / 7;
      final pulse = (sin(time * 7.5 + i * 1.3) + 1) * 0.5;
      final jitter = sin(time * 5.3 + i * 2.2) * 2.0;
      final p = start + Offset(ux, uy) * (len * t) + normal * jitter;
      final radius = 2.0 + pulse * 3.0;
      final sparkPaint = Paint()..color = color.withOpacity(0.8);
      canvas.drawCircle(p, radius, sparkPaint);
    }
  }

  void _drawSwordSwing(
    Canvas canvas,
    Offset heroPos,
    List<_Enemy> enemies,
    double sendingDuration,
    double remaining,
  ) {
    _Enemy? nearest;
    double bestDist = double.infinity;
    for (final enemy in enemies) {
      if (enemy.isDying) {
        continue;
      }
      final d = (enemy.position - heroPos).distance;
      if (d < bestDist) {
        bestDist = d;
        nearest = enemy;
      }
    }
    if (nearest == null) {
      return;
    }

    final dir = nearest.position - heroPos;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;

    final progress = (1 - (remaining / sendingDuration)).clamp(0.0, 1.0);
    final swing = sin(progress * pi * 2); // up -> down -> up
    final swingOffset = Offset(-uy, ux) * (swing * 18);
    final end = heroPos + Offset(ux, uy) * _GameViewState.swordRadius + swingOffset;

    final arcStart = heroPos + Offset(ux, uy) * (_GameViewState.swordRadius * 0.2);
    final arcEnd = end;
    final arcMid = heroPos +
        Offset(ux, uy) * (_GameViewState.swordRadius * 0.65) +
        Offset(-uy, ux) * (swing * 26);
    final arcPath = Path()
      ..moveTo(arcStart.dx, arcStart.dy)
      ..quadraticBezierTo(arcMid.dx, arcMid.dy, arcEnd.dx, arcEnd.dy);

    final glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        arcStart,
        arcEnd,
        [
          const Color(0xFFF7EED0).withOpacity(0.0),
          const Color(0xFFF7EED0).withOpacity(0.8),
          const Color(0xFFFFC06A).withOpacity(0.0),
        ],
        const [0.0, 0.55, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawPath(arcPath, glowPaint);

    final bladePaint = Paint()
      ..color = const Color(0xFFEFE2C6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(heroPos, end, bladePaint);

    final slashPaint = Paint()
      ..color = const Color(0xFFFFE7A3).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(arcPath, slashPaint);

    for (int i = 0; i < 6; i++) {
      final t = i / 5;
      final wave = sin(time * 6.0 + i * 1.2) * 2.5;
      final p = Offset.lerp(arcStart, arcEnd, t)! + Offset(-uy, ux) * wave;
      final sparkPaint = Paint()..color = const Color(0xFFFFD98A).withOpacity(0.8);
      canvas.drawCircle(p, 1.4 + (i % 2) * 0.6, sparkPaint);
    }
  }


  void _drawTargetIndicator(Canvas canvas, Offset center) {
    final targetPaint = Paint()
      ..color = const Color(0xFF6FE2C1).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final targetFillPaint = Paint()
      ..color = const Color(0xFF6FE2C1).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const targetSize = 24.0;
    canvas.drawCircle(center, targetSize, targetFillPaint);
    canvas.drawCircle(center, targetSize, targetPaint);

    final crosshairPaint = Paint()
      ..color = const Color(0xFFB5FFF0).withOpacity(0.95)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx - targetSize - 8, center.dy),
      Offset(center.dx + targetSize + 8, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - targetSize - 8),
      Offset(center.dx, center.dy + targetSize + 8),
      crosshairPaint,
    );
  }

  IconData _aerinModeIcon(_HeroMode mode) {
    switch (mode) {
      case _HeroMode.fast:
        return Icons.flash_on;
      case _HeroMode.strong:
        return Icons.whatshot;
      case _HeroMode.normal:
        return Icons.auto_awesome;
    }
  }

  @override
  bool shouldRepaint(_GamePainter oldDelegate) {
    return true;
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({
    required this.wallHp,
    required this.currentWave,
    required this.enemiesKilled,
    required this.coinsEarned,
    required this.gameDurationText,
    required this.enemiesInWave,
    required this.totalEnemiesInWave,
  });

  final double wallHp;
  final int currentWave;
  final int enemiesKilled;
  final int coinsEarned;
  final String gameDurationText;
  final int enemiesInWave;
  final int totalEnemiesInWave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2C29), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Wall HP
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Wall HP',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
                Text(
                  wallHp.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Wave info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Wave',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
                Text(
 'Wave $currentWave',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Stats row
          Expanded(
            flex: 5,
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildStatItem(Icons.favorite, Colors.redAccent, enemiesKilled),
                _buildStatItem(Icons.monetization_on, Colors.amber, coinsEarned),
                _buildStatItem(Icons.timer, Colors.blueAccent, gameDurationText, isText: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, dynamic value, {bool isText = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          isText ? value.toString() : value.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

enum _HeroPhase { sending, cooldown }
enum _AttackType { projectile, beam }
enum _HeroMode { normal, fast, strong }
enum _VeyraMode { rapid, explosive, lightning }
enum _ThalorMode { projectile, sword, energy }
enum _NyxraMode { normal, lightning, voidchain }
enum _MyrisMode { normal, ice, freeze }
enum _KaelenMode { normal, vine, spore }
enum _SolenneMode { normal, sunburst, radiant }
enum _RavikMode { normal, voidburst, soul }
enum _BrannMode { normal, earthquake, boulder }
enum _EldrinMode { normal, cosmic, nova }

class _HeroState {
  _HeroState({
    required this.phase,
    required this.timeRemaining,
    this.pendingAttack = false,
    this.beamTarget,
  });

  _HeroPhase phase;
  double timeRemaining;
  bool pendingAttack;
  _Enemy? beamTarget;
}

class HeroDef {
  const HeroDef(
    this.name,
    this.color, {
    this.imageAsset = '',
    this.cooldownDuration = _GameViewState.spellCooldownDuration,
    this.damage = 5.0,
    this.attackType = _AttackType.projectile,
    this.beamDps = 2.0,
  });

  final String name;
  final Color color;
  final String imageAsset;
  final double cooldownDuration;
  final double damage;
  final _AttackType attackType;
  final double beamDps;
}

class _DamageText {
  _DamageText({
    required this.position,
    required this.value,
  });

  Offset position;
  final double value;
  final double maxLife = 0.8;
  double lifeRemaining = 0.8;
  final double speed = 24;
}

class _ExplosionEffect {
  _ExplosionEffect({
    required this.position,
    required this.radius,
    required this.isFire,
    this.seed = 0,
  });

  final Offset position;
  final double radius;
  final bool isFire;
  final double seed;
  double lifeRemaining = _GameViewState.explosionDuration;
}

class _LightningSegment {
  _LightningSegment({required this.start, required this.end, required this.seed});

  final Offset start;
  final Offset end;
  final double seed;
}

class _LightningEffect {
  _LightningEffect({required this.segments});

  final List<_LightningSegment> segments;
  final double maxLife = 0.28;
  double lifeRemaining = 0.28;
}

class _SpeedPanel extends StatelessWidget {
  const _SpeedPanel({
    required this.isOpen,
    required this.speed,
    required this.onToggle,
    required this.onSetSpeed,
  });

  final bool isOpen;
  final double speed;
  final VoidCallback onToggle;
  final ValueChanged<double> onSetSpeed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        width: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF101816),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2C29)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              child: Row(
                children: [
                  const Icon(Icons.speed, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Rychlost x${speed.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(
                    isOpen ? Icons.expand_more : Icons.chevron_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (isOpen) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _SpeedButton(
                    label: '1x',
                    selected: speed == 1,
                    onTap: () => onSetSpeed(1),
                  ),
                  const SizedBox(width: 6),
                  _SpeedButton(
                    label: '2x',
                    selected: speed == 2,
                    onTap: () => onSetSpeed(2),
                  ),
                  const SizedBox(width: 6),
                  _SpeedButton(
                    label: '4x',
                    selected: speed == 4,
                    onTap: () => onSetSpeed(4),
                  ),
                  const SizedBox(width: 6),
                  _SpeedButton(
                    label: '8x',
                    selected: speed == 8,
                    onTap: () => onSetSpeed(8),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AutoModePanel extends StatelessWidget {
  const _AutoModePanel({
    required this.enabled,
    required this.onToggle,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF101816),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2C29)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Automode',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: const Color(0xFF6FE2C1),
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: const Color(0xFF2F4B45),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2F4B45) : const Color(0xFF1F2C29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _AerinModeMenu extends StatelessWidget {
  const _AerinModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _HeroMode mode;
  final ValueChanged<_HeroMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_HeroMode.normal, _HeroMode.fast, _HeroMode.strong];
    final icons = [Icons.auto_awesome, Icons.flash_on, Icons.whatshot];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _VeyraModeMenu extends StatelessWidget {
  const _VeyraModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _VeyraMode mode;
  final ValueChanged<_VeyraMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 34;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_VeyraMode.rapid, _VeyraMode.explosive, _VeyraMode.lightning];
    final icons = [Icons.flash_on, Icons.whatshot, Icons.bolt];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _ThalorModeMenu extends StatelessWidget {
  const _ThalorModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _ThalorMode mode;
  final ValueChanged<_ThalorMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 34;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_ThalorMode.projectile, _ThalorMode.sword];
    final icons = [Icons.auto_awesome, Icons.gavel];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(2, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _NyxraModeMenu extends StatelessWidget {
  const _NyxraModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _NyxraMode mode;
  final ValueChanged<_NyxraMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 34;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_NyxraMode.normal, _NyxraMode.lightning];
    final icons = [Icons.auto_awesome, Icons.bolt];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(2, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _ModeCircleButton extends StatelessWidget {
  const _ModeCircleButton({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFF1F2C29),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class HeroSelectScreen extends StatefulWidget {
  const HeroSelectScreen({super.key});

  @override
  State<HeroSelectScreen> createState() => _HeroSelectScreenState();
}

class _HeroSelectScreenState extends State<HeroSelectScreen> {
  static const int slotCount = 5;

  final List<HeroDef> _heroes = const [
    HeroDef('Aerin', Color(0xFFE57373), imageAsset: 'assets/heroes/hero_aerin.png'),
    HeroDef('Veyra', Color(0xFFBA68C8), imageAsset: 'assets/heroes/hero_veyra.png', cooldownDuration: 5, damage: 2.5),
    HeroDef('Thalor', Color(0xFF64B5F6), imageAsset: 'assets/heroes/hero_thalor.png'),
    HeroDef('Myris', Color(0xFF4DB6AC), imageAsset: 'assets/heroes/hero_myris.png'),
    HeroDef('Kaelen', Color(0xFF81C784), imageAsset: 'assets/heroes/hero_kaelen.png'),
    HeroDef('Solenne', Color(0xFFFFD54F), imageAsset: 'assets/heroes/hero_solenne.png', attackType: _AttackType.beam, beamDps: 2.0),
    HeroDef('Ravik', Color(0xFFFF8A65), imageAsset: 'assets/heroes/hero_ravik.png'),
    HeroDef('Brann', Color(0xFFA1887F), imageAsset: 'assets/heroes/hero_brann.png'),
    HeroDef('Nyxra', Color(0xFF90A4AE), imageAsset: 'assets/heroes/hero_nyxra.png'),
    HeroDef('Eldrin', Color(0xFF9575CD), imageAsset: 'assets/heroes/hero_eldrin.png'),
  ];

  late final List<HeroDef?> _slots = List<HeroDef?>.filled(slotCount, null);
  PlayerProgress? _progress;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await RpgSystem.getProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  bool _isHeroUnlocked(String heroName) {
    final heroData = _progress?.heroes[heroName];
    return heroData?.unlocked ?? false;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _assignHero(HeroDef hero) {
    if (_slots.contains(hero)) {
      return;
    }
    final idx = _slots.indexWhere((c) => c == null);
    if (idx == -1) {
      return;
    }
    setState(() {
      _slots[idx] = hero;
    });
  }

  void _removeHero(int slotIndex) {
    setState(() {
      _slots[slotIndex] = null;
    });
  }

  void _startGame() {
    final selected = _slots.whereType<HeroDef>().toList();
    if (selected.isEmpty) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameHomeScreen(heroes: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _slots.any((c) => c != null);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _heroes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final hero = _heroes[index];
                final isSelected = _slots.contains(hero);
                final isUnlocked = _isHeroUnlocked(hero.name);
                return GestureDetector(
                  onTap: !isUnlocked ? null : (isSelected ? null : () => _assignHero(hero)),
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      color: !isUnlocked
                          ? Colors.grey.shade800
                          : (isSelected ? Colors.grey : hero.color).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isUnlocked ? Colors.white24 : Colors.grey.shade700),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: hero.imageAsset.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          hero.imageAsset,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.person,
                                              color: Colors.white54,
                                              size: 40,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                hero.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isUnlocked ? Colors.grey.shade500 : Colors.white,
                                  fontSize: 12,
                                  height: 1.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (!isUnlocked)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 40,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 380,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              margin: const EdgeInsets.only(right: 16, bottom: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF101816),
                border: Border(
                  top: BorderSide(color: Color(0xFF1F2C29), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(slotCount, (i) {
                      final hero = _slots[i];
                      return GestureDetector(
                        onTap: hero == null ? null : () => _removeHero(i),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: hero?.color ?? const Color(0xFF1F2C29),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: hero == null
                              ? const Icon(Icons.add, color: Colors.white38)
                              : hero.imageAsset.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        hero.imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            color: Colors.white54,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.person, color: Colors.white54),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Zpět'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: hasSelection ? _startGame : null,
                          child: const Text('Boj'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyrisModeMenu extends StatelessWidget {
  const _MyrisModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _MyrisMode mode;
  final ValueChanged<_MyrisMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_MyrisMode.normal, _MyrisMode.ice, _MyrisMode.freeze];
    final icons = [Icons.auto_awesome, Icons.ac_unit, Icons.grain];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _KaelenModeMenu extends StatelessWidget {
  const _KaelenModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _KaelenMode mode;
  final ValueChanged<_KaelenMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_KaelenMode.normal, _KaelenMode.vine, _KaelenMode.spore];
    final icons = [Icons.auto_awesome, Icons.grass, Icons.cloud];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _SolenneModeMenu extends StatelessWidget {
  const _SolenneModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _SolenneMode mode;
  final ValueChanged<_SolenneMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_SolenneMode.normal, _SolenneMode.sunburst, _SolenneMode.radiant];
    final icons = [Icons.auto_awesome, Icons.wb_sunny, Icons.circle];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _RavikModeMenu extends StatelessWidget {
  const _RavikModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _RavikMode mode;
  final ValueChanged<_RavikMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_RavikMode.normal, _RavikMode.voidburst, _RavikMode.soul];
    final icons = [Icons.auto_awesome, Icons.blur_on, Icons.favorite];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _BrannModeMenu extends StatelessWidget {
  const _BrannModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _BrannMode mode;
  final ValueChanged<_BrannMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_BrannMode.normal, _BrannMode.earthquake, _BrannMode.boulder];
    final icons = [Icons.auto_awesome, Icons.vibration, Icons.circle];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _EldrinModeMenu extends StatelessWidget {
  const _EldrinModeMenu({
    required this.center,
    required this.cardWidth,
    required this.cardHeight,
    required this.t,
    required this.color,
    required this.mode,
    required this.onSelect,
  });

  final Offset center;
  final double cardWidth;
  final double cardHeight;
  final double t;
  final Color color;
  final _EldrinMode mode;
  final ValueChanged<_EldrinMode> onSelect;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) {
      return const SizedBox.shrink();
    }
    const double radius = 18;
    const double spacing = 44;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_EldrinMode.normal, _EldrinMode.cosmic, _EldrinMode.nova];
    final icons = [Icons.auto_awesome, Icons.star, Icons.brightness_5];

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Stack(
        children: List.generate(3, (i) {
          final pos = Offset.lerp(center, targets[i], t) ?? center;
          return Positioned(
            left: pos.dx - radius,
            top: pos.dy - radius,
            child: _ModeCircleButton(
              icon: icons[i],
              selected: mode == modes[i],
              color: color,
              onTap: () => onSelect(modes[i]),
            ),
          );
        }),
      ),
    );
  }
}
