// =============================================================================
//  Onboarding questions — a few, per stage, and every answer gives something back
// -----------------------------------------------------------------------------
//  The Flo teardown's finding (docs/FLO-TEARDOWN.md §3): a long form is
//  tolerable when it is a conversation that answers back; a short form is
//  required when it is an interrogation. Ours is short AND answers back —
//  two or three questions per stage, each with a line she gets the moment
//  she taps, before any Continue.
//
//  WHERE THE ANSWERS GO. Every question writes to `FamilyProfileStore` — the
//  personalisation engine's existing sink (docs/PERSONALIZATION.md) — through
//  the setters it already has, so nothing here invents a new field. A question
//  whose answer nothing in the app reads yet goes through `setOther`, which is
//  recorded but not ranked on; CLAUDE.md's "only add a flag when something
//  concrete reads it" is why those are few.
//
//  THE GIVE-BACK LINES ARE NOT CLINICAL ADVICE. Population facts phrased to
//  reduce pressure (allowed: "most couples conceive within a year") and never
//  a personalised probability, a target, or a diagnosis. `test/
//  ttc_clinical_review_test.dart` scans this file too.
//
//  English only (CLAUDE.md, 2026-08-27).
// =============================================================================

import '../../../services/family_profile.dart';

class ObOption {
  const ObOption(this.id, this.label, this.giveBack);
  final String id;
  final String label;

  /// The line shown the moment this option is chosen.
  final String giveBack;
}

class ObQuestion {
  const ObQuestion({
    required this.id,
    required this.title,
    required this.options,
    this.subtitle,
    this.multi = false,
    this.multiGiveBack,
    required this.apply,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool multi;

  /// For a multi-select, one line once anything is chosen (the per-option
  /// lines are not shown, they would stack).
  final String? multiGiveBack;
  final List<ObOption> options;

  /// Write the chosen option ids to the profile store.
  final void Function(FamilyProfileStore store, Set<String> chosen) apply;
}

/// What each question is CALLED on the "Keep all of this" card (2026-10-01).
///
/// The card used to show only the chosen option's label, so a mother saw
/// "Just starting" or "Yes, mostly" with no hint of what it answered (the
/// user: the answers "look very vague"). One short name per question, kept
/// here beside the questions rather than in the screen so a new question
/// gets its name where it is written. `test/onboarding_flow_test.dart` fails
/// the build if a question has none.
const Map<String, String> kObSummaryLabels = {
  'ttc_duration': 'Trying for',
  'ttc_cycles': 'Your cycles',
  'ttc_folic': 'Folic acid',
  'preg_parity': 'This pregnancy',
  'preg_priorities': 'Most help with',
  'preg_diet': 'How you eat',
  'pp_feeding': 'Feeding',
  'pp_sleep': 'Sleep',
  'pp_priorities': 'Matters most',
  'sk_interests': 'Enjoys',
  'sk_time': 'Time each day',
};

/// The questions for a stage, in order. [childName] personalises the skilling
/// and parenting titles when it is known.
List<ObQuestion> onboardingQuestionsFor(String stageId, {String? childName}) {
  final name = (childName == null || childName.trim().isEmpty)
      ? 'your child'
      : childName.trim();
  switch (stageId) {
    case 'trying':
      return _trying;
    case 'pregnancy':
      return _pregnancy;
    case 'parenting':
      return _parenting(name);
    case 'skilling':
      return _skilling(name);
    default:
      return const [];
  }
}

// ---- Trying to conceive ------------------------------------------------------

final List<ObQuestion> _trying = [
  ObQuestion(
    id: 'ttc_duration',
    title: 'How long have you been trying?',
    subtitle: 'There is no wrong answer — this only sets the tone.',
    options: const [
      ObOption(
        'starting',
        'Just starting',
        'Most couples conceive within a year of trying. The first months are for learning your cycle, not for worrying.',
      ),
      ObOption(
        'months',
        'A few months',
        'A few months is normal. Three months of dates tells you more about your window than any article can.',
      ),
      ObOption(
        'six',
        'Six months or more',
        'Still within the range most couples fall in. If you are over 35, six months is when a doctor is worth a visit — calmly, not urgently.',
      ),
      ObOption(
        'year',
        'Over a year',
        'A year is the point where guidelines suggest a check for both of you. Nothing is wrong with asking; most causes are findable and many are simple.',
      ),
    ],
    apply: (s, c) => s.setOther('ttc_duration', c.join(',')),
  ),
  ObQuestion(
    id: 'ttc_cycles',
    title: 'Are your cycles fairly regular?',
    options: const [
      ObOption(
        'yes',
        'Yes, mostly',
        'Regular usually means 21 to 35 days, give or take a couple. The cycle tool will find your window from your own dates.',
      ),
      ObOption(
        'no',
        'Not really',
        'Irregular cycles are common and often have an ordinary reason. Recording the dates is the single most useful thing to do before a doctor looks.',
      ),
      ObOption(
        'unsure',
        'Not sure',
        'That is fine — nobody is asked to know this. Log the first day of your next period and the app starts working it out with you.',
      ),
    ],
    apply: (s, c) => s.setOther('ttc_cycles', c.join(',')),
  ),
  ObQuestion(
    id: 'ttc_folic',
    title: 'Is anyone taking folic acid yet?',
    subtitle: 'The one supplement every guideline agrees on.',
    options: const [
      ObOption(
        'yes',
        'Yes',
        'Good — 400 micrograms a day is the usual dose, and it matters most in the weeks before a test turns positive.',
      ),
      ObOption(
        'no',
        'Not yet',
        'Worth starting now: 400 micrograms a day. It matters most in the weeks before you would know — which is exactly why it is asked here.',
      ),
    ],
    apply: (s, c) => s.setOther('ttc_folic', c.join(',')),
  ),
];

// ---- Pregnancy -----------------------------------------------------------------

final List<ObQuestion> _pregnancy = [
  ObQuestion(
    id: 'preg_parity',
    title: 'Is this your first pregnancy?',
    options: const [
      ObOption(
        'first',
        'My first',
        'Then every word gets explained before it is used. Nothing here assumes you know what a scan name means.',
      ),
      ObOption(
        'subsequent',
        "I've been pregnant before",
        "Then we skip the basics where you've been here already, and lead with what is different this time.",
      ),
    ],
    apply: (s, c) => s.setParity(
      c.contains('subsequent') ? Parity.subsequent : Parity.first,
    ),
  ),
  ObQuestion(
    id: 'preg_priorities',
    title: 'What would you most like help with?',
    subtitle: 'Pick as many as you like. Your home leads with these.',
    multi: true,
    multiGiveBack:
        'Your home will lead with these — you can change them any time from Profile.',
    options: const [
      ObOption('nutrition', 'Eating well', ''),
      ObOption('sleep', 'Sleeping', ''),
      ObOption('anxiety', 'Worry and mood', ''),
      ObOption('birthPrep', 'Preparing for birth', ''),
      ObOption('fitness', 'Staying active', ''),
      ObOption('babyDevelopment', "How the baby's growing", ''),
      ObOption('symptoms', 'Symptoms, explained', ''),
    ],
    apply: (s, c) {
      for (final p in PregPriority.values) {
        final want = c.contains(p.name);
        if (s.pregPriorities.contains(p) != want) s.togglePregPriority(p);
      }
    },
  ),
  ObQuestion(
    id: 'preg_diet',
    title: 'How do you eat?',
    subtitle: 'Every recipe and food page respects this.',
    options: const [
      ObOption(
        'vegetarian',
        'Vegetarian',
        'Every recipe and food page will be vegetarian — iron and protein sources included, since those are the ones to watch.',
      ),
      ObOption(
        'eggetarian',
        'Eggetarian',
        'Eggs stay in; meat and fish stay out. Fully cooked eggs are one of the easiest proteins in pregnancy.',
      ),
      ObOption(
        'nonVegetarian',
        'Non-vegetarian',
        "Everything is on the table. The food pages will say which fish and how well-cooked, without a lecture.",
      ),
      ObOption(
        'jain',
        'Jain',
        'No root vegetables, no eggs — the recipe set is filtered for it, and the iron pages lean on what fits.',
      ),
      ObOption(
        'vegan',
        'Vegan',
        'Plant-based throughout. B12 is the one thing to plan for; the food pages will keep saying so, gently.',
      ),
    ],
    apply: (s, c) {
      final id = c.isEmpty ? null : c.first;
      s.setDiet(DietPreference.values.where((d) => d.name == id).firstOrNull);
    },
  ),
];

// ---- Parenting -----------------------------------------------------------------

List<ObQuestion> _parenting(String name) => [
  ObQuestion(
    id: 'pp_feeding',
    title: 'How is $name being fed?',
    options: const [
      ObOption(
        'breastfeeding',
        'Breastfeeding',
        'The feeding pages lead with positions, supply and the 30-day journey — and nothing here will push formula at you.',
      ),
      ObOption(
        'formula',
        'Formula',
        'The feeding pages lead with amounts by age, safe preparation and bottle hygiene — and nothing here will guilt you.',
      ),
      ObOption(
        'mixed',
        'Both',
        'Mixed feeding is common and works. The pages cover both without treating one as the fallback.',
      ),
      ObOption(
        'solids',
        'Solids have started',
        'Then first foods, textures and what to hold back on lead the feeding pages.',
      ),
    ],
    apply: (s, c) => s.setFeeding(
      FeedingMethod.values
          .where((f) => f.name == (c.isEmpty ? '' : c.first))
          .firstOrNull,
    ),
  ),
  ObQuestion(
    id: 'pp_sleep',
    title: 'And how is sleep going?',
    options: const [
      ObOption(
        'well',
        'Mostly fine',
        'Good. The sleep pages will stay out of the way and show up when a leap or a regression is due.',
      ),
      ObOption(
        'nightWaking',
        'Waking a lot at night',
        'Night waking is the most common thing parents ask about, and at most ages it is what sleep looks like. The sleep door starts with what is normal for this month.',
      ),
      ObOption(
        'shortNaps',
        'Short naps',
        'Short naps are usual in the early months — nap length grows with age. The sleep door has the rhythm by month.',
      ),
      ObOption(
        'earlyWaking',
        'Waking very early',
        'Early waking usually has a bedtime or a light reason before it has a sleep problem. The sleep door starts there.',
      ),
      ObOption(
        'unsure',
        'Hard to say',
        'That is an honest answer. Log a few nights and the pattern shows itself.',
      ),
    ],
    apply: (s, c) => s.setSleep(
      SleepPattern.values
          .where((p) => p.name == (c.isEmpty ? '' : c.first))
          .firstOrNull,
    ),
  ),
  ObQuestion(
    id: 'pp_priorities',
    title: 'What matters most right now?',
    subtitle: 'Pick as many as you like.',
    multi: true,
    multiGiveBack:
        'Your home leads with these. Change them any time from Profile.',
    options: const [
      ObOption('sleep', 'Sleep', ''),
      ObOption('feeding', 'Feeding', ''),
      ObOption('development', 'Development', ''),
      ObOption('health', 'Health and vaccines', ''),
      ObOption('behaviour', 'Behaviour', ''),
      ObOption('play', 'Play and activities', ''),
      ObOption('milestones', 'Milestones', ''),
    ],
    apply: (s, c) {
      for (final p in Priority.values) {
        final want = c.contains(p.name);
        if (s.priorities.contains(p) != want) s.togglePriority(p);
      }
    },
  ),
];

// ---- Skilling ------------------------------------------------------------------

List<ObQuestion> _skilling(String name) => [
  ObQuestion(
    id: 'sk_interests',
    title: 'What does $name enjoy?',
    subtitle: 'Pick as many as you like.',
    multi: true,
    multiGiveBack:
        'The first activities will start from these — and widen from there.',
    options: const [
      ObOption('stories', 'Stories', ''),
      ObOption('building', 'Building things', ''),
      ObOption('drawing', 'Drawing', ''),
      ObOption('numbers', 'Numbers and puzzles', ''),
      ObOption('talking', 'Talking and questions', ''),
      ObOption('moving', 'Running and moving', ''),
    ],
    apply: (s, c) => s.setOther('sk_interests', (c.toList()..sort()).join(',')),
  ),
  ObQuestion(
    id: 'sk_time',
    title: 'How much time can you give most days?',
    options: const [
      ObOption(
        '10',
        'About 10 minutes',
        'Ten focused minutes is enough — every activity here fits in one.',
      ),
      ObOption(
        '20',
        'About 20 minutes',
        'Twenty minutes fits an activity and the talk around it, which is where most of the learning is.',
      ),
      ObOption(
        'more',
        'More, when we can',
        'Then the longer projects unlock too — and the short ones are still there for the busy days.',
      ),
    ],
    apply: (s, c) => s.setOther('sk_time', c.join(',')),
  ),
];
