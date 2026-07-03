// =============================================================================
//  FatherPreview — TESTING-ONLY mother/father mode switch
// -----------------------------------------------------------------------------
//  A tiny global flag the app reads to preview the Father experience without
//  going through the pairing flow. When [on], MainScaffold swaps the Today tab
//  for the Father Daily screen and the week-20 weekly renders its father-tailored
//  variant; everything else stays the mother app.
//
//  This is a DEV affordance (a small "Mom | Dad" pill on the Today tab) so the
//  team can eyeball both modes quickly. It is NOT part of the final product —
//  in the shipped app, role is fixed at pairing. Strip the pill + these reads
//  before launch (search for FatherPreview).
// =============================================================================

import 'package:flutter/foundation.dart';

class FatherPreview extends ChangeNotifier {
  FatherPreview._();
  static final FatherPreview instance = FatherPreview._();

  bool _on = false;
  bool get on => _on;

  set on(bool value) {
    if (value == _on) return;
    _on = value;
    notifyListeners();
  }

  void toggle() => on = !_on;
}
