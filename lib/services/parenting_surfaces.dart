// =============================================================================
//  Parenting surfaces — what a bracket can point at on the parenting side
// -----------------------------------------------------------------------------
//  ⚠️ WHY THIS IS NOT IN app_structure.dart.
//
//  `app_structure.dart` is pregnancy-shaped and honest about it: its `AppHome`
//  enum is today · prepare · tools · calendar · community · profile, which is
//  the pregnancy tab set. Parenting's tabs are My Child · Brain · Tools ·
//  Community · Products, pushed rather than indexed (`pp_common.dart`
//  `openPpTab`). Forcing parenting ids through `homeFor()` would either answer
//  null for all of them or require inventing a fake pregnancy home for each —
//  and a wrong answer here is worse than no answer, because null is what a
//  bracket reads as "not available in this stage".
//
//  So parenting declares its own list, and the bracket screen asks whichever
//  stage it is showing. See `BracketScreen.labelFor`.
//
//  IDS ARE PREFIXED `pp_` so a parenting surface can never be mistaken for a
//  pregnancy one in a table, a log or a route name. The two stages have screens
//  with the same job and different content — a Tools hub each, a Community each
//  — and an unprefixed 'tools' would be ambiguous in exactly the places
//  ambiguity is expensive.
//
//  NOTHING HERE IS A NEW SCREEN. Every entry names something that already ships;
//  this file only records that it exists and what it is called.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

@immutable
class PpSurface {
  const PpSurface(this.id, this.label);

  /// Stable, never translated, always `pp_`-prefixed.
  final String id;

  final LocalizedText label;
}

const _t = LocalizedText.new;

/// Everything a parenting bracket may point at.
///
/// Grouped by the bracket that needed it, because that is the only reason any
/// of them are listed — this is not an attempt to describe the parenting app,
/// which has roughly forty more screens than appear here.
// `final`, not `const`: `_t` is a constructor tear-off, and Dart will not accept
// one inside a const list. Not worth expanding twenty entries to the long
// LocalizedText(en:, hi:) form for a compile-time constant nobody needs.
final List<PpSurface> kPpSurfaces = [
  // ---- Sleep ---------------------------------------------------------------
  PpSurface('pp_sleep', _t(en: 'Sleep journey', hi: 'नींद का सफ़र')),

  // ---- Feeding -------------------------------------------------------------
  PpSurface('pp_feeding', _t(en: 'Feeding journey', hi: 'दूध और खाने का सफ़र')),
  PpSurface('pp_food', _t(en: 'Food & recipes', hi: 'खाना और रेसिपी')),

  // ---- Health --------------------------------------------------------------
  PpSurface('pp_health', _t(en: 'Health record', hi: 'सेहत का रिकॉर्ड')),
  PpSurface('pp_vaccines', _t(en: 'Vaccinations', hi: 'टीकाकरण')),
  PpSurface('pp_what_changed', _t(en: 'What changed?', hi: 'क्या बदला?')),
  PpSurface('pp_growth', _t(en: 'Growth', hi: 'बढ़त')),

  // ---- Development ---------------------------------------------------------
  PpSurface('pp_development', _t(en: 'Development', hi: 'विकास')),
  PpSurface('pp_milestones', _t(en: 'Milestones', hi: 'पड़ाव')),
  PpSurface('pp_activities', _t(en: "Today's activity", hi: 'आज की गतिविधि')),

  // ---- Learn / watch / read ------------------------------------------------
  PpSurface('pp_read', _t(en: 'Read', hi: 'पढ़िए')),
  PpSurface('pp_watch', _t(en: 'Watch', hi: 'देखिए')),
  PpSurface('pp_courses', _t(en: 'Courses & masterclasses', hi: 'कोर्स और मास्टरक्लास')),

  // ---- Commerce ------------------------------------------------------------
  PpSurface('pp_products', _t(en: 'Products', hi: 'प्रोडक्ट')),
  PpSurface('pp_product_guide', _t(en: 'Buying guides', hi: 'ख़रीदने की गाइड')),
  PpSurface('pp_recos', _t(en: 'Recommendations', hi: 'सुझाव')),

  // ---- People --------------------------------------------------------------
  PpSurface('pp_experts', _t(en: 'Talk to an expert', hi: 'विशेषज्ञ से बात')),
  PpSurface('pp_find_help', _t(en: 'Find help', hi: 'मदद ढूँढिए')),

  // ---- Mother --------------------------------------------------------------
  PpSurface('pp_yoga', _t(en: 'Yoga & recovery', hi: 'योग और रिकवरी')),

  // ---- Tradition -----------------------------------------------------------
  PpSurface('pp_nuskhe', _t(en: 'Dadi–Nani remedies', hi: 'दादी–नानी के नुस्ख़े')),
  PpSurface('pp_names', _t(en: 'Baby names', hi: 'बच्चे के नाम')),
];

/// Null for an unknown id — the same contract `homeFor()` has, and for the same
/// reason: a guess here becomes a row that opens nothing.
LocalizedText? ppSurfaceLabel(String id) {
  for (final s in kPpSurfaces) {
    if (s.id == id) return s.label;
  }
  return null;
}
