// =============================================================================
//  What to ask about your condition
// -----------------------------------------------------------------------------
//  The Complications door's "before your appointment" checklist.
//
//  ⚠️ IT NAMES HER CONDITION WHERE SHE HAS ADDED ONE. "What to ask about your
//  condition" is a leaflet; "What to ask about your gestational diabetes" is
//  hers. That comes from `ConditionsStore.addedConditions` — the visible end of
//  the "Add to my journey" button — so nothing is asked for twice.
//
//  ⚠️ AND THE QUESTIONS ARE DELIBERATELY CONDITION-AGNOSTIC. The obvious build
//  is a different list per condition, and it is wrong twice over: twenty-seven
//  lists is twenty-seven things to keep clinically current, and the questions
//  that actually matter at an appointment do not vary by diagnosis. "What
//  should make me call you rather than wait" is the same question whether the
//  word was anaemia or preeclampsia.
//
//  Where a condition DOES have its own questions, they already exist and are
//  already shown: `ReportFinding.questions` carries three per finding on the
//  finding pages. This list is the other half — the questions about the PLAN
//  rather than about the word.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NOTHING HERE ASKS US TO INTERPRET ANYTHING
//  ---------------------------------------------------------------------------
//
//  Every line is a question for her clinician. None is a threshold, a number to
//  check, or a self-assessment, and none implies a right answer. Where a doctor
//  owns a decision we may explain it, remind about it, or help her prepare for
//  it — and a list of questions is the purest form of the third.
//
//  ⚠️ AND NO BARE MEDICAL WORD, ANYWHERE. The Complications brief:
//  *"Never put a bare medical word as a list label, a section heading, or a
//  red-flag line."* A checklist item is a label.
// =============================================================================

import '../../services/pregnancy_controller.dart';
import '../conditions_data.dart';
import 'pv_checklist.dart';

/// The condition she has added, as a plain name, or null.
///
/// ⚠️ THE FIRST ONE, NOT ALL OF THEM. Somebody managing two conditions gets the
/// one she added first in the heading, and the questions below serve both — see
/// the note above on why they are condition-agnostic. Listing two in a title
/// makes a heading that wraps to three lines and says less.
String? _addedConditionName(PregnancyController _) {
  final added = ConditionsStore.instance.addedConditions;
  if (added.isEmpty) return null;
  // ⚠️ `.en`, NOT `.now`. This is composed into a title and into a shared
  // message, and `.now` is display — wrong the moment a value leaves the widget
  // that drew it.
  return added.first.name.en;
}

final PvChecklist kConditionQuestionsChecklist = PvChecklist(
  id: 'condition_questions',
  eyebrow: 'Before your appointment',
  title: 'What to ask about your condition',
  intro: 'Tick what matters to you and take the list in with you. These are '
      'questions your doctor is used to answering — none of them is a test, '
      'and none of them will annoy anybody.',
  shareHeader: 'What to ask my doctor',
  subject: _addedConditionName,
  subjectTitle: (s) => 'What to ask about your $s',
  subjectIntro: (s) => 'Tick what matters to you and take the list in with '
      'you. These are questions your doctor is used to answering about $s.',
  groups: [
    PvChecklistGroup('Understanding it', [
      PvChecklistItem('und_what',
          'In plain words, what does this mean for me?'),
      PvChecklistItem('und_why',
          'Do we know why it happened, or is that usually not knowable?'),
      PvChecklistItem('und_serious',
          'How worried should I actually be, on a normal day?'),
      PvChecklistItem('und_common',
          'How often do you see this?'),
      PvChecklistItem('und_temp',
          'Will this go away after the birth, or is it something I keep?'),
    ]),

    PvChecklistGroup('The plan', [
      PvChecklistItem('plan_next',
          'What happens next, and when?'),
      PvChecklistItem('plan_tests',
          'Which tests will you repeat, and how often?'),
      PvChecklistItem('plan_working',
          'How will we know whether it is working?'),
      PvChecklistItem('plan_choices',
          'Is there more than one way to manage this?'),
      PvChecklistItem('plan_scans',
          'Does this change how often I need scans?'),
    ]),

    PvChecklistGroup('Medicines and daily life', [
      PvChecklistItem('med_what',
          'What exactly am I taking, and what is it doing?'),
      PvChecklistItem('med_when',
          'When should I take it, and with what?'),
      PvChecklistItem('med_side',
          'What side effects are normal, and which ones mean I should call?'),
      PvChecklistItem('med_stop',
          'What happens if I miss one, and when do I stop?'),
      PvChecklistItem('life_change',
          'Does anything need to change in what I eat, or how I work?'),
      PvChecklistItem('life_travel',
          'Is travel still alright?'),
    ]),

    PvChecklistGroup('The baby, and the birth', [
      PvChecklistItem('baby_effect',
          'Does this affect the baby, and how would we know?'),
      PvChecklistItem('baby_birth',
          'Does this change anything about how or when I deliver?'),
      PvChecklistItem('baby_after',
          'Is there anything to watch for after the birth?'),
    ]),

    PvChecklistGroup('When to call', [
      PvChecklistItem('call_who',
          'Who do I call if something changes — you, or the hospital?'),
      // ⚠️ THE ONE QUESTION EVERY CLINICIAN HAS AN ANSWER TO AND FEW SAY OUT
      // LOUD. It is last because the last thing read is the thing remembered
      // walking out, and because on a condition page it is the question the
      // whole safety tab exists to answer.
      PvChecklistItem('call_when',
          'What would make you want me to call the same day?'),
    ]),
  ],
);
