import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:dark_crystals/unit_spacing.dart';

void main() {
  void expectSeparated(List<SpacingUnit> units) {
    for (var i = 0; i < units.length; i++) {
      for (var j = i + 1; j < units.length; j++) {
        expect((units[i].position - units[j].position).distance,
            greaterThanOrEqualTo(units[i].radius + units[j].radius + 5.999));
      }
    }
  }

  test('Mixed heroes, workers and enemies cannot share space', () {
    final units = [
      SpacingUnit(const Offset(500, 500), 96),
      SpacingUnit(const Offset(500, 500), 104),
      ...List.generate(20, (_) => SpacingUnit(const Offset(500, 500), 54)),
    ];
    expect(separateUnits(units, const Rect.fromLTWH(0, 0, 3000, 3000), (_) => true), isTrue);
    expectSeparated(units);
    final positions = units.map((unit) => unit.position).toList();
    separateUnits(units, const Rect.fromLTWH(0, 0, 3000, 3000), (_) => true);
    expect(units.map((unit) => unit.position).toList(), positions);
  });

  test('Spacing preserves map boundaries and excludes buildings', () {
    const bounds = Rect.fromLTWH(100, 0, 1200, 800);
    const building = Rect.fromLTWH(200, 200, 300, 300);
    final units = List.generate(8, (_) => SpacingUnit(const Offset(110, 300), 54));
    expect(separateUnits(units, bounds, (point) => !building.contains(point)), isTrue);
    for (final unit in units) {
      expect(bounds.contains(unit.position), isTrue);
      expect(building.contains(unit.position), isFalse);
    }
    expectSeparated(units);
  });
}
