// =============================================================================
//  SpiritualPrefsStore - per-read Interested / Not-interested preferences
// -----------------------------------------------------------------------------
//  Lets the mother mark individual Spiritual-Reading items as Interested or
//  Not-interested. Interested items are gently floated to the top of a list and
//  Not-interested ones are greyed and sunk to the bottom. Keyed by read TITLE
//  (titles are unique within the tool and are already used as save-keys
//  elsewhere). Persisted via shared_preferences.
//
//  Self-initialising: loads lazily on first construction so it needs no wiring
//  in main.dart. Best-effort persistence (failures keep in-memory state).
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpiritualPrefsStore extends ChangeNotifier {
  SpiritualPrefsStore._() {
    _load();
  }
  static final SpiritualPrefsStore instance = SpiritualPrefsStore._();

  static const _interestedKey = 'spr_interested';
  static const _notInterestedKey = 'spr_not_interested';

  final Set<String> _interested = {};
  final Set<String> _notInterested = {};
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _interested
        ..clear()
        ..addAll(p.getStringList(_interestedKey) ?? const []);
      _notInterested
        ..clear()
        ..addAll(p.getStringList(_notInterestedKey) ?? const []);
    } catch (_) {/* keep defaults */}
    _loaded = true;
    notifyListeners();
  }

  bool isInterested(String key) => _interested.contains(key);
  bool isNotInterested(String key) => _notInterested.contains(key);

  /// Toggle "interested"; clears any "not interested" on the same item.
  void toggleInterested(String key) {
    if (_interested.remove(key)) {
      // was interested → now neutral
    } else {
      _interested.add(key);
      _notInterested.remove(key);
    }
    _persist();
    notifyListeners();
  }

  /// Toggle "not interested"; clears any "interested" on the same item.
  void toggleNotInterested(String key) {
    if (_notInterested.remove(key)) {
      // was not-interested → now neutral
    } else {
      _notInterested.add(key);
      _interested.remove(key);
    }
    _persist();
    notifyListeners();
  }

  /// Sort helper: interested first (0), neutral (1), not-interested last (2).
  int rank(String key) => isInterested(key)
      ? 0
      : isNotInterested(key)
          ? 2
          : 1;

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_interestedKey, _interested.toList());
      await p.setStringList(_notInterestedKey, _notInterested.toList());
    } catch (_) {/* best-effort */}
  }
}
