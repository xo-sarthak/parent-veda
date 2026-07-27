// =============================================================================
//  TTC Chapter Engine - the spine of the Trying-to-Conceive stage
// -----------------------------------------------------------------------------
//  Pregnancy is organised by WEEKS. Parenting is organised by PHASES.
//  Trying to Conceive is organised by CHAPTERS.
//
//  The single most important rule here, straight from the master document:
//
//      "Cycle Day remains the backend truth. The user experiences something
//       different."                                        - TTC master, §10
//
//  So this file holds both halves and keeps them apart on purpose:
//
//    * the BIOLOGY  - cycle day, estimated ovulation, fertility level. Honest,
//      medically conventional, and never shown raw in calm copy.
//    * the EMOTION  - which Chapter the couple is living in today.
//
//  Deliberately pure Dart (no Flutter import) so the whole spine is unit
//  testable without a widget harness. Stores wrap it; screens never re-derive.
//
//  A note on why chapters LOOP. Chapters 2-4 ride the cycle, so a couple who
//  did not conceive this month moves from "The Waiting Days" back to "Knowing
//  Your Rhythm". That is the honest shape of trying to conceive. It must never
//  be rendered as regression - which is why this engine exposes progress WITHIN
//  a chapter and never a global "Chapter 2 of 5" bar that can travel backwards.
//  See docs/TTC-SPEC.md for the decision record.
// =============================================================================

import 'ttc_care_pathway.dart';

export 'ttc_care_pathway.dart';

/// The five chapters a couple moves through. Emotional, not biological.
enum TtcChapter {
  /// Building healthy routines, understanding fertility, meeting experts.
  preparingTogether,

  /// Cycles, ovulation, hormones, body literacy - without obsession.
  knowingYourRhythm,

  /// The fertile window, partner support, communication, medical guidance.
  tryingTogether,

  /// The hardest stretch. Learn, reflect, rest, connect - never a countdown.
  theWaitingDays,

  /// Positive test. The quiet hand-off into Pregnancy.
  aNewBeginning,
}

/// How sure we are about the ovulation estimate.
///
/// "Confidence replaces certainty." - TTC master, §3.5. ParentVeda never says
/// "you WILL ovulate tomorrow"; it says what it can honestly support.
enum OvulationConfidence {
  /// Not enough information to estimate at all. We say so rather than guess.
  unknown,

  /// A single cycle, or cycles that vary too much to lean on.
  low,

  /// A few consistent cycles - a calendar estimate worth showing.
  medium,

  /// Confirmed by a positive LH test or a recorded temperature shift.
  high,
}

/// How fertile a given day is. Deliberately NOT green / red / danger.
/// "Everything remains emotionally calm." - TTC master, §3.6
enum FertilityLevel { low, medium, high, peak }

// TtcPath and the pathway rules now live in ttc_care_pathway.dart, re-exported
// here so every existing import keeps working. They moved because *which
// treatment* turned out to be the wrong thing to branch on - see the header of
// that file.

/// Everything the engine needs to answer "where are they today?".
///
/// All fields are nullable or defaulted on purpose: a couple who has just
/// arrived and logged nothing is a completely valid input, and must still get
/// a real answer rather than an error or an empty screen.
class TtcJourneyState {
  const TtcJourneyState({
    this.journeyStart,
    this.lastPeriodStart,
    this.cycleLengths = const [],
    this.pregnancyConfirmed = false,
    this.lhPositiveDay,
    this.temperatureShiftDay,
    this.ownership = TimingOwnership.parentveda,
    this.today,
  });

  /// The day the couple started their TTC journey in ParentVeda.
  final DateTime? journeyStart;

  /// First day of the most recent period. Cycle day 1.
  final DateTime? lastPeriodStart;

  /// Lengths (in days) of completed cycles, oldest first.
  final List<int> cycleLengths;

  /// Set once a positive test is recorded. Ends the TTC stage.
  final bool pregnancyConfirmed;

  /// Cycle day a positive LH (ovulation strip) was logged this cycle, if any.
  final int? lhPositiveDay;

  /// Cycle day a sustained basal-temperature rise was seen this cycle, if any.
  final int? temperatureShiftDay;

  /// Who owns the timing of this cycle. THE fertility rule.
  ///
  /// The engine refuses to publish an ovulation day or a fertility grade unless
  /// this is [TimingOwnership.parentveda]. Enforcing it here rather than in
  /// each screen is what makes it impossible for a surface to show one by
  /// accident - and it is why the three-tier model lives in the engine input
  /// rather than in a widget.
  final TimingOwnership ownership;

  /// Injectable "now" so tests never depend on the wall clock.
  final DateTime? today;

  DateTime get _now {
    final t = today ?? DateTime.now();
    return DateTime(t.year, t.month, t.day);
  }
}

/// The engine's answer: what is true today, in both languages of the product.
class TtcToday {
  const TtcToday({
    required this.chapter,
    required this.cycleDay,
    required this.cycleLength,
    required this.estimatedOvulationDay,
    required this.confidence,
    required this.fertility,
    required this.daysIntoChapter,
    required this.chapterLength,
    this.ownership = TimingOwnership.parentveda,
  });

  final TtcChapter chapter;

  /// Day 1 = first day of the last period. Null when no period is logged.
  /// BACKEND TRUTH - never render this raw in the calm surfaces.
  final int? cycleDay;

  /// The cycle length we are reasoning with (logged average, or the 28-day
  /// default when we have nothing better).
  final int cycleLength;

  /// Estimated cycle day of ovulation. Null when we refuse to guess.
  final int? estimatedOvulationDay;

  final OvulationConfidence confidence;

  /// Null when confidence is [OvulationConfidence.unknown] - we would rather
  /// show nothing than a fertility level we cannot stand behind.
  final FertilityLevel? fertility;

  /// Position inside the current chapter, for a progress bar that only ever
  /// moves forward within the chapter it belongs to.
  final int daysIntoChapter;
  final int chapterLength;

  /// Who owns the timing today. Screens read [behaviour] off this to decide
  /// what to show, and to explain WHY there is no ovulation day rather than
  /// falling back to "still learning your rhythm" - which would be untrue on a
  /// clinic cycle. We are not learning; we are deferring.
  final TimingOwnership ownership;

  /// What this tier turns on and off. The one thing screens should branch on.
  TtcPathwayBehaviour get behaviour => TtcPathwayBehaviour(ownership);

  /// Convenience for the many surfaces that only care "is anyone else
  /// involved?" - a card heading, a disclaimer. Anything that changes what is
  /// COMPUTED must use [behaviour] instead.
  bool get clinicInvolved => ownership != TimingOwnership.parentveda;

  /// 0.0 - 1.0 progress through the current chapter.
  double get chapterProgress =>
      chapterLength <= 0 ? 0 : (daysIntoChapter / chapterLength).clamp(0.0, 1.0);

  /// True while we are inside the seven-day fertile window.
  bool get inFertileWindow =>
      fertility != null && fertility != FertilityLevel.low;
}

/// The calendar-method engine.
///
/// The luteal phase (ovulation → next period) is far more stable across women
/// than the follicular phase, so ovulation is estimated backwards from the
/// NEXT expected period rather than forwards from the last one. This is why a
/// 26-day cycle and a 34-day cycle both land somewhere sensible instead of
/// everyone being told "day 14".
class TtcChapterEngine {
  const TtcChapterEngine();

  /// Days from ovulation to the next period. Clinically 12-16; 14 is the
  /// conventional midpoint and the one every calendar method uses.
  static const int lutealPhaseDays = 14;

  /// Used only when nothing has been logged yet. Never presented as *her*
  /// cycle length - the UI says "most cycles" when it is leaning on this.
  static const int defaultCycleLength = 28;

  /// A journey younger than this is still Chapter 1 regardless of cycle data.
  /// Preparing Together is about folic acid, lifestyle and first appointments,
  /// which genuinely is the opening stretch of a journey rather than a phase
  /// of a cycle.
  static const int preparingChapterDays = 28;

  /// Cycles varying by more than this are treated as irregular, which caps
  /// confidence. PCOS and irregular cycles must still feel understood - so we
  /// lower confidence rather than hiding the tool or inventing a prediction.
  static const int irregularVarianceDays = 8;

  /// The average cycle length we should reason with.
  int cycleLengthFor(TtcJourneyState s) {
    if (s.cycleLengths.isEmpty) return defaultCycleLength;
    // Recent cycles describe her better than cycles from a year ago.
    final recent = s.cycleLengths.length <= 6
        ? s.cycleLengths
        : s.cycleLengths.sublist(s.cycleLengths.length - 6);
    final sum = recent.reduce((a, b) => a + b);
    return (sum / recent.length).round();
  }

  /// True when logged cycles vary too much to lean on a calendar estimate.
  bool isIrregular(TtcJourneyState s) {
    if (s.cycleLengths.length < 2) return false;
    final lo = s.cycleLengths.reduce((a, b) => a < b ? a : b);
    final hi = s.cycleLengths.reduce((a, b) => a > b ? a : b);
    return (hi - lo) > irregularVarianceDays;
  }

  /// Cycle day today. Day 1 is the first day of the last period.
  int? cycleDay(TtcJourneyState s) {
    final start = s.lastPeriodStart;
    if (start == null) return null;
    final from = DateTime(start.year, start.month, start.day);
    final days = s._now.difference(from).inDays;
    if (days < 0) return null; // a future date is bad input, not day 1
    return days + 1;
  }

  /// A recorded gap long enough that it is more likely a cycle she did not log,
  /// or one where she did not ovulate, than a real cycle of that length.
  ///
  /// Either way the history underneath our arithmetic is thinner than the
  /// number of entries suggests, so we should be less sure - not more sure
  /// because there is "more data".
  bool hasUnreliableHistory(TtcJourneyState s) =>
      s.cycleLengths.any((l) => l > 45);

  /// The current cycle has run well past where her own history says it should
  /// have ended.
  ///
  /// Could be a late period, a missed log, or a cycle without ovulation. We
  /// cannot tell which, and that is exactly the point: any window we draw from
  /// here is arithmetic on an assumption that has already been contradicted.
  bool isCurrentCycleOverdue(TtcJourneyState s) {
    final day = cycleDay(s);
    if (day == null) return false;
    return day > cycleLengthFor(s) + lutealPhaseDays;
  }

  /// How sure we are about the ovulation estimate.
  ///
  /// Everything here is DERIVED from what she has already logged. There is no
  /// questionnaire behind it, and there should not be: asking six screening
  /// questions to grade our own confidence would trade her time for our
  /// comfort. Where the data is thin we say so instead.
  OvulationConfidence confidence(TtcJourneyState s) {
    if (s.lastPeriodStart == null) return OvulationConfidence.unknown;
    // A body signal beats any calendar arithmetic - including the doubts below,
    // because an LH strip this cycle is evidence about THIS cycle.
    if (s.lhPositiveDay != null || s.temperatureShiftDay != null) {
      return OvulationConfidence.high;
    }
    if (isCurrentCycleOverdue(s) || hasUnreliableHistory(s)) {
      return OvulationConfidence.low;
    }
    if (isIrregular(s)) return OvulationConfidence.low;
    if (s.cycleLengths.length >= 2) return OvulationConfidence.medium;
    if (s.cycleLengths.length == 1) return OvulationConfidence.low;
    // A logged period but no completed cycle: we can count days, but the
    // 28-day default is an assumption about her, so we say low.
    return OvulationConfidence.low;
  }

  /// Estimated cycle day of ovulation, or null when we will not guess.
  int? estimatedOvulationDay(TtcJourneyState s) {
    if (s.lastPeriodStart == null) return null;
    // A recorded body signal wins outright. A temperature shift is seen the
    // day AFTER ovulation, so it is read back by one day.
    if (s.lhPositiveDay != null) return s.lhPositiveDay! + 1;
    if (s.temperatureShiftDay != null) return s.temperatureShiftDay! - 1;
    if (confidence(s) == OvulationConfidence.unknown) return null;
    final day = cycleLengthFor(s) - lutealPhaseDays;
    return day < 1 ? null : day;
  }

  /// Graded fertility for a given cycle day. Returns null when we hold back.
  ///
  /// Sperm survive around five days; the egg around a day. So the window is
  /// ovulation-5 → ovulation+1, graded rather than flagged.
  FertilityLevel? fertilityFor(TtcJourneyState s, int? day) {
    // Unless her body owns the timing, there is no calendar answer worth
    // giving. Refusing here means no screen can render one, however it asks.
    if (!TtcPathwayBehaviour(s.ownership).showsFertilityWindow) return null;
    final ov = estimatedOvulationDay(s);
    if (day == null || ov == null) return null;
    if (confidence(s) == OvulationConfidence.unknown) return null;
    final offset = day - ov; // negative = before ovulation
    if (offset == -1 || offset == 0) return FertilityLevel.peak;
    if (offset == -3 || offset == -2 || offset == 1) return FertilityLevel.high;
    if (offset == -5 || offset == -4) return FertilityLevel.medium;
    return FertilityLevel.low;
  }

  /// Days since the journey began. Null when we were never told.
  int? daysIntoJourney(TtcJourneyState s) {
    final start = s.journeyStart;
    if (start == null) return null;
    final from = DateTime(start.year, start.month, start.day);
    final days = s._now.difference(from).inDays;
    return days < 0 ? 0 : days;
  }

  /// The whole answer for today.
  TtcToday resolve(TtcJourneyState s) {
    final len = cycleLengthFor(s);
    final day = cycleDay(s);
    final ov = estimatedOvulationDay(s);
    final conf = confidence(s);
    final fert = fertilityFor(s, day);

    // `ov` is still needed INTERNALLY to place a couple in the right chapter -
    // the waiting days are just as real during an IVF cycle - but it is only
    // published when her body owns the timing. So the chapters keep working
    // while no screen can show a date that might contradict a clinic.
    final publishedOv =
        TtcPathwayBehaviour(s.ownership).predictsOvulation ? ov : null;

    // --- Chapter 5: a positive test ends the stage, whatever the cycle says.
    if (s.pregnancyConfirmed) {
      return TtcToday(
        chapter: TtcChapter.aNewBeginning,
        cycleDay: day,
        cycleLength: len,
        estimatedOvulationDay: publishedOv,
        confidence: conf,
        fertility: fert,
        ownership: s.ownership,
        daysIntoChapter: 0,
        chapterLength: 1,
      );
    }

    // --- Chapter 1: the opening stretch, or no cycle data to ride yet.
    final into = daysIntoJourney(s);
    final young = into != null && into < preparingChapterDays;
    if (day == null || ov == null || young) {
      return TtcToday(
        chapter: TtcChapter.preparingTogether,
        cycleDay: day,
        cycleLength: len,
        estimatedOvulationDay: publishedOv,
        confidence: conf,
        fertility: fert,
        ownership: s.ownership,
        daysIntoChapter: (into ?? 0).clamp(0, preparingChapterDays),
        chapterLength: preparingChapterDays,
      );
    }

    // --- Chapters 2-4 ride the cycle.
    final windowOpens = ov - 5;
    final windowCloses = ov + 1;

    if (day < windowOpens) {
      // Chapter 2 - Knowing Your Rhythm: day 1 until the window opens.
      return TtcToday(
        chapter: TtcChapter.knowingYourRhythm,
        cycleDay: day,
        cycleLength: len,
        estimatedOvulationDay: publishedOv,
        confidence: conf,
        fertility: fert,
        ownership: s.ownership,
        daysIntoChapter: day - 1,
        chapterLength: (windowOpens - 1).clamp(1, 400),
      );
    }

    if (day <= windowCloses) {
      // Chapter 3 - Trying Together: the seven-day fertile window.
      return TtcToday(
        chapter: TtcChapter.tryingTogether,
        cycleDay: day,
        cycleLength: len,
        estimatedOvulationDay: publishedOv,
        confidence: conf,
        fertility: fert,
        ownership: s.ownership,
        daysIntoChapter: day - windowOpens,
        chapterLength: windowCloses - windowOpens,
      );
    }

    // Chapter 4 - The Waiting Days: the luteal stretch to the next period.
    // Clamped so an overdue period never produces progress past 100%, which
    // would read as "you are late" - exactly the anxiety we refuse to create.
    final waitLength = (len - windowCloses).clamp(1, 400);
    return TtcToday(
      chapter: TtcChapter.theWaitingDays,
      cycleDay: day,
      cycleLength: len,
      estimatedOvulationDay: ov,
      confidence: conf,
      fertility: fert,
      daysIntoChapter: (day - windowCloses).clamp(0, waitLength),
      chapterLength: waitLength,
    );
  }
}

// ---- chapter copy -----------------------------------------------------------
//  Bilingual, following the app's _p(english, hinglish) convention. Hinglish is
//  real conversational Hinglish in Latin script, addressing her warmly - never
//  formal Hindi, never transliterated English.

extension TtcChapterCopy on TtcChapter {
  /// 1-based number. Used for content lookup and the Journey Map - NOT for a
  /// progress bar (see the note at the top of this file).
  int get number => index + 1;

  String title(bool hinglish) {
    switch (this) {
      case TtcChapter.preparingTogether:
        return hinglish ? 'Saath mein taiyaari' : 'Preparing Together';
      case TtcChapter.knowingYourRhythm:
        return hinglish ? 'Apni rhythm samajhna' : 'Knowing Your Rhythm';
      case TtcChapter.tryingTogether:
        return hinglish ? 'Saath mein koshish' : 'Trying Together';
      case TtcChapter.theWaitingDays:
        return hinglish ? 'Intezaar ke din' : 'The Waiting Days';
      case TtcChapter.aNewBeginning:
        return hinglish ? 'Ek nayi shuruaat' : 'A New Beginning';
    }
  }

  /// The one line under the chapter name on the Today hero.
  String tagline(bool hinglish) {
    switch (this) {
      case TtcChapter.preparingTogether:
        return hinglish
            ? 'Chhote badlaav, dono ke liye. Koi jaldi nahi.'
            : 'Small changes, for both of you. There is no rush.';
      case TtcChapter.knowingYourRhythm:
        return hinglish
            ? 'Apne body ko samajhna - bina uspe nazar gadaaye.'
            : 'Learning your body - without watching it too closely.';
      case TtcChapter.tryingTogether:
        return hinglish
            ? 'Agar aaj dono ko sahi lage, toh yeh naturally fertile din hain.'
            : 'If this feels right for you both, these are naturally fertile days.';
      case TtcChapter.theWaitingDays:
        return hinglish
            ? 'Intezaar mushkil hai. In dino ko apne liye rakhiye.'
            : 'Waiting is hard. Let these days be for you, not for counting.';
      case TtcChapter.aNewBeginning:
        return hinglish
            ? 'Ek khoobsurat naya chapter shuru hota hai.'
            : 'A beautiful new chapter begins.';
    }
  }

  /// What comes after this chapter, and what brings it - the hero's "next" line.
  ///
  /// Both shipped stages answer this above the fold: pregnancy with "Baby's
  /// almost here", parenting with "Next: the peak, and the first smile, around
  /// 1 month." TTC answered it nowhere, which is why a chapter that lasts
  /// twenty-eight days read as the app having stopped.
  ///
  /// Deliberately names a TRIGGER rather than a date. Chapters 2-4 turn with
  /// the cycle, and the honest answer to "when" is "when your period arrives",
  /// not a countdown we would then have to be wrong about.
  String nextUp(bool hinglish) {
    switch (this) {
      case TtcChapter.preparingTogether:
        return hinglish
            ? 'Aage: Apni rhythm samajhna - jaise hi aapka agla period shuru ho, use log karein'
            : 'Next: Knowing Your Rhythm — from the day you log your next period';
      case TtcChapter.knowingYourRhythm:
        return hinglish
            ? 'Aage: Saath mein koshish - jab aapke fertile din paas aayenge'
            : 'Next: Trying Together — as your fertile days come round';
      case TtcChapter.tryingTogether:
        return hinglish
            ? 'Aage: Intezaar ke din - ovulation ke baad'
            : 'Next: The Waiting Days — after ovulation passes';
      case TtcChapter.theWaitingDays:
        return hinglish
            ? 'Aage: ya toh ek nayi shuruaat, ya agla cycle. Dono theek hain.'
            : 'Next: either a new beginning, or the next cycle. Both are fine.';
      case TtcChapter.aNewBeginning:
        return hinglish
            ? 'Aage: pregnancy ka safar, jab aap taiyaar hon'
            : 'Next: the pregnancy journey, whenever you are ready';
    }
  }

  /// What this chapter is asking of them - the hero's "Current Focus".
  String focus(bool hinglish) {
    switch (this) {
      case TtcChapter.preparingTogether:
        return hinglish ? 'Sehat aur aadatein' : 'Health and habits';
      case TtcChapter.knowingYourRhythm:
        return hinglish ? 'Body ki samajh' : 'Body literacy';
      case TtcChapter.tryingTogether:
        return hinglish ? 'Judaav aur samay' : 'Connection and timing';
      case TtcChapter.theWaitingDays:
        return hinglish ? 'Aaram aur sambhaal' : 'Rest and self-care';
      case TtcChapter.aNewBeginning:
        return hinglish ? 'Aage ka safar' : 'The journey ahead';
    }
  }

  /// One concrete thing worth doing in this chapter - the "Current Goal".
  String goal(bool hinglish) {
    switch (this) {
      case TtcChapter.preparingTogether:
        return hinglish
            ? 'Folic acid shuru karein aur ek baar doctor se milein'
            : 'Start folic acid and see a doctor once';
      case TtcChapter.knowingYourRhythm:
        return hinglish
            ? 'Apne cycle ke signals pehchaanna seekhein'
            : 'Learn to recognise your own cycle signals';
      case TtcChapter.tryingTogether:
        return hinglish
            ? 'Ek-doosre ke saath rahiye - pressure ke bina'
            : 'Stay close to each other - without pressure';
      case TtcChapter.theWaitingDays:
        return hinglish
            ? 'Kuch aisa karein jo aapko achha lage'
            : 'Do something that is just for you';
      case TtcChapter.aNewBeginning:
        return hinglish
            ? 'Apni pehli pregnancy appointment book karein'
            : 'Book your first pregnancy appointment';
    }
  }
}

extension FertilityLevelCopy on FertilityLevel {
  /// Calm words only. Never "danger", never "you missed it".
  String label(bool hinglish) {
    switch (this) {
      case FertilityLevel.low:
        return hinglish ? 'Kam' : 'Low';
      case FertilityLevel.medium:
        return hinglish ? 'Thodi zyada' : 'Medium';
      case FertilityLevel.high:
        return hinglish ? 'Zyada' : 'High';
      case FertilityLevel.peak:
        return hinglish ? 'Sabse zyada' : 'Peak';
    }
  }
}

extension OvulationConfidenceCopy on OvulationConfidence {
  /// How the estimate is introduced. Always hedged - the product refuses to
  /// promise a day it cannot know.
  String phrase(bool hinglish) {
    switch (this) {
      case OvulationConfidence.unknown:
        return hinglish
            ? 'Abhi andaaza lagane ke liye kaafi jaankari nahi hai'
            : 'Not enough information to estimate yet';
      case OvulationConfidence.low:
        return hinglish
            ? 'Yeh ek shuruaati andaaza hai'
            : 'This is an early estimate';
      case OvulationConfidence.medium:
        return hinglish
            ? 'Aapke cycles ke hisaab se'
            : 'Based on your cycles so far';
      case OvulationConfidence.high:
        return hinglish
            ? 'Aapke apne body signals se confirm hua'
            : 'Confirmed by your own body signals';
    }
  }
}
