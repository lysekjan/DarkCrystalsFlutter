import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'level_data.dart';
import 'level_repository.dart';

class LevelEditorScreen extends StatefulWidget {
  const LevelEditorScreen({
    super.key,
    required this.chapterNumber,
    required this.levelNumber,
    required this.onPreviewLevel,
  });

  final int chapterNumber;
  final int levelNumber;
  final Future<void> Function(BuildContext context) onPreviewLevel;

  @override
  State<LevelEditorScreen> createState() => _LevelEditorScreenState();
}

class _LevelEditorScreenState extends State<LevelEditorScreen> {
  LevelDef? _levelDef;
  bool _loading = true;
  bool _saving = false;
  int _selectedWaveIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final level = await LevelRepository.loadLevel(
      chapterNumber: widget.chapterNumber,
      levelNumber: widget.levelNumber,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _levelDef = level;
      _selectedWaveIndex = level.waves.isEmpty
          ? 0
          : _selectedWaveIndex.clamp(0, level.waves.length - 1).toInt();
      _loading = false;
    });
  }

  WaveDef? get _selectedWave {
    final level = _levelDef;
    if (level == null || level.waves.isEmpty) {
      return null;
    }
    return level.waves[_selectedWaveIndex];
  }

  Future<void> _saveLevel() async {
    final level = _levelDef;
    if (level == null) {
      return;
    }
    setState(() {
      _saving = true;
    });
    await LevelRepository.saveLevelOverride(level);
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level ulozen do lokalniho editor override.')),
    );
  }

  Future<void> _resetToDefault() async {
    await LevelRepository.clearLevelOverride(
      chapterNumber: widget.chapterNumber,
      levelNumber: widget.levelNumber,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Override smazan, nacitam vychozi level.')),
    );
    setState(() {
      _loading = true;
    });
    await _loadLevel();
  }

  void _replaceSelectedWave(WaveDef wave) {
    final level = _levelDef;
    if (level == null) {
      return;
    }
    final updatedWaves = List<WaveDef>.from(level.waves);
    updatedWaves[_selectedWaveIndex] = wave;
    updatedWaves.sort((a, b) => a.id.compareTo(b.id));
    _levelDef = level.copyWith(waves: updatedWaves);
  }

  void _addWave() {
    final level = _levelDef;
    if (level == null) {
      return;
    }
    final nextId = level.waves.isEmpty
        ? 1
        : level.waves.map((wave) => wave.id).reduce((a, b) => a > b ? a : b) + 1;
    final updated = List<WaveDef>.from(level.waves)
      ..add(
        WaveDef(
          id: nextId,
          startDelay: 2,
          completeWhenNoEnemies: true,
          events: const <SpawnEventDef>[],
        ),
      );
    setState(() {
      _levelDef = level.copyWith(waves: updated);
      _selectedWaveIndex = updated.length - 1;
    });
  }

  void _deleteSelectedWave() {
    final level = _levelDef;
    if (level == null || level.waves.isEmpty) {
      return;
    }
    final updated = List<WaveDef>.from(level.waves)..removeAt(_selectedWaveIndex);
    setState(() {
      _levelDef = level.copyWith(waves: updated);
      _selectedWaveIndex = updated.isEmpty
          ? 0
          : _selectedWaveIndex.clamp(0, updated.length - 1).toInt();
    });
  }

  Future<void> _editWaveSettings() async {
    final wave = _selectedWave;
    if (wave == null) {
      return;
    }
    final startDelayController = TextEditingController(text: wave.startDelay.toString());
    var completeWhenNoEnemies = wave.completeWhenNoEnemies;
    final result = await showDialog<WaveDef>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Wave ${wave.id}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: startDelayController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Start delay (s)'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dokoncit po smrti vsech nepratel'),
                    value: completeWhenNoEnemies,
                    onChanged: (value) {
                      setModalState(() {
                        completeWhenNoEnemies = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Zrusit'),
                ),
                FilledButton(
                  onPressed: () {
                    final startDelay = double.tryParse(startDelayController.text) ?? wave.startDelay;
                    Navigator.of(context).pop(
                      wave.copyWith(
                        startDelay: startDelay < 0 ? 0 : startDelay,
                        completeWhenNoEnemies: completeWhenNoEnemies,
                      ),
                    );
                  },
                  child: const Text('Ulozit'),
                ),
              ],
            );
          },
        );
      },
    );
    startDelayController.dispose();
    if (result == null) {
      return;
    }
    setState(() {
      _replaceSelectedWave(result);
    });
  }

  Future<void> _editEvent({SpawnEventDef? event, int? eventIndex}) async {
    final wave = _selectedWave;
    if (wave == null) {
      return;
    }
    final current = event ??
        const SpawnEventDef(
          time: 0,
          enemyType: 'fat_zombie',
          count: 1,
          lane: 1,
          spacing: 0.6,
          hpMultiplier: 1,
          speedMultiplier: 1,
        );
    final timeController = TextEditingController(text: current.time.toString());
    final countController = TextEditingController(text: current.count.toString());
    final laneController = TextEditingController(text: current.lane.toString());
    final spacingController = TextEditingController(text: current.spacing.toString());
    final hpController = TextEditingController(text: current.hpMultiplier.toString());
    final speedController = TextEditingController(text: current.speedMultiplier.toString());
    var enemyType = current.enemyType;

    final result = await showDialog<SpawnEventDef>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(event == null ? 'Novy spawn event' : 'Upravit spawn event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: enemyType,
                      items: enemyTypeRegistry.values
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type.id,
                              child: Text(type.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          enemyType = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Typ nepritele'),
                    ),
                    TextField(
                      controller: timeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cas od startu wave (s)'),
                    ),
                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pocet kusu'),
                    ),
                    TextField(
                      controller: laneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Lane 1-5'),
                    ),
                    TextField(
                      controller: spacingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Rozestup mezi kusy (s)'),
                    ),
                    TextField(
                      controller: hpController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'HP multiplier'),
                    ),
                    TextField(
                      controller: speedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Speed multiplier'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Zrusit'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      SpawnEventDef(
                        time: (double.tryParse(timeController.text) ?? current.time)
                            .clamp(0, 9999)
                            .toDouble(),
                        enemyType: enemyType,
                        count: (int.tryParse(countController.text) ?? current.count)
                            .clamp(1, 999)
                            .toInt(),
                        lane: (int.tryParse(laneController.text) ?? current.lane)
                            .clamp(1, 5)
                            .toInt(),
                        spacing: (double.tryParse(spacingController.text) ?? current.spacing)
                            .clamp(0, 9999)
                            .toDouble(),
                        hpMultiplier: (double.tryParse(hpController.text) ?? current.hpMultiplier)
                            .clamp(0.1, 999)
                            .toDouble(),
                        speedMultiplier:
                            (double.tryParse(speedController.text) ?? current.speedMultiplier)
                                .clamp(0.1, 999)
                                .toDouble(),
                      ),
                    );
                  },
                  child: const Text('Ulozit'),
                ),
              ],
            );
          },
        );
      },
    );

    timeController.dispose();
    countController.dispose();
    laneController.dispose();
    spacingController.dispose();
    hpController.dispose();
    speedController.dispose();

    if (result == null) {
      return;
    }

    final events = List<SpawnEventDef>.from(wave.events);
    if (eventIndex == null) {
      events.add(result);
    } else {
      events[eventIndex] = result;
    }
    events.sort((a, b) => a.time.compareTo(b.time));
    setState(() {
      _replaceSelectedWave(wave.copyWith(events: events));
    });
  }

  void _duplicateEvent(int eventIndex) {
    final wave = _selectedWave;
    if (wave == null) {
      return;
    }
    final events = List<SpawnEventDef>.from(wave.events);
    final source = events[eventIndex];
    events.insert(eventIndex + 1, source.copyWith(time: source.time + 0.25));
    events.sort((a, b) => a.time.compareTo(b.time));
    setState(() {
      _replaceSelectedWave(wave.copyWith(events: events));
    });
  }

  void _deleteEvent(int eventIndex) {
    final wave = _selectedWave;
    if (wave == null) {
      return;
    }
    final events = List<SpawnEventDef>.from(wave.events)..removeAt(eventIndex);
    setState(() {
      _replaceSelectedWave(wave.copyWith(events: events));
    });
  }

  Future<void> _copyJsonToClipboard() async {
    final level = _levelDef;
    if (level == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: level.toPrettyJson()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON zkopirovan do schranky.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _levelDef;
    final selectedWave = _selectedWave;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor levelu C${widget.chapterNumber} L${widget.levelNumber}'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _copyJsonToClipboard,
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: 'Kopirovat JSON',
          ),
          IconButton(
            onPressed: _loading ? null : _resetToDefault,
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset override',
          ),
          IconButton(
            onPressed: _loading || _saving
                ? null
                : () async {
                    await _saveLevel();
                    if (!mounted) {
                      return;
                    }
                    await widget.onPreviewLevel(context);
                  },
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Ulozit a spustit preview',
          ),
          IconButton(
            onPressed: _loading || _saving ? null : _saveLevel,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            tooltip: 'Ulozit',
          ),
        ],
      ),
      body: _loading || level == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                SizedBox(
                  width: 250,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xFF11161B)),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            level.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('${level.waves.length} waves'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: level.waves.length,
                            itemBuilder: (context, index) {
                              final wave = level.waves[index];
                              return ListTile(
                                selected: index == _selectedWaveIndex,
                                title: Text('Wave ${wave.id}'),
                                subtitle: Text('${wave.totalEnemyCount} nepratel'),
                                onTap: () {
                                  setState(() {
                                    _selectedWaveIndex = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _addWave,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Pridat wave'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: selectedWave == null ? null : _deleteSelectedWave,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Smazat wave'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: selectedWave == null
                      ? const Center(child: Text('Level nema zadne wave.'))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Wave ${selectedWave.id}',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.tonalIcon(
                                    onPressed: _editWaveSettings,
                                    icon: const Icon(Icons.tune),
                                    label: const Text('Nastaveni'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _editEvent(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Pridat spawn'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _InfoChip(label: 'Start delay', value: '${selectedWave.startDelay}s'),
                                  _InfoChip(label: 'Spawny', value: '${selectedWave.events.length}'),
                                  _InfoChip(label: 'Nepratele', value: '${selectedWave.totalEnemyCount}'),
                                  _InfoChip(
                                    label: 'Dokonceni',
                                    value: selectedWave.completeWhenNoEnemies ? 'Po smrti vsech' : 'Po eventech',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: selectedWave.events.isEmpty
                                    ? const Center(child: Text('Wave zatim nema zadne spawn eventy.'))
                                    : ListView.separated(
                                        itemCount: selectedWave.events.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final event = selectedWave.events[index];
                                          return Card(
                                            child: ListTile(
                                              title: Text(
                                                '${enemyTypeRegistry[event.enemyType]?.name ?? event.enemyType}  x${event.count}',
                                              ),
                                              subtitle: Text(
                                                't=${event.time}s, lane ${event.lane}, spacing ${event.spacing}s, HP x${event.hpMultiplier}, SPD x${event.speedMultiplier}',
                                              ),
                                              trailing: Wrap(
                                                spacing: 4,
                                                children: [
                                                  IconButton(
                                                    onPressed: () => _editEvent(event: event, eventIndex: index),
                                                    icon: const Icon(Icons.edit_outlined),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => _duplicateEvent(index),
                                                    icon: const Icon(Icons.copy_outlined),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => _deleteEvent(index),
                                                    icon: const Icon(Icons.delete_outline),
                                                  ),
                                                ],
                                              ),
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
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141C21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
