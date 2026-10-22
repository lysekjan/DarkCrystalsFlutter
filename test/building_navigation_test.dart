import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:dark_crystals/building_navigation.dart';

void main() {
  const bounds = Rect.fromLTWH(0, 0, 800, 600);

  test('Unblocked movement preserves speed and stops at destination', () {
    final nav = BuildingNavigation(bounds, []);
    expect(nav.move(const Offset(10, 10), const Offset(110, 10), 25),
        const Offset(35, 10));
    expect(nav.move(const Offset(10, 10), const Offset(110, 10), 200),
        const Offset(110, 10));
  });

  test('Units go around multiple buildings without crossing their footprints', () {
    final nav = BuildingNavigation(bounds, [
      const Rect.fromLTWH(200, 160, 100, 240),
      const Rect.fromLTWH(400, 100, 100, 240),
    ]);
    var position = const Offset(100, 250);
    const destination = Offset(700, 250);
    for (var tick = 0; tick < 2000; tick++) {
      final next = nav.move(position, destination, 2);
      expect(nav.obstacles.any((r) => r.contains(next)), isFalse);
      expect((next - position).distance, lessThanOrEqualTo(2.000001));
      position = next;
      if ((position - destination).distance < 0.001) break;
    }
    expect((position - destination).distance, lessThan(0.001));
  });

  test('A destination inside a building resolves to its accessible edge', () {
    final nav = BuildingNavigation(bounds, [const Rect.fromLTWH(200, 200, 100, 100)]);
    const target = Offset(250, 250);
    final end = nav.move(const Offset(50, 250), target, 1000);
    expect(end, nav.outside(target));
    expect(nav.obstacles.single.contains(end), isFalse);
  });

  test('An enclosed route stops instead of crossing a building', () {
    final nav = BuildingNavigation(bounds, [const Rect.fromLTWH(200, -20, 100, 640)]);
    const start = Offset(100, 300);
    expect(nav.move(start, const Offset(700, 300), 1000), start);
  });

  test('Units caught inside a newly built tower are moved outside', () {
    final nav = BuildingNavigation(bounds, [const Rect.fromLTWH(200, 200, 100, 100)]);
    final corrected = nav.outside(const Offset(250, 250));
    expect(nav.obstacles.any((r) => r.contains(corrected)), isFalse);
    expect(bounds.contains(corrected), isTrue);
  });
}
