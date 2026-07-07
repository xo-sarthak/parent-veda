// =============================================================================
//  AppNav - tiny shared tab router
// -----------------------------------------------------------------------------
//  Lets any screen request a MainScaffold tab change (e.g. the Home → Weekly
//  "flow" toggle) without threading callbacks everywhere. MainScaffold listens
//  to this and applies the change. Keeps the Journey pill working as before.
// =============================================================================

import 'package:flutter/foundation.dart';

class AppNav extends ChangeNotifier {
  AppNav._();
  static final AppNav instance = AppNav._();

  static const int todayTab = 0;
  static const int journeyTab = 1;

  int _index = 0;
  int get index => _index;

  void go(int i) {
    if (i < 0) return;
    _index = i;
    notifyListeners();
  }

  void goToday() => go(todayTab);
  void goWeekly() => go(journeyTab);
}
