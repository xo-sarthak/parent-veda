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

import '../ttc/ttc_row_merge.dart';
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

  /// Edit times, removals, owners and what waits to upload (2026-10-17, 0099).
  static const _bookKey = 'pv_family_timeline_sync';
  final TtcRowBook _book = TtcRowBook();

  final Map<String, TimelineEvent> _events = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  @override
  bool get hasPendingPush => _book.dirty.isNotEmpty;

  @visibleForTesting
  TtcRowBook get bookForTest => _book;

  /// A moment her partner's phone wrote. Shown, never uploaded from here:
  /// 0099 lets each person change only their own rows.
  bool _theirs(String id, String? uid) {
    final owner = _book.owners[id];
    return owner != null && uid != null && owner != uid;
  }

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

  /// One moment by its id, or null (2026-10-24, STAGE-TRANSITIONS B3: a
  /// second pregnancy needs to know whether the fixed id is already a
  /// different day's moment).
  TimelineEvent? byId(String id) => _events[id];

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
    _book.touch(id);
    _persist();
    notifyListeners();
  }

  /// Corrects the DATE and WORDS of an event the app derived itself, never
  /// one she wrote (2026-09-30). Trying to conceive writes its milestones
  /// ("Logged your first period") the day the app first notices them, so a
  /// period logged today for 19 Aug read "30 Sep" on the timeline and the
  /// calendar's day card. The date is now the day it happened
  /// (`TtcMilestoneEngine.syncToTimeline`), and an entry already stored with
  /// the noticing date is corrected here. Still append-only for anything she
  /// typed: only milestone ids call this, and nothing is created.
  void refreshDerived(String id, {required DateTime on, String? titleEn, String? detailEn}) {
    final e = _events[id];
    if (e == null) return;
    final iso = DateTime(on.year, on.month, on.day).toIso8601String();
    final newTitle = titleEn ?? e.titleEn;
    final newDetail = detailEn ?? e.detailEn;
    if (e.dateIso == iso && e.titleEn == newTitle && e.detailEn == newDetail) {
      return;
    }
    _events[id] = TimelineEvent(
      id: e.id,
      dateIso: iso,
      stage: e.stage,
      kind: e.kind,
      titleEn: newTitle,
      titleHi: e.titleHi,
      detailEn: newDetail,
      detailHi: e.detailHi,
    );
    // Since 0099 a correction reaches the cloud, and so the other phone.
    _book.touch(id);
    _persist();
    notifyListeners();
  }

  /// Removing exists only for a mis-tap the parent made themselves - there is
  /// deliberately no bulk clear and no edit.
  ///
  /// A soft delete since 0099 (2026-10-17): the removal is a row with a time,
  /// so an offline phone or the other phone's copy cannot bring it back.
  void remove(String id) {
    final gone = _events.remove(id);
    if (gone == null) return;
    _book.remove(id, _cloudColumns(gone));
    _persist();
    // Kept for revert (2026-10-17): the hard delete.
    //   if (SupabaseRepo.isLoggedIn) {
    //     SupabaseRepo.delete(TtcTables.timeline, id).catchError((_) {});
    //   }
    notifyListeners();
  }

  /// A sign-out, or another account signing in (2026-10-17): this store forgets the person in memory; the cloud keeps it.
  @override
  void resetLocal() => resetForTest();

  @visibleForTesting
  void resetForTest() {
    _events.clear();
    _book.clear();
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
      final book = p.getString(_bookKey);
      if (book != null) _book.loadJson(jsonDecode(book));
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncFromCloud();
  }

  // ---- cloud ----------------------------------------------------------------
  //  Couple-readable, own-write, and APPEND-ONLY: 0041 grants no UPDATE on this
  //  table at all. A life story you can silently rewrite is not a record.
  //
  //  ⚠️ SUPERSEDED 2026-10-17 (0099, the user's decision). Without UPDATE the
  //  upload could never work: an upsert is INSERT ... ON CONFLICT DO UPDATE,
  //  and Postgres demands UPDATE for it even on a new row, so every upload
  //  was refused (silently). 0099 grants UPDATE on her OWN rows only. The
  //  "never rewrite what she wrote" rule now lives here, in code: there is
  //  still no edit, only `refreshDerived` for the app's own milestones.

  /// The moment's own columns, without the owner or the two times. Nulls are
  /// sent so a cleared detail clears everywhere.
  static Map<String, dynamic> _cloudColumns(TimelineEvent e) => {
        'stage': e.stage.id,
        'kind': e.kind.name,
        'happened_on': TtcSyncUtil.date(e.date),
        'title_en': e.titleEn,
        'title_hi': e.titleHi,
        'detail_en': e.detailEn,
        'detail_hi': e.detailHi,
      };

  // Newer wins, both ways (2026-10-17, 0099). The ids are fixed per moment
  // ("ttc_positive_test"), so the cloud's copy of an id IS the same moment,
  // and the newer copy is the right one. Kept for revert: `_pullUnionKept`.
  @override
  Future<void> pullFromCloud() async {
    final rows = await SupabaseRepo.fetchShared(TtcTables.timeline,
        orderBy: 'happened_on', ascending: true);
    applyCloudRows(rows);
  }

  /// The merge, network-free so a test can hand it rows.
  @visibleForTesting
  void applyCloudRows(List<Map<String, dynamic>> rows) {
    for (final row in _book.merge(_events.keys, rows)) {
      final id = row['id'] as String;
      if (_book.removed.containsKey(id)) {
        _events.remove(id);
        continue;
      }
      final on = TtcSyncUtil.parseDate(row['happened_on']);
      final titleEn = row['title_en'];
      if (on == null || titleEn is! String) continue;
      _events[id] = TimelineEvent(
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
      );
    }
  }

  // Kept for revert (2026-10-17): the union pull.
  // ignore: unused_element
  Future<void> _pullUnionKept() async {
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

  /// Her own moments only, only what is waiting, each confirmed (2026-10-17).
  ///
  /// A moment her partner wrote is never sent: RLS would refuse it, and it
  /// would then wait forever. If she removes one of his, it goes from this
  /// phone only.
  @override
  Future<void> pushToCloud() async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    for (final id in List.of(_book.dirty)) {
      final live = _events[id];
      final cols = live != null ? _cloudColumns(live) : _book.removedRows[id];
      if (cols == null || _theirs(id, uid)) {
        _book.dirty.remove(id);
        continue;
      }
      final sent = _book.stamps[id] ??=
          DateTime.now().toUtc().millisecondsSinceEpoch;
      final t = _book.times(id);
      final ok = await TtcSyncUtil.upsertConfirmed(
        TtcTables.timeline,
        {
          ...cols,
          'id': id,
          'user_id': uid,
          'updated_at': t.updatedAt,
          'removed_at': live == null ? t.removedAt : null,
        },
        onConflict: 'id',
      );
      _book.confirmed(id, ok: ok, sent: sent);
    }
    await _persist();
  }

  // Kept for revert (2026-10-17): every moment, every time; refused by the
  // database from the start (no UPDATE grant before 0099).
  // ignore: unused_element
  Future<void> _pushAllKept() async {
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
      await p.setString(_bookKey, jsonEncode(_book.toJson()));
    } catch (_) {/* best-effort */}
  }
}
