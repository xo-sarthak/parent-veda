// =============================================================================
//  ScanQuestionsStore — which questions she has ticked to take in with her
// -----------------------------------------------------------------------------
//  The smallest store in the app, and it is a store rather than screen state
//  for one reason: the brief calls "What to ask at your next scan" a CHECKLIST,
//  and a checklist that empties itself every time you close it is a page of
//  checkboxes. She ticks two questions on Tuesday, remembers a third on
//  Wednesday, and takes all three in on Thursday.
//
//  ⚠️ LOCAL ONLY, AND DELIBERATELY NOT SYNCED. Every other store in this stage
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
//  ⚠️ IDS, NOT TEXT. The set holds question ids from `kScanQuestions`. Storing
//  the sentence would strand every tick the day a question is reworded — and
//  worse, it would silently keep a tick against text that no longer exists, so
//  the count would be right and the list would be short.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanQuestionsStore extends ChangeNotifier {
  ScanQuestionsStore._();
  static final ScanQuestionsStore instance = ScanQuestionsStore._();

  static const _key = 'scan_questions_ticked';

  final Set<String> _ticked = {};
  bool _loaded = false;

  /// Which question ids are ticked. Unmodifiable — callers ask, they do not
  /// reach in.
  Set<String> get ticked => Set.unmodifiable(_ticked);

  bool isTicked(String id) => _ticked.contains(id);

  int get count => _ticked.length;

  /// ⚠️ IDEMPOTENT, AND IT RETURNS EARLY RATHER THAN RELOADING. Every screen
  /// that shows the checklist calls this in `initState`; without the guard, a
  /// second visit would re-read prefs and notify for no change.
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _ticked.addAll(prefs.getStringList(_key) ?? const []);
    } catch (_) {
      // Start empty. A store that cannot read its cache is a store with no
      // ticks yet, never a crash — local-first is absolute.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (!_ticked.remove(id)) _ticked.add(id);
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    if (_ticked.isEmpty) return;
    _ticked.clear();
    notifyListeners();
    await _save();
  }

  /// ⚠️ NOTIFY FIRST, WRITE AFTER. A checkbox that waits for a disk write
  /// before it moves reads as a laggy app on a budget handset, and there is
  /// nothing to roll back to if the write fails — the tick is already the
  /// truth in memory.
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _ticked.toList());
    } catch (_) {
      // Fire and forget, the same as every cloud write in this repo. The cost
      // is stated honestly: a failed write loses the ticks on next launch, and
      // that is a far smaller cost than a checklist that can throw.
    }
  }
}
