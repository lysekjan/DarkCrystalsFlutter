import 'dart:math' as math;
import 'dart:ui';

class SpacingUnit {
  SpacingUnit(this.position, this.radius);
  Offset position;
  final double radius;
}

/// Places all living units in a shared spatial grid, including mixed teams.
/// Earlier units keep their place; overlaps are relocated to nearby free space.
bool separateUnits(List<SpacingUnit> units, Rect bounds,
    bool Function(Offset) canStand, {double gap = 6,
    bool Function(Offset, Offset)? canRelocate}) {
  if (units.isEmpty) return true;
  final maxRadius = units.map((u) => u.radius).reduce(math.max);
  final cellSize = maxRadius * 2 + gap;
  final cells = <(int, int), List<SpacingUnit>>{};
  (int, int) cell(Offset p) => ((p.dx / cellSize).floor(), (p.dy / cellSize).floor());
  bool free(Offset p, double radius) {
    if (!bounds.contains(p)) return false;
    final key = cell(p);
    for (var x = key.$1 - 1; x <= key.$1 + 1; x++) {
      for (var y = key.$2 - 1; y <= key.$2 + 1; y++) {
        for (final other in cells[(x, y)] ?? const <SpacingUnit>[]) {
          final distance = radius + other.radius + gap;
          if ((p - other.position).distanceSquared < distance * distance - 0.001) {
            return false;
          }
        }
      }
    }
    // In crowds most candidates already collide with a nearby unit. Avoid an
    // expensive building/navigation query until those cheap checks pass.
    return canStand(p);
  }
  for (final unit in units) {
    final origin = unit.position;
    if (!free(origin, unit.radius)) {
      var found = false;
      final limit = math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height);
      // Fine rings preserve locality for small overlaps; spacing grows naturally
      // for newly spawned groups that share the same starting position.
      for (double radius = 4; radius <= limit && !found; radius += 8) {
        final samples = math.max(16, (2 * math.pi * radius / 12).ceil());
        for (var i = 0; i < samples; i++) {
          final angle = i * 2 * math.pi / samples;
          final candidate = origin + Offset(math.cos(angle), math.sin(angle)) * radius;
          if (free(candidate, unit.radius) &&
              (canRelocate == null || canRelocate(origin, candidate))) {
            unit.position = candidate;
            found = true;
            break;
          }
        }
      }
      if (!found) {
        // The map must have enough walkable area for the requested population.
        return false;
      }
    }
    (cells[cell(unit.position)] ??= <SpacingUnit>[]).add(unit);
  }
  return true;
}
