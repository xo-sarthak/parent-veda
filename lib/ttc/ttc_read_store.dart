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

class TtcReadStore extends ChangeNotifier {
  TtcReadStore._() {
    _load();
  }
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
