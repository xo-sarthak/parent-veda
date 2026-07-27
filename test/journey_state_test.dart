// =============================================================================
//  JourneyState — where a family is, and who owns what
// -----------------------------------------------------------------------------
//  The valuable half of this is question 5: what may ParentVeda infer, and what
//  must come from a clinician.
//
//  That question existed only inside TTC, as a fertility-window rule discovered
//  after the app had already been showing an IVF couple a calendar estimate. It
//  is really a cross-stage principle, and these tests are what stop it being
//  re-learned the same expensive way in pregnancy or parenting.
//
//  Default-deny is the property to protect: anything not explicitly permitted
//  is refused, so a new Inferable added later is safe until somebody decides
//  otherwise in code.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/journey_state.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = JourneyStateEngine();

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
  });

  // ===========================================================================
  group('nothing declared means nothing inferred', () {
    test('no stage: every inference is refused', () {
      final s = engine.resolve(const JourneyInputs());
      expect(s.stage, isNull);
      for (final i in Inferable.values) {
        expect(s.mayInfer(i), isFalse, reason: '$i');
        expect(s.mustComeFromClinician(i), isTrue, reason: '$i');
      }
    });

    test('a null stage is a real state, not an error', () {
      expect(() => engine.resolve(const JourneyInputs()), returnsNormally);
    });
  });

  // ===========================================================================
  group('default-deny', () {
    test('no state permits every inferable at once', () {
      // If one ever did, the boundary would have stopped meaning anything.
      final states = [
        engine.resolve(const JourneyInputs()),
        engine.resolve(const JourneyInputs(stage: LifeStage.tryingToConceive)),
        engine.resolve(const JourneyInputs(stage: LifeStage.pregnancy)),
        engine.resolve(const JourneyInputs(stage: LifeStage.parenting)),
      ];
      for (final s in states) {
        final permitted =
            Inferable.values.where(s.mayInfer).length;
        expect(permitted, lessThan(Inferable.values.length),
            reason: '${s.stage} permits everything');
      }
    });

    test('a stage only ever permits inferences that belong to it', () {
      final trying = engine.resolve(const JourneyInputs(
        stage: LifeStage.tryingToConceive,
        pathway: TtcCarePathway(
            path: TtcPath.natural,
            clinicMonitors: false,
            medicationControlsOvulation: false),
      ));
      // Trying to conceive says nothing about a child's growth.
      expect(trying.mayInfer(Inferable.growthExpectation), isFalse);
      expect(trying.mayInfer(Inferable.developmentalStage), isFalse);

      final parenting =
          engine.resolve(const JourneyInputs(stage: LifeStage.parenting));
      expect(parenting.mayInfer(Inferable.fertilityTiming), isFalse);
      expect(parenting.mayInfer(Inferable.gestationalAge), isFalse);
    });
  });

  // ===========================================================================
  group('trying to conceive — the three tiers map through', () {
    JourneyState forPathway(TtcCarePathway p) => engine.resolve(
        JourneyInputs(stage: LifeStage.tryingToConceive, pathway: p));

    test('her own cycle: ParentVeda owns it and may infer timing', () {
      final s = forPathway(const TtcCarePathway(
          path: TtcPath.natural,
          clinicMonitors: false,
          medicationControlsOvulation: false));
      expect(s.ownership, ClinicalOwnership.parentveda);
      expect(s.mayInfer(Inferable.fertilityTiming), isTrue);
      expect(s.clinicianInvolved, isFalse);
    });

    test('monitored: SHARED, and timing becomes the clinic\'s', () {
      final s = forPathway(const TtcCarePathway(
          path: TtcPath.ovulationInduction,
          clinicMonitors: true,
          medicationControlsOvulation: false));
      expect(s.ownership, ClinicalOwnership.shared);
      expect(s.mayInfer(Inferable.fertilityTiming), isFalse);
      expect(s.clinicianInvolved, isTrue);
    });

    test('medicated: the clinic owns it outright', () {
      final s = forPathway(const TtcCarePathway(
          path: TtcPath.ivf,
          clinicMonitors: true,
          medicationControlsOvulation: true));
      expect(s.ownership, ClinicalOwnership.clinic);
      expect(s.mayInfer(Inferable.fertilityTiming), isFalse);
    });

    test('the pathway travels with the state', () {
      final s = forPathway(const TtcCarePathway(path: TtcPath.iui));
      expect(s.pathway?.path, TtcPath.iui);
    });

    test('with no pathway given it assumes the natural default', () {
      final s = engine
          .resolve(const JourneyInputs(stage: LifeStage.tryingToConceive));
      expect(s.ownership, ClinicalOwnership.parentveda);
    });
  });

  // ===========================================================================
  group('pregnancy — the same class of rule, found before it bit', () {
    test('without a dating scan we may work out how far along she is', () {
      final s = engine.resolve(const JourneyInputs(stage: LifeStage.pregnancy));
      expect(s.mayInfer(Inferable.gestationalAge), isTrue);
      expect(s.ownership, ClinicalOwnership.parentveda);
    });

    test('once a scan has dated it, that becomes the clinic\'s', () {
      // A dating scan beats counting from a last period, and the clinic owns
      // the scan - so ours stops being a second opinion. Exactly the shape of
      // the IVF fertility-window mistake, named here before it can happen.
      final s = engine.resolve(const JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: true));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);
      expect(s.mustComeFromClinician(Inferable.gestationalAge), isTrue);
      expect(s.ownership, ClinicalOwnership.shared);
    });
  });

  // ===========================================================================
  group('parenting', () {
    test('growth and development are described, so inference is allowed', () {
      final s = engine.resolve(const JourneyInputs(stage: LifeStage.parenting));
      expect(s.mayInfer(Inferable.growthExpectation), isTrue);
      expect(s.mayInfer(Inferable.developmentalStage), isTrue);
      expect(s.ownership, ClinicalOwnership.parentveda);
    });
  });

  // ===========================================================================
  group('the next milestone', () {
    test('a clinic date is marked as coming from the clinic', () {
      final on = DateTime.now().add(const Duration(days: 3));
      final s = engine.resolve(JourneyInputs(
        stage: LifeStage.tryingToConceive,
        pathway: const TtcCarePathway(path: TtcPath.ivf),
        nextTreatmentStep: ('retrieval', on),
      ));
      expect(s.nextMilestone, isNotNull);
      expect(s.nextMilestone!.id, 'retrieval');
      expect(s.nextMilestone!.fromClinic, isTrue,
          reason: 'a surface showing both must be able to say which is which');
    });

    test('days away counts whole days, and past reads as past', () {
      final soon = JourneyMilestone(
          id: 'x',
          on: DateTime.now().add(const Duration(days: 5)),
          fromClinic: true);
      expect(soon.daysAway, 5);
      expect(soon.isPast, isFalse);

      final gone = JourneyMilestone(
          id: 'x',
          on: DateTime.now().subtract(const Duration(days: 2)),
          fromClinic: true);
      expect(gone.isPast, isTrue);
    });

    test('no milestone is null rather than invented', () {
      final s = engine
          .resolve(const JourneyInputs(stage: LifeStage.tryingToConceive));
      expect(s.nextMilestone, isNull);
    });

    test('it carries an id, not user-facing text', () {
      // The resolver holds no copy - the caller renders it in the right
      // language, so this can never be the thing that ships English to a
      // Hinglish reader.
      final s = engine.resolve(JourneyInputs(
        stage: LifeStage.tryingToConceive,
        nextTreatmentStep: ('betaTest', DateTime.now()),
      ));
      expect(s.nextMilestone!.id, 'betaTest');
    });
  });

  // ===========================================================================
  group('it composes from the live stores', () {
    test('currentJourneyState follows the declared stage', () {
      expect(currentJourneyState().stage, isNull);
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      expect(currentJourneyState().stage, LifeStage.tryingToConceive);
    });

    test('and follows the pathway as it changes', () {
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      expect(currentJourneyState().ownership, ClinicalOwnership.parentveda);

      TtcStore.instance.setPath(TtcPath.ivf);
      expect(currentJourneyState().ownership, ClinicalOwnership.clinic);
      expect(currentJourneyState().mayInfer(Inferable.fertilityTiming), isFalse);

      TtcStore.instance.setPath(TtcPath.iui);
      TtcStore.instance.setClinicMonitors(false);
      TtcStore.instance.setMedicationControlsOvulation(false);
      expect(currentJourneyState().ownership, ClinicalOwnership.parentveda,
          reason: 'her answers should have handed timing back to her');
    });

    test('it picks up a treatment milestone without being told', () {
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      TtcStore.instance.setPath(TtcPath.ivf);
      expect(currentJourneyState().nextMilestone, isNull);

      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.retrieval,
          DateTime.now().add(const Duration(days: 6)));
      final m = currentJourneyState().nextMilestone;
      expect(m, isNotNull);
      expect(m!.id, TtcTreatmentStep.retrieval.name);
      expect(m.fromClinic, isTrue);
    });

    test('it owns no state of its own', () {
      // The property that stops it drifting: change a store, and the answer
      // changes with it, because there is nothing cached in between.
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      final before = currentJourneyState().ownership;
      TtcStore.instance.setPath(TtcPath.ivf);
      expect(currentJourneyState().ownership, isNot(before));
    });
  });

  // ===========================================================================
  group('it agrees with the TTC engine rather than duplicating it', () {
    test('a window can never appear where inference is forbidden', () {
      // Relative dates only: a fixed start plus a relative end meant the gap
      // between them grew by a day every day, and the fixture eventually
      // tripped rules it was never written to exercise.
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 68)))
        ..logPeriodStart(now.subtract(const Duration(days: 40)))
        ..logPeriodStart(now.subtract(const Duration(days: 12)));
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);

      for (final path in TtcPath.values) {
        TtcStore.instance.setPath(path);
        final mayInfer =
            currentJourneyState().mayInfer(Inferable.fertilityTiming);
        final hasWindow = TtcStore.instance.today.fertility != null;

        // ONE-WAY on purpose. Permission and data quality are different
        // questions, and only became visibly different once the engine started
        // refusing to publish estimates built on a history it distrusts. A
        // window without permission is the IVF defect; permission without a
        // window is simply having nothing worth saying yet.
        if (hasWindow) {
          expect(mayInfer, isTrue,
              reason: '$path: a window appeared where we may not infer');
        }
      }
    });

    test('and on a natural path with clean data there IS one', () {
      // Guards the test above from passing vacuously if the engine ever stopped
      // producing windows at all.
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 68)))
        ..logPeriodStart(now.subtract(const Duration(days: 40)))
        ..logPeriodStart(now.subtract(const Duration(days: 12)));
      LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
      TtcStore.instance.setPath(TtcPath.natural);
      expect(TtcStore.instance.today.fertility, isNotNull);
    });
  });
}
