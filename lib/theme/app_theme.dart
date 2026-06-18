// =============================================================================
//  ParentVeda  |  "Nurturing Wisdom" Design System
//  Flutter Material 3 Theme
// -----------------------------------------------------------------------------
//  AESTHETIC BRIEF (read this before styling anything)
//
//  Goal: premium, soothing, trustworthy "baby aesthetic" for new Indian parents.
//  Feel: airy, soft, calm, never loud. Lots of negative space, gentle rounded
//  corners, almost no hard shadows, soft lavender-white surfaces. Color is used
//  sparingly as accent, not as fill. Think calm nursery, not toy store.
//
//  Rules of thumb:
//   - Backgrounds stay light and quiet (soft lavender-white), never pure grey.
//   - Primary purple is for ONE clear action per screen, not for everything.
//   - Coral (secondary) is for warmth / highlights, brown (tertiary) for earthy
//     grounded accents, neutral for text and structure.
//   - Corners: cards 20-24, buttons 16, inputs 16, FABs / pills fully rounded.
//   - Elevation is near-flat. Prefer subtle surface tints over drop shadows.
//   - Generous padding. Comfortable line height. Nothing cramped.
//
//  Requires: google_fonts (pubspec.yaml -> google_fonts: ^6.2.1 or later)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All brand colors and the full Material theme live here.
/// Use `AppTheme.light` (and optionally `AppTheme.dark`) in MaterialApp:
///
///   MaterialApp(
///     theme: AppTheme.light,
///     darkTheme: AppTheme.dark,
///     themeMode: ThemeMode.light,
///   )
class AppTheme {
  AppTheme._();

  // ===========================================================================
  //  1. BRAND COLOR TOKENS  (base hexes straight from the palette board)
  // ===========================================================================

  static const Color primary = Color(0xFF6A30B6); // purple
  static const Color secondary = Color(0xFFFF5A79); // coral / pink
  static const Color tertiary = Color(0xFF7A4600); // earthy brown
  static const Color neutral = Color(0xFF7B757F); // warm grey
  static const Color danger = Color(0xFFD92D20); // red (delete / destructive)

  // ===========================================================================
  //  2. FULL TONAL SHADES  (50 = lightest, 900 = darkest)
  //     Each ramp is anchored on the board's base value at 500.
  //     Use these for hover states, containers, borders, gradients, charts.
  // ===========================================================================

  // ---- Primary (purple) -----------------------------------------------------
  static const Color primary50 = Color(0xFFF3EFF9);
  static const Color primary100 = Color(0xFFE4DAF2);
  static const Color primary200 = Color(0xFFCBB6E5);
  static const Color primary300 = Color(0xFFAD8DD7);
  static const Color primary400 = Color(0xFF8F64C8);
  static const Color primary500 = Color(0xFF6A30B6); // base
  static const Color primary600 = Color(0xFF5D2AA0);
  static const Color primary700 = Color(0xFF502489);
  static const Color primary800 = Color(0xFF401D6D);
  static const Color primary900 = Color(0xFF2D144C);

  // ---- Secondary (coral) ----------------------------------------------------
  static const Color secondary50 = Color(0xFFFFEFF2);
  static const Color secondary100 = Color(0xFFFFDBE2);
  static const Color secondary200 = Color(0xFFFFBDCA);
  static const Color secondary300 = Color(0xFFFF9CAF);
  static const Color secondary400 = Color(0xFFFF7B94);
  static const Color secondary500 = Color(0xFFFF5A79); // base
  static const Color secondary600 = Color(0xFFE04F6A);
  static const Color secondary700 = Color(0xFFBF435B);
  static const Color secondary800 = Color(0xFF993649);
  static const Color secondary900 = Color(0xFF6B2633);

  // ---- Tertiary (brown) -----------------------------------------------------
  static const Color tertiary50 = Color(0xFFF3EFEA);
  static const Color tertiary100 = Color(0xFFE4DACC);
  static const Color tertiary200 = Color(0xFFCCB99E);
  static const Color tertiary300 = Color(0xFFB2946B);
  static const Color tertiary400 = Color(0xFF976F38);
  static const Color tertiary500 = Color(0xFF7A4600); // base
  static const Color tertiary600 = Color(0xFF6B3E00);
  static const Color tertiary700 = Color(0xFF5C3500);
  static const Color tertiary800 = Color(0xFF492A00);
  static const Color tertiary900 = Color(0xFF331D00);

  // ---- Neutral (warm grey, for text + structure) ----------------------------
  static const Color neutral50 = Color(0xFFF4F3F5);
  static const Color neutral100 = Color(0xFFE4E2E5);
  static const Color neutral200 = Color(0xFFCCC9CE);
  static const Color neutral300 = Color(0xFFB2AEB5);
  static const Color neutral400 = Color(0xFF98939B);
  static const Color neutral500 = Color(0xFF7B757F); // base
  static const Color neutral600 = Color(0xFF69636C);
  static const Color neutral700 = Color(0xFF565259);
  static const Color neutral800 = Color(0xFF444046);
  static const Color neutral900 = Color(0xFF2F2C30);

  // ===========================================================================
  //  3. SEMANTIC SURFACES  (the calm lavender-white world the UI sits in)
  // ===========================================================================

  /// App canvas. Soft lavender-white, never pure white, never grey.
  static const Color scaffoldBackground = Color(0xFFFBF9FE);

  /// Cleanest raised surface (cards that need to "pop" off the canvas).
  static const Color surface = Color(0xFFFFFFFF);

  /// Soft tinted container (the lavender panels in the board).
  static const Color surfaceContainer = Color(0xFFF3EEF7);
  static const Color surfaceContainerLow = Color(0xFFFBF9FE);
  static const Color surfaceContainerHigh = Color(0xFFECE5F2);
  static const Color surfaceContainerHighest = Color(0xFFE6DEED);

  static const Color outline = Color(0xFFB2AEB5); // neutral300
  static const Color outlineVariant = Color(0xFFE4E2E5); // neutral100

  // ===========================================================================
  //  4. MATERIAL SWATCHES  (optional, for APIs that still want MaterialColor)
  // ===========================================================================

  static const MaterialColor primarySwatch = MaterialColor(0xFF6A30B6, {
    50: primary50,
    100: primary100,
    200: primary200,
    300: primary300,
    400: primary400,
    500: primary500,
    600: primary600,
    700: primary700,
    800: primary800,
    900: primary900,
  });

  // ===========================================================================
  //  5. COLOR SCHEMES
  // ===========================================================================

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary500,
    onPrimary: Colors.white,
    primaryContainer: primary100,
    onPrimaryContainer: primary900,
    secondary: secondary500,
    onSecondary: Colors.white,
    secondaryContainer: secondary100,
    onSecondaryContainer: secondary900,
    tertiary: tertiary500,
    onTertiary: Colors.white,
    tertiaryContainer: tertiary100,
    onTertiaryContainer: tertiary900,
    error: danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFCE9E7),
    onErrorContainer: Color(0xFF5C1410),
    surface: surface,
    onSurface: neutral900,
    onSurfaceVariant: neutral600,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Color(0x1A2D144C), // soft lavender-tinted shadow, low opacity
    scrim: Color(0x662D144C),
    inverseSurface: neutral900,
    onInverseSurface: neutral50,
    inversePrimary: primary200,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary300,
    onPrimary: primary900,
    primaryContainer: primary700,
    onPrimaryContainer: primary100,
    secondary: secondary300,
    onSecondary: secondary900,
    secondaryContainer: secondary800,
    onSecondaryContainer: secondary100,
    tertiary: tertiary300,
    onTertiary: tertiary900,
    tertiaryContainer: tertiary800,
    onTertiaryContainer: tertiary100,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1A171D),
    onSurface: Color(0xFFE9E2EC),
    onSurfaceVariant: neutral300,
    surfaceContainerLowest: Color(0xFF141117),
    surfaceContainerLow: Color(0xFF1F1B23),
    surfaceContainer: Color(0xFF231F28),
    surfaceContainerHigh: Color(0xFF2D2833),
    surfaceContainerHighest: Color(0xFF38323F),
    outline: neutral600,
    outlineVariant: neutral800,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE9E2EC),
    onInverseSurface: neutral900,
    inversePrimary: primary500,
  );

  // ===========================================================================
  //  6. TYPOGRAPHY
  //
  //  Three-font system:
  //    Fraunces         -> displayLarge / displayMedium / displaySmall
  //                        Use only on hero screens, splash, module intros,
  //                        and big marketing moments. Never in UI widgets.
  //                        Its soft optical-size serif reads "premium + human"
  //                        and gives ParentVeda emotional warmth at large sizes.
  //
  //    Plus Jakarta Sans -> headline* / title*
  //                        All in-app UI titles, section headers, card titles.
  //                        Geometric and friendly without being childish.
  //
  //    Manrope           -> body* / label* / titleMedium / titleSmall
  //                        All body copy, captions, chips, button labels.
  //                        Very legible at small sizes, calm personality.
  // ===========================================================================

  static TextTheme _textTheme(ColorScheme scheme) {
    final Color strong = scheme.onSurface;
    final Color soft = scheme.onSurfaceVariant;

    // Fraunces: soft display serif, warm and editorial
    TextStyle display(double size, FontWeight w, double spacing,
            {double height = 1.08, Color? color}) =>
        GoogleFonts.fraunces(
          fontSize: size,
          fontWeight: w,
          letterSpacing: spacing,
          height: height,
          color: color ?? strong,
        );

    // Plus Jakarta Sans: clean geometric sans for UI titles
    TextStyle head(double size, FontWeight w, double spacing,
            {double height = 1.15, Color? color}) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: w,
          letterSpacing: spacing,
          height: height,
          color: color ?? strong,
        );

    // Manrope: calm, legible sans for body and labels
    TextStyle body(double size, FontWeight w, double spacing,
            {double height = 1.5, Color? color}) =>
        GoogleFonts.manrope(
          fontSize: size,
          fontWeight: w,
          letterSpacing: spacing,
          height: height,
          color: color ?? strong,
        );

    return TextTheme(
      // --- Display (Fraunces): hero moments only ----------------------------
      displayLarge:  display(52, FontWeight.w600, -1.2, height: 1.06),
      displayMedium: display(42, FontWeight.w600, -0.8, height: 1.08),
      displaySmall:  display(34, FontWeight.w500, -0.5, height: 1.1),

      // --- Headlines (Plus Jakarta Sans): in-app section titles ------------
      headlineLarge:  head(28, FontWeight.w700, -0.3),
      headlineMedium: head(24, FontWeight.w600, -0.2),
      headlineSmall:  head(20, FontWeight.w600, -0.1),

      // --- Titles: Jakarta for large, Manrope for smaller ------------------
      titleLarge:  head(18, FontWeight.w600, 0),
      titleMedium: GoogleFonts.manrope(
          fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: strong),
      titleSmall: GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: strong),

      // --- Body (Manrope): all reading content -----------------------------
      bodyLarge:  body(16, FontWeight.w500, 0.1),
      bodyMedium: body(14, FontWeight.w500, 0.1, color: soft),
      bodySmall:  body(12, FontWeight.w500, 0.2, color: soft),

      // --- Labels (Manrope): buttons, chips, captions ----------------------
      labelLarge:  GoogleFonts.manrope(
          fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: strong),
      labelMedium: GoogleFonts.manrope(
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: soft),
      labelSmall:  GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: soft),
    );
  }

  // ===========================================================================
  //  7. SHARED SHAPE / ELEVATION TOKENS
  // ===========================================================================

  static const double _rCard = 22;
  static const double _rButton = 16;
  static const double _rInput = 16;
  static const double _rChip = 40;

  // ===========================================================================
  //  8. THEME BUILDER
  // ===========================================================================

  static ThemeData _build(ColorScheme scheme, Color scaffold) {
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      // Soft lavender splash, never harsh
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),

      // ---- App bar: quiet, flat, surface-colored --------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),

      // ---- Cards: near-flat, soft tinted, generously rounded --------------
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shadowColor: scheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rCard),
        ),
      ),

      // ---- Primary action: filled purple ----------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton),
          ),
        ),
      ),

      // ---- Secondary action: soft outlined --------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: scheme.outline, width: 1.2),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton),
          ),
        ),
      ),

      // ---- Inputs: filled, soft, rounded, calm hints ----------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rInput),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rInput),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
      ),

      // ---- Chips: pill-shaped, soft ---------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelMedium,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rChip),
        ),
      ),

      // ---- FAB: circular, primary -----------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 2,
        highlightElevation: 2,
        shape: const CircleBorder(),
      ),

      // ---- Bottom navigation: pill container, soft active indicator -------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),

      // ---- Sliders / progress: thin, rounded, brand-colored ---------------
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHigh,
        thumbColor: scheme.primary,
        trackHeight: 4,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
        linearMinHeight: 6,
      ),

      // ---- Switch / toggles ------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHigh,
        ),
      ),

      // ---- Dividers, icons, dialogs, sheets --------------------------------
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rCard),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rButton),
        ),
      ),
    );
  }

  // ===========================================================================
  //  9. PUBLIC ENTRY POINTS
  // ===========================================================================

  static ThemeData get light => _build(_lightScheme, scaffoldBackground);
  static ThemeData get dark => _build(_darkScheme, _darkScheme.surfaceContainerLowest);
}
