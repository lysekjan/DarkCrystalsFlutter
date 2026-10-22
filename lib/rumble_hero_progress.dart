import 'dart:math' as math;

class RumbleHeroProgress {
  int _level = 1;
  int _xp = 0;

  int get level => _level;
  int get xp => _xp;
  int get xpForNextLevel => (10 * math.pow(1.5, _level - 1)).round();
  double get statMultiplier => math.pow(1.2, _level - 1).toDouble();

  bool addXp(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'XP cannot be negative');
    }
    final previousLevel = _level;
    _xp += amount;
    while (_xp >= xpForNextLevel) {
      _xp -= xpForNextLevel;
      _level++;
    }
    return _level > previousLevel;
  }
}
