import 'dart:convert';

class EnemyTypeDef {
  const EnemyTypeDef({
    required this.id,
    required this.name,
    required this.baseHp,
    required this.baseSpeed,
    required this.baseDamagePerSecond,
  });

  final String id;
  final String name;
  final double baseHp;
  final double baseSpeed;
  final double baseDamagePerSecond;
}

const Map<String, EnemyTypeDef> enemyTypeRegistry = <String, EnemyTypeDef>{
  'fat_zombie': EnemyTypeDef(
    id: 'fat_zombie',
    name: 'Fat Zombie',
    baseHp: 20,
    baseSpeed: 16,
    baseDamagePerSecond: 5,
  ),
};

class SpawnEventDef {
  const SpawnEventDef({
    required this.time,
    required this.enemyType,
    required this.count,
    required this.lane,
    required this.spacing,
    this.hpMultiplier = 1.0,
    this.speedMultiplier = 1.0,
  });

  final double time;
  final String enemyType;
  final int count;
  final int lane;
  final double spacing;
  final double hpMultiplier;
  final double speedMultiplier;

  SpawnEventDef copyWith({
    double? time,
    String? enemyType,
    int? count,
    int? lane,
    double? spacing,
    double? hpMultiplier,
    double? speedMultiplier,
  }) {
    return SpawnEventDef(
      time: time ?? this.time,
      enemyType: enemyType ?? this.enemyType,
      count: count ?? this.count,
      lane: lane ?? this.lane,
      spacing: spacing ?? this.spacing,
      hpMultiplier: hpMultiplier ?? this.hpMultiplier,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time,
      'enemyType': enemyType,
      'count': count,
      'lane': lane,
      'spacing': spacing,
      'hpMultiplier': hpMultiplier,
      'speedMultiplier': speedMultiplier,
    };
  }

  factory SpawnEventDef.fromJson(Map<String, dynamic> json) {
    return SpawnEventDef(
      time: (json['time'] as num?)?.toDouble() ?? 0,
      enemyType: (json['enemyType'] as String?) ?? 'fat_zombie',
      count: (json['count'] as num?)?.toInt() ?? 1,
      lane: (json['lane'] as num?)?.toInt() ?? 1,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0,
      hpMultiplier: (json['hpMultiplier'] as num?)?.toDouble() ?? 1,
      speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 1,
    );
  }
}

class WaveDef {
  const WaveDef({
    required this.id,
    required this.startDelay,
    required this.completeWhenNoEnemies,
    required this.events,
  });

  final int id;
  final double startDelay;
  final bool completeWhenNoEnemies;
  final List<SpawnEventDef> events;

  int get totalEnemyCount =>
      events.fold<int>(0, (sum, event) => sum + event.count);

  WaveDef copyWith({
    int? id,
    double? startDelay,
    bool? completeWhenNoEnemies,
    List<SpawnEventDef>? events,
  }) {
    return WaveDef(
      id: id ?? this.id,
      startDelay: startDelay ?? this.startDelay,
      completeWhenNoEnemies: completeWhenNoEnemies ?? this.completeWhenNoEnemies,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'startDelay': startDelay,
      'completeWhenNoEnemies': completeWhenNoEnemies,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  factory WaveDef.fromJson(Map<String, dynamic> json) {
    final eventsJson = (json['events'] as List<dynamic>? ?? const <dynamic>[]);
    return WaveDef(
      id: (json['id'] as num?)?.toInt() ?? 1,
      startDelay: (json['startDelay'] as num?)?.toDouble() ?? 0,
      completeWhenNoEnemies: json['completeWhenNoEnemies'] as bool? ?? true,
      events: eventsJson
          .map((event) => SpawnEventDef.fromJson(event as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LevelDef {
  const LevelDef({
    required this.version,
    required this.chapter,
    required this.level,
    required this.name,
    required this.waves,
  });

  final int version;
  final int chapter;
  final int level;
  final String name;
  final List<WaveDef> waves;

  LevelDef copyWith({
    int? version,
    int? chapter,
    int? level,
    String? name,
    List<WaveDef>? waves,
  }) {
    return LevelDef(
      version: version ?? this.version,
      chapter: chapter ?? this.chapter,
      level: level ?? this.level,
      name: name ?? this.name,
      waves: waves ?? this.waves,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'chapter': chapter,
      'level': level,
      'name': name,
      'waves': waves.map((wave) => wave.toJson()).toList(),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory LevelDef.fromJson(Map<String, dynamic> json) {
    final wavesJson = (json['waves'] as List<dynamic>? ?? const <dynamic>[]);
    return LevelDef(
      version: (json['version'] as num?)?.toInt() ?? 1,
      chapter: (json['chapter'] as num?)?.toInt() ?? 1,
      level: (json['level'] as num?)?.toInt() ?? 1,
      name: (json['name'] as String?) ?? 'Level',
      waves: wavesJson
          .map((wave) => WaveDef.fromJson(wave as Map<String, dynamic>))
          .toList(),
    );
  }
}
