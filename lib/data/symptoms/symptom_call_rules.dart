// =============================================================================
//  When to call, for what she logged (P5 S1, 2026-10-28)
// -----------------------------------------------------------------------------
//  The Symptoms check-in showed each logged symptom's FIRST self-care tip. So
//  a headache got "Rest in a quiet, dark room" and blurred vision "Rest your
//  eyes often", and the line that mattered (pre-eclampsia, cholestasis) sat a
//  tap deeper on the page. Three warning signs on one day read as three
//  comfort tips.
//
//  Two things live here:
//
//    · a short when-to-call line per symptom that has a call condition. It is
//      shown IN PLACE of the tip. The words are each symptom's own
//      `doctorGuidance`, shortened: never new advice;
//    · ONE fixed rule: from 20 weeks, a headache on the same day as blurred
//      vision or swelling. That is the NHS pre-eclampsia when-to-call card.
//
//  ⚠️ A RULE, NOT A RISK. Nothing here computes a likelihood; it matches what
//  she logged against a published card. It lives in code, never in the CMS:
//  a clinical safety rule must not gain a network dependency or become a
//  dropdown (CLAUDE.md, "Do not propose"). Every line and the 20-week gate are
//  on BEFORE-LAUNCH as clinician CHECK lines.
// =============================================================================

/// From this week a headache is read as a possible pre-eclampsia sign
/// (NHS, NICE NG133). Before it, a headache keeps its comfort tip.
const int kSymptomPreeclampsiaFromWeek = 20;

/// The one rule's words, shown with the dialler.
const String kSymptomTogetherCallLine =
    'Together, these are a reason to call your maternity unit now.';

/// The one rule's second line: what to say and why, without naming a
/// condition she has not been told she has.
const String kSymptomTogetherWhy =
    'A headache with blurred vision or swelling, from 20 weeks, is on every '
    "maternity unit's call-now list. It's usually checked quickly with a "
    'blood pressure reading and a urine test.';

/// The short when-to-call line for [symptomId] at [week], or null when the
/// symptom keeps its comfort tip.
///
/// Each line is its symptom's own `doctorGuidance`, cut to the call.
String? symptomCallLine(String symptomId, {required int week}) {
  switch (symptomId) {
    case 'headache':
      if (week < kSymptomPreeclampsiaFromWeek) return null;
      return 'A severe headache, or one with blurred vision or swelling: '
          'call your doctor promptly.';
    case 'blurryVision':
      return 'Blurred vision, flashing lights or spots with a headache or '
          'swelling is a call now. Mild blurring on its own: mention it at '
          'your next visit.';
    case 'itching':
    case 'redPalms':
      return 'Itching on your palms or soles, worse at night: call for a '
          'blood test the same day.';
    case 'swelling':
      return 'Sudden swelling of your face or hands, or swelling with a '
          'headache: get medical advice promptly.';
    case 'spotting':
      return 'Any bleeding in pregnancy, even light spotting, is a call now, '
          'at any hour.';
    case 'cramps':
      return 'Cramps with bleeding, or pain on one side: go to hospital now.';
  }
  return null;
}

/// True when the one fixed rule fires: from [kSymptomPreeclampsiaFromWeek],
/// a headache logged on the same day as blurred vision or swelling.
bool symptomTogetherRule(Iterable<String> loggedIds, {required int week}) {
  if (week < kSymptomPreeclampsiaFromWeek) return false;
  final ids = loggedIds.toSet();
  return ids.contains('headache') &&
      (ids.contains('blurryVision') || ids.contains('swelling'));
}
