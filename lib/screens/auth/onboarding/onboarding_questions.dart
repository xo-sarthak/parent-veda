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
  'ttc_cycles': 'Your periods',
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
    subtitle: "There's no wrong answer. It just helps us talk to you in the right way.",
    options: const [
      ObOption(
        'starting',
        'Just starting',
        'Most couples get pregnant within a year of trying. The first months are for getting to know your cycle, not for worrying.',
      ),
      ObOption(
        'months',
        'A few months',
        'A few months is normal. Three months of period dates tells you more about your fertile days than any article can.',
      ),
      ObOption(
        'six',
        'Six months or more',
        "This is still normal for many couples. If you're over 35, six months is a good time to see a doctor. It's a calm check, not an emergency.",
      ),
      ObOption(
        'year',
        'Over a year',
        "After a year, doctors suggest a check-up for both of you. It's fine to ask. Most causes can be found, and many are simple.",
      ),
    ],
    apply: (s, c) => s.setOther('ttc_duration', c.join(',')),
  ),
  ObQuestion(
    id: 'ttc_cycles',
    title: 'Are your periods fairly regular?',
    options: const [
      ObOption(
        'yes',
        'Yes, mostly',
        'Regular usually means a period every 21 to 35 days. The app will work out your fertile days from your own dates.',
      ),
      ObOption(
        'no',
        'Not really',
        'Irregular periods are common and often have a simple reason. Writing down the dates is the most useful thing to do before you see a doctor.',
      ),
      ObOption(
        'unsure',
        'Not sure',
        "That's completely fine, lots of people don't. Note the first day of your next period and we'll work it out together.",
      ),
    ],
    apply: (s, c) => s.setOther('ttc_cycles', c.join(',')),
  ),
  ObQuestion(
    id: 'ttc_folic',
    title: 'Is anyone taking folic acid yet?',
    subtitle: 'The one vitamin doctors everywhere agree on.',
    options: const [
      ObOption(
        'yes',
        'Yes',
        'Good. The usual dose is 400 micrograms a day. It matters most in the weeks before a test turns positive.',
      ),
      ObOption(
        'no',
        'Not yet',
        "It's worth starting now, at 400 micrograms a day. It matters most in the early weeks, before you'd even know you're pregnant.",
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
        "Then we'll explain every word as we go. You don't need to know what any scan is called.",
      ),
      ObOption(
        'subsequent',
        "I've been pregnant before",
        "Then we'll skip the basics you already know and start with what's different this time.",
      ),
    ],
    apply: (s, c) => s.setParity(
      c.contains('subsequent') ? Parity.subsequent : Parity.first,
    ),
  ),
  ObQuestion(
    id: 'preg_priorities',
    title: 'What would you most like help with?',
    subtitle: 'Pick as many as you like. Your home will show these first.',
    multi: true,
    multiGiveBack:
        'Your home will show these first. You can change them any time in Profile.',
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
    subtitle: "We'll match every recipe and food page to this.",
    options: const [
      ObOption(
        'vegetarian',
        'Vegetarian',
        'Every recipe and food page will be vegetarian, with good sources of iron and protein, since those need the most care.',
      ),
      ObOption(
        'eggetarian',
        'Eggetarian',
        'Eggs are in; meat and fish are out. Well-cooked eggs are one of the easiest proteins in pregnancy.',
      ),
      ObOption(
        'nonVegetarian',
        'Non-vegetarian',
        "Everything is on the menu. The food pages will tell you which fish to pick and how well to cook things, without a lecture.",
      ),
      ObOption(
        'jain',
        'Jain',
        'No root vegetables and no eggs. The recipes will fit this, and the iron tips will use foods you eat.',
      ),
      ObOption(
        'vegan',
        'Vegan',
        'All plant-based. Vitamin B12 is the one thing to plan for, and the food pages will gently remind you.',
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
        "The feeding pages will start with holds, milk supply and the 30-day guide. We'll never push formula on you.",
      ),
      ObOption(
        'formula',
        'Formula',
        "The feeding pages will start with how much to give by age, how to make it safely and how to keep bottles clean. We'll never make you feel guilty.",
      ),
      ObOption(
        'mixed',
        'Both',
        'Doing both is common, and it works. The pages cover both, and neither is treated as second best.',
      ),
      ObOption(
        'solids',
        'Solids have started',
        'Then the feeding pages will start with first foods, textures and what to wait on for now.',
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
        'Good. The sleep pages will stay quiet, and show up at the ages when sleep often changes.',
      ),
      ObOption(
        'nightWaking',
        'Waking a lot at night',
        "Waking at night is what parents ask about most, and at most ages it's normal. The sleep pages start with what's normal this month.",
      ),
      ObOption(
        'shortNaps',
        'Short naps',
        'Short naps are normal in the early months, and naps get longer with age. The sleep pages show what to expect each month.',
      ),
      ObOption(
        'earlyWaking',
        'Waking very early',
        'Waking early is usually about bedtime or light in the room, not a sleep problem. The sleep pages start there.',
      ),
      ObOption(
        'unsure',
        'Hard to say',
        "That's an honest answer. Jot down a few nights and a pattern will start to show.",
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
        'Your home will show these first. You can change them any time in Profile.',
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
        'The first activities will start with these, then grow from there.',
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
        'Ten minutes is enough. Every activity here fits in ten minutes.',
      ),
      ObOption(
        '20',
        'About 20 minutes',
        'Twenty minutes fits an activity and a chat about it, which is where most of the learning happens.',
      ),
      ObOption(
        'more',
        'More, when we can',
        'Then you can try the longer projects too. The short ones are still there for busy days.',
      ),
    ],
    apply: (s, c) => s.setOther('sk_time', c.join(',')),
  ),
];
