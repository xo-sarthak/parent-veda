// =============================================================================
//  "Should I get help?" — a readiness read that leans toward talking
// -----------------------------------------------------------------------------
//  ⚠️ THE ASYMMETRY IS THE WHOLE DESIGN. Everywhere this tool is uncertain it
//  leans toward "worth a conversation", never toward "keep waiting".
//
//  That is not caution for its own sake. The two errors here are not equal:
//  telling someone to book a chat she did not strictly need costs her an
//  appointment; telling a 38-year-old with irregular cycles to wait another six
//  months costs her six months she cannot get back. **Under-referring is the
//  real harm**, so every ambiguous path resolves the same way.
//
//  ---------------------------------------------------------------------------
//  ⚠️ 35 HERE AND 36 IN THE ENGINE, AND BOTH ARE CORRECT
//  ---------------------------------------------------------------------------
//
//  `FertilityAgeBand.refersAtPresentation` in `ttc_fertility_help_rules.dart`
//  hinges on **36**, with a comment citing NICE and warning that writing 35 is
//  the commonest error in fertility copy. This file hinges on **35**. That looks
//  like a contradiction and is not, because the two are answering different
//  questions:
//
//    * **36** is when guidance says a clinician should start INVESTIGATING
//      earlier than the usual twelve months. It is a referral threshold and
//      softening it would misstate the guideline.
//    * **35** is when this tool stops being willing to say "keep waiting". It
//      is a threshold on our own willingness to reassure, and being more
//      cautious than a guideline about whether to have a CONVERSATION is safe
//      in a way that being less cautious never is.
//
//  So nothing was softened and nothing was invented. If you find yourself
//  reconciling them to one number, read this paragraph again first — the one
//  that must not move is 36.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS REUSES, AND WHY IT IS NOT A REWRITE
//  ---------------------------------------------------------------------------
//
//  The brief describes the shipped tool as a three-question check that "misses
//  age and how long she has been trying". That is not what is on disk. The
//  shipped engine asks age, derives duration from `TtcStore.daysTrying`, derives
//  cycle regularity from `CycleStore`, reads the PCOS check, and carries named
//  reasons including a genuinely urgent fertility-preservation route.
//
//  So this file does not replace the engine. It reuses `FertilityHelpContext` —
//  the part that reads the app's own stores — and implements the brief's
//  routing and output on top of it. Reimplementing thresholds the brief itself
//  says not to improvise, when 494 reviewed lines of them already exist, would
//  have been the worst of both.
//
//  What is genuinely new: an explicit question about his semen test (male factor
//  is about half of cases and the shipped flow never asked), a cycle question
//  that prefills and confirms rather than deriving silently, and the
//  never-default-to-waiting rule.
// =============================================================================

import 'ttc_fertility_help_rules.dart';
import 'ttc_fertility_help_store.dart';

// -----------------------------------------------------------------------------
//  The six questions
// -----------------------------------------------------------------------------

// ⚠️ `IvfAge` IS GONE — RETIRED 2026-09-03. Age is `FertilityAgeBand`, from
// `ttc_fertility_help_rules.dart`, and this screen now uses the same enum the
// engine behind it stores.
//
// It was a separate enum with the brief's cut points (under 35 / 35-37 /
// 38-40 / over 40) sitting in front of an engine with different ones (under 30
// / 30-35 / 36-39 / 40+). Two sets of bands meant her answer here could not be
// saved there without guessing which side of a boundary she fell on — "Under
// 35" is both "under 30" and "30 to 35" — so the tool re-asked all six
// questions on every visit rather than guess.
//
// The brief's bands won and the engine moved onto them. Nothing translates any
// more, because there is nothing to translate. `holdsBackReassurance` moved
// onto `FertilityAgeBand` unchanged.

enum IvfTrying { underSix, sixToTwelve, overAYear, overTwoYears }

extension IvfTryingCopy on IvfTrying {
  String get label => switch (this) {
        IvfTrying.underSix => 'Less than 6 months',
        IvfTrying.sixToTwelve => '6 to 12 months',
        IvfTrying.overAYear => 'More than a year',
        IvfTrying.overTwoYears => 'More than 2 years',
      };

  bool get atLeastSixMonths => this != IvfTrying.underSix;
  bool get overAYearOrMore =>
      this == IvfTrying.overAYear || this == IvfTrying.overTwoYears;
}

enum IvfCycles { regular, irregular, longGaps }

extension IvfCyclesCopy on IvfCycles {
  String get label => switch (this) {
        IvfCycles.regular => 'Fairly regular',
        IvfCycles.irregular => 'Irregular',
        IvfCycles.longGaps => 'Long gaps, or no periods',
      };

  /// Both non-regular answers are red flags in the brief's routing.
  bool get isFlag => this != IvfCycles.regular;
}

enum IvfSemen { notDone, normal, issue, notSure }

extension IvfSemenCopy on IvfSemen {
  String get label => switch (this) {
        IvfSemen.notDone => 'Not yet',
        IvfSemen.normal => 'Yes, it was normal',
        IvfSemen.issue => 'Yes, there was an issue',
        IvfSemen.notSure => 'Not sure',
      };
}

enum IvfCheck { no, past, inItNow }

extension IvfCheckCopy on IvfCheck {
  String get label => switch (this) {
        IvfCheck.no => 'No',
        IvfCheck.past => 'Yes, in the past',
        IvfCheck.inItNow => 'I am in it right now',
      };
}

/// The things she may already have been told, and which of them change the
/// routing.
///
/// ⚠️ FOUR OF THE SIX ARE RED FLAGS AND TWO ARE NOT, and the difference is not
/// about severity. A thyroid problem is a real condition that affects cycles and
/// is also, usually, already being treated by someone — it does not on its own
/// mean a fertility conversation is overdue. PCOS, endometriosis, a previous
/// miscarriage and previous pelvic surgery or infection each change what an
/// early conversation would be *for*, which is why they override the timeline.
const List<({String id, String label, bool flag})> kIvfKnownConditions = [
  (id: 'pcos', label: 'PCOS', flag: true),
  (id: 'endo', label: 'Endometriosis', flag: true),
  (id: 'thyroid', label: 'A thyroid problem', flag: false),
  (id: 'miscarriage', label: 'A previous miscarriage', flag: true),
  (id: 'pelvic', label: 'Pelvic surgery or infection', flag: true),
];

class IvfReadinessAnswers {
  FertilityAgeBand? age;
  IvfTrying? trying;
  IvfCycles? cycles;

  /// Ids from [kIvfKnownConditions]. Empty plus [conditionsChecked] means
  /// "none of these".
  Set<String> conditions = {};
  bool conditionsChecked = false;

  /// True when she picked "not sure" rather than naming anything.
  bool conditionsUnsure = false;

  IvfSemen? semen;
  IvfCheck? check;

  /// Which red flags are present, as plain labels for the output.
  List<String> get flags {
    final out = <String>[];
    if (cycles == IvfCycles.irregular) out.add('your cycles are irregular');
    if (cycles == IvfCycles.longGaps) {
      out.add('you have had long gaps without a period');
    }
    for (final c in kIvfKnownConditions) {
      if (c.flag && conditions.contains(c.id)) {
        out.add(c.label.toLowerCase());
      }
    }
    if (semen == IvfSemen.issue) out.add('his semen test showed an issue');
    return out;
  }

  bool get hasFlag => flags.isNotEmpty;

  /// Save what she just answered into the shipped store, so the next visit does
  /// not ask again.
  ///
  /// ⚠️ THIS IS THE FIX FOR THE DEFECT IN `docs/STILL-OPEN.md` §18.1. The tool
  /// READ from `TtcFertilityHelpStore` to pre-fill two questions and wrote
  /// nothing back, so every visit re-asked all six and `hasCompleted` never
  /// became true. It worked perfectly and remembered nothing — the exact
  /// friction the rebuild existed to remove.
  ///
  /// Modelled on `PcosStandAnswers.writeThrough`, one door over. Same shape on
  /// purpose: two short flows feeding two shipped stores should not be two
  /// different mechanisms.
  ///
  /// ⚠️ IT WRITES ONLY WHAT SHE ACTUALLY ANSWERED, AND THAT IS THE WHOLE RULE.
  /// The store holds ten question ids; this flow asks six. `miscarriages`,
  /// `pain`, `pelvic` and `cancer` are NOT touched, so they stay unanswered and
  /// `missingQuestionIds` still names them. Writing a default into a clinical
  /// question she was never asked would put words in her mouth in the one place
  /// it matters — a "no" she never said, feeding a rule that decides whether
  /// she is told to see somebody.
  Future<void> writeThrough(TtcFertilityHelpStore store) async {
    if (age != null) await store.answer('age', age!.name);

    // ⚠️ 'past' AND 'current' ARE THE STORE'S WORDS, NOT AN ENUM'S NAME.
    // `_answers['pathway']` is switched on as a raw string in
    // `TtcFertilityHelpStore.context`; sending `IvfCheck.past.name` would fall
    // through the switch to `notStarted` silently, which is a wrong answer that
    // never announces itself.
    if (check != null) {
      await store.answer(
          'pathway',
          switch (check!) {
            IvfCheck.no => 'not_started',
            IvfCheck.past => 'done',
            IvfCheck.inItNow => 'current',
          });
    }

    // Conditions share ids with the store already (`pcos`, `endo`, `thyroid`,
    // `miscarriage`, `pelvic`), so this is a copy rather than a mapping.
    //
    // "Not sure" is deliberately NOT written. The store models a set of named
    // conditions and an explicit "none"; it has no way to hold "she does not
    // know", and recording that as "none" would convert an absence of
    // information into information. Left unanswered, which is true.
    if (conditionsChecked && !conditionsUnsure) {
      await store.answer(
          'conditions', conditions.isEmpty ? 'none' : conditions.join(','));
    }

    // ⚠️ ONLY A FOUND ISSUE BECOMES "YES". `notDone` and `notSure` are not
    // "no" — they are the absence of a test — and the store's `partnerConcern`
    // is read as a red flag. A "no" here would quietly clear a flag on the
    // strength of a test nobody has done.
    if (semen == IvfSemen.issue) {
      await store.answer('partner', 'yes');
    } else if (semen == IvfSemen.normal) {
      await store.answer('partner', 'no');
    }

    await store.complete();
  }

  /// ⚠️ WHAT COUNTS AS ENOUGH TO REASSURE SOMEONE. Deliberately strict: the
  /// only branch that says "keep trying" requires every one of these to be
  /// present and benign. Anything unanswered, and anything answered "not sure",
  /// falls through to the conversation.
  bool get enoughToReassure =>
      age != null &&
      trying != null &&
      cycles != null &&
      conditionsChecked &&
      !conditionsUnsure &&
      semen != null &&
      semen != IvfSemen.notSure &&
      check != null;
}

// -----------------------------------------------------------------------------
//  The read
// -----------------------------------------------------------------------------

/// Which branch fired. Exposed so a test can assert the routing directly rather
/// than by matching prose.
enum IvfVerdict {
  alreadyInCare,
  flagged,
  soon,
  nowByAge,
  nowByDuration,
  nowBySemenUnknown,

  /// 35 or over, nothing else remarkable, and not yet six months in.
  ///
  /// ⚠️ THIS BRANCH EXISTS BECAUSE A TEST CAUGHT ITS ABSENCE, and the hole it
  /// filled was the worst one available in this file. Without it, a fully
  /// answered, entirely unremarkable 36-year-old four months in fell through to
  /// the reassuring branch — which is the single thing the spec forbids
  /// outright: *never tell someone aged 35 or older to keep waiting.*
  ///
  /// It read as correct because every rule above it was correct. The bug was in
  /// the branch none of them matched.
  nowByAgeEarly,

  nowByMissingInfo,
  keepTrying,
}

extension IvfVerdictCopy on IvfVerdict {
  /// Whether the main action is the specialist rather than the fertile window.
  bool get pushesToSpecialist => this != IvfVerdict.keepTrying;
}

class IvfReadinessResult {
  const IvfReadinessResult({
    required this.verdict,
    required this.where,
    required this.timing,
    required this.openDoor,
    required this.checklist,
  });

  final IvfVerdict verdict;

  /// Block 1 — where she is, in plain words. No numbers about her odds.
  final String where;

  /// Block 2 — the one line about timing, with its reason.
  final String timing;

  /// Block 3's second line. Always present: on the reassuring branch it is the
  /// open door, on every other branch it is the closing disclaimer.
  final String openDoor;

  final List<({String label, String value})> checklist;
}

/// The line that closes every path, unchanged. A constant because it must be
/// identical everywhere and therefore must not be built.
const String kIvfAlwaysLine =
    'This is not a diagnosis. A specialist reading your full history is the '
    'only way to know.';

const String kIvfChecklistDisclaimer =
    'These are my notes for my appointment. They are not a diagnosis.';

/// Suggest a cycle answer from her logs, or null to ask cold.
///
/// ⚠️ PREFILL AND CONFIRM, NOT DERIVE SILENTLY. The shipped engine reads cycle
/// regularity straight from `CycleStore` and never shows her the conclusion,
/// which means a wrong reading — two logged cycles, a missed month — changes the
/// answer invisibly. Showing it as a selected chip she can change costs one tap
/// and makes the input auditable.
IvfCycles? ivfSuggestedCycles(FertilityHelpContext ctx) {
  if (!ctx.hasEnoughCycleData) return null;
  final lo = ctx.cycleShortest;
  final hi = ctx.cycleLongest;
  if (lo == null || hi == null) return null;
  if (hi >= 90) return IvfCycles.longGaps;
  return ctx.cyclesIrregular ? IvfCycles.irregular : IvfCycles.regular;
}

/// Build the read. [ctx] supplies what the app already knows; [a] supplies what
/// it had to ask.
IvfReadinessResult ivfBuildReadiness(
    IvfReadinessAnswers a, FertilityHelpContext ctx) {
  // ---- Block 1: where she is ----------------------------------------------
  final bits = <String>[];
  if (a.age != null) bits.add('You are ${a.age!.label.en.toLowerCase()}');
  if (a.trying != null) {
    bits.add(a.trying == IvfTrying.underSix
        ? 'and have been trying less than six months'
        : 'and have been trying ${a.trying!.label.toLowerCase()}');
  }
  var where = bits.isEmpty
      ? 'You have not told us enough yet for this to say much.'
      : '${bits.join(' ')}.';
  if (a.cycles != null) {
    where += switch (a.cycles!) {
      IvfCycles.regular => ' Your cycles look fairly regular.',
      IvfCycles.irregular => ' Your cycles have been irregular.',
      IvfCycles.longGaps => ' You have had long gaps without a period.',
    };
  }

  // ---- Block 2: the routing, first match wins -----------------------------
  //
  // ⚠️ ORDER IS LOAD-BEARING AND IT IS THE ORDER IN THE SPEC. Already-in-care
  // comes first because everything below it would be telling someone under a
  // consultant's care to go and find one. Red flags come next because they
  // override age and duration — a 29-year-old four months in with a previous
  // ectopic should not be told to keep waiting because the clock says so.
  final (IvfVerdict verdict, String timing) = switch (a) {
    _ when a.check == IvfCheck.inItNow => (
        IvfVerdict.alreadyInCare,
        'You are already being seen, which is the right place to be. Keep '
            'logging what happens in the cycle you are in, and take your '
            'questions to the team who know your history.'
      ),
    _ when a.hasFlag => (
        IvfVerdict.flagged,
        'It is worth a conversation now, whatever the timeline — because '
            '${_join(a.flags)}. That is not a verdict on anything; it is a '
            'reason a specialist would want to look sooner rather than later.'
      ),
    _ when a.age == FertilityAgeBand.over40 => (
        IvfVerdict.soon,
        'It is worth speaking to someone soon. Over 40, the usual advice to '
            'wait and see does not apply, and an early conversation keeps more '
            'options open.'
      ),
    _
        when (a.age?.holdsBackReassurance ?? false) &&
            (a.trying?.atLeastSixMonths ?? false) =>
      (
        IvfVerdict.nowByAge,
        'It is worth a conversation now. At 35 or over, six months of trying '
            'is the point at which most guidance suggests looking into it '
            'rather than waiting the full year.'
      ),
    _
        when a.age == FertilityAgeBand.under35 &&
            (a.trying?.overAYearOrMore ?? false) =>
      (
        IvfVerdict.nowByDuration,
        'It is worth a conversation now. A year of trying is the usual point '
            'to have someone look, and there is nothing to be gained by '
            'waiting longer.'
      ),
    _
        when a.semen == IvfSemen.notSure &&
            (a.trying?.atLeastSixMonths ?? false) =>
      (
        IvfVerdict.nowBySemenUnknown,
        'It is worth a conversation now, and getting his semen test done is a '
            'good first step. It is quick, inexpensive, and it answers about '
            'half the question.'
      ),
    // ⚠️ 35 OR OVER, AND NOTHING ELSE TO GO ON. Not a red flag, not six months
    // yet — but old enough that "keep trying" is not ours to say. So the answer
    // is the conversation, framed as available rather than overdue.
    _ when (a.age?.holdsBackReassurance ?? false) && a.enoughToReassure => (
        IvfVerdict.nowByAgeEarly,
        'A conversation is worth having whenever you are ready. Nothing here '
            'looks unusual — but at 35 or over the advice to give it a full '
            'year before asking does not really apply, so there is no reason '
            'to hold off if you would rather know.'
      ),
    // ⚠️ THE REASSURING BRANCH IS THE NARROWEST ONE. It requires every answer
    // to be present AND her to be under 35 — see `enoughToReassure` for the
    // first half and the branch above for why the second half is not optional.
    _ when a.age == FertilityAgeBand.under35 && a.enoughToReassure => (
        IvfVerdict.keepTrying,
        'It is reasonable to keep trying for now. Most couples in this '
            'situation conceive within a year, and nothing you have told us '
            'suggests a reason to hurry.'
      ),
    // ⚠️ THE DEFAULT, AND IT IS THE CONVERSATION. Anything unanswered lands
    // here rather than in the branch above. Never default to waiting.
    _ => (
        IvfVerdict.nowByMissingInfo,
        'It is worth a conversation now. There are a few things here we do not '
            'know, and a specialist can settle them far faster than waiting '
            'will.'
      ),
  };

  // ---- Block 3's second line ----------------------------------------------
  final openDoor = verdict == IvfVerdict.keepTrying
      ? 'If you would feel better talking to someone, that is always okay. '
          '$kIvfAlwaysLine'
      : kIvfAlwaysLine;

  return IvfReadinessResult(
    verdict: verdict,
    where: where,
    timing: timing,
    openDoor: openDoor,
    checklist: [
      (label: 'My age', value: a.age?.label.en ?? 'Not answered'),
      (
        label: 'How long we have been trying',
        value: a.trying?.label ?? 'Not answered'
      ),
      (
        label: 'My cycle pattern',
        value: a.cycles?.label ??
            (ctx.hasEnoughCycleData ? 'See my logs' : 'Not enough logged yet')
      ),
      (
        label: 'Already known',
        value: a.conditionsUnsure
            ? 'Not sure'
            : a.conditions.isEmpty
                ? 'Nothing so far'
                : kIvfKnownConditions
                    .where((c) => a.conditions.contains(c.id))
                    .map((c) => c.label)
                    .join(', ')
      ),
      (
        label: 'His semen test',
        value: switch (a.semen) {
          IvfSemen.normal => 'Done, and it was normal',
          IvfSemen.issue => 'Done, and there was an issue',
          IvfSemen.notDone => 'Not done yet',
          IvfSemen.notSure => 'Not sure',
          null => 'Not answered',
        }
      ),
      (
        label: 'Any earlier fertility check',
        value: a.check?.label ?? 'Not answered'
      ),
    ],
  );
}

/// "a, b and c" — so a list of reasons reads as a sentence.
String _join(List<String> parts) {
  if (parts.length == 1) return parts.first;
  if (parts.length == 2) return '${parts[0]} and ${parts[1]}';
  return '${parts.sublist(0, parts.length - 1).join(', ')} '
      'and ${parts.last}';
}
