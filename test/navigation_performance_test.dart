import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:dark_crystals/building_navigation.dart';
import 'package:dark_crystals/unit_spacing.dart';

class CountingNavigation extends BuildingNavigation {
  CountingNavigation(super.bounds, super.obstacles);
  int queries = 0;
  @override
  bool clear(Offset a, Offset b) {
    queries++;
    return super.clear(a, b);
  }
}

void main() {
  test('A continuing route does not repeat graph searches every frame', () {
    final nav = CountingNavigation(const Rect.fromLTWH(0, 0, 1000, 1000),
        [const Rect.fromLTWH(300, 200, 150, 400)]);
    final key = Object();
    const target = Offset(800, 400);
    nav.queries = 0;
    var position = nav.move(const Offset(100, 400), target, 2, routeKey: key);
    final firstQueries = nav.queries;
    for (var i = 0; i < 20; i++) {
      nav.queries = 0;
      final next = nav.move(position, target, 2, routeKey: key);
      expect(nav.queries, lessThanOrEqualTo(2));
      expect(nav.queries, lessThan(firstQueries));
      expect(nav.canStand(next), isTrue);
      expect((next - position).distance, closeTo(2, 0.000001));
      position = next;
    }
    // A new order must not follow the old cached destination.
    const newTarget = Offset(50, 50);
    expect(nav.move(position, newTarget, 2000, routeKey: key), newTarget);
  });

  test('Spatial queries agree with individual obstacle checks across cell boundaries', () {
    const bounds = Rect.fromLTWH(-500, -500, 3000, 3000);
    final obstacles = List.generate(30, (i) =>
        Rect.fromLTWH((i % 6) * 300.0, (i ~/ 6) * 300.0, 256, 80));
    final nav = BuildingNavigation(bounds, obstacles);
    final individual = [for (final rect in obstacles) BuildingNavigation(bounds, [rect])];
    for (var x = -10; x < 2000; x += 127) {
      final a = Offset(x.toDouble(), 79);
      final b = a + const Offset(257, 180);
      expect(nav.clear(a, b), individual.every((item) => item.clear(a, b)));
      expect(nav.canStand(a), !obstacles.any((rect) => rect.contains(a)));
    }
  });

  test('Crowd candidates occupied by units do not query buildings', () {
    var buildingQueries = 0;
    final units = List.generate(12, (_) => SpacingUnit(const Offset(500, 500), 54));
    expect(separateUnits(units, const Rect.fromLTWH(0, 0, 2000, 2000), (_) {
      buildingQueries++;
      return true;
    }), isTrue);
    expect(buildingQueries, units.length);
  });
}
