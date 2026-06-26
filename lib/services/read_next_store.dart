// =============================================================================
//  ReadNextStore — saved / reading / completed states for Read Next
// -----------------------------------------------------------------------------
//  Two clean concepts: a per-item STATUS (reading | completed) for the Read Next
//  chip, and an explicit SAVED/bookmark set with a save-timestamp (so the Saved
//  hub can show newest-first). No gamification — gentle bookkeeping only.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadNextStore extends ChangeNotifier {
  ReadNextStore._();
  static final ReadNextStore instance = ReadNextStore._();

  static const _key = 'readnext_state'; // status: id → 'reading' | 'completed'
  static const _savedKey = 'readnext_saved'; // bookmarks: id → saved-at millis
  SharedPreferences? _prefs;
  final Map<String, String> _status = {};
  final Map<String, int> _saved = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _status.clear();
    _saved.clear();
    // New bookmark map (preferred).
    final rawSaved = _prefs?.getString(_savedKey);
    if (rawSaved != null) {
      try {
        final m = jsonDecode(rawSaved) as Map;
        m.forEach((k, v) => _saved[k.toString()] = (v as num).toInt());
      } catch (_) {/* ignore */}
    }
    // Legacy combined map (id → 'saved' | 'reading' | 'completed') — split it.
    final raw = _prefs?.getString(_key);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map;
        m.forEach((k, v) {
          final key = k.toString();
          final val = v.toString();
          if (val == 'saved') {
            _saved.putIfAbsent(key, () => 0); // legacy bookmark (no timestamp)
          } else {
            _status[key] = val; // reading | completed
          }
        });
      } catch (_) {/* ignore */}
    }
    notifyListeners();
  }

  // --- status (reading / completed) -----------------------------------------
  String? statusOf(String id) => _status[id];
  void setStatus(String id, String status) {
    _status[id] = status;
    _persist();
    notifyListeners();
  }

  void clearStatus(String id) {
    if (_status.remove(id) != null) {
      _persist();
      notifyListeners();
    }
  }

  // --- saved / bookmarks (with timestamps) ----------------------------------
  bool isSaved(String id) => _saved.containsKey(id);
  List<String> get savedIds => _saved.keys.toList();
  bool get hasSaved => _saved.isNotEmpty;
  int savedAt(String id) => _saved[id] ?? 0;

  /// Saved ids, most recently saved first.
  List<String> savedIdsRecent() {
    final ids = _saved.keys.toList();
    ids.sort((a, b) => _saved[b]!.compareTo(_saved[a]!));
    return ids;
  }

  void toggleSave(String id) {
    if (_saved.remove(id) == null) {
      _saved[id] = DateTime.now().millisecondsSinceEpoch;
    }
    _persist();
    notifyListeners();
  }

  void _persist() {
    _prefs?.setString(_key, jsonEncode(_status));
    _prefs?.setString(_savedKey, jsonEncode(_saved));
  }
}
