// =============================================================================
//  "Where do I stand" — a self-read that refuses to be a verdict
// -----------------------------------------------------------------------------
//  ⚠️ THE WHOLE DESIGN IS THE ABSENCE OF AN ANSWER, and that is not a hedge.
//  The competitor takes these same inputs and ends on "low match / high match",
//  which lands as either false reassurance or quiet alarm — and PCOS is exactly
//  the condition where both are harmful. A woman told "low match" stops asking;
//  a woman told "high match" arrives at a clinic already certain, and a real
//  diagnosis needs a history, an exam, often bloods and a scan.
//
//  So this file computes NO score, NO percentage, NO label and NO match. It
//  reflects her own pattern back in plain words and routes to a doctor. That is
//  "PCOS, without the panic" made literal rather than printed on a hero.
//
//  ---------------------------------------------------------------------------
//  ⚠️ LONG GAPS COME FROM `periodStarts`, NEVER FROM `cycleLengths`
//  ---------------------------------------------------------------------------
//
//  This is the single trap in the whole file and it would have been silent.
//
//  `CycleStore.cycleLengths` filters out any gap longer than 90 days as
//  implausible — correct for an average, because a mis-tap or a missed log
//  would otherwise poison it. But a gap of three months or more without a
//  period is precisely the thing this tool exists to notice, and it is one of
//  the most common presentations of PCOS there is.
//
//  Reading gaps off `cycleLengths` would therefore have discarded exactly the
//  users the tool matters most to, and it would have looked like it worked: the
//  screen renders, the sentence appears, and the answer is quietly "your cycles
//  look regular" for someone who has not bled since April.
//
//  **A filter written for one question is almost never right for the next one.**
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT IS NOT HERE
//  ---------------------------------------------------------------------------
//
//  * **No weight number is requested and no weight target is produced.** Not a
//    BMI, not a range, not "a few kilos". The brief is explicit and the reason
//    is clinical as much as kind: weight talk is the fastest route to someone
//    closing an app about their own body.
//  * **No mood / libido / fatigue / appetite battery.** Dropped on purpose —
//    that stack is what makes the competitor's version read as an interrogation
//    and it adds nothing this tool is allowed to conclude from.
//  * **No age question — and the nudge no longer needs one.** The date of birth
//    lives on `FamilyProfileStore`, asked once at onboarding, so the 35-and-six-
//    months rule fires without this flow asking anything. See `_nudge`.
// =============================================================================

import '../services/family_profile.dart';
import 'cycle_store.dart';
import 'ttc_chapter.dart' show kTtcIrregularSpreadDays;
import 'ttc_pcos_check_store.dart';

// -----------------------------------------------------------------------------
//  What she is asked
// -----------------------------------------------------------------------------

/// Every question is one of these three shapes. Kept deliberately small: three
/// answer vocabularies across eight questions is what stops the flow feeling
/// like a form.
enum PcosYesNo { yes, no, notSure }

/// "Haven't noticed" is [none] and it is a real answer, not an absent one — the
/// difference matters, because an unanswered question and a noticed-nothing
/// produce different output blocks.
enum PcosDegree { none, mild, moderate, severe }

enum PcosCycleLength { typical, shorter, longer, notSure }

enum PcosTrying { underSix, sixToTwelve, overAYear, notTrying }

enum PcosFamily { yes, no, dontKnow }

/// Where extra hair growth was noticed. Ids are persisted, labels are not.
enum PcosHairArea { upperLip, chin, chest, belly, thighs }

extension PcosHairAreaCopy on PcosHairArea {
  String get label => switch (this) {
        PcosHairArea.upperLip => 'Upper lip',
        PcosHairArea.chin => 'Chin',
        PcosHairArea.chest => 'Chest',
        PcosHairArea.belly => 'Belly',
        PcosHairArea.thighs => 'Thighs',
      };
}

/// Everything she answered. All nullable — an unanswered question is a state,
/// and the result has to be buildable from a partly-finished flow.
class PcosStandAnswers {
  PcosCycleLength? cycleLength;
  PcosYesNo? longGaps;

  /// Empty set plus [hairChecked] true means "haven't noticed".
  Set<PcosHairArea> hairAreas = {};
  bool hairChecked = false;

  PcosDegree? thinning;
  PcosDegree? acne;
  PcosYesNo? skinDarkening;
  PcosTrying? trying;
  PcosFamily? family;

  /// Write these answers into the shipped PCOS store.
  ///
  /// ⚠️ THIS IS THE WHOLE REASON THE TOOL IS NOT A SECOND STORE. A 20-question
  /// PCOS checker already ships, and five other surfaces read its answers — the
  /// BMI screen, the pre-check rules, the fertility-help store, the Tools hub
  /// and a journey. A new self-read with its own private state would leave all
  /// five looking at a check the user believes she has already done.
  ///
  /// So the short flow is a new FRONT, not a new store: eight questions mapped
  /// onto the ids that already exist. The twelve questions this flow does not
  /// ask simply stay unanswered, which every reader already has to cope with —
  /// the old screen let her quit at any point too.
  ///
  /// ⚠️ THE MAPPING IS LOSSY IN ONE DIRECTION ONLY, deliberately. `q_hair_growth`
  /// has four levels and we collect a set of body areas, so the count becomes
  /// the level: more places is more noticeable. That is a judgement, it is
  /// written down here, and it is the only place it is made.
  ///
  /// ⚠️ FAMILY HISTORY IS NOT WRITTEN THROUGH, because the store has no question
  /// for it. Inventing an id would put a key in persisted user state that no
  /// rule reads — a column that exists only to be written. It lives on this
  /// object, appears in the read, and is not stored.
  Future<void> writeThrough() async {
    final store = TtcPcosCheckStore.instance;

    Future<void> put(String qid, String? option) async {
      if (option != null) await store.answer(qid, option);
    }

    await put(
        'q_length',
        switch (cycleLength) {
          PcosCycleLength.typical => 'normal',
          PcosCycleLength.shorter => 'short',
          PcosCycleLength.longer => 'long',
          PcosCycleLength.notSure => 'unsure',
          null => null,
        });

    await put(
        'q_gap',
        switch (longGaps) {
          PcosYesNo.yes => 'yes',
          PcosYesNo.no => 'no',
          PcosYesNo.notSure => 'unsure',
          null => null,
        });

    if (hairChecked) {
      await put(
          'q_hair_growth',
          switch (hairAreas.length) {
            0 => 'no',
            1 => 'mild',
            2 => 'noticeable',
            _ => 'significant',
          });
    }

    await put(
        'q_thinning',
        switch (thinning) {
          PcosDegree.none => 'no',
          PcosDegree.mild => 'mild',
          PcosDegree.moderate => 'noticeable',
          PcosDegree.severe => 'significant',
          null => null,
        });

    await put(
        'q_acne',
        switch (acne) {
          PcosDegree.none => 'no',
          PcosDegree.mild => 'sometimes',
          PcosDegree.moderate => 'often',
          PcosDegree.severe => 'persistent',
          null => null,
        });

    await put(
        'q_skin_patches',
        switch (skinDarkening) {
          PcosYesNo.yes => 'yes',
          PcosYesNo.no => 'no',
          PcosYesNo.notSure => 'unsure',
          null => null,
        });

    await put(
        'q_trying',
        switch (trying) {
          PcosTrying.notTrying => 'not_trying',
          PcosTrying.underSix => 'under6',
          PcosTrying.sixToTwelve => 'six_twelve',
          PcosTrying.overAYear => 'over12',
          null => null,
        });

    await store.complete();
  }
}

// -----------------------------------------------------------------------------
//  What we already know without asking
// -----------------------------------------------------------------------------

enum PcosRegularity { regular, irregular, notEnoughData }

/// What her logged cycles say, before a single question is asked.
class PcosCycleFacts {
  const PcosCycleFacts({
    required this.regularity,
    required this.completedCycles,
    required this.longestGapDays,
  });

  final PcosRegularity regularity;
  final int completedCycles;

  /// The longest interval between two logged period starts, in days. Null when
  /// there are fewer than two.
  ///
  /// ⚠️ COMPUTED FROM `periodStarts`, NOT FROM `cycleLengths` — see the file
  /// header. This number is allowed to be 140 days; the average is not.
  final int? longestGapDays;

  /// Three months or more without a period.
  bool get hasLongGap => (longestGapDays ?? 0) >= 90;

  /// What Q1 should be prefilled with, or null to ask cold.
  PcosCycleLength? get suggestedLength {
    if (completedCycles < 2) return null;
    final lens = CycleStore.instance.cycleLengths;
    if (lens.isEmpty) return null;
    final avg = lens.reduce((a, b) => a + b) / lens.length;
    if (avg < 21) return PcosCycleLength.shorter;
    if (avg > 35) return PcosCycleLength.longer;
    return PcosCycleLength.typical;
  }
}

/// Read her logs. Never asks, never guesses beyond what is there.
PcosCycleFacts pcosCycleFacts() {
  final starts = CycleStore.instance.periodStarts;
  final lens = CycleStore.instance.cycleLengths;

  int? longest;
  for (var i = 1; i < starts.length; i++) {
    final gap = starts[i].difference(starts[i - 1]).inDays;
    if (longest == null || gap > longest) longest = gap;
  }

  // ⚠️ THREE CYCLES BEFORE WE WILL CALL ANYTHING IRREGULAR. Two cycles give one
  // comparison, and one comparison is an anecdote — a 26 followed by a 33 is
  // completely ordinary and would read as "irregular" on a two-point sample.
  //
  // ⚠️ AND THE THRESHOLD IS SPREAD, NOT DISTANCE FROM 28. Cycles that run 33,
  // 34, 33 are regular; that woman simply has a long cycle. What makes a cycle
  // irregular is that it does not repeat. Nine days of cycle-to-cycle variation
  // is the line clinicians use, and using anything else here would mean the app
  // and her doctor disagreeing about a word she is about to hear from both.
  var regularity = PcosRegularity.notEnoughData;
  if (lens.length >= 3) {
    final lo = lens.reduce((a, b) => a < b ? a : b);
    final hi = lens.reduce((a, b) => a > b ? a : b);
    // ⚠️ SEVEN, NOT NINE, SINCE 2026-09-26: the app's one definition of
    // irregular (`kTtcIrregularSpreadDays`, FIGO 2018 for ages 26 to 41;
    // nine is FIGO's figure for 18 to 25 and 42 to 45). The three-cycle floor
    // above stays. Kept for revert: `(hi - lo) > 9`.
    regularity = (hi - lo) > kTtcIrregularSpreadDays
        ? PcosRegularity.irregular
        : PcosRegularity.regular;
  }
  // A logged gap of three months is irregular whatever the average says — and
  // it is the case `cycleLengths` cannot see at all, because it filtered it.
  if (longest != null && longest >= 90) regularity = PcosRegularity.irregular;

  return PcosCycleFacts(
    regularity: regularity,
    completedCycles: lens.length,
    longestGapDays: longest,
  );
}

// -----------------------------------------------------------------------------
//  What she is told
// -----------------------------------------------------------------------------

/// The finished read. Three blocks, a checklist, and nothing that resembles a
/// verdict.
class PcosStandResult {
  const PcosStandResult({
    required this.cycleLine,
    required this.noticed,
    required this.always,
    required this.nudge,
    required this.checklist,
  });

  /// Block 1 — one sentence about her cycle, in her own data's terms.
  final String cycleLine;

  /// Block 2 — one neutral line per thing she marked. Empty is a valid result
  /// and the screen must render the block away rather than say "nothing".
  final List<String> noticed;

  /// Block 3 — always shown, always the same, never softened.
  final String always;

  /// Block 3's optional second line. Null unless it is earned.
  final String? nudge;

  /// The appointment-prep summary, as label/value pairs.
  final List<({String label, String value})> checklist;
}

/// The one sentence about her cycle.
///
/// ⚠️ NEVER "THIS POINTS TO PCOS", in any phrasing. An irregular cycle has a
/// long list of causes — thyroid, stress, weight change, perimenopause,
/// contraception, a recent birth — and naming one of them is a diagnosis
/// wearing a hedge. The furthest this is allowed to go is that it is worth a
/// doctor looking at, which is true of every branch.
String _cycleLine(PcosCycleFacts facts, PcosStandAnswers a) {
  if (facts.hasLongGap) {
    return 'Your logs show a gap of about ${facts.longestGapDays! ~/ 30} '
        'months without a period. That can make ovulation hard to predict. '
        "It's one of the things a doctor can look into.";
  }
  if (facts.regularity == PcosRegularity.irregular) {
    return 'Your cycles have changed quite a bit from one to the next. That '
        "can make ovulation harder to predict. It's one of the things a "
        'doctor can look into.';
  }
  if (facts.regularity == PcosRegularity.regular) {
    return 'Your cycles look regular. That makes your fertile window easier '
        'to spot.';
  }

  // Not enough logged. Fall back to what she told us, and say plainly that the
  // app is going on her word rather than on data it does not have.
  return switch (a.cycleLength) {
    PcosCycleLength.typical =>
      'You said your cycles are usually 21 to 35 days. Once you log a few '
          'more here, this will use your own dates.',
    PcosCycleLength.shorter || PcosCycleLength.longer =>
      'You said your cycles are often outside the usual 21 to 35 days. That '
          "can make ovulation harder to predict. It's one of the things a "
          'doctor can look into.',
    _ => "There isn't enough logged yet to describe your pattern. Logging a "
        'few period start dates is the quickest way to change that.',
  };
}

/// One neutral line per marked item.
///
/// ⚠️ EVERY LINE ENDS SOMEWHERE NEUTRAL, and several say "many causes" in so
/// many words. This is the block where a verdict would sneak in — four
/// observations listed together read as a case being built unless each one is
/// explicitly de-linked.
List<String> _noticed(PcosStandAnswers a) {
  final out = <String>[];

  if (a.hairAreas.isNotEmpty) {
    final where = a.hairAreas.map((h) => h.label.toLowerCase()).join(', ');
    out.add('You noticed extra hair growth ($where). On its own, this can '
        'have many causes.');
  }
  if (a.thinning != null && a.thinning != PcosDegree.none) {
    out.add('You noticed some hair thinning. Worth mentioning at a check-up.');
  }
  if (a.acne != null && a.acne != PcosDegree.none) {
    out.add("You've had acne that skincare didn't fix. Worth mentioning at "
        'a check-up.');
  }
  if (a.skinDarkening == PcosYesNo.yes) {
    out.add('You noticed some skin darkening. Worth mentioning at a check-up.');
  }
  if (a.family == PcosFamily.yes) {
    out.add("PCOS runs in your family. That's useful for a doctor to know.");
  }
  return out;
}

/// Whether to add the "sooner rather than later" line, and why.
///
/// ⚠️ THIS IS THE LOUDEST THIS TOOL IS EVER ALLOWED TO GET. Not a warning, not
/// a flag, not a colour change — one extra sentence suggesting she books
/// sooner. Anything stronger is urgency theatre on a screen whose entire job is
/// to take the panic out.
///
/// ⚠️ THE AGE BRANCH IS LIVE NOW, AND IT WAS DORMANT FOR A REAL REASON. It
/// fires at six months of trying from 35, which is the correct clinical
/// threshold and the one this flow could not reach: nothing in the app stored a
/// maternal age. Rather than add a ninth question to a flow whose whole point is
/// being short — and ask the same thing the IVF tool already asks — the date of
/// birth now lives on `FamilyProfileStore`, collected once at onboarding.
///
/// ⚠️ AND IT READS `age`, NOT A STORED NUMBER. `FamilyProfileStore.age` derives
/// from the date on every read, so a woman who onboards at 34 crosses this
/// threshold on her birthday rather than never. A stored age would have made
/// this branch quietly wrong for everyone who kept the app more than a year,
/// which is worse than it being dormant.
///
/// ⚠️ NULL AGE STILL WORKS. It simply does not fire — the same behaviour this
/// had before the field existed, which is why nothing else needed changing.
String? _nudge(PcosCycleFacts facts, PcosStandAnswers a) {
  if (facts.hasLongGap) {
    return "Because you've had a long gap without a period, it's worth "
        'booking a check sooner rather than later.';
  }
  if (a.trying == PcosTrying.overAYear) {
    return "Because you've been trying for a while, it's worth booking a "
        'check sooner rather than later.';
  }

  // ⚠️ SIX MONTHS FROM 35, AND THE ORDER MATTERS. This sits below the two above
  // rather than beside them because their wording names a stronger reason. A
  // woman with a four-month gap AND aged 36 should hear about the gap, which is
  // the thing a doctor will act on first.
  final age = FamilyProfileStore.instance.age;
  final sixMonths = a.trying == PcosTrying.sixToTwelve ||
      a.trying == PcosTrying.overAYear;
  if (age != null && age >= 35 && sixMonths) {
    return 'Because you\'re ${age >= 40 ? 'over 40' : '35 or over'} and have '
        "been trying six months or more, it's worth booking a check sooner "
        'rather than later. Under 35, the usual advice is to give it a year. '
        "From 35, it's six months.";
  }
  return null;
}

/// The always-shown line. Deliberately a constant: it is the one sentence that
/// must be identical on every path, so it is not built.
const String kPcosAlwaysLine =
    "Only a doctor can say what's behind this. PCOS is diagnosed by a doctor, "
    'with a check-up and sometimes a scan or a blood test, not by an app.';

/// The closing line on the checklist. Also a constant, same reason.
const String kPcosChecklistDisclaimer =
    'These are my notes for my appointment. They are not a diagnosis.';

/// Build the whole read.
PcosStandResult pcosBuildStand(PcosStandAnswers a, {PcosCycleFacts? facts}) {
  final f = facts ?? pcosCycleFacts();

  final noticed = <String>[];
  if (a.hairAreas.isNotEmpty) noticed.add('extra hair growth');
  if (a.thinning != null && a.thinning != PcosDegree.none) {
    noticed.add('hair thinning');
  }
  if (a.acne != null && a.acne != PcosDegree.none) {
    noticed.add("acne that skincare didn't fix");
  }
  if (a.skinDarkening == PcosYesNo.yes) noticed.add('skin darkening');

  return PcosStandResult(
    cycleLine: _cycleLine(f, a),
    noticed: _noticed(a),
    always: kPcosAlwaysLine,
    nudge: _nudge(f, a),
    checklist: [
      (
        label: 'My cycle pattern, from my logs',
        value: switch (f.regularity) {
          PcosRegularity.regular => 'Regular, over ${f.completedCycles} '
              'logged cycles',
          PcosRegularity.irregular =>
            'Varies, over ${f.completedCycles} logged cycles',
          PcosRegularity.notEnoughData => 'Not enough logged yet',
        },
      ),
      (
        label: 'Longest gap without a period',
        value: f.longestGapDays == null
            ? 'Not known yet'
            : '${f.longestGapDays} days',
      ),
      (
        label: "What I've noticed",
        // ⚠️ "Nothing in particular" RATHER THAN AN EMPTY LINE. She is taking
        // this to an appointment; a blank next to a heading reads as a question
        // she skipped, which invites the doctor to ask it again.
        value: noticed.isEmpty ? 'Nothing in particular' : noticed.join(', '),
      ),
      (
        label: "How long I've been trying",
        value: switch (a.trying) {
          PcosTrying.underSix => 'Less than 6 months',
          PcosTrying.sixToTwelve => '6 to 12 months',
          PcosTrying.overAYear => 'More than a year',
          PcosTrying.notTrying => 'Not trying right now',
          null => 'Not answered',
        },
      ),
    ],
  );
}
