// =============================================================================
//  TtcReadStore - what she saved, and how far she got
// -----------------------------------------------------------------------------
//  Two facts about reading, and deliberately no more:
//
//    * which insights she saved, and
//    * how far through each one she reached.
//
//  Local only. No `TtcSyncedStore` mixin, no table, no columns — TTC is taking
//  no new schema while the interface is being finalised, and a reading position
//  is the least costly thing in the app to lose. When it does sync, it is a
//  saved/liked-shaped store, which `ttc_sync.dart` notes wants own-row union
//  semantics rather than cloud-wins: a save made offline must not vanish
//  because another device pushed first.
//
//  ---------------------------------------------------------------------------
//  Why progress is stored at all
//
//  Not for a completion metric, and there is deliberately no "3 of 25 read"
//  anywhere. It exists so a piece she abandoned halfway does not restart at the
//  top, and so the library can quietly put "keep reading" above "start
//  something new". Reading is not a streak in this product.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_merged_store.dart';
// import '../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)

// ⚠️ IN THE CLOUD SINCE STEP 13 (2026-10-22, sync log). It was phone-only, so
// a sign-out or a new phone lost her saved insights and her place in each.
// Items: `s|<insight id>` -> true for a save (union-shaped, as the header
// wanted), `p|<insight id>` -> how far she got in thousandths (an int, so the
// value survives the trip through Postgres unchanged). setProgress() still
// does not notify, so a new position rides the store's next notify.
class TtcReadStore extends ChangeNotifier with CloudMergedStore {
  TtcReadStore._() {
    _load();
  }
  // Kept for revert (step 13): the reset now comes from the mixin.
  //   TtcReadStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //     _load();
  //   }
  static final TtcReadStore instance = TtcReadStore._();

  static const _savedKey = 'ttc_read_saved';
  static const _progressKey = 'ttc_read_progress';

  final Set<String> _saved = {};

  /// insightId -> 0.0..1.0, the furthest point reached.
  final Map<String, double> _progress = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  List<String> get saved => List.unmodifiable(_saved);
  bool isSaved(String id) => _saved.contains(id);
  int get savedCount => _saved.length;

  /// 0 when never opened. Never used to gate anything — only to resume.
  double progressOf(String id) => _progress[id] ?? 0;

  /// Started but not finished. What "keep reading" is built from.
  bool isInProgress(String id) {
    final p = progressOf(id);
    return p > 0.03 && p < 0.95;
  }

  void toggleSaved(String id) {
    if (!_saved.remove(id)) _saved.add(id);
    _persist();
    notifyListeners();
  }

  /// Records the furthest point reached, never a retreat.
  ///
  /// Scrolling back up to re-read a paragraph is not losing your place, and a
  /// progress value that fell when she scrolled up would make the bar jitter on
  /// every flick. Only forward movement is recorded.
  void setProgress(String id, double value) {
    final v = value.clamp(0.0, 1.0);
    if (v <= progressOf(id)) return;
    _progress[id] = v;
    _persist();
    // Deliberately NOT notifying: this fires on every scroll frame, and the
    // reader already paints its own bar from local state. Rebuilding the whole
    // listener tree sixty times a second to move a two-pixel bar is how a
    // reading surface starts dropping frames.
  }

  // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  // are wiped, the singleton was not.
  // Loaded once, in the constructor, so `_loaded` stays true: prefs are
  // empty now, and empty sets are what a reload would find.
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   void _resetForAccount() => resetForTest();

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'ttc_reads';

  @override
  Map<String, Object?> cloudItems() => {
        for (final id in _saved) 's|$id': true,
        for (final e in _progress.entries)
          if ((e.value * 1000).round() > 0) 'p|${e.key}': (e.value * 1000).round(),
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    _saved.clear();
    _progress.clear();
    for (final e in items.entries) {
      if (e.key.startsWith('s|')) {
        _saved.add(e.key.substring(2));
      } else if (e.key.startsWith('p|') && e.value is num) {
        _progress[e.key.substring(2)] =
            ((e.value as num) / 1000).clamp(0.0, 1.0).toDouble();
      }
    }
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() => _persist();

  @visibleForTesting
  void resetForTest() {
    _saved.clear();
    _progress.clear();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _saved.addAll(p.getStringList(_savedKey) ?? const []);
      for (final row in p.getStringList(_progressKey) ?? const []) {
        final i = row.lastIndexOf('|');
        if (i <= 0) continue;
        final v = double.tryParse(row.substring(i + 1));
        if (v != null) _progress[row.substring(0, i)] = v;
      }
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
    await syncMergedFromCloud();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_savedKey, _saved.toList());
      await p.setStringList(_progressKey,
          [for (final e in _progress.entries) '${e.key}|${e.value}']);
    } catch (_) {/* best-effort */}
  }
}
