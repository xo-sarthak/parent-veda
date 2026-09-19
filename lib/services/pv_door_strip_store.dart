// =============================================================================
//  PvDoorStripStore — which "start here" strips she has dismissed
// -----------------------------------------------------------------------------
//  A door section marked `strip: true` shows a slim strip above the tab's
//  first list until she taps its ✕ once; the heading is the key. Local
//  only (`shared_preferences`): a dismissed hint is the one thing nobody
//  wants synced back.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PvDoorStripStore extends ChangeNotifier {
  PvDoorStripStore._();
  static final PvDoorStripStore instance = PvDoorStripStore._();

  static const _key = 'pv_door_strips_dismissed';
  Set<String> _gone = {};
  bool _loaded = false;

  bool dismissed(String heading) => _gone.contains(heading);

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _gone = (prefs.getStringList(_key) ?? const []).toSet();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> dismiss(String heading) async {
    _gone.add(heading);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _gone.toList());
    } catch (_) {}
  }
}
