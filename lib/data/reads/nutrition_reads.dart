// =============================================================================
//  Nutrition — the library, as reads
// -----------------------------------------------------------------------------
//  2026-09-20, the consistency pass. The Nutrition door's leaves were four
//  screens of their own in the old kit — `NutrientDetailScreen`,
//  `StageDetailScreen`, `ConditionDetailScreen`, `FastingScreen` — violet
//  buttons, tinted boxes, text walls. ONE READER: each becomes a `PvRead`
//  and opens in `PvReaderScreen`, the same page Scans' and Complications'
//  reads open in, with a photo band and the base UI. The old screens stay
//  in place for revert; the router no longer reaches them.
//
//  Four adapters, one shape each:
//    nutrient   what it does · everyday foods (as a list) · the tablet
//    stage      focus · what helps · lean on · a sample day
//    condition  summary · guidance · (the Complications page as a next step)
//    fasting    the topic's one body, plus the general "should I / how /
//               when to skip" as read-next — the eight pages owed since
//               STILL-OPEN §35.6, finally
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../nutrition_data.dart';

const String kNutrientReadPrefix = 'nutrient_';
const String kStageReadPrefix = 'dietstage_';
const String kDietConditionReadPrefix = 'dietcond_';
const String kFastingReadPrefix = 'fasting_';
const String kDietQuestionReadPrefix = 'dietq_';

const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _kicker = LocalizedText(en: 'Nutrition', hi: 'Nutrition');
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

const PvCallout _doctorFirst = PvCallout(
  tone: PvCalloutTone.note,
  title: LocalizedText(en: 'Your doctor sets the dose', hi: 'Your doctor sets the dose'),
  body: LocalizedText(
      en: 'Food is yours to choose; tablets and amounts are your doctor\'s to set. If '
          'anything here disagrees with what they said, they are right.',
      hi: 'Food is yours to choose; tablets and amounts are your doctor\'s to set. If '
          'anything here disagrees with what they said, they are right.'),
);

PvRead pvReadFromNutrient(NutrientGuide g) => PvRead(
      id: '$kNutrientReadPrefix${g.id}',
      kicker: _kicker,
      title: g.name,
      teaser: _same('What your body needs'),
      scaleSetter: g.whatItDoes,
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: 104,
      sections: [
        PvReadSection(heading: _same('Everyday foods that give it'), bullets: g.foods),
        PvReadSection(heading: _same('About the tablet'), paragraphs: [g.supplementNote]),
      ],
      whenToSeeSomeone: _doctorFirst,
      faqs: const [],
      readNext: [
        for (final o in kNutrientGuides)
          if (o.id != g.id) '$kNutrientReadPrefix${o.id}',
      ].take(4).toList(),
    );

PvRead pvReadFromStage(TrimesterGuide g) => PvRead(
      id: '$kStageReadPrefix${g.id}',
      kicker: _kicker,
      title: g.label,
      teaser: _same('Food for your stage'),
      scaleSetter: g.focus,
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: 104,
      sections: [
        PvReadSection(heading: _same('What helps'), bullets: g.helps),
        PvReadSection(heading: _same('Lean on'), bullets: g.leanOn),
        PvReadSection(
            heading: _same('A sample day'),
            bullets: [for (final m in g.sampleDay) LocalizedText(en: '${m.meal.en}: ${m.items.en}', hi: '${m.meal.hi}: ${m.items.hi}')]),
      ],
      whenToSeeSomeone: _doctorFirst,
      faqs: const [],
      readNext: [
        for (final o in kTrimesterGuides)
          if (o.id != g.id) '$kStageReadPrefix${o.id}',
      ],
    );

PvRead pvReadFromDietCondition(ConditionGuide g) => PvRead(
      id: '$kDietConditionReadPrefix${g.id}',
      kicker: _kicker,
      title: g.label,
      teaser: _same('Eating for a condition'),
      scaleSetter: g.summary,
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: 104,
      sections: [
        PvReadSection(heading: _same('What to do at the table'), bullets: g.guidance),
      ],
      whenToSeeSomeone: const PvCallout(
        tone: PvCalloutTone.urgent,
        title: LocalizedText(en: 'This is a plan your doctor manages', hi: 'This is a plan your doctor manages'),
        body: LocalizedText(
            en: 'A condition is treated to numbers your doctor sets. Eating well supports that; it never replaces the '
                'medicine, the tests or the visits.',
            hi: 'A condition is treated to numbers your doctor sets. Eating well supports that; it never replaces the '
                'medicine, the tests or the visits.'),
      ),
      faqs: const [],
      nextSteps: [
        if (g.linkId != null)
          PvReadNextStep(
            kind: PvNextKind.read,
            title: _same('The condition itself, in Complications'),
            value: _same('Signs, tests and what your doctor will do — the diet is only the food half.'),
            action: 'condition:${g.linkId}',
          ),
      ],
    );

PvRead pvReadFromFasting(FastingTopic t) {
  final all = [...kFastingByOccasion, ...kFastingGeneral];
  return PvRead(
    id: '$kFastingReadPrefix${t.id}',
    kicker: _kicker,
    title: t.title,
    teaser: _same('Fasting, done safely'),
    // The first sentence sets the scale; the rest is the short version. The
    // whole body in both read as the same paragraph twice (the phone,
    // 2026-09-21).
    scaleSetter: _firstSentence(t.body),
    author: _desk,
    authorRole: _kicker,
    reviewed: false,
    hue: 42,
    sections: [
      if (_rest(t.body) case final rest?) PvReadSection(heading: _same('The short version'), paragraphs: [rest]),
      PvReadSection(
          heading: _same('Whatever the fast, the same three rules'),
          bullets: [
            _same('Fluids do not stop: water, coconut water, buttermilk, unless the fast forbids them — then ask whether the fast is for you this year.'),
            _same('Break it gently: fruit and a little protein before anything fried or sweet.'),
            _same('Stop if you feel faint, dizzy, get a headache, or the baby moves less. A fast is never worth that.'),
          ]),
    ],
    whenToSeeSomeone: const PvCallout(
      tone: PvCalloutTone.urgent,
      title: LocalizedText(en: 'Ask before you fast', hi: 'Ask before you fast'),
      body: LocalizedText(
          en: 'With gestational diabetes, anaemia, twins, a small baby, or any complication, fasting is your doctor\'s '
              'call. Most faiths excuse pregnancy; ask a doctor and, if you wish, a priest or imam.',
          hi: 'With gestational diabetes, anaemia, twins, a small baby, or any complication, fasting is your doctor\'s '
              'call. Most faiths excuse pregnancy; ask a doctor and, if you wish, a priest or imam.'),
    ),
    faqs: const [],
    readNext: [
      for (final o in all)
        if (o.id != t.id) '$kFastingReadPrefix${o.id}',
    ].take(4).toList(),
  );
}

/// Resolve any nutrition read id — for the reader's read-next rail.
PvRead? nutritionReadById(String id) {
  if (id.startsWith(kNutrientReadPrefix)) {
    final g = kNutrientGuides.where((x) => x.id == id.substring(kNutrientReadPrefix.length)).firstOrNull;
    return g == null ? null : pvReadFromNutrient(g);
  }
  if (id.startsWith(kStageReadPrefix)) {
    final g = kTrimesterGuides.where((x) => x.id == id.substring(kStageReadPrefix.length)).firstOrNull;
    return g == null ? null : pvReadFromStage(g);
  }
  if (id.startsWith(kDietConditionReadPrefix)) {
    final g = kConditionGuides.where((x) => x.id == id.substring(kDietConditionReadPrefix.length)).firstOrNull;
    return g == null ? null : pvReadFromDietCondition(g);
  }
  if (id.startsWith(kFastingReadPrefix)) {
    final t = [...kFastingByOccasion, ...kFastingGeneral].where((x) => x.id == id.substring(kFastingReadPrefix.length)).firstOrNull;
    return t == null ? null : pvReadFromFasting(t);
  }
  return null;
}

/// One of the five whole-diet questions ("Which prenatal vitamins?", "Is my
/// normal thali enough?"). They were cards at the foot of `NutrientsScreen`,
/// reached from a tool tile at the end of the nutrients rail — a screen that
/// listed the twelve nutrients again before them (the user, 2026-09-20:
/// "isn't this repetitive?"). Now each is a read of its own, in the same
/// rail as the nutrients, and that screen is unreached.
PvRead pvReadFromDietQuestion(NutritionPracticalCard c) => PvRead(
      id: '$kDietQuestionReadPrefix${c.id}',
      kicker: _kicker,
      title: c.title,
      teaser: _same('The bigger questions'),
      scaleSetter: c.body,
      author: _desk,
      authorRole: _kicker,
      reviewed: false,
      hue: 104,
      sections: const [],
      whenToSeeSomeone: _doctorFirst,
      faqs: const [],
      readNext: const [],
    );

/// The first sentence of a body, as its own text.
LocalizedText _firstSentence(LocalizedText t) {
  String cut(String x) {
    final m = RegExp(r'^(.+?[.!?])(\s|$)').firstMatch(x.trim());
    return m == null ? x.trim() : m.group(1)!;
  }
  return LocalizedText(en: cut(t.en), hi: cut(t.hi));
}

/// Everything after the first sentence, or null when there is nothing.
LocalizedText? _rest(LocalizedText t) {
  String rest(String x) {
    final m = RegExp(r'^(.+?[.!?])(\s|$)').firstMatch(x.trim());
    return m == null ? '' : x.trim().substring(m.end).trim();
  }
  final en = rest(t.en);
  if (en.isEmpty) return null;
  final hi = rest(t.hi);
  return LocalizedText(en: en, hi: hi.isEmpty ? en : hi);
}
