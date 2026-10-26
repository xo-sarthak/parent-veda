// =============================================================================
//  PregnancyRecords - one record per pregnancy (R1, 2026-10-25, 0114)
// -----------------------------------------------------------------------------
//  Until now a pregnancy was not a thing the app could name: one due date, one
//  stage, one loss flag per person. So a pregnancy after a loss showed the lost
//  one's bump photos, scans and hospital bag, and nothing could be looked back
//  at or removed on purpose (STAGE-TRANSITIONS R1).
//
//  A record is one pregnancy: its start, due date (and how it was set), how and
//  when it ended, the child it became, and an ARCHIVE of the records that have
//  no date to tell pregnancies apart (pregnancy_archive.dart).
//
//  ⚠️ WHOSE IS A DATED RECORD: THE WINDOW RULE. The records sort by start, and
//  each owns the time from its start to the next one's start (the first owns
//  everything before it; the latest owns everything after). A bump photo, a
//  symptom or a letter belongs to the pregnancy whose window holds its date.
//  So the windows partition time: no record is in two pregnancies, none is in
//  none. Every pregnancy reader asks [inCurrent], the one place the rule lives
//  (BACKEND-PATTERNS 16oo). A removed record still bounds the windows, so what
//  it held never slides into its neighbour.
//
//  Decided 2026-10-25 (the user): her records are sealed, never deleted for
//  her; she can look at an old pregnancy, or delete it (the house soft delete,
//  purged after 90 days). Never asked at the moment of the loss.
//
//  Synced own-row, newer wins (OwnRowLedger). Her partner's phone reads her
//  rows (0114's partner read) and uses them for its windows when it has none.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/post_pregnancy/pp_child_profile.dart';
import 'family_timeline.dart';
import 'life_stage_store.dart';
import 'pregnancy_archive.dart';
import 'pregnancy_controller.dart';
import 'pregnancy_ended_store.dart';
import 'remote/own_row_ledger.dart';
import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';
import 'remote/sync_row_book.dart';

/// How a pregnancy ended. `ended` is "it ended and the app was not told how"
/// (the stage moved without a loss or a birth being recorded): never shown as
/// a loss, because naming a loss she did not tell us of would be the worst
/// guess to get wrong.
enum PregnancyOutcome { ongoing, loss, birth, ended }

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// How long After a loss leads the trying-to-conceive home once a loss has
/// closed (2026-10-26): about three cycles, the time most mothers are told to
/// wait or watch. Then the door goes back to its own place; it never goes.
const int kAfterLossLeadDays = 90;
String _iso(DateTime d) => _day(d).toIso8601String().substring(0, 10);
DateTime? _parse(Object? v) {
  final d = v == null ? null : DateTime.tryParse(v.toString());
  return d == null ? null : _day(d);
}

class PregnancyRecord {
  PregnancyRecord({
    required this.id,
    required this.startedOn,
    this.dueDate,
    this.dueDateSource,
    this.endedOn,
    this.outcome = PregnancyOutcome.ongoing,
    this.childId,
    Map<String, Object?>? archive,
  }) : archive = archive ?? {};

  final String id;
  DateTime startedOn;
  DateTime? dueDate;
  String? dueDateSource;
  DateTime? endedOn;
  PregnancyOutcome outcome;
  String? childId;

  /// part key -> that part's records, copied when the next pregnancy began
  /// (pregnancy_archive.dart). Empty while this is the latest pregnancy: its
  /// undated records are still the live stores'.
  Map<String, Object?> archive;

  bool get sealed => archive.isNotEmpty;

  static String idFor(DateTime start) => 'preg_${_iso(start)}';

  Map<String, dynamic> toRow() => {
        'id': id,
        'started_on': _iso(startedOn),
        'due_date': dueDate == null ? null : _iso(dueDate!),
        'due_date_source': dueDateSource,
        'ended_on': endedOn == null ? null : _iso(endedOn!),
        'outcome': outcome.name,
        'child_id': childId,
        'archive': archive,
      };

  static PregnancyRecord? fromRow(Map<String, dynamic> r) {
    final id = (r['id'] ?? '').toString();
    final start = _parse(r['started_on']);
    if (id.isEmpty || start == null) return null;
    final a = r['archive'];
    return PregnancyRecord(
      id: id,
      startedOn: start,
      dueDate: _parse(r['due_date']),
      dueDateSource: r['due_date_source']?.toString(),
      endedOn: _parse(r['ended_on']),
      outcome: PregnancyOutcome.values.firstWhere(
          (o) => o.name == r['outcome'],
          orElse: () => PregnancyOutcome.ongoing),
      childId: r['child_id']?.toString(),
      archive: a is Map ? Map<String, Object?>.from(a) : null,
    );
  }
}

/// A pregnancy's stretch of time: [from] inclusive, [until] exclusive; null
/// is open on that side.
class PregnancyWindow {
  const PregnancyWindow(this.from, this.until);
  final DateTime? from;
  final DateTime? until;

  /// Everything (no pregnancy recorded yet).
  static const all = PregnancyWindow(null, null);

  bool holds(DateTime d) {
    final x = _day(d);
    if (from != null && x.isBefore(from!)) return false;
    if (until != null && !x.isBefore(until!)) return false;
    return true;
  }
}

/// A store whose records carry a date and so belong to one pregnancy's window
/// (R1). The "Kept for you" page counts them and its delete removes them,
/// each the way the store's own delete does, so the removal syncs.
abstract interface class PregnancyScopedStore {
  /// How many of her records fall in [w].
  int countIn(PregnancyWindow w);

  /// Removes them (soft deletes that travel), and says how many.
  Future<int> removeIn(PregnancyWindow w);
}

/// Pure: the window of [r] among [records] (removed ones included, so a
/// removed pregnancy still bounds its neighbours).
PregnancyWindow pregnancyWindowOf(PregnancyRecord r, List<PregnancyRecord> records) {
  final sorted = [...records]..sort((a, b) => a.startedOn.compareTo(b.startedOn));
  final i = sorted.indexWhere((x) => x.id == r.id);
  if (i < 0) return PregnancyWindow.all;
  return PregnancyWindow(
    i == 0 ? null : sorted[i].startedOn,
    i == sorted.length - 1 ? null : sorted[i + 1].startedOn,
  );
}

/// Pure: the records an install from before R1 already implies. Derived, never
/// asked (CLAUDE.md "derive, never ask").
///  · each pregnancy the family timeline remembers (`pregnancy_started`,
///    `pregnancy_started:<day>`, ttc_transition.dart), started four weeks
///    before the day the test was confirmed;
///  · the pregnancy her due date describes, started 280 days before it, when
///    the stage is pregnancy or parenting (a due date worked out on the TTC
///    calculator is not a pregnancy);
///  two within 60 days are one pregnancy, the due date's start winning.
///  How each ended: a child born inside its window -> birth; the recorded loss
///  inside it -> loss; the latest with nothing -> ongoing while the stage is
///  pregnancy, else ended; an earlier one with nothing -> ended.
List<PregnancyRecord> backfillPregnancies({
  required List<DateTime> confirmedDays,
  DateTime? dueDate,
  String? dueDateSource,
  required LifeStage? stage,
  DateTime? lossAt,
  required List<({String id, DateTime dob})> children,
}) {
  final starts = <({DateTime start, bool fromDue})>[
    for (final d in confirmedDays)
      (start: _day(d).subtract(const Duration(days: 28)), fromDue: false),
    if (dueDate != null &&
        (stage == LifeStage.pregnancy || stage == LifeStage.parenting))
      (start: _day(dueDate).subtract(const Duration(days: 280)), fromDue: true),
  ]..sort((a, b) => a.start.compareTo(b.start));
  final merged = <({DateTime start, bool fromDue})>[];
  for (final s in starts) {
    if (merged.isNotEmpty &&
        s.start.difference(merged.last.start).inDays.abs() < 60) {
      if (s.fromDue) merged[merged.length - 1] = s;
      continue;
    }
    merged.add(s);
  }
  final out = <PregnancyRecord>[];
  for (var i = 0; i < merged.length; i++) {
    final start = merged[i].start;
    final next = i + 1 < merged.length ? merged[i + 1].start : null;
    bool inside(DateTime d) =>
        !_day(d).isBefore(start) && (next == null || _day(d).isBefore(next));
    final r = PregnancyRecord(
      id: PregnancyRecord.idFor(start),
      startedOn: start,
      dueDate: merged[i].fromDue ? _day(dueDate!) : null,
      dueDateSource: merged[i].fromDue ? dueDateSource : null,
    );
    final born = [
      for (final c in children)
        if (inside(c.dob) && c.dob.difference(start).inDays >= 140) c,
    ];
    if (born.isNotEmpty) {
      r
        ..outcome = PregnancyOutcome.birth
        ..endedOn = _day(born.first.dob)
        ..childId = born.first.id;
    } else if (lossAt != null && inside(lossAt)) {
      r
        ..outcome = PregnancyOutcome.loss
        ..endedOn = _day(lossAt);
    } else if (next != null) {
      r.outcome = PregnancyOutcome.ended;
    } else {
      r.outcome = stage == LifeStage.pregnancy
          ? PregnancyOutcome.ongoing
          : PregnancyOutcome.ended;
    }
    out.add(r);
  }
  return out;
}

class PregnancyRecords extends ChangeNotifier {
  PregnancyRecords._();
  static final PregnancyRecords instance = PregnancyRecords._();

  static const _key = 'pregnancy_records_v1';

  final List<PregnancyRecord> _rows = [];

  /// Removed records: kept so the windows stay where they were.
  final List<PregnancyRecord> _removed = [];

  /// Her partner's records, read only (0114's partner read). Used for the
  /// windows only when this phone has none of its own: his phone.
  final List<PregnancyRecord> _partner = [];

  final OwnRowLedger _sync = OwnRowLedger('pregnancies', 'pregnancies_sync');
  bool _loaded = false;
  Future<void>? _loading;

  bool get hasPending => _sync.hasPending;

  // ---- reads -----------------------------------------------------------------

  /// Her pregnancies, oldest first.
  List<PregnancyRecord> get all =>
      List.unmodifiable([..._rows]..sort((a, b) => a.startedOn.compareTo(b.startedOn)));

  List<PregnancyRecord> get _windowSource {
    final own = [..._rows, ..._removed];
    return own.isNotEmpty ? own : [..._partner];
  }

  /// The pregnancy the pregnancy screens show: the latest one, whether or not
  /// it has ended (after a loss she still sees her pregnancy's things until a
  /// new one starts). Null before any.
  PregnancyRecord? get latest {
    final l = all;
    return l.isEmpty ? null : l.last;
  }

  /// The pregnancy going on now, or null.
  PregnancyRecord? get current {
    final l = latest;
    return l != null && l.outcome == PregnancyOutcome.ongoing ? l : null;
  }

  /// "Kept for you": every pregnancy that has ended, newest first.
  List<PregnancyRecord> get kept => [
        for (final r in all.reversed)
          if (r.outcome != PregnancyOutcome.ongoing) r,
      ];

  // ---- how the last one ended (personalisation, STILL-OPEN §61.1) ----------
  //
  // ⚠️ `ended` IS NEVER A LOSS. It means the app was not told how a pregnancy
  // ended (the enum's own rule), so nothing below lifts loss content for it.

  /// The newest pregnancy that has ended, or null.
  PregnancyRecord? get lastEnded {
    final k = kept;
    return k.isEmpty ? null : k.first;
  }

  /// The pregnancy that ended just before the one going on now, or null.
  PregnancyRecord? get beforeCurrent {
    final cur = current;
    if (cur == null) return null;
    final l = all;
    final i = l.indexWhere((r) => r.id == cur.id);
    return i > 0 ? l[i - 1] : null;
  }

  /// Pregnant now, and the pregnancy before this one was a loss. Lifts the
  /// pages written for a pregnancy after a loss; never hides anything.
  bool get pregnantAfterLoss =>
      beforeCurrent?.outcome == PregnancyOutcome.loss;

  /// The pregnancy going on, or the one about to start (the positive test,
  /// before `startNew`), comes after a loss. One answer across that moment,
  /// so a page built before the record and rebuilt after it says the same.
  bool get followsLoss => current != null
      ? pregnantAfterLoss
      : lastEnded?.outcome == PregnancyOutcome.loss;

  /// Not pregnant, the last pregnancy was a loss, and it ended within
  /// [kAfterLossLeadDays]: the TTC home leads with After a loss.
  bool lossRecentlyClosed({DateTime? now}) {
    if (current != null) return false;
    final last = lastEnded;
    if (last == null || last.outcome != PregnancyOutcome.loss) return false;
    final on = last.endedOn;
    if (on == null) return false;
    final days = _day(now ?? DateTime.now()).difference(on).inDays;
    return days >= 0 && days < kAfterLossLeadDays;
  }

  PregnancyWindow windowOf(PregnancyRecord r) =>
      pregnancyWindowOf(r, _windowSource);

  /// The window the pregnancy screens read: the latest pregnancy's (its own,
  /// or on his phone hers). Everything before any pregnancy is recorded.
  PregnancyWindow get currentWindow {
    final src = _windowSource;
    if (src.isEmpty) return PregnancyWindow.all;
    final last = ([...src]..sort((a, b) => a.startedOn.compareTo(b.startedOn))).last;
    return pregnancyWindowOf(last, src);
  }

  /// ⚠️ THE ONE RULE every pregnancy reader asks: does a record dated [d]
  /// belong to the pregnancy on screen?
  bool inCurrent(DateTime d) => currentWindow.holds(d);

  PregnancyRecord? byId(String id) {
    for (final r in _rows) {
      if (r.id == id) return r;
    }
    return null;
  }

  // ---- load and sync --------------------------------------------------------

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final j = jsonDecode(raw);
        if (j is Map) {
          void fill(Object? list, List<PregnancyRecord> into) {
            if (list is! List) return;
            for (final e in list) {
              if (e is! Map) continue;
              final r = PregnancyRecord.fromRow(Map<String, dynamic>.from(e));
              if (r != null) into.add(r);
            }
          }

          fill(j['rows'], _rows);
          fill(j['removed'], _removed);
        }
      }
    } catch (_) {/* start empty */}
    await _sync.load();
    SyncRegistry.registerPending(() => hasPending);
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    _loaded = true;
    notifyListeners();
    await _syncFromCloud();
    if (_rows.isEmpty && _removed.isEmpty && _partner.isEmpty) {
      // What the records are derived from, read first (each is idempotent).
      await Future.wait([
        FamilyTimeline.instance.ready,
        LifeStageStore.instance.ready,
        ChildProfileStore.instance.init(),
        PregnancyEndedStore.instance.load(),
      ].map((f) => f.catchError((_) {})));
      await backfill();
    }
  }

  void _resetLocal() {
    _rows.clear();
    _removed.clear();
    _partner.clear();
    _sync
      ..clear()
      ..save();
    _loading = null;
    _loaded = false;
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> _live() =>
      {for (final r in _rows) r.id: r.toRow()};

  Future<void> _pushWaiting() => _sync.push(_live);

  Future<void> _syncFromCloud() async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final taken =
          await _sync.pull(liveKeys: _rows.map((r) => r.id), orderBy: 'started_on');
      for (final row in taken) {
        final id = row['id'] as String;
        _rows.removeWhere((r) => r.id == id);
        final r = PregnancyRecord.fromRow(row);
        if (r == null) continue;
        if (syncParseStamp(row['removed_at']) != null) {
          _removed
            ..removeWhere((x) => x.id == id)
            ..add(r);
        } else {
          _rows.add(r);
        }
      }
      _partner.clear();
      final partnerId = await SupabaseRepo.myPartnerId();
      if (partnerId != null) {
        for (final row in await SupabaseRepo.fetchByUser('pregnancies', partnerId)) {
          final r = PregnancyRecord.fromRow(row);
          if (r != null) _partner.add(r);
        }
      }
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline: keep local */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key,
          jsonEncode({
            'rows': [for (final r in _rows) r.toRow()],
            'removed': [for (final r in _removed) r.toRow()],
          }));
    } catch (_) {}
  }

  Future<void> _changed(PregnancyRecord r) async {
    _sync.touch(r.id);
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  /// The records this install already implies (see [backfillPregnancies]).
  /// Runs once, when there are none; also before any move, so a phone that
  /// has never loaded still starts from the right place.
  Future<void> backfill() async {
    if (_rows.isNotEmpty || _removed.isNotEmpty || _partner.isNotEmpty) return;
    final ctrl = PregnancyController.current;
    final ended = PregnancyEndedStore.instance;
    final made = backfillPregnancies(
      confirmedDays: [
        for (final e in FamilyTimeline.instance.events)
          if (e.id == 'pregnancy_started' || e.id.startsWith('pregnancy_started:')) e.date,
      ],
      dueDate: ctrl != null && ctrl.isDueDateSet ? ctrl.dueDate : null,
      dueDateSource: ctrl?.dueDateSource.name,
      stage: LifeStageStore.instance.stage,
      lossAt: ended.lossRecorded ? ended.endedAt : null,
      children: [
        for (final c in ChildProfileStore.instance.children) (id: c.id, dob: c.dob),
      ],
    );
    if (made.isEmpty) return;
    _rows.addAll(made);
    for (final r in made) {
      _sync.touch(r.id);
    }
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  Future<void> _ready() async {
    if (!_loaded) await load();
    await backfill();
  }

  // ---- the moves ------------------------------------------------------------

  /// A new pregnancy (the positive test; later "Add a pregnancy"). The one
  /// before it is SEALED first: its undated records are copied into its
  /// archive and the live stores start clean (pregnancy_archive.dart).
  /// Confirming the same pregnancy again only re-dates it.
  Future<PregnancyRecord> startNew({
    required DateTime due,
    String? dueDateSource,
    DateTime? today,
  }) async {
    await _ready();
    var start = _day(due).subtract(const Duration(days: 280));
    final cur = current;
    if (cur != null && start.difference(cur.startedOn).inDays.abs() < 60) {
      cur
        ..dueDate = _day(due)
        ..dueDateSource = dueDateSource ?? cur.dueDateSource;
      await _changed(cur);
      return cur;
    }
    final prev = latest;
    if (prev != null) {
      if (prev.outcome == PregnancyOutcome.ongoing) {
        prev
          ..outcome = PregnancyOutcome.ended
          ..endedOn = _day(today ?? DateTime.now());
      }
      if (!prev.sealed) prev.archive = await PregnancyArchive.seal();
      await _changed(prev);
      // The new window must start after the old one, or her old records
      // would land in the new pregnancy.
      final floor = (prev.endedOn ?? prev.startedOn).add(const Duration(days: 1));
      if (start.isBefore(floor)) start = floor;
    }
    final r = PregnancyRecord(
      id: PregnancyRecord.idFor(start),
      startedOn: start,
      dueDate: _day(due),
      dueDateSource: dueDateSource,
    );
    _rows.removeWhere((x) => x.id == r.id);
    _rows.add(r);
    await _changed(r);
    return r;
  }

  /// Undo of [startNew] ("the test was wrong"): the new record goes, and the
  /// one before gets its things back.
  Future<void> undoStart(PregnancyRecord made) async {
    _rows.removeWhere((r) => r.id == made.id);
    _sync.remove(made.id, made.toRow());
    final prev = latest;
    if (prev != null && prev.sealed) {
      await PregnancyArchive.restore(prev.archive);
      prev.archive = {};
      if (prev.outcome == PregnancyOutcome.ended) {
        prev
          ..outcome = PregnancyOutcome.ongoing
          ..endedOn = null;
      }
      _sync.touch(prev.id);
    }
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  /// Her due date changed (the due-date screens, a re-date, onboarding).
  /// Moves the current pregnancy's dates; never starts one.
  Future<void> dueDateSet(DateTime due, String? source) async {
    await _ready();
    final cur = current;
    if (cur == null) return;
    var start = _day(due).subtract(const Duration(days: 280));
    final before = all.where((r) => r.id != cur.id).toList();
    if (before.isNotEmpty) {
      final floor = (before.last.endedOn ?? before.last.startedOn).add(const Duration(days: 1));
      if (start.isBefore(floor)) start = floor;
    }
    cur
      ..dueDate = _day(due)
      ..dueDateSource = source
      ..startedOn = start;
    await _changed(cur);
  }

  /// The pregnancy ended (a loss, or a birth with [childId]).
  Future<void> end(PregnancyOutcome outcome, {DateTime? on, String? childId}) async {
    await _ready();
    final l = latest;
    // The ongoing one, or one the backfill could only call "ended".
    final cur = current ?? (l?.outcome == PregnancyOutcome.ended ? l : null);
    if (cur == null) return;
    cur
      ..outcome = outcome
      ..endedOn = _day(on ?? DateTime.now())
      ..childId = childId;
    await _changed(cur);
  }

  /// The loss was recorded by mistake: the pregnancy goes on.
  Future<void> undoEnd() async {
    await _ready();
    final l = latest;
    if (l == null || l.outcome != PregnancyOutcome.loss) return;
    l
      ..outcome = PregnancyOutcome.ongoing
      ..endedOn = null;
    await _changed(l);
  }

  /// She deleted [r] (pregnancy_archive.dart removes its records first). The
  /// house soft delete: gone from her phones now, purged after 90 days. It
  /// still bounds the windows, so what is left never slides into a neighbour.
  Future<void> remove(PregnancyRecord r) async {
    _rows.removeWhere((x) => x.id == r.id);
    r.archive = {};
    _removed
      ..removeWhere((x) => x.id == r.id)
      ..add(r);
    _sync.remove(r.id, r.toRow());
    notifyListeners();
    await _persist();
    await _pushWaiting();
  }

  @visibleForTesting
  void debugReset({List<PregnancyRecord> rows = const []}) {
    _rows
      ..clear()
      ..addAll(rows);
    _removed.clear();
    _partner.clear();
    _sync.clear();
    _loaded = true;
    _loading = Future.value();
    notifyListeners();
  }
}
