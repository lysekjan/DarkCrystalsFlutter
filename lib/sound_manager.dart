import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

// Simple audio player for game sound effects
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Sound effect types
  static const String hit = 'hit';
  static const String death = 'death';
  static const String victory = 'victory';
  static const String gameover = 'gameover';
  static const String waveComplete = 'wave_complete';
  static const String fire = 'fire';
  static const String explosion = 'explosion';
  static const String coin = 'coin';
  static const String levelUp = 'level_up';

  bool _soundEnabled = true;
  double _masterVolume = 0.7;

  bool get soundEnabled => _soundEnabled;
  double get masterVolume => _masterVolume;

  Future<void> playHit() async => _playTone(440, 0.1);
  Future<void> playDeath() async => _playTone(220, 0.2);
  Future<void> playVictory() async {
    await _playTone(523, 0.1);
    await Future.delayed(const Duration(milliseconds: 150));
    await _playTone(659, 0.1);
    await Future.delayed(const Duration(milliseconds: 150));
    await _playTone(784, 0.2);
  }
  Future<void> playGameOver() async {
    await _playTone(196, 0.2);
    await Future.delayed(const Duration(milliseconds: 200));
    await _playTone(175, 0.2);
  }
  Future<void> playWaveComplete() async {
    await _playTone(587, 0.1);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(740, 0.15);
  }
  Future<void> playFire() async => _playTone(880, 0.05);
  Future<void> playExplosion() async => _playTone(110, 0.15);
  Future<void> playCoin() async => _playTone(988, 0.08);
  Future<void> playLevelUp() async {
    await _playTone(523, 0.1);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(659, 0.1);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(784, 0.1);
  }

  Future<void> _playTone(double frequency, double duration) async {
    if (!_soundEnabled) return;

    try {
      // Simple beep using MethodChannel for platform-specific implementation
      // For now, we'll use vibration as a fallback
      if (duration > 0.1) {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Silently fail - sound is optional
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
  }
}

// Haptic feedback helper
class HapticFeedback {
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Fallback silently
    }
  }

  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Fallback silently
    }
  }

  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.vibrate();
      await HapticFeedback.vibrate();
    } catch (e) {
      // Fallback silently
    }
  }

  static Future<void> vibrate() async {
    try {
      // Vibrate using platform channel
      await const MethodChannel('vibration').invokeMethod('vibrate', {
        'duration': 50,
        'pattern': [0, 50],
      });
    } catch (e) {
      // Silently fail
    }
  }
}
