import 'dart:math' as math;
import 'dart:ui';

/// Visibility-graph navigation around rectangular building footprints.
class BuildingNavigation {
  BuildingNavigation(this.bounds, this.obstacles) {
    for (var i = 0; i < obstacles.length; i++) {
      final rect = obstacles[i];
      for (var x = (rect.left / _cellSize).floor(); x <= (rect.right / _cellSize).floor(); x++) {
        for (var y = (rect.top / _cellSize).floor(); y <= (rect.bottom / _cellSize).floor(); y++) {
          (_obstacleCells[(x, y)] ??= <int>[]).add(i);
        }
      }
    }
    for (final rect in obstacles) {
      final outer = rect.inflate(1);
      for (final point in [outer.topLeft, outer.topRight,
        outer.bottomLeft, outer.bottomRight]) {
        if (bounds.contains(point) && !obstacles.any((r) => r.contains(point))) {
          corners.add(point);
        }
      }
    }
    edges = List.generate(corners.length, (_) => <int>[]);
    for (var i = 0; i < corners.length; i++) {
      for (var j = i + 1; j < corners.length; j++) {
        if (clear(corners[i], corners[j])) {
          edges[i].add(j);
          edges[j].add(i);
        }
      }
    }
  }

  final Rect bounds;
  final List<Rect> obstacles;
  final List<Offset> corners = [];
  late final List<List<int>> edges;
  final Expando<_CachedBuildingRoute> _routes = Expando<_CachedBuildingRoute>();
  static const double _cellSize = 256;
  final Map<(int, int), List<int>> _obstacleCells = {};

  bool _blocked(Offset point) {
    final cell = ((point.dx / _cellSize).floor(), (point.dy / _cellSize).floor());
    for (final i in _obstacleCells[cell] ?? const <int>[]) {
      if (obstacles[i].contains(point)) return true;
    }
    return false;
  }

  bool canStand(Offset point) => bounds.contains(point) && !_blocked(point);

  Iterable<Rect> _segmentObstacles(double left, double top, double right, double bottom) sync* {
    final x0 = (left / _cellSize).floor();
    final y0 = (top / _cellSize).floor();
    final x1 = (right / _cellSize).floor();
    final y1 = (bottom / _cellSize).floor();
    if ((x1 - x0 + 1) * (y1 - y0 + 1) >= obstacles.length) {
      yield* obstacles;
      return;
    }
    final seen = <int>{};
    for (var x = x0; x <= x1; x++) {
      for (var y = y0; y <= y1; y++) {
        for (final i in _obstacleCells[(x, y)] ?? const <int>[]) {
          if (seen.add(i)) yield obstacles[i];
        }
      }
    }
  }

  bool clear(Offset a, Offset b) {
    final minX = math.min(a.dx, b.dx);
    final maxX = math.max(a.dx, b.dx);
    final minY = math.min(a.dy, b.dy);
    final maxY = math.max(a.dy, b.dy);
    for (final rect in _segmentObstacles(minX, minY, maxX, maxY)) {
      // Check only nearby cells for short movement and separation queries.
      if (rect.right < minX || rect.left > maxX ||
          rect.bottom < minY || rect.top > maxY) {
        continue;
      }
      if (_segmentHits(a, b, rect)) return false;
    }
    return true;
  }

  static bool _segmentHits(Offset a, Offset b, Rect rect) {
    var low = 0.0;
    var high = 1.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dx.abs() < 1e-9) {
      if (a.dx < rect.left || a.dx > rect.right) return false;
    } else {
      final t1 = (rect.left - a.dx) / dx;
      final t2 = (rect.right - a.dx) / dx;
      low = math.max(low, math.min(t1, t2));
      high = math.min(high, math.max(t1, t2));
    }
    if (dy.abs() < 1e-9) {
      if (a.dy < rect.top || a.dy > rect.bottom) return false;
    } else {
      final t1 = (rect.top - a.dy) / dy;
      final t2 = (rect.bottom - a.dy) / dy;
      low = math.max(low, math.min(t1, t2));
      high = math.min(high, math.max(t1, t2));
    }
    return low <= high;
  }

  Offset outside(Offset point) {
    var result = Offset(point.dx.clamp(bounds.left, bounds.right - 0.01),
        point.dy.clamp(bounds.top, bounds.bottom - 0.01));
    // Also handles units caught by newly completed buildings.
    for (var pass = 0; pass <= obstacles.length; pass++) {
      if (!_blocked(result)) return result;
      final candidates = <Offset>[];
      for (final rect in obstacles) {
        candidates.addAll([
          Offset(rect.left - 1, result.dy), Offset(rect.right + 1, result.dy),
          Offset(result.dx, rect.top - 1), Offset(result.dx, rect.bottom + 1),
        ]);
      }
      candidates.removeWhere((p) => !canStand(p));
      if (candidates.isEmpty) return result;
      candidates.sort((a, b) => (a - point).distanceSquared
          .compareTo((b - point).distanceSquared));
      result = candidates.first;
    }
    return result;
  }

  Offset move(Offset position, Offset destination, double distance, {Object? routeKey}) {
    var start = outside(position);
    final target = outside(destination);
    if (distance <= 0) return start;
    if (clear(start, target)) {
      if (routeKey != null) _routes[routeKey] = null;
      final delta = target - start;
      return delta.distance <= distance ? target : start + delta / delta.distance * distance;
    }
    final cached = routeKey == null ? null : _routes[routeKey];
    if (cached != null && cached.target == target && cached.blockedStart == start) {
      return start;
    }
    if (cached != null && cached.target == target &&
        cached.next < cached.points.length && clear(start, cached.points[cached.next])) {
      return _followRoute(start, cached, distance);
    }
    // A* over the corner visibility graph; the straight-line heuristic keeps the
    // search local even with many obstacles (e.g. a forest of trees).
    final startIndex = corners.length;
    final endIndex = corners.length + 1;
    Offset node(int i) =>
        i == startIndex ? start : i == endIndex ? target : corners[i];
    final costs = List<double>.filled(corners.length + 2, double.infinity);
    final previous = List<int>.filled(corners.length + 2, -1);
    final closed = List<bool>.filled(corners.length + 2, false);
    final open = <int>[startIndex];
    costs[startIndex] = 0;
    double estimate(int i) => costs[i] + (node(i) - target).distance;
    while (open.isNotEmpty) {
      var best = 0;
      var bestEstimate = estimate(open[0]);
      for (var k = 1; k < open.length; k++) {
        final value = estimate(open[k]);
        if (value < bestEstimate) {
          best = k;
          bestEstimate = value;
        }
      }
      final current = open[best];
      open[best] = open.last;
      open.removeLast();
      if (current == endIndex) break;
      if (closed[current]) continue;
      closed[current] = true;
      final from = node(current);
      void relax(int next) {
        final cost = costs[current] + (node(next) - from).distance;
        if (cost < costs[next]) {
          costs[next] = cost;
          previous[next] = current;
          open.add(next);
        }
      }
      if (current == startIndex) {
        for (var i = 0; i < corners.length; i++) {
          if (clear(start, corners[i])) relax(i);
        }
      } else {
        for (final next in edges[current]) {
          if (!closed[next]) relax(next);
        }
      }
      if (clear(from, target)) relax(endIndex);
    }
    if (previous[endIndex] < 0) {
      if (routeKey != null) {
        _routes[routeKey] = _CachedBuildingRoute(target, [], blockedStart: start);
      }
      return start; // Never cross a blocked route.
    }
    final path = <Offset>[];
    for (var i = endIndex; i != startIndex; i = previous[i]) {
      path.add(node(i));
    }
    final route = _CachedBuildingRoute(target, path.reversed.toList());
    if (routeKey != null) _routes[routeKey] = route;
    return _followRoute(start, route, distance);
  }

  Offset _followRoute(Offset start, _CachedBuildingRoute route, double distance) {
    while (route.next < route.points.length) {
      final waypoint = route.points[route.next];
      final delta = waypoint - start;
      if (delta.distance > distance) return start + delta / delta.distance * distance;
      distance -= delta.distance;
      start = waypoint;
      route.next++;
    }
    return start;
  }
}

class _CachedBuildingRoute {
  _CachedBuildingRoute(this.target, this.points, {this.blockedStart});
  final Offset target;
  final List<Offset> points;
  final Offset? blockedStart;
  int next = 0;
}
