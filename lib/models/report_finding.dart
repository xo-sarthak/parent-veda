// =============================================================================
//  Understanding Your Report™  - finding model
// -----------------------------------------------------------------------------
//  A calm, reassurance-first explainer for a scan/test finding. NOT a diagnosis,
//  prediction, symptom checker or risk calculator. Every finding uses the EXACT
//  same 7-section structure (consistency builds trust):
//    1 What Does This Mean?   2 How Common Is It?   3 What Usually Happens Next?
//    4 When Is It Usually Discussed?  5 Questions To Ask Your Doctor
//    6 Things To Remember     7 (a fixed ParentVeda reassurance message)
//
//  Section 7 is identical for every article, so it lives in S (mandatory), not
//  here. English-first: content uses LocalizedText (today hi mirrors en).
// =============================================================================

import '../localization/app_language.dart';

class ReportFinding {
  const ReportFinding({
    required this.id,
    required this.name,
    this.altName,
    required this.whatItMeans,
    required this.howCommon,
    required this.whatNext,
    this.weekFrom,
    this.weekTo,
    this.questions = const [],
    this.remember = const [],
    this.aliases = const [],
  });

  /// Slug, e.g. 'low_lying_placenta'.
  final String id;

  /// Display name, e.g. "Low-Lying Placenta".
  final LocalizedText name;

  /// Medical/alternate name shown as a subtitle, e.g. "Placenta Previa". Optional.
  final LocalizedText? altName;

  // The fixed sections (1–3 always present).
  final LocalizedText whatItMeans; // §1
  final LocalizedText howCommon; // §2
  final LocalizedText whatNext; // §3 (the most important)

  /// §4 - "Typically identified around Week [weekFrom]–[weekTo]". Either may be
  /// null (e.g. "from Week 20" or omitted entirely).
  final int? weekFrom;
  final int? weekTo;

  final List<LocalizedText> questions; // §5
  final List<LocalizedText> remember; // §6

  /// Extra search terms (medical synonyms, keyword groups, Hindi words).
  final List<String> aliases;

  bool get hasWhen => weekFrom != null || weekTo != null;
}
