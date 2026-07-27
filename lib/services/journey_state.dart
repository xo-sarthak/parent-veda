// =============================================================================
//  JourneyState - one place to ask where a family is and who owns what
// -----------------------------------------------------------------------------
//  Answers five questions, in one call, across every life stage:
//
//    1. What life stage are they in?
//    2. What care pathway are they following?
//    3. Who owns clinical decisions right now?
//    4. What is the next meaningful milestone?
//    5. What may ParentVeda infer, and what must come from a clinician?
//
//  Questions 1-3 already had answers scattered across LifeStageStore and the
//  TTC pathway. Questions 4 and 5 did not, and 5 is the important one: it was
//  a TTC-only idea when it is really a cross-stage principle. Pregnancy and
//  parenting both have facts a clinician owns, and nothing named that before.
//
//  ---------------------------------------------------------------------------
//  WHAT THIS DELIBERATELY IS NOT
//
//  It is a READ MODEL, not an engine that drives screens. It owns no state of
//  its own - every value is composed from stores that already exist - which is
//  the property that stops it drifting from them. Screens ASK it; it never
//  pushes.
//
//  It also does not decide what a screen renders or which cards appear. That
//  would be personalising structure, which the product forbids: personalisation
//  changes content, ranking and order, never navigation, because everyone has
//  to learn one ParentVeda.
//
//  ---------------------------------------------------------------------------
//  WHY IT TAKES ITS INPUTS RATHER THAN READING EVERYTHING
//
//  PregnancyController is constructed in main.dart and threaded down rather
//  than exposed as a singleton, so this cannot reach it. Pretending otherwise
//  would mean silently reporting "no pregnancy milestone" for every pregnant
//  user. Instead the caller passes what only the caller has, and the resolver
//  stays pure and testable - the same shape as TtcChapterEngine.
// =============================================================================

import '../ttc/ttc_chapter.dart'; // re-exports ttc_care_pathway
import '../ttc/ttc_store.dart';
import '../ttc/ttc_treatment_store.dart';
import 'life_stage_store.dart';

/// Who owns clinical decisions right now.
///
/// Deliberately broader than TTC's [TimingOwnership], which is specifically
/// about the timing of ovulation. This is about clinical decisions generally,
/// and it is the concept the other stages will need as they grow.
enum ClinicalOwnership {
  /// ParentVeda may infer, estimate and suggest, saying how sure it is.
  parentveda,

  /// A clinician is involved and their answer wins where the two differ. We
  /// keep helping around the edges - logging, records, questions to ask.
  ///
  /// What "helping around the edges" means, precisely: we may EXPLAIN a
  /// decision, REMIND about it, and help her PREPARE for it. We may not
  /// recreate, reinterpret or compete with it. Explaining what a dating scan
  /// measures is help; recalculating gestational age after one is not.
  shared,

  /// A clinician owns this entirely. We carry what they said and infer nothing.
  clinic,
}

/// The things ParentVeda might otherwise calculate for itself.
///
/// Each one is a place where being wrong means contradicting somebody's doctor,
/// which is the single failure this product must not have. The IVF fertility
/// window was exactly this kind of mistake, found late; naming the category is
/// how the next one gets found early.
enum Inferable {
  /// When ovulation is likely, and the fertile window around it.
  fertilityTiming,

  /// How far along a pregnancy is, and the due date.
  ///
  /// A dating scan overrides a last-period calculation, and the clinic owns the
  /// scan - so once a scan-derived date exists, ours is not a second opinion.
  gestationalAge,

  /// Whether a child's growth is where it should be.
  growthExpectation,

  /// Whether a child has reached a developmental stage.
  developmentalStage,
}

/// Something worth knowing is coming. Deliberately small: a title the caller
/// already has words for, a date, and where it came from.
class JourneyMilestone {
  const JourneyMilestone({
    required this.id,
    required this.on,
    required this.fromClinic,
  });

  /// A stable key the caller resolves to copy in the right language, rather
  /// than a string baked in here - this file holds no user-facing text.
  final String id;
  final DateTime on;

  /// True when a clinician set this date. Those are facts; ours are estimates,
  /// and a surface showing both should say which is which.
  final bool fromClinic;

  int get daysAway =>
      DateTime(on.year, on.month, on.day)
          .difference(_today())
          .inDays;

  bool get isPast => daysAway < 0;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// What the caller knows. Everything is optional - a family part-way through
/// onboarding is a normal input, not an error.
class JourneyInputs {
  const JourneyInputs({
    this.stage,
    this.pathway,
    this.ttcToday,
    this.nextTreatmentStep,
    this.pregnancyWeek,
    this.dueDateFromClinic = false,
    this.childAgeMonths,
    this.now,
  });

  final LifeStage? stage;

  /// TTC only.
  final TtcCarePathway? pathway;
  final TtcToday? ttcToday;
  final (String, DateTime)? nextTreatmentStep;

  /// Pregnancy only - passed in, because PregnancyController is threaded rather
  /// than a singleton.
  final int? pregnancyWeek;

  /// True once a clinic measured or decided the due date - a dating scan, an
  /// IVF transfer they scheduled, or a date her doctor gave her. From then on
  /// the clinic owns gestational age and our own calculation is not a second
  /// opinion.
  ///
  /// Written by `PregnancyController.dueDateFromClinic`, which learns it from
  /// the method she picks in the Due Date Calculator.
  final bool dueDateFromClinic;

  /// Parenting only.
  final int? childAgeMonths;

  final DateTime? now;
}

/// The answer.
class JourneyState {
  const JourneyState({
    required this.stage,
    required this.ownership,
    required this.pathway,
    required this.nextMilestone,
    required Set<Inferable> mayInferSet,
  }) : _mayInfer = mayInferSet;

  /// Null when they have never declared one. A real state, not a bug - callers
  /// must handle it rather than assuming pregnancy.
  final LifeStage? stage;

  final ClinicalOwnership ownership;

  /// TTC only; null elsewhere.
  final TtcCarePathway? pathway;

  final JourneyMilestone? nextMilestone;

  final Set<Inferable> _mayInfer;

  /// THE question worth asking before showing any calculated number.
  ///
  /// Default-deny: anything not explicitly permitted is refused. A new
  /// [Inferable] added later is therefore safe by default - it stays off until
  /// somebody decides, in code, that inferring it is acceptable.
  bool mayInfer(Inferable what) => _mayInfer.contains(what);

  /// The complement, for surfaces that explain why a number is missing.
  bool mustComeFromClinician(Inferable what) => !mayInfer(what);

  bool get clinicianInvolved => ownership != ClinicalOwnership.parentveda;
}

class JourneyStateEngine {
  const JourneyStateEngine();

  JourneyState resolve(JourneyInputs input) {
    final stage = input.stage;

    switch (stage) {
      case LifeStage.tryingToConceive:
        return _trying(input);
      case LifeStage.pregnancy:
        return _pregnancy(input);
      case LifeStage.parenting:
        return _parenting(input);
      case null:
        // Nothing declared. Infer nothing rather than assuming a stage - the
        // whole point of default-deny.
        return const JourneyState(
          stage: null,
          ownership: ClinicalOwnership.parentveda,
          pathway: null,
          nextMilestone: null,
          mayInferSet: {},
        );
    }
  }

  // ---- trying to conceive ---------------------------------------------------

  JourneyState _trying(JourneyInputs input) {
    final pathway = input.pathway ?? const TtcCarePathway(path: TtcPath.natural);
    final behaviour = ttcBehaviourFor(pathway);

    final ownership = switch (pathway.ownership) {
      TimingOwnership.parentveda => ClinicalOwnership.parentveda,
      TimingOwnership.clinicGuided => ClinicalOwnership.shared,
      TimingOwnership.clinicControlled => ClinicalOwnership.clinic,
    };

    // A clinic's date beats anything we could estimate, so it wins the "next
    // milestone" slot outright.
    JourneyMilestone? next;
    final step = input.nextTreatmentStep;
    if (step != null) {
      next = JourneyMilestone(id: step.$1, on: step.$2, fromClinic: true);
    }

    return JourneyState(
      stage: LifeStage.tryingToConceive,
      ownership: ownership,
      pathway: pathway,
      nextMilestone: next,
      mayInferSet: {
        // The single rule the whole TTC stage turns on.
        if (behaviour.predictsOvulation) Inferable.fertilityTiming,
      },
    );
  }

  // ---- pregnancy ------------------------------------------------------------

  JourneyState _pregnancy(JourneyInputs input) {
    // A dating scan is more accurate than counting from a last period, and the
    // clinic owns the scan. Once one exists, gestational age is theirs - the
    // same shape as the fertility window on a treatment cycle, in the stage
    // where it has not been named before.
    final clinicOwnsDating = input.dueDateFromClinic;

    return JourneyState(
      stage: LifeStage.pregnancy,
      ownership:
          clinicOwnsDating ? ClinicalOwnership.shared : ClinicalOwnership.parentveda,
      pathway: null,
      nextMilestone: null,
      mayInferSet: {
        if (!clinicOwnsDating) Inferable.gestationalAge,
      },
    );
  }

  // ---- parenting ------------------------------------------------------------

  JourneyState _parenting(JourneyInputs input) {
    // Growth and development are described, never diagnosed: the parenting app
    // shows a typical-range band and words on a soft arc rather than a verdict.
    // That is inference we are comfortable with, and the disclaimers already
    // carry the rest.
    return const JourneyState(
      stage: LifeStage.parenting,
      ownership: ClinicalOwnership.parentveda,
      pathway: null,
      nextMilestone: null,
      mayInferSet: {
        Inferable.growthExpectation,
        Inferable.developmentalStage,
      },
    );
  }
}

/// Resolves from the singletons that ARE reachable, for callers that have no
/// extra context to add.
///
/// [pregnancyWeek] and [dueDateFromClinic] must be passed by a caller that holds
/// PregnancyController; omitting them on the pregnancy stage means the answer
/// is about ownership only, not about the week.
///
/// Pass `controller.dueDateFromClinic` for the second - defaulting it to false
/// says "we worked this out ourselves", which is the safe way to be wrong.
JourneyState currentJourneyState({
  int? pregnancyWeek,
  bool dueDateFromClinic = false,
  int? childAgeMonths,
}) {
  final stage = LifeStageStore.instance.stage;
  final ttc = TtcStore.instance;

  (String, DateTime)? nextStep;
  if (stage == LifeStage.tryingToConceive) {
    final n = TtcTreatmentStore.instance.cycle.next;
    if (n != null) nextStep = (n.$1.name, n.$2);
  }

  return const JourneyStateEngine().resolve(JourneyInputs(
    stage: stage,
    pathway: stage == LifeStage.tryingToConceive ? ttc.pathway : null,
    ttcToday: stage == LifeStage.tryingToConceive ? ttc.today : null,
    nextTreatmentStep: nextStep,
    pregnancyWeek: pregnancyWeek,
    dueDateFromClinic: dueDateFromClinic,
    childAgeMonths: childAgeMonths,
  ));
}
