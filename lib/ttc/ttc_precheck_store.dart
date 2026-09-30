// =============================================================================
//  TtcPrecheckStore — her statuses, her notes, and when she settled each one
// -----------------------------------------------------------------------------
//  Singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences`. The house pattern.
//
//  ⚠️ A LIVING LIST, NOT A ONE-SHOT FORM. §23 of the brief: items carry a
//  status, an optional note, the date it was settled, and whether she has
//  actually discussed it with a doctor. Preparing to conceive runs over months,
//  and a checklist that cannot be reopened is a checklist that gets filled in
//  once and never looked at again.
//
//  ⚠️ `discussedWithDoctor` IS A SEPARATE FLAG FROM `done`, AND THAT IS THE
//  WHOLE POINT OF IT. "I have started folic acid" and "a pharmacist confirmed
//  my dose" are different facts, and the second is the one that matters on a
//  core medical item. Collapsing them into one tick would let the list report
//  a medication review that never happened.
//
//  ⚠️ NO CLOUD SYNC. TTC takes no new tables while its UI is settling —
//  `docs/STILL-OPEN.md` §9.7, the same call attachments, vaccinations and the
//  PCOS checker all made.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ttc_precheck_data.dart';
import 'ttc_precheck_rules.dart';

@immutable
class PrecheckEntry {
  const PrecheckEntry({
    required this.status,
    this.settledOn,
    this.discussedWithDoctor = false,
    this.note,
  });

  final PrecheckStatus status;
  final DateTime? settledOn;
  final bool discussedWithDoctor;
  final String? note;

  PrecheckEntry copyWith({
    PrecheckStatus? status,
    DateTime? settledOn,
    bool? discussedWithDoctor,
    String? note,
  }) =>
      PrecheckEntry(
        status: status ?? this.status,
        settledOn: settledOn ?? this.settledOn,
        discussedWithDoctor: discussedWithDoctor ?? this.discussedWithDoctor,
        note: note ?? this.note,
      );

  String encode() => [
        status.name,
        settledOn?.toIso8601String() ?? '',
        discussedWithDoctor ? '1' : '0',
        (note ?? '').replaceAll('|', '/'),
      ].join('|');

  static PrecheckEntry? decode(String raw) {
    final parts = raw.split('|');
    if (parts.length < 3) return null;
    final st = PrecheckStatus.values.where((s) => s.name == parts[0]);
    if (st.isEmpty) return null;
    return PrecheckEntry(
      status: st.first,
      settledOn: parts[1].isEmpty ? null : DateTime.tryParse(parts[1]),
      discussedWithDoctor: parts[2] == '1',
      note: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
    );
  }
}

class TtcPrecheckStore extends ChangeNotifier {
  TtcPrecheckStore._();
  static final TtcPrecheckStore instance = TtcPrecheckStore._();

  static const _kEntries = 'ttc_precheck_entries';
  static const _kOpened = 'ttc_precheck_opened';

  final Map<String, PrecheckEntry> _entries = {};
  bool _everOpened = false;
  bool _loaded = false;

  bool get everOpened => _everOpened;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    for (final row in p.getStringList(_kEntries) ?? const <String>[]) {
      final i = row.indexOf('::');
      if (i <= 0) continue;
      final e = PrecheckEntry.decode(row.substring(i + 2));
      if (e != null) _entries[row.substring(0, i)] = e;
    }
    _everOpened = p.getBool(_kOpened) ?? false;
    notifyListeners();
  }

  Future<void> markOpened() async {
    if (_everOpened) return;
    _everOpened = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOpened, true);
  }

  PrecheckEntry? entryFor(String id) => _entries[id];

  /// Her status for an item, or what the app can honestly derive.
  ///
  /// ⚠️ HER ANSWER ALWAYS WINS OVER THE DERIVED ONE. If she has said anything
  /// at all about an item, that stands — even where the app's own data
  /// disagrees. Same rule as the truth hierarchy the rest of the stage follows:
  /// her own observation sits above ParentVeda's calculation.
  PrecheckStatus statusOf(String id, PrecheckContext c) {
    final mine = _entries[id];
    if (mine != null) return mine.status;
    final item = precheckItemById(id);
    // Kept for revert (2026-09-29):
    // if (item != null && precheckAutoDone(item, c)) return PrecheckStatus.done;
    // ⚠️ AND WHAT HER OWN RECORDS SETTLE (launch sanity D12): folic acid on
    // her supplement list, her live vaccines settled. See
    // `precheckDerivedDone` for why this is not auto-completion.
    if (item != null &&
        (precheckAutoDone(item, c) || precheckDerivedDone(item, c))) {
      return PrecheckStatus.done;
    }
    return PrecheckStatus.untouched;
  }

  /// Puts an item back exactly as it was, for Undo (2026-09-29).
  ///
  /// ⚠️ NULL MEANS "SHE HAD NEVER ANSWERED", WHICH IS NOT `untouched`. A tick
  /// the app derived from her records is taken off by storing her answer
  /// (`untouched`); undoing that must remove the answer, so the derived tick
  /// comes back, rather than store a second answer on top of it.
  Future<void> restore(String id, PrecheckEntry? entry) async {
    if (entry == null) {
      _entries.remove(id);
    } else {
      _entries[id] = entry;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setStatus(String id, PrecheckStatus status) async {
    final existing = _entries[id];
    _entries[id] = PrecheckEntry(
      status: status,
      settledOn: status == PrecheckStatus.untouched ? null : DateTime.now(),
      // ⚠️ A DOCTOR-DISCUSSED FLAG SURVIVES A STATUS CHANGE. She may move an
      // item back to "need to do" after a conversation that raised something
      // new; the conversation still happened.
      discussedWithDoctor: existing?.discussedWithDoctor ?? false,
      note: existing?.note,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> setDiscussed(String id, bool value) async {
    final existing = _entries[id] ??
        const PrecheckEntry(status: PrecheckStatus.untouched);
    _entries[id] = existing.copyWith(
      discussedWithDoctor: value,
      settledOn: existing.settledOn ?? DateTime.now(),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> setNote(String id, String? note) async {
    final existing = _entries[id] ??
        const PrecheckEntry(status: PrecheckStatus.untouched);
    _entries[id] = existing.copyWith(note: note);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kEntries,
        [for (final e in _entries.entries) '${e.key}::${e.value.encode()}']);
  }

  // ---------------------------------------------------------------------------
  //  Counts — of HER LIST, never of her
  // ---------------------------------------------------------------------------

  /// ⚠️ THE DENOMINATOR IS WHAT SHE IS TRACKING, NOT THE WHOLE CATALOGUE.
  ///
  /// §17: "8 of 12 items you've chosen to track are complete", never "82%
  /// ready". Items she has marked not-relevant leave the denominator entirely,
  /// so opting out of a section cannot make her look incomplete.
  ({int done, int open, int notSure, int tracking}) counts(PrecheckContext c) {
    var done = 0, open = 0, notSure = 0, tracking = 0;
    // Visible items only (2026-09-29). Kept for revert: kPrecheckItems.
    for (final item in kPrecheckVisibleItems) {
      final s = statusOf(item.id, c);
      if (s == PrecheckStatus.notRelevant) continue;
      tracking++;
      switch (s) {
        case PrecheckStatus.done:
          done++;
        case PrecheckStatus.needsAttention:
          open++;
        case PrecheckStatus.notSure:
          notSure++;
          open++;
        case PrecheckStatus.untouched:
        case PrecheckStatus.notRelevant:
          break;
      }
    }
    return (done: done, open: open, notSure: notSure, tracking: tracking);
  }

  List<PrecheckPriority> priorities(PrecheckContext c) =>
      precheckPriorities(c, (id) => statusOf(id, c));

  /// Items she has flagged or left unsure — the "worth checking" list.
  List<PrecheckItem> openItems(PrecheckContext c) => [
        // Visible items only (2026-09-29). Kept for revert: kPrecheckItems.
        for (final i in kPrecheckVisibleItems)
          if (statusOf(i.id, c).isOpen) i,
      ];

  /// Items settled as done, in the order they appear.
  List<PrecheckItem> doneItems(PrecheckContext c) => [
        // Visible items only (2026-09-29). Kept for revert: kPrecheckItems.
        for (final i in kPrecheckVisibleItems)
          if (statusOf(i.id, c) == PrecheckStatus.done) i,
      ];

  /// Forgets what is in memory and reads it back from the phone, as a fresh
  /// launch would. Tests only (2026-09-29): "state persists across a reload"
  /// has to be proven against storage, not against the singleton's memory.
  @visibleForTesting
  Future<void> reloadForTest() async {
    _entries.clear();
    _everOpened = false;
    _loaded = false;
    await load();
  }

  Future<void> reset() async {
    _entries.clear();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kEntries);
  }
}
