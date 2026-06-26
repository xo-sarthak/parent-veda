// =============================================================================
//  VideoStore — saved "Watch & Learn" videos
// -----------------------------------------------------------------------------
//  The set of saved video ids (persisted) + when each was saved, so the Saved
//  hub can show newest-first with a date. Video content itself is static
//  (kVideos). "Save for later" syncs the mother's chosen videos across the
//  Today's Video card, Watch & Learn and the Saved hub.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoStore extends ChangeNotifier {
  VideoStore._();
  static final VideoStore instance = VideoStore._();

  static const _key = 'video_saved';
  static const _atKey = 'video_saved_at';
  final Set<String> _saved = {};
  final Map<String, int> _savedAt = {}; // id → saved-at millis
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as List)) {
          _saved.add(e.toString());
        }
      }
      final rawAt = prefs.getString(_atKey);
      if (rawAt != null) {
        final m = jsonDecode(rawAt) as Map;
        m.forEach((k, v) => _savedAt[k.toString()] = (v as num).toInt());
      }
      // Back-fill any legacy saved id missing a timestamp.
      for (final id in _saved) {
        _savedAt.putIfAbsent(id, () => 0);
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  bool isSaved(String id) => _saved.contains(id);
  Set<String> get savedIds => Set.unmodifiable(_saved);
  int savedAt(String id) => _savedAt[id] ?? 0;

  /// Saved ids, most recently saved first.
  List<String> savedIdsRecent() {
    final ids = _saved.toList();
    ids.sort((a, b) => (_savedAt[b] ?? 0).compareTo(_savedAt[a] ?? 0));
    return ids;
  }

  Future<void> toggle(String id) async {
    if (_saved.remove(id)) {
      _savedAt.remove(id);
    } else {
      _saved.add(id);
      _savedAt[id] = DateTime.now().millisecondsSinceEpoch;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_saved.toList()));
      await prefs.setString(_atKey, jsonEncode(_savedAt));
    } catch (_) {/* best-effort */}
  }
}
