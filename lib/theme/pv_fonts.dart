// =============================================================================
//  PvType - the language-aware type system
// -----------------------------------------------------------------------------
//  ParentVeda's three Latin fonts (Fraunces, Plus Jakarta Sans, Manrope) carry
//  NO Devanagari glyphs. Rendering Hindi in them silently falls back to whatever
//  the platform ships - a different face on Android and iOS - which throws away
//  the brand's typography exactly where it matters most.
//
//  So Hindi gets its own pairing, chosen to sit as close as possible to the
//  role each Latin font plays:
//
//    Fraunces          -> Noto Serif Devanagari
//        Fraunces is the warm editorial SERIF used for hero moments only. Noto
//        Serif Devanagari is the closest serif with a full weight range
//        (100-900) - Tiro Devanagari Hindi is warmer still, but ships Regular
//        only, so w500/w600 display styles would be synthetically emboldened
//        and look mushy at 52px.
//
//    Plus Jakarta Sans -> Mukta
//    Manrope           -> Mukta
//        Both Latin faces are geometric/humanist sans used for UI and body.
//        Mukta is the standard geometric Devanagari UI face, weights 200-800,
//        and stays legible at 11px label sizes. One family covers both roles:
//        Devanagari pairing is far less developed than Latin, and two sans
//        families that close together read as a mistake rather than a system.
//
//  BOTH Devanagari families also carry Latin glyphs, which matters because the
//  content is code-mixed ("आपका anomaly scan इस हफ्ते"). Keeping one family for
//  the whole string renders that sentence in a single consistent face instead
//  of visibly switching typeface mid-line.
//
//  ---------------------------------------------------------------------------
//  TWO METRIC CORRECTIONS ARE NOT OPTIONAL
//
//  1. LINE HEIGHT. Devanagari hangs matras ABOVE the shirorekha and vowel signs
//     BELOW the baseline, so it needs a taller line box than Latin. The Latin
//     display styles run as tight as height: 1.06 - at 52px that CLIPS the
//     matras outright. Hindi styles are relaxed to ~1.35 and up.
//
//  2. LETTER SPACING. Every Latin display/headline style uses NEGATIVE tracking
//     (down to -1.2). Devanagari is a connected script: negative tracking pulls
//     conjuncts into each other and turns ligatures to mush. All negative
//     spacing is clamped to 0 for Hindi.
//
//  Anything that renders Hindi must go through here rather than calling
//  GoogleFonts directly, or it silently loses both corrections.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';

/// The active language, mirrored here so inline call sites can pick a font
/// without threading [AppLanguage] through every widget constructor.
///
/// Kept in sync from the app root whenever the language changes. It is a
/// display concern only - never read this to decide CONTENT; content always
/// comes from `LocalizedText.of(lang)` / `S(lang)` with an explicit language.
class PvType {
  PvType._();

  static AppLanguage _lang = AppLanguage.english;

  static AppLanguage get lang => _lang;

  /// Called from the app root when the language toggle flips.
  static void setLanguage(AppLanguage l) => _lang = l;

  static bool get _hi => _lang.isHindi;
}

// ---------------------------------------------------------------------------
//  Metric correction
// ---------------------------------------------------------------------------

/// Devanagari needs a taller line box than Latin at the same size. Scales the
/// Latin height up, with a floor so the tightest display styles cannot clip.
double _hiHeight(double latin, {double floor = 1.35}) {
  final scaled = latin * 1.25;
  return scaled < floor ? floor : scaled;
}

/// Negative tracking merges Devanagari conjuncts - clamp it away.
double _hiSpacing(double latin) => latin < 0 ? 0 : latin;

// ---------------------------------------------------------------------------
//  The three roles
// ---------------------------------------------------------------------------

/// Hero display type. Fraunces in English, Noto Serif Devanagari in Hindi.
TextStyle pvDisplayStyle({
  required double size,
  FontWeight weight = FontWeight.w600,
  double letterSpacing = 0,
  double height = 1.08,
  Color? color,
  AppLanguage? lang,
}) {
  final hi = (lang ?? PvType.lang).isHindi;
  return hi
      ? GoogleFonts.notoSerifDevanagari(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: _hiSpacing(letterSpacing),
          height: _hiHeight(height),
          color: color,
        )
      : GoogleFonts.fraunces(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
        );
}

/// UI titles and section headers. Plus Jakarta Sans in English, Mukta in Hindi.
TextStyle pvHeadStyle({
  required double size,
  FontWeight weight = FontWeight.w600,
  double letterSpacing = 0,
  double height = 1.15,
  Color? color,
  AppLanguage? lang,
}) {
  final hi = (lang ?? PvType.lang).isHindi;
  return hi
      ? GoogleFonts.mukta(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: _hiSpacing(letterSpacing),
          height: _hiHeight(height, floor: 1.4),
          color: color,
        )
      : GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
        );
}

/// Body copy, labels, chips, buttons. Manrope in English, Mukta in Hindi.
TextStyle pvBodyStyle({
  required double size,
  FontWeight weight = FontWeight.w500,
  double letterSpacing = 0,
  double height = 1.5,
  Color? color,
  AppLanguage? lang,
}) {
  final hi = (lang ?? PvType.lang).isHindi;
  return hi
      ? GoogleFonts.mukta(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: _hiSpacing(letterSpacing),
          height: _hiHeight(height, floor: 1.55),
          color: color,
        )
      : GoogleFonts.manrope(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
        );
}

// ---------------------------------------------------------------------------
//  Drop-in replacements for the inline GoogleFonts.* call sites
// ---------------------------------------------------------------------------
//  ~1,200 widgets style themselves inline rather than reading the text theme,
//  so fixing ThemeData alone would leave most of the app rendering Hindi in a
//  platform fallback. These mirror the GoogleFonts signature closely enough to
//  be a mechanical swap:
//
//      GoogleFonts.manrope(fontSize: 14, ...)  ->  pvManrope(fontSize: 14, ...)
//
//  They take the language from [PvType.lang], so no call site needs to thread
//  it through.
// ---------------------------------------------------------------------------

/// Replaces `GoogleFonts.fraunces(...)`.
TextStyle pvFraunces({
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
  Color? color,
  TextDecoration? decoration,
  List<Shadow>? shadows,
}) =>
    PvType._hi
        ? GoogleFonts.notoSerifDevanagari(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing:
                letterSpacing == null ? null : _hiSpacing(letterSpacing),
            height: height == null ? null : _hiHeight(height),
            color: color,
            decoration: decoration,
            shadows: shadows,
          )
        : GoogleFonts.fraunces(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            height: height,
            color: color,
            decoration: decoration,
            shadows: shadows,
          );

/// Replaces `GoogleFonts.plusJakartaSans(...)`.
TextStyle pvJakarta({
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
  Color? color,
  TextDecoration? decoration,
  List<Shadow>? shadows,
}) =>
    PvType._hi
        ? GoogleFonts.mukta(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing:
                letterSpacing == null ? null : _hiSpacing(letterSpacing),
            height: height == null ? null : _hiHeight(height, floor: 1.4),
            color: color,
            decoration: decoration,
            shadows: shadows,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            height: height,
            color: color,
            decoration: decoration,
            shadows: shadows,
          );

/// Replaces `GoogleFonts.manrope(...)`.
TextStyle pvManrope({
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
  Color? color,
  TextDecoration? decoration,
  List<Shadow>? shadows,
}) =>
    PvType._hi
        ? GoogleFonts.mukta(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing:
                letterSpacing == null ? null : _hiSpacing(letterSpacing),
            height: height == null ? null : _hiHeight(height, floor: 1.55),
            color: color,
            decoration: decoration,
            shadows: shadows,
          )
        : GoogleFonts.manrope(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            height: height,
            color: color,
            decoration: decoration,
            shadows: shadows,
          );
