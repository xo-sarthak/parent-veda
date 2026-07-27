// =============================================================================
//  FamilyTimeline - one continuous life story across every stage
// -----------------------------------------------------------------------------
//  The master document names this as the one feature it thinks is missing, and
//  is specific about why it is not just "a timeline":
//
//      January 2028 · "We decided we wanted a baby" → First journal →
//      Partner joined → Started folic acid → First fertility consultation →
//      Positive pregnancy test → Week 12 → Baby's first kick → Birth →
//      First smile → First word → Started school
//
//      "One continuous life story. Not TTC. Not Pregnancy. Not Parenting.
//       Family."                                        - TTC master, p.117
//
//  ---------------------------------------------------------------------------
//  Why this is ADDITIVE rather than the Part 4 rewrite
//
//  Part 4 proposes re-modelling everything around a Family Journey Graph. Doing
//  that to 56 live tables carrying real pregnancy and parenting data, in order
//  to build a third stage, is the expensive kind of risk. So this is a thin
//  append-only event log that TTC writes into from day one and that the other
//  two stages can backfill into later, at their own pace, without either of
//  them changing shape.
//
//  Lives in lib/services/ rather than lib/ttc/ because it belongs to no stage.
//  TTC is simply the first to write to it.
//
//  Append-only by design: `add` is idempotent on the event id, and there is no
//  update. A life story you can silently rewrite is not a record.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ttc/ttc_sync.dart';
import 'life_stage_store.dart';
import 'remote/supabase_repo.dart';

/// What kind of moment this was. Drives the icon and the grouping, never the
/// ordering - the timeline is strictly chronological.
enum TimelineKind {
  /// Entering a stage: started trying, positive test, birth.
  milestone,

  /// Something medical: a test, a consultation, a report.
  medical,

  /// Something written: a journal entry, a letter.
  written,

  /// Someone joined: a partner, a doctor, a care partner.
  people,

  /// A habit or a decision: started folic acid, booked a class.
  action,
}

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.dateIso,
    required this.stage,
    required this.kind,
    required this.titleEn,
    required this.titleHi,
    this.detailEn,
    this.detailHi,
  });

  /// App-generated and stable, so a re-run of the same write does not create a
  /// second copy of the same moment.
  final String id;
  final String dateIso;

  /// Which chapter of the family's life this happened in.
  final LifeStage stage;
  final TimelineKind kind;

  final String titleEn;
  final String titleHi;
  final String? detailEn;
  final String? detailHi;

  DateTime get date => DateTime.tryParse(dateIso) ?? DateTime.now();

  String title(bool hi) => hi ? titleHi : titleEn;
  String? detail(bool hi) => hi ? detailHi : detailEn;

  Map<String, Object?> toJson() => {
        'id': id,
        'date': dateIso,
        'stage': stage.id,
        'kind': kind.name,
        'en': titleEn,
        'hi': titleHi,
        if (detailEn != null) 'den': detailEn,
        if (detailHi != null) 'dhi': detailHi,
      };

  static TimelineEvent? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final date = raw['date'];
    final en = raw['en'];
    if (id is! String || date is! String || en is! String) return null;
    return TimelineEvent(
      id: id,
      dateIso: date,
      stage: LifeStageCopy.fromId(raw['stage'] as String?) ??
          LifeStage.tryingToConceive,
      kind: TimelineKind.values.where((e) => e.name == raw['kind']).firstOrNull ??
          TimelineKind.action,
      titleEn: en,
      titleHi: (raw['hi'] as String?) ?? en,
      detailEn: raw['den'] as String?,
      detailHi: raw['dhi'] as String?,
    );
  }
}

class FamilyTimeline extends ChangeNotifier with TtcSyncedStore {
  FamilyTimeline._() {
    _load();
  }
  static final FamilyTimeline instance = FamilyTimeline._();

  static const _key = 'pv_family_timeline';

  final Map<String, TimelineEvent> _events = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The whole story, oldest first - the order a life is lived in.
  List<TimelineEvent> get events {
    final out = _events.values.toList()
      ..sort((a, b) => a.dateIso.compareTo(b.dateIso));
    return List.unmodifiable(out);
  }

  /// Newest first, for a "recently" view.
  List<TimelineEvent> get recent => List.unmodifiable(events.reversed);

  List<TimelineEvent> forStage(LifeStage stage) =>
      events.where((e) => e.stage == stage).toList();

  bool has(String id) => _events.containsKey(id);

  int get count => _events.length;

  /// Records a moment. Idempotent on [id]: writing the same event twice - which
  /// happens naturally when a screen rebuilds - leaves one entry, not two.
  void add({
    required String id,
    required LifeStage stage,
    required TimelineKind kind,
    required String titleEn,
    required String titleHi,
    String? detailEn,
    String? detailHi,
    DateTime? on,
  }) {
    if (_events.containsKey(id)) return;
    final when = on ?? DateTime.now();
    _events[id] = TimelineEvent(
      id: id,
      dateIso: DateTime(when.year, when.month, when.day).toIso8601String(),
      stage: stage,
      kind: kind,
      titleEn: titleEn,
      titleHi: titleHi,
      detailEn: detailEn,
      detailHi: detailHi,
    );
    _persist();
    notifyListeners();
  }

  /// Removing exists only for a mis-tap the parent made themselves - there is
  /// deliberately no bulk clear and no edit.
  void remove(String id) {
    if (_events.remove(id) == null) return;
    _persist();
    // Delete IS granted (a mis-tapped positive test must be undoable) - and it
    // has to reach the cloud, or the union pull restores the moment.
    if (SupabaseRepo.isLoggedIn) {
      SupabaseRepo.delete(TtcTables.timeline, id).catchError((_) {});
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _events.clear();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      for (final row in p.getStringList(_key) ?? const <String>[]) {
        try {
          final e = TimelineEvent.fromJson(jsonDecode(row));
          if (e != null) _events[e.id] = e;
        } catch (_) {/* a corrupt row is dropped, never fatal */}
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  Couple-readable, own-write, and APPEND-ONLY: 0041 grants no UPDATE on this
  //  table at all. A life story you can silently rewrite is not a record.

  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared(TtcTables.timeline,
        orderBy: 'happened_on', ascending: true);
    for (final row in rows) {
      final id = row['id'];
      final on = TtcSyncUtil.parseDate(row['happened_on']);
      final titleEn = row['title_en'];
      if (id is! String || on == null || titleEn is! String) continue;
      // putIfAbsent, so a moment recorded offline is never overwritten by the
      // cloud's copy of a different moment with the same id.
      _events.putIfAbsent(
        id,
        () => TimelineEvent(
          id: id,
          dateIso: on.toIso8601String(),
          stage: LifeStageCopy.fromId(row['stage'] as String?) ??
              LifeStage.tryingToConceive,
          kind: TimelineKind.values
                  .where((e) => e.name == row['kind'])
                  .firstOrNull ??
              TimelineKind.action,
          titleEn: titleEn,
          titleHi: (row['title_hi'] as String?) ?? titleEn,
          detailEn: row['detail_en'] as String?,
          detailHi: row['detail_hi'] as String?,
        ),
      );
    }
  }

  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    await TtcSyncUtil.upsertAll(
      TtcTables.timeline,
      [
        for (final e in _events.values)
          {
            'id': e.id,
            'user_id': uid,
            'stage': e.stage.id,
            'kind': e.kind.name,
            'happened_on': TtcSyncUtil.date(e.date),
            'title_en': e.titleEn,
            'title_hi': e.titleHi,
            if (e.detailEn != null) 'detail_en': e.detailEn,
            if (e.detailHi != null) 'detail_hi': e.detailHi,
          }
      ],
      onConflict: 'id',
    );
  }

  @override
  Future<void> persistLocalCache() => _persist();

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _key, _events.values.map((e) => jsonEncode(e.toJson())).toList());
    } catch (_) {/* best-effort */}
  }
}
