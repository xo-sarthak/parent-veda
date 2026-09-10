// =============================================================================
//  What to ask about your diet
// -----------------------------------------------------------------------------
//  The Nutrition door's "before your appointment" checklist, and the second of
//  the two genuinely new items in that whole area.
//
//  ⚠️ IT NAMES HER STAGE, NOT A CONDITION. The scans checklist knows which scan
//  is coming and the conditions one knows what she has added; this one knows
//  which third of the pregnancy she is in, which is what actually changes the
//  answers — iron and calcium in the middle months, frequency and fluid at the
//  end.
//
//  ⚠️ AND IT IS FOR A DIETICIAN OR A DOCTOR, NOT FOR US. Every line is a
//  question to ask a person. None is a threshold, a portion size or a number to
//  hit — the whole area's standing rule is that the numbers are her care team's
//  to set, and a checklist that handed her some would be the app quietly taking
//  a decision it has said four times it will not take.
//
//  ⚠️ NO BARE MEDICAL WORD. Same rule the Complications door holds. "Pregnancy
//  sugar", not gestational diabetes; "low iron", not anaemia.
// =============================================================================

import '../../services/pregnancy_controller.dart';
import 'pv_checklist.dart';

/// Which third she is in, in words.
///
/// ⚠️ READ FROM THE CONTROLLER, NOT ASKED. She has already told the app her due
/// date; asking again on a checklist would be the app forgetting what it just
/// did. Null before a due date exists, which falls back to the plain title.
///
/// ⚠️ AND THE BOUNDARIES MATCH THE REST OF THE APP — 14 and 28, the same two
/// numbers `cravings_screen.dart` and the diet charts use. A third definition
/// of "second trimester" is a third answer to one question.
String? _stageName(PregnancyController c) {
  final week = c.currentWeek;
  if (week <= 0) return null;
  if (week < 14) return 'the first three months';
  if (week < 28) return 'the middle months';
  return 'the last three months';
}

final PvChecklist kDietQuestionsChecklist = PvChecklist(
  id: 'diet_questions',
  eyebrow: 'Before your appointment',
  title: 'What to ask about your diet',
  intro: 'Tick what matters to you and take the list in with you. These are '
      'questions a doctor or a dietician answers every day — none of them is '
      'a silly one.',
  shareHeader: 'What to ask about my diet',
  subject: _stageName,
  subjectTitle: (s) => 'What to ask about your diet',
  subjectIntro: (s) => 'You are in $s. Tick what matters to you and take the '
      'list in with you — these are questions a doctor or a dietician answers '
      'every day.',
  groups: [
    PvChecklistGroup('Is my plate alright?', [
      PvChecklistItem('plate_enough',
          'Looking at what I actually eat in a day, is anything missing?'),
      PvChecklistItem('plate_veg',
          'I am vegetarian — is there anything I need to add or take?'),
      PvChecklistItem('plate_weight',
          'Am I gaining weight the way you would expect at this stage?'),
      PvChecklistItem('plate_portion',
          'How much more should I be eating than before, if any?'),
      PvChecklistItem('plate_home',
          'My family cooks one meal for everyone — can I eat that?'),
    ]),

    PvChecklistGroup('Tablets and supplements', [
      PvChecklistItem('sup_which',
          'Which of my tablets is for what, and how long do I take each one?'),
      PvChecklistItem('sup_when',
          'When should I take each one, and what should I avoid with it?'),
      PvChecklistItem('sup_sick',
          'They upset my stomach — is there another version I could try?'),
      PvChecklistItem('sup_extra',
          'Do I need anything you have not already given me?'),
      PvChecklistItem('sup_bought',
          'I bought this on my own — should I be taking it?'),
    ]),

    PvChecklistGroup('Food I am unsure about', [
      PvChecklistItem('food_papaya',
          'Are the foods my family says to avoid actually a problem?'),
      PvChecklistItem('food_outside',
          'How careful do I need to be about eating outside?'),
      PvChecklistItem('food_tea',
          'How much tea or coffee is alright in a day?'),
      PvChecklistItem('food_craving',
          'I am craving something odd — is that worth mentioning?'),
    ]),

    PvChecklistGroup('If something has been flagged', [
      PvChecklistItem('flag_change',
          'What should change in what I eat, starting today?'),
      PvChecklistItem('flag_numbers',
          'What readings are you aiming for, and how often should I check?'),
      PvChecklistItem('flag_chart',
          'Can I have this written down as a plan I can follow at home?'),
      PvChecklistItem('flag_dietician',
          'Would it help to see a dietician about this?'),
    ]),

    PvChecklistGroup('Fasting and festivals', [
      PvChecklistItem('fast_safe',
          'A fast is coming up — is it alright for me to keep it this year?'),
      PvChecklistItem('fast_modify',
          'If I do keep it, what should I change to make it safer?'),
      // ⚠️ LAST, AND IT IS THE SAME LINE EVERY CHECKLIST ENDS ON. Every
      // clinician carries a threshold for "call me rather than wait"; few say
      // it out loud unless asked, and the last thing read is the thing
      // remembered walking out.
      PvChecklistItem('fast_call',
          'What would make you want me to call rather than wait?'),
    ]),
  ],
);
