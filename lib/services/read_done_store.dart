// =============================================================================
//  ReadDoneStore — which Daily Reads / Read Next items the mother has finished
// -----------------------------------------------------------------------------
//  A small, satisfying "accomplished" layer: tick a read as done and it sticks.
//  Lazy-loaded (no main.dart wiring) + persisted via shared_preferences.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadDoneStore extends ChangeNotifier {
  ReadDoneStore._();
  static final ReadDoneStore instance = ReadDoneStore._();

  static const _key = 'reads_done';
  final Set<String> _done = {};
  bool _loaded = false;

  /// Load once (call from build — it's a no-op after the first time).
  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _done.addAll(prefs.getStringList(_key) ?? const []);
      notifyListeners();
    } catch (_) {/* start empty */}
  }

  bool isDone(String id) => _done.contains(id);

  void toggle(String id) {
    if (!_done.remove(id)) _done.add(id);
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _done.toList());
    } catch (_) {/* best-effort */}
  }
}
