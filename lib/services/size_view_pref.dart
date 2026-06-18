// =============================================================================
//  SizeViewPref
// -----------------------------------------------------------------------------
//  Tiny global preference for the Size Reveal card's Fruit vs Baby view.
//  Persisted in shared_preferences so it survives app restarts.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SizeViewPref {
  SizeViewPref._();

  static const _key = 'size_baby_mode';

  /// false = Fruit (default), true = Baby.
  static final ValueNotifier<bool> babyMode = ValueNotifier<bool>(false);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      babyMode.value = prefs.getBool(_key) ?? false;
    } catch (_) {/* default fruit */}
  }

  static Future<void> set(bool baby) async {
    babyMode.value = baby;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, baby);
    } catch (_) {}
  }
}
