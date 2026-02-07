import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Crystals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Dark Crystals',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const HeroSelectScreen(),
                  ),
                );
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameHomeScreen extends StatelessWidget {
  const GameHomeScreen({super.key, required this.heroes});

  final List<_HeroDef> heroes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameView(heroes: heroes),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, required this.heroes});

  final List<_HeroDef> heroes;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  static const double mapWidth = 1600;
  static const double mapHeight = 640;
  static const double heroAreaWidth = 150;
  static const int heroSlots = 5;
  static const double heroLaneHeight = 80;
  static const double heroCardHeight = 28;
  static const double wallHpMax = 300;
  static const double enemyHpMax = 20;
  static const double enemySize = 40;
  static const double enemySpeed = 16; // units per second
  static const double projectileSpeed = 160; // units per second
  static const double spellCastingDuration = 5; // seconds
  static const double spellSendingDuration = 2; // seconds
  static const double spellCooldownDuration = 10; // seconds
  static const double wallDps = 5; // damage per second
  static const double hitFlashDuration = 0.12; // seconds
  static const double projectileRadius = 2;
  static const double explosionDuration = 0.35; // seconds
  static const double swordRadius = 140;

  final Random _rng = Random();
  late final Ticker _ticker;
  double _lastTime = 0;
  double _wallHp = wallHpMax;
  double _timeUntilNextSpawn = 0;
  late final List<_HeroState> _heroStates;
  late final List<int> _heroSlotIndices;
  bool _gameOver = false;
  double _gameSpeed = 1;
  bool _speedPanelOpen = false;
  _HeroMode _aerinMode = _HeroMode.normal;
  bool _aerinMenuOpen = false;
  late final AnimationController _aerinMenuController;
  _VeyraMode _veyraMode = _VeyraMode.rapid;
  bool _veyraMenuOpen = false;
  late final AnimationController _veyraMenuController;
  _ThalorMode _thalorMode = _ThalorMode.projectile;
  bool _thalorMenuOpen = false;
  late final AnimationController _thalorMenuController;

  final List<_Enemy> _enemies = [];
  final List<_Projectile> _projectiles = [];
  final List<_DamageText> _damageTexts = [];
  final List<_ExplosionEffect> _explosions = [];

  @override
  void initState() {
    super.initState();
    _timeUntilNextSpawn = 4;
    _heroSlotIndices = _resolveHeroSlots(widget.heroes.length);
    _heroStates = List<_HeroState>.generate(
      widget.heroes.length,
      (_) => _HeroState(
        phase: _HeroPhase.casting,
        timeRemaining: spellCastingDuration,
      ),
    );
    _aerinMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _veyraMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _thalorMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _aerinMenuController.dispose();
    _veyraMenuController.dispose();
    _thalorMenuController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  double _nextSpawnDelay() => 1 + _rng.nextDouble() * 9;

  List<int> _resolveHeroSlots(int count) {
    switch (count) {
      case 1:
        return [2];
      case 2:
        return [1, 3];
      case 3:
        return [1, 2, 3];
      case 4:
        return [0, 1, 3, 4];
      case 5:
        return [0, 1, 2, 3, 4];
      default:
        return [];
    }
  }

  Offset _heroPosition(int slotIndex) {
    final y = _laneCenterY(slotIndex);
    return const Offset(heroAreaWidth / 2, 0) + Offset(0, y);
  }

  double _laneCenterY(int slotIndex) {
    final lanesHeight = heroLaneHeight * heroSlots;
    final top = (mapHeight - lanesHeight) / 2;
    return top + heroLaneHeight * (slotIndex + 0.5);
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
    _updateHero(dt);
    _updateEffects(dt);

    if (_wallHp <= 0) {
      _wallHp = 0;
      _gameOver = true;
    }

    setState(() {});
  }

  void _updateSpawning(double dt) {
    _timeUntilNextSpawn -= dt;
    if (_timeUntilNextSpawn <= 0) {
      final lane = _rng.nextInt(heroSlots);
      final y = _laneCenterY(lane);
      _enemies.add(
        _Enemy(
          position: Offset(mapWidth, y),
          hp: enemyHpMax,
        ),
      );
      _timeUntilNextSpawn = _nextSpawnDelay();
    }
  }

  void _updateEnemies(double dt) {
    for (final enemy in _enemies) {
      if (enemy.position.dx > heroAreaWidth + 4) {
        enemy.position = enemy.position.translate(-enemySpeed * dt, 0);
        enemy.attacking = false;
      } else {
        enemy.attacking = true;
        _wallHp -= wallDps * dt;
      }
    }
    _enemies.removeWhere((e) => e.hp <= 0);
  }

  void _updateProjectiles(double dt) {
    for (final proj in _projectiles) {
      proj.position = proj.position.translate(proj.velocity.dx * dt, proj.velocity.dy * dt);
    }

    for (final proj in List<_Projectile>.from(_projectiles)) {
      _Enemy? hit;
      for (final enemy in _enemies) {
        if ((enemy.position - proj.position).distance <= enemySize / 2 + proj.radius) {
          hit = enemy;
          break;
        }
      }
      if (hit != null) {
        if (proj.aoeRadius > 0) {
          for (final enemy in _enemies) {
            if ((enemy.position - hit.position).distance <= proj.aoeRadius) {
              _applyDamage(enemy, proj.damage);
            }
          }
          _explosions.add(_ExplosionEffect(position: hit.position, radius: proj.aoeRadius));
        } else {
          _applyDamage(hit, proj.damage);
        }
        _projectiles.remove(proj);
      } else if (proj.position.dx > mapWidth + 10 || proj.position.dy < -10 || proj.position.dy > mapHeight + 10) {
        _projectiles.remove(proj);
      }
    }
  }

  void _updateHero(double dt) {
    if (_enemies.isEmpty) {
      return;
    }
    for (int i = 0; i < widget.heroes.length; i++) {
      var remaining = dt;
      final state = _heroStates[i];
      while (remaining > 0) {
        if (state.timeRemaining > remaining) {
          state.timeRemaining -= remaining;
          remaining = 0;
        } else {
          remaining -= state.timeRemaining;
          state.timeRemaining = 0;
        }

        if (state.timeRemaining > 0) {
          continue;
        }

        if (state.phase == _HeroPhase.casting) {
          if (_isThalor(i) && _thalorMode == _ThalorMode.sword) {
            if (_hasEnemyInSwordRange(i)) {
              _enterSending(i);
            } else {
              _enterCasting(i);
            }
          } else {
            _enterSending(i);
          }
        } else if (state.phase == _HeroPhase.sending) {
          _enterCooldown(i);
        } else {
          _enterCasting(i);
        }
      }

      if (state.phase == _HeroPhase.sending && widget.heroes[i].attackType == _AttackType.beam) {
        _applyBeamDamage(i, dt);
      }
    }
  }

  void _applyDamage(_Enemy enemy, double damage) {
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
  }

  void _applyBeamDamage(int heroIndex, double dt) {
    final hero = widget.heroes[heroIndex];
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = hero.beamDps * dt;
    if (damage <= 0) {
      return;
    }

    if (_enemies.isEmpty) {
      return;
    }

    _Enemy nearest = _enemies.first;
    double bestDist = (nearest.position - heroPos).distance;
    for (final enemy in _enemies.skip(1)) {
      final d = (enemy.position - heroPos).distance;
      if (d < bestDist) {
        bestDist = d;
        nearest = enemy;
      }
    }

    final dir = nearest.position - heroPos;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;

    for (final enemy in _enemies) {
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
    }

    for (final fx in _explosions) {
      fx.lifeRemaining -= dt;
    }
    _explosions.removeWhere((e) => e.lifeRemaining <= 0);

    for (final text in _damageTexts) {
      text.lifeRemaining -= dt;
      text.position = text.position.translate(0, -text.speed * dt);
    }
    _damageTexts.removeWhere((t) => t.lifeRemaining <= 0);
  }

  void _enterCasting(int heroIndex) {
    _heroStates[heroIndex]
      ..phase = _HeroPhase.casting
      ..timeRemaining = _effectiveCasting(heroIndex);
  }

  void _enterSending(int heroIndex) {
    _heroStates[heroIndex]
      ..phase = _HeroPhase.sending
      ..timeRemaining = _effectiveSending(heroIndex);
    if (widget.heroes[heroIndex].attackType == _AttackType.projectile) {
      if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
        _swordHit(heroIndex);
      } else {
        _fireProjectile(heroIndex);
      }
    }
  }

  void _enterCooldown(int heroIndex) {
    _heroStates[heroIndex]
      ..phase = _HeroPhase.cooldown
      ..timeRemaining = _effectiveCooldown(heroIndex);
  }

  void _fireProjectile(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    Offset target;
    if (_enemies.isEmpty) {
      target = Offset(mapWidth, heroPos.dy);
    } else {
      _Enemy nearest = _enemies.first;
      double bestDist = (nearest.position - heroPos).distance;
      for (final enemy in _enemies.skip(1)) {
        final d = (enemy.position - heroPos).distance;
        if (d < bestDist) {
          bestDist = d;
          nearest = enemy;
        }
      }
      target = nearest.position;
    }

    final dir = (target - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(dir.dx / len * projectileSpeed, dir.dy / len * projectileSpeed);
    final damage = _effectiveDamage(heroIndex);
    final radius = _effectiveProjectileRadius(heroIndex);
    final aoeRadius = _effectiveAoeRadius(heroIndex);
    _projectiles.add(
      _Projectile(
        position: heroPos,
        velocity: velocity,
        damage: damage,
        radius: radius,
        aoeRadius: aoeRadius,
      ),
    );
  }

  bool _isAerin(int heroIndex) => widget.heroes[heroIndex].name == 'Aerin';
  bool _isVeyra(int heroIndex) => widget.heroes[heroIndex].name == 'Veyra';
  bool _isThalor(int heroIndex) => widget.heroes[heroIndex].name == 'Thalor';

  double _effectiveCasting(int heroIndex) {
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return 0.5;
        case _VeyraMode.explosive:
          return 1;
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return 1;
    }
    return spellCastingDuration;
  }

  double _effectiveSending(int heroIndex) {
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return 1;
        case _VeyraMode.explosive:
          return 1;
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return 1;
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
    }
  }

  IconData _thalorModeIcon(_ThalorMode mode) {
    switch (mode) {
      case _ThalorMode.projectile:
        return Icons.auto_awesome;
      case _ThalorMode.sword:
        return Icons.gavel;
    }
  }

  double _effectiveCooldown(int heroIndex) {
    if (_isAerin(heroIndex)) {
      switch (_aerinMode) {
        case _HeroMode.fast:
          return 3;
        case _HeroMode.strong:
          return 20;
        case _HeroMode.normal:
          return widget.heroes[heroIndex].cooldownDuration;
      }
    }
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return 2;
        case _VeyraMode.explosive:
          return 10;
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return 2;
    }
    return widget.heroes[heroIndex].cooldownDuration;
  }

  double _effectiveDamage(int heroIndex) {
    if (_isAerin(heroIndex)) {
      switch (_aerinMode) {
        case _HeroMode.fast:
          return 1;
        case _HeroMode.strong:
          return 20;
        case _HeroMode.normal:
          return widget.heroes[heroIndex].damage;
      }
    }
    if (_isVeyra(heroIndex)) {
      switch (_veyraMode) {
        case _VeyraMode.rapid:
          return 1;
        case _VeyraMode.explosive:
          return 3;
      }
    }
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return 5;
    }
    return widget.heroes[heroIndex].damage;
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
    return projectileRadius;
  }

  double _effectiveAoeRadius(int heroIndex) {
    if (_isVeyra(heroIndex) && _veyraMode == _VeyraMode.explosive) {
      return 60;
    }
    return 0;
  }

  void _swordHit(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if ((enemy.position - heroPos).distance <= swordRadius) {
        _applyDamage(enemy, damage);
      }
    }
  }

  bool _hasEnemyInSwordRange(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    for (final enemy in _enemies) {
      if ((enemy.position - heroPos).distance <= swordRadius) {
        return true;
      }
    }
    return false;
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
    final aerinIndex = widget.heroes.indexWhere((h) => h.name == 'Aerin');
    final hasAerin = aerinIndex != -1;
    final aerinPos = hasAerin ? _heroPosition(_heroSlotIndices[aerinIndex]) : Offset.zero;
    final aerinColor = hasAerin ? widget.heroes[aerinIndex].color : Colors.white;
    final aerinCardWidth = heroAreaWidth - 12;
    final aerinCardRect = Rect.fromCenter(
      center: aerinPos,
      width: aerinCardWidth,
      height: heroCardHeight,
    );
    final veyraIndex = widget.heroes.indexWhere((h) => h.name == 'Veyra');
    final hasVeyra = veyraIndex != -1;
    final veyraPos = hasVeyra ? _heroPosition(_heroSlotIndices[veyraIndex]) : Offset.zero;
    final veyraColor = hasVeyra ? widget.heroes[veyraIndex].color : Colors.white;
    final veyraCardRect = Rect.fromCenter(
      center: veyraPos,
      width: heroAreaWidth - 12,
      height: heroCardHeight,
    );
    final thalorIndex = widget.heroes.indexWhere((h) => h.name == 'Thalor');
    final hasThalor = thalorIndex != -1;
    final thalorPos = hasThalor ? _heroPosition(_heroSlotIndices[thalorIndex]) : Offset.zero;
    final thalorColor = hasThalor ? widget.heroes[thalorIndex].color : Colors.white;
    final thalorCardRect = Rect.fromCenter(
      center: thalorPos,
      width: heroAreaWidth - 12,
      height: heroCardHeight,
    );
    final heroCooldowns = List<double>.generate(
      widget.heroes.length,
      (i) => _effectiveCooldown(i),
    );
    final heroCastings = List<double>.generate(
      widget.heroes.length,
      (i) => _effectiveCasting(i),
    );
    final heroSendings = List<double>.generate(
      widget.heroes.length,
      (i) => _effectiveSending(i),
    );
    return Stack(
      children: [
        Column(
          children: [
            _HpBar(wallHp: _wallHp),
            Expanded(
              child: ClipRect(
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: Stack(
                      children: [
                        CustomPaint(
                          key: ValueKey<_HeroMode>(_aerinMode),
                          size: const Size(mapWidth, mapHeight),
                          painter: _GamePainter(
                            wallHp: _wallHp,
                            enemies: _enemies,
                            projectiles: _projectiles,
                            damageTexts: _damageTexts,
                            explosions: _explosions,
                            heroSlots: heroSlots,
                            heroAreaWidth: heroAreaWidth,
                            heroes: widget.heroes,
                            heroSlotIndices: _heroSlotIndices,
                            heroStates: _heroStates,
                            aerinMode: _aerinMode,
                            thalorMode: _thalorMode,
                            heroCooldowns: heroCooldowns,
                            heroCastings: heroCastings,
                            heroSendings: heroSendings,
                          ),
                        ),
                        if (hasAerin)
                          Positioned(
                            left: aerinCardRect.center.dx - 10,
                            top: aerinCardRect.center.dy - 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _aerinMenuOpen = !_aerinMenuOpen;
                                  if (_aerinMenuOpen) {
                                    _aerinMenuController.forward();
                                  } else {
                                    _aerinMenuController.reverse();
                                  }
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2C29),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Icon(
                                  _aerinModeIcon(_aerinMode),
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (hasVeyra)
                          Positioned(
                            left: veyraCardRect.center.dx - 10,
                            top: veyraCardRect.center.dy - 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _veyraMenuOpen = !_veyraMenuOpen;
                                  if (_veyraMenuOpen) {
                                    _veyraMenuController.forward();
                                  } else {
                                    _veyraMenuController.reverse();
                                  }
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2C29),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Icon(
                                  _veyraModeIcon(_veyraMode),
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (hasThalor)
                          Positioned(
                            left: thalorCardRect.center.dx - 10,
                            top: thalorCardRect.center.dy - 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _thalorMenuOpen = !_thalorMenuOpen;
                                  if (_thalorMenuOpen) {
                                    _thalorMenuController.forward();
                                  } else {
                                    _thalorMenuController.reverse();
                                  }
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2C29),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Icon(
                                  _thalorModeIcon(_thalorMode),
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (hasAerin)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_aerinMenuOpen,
                              child: AnimatedBuilder(
                                animation: _aerinMenuController,
                                builder: (context, _) {
                                  final t = _aerinMenuController.value;
                                  return _AerinModeMenu(
                                    center: aerinPos,
                                    cardWidth: aerinCardWidth,
                                    cardHeight: heroCardHeight,
                                    t: t,
                                    color: aerinColor,
                                    mode: _aerinMode,
                                    onSelect: (mode) {
                                      setState(() {
                                        _aerinMode = mode;
                                        _aerinMenuOpen = false;
                                        _aerinMenuController.reverse();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        if (hasVeyra)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_veyraMenuOpen,
                              child: AnimatedBuilder(
                                animation: _veyraMenuController,
                                builder: (context, _) {
                                  final t = _veyraMenuController.value;
                                  return _VeyraModeMenu(
                                    center: veyraPos,
                                    cardWidth: heroAreaWidth - 12,
                                    cardHeight: heroCardHeight,
                                    t: t,
                                    color: veyraColor,
                                    mode: _veyraMode,
                                    onSelect: (mode) {
                                      setState(() {
                                        _veyraMode = mode;
                                        _veyraMenuOpen = false;
                                        _veyraMenuController.reverse();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        if (hasThalor)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !_thalorMenuOpen,
                              child: AnimatedBuilder(
                                animation: _thalorMenuController,
                                builder: (context, _) {
                                  final t = _thalorMenuController.value;
                                  return _ThalorModeMenu(
                                    center: thalorPos,
                                    cardWidth: heroAreaWidth - 12,
                                    cardHeight: heroCardHeight,
                                    t: t,
                                    color: thalorColor,
                                    mode: _thalorMode,
                                    onSelect: (mode) {
                                      setState(() {
                                        _thalorMode = mode;
                                        _thalorMenuOpen = false;
                                        _thalorMenuController.reverse();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        if (_gameOver)
                          const Center(
                            child: Text(
                              'Game Over',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }
}

class _Enemy {
  _Enemy({required this.position, required this.hp});

  Offset position;
  double hp;
  bool attacking = false;
  double flashRemaining = 0;
  double damageTextCooldown = 0;
  double pendingDamage = 0;
}

class _Projectile {
  _Projectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.radius,
    required this.aoeRadius,
  });

  Offset position;
  Offset velocity;
  double damage;
  double radius;
  double aoeRadius;
}

class _GamePainter extends CustomPainter {
  _GamePainter({
    required this.wallHp,
    required this.enemies,
    required this.projectiles,
    required this.damageTexts,
    required this.explosions,
    required this.heroSlots,
    required this.heroAreaWidth,
    required this.heroes,
    required this.heroSlotIndices,
    required this.heroStates,
    required this.aerinMode,
    required this.thalorMode,
    required this.heroCooldowns,
    required this.heroCastings,
    required this.heroSendings,
  });

  final double wallHp;
  final List<_Enemy> enemies;
  final List<_Projectile> projectiles;
  final List<_DamageText> damageTexts;
  final List<_ExplosionEffect> explosions;
  final int heroSlots;
  final double heroAreaWidth;
  final List<_HeroDef> heroes;
  final List<int> heroSlotIndices;
  final List<_HeroState> heroStates;
  final _HeroMode aerinMode;
  final _ThalorMode thalorMode;
  final List<double> heroCooldowns;
  final List<double> heroCastings;
  final List<double> heroSendings;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0E1412);
    canvas.drawRect(Offset.zero & size, bg);

    final heroArea = Paint()..color = const Color(0xFF172422);
    canvas.drawRect(Rect.fromLTWH(0, 0, heroAreaWidth, size.height), heroArea);

    final slotPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2F4B45)
      ..strokeWidth = 1;
    final slotHeight = _GameViewState.heroLaneHeight;
    final lanesHeight = slotHeight * heroSlots;
    final top = (size.height - lanesHeight) / 2;
    for (int i = 0; i < heroSlots; i++) {
      final rect = Rect.fromLTWH(0, top + slotHeight * i, heroAreaWidth, slotHeight);
      canvas.drawRect(rect, slotPaint);
    }

    for (int i = 0; i < heroes.length; i++) {
      final isCooldown = heroStates[i].phase == _HeroPhase.cooldown;
      final heroColor = isCooldown ? Colors.grey.shade500 : heroes[i].color;
      final slotIndex = heroSlotIndices[i];
      final heroPos = Offset(heroAreaWidth / 2, top + slotHeight * (slotIndex + 0.5));
      _drawHeroCard(canvas, heroes[i].name, heroPos, heroColor);

      final phase = heroStates[i].phase;
      final remaining = heroStates[i].timeRemaining;
      final castingValue = phase == _HeroPhase.casting
          ? (remaining / heroCastings[i])
          : phase == _HeroPhase.sending
              ? 0.0
              : 0.0;
      final sendingValue = phase == _HeroPhase.casting
          ? 1.0
          : phase == _HeroPhase.sending
              ? (remaining / heroSendings[i])
              : 0.0;
      final cooldownValue = phase == _HeroPhase.cooldown
          ? (remaining / heroCooldowns[i])
          : 1.0;

      _drawPhaseBars(
        canvas,
        heroPos,
        castingValue.clamp(0.0, 1.0),
        sendingValue.clamp(0.0, 1.0),
        cooldownValue.clamp(0.0, 1.0),
      );

      if (heroStates[i].phase == _HeroPhase.sending && heroes[i].attackType == _AttackType.beam) {
        if (enemies.isNotEmpty) {
          _Enemy nearest = enemies.first;
          double bestDist = (nearest.position - heroPos).distance;
          for (final enemy in enemies.skip(1)) {
            final d = (enemy.position - heroPos).distance;
            if (d < bestDist) {
              bestDist = d;
              nearest = enemy;
            }
          }
          final dir = nearest.position - heroPos;
          final len = max(dir.distance, 0.001);
          final end = heroPos + Offset(dir.dx / len * size.width, dir.dy / len * size.width);
          final beamPaint = Paint()
            ..color = heroes[i].color.withOpacity(0.8)
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(heroPos, end, beamPaint);
        }
      }

      if (heroes[i].name == 'Thalor' &&
          thalorMode == _ThalorMode.sword &&
          heroStates[i].phase == _HeroPhase.sending) {
        _drawSwordSwing(canvas, heroPos, enemies, heroSendings[i], heroStates[i].timeRemaining);
      }
    }

    final wall = Paint()..color = const Color(0xFF8B7D5A);
    canvas.drawRect(Rect.fromLTWH(heroAreaWidth, 0, 4, size.height), wall);

    final wallHpPaint = Paint()
      ..color = const Color(0xFF6BFA9D)
      ..style = PaintingStyle.fill;
    final hpRatio = (wallHp / _GameViewState.wallHpMax).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(heroAreaWidth + 2, 0, 2, size.height * hpRatio), wallHpPaint);

    final enemyPaint = Paint()..color = const Color(0xFFE06A5E);
    final enemyHitPaint = Paint()..color = Colors.white;
    final enemyHpBack = Paint()..color = const Color(0xFF2A2A2A);
    final enemyHpFill = Paint()..color = const Color(0xFF6BFA9D);
    for (final enemy in enemies) {
      final paint = enemy.flashRemaining > 0 ? enemyHitPaint : enemyPaint;
      final rect = Rect.fromCenter(
        center: enemy.position,
        width: _GameViewState.enemySize,
        height: _GameViewState.enemySize,
      );
      canvas.drawRect(rect, paint);

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
      canvas.drawCircle(p.position, p.radius, projPaint);
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
      final paint = Paint()
        ..color = Colors.orangeAccent.withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(boom.position, boom.radius * (1 - alpha * 0.3), paint);
    }

  }

  void _drawPhaseBars(
    Canvas canvas,
    Offset heroPos,
    double casting,
    double sending,
    double cooldown,
  ) {
    const double barWidth = 18;
    const double barHeight = 2;
    const double gap = 2;
    final totalHeight = barHeight * 3 + gap * 2;
    final left = heroAreaWidth - barWidth - 4;
    final top = heroPos.dy - totalHeight / 2;

    final bg = Paint()..color = const Color(0xFF1F2C29);
    final castingPaint = Paint()..color = const Color(0xFF64B5F6);
    final sendingPaint = Paint()..color = const Color(0xFFFFD54F);
    final cooldownPaint = Paint()..color = const Color(0xFFB0BEC5);

    void drawBar(double y, double value, Paint fill) {
      final back = Rect.fromLTWH(left, y, barWidth, barHeight);
      final fillRect = Rect.fromLTWH(left, y, barWidth * value, barHeight);
      canvas.drawRect(back, bg);
      canvas.drawRect(fillRect, fill);
    }

    drawBar(top, casting, castingPaint);
    drawBar(top + barHeight + gap, sending, sendingPaint);
    drawBar(top + (barHeight + gap) * 2, cooldown, cooldownPaint);
  }

  void _drawSwordSwing(
    Canvas canvas,
    Offset heroPos,
    List<_Enemy> enemies,
    double sendingDuration,
    double remaining,
  ) {
    if (enemies.isEmpty) {
      return;
    }
    _Enemy nearest = enemies.first;
    double bestDist = (nearest.position - heroPos).distance;
    for (final enemy in enemies.skip(1)) {
      final d = (enemy.position - heroPos).distance;
      if (d < bestDist) {
        bestDist = d;
        nearest = enemy;
      }
    }

    final dir = nearest.position - heroPos;
    final len = max(dir.distance, 0.001);
    final ux = dir.dx / len;
    final uy = dir.dy / len;

    final progress = (1 - (remaining / sendingDuration)).clamp(0.0, 1.0);
    final swing = sin(progress * pi * 2); // up -> down -> up
    final swingOffset = Offset(-uy, ux) * (swing * 18);
    final end = heroPos + Offset(ux, uy) * _GameViewState.swordRadius + swingOffset;

    final paint = Paint()
      ..color = const Color(0xFFEFE2C6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(heroPos, end, paint);
  }

  void _drawHeroCard(Canvas canvas, String name, Offset heroPos, Color color) {
    final double cardWidth = heroAreaWidth - 12;
    final rect = Rect.fromCenter(
      center: heroPos,
      width: cardWidth,
      height: _GameViewState.heroCardHeight,
    );
    final cardPaint = Paint()..color = color.withOpacity(0.9);
    final borderPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, cardPaint);
    canvas.drawRRect(rrect, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: cardWidth - 26);
    final offset = Offset(rect.left + 8, heroPos.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
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
  bool shouldRepaint(covariant _GamePainter oldDelegate) {
    return true;
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({required this.wallHp});

  final double wallHp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2C29), width: 1),
        ),
      ),
      child: Text(
        'Wall HP: ${wallHp.toStringAsFixed(0)}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

enum _HeroPhase { casting, sending, cooldown }
enum _AttackType { projectile, beam }
enum _HeroMode { normal, fast, strong }
enum _VeyraMode { rapid, explosive }
enum _ThalorMode { projectile, sword }

class _HeroState {
  _HeroState({required this.phase, required this.timeRemaining});

  _HeroPhase phase;
  double timeRemaining;
}

class _HeroDef {
  const _HeroDef(
    this.name,
    this.color, {
    this.cooldownDuration = _GameViewState.spellCooldownDuration,
    this.damage = 5.0,
    this.attackType = _AttackType.projectile,
    this.beamDps = 2.0,
  });

  final String name;
  final Color color;
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
  _ExplosionEffect({required this.position, required this.radius});

  final Offset position;
  final double radius;
  double lifeRemaining = _GameViewState.explosionDuration;
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
    const double radius = 12;
    const double spacing = 30;
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
    const double radius = 12;
    const double spacing = 22;
    final endY = center.dy + cardHeight / 2 + 16;
    final targets = [
      Offset(center.dx - spacing, endY),
      Offset(center.dx + spacing, endY),
    ];
    final modes = [_VeyraMode.rapid, _VeyraMode.explosive];
    final icons = [Icons.flash_on, Icons.whatshot];

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
    const double radius = 12;
    const double spacing = 22;
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
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFF1F2C29),
          shape: BoxShape.circle,
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
          size: 14,
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

  final List<_HeroDef> _heroes = const [
    _HeroDef('Aerin', Color(0xFFE57373)),
    _HeroDef('Veyra', Color(0xFFBA68C8), cooldownDuration: 5, damage: 2.5),
    _HeroDef('Thalor', Color(0xFF64B5F6)),
    _HeroDef('Myris', Color(0xFF4DB6AC)),
    _HeroDef('Kaelen', Color(0xFF81C784)),
    _HeroDef('Solenne', Color(0xFFFFD54F), attackType: _AttackType.beam, beamDps: 2.0),
    _HeroDef('Ravik', Color(0xFFFF8A65)),
    _HeroDef('Brann', Color(0xFFA1887F)),
    _HeroDef('Nyxra', Color(0xFF90A4AE)),
    _HeroDef('Eldrin', Color(0xFF9575CD)),
  ];

  late final List<_HeroDef?> _slots = List<_HeroDef?>.filled(slotCount, null);

  void _assignHero(_HeroDef hero) {
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
    final selected = _slots.whereType<_HeroDef>().toList();
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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _heroes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final hero = _heroes[index];
                  final isSelected = _slots.contains(hero);
                  return GestureDetector(
                    onTap: isSelected ? null : () => _assignHero(hero),
                    child: Container(
                      width: 144,
                      height: 144,
                      decoration: BoxDecoration(
                        color: (isSelected ? Colors.grey : hero.color).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hero.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF101816),
                border: Border(
                  top: BorderSide(color: Color(0xFF1F2C29), width: 1),
                ),
              ),
              child: Column(
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
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: hasSelection ? _startGame : null,
                      child: const Text('Boj'),
                    ),
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
