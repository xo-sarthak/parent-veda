// =============================================================================
//  PregSizeSetStore — which comparison set she prefers
// -----------------------------------------------------------------------------
//  Fruit & veg, kitchen or sweets (lib/data/preg_size_sets.dart). One
//  preference, local only, the `V2BlockArtMode` shape: a singleton
//  ChangeNotifier, lazy load, `notifyListeners()`. It is a taste, not a fact
//  about her pregnancy, so it does not sync — a phone she borrows shows the
//  fruit until she taps.
//
//  Read by the home's hero line, the size insight card and the size sheet, so
//  the three always name the same thing.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/preg_size_sets.dart';

class PregSizeSetStore extends ChangeNotifier {
  PregSizeSetStore._() {
    _load();
  }
  static final PregSizeSetStore instance = PregSizeSetStore._();

  static const _key = 'preg_size_set';

  PregSizeSet _set = PregSizeSet.fruit;

  /// Fruit while the toggle is off (`kPregSizeToggle`), whatever was saved.
  PregSizeSet get set => kPregSizeToggle ? _set : PregSizeSet.fruit;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_key);
      final found = PregSizeSet.values.where((s) => s.name == v).firstOrNull;
      if (found != null && found != _set) {
        _set = found;
        notifyListeners();
      }
    } catch (_) {/* the default is fine */}
  }

  Future<void> choose(PregSizeSet s) async {
    if (s == _set) return;
    _set = s;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, s.name);
    } catch (_) {/* stays for this session */}
  }
}
