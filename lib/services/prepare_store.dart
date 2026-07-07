// =============================================================================
//  PrepareStore - local "booked / enrolled / saved" state for the Prepare tab
// -----------------------------------------------------------------------------
//  The Prepare commerce flows are a MOCK for now (no payment gateway). This tiny
//  store remembers, per item id, whether the mother has "booked" it - so a
//  reserved masterclass, a booked consult, or a joined cohort reflects back in
//  the UI and survives an app restart (SharedPreferences). When the real
//  commerce backend lands, this is the seam it plugs into.
//
//  Self-initialising: loads on first access, so no wiring in main.dart is
//  needed. Follows the app's plain ChangeNotifier-singleton store pattern.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrepareStore extends ChangeNotifier {
  PrepareStore._() {
    _load();
  }
  static final PrepareStore instance = PrepareStore._();

  static const String _key = 'prepare_booked_v1';
  final Set<String> _booked = <String>{};
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _booked.addAll(p.getStringList(_key) ?? const <String>[]);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, _booked.toList());
  }

  bool isBooked(String id) => _booked.contains(id);

  Future<void> book(String id) async {
    if (_booked.add(id)) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> cancel(String id) async {
    if (_booked.remove(id)) {
      notifyListeners();
      await _persist();
    }
  }
}
