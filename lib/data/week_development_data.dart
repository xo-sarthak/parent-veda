// =============================================================================
//  Week development data - baby's body-systems maturity, week by week
// -----------------------------------------------------------------------------
//  Powers the "This week's update" card (the info we send on WhatsApp): a small
//  organ / body-systems breakdown shown as labeled progress bars. For a given
//  week, developmentForWeek(week) returns a deterministic list of
//  (label, status word, progress 0..1) - earlier weeks read less developed,
//  later weeks more.
//
//  IMPORTANT: kept as plain top-level `final` + a function (NOT const). Do NOT
//  wrap this in a const expression that reads `.length` / other runtime
//  properties - that triggers const_eval_property_access. Progress is a pure
//  function of the week, so it is stable across rebuilds (no Random / DateTime).
// =============================================================================

import '../localization/app_language.dart';

/// One body-system row: a label, a short status word, and a 0..1 progress.
class DevelopmentStat {
  const DevelopmentStat({
    required this.label,
    required this.status,
    required this.progress,
  });

  final LocalizedText label;
  final LocalizedText status;

  /// 0..1 maturity for this system at the requested week.
  final double progress;
}

/// A status word that applies while progress is `<= upTo` (buckets are read in
/// ascending order; the last one should use `upTo: 1.0`).
class _Word {
  const _Word(this.upTo, this.en, this.hi);
  final double upTo;
  final String en;
  final String hi;
}

/// An organ / body-system and its developmental curve.
class _Organ {
  const _Organ({
    required this.label,
    required this.onset,
    required this.mature,
    required this.words,
  });

  final LocalizedText label;

  /// Week the system meaningfully starts developing (progress leaves 0).
  final int onset;

  /// Week the system reads as fully developed (progress hits 1.0).
  final int mature;

  final List<_Word> words;
}

/// The eight systems shown on the weekly update, each with its own curve and
/// vocabulary so the words read true to that organ (Heart -> "100%",
/// Hearing -> "Active", Lungs -> "Maturing", ...).
final List<_Organ> _organs = [
  _Organ(
    label: LocalizedText(en: 'Heart', hi: 'दिल'),
    onset: 5,
    mature: 20,
    words: [
      _Word(0.0, 'Forming', 'बनना शुरू'),
      _Word(0.55, 'Beating', 'धड़क रहा है'),
      _Word(0.95, 'Strong', 'मज़बूत'),
      _Word(1.0, '100%', '100%'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Brain', hi: 'दिमाग़'),
    onset: 4,
    mature: 40,
    words: [
      _Word(0.0, 'Forming', 'बनना शुरू'),
      _Word(0.65, 'Still developing', 'अभी विकास जारी'),
      _Word(0.9, 'Maturing', 'लगभग तैयार'),
      _Word(1.0, 'Highly active', 'बहुत सक्रिय'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Lungs', hi: 'फेफड़े'),
    onset: 10,
    mature: 38,
    words: [
      _Word(0.0, 'Not yet', 'अभी नहीं'),
      _Word(0.3, 'Developing', 'विकास जारी'),
      _Word(0.85, 'Maturing', 'लगभग तैयार'),
      _Word(1.0, 'Ready', 'तैयार'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Bones', hi: 'हड्डियाँ'),
    onset: 6,
    mature: 38,
    words: [
      _Word(0.0, 'Cartilage', 'नरम हड्डी'),
      _Word(0.4, 'Hardening', 'सख़्त हो रही'),
      _Word(0.9, 'Strengthening', 'मज़बूत हो रही'),
      _Word(1.0, 'Strong', 'मज़बूत'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Hearing', hi: 'सुनना'),
    onset: 16,
    mature: 26,
    words: [
      _Word(0.0, 'Not yet', 'अभी नहीं'),
      _Word(0.4, 'Forming', 'बनना शुरू'),
      _Word(0.9, 'Active', 'सक्रिय'),
      _Word(1.0, 'Sharp', 'तेज़'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Vision', hi: 'देखना'),
    onset: 16,
    mature: 34,
    words: [
      _Word(0.0, 'Not yet', 'अभी नहीं'),
      _Word(0.55, 'Developing', 'विकास जारी'),
      _Word(0.9, 'Eyes opening', 'आँखें खुल रही हैं'),
      _Word(1.0, 'Focusing', 'नज़र टिक रही'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Muscles', hi: 'मांसपेशियाँ'),
    onset: 7,
    mature: 34,
    words: [
      _Word(0.0, 'Forming', 'बनना शुरू'),
      _Word(0.7, 'Growing', 'बढ़ रही'),
      _Word(0.92, 'Strengthening', 'मज़बूत हो रही'),
      _Word(1.0, 'Strong', 'मज़बूत'),
    ],
  ),
  _Organ(
    label: LocalizedText(en: 'Immune system', hi: 'रोग-प्रतिरोधक तंत्र'),
    onset: 12,
    mature: 40,
    words: [
      _Word(0.0, 'Not yet', 'अभी नहीं'),
      _Word(0.6, 'Developing', 'विकास जारी'),
      _Word(0.9, 'Building', 'बनता जा रहा'),
      _Word(1.0, 'Ready', 'तैयार'),
    ],
  ),
];

/// Linear maturity for a system between its onset and mature weeks.
double _progress(int week, int onset, int mature) {
  if (week <= onset) return 0.0;
  if (week >= mature) return 1.0;
  return (week - onset) / (mature - onset);
}

LocalizedText _pick(List<_Word> words, double p) {
  for (final w in words) {
    if (p <= w.upTo) return LocalizedText(en: w.en, hi: w.hi);
  }
  final last = words.last;
  return LocalizedText(en: last.en, hi: last.hi);
}

/// Body-systems development for [week] (clamped to 1..40). Deterministic.
List<DevelopmentStat> developmentForWeek(int week) {
  final w = week < 1 ? 1 : (week > 40 ? 40 : week);
  return _organs.map((o) {
    final p = _progress(w, o.onset, o.mature);
    return DevelopmentStat(label: o.label, status: _pick(o.words, p), progress: p);
  }).toList();
}
