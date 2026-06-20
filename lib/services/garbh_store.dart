// =============================================================================
//  GarbhStore — persistence for the Garbh Sanskar Journey
// -----------------------------------------------------------------------------
//  Favorites (across all four pillars), a "continue your practice" pointer, and
//  a PURELY REFLECTIVE session tally (listening / reflection / connection /
//  breathing). No streaks, points, badges or leaderboards — by design.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GarbhStore extends ChangeNotifier {
  GarbhStore._();
  static final GarbhStore instance = GarbhStore._();

  static const _favsKey = 'garbh_favs';
  static const _listenKey = 'garbh_listening';
  static const _reflectKey = 'garbh_reflection';
  static const _connectKey = 'garbh_connection';
  static const _breatheKey = 'garbh_breathing';
  static const _lastIdKey = 'garbh_last_id';
  static const _lastTypeKey = 'garbh_last_type';
  static const _lastTitleKey = 'garbh_last_title';

  SharedPreferences? _prefs;
  final Set<String> _favs = {};
  int _listening = 0, _reflection = 0, _connection = 0, _breathing = 0;
  String? _lastId, _lastType, _lastTitle;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favs
      ..clear()
      ..addAll(_prefs?.getStringList(_favsKey) ?? const []);
    _listening = _prefs?.getInt(_listenKey) ?? 0;
    _reflection = _prefs?.getInt(_reflectKey) ?? 0;
    _connection = _prefs?.getInt(_connectKey) ?? 0;
    _breathing = _prefs?.getInt(_breatheKey) ?? 0;
    _lastId = _prefs?.getString(_lastIdKey);
    _lastType = _prefs?.getString(_lastTypeKey);
    _lastTitle = _prefs?.getString(_lastTitleKey);
    notifyListeners();
  }

  // --- favorites ---
  bool isFav(String id) => _favs.contains(id);
  List<String> get favIds => List.unmodifiable(_favs);
  void toggleFav(String id) {
    if (!_favs.remove(id)) _favs.add(id);
    _prefs?.setStringList(_favsKey, _favs.toList());
    notifyListeners();
  }

  // --- reflective tally ---
  int get listening => _listening;
  int get reflection => _reflection;
  int get connection => _connection;
  int get breathing => _breathing;

  void addListening() => _bump(_listenKey, () => _listening++);
  void addReflection() => _bump(_reflectKey, () => _reflection++);
  void addConnection() => _bump(_connectKey, () => _connection++);
  void addBreathing() => _bump(_breatheKey, () => _breathing++);

  void _bump(String key, VoidCallback inc) {
    inc();
    final v = {
      _listenKey: _listening,
      _reflectKey: _reflection,
      _connectKey: _connection,
      _breatheKey: _breathing,
    }[key]!;
    _prefs?.setInt(key, v);
    notifyListeners();
  }

  // --- continue your practice ---
  bool get hasLast => _lastId != null;
  String? get lastId => _lastId;
  String? get lastType => _lastType;
  String? get lastTitle => _lastTitle;
  void setLast({required String type, required String id, required String title}) {
    _lastType = type;
    _lastId = id;
    _lastTitle = title;
    _prefs?.setString(_lastTypeKey, type);
    _prefs?.setString(_lastIdKey, id);
    _prefs?.setString(_lastTitleKey, title);
    notifyListeners();
  }
}
