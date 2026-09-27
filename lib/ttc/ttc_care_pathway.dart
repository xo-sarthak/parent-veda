// =============================================================================
//  Care pathway - WHO owns the timing of this cycle
// -----------------------------------------------------------------------------
//  The single most important fertility rule in the product. Every surface that
//  might show an ovulation date, a fertile window, or a countdown reads this.
//
//  ---------------------------------------------------------------------------
//  WHY TREATMENT TYPE WAS THE WRONG ABSTRACTION
//
//  The first version keyed everything off TtcPath - natural / ovulation
//  induction / IUI / IVF / FET - and treated "anything except natural" as
//  clinic-run. That was a clean line to draw in code and the wrong line to draw
//  in medicine, because the same treatment behaves in opposite ways:
//
//    Letrozole, no monitoring, no trigger, told to time intercourse
//      → her body decides when. ParentVeda SHOULD estimate the window.
//
//    Letrozole, follicular scans, trigger shot, timed intercourse
//      → the clinic decides when. ParentVeda must NOT estimate.
//
//  Both are "ovulation induction". Same for natural-cycle FET versus a fully
//  medicated one. So the question that actually matters is not *what treatment
//  is this* but *who owns the timing*.
//
//  ---------------------------------------------------------------------------
//  THREE TIERS, NOT TWO
//
//  The first fix was binary - predict, or say nothing - and that over-corrected.
//  A woman on monitored letrozole with timed intercourse was shown no fertility
//  information at all, when her own LH surge is exactly what her clinic is
//  timing around. The middle tier is the point of this file.
//
//  ---------------------------------------------------------------------------
//  DELIBERATELY IN CODE, NOT IN A TABLE OR A CMS
//
//  There are a handful of these, they are identical for every user, and they
//  change with clinical understanding rather than per-tenant. Putting them in
//  the database would give a clinical safety rule a network dependency - and
//  local-first says serve the cached value, which for a safety rule is exactly
//  the wrong answer. Making them editable from a CMS would let a non-engineer
//  switch the fertility window back on for IVF from a dropdown.
//
//  They are versioned, tested code. Adding a pathway is a small edit here plus
//  a test, which is the right amount of friction for something that decides
//  whether we contradict somebody's doctor.
// =============================================================================

/// Who decides when ovulation (or transfer) happens on this cycle.
enum TimingOwnership {
  /// Her body decides, unobserved. ParentVeda estimates, and everything her
  /// body tells her is worth logging.
  parentveda,

  /// Her body still decides, but a clinic is watching and acting on it -
  /// monitored letrozole, natural-cycle FET, an IUI timed to her own surge.
  ///
  /// We do NOT predict, because the clinic's scan beats our arithmetic. But her
  /// own signals stay meaningful, because they are what the clinic is timing
  /// around - so logging stays on. This is the tier the binary version missed.
  clinicGuided,

  /// Medication decides and the clinic schedules it - IVF, ICSI, a medicated
  /// FET. Nothing of her natural cycle is informative here, so nothing is
  /// predicted and nothing is asked for.
  clinicControlled,
}

/// The medical pathway, as she describes it. Kept because it is what a person
/// actually knows the name of - but it no longer drives behaviour on its own.
enum TtcPath { natural, ovulationInduction, iui, ivf, frozenEmbryoTransfer }

extension TtcPathCopy on TtcPath {
  String label(bool hinglish) {
    switch (this) {
      case TtcPath.natural:
        return hinglish ? 'Naturally koshish' : 'Trying naturally';
      case TtcPath.ovulationInduction:
        return hinglish
            ? 'Ovulation induction (dawai se)'
            : 'Ovulation induction';
      case TtcPath.iui:
        return 'IUI';
      case TtcPath.ivf:
        return 'IVF';
      case TtcPath.frozenEmbryoTransfer:
        return hinglish ? 'Frozen embryo transfer' : 'Frozen embryo transfer';
    }
  }

  /// What we assume before she has answered the two questions.
  ///
  /// These are DEFAULTS, not conclusions - every one of them is overridable by
  /// her answers, which is the whole reason the questions exist. They are set
  /// to the safer side: where a pathway is usually clinic-run we assume it is,
  /// because wrongly showing a window is worse than wrongly hiding one.
  bool get defaultMonitored {
    switch (this) {
      case TtcPath.natural:
        return false;
      case TtcPath.ovulationInduction:
        // Genuinely split in practice, which is exactly why we ask.
        return true;
      case TtcPath.iui:
      case TtcPath.ivf:
      case TtcPath.frozenEmbryoTransfer:
        return true;
    }
  }

  bool get defaultMedicated {
    switch (this) {
      case TtcPath.natural:
      case TtcPath.ovulationInduction:
      case TtcPath.iui:
        return false;
      case TtcPath.ivf:
        return true;
      case TtcPath.frozenEmbryoTransfer:
        // Most FETs are medicated; natural-cycle FET is the exception she can
        // declare.
        return true;
    }
  }

  /// True where the two questions actually change the answer, so the app only
  /// asks when asking is worth something.
  bool get answersMatter => this != TtcPath.natural && this != TtcPath.ivf;
}

/// The pathway as the app understands it: what she is on, plus the two facts
/// that decide who owns the timing.
class TtcCarePathway {
  const TtcCarePathway({
    required this.path,
    this.clinicMonitors,
    this.medicationControlsOvulation,
  });

  final TtcPath path;

  /// "Is your clinic tracking this cycle with scans or blood tests?"
  ///
  /// Null until she answers - the pathway's default is used instead. Genuinely
  /// unknowable to us, which is why the product is allowed to ask it: no amount
  /// of cycle history reveals whether somebody is being scanned.
  final bool? clinicMonitors;

  /// "Are you taking medication that controls WHEN you ovulate?" - a trigger
  /// shot, or a fully medicated cycle.
  final bool? medicationControlsOvulation;

  bool get monitored => clinicMonitors ?? path.defaultMonitored;
  bool get medicated =>
      medicationControlsOvulation ?? path.defaultMedicated;

  /// True once she has told us, rather than us assuming from the pathway.
  bool get isAnswered =>
      clinicMonitors != null && medicationControlsOvulation != null;

  /// THE rule. Everything else in the product reads this.
  ///
  /// ⚠️ SINCE 2026-09-26 THIS IS THE TIER, NOT THE VERDICT. The app reads
  /// `TtcStore.ownership`, which asks [ttcTimingOwnershipFromEvidence]: this
  /// label-and-answers tier applies only once the treatment tracker holds a
  /// clinic date for the cycle. Without one, the cycle is hers.
  TimingOwnership get ownership {
    // Medication deciding the moment is the strongest signal there is - it does
    // not matter what the pathway is called.
    if (medicated) return TimingOwnership.clinicControlled;
    // Her own cycle, but somebody is watching it and will act on what they see.
    if (monitored) return TimingOwnership.clinicGuided;
    return TimingOwnership.parentveda;
  }

  TtcCarePathway copyWith({
    TtcPath? path,
    bool? clinicMonitors,
    bool? medicationControlsOvulation,
    bool clearAnswers = false,
  }) =>
      TtcCarePathway(
        path: path ?? this.path,
        clinicMonitors:
            clearAnswers ? null : (clinicMonitors ?? this.clinicMonitors),
        medicationControlsOvulation: clearAnswers
            ? null
            : (medicationControlsOvulation ?? this.medicationControlsOvulation),
      );
}

/// What each tier turns on and off.
///
/// Seven flags, every one of them clinically motivated. Deliberately NOT a
/// general configuration object: things like which cards appear on Today, or
/// how the community behaves, are not in here, because the product's own rule
/// is that personalisation changes content and never navigation - everyone
/// learns one ParentVeda, and a woman who used the app during IVF should not be
/// lost in it when she switches to trying naturally.
class TtcPathwayBehaviour {
  const TtcPathwayBehaviour(this.ownership);

  final TimingOwnership ownership;

  bool get _own => ownership == TimingOwnership.parentveda;
  bool get _controlled => ownership == TimingOwnership.clinicControlled;

  /// May the engine publish an estimated ovulation day?
  bool get predictsOvulation => _own;

  /// May any surface show a graded fertile window?
  bool get showsFertilityWindow => _own;

  /// Are HER OWN signals - LH strips, temperature - worth recording?
  ///
  /// True in the middle tier as well, and that is the whole improvement: on a
  /// natural-cycle FET or an IUI timed to her surge, her LH is precisely what
  /// the clinic is acting on. Only a fully medicated cycle makes it noise.
  bool get logsBodySignals => !_controlled;

  /// Do we show the clinic's own milestones - trigger, retrieval, transfer?
  bool get showsClinicTimeline => !_own;

  /// May we count down to her next period?
  ///
  /// Only when nobody else is involved. Luteal support delays menses, so a
  /// "your period is late" on any clinic cycle means nothing and reads as hope.
  bool get countsToPeriod => _own;

  /// The two-week wait counts to the blood test instead.
  bool get countsToBeta => !_own;

  /// May we ever send an ovulation notification?
  ///
  /// There is no such notification in the app today. The flag exists so that
  /// when one is written it cannot be added without meeting this rule.
  bool get sendsOvulationReminders => _own;
}

/// Convenience: the behaviour for a pathway.
TtcPathwayBehaviour ttcBehaviourFor(TtcCarePathway pathway) =>
    TtcPathwayBehaviour(pathway.ownership);

// =============================================================================
//  THE EVIDENCE FOR "A CLINIC OWNS THIS CYCLE" — DECIDED 2026-09-26
// -----------------------------------------------------------------------------
//  The user's decision: "clinic ownership = real clinic dates". Until then the
//  app treated a cycle as clinic-run on the strength of the pathway LABEL she
//  tapped in setup (`TtcCarePathway.ownership`, from `path.defaultMedicated` /
//  `defaultMonitored`), and `TtcStore.setPath` clears her two answers, so the
//  label's guess always applied. One stray tap on "IVF" switched the fertile
//  window off everywhere, with the hero as the one exception
//  (`ignoreOwnership`, now retired) — which is how the hero and the cards came
//  to disagree.
//
//  ⚠️ WHAT CHANGED IS THE EVIDENCE, NOT THE RULE. `TimingOwnership` and
//  `TtcPathwayBehaviour` mean exactly what they meant: when a clinic owns the
//  timing we publish no window, no due date and no "late", and never compete
//  with their dates. What changed is what counts as proof that a clinic owns
//  it: a date her clinic gave her for THIS cycle (a stimulation start, a
//  trigger, a retrieval or IUI, a transfer or a blood test), entered in the
//  treatment tracker. A label with no dates behind it is her own cycle, top of
//  the screen and cards alike, because nothing a clinic said is there to
//  contradict.
//
//  The tier (guided or controlled) still comes from the pathway and her two
//  answers when they name one. When they do not (the label is "trying
//  naturally", yet she has entered clinic dates), the dates choose: a
//  stimulation start, a trigger or a transfer means medication is timing the
//  cycle; a retrieval/IUI or a blood test alone means a clinic is watching it.
//  Both tiers refuse every prediction; the tier only decides whether her own
//  body signals are still worth logging.
//
//  Pure, like everything in this file: the caller gathers the dates
//  (`TtcStore.ownershipOfCycle`), this decides.
// =============================================================================

/// Who owns the timing of one cycle, from the evidence.
///
/// [hasClinicDates] — the treatment tracker holds at least one clinic date
/// inside this cycle. [medicationDated] — one of those is a stimulation start,
/// a trigger or a transfer.
TimingOwnership ttcTimingOwnershipFromEvidence({
  required TtcCarePathway pathway,
  required bool hasClinicDates,
  bool medicationDated = false,
}) {
  if (!hasClinicDates) return TimingOwnership.parentveda;
  final labelled = pathway.ownership;
  if (labelled != TimingOwnership.parentveda) return labelled;
  return medicationDated
      ? TimingOwnership.clinicControlled
      : TimingOwnership.clinicGuided;
}

extension TimingOwnershipCopy on TimingOwnership {
  /// The value sent to Ask Veda, and stored. Stable - renaming needs a
  /// migration.
  String get id {
    switch (this) {
      case TimingOwnership.parentveda:
        return 'parentveda';
      case TimingOwnership.clinicGuided:
        return 'clinic_guided';
      case TimingOwnership.clinicControlled:
        return 'clinic_controlled';
    }
  }

  static TimingOwnership? fromId(String? id) {
    switch (id) {
      case 'parentveda':
        return TimingOwnership.parentveda;
      case 'clinic_guided':
        return TimingOwnership.clinicGuided;
      case 'clinic_controlled':
        return TimingOwnership.clinicControlled;
      default:
        return null;
    }
  }

  String title(bool hi) {
    switch (this) {
      case TimingOwnership.parentveda:
        return hi ? 'Aapka apna cycle' : 'Your own cycle';
      case TimingOwnership.clinicGuided:
        return hi
            ? 'Aapki clinic aapke cycle par nazar rakh rahi hai'
            : 'Your clinic is watching this cycle';
      case TimingOwnership.clinicControlled:
        return hi
            ? 'Ye cycle aapki clinic chala rahi hai'
            : 'Your clinic is running this cycle';
    }
  }

  String body(bool hi) {
    switch (this) {
      case TimingOwnership.parentveda:
        return hi
            ? 'Aapka body hi tay karta hai kab. Hum uska andaaza lagate hain aur imaandaari se batate hain ki kitna pakka hai.'
            : "Your body decides when. We estimate it, and we always tell you how sure we are.";
      case TimingOwnership.clinicGuided:
        return hi
            ? 'Ovulation aapka apna hai, lekin aapki clinic use scan se dekh rahi hai - aur unka scan hamare hisaab se behtar hai. Isliye hum koi date nahi batate. Aapke apne signals log karte rahiye: clinic unhi ke hisaab se timing tay karti hai.'
            : "You still ovulate on your own, but your clinic is watching it on a scan. Their scan is more accurate than our maths, so we don't give you a date. Keep logging your own signals, because they're what your clinic is timing things around.";
      case TimingOwnership.clinicControlled:
        return hi
            ? 'Is cycle mein ovulation dawai se hota hai aur clinic uska samay tay karti hai. Calendar ka andaaza unki baat se alag ho sakta hai, isliye hum koi nahi dete. Unki dates hi asli hain.'
            : "On this cycle, medicine causes ovulation and your clinic sets the timing. A calendar estimate could disagree with them, so we don't give one. Their dates are the ones that count.";
    }
  }
}
