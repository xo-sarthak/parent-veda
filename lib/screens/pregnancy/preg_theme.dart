// =============================================================================
//  The pregnancy theme — the app theme with the violet taken out (2026-09-30)
// -----------------------------------------------------------------------------
//  Main's "one ParentVeda" rules: one ink #2F2C30 for everything pressable, no
//  violet or plum chrome. Most of the app theme (`AppTheme._build`) was already
//  moved to ink control by control since 2026-09-17; what still reads the brand
//  violet is the COLOUR SCHEME itself, so every Flutter default that asks for
//  `primary` drew violet on a pregnancy screen: the floating action buttons,
//  a selected ChoiceChip, a Switch's track, a Slider, a progress bar, a
//  TextButton's words, the date picker's chosen day.
//
//  ⚠️ WHY HERE, AND WHY ONLY FOR PREGNANCY. Pregnancy's screens are pushed on
//  the root navigator, above any widget a pregnancy shell could wrap them in,
//  so the one place that reaches all of them is the MaterialApp's theme.
//  `main.dart` picks this theme while the stage is pregnancy and the plain app
//  theme otherwise, so trying to conceive (which sets its colours widget by
//  widget) and parenting are exactly as they were. The scheme swap is the whole
//  of it: every component theme in `AppTheme._build` reads the scheme, so each
//  one follows without being restated here.
//
//  The trade-off, named: a theme that changes with the stage is one more thing
//  that depends on `LifeStageStore`. What it buys is that a pregnancy screen
//  written years ago with a default `Switch` is not violet, and nobody has to
//  find and fix each one.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// [base] with the violet swapped for ink: primary and its container, and the
/// few scheme slots Material fills with them.
ThemeData pregThemeFrom(ThemeData base) {
  final s = base.colorScheme.copyWith(
    primary: AppTheme.neutral900, // #2F2C30, the one ink
    onPrimary: Colors.white,
    primaryContainer: AppTheme.neutral100,
    onPrimaryContainer: AppTheme.neutral900,
    inversePrimary: AppTheme.neutral200,
    surfaceTint: Colors.transparent,
    shadow: const Color(0x1A2F2C30),
    scrim: const Color(0x662F2C30),
  );
  return base.copyWith(
    colorScheme: s,
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: s.primary,
      foregroundColor: s.onPrimary,
    ),
    chipTheme: base.chipTheme.copyWith(selectedColor: s.primaryContainer),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: s.primary,
      thumbColor: s.primary,
      overlayColor: s.primary.withValues(alpha: 0.12),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(indicatorColor: s.primaryContainer),
  );
}
