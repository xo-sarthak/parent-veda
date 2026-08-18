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
    this.tests = const [],
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

  /// ⚠️ WHICH REPORTS THIS TOPIC CAN APPEAR ON. Many-to-many, on purpose.
  ///
  /// The requirement, verbatim:
  ///
  ///   "Is it possible to add filter, where user can add filter on a particular
  ///    test and we just show topics related to it, then user should be able to
  ///    apply multiple filters, and one topic should be able to be tagged to
  ///    multiple reports."
  ///
  /// The last clause is the design constraint and it rules out the obvious
  /// implementation. A single `test:` field — one topic, one owning report —
  /// would be a tidier model and it would be wrong: **low-lying placenta shows up
  /// on the anomaly scan AND every growth scan after it; anaemia comes off a
  /// blood test AND is what a growth scan is chasing.** A one-owner model forces
  /// a choice between them, and whichever you pick, a mother holding the other
  /// report searches and finds nothing.
  ///
  /// So this is a LIST, and the filter is set-intersection rather than equality.
  /// The cost is real and worth naming: nothing stops a topic being tagged to
  /// every test, which would make the filter useless while still passing every
  /// test that only checks a topic is reachable. `test/report_filter_test.dart`
  /// therefore asserts the tags actually PARTITION — no test's filter returns
  /// everything, and no topic claims more than four.
  ///
  /// ⚠️ THESE ARE IDS FROM `tests_scans_reports_data.dart`, NOT LABELS. Ids get
  /// compared; labels get translated. A tag of 'Anomaly scan' would match nothing
  /// in the Hindi build — the `.en` is identity / `.now` is display rule, in the
  /// shape it usually arrives in.
  final List<String> tests;

  bool get hasWhen => weekFrom != null || weekTo != null;
}
