// =============================================================================
//  Pregnancy week page — the extra content per week (2026-09-29)
// -----------------------------------------------------------------------------
//  The pregnancy gap analysis (Flo and What to Expect vs ParentVeda, "Behind ·
//  Week by week", 230 pieces) found the week page, the page she opens every
//  week, saying less than either competitor. Most of what was missing already
//  lives in weekContent.json (symptoms, do and skip, red flags, myth, partner
//  corner) and is drawn by `preg_week_screen.dart`. What had nowhere to live
//  is here:
//
//    · a one-line tip for each of the week's symptoms, and the Symptoms door
//      page it opens when there is one
//    · "Asked this week": two or three questions women search that week
//    · "Where this comes from": the sources behind the week
//    · pages for weeks 1 to 3 and 41 to 42, which weekContent.json does not
//      cover (the week data runs 4 to 40)
//
//  English only (CLAUDE.md, 2026-08-27). Written to docs/PREG-VOICE.md.
//  Split into four part files so the writing could be done in parallel; this
//  file is the model and the one place the screen reads from.
// =============================================================================

import 'preg_week_extras_a.dart';
import 'preg_week_extras_b.dart';
import 'preg_week_extras_c.dart';
import 'preg_week_extras_special.dart';

/// One of the week's symptoms, with a line on what helps.
class PregWeekSymptomTip {
  const PregWeekSymptomTip({
    required this.symptom,
    required this.tip,
    this.symptomId,
  });

  /// The label exactly as `momJourney.commonSymptoms[i].en` in
  /// weekContent.json, so the screen can pair them.
  final String symptom;

  /// One or two short sentences: what helps, or why it happens.
  final String tip;

  /// The Symptoms door page this opens (`symptomById` in
  /// lib/data/symptoms/symptom_library.dart), when one exists.
  final String? symptomId;
}

/// A question women ask that week, answered in two or three sentences.
class PregWeekQuestion {
  const PregWeekQuestion({required this.q, required this.a});
  final String q;
  final String a;
}

/// Everything the week page adds for one week.
class PregWeekExtra {
  const PregWeekExtra({
    required this.week,
    this.symptomTips = const [],
    this.asked = const [],
    this.sources = const [],
  });

  final int week;
  final List<PregWeekSymptomTip> symptomTips;
  final List<PregWeekQuestion> asked;

  /// Keys into [kPregWeekSources].
  final List<String> sources;
}

/// A page for a week that weekContent.json does not cover (1 to 3, 41, 42).
class PregSpecialWeekPage {
  const PregSpecialWeekPage({
    required this.id,
    required this.weeks,
    required this.chipLabel,
    required this.title,
    required this.shortAnswer,
    required this.sections,
    this.callYourDoctor,
    this.asked = const [],
    this.sources = const [],
  });

  /// 'weeks_1_3', 'week_41', 'week_42'.
  final String id;
  final List<int> weeks;

  /// What the week chip says: "1 to 3 weeks", "41 weeks".
  final String chipLabel;
  final String title;
  final String shortAnswer;
  final List<PregWeekSection> sections;
  final String? callYourDoctor;
  final List<PregWeekQuestion> asked;
  final List<String> sources;
}

/// A headed block of prose, bullets or both.
class PregWeekSection {
  const PregWeekSection({
    required this.heading,
    this.paragraphs = const [],
    this.bullets = const [],
  });
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// A source the week pages cite. Real, published guidance only; the list is
/// owed a clinician's check before launch (docs/STILL-OPEN.md).
class PregWeekSource {
  const PregWeekSource(this.label);
  final String label;
}

/// The vetted source list. Week entries cite these by key; no week invents
/// its own reference.
const Map<String, PregWeekSource> kPregWeekSources = {
  'mohfw_anc': PregWeekSource(
      'Ministry of Health and Family Welfare, Government of India. Guidelines '
      'for Antenatal Care and Skilled Attendance at Birth by ANMs, LHVs and '
      'SNs. 2010.'),
  'mohfw_pmsma': PregWeekSource(
      'Ministry of Health and Family Welfare, Government of India. Pradhan '
      'Mantri Surakshit Matritva Abhiyan (PMSMA) operational guidelines. '
      '2016.'),
  'icmr_nin': PregWeekSource(
      'ICMR–National Institute of Nutrition. Dietary Guidelines for Indians. '
      '2024.'),
  'who_anc': PregWeekSource(
      'World Health Organization. WHO recommendations on antenatal care for '
      'a positive pregnancy experience. 2016.'),
  'nice_ng201': PregWeekSource(
      'National Institute for Health and Care Excellence (NICE). Antenatal '
      'care, guideline NG201. 2021.'),
  'acog_month': PregWeekSource(
      'American College of Obstetricians and Gynecologists. Your Pregnancy '
      'and Childbirth: Month to Month. 7th edition. 2021.'),
  'moore_embryology': PregWeekSource(
      'Moore KL, Persaud TVN, Torchia MG. The Developing Human: Clinically '
      'Oriented Embryology. 11th edition. 2019.'),
  'rcog_rfm': PregWeekSource(
      'Royal College of Obstetricians and Gynaecologists. Reduced Fetal '
      'Movements, Green-top Guideline No. 57. 2011.'),
  'nice_ng207': PregWeekSource(
      'National Institute for Health and Care Excellence (NICE). Inducing '
      'labour, guideline NG207. 2021.'),
  'who_intrapartum': PregWeekSource(
      'World Health Organization. WHO recommendations: intrapartum care for '
      'a positive childbirth experience. 2018.'),
};

/// Every week's extras, 4 to 40.
final Map<int, PregWeekExtra> kPregWeekExtras = {
  for (final e in [...kPregWeekExtrasA, ...kPregWeekExtrasB, ...kPregWeekExtrasC])
    e.week: e,
};

/// Weeks 1 to 3, 41 and 42.
List<PregSpecialWeekPage> get kPregSpecialWeekPages => kPregSpecialWeeks;

/// The special page for [week], or null when weekContent.json covers it.
PregSpecialWeekPage? pregSpecialPageFor(int week) {
  for (final p in kPregSpecialWeeks) {
    if (p.weeks.contains(week)) return p;
  }
  return null;
}

/// "Month 5", counted the way Indian doctors and families count: months of
/// about four and a third weeks from the first day of the last period.
int pregMonthFor(int week) {
  if (week <= 4) return 1;
  if (week <= 8) return 2;
  if (week <= 13) return 3;
  if (week <= 17) return 4;
  if (week <= 21) return 5;
  if (week <= 26) return 6;
  if (week <= 30) return 7;
  if (week <= 35) return 8;
  return 9;
}

/// "First trimester" (weeks 1 to 12), "Second" (13 to 27), "Third" (28 on):
/// the NHS and MoHFW boundaries, and the ones weekContent.json is written to
/// (week 13 says "Hello Second Trimester"; week 27 says the third starts next
/// week).
String pregTrimesterFor(int week) {
  if (week <= 12) return 'First trimester';
  if (week <= 27) return 'Second trimester';
  return 'Third trimester';
}
