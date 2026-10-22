import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'level_data.dart';
import 'level_editor_screen.dart';
import 'level_repository.dart';
import 'rpg_system.dart';
import 'hero_upgrade_screen.dart';
import 'sound_manager.dart';
import 'skill_trees.dart';
import 'localization.dart';
import 'language_manager.dart';
import 'language_switcher.dart';
import 'rumble_hero_progress.dart';
import 'building_navigation.dart';
import 'unit_spacing.dart';
import 'pixel_ui.dart';

Future<void> _enableFullscreenMode() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageManager.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await _enableFullscreenMode();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LanguageManager.languageNotifier.addListener(_onLanguageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enableFullscreenMode();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LanguageManager.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableFullscreenMode();
    }
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Crystals',
      debugShowCheckedModeBanner: false,
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
      backgroundColor: const Color(0xFF15100E),
      body: PixelMenuBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 380;
              final titleSize = compact ? 44.0 : 64.0;
              final crystalHeight = compact ? 110.0 : 160.0;
              return Stack(
                children: [
                  // Language switcher at top right, in a small stone frame
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CustomPaint(
                      painter: const PixelFramePainter(fill: PixelFill.stone),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: LanguageSwitcher(),
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: crystalHeight * 0.7,
                                height: crystalHeight,
                                child: const CustomPaint(
                                  painter: PixelCrystalPainter(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: crystalHeight * 0.18),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      loc.appName,
                                      textAlign: TextAlign.center,
                                      style: pixelTextStyle(fontSize: titleSize),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: crystalHeight * 0.7,
                                height: crystalHeight,
                                child: const CustomPaint(
                                  painter: PixelCrystalPainter(mirrored: true),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 6 : 10),
                          const SizedBox(
                            width: 360,
                            height: 30,
                            child: CustomPaint(painter: PixelOrnamentPainter()),
                          ),
                          SizedBox(height: compact ? 14 : 26),
                          SizedBox(
                            width: 320,
                            child: PixelButton(
                              label: '${loc.playButton}!',
                              height: compact ? 58 : 68,
                              fontSize: compact ? 26 : 32,
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const SaveSlotScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          SizedBox(
                            width: 250,
                            child: PixelButton(
                              label: loc.heroesButton,
                              fill: PixelFill.stone,
                              gems: false,
                              height: compact ? 46 : 52,
                              fontSize: compact ? 20 : 22,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const HeroUpgradeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
      MaterialPageRoute<void>(builder: (_) => const VillageScreen()),
    );
  }

  void _goBackToIntro() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const IntroScreen()),
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToIntro();
        }
      },
      child: Scaffold(
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
                        color: isActive
                            ? const Color(0xFF6BFA9D)
                            : const Color(0xFF2F4B45),
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
                onPressed: _goBackToIntro,
                child: const Text('Zpet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VillageScreen extends StatefulWidget {
  const VillageScreen({super.key});

  @override
  State<VillageScreen> createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  static const String _villageBackgroundAsset =
      'assets/backgrounds/village_basic.png';
  static const String _heroesAtriumAsset = 'assets/buildings/heroesAtrium.png';
  static const String _shamanTentAsset = 'assets/buildings/shamanTent.png';
  static const String _villageTowerAsset = 'assets/buildings/tower.png';
  static const String _villageAtriumAsset = 'assets/buildings/atrium.png';
  static const String _explorerTentAsset = 'assets/buildings/explorerTent.png';
  static const double _villageMaxZoomMultiplier = 3.0;
  static const double _villageWheelZoomStep = 0.12;
  static const double _villageLogicalMapWidth = 1500.0;
  static const double _villageLogicalMapHeight = 980.0;
  final TransformationController _villageMapController =
      TransformationController();
  Size? _villageConfiguredViewportSize;
  Size? _villageConfiguredContentSize;
  int _villageCoins = 0;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
    _loadVillageCoins();
  }

  void _goBackToSaveSlots() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SaveSlotScreen()),
    );
  }

  Future<void> _loadVillageCoins() async {
    final progress = await RpgSystem.getProgress();
    if (!mounted) {
      return;
    }
    setState(() {
      _villageCoins = progress.coins;
    });
  }

  Future<void> _openHeroes() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HeroUpgradeScreen()));
    await _loadVillageCoins();
  }

  void _openDefenseFlow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HeroSelectScreen()),
    );
  }

  void _openExplorationFlow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ExplorationChapterSelectScreen(),
      ),
    );
  }

  void _openGathering() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GameHomeScreen(isGathering: true),
      ),
    );
  }

  void _openRumble() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ChapterSelectScreen(heroes: [], isRumble: true),
      ),
    );
  }

  void _showPlaceholderMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tato cast vesnice zatim neni dostupna.')),
    );
  }

  void _configureVillageMapViewport({
    required Size viewportSize,
    required Size contentSize,
    bool force = false,
  }) {
    final sameViewport = _villageConfiguredViewportSize == viewportSize;
    final sameContent = _villageConfiguredContentSize == contentSize;
    if (!force && sameViewport && sameContent) {
      return;
    }
    _villageConfiguredViewportSize = viewportSize;
    _villageConfiguredContentSize = contentSize;
    final fitScale = _villageFitScale(viewportSize, contentSize);
    final defaultOffset = _defaultVillageOffset(
      viewportSize: viewportSize,
      contentSize: contentSize,
      scale: fitScale,
    );
    final matrix = Matrix4.identity()..scale(fitScale);
    matrix.setTranslationRaw(defaultOffset.dx, defaultOffset.dy, 0);
    _villageMapController.value = matrix;
  }

  double _villageFitScale(Size viewportSize, Size contentSize) {
    return viewportSize.width / contentSize.width;
  }

  Offset _defaultVillageOffset({
    required Size viewportSize,
    required Size contentSize,
    required double scale,
  }) {
    final scaledHeight = contentSize.height * scale;
    return Offset(
      0,
      scaledHeight <= viewportSize.height
          ? (viewportSize.height - scaledHeight) / 2
          : 0,
    );
  }

  Offset _clampVillageOffset({
    required Offset offset,
    required Size viewportSize,
    required Size contentSize,
    required double scale,
  }) {
    final scaledWidth = contentSize.width * scale;
    final scaledHeight = contentSize.height * scale;
    final defaultOffset = _defaultVillageOffset(
      viewportSize: viewportSize,
      contentSize: contentSize,
      scale: scale,
    );
    final minDx = min(defaultOffset.dx, viewportSize.width - scaledWidth);
    final maxDx = max(defaultOffset.dx, 0.0);
    final minDy = min(defaultOffset.dy, viewportSize.height - scaledHeight);
    final maxDy = max(defaultOffset.dy, 0.0);
    return Offset(offset.dx.clamp(minDx, maxDx), offset.dy.clamp(minDy, maxDy));
  }

  void _setVillageZoomAroundViewportPoint({
    required double nextScale,
    required Offset viewportPoint,
    required Size viewportSize,
    required Size contentSize,
    required double minScale,
    required double maxScale,
  }) {
    final clampedScale = nextScale.clamp(minScale, maxScale).toDouble();
    final currentScale = _villageMapController.value.getMaxScaleOnAxis();
    if ((clampedScale - currentScale).abs() < 0.0001) {
      return;
    }
    final anchorScenePosition = _villageMapController.toScene(viewportPoint);
    final unclampedOffset = Offset(
      viewportPoint.dx - anchorScenePosition.dx * clampedScale,
      viewportPoint.dy - anchorScenePosition.dy * clampedScale,
    );
    final clampedOffset = _clampVillageOffset(
      offset: unclampedOffset,
      viewportSize: viewportSize,
      contentSize: contentSize,
      scale: clampedScale,
    );
    final matrix = Matrix4.identity()..scale(clampedScale);
    matrix.setTranslationRaw(clampedOffset.dx, clampedOffset.dy, 0);
    _villageMapController.value = matrix;
  }

  @override
  void dispose() {
    _villageMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToSaveSlots();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxHeight < 520 || constraints.maxWidth < 820;
            const mapWidth = _villageLogicalMapWidth;
            const mapHeight = _villageLogicalMapHeight;
            final contentPadding = compact ? 18.0 : 24.0;
            final heroesBuildingWidth = mapWidth * (544.0 / 1500.0);
            final defenseBuildingWidth = mapWidth * (230.0 / 1500.0);
            final shamanBuildingWidth = mapWidth * (448.0 / 1500.0);
            final managementBuildingWidth = mapWidth * (448.0 / 1500.0);
            final explorationBuildingWidth = mapWidth * (432.0 / 1500.0);
            final viewportSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final contentSize = Size(mapWidth, mapHeight);
            final minScale = _villageFitScale(viewportSize, contentSize);
            final maxScale = minScale * _villageMaxZoomMultiplier;
            _configureVillageMapViewport(
              viewportSize: viewportSize,
              contentSize: contentSize,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: Listener(
                    onPointerSignal: (event) {
                      if (event is! PointerScrollEvent ||
                          event.kind != ui.PointerDeviceKind.mouse) {
                        return;
                      }
                      final currentScale = _villageMapController.value
                          .getMaxScaleOnAxis();
                      final nextScale =
                          currentScale +
                          (event.scrollDelta.dy < 0
                              ? _villageWheelZoomStep
                              : -_villageWheelZoomStep);
                      _setVillageZoomAroundViewportPoint(
                        nextScale: nextScale,
                        viewportPoint: event.localPosition,
                        viewportSize: viewportSize,
                        contentSize: contentSize,
                        minScale: minScale,
                        maxScale: maxScale,
                      );
                    },
                    child: InteractiveViewer(
                      transformationController: _villageMapController,
                      panEnabled: true,
                      scaleEnabled: true,
                      constrained: false,
                      alignment: Alignment.topLeft,
                      boundaryMargin: EdgeInsets.zero,
                      minScale: minScale,
                      maxScale: maxScale,
                      child: SizedBox(
                        width: mapWidth,
                        height: mapHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                _villageBackgroundAsset,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x55101713),
                                      Color(0x99101713),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: contentPadding,
                              top: contentPadding,
                              child: OutlinedButton(
                                onPressed: _goBackToSaveSlots,
                                child: const Text('Zpet'),
                              ),
                            ),
                            Positioned(
                              left: mapWidth * 0.16,
                              top: mapHeight * 0.01,
                              child: _VillageMapBuilding(
                                label: 'Pruzkum',
                                assetPath: _explorerTentAsset,
                                width: explorationBuildingWidth,
                                mirrorHorizontally: true,
                                onTap: _openExplorationFlow,
                              ),
                            ),
                            Positioned(
                              left: mapWidth * 0.37 - heroesBuildingWidth / 2,
                              top: mapHeight * 0.39,
                              child: _VillageMapBuilding(
                                label: 'Hrdinove',
                                assetPath: _heroesAtriumAsset,
                                width: heroesBuildingWidth,
                                onTap: _openHeroes,
                              ),
                            ),
                            Positioned(
                              left: mapWidth * 0.45,
                              top: mapHeight * -0.15,
                              child: _VillageMapBuilding(
                                label: 'Samanova chyse',
                                assetPath: _shamanTentAsset,
                                width: shamanBuildingWidth,
                                onTap: _openRumble,
                              ),
                            ),
                            Positioned(
                              left: mapWidth * 0.52,
                              top: mapHeight * 0.40,
                              child: _VillageMapBuilding(
                                label: 'Management vesnice',
                                assetPath: _villageAtriumAsset,
                                width: managementBuildingWidth,
                                onTap: _openGathering,
                              ),
                            ),
                            Positioned(
                              left: mapWidth * 0.68,
                              top: mapHeight * 0.04,
                              child: _VillageMapBuilding(
                                label: 'Branit vesnici',
                                assetPath: _villageTowerAsset,
                                width: defenseBuildingWidth,
                                onTap: _openDefenseFlow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: contentPadding,
                  top: contentPadding,
                  child: IgnorePointer(
                    child: _VillageCoinsBadge(coins: _villageCoins),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VillageMenuButton extends StatelessWidget {
  const _VillageMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.58), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VillageCoinsBadge extends StatelessWidget {
  const _VillageCoinsBadge({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC101816),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55F2C14E)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFF2C14E),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              coins.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VillageMapBuilding extends StatelessWidget {
  const _VillageMapBuilding({
    required this.label,
    required this.assetPath,
    required this.width,
    required this.onTap,
    this.mirrorHorizontally = false,
  });

  final String label;
  final String assetPath;
  final double width;
  final VoidCallback onTap;
  final bool mirrorHorizontally;

  @override
  Widget build(BuildContext context) {
    final shadowWidth = width * 0.8;
    final shadowHeight = width * 0.19;
    final shadowBottom = width * 0.1;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: shadowBottom,
                child: IgnorePointer(
                  child: Container(
                    width: shadowWidth,
                    height: shadowHeight,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.26),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  mirrorHorizontally ? -1.0 : 1.0,
                  1.0,
                  1.0,
                ),
                child: Image.asset(
                  assetPath,
                  width: width,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChapterSelectScreen extends StatefulWidget {
  const ChapterSelectScreen({
    super.key,
    required this.heroes,
    this.isRumble = false,
  });

  final List<HeroDef> heroes;
  final bool isRumble;

  @override
  State<ChapterSelectScreen> createState() => _ChapterSelectScreenState();
}

class ExplorationChapterSelectScreen extends StatefulWidget {
  const ExplorationChapterSelectScreen({super.key});

  @override
  State<ExplorationChapterSelectScreen> createState() =>
      _ExplorationChapterSelectScreenState();
}

class _ExplorationChapterSelectScreenState
    extends State<ExplorationChapterSelectScreen> {
  static const List<_ChapterChoice> _chapters = [
    _ChapterChoice(
      number: 1,
      title: 'Kapitola I',
      subtitle: 'Pruzkum pohranici',
      unlocked: true,
    ),
    _ChapterChoice(
      number: 2,
      title: 'Kapitola II',
      subtitle: 'Pruzkum hlubin',
      unlocked: true,
    ),
  ];

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
    _pageController = PageController(viewportFraction: 0.42);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goBackToVillage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const VillageScreen()),
    );
  }

  Future<void> _goToChapter(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectCurrentChapter() {
    final chapter = _chapters[_currentIndex];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExplorationLevelSelectScreen(
          chapterNumber: chapter.number,
          chapterTitle: chapter.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _chapters[_currentIndex];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToVillage();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070909),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactCards =
                  constraints.maxWidth < 760 || constraints.maxHeight < 520;
              final carouselHeight = compactCards ? 280.0 : 320.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Pruzkum Kapitol',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Vyber kapitolu a pokracuj do nabidky lokaci.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: compactCards ? 16 : 24),
                        SizedBox(
                          height: carouselHeight,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compactCards ? 34 : 44,
                                ),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _chapters.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final item = _chapters[index];
                                    final isActive = index == _currentIndex;
                                    return AnimatedPadding(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compactCards ? 8 : 12,
                                        vertical: isActive
                                            ? 0
                                            : (compactCards ? 8 : 16),
                                      ),
                                      child: _SelectionCard(
                                        title: item.title,
                                        subtitle: item.subtitle,
                                        icon: Icons.explore_rounded,
                                        accentColor: const Color(0xFF64B5F6),
                                        compact: compactCards,
                                        buttonLabel: 'Vybrat kapitolu',
                                        onPressed: isActive
                                            ? _selectCurrentChapter
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (_currentIndex > 0)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: IconButton.filledTonal(
                                      onPressed: () =>
                                          _goToChapter(_currentIndex - 1),
                                      iconSize: 32,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                              if (_currentIndex < _chapters.length - 1)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: IconButton.filledTonal(
                                      onPressed: () =>
                                          _goToChapter(_currentIndex + 1),
                                      iconSize: 32,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _goBackToVillage,
                                child: const Text('Zpet'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: _selectCurrentChapter,
                                child: Text('Pokracovat do ${chapter.title}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ExplorationLevelSelectScreen extends StatefulWidget {
  const ExplorationLevelSelectScreen({
    super.key,
    required this.chapterNumber,
    required this.chapterTitle,
  });

  final int chapterNumber;
  final String chapterTitle;

  @override
  State<ExplorationLevelSelectScreen> createState() =>
      _ExplorationLevelSelectScreenState();
}

class _ExplorationLevelSelectScreenState
    extends State<ExplorationLevelSelectScreen> {
  static const int _levelCount = 2;

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
    _pageController = PageController(viewportFraction: 0.42);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goBackToChapters() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ExplorationChapterSelectScreen(),
      ),
    );
  }

  Future<void> _goToLevel(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openSelectedLocation() async {
    final levelNumber = _currentIndex + 1;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pruzkum'),
          content: Text(
            'Kapitola ${widget.chapterNumber}, lokace $levelNumber je pripravena v nabidce. Samotny gameplay pruzkumu doplnime pozdeji.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Zavrit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelNumber = _currentIndex + 1;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToChapters();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070909),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactCards =
                  constraints.maxWidth < 760 || constraints.maxHeight < 520;
              final carouselHeight = compactCards ? 280.0 : 320.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.chapterTitle}  Lokace $levelNumber',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Vyber lokaci pro pruzkum. Zatim je pripraveny jen navigacni placeholder flow.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: compactCards ? 16 : 24),
                        SizedBox(
                          height: carouselHeight,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compactCards ? 34 : 44,
                                ),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _levelCount,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final currentLevel = index + 1;
                                    final isActive = index == _currentIndex;
                                    return AnimatedPadding(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compactCards ? 8 : 12,
                                        vertical: isActive
                                            ? 0
                                            : (compactCards ? 8 : 16),
                                      ),
                                      child: _SelectionCard(
                                        title: 'Lokace $currentLevel',
                                        subtitle: currentLevel == 1
                                            ? 'Prvni misto k prozkoumani'
                                            : 'Druhe misto k prozkoumani',
                                        icon: Icons.travel_explore_rounded,
                                        accentColor: const Color(0xFF64B5F6),
                                        compact: compactCards,
                                        buttonLabel: 'Otevrit lokaci',
                                        onPressed: isActive
                                            ? _openSelectedLocation
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (_currentIndex > 0)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: IconButton.filledTonal(
                                      onPressed: () =>
                                          _goToLevel(_currentIndex - 1),
                                      iconSize: 32,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                              if (_currentIndex < _levelCount - 1)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: IconButton.filledTonal(
                                      onPressed: () =>
                                          _goToLevel(_currentIndex + 1),
                                      iconSize: 32,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _goBackToChapters,
                                child: const Text('Zpet'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: _openSelectedLocation,
                                child: const Text('Pokracovat'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChapterSelectScreenState extends State<ChapterSelectScreen> {
  static const List<_ChapterChoice> _chapters = _ChapterChoice.all;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
  }

  void _goBackToHeroSelect() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.isRumble ? const VillageScreen() : HeroSelectScreen(
          initialSelection: widget.heroes,
          isRumble: widget.isRumble,
        ),
      ),
    );
  }

  void _selectCurrentChapter() {
    final chapter = _chapters[_currentIndex];
    if (!chapter.unlocked) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LevelSelectScreen(
          heroes: widget.heroes,
          chapterNumber: chapter.number,
          isRumble: widget.isRumble,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _chapters[_currentIndex];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToHeroSelect();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF15100E),
        body: PixelMenuBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 380;
                return Padding(
                  padding: EdgeInsets.all(compact ? 8 : 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: PixelButton(
                              label: 'Zpět',
                              icon: Icons.chevron_left,
                              fill: PixelFill.stone,
                              gems: false,
                              height: 44,
                              fontSize: 18,
                              onPressed: _goBackToHeroSelect,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: PixelTitleBanner(
                                title: 'Vyber kapitolu',
                                fontSize: compact ? 20 : 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 110),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var index = 0; index < _chapters.length; index++) ...[
                              if (index > 0) SizedBox(width: compact ? 12 : 20),
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 300),
                                  child: _buildChapterCard(index, compact),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      SizedBox(
                        width: 300,
                        child: PixelButton(
                          label: chapter.unlocked ? 'Pokračovat' : 'Zamčeno',
                          icon: chapter.unlocked ? null : Icons.lock,
                          height: compact ? 50 : 60,
                          fontSize: compact ? 22 : 26,
                          onPressed: chapter.unlocked ? _selectCurrentChapter : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(int index, bool compact) {
    final item = _chapters[index];
    final selected = index == _currentIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: '${item.title}, ${item.subtitle}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        onDoubleTap: () {
          setState(() => _currentIndex = index);
          _selectCurrentChapter();
        },
        child: PixelPanel(
          fill: item.unlocked ? PixelFill.stone : PixelFill.grey,
          highlighted: selected,
          padding: EdgeInsets.all(compact ? 4 : 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = min(constraints.maxWidth * 0.6,
                        constraints.maxHeight / 1.15);
                    return Center(
                      child: SizedBox(
                        width: width,
                        height: width * 1.15,
                        child: CustomPaint(
                          painter: PixelShieldPainter(
                            fill: item.unlocked ? PixelFill.ruby : PixelFill.grey,
                            selected: selected && item.unlocked,
                            dimmed: !item.unlocked,
                          ),
                          child: Align(
                            alignment: const Alignment(0, -0.2),
                            child: item.unlocked
                                ? Text(
                                    item.roman,
                                    style: pixelTextStyle(fontSize: width * 0.3),
                                  )
                                : Icon(
                                    Icons.lock,
                                    size: width * 0.32,
                                    color: const Color(0xFFCFC9C2),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: compact ? 4 : 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: pixelTextStyle(fontSize: compact ? 18 : 22),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: pixelTextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  color: item.unlocked
                      ? const Color(0xFFD9C8B4)
                      : const Color(0xFFA8A29C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    required this.heroes,
    required this.chapterNumber,
    this.isRumble = false,
  });

  final List<HeroDef> heroes;
  final int chapterNumber;
  final bool isRumble;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  static const int _levelCount = 19;

  int _currentIndex = 0;
  PlayerProgress? _progress;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await RpgSystem.getProgress();
    if (!mounted) {
      return;
    }
    setState(() {
      _progress = progress;
    });
  }

  bool _isLevelCompleted(int levelNumber) {
    return _progress?.isLevelCompleted(widget.chapterNumber, levelNumber) ??
        false;
  }

  void _selectLevel(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _startSelectedLevel() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _selectedLevelScreen(),
      ),
    );
  }

  Widget _selectedLevelScreen() {
    if (widget.isRumble &&
        !_isRumbleAerinTutorial(widget.isRumble, widget.chapterNumber, _currentIndex + 1) &&
        !_isRumbleTutorial(widget.isRumble, widget.chapterNumber, _currentIndex + 1)) {
      return HeroSelectScreen(
        initialSelection: widget.heroes,
        isRumble: true,
        chapterNumber: widget.chapterNumber,
        levelNumber: _currentIndex + 1,
      );
    }
    return GameHomeScreen(
          heroes: widget.heroes,
          chapterNumber: widget.chapterNumber,
          levelNumber: _currentIndex + 1,
          isRumble: widget.isRumble,
    );
  }

  void _openLevelEditor() {
    final levelNumber = _currentIndex + 1;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LevelEditorScreen(
          chapterNumber: widget.chapterNumber,
          levelNumber: levelNumber,
          onPreviewLevel: (editorContext) async {
            Navigator.of(editorContext).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => _selectedLevelScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _goBackFromLevelSelect() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const VillageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _ChapterChoice.byNumber(widget.chapterNumber);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackFromLevelSelect();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF15100E),
        body: PixelMenuBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 380;
                final detailWidth = min(260.0, constraints.maxWidth * 0.32);
                return Padding(
                  padding: EdgeInsets.all(compact ? 8 : 14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            child: PixelButton(
                              label: 'Zpět',
                              icon: Icons.chevron_left,
                              fill: PixelFill.stone,
                              gems: false,
                              height: 44,
                              fontSize: 18,
                              onPressed: _goBackFromLevelSelect,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: PixelTitleBanner(
                                title: chapter.title,
                                subtitle: chapter.subtitle,
                                fontSize: compact ? 20 : 26,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: PixelButton(
                              label: 'Editor',
                              fill: PixelFill.stone,
                              gems: false,
                              height: 44,
                              fontSize: 18,
                              onPressed: _openLevelEditor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: PixelPanel(
                                padding: const EdgeInsets.all(6),
                                child: _buildShieldGrid(),
                              ),
                            ),
                            SizedBox(width: compact ? 8 : 12),
                            SizedBox(
                              width: detailWidth,
                              child: _buildLevelDetail(compact),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Pick the column count that gives the biggest shields.
        var bestColumns = 5;
        var bestWidth = 0.0;
        for (var columns = 4; columns <= 10; columns++) {
          final rows = (_levelCount / columns).ceil();
          final width = min(
            constraints.maxWidth / columns,
            constraints.maxHeight / rows / 1.15,
          );
          if (width > bestWidth) {
            bestWidth = width;
            bestColumns = columns;
          }
        }
        final cellWidth = constraints.maxWidth / bestColumns;
        final rows = (_levelCount / bestColumns).ceil();
        final cellHeight = constraints.maxHeight / rows;
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var index = 0; index < _levelCount; index++)
              SizedBox(
                width: cellWidth,
                height: cellHeight,
                child: _buildShield(index, bestWidth * 0.92),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShield(int index, double width) {
    final levelNumber = index + 1;
    final selected = index == _currentIndex;
    final completed = _isLevelCompleted(levelNumber);
    final height = width * 1.15;
    return Center(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Level $levelNumber${completed ? ', dokončeno' : ''}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectLevel(index),
          onDoubleTap: () {
            _selectLevel(index);
            _startSelectedLevel();
          },
          child: AnimatedScale(
            scale: selected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 140),
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: PixelShieldPainter(
                  fill: completed ? PixelFill.emerald : PixelFill.ruby,
                  selected: selected,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.2),
                      child: Text(
                        '$levelNumber',
                        style: pixelTextStyle(fontSize: width * 0.34),
                      ),
                    ),
                    if (completed)
                      Align(
                        alignment: const Alignment(0, 0.55),
                        child: Icon(
                          Icons.star,
                          size: width * 0.22,
                          color: PixelPalette.goldLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDetail(bool compact) {
    final levelNumber = _currentIndex + 1;
    final hpBonusPercent = ((pow(1.2, _currentIndex) - 1) * 100).round();
    final completed = _isLevelCompleted(levelNumber);
    final labelStyle = pixelTextStyle(
      fontSize: compact ? 13 : 15,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFD9C8B4),
    );
    final valueStyle = pixelTextStyle(fontSize: compact ? 16 : 19);
    return PixelPanel(
      padding: EdgeInsets.all(compact ? 4 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Úroveň $levelNumber',
                    textAlign: TextAlign.center,
                    style: pixelTextStyle(fontSize: compact ? 22 : 28),
                  ),
                  const SizedBox(height: 6),
                  const _PixelDivider(),
                  SizedBox(height: compact ? 6 : 10),
                  Text('Síla nepřátel', style: labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    hpBonusPercent <= 0 ? 'Základní' : '+$hpBonusPercent % HP',
                    style: valueStyle,
                  ),
                  const SizedBox(height: 6),
                  _PixelMeter(value: levelNumber / _levelCount),
                  SizedBox(height: compact ? 6 : 10),
                  Text('Stav', style: labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    completed ? 'Dobyto' : 'Čeká na hrdiny',
                    style: pixelTextStyle(
                      fontSize: compact ? 16 : 19,
                      color: completed
                          ? PixelPalette.emeraldLight
                          : PixelPalette.goldText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
          PixelButton(
            label: completed ? 'Znovu!' : 'Hrát!',
            height: compact ? 50 : 60,
            fontSize: compact ? 22 : 26,
            onPressed: _startSelectedLevel,
          ),
        ],
      ),
    );
  }
}

/// Thin gold pixel line used as a separator in pixel menus.
class _PixelDivider extends StatelessWidget {
  const _PixelDivider();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 3, color: PixelPalette.gold),
        Container(height: 3, color: PixelPalette.goldDark),
      ],
    );
  }
}

/// Segmented pixel bar (e.g. enemy strength of a level).
class _PixelMeter extends StatelessWidget {
  const _PixelMeter({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    const segments = 10;
    final filled = (value * segments).ceil().clamp(1, segments);
    return Container(
      height: 14,
      padding: const EdgeInsets.all(2),
      color: PixelPalette.outline,
      child: Row(
        children: [
          for (var i = 0; i < segments; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                color: i < filled
                    ? (i < filled - 1 ? PixelPalette.ruby : PixelPalette.rubyLight)
                    : PixelPalette.stoneDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.buttonLabel,
    this.locked = false,
    this.completed = false,
    this.compact = false,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String buttonLabel;
  final bool locked;
  final bool completed;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cardColor = locked
        ? const Color(0xFF25282C)
        : accentColor.withOpacity(0.24);
    final borderColor = locked ? Colors.white12 : accentColor.withOpacity(0.65);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dense = compact || constraints.maxHeight < 290;
        final ultraDense = constraints.maxHeight < 250;
        final cardPadding = ultraDense ? 14.0 : (dense ? 18.0 : 24.0);
        final iconSize = ultraDense ? 38.0 : (dense ? 46.0 : 62.0);
        final iconContainerSize = ultraDense ? 78.0 : (dense ? 96.0 : 124.0);
        final titleFontSize = ultraDense ? 18.0 : (dense ? 20.0 : 24.0);
        final subtitleFontSize = ultraDense ? 12.0 : (dense ? 13.0 : 14.0);
        final titleSpacing = ultraDense ? 10.0 : (dense ? 16.0 : 22.0);
        final subtitleSpacing = ultraDense ? 6.0 : (dense ? 8.0 : 10.0);
        final buttonSpacing = ultraDense ? 12.0 : (dense ? 18.0 : 24.0);
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(dense ? 20 : 24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.black26
                        : accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: locked
                          ? Colors.white24
                          : accentColor.withOpacity(0.7),
                    ),
                  ),
                  child: Icon(
                    locked ? Icons.lock : icon,
                    color: locked ? Colors.white54 : Colors.white,
                    size: iconSize,
                  ),
                ),
                if (completed && !locked) ...[
                  SizedBox(height: dense ? 10 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: dense ? 10 : 12,
                      vertical: dense ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D6F42),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF6BFA9D).withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      'Dokonceno',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ultraDense ? 10 : 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: titleSpacing),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: ultraDense ? 2 : null,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: subtitleSpacing),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: ultraDense ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: subtitleFontSize,
                  ),
                ),
                SizedBox(height: buttonSpacing),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPressed,
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChapterChoice {
  const _ChapterChoice({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.unlocked,
    this.roman = '',
  });

  final int number;
  final String title;
  final String subtitle;
  final bool unlocked;
  final String roman;

  // Campaign chapters shown in the pixel chapter/level menus.
  static const List<_ChapterChoice> all = [
    _ChapterChoice(
      number: 1,
      title: 'Kapitola I',
      subtitle: 'Temný les',
      unlocked: true,
      roman: 'I',
    ),
    _ChapterChoice(
      number: 2,
      title: 'Kapitola II',
      subtitle: 'Brzy dostupné',
      unlocked: false,
      roman: 'II',
    ),
  ];

  static _ChapterChoice byNumber(int number) =>
      all.firstWhere((chapter) => chapter.number == number, orElse: () => all.first);
}

bool _isRumbleTutorial(bool isRumble, int chapter, int level) =>
    isRumble && chapter == 1 && level == 2;

bool _isRumbleAerinTutorial(bool isRumble, int chapter, int level) =>
    isRumble && chapter == 1 && level == 1;

class GameHomeScreen extends StatelessWidget {
  const GameHomeScreen({
    super.key,
    this.heroes = const <HeroDef>[],
    this.chapterNumber = 1,
    this.levelNumber = 1,
    this.isGathering = false,
    this.isRumble = false,
  });

  final List<HeroDef> heroes;
  final int chapterNumber;
  final int levelNumber;
  final bool isGathering;
  final bool isRumble;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameView(
        heroes: _isRumbleTutorial(isRumble, chapterNumber, levelNumber)
            ? const <HeroDef>[]
            : _isRumbleAerinTutorial(isRumble, chapterNumber, levelNumber)
                ? const <HeroDef>[
                    HeroDef('Aerin', Color(0xFFE57373),
                        imageAsset: 'assets/heroes/hero_aerin.png'),
                  ]
                : heroes,
        chapterNumber: chapterNumber,
        levelNumber: levelNumber,
        isGathering: isGathering,
        isRumble: isRumble,
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.heroes,
    required this.chapterNumber,
    required this.levelNumber,
    this.isGathering = false,
    this.isRumble = false,
  });

  final List<HeroDef> heroes;
  final int chapterNumber;
  final int levelNumber;
  final bool isGathering;
  final bool isRumble;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  bool get _isAerinTutorial => _isRumbleAerinTutorial(
      widget.isRumble, widget.chapterNumber, widget.levelNumber);
  bool get _hasWorkerPortal =>
      (widget.isGathering || widget.isRumble) && !_isAerinTutorial;
  bool get _isTutorial => _isRumbleTutorial(
    widget.isRumble, widget.chapterNumber, widget.levelNumber);
  static const double baseMapWidth = 1600;
  static const double baseMapHeight = 400;
  static const double rumbleMapHeightMultiplier = 2;
  static const double rumbleMapExpansion = 4;
  static const double heroAreaWidth = 100;
  static const int heroSlots = 5;
  static const int heroGridRows = 7;
  static const int enemyLanes = 5;
  static const int enemySpawnCountMultiplier = 10;
  static const int rumbleWaveCount = 30;
  static const int rumbleFirstWaveEnemyCount = 1;
  static const int rumbleWaveEnemyCountIncrease = 2;
  static const double rumbleWaveInterval = 30;
  static const double heroPositionHeight = 50;
  double get cameraReferenceHeight => widget.isRumble
      ? baseMapHeight * rumbleMapHeightMultiplier
      : baseMapHeight;
  double get mapWidth =>
      baseMapWidth * (widget.isRumble ? rumbleMapExpansion : 1);
  double get mapHeight =>
      cameraReferenceHeight * (widget.isRumble ? rumbleMapExpansion : 1);
  double get heroSpacerHeight =>
      (mapHeight - heroSlots * heroPositionHeight) / 2;
  double get enemyLaneHeight => mapHeight / enemyLanes;
  static const double heroCardHeight = 28;
  static const double wallHpMax = 300;
  static const double enemyHpMax = 20;
  static const double enemySize = 40;
  static const double enemySeparationDistance = enemySize * 0.9;
  static const double projectileSpeed = 160; // units per second
  static const double heroMoveSpeed = 110; // units per second
  static const double brannMoveSpeedMultiplier = 0.5;
  static const double spellSendingDuration = 2; // seconds
  static const double spellCooldownDuration = 10; // seconds
  static const double cooldownScale = 0.25;
  static const double heroAttackRangeMultiplier = 4;
  static const double defaultHeroAttackRange =
      baseMapWidth / 6 * heroAttackRangeMultiplier;
  static const double enemyTapRadius = 18;
  static const double heroTapRadius = 48;
  static const double heroUnitSize = 96;
  static const double heroRenderSize = heroUnitSize * 2;
  static const double heroWallStopPadding = heroUnitSize * 0.6;
  static const double wallDps = 5; // damage per second
  static const double hitFlashDuration = 0.12; // seconds
  static const double wallHitEffectDuration = 0.16;
  static const double projectileRadius = 2;
  static const double explosionDuration = 0.35; // seconds
  static const double swordRadius = 140 * heroAttackRangeMultiplier;
  static const double enemyDeathFrameDuration = 0.12;
  static const double enemyHitFrameDuration = 0.05;
  static const double zombieShooterProjectileFrameDuration = 0.06;
  static const double enemyCorpseFadeDuration = 5.0;
  double get minZoomMultiplier => widget.isRumble ? 0.25 : 1.0;
  static const double maxZoomMultiplier = 2.5;
  static const double zoomStep = 0.2;
  static const double mapJoystickViewportHeightFactor = 0.33;
  static const double mapJoystickMinSize = 120.0;
  static const double mapJoystickMaxSize = 220.0;
  static const double mapJoystickKnobRadiusFactor = 0.26;
  static const double mapJoystickPanSpeedViewportFactor = 1.35;
  static const double heroRangeIndicatorVisibleDuration = 5.0;
  static const double heroRangeIndicatorFadeDuration = 0.6;

  double get _levelEnemyHpMultiplier =>
      pow(1.2, widget.levelNumber - 1).toDouble();
  static const double multiSelectDragThreshold = 18.0;
  static const double multiMoveSpacing = heroUnitSize + 12.0;
  static const double heroSpacingRadius = heroRenderSize / 2;
  static const double workerSpacingRadius = gatheringWorkerRenderSize / 2;
  static const double enemySpacingRadius = enemySize * 1.35;
  static const double enemyHeroContactRange = enemySpacingRadius + heroSpacingRadius + 10;
  static const double enemyWorkerContactRange = enemySpacingRadius + workerSpacingRadius + 10;
  static const double offensiveRangePadding = 18.0;
  static const double defensiveThreatPadding = 28.0;
  static const double defensiveRetreatPadding = 180.0;
  static const double defensiveReturnTolerance = 8.0;
  static const double defensiveRetreatMinDuration = 2.0;
  static const double towerCooldownDuration = 5.0;
  static const int constructionCost = 200;
  static const int lightningTowerCost = 300;
  static const double lightningTowerSize = 160;
  static const Color lightningTowerColor = Color(0xFF963DCE);
  static const int constructionUpgradeCost = 100;
  static const double constructionDuration = 60;
  static const double constructionSiteSize = 28;
  static const double towerDamage = 10.0;
  static const double towerWidth = 352.0;
  static const double towerHeight = 544.0;
  static const double towerRange = baseMapWidth / 3;
  static const Offset towerPosition = Offset(44, 72);
  static const Color zombieShooterProjectileColor = Color(0xFF92C96F);
  static const double gatheringWorkerSize = 26;
  static const double gatheringWorkerRenderSize = gatheringWorkerSize * 8;
  static const double gatheringWorkerMaxHp = 20;
  // HP bar sits just above the spirit's head inside its 208 px render box.
  static const double workerHpBarTopFactor = 0.13;
  static const double workerHpBarWidthFactor = 0.42;
  static const double gatheringWorkerAttackDamage = 3;
  static const double gatheringWorkerAttackInterval = 1;
  // Spirit.png: 0-7 move/idle, 8-15 mining/building, 16-23 claw attack.
  static const int workerSpriteFrameCount = 24;
  static const double gatheringWorkerSpeed = 78;
  static const double gatheringMiningDuration = 3;
  static const int gatheringGoldReward = 10;
  static const Size goldMineSize = Size(600, 544);
  static const double goldMineClearance = 180;
  static const Size manaPoolSize = Size(96, 81);
  static const double manaPoolSpacing = 100;
  // Tree variants for wood sources: sprite sheet (24 frames, 6x4 grid) and map size.
  static const List<String> woodTreeSheetAssets = <String>[
    'assets/buildings/tree_sheet.png',
    'assets/buildings/tree2_sheet.png',
    'assets/buildings/tree3_sheet.png',
  ];
  static const List<Size> woodTreeSizes = <Size>[
    Size(416, 440),
    Size(416, 472),
    Size(440, 436),
  ];
  static const Size woodTreeSize = Size(440, 472); // largest variant, used for spacing
  static const double woodTreeSpacing = 320;
  static const int woodTreeCountMultiplier = 10;
  static const int gatheringWoodReward = 10;
  static const int gatheringStoneReward = 10;
  static const int gatheringFragmentCarryAmount = 10;
  static const double heroMagicEnergyMax = 20;
  static const int gatheringWorkerCost = 20;
  static const int heroReviveCost = 200;

  final Random _rng = Random();
  late final Ticker _ticker;
  DateTime _gameStartTime = DateTime.now();
  double _lastTime = 0;
  double _wallHp = wallHpMax;
  double _wallHitEffectRemaining = 0;
  // Wave and statistics tracking
  int _currentWave = 1;
  int _enemiesKilled = 0;
  int _enemiesInWave = 0;
  int _enemiesSpawnedInWave = 0;
  int _totalWaves = 10;
  late final List<_HeroState> _heroStates;
  late final List<int> _heroSlotIndices;
  late final List<_HeroUnit> _heroUnits;
  late final List<_HeroBehaviorMode> _heroBehaviors;
  late final List<double> _heroAttackAnimationRemainingTimes;
  bool _gameOver = false;
  bool _gameOverDialogShown = false;
  bool _levelCompleted = false;
  bool _levelCompleteDialogShown = false;
  double _gameSpeed = 2;
  bool _speedPanelOpen = false;
  bool _autoMode = true;
  int? _readyHeroIndex;
  final _interactiveViewerKey = GlobalKey();
  final FocusNode _gameFocusNode = FocusNode(debugLabel: 'game_view_input');
  final TransformationController _mapTransformController =
      TransformationController();
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
  final List<_EnemyProjectile> _enemyProjectiles = [];
  final List<_DamageText> _damageTexts = [];
  final List<_FloatingCoinReward> _floatingCoinRewards = [];
  final List<_ExplosionEffect> _explosions = [];
  final List<_LightningEffect> _lightnings = [];
  Offset? _targetIndicator; // Shows manual target position
  bool _preventAutoReselect = false;
  DateTime _lastManualFireTime = DateTime.now();
  bool _isHoldingTouch = false;
  Offset? _holdPosition;
  int? _selectedHeroIndex;
  final Set<int> _multiSelectedHeroIndices = <int>{};
  final Set<int> _rangeIndicatorHeroIndices = <int>{};
  double? _rangeIndicatorShownAt;
  Offset? _pointerDownScenePosition;
  int? _pointerDownHeroIndex;
  Offset? _selectionDragCurrent;
  int _activePointerCount = 0;

  // RPG bonus helper methods
  // RPG system variables
  int _coinsEarned = 0;
  final Map<String, int> _xpEarned = {}; // heroName -> xp amount

  // Hero bonuses from RPG system
  final Map<String, double> _damageBonuses = {}; // heroName -> damage bonus
  final Map<String, double> _cooldownReductions =
      {}; // heroName -> cooldown reduction (seconds)
  final Map<String, ui.Image> _enemySpriteSheets = <String, ui.Image>{};
  ui.Image? _grassBackground;
  ui.Image? _wallSprite;
  ui.Image? _towerSprite;
  ui.Image? _workerSpriteSheet;
  ui.Image? _portalSpriteSheet;
  ui.Image? _goldMineSpriteSheet;
  ui.Image? _manaPoolSpriteSheet;
  final List<ui.Image?> _woodTreeSpriteSheets =
      List<ui.Image?>.filled(woodTreeSheetAssets.length, null);
  bool _portalMenuOpen = false;
  static const Rect _portalRect = Rect.fromLTWH(0, -120, 640, 640);
  BuildingNavigation? _buildingNavigation;
  List<(bool, _ConstructionType)> _navigationSiteStates = [];

  static Rect _gridFrame(ui.Image sheet, int frame, {int columns = 6, int rows = 4}) {
    final width = sheet.width / columns;
    final height = sheet.height / rows;
    return Rect.fromLTWH((frame % columns) * width, (frame ~/ columns) * height, width, height);
  }

  /// Trees and mana pools, drawn by the game painter below all units.
  List<_SceneSprite> _economySceneSprites() {
    if (!(widget.isGathering || widget.isRumble)) return const <_SceneSprite>[];
    final tick = (_lastTime * 12).floor();
    final sprites = <_SceneSprite>[];
    for (var i = 0; i < _gatheringWoodPositions.length; i++) {
      final position = _gatheringWoodPositions[i];
      final sheet = _woodTreeSpriteSheets[_gatheringWoodVariants[i]];
      if (sheet == null) {
        sprites.add(_SceneSprite(
          dst: Rect.fromCenter(center: position, width: 20, height: 20),
          color: const Color(0xFF8B5A2B),
          border: const Color(0xFF573717),
        ));
        continue;
      }
      final size = _woodTreeSizeAt(i);
      // Offset per tree so they do not sway in sync.
      final frame = (tick + (position.dx * 5 + position.dy * 3).floor()) % 24;
      sprites.add(_SceneSprite(
        image: sheet,
        src: _gridFrame(sheet, frame),
        dst: Rect.fromCenter(center: position, width: size.width, height: size.height),
      ));
    }
    for (final position in _gatheringFragmentPositions) {
      final sheet = _manaPoolSpriteSheet;
      if (sheet == null) {
        sprites.add(_SceneSprite(
          dst: Rect.fromCenter(center: position, width: 20, height: 20),
          color: const Color(0xFF9B6CDE),
          border: const Color(0xFF5B3B8A),
        ));
        continue;
      }
      // Offset per pool so they do not swirl in sync.
      final frame = (tick + (position.dx * 7 + position.dy * 3).floor()) % 24;
      sprites.add(_SceneSprite(
        image: sheet,
        src: _gridFrame(sheet, frame),
        dst: Rect.fromCenter(
            center: position, width: manaPoolSize.width, height: manaPoolSize.height),
      ));
    }
    return sprites;
  }

  /// Everything units can walk behind, as currently drawn on the map.
  List<_SceneSprite> _occluderSprites() {
    final sprites = <_SceneSprite>[];
    final tower = _towerSprite;
    _SceneSprite towerAt(ui.Image sheet, Offset center, double phase) {
      final frameWidth = sheet.width / _GamePainter.towerSpriteFrameCount;
      final frame = ((_lastTime * 10).floor() + phase.floor()) %
          _GamePainter.towerSpriteFrameCount;
      return _SceneSprite(
        image: sheet,
        src: Rect.fromLTWH(frame * frameWidth, 0, frameWidth, sheet.height.toDouble()),
        dst: Rect.fromCenter(center: center, width: towerWidth, height: towerHeight),
      );
    }

    if (tower != null) sprites.add(towerAt(tower, towerPosition, 0));
    for (final site in _constructionSites) {
      if (site.level <= 0) continue;
      if (site.type == _ConstructionType.lightning) {
        sprites.add(_SceneSprite(
          dst: Rect.fromCenter(
              center: site.position, width: lightningTowerSize, height: lightningTowerSize),
          color: lightningTowerColor,
          border: const Color(0xFFDDADFF),
        ));
      } else if (tower != null) {
        sprites.add(towerAt(tower, site.position, site.position.dx + site.position.dy));
      }
    }
    if (widget.isGathering || widget.isRumble) {
      final frame = (_lastTime * 12).floor() % 24;
      final portal = _portalSpriteSheet;
      if (_hasWorkerPortal && portal != null) {
        sprites.add(_SceneSprite(image: portal, src: _gridFrame(portal, frame), dst: _portalRect));
      }
      final mine = _goldMineSpriteSheet;
      if (mine != null) {
        sprites.add(_SceneSprite(
          image: mine,
          src: _gridFrame(mine, frame),
          dst: Rect.fromCenter(center: _gatheringGoldPosition,
              width: goldMineSize.width, height: goldMineSize.height),
        ));
      }
      sprites.addAll(_economySceneSprites());
    }
    return sprites;
  }

  /// Drawn rect and ground line (logical position) of every visible unit.
  List<(Rect, double)> _occludableUnits() {
    return [
      for (var i = 0; i < _heroUnits.length; i++)
        if (_heroUnits[i].isAlive)
          (Rect.fromCenter(center: _heroPosition(i),
              width: _heroWidgetWidthForIndex(i), height: _heroWidgetHeightForIndex(i)),
           _heroPosition(i).dy),
      for (final worker in _gatheringWorkers)
        if (worker.isAlive)
          (Rect.fromCenter(center: worker.position,
              width: gatheringWorkerRenderSize, height: gatheringWorkerRenderSize),
           worker.position.dy),
      for (final enemy in _enemies)
        (Rect.fromCenter(center: enemy.position, width: enemySize * 2.8, height: enemySize * 2.8),
         enemy.position.dy),
    ];
  }

  // Workers mine in front of a resource (just below its blocking lower half),
  // so they stay visible instead of standing behind the building or tree.
  Offset _miningSpotFor(_GatheringWorker worker) {
    const gap = 6.0;
    switch (worker.targetResource) {
      case _GatheringResource.wood:
        final index = worker.targetWoodIndex!;
        return _gatheringWoodPositions[index]
            .translate(0, _woodTreeSizeAt(index).height / 2 + gap);
      case _GatheringResource.stone:
        return _gatheringStonePositions[worker.targetStoneIndex!];
      case _GatheringResource.fragments:
        return _gatheringFragmentPositions[worker.targetFragmentIndex!]
            .translate(0, manaPoolSize.height / 2 + gap);
      case _GatheringResource.gold:
      case null:
        return _gatheringGoldPosition.translate(0, goldMineSize.height / 2 + gap);
    }
  }

  static Rect _blockingHalf(Rect image) =>
      Rect.fromLTRB(image.left, image.center.dy, image.right, image.bottom);

  BuildingNavigation get _navigation {
    // Terrain resources are fixed for this scene. Only tower footprint changes
    // can invalidate navigation; do not rebuild/compare every tree per unit.
    final cached = _buildingNavigation;
    var unchanged = cached != null &&
        _navigationSiteStates.length == _constructionSites.length;
    if (unchanged) {
      for (var i = 0; i < _constructionSites.length; i++) {
        final site = _constructionSites[i];
        if (_navigationSiteStates[i] != (site.isOrdered || site.level > 0, site.type)) {
          unchanged = false;
          break;
        }
      }
    }
    if (unchanged) return cached!;
    // The lower half of a building's image blocks movement; the upper half
    // stays walkable so units can pass behind it.
    Rect footprint(Rect rect) => _blockingHalf(rect);
    final obstacles = <Rect>[
      footprint(Rect.fromCenter(center: towerPosition,
          width: towerWidth, height: towerHeight)),
      if (widget.isGathering || widget.isRumble) ...[
        if (_hasWorkerPortal) footprint(_portalRect),
        footprint(Rect.fromCenter(center: _gatheringGoldPosition,
            width: goldMineSize.width, height: goldMineSize.height)),
        // Trees block only around the trunk and roots, the canopy stays walkable.
        ..._woodTreeFootprints,
        for (final fragmentPosition in _gatheringFragmentPositions)
          footprint(Rect.fromCenter(center: fragmentPosition,
              width: manaPoolSize.width, height: manaPoolSize.height)),
      ],
      for (final site in _constructionSites)
        if (site.isOrdered || site.level > 0)
          footprint(Rect.fromCenter(center: site.position,
            width: site.type == _ConstructionType.lightning ? lightningTowerSize : towerWidth,
            height: site.type == _ConstructionType.lightning ? lightningTowerSize : towerHeight)),
    ];
    final old = _buildingNavigation;
    if (old == null || old.obstacles.length != obstacles.length ||
        List.generate(obstacles.length, (i) => i)
            .any((i) => old.obstacles[i] != obstacles[i])) {
      _buildingNavigation = BuildingNavigation(
        Rect.fromLTRB(heroAreaWidth + 4, 16, mapWidth + enemySize * 2, mapHeight - 16),
        obstacles,
      );
    }
    _navigationSiteStates = [for (final site in _constructionSites)
      (site.isOrdered || site.level > 0, site.type)];
    return _buildingNavigation!;
  }

  Offset _portalWorkerPosition(int index) => Offset(
    _portalRect.right + 60 + (index ~/ 5) * 34,
    _portalRect.center.dy - 148 + (index % 5) * 34,
  );
  ui.Image? _zombieShooterProjectileSprite;
  final Map<String, int> _enemySpriteFrameCounts = <String, int>{};
  double _baseMapScale = 1.0;
  double _zoomMultiplier = 1.0;
  double _towerCooldownRemaining = 0.0;
  Offset _mapViewportOffset = Offset.zero;
  Offset _mapJoystickInput = Offset.zero;
  final Map<int, Offset> _activeViewportPointers = <int, Offset>{};
  int? _desktopPanPointer;
  Offset? _desktopPanLastViewportPosition;
  bool _spacePanModifierPressed = false;
  late LevelDef _levelDef;
  bool _levelDataReady = false;
  double _waveElapsedTime = 0.0;
  int _nextWaveSpawnIndex = 0;
  List<_ScheduledSpawn> _scheduledWaveSpawns = <_ScheduledSpawn>[];
  late final Offset _gatheringGoldPosition;
  late final Offset _gatheringWallPosition;
  late final List<Offset> _gatheringWoodPositions;
  late final List<int> _gatheringWoodVariants;
  late final List<Rect> _woodTreeFootprints;

  Size _woodTreeSizeAt(int index) => woodTreeSizes[_gatheringWoodVariants[index]];
  late final List<Offset> _gatheringStonePositions;
  late final List<Offset> _gatheringFragmentPositions;
  final List<_GatheringWorker> _gatheringWorkers = <_GatheringWorker>[];
  final List<_ConstructionSite> _constructionSites = <_ConstructionSite>[];
  _ConstructionSite? _selectedConstructionSite;
  final Set<int> _selectedGatheringWorkerIndices = <int>{};
  int? _selectedGatheringWorkerIndex;
  int _gatheringCoins = 0;
  int _gatheringWood = 0;
  int _gatheringStone = 0;

  @override
  void initState() {
    super.initState();
    _enableFullscreenMode();
    _levelDef = LevelRepository.buildLegacyTemplate(
      chapterNumber: widget.chapterNumber,
      levelNumber: widget.levelNumber,
    );
    _heroSlotIndices = List<int>.generate(
      widget.heroes.length,
      (index) => index,
    );
    _heroStates = List<_HeroState>.generate(
      widget.heroes.length,
      (_) => _HeroState(
        phase: _HeroPhase.cooldown,
        timeRemaining: 0,
        pendingAttack: false,
        magicEnergy: heroMagicEnergyMax,
      ),
    );
    _heroUnits = List<_HeroUnit>.generate(
      widget.heroes.length,
      _initialHeroUnit,
    );
    _heroBehaviors = List<_HeroBehaviorMode>.filled(
      widget.heroes.length,
      _HeroBehaviorMode.holdPosition,
    );
    _heroAttackAnimationRemainingTimes = List<double>.filled(
      widget.heroes.length,
      0,
    );
    _aerinMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _loadGrassBackground();
    _loadWallSprite();
    _loadTowerSprite();
    _loadWorkerSpriteSheet();
    if (widget.isGathering || widget.isRumble) {
      _loadPortalSpriteSheet();
      _loadGoldMineSpriteSheet();
      _loadManaPoolSpriteSheet();
      _loadWoodTreeSpriteSheets();
    }
    _loadEnemySpriteSheet();
    _loadZombieShooterProjectileSprite();
    // Load RPG bonuses
    _loadHeroBonuses();
    _loadGatheringCoins();
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
    _ticker = createTicker(_onTick);
    if (widget.isGathering) {
      _initializeGathering();
      _ticker.start();
    } else {
      if (widget.isRumble) {
        _initializeGathering();
      }
      _prepareWaveRuntime();
      _loadLevelDefinitionAndStartTicker();
    }
    _separateAllUnits();
  }

  void _initializeGathering() {
    _gatheringWallPosition = Offset(heroAreaWidth + 28, cameraReferenceHeight / 2);
    if (widget.isRumble) {
      _constructionSites.addAll([
        _ConstructionSite(Offset(mapWidth * 0.30, mapHeight * 0.32)),
        _ConstructionSite(Offset(mapWidth * 0.60, mapHeight * 0.68)),
      ]);
    }
    Offset goldPosition;
    do {
      goldPosition = Offset(
        220 + _rng.nextDouble() * (mapWidth - 300),
        min(goldMineSize.height, mapHeight) / 2 +
            _rng.nextDouble() * max(0.0, mapHeight - goldMineSize.height),
      );
    } while (_isConstructionArea(goldPosition) ||
        _portalRect.inflate(goldMineSize.width / 2 + 10).contains(goldPosition));
    _gatheringGoldPosition = goldPosition;
    final woodCount = (5 + _rng.nextInt(6)) * woodTreeCountMultiplier;
    final woodPositions = <Offset>[];
    // Keep the fixed mana pool next to the base free of trees.
    final fixedFragmentPosition =
        Offset(_gatheringWallPosition.dx + 70, manaPoolSize.height / 2 + 4);
    var attempts = 0;
    while (woodPositions.length < woodCount && attempts < woodCount * 40) {
      attempts++;
      final candidate = Offset(
        220 + _rng.nextDouble() * (mapWidth - 300),
        min(woodTreeSize.height, mapHeight) / 2 +
            _rng.nextDouble() * max(0.0, mapHeight - woodTreeSize.height),
      );
      if (_isConstructionArea(candidate) ||
          _portalRect.inflate(woodTreeSize.width / 2 + 10).contains(candidate) ||
          (candidate - _gatheringGoldPosition).distance <
              max(goldMineClearance, goldMineSize.width / 2) +
                  woodTreeSize.width / 2 ||
          (candidate - fixedFragmentPosition).distance < 100 ||
          woodPositions.any(
              (position) => (position - candidate).distance < woodTreeSpacing)) {
        continue;
      }
      woodPositions.add(candidate);
    }
    _gatheringWoodPositions = woodPositions;
    _gatheringWoodVariants = List<int>.generate(
        woodPositions.length, (_) => _rng.nextInt(woodTreeSheetAssets.length));
    // Trees block the lower half of their image, but only the middle 50 % of
    // its width (trunk, roots, rocks); the canopy stays walkable.
    _woodTreeFootprints = List<Rect>.generate(woodPositions.length, (i) {
      final size = _woodTreeSizeAt(i);
      final image = Rect.fromCenter(
          center: woodPositions[i], width: size.width, height: size.height);
      return Rect.fromLTRB(image.center.dx - size.width * 0.25, image.center.dy,
          image.center.dx + size.width * 0.25, image.bottom);
    });
    final stoneCount = 5 + _rng.nextInt(6);
    final stonePositions = <Offset>[];
    attempts = 0;
    while (stonePositions.length < stoneCount && attempts < 3000) {
      attempts++;
      final candidate = Offset(
        220 + _rng.nextDouble() * (mapWidth - 280),
        36 + _rng.nextDouble() * (mapHeight - 72),
      );
      if (_isConstructionArea(candidate) ||
          (candidate - _gatheringGoldPosition).distance < goldMineClearance ||
          woodPositions.any((position) => (position - candidate).distance < 64) ||
          stonePositions.any((position) => (position - candidate).distance < 38)) {
        continue;
      }
      stonePositions.add(candidate);
    }
    _gatheringStonePositions = stonePositions;
    final fragmentCount = 5 + _rng.nextInt(6);
    final fragmentPositions = <Offset>[
      fixedFragmentPosition,
    ];
    attempts = 0;
    while (fragmentPositions.length < fragmentCount + 1 && attempts < 3000) {
      attempts++;
      final candidate = Offset(
        220 + _rng.nextDouble() * (mapWidth - 300),
        manaPoolSize.height / 2 +
            _rng.nextDouble() * (mapHeight - manaPoolSize.height),
      );
      if (_isConstructionArea(candidate) ||
          _portalRect.inflate(manaPoolSize.width / 2 + 10).contains(candidate) ||
          (candidate - _gatheringGoldPosition).distance <
              goldMineClearance + manaPoolSize.width / 2 ||
          woodPositions.any((position) => (position - candidate).distance < 100) ||
          stonePositions.any((position) => (position - candidate).distance < 70) ||
          fragmentPositions.any(
              (position) => (position - candidate).distance < manaPoolSpacing)) {
        continue;
      }
      fragmentPositions.add(candidate);
    }
    _gatheringFragmentPositions = fragmentPositions;
    if (_hasWorkerPortal) {
      _gatheringWorkers.add(_newGatheringWorker());
      if (widget.isRumble && !_isTutorial) {
        _gatheringWorkers.add(_newGatheringWorker());
      }
    }
    _loadGatheringWood();
    _loadGatheringStone();
  }

  _GatheringWorker _newGatheringWorker() => _GatheringWorker(
    position: _portalWorkerPosition(_gatheringWorkers.length),
  );

  Future<void> _loadGatheringCoins() async {
    final progress = await RpgSystem.getProgress();
    if (!mounted) {
      return;
    }
    setState(() {
      _gatheringCoins = progress.coins;
    });
  }

  Future<void> _loadGatheringWood() async {
    final progress = await RpgSystem.getProgress();
    if (!mounted) {
      return;
    }
    setState(() {
      _gatheringWood = progress.wood;
    });
  }

  Future<void> _loadGatheringStone() async {
    final progress = await RpgSystem.getProgress();
    if (!mounted) {
      return;
    }
    setState(() {
      _gatheringStone = progress.stone;
    });
  }

  Future<void> _persistGatheringGold() async {
    await RpgSystem.addCoins(gatheringGoldReward);
    await RpgSystem.saveProgress();
  }

  Future<void> _persistGatheringWood() async {
    await RpgSystem.addWood(gatheringWoodReward);
    await RpgSystem.saveProgress();
  }

  Future<void> _persistGatheringStone() async {
    await RpgSystem.addStone(gatheringStoneReward);
    await RpgSystem.saveProgress();
  }

  Future<void> _buyGatheringWorker() async {
    if (!_hasWorkerPortal || _gatheringCoins < gatheringWorkerCost) {
      return;
    }
    setState(() {
      _gatheringCoins -= gatheringWorkerCost;
      _gatheringWorkers.add(_newGatheringWorker());
      _separateAllUnits();
    });
    await RpgSystem.addCoins(-gatheringWorkerCost);
    await RpgSystem.saveProgress();
  }

  @override
  void dispose() {
    for (final spriteSheet in _enemySpriteSheets.values) {
      spriteSheet.dispose();
    }
    _grassBackground?.dispose();
    _wallSprite?.dispose();
    _towerSprite?.dispose();
    _workerSpriteSheet?.dispose();
    _portalSpriteSheet?.dispose();
    _goldMineSpriteSheet?.dispose();
    _manaPoolSpriteSheet?.dispose();
    for (final sheet in _woodTreeSpriteSheets) {
      sheet?.dispose();
    }
    _zombieShooterProjectileSprite?.dispose();
    _gameFocusNode.dispose();
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

  Future<void> _loadGrassBackground() async {
    try {
      final data = await rootBundle.load('assets/backgrounds/grass.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _grassBackground?.dispose();
        _grassBackground = image;
      });
    } catch (_) {
      // Keep the solid-color background fallback if the texture cannot load.
    }
  }

  Future<void> _loadWallSprite() async {
    try {
      final data = await rootBundle.load('assets/backgrounds/palisade.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _wallSprite?.dispose();
        _wallSprite = image;
      });
    } catch (_) {
      // Keep the painted wall fallback if the texture cannot load.
    }
  }

  Future<void> _loadTowerSprite() async {
    try {
      // Animated sheet: 12 frames of the tower in one row (flag + torch).
      final data = await rootBundle.load('assets/backgrounds/tower_sheet.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _towerSprite?.dispose();
        _towerSprite = image;
      });
    } catch (_) {
      // Keep the painted tower fallback if the texture cannot load.
    }
  }

  Future<void> _loadPortalSpriteSheet() async {
    try {
      final data = await rootBundle.load('assets/buildings/portal_sheet.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _portalSpriteSheet?.dispose();
        _portalSpriteSheet = image;
      });
    } catch (_) {
      // Keep the portal usable even if its sprite cannot load.
    }
  }

  Future<void> _loadGoldMineSpriteSheet() async {
    try {
      final data = await rootBundle.load('assets/buildings/goldMine_sheet.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _goldMineSpriteSheet?.dispose();
        _goldMineSpriteSheet = image;
      });
    } catch (_) {
      // Keep the painted gold box fallback if the mine sprite cannot load.
    }
  }

  Future<void> _loadManaPoolSpriteSheet() async {
    try {
      final data = await rootBundle.load('assets/buildings/manaPool_sheet.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _manaPoolSpriteSheet?.dispose();
        _manaPoolSpriteSheet = image;
      });
    } catch (_) {
      // Keep the painted fragment boxes if the mana pool sprite cannot load.
    }
  }

  Future<void> _loadWoodTreeSpriteSheets() async {
    for (int variant = 0; variant < woodTreeSheetAssets.length; variant++) {
      try {
        final data = await rootBundle.load(woodTreeSheetAssets[variant]);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        late final ui.Image image;
        try {
          image = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
        if (!mounted) {
          image.dispose();
          return;
        }
        setState(() {
          _woodTreeSpriteSheets[variant]?.dispose();
          _woodTreeSpriteSheets[variant] = image;
        });
      } catch (_) {
        // Keep the painted wood box for this variant if its sprite cannot load.
      }
    }
  }

  Widget _buildPortal() {
    return Positioned.fromRect(
      rect: _portalRect,
      child: Semantics(
        label: 'Portál – nákup sběračů',
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            _portalMenuOpen = !_portalMenuOpen;
            _selectedConstructionSite = null;
            _selectedHeroIndex = null;
            _multiSelectedHeroIndices.clear();
            _selectedGatheringWorkerIndex = null;
            _selectedGatheringWorkerIndices.clear();
            _clearHeroRangeIndicator();
          }),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _buildPortalMenu() {
    return Positioned(
      left: _portalRect.right + 8,
      top: max(8.0, _portalRect.top),
      width: 84,
      height: 80,
      child: Tooltip(
        message: 'Koupit sběrače za $gatheringWorkerCost zlata',
        child: FilledButton(
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(4)),
          onPressed: _gatheringCoins >= gatheringWorkerCost ? _buyGatheringWorker : null,
          child: Column(children: [
            Expanded(child: _workerSpriteSheet == null
                ? const Icon(Icons.person_add)
                : CustomPaint(
                    size: const Size(52, 52),
                    painter: _SpriteFramePainter(
                      spriteSheet: _workerSpriteSheet!, frameIndex: 0,
                      frameCount: workerSpriteFrameCount,
                      frameWidth: _workerSpriteSheet!.width / workerSpriteFrameCount,
                      frameHeight: _workerSpriteSheet!.height.toDouble(),
                    ),
                  )),
            Text('$gatheringWorkerCost zlata'),
          ]),
        ),
      ),
    );
  }

  Future<void> _loadWorkerSpriteSheet() async {
    try {
      final data = await rootBundle.load('assets/workers/Spirit.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _workerSpriteSheet?.dispose();
        _workerSpriteSheet = image;
      });
    } catch (_) {
      // Keep the worker's painted fallback if the sprite cannot load.
    }
  }

  Future<void> _loadZombieShooterProjectileSprite() async {
    try {
      final data = await rootBundle.load(
        'assets/enemies/Projectile_zombie_shooter.png',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _zombieShooterProjectileSprite?.dispose();
        _zombieShooterProjectileSprite = image;
      });
    } catch (_) {
      // Keep the painted projectile fallback if the sprite cannot load.
    }
  }

  Future<void> _loadEnemySpriteSheet() async {
    final loadedSheets = <String, ui.Image>{};
    final loadedFrameCounts = <String, int>{};
    try {
      for (final entry in _enemySpriteConfigs.entries) {
        final config = entry.value;
        final data = await rootBundle.load(config.assetPath);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        final image = frame.image;
        loadedSheets[entry.key] = image;
        loadedFrameCounts[entry.key] = max(
          1,
          image.width ~/ config.frameWidth.round(),
        );
      }
      if (!mounted) {
        for (final image in loadedSheets.values) {
          image.dispose();
        }
        return;
      }
      setState(() {
        for (final spriteSheet in _enemySpriteSheets.values) {
          spriteSheet.dispose();
        }
        _enemySpriteSheets
          ..clear()
          ..addAll(loadedSheets);
        _enemySpriteFrameCounts
          ..clear()
          ..addAll(loadedFrameCounts);
      });
    } catch (_) {
      for (final image in loadedSheets.values) {
        image.dispose();
      }
      // Keep the painter fallback if the sprite sheet cannot be loaded.
    }
  }

  Future<void> _loadHeroBonuses() async {
    final skillTrees = _getSkillTrees();
    for (final hero in widget.heroes) {
      final skillTree = skillTrees[hero.name];
      if (skillTree != null) {
        final damageBonus = await RpgSystem.getTotalDamageBonus(
          hero.name,
          skillTree,
        );
        final cooldownReduction = await RpgSystem.getTotalCooldownReduction(
          hero.name,
          skillTree,
        );
        if (mounted) {
          setState(() {
            _damageBonuses[hero.name] = damageBonus;
            _cooldownReductions[hero.name] = cooldownReduction;
          });
        }
      }
    }
  }

  Future<void> _loadLevelDefinitionAndStartTicker() async {
    final loadedLevel = widget.isRumble
        ? _buildRumbleLevelDefinition()
        : await LevelRepository.loadLevel(
            chapterNumber: widget.chapterNumber,
            levelNumber: widget.levelNumber,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _levelDef = loadedLevel;
      _levelDataReady = true;
      _currentWave = 1;
      _totalWaves = max(1, _levelDef.waves.length);
      _prepareWaveRuntime();
    });
    _ticker.start();
  }

  LevelDef _buildRumbleLevelDefinition() {
    return LevelDef(
      version: 1,
      chapter: widget.chapterNumber,
      level: widget.levelNumber,
      name: 'Rumble',
      waves: List<WaveDef>.generate(_isTutorial ? 10 : rumbleWaveCount, (waveIndex) {
        return WaveDef(
          id: waveIndex + 1,
          startDelay: waveIndex == 0 ? 0 : rumbleWaveInterval,
          completeWhenNoEnemies: false,
          events: <SpawnEventDef>[
            SpawnEventDef(
              time: 0,
              enemyType: 'fat_zombie',
              count: _isTutorial ? 4 : rumbleFirstWaveEnemyCount +
                  waveIndex * rumbleWaveEnemyCountIncrease,
              lane: waveIndex % enemyLanes + 1,
              spacing: 0,
            ),
          ],
        );
      }),
    );
  }

  void _prepareWaveRuntime() {
    _waveElapsedTime = 0;
    _nextWaveSpawnIndex = 0;
    _enemiesSpawnedInWave = 0;
    if (_levelDef.waves.isEmpty) {
      _scheduledWaveSpawns = <_ScheduledSpawn>[];
      _enemiesInWave = 0;
      _totalWaves = 0;
      return;
    }
    _totalWaves = _levelDef.waves.length;
    final waveIndex = (_currentWave - 1)
        .clamp(0, _levelDef.waves.length - 1)
        .toInt();
    final wave = _levelDef.waves[waveIndex];
    final scheduled = <_ScheduledSpawn>[];
    final mixedTypes = <String>[];
    for (final event in wave.events) {
      final enemyType =
          enemyTypeRegistry[event.enemyType] ?? enemyTypeRegistry.values.first;
      final spawnCount = event.count *
          (widget.isRumble ? 1 : enemySpawnCountMultiplier);
      for (int i = 0; i < spawnCount; i++) {
        // Shuffle bags keep the default waves varied, including level 1/Rumble.
        // Explicit non-zombie types from the level editor remain unchanged.
        var spawnType = enemyType;
        if (event.enemyType == 'fat_zombie') {
          if (mixedTypes.isEmpty) {
            mixedTypes.addAll(_enemySpriteConfigs.keys);
            mixedTypes.shuffle(_rng);
          }
          spawnType = enemyTypeRegistry[mixedTypes.removeLast()]!;
        }
        scheduled.add(
          _ScheduledSpawn(
            time: wave.startDelay + event.time + i * event.spacing,
            enemyType: spawnType,
            lane: event.lane,
            hpMultiplier: event.hpMultiplier,
            speedMultiplier: event.speedMultiplier,
            seedOffset: i * 17.0 + event.time,
          ),
        );
      }
    }
    scheduled.sort((a, b) => a.time.compareTo(b.time));
    // Keep authored pauses, but stagger simultaneous arrivals in each lane.
    final nextLaneArrival = <int, double>{};
    _scheduledWaveSpawns = scheduled.map((spawn) {
      final time = max(spawn.time, nextLaneArrival[spawn.lane] ?? spawn.time);
      nextLaneArrival[spawn.lane] = time + 0.15 + _rng.nextDouble() * 0.20;
      return _ScheduledSpawn(
        time: time,
        enemyType: spawn.enemyType,
        lane: spawn.lane,
        hpMultiplier: spawn.hpMultiplier,
        speedMultiplier: spawn.speedMultiplier,
        seedOffset: spawn.seedOffset,
      );
    }).toList()..sort((a, b) => a.time.compareTo(b.time));
    _enemiesInWave = scheduled.length;
  }

  void _updateMapScale(double baseScale) {
    if ((_baseMapScale - baseScale).abs() < 0.0001) {
      return;
    }
    _baseMapScale = baseScale;
    _mapViewportOffset = _clampMapViewportOffset(_mapViewportOffset);
    _applyMapTransform();
  }

  void _applyMapTransform() {
    final matrix = Matrix4.identity()..scale(_baseMapScale * _zoomMultiplier);
    matrix.setTranslationRaw(_mapViewportOffset.dx, _mapViewportOffset.dy, 0);
    _mapTransformController.value = matrix;
  }

  double _mapJoystickSizeForViewport(double viewportHeight) {
    return (viewportHeight * mapJoystickViewportHeightFactor)
        .clamp(mapJoystickMinSize, mapJoystickMaxSize)
        .toDouble();
  }

  void _updateMapJoystickInput(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final rawDelta = localPosition - center;
    final maxDistance = size * mapJoystickKnobRadiusFactor;
    final distance = rawDelta.distance;
    final clampedDelta = distance <= maxDistance || distance <= 0.0001
        ? rawDelta
        : rawDelta / distance * maxDistance;
    setState(() {
      _mapJoystickInput = Offset(
        (clampedDelta.dx / maxDistance).clamp(-1.0, 1.0),
        (clampedDelta.dy / maxDistance).clamp(-1.0, 1.0),
      );
    });
  }

  void _resetMapJoystickInput() {
    if (_mapJoystickInput.distanceSquared <= 0.0001) {
      return;
    }
    setState(() {
      _mapJoystickInput = Offset.zero;
    });
  }

  void _updateMapJoystickPan(double dt) {
    if (_mapJoystickInput.distanceSquared <= 0.0001) {
      return;
    }
    final viewportSize = _interactiveViewportSize();
    if (viewportSize == null) {
      return;
    }
    final panSpeed = viewportSize.height * mapJoystickPanSpeedViewportFactor;
    final delta = Offset(
      -_mapJoystickInput.dx * panSpeed * dt,
      -_mapJoystickInput.dy * panSpeed * dt,
    );
    if (delta.distanceSquared <= 0) {
      return;
    }
    _mapViewportOffset = _clampMapViewportOffset(_mapViewportOffset + delta);
    _applyMapTransform();
  }

  double _zoomAfterStep(double delta) {
    // Five extra Rumble steps below the unchanged initial zoom: .85 to .25.
    if (widget.isRumble &&
        (_zoomMultiplier < 1.0 - 0.0001 ||
            (delta < 0 && _zoomMultiplier <= 1.0 + 0.0001))) {
      return (_zoomMultiplier + delta * 0.75)
          .clamp(minZoomMultiplier, 1.0).toDouble();
    }
    return (_zoomMultiplier + delta).clamp(1.0, maxZoomMultiplier).toDouble();
  }

  void _changeZoom(double delta) {
    final nextZoom = _zoomAfterStep(delta);
    final viewportSize = _interactiveViewportSize();
    final viewportCenter = viewportSize == null
        ? null
        : Offset(viewportSize.width / 2, viewportSize.height / 2);
    _setZoomAroundViewportPoint(nextZoom.toDouble(), viewportCenter);
  }

  void _setZoomAroundViewportPoint(double nextZoom, Offset? viewportPoint) {
    if ((nextZoom - _zoomMultiplier).abs() < 0.0001) {
      return;
    }
    final anchorScenePosition = viewportPoint == null
        ? null
        : _mapTransformController.toScene(viewportPoint);
    setState(() {
      _zoomMultiplier = nextZoom;
      if (viewportPoint != null && anchorScenePosition != null) {
        final nextScale = _baseMapScale * _zoomMultiplier;
        _mapViewportOffset = Offset(
          viewportPoint.dx - anchorScenePosition.dx * nextScale,
          viewportPoint.dy - anchorScenePosition.dy * nextScale,
        );
      }
      _mapViewportOffset = _clampMapViewportOffset(_mapViewportOffset);
      _applyMapTransform();
    });
  }

  bool _isDesktopPanTrigger(PointerEvent event) {
    if (event.kind != ui.PointerDeviceKind.mouse) {
      return false;
    }
    final isMiddleDrag = (event.buttons & 0x04) != 0;
    final isSpaceModifiedPrimaryDrag =
        _spacePanModifierPressed && (event.buttons & 0x01) != 0;
    return isMiddleDrag || isSpaceModifiedPrimaryDrag;
  }

  bool _isDesktopPanActiveForPointer(PointerEvent event) {
    return _desktopPanPointer != null && _desktopPanPointer == event.pointer;
  }

  void _startDesktopPan(PointerDownEvent event) {
    _desktopPanPointer = event.pointer;
    _desktopPanLastViewportPosition = _pointerEventToViewportPosition(event);
  }

  void _updateDesktopPan(PointerMoveEvent event) {
    final previousViewportPosition = _desktopPanLastViewportPosition;
    if (previousViewportPosition == null) {
      return;
    }
    final viewportPosition = _pointerEventToViewportPosition(event);
    final delta = viewportPosition - previousViewportPosition;
    if (delta.distanceSquared <= 0) {
      _desktopPanLastViewportPosition = viewportPosition;
      return;
    }
    _desktopPanLastViewportPosition = viewportPosition;
    _mapViewportOffset = _clampMapViewportOffset(_mapViewportOffset + delta);
    _applyMapTransform();
  }

  void _stopDesktopPan() {
    _desktopPanPointer = null;
    _desktopPanLastViewportPosition = null;
  }

  KeyEventResult _handleGameKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    final isPressed = event is! KeyUpEvent;
    if (_spacePanModifierPressed == isPressed) {
      return KeyEventResult.handled;
    }
    setState(() {
      _spacePanModifierPressed = isPressed;
      if (!isPressed) {
        _stopDesktopPan();
      }
    });
    return KeyEventResult.handled;
  }

  Size? _interactiveViewportSize() {
    final renderObject = _interactiveViewerKey.currentContext
        ?.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.size;
    }
    return null;
  }

  Offset _clampMapViewportOffset(Offset offset) {
    final viewportSize = _interactiveViewportSize();
    if (viewportSize == null) {
      return offset;
    }
    final scale = _baseMapScale * _zoomMultiplier;
    final scaledWidth = mapWidth * scale;
    final scaledHeight = mapHeight * scale;
    final minDx = min(0.0, viewportSize.width - scaledWidth);
    final minDy = min(0.0, viewportSize.height - scaledHeight);
    return Offset(offset.dx.clamp(minDx, 0.0), offset.dy.clamp(minDy, 0.0));
  }

  Offset _viewportCentroid(Iterable<Offset> positions) {
    double dx = 0;
    double dy = 0;
    int count = 0;
    for (final position in positions) {
      dx += position.dx;
      dy += position.dy;
      count++;
    }
    if (count == 0) {
      return Offset.zero;
    }
    return Offset(dx / count, dy / count);
  }

  double _viewportPointerSpread(Iterable<Offset> positions) {
    final values = positions.take(2).toList(growable: false);
    if (values.length < 2) {
      return 0;
    }
    return (values[0] - values[1]).distance;
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

  bool _isHeroAlive(int heroIndex) => _heroUnits[heroIndex].isAlive;

  bool _containsTargetableEnemy(_Enemy? enemy) {
    return enemy != null &&
        _enemies.contains(enemy) &&
        _isEnemyTargetable(enemy);
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

  double _heroCurrentAttackRange(int heroIndex) {
    if (_isThalor(heroIndex) && _thalorMode == _ThalorMode.sword) {
      return swordRadius;
    }
    if (_isMyris(heroIndex) && _myrisMode == _MyrisMode.freeze) {
      return 200 * heroAttackRangeMultiplier;
    }
    if (_isKaelen(heroIndex) && _kaelenMode == _KaelenMode.vine) {
      return 100 * heroAttackRangeMultiplier;
    }
    if (_isKaelen(heroIndex) && _kaelenMode == _KaelenMode.healing) {
      return 100;
    }
    if (_isSolenne(heroIndex)) {
      switch (_solenneMode) {
        case _SolenneMode.sunburst:
          return 40 * heroAttackRangeMultiplier;
        case _SolenneMode.radiant:
          return 90 * heroAttackRangeMultiplier;
        case _SolenneMode.normal:
          return widget.heroes[heroIndex].attackRange;
      }
    }
    if (_isBrann(heroIndex) && _brannMode == _BrannMode.earthquake) {
      return 80 * heroAttackRangeMultiplier;
    }
    if (_isEldrin(heroIndex) && _eldrinMode == _EldrinMode.nova) {
      return 100 * heroAttackRangeMultiplier;
    }
    return widget.heroes[heroIndex].attackRange;
  }

  bool _isEnemyInHeroRange(int heroIndex, _Enemy enemy, {double? range}) {
    if (!_isEnemyTargetable(enemy) || !_isHeroAlive(heroIndex)) {
      return false;
    }
    final maxRange = range ?? _heroCurrentAttackRange(heroIndex);
    return (enemy.position - _heroPosition(heroIndex)).distance <= maxRange;
  }

  _Enemy? _forcedTargetForHero(int heroIndex) {
    final target = _heroUnits[heroIndex].forcedAttackTarget;
    return _containsTargetableEnemy(target) ? target : null;
  }

  _Enemy? _nearestEnemyForHero(
    int heroIndex, {
    _Enemy? preferredTarget,
    Set<_Enemy> exclude = const <_Enemy>{},
    double? range,
  }) {
    final maxRange = range ?? _heroCurrentAttackRange(heroIndex);
    final forcedTarget = _forcedTargetForHero(heroIndex);
    if (forcedTarget != null) {
      if (!exclude.contains(forcedTarget) &&
          _isEnemyInHeroRange(heroIndex, forcedTarget, range: maxRange)) {
        return forcedTarget;
      }
      return null;
    }
    if (_containsTargetableEnemy(preferredTarget) &&
        !exclude.contains(preferredTarget) &&
        _isEnemyInHeroRange(heroIndex, preferredTarget!, range: maxRange)) {
      return preferredTarget;
    }
    return _nearestEnemy(
      _heroPosition(heroIndex),
      exclude,
      maxDistance: maxRange,
    );
  }

  _Enemy? _hitTestEnemy(Offset position) {
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
    return hit;
  }

  void _beginEnemyDeath(_Enemy enemy, {int? killerHeroIndex}) {
    if (enemy.isDying) {
      return;
    }
    for (int i = 0; i < _heroUnits.length; i++) {
      if (identical(_heroUnits[i].forcedAttackTarget, enemy)) {
        _clearForcedAttackOrder(i);
      }
    }
    enemy
      ..hp = 0
      ..attacking = false
      ..isDying = true
      ..deathAnimTime = 0
      ..corpseFadeTime = 0;
    _floatingCoinRewards.add(_FloatingCoinReward(position: enemy.position));
    RpgSystem.addCoins(1);
    if (widget.isRumble) {
      _gatheringCoins++;
    }
    _coinsEarned++;
    _enemiesKilled++;
    if (widget.isRumble) {
      if (killerHeroIndex != null &&
          killerHeroIndex >= 0 &&
          killerHeroIndex < _heroUnits.length) {
        final killer = _heroUnits[killerHeroIndex];
        final progress = killer.rumbleProgress;
        if (progress != null && progress.addXp(1)) {
          killer.maxHp = widget.heroes[killerHeroIndex].maxHp *
              progress.statMultiplier;
          if (killer.isAlive) {
            killer.hp = killer.maxHp;
          }
        }
      }
    } else {
      for (final hero in widget.heroes) {
        _xpEarned[hero.name] = (_xpEarned[hero.name] ?? 0) + 1;
      }
    }
    SoundManager().playDeath();
  }

  int? _hitTestHero(Offset position) {
    for (int i = _heroUnits.length - 1; i >= 0; i--) {
      if (!_heroUnits[i].isAlive) {
        continue;
      }
      final hitBox = Rect.fromCenter(
        center: _heroUnits[i].position.translate(0, 5),
        width: _heroWidgetWidthForIndex(i),
        height: _heroWidgetHeightForIndex(i),
      );
      if (hitBox.contains(position)) {
        return i;
      }
    }
    return null;
  }

  void _showHeroRangeIndicator(int heroIndex) {
    _showHeroRangeIndicators(<int>{heroIndex});
  }

  void _showHeroRangeIndicators(Set<int> heroIndices) {
    _rangeIndicatorHeroIndices
      ..clear()
      ..addAll(heroIndices.where(_isHeroAlive));
    if (_rangeIndicatorHeroIndices.isEmpty) {
      _rangeIndicatorShownAt = null;
      return;
    }
    _rangeIndicatorShownAt = _lastTime;
  }

  void _clearHeroRangeIndicator() {
    _rangeIndicatorHeroIndices.clear();
    _rangeIndicatorShownAt = null;
  }

  bool get _isMultiSelectMode => _multiSelectedHeroIndices.isNotEmpty;

  Rect _selectionSquareFromPoints(Offset start, Offset current) {
    final dx = current.dx - start.dx;
    final dy = current.dy - start.dy;
    final side = max(dx.abs(), dy.abs());
    final end = Offset(
      start.dx + (dx >= 0 ? side : -side),
      start.dy + (dy >= 0 ? side : -side),
    );
    return Rect.fromPoints(start, end);
  }

  Rect? _activeSelectionSquare() {
    final start = _pointerDownScenePosition;
    final current = _selectionDragCurrent;
    if (start == null ||
        current == null ||
        (_pointerDownHeroIndex != null && !widget.isRumble)) {
      return null;
    }
    if ((current - start).distance < multiSelectDragThreshold) {
      return null;
    }
    return _selectionSquareFromPoints(start, current);
  }

  void _issueMoveOrder(int heroIndex, Offset target) {
    final unit = _heroUnits[heroIndex];
    unit
      ..forcedAttackTarget = null
      ..homePosition = target
      ..hasManualMoveOrder = true
      ..defensiveRetreatLockUntil = 0
      ..target = target
      ..isMoving = (unit.position - target).distance > 0.01;
  }

  void _showTargetIndicatorAt(Offset target) {
    setState(() {
      _targetIndicator = target;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _targetIndicator = null;
      });
    });
  }

  Offset _attackApproachTarget(int heroIndex, _Enemy enemy) {
    final heroPos = _heroPosition(heroIndex);
    final desiredDistance = max(
      24.0,
      _heroCurrentAttackRange(heroIndex) - offensiveRangePadding,
    );
    final delta = heroPos - enemy.position;
    if (delta.distance <= 0.001) {
      return _clampHeroTarget(enemy.position.translate(-desiredDistance, 0));
    }
    final direction = delta / delta.distance;
    return _clampHeroTarget(enemy.position + direction * desiredDistance);
  }

  void _issueAttackOrder(int heroIndex, _Enemy enemy) {
    final unit = _heroUnits[heroIndex];
    final target = _attackApproachTarget(heroIndex, enemy);
    unit
      ..forcedAttackTarget = enemy
      ..homePosition = target
      ..hasManualMoveOrder = true
      ..defensiveRetreatLockUntil = 0
      ..target = target
      ..isMoving = (unit.position - target).distance > 0.01;
  }

  void _issueMultiAttackOrder(_Enemy enemy) {
    final heroIndices = _multiSelectedHeroIndices.where(_isHeroAlive).toList()
      ..sort();
    for (final heroIndex in heroIndices) {
      _issueAttackOrder(heroIndex, enemy);
    }
  }

  void _clearForcedAttackOrder(int heroIndex, {bool stopMovement = true}) {
    final unit = _heroUnits[heroIndex];
    unit.forcedAttackTarget = null;
    unit.hasManualMoveOrder = false;
    if (stopMovement) {
      unit
        ..target = unit.position
        ..isMoving = false;
    }
  }

  void _issueMultiMoveOrder(Offset center) {
    final heroIndices = _multiSelectedHeroIndices.where(_isHeroAlive).toList()
      ..sort();
    if (heroIndices.isEmpty) {
      _multiSelectedHeroIndices.clear();
      return;
    }
    final columns = max(1, sqrt(heroIndices.length).ceil());
    final rows = (heroIndices.length / columns).ceil();
    final startX = center.dx - (columns - 1) * multiMoveSpacing / 2;
    final startY = center.dy - (rows - 1) * multiMoveSpacing / 2;
    for (int i = 0; i < heroIndices.length; i++) {
      final row = i ~/ columns;
      final column = i % columns;
      final target = _clampHeroTarget(
        Offset(
          startX + column * multiMoveSpacing,
          startY + row * multiMoveSpacing,
        ),
      );
      _issueMoveOrder(heroIndices[i], target);
    }
  }

  void _selectHeroesInSquare(Rect square) {
    final selected = <int>{};
    for (int i = 0; i < _heroUnits.length; i++) {
      if (!_isHeroAlive(i)) {
        continue;
      }
      if (square.contains(_heroPosition(i))) {
        selected.add(i);
      }
    }
    setState(() {
      _selectedHeroIndex = null;
      _multiSelectedHeroIndices
        ..clear()
        ..addAll(selected);
      _showHeroRangeIndicators(selected);
    });
  }

  void _selectHeroesFromCardIndices(Set<int> heroIndices) {
    final selected = heroIndices.where(_isHeroAlive).toSet();
    setState(() {
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
      _selectedHeroIndex = null;
      _multiSelectedHeroIndices
        ..clear()
        ..addAll(selected);
      _showHeroRangeIndicators(selected);
    });
  }

  double _heroRangeIndicatorOpacity() {
    final shownAt = _rangeIndicatorShownAt;
    if (shownAt == null ||
        _rangeIndicatorHeroIndices.every(
          (heroIndex) => !_isHeroAlive(heroIndex),
        )) {
      return 0;
    }
    final elapsed = _lastTime - shownAt;
    if (elapsed < 0) {
      return 0;
    }
    if (elapsed <= heroRangeIndicatorVisibleDuration) {
      return 1;
    }
    final fadeProgress =
        (elapsed - heroRangeIndicatorVisibleDuration) /
        heroRangeIndicatorFadeDuration;
    if (fadeProgress >= 1) {
      return 0;
    }
    return 1 - fadeProgress;
  }

  List<int> _activeRangeIndicatorHeroIndices() {
    if (_heroRangeIndicatorOpacity() <= 0) {
      return const <int>[];
    }
    return _rangeIndicatorHeroIndices.where(_isHeroAlive).toList()..sort();
  }

  void _selectHero(int heroIndex) {
    final shouldDeselect = _selectedHeroIndex == heroIndex;
    setState(() {
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
      if (widget.isRumble) {
        _selectedGatheringWorkerIndices.clear();
        _selectedGatheringWorkerIndex = null;
      }
      _multiSelectedHeroIndices.clear();
      _selectedHeroIndex = shouldDeselect ? null : heroIndex;
      if (shouldDeselect) {
        _clearHeroRangeIndicator();
      } else {
        _showHeroRangeIndicator(heroIndex);
      }
    });
  }

  void _centerMapOnHero(int heroIndex) {
    final viewportSize = _interactiveViewportSize();
    if (viewportSize == null || !_isHeroAlive(heroIndex)) {
      return;
    }
    final heroPosition = _heroPosition(heroIndex);
    final scale = _baseMapScale * _zoomMultiplier;
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );
    setState(() {
      _multiSelectedHeroIndices.clear();
      _selectedHeroIndex = heroIndex;
      _showHeroRangeIndicator(heroIndex);
      _mapViewportOffset = _clampMapViewportOffset(
        Offset(
          viewportCenter.dx - heroPosition.dx * scale,
          viewportCenter.dy - heroPosition.dy * scale,
        ),
      );
      _applyMapTransform();
    });
  }

  void _handleMapTap(Offset position) {
    final tappedHeroIndex = _hitTestHero(position);
    if (tappedHeroIndex != null) {
      _selectHero(tappedHeroIndex);
      return;
    }

    final tappedEnemy = _hitTestEnemy(position);
    if (tappedEnemy != null) {
      if (_isMultiSelectMode) {
        setState(() {
          _issueMultiAttackOrder(tappedEnemy);
          _multiSelectedHeroIndices.clear();
          _selectedHeroIndex = null;
        });
        return;
      }

      final selectedHeroIndex = _selectedHeroIndex;
      if (selectedHeroIndex != null && _isHeroAlive(selectedHeroIndex)) {
        setState(() {
          _issueAttackOrder(selectedHeroIndex, tappedEnemy);
          _selectedHeroIndex = null;
        });
        return;
      }
    }

    if (_isMultiSelectMode) {
      final target = _clampHeroTarget(position);
      setState(() {
        _issueMultiMoveOrder(target);
        _multiSelectedHeroIndices.clear();
      });
      _showTargetIndicatorAt(target);
      return;
    }

    final selectedHeroIndex = _selectedHeroIndex;
    if (selectedHeroIndex == null || !_isHeroAlive(selectedHeroIndex)) {
      return;
    }

    final target = _clampHeroTarget(position);
    setState(() {
      _issueMoveOrder(selectedHeroIndex, target);
      _selectedHeroIndex = null;
    });
    _showTargetIndicatorAt(target);
  }

  int _totalEnemiesForCurrentWave() => _enemiesInWave;

  _HeroUnit _initialHeroUnit(int index) {
    final count = max(1, widget.heroes.length);
    final spacing = cameraReferenceHeight / (count + 1);
    final position = Offset(
      _minimumHeroX + heroUnitSize * 0.45,
      spacing * (index + 1),
    );
    return _HeroUnit(
      position: position,
      target: position,
      homePosition: position,
      hp: widget.heroes[index].maxHp,
      maxHp: widget.heroes[index].maxHp,
      rumbleProgress: widget.isRumble ? RumbleHeroProgress() : null,
    );
  }

  Offset _heroPosition(int heroIndex) => _heroUnits[heroIndex].position;

  double get _minimumHeroX => heroAreaWidth + 4 + heroWallStopPadding;

  Offset _clampHeroTarget(Offset position) {
    final padding = heroUnitSize * 0.6;
    return Offset(
      position.dx.clamp(_minimumHeroX, mapWidth - padding),
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
    if (dt <= 0 || _gameOver || _levelCompleted) {
      setState(() {});
      return;
    }

    final navigation = _navigation;
    for (final unit in _heroUnits) {
      if (unit.isAlive) unit.position = navigation.outside(unit.position);
    }
    for (final worker in _gatheringWorkers) {
      if (worker.isAlive) worker.position = navigation.outside(worker.position);
    }
    for (final enemy in _enemies) {
      if (_isEnemyTargetable(enemy)) enemy.position = navigation.outside(enemy.position);
    }
    if (widget.isGathering) {
      _updateGathering(dt);
      _separateAllUnits();
      _updateMapJoystickPan(dt);
      setState(() {});
      return;
    }

    _updateSpawning(dt);
    _updateEnemies(dt);
    _updateProjectiles(dt);
    _updateEnemyProjectiles(dt);
    _updateTower(dt);
    _updateHeroAttackAnimations(dt, rawDt);
    _updateMapJoystickPan(dt);
    _updateHeroBehaviorTargets();
    _updateHeroMovement(dt);
    _updateHero(dt);
    if (widget.isRumble) {
      _updateGathering(dt);
    }
    _separateAllUnits();
    _updateEffects(dt);

    if (_wallHp <= 0) {
      _wallHp = 0;
      _gameOver = true;
      SoundManager().playGameOver();
    }

    if (_didCompleteLevel) {
      _levelCompleted = true;
      _markLevelCompleted();
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
    if (_levelCompleted && !_levelCompleteDialogShown) {
      _levelCompleteDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showLevelCompleteDialog();
        }
      });
    }
  }

  bool get _didCompleteLevel {
    if (!_levelDataReady || _levelDef.waves.isEmpty) {
      return false;
    }
    final isFinalWave = _currentWave >= _levelDef.waves.length;
    final allSpawnsConsumed =
        _nextWaveSpawnIndex >= _scheduledWaveSpawns.length;
    return isFinalWave && allSpawnsConsumed && !_hasTargetableEnemies;
  }

  void _updateSpawning(double dt) {
    if (!_levelDataReady) {
      return;
    }

    if (_scheduledWaveSpawns.isEmpty) {
      if (_currentWave < _levelDef.waves.length && !_hasTargetableEnemies) {
        _currentWave++;
        _prepareWaveRuntime();
      }
      return;
    }

    _waveElapsedTime += dt;
    while (_nextWaveSpawnIndex < _scheduledWaveSpawns.length &&
        _scheduledWaveSpawns[_nextWaveSpawnIndex].time <= _waveElapsedTime) {
      final spawn = _scheduledWaveSpawns[_nextWaveSpawnIndex];
      final lane = (spawn.lane - 1).clamp(0, enemyLanes - 1).toInt();
      final spawnedHp =
          spawn.enemyType.baseHp * spawn.hpMultiplier * _levelEnemyHpMultiplier;
      _enemies.add(
        _Enemy(
          position: _enemySpawnPosition(lane),
          animationOffset: _rng.nextDouble() * 10,
          hp: spawnedHp,
          maxHp: spawnedHp,
          seed: (_rng.nextDouble() * 1000) + spawn.seedOffset,
          speed: spawn.enemyType.baseSpeed * spawn.speedMultiplier,
          damagePerSecond: spawn.enemyType.baseDamagePerSecond,
          typeId: spawn.enemyType.id,
          isRanged: spawn.enemyType.isRanged,
          rangedAttackRange: spawn.enemyType.rangedAttackRange,
          rangedAttackCooldown: spawn.enemyType.rangedAttackCooldown,
          projectileDamage: spawn.enemyType.projectileDamage,
        ),
      );
      _enemiesSpawnedInWave++;
      _nextWaveSpawnIndex++;
    }

    final currentWaveIndex = _currentWave - 1;
    final waveCompleteCondition = currentWaveIndex < _levelDef.waves.length
        ? (_levelDef.waves[currentWaveIndex].completeWhenNoEnemies
              ? !_hasTargetableEnemies
              : true)
        : false;
    if (currentWaveIndex < _levelDef.waves.length &&
        _nextWaveSpawnIndex >= _scheduledWaveSpawns.length &&
        waveCompleteCondition) {
      if (_currentWave < _levelDef.waves.length) {
        final rumbleElapsedSinceStart = widget.isRumble
            ? max(0.0, _waveElapsedTime -
                _levelDef.waves[currentWaveIndex].startDelay)
            : 0.0;
        _currentWave++;
        _prepareWaveRuntime();
        if (widget.isRumble) {
          _waveElapsedTime = rumbleElapsedSinceStart;
        }
        SoundManager().playWaveComplete();
      }
    }
  }

  Offset _enemySpawnPosition(int lane) {
    var best = Offset(mapWidth, _enemyLaneCenterY(lane));
    var bestClearance = -1.0;
    for (int attempt = 0; attempt < 16; attempt++) {
      final candidate = Offset(
        mapWidth + _rng.nextDouble() * enemySize,
        (_enemyLaneCenterY(lane) +
            (_rng.nextDouble() - 0.5) * enemyLaneHeight * 0.8)
            .clamp(enemySize / 2, mapHeight - enemySize / 2).toDouble(),
      );
      var clearance = double.infinity;
      for (final other in _enemies) {
        if (!_isEnemyTargetable(other)) continue;
        clearance = min(clearance, (candidate - other.position).distance);
      }
      if (clearance > bestClearance) {
        best = candidate;
        bestClearance = clearance;
      }
      if (clearance >= enemySeparationDistance) break;
    }
    return best;
  }

  void _updateEnemies(double dt) {
    for (final enemy in _enemies) {
      if (enemy.isDying) {
        continue;
      }
      enemy.navigationRefreshRemaining -= dt;
      enemy.targetScanRemaining -= dt;
      if (enemy.attackCooldownRemaining > 0) {
        enemy.attackCooldownRemaining = max(
          0,
          enemy.attackCooldownRemaining - dt,
        );
      }
      if (enemy.position.dx <= heroAreaWidth + 4) {
        enemy.attacking = true;
        _wallHp -= wallDps * dt;
        _wallHitEffectRemaining = max(
          _wallHitEffectRemaining,
          wallHitEffectDuration,
        );
        continue;
      }
      final combatTarget = _enemyCombatTarget(enemy);
      if (combatTarget != null) {
        final attackRange = enemy.isRanged
            ? enemy.rangedAttackRange
            : combatTarget.workerIndex != null
                ? enemyWorkerContactRange
                : enemyHeroContactRange;
        // A stable point on the right-hand arc keeps the target ahead on X.
        final angle = (enemy.seed % 1 - 0.5) * pi * 0.85;
        final approach = combatTarget.position +
            Offset(cos(angle), sin(angle)) * (attackRange * 0.92);
        _moveEnemyTowards(enemy, approach, dt);
        if ((combatTarget.position - enemy.position).distance <= attackRange) {
          enemy.attacking = true;
          if (enemy.isRanged) {
            if (enemy.attackCooldownRemaining <= 0) {
              _fireEnemyProjectile(
                enemy,
                combatTarget.position,
                targetHeroIndex: combatTarget.heroIndex,
                targetWorkerIndex: combatTarget.workerIndex,
              );
              enemy.attackCooldownRemaining = enemy.rangedAttackCooldown;
            }
          } else {
            if (combatTarget.heroIndex != null) {
              _applyHeroDamage(
                combatTarget.heroIndex!,
                enemy.damagePerSecond * dt,
              );
            } else if (combatTarget.workerIndex != null) {
              _applyGatheringWorkerDamage(
                combatTarget.workerIndex!,
                enemy.damagePerSecond * dt,
              );
            }
          }
        } else {
          enemy.attacking = false;
        }
      } else if (enemy.position.dx > heroAreaWidth + 4) {
        _moveEnemyTowards(
          enemy, enemy.wallDestination ??=
              Offset(heroAreaWidth + 4, enemy.position.dy), dt,
        );
        enemy.attacking = false;
      }
    }
    _enemies.removeWhere((e) => e.canRemove);
  }

  void _moveEnemyTowards(_Enemy enemy, Offset target, double dt) {
    final navigation = _navigation;
    // Track unobstructed targets immediately; hold the routed destination between
    // staggered refreshes so a moving hero does not invalidate A* every frame.
    if (enemy.navigationDestination == null ||
        enemy.navigationRefreshRemaining <= 0 ||
        navigation.clear(enemy.position, target)) {
      enemy.navigationDestination = target;
      enemy.navigationRefreshRemaining = 0.4 + (enemy.seed % 1) * 0.2;
    }
    enemy.position = navigation.move(enemy.position,
        enemy.navigationDestination!, enemy.speed * dt, routeKey: enemy);
  }

  void _separateAllUnits() {
    final navigation = _navigation;
    final units = <SpacingUnit>[];
    final apply = <void Function(Offset)>[];
    for (final hero in _heroUnits) {
      if (!hero.isAlive) continue;
      units.add(SpacingUnit(navigation.outside(hero.position), heroSpacingRadius));
      apply.add((position) {
        final offset = position - hero.position;
        hero.position = position;
        if (!hero.isMoving) {
          hero.target = position;
          hero.homePosition += offset;
        }
      });
    }
    for (final worker in _gatheringWorkers) {
      if (!worker.isAlive) continue;
      units.add(SpacingUnit(navigation.outside(worker.position), workerSpacingRadius));
      apply.add((position) => worker.position = position);
    }
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) continue;
      units.add(SpacingUnit(navigation.outside(enemy.position), enemySpacingRadius));
      apply.add((position) => enemy.position = position);
    }
    separateUnits(units, navigation.bounds,
        navigation.canStand,
        canRelocate: navigation.clear);
    for (var i = 0; i < units.length; i++) {
      apply[i](units[i].position);
    }
  }

  void _updateHeroBehaviorTargets() {
    for (int i = 0; i < _heroUnits.length; i++) {
      if (!_isHeroAlive(i)) {
        continue;
      }
      final forcedTarget = _forcedTargetForHero(i);
      if (forcedTarget != null) {
        _updateForcedAttackTarget(i, forcedTarget);
        continue;
      }
      if (_heroUnits[i].forcedAttackTarget != null) {
        _clearForcedAttackOrder(i);
      }
      if (_heroUnits[i].hasManualMoveOrder) {
        continue;
      }
      switch (_heroBehaviors[i]) {
        case _HeroBehaviorMode.holdPosition:
          break;
        case _HeroBehaviorMode.offensive:
          _updateOffensiveBehaviorTarget(i);
          break;
        case _HeroBehaviorMode.defensive:
          _updateDefensiveBehaviorTarget(i);
          break;
      }
    }
  }

  void _updateForcedAttackTarget(int heroIndex, _Enemy enemy) {
    final unit = _heroUnits[heroIndex];
    if (_isEnemyInHeroRange(heroIndex, enemy)) {
      unit
        ..target = unit.position
        ..isMoving = false;
      return;
    }
    final target = _attackApproachTarget(heroIndex, enemy);
    unit
      ..homePosition = target
      ..hasManualMoveOrder = true
      ..defensiveRetreatLockUntil = 0
      ..target = target;
  }

  void _updateOffensiveBehaviorTarget(int heroIndex) {
    final unit = _heroUnits[heroIndex];
    final enemy = _nearestEnemy(unit.position, const <_Enemy>{});
    if (enemy == null) {
      unit.target = unit.position;
      return;
    }
    if (_isEnemyInHeroRange(heroIndex, enemy)) {
      unit.target = unit.position;
      return;
    }
    unit.target = _offensiveApproachTarget(heroIndex, enemy);
  }

  void _updateDefensiveBehaviorTarget(int heroIndex) {
    final unit = _heroUnits[heroIndex];
    if (unit.defensiveRetreatLockUntil > _lastTime) {
      return;
    }
    final threatRange = enemyHeroContactRange + defensiveThreatPadding;
    final threat = _nearestEnemy(
      unit.position,
      const <_Enemy>{},
      maxDistance: threatRange,
    );
    if (threat != null) {
      unit
        ..target = _defensiveRetreatTarget(heroIndex, threat)
        ..defensiveRetreatLockUntil = _lastTime + defensiveRetreatMinDuration;
      return;
    }

    final hasEnemyInAttackRange = _nearestEnemyForHero(heroIndex) != null;
    if (!hasEnemyInAttackRange &&
        (unit.position - unit.homePosition).distance >
            defensiveReturnTolerance) {
      unit.target = unit.homePosition;
      return;
    }

    unit.target = unit.position;
  }

  Offset _offensiveApproachTarget(int heroIndex, _Enemy enemy) {
    return _attackApproachTarget(heroIndex, enemy);
  }

  Offset _defensiveRetreatTarget(int heroIndex, _Enemy enemy) {
    final heroPos = _heroPosition(heroIndex);
    final safeDistance = max(
      max(
        enemyHeroContactRange + defensiveRetreatPadding,
        heroMoveSpeed * defensiveRetreatMinDuration,
      ),
      _heroCurrentAttackRange(heroIndex) * 0.7,
    );
    final delta = heroPos - enemy.position;
    if (delta.distance <= 0.001) {
      return _clampHeroTarget(heroPos.translate(-safeDistance, 0));
    }
    final direction = delta / delta.distance;
    return _clampHeroTarget(enemy.position + direction * safeDistance);
  }

  void _updateHeroAttackAnimations(double dt, double rawDt) {
    for (int i = 0; i < _heroAttackAnimationRemainingTimes.length; i++) {
      final remaining = _heroAttackAnimationRemainingTimes[i];
      if (remaining <= 0) {
        continue;
      }
      final animationDt = _isAerin(i) ? rawDt : dt;
      _heroAttackAnimationRemainingTimes[i] = max(0.0, remaining - animationDt);
    }
  }

  void _updateHeroMovement(double dt) {
    for (int i = 0; i < _heroUnits.length; i++) {
      final unit = _heroUnits[i];
      if (!unit.isAlive) {
        continue;
      }
      unit.target = _navigation.outside(unit.target);
      final next = _navigation.move(unit.position, unit.target, _heroMoveSpeedFor(i) * dt, routeKey: unit);
      unit.position = next;
      unit.isMoving = (unit.target - next).distance > 0.01;
      if (!unit.isMoving) {
        unit.hasManualMoveOrder = false;
        _tryPerformQueuedAttackAfterMovement(i);
      }
    }
  }

  void _tryPerformQueuedAttackAfterMovement(int heroIndex) {
    final state = _heroStates[heroIndex];
    if (state.phase != _HeroPhase.sending ||
        !state.pendingAttack ||
        !_isHeroAlive(heroIndex)) {
      return;
    }
    final forcedTarget = _forcedTargetForHero(heroIndex);
    if (_heroCanAutoAttackNow(heroIndex)) {
      state.pendingAttack = false;
      _performAttack(heroIndex, target: forcedTarget);
    } else {
      state
        ..phase = _HeroPhase.cooldown
        ..timeRemaining = 0
        ..pendingAttack = false
        ..beamTarget = null;
    }
  }

  void _updateProjectiles(double dt) {
    for (final proj in _projectiles) {
      proj.position = proj.position.translate(
        proj.velocity.dx * dt,
        proj.velocity.dy * dt,
      );
    }

    for (final proj in List<_Projectile>.from(_projectiles)) {
      _Enemy? hit;
      for (final enemy in _enemies) {
        if (!_isEnemyTargetable(enemy)) {
          continue;
        }
        if ((enemy.position - proj.position).distance <=
            enemySize / 2 + proj.radius) {
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
              _applyDamage(enemy, proj.damage, heroIndex: proj.heroIndex);
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
          _applyDamage(hit, proj.damage, heroIndex: proj.heroIndex);
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
      } else if (proj.position.dx > mapWidth + 10 ||
          proj.position.dy < -10 ||
          proj.position.dy > mapHeight + 10) {
        _projectiles.remove(proj);
      }
    }
  }

  double _heroMoveSpeedFor(int heroIndex) {
    if (_isBrann(heroIndex)) {
      return heroMoveSpeed * brannMoveSpeedMultiplier;
    }
    return heroMoveSpeed;
  }

  Future<void> _reviveHero(int heroIndex) async {
    if (heroIndex < 0 || heroIndex >= _heroUnits.length) {
      return;
    }
    if (_heroUnits[heroIndex].isAlive) {
      return;
    }
    if (_gatheringCoins < heroReviveCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nedostatek zlata na oziveni hrdiny.')),
      );
      return;
    }
    final respawnUnit = _initialHeroUnit(heroIndex);
    setState(() {
      _gatheringCoins -= heroReviveCost;
      _heroUnits[heroIndex]
        ..position = respawnUnit.position
        ..target = respawnUnit.target
        ..homePosition = respawnUnit.homePosition
        ..hp = _heroUnits[heroIndex].maxHp
        ..isMoving = false
        ..isAlive = true
        ..hasManualMoveOrder = false
        ..defensiveRetreatLockUntil = 0
        ..forcedAttackTarget = null;
      _heroStates[heroIndex]
        ..phase = _HeroPhase.cooldown
        ..timeRemaining = 0
        ..pendingAttack = false
        ..magicEnergy = heroMagicEnergyMax
        ..attackFlipHorizontally = false
        ..beamTarget = null;
      _heroAttackAnimationRemainingTimes[heroIndex] = 0;
    });
    await RpgSystem.addCoins(-heroReviveCost);
    await RpgSystem.saveProgress();
  }

  double _heroWidgetWidthForIndex(int heroIndex) {
    if (_isBrann(heroIndex)) {
      return heroRenderSize * _HeroUnitWidget.brannWidgetWidthFactor;
    }
    return heroRenderSize + 18;
  }

  double _heroWidgetHeightForIndex(int heroIndex) {
    if (_isBrann(heroIndex)) {
      return heroRenderSize * _HeroUnitWidget.brannWidgetHeightFactor + 20;
    }
    return heroRenderSize + 22;
  }

  void _updateEnemyProjectiles(double dt) {
    for (final proj in _enemyProjectiles) {
      if (proj.isImpacting) {
        proj.impactTimeRemaining = max(0, proj.impactTimeRemaining - dt);
      } else {
        proj.position = proj.position.translate(
          proj.velocity.dx * dt,
          proj.velocity.dy * dt,
        );
      }
      proj.animTime += dt;
    }

    for (final proj in List<_EnemyProjectile>.from(_enemyProjectiles)) {
      if (proj.isImpacting) {
        if (proj.impactTimeRemaining <= 0) {
          _enemyProjectiles.remove(proj);
        }
        continue;
      }
      int? hitHeroIndex = proj.targetHeroIndex;
      int? hitWorkerIndex = proj.targetWorkerIndex;
      if (hitHeroIndex != null &&
          (!_isHeroAlive(hitHeroIndex) ||
              (_heroUnits[hitHeroIndex].position - proj.position).distance >
                  heroUnitSize * 0.35 + proj.radius)) {
        hitHeroIndex = null;
      }
      if (hitWorkerIndex != null &&
          (hitWorkerIndex < 0 ||
              hitWorkerIndex >= _gatheringWorkers.length ||
              !_gatheringWorkers[hitWorkerIndex].isAlive ||
              (_gatheringWorkers[hitWorkerIndex].position - proj.position)
                      .distance >
                  gatheringWorkerSize * 0.45 + proj.radius)) {
        hitWorkerIndex = null;
      }
      if (hitHeroIndex == null && hitWorkerIndex == null) {
        for (int i = 0; i < _heroUnits.length; i++) {
          if (!_isHeroAlive(i)) {
            continue;
          }
          if ((_heroUnits[i].position - proj.position).distance <=
              heroUnitSize * 0.35 + proj.radius) {
            hitHeroIndex = i;
            break;
          }
        }
      }
      if (hitHeroIndex == null && hitWorkerIndex == null) {
        for (int i = 0; i < _gatheringWorkers.length; i++) {
          if (!_gatheringWorkers[i].isAlive) {
            continue;
          }
          if ((_gatheringWorkers[i].position - proj.position).distance <=
              gatheringWorkerSize * 0.45 + proj.radius) {
            hitWorkerIndex = i;
            break;
          }
        }
      }
      if (hitHeroIndex != null) {
        _applyHeroDamage(hitHeroIndex, proj.damage);
        proj
          ..position = _heroUnits[hitHeroIndex].position
          ..isImpacting = true
          ..impactTimeRemaining =
              _EnemyProjectile.impactFrameCount *
              _GameViewState.zombieShooterProjectileFrameDuration
          ..animTime = 0;
      } else if (hitWorkerIndex != null) {
        _applyGatheringWorkerDamage(hitWorkerIndex, proj.damage);
        proj
          ..position = _gatheringWorkers[hitWorkerIndex].position
          ..isImpacting = true
          ..impactTimeRemaining =
              _EnemyProjectile.impactFrameCount *
              _GameViewState.zombieShooterProjectileFrameDuration
          ..animTime = 0;
      } else if (proj.position.dx < heroAreaWidth - 20 ||
          proj.position.dx > mapWidth + 20 ||
          proj.position.dy < -20 ||
          proj.position.dy > mapHeight + 20) {
        _enemyProjectiles.remove(proj);
      }
    }
  }

  void _updateTower(double dt) {
    for (final site in _constructionSites) {
      if (!site.isComplete) {
        continue;
      }
      site.cooldownRemaining = max(0, site.cooldownRemaining - dt);
      if (site.cooldownRemaining > 0) {
        continue;
      }
      final target = _nearestEnemy(
        site.position,
        const <_Enemy>{},
        maxDistance: towerRange,
      );
      if (target != null) {
        if (site.type == _ConstructionType.lightning) {
          _lightnings.add(_LightningEffect(segments: [
            _LightningSegment(
              start: site.position,
              end: target.position,
              seed: _rng.nextDouble() * 1000,
            ),
          ]));
          _applyDamage(target, site.damage);
        } else {
          _fireTowerProjectile(target, origin: site.position, damage: site.damage);
        }
        site.cooldownRemaining = towerCooldownDuration;
      }
    }
    _towerCooldownRemaining = max(0, _towerCooldownRemaining - dt);
    if (_towerCooldownRemaining > 0) {
      return;
    }
    final target = _nearestEnemy(
      towerPosition,
      const <_Enemy>{},
      maxDistance: towerRange,
    );
    if (target == null) {
      return;
    }
    _fireTowerProjectile(target);
    _towerCooldownRemaining = towerCooldownDuration;
  }

  void _fireTowerProjectile(
    _Enemy target, {
    Offset origin = towerPosition,
    double damage = towerDamage,
  }) {
    final dir = target.position - origin;
    final len = max(dir.distance, 0.001);
    final velocity = Offset(
      dir.dx / len * projectileSpeed,
      dir.dy / len * projectileSpeed,
    );
    _projectiles.add(
      _Projectile(
        position: origin,
        velocity: velocity,
        damage: damage,
        radius: projectileRadius + 1,
        aoeRadius: 0,
        isAerinStrong: false,
        seed: _rng.nextDouble() * 1000,
        color: const Color(0xFF7CE7FF),
      ),
    );
  }

  void _updateHero(double dt) {
    for (int i = 0; i < _heroStates.length; i++) {
      if (!_isHeroAlive(i)) {
        continue;
      }
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
          if (_heroCanAutoAttackNow(i)) {
            _enterSending(i);
          } else {
            state.timeRemaining = 0;
          }
        }
      }
    }
  }

  bool _heroCanAutoAttackNow(int heroIndex) {
    if (!_isHeroAlive(heroIndex)) {
      return false;
    }
    if (_heroStates[heroIndex].magicEnergy <= 0) {
      return false;
    }
    if (_isKaelen(heroIndex) && _kaelenMode == _KaelenMode.healing) {
      return true;
    }
    final forcedTarget = _forcedTargetForHero(heroIndex);
    if (forcedTarget != null) {
      return _isEnemyInHeroRange(heroIndex, forcedTarget);
    }
    return _nearestEnemyForHero(heroIndex) != null;
  }

  void _applyDamage(_Enemy enemy, double damage, {int? heroIndex}) {
    if (enemy.isDying) {
      return;
    }
    enemy.hp -= damage;
    enemy.flashRemaining = hitFlashDuration;
    final spriteConfig =
        _enemySpriteConfigs[enemy.typeId] ?? _enemySpriteConfigs['fat_zombie']!;
    if (spriteConfig.hitFrameStart != null && spriteConfig.hitFrameCount > 0) {
      enemy.hitAnimRemaining =
          spriteConfig.hitFrameCount * enemyHitFrameDuration;
    }
    enemy.pendingDamage += damage;
    if (enemy.damageTextCooldown <= 0) {
      _damageTexts.add(
        _DamageText(position: enemy.position, value: enemy.pendingDamage),
      );
      enemy.pendingDamage = 0;
      enemy.damageTextCooldown = 0.35;
    }
    if (enemy.hp <= 0) {
      _beginEnemyDeath(enemy, killerHeroIndex: heroIndex);
    }
  }

  int? _nearestHeroAheadOfEnemy(_Enemy enemy) {
    int? bestIndex;
    double bestDistance = double.infinity;
    for (int i = 0; i < _heroUnits.length; i++) {
      final hero = _heroUnits[i];
      if (!hero.isAlive || hero.position.dx >= enemy.position.dx) {
        continue;
      }
      final distance = (hero.position - enemy.position).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static const double enemyDetectionRadius = 500;
  static const double enemyPursuitRadius = 650;

  _EnemyCombatTarget? _enemyCombatTarget(_Enemy enemy) {
    final locked = enemy.combatTarget;
    if (locked != null) {
      _EnemyCombatTarget? current;
      final heroIndex = locked.heroIndex;
      final workerIndex = locked.workerIndex;
      if (heroIndex != null && _isHeroAlive(heroIndex)) {
        current = _EnemyCombatTarget(
            position: _heroUnits[heroIndex].position, heroIndex: heroIndex);
      } else if (workerIndex != null &&
          workerIndex < _gatheringWorkers.length &&
          _gatheringWorkers[workerIndex].isAlive) {
        current = _EnemyCombatTarget(
            position: _gatheringWorkers[workerIndex].position,
            workerIndex: workerIndex);
      }
      if (current != null &&
          (current.position - enemy.position).distanceSquared <=
              enemyPursuitRadius * enemyPursuitRadius) {
        return current;
      }
      enemy.combatTarget = null;
      enemy.navigationDestination = null;
      enemy.wallDestination = null;
      enemy.targetScanRemaining = 0;
    }
    if (enemy.targetScanRemaining > 0) return null;
    enemy.targetScanRemaining = 0.2 + (enemy.seed % 1) * 0.2;
    final target = _nearestCombatTargetInDetectionRadius(enemy);
    if (target != null) {
      enemy.combatTarget = target;
      enemy.navigationDestination = null;
      enemy.wallDestination = null;
    }
    return target;
  }

  _EnemyCombatTarget? _nearestCombatTargetInDetectionRadius(_Enemy enemy) {
    _EnemyCombatTarget? nearest;
    var nearestDistance = enemyDetectionRadius * enemyDetectionRadius;
    for (int index = 0; index < _heroUnits.length; index++) {
      if (!_isHeroAlive(index)) {
        continue;
      }
      final distance = (_heroUnits[index].position - enemy.position).distanceSquared;
      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nearest = _EnemyCombatTarget(
          position: _heroUnits[index].position,
          heroIndex: index,
        );
      }
    }
    for (int index = 0; index < _gatheringWorkers.length; index++) {
      final worker = _gatheringWorkers[index];
      if (!worker.isAlive) {
        continue;
      }
      final distance = (worker.position - enemy.position).distanceSquared;
      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nearest = _EnemyCombatTarget(
          position: worker.position,
          workerIndex: index,
        );
      }
    }
    return nearest;
  }

  void _applyHeroDamage(int heroIndex, double damage) {
    final hero = _heroUnits[heroIndex];
    if (!hero.isAlive || damage <= 0) {
      return;
    }
    hero.hp = max(0, hero.hp - damage);
    if (hero.hp <= 0) {
      hero
        ..isAlive = false
        ..isMoving = false
        ..target = hero.position;
      final state = _heroStates[heroIndex];
      state
        ..pendingAttack = false
        ..beamTarget = null;
      if (_selectedHeroIndex == heroIndex) {
        _selectedHeroIndex = null;
      }
      _multiSelectedHeroIndices.remove(heroIndex);
      if (_rangeIndicatorHeroIndices.remove(heroIndex) &&
          _rangeIndicatorHeroIndices.isEmpty) {
        _clearHeroRangeIndicator();
      }
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

  List<_HeroModeAction> _heroModeActions(int heroIndex) {
    final hero = widget.heroes[heroIndex];
    switch (hero.name) {
      case 'Aerin':
        return [
          _HeroModeAction(
            icon: _aerinModeIcon(_HeroMode.normal),
            selected: _aerinMode == _HeroMode.normal,
            onTap: () => _setHeroMode(heroIndex, _HeroMode.normal),
          ),
          _HeroModeAction(
            icon: _aerinModeIcon(_HeroMode.fast),
            selected: _aerinMode == _HeroMode.fast,
            onTap: () => _setHeroMode(heroIndex, _HeroMode.fast),
          ),
          _HeroModeAction(
            icon: _aerinModeIcon(_HeroMode.strong),
            selected: _aerinMode == _HeroMode.strong,
            onTap: () => _setHeroMode(heroIndex, _HeroMode.strong),
          ),
        ];
      case 'Veyra':
        return [
          _HeroModeAction(
            icon: _veyraModeIcon(_VeyraMode.rapid),
            selected: _veyraMode == _VeyraMode.rapid,
            onTap: () => _setHeroMode(heroIndex, _VeyraMode.rapid),
          ),
          _HeroModeAction(
            icon: _veyraModeIcon(_VeyraMode.explosive),
            selected: _veyraMode == _VeyraMode.explosive,
            onTap: () => _setHeroMode(heroIndex, _VeyraMode.explosive),
          ),
          _HeroModeAction(
            icon: _veyraModeIcon(_VeyraMode.lightning),
            selected: _veyraMode == _VeyraMode.lightning,
            onTap: () => _setHeroMode(heroIndex, _VeyraMode.lightning),
          ),
        ];
      case 'Thalor':
        return [
          _HeroModeAction(
            icon: _thalorModeIcon(_ThalorMode.projectile),
            selected: _thalorMode == _ThalorMode.projectile,
            onTap: () => _setHeroMode(heroIndex, _ThalorMode.projectile),
          ),
          _HeroModeAction(
            icon: _thalorModeIcon(_ThalorMode.sword),
            selected: _thalorMode == _ThalorMode.sword,
            onTap: () => _setHeroMode(heroIndex, _ThalorMode.sword),
          ),
          _HeroModeAction(
            icon: _thalorModeIcon(_ThalorMode.energy),
            selected: _thalorMode == _ThalorMode.energy,
            onTap: () => _setHeroMode(heroIndex, _ThalorMode.energy),
          ),
        ];
      case 'Nyxra':
        return [
          _HeroModeAction(
            icon: _nyxraModeIcon(_NyxraMode.normal),
            selected: _nyxraMode == _NyxraMode.normal,
            onTap: () => _setHeroMode(heroIndex, _NyxraMode.normal),
          ),
          _HeroModeAction(
            icon: _nyxraModeIcon(_NyxraMode.lightning),
            selected: _nyxraMode == _NyxraMode.lightning,
            onTap: () => _setHeroMode(heroIndex, _NyxraMode.lightning),
          ),
          _HeroModeAction(
            icon: _nyxraModeIcon(_NyxraMode.voidchain),
            selected: _nyxraMode == _NyxraMode.voidchain,
            onTap: () => _setHeroMode(heroIndex, _NyxraMode.voidchain),
          ),
        ];
      case 'Myris':
        return [
          _HeroModeAction(
            icon: _myrisModeIcon(_MyrisMode.normal),
            selected: _myrisMode == _MyrisMode.normal,
            onTap: () => _setHeroMode(heroIndex, _MyrisMode.normal),
          ),
          _HeroModeAction(
            icon: _myrisModeIcon(_MyrisMode.ice),
            selected: _myrisMode == _MyrisMode.ice,
            onTap: () => _setHeroMode(heroIndex, _MyrisMode.ice),
          ),
          _HeroModeAction(
            icon: _myrisModeIcon(_MyrisMode.freeze),
            selected: _myrisMode == _MyrisMode.freeze,
            onTap: () => _setHeroMode(heroIndex, _MyrisMode.freeze),
          ),
        ];
      case 'Kaelen':
        return [
          _HeroModeAction(
            icon: _kaelenModeIcon(_KaelenMode.normal),
            selected: _kaelenMode == _KaelenMode.normal,
            onTap: () => _setHeroMode(heroIndex, _KaelenMode.normal),
          ),
          _HeroModeAction(
            icon: _kaelenModeIcon(_KaelenMode.vine),
            selected: _kaelenMode == _KaelenMode.vine,
            onTap: () => _setHeroMode(heroIndex, _KaelenMode.vine),
          ),
          _HeroModeAction(
            icon: _kaelenModeIcon(_KaelenMode.healing),
            selected: _kaelenMode == _KaelenMode.healing,
            onTap: () => _setHeroMode(heroIndex, _KaelenMode.healing),
          ),
        ];
      case 'Solenne':
        return [
          _HeroModeAction(
            icon: _solenneModeIcon(_SolenneMode.normal),
            selected: _solenneMode == _SolenneMode.normal,
            onTap: () => _setHeroMode(heroIndex, _SolenneMode.normal),
          ),
          _HeroModeAction(
            icon: _solenneModeIcon(_SolenneMode.sunburst),
            selected: _solenneMode == _SolenneMode.sunburst,
            onTap: () => _setHeroMode(heroIndex, _SolenneMode.sunburst),
          ),
          _HeroModeAction(
            icon: _solenneModeIcon(_SolenneMode.radiant),
            selected: _solenneMode == _SolenneMode.radiant,
            onTap: () => _setHeroMode(heroIndex, _SolenneMode.radiant),
          ),
        ];
      case 'Ravik':
        return [
          _HeroModeAction(
            icon: _ravikModeIcon(_RavikMode.normal),
            selected: _ravikMode == _RavikMode.normal,
            onTap: () => _setHeroMode(heroIndex, _RavikMode.normal),
          ),
          _HeroModeAction(
            icon: _ravikModeIcon(_RavikMode.voidburst),
            selected: _ravikMode == _RavikMode.voidburst,
            onTap: () => _setHeroMode(heroIndex, _RavikMode.voidburst),
          ),
          _HeroModeAction(
            icon: _ravikModeIcon(_RavikMode.soul),
            selected: _ravikMode == _RavikMode.soul,
            onTap: () => _setHeroMode(heroIndex, _RavikMode.soul),
          ),
        ];
      case 'Brann':
        return [
          _HeroModeAction(
            icon: _brannModeIcon(_BrannMode.normal),
            selected: _brannMode == _BrannMode.normal,
            onTap: () => _setHeroMode(heroIndex, _BrannMode.normal),
          ),
          _HeroModeAction(
            icon: _brannModeIcon(_BrannMode.earthquake),
            selected: _brannMode == _BrannMode.earthquake,
            onTap: () => _setHeroMode(heroIndex, _BrannMode.earthquake),
          ),
          _HeroModeAction(
            icon: _brannModeIcon(_BrannMode.boulder),
            selected: _brannMode == _BrannMode.boulder,
            onTap: () => _setHeroMode(heroIndex, _BrannMode.boulder),
          ),
        ];
      case 'Eldrin':
        return [
          _HeroModeAction(
            icon: _eldrinModeIcon(_EldrinMode.normal),
            selected: _eldrinMode == _EldrinMode.normal,
            onTap: () => _setHeroMode(heroIndex, _EldrinMode.normal),
          ),
          _HeroModeAction(
            icon: _eldrinModeIcon(_EldrinMode.cosmic),
            selected: _eldrinMode == _EldrinMode.cosmic,
            onTap: () => _setHeroMode(heroIndex, _EldrinMode.cosmic),
          ),
          _HeroModeAction(
            icon: _eldrinModeIcon(_EldrinMode.nova),
            selected: _eldrinMode == _EldrinMode.nova,
            onTap: () => _setHeroMode(heroIndex, _EldrinMode.nova),
          ),
        ];
    }
    return const [];
  }

  Widget _buildSelectedHeroModeMenu() {
    final selectedHeroIndex = _selectedHeroIndex;
    if (selectedHeroIndex == null || !_isHeroAlive(selectedHeroIndex)) {
      return const SizedBox.shrink();
    }
    final actions = _heroModeActions(selectedHeroIndex);
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return _HeroContextModeMenu(
      center: _heroPosition(selectedHeroIndex),
      heroColor: widget.heroes[selectedHeroIndex].color,
      actions: actions,
        verticalOffset: _GameViewState.heroRenderSize * 0.55,
    );
  }

  void _setHeroBehavior(int heroIndex, _HeroBehaviorMode behavior) {
    setState(() {
      _heroBehaviors[heroIndex] = behavior;
      if (behavior != _HeroBehaviorMode.offensive) {
        final unit = _heroUnits[heroIndex];
        unit
          ..homePosition = unit.position
          ..hasManualMoveOrder = false
          ..defensiveRetreatLockUntil = 0
          ..target = unit.position
          ..isMoving = false;
      }
    });
  }

  List<_HeroModeAction> _heroBehaviorActions(int heroIndex) {
    final behavior = _heroBehaviors[heroIndex];
    return [
      _HeroModeAction(
        icon: Icons.flag,
        selected: behavior == _HeroBehaviorMode.holdPosition,
        onTap: () =>
            _setHeroBehavior(heroIndex, _HeroBehaviorMode.holdPosition),
      ),
      _HeroModeAction(
        icon: Icons.flash_on,
        selected: behavior == _HeroBehaviorMode.offensive,
        onTap: () => _setHeroBehavior(heroIndex, _HeroBehaviorMode.offensive),
      ),
      _HeroModeAction(
        icon: Icons.security,
        selected: behavior == _HeroBehaviorMode.defensive,
        onTap: () => _setHeroBehavior(heroIndex, _HeroBehaviorMode.defensive),
      ),
    ];
  }

  Widget _buildSelectedHeroBehaviorMenu() {
    final selectedHeroIndex = _selectedHeroIndex;
    if (selectedHeroIndex == null || !_isHeroAlive(selectedHeroIndex)) {
      return const SizedBox.shrink();
    }
    return _HeroContextModeMenu(
      center: _heroPosition(selectedHeroIndex),
      heroColor: widget.heroes[selectedHeroIndex].color,
      actions: _heroBehaviorActions(selectedHeroIndex),
        verticalOffset: -_GameViewState.heroRenderSize * 1.1,
    );
  }

  Future<void> _saveProgress() async {
    if (_xpEarned.isNotEmpty || _coinsEarned > 0) {
      // Award XP to heroes
      for (final entry in _xpEarned.entries) {
        await RpgSystem.addHeroXp(entry.key, entry.value);
      }

      // Auto-save
      await RpgSystem.saveProgress();

      // Reset tracking
      _xpEarned.clear();
    }
  }

  void _applyGatheringWorkerDamage(int workerIndex, double damage) {
    if (workerIndex < 0 || workerIndex >= _gatheringWorkers.length) {
      return;
    }
    final worker = _gatheringWorkers[workerIndex];
    if (!worker.isAlive || damage <= 0) {
      return;
    }
    worker.hp = max(0, worker.hp - damage);
    if (worker.hp <= 0) {
      worker
        ..isAlive = false
        ..isMoving = false
        ..destination = worker.position
        ..order = _GatheringWorkerOrder.idle
        ..attackTarget = null
        ..repeatMining = false
        ..carriedResource = null;
      _selectedGatheringWorkerIndices.remove(workerIndex);
      if (_selectedGatheringWorkerIndex == workerIndex) {
        _selectedGatheringWorkerIndex = null;
      }
    } else if (worker.order == _GatheringWorkerOrder.idle) {
      final enemy = _nearestEnemy(worker.position, const <_Enemy>{});
      if (enemy != null) {
        _issueGatheringAttackOrder(worker, enemy);
      }
    }
  }

  void _issueGatheringAttackOrder(_GatheringWorker worker, _Enemy enemy) {
    if (!worker.isAlive) {
      return;
    }
    worker
      ..constructionSite = null
      ..miningRemaining = 0
      ..repeatMining = false
      ..attackTarget = enemy
      ..order = _GatheringWorkerOrder.attack;
  }

  Widget _buildWorkerHpBar(_GatheringWorker worker) {
    final hpFraction = (worker.hp / gatheringWorkerMaxHp).clamp(0.0, 1.0);
    const barWidth = gatheringWorkerRenderSize * workerHpBarWidthFactor;
    return Container(
      width: barWidth,
      height: 9,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: const Color(0xCC160F0F),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF0A0606), width: 1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: hpFraction,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(
                    const Color(0xFFE14D4D),
                    const Color(0xFF58D68D),
                    hpFraction,
                  ) ??
                  const Color(0xFF58D68D),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  bool _isWorkerClawAttacking(_GatheringWorker worker) =>
      worker.isAlive &&
      !worker.isMoving &&
      worker.order == _GatheringWorkerOrder.attack &&
      worker.attackTarget != null;

  bool _isWorkerFacingLeft(_GatheringWorker worker) {
    if (_isWorkerClawAttacking(worker)) {
      return worker.attackTarget!.position.dx < worker.position.dx;
    }
    return worker.isMoving && worker.isMovingLeft;
  }

  // The claw swipe is synced to the attack cooldown: frame 16 is the impact
  // right after a hit, then recovery and wind-up for the next one.
  int _workerFrameIndex(_GatheringWorker worker) {
    if (_isWorkerClawAttacking(worker)) {
      final progress = 1 -
          (worker.attackCooldown / gatheringWorkerAttackInterval).clamp(0.0, 1.0);
      return 16 + min(7, (progress * 8).floor());
    }
    return (worker.isPerformingAction ? 8 : 0) +
        (worker.animationTime * 8).floor() % 8;
  }

  void _updateGatheringAttack(_GatheringWorker worker, double dt) {
    final enemy = worker.attackTarget;
    if (enemy == null || !_isEnemyTargetable(enemy) ||
        !_enemies.contains(enemy)) {
      worker
        ..attackTarget = null
        ..order = _GatheringWorkerOrder.idle
        ..isMoving = false;
      return;
    }
    final direction = enemy.position - worker.position;
    final distance = direction.distance;
    const reach = enemyWorkerContactRange;
    if (distance > reach + 0.001) {
      worker.isMoving = true;
      worker.isMovingLeft = direction.dx < 0;
      final next = _navigation.move(worker.position, enemy.position,
          min(gatheringWorkerSpeed * dt, distance - reach), routeKey: worker);
      worker.isMovingLeft = next.dx < worker.position.dx;
      worker.position = next;
      return;
    }
    worker.isMoving = false;
    if (worker.attackCooldown <= 0) {
      _applyDamage(enemy, gatheringWorkerAttackDamage);
      worker.attackCooldown = gatheringWorkerAttackInterval;
    }
  }

  void _updateGathering(double dt) {
    for (final worker in _gatheringWorkers) {
      if (!worker.isAlive) {
        continue;
      }
      worker.attackCooldown = max(0, worker.attackCooldown - dt);
      worker.animationTime = (worker.animationTime + dt) % 1.0;
      if (worker.order == _GatheringWorkerOrder.build) {
        _updateConstruction(worker, dt);
        continue;
      }
      if (worker.order == _GatheringWorkerOrder.attack) {
        _updateGatheringAttack(worker, dt);
        continue;
      }
      if (worker.miningRemaining > 0) {
        worker.isMoving = false;
        worker.miningRemaining = max(0, worker.miningRemaining - dt);
        if (worker.miningRemaining <= 0) {
          worker.carriedResource = worker.targetResource;
          worker.order = _GatheringWorkerOrder.deliver;
        }
        continue;
      }

      final requestedTarget = switch (worker.order) {
        _GatheringWorkerOrder.mineGold => _miningSpotFor(worker),
        _GatheringWorkerOrder.deliver => worker.carriedResource ==
                _GatheringResource.fragments
            ? _nearestFragmentRecipientPosition(worker.position)
            : _gatheringWallPosition,
        _GatheringWorkerOrder.move => worker.destination,
        _GatheringWorkerOrder.idle => null,
        _GatheringWorkerOrder.attack => null,
        _GatheringWorkerOrder.build => null,
      };
      if (requestedTarget == null) {
        worker.isMoving = false;
        continue;
      }
      final target = _navigation.outside(requestedTarget);
      final next = _navigation.move(worker.position, target, gatheringWorkerSpeed * dt, routeKey: worker);
      worker.isMovingLeft = next.dx < worker.position.dx;
      worker.position = next;
      worker.isMoving = (target - next).distance > 0.01;
      if (worker.isMoving) continue;
      switch (worker.order) {
        case _GatheringWorkerOrder.mineGold:
          if (worker.carriedResource == null) {
            worker.miningRemaining = gatheringMiningDuration;
          } else {
            worker.order = _GatheringWorkerOrder.deliver;
          }
          break;
        case _GatheringWorkerOrder.deliver:
          if (worker.carriedResource == _GatheringResource.gold) {
            _gatheringCoins += gatheringGoldReward;
            unawaited(_persistGatheringGold());
          } else if (worker.carriedResource == _GatheringResource.wood) {
            _gatheringWood += gatheringWoodReward;
            unawaited(_persistGatheringWood());
          } else if (worker.carriedResource == _GatheringResource.stone) {
            _gatheringStone += gatheringStoneReward;
            unawaited(_persistGatheringStone());
          } else if (worker.carriedResource == _GatheringResource.fragments) {
            final heroIndex = _nearestFragmentRecipientIndex(worker.position);
            if (heroIndex == null ||
                _heroStates[heroIndex].magicEnergy >= heroMagicEnergyMax) {
              continue;
            }
            _heroStates[heroIndex].magicEnergy = min(
              heroMagicEnergyMax,
              _heroStates[heroIndex].magicEnergy +
                  gatheringFragmentCarryAmount,
            );
          }
          worker.carriedResource = null;
          worker.order = worker.repeatMining
              ? _GatheringWorkerOrder.mineGold
              : _GatheringWorkerOrder.idle;
          break;
        case _GatheringWorkerOrder.move:
          worker.order = _GatheringWorkerOrder.idle;
          break;
        case _GatheringWorkerOrder.idle:
        case _GatheringWorkerOrder.attack:
        case _GatheringWorkerOrder.build:
          break;
      }
    }
  }

  bool _isConstructionArea(Offset position) =>
      (_hasWorkerPortal && _portalRect.inflate(40).contains(position)) || _constructionSites.any(
    (site) => Rect.fromCenter(
      center: site.position,
      width: towerWidth + 80,
      height: towerHeight + 80,
    ).contains(position),
  );

  bool _hasConstructionWorker(_ConstructionSite site) =>
      _gatheringWorkers.any((worker) =>
          worker.isAlive &&
          worker.order == _GatheringWorkerOrder.build &&
          identical(worker.constructionSite, site));

  void _assignConstructionWorker(
    _GatheringWorker worker,
    _ConstructionSite site,
  ) {
    worker
      ..constructionSite = site
      ..order = _GatheringWorkerOrder.build
      ..destination = site.position.translate(
        -towerWidth / 2 - gatheringWorkerSize / 2 - 8,
        0,
      )
      ..repeatMining = false
      ..miningRemaining = 0
      ..attackTarget = null
      ..isMoving = true;
  }

  void _assignIdleConstructionWorker(_ConstructionSite site) {
    final idleWorkers = _gatheringWorkers
        .where((worker) => worker.isIdle)
        .toList()
      ..sort((a, b) => (a.position - site.position).distanceSquared
          .compareTo((b.position - site.position).distanceSquared));
    if (idleWorkers.isNotEmpty) {
      _assignConstructionWorker(idleWorkers.first, site);
    }
  }

  Future<void> _upgradeConstructionTower(_ConstructionSite site) async {
    if (!widget.isRumble || !site.isComplete || _gameOver || _levelCompleted) {
      return;
    }
    if (_gatheringCoins < constructionUpgradeCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Na vylepšení potřebuješ 100 zlata.')),
      );
      return;
    }
    setState(() {
      _gatheringCoins -= constructionUpgradeCost;
      site
        ..investment += constructionUpgradeCost
        ..isUpgrading = true
        ..remaining = constructionDuration;
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
      _assignIdleConstructionWorker(site);
    });
    await RpgSystem.addCoins(-constructionUpgradeCost);
    await RpgSystem.saveProgress();
  }

  Future<void> _demolishConstructionTower(_ConstructionSite site) async {
    if (!widget.isRumble || site.level == 0 || _gameOver || _levelCompleted) {
      return;
    }
    final refund = site.demolitionRefund;
    setState(() {
      for (final worker in _gatheringWorkers) {
        if (identical(worker.constructionSite, site)) {
          worker.constructionSite = null;
          if (worker.order == _GatheringWorkerOrder.build) {
            worker
              ..order = _GatheringWorkerOrder.idle
              ..isMoving = false
              ..destination = worker.position;
          }
        }
      }
      site.reset();
      _gatheringCoins += refund;
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
    });
    await RpgSystem.addCoins(refund);
    await RpgSystem.saveProgress();
  }

  Future<void> _buyConstructionTower(
    _ConstructionSite site,
    _ConstructionType type,
  ) async {
    if (!widget.isRumble || site.isOrdered || _gameOver || _levelCompleted) {
      return;
    }
    final cost = type.cost;
    if (_gatheringCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Na budovu ${type.label} potřebuješ $cost zlata.')),
      );
      return;
    }
    setState(() {
      _gatheringCoins -= cost;
      site.type = type;
      site.isOrdered = true;
      site.investment = cost;
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
      _assignIdleConstructionWorker(site);
    });
    await RpgSystem.addCoins(-cost);
    await RpgSystem.saveProgress();
  }

  bool _handleConstructionTap(Offset position) {
    for (final site in _constructionSites) {
      if (!Rect.fromCenter(
        center: site.position,
        width: site.level > 0
            ? (site.type == _ConstructionType.lightning ? lightningTowerSize : towerWidth)
            : constructionSiteSize + 12,
        height: site.level > 0
            ? (site.type == _ConstructionType.lightning ? lightningTowerSize : towerHeight)
            : constructionSiteSize + 12,
      ).contains(position)) {
        continue;
      }
      if (site.needsWork) {
        _selectedConstructionSite = null;
    _portalMenuOpen = false;
        if (!_hasConstructionWorker(site)) {
          final selected = <int>{
            ..._selectedGatheringWorkerIndices,
            if (_selectedGatheringWorkerIndex != null)
              _selectedGatheringWorkerIndex!,
          }.where((index) =>
              index >= 0 &&
              index < _gatheringWorkers.length &&
              _gatheringWorkers[index].isAlive).toList()
            ..sort((a, b) =>
                (_gatheringWorkers[a].position - site.position).distanceSquared
                    .compareTo((_gatheringWorkers[b].position - site.position)
                        .distanceSquared));
          if (selected.isNotEmpty) {
            final index = selected.first;
            setState(() {
              _assignConstructionWorker(_gatheringWorkers[index], site);
              _selectedGatheringWorkerIndices.remove(index);
              if (_selectedGatheringWorkerIndex == index) {
                _selectedGatheringWorkerIndex = null;
              }
            });
            return true;
          }
        }
        if (site.level == 0) {
          return true;
        }
      }
      setState(() {
        _selectedConstructionSite =
            identical(_selectedConstructionSite, site) ? null : site;
        _selectedHeroIndex = null;
        _multiSelectedHeroIndices.clear();
        _selectedGatheringWorkerIndex = null;
        _selectedGatheringWorkerIndices.clear();
        _clearHeroRangeIndicator();
      });
      return true;
    }
    return false;
  }

  void _updateConstruction(_GatheringWorker worker, double dt) {
    final site = worker.constructionSite;
    if (site == null || !site.needsWork) {
      worker
        ..order = _GatheringWorkerOrder.idle
        ..constructionSite = null
        ..isMoving = false;
      return;
    }
    final target = _navigation.outside(worker.destination);
    final previous = worker.position;
    final next = _navigation.move(previous, target, gatheringWorkerSpeed * dt, routeKey: worker);
    worker.isMovingLeft = next.dx < previous.dx;
    worker.position = next;
    worker.isMoving = (target - next).distance > 0.01;
    if (worker.isMoving) return;
    // Work starts on the tick after arrival, without counting travel as work.
    if ((previous - target).distance > 0.01) return;
    site.remaining = max(0, site.remaining - dt);
    if (site.remaining <= 0) {
      site.level++;
      site
        ..isUpgrading = false
        ..cooldownRemaining = 0;
      worker
        ..order = _GatheringWorkerOrder.idle
        ..constructionSite = null;
    }
  }

  Iterable<Widget> _buildConstructionMarkers() sync* {
    for (final site in _constructionSites) {
      if (site.level > 0) {
        yield Positioned(
          left: site.position.dx - 40,
          top: site.position.dy + towerHeight / 2 + 32,
          width: 80,
          child: IgnorePointer(
            child: Container(
              color: const Color(0xDD182127),
              padding: const EdgeInsets.all(3),
              child: Text(
                'Úroveň ${site.level}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        );
      }
      if (site.level == 0) {
        yield Positioned(
          left: site.position.dx - constructionSiteSize / 2,
          top: site.position.dy - constructionSiteSize / 2,
          child: IgnorePointer(
            child: Container(
              width: constructionSiteSize,
              height: constructionSiteSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFF922B),
                border: Border.all(
                  color: identical(_selectedConstructionSite, site)
                      ? Colors.white : const Color(0xFF8A4100),
                  width: 2,
                ),
              ),
              child: site.isOrdered
                  ? const Icon(Icons.construction, size: 18, color: Colors.black87)
                  : null,
            ),
          ),
        );
      }
      if (site.needsWork) {
        final working = _hasConstructionWorker(site);
        yield Positioned(
          left: site.position.dx - 76,
          top: site.position.dy + (site.level > 0 ? towerHeight / 2 + 56 : 20),
          width: 152,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xDD182127),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${working ? (site.isUpgrading ? 'Vylepšení' : 'Stavba') : 'Čeká na sběrače'} · ${site.remaining.ceil()} s',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    LinearProgressIndicator(
                      value: 1 - site.remaining / constructionDuration,
                      minHeight: 4,
                      color: const Color(0xFFFF922B),
                      backgroundColor: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Widget _buildConstructionMenu() {
    final site = _selectedConstructionSite;
    if (site == null || (site.isOrdered && site.level == 0)) {
      return const SizedBox.shrink();
    }
    const offsets = [
      Offset(70, 0),
      Offset(140, 70),
      Offset(70, 140),
      Offset(0, 70),
    ];
    final built = site.level > 0;
    return Positioned(
      left: site.position.dx - 96,
      top: site.position.dy - 96,
      width: 192,
      height: 192,
      child: Stack(
        children: List.generate(4, (index) {
          final demolish = built && index == 1;
          final buildType = !built && index < _ConstructionType.values.length
              ? _ConstructionType.values[index] : null;
          final cost = built ? constructionUpgradeCost : (buildType?.cost ?? 0);
          final canAfford = _gatheringCoins >= cost;
          final available = built ? index < 2 : buildType != null;
          final enabled = demolish ||
              (available && canAfford && !site.isUpgrading);
          final label = demolish
              ? 'Zbourat · vrátí ${site.demolitionRefund} zlata'
              : !available
                  ? 'Zatím nedostupné'
                  : !built
                      ? '${buildType!.label} · $cost zlata · stavba 60 s'
                      : site.isUpgrading
                          ? 'Probíhá vylepšení · věž nestřílí'
                          : 'Vylepšit na úroveň ${site.level + 1} · $cost zlata · 60 s · poškození ×3';
          return Positioned(
            left: offsets[index].dx,
            top: offsets[index].dy,
            width: 52,
            height: 52,
            child: Tooltip(
              message: label,
              child: Semantics(
                button: true,
                enabled: enabled,
                label: label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (demolish) {
                      unawaited(_demolishConstructionTower(site));
                    } else if (index == 0 && built) {
                      unawaited(_upgradeConstructionTower(site));
                    } else if (buildType != null) {
                      unawaited(_buyConstructionTower(site, buildType));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xF0182127),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: enabled
                            ? const Color(0xFFFF922B) : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: available
                        ? Column(
                            children: [
                              if (built)
                                SizedBox(
                                  height: 30,
                                  child: Icon(
                                    demolish ? Icons.delete_outline : Icons.upgrade,
                                    size: 26,
                                    color: demolish ? Colors.redAccent
                                        : enabled ? Colors.amber : Colors.white38,
                                  ),
                                )
                              else if (buildType == _ConstructionType.lightning)
                                const SizedBox(
                                  width: 28,
                                  height: 30,
                                  child: Center(
                                    child: ColoredBox(
                                      color: lightningTowerColor,
                                      child: SizedBox(width: 24, height: 24),
                                    ),
                                  ),
                                )
                              else
                                Image.asset(
                                  'assets/backgrounds/tower.png',
                                  width: 28,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fort, size: 28, color: Colors.white,
                                  ),
                                ),
                              Text(demolish ? '+${site.demolitionRefund}' : '$cost', style: TextStyle(
                                fontSize: 11,
                                color: demolish ? Colors.lightGreenAccent
                                    : canAfford ? Colors.amber : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              )),
                            ],
                          )
                        : const Icon(Icons.lock_outline,
                            size: 22, color: Colors.white38),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  int? _nearestFragmentRecipientIndex(Offset position) {
    int? nearestIndex;
    var nearestDistance = double.infinity;
    for (int index = 0; index < _heroUnits.length; index++) {
      if (!_isHeroAlive(index) ||
          _heroStates[index].magicEnergy >= heroMagicEnergyMax) {
        continue;
      }
      final distance = (_heroUnits[index].position - position).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = index;
      }
    }
    return nearestIndex;
  }

  Offset? _nearestFragmentRecipientPosition(Offset position) {
    final index = _nearestFragmentRecipientIndex(position);
    return index == null ? null : _heroUnits[index].position;
  }

  int? _hitTestGatheringWorker(Offset position) {
    for (int i = _gatheringWorkers.length - 1; i >= 0; i--) {
      if (!_gatheringWorkers[i].isAlive) {
        continue;
      }
      if ((_gatheringWorkers[i].position - position).distance <=
              gatheringWorkerRenderSize * 0.35) {
        return i;
      }
    }
    return null;
  }

  void _handleGatheringTap(Offset position) {
    final tappedWorker = _hitTestGatheringWorker(position);
    if (tappedWorker != null) {
      setState(() {
        _selectedGatheringWorkerIndices
          ..clear()
          ..add(tappedWorker);
        _selectedGatheringWorkerIndex = tappedWorker;
      });
      return;
    }

    final selectedIndices = _selectedGatheringWorkerIndices.isNotEmpty
        ? _selectedGatheringWorkerIndices
              .where((index) => index >= 0 && index < _gatheringWorkers.length)
              .toList()
        : (_selectedGatheringWorkerIndex == null
              ? <int>[]
              : <int>[_selectedGatheringWorkerIndex!]);
    if (selectedIndices.isEmpty) {
      return;
    }
    final tappedResource = _hitTestGatheringResource(position);
    for (final selectedIndex in selectedIndices) {
      final worker = _gatheringWorkers[selectedIndex];
      worker.constructionSite = null;
      worker.miningRemaining = 0;
      worker.attackTarget = null;
      if (tappedResource != null) {
        worker.repeatMining = true;
        worker.targetResource = tappedResource.resource;
        worker.targetWoodIndex = tappedResource.woodIndex;
        worker.targetStoneIndex = tappedResource.stoneIndex;
        worker.targetFragmentIndex = tappedResource.fragmentIndex;
        worker.order = _GatheringWorkerOrder.mineGold;
      } else if (position.dx <= heroAreaWidth) {
        worker.repeatMining = false;
        worker.order = _GatheringWorkerOrder.deliver;
      } else {
        worker
          ..repeatMining = false
          ..order = _GatheringWorkerOrder.move
          ..destination = Offset(
            position.dx.clamp(
              heroAreaWidth + gatheringWorkerSize / 2,
              mapWidth - gatheringWorkerSize / 2,
            ).toDouble(),
            position.dy.clamp(
              gatheringWorkerSize / 2,
              mapHeight - gatheringWorkerSize / 2,
            ).toDouble(),
          );
      }
    }
    setState(() {});
  }

  void _selectIdleGatheringWorker() {
    final index = _gatheringWorkers.indexWhere((worker) => worker.isIdle);
    if (index < 0) {
      return;
    }
    setState(() {
      _selectedConstructionSite = null;
    _portalMenuOpen = false;
      _selectedHeroIndex = null;
      _multiSelectedHeroIndices.clear();
      _selectedGatheringWorkerIndices
        ..clear()
        ..add(index);
      _selectedGatheringWorkerIndex = index;
    });
  }

  void _selectGatheringWorkersInSquare(Rect selection) {
    final selectedIndices = <int>{};
    for (int index = 0; index < _gatheringWorkers.length; index++) {
      if (_gatheringWorkers[index].isAlive &&
          selection.contains(_gatheringWorkers[index].position)) {
        selectedIndices.add(index);
      }
    }
    setState(() {
      _selectedGatheringWorkerIndices
        ..clear()
        ..addAll(selectedIndices);
      _selectedGatheringWorkerIndex = selectedIndices.length == 1
          ? selectedIndices.first
          : null;
    });
  }

  void _selectRumbleUnitsInSquare(Rect selection) {
    _selectedConstructionSite = null;
    _portalMenuOpen = false;
    final workerIndices = <int>{};
    final heroIndices = <int>{};
    for (int index = 0; index < _gatheringWorkers.length; index++) {
      if (_gatheringWorkers[index].isAlive &&
          selection.contains(_gatheringWorkers[index].position)) {
        workerIndices.add(index);
      }
    }
    for (int index = 0; index < _heroUnits.length; index++) {
      if (_isHeroAlive(index) && selection.contains(_heroPosition(index))) {
        heroIndices.add(index);
      }
    }
    setState(() {
      _selectedHeroIndex = heroIndices.length == 1 && workerIndices.isEmpty
          ? heroIndices.first
          : null;
      _multiSelectedHeroIndices
        ..clear()
        ..addAll(heroIndices);
      _selectedGatheringWorkerIndices
        ..clear()
        ..addAll(workerIndices);
      _selectedGatheringWorkerIndex = workerIndices.length == 1 &&
              heroIndices.isEmpty
          ? workerIndices.first
          : null;
      _showHeroRangeIndicators(heroIndices);
    });
  }

  void _handleRumbleTap(Offset position) {
    if (_handleConstructionTap(position)) {
      return;
    }
    _selectedConstructionSite = null;
    _portalMenuOpen = false;
    final tappedWorker = _hitTestGatheringWorker(position);
    if (tappedWorker != null) {
      setState(() {
        _selectedHeroIndex = null;
        _multiSelectedHeroIndices.clear();
        _selectedGatheringWorkerIndices
          ..clear()
          ..add(tappedWorker);
        _selectedGatheringWorkerIndex = tappedWorker;
      });
      return;
    }

    final tappedHero = _hitTestHero(position);
    if (tappedHero != null) {
      _selectHero(tappedHero);
      return;
    }

    final selectedHeroes = <int>{
      ..._multiSelectedHeroIndices.where(_isHeroAlive),
      if (_selectedHeroIndex != null && _isHeroAlive(_selectedHeroIndex!))
        _selectedHeroIndex!,
    };
    final selectedWorkers = _selectedGatheringWorkerIndices
        .where((index) => index >= 0 && index < _gatheringWorkers.length)
        .toList();
    final tappedEnemy = _hitTestEnemy(position);
    final tappedResource = _hitTestGatheringResource(position);

    if (tappedEnemy != null &&
        (selectedHeroes.isNotEmpty || selectedWorkers.isNotEmpty)) {
      for (final heroIndex in selectedHeroes) {
        _issueAttackOrder(heroIndex, tappedEnemy);
      }
      for (final workerIndex in selectedWorkers) {
        _issueGatheringAttackOrder(_gatheringWorkers[workerIndex], tappedEnemy);
      }
      setState(() {
        _selectedHeroIndex = null;
        _multiSelectedHeroIndices.clear();
        _selectedGatheringWorkerIndex = null;
        _selectedGatheringWorkerIndices.clear();
      });
      return;
    }

    if (tappedResource != null && selectedWorkers.isNotEmpty) {
      _handleGatheringTap(position);
      if (selectedHeroes.isNotEmpty) {
        final target = _clampHeroTarget(position);
        setState(() {
          for (final heroIndex in selectedHeroes) {
            _issueMoveOrder(heroIndex, target);
          }
          _selectedHeroIndex = null;
          _multiSelectedHeroIndices.clear();
        });
      }
      return;
    }

    if (selectedHeroes.isNotEmpty) {
      final target = _clampHeroTarget(position);
      setState(() {
        for (final heroIndex in selectedHeroes) {
          _issueMoveOrder(heroIndex, target);
        }
        _selectedHeroIndex = null;
        _multiSelectedHeroIndices.clear();
      });
      _showTargetIndicatorAt(target);
    }
    if (selectedWorkers.isNotEmpty) {
      _handleGatheringTap(position);
    }
  }

  _GatheringResourceTarget? _hitTestGatheringResource(Offset position) {
    if (Rect.fromCenter(
      center: _gatheringGoldPosition,
      width: goldMineSize.width * 0.8,
      height: goldMineSize.height * 0.8,
    ).contains(position)) {
      return const _GatheringResourceTarget(_GatheringResource.gold);
    }
    for (int i = 0; i < _gatheringWoodPositions.length; i++) {
      final offset = position - _gatheringWoodPositions[i];
      final size = _woodTreeSizeAt(i);
      final nx = offset.dx / (size.width * 0.45);
      final ny = offset.dy / (size.height * 0.45);
      if (nx * nx + ny * ny <= 1) {
        return _GatheringResourceTarget(_GatheringResource.wood, woodIndex: i);
      }
    }
    for (int i = 0; i < _gatheringStonePositions.length; i++) {
      if ((position - _gatheringStonePositions[i]).distance <= 20) {
        return _GatheringResourceTarget(
          _GatheringResource.stone,
          stoneIndex: i,
        );
      }
    }
    for (int i = 0; i < _gatheringFragmentPositions.length; i++) {
      final offset = position - _gatheringFragmentPositions[i];
      final nx = offset.dx / (manaPoolSize.width * 0.45);
      final ny = offset.dy / (manaPoolSize.height * 0.45);
      if (nx * nx + ny * ny <= 1) {
        return _GatheringResourceTarget(
          _GatheringResource.fragments,
          fragmentIndex: i,
        );
      }
    }
    return null;
  }

  Future<void> _resetGame() async {
    await _saveProgress();
    if (!mounted) {
      return;
    }

    setState(() {
      _gameStartTime = DateTime.now();
      _lastTime = 0;
      _wallHp = wallHpMax;
      _wallHitEffectRemaining = 0;
      _currentWave = 1;
      _enemiesKilled = 0;
      _enemiesInWave = 0;
      _enemiesSpawnedInWave = 0;
      _waveElapsedTime = 0;
      _nextWaveSpawnIndex = 0;
      _scheduledWaveSpawns = <_ScheduledSpawn>[];
      _gameOver = false;
      _gameOverDialogShown = false;
      _levelCompleted = false;
      _levelCompleteDialogShown = false;
      _gameSpeed = 2;
      _speedPanelOpen = false;
      _autoMode = true;
      _readyHeroIndex = null;
      _towerCooldownRemaining = 0;
      _selectedConstructionSite = null;
      for (final site in _constructionSites) {
        site.reset();
      }
      _zoomMultiplier = 1.0;
      _portalMenuOpen = false;
      _targetIndicator = null;
      _preventAutoReselect = false;
      _lastManualFireTime = DateTime.now();
      _modeSelectorOpen = false;
      _aerinMode = _HeroMode.normal;
      _veyraMode = _VeyraMode.rapid;
      _thalorMode = _ThalorMode.projectile;
      _nyxraMode = _NyxraMode.normal;
      _myrisMode = _MyrisMode.normal;
      _kaelenMode = _KaelenMode.normal;
      _solenneMode = _SolenneMode.normal;
      _ravikMode = _RavikMode.normal;
      _brannMode = _BrannMode.normal;
      _eldrinMode = _EldrinMode.normal;
      _closeAllModeMenus();
      _enemies.clear();
      _projectiles.clear();
      _enemyProjectiles.clear();
      _damageTexts.clear();
      _floatingCoinRewards.clear();
      _explosions.clear();
      _lightnings.clear();
      _coinsEarned = 0;
      for (int i = 0; i < _heroUnits.length; i++) {
        _heroUnits[i] = _initialHeroUnit(i);
        _heroBehaviors[i] = _HeroBehaviorMode.holdPosition;
        _heroAttackAnimationRemainingTimes[i] = 0;
      }
      for (final state in _heroStates) {
        state.phase = _HeroPhase.cooldown;
        state.timeRemaining = 0;
        state.pendingAttack = false;
        state.magicEnergy = heroMagicEnergyMax;
        state.attackFlipHorizontally = false;
        state.beamTarget = null;
      }
      if (widget.isRumble || widget.isGathering) {
        for (int index = 0; index < _gatheringWorkers.length; index++) {
          _gatheringWorkers[index]
            ..position = _portalWorkerPosition(index)
            ..hp = gatheringWorkerMaxHp
            ..constructionSite = null
            ..attackTarget = null
            ..attackCooldown = 0
            ..isAlive = true
            ..isMoving = false
            ..destination = _gatheringWorkers[index].position
            ..order = _GatheringWorkerOrder.idle
            ..repeatMining = false
            ..miningRemaining = 0
            ..carriedResource = null;
        }
        _selectedGatheringWorkerIndices.clear();
        _selectedGatheringWorkerIndex = null;
      }
      _selectedHeroIndex = null;
      _multiSelectedHeroIndices.clear();
      _selectionDragCurrent = null;
      _pointerDownScenePosition = null;
      _pointerDownHeroIndex = null;
      _activePointerCount = 0;
      _activeViewportPointers.clear();
      _mapViewportOffset = Offset.zero;
      _mapJoystickInput = Offset.zero;
      _clearHeroRangeIndicator();
      _prepareWaveRuntime();
      _separateAllUnits();
      _applyMapTransform();
    });
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
                      _buildStatRow(
                        Icons.waves,
                        Colors.blue,
                        'Wave Reached',
                        _currentWave.toString(),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        Icons.favorite,
                        Colors.redAccent,
                        'Enemies Killed',
                        _enemiesKilled.toString(),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        Icons.monetization_on,
                        Colors.amber,
                        'Coins Earned',
                        _coinsEarned.toString(),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        Icons.timer,
                        Colors.lightBlue,
                        'Game Time',
                        _gameDurationText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _resetGame();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () async {
                await _saveProgress();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => widget.isRumble
                        ? LevelSelectScreen(heroes: widget.heroes,
                            chapterNumber: widget.chapterNumber, isRumble: true)
                        : const HeroSelectScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text(widget.isRumble
                  ? 'Návrat do výběru levelu' : 'Návrat do výběru hrdinů'),
            ),
            TextButton(
              onPressed: () async {
                await _saveProgress();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const IntroScreen()),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
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
    if (!_isHeroAlive(heroIndex) || _heroUnits[heroIndex].isMoving) {
      return;
    }
    final hero = widget.heroes[heroIndex];
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final range = _heroCurrentAttackRange(heroIndex);
    final damage =
        hero.beamDps *
        dt *
        (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0);
    if (damage <= 0) {
      return;
    }
    final state = _heroStates[heroIndex];
    final nearest = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: state.beamTarget,
    );
    if (nearest == null) {
      state.beamTarget = null;
      return;
    }
    state.beamTarget = nearest;

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
      if (proj < 0 || proj > range) {
        continue;
      }
      final perp = (vx * vx + vy * vy) - proj * proj;
      if (perp > (enemySize / 2) * (enemySize / 2)) {
        continue;
      }
      _applyDamage(enemy, damage, heroIndex: heroIndex);
    }
  }

  void _updateEffects(double dt) {
    if (_wallHitEffectRemaining > 0) {
      _wallHitEffectRemaining = max(0, _wallHitEffectRemaining - dt);
    }
    for (final enemy in _enemies) {
      if (enemy.flashRemaining > 0) {
        enemy.flashRemaining = max(0, enemy.flashRemaining - dt);
      }
      if (enemy.hitAnimRemaining > 0) {
        enemy.hitAnimRemaining = max(0, enemy.hitAnimRemaining - dt);
      }
      if (enemy.damageTextCooldown > 0) {
        enemy.damageTextCooldown = max(0, enemy.damageTextCooldown - dt);
      }
      enemy.animTime += dt;
      if (enemy.isDying) {
        final spriteConfig =
            _enemySpriteConfigs[enemy.typeId] ??
            _enemySpriteConfigs['fat_zombie']!;
        final deathDuration =
            spriteConfig.deathFrameCount * _Enemy.deathFrameDuration;
        if (enemy.deathAnimTime < deathDuration) {
          enemy.deathAnimTime = min(deathDuration, enemy.deathAnimTime + dt);
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

    for (final reward in _floatingCoinRewards) {
      reward.lifeRemaining -= dt;
      reward.position = reward.position.translate(0, -reward.speed * dt);
    }
    _floatingCoinRewards.removeWhere((reward) => reward.lifeRemaining <= 0);
  }

  void _enterSending(int heroIndex) {
    if (!_heroCanAutoAttackNow(heroIndex)) {
      _heroStates[heroIndex]
        ..phase = _HeroPhase.cooldown
        ..timeRemaining = 0
        ..pendingAttack = false
        ..attackFlipHorizontally = false
        ..beamTarget = null;
      return;
    }
    final isMoving = _heroUnits[heroIndex].isMoving;
    _heroStates[heroIndex]
      ..phase = _HeroPhase.sending
      ..pendingAttack = isMoving
      ..attackFlipHorizontally = false
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
      ..attackFlipHorizontally = false
      ..beamTarget = null
      ..timeRemaining = _effectiveCooldown(heroIndex);
  }

  void _beginSendingAfterManualAttack(int heroIndex) {
    _heroStates[heroIndex]
      ..pendingAttack = false
      ..attackFlipHorizontally = false
      ..timeRemaining = _effectiveSending(heroIndex);
  }

  bool _shouldFlipHeroSprite(int heroIndex) {
    if (!_isHeroAlive(heroIndex)) {
      return false;
    }
    final unit = _heroUnits[heroIndex];
    if (unit.isMoving) {
      return unit.target.dx < unit.position.dx - 0.01;
    }
    final state = _heroStates[heroIndex];
    if (state.phase != _HeroPhase.sending || state.pendingAttack) {
      return false;
    }
    final beamTarget = state.beamTarget;
    if (_containsTargetableEnemy(beamTarget)) {
      return beamTarget!.position.dx < unit.position.dx - 0.01;
    }
    return state.attackFlipHorizontally;
  }

  bool _attackFlipFromTarget(int heroIndex, _Enemy? target) {
    if (!_containsTargetableEnemy(target)) {
      return false;
    }
    return target!.position.dx < _heroPosition(heroIndex).dx - 0.01;
  }

  void _performAttack(int heroIndex, {_Enemy? target}) {
    if (!_isHeroAlive(heroIndex)) {
      return;
    }
    final state = _heroStates[heroIndex];
    if (state.magicEnergy <= 0) {
      return;
    }
    state.magicEnergy = max(0, state.magicEnergy - 1);
    state.attackFlipHorizontally = _attackFlipFromTarget(
      heroIndex,
      target ?? _nearestEnemyForHero(heroIndex),
    );
    if (_isAerin(heroIndex)) {
      _heroAttackAnimationRemainingTimes[heroIndex] =
          _HeroUnitWidget.aerinAttackAnimationDurationSeconds;
    } else if (_isVeyra(heroIndex)) {
      _heroAttackAnimationRemainingTimes[heroIndex] =
          _HeroUnitWidget.veyraAttackAnimationDurationSeconds;
    } else if (_isBrann(heroIndex)) {
      _heroAttackAnimationRemainingTimes[heroIndex] =
          _HeroUnitWidget.brannAttackAnimationDurationSeconds;
    }
    final attackType = widget.heroes[heroIndex].attackType;

    if (_isMyris(heroIndex)) {
      switch (_myrisMode) {
        case _MyrisMode.normal:
          _castVeyraLightning(heroIndex, target: target);
          break;
        case _MyrisMode.ice:
          _castMyrisIce(heroIndex, target: target);
          break;
        case _MyrisMode.freeze:
          _castMyrisFreeze(heroIndex);
          break;
      }
    } else if (_isNyxra(heroIndex)) {
      switch (_nyxraMode) {
        case _NyxraMode.normal:
          _castVeyraLightning(heroIndex, target: target);
          break;
        case _NyxraMode.lightning:
          _castNyxraLightning(heroIndex, target: target);
          break;
        case _NyxraMode.voidchain:
          _castNyxraVoidChain(heroIndex, target: target);
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
        case _KaelenMode.healing:
          _castKaelenHealingPulse(heroIndex);
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
          _castVeyraLightning(heroIndex, target: target);
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
    final hit = _hitTestEnemy(position);
    if (hit == null) {
      return;
    }
    _triggerManualAttack(hit);
  }

  Future<void> _markLevelCompleted() async {
    await _saveProgress();
    final progress = await RpgSystem.getProgress();
    progress.markLevelCompleted(widget.chapterNumber, widget.levelNumber);
    await RpgSystem.saveProgress();
  }

  Future<void> _showLevelCompleteDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Vesnice ubranená'),
          content: const Text('Ubranil jsi vesnici a dokoncil tento level.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _resetGame();
              },
              child: const Text('Hrat znovu'),
            ),
            TextButton(
              onPressed: () async {
                await _saveProgress();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => LevelSelectScreen(
                      heroes: widget.heroes,
                      chapterNumber: widget.chapterNumber,
                      isRumble: widget.isRumble,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Vyber levelu'),
            ),
          ],
        );
      },
    );
  }

  void _triggerManualPositionAttack(Offset screenPosition) {
    final heroIndex = _readyHeroIndex;
    if (heroIndex == null) {
      return;
    }
    if (_heroStates[heroIndex].magicEnergy <= 0) {
      return;
    }

    // Prevent rapid-fire tapping (minimum 200ms between shots)
    final now = DateTime.now();
    final timeSinceLastFire = now
        .difference(_lastManualFireTime)
        .inMilliseconds;
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
    _showTargetIndicatorAt(mapPosition);

    // Fire projectile at map position
    final dir = (mapPosition - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(
      dir.dx / len * projectileSpeed,
      dir.dy / len * projectileSpeed,
    );
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
        heroIndex: heroIndex,
        seed: _rng.nextDouble() * 1000,
      ),
    );
    _heroStates[heroIndex].magicEnergy = max(
      0,
      _heroStates[heroIndex].magicEnergy - 1,
    );

    // Manual fire starts sending now; cooldown starts when sending ends.
    _beginSendingAfterManualAttack(heroIndex);
  }

  Offset _screenToMapPosition(Offset screenPosition) {
    // Pointer localPosition from the map listener is already in map-space.
    return screenPosition;
  }

  Offset _pointerEventToScenePosition(PointerEvent event) {
    final viewportPosition = _pointerEventToViewportPosition(event);
    return _mapTransformController.toScene(viewportPosition);
  }

  Offset _pointerEventToViewportPosition(PointerEvent event) {
    final renderObject = _interactiveViewerKey.currentContext
        ?.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.globalToLocal(event.position);
    }
    return event.localPosition;
  }

  void _handleGameplayPointerDown(PointerDownEvent event) {
    if (_portalMenuOpen) setState(() => _portalMenuOpen = false);
    _gameFocusNode.requestFocus();
    if (_isDesktopPanTrigger(event)) {
      setState(() {
        _startDesktopPan(event);
        _pointerDownScenePosition = null;
        _pointerDownHeroIndex = null;
        _selectionDragCurrent = null;
      });
      return;
    }
    final viewportPosition = _pointerEventToViewportPosition(event);
    final scenePosition = _pointerEventToScenePosition(event);
    final nextPointerCount = _activePointerCount + 1;
    setState(() {
      _activeViewportPointers[event.pointer] = viewportPosition;
      _activePointerCount = nextPointerCount;
      if (_activePointerCount >= 2) {
        _pointerDownScenePosition = null;
        _pointerDownHeroIndex = null;
        _selectionDragCurrent = null;
      } else {
        _pointerDownScenePosition = scenePosition;
        _pointerDownHeroIndex = _hitTestHero(scenePosition);
        _selectionDragCurrent = null;
      }
    });
  }

  void _handleGameplayPointerMove(PointerMoveEvent event) {
    if (_isDesktopPanActiveForPointer(event)) {
      _updateDesktopPan(event);
      return;
    }
    final previousViewportPosition = _activeViewportPointers[event.pointer];
    final viewportPosition = _pointerEventToViewportPosition(event);
    if (previousViewportPosition != null) {
      _activeViewportPointers[event.pointer] = viewportPosition;
    }
    if (_activeViewportPointers.length >= 2 &&
        previousViewportPosition != null) {
      final previousCentroid = _viewportCentroid(
        _activeViewportPointers.entries.map(
          (entry) => entry.key == event.pointer
              ? previousViewportPosition
              : entry.value,
        ),
      );
      final previousSpread = _viewportPointerSpread(
        _activeViewportPointers.entries.map(
          (entry) => entry.key == event.pointer
              ? previousViewportPosition
              : entry.value,
        ),
      );
      final currentSpread = _viewportPointerSpread(
        _activeViewportPointers.values,
      );
      final zoomRatio = previousSpread > 0 && currentSpread > 0
          ? currentSpread / previousSpread
          : 1.0;
      final nextZoom = (_zoomMultiplier * zoomRatio)
          .clamp(minZoomMultiplier, maxZoomMultiplier)
          .toDouble();
      final sceneAnchor = _mapTransformController.toScene(previousCentroid);
      if ((nextZoom - _zoomMultiplier).abs() > 0.0001) {
        setState(() {
          _zoomMultiplier = nextZoom;
          final nextScale = _baseMapScale * _zoomMultiplier;
          _mapViewportOffset = _clampMapViewportOffset(
            Offset(
              previousCentroid.dx - sceneAnchor.dx * nextScale,
              previousCentroid.dy - sceneAnchor.dy * nextScale,
            ),
          );
          _pointerDownScenePosition = null;
          _pointerDownHeroIndex = null;
          _selectionDragCurrent = null;
          _applyMapTransform();
        });
      }
      return;
    }
    final start = _pointerDownScenePosition;
    if (_activePointerCount != 1 ||
        start == null ||
        (_pointerDownHeroIndex != null && !widget.isRumble)) {
      return;
    }
    final scenePosition = _pointerEventToScenePosition(event);
    if ((scenePosition - start).distance < multiSelectDragThreshold) {
      return;
    }
    setState(() {
      _selectionDragCurrent = scenePosition;
    });
  }

  void _handleGameplayPointerUp(PointerEvent event) {
    if (_isDesktopPanActiveForPointer(event)) {
      setState(() {
        _stopDesktopPan();
        _pointerDownScenePosition = null;
        _pointerDownHeroIndex = null;
        _selectionDragCurrent = null;
      });
      return;
    }
    final scenePosition = _pointerEventToScenePosition(event);
    final start = _pointerDownScenePosition;
    final pointerDownHeroIndex = _pointerDownHeroIndex;
    final wasMultiTouchGesture = _activePointerCount >= 2;
    final dragDistance = start == null ? 0.0 : (scenePosition - start).distance;
    setState(() {
      _activeViewportPointers.remove(event.pointer);
      _activePointerCount = max(0, _activePointerCount - 1);
      _pointerDownScenePosition = null;
      _pointerDownHeroIndex = null;
      _selectionDragCurrent = null;
    });
    if (wasMultiTouchGesture) {
      return;
    }
    if (start == null) {
      return;
    }
    if (widget.isRumble) {
      if (dragDistance >= multiSelectDragThreshold) {
        _selectRumbleUnitsInSquare(
          _selectionSquareFromPoints(start, scenePosition),
        );
      } else if (dragDistance <= 12) {
        _handleRumbleTap(scenePosition);
      }
      return;
    }
    if (widget.isGathering) {
      if (dragDistance >= multiSelectDragThreshold) {
        _selectGatheringWorkersInSquare(
          _selectionSquareFromPoints(start, scenePosition),
        );
      } else if (dragDistance <= 12) {
        _handleGatheringTap(scenePosition);
      }
      return;
    }
    if (pointerDownHeroIndex == null &&
        dragDistance >= multiSelectDragThreshold) {
      _selectHeroesInSquare(_selectionSquareFromPoints(start, scenePosition));
      return;
    }
    if (dragDistance > 12) {
      return;
    }
    if (pointerDownHeroIndex != null) {
      _selectHero(pointerDownHeroIndex);
      return;
    }
    _handleMapTap(scenePosition);
  }

  void _handleGameplayPointerCancel(PointerEvent event) {
    if (_isDesktopPanActiveForPointer(event)) {
      setState(() {
        _stopDesktopPan();
        _pointerDownScenePosition = null;
        _pointerDownHeroIndex = null;
        _selectionDragCurrent = null;
      });
      return;
    }
    setState(() {
      _activeViewportPointers.remove(event.pointer);
      _activePointerCount = max(0, _activePointerCount - 1);
      _pointerDownScenePosition = null;
      _pointerDownHeroIndex = null;
      _selectionDragCurrent = null;
    });
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
    if (!_isHeroAlive(heroIndex)) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final resolvedTarget = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
    );
    if (resolvedTarget == null) {
      return;
    }
    final targetPos = resolvedTarget.position;

    final dir = (targetPos - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(
      dir.dx / len * projectileSpeed,
      dir.dy / len * projectileSpeed,
    );
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
        heroIndex: heroIndex,
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
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.normal) {
      return 1;
    }
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
          return 1;
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
        case _KaelenMode.healing:
          return 0.5;
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
        return Icons.bolt;
      case _NyxraMode.lightning:
        return Icons.bolt;
      case _NyxraMode.voidchain:
        return Icons.blur_on;
    }
  }

  IconData _myrisModeIcon(_MyrisMode mode) {
    switch (mode) {
      case _MyrisMode.normal:
        return Icons.bolt;
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
      case _KaelenMode.healing:
        return Icons.favorite;
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
    if (_isNyxra(heroIndex) && _nyxraMode == _NyxraMode.normal) {
      return _scaleCooldown(2);
    }
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
          return _scaleCooldown(2);
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
        case _KaelenMode.healing:
          return _scaleCooldown(6);
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
    final baseCooldown = _scaleCooldown(
      widget.heroes[heroIndex].cooldownDuration,
    );
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
          baseDamage = 30;
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
        case _KaelenMode.healing:
          baseDamage = 0;
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
    return baseDamage *
        (1 + bonusMultiplier) *
        (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0);
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
    if (_isAerin(heroIndex) && _aerinMode == _HeroMode.strong) {
      return 52;
    }
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

  _Enemy? _nearestEnemy(
    Offset from,
    Set<_Enemy> exclude, {
    double? maxDistance,
  }) {
    _Enemy? nearest;
    double bestDist = maxDistance ?? double.infinity;
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
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final used = <_Enemy>{};

    final first = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
      exclude: used,
    );
    if (first == null) {
      return;
    }
    used.add(first);
    _applyDamage(first, 10 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);

    final segments = <_LightningSegment>[
      _LightningSegment(
        start: heroPos,
        end: first.position,
        seed: _rng.nextDouble() * 1000,
      ),
    ];

    final second = _nearestEnemy(first.position, used);
    if (second != null) {
      used.add(second);
      _applyDamage(second, 8 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
      segments.add(
        _LightningSegment(
          start: first.position,
          end: second.position,
          seed: _rng.nextDouble() * 1000,
        ),
      );
    }

    if (second != null) {
      final third = _nearestEnemy(second.position, used);
      if (third != null) {
        used.add(third);
        _applyDamage(third, 5 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
        segments.add(
          _LightningSegment(
            start: second.position,
            end: third.position,
            seed: _rng.nextDouble() * 1000,
          ),
        );
      }
    }

    _lightnings.add(
      _LightningEffect(
        segments: segments,
        glowColor: const Color(0xFF2A2A2A),
        coreColor: const Color(0xFF000000),
        impactColor: const Color(0xFF141414),
      ),
    );
  }

  void _fireEnemyProjectile(
    _Enemy enemy,
    Offset targetPosition, {
    int? targetHeroIndex,
    int? targetWorkerIndex,
  }) {
    final dir = targetPosition - enemy.position;
    final len = max(dir.distance, 0.001);
    final velocity = Offset(
      dir.dx / len * projectileSpeed,
      dir.dy / len * projectileSpeed,
    );
    _enemyProjectiles.add(
      _EnemyProjectile(
        position: enemy.position,
        velocity: velocity,
        damage: enemy.projectileDamage,
        radius: projectileRadius + 1,
        color: zombieShooterProjectileColor,
        targetHeroIndex: targetHeroIndex,
        targetWorkerIndex: targetWorkerIndex,
      ),
    );
  }

  void _swordHit(int heroIndex) {
    if (!_isHeroAlive(heroIndex)) {
      return;
    }
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= swordRadius) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
  }

  bool _hasEnemyInSwordRange(int heroIndex) {
    if (!_isHeroAlive(heroIndex)) {
      return false;
    }
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
    _fireProjectileWithAoe(
      heroIndex,
      heroPos,
      heroColor,
      50,
      false,
      target: target,
    );
  }

  void _castMyrisFreeze(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      final dist = (enemy.position - heroPos).distance;
      if (dist <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: _heroCurrentAttackRange(heroIndex),
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
      if ((enemy.position - heroPos).distance <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
  }

  void _castKaelenHealingPulse(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    const healingRadius = 100.0;
    const healAmount = 2.0;
    for (final unit in _heroUnits) {
      if (!unit.isAlive) {
        continue;
      }
      if ((unit.position - heroPos).distance > healingRadius) {
        continue;
      }
      unit.hp = min(unit.maxHp, unit.hp + healAmount);
    }
  }

  void _castSolenneSunburst(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: _heroCurrentAttackRange(heroIndex),
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
      if ((enemy.position - heroPos).distance <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: _heroCurrentAttackRange(heroIndex),
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castRavikVoidBurst(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final heroColor = widget.heroes[heroIndex].color;
    _fireProjectileWithAoe(
      heroIndex,
      heroPos,
      heroColor,
      60,
      false,
      target: target,
    );
  }

  void _castRavikSoulDrain(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final first = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
      exclude: const <_Enemy>{},
    );
    if (first == null) {
      return;
    }
    _applyDamage(first, 5 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
    final unit = _heroUnits[heroIndex];
    final healAmount = unit.maxHp * 0.02;
    unit.hp = min(unit.maxHp, unit.hp + healAmount);

    final segments = <_LightningSegment>[
      _LightningSegment(
        start: heroPos,
        end: first.position,
        seed: _rng.nextDouble() * 1000,
      ),
    ];

    _lightnings.add(
      _LightningEffect(
        segments: segments,
        glowColor: const Color(0xFF2A2A2A),
        coreColor: const Color(0xFF000000),
        impactColor: const Color(0xFF141414),
      ),
    );
  }

  void _castBrannEarthquake(int heroIndex) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final damage = _effectiveDamage(heroIndex);
    for (final enemy in _enemies) {
      if (!_isEnemyTargetable(enemy)) {
        continue;
      }
      if ((enemy.position - heroPos).distance <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: _heroCurrentAttackRange(heroIndex),
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
      if ((enemy.position - heroPos).distance <= _heroCurrentAttackRange(heroIndex)) {
        _applyDamage(enemy, damage, heroIndex: heroIndex);
      }
    }
    _explosions.add(
      _ExplosionEffect(
        position: heroPos,
        radius: _heroCurrentAttackRange(heroIndex),
        isFire: false,
        seed: _rng.nextDouble() * 1000,
      ),
    );
  }

  void _castVeyraLightning(int heroIndex, {_Enemy? target}) {
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final resolvedTarget = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
    );
    if (resolvedTarget == null) {
      return;
    }

    _applyDamage(resolvedTarget, 30 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
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
    final heroPos = _heroPosition(_heroSlotIndices[heroIndex]);
    final used = <_Enemy>{};

    final first = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
      exclude: used,
    );
    if (first == null) {
      return;
    }
    used.add(first);
    _applyDamage(first, 8 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);

    final segments = <_LightningSegment>[
      _LightningSegment(
        start: heroPos,
        end: first.position,
        seed: _rng.nextDouble() * 1000,
      ),
    ];

    final second = _nearestEnemy(first.position, used);
    if (second != null) {
      used.add(second);
      _applyDamage(second, 6 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
      segments.add(
        _LightningSegment(
          start: first.position,
          end: second!.position,
          seed: _rng.nextDouble() * 1000,
        ),
      );

      final third = _nearestEnemy(second!.position, used);
      if (third != null) {
        used.add(third);
        _applyDamage(third, 4 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
        segments.add(
          _LightningSegment(
            start: second!.position,
            end: third!.position,
            seed: _rng.nextDouble() * 1000,
          ),
        );

        final fourth = _nearestEnemy(third!.position, used);
        if (fourth != null) {
          used.add(fourth);
          _applyDamage(fourth, 2 * (_heroUnits[heroIndex].rumbleProgress?.statMultiplier ?? 1.0), heroIndex: heroIndex);
          segments.add(
            _LightningSegment(
              start: third!.position,
              end: fourth!.position,
              seed: _rng.nextDouble() * 1000,
            ),
          );
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
    final resolvedTarget = _nearestEnemyForHero(
      heroIndex,
      preferredTarget: target,
    );
    if (resolvedTarget == null) {
      return;
    }
    final targetPos = resolvedTarget.position;

    final dir = (targetPos - heroPos);
    final len = max(dir.distance, 0.001);
    final velocity = Offset(
      dir.dx / len * projectileSpeed,
      dir.dy / len * projectileSpeed,
    );
    final damage = _effectiveDamage(heroIndex);

    _projectiles.add(
      _Projectile(
        position: heroPos,
        velocity: velocity,
        damage: damage,
        radius: projectileRadius,
        aoeRadius: aoeRadius,
        isAerinStrong: isFire,
        heroIndex: heroIndex,
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
                    builder: (_) => const VillageScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Zpět do vesnice'),
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
    final mapJoystickSize = _mapJoystickSizeForViewport(
      MediaQuery.sizeOf(context).height,
    );
    final selectionSquare = _activeSelectionSquare();
    final rangeIndicatorOpacity = _heroRangeIndicatorOpacity();
    final rangeIndicatorHeroIndices = _activeRangeIndicatorHeroIndices();
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
              widget.isRumble
                  ? _RumbleTopBar(
                      onBack: () => Navigator.of(context).pop(),
                      onZoomIn: () => _changeZoom(zoomStep),
                      onZoomOut: () => _changeZoom(-zoomStep),
                      wallHp: _wallHp,
                      currentWave: _currentWave,
                      totalWaves: _levelDef.waves.length,
                      coins: _gatheringCoins,
                      wood: _gatheringWood,
                      stone: _gatheringStone,
                    )
                  : widget.isGathering
                  ? _GatheringTopBar(
                      onBack: () => Navigator.of(context).pop(),
                      onZoomIn: () => _changeZoom(zoomStep),
                      onZoomOut: () => _changeZoom(-zoomStep),
                      coins: _gatheringCoins,
                      wood: _gatheringWood,
                      stone: _gatheringStone,
                    )
                  : _HpBar(
                      wallHp: _wallHp,
                      currentWave: _currentWave,
                      enemiesKilled: _enemiesKilled,
                      coinsEarned: _coinsEarned,
                      gameDurationText: _gameDurationText,
                      enemiesInWave: _enemiesSpawnedInWave,
                      totalEnemiesInWave: _totalEnemiesForCurrentWave(),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _openMenu(context),
                            icon: const Icon(Icons.menu),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fitToHeightScale = max(
                      constraints.maxHeight / cameraReferenceHeight,
                      constraints.maxWidth / baseMapWidth,
                    );
                    _updateMapScale(fitToHeightScale);

                    return Focus(
                      focusNode: _gameFocusNode,
                      autofocus: true,
                      onKeyEvent: _handleGameKeyEvent,
                      child: InteractiveViewer(
                        key: _interactiveViewerKey,
                        transformationController: _mapTransformController,
                        constrained: false,
                        panEnabled: false,
                        scaleEnabled: false,
                        boundaryMargin: EdgeInsets.zero,
                        minScale: fitToHeightScale * minZoomMultiplier,
                        maxScale: fitToHeightScale * maxZoomMultiplier,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: mapWidth,
                          height: mapHeight,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(mapWidth, mapHeight),
                                painter: _GamePainter(
                                  wallHp: _wallHp,
                                  wallHitEffectRemaining:
                                      _wallHitEffectRemaining,
                                  enemies: _enemies,
                                  projectiles: _projectiles,
                                  enemyProjectiles: _enemyProjectiles,
                                  damageTexts: _damageTexts,
                                  floatingCoinRewards: _floatingCoinRewards,
                                  explosions: _explosions,
                                  lightnings: _lightnings,
                                  wallX: heroAreaWidth,
                                  towerPosition: towerPosition,
                                  constructionSites: _constructionSites,
                                  towerWidth: towerWidth,
                                  towerHeight: towerHeight,
                                  heroes: widget.heroes,
                                  heroPositions: _heroUnits
                                      .map((unit) => unit.position)
                                      .toList(),
                                  heroAttackRanges: List<double>.generate(
                                    widget.heroes.length,
                                    _heroCurrentAttackRange,
                                  ),
                                  heroAlive: _heroUnits
                                      .map((unit) => unit.isAlive)
                                      .toList(),
                                  heroStates: _heroStates,
                                  thalorMode: _thalorMode,
                                  time: _lastTime,
                                  grassBackground: _grassBackground,
                                  wallSprite: _wallSprite,
                                  towerSprite: _towerSprite,
                                  portalSprite: _portalSpriteSheet,
                                  showPortal: _hasWorkerPortal,
                                  goldMineSprite: _goldMineSpriteSheet,
                                  groundSprites: _economySceneSprites(),
                                  goldMinePosition: widget.isGathering || widget.isRumble
                                      ? _gatheringGoldPosition : Offset.zero,
                                  showEconomyBuildings: widget.isGathering || widget.isRumble,
                                  zombieShooterProjectileSprite:
                                      _zombieShooterProjectileSprite,
                                  enemySpriteSheets: _enemySpriteSheets,
                                  enemySpriteFrameCounts:
                                      _enemySpriteFrameCounts,
                                  targetIndicator: _targetIndicator,
                                ),
                              ),
                              if (widget.isGathering || widget.isRumble)
                                for (final stonePosition
                                    in _gatheringStonePositions)
                                  Positioned(
                                    left: stonePosition.dx - 10,
                                    top: stonePosition.dy - 10,
                                    child: const IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF858B91),
                                          border: Border.fromBorderSide(
                                            BorderSide(
                                              color: Color(0xFF4D5358),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: SizedBox(width: 20, height: 20),
                                      ),
                                    ),
                                  ),
                              if (widget.isGathering || widget.isRumble)
                                for (final worker in _gatheringWorkers)
                                  if (worker.isAlive)
                                  Positioned(
                                    left:
                                        worker.position.dx -
                                        gatheringWorkerRenderSize / 2,
                                    top:
                                        worker.position.dy -
                                        gatheringWorkerRenderSize / 2,
                                    child: IgnorePointer(
                                      child: SizedBox(
                                        width: gatheringWorkerRenderSize,
                                        height: gatheringWorkerRenderSize,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox.expand(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: _workerSpriteSheet != null
                                                      ? Colors.transparent
                                                      : const Color(
                                                    0xFF1FA82E,
                                                  ),
                                                  border:
                                                      Border.fromBorderSide(
                                                        BorderSide(
                                                          color:
                                                              _selectedGatheringWorkerIndices.contains(
                                                                _gatheringWorkers.indexOf(worker),
                                                              )
                                                              ? const Color(
                                                                  0xFFFFFFFF,
                                                                )
                                                              : _workerSpriteSheet != null
                                                              ? Colors.transparent
                                                              : const Color(
                                                                  0xFF0E5A17,
                                                                ),
                                                          width:
                                                              _selectedGatheringWorkerIndices.contains(
                                                                _gatheringWorkers.indexOf(worker),
                                                              )
                                                              ? 3
                                                              : 2,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            if (_workerSpriteSheet != null)
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: _SpriteFramePainter(
                                                    spriteSheet: _workerSpriteSheet!,
                                                    flipHorizontally: _isWorkerFacingLeft(worker),
                                                    frameIndex: _workerFrameIndex(worker),
                                                    frameCount: workerSpriteFrameCount,
                                                    frameWidth: _workerSpriteSheet!.width / workerSpriteFrameCount,
                                                    frameHeight: _workerSpriteSheet!.height.toDouble(),
                                                  ),
                                                ),
                                              ),
                                            if (worker.carriedResource != null)
                                              Positioned(
                                                top: gatheringWorkerRenderSize * workerHpBarTopFactor - 16,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: worker.carriedResource ==
                                                            _GatheringResource.wood
                                                        ? const Color(0xFF8B5A2B)
                                                        : worker.carriedResource ==
                                                            _GatheringResource.stone
                                                            ? const Color(0xFF858B91)
                                                            : worker.carriedResource ==
                                                                    _GatheringResource.fragments
                                                                ? const Color(0xFF9B6CDE)
                                                            : const Color(0xFFF2C14E),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SizedBox(
                                                    width: 8,
                                                    height: 8,
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              top: gatheringWorkerRenderSize * workerHpBarTopFactor,
                                              child: _buildWorkerHpBar(worker),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              for (final heroIndex in rangeIndicatorHeroIndices)
                                Positioned(
                                  left:
                                      _heroPosition(heroIndex).dx -
                                      _heroCurrentAttackRange(heroIndex),
                                  top:
                                      _heroPosition(heroIndex).dy -
                                      _heroCurrentAttackRange(heroIndex),
                                  child: IgnorePointer(
                                    child: Container(
                                      width:
                                          _heroCurrentAttackRange(heroIndex) *
                                          2,
                                      height:
                                          _heroCurrentAttackRange(heroIndex) *
                                          2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.heroes[heroIndex].color
                                            .withOpacity(
                                              0.14 * rangeIndicatorOpacity,
                                            ),
                                        border: Border.all(
                                          color: widget.heroes[heroIndex].color
                                              .withOpacity(
                                                0.58 * rangeIndicatorOpacity,
                                              ),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned.fill(
                                child: Listener(
                                  onPointerSignal: (event) {
                                    if (event is! PointerScrollEvent ||
                                        event.kind !=
                                            ui.PointerDeviceKind.mouse) {
                                      return;
                                    }
                                    _gameFocusNode.requestFocus();
                                    final nextZoom = _zoomAfterStep(
                                      event.scrollDelta.dy < 0
                                          ? zoomStep
                                          : -zoomStep,
                                    );
                                    _setZoomAroundViewportPoint(
                                      nextZoom,
                                      _pointerEventToViewportPosition(event),
                                    );
                                  },
                                  onPointerDown: (event) {
                                    _handleGameplayPointerDown(event);
                                  },
                                  onPointerMove: (event) {
                                    _handleGameplayPointerMove(event);
                                  },
                                  onPointerUp: (event) {
                                    _handleGameplayPointerUp(event);
                                  },
                                  onPointerCancel: (event) {
                                    _handleGameplayPointerCancel(event);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              if (selectionSquare != null)
                                Positioned.fromRect(
                                  rect: selectionSquare,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color(0x3358D68D),
                                        border: Border.all(
                                          color: const Color(0xFF58D68D),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              for (int i = 0; i < widget.heroes.length; i++)
                                if (_heroUnits[i].isAlive)
                                  Positioned(
                                    key: ValueKey<String>('hero-unit-$i'),
                                    left: _heroPosition(i).dx -
                                        _heroWidgetWidthForIndex(i) / 2,
                                    top: _heroPosition(i).dy -
                                        _heroWidgetHeightForIndex(i) / 2,
                                    child: Listener(
                                      behavior: HitTestBehavior.opaque,
                                      onPointerDown: _handleGameplayPointerDown,
                                      onPointerMove: _handleGameplayPointerMove,
                                      onPointerUp: _handleGameplayPointerUp,
                                      onPointerCancel:
                                          _handleGameplayPointerCancel,
                                      child: SizedBox(
                                        width: _heroWidgetWidthForIndex(i),
                                        height: _heroWidgetHeightForIndex(i),
                                        child: Center(
                                          child: _HeroUnitWidget(
                                            key: ValueKey<String>(
                                              'hero-unit-widget-$i',
                                            ),
                                            hero: widget.heroes[i],
                                            state: _heroStates[i],
                                            isSelected:
                                                _selectedHeroIndex == i ||
                                                _multiSelectedHeroIndices
                                                    .contains(i),
                                            isMoving: _heroUnits[i].isMoving,
                                            hp: _heroUnits[i].hp,
                                            maxHp: _heroUnits[i].maxHp,
                                            magicEnergy:
                                                _heroStates[i].magicEnergy,
                                            cooldownDuration: heroCooldowns[i],
                                            attackAnimationRemainingTime:
                                                _heroAttackAnimationRemainingTimes[i],
                                            flipHorizontally:
                                                _shouldFlipHeroSprite(i),
                                            size: heroRenderSize,
                                            time: _lastTime,
                                          ),
                                        ),
                                        ),
                                      ),
                                    ),
                              // Buildings drawn again at 70 % over units standing behind them.
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _OcclusionPainter(
                                      occluders: _occluderSprites(),
                                      units: _occludableUnits(),
                                    ),
                                  ),
                                ),
                              ),
                              _buildSelectedHeroBehaviorMenu(),
                              _buildSelectedHeroModeMenu(),
                              ..._buildConstructionMarkers(),
                              _buildConstructionMenu(),
                              if (_hasWorkerPortal) _buildPortal(),
                              if (_portalMenuOpen) _buildPortalMenu(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _MapPanJoystick(
              size: mapJoystickSize,
              input: _mapJoystickInput,
              onPanDown: (localPosition) =>
                  _updateMapJoystickInput(localPosition, mapJoystickSize),
              onPanUpdate: (localPosition) =>
                  _updateMapJoystickInput(localPosition, mapJoystickSize),
              onPanEnd: _resetMapJoystickInput,
            ),
          ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _HeroCardsPanel(
                    leadingCard: _hasWorkerPortal
                        ? _GatheringQuickCard(
                            idleCount: _gatheringWorkers
                                .where((worker) => worker.isIdle).length,
                            totalCount: _gatheringWorkers
                                .where((worker) => worker.isAlive).length,
                            isSelected: _selectedGatheringWorkerIndices.isNotEmpty,
                            onTap: _selectIdleGatheringWorker,
                          )
                        : null,
                    heroes: widget.heroes,
                    heroUnits: _heroUnits,
                    selectedHeroIndex: _selectedHeroIndex,
                    multiSelectedHeroIndices: _multiSelectedHeroIndices,
                    onHeroTap: _selectHero,
                    onHeroRevive: _reviveHero,
                    onHeroDoubleTap: _centerMapOnHero,
                    onHeroMultiSelect: _selectHeroesFromCardIndices,
                  ),
                  if (!widget.isGathering) const SizedBox(width: 8),
                  if (!widget.isGathering) _SpeedPanel(
                    isOpen: _speedPanelOpen,
                    speed: _gameSpeed,
                    onToggle: () =>
                        setState(() => _speedPanelOpen = !_speedPanelOpen),
                    onSetSpeed: (value) => setState(() => _gameSpeed = value),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroCardsPanel extends StatefulWidget {
  const _HeroCardsPanel({
    this.leadingCard,
    required this.heroes,
    required this.heroUnits,
    required this.selectedHeroIndex,
    required this.multiSelectedHeroIndices,
    required this.onHeroTap,
    required this.onHeroRevive,
    required this.onHeroDoubleTap,
    required this.onHeroMultiSelect,
  });

  final Widget? leadingCard;
  final List<HeroDef> heroes;
  final List<_HeroUnit> heroUnits;
  final int? selectedHeroIndex;
  final Set<int> multiSelectedHeroIndices;
  final ValueChanged<int> onHeroTap;
  final ValueChanged<int> onHeroRevive;
  final ValueChanged<int> onHeroDoubleTap;
  final ValueChanged<Set<int>> onHeroMultiSelect;

  @override
  State<_HeroCardsPanel> createState() => _HeroCardsPanelState();
}

class _HeroCardsPanelState extends State<_HeroCardsPanel> {
  static const double _panelPadding = 8;
  static const double _cardSpacing = 8;
  static const Duration _doubleTapWindow = Duration(milliseconds: 280);

  Offset? _dragStartLocal;
  Offset? _dragCurrentLocal;
  int? _dragStartCardIndex;
  int? _pointerDownCardIndex;
  int? _lastTappedCardIndex;
  DateTime? _lastTapAt;

  Rect _cardRect(int index) {
    final left =
        _panelPadding + (index + (widget.leadingCard == null ? 0 : 1)) *
            (_HeroQuickCard.outerWidth + _cardSpacing);
    return Rect.fromLTWH(
      left,
      _panelPadding,
      _HeroQuickCard.outerWidth,
      _HeroQuickCard.outerHeight,
    );
  }

  int? _hitTestCard(Offset localPosition, {bool requireAlive = false}) {
    for (int i = 0; i < widget.heroes.length; i++) {
      if (requireAlive && !widget.heroUnits[i].isAlive) {
        continue;
      }
      if (_cardRect(i).contains(localPosition)) {
        return i;
      }
    }
    return null;
  }

  Rect? get _selectionRect {
    final start = _dragStartLocal;
    final current = _dragCurrentLocal;
    if (start == null || current == null || _dragStartCardIndex == null) {
      return null;
    }
    if ((current - start).distance < _GameViewState.multiSelectDragThreshold) {
      return null;
    }
    return Rect.fromPoints(start, current);
  }

  void _handlePointerDown(PointerDownEvent event) {
    final cardIndex = _hitTestCard(event.localPosition);
    final canDrag = cardIndex != null && widget.heroUnits[cardIndex].isAlive;
    setState(() {
      _pointerDownCardIndex = cardIndex;
      _dragStartLocal = canDrag ? event.localPosition : null;
      _dragCurrentLocal = null;
      _dragStartCardIndex = canDrag ? cardIndex : null;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final start = _dragStartLocal;
    if (start == null || _dragStartCardIndex == null) {
      return;
    }
    if ((event.localPosition - start).distance <
        _GameViewState.multiSelectDragThreshold) {
      return;
    }
    setState(() {
      _dragCurrentLocal = event.localPosition;
    });
  }

  void _handlePointerEnd(PointerEvent event) {
    final start = _dragStartLocal;
    final dragStartCardIndex = _dragStartCardIndex;
    final pointerDownCardIndex = _pointerDownCardIndex;
    final selectionRect = _selectionRect;
    final endPosition = event.localPosition;
    setState(() {
      _dragStartLocal = null;
      _dragCurrentLocal = null;
      _dragStartCardIndex = null;
      _pointerDownCardIndex = null;
    });
    if (start == null || dragStartCardIndex == null) {
      if (pointerDownCardIndex != null &&
          !widget.heroUnits[pointerDownCardIndex].isAlive &&
          (event.localPosition - (start ?? event.localPosition)).distance <=
              12) {
        widget.onHeroRevive(pointerDownCardIndex);
      }
      return;
    }
    if (selectionRect != null) {
      final selected = <int>{};
      for (int i = 0; i < widget.heroes.length; i++) {
        if (!widget.heroUnits[i].isAlive) {
          continue;
        }
        if (selectionRect.overlaps(_cardRect(i))) {
          selected.add(i);
        }
      }
      widget.onHeroMultiSelect(selected);
      return;
    }
    if ((endPosition - start).distance > 12) {
      return;
    }
    final tappedCardIndex = _hitTestCard(endPosition, requireAlive: true);
    if (tappedCardIndex == null || tappedCardIndex != dragStartCardIndex) {
      return;
    }
    final now = DateTime.now();
    final isDoubleTap =
        _lastTappedCardIndex == tappedCardIndex &&
        _lastTapAt != null &&
        now.difference(_lastTapAt!) <= _doubleTapWindow;
    widget.onHeroTap(tappedCardIndex);
    if (isDoubleTap) {
      widget.onHeroDoubleTap(tappedCardIndex);
      _lastTappedCardIndex = null;
      _lastTapAt = null;
      return;
    }
    _lastTappedCardIndex = tappedCardIndex;
    _lastTapAt = now;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB012171B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_panelPadding),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leadingCard != null) ...[
                    widget.leadingCard!,
                    if (widget.heroes.isNotEmpty)
                      const SizedBox(width: _cardSpacing),
                  ],
                  ...List.generate(widget.heroes.length, (index) {
                  final isSelected =
                      widget.selectedHeroIndex == index ||
                      widget.multiSelectedHeroIndices.contains(index);
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == widget.heroes.length - 1
                          ? 0
                          : _cardSpacing,
                    ),
                    child: _HeroQuickCard(
                      hero: widget.heroes[index],
                      unit: widget.heroUnits[index],
                      isSelected: isSelected,
                    ),
                  );
                  }),
                ],
              ),
              if (_selectionRect != null)
                Positioned.fromRect(
                  rect: _selectionRect!,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x3358D68D),
                        border: Border.all(
                          color: const Color(0xFF58D68D),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPanJoystick extends StatelessWidget {
  const _MapPanJoystick({
    required this.size,
    required this.input,
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final double size;
  final Offset input;
  final ValueChanged<Offset> onPanDown;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    final knobTravel = size * _GameViewState.mapJoystickKnobRadiusFactor;
    final knobOffset = Offset(
      input.dx.clamp(-1.0, 1.0) * knobTravel,
      input.dy.clamp(-1.0, 1.0) * knobTravel,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) => onPanDown(details.localPosition),
      onPanUpdate: (details) => onPanUpdate(details.localPosition),
      onPanEnd: (_) => onPanEnd(),
      onPanCancel: onPanEnd,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x5512181C),
                  borderRadius: BorderRadius.circular(size * 0.18),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(size * 0.14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x221D2830),
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
            ),
            Positioned(
              left: size / 2 + knobOffset.dx - size * 0.16,
              top: size / 2 + knobOffset.dy - size * 0.16,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xCC5FAAA0),
                  border: Border.all(color: Colors.white54, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x885FAAA0),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: size * 0.08,
              child: Text(
                'MAPA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroUnitWidget extends StatelessWidget {
  const _HeroUnitWidget({
    super.key,
    required this.hero,
    required this.state,
    required this.isSelected,
    required this.isMoving,
    required this.hp,
    required this.maxHp,
    required this.magicEnergy,
    required this.cooldownDuration,
    required this.attackAnimationRemainingTime,
    required this.flipHorizontally,
    required this.size,
    required this.time,
  });

  final HeroDef hero;
  final _HeroState state;
  final bool isSelected;
  final bool isMoving;
  final double hp;
  final double maxHp;
  final double magicEnergy;
  final double cooldownDuration;
  final double attackAnimationRemainingTime;
  final bool flipHorizontally;
  final double size;
  final double time;

  static const String _aerinSpriteSheetAsset =
      'assets/heroes/Aerin/Aerin_idle_sheet.png';
  static const String _aerinFallbackAsset = 'assets/heroes/Aerin_default.png';
  static const String _brannInGameSpriteAsset =
      'assets/heroes/Brann/BrannIdle.png';
  static const String _brannWalkSpriteAsset =
      'assets/heroes/Brann/BrannWalk.png';
  static const String _brannAttackSpriteAsset =
      'assets/heroes/Brann/BrannAttack.png';
  static const double _brannAttackAnimationDurationSeconds = 3.7;
  static const double _brannVisualScale = 8 / 9;
  static const double _brannHorizontalOffset = 0.0;
  static const double _brannVerticalOffset = 0.0;
  static const double _brannWidgetWidthFactor = 2.2;
  static const double _brannWidgetHeightFactor = 1.5;
  static const double _brannShadowInsetFactor = 0.385;
  static double get brannWidgetWidthFactor => _brannWidgetWidthFactor;
  static double get brannWidgetHeightFactor => _brannWidgetHeightFactor;
  static const String _nyxraInGameSpriteAsset = 'assets/heroes/Nyxra/Nyxra.png';
  static const int _aerinFrameCount = 16;
  static const double _aerinFrameWidth = 316;
  static const double _aerinFrameHeight = 307;
  static ui.Image? _aerinSpriteSheetCache;
  static final Future<ui.Image?> _aerinSpriteSheetFuture =
      _loadAerinSpriteSheet();
  // Attack frames are wider than idle (room for the fireball on the right);
  // the hero keeps the idle position, the extra width overflows to the right.
  static const String _aerinAttackSpriteSheetAsset =
      'assets/heroes/Aerin/Aerin_attack_sheet.png';
  static const int _aerinAttackFrameCount = 13;
  static const double _aerinAttackFrameWidth = 420;
  static const double _aerinAttackFrameHeight = 307;
  static const double _aerinAttackFramesPerSecond = 12;
  static ui.Image? _aerinAttackSpriteSheetCache;
  static final Future<ui.Image?> _aerinAttackSpriteSheetFuture =
      _loadSpriteSheet(_aerinAttackSpriteSheetAsset);
  static const double _aerinAttackAnimationDurationSeconds =
      _aerinAttackFrameCount / _aerinAttackFramesPerSecond;
  static double get aerinAttackAnimationDurationSeconds =>
      _aerinAttackAnimationDurationSeconds;
  // Run cycle uses the same 316x307 frame and anchoring as idle.
  static const String _aerinWalkSpriteSheetAsset =
      'assets/heroes/Aerin/Aerin_walk_sheet.png';
  static const int _aerinWalkFrameCount = 12;
  static const double _aerinWalkFramesPerSecond = 14;
  static ui.Image? _aerinWalkSpriteSheetCache;
  static final Future<ui.Image?> _aerinWalkSpriteSheetFuture =
      _loadSpriteSheet(_aerinWalkSpriteSheetAsset);
  static const String _veyraSpriteSheetAsset =
      'assets/heroes/Veyra/standing/Veyra_sheet.png';
  static const int _veyraFrameCount = 16;
  static const double _veyraFrameWidth = 688;
  static const double _veyraFrameHeight = 464;
  static ui.Image? _veyraSpriteSheetCache;
  static final Future<ui.Image?> _veyraSpriteSheetFuture = _loadSpriteSheet(
    _veyraSpriteSheetAsset,
  );
  static const String _veyraAttackSpriteSheetAsset =
      'assets/heroes/Veyra/attack/Veyra_attack_sheet_grid.png';
  static const int _veyraAttackFrameCount = 29;
  static const int _veyraAttackFrameColumns = 6;
  static const double _veyraAttackFrameWidth = 512;
  static const double _veyraAttackFrameHeight = 345;
  static ui.Image? _veyraAttackSpriteSheetCache;
  static final Future<ui.Image?> _veyraAttackSpriteSheetFuture =
      _loadSpriteSheet(_veyraAttackSpriteSheetAsset);
  static const double _veyraAttackAnimationDurationSeconds = 2.9;
  static double get veyraAttackAnimationDurationSeconds =>
      _veyraAttackAnimationDurationSeconds;
  static double get brannAttackAnimationDurationSeconds =>
      _brannAttackAnimationDurationSeconds;

  static Future<ui.Image?> _loadSpriteSheet(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (assetPath == _aerinSpriteSheetAsset) {
        _aerinSpriteSheetCache = image;
      } else if (assetPath == _aerinAttackSpriteSheetAsset) {
        _aerinAttackSpriteSheetCache = image;
      } else if (assetPath == _aerinWalkSpriteSheetAsset) {
        _aerinWalkSpriteSheetCache = image;
      } else if (assetPath == _veyraSpriteSheetAsset) {
        _veyraSpriteSheetCache = image;
      } else if (assetPath == _veyraAttackSpriteSheetAsset) {
        _veyraAttackSpriteSheetCache = image;
      }
      return image;
    } catch (_) {
      return null;
    }
  }

  static Future<ui.Image?> _loadAerinSpriteSheet() async {
    // Warm the attack sheet before the first attack starts its frame timer.
    await _aerinAttackSpriteSheetFuture;
    await _aerinWalkSpriteSheetFuture;
    return _loadSpriteSheet(_aerinSpriteSheetAsset);
  }

  bool get _usesBaseHorizontalFlip => hero.name == 'Veyra';

  bool get _effectiveFlipHorizontally =>
      _usesBaseHorizontalFlip != flipHorizontally;

  Widget _maybeFlip({required Widget child, required bool flip}) {
    if (!flip) {
      return child;
    }
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(-1, 1, 1),
      child: child,
    );
  }

  Widget _buildHeroImage({
    required String imageAsset,
    required bool isTransparentInGameSprite,
    required bool flipHorizontally,
    double scale = 1.0,
    Offset offset = Offset.zero,
  }) {
    final image = Image.asset(
      imageAsset,
      fit: isTransparentInGameSprite ? BoxFit.contain : BoxFit.cover,
      filterQuality: isTransparentInGameSprite
          ? FilterQuality.none
          : FilterQuality.low,
      isAntiAlias: !isTransparentInGameSprite,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        if (isTransparentInGameSprite) {
          return Image.asset(
            _aerinFallbackAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            isAntiAlias: false,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, color: Colors.white70, size: 20);
            },
          );
        }
        return const Icon(Icons.person, color: Colors.white70, size: 20);
      },
    );
    final transformedChild = offset == Offset.zero
        ? (scale == 1.0 ? image : Transform.scale(scale: scale, child: image))
        : Transform.translate(
            offset: offset,
            child: scale == 1.0
                ? image
                : Transform.scale(scale: scale, child: image),
          );
    return _maybeFlip(flip: flipHorizontally, child: transformedChild);
  }

  Widget _buildAerinFrame(int frameIndex) {
    return FutureBuilder<ui.Image?>(
      future: _aerinSpriteSheetFuture,
      key: const ValueKey('aerin-idle-sheet'),
      initialData: _aerinSpriteSheetCache,
      builder: (context, snapshot) {
        final spriteSheet = snapshot.data ?? _aerinSpriteSheetCache;
        if (spriteSheet == null) {
          return _buildHeroImage(
            imageAsset: _aerinFallbackAsset,
            isTransparentInGameSprite: true,
            flipHorizontally: _effectiveFlipHorizontally,
          );
        }
        return SizedBox.expand(
          child: CustomPaint(
            painter: _SpriteFramePainter(
              spriteSheet: spriteSheet,
              frameIndex: frameIndex,
              frameCount: _aerinFrameCount,
              frameWidth: _aerinFrameWidth,
              frameHeight: _aerinFrameHeight,
              flipHorizontally: _effectiveFlipHorizontally,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAerinWalkFrame(int idleFrameIndex) {
    return FutureBuilder<ui.Image?>(
      future: _aerinWalkSpriteSheetFuture,
      key: const ValueKey('aerin-walk-sheet'),
      initialData: _aerinWalkSpriteSheetCache,
      builder: (context, snapshot) {
        final spriteSheet = snapshot.data ?? _aerinWalkSpriteSheetCache;
        if (spriteSheet == null) {
          return _buildAerinFrame(idleFrameIndex);
        }
        return SizedBox.expand(
          child: CustomPaint(
            painter: _SpriteFramePainter(
              spriteSheet: spriteSheet,
              frameIndex:
                  (time * _aerinWalkFramesPerSecond).floor() %
                  _aerinWalkFrameCount,
              frameCount: _aerinWalkFrameCount,
              frameWidth: _aerinFrameWidth,
              frameHeight: _aerinFrameHeight,
              flipHorizontally: _effectiveFlipHorizontally,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAerinAnimatedFrame({
    required int idleFrameIndex,
    required double attackAnimationRemainingTime,
  }) {
    if (attackAnimationRemainingTime <= 0) {
      return isMoving
          ? _buildAerinWalkFrame(idleFrameIndex)
          : _buildAerinFrame(idleFrameIndex);
    }
    final attackAnimationElapsed =
        _aerinAttackAnimationDurationSeconds - attackAnimationRemainingTime;
    final attackFrameIndex = min(
      _aerinAttackFrameCount - 1,
      (attackAnimationElapsed * _aerinAttackFramesPerSecond).floor(),
    );
    return FutureBuilder<ui.Image?>(
      future: _aerinAttackSpriteSheetFuture,
      key: const ValueKey('aerin-attack-sheet'),
      initialData: _aerinAttackSpriteSheetCache,
      builder: (context, snapshot) {
        final spriteSheet = snapshot.data ?? _aerinAttackSpriteSheetCache;
        if (spriteSheet == null) {
          return _buildAerinFrame(idleFrameIndex);
        }
        return SizedBox.expand(
          child: CustomPaint(
            painter: _SpriteFramePainter(
              spriteSheet: spriteSheet,
              frameIndex: attackFrameIndex,
              frameCount: _aerinAttackFrameCount,
              frameWidth: _aerinAttackFrameWidth,
              frameHeight: _aerinAttackFrameHeight,
              layoutFrameWidth: _aerinFrameWidth,
              layoutFrameHeight: _aerinFrameHeight,
              flipHorizontally: _effectiveFlipHorizontally,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVeyraIdleFrame(int frameIndex) {
    return FutureBuilder<ui.Image?>(
      future: _veyraSpriteSheetFuture,
      initialData: _veyraSpriteSheetCache,
      builder: (context, snapshot) {
        final spriteSheet = snapshot.data ?? _veyraSpriteSheetCache;
        if (spriteSheet == null) {
          return _buildHeroImage(
            imageAsset: hero.imageAsset,
            isTransparentInGameSprite: false,
            flipHorizontally: _effectiveFlipHorizontally,
          );
        }
        return SizedBox.expand(
          child: CustomPaint(
            painter: _SpriteFramePainter(
              spriteSheet: spriteSheet,
              frameIndex: frameIndex,
              frameCount: _veyraFrameCount,
              frameWidth: _veyraFrameWidth,
              frameHeight: _veyraFrameHeight,
              flipHorizontally: _effectiveFlipHorizontally,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVeyraFrame({
    required int idleFrameIndex,
    required double attackAnimationRemainingTime,
  }) {
    if (attackAnimationRemainingTime <= 0) {
      return _buildVeyraIdleFrame(idleFrameIndex);
    }
    final attackAnimationElapsed =
        _veyraAttackAnimationDurationSeconds - attackAnimationRemainingTime;
    final attackFrameIndex = min(
      _veyraAttackFrameCount - 1,
      (attackAnimationElapsed * 10).floor(),
    );
    return FutureBuilder<ui.Image?>(
      future: _veyraAttackSpriteSheetFuture,
      initialData: _veyraAttackSpriteSheetCache,
      builder: (context, snapshot) {
        final spriteSheet = snapshot.data ?? _veyraAttackSpriteSheetCache;
        if (spriteSheet == null) {
          return _buildVeyraIdleFrame(idleFrameIndex);
        }
        return SizedBox.expand(
          child: CustomPaint(
            painter: _SpriteFramePainter(
              spriteSheet: spriteSheet,
              frameIndex: attackFrameIndex,
              frameCount: _veyraAttackFrameCount,
              frameColumns: _veyraAttackFrameColumns,
              frameWidth: _veyraAttackFrameWidth,
              frameHeight: _veyraAttackFrameHeight,
              flipHorizontally: _effectiveFlipHorizontally,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pulse = sin(time * 6) * 0.5 + 0.5;
    final isAerinInGameSprite = hero.name == 'Aerin';
    final isBrannInGameSprite = hero.name == 'Brann';
    final isNyxraInGameSprite = hero.name == 'Nyxra';
    final isVeyraInGameSprite = hero.name == 'Veyra';
    final usesTransparentInGameSprite =
        isAerinInGameSprite || isVeyraInGameSprite || isBrannInGameSprite;
    final widgetWidth = isBrannInGameSprite
        ? size * _brannWidgetWidthFactor
        : size;
    final widgetHeight = isBrannInGameSprite
        ? size * _brannWidgetHeightFactor
        : size;
    final shadowBottomOffset = isVeyraInGameSprite ? size * 0.10 : size * 0.04;
    final shadowHorizontalInset = isBrannInGameSprite
        ? widgetWidth * _brannShadowInsetFactor
        : widgetWidth * 0.15;
    final cooldownFraction =
        (state.phase == _HeroPhase.cooldown && cooldownDuration > 0)
        ? (state.timeRemaining / cooldownDuration).clamp(0.0, 1.0)
        : 0.0;
    final hpFraction = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    final magicEnergyFraction =
        (magicEnergy / _GameViewState.heroMagicEnergyMax).clamp(0.0, 1.0);

    return SizedBox(
      width: widgetWidth,
      height: widgetHeight + 22,
      child: Column(
        children: [
          SizedBox(
            width: widgetWidth,
            height: widgetHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: shadowHorizontalInset,
                  right: shadowHorizontalInset,
                  bottom: shadowBottomOffset,
                  child: Container(
                    height: size * 0.14,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Container(
                  width: widgetWidth,
                  height: widgetHeight,
                  decoration: BoxDecoration(
                    color: usesTransparentInGameSprite
                        ? Colors.transparent
                        : hero.color.withOpacity(isMoving ? 0.75 : 0.9),
                    borderRadius: BorderRadius.circular(
                      usesTransparentInGameSprite ? 0 : 10,
                    ),
                    border: usesTransparentInGameSprite
                        ? null
                        : Border.all(
                            color: isSelected
                                ? const Color(0xFFFFE08A)
                                : Colors.white24,
                            width: isSelected ? 2.5 : 1,
                          ),
                    boxShadow: isSelected && !usesTransparentInGameSprite
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFFE08A,
                              ).withOpacity(0.5 + pulse * 0.35),
                              blurRadius: 14 + pulse * 6,
                              spreadRadius: 1.5,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    clipBehavior: usesTransparentInGameSprite
                        ? Clip.none
                        : Clip.antiAlias,
                    borderRadius: BorderRadius.circular(
                      usesTransparentInGameSprite ? 0 : 9,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: usesTransparentInGameSprite
                          ? Clip.none
                          : Clip.hardEdge,
                      children: [
                        if (isAerinInGameSprite)
                          _buildAerinAnimatedFrame(
                            idleFrameIndex:
                                (time * 12).floor() % _aerinFrameCount,
                            attackAnimationRemainingTime:
                                attackAnimationRemainingTime,
                          )
                        else if (isVeyraInGameSprite)
                          _buildVeyraFrame(
                            idleFrameIndex:
                                (time * 12).floor() % _veyraFrameCount,
                            attackAnimationRemainingTime:
                                attackAnimationRemainingTime,
                          )
                        else if (isBrannInGameSprite)
                          _buildHeroImage(
                            imageAsset: isMoving
                                ? _brannWalkSpriteAsset
                                : attackAnimationRemainingTime > 0
                                ? _brannAttackSpriteAsset
                                : _brannInGameSpriteAsset,
                            isTransparentInGameSprite: true,
                            flipHorizontally: _effectiveFlipHorizontally,
                            scale: _brannVisualScale,
                            offset: const Offset(
                              _brannHorizontalOffset,
                              _brannVerticalOffset,
                            ),
                          )
                        else if (isNyxraInGameSprite)
                          _buildHeroImage(
                            imageAsset: _nyxraInGameSpriteAsset,
                            isTransparentInGameSprite: false,
                            flipHorizontally: _effectiveFlipHorizontally,
                          )
                        else if (hero.imageAsset.isNotEmpty)
                          _buildHeroImage(
                            imageAsset: hero.imageAsset,
                            isTransparentInGameSprite: false,
                            flipHorizontally: _effectiveFlipHorizontally,
                          )
                        else
                          const Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 20,
                          ),
                        if (isMoving && !usesTransparentInGameSprite)
                          Container(
                            color: const Color(0x66000000),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.directions_run,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: size,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x66160F0F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: hpFraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF6A6A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
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
          const SizedBox(height: 2),
          Container(
            width: size,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x66351C5E),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: magicEnergyFraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB47CFF),
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
  const _ZoomButton({required this.icon, required this.onTap});

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

class _GatheringQuickCard extends StatelessWidget {
  const _GatheringQuickCard({
    required this.idleCount,
    required this.totalCount,
    required this.isSelected,
    required this.onTap,
  });

  final int idleCount;
  final int totalCount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = idleCount > 0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Sběrači: $idleCount volných z $totalCount',
      child: Tooltip(
        message: 'Vybrat volného sběrače',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Container(
            width: _HeroQuickCard.outerWidth,
            height: _HeroQuickCard.outerHeight,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: enabled ? const Color(0xCC1A2228) : const Color(0xCC3A3A3A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: enabled && isSelected
                    ? const Color(0xFFFFE08A) : Colors.white24,
                width: enabled && isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.groups, size: 32,
                    color: enabled ? const Color(0xFF1FA82E) : Colors.grey),
                Text('Sběrači', style: TextStyle(
                    fontSize: 10, color: enabled ? Colors.white : Colors.white38)),
                Text('$idleCount / $totalCount', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : Colors.white38)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroQuickCard extends StatelessWidget {
  const _HeroQuickCard({
    required this.hero,
    required this.unit,
    required this.isSelected,
  });

  static const double outerWidth = 66;
  static const double outerHeight = 80;

  static const List<double> _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  final HeroDef hero;
  final _HeroUnit unit;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final hpFraction = unit.maxHp > 0
        ? (unit.hp / unit.maxHp).clamp(0.0, 1.0)
        : 0.0;
    final isDead = !unit.isAlive;
    final progress = unit.rumbleProgress;
    final xpFraction = progress == null
        ? 0.0
        : (progress.xp / progress.xpForNextLevel).clamp(0.0, 1.0).toDouble();
    final content = Container(
      width: outerWidth,
      height: outerHeight,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 7),
      decoration: BoxDecoration(
        color: isDead ? const Color(0xCC3A3A3A) : const Color(0xCC1A2228),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFE08A) : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0x66FFE08A),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          SizedBox(
            width: 52,
            height: 52,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: hero.imageAsset.isNotEmpty
                  ? ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        isDead
                            ? _grayscaleMatrix
                            : const <double>[
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ],
                      ),
                      child: Opacity(
                        opacity: isDead ? 0.55 : 1,
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
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: isDead ? Colors.white38 : Colors.white54,
                    ),
            ),
          ),
          const SizedBox(height: 2),
          if (progress != null)
            Container(
              width: double.infinity,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF17324D),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 54 * xpFraction,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36AEFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0x66160F0F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 54 * hpFraction,
                decoration: BoxDecoration(
                  color: isDead
                      ? Colors.grey.shade500
                      : Color.lerp(
                              const Color(0xFFE14D4D),
                              const Color(0xFF58D68D),
                              hpFraction,
                            ) ??
                            const Color(0xFF58D68D),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
            ],
          ),
          if (unit.rumbleProgress != null)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xEE7A4B11),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFD166), width: 1),
                ),
                child: Text(
                  '${unit.rumbleProgress!.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          if (isDead)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xAA242424),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Color(0xFFFFD54F), size: 22),
                      SizedBox(height: 2),
                      Text(
                        'Ozivit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '200',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (progress == null) {
      return content;
    }
    return Tooltip(
      message: 'Úroveň ${progress.level} · XP ${progress.xp}/${progress.xpForNextLevel}',
      child: content,
    );
  }
}

/// A static map sprite (building, tree, mana pool) or its painted fallback box.
class _SceneSprite {
  const _SceneSprite({
    required this.dst,
    this.image,
    this.src = Rect.zero,
    this.color,
    this.border,
  });

  final Rect dst;
  final ui.Image? image;
  final Rect src;
  final Color? color;
  final Color? border;

  /// Units above this line stand behind the sprite (its lower half blocks).
  double get baseline => dst.center.dy;

  void paint(Canvas canvas, {double opacity = 1}) {
    final sheet = image;
    if (sheet != null) {
      canvas.drawImageRect(
        sheet,
        src,
        dst,
        Paint()
          ..filterQuality = FilterQuality.none
          ..color = Color.fromRGBO(255, 255, 255, opacity),
      );
      return;
    }
    final fill = color;
    if (fill == null) return;
    canvas.drawRect(dst, Paint()..color = fill.withOpacity(fill.opacity * opacity));
    final edge = border;
    if (edge != null) {
      canvas.drawRect(
        dst.deflate(1),
        Paint()
          ..color = edge.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }
}

/// Redraws buildings over units that stand behind them, so those units stay
/// visible only faintly (the building covers them at 70 % opacity). Units in
/// front of the same building are cut out of the overlay.
class _OcclusionPainter extends CustomPainter {
  const _OcclusionPainter({required this.occluders, required this.units});

  static const double behindOpacity = 0.7;

  final List<_SceneSprite> occluders;
  final List<(Rect, double)> units;

  @override
  void paint(Canvas canvas, Size size) {
    for (final occluder in occluders) {
      Path? behind;
      Path? front;
      for (final (rect, groundY) in units) {
        if (!rect.overlaps(occluder.dst)) continue;
        final path = groundY < occluder.baseline
            ? (behind ??= Path())
            : (front ??= Path());
        path.addRect(rect);
      }
      if (behind == null) continue;
      final clip = front == null
          ? behind
          : Path.combine(PathOperation.difference, behind, front);
      canvas.save();
      canvas.clipPath(clip);
      occluder.paint(canvas, opacity: behindOpacity);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OcclusionPainter oldDelegate) => true;
}

class _SpriteFramePainter extends CustomPainter {
  const _SpriteFramePainter({
    required this.spriteSheet,
    required this.frameIndex,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
    this.frameColumns,
    this.flipHorizontally = false,
    this.layoutFrameWidth,
    this.layoutFrameHeight,
  });

  final ui.Image spriteSheet;
  final int frameIndex;
  final int frameCount;
  final double frameWidth;
  final double frameHeight;
  final int? frameColumns;
  final bool flipHorizontally;
  // Optional reference frame size used for scaling and centring. A wider
  // frame then keeps the same scale and left edge and overflows to the right.
  final double? layoutFrameWidth;
  final double? layoutFrameHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || frameCount <= 0) {
      return;
    }
    final clampedFrameIndex = frameIndex.clamp(0, frameCount - 1);
    final columns = frameColumns == null || frameColumns! <= 0
        ? frameCount
        : frameColumns!;
    final src = Rect.fromLTWH(
      (clampedFrameIndex % columns) * frameWidth,
      (clampedFrameIndex ~/ columns) * frameHeight,
      frameWidth,
      frameHeight,
    );
    final layoutWidth = layoutFrameWidth ?? frameWidth;
    final layoutHeight = layoutFrameHeight ?? frameHeight;
    final scale = min(size.width / layoutWidth, size.height / layoutHeight);
    final dst = Rect.fromLTWH(
      (size.width - layoutWidth * scale) / 2,
      (size.height - layoutHeight * scale) / 2,
      frameWidth * scale,
      frameHeight * scale,
    );
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;
    if (flipHorizontally) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
      canvas.drawImageRect(spriteSheet, src, dst, paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(spriteSheet, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpriteFramePainter oldDelegate) {
    return oldDelegate.spriteSheet != spriteSheet ||
        oldDelegate.frameIndex != frameIndex ||
        oldDelegate.frameCount != frameCount ||
        oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight ||
        oldDelegate.frameColumns != frameColumns ||
        oldDelegate.flipHorizontally != flipHorizontally ||
        oldDelegate.layoutFrameWidth != layoutFrameWidth ||
        oldDelegate.layoutFrameHeight != layoutFrameHeight;
  }
}

class _HeroUnit {
  _HeroUnit({
    required this.position,
    required this.target,
    required this.homePosition,
    required this.hp,
    required this.maxHp,
    this.rumbleProgress,
  });

  Offset position;
  Offset target;
  Offset homePosition;
  double hp;
  double maxHp;
  final RumbleHeroProgress? rumbleProgress;
  bool isMoving = false;
  bool isAlive = true;
  bool hasManualMoveOrder = false;
  double defensiveRetreatLockUntil = 0;
  _Enemy? forcedAttackTarget;
}

class _Enemy {
  _Enemy({
    double animationOffset = 0,
    required this.position,
    required this.hp,
    required this.maxHp,
    required this.seed,
    required this.speed,
    required this.damagePerSecond,
    required this.typeId,
    this.isRanged = false,
    this.rangedAttackRange = 0,
    this.rangedAttackCooldown = 1,
    this.projectileDamage = 0,
  }) : animTime = animationOffset;

  Offset position;
  double hp;
  final double maxHp;
  final double seed;
  final double speed;
  final double damagePerSecond;
  final String typeId;
  final bool isRanged;
  final double rangedAttackRange;
  final double rangedAttackCooldown;
  final double projectileDamage;
  bool attacking = false;
  double attackCooldownRemaining = 0;
  _EnemyCombatTarget? combatTarget;
  Offset? wallDestination;
  Offset? navigationDestination;
  double navigationRefreshRemaining = 0;
  double targetScanRemaining = 0;
  double flashRemaining = 0;
  double hitAnimRemaining = 0;
  double damageTextCooldown = 0;
  double pendingDamage = 0;
  double animTime;
  bool isDying = false;
  double deathAnimTime = 0;
  double corpseFadeTime = 0;

  static const int deathFrameCount = 6;
  static const double deathFrameDuration =
      _GameViewState.enemyDeathFrameDuration;
  static const double deathDuration = deathFrameCount * deathFrameDuration;

  bool get canRemove =>
      isDying && corpseFadeTime >= _GameViewState.enemyCorpseFadeDuration;
}

class _ScheduledSpawn {
  const _ScheduledSpawn({
    required this.time,
    required this.enemyType,
    required this.lane,
    required this.hpMultiplier,
    required this.speedMultiplier,
    required this.seedOffset,
  });

  final double time;
  final EnemyTypeDef enemyType;
  final int lane;
  final double hpMultiplier;
  final double speedMultiplier;
  final double seedOffset;
}

class _EnemySpriteConfig {
  const _EnemySpriteConfig({
    required this.assetPath,
    required this.frameWidth,
    required this.frameHeight,
    required this.walkFrameStart,
    required this.walkFrameCount,
    required this.attackFrameStart,
    required this.attackFrameCount,
    this.hitFrameStart,
    this.hitFrameCount = 0,
    this.deathFrameCount = _Enemy.deathFrameCount,
  });

  final String assetPath;
  final double frameWidth;
  final double frameHeight;
  final int walkFrameStart;
  final int walkFrameCount;
  final int attackFrameStart;
  final int attackFrameCount;
  final int? hitFrameStart;
  final int hitFrameCount;
  final int deathFrameCount;
}

const Map<String, _EnemySpriteConfig> _enemySpriteConfigs =
    <String, _EnemySpriteConfig>{
      'fat_zombie': _EnemySpriteConfig(
        assetPath: 'assets/enemies/FatZombie.png',
        frameWidth: 90,
        frameHeight: 90,
        walkFrameStart: 8,
        walkFrameCount: 8,
        attackFrameStart: 16,
        attackFrameCount: 9,
      ),
      'vampire': _EnemySpriteConfig(
        assetPath: 'assets/enemies/Vampire.png',
        frameWidth: 90,
        frameHeight: 90,
        walkFrameStart: 8,
        walkFrameCount: 8,
        attackFrameStart: 16,
        attackFrameCount: 9,
        hitFrameStart: 25,
        hitFrameCount: 2,
      ),
      'devil': _EnemySpriteConfig(
        assetPath: 'assets/enemies/Devil.png',
        frameWidth: 90,
        frameHeight: 90,
        walkFrameStart: 8,
        walkFrameCount: 8,
        attackFrameStart: 16,
        attackFrameCount: 9,
        hitFrameStart: 25,
        hitFrameCount: 2,
      ),
      'orc': _EnemySpriteConfig(
        assetPath: 'assets/enemies/Orc.png',
        frameWidth: 90,
        frameHeight: 90,
        walkFrameStart: 8,
        walkFrameCount: 8,
        attackFrameStart: 16,
        attackFrameCount: 9,
        hitFrameStart: 25,
        hitFrameCount: 2,
      ),
      'zombie_female': _EnemySpriteConfig(
        assetPath: 'assets/enemies/ZombieFemale.png',
        frameWidth: 62,
        frameHeight: 37,
        walkFrameStart: 8,
        walkFrameCount: 8,
        attackFrameStart: 16,
        attackFrameCount: 8,
        deathFrameCount: 9,
      ),
      'skull_mage': _EnemySpriteConfig(
        assetPath: 'assets/enemies/Skull_mage_sprite_sheet.png',
        frameWidth: 180,
        frameHeight: 180,
        walkFrameStart: 0,
        walkFrameCount: 18,
        attackFrameStart: 18,
        attackFrameCount: 7,
        deathFrameCount: 5,
      ),
      'zombie_shooter': _EnemySpriteConfig(
        assetPath: 'assets/enemies/ZombieShooter.png',
        frameWidth: 90,
        frameHeight: 90,
        walkFrameStart: 7,
        walkFrameCount: 9,
        attackFrameStart: 16,
        attackFrameCount: 6,
        hitFrameStart: 22,
        hitFrameCount: 5,
        deathFrameCount: 5,
      ),
    };

class _Projectile {
  _Projectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.radius,
    required this.aoeRadius,
    required this.isAerinStrong,
    required this.seed,
    this.color = const Color(0xFFF2E86D),
    this.heroIndex,
  });

  Offset position;
  Offset velocity;
  double damage;
  double radius;
  double aoeRadius;
  final bool isAerinStrong;
  final double seed;
  final Color color;
  final int? heroIndex;
}

class _EnemyProjectile {
  _EnemyProjectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.radius,
    required this.color,
    this.targetHeroIndex,
    this.targetWorkerIndex,
  });

  Offset position;
  final Offset velocity;
  final double damage;
  final double radius;
  final Color color;
  final int? targetHeroIndex;
  final int? targetWorkerIndex;
  bool isImpacting = false;
  double impactTimeRemaining = 0;
  double animTime = 0;

  static const int flightFrameCount = 4;
  static const int impactFrameCount = 4;
}

class _GamePainter extends CustomPainter {
  _GamePainter({
    required this.wallHp,
    required this.wallHitEffectRemaining,
    required this.enemies,
    required this.projectiles,
    required this.enemyProjectiles,
    required this.damageTexts,
    required this.floatingCoinRewards,
    required this.explosions,
    required this.lightnings,
    required this.wallX,
    required this.towerPosition,
    required this.constructionSites,
    required this.towerWidth,
    required this.towerHeight,
    required this.heroes,
    required this.heroPositions,
    required this.heroAttackRanges,
    required this.heroAlive,
    required this.heroStates,
    required this.thalorMode,
    required this.time,
    required this.grassBackground,
    required this.wallSprite,
    required this.towerSprite,
    required this.portalSprite,
    required this.showPortal,
    required this.goldMineSprite,
    this.groundSprites = const <_SceneSprite>[],
    required this.goldMinePosition,
    required this.showEconomyBuildings,
    required this.zombieShooterProjectileSprite,
    required this.enemySpriteSheets,
    required this.enemySpriteFrameCounts,
    this.targetIndicator,
  });

  final double wallHp;
  final double wallHitEffectRemaining;
  final List<_Enemy> enemies;
  final List<_Projectile> projectiles;
  final List<_EnemyProjectile> enemyProjectiles;
  final List<_DamageText> damageTexts;
  final List<_FloatingCoinReward> floatingCoinRewards;
  final List<_ExplosionEffect> explosions;
  final List<_LightningEffect> lightnings;
  final double wallX;
  final Offset towerPosition;
  final List<_ConstructionSite> constructionSites;
  final double towerWidth;
  final double towerHeight;
  final List<HeroDef> heroes;
  final List<Offset> heroPositions;
  final List<double> heroAttackRanges;
  final List<bool> heroAlive;
  final List<_HeroState> heroStates;
  final _ThalorMode thalorMode;
  final double time;
  final ui.Image? grassBackground;
  final ui.Image? wallSprite;
  final ui.Image? towerSprite;
  final ui.Image? portalSprite;
  final bool showPortal;
  final ui.Image? goldMineSprite;
  // Trees and mana pools; drawn before enemies so units appear in front of them.
  final List<_SceneSprite> groundSprites;
  final Offset goldMinePosition;
  final bool showEconomyBuildings;
  final ui.Image? zombieShooterProjectileSprite;
  final Map<String, ui.Image> enemySpriteSheets;
  final Map<String, int> enemySpriteFrameCounts;
  final Offset? targetIndicator;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0E1412);
    canvas.drawRect(Offset.zero & size, bg);
    if (grassBackground != null) {
      canvas.drawImageRect(
        grassBackground!,
        Rect.fromLTWH(
          0,
          0,
          grassBackground!.width.toDouble(),
          grassBackground!.height.toDouble(),
        ),
        Offset.zero & size,
        Paint(),
      );
    }

    for (int i = 0; i < heroes.length; i++) {
      if (!heroAlive[i]) {
        continue;
      }
      final heroPos = heroPositions[i];
      if (heroes[i].attackType == _AttackType.beam &&
          heroStates[i].phase == _HeroPhase.sending) {
        _Enemy? nearest;
        double minDist = double.infinity;
        for (final enemy in enemies) {
          if (enemy.isDying) {
            continue;
          }
          final dist = (enemy.position - heroPos).distance;
          if (dist <= heroAttackRanges[i] && dist < minDist) {
            minDist = dist;
            nearest = enemy;
          }
        }
        if (nearest != null) {
          final dir = nearest.position - heroPos;
          final len = max(dir.distance, 0.001);
          final end =
              heroPos +
              Offset(
                dir.dx / len * heroAttackRanges[i],
                dir.dy / len * heroAttackRanges[i],
              );
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

    final wallEffectStrength =
        (wallHitEffectRemaining / _GameViewState.wallHitEffectDuration).clamp(
          0.0,
          1.0,
        );
    final isWallDestroyed = wallHp <= 0;
    if (wallSprite != null && !isWallDestroyed) {
      final sourceRect = Rect.fromLTWH(
        0,
        0,
        wallSprite!.width.toDouble(),
        wallSprite!.height.toDouble(),
      );
      final wallWidth = max(28.0, size.width * 0.03);
      final shakeOffset = Offset(
        sin(time * 85) * 2.2 * wallEffectStrength,
        cos(time * 57) * 1.1 * wallEffectStrength,
      );
      final destRect = Rect.fromLTWH(
        wallX - wallWidth / 2 + shakeOffset.dx,
        shakeOffset.dy,
        wallWidth,
        size.height,
      );
      canvas.drawImageRect(wallSprite!, sourceRect, destRect, Paint());
      if (wallEffectStrength > 0) {
        final flashOpacity =
            (0.14 + 0.28 * (0.5 + 0.5 * sin(time * 48))) * wallEffectStrength;
        canvas.drawImageRect(
          wallSprite!,
          sourceRect,
          destRect,
          Paint()
            ..colorFilter = ui.ColorFilter.mode(
              Colors.white.withOpacity(flashOpacity),
              BlendMode.srcATop,
            ),
        );
      }
    } else if (!isWallDestroyed) {
      final wall = Paint()..color = const Color(0xFF8B7D5A);
      canvas.drawRect(Rect.fromLTWH(wallX, 0, 4, size.height), wall);
    }

    if (wallSprite == null && !isWallDestroyed) {
      final wallHpPaint = Paint()
        ..color = const Color(0xFF6BFA9D)
        ..style = PaintingStyle.fill;
      final hpRatio = (wallHp / _GameViewState.wallHpMax).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(wallX + 4, 0, 3, size.height * hpRatio),
        wallHpPaint,
      );
    }
    _drawDefenseTower(canvas);
    for (final site in constructionSites) {
      if (site.level > 0) {
        if (site.type == _ConstructionType.lightning) {
          final rect = Rect.fromCenter(
            center: site.position,
            width: _GameViewState.lightningTowerSize,
            height: _GameViewState.lightningTowerSize,
          );
          canvas.drawRect(rect, Paint()..color = _GameViewState.lightningTowerColor);
          canvas.drawRect(rect, Paint()
            ..color = const Color(0xFFDDADFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
          continue;
        }
        canvas.save();
        final offset = site.position - towerPosition;
        canvas.translate(offset.dx, offset.dy);
        _drawDefenseTower(canvas, phase: site.position.dx + site.position.dy);
        canvas.restore();
      }
    }

    if (showEconomyBuildings) {
      if (showPortal) {
        _drawAnimatedBuilding(canvas, portalSprite, _GameViewState._portalRect);
      }
      _drawAnimatedBuilding(canvas, goldMineSprite, Rect.fromCenter(
        center: goldMinePosition, width: _GameViewState.goldMineSize.width,
        height: _GameViewState.goldMineSize.height));
    }
    final sortedGround = [...groundSprites]
      ..sort((a, b) => a.dst.bottom.compareTo(b.dst.bottom));
    for (final sprite in sortedGround) {
      sprite.paint(canvas);
    }

    final enemyPaint = Paint()..color = const Color(0xFFE06A5E);
    final enemyHitPaint = Paint()..color = Colors.white;
    final enemyHpBack = Paint()..color = const Color(0xFF2A2A2A);
    final enemyHpFill = Paint()..color = const Color(0xFF6BFA9D);
    for (final enemy in enemies) {
      final shadowRect = Rect.fromCenter(
        center: enemy.position.translate(0, _GameViewState.enemySize * 0.10),
        width: _GameViewState.enemySize * 1.8,
        height: _GameViewState.enemySize * 0.44,
      );
      canvas.drawOval(
        shadowRect,
        Paint()..color = Colors.black.withOpacity(enemy.isDying ? 0.12 : 0.18),
      );
      canvas.save();
      canvas.translate(enemy.position.dx, enemy.position.dy);
      canvas.scale(2.0);
      canvas.translate(-enemy.position.dx, -enemy.position.dy);
      if (enemySpriteSheets.containsKey(enemy.typeId) &&
          (enemySpriteFrameCounts[enemy.typeId] ?? 0) > 0) {
        _drawEnemySprite(canvas, enemy);
      } else {
        _drawHungryEnemy(
          canvas,
          enemy,
          enemy.flashRemaining > 0 ? enemyHitPaint : enemyPaint,
        );
      }

      canvas.restore();
      if (enemy.isDying) {
        continue;
      }
      final hpRatio = enemy.maxHp > 0
          ? (enemy.hp / enemy.maxHp).clamp(0.0, 1.0)
          : 0.0;
      final barWidth = _GameViewState.enemySize * 2;
      const barHeight = 4.0;
      final barLeft = enemy.position.dx - barWidth / 2;
      final barTop = enemy.position.dy - _GameViewState.enemySize - 8;
      final backRect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
      final fillRect = Rect.fromLTWH(
        barLeft,
        barTop,
        barWidth * hpRatio,
        barHeight,
      );
      canvas.drawRect(backRect, enemyHpBack);
      canvas.drawRect(fillRect, enemyHpFill);
    }

    for (final p in projectiles) {
      final projPaint = Paint()..color = p.color;
      if (p.isAerinStrong) {
        _drawFireballProjectile(canvas, p, time);
      } else {
        canvas.drawCircle(p.position, p.radius, projPaint);
      }
    }

    for (final p in enemyProjectiles) {
      if (zombieShooterProjectileSprite != null) {
        _drawZombieShooterProjectile(canvas, p);
      } else {
        final projPaint = Paint()..color = p.color;
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

    for (final reward in floatingCoinRewards) {
      _drawFloatingCoinReward(canvas, reward);
    }

    for (final boom in explosions) {
      final alpha = (boom.lifeRemaining / _GameViewState.explosionDuration)
          .clamp(0.0, 1.0);
      if (boom.isFire) {
        _drawFireExplosion(canvas, boom, time, alpha);
      } else {
        final paint = Paint()
          ..color = Colors.orangeAccent.withOpacity(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(
          boom.position,
          boom.radius * (1 - alpha * 0.3),
          paint,
        );
      }
    }

    for (final bolt in lightnings) {
      _drawLightningEffect(canvas, bolt, time);
    }

    if (targetIndicator != null) {
      _drawTargetIndicator(canvas, targetIndicator!);
    }
  }

  void _drawAnimatedBuilding(Canvas canvas, ui.Image? image, Rect rect) {
    if (image == null) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          Paint()..color = const Color(0xFF684A89));
      return;
    }
    final frame = (time * 12).floor() % 24;
    final width = image.width / 6;
    final height = image.height / 4;
    canvas.drawImageRect(image,
        Rect.fromLTWH((frame % 6) * width, (frame ~/ 6) * height, width, height),
        rect, Paint()..filterQuality = FilterQuality.none);
  }

  static const int towerSpriteFrameCount = 12;

  void _drawDefenseTower(Canvas canvas, {double phase = 0}) {
    final towerRect = Rect.fromCenter(
      center: towerPosition,
      width: towerWidth,
      height: towerHeight,
    );
    final shadowRect = Rect.fromCenter(
      center: towerPosition.translate(0, towerHeight * 0.44),
      width: towerWidth * 0.7,
      height: towerHeight * 0.14,
    );
    canvas.drawOval(
      shadowRect,
      Paint()..color = Colors.black.withOpacity(0.22),
    );
    if (towerSprite != null) {
      // Built towers get a position-based phase so flags do not wave in sync.
      final frameWidth = towerSprite!.width / towerSpriteFrameCount;
      final frame = ((time * 10).floor() + phase.floor()) % towerSpriteFrameCount;
      canvas.drawImageRect(
        towerSprite!,
        Rect.fromLTWH(
          frame * frameWidth,
          0,
          frameWidth,
          towerSprite!.height.toDouble(),
        ),
        towerRect,
        Paint()..filterQuality = FilterQuality.none,
      );
      return;
    }
    final basePaint = Paint()..color = const Color(0xFF284B57);
    final borderPaint = Paint()
      ..color = const Color(0xFF8FE9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final corePaint = Paint()..color = const Color(0xFF7CE7FF);
    final barrelPaint = Paint()
      ..color = const Color(0xFFB9F5FF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(towerRect, const Radius.circular(6)),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(towerRect, const Radius.circular(6)),
      borderPaint,
    );
    canvas.drawCircle(towerPosition, 6, corePaint);
    canvas.drawLine(towerPosition, towerPosition.translate(12, 0), barrelPaint);
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
    final trailOffset =
        p.position - trailDir * trailLength * (0.5 + flicker * 0.2);
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
      ..shader = ui.Gradient.linear(p.position, trailOffset, [
        const Color(0xFFFFC15A).withOpacity(0.75),
        const Color(0xFFFF6A3A).withOpacity(0.0),
      ]);
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
      final sparkPaint = Paint()
        ..color = const Color(0xFFFFE08A).withOpacity(0.8);
      canvas.drawCircle(sparkPos, 1.2 + flicker, sparkPaint);
    }
  }

  void _drawFireExplosion(
    Canvas canvas,
    _ExplosionEffect boom,
    double time,
    double alpha,
  ) {
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

    final sparkPaint = Paint()
      ..color = const Color(0xFFFFD08A).withOpacity(0.8 * alpha);
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
      ..color = bolt.glowColor.withOpacity(0.6 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    final corePaint = Paint()
      ..color = bolt.coreColor.withOpacity(0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    for (final seg in bolt.segments) {
      final path = _buildLightningPath(seg.start, seg.end, seg.seed, time);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, corePaint);

      final impact = Paint()..color = bolt.impactColor.withOpacity(0.8 * alpha);
      canvas.drawCircle(seg.end, 4 + sin(time * 14 + seg.seed) * 1.5, impact);
    }
  }

  void _drawFloatingCoinReward(Canvas canvas, _FloatingCoinReward reward) {
    final alpha = (reward.lifeRemaining / reward.maxLife).clamp(0.0, 1.0);
    final coinCenter = reward.position.translate(-16, -22);
    final coinPaint = Paint()..color = const Color(0xFFF2C14E).withOpacity(alpha);
    final coinInnerPaint = Paint()
      ..color = const Color(0xFFFFE08A).withOpacity(alpha * 0.95);
    final coinBorderPaint = Paint()
      ..color = const Color(0xFF9C6B13).withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(coinCenter, 8, coinPaint);
    canvas.drawCircle(coinCenter, 5.2, coinInnerPaint);
    canvas.drawCircle(coinCenter, 8, coinBorderPaint);

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(alpha * 0.9)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      coinCenter.translate(-2.5, -2.2),
      coinCenter.translate(2.5, 2.2),
      sparklePaint,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '+1',
        style: TextStyle(
          color: const Color(0xFFFFF3BF).withOpacity(alpha),
          fontSize: 15,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(alpha * 0.45),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(reward.position.dx - 2, reward.position.dy - 31 - textPainter.height / 2),
    );
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
    final spriteConfig =
        _enemySpriteConfigs[enemy.typeId] ?? _enemySpriteConfigs['fat_zombie']!;
    final spriteSheet =
        enemySpriteSheets[enemy.typeId] ?? enemySpriteSheets['fat_zombie'];
    final spriteFrameCount =
        enemySpriteFrameCounts[enemy.typeId] ??
        enemySpriteFrameCounts['fat_zombie'] ??
        0;
    if (spriteSheet == null || spriteFrameCount <= 0) {
      return;
    }

    final deathFrameStart = max(
      0,
      spriteFrameCount - spriteConfig.deathFrameCount,
    );
    final availableWalkFrames = max(
      1,
      min(
        spriteConfig.walkFrameCount,
        spriteFrameCount - spriteConfig.walkFrameStart,
      ),
    );
    final availableAttackFrames = max(
      1,
      min(
        spriteConfig.attackFrameCount,
        spriteFrameCount - spriteConfig.attackFrameStart,
      ),
    );
    final availableHitFrames =
        spriteConfig.hitFrameStart == null || spriteConfig.hitFrameCount <= 0
        ? 0
        : max(
            1,
            min(
              spriteConfig.hitFrameCount,
              spriteFrameCount - spriteConfig.hitFrameStart!,
            ),
          );

    late final int frameIndex;
    if (enemy.isDying) {
      final deathFrameOffset = min(
        spriteConfig.deathFrameCount - 1,
        (enemy.deathAnimTime / _Enemy.deathFrameDuration).floor(),
      );
      frameIndex = deathFrameStart + deathFrameOffset;
    } else if (enemy.hitAnimRemaining > 0 && availableHitFrames > 0) {
      final totalHitDuration =
          availableHitFrames * _GameViewState.enemyHitFrameDuration;
      final elapsed = (totalHitDuration - enemy.hitAnimRemaining).clamp(
        0.0,
        totalHitDuration,
      );
      final hitFrameOffset = min(
        availableHitFrames - 1,
        (elapsed / _GameViewState.enemyHitFrameDuration).floor(),
      );
      frameIndex = spriteConfig.hitFrameStart! + hitFrameOffset;
    } else {
      final animFps = enemy.attacking ? 10.0 : 12.0;
      final animPhase = (enemy.animTime * animFps + enemy.seed * 0.03).floor();
      frameIndex = enemy.attacking
          ? spriteConfig.attackFrameStart + (animPhase % availableAttackFrames)
          : spriteConfig.walkFrameStart + (animPhase % availableWalkFrames);
    }

    final frameWidth = spriteConfig.frameWidth;
    final frameHeight = spriteConfig.frameHeight;
    final t = enemy.animTime;
    final bob = enemy.isDying ? 0.0 : sin(t * 2.4 + enemy.seed) * 1.2;
    final jitter = enemy.isDying
        ? 0.0
        : enemy.attacking
        ? sin(t * 18 + enemy.seed * 0.7) * 1.0
        : sin(t * 10 + enemy.seed * 0.7) * 0.5;
    final drawCenter = enemy.position + Offset(jitter, bob);
    final enemyDrawWidth = _GameViewState.enemySize * 1.35;
    final enemyDrawHeight = enemy.typeId == 'zombie_female'
        ? _GameViewState.enemySize * 0.9
        : _GameViewState.enemySize * 1.35;
    final destRect = Rect.fromCenter(
      center: drawCenter,
      width: enemyDrawWidth,
      height: enemyDrawHeight,
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
      paint.colorFilter = const ui.ColorFilter.mode(
        Colors.white,
        BlendMode.modulate,
      );
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

  void _drawZombieShooterProjectile(
    Canvas canvas,
    _EnemyProjectile projectile,
  ) {
    final spriteSheet = zombieShooterProjectileSprite;
    if (spriteSheet == null) {
      final projPaint = Paint()..color = projectile.color;
      canvas.drawCircle(projectile.position, projectile.radius, projPaint);
      return;
    }

    const frameWidth = 17.0;
    const frameHeight = 23.0;
    final frameOffset = projectile.isImpacting
        ? min(
            _EnemyProjectile.impactFrameCount - 1,
            (projectile.animTime /
                    _GameViewState.zombieShooterProjectileFrameDuration)
                .floor(),
          )
        : (projectile.animTime /
                      _GameViewState.zombieShooterProjectileFrameDuration)
                  .floor() %
              _EnemyProjectile.flightFrameCount;
    final frameIndex = projectile.isImpacting ? 4 + frameOffset : frameOffset;
    final srcRect = Rect.fromLTWH(
      frameIndex * frameWidth,
      0,
      frameWidth,
      frameHeight,
    );
    final drawWidth = projectile.isImpacting ? 30.0 : 22.0;
    final drawHeight = projectile.isImpacting ? 40.0 : 28.0;
    final destRect = Rect.fromCenter(
      center: projectile.position,
      width: drawWidth,
      height: drawHeight,
    );
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    canvas.drawImageRect(spriteSheet, srcRect, destRect, paint);
  }

  void _drawHungryEnemy(Canvas canvas, _Enemy enemy, Paint bodyPaint) {
    final baseSize = _GameViewState.enemySize;
    final t = enemy.animTime;
    final seed = enemy.seed;
    final bob = sin(t * 2.4 + seed) * 1.6;
    final jitter = enemy.attacking
        ? sin(t * 18 + seed * 0.7) * 1.2
        : sin(t * 10 + seed * 0.7) * 0.6;
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

    final droolPaint = Paint()
      ..color = const Color(0xFF7EC7FF).withOpacity(0.7);
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

  void _drawMagicBeam(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double time,
  ) {
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
    final end =
        heroPos + Offset(ux, uy) * _GameViewState.swordRadius + swingOffset;

    final arcStart =
        heroPos + Offset(ux, uy) * (_GameViewState.swordRadius * 0.2);
    final arcEnd = end;
    final arcMid =
        heroPos +
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
      final sparkPaint = Paint()
        ..color = const Color(0xFFFFD98A).withOpacity(0.8);
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

class _GatheringTopBar extends StatelessWidget {
  const _GatheringTopBar({
    required this.onBack,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.coins,
    required this.wood,
    required this.stone,
  });

  final VoidCallback onBack;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final int coins;
  final int wood;
  final int stone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2C29))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            tooltip: 'Zpet do vesnice',
          ),
          const Expanded(
            child: Text(
              'Gathering',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(
            Icons.monetization_on_rounded,
            color: Color(0xFFF2C14E),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            coins.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.park_rounded,
            color: Color(0xFFB7793E),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            wood.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.terrain,
            color: Color(0xFF858B91),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            stone.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          _ZoomButton(icon: Icons.add, onTap: onZoomIn),
          const SizedBox(width: 8),
          _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _RumbleTopBar extends StatelessWidget {
  const _RumbleTopBar({
    required this.onBack,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.wallHp,
    required this.currentWave,
    required this.totalWaves,
    required this.coins,
    required this.wood,
    required this.stone,
  });

  final VoidCallback onBack;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final double wallHp;
  final int currentWave;
  final int totalWaves;
  final int coins;
  final int wood;
  final int stone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2C29))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            tooltip: 'Zpet do vesnice',
          ),
          const SizedBox(width: 4),
          const Text(
            'Rumble',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Palisada ${wallHp.round()} / ${_GameViewState.wallHpMax.round()}  •  Vlna $currentWave / ${max(1, totalWaves)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  value: (wallHp / _GameViewState.wallHpMax).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFF66BB6A),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _RumbleResource(icon: Icons.monetization_on_rounded, color: const Color(0xFFF2C14E), value: coins),
          _RumbleResource(icon: Icons.park_rounded, color: const Color(0xFFB7793E), value: wood),
          _RumbleResource(icon: Icons.terrain, color: const Color(0xFF858B91), value: stone),
          _ZoomButton(icon: Icons.add, onTap: onZoomIn),
          const SizedBox(width: 6),
          _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _RumbleResource extends StatelessWidget {
  const _RumbleResource({required this.icon, required this.color, required this.value});

  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 3),
          Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
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
    this.trailing,
  });

  final double wallHp;
  final int currentWave;
  final int enemiesKilled;
  final int coinsEarned;
  final String gameDurationText;
  final int enemiesInWave;
  final int totalEnemiesInWave;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF101816),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2C29), width: 1)),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
                _buildStatItem(
                  Icons.monetization_on,
                  Colors.amber,
                  coinsEarned,
                ),
                _buildStatItem(
                  Icons.timer,
                  Colors.blueAccent,
                  gameDurationText,
                  isText: true,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color color,
    dynamic value, {
    bool isText = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          isText ? value.toString() : value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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

enum _KaelenMode { normal, vine, healing }

enum _SolenneMode { normal, sunburst, radiant }

enum _RavikMode { normal, voidburst, soul }

enum _BrannMode { normal, earthquake, boulder }

enum _EldrinMode { normal, cosmic, nova }

enum _HeroBehaviorMode { holdPosition, offensive, defensive }

class _HeroState {
  _HeroState({
    required this.phase,
    required this.timeRemaining,
    this.pendingAttack = false,
    this.magicEnergy = _GameViewState.heroMagicEnergyMax,
    this.attackFlipHorizontally = false,
    this.beamTarget,
  });

  _HeroPhase phase;
  double timeRemaining;
  bool pendingAttack;
  double magicEnergy;
  bool attackFlipHorizontally;
  _Enemy? beamTarget;
}

class HeroDef {
  const HeroDef(
    this.name,
    this.color, {
    this.imageAsset = '',
    this.maxHp = 100.0,
    this.attackRange = _GameViewState.defaultHeroAttackRange,
    this.cooldownDuration = _GameViewState.spellCooldownDuration,
    this.damage = 5.0,
    this.attackType = _AttackType.projectile,
    this.beamDps = 2.0,
  });

  final String name;
  final Color color;
  final String imageAsset;
  final double maxHp;
  final double attackRange;
  final double cooldownDuration;
  final double damage;
  final _AttackType attackType;
  final double beamDps;
}

class _DamageText {
  _DamageText({required this.position, required this.value});

  Offset position;
  final double value;
  final double maxLife = 0.8;
  double lifeRemaining = 0.8;
  final double speed = 24;
}

class _FloatingCoinReward {
  _FloatingCoinReward({required this.position});

  Offset position;
  final double maxLife = 0.9;
  double lifeRemaining = 0.9;
  final double speed = 34;
}

class _GatheringWorker {
  _GatheringWorker({required this.position});

  bool get isPerformingAction => isAlive && !isMoving &&
      (miningRemaining > 0 ||
          order == _GatheringWorkerOrder.attack ||
          order == _GatheringWorkerOrder.build);

  bool get isIdle => isAlive && order == _GatheringWorkerOrder.idle &&
      !isMoving && miningRemaining <= 0;

  Offset position;
  double hp = _GameViewState.gatheringWorkerMaxHp;
  bool isAlive = true;
  bool isMoving = false;
  bool repeatMining = false;
  double miningRemaining = 0;
  _Enemy? attackTarget;
  _ConstructionSite? constructionSite;
  double attackCooldown = 0;
  double animationTime = 0;
  bool isMovingLeft = false;
  _GatheringWorkerOrder order = _GatheringWorkerOrder.idle;
  Offset destination = Offset.zero;
  _GatheringResource? targetResource;
  int? targetWoodIndex;
  int? targetStoneIndex;
  int? targetFragmentIndex;
  _GatheringResource? carriedResource;
}

class _EnemyCombatTarget {
  const _EnemyCombatTarget({
    required this.position,
    this.heroIndex,
    this.workerIndex,
  });

  final Offset position;
  final int? heroIndex;
  final int? workerIndex;
}

enum _GatheringWorkerOrder { idle, move, mineGold, deliver, attack, build }

enum _ConstructionType {
  guard,
  lightning;

  int get cost => this == lightning
      ? _GameViewState.lightningTowerCost : _GameViewState.constructionCost;
  String get label => this == lightning ? 'Blesková věž' : 'Strážná věž';
  double get damageMultiplier => this == lightning ? 2.0 : 1.0;
}

class _ConstructionSite {
  _ConstructionSite(this.position);

  final Offset position;
  _ConstructionType type = _ConstructionType.guard;
  bool isOrdered = false;
  bool isUpgrading = false;
  int level = 0;
  int investment = 0;
  double remaining = _GameViewState.constructionDuration;
  double cooldownRemaining = 0;

  bool get isComplete => level > 0 && !isUpgrading;
  bool get needsWork => isOrdered && remaining > 0;
  int get demolitionRefund => investment ~/ 2;
  double get damage =>
      _GameViewState.towerDamage * type.damageMultiplier * pow(3, level - 1);

  void reset() {
    type = _ConstructionType.guard;
    isOrdered = false;
    isUpgrading = false;
    level = 0;
    investment = 0;
    remaining = _GameViewState.constructionDuration;
    cooldownRemaining = 0;
  }
}

enum _GatheringResource { gold, wood, stone, fragments }

class _GatheringResourceTarget {
  const _GatheringResourceTarget(
    this.resource, {
    this.woodIndex,
    this.stoneIndex,
    this.fragmentIndex,
  });

  final _GatheringResource resource;
  final int? woodIndex;
  final int? stoneIndex;
  final int? fragmentIndex;
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
  _LightningSegment({
    required this.start,
    required this.end,
    required this.seed,
  });

  final Offset start;
  final Offset end;
  final double seed;
}

class _LightningEffect {
  _LightningEffect({
    required this.segments,
    this.glowColor = const Color(0xFFBFE8FF),
    this.coreColor = const Color(0xFFEAF8FF),
    this.impactColor = const Color(0xFFD9F4FF),
  });

  final List<_LightningSegment> segments;
  final Color glowColor;
  final Color coreColor;
  final Color impactColor;
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
  const _AutoModePanel({required this.enabled, required this.onToggle});

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
    final modes = [
      _VeyraMode.rapid,
      _VeyraMode.explosive,
      _VeyraMode.lightning,
    ];
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
    final icons = [Icons.bolt, Icons.bolt];

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
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _HeroModeAction {
  const _HeroModeAction({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
}

class _HeroContextModeMenu extends StatelessWidget {
  const _HeroContextModeMenu({
    required this.center,
    required this.heroColor,
    required this.actions,
    required this.verticalOffset,
  });

  final Offset center;
  final Color heroColor;
  final List<_HeroModeAction> actions;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    const buttonSize = 36.0;
    const spacing = 44.0;
    final totalWidth = buttonSize + max(0, actions.length - 1) * spacing;
    final left = center.dx - totalWidth / 2;
    final top = center.dy + verticalOffset;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCC101816),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C3F3A)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _ModeCircleButton(
                    icon: actions[i].icon,
                    selected: actions[i].selected,
                    color: heroColor,
                    onTap: actions[i].onTap,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroSelectScreen extends StatefulWidget {
  const HeroSelectScreen({
    super.key,
    this.initialSelection = const [],
    this.isRumble = false,
    this.chapterNumber,
    this.levelNumber,
  });

  final List<HeroDef> initialSelection;
  final bool isRumble;
  final int? chapterNumber;
  final int? levelNumber;

  @override
  State<HeroSelectScreen> createState() => _HeroSelectScreenState();
}

class _HeroSelectScreenState extends State<HeroSelectScreen> {
  static const int slotCount = 5;

  final List<HeroDef> _heroes = const [
    HeroDef(
      'Aerin',
      Color(0xFFE57373),
      imageAsset: 'assets/heroes/hero_aerin.png',
    ),
    HeroDef(
      'Veyra',
      Color(0xFFBA68C8),
      imageAsset: 'assets/heroes/hero_veyra.png',
      cooldownDuration: 5,
      damage: 2.5,
    ),
    HeroDef(
      'Thalor',
      Color(0xFF64B5F6),
      imageAsset: 'assets/heroes/hero_thalor.png',
    ),
    HeroDef(
      'Myris',
      Color(0xFF4DB6AC),
      imageAsset: 'assets/heroes/hero_myris.png',
    ),
    HeroDef(
      'Kaelen',
      Color(0xFF81C784),
      imageAsset: 'assets/heroes/hero_kaelen.png',
    ),
    HeroDef(
      'Solenne',
      Color(0xFFFFD54F),
      imageAsset: 'assets/heroes/hero_solenne.png',
      attackType: _AttackType.beam,
      beamDps: 2.0,
    ),
    HeroDef(
      'Ravik',
      Color(0xFFFF8A65),
      imageAsset: 'assets/heroes/hero_ravik.png',
    ),
    HeroDef(
      'Brann',
      Color(0xFFA1887F),
      imageAsset: 'assets/heroes/hero_brann.png',
      maxHp: 500,
    ),
    HeroDef(
      'Nyxra',
      Color(0xFF90A4AE),
      imageAsset: 'assets/heroes/hero_nyxra.png',
    ),
    HeroDef(
      'Eldrin',
      Color(0xFF9575CD),
      imageAsset: 'assets/heroes/hero_eldrin.png',
    ),
  ];

  late final List<HeroDef?> _slots;
  PlayerProgress? _progress;

  @override
  void initState() {
    super.initState();
    _slots = List<HeroDef?>.filled(slotCount, null);
    for (var i = 0; i < widget.initialSelection.length && i < slotCount; i++) {
      _slots[i] = widget.initialSelection[i];
    }
    _enableFullscreenMode();
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
        builder: (_) => widget.levelNumber != null
            ? GameHomeScreen(heroes: selected,
                chapterNumber: widget.chapterNumber!,
                levelNumber: widget.levelNumber!, isRumble: widget.isRumble)
            : ChapterSelectScreen(
          heroes: selected,
          isRumble: widget.isRumble,
        ),
      ),
    );
  }

  void _goBackToSaveSlots() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => widget.levelNumber != null
          ? LevelSelectScreen(heroes: widget.initialSelection,
              chapterNumber: widget.chapterNumber!, isRumble: widget.isRumble)
          : const VillageScreen()),
    );
  }

  Future<void> _openHeroUpgrades() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HeroUpgradeScreen()));
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _slots.any((c) => c != null);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBackToSaveSlots();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 210,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _heroes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final hero = _heroes[index];
                      final isSelected = _slots.contains(hero);
                      final isUnlocked = _isHeroUnlocked(hero.name);
                      return GestureDetector(
                        onTap: !isUnlocked
                            ? null
                            : (isSelected ? null : () => _assignHero(hero)),
                        child: Container(
                          width: 216,
                          height: 216,
                          decoration: BoxDecoration(
                            color: !isUnlocked
                                ? Colors.grey.shade800
                                : (isSelected ? Colors.grey : hero.color)
                                      .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isUnlocked
                                  ? Colors.white24
                                  : Colors.grey.shade700,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: hero.imageAsset.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                hero.imageAsset,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.person,
                                                        color: Colors.white54,
                                                        size: 56,
                                                      );
                                                    },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.white54,
                                              size: 56,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      hero.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !isUnlocked
                                            ? Colors.grey.shade500
                                            : Colors.white,
                                        fontSize: 16,
                                        height: 1.0,
                                        fontWeight: FontWeight.w600,
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
                                      size: 56,
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
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 640,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                margin: const EdgeInsets.only(bottom: 16),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slotCount, (i) {
                        final hero = _slots[i];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i == slotCount - 1 ? 0 : 14,
                          ),
                          child: GestureDetector(
                            onTap: hero == null ? null : () => _removeHero(i),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: hero?.color ?? const Color(0xFF1F2C29),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: hero == null
                                  ? const Icon(
                                      Icons.add,
                                      color: Colors.white38,
                                      size: 30,
                                    )
                                  : hero.imageAsset.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        hero.imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                color: Colors.white54,
                                                size: 30,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                      size: 30,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goBackToSaveSlots,
                            child: const Text('Zpět'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _openHeroUpgrades,
                            child: const Text('Hrdinove'),
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
    final icons = [Icons.bolt, Icons.ac_unit, Icons.grain];

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
    final modes = [_KaelenMode.normal, _KaelenMode.vine, _KaelenMode.healing];
    final icons = [Icons.auto_awesome, Icons.grass, Icons.favorite];

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
    final modes = [
      _SolenneMode.normal,
      _SolenneMode.sunburst,
      _SolenneMode.radiant,
    ];
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
    final modes = [
      _BrannMode.normal,
      _BrannMode.earthquake,
      _BrannMode.boulder,
    ];
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
