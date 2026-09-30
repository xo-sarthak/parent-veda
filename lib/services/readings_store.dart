// =============================================================================
//  ReadingsStore — her blood pressure and sugar readings (2026-09-30)
// -----------------------------------------------------------------------------
//  From the pregnancy gap analysis, "A blood pressure and sugar log" (P2):
//  women with gestational diabetes or high blood pressure are asked to check at
//  home, the Complications door explains both, and there was nowhere to keep
//  the numbers. "A 'Track my readings' journey exists in our data with no way to
//  reach it."
//
//  ⚠️ THE LINE THIS STORE HOLDS: IT KEEPS NUMBERS, IT NEVER JUDGES THEM.
//  Nothing here classifies a reading as high, low, normal, red or green. The
//  only comparison in the whole feature is the one her DOCTOR set: she may enter
//  the target she was given and we show it beside her readings, as her own words.
//  CLAUDE.md: where a clinician owns a decision we may explain it, remind about
//  it or help her prepare for it, never reinterpret it. A tracker that starts
//  colouring numbers has started diagnosing, and one that colours them from OUR
//  ranges would contradict a doctor who set her a different target for her own
//  reasons (a woman with chronic hypertension has a different target).
//
//  ⚠️ THE ONE CHECK IT DOES RUN IS ON TYPING, NOT ON MEANING. A pressure of
//  1180/76 is a slipped finger, and a log that keeps it makes every chart wrong.
//  `Reading.plausible` rejects values no human has (systolic 50 to 260, diastolic
//  30 to 160, diastolic below systolic, sugar 20 to 600 mg/dL) and says "check
//  the number", which is data-entry hygiene, not a verdict on her health. The
//  bounds are wide on purpose: a real emergency reading must still be loggable.
//
//  LOCAL-FIRST, AND THE APP MAKES THE IDS. Shows from shared_preferences at once,
//  syncs after through `CloudSyncedStore` (one blob in `user_state` under
//  `readings`, so no schema change), and an id is minted on the phone so a local
//  row and its cloud copy are one identity and a sync is an idempotent merge.
//  Units: sugar is mg/dL, what an Indian glucometer prints. mmol/L is not offered;
//  a second unit is a second way to be wrong by a factor of 18.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_synced_store.dart';

enum ReadingKind { bloodPressure, sugar }

/// When a sugar reading was taken, because the same number means different
/// things fasting and after food. Blood pressure has no context.
enum SugarContext { fasting, beforeFood, afterFood, bedtime, other }

extension SugarContextX on SugarContext {
  String get label => switch (this) {
        SugarContext.fasting => 'Fasting',
        SugarContext.beforeFood => 'Before food',
        SugarContext.afterFood => 'After food',
        SugarContext.bedtime => 'Bedtime',
        SugarContext.other => 'Other',
      };
}

class Reading {
  const Reading({
    required this.id,
    required this.kind,
    required this.at,
    this.systolic,
    this.diastolic,
    this.mgdl,
    this.context,
    this.note = '',
  });

  final String id;
  final ReadingKind kind;
  final DateTime at;
  final int? systolic;
  final int? diastolic;
  final int? mgdl;
  final SugarContext? context;
  final String note;

  /// "118/76" or "104". No unit and no verdict: the screen adds "mg/dL" as a label.
  String get valueText => kind == ReadingKind.bloodPressure ? '$systolic/$diastolic' : '$mgdl';

  /// Whether the numbers are ones a person can have. NOT a health judgement; see
  /// the header.
  bool get plausible => switch (kind) {
        ReadingKind.bloodPressure => systolic != null &&
            diastolic != null &&
            systolic! >= 50 &&
            systolic! <= 260 &&
            diastolic! >= 30 &&
            diastolic! <= 160 &&
            diastolic! < systolic!,
        ReadingKind.sugar => mgdl != null && mgdl! >= 20 && mgdl! <= 600,
      };

  Reading copyWith({DateTime? at, int? systolic, int? diastolic, int? mgdl, SugarContext? context, String? note}) =>
      Reading(
        id: id,
        kind: kind,
        at: at ?? this.at,
        systolic: systolic ?? this.systolic,
        diastolic: diastolic ?? this.diastolic,
        mgdl: mgdl ?? this.mgdl,
        context: context ?? this.context,
        note: note ?? this.note,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'at': at.toIso8601String(),
        if (systolic != null) 'sys': systolic,
        if (diastolic != null) 'dia': diastolic,
        if (mgdl != null) 'mgdl': mgdl,
        if (context != null) 'ctx': context!.name,
        if (note.isNotEmpty) 'note': note,
      };

  /// Null for a row that is not a reading, so one bad row never loses the rest.
  static Reading? fromJson(Object? j) {
    if (j is! Map) return null;
    final kind = ReadingKind.values.where((k) => k.name == j['kind']).firstOrNull;
    final at = DateTime.tryParse('${j['at']}');
    final id = j['id'];
    if (kind == null || at == null || id is! String) return null;
    return Reading(
      id: id,
      kind: kind,
      at: at,
      systolic: j['sys'] is int ? j['sys'] as int : null,
      diastolic: j['dia'] is int ? j['dia'] as int : null,
      mgdl: j['mgdl'] is int ? j['mgdl'] as int : null,
      context: SugarContext.values.where((c) => c.name == j['ctx']).firstOrNull,
      note: j['note'] is String ? j['note'] as String : '',
    );
  }
}

/// What HER doctor told her to aim for. Every field is optional and hers; we
/// print it beside her readings as "Your doctor's target" and compare nothing.
class ReadingTargets {
  const ReadingTargets({this.sysUnder, this.diaUnder, this.fastingUnder, this.afterFoodUnder});

  final int? sysUnder;
  final int? diaUnder;
  final int? fastingUnder;
  final int? afterFoodUnder;

  bool get isEmpty => sysUnder == null && diaUnder == null && fastingUnder == null && afterFoodUnder == null;

  /// "Under 140/90", or null when she has not entered one.
  String? get pressureLine {
    if (sysUnder == null && diaUnder == null) return null;
    if (sysUnder != null && diaUnder != null) return 'Under $sysUnder/$diaUnder';
    return sysUnder != null ? 'Top number under $sysUnder' : 'Bottom number under $diaUnder';
  }

  /// "Fasting under 95, after food under 140 (mg/dL)".
  String? get sugarLine {
    final parts = [
      if (fastingUnder != null) 'fasting under $fastingUnder',
      if (afterFoodUnder != null) 'after food under $afterFoodUnder',
    ];
    if (parts.isEmpty) return null;
    final s = parts.join(', ');
    return '${s[0].toUpperCase()}${s.substring(1)} (mg/dL)';
  }

  Map<String, Object?> toJson() => {
        if (sysUnder != null) 'sys': sysUnder,
        if (diaUnder != null) 'dia': diaUnder,
        if (fastingUnder != null) 'fasting': fastingUnder,
        if (afterFoodUnder != null) 'after': afterFoodUnder,
      };

  static ReadingTargets fromJson(Object? j) {
    if (j is! Map) return const ReadingTargets();
    int? n(Object? v) => v is int ? v : null;
    return ReadingTargets(
        sysUnder: n(j['sys']), diaUnder: n(j['dia']), fastingUnder: n(j['fasting']), afterFoodUnder: n(j['after']));
  }
}

class ReadingsStore extends ChangeNotifier with CloudSyncedStore {
  ReadingsStore._();
  static final ReadingsStore instance = ReadingsStore._();

  /// A store of its own, for a test that must not touch the singleton.
  @visibleForTesting
  ReadingsStore.forTest();

  static const _key = 'readings_v1';

  final List<Reading> _all = [];
  ReadingTargets _targets = const ReadingTargets();
  bool _loaded = false;

  ReadingTargets get targets => _targets;
  bool get isLoaded => _loaded;

  /// Newest first.
  List<Reading> of(ReadingKind kind) =>
      _all.where((r) => r.kind == kind).toList()..sort((a, b) => b.at.compareTo(a.at));

  Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) _adopt(jsonDecode(raw));
    } catch (_) {/* a bad blob is an empty log, never a crash */}
    _loaded = true;
    notifyListeners();
    await syncStateFromCloud();
  }

  void _adopt(Object? data) {
    if (data is! Map) return;
    _all
      ..clear()
      ..addAll([
        for (final j in (data['entries'] is List ? data['entries'] as List : const []))
          ?Reading.fromJson(j),
      ]);
    _targets = ReadingTargets.fromJson(data['targets']);
  }

  /// Mints the id on the phone, so the local row and its cloud copy are one.
  Reading add({
    required ReadingKind kind,
    required DateTime at,
    int? systolic,
    int? diastolic,
    int? mgdl,
    SugarContext? context,
    String note = '',
  }) {
    final r = Reading(
      id: 'rd_${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      at: at,
      systolic: systolic,
      diastolic: diastolic,
      mgdl: mgdl,
      context: kind == ReadingKind.sugar ? (context ?? SugarContext.other) : null,
      note: note.trim(),
    );
    _all.add(r);
    _changed();
    return r;
  }

  void update(Reading r) {
    final i = _all.indexWhere((e) => e.id == r.id);
    if (i < 0) return;
    _all[i] = r;
    _changed();
  }

  void remove(String id) {
    if (_all.any((e) => e.id == id)) {
      _all.removeWhere((e) => e.id == id);
      _changed();
    }
  }

  void setTargets(ReadingTargets t) {
    _targets = t;
    _changed();
  }

  void _changed() {
    _persist();
    notifyListeners();
  }

  /// Plain text she can send to her doctor. Numbers as she typed them, the
  /// target as she entered it, and no adjectives.
  String summary(ReadingKind kind, {int limit = 30}) {
    final rows = of(kind).take(limit).toList();
    final isBp = kind == ReadingKind.bloodPressure;
    final b = StringBuffer(isBp ? 'My blood pressure readings' : 'My blood sugar readings (mg/dL)');
    b.writeln(' (from ParentVeda)');
    final target = isBp ? _targets.pressureLine : _targets.sugarLine;
    if (target != null) b.writeln("The target my doctor gave me: ${target.toLowerCase()}");
    b.writeln();
    for (final r in rows.reversed) {
      final d = r.at;
      final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      final ctx = r.context == null ? '' : ', ${r.context!.label.toLowerCase()}';
      final note = r.note.isEmpty ? '' : ' (${r.note})';
      b.writeln('$date $time  ${r.valueText}$ctx$note');
    }
    return b.toString().trimRight();
  }

  // ---- cloud (CloudSyncedStore) ----------------------------------------------
  @override
  String get cloudKey => 'readings';

  @override
  Object cloudData() => {
        'entries': [for (final r in _all) r.toJson()],
        'targets': _targets.toJson(),
      };

  @override
  void applyCloudData(Object data) => _adopt(data);

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(cloudData()));
    } catch (_) {/* best-effort, the cloud copy still has it */}
  }
}
