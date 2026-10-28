// =============================================================================
//  PvChecklistStore — which questions she has ticked to take in with her
// -----------------------------------------------------------------------------
//  The smallest store in the app, and it is a store rather than screen state
//  for one reason: the brief calls "What to ask at your next scan" a CHECKLIST,
//  and a checklist that empties itself every time you close it is a page of
//  checkboxes. She ticks two questions on Tuesday, remembers a third on
//  Wednesday, and takes all three in on Thursday.
//
//  ⚠️ SUPERSEDED (P1 D8, 2026-10-28): the ticks sync since step 13 (see the
//  note above the class). The reasoning below is kept as history; the
//  decision that replaced it is that a sign-out or a new phone must not empty
//  her list. Backup is the house norm; consent (PpUseConsent) governs USING
//  her data elsewhere, and nothing reads these ticks but this screen.
//
//  (was) LOCAL ONLY, AND DELIBERATELY NOT SYNCED. Every other store in this stage
//  registers with `SyncRegistry` and writes to Supabase. This one does not, and
//  the reasoning is worth stating because the next person will assume it was an
//  omission:
//
//    · **It is a scratchpad, not a record.** What she is nervous enough to ask
//      about is a more sensitive signal than most of what this app stores, and
//      it has no clinical value to anyone later. The cheapest way to keep it
//      private is for it never to leave the phone.
//    · **There is nothing to merge.** A tick list for one appointment has no
//      second device and no partner view — the co-parenting shapes in
//      `docs/BACKEND-PATTERNS.md` all exist to reconcile two people writing the
//      same row, and nobody else writes this one.
//
//  If it is ever synced, that is a decision about privacy first and plumbing
//  second. See CLAUDE.md: usage analytics in this app records which room, never
//  what was in it, and this is the same instinct one layer down.
//
//  ⚠️ IDS, NOT TEXT. The set holds `PvChecklistItem.id`s. Storing
//  the sentence would strand every tick the day a question is reworded — and
//  worse, it would silently keep a tick against text that no longer exists, so
//  the count would be right and the list would be short.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/cloud_merged_store.dart';
// import 'remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). The ticks lived only on
// this phone, so a sign-out or a new phone emptied every checklist. Each tick
// is now one item (`<list>|<id>`) in a per-item merged store
// (cloud_merged_store.dart): two phones ticking different questions both keep
// theirs, and an untick travels.
class PvChecklistStore extends ChangeNotifier with CloudMergedStore {
  PvChecklistStore._();
  // Kept for revert (step 13): the reset now comes from the mixin.
  //   PvChecklistStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final PvChecklistStore instance = PvChecklistStore._();

  /// ⚠️ ONE KEY PER CHECKLIST, AND THE SCANS ONE KEEPS ITS ORIGINAL STRING.
  /// `scan_questions_ticked` already shipped; changing it would silently empty
  /// the list of anybody who had started one, and an emptied checklist looks
  /// exactly like a checklist never used.
  static String _keyFor(String id) =>
      id == 'scan_questions' ? 'scan_questions_ticked' : 'checklist_${id}_ticked';

  /// Ticked ids, per checklist.
  final Map<String, Set<String>> _ticked = {};
  final Set<String> _loaded = {};

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   void _resetForAccount() {
  //     _ticked.clear();
  //     _loaded.clear();
  //     notifyListeners();
  //   }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'pv_checklists';

  @override
  Map<String, Object?> cloudItems() => {
        for (final e in _ticked.entries)
          for (final id in e.value) '${e.key}|$id': true,
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _ticked.clear();
    for (final k in items.keys) {
      final bar = k.indexOf('|');
      if (bar <= 0) continue;
      _ticked
          .putIfAbsent(k.substring(0, bar), () => <String>{})
          .add(k.substring(bar + 1));
    }
    // Every list is now known from the cloud: nothing left to read from prefs.
    _loaded.addAll(_ticked.keys);
  }

  @override
  Future<void> persistLocalCache() async {
    for (final list in {..._ticked.keys, ..._everSeen}) {
      await _save(list);
    }
  }

  /// Lists that held ticks at some point, so a list the cloud emptied is
  /// written back empty rather than left holding its old ticks on disk.
  final Set<String> _everSeen = {};

  bool _allLoaded = false;

  /// Reads every checklist this phone holds, then joins the cloud. A list's
  /// ticks must all be known before the first merge, or a list not yet opened
  /// would read as "unticked everything".
  Future<void> _loadAll() async {
    if (_allLoaded) return;
    _allLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys()) {
        String? list;
        if (key == 'scan_questions_ticked') {
          list = 'scan_questions';
        } else if (key.startsWith('checklist_') && key.endsWith('_ticked')) {
          list = key.substring(10, key.length - 7);
        }
        if (list == null || list.isEmpty) continue;
        _ticked
            .putIfAbsent(list, () => <String>{})
            .addAll(prefs.getStringList(key) ?? const []);
        _loaded.add(list);
        _everSeen.add(list);
      }
    } catch (_) {/* start empty */}
    await syncMergedFromCloud();
  }

  /// Which question ids are ticked on [list]. Unmodifiable — callers ask, they
  /// do not reach in.
  Set<String> ticked(String list) =>
      Set.unmodifiable(_ticked[list] ?? const <String>{});

  bool isTicked(String list, String id) =>
      _ticked[list]?.contains(id) ?? false;

  int count(String list) => _ticked[list]?.length ?? 0;

  /// ⚠️ IDEMPOTENT, AND IT RETURNS EARLY RATHER THAN RELOADING. Every screen
  /// that shows the checklist calls this in `initState`; without the guard, a
  /// second visit would re-read prefs and notify for no change.
  Future<void> init(String list) async {
    await _loadAll();
    if (_loaded.contains(list)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _ticked
          .putIfAbsent(list, () => <String>{})
          .addAll(prefs.getStringList(_keyFor(list)) ?? const []);
    } catch (_) {
      // Start empty. A store that cannot read its cache is a store with no
      // ticks yet, never a crash — local-first is absolute.
    }
    _loaded.add(list);
    notifyListeners();
  }

  Future<void> toggle(String list, String id) async {
    final set = _ticked.putIfAbsent(list, () => <String>{});
    if (!set.remove(id)) set.add(id);
    notifyListeners();
    await _save(list);
  }

  /// Moves the ticks of [from] onto [to], once, when [to] has none (P1 D8:
  /// the one-key scan ticks land on the scan she is heading for now). The old
  /// list is emptied, so this never runs twice and the move syncs.
  Future<void> adopt(String from, String to) async {
    final old = _ticked[from];
    if (old == null || old.isEmpty || count(to) > 0 || from == to) return;
    _ticked[to] = {...old};
    old.clear();
    notifyListeners();
    await _save(from);
    await _save(to);
  }

  /// Puts back ticks a Clear all removed (its Undo).
  Future<void> restore(String list, Set<String> ids) async {
    _ticked.putIfAbsent(list, () => <String>{}).addAll(ids);
    notifyListeners();
    await _save(list);
  }

  Future<void> clear(String list) async {
    final set = _ticked[list];
    if (set == null || set.isEmpty) return;
    set.clear();
    notifyListeners();
    await _save(list);
  }

  /// ⚠️ NOTIFY FIRST, WRITE AFTER. A checkbox that waits for a disk write
  /// before it moves reads as a laggy app on a budget handset, and there is
  /// nothing to roll back to if the write fails — the tick is already the
  /// truth in memory.
  Future<void> _save(String list) async {
    _everSeen.add(list);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _keyFor(list), (_ticked[list] ?? const <String>{}).toList());
    } catch (_) {
      // Fire and forget, the same as every cloud write in this repo. The cost
      // is stated honestly: a failed write loses the ticks on next launch, and
      // that is a far smaller cost than a checklist that can throw.
    }
  }
}
