import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'level_data.dart';

class LevelRepository {
  static const int legacyWaveCount = 10;

  static String assetPath(int chapterNumber, int levelNumber) {
    final levelLabel = levelNumber.toString().padLeft(2, '0');
    return 'assets/levels/chapter_$chapterNumber/level_$levelLabel.json';
  }

  static String prefsKey(int chapterNumber, int levelNumber) {
    return 'level_editor_override_c${chapterNumber}_l${levelNumber}';
  }

  static Future<LevelDef> loadLevel({
    required int chapterNumber,
    required int levelNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final overrideJson = prefs.getString(prefsKey(chapterNumber, levelNumber));
    if (overrideJson != null && overrideJson.trim().isNotEmpty) {
      return LevelDef.fromJson(jsonDecode(overrideJson) as Map<String, dynamic>);
    }

    try {
      final assetJson = await rootBundle.loadString(assetPath(chapterNumber, levelNumber));
      return LevelDef.fromJson(jsonDecode(assetJson) as Map<String, dynamic>);
    } catch (_) {
      return buildLegacyTemplate(
        chapterNumber: chapterNumber,
        levelNumber: levelNumber,
      );
    }
  }

  static Future<void> saveLevelOverride(LevelDef levelDef) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKey(levelDef.chapter, levelDef.level),
      levelDef.toPrettyJson(),
    );
  }

  static Future<void> clearLevelOverride({
    required int chapterNumber,
    required int levelNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKey(chapterNumber, levelNumber));
  }

  static LevelDef buildLegacyTemplate({
    required int chapterNumber,
    required int levelNumber,
  }) {
    final randomSeed = chapterNumber * 1000 + levelNumber * 37;
    final rng = Random(randomSeed);
    final waves = List<WaveDef>.generate(legacyWaveCount, (waveIndex) {
      final waveNumber = waveIndex + 1;
      final enemyCount = 5 + waveNumber * 2;
      final baseSpacing = max(0.65, 1.2 - waveNumber * 0.04);
      final events = List<SpawnEventDef>.generate(enemyCount, (enemyIndex) {
        final lane = ((enemyIndex + waveIndex) % 5) + 1;
        final time = enemyIndex * baseSpacing + rng.nextDouble() * 0.12;
        return SpawnEventDef(
          time: double.parse(time.toStringAsFixed(2)),
          enemyType: 'fat_zombie',
          count: 1,
          lane: lane,
          spacing: 0,
          hpMultiplier: 1.0 + waveIndex * 0.1,
          speedMultiplier: 1.0,
        );
      });
      return WaveDef(
        id: waveNumber,
        startDelay: waveIndex == 0 ? 4.0 : 2.5,
        completeWhenNoEnemies: true,
        events: events,
      );
    });
    return LevelDef(
      version: 1,
      chapter: chapterNumber,
      level: levelNumber,
      name: 'Legacy Level $levelNumber',
      waves: waves,
    );
  }
}
