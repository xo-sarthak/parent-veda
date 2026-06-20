// =============================================================================
//  ReadNextStore — saved / reading / completed states for Read Next
// -----------------------------------------------------------------------------
//  One status per item (saved | reading | completed), persisted. No gamification
//  (no streaks, points or badges) — just gentle bookkeeping of what she has kept
//  and read.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadNextStore extends ChangeNotifier {
  ReadNextStore._();
  static final ReadNextStore instance = ReadNextStore._();

  static const _key = 'readnext_state';
  SharedPreferences? _prefs;
  final Map<String, String> _state = {}; // id → 'saved' | 'reading' | 'completed'

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _state.clear();
    final raw = _prefs?.getString(_key);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map;
        m.forEach((k, v) => _state[k.toString()] = v.toString());
      } catch (_) {/* ignore */}
    }
    notifyListeners();
  }

  String? statusOf(String id) => _state[id];
  bool isSaved(String id) => _state.containsKey(id);
  List<String> get savedIds => _state.keys.toList();
  bool get hasSaved => _state.isNotEmpty;

  void toggleSave(String id) {
    if (_state.remove(id) == null) _state[id] = 'saved';
    _persist();
    notifyListeners();
  }

  void setStatus(String id, String status) {
    _state[id] = status;
    _persist();
    notifyListeners();
  }

  void _persist() => _prefs?.setString(_key, jsonEncode(_state));
}
