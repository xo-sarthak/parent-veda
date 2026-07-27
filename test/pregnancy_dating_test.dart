// =============================================================================
//  Who owns the due date
// -----------------------------------------------------------------------------
//  A dating scan is more accurate than counting from a last period, and the
//  clinic owns the scan. Until now the app could not tell the two apart: it
//  stored a date and forgot where the date came from.
//
//  The failure this prevents is "my app says 9w2d, my doctor says 8w5d". Being
//  right afterwards does not buy back the trust that costs.
//
//  Same shape as the IVF fertility window, in the stage that has real users.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/tools/due_date_calculator_screen.dart';
import 'package:parentveda/services/journey_state.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const engine = JourneyStateEngine();

  // ===========================================================================
  group('which sources a clinic owns', () {
    test('a scan, a transfer and a doctor telling her', () {
      expect(DueDateSource.scan.clinicOwned, isTrue);
      expect(DueDateSource.ivfTransfer.clinicOwned, isTrue);
      expect(DueDateSource.clinician.clinicOwned, isTrue);
    });

    test('our own arithmetic is not', () {
      expect(DueDateSource.lastPeriod.clinicOwned, isFalse);
      expect(DueDateSource.conception.clinicOwned, isFalse);
    });

    test('unknown counts as ours, which is the safe way to be wrong', () {
      // Assuming a clinic gave a date we cannot account for would be the exact
      // wrong error: it would silence our estimate on no evidence, and later
      // make a real disagreement invisible.
      expect(DueDateSource.unknown.clinicOwned, isFalse);
    });
  });

  // ===========================================================================
  group('the calculator already knew - it just was not recording it', () {
    test('every method maps to a source', () {
      for (final m in DdcMethod.values) {
        expect(() => ddcSourceFor(m), returnsNormally, reason: '$m');
      }
    });

    test('ultrasound, IVF and "my doctor told me" are the clinic\'s', () {
      expect(ddcSourceFor(DdcMethod.ultrasound).clinicOwned, isTrue);
      expect(ddcSourceFor(DdcMethod.ivf).clinicOwned, isTrue);
      expect(ddcSourceFor(DdcMethod.known).clinicOwned, isTrue);
    });

    test('last period and conception are ours', () {
      expect(ddcSourceFor(DdcMethod.lmp).clinicOwned, isFalse);
      expect(ddcSourceFor(DdcMethod.conception).clinicOwned, isFalse);
    });
  });

  // ===========================================================================
  group('the controller carries it', () {
    test('a fresh controller has no source', () {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      expect(c.dueDateSource, DueDateSource.unknown);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('setting a scan-derived date hands ownership over', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      expect(c.dueDateSource, DueDateSource.scan);
      expect(c.dueDateFromClinic, isTrue);
    });

    test('setting an LMP-derived date leaves it with us', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: DueDateSource.lastPeriod);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('omitting the source does not silently claim a clinic gave it',
        () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10));
      expect(c.dueDateFromClinic, isFalse);
    });

    test('a later LMP date takes ownership back from a scan', () async {
      // She re-entered it herself. Whatever that means clinically, we must not
      // keep claiming a scan we no longer have.
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      await c.setDueDate(DateTime(2027, 1, 14),
          source: DueDateSource.lastPeriod);
      expect(c.dueDateFromClinic, isFalse);
    });

    test('resetting clears the source too', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      await c.resetForTesting();
      expect(c.dueDateSource, DueDateSource.unknown);
    });

    test('the source is persisted under its own key', () async {
      SharedPreferences.setMockInitialValues({});
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10), source: DueDateSource.scan);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregnancyController.kDueDateSourceKey),
          DueDateSource.scan.name);
    });
  });

  // ===========================================================================
  group('and the boundary finally has a writer', () {
    test('without a clinic date we may work out how far along she is', () {
      final s = engine.resolve(const JourneyInputs(stage: LifeStage.pregnancy));
      expect(s.mayInfer(Inferable.gestationalAge), isTrue);
    });

    test('with one, gestational age is theirs', () {
      final s = engine.resolve(const JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: true));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);
      expect(s.mustComeFromClinician(Inferable.gestationalAge), isTrue);
      expect(s.ownership, ClinicalOwnership.shared);
    });

    test('a real controller can answer the question the state asks', () async {
      // The wiring that was missing: something has to KNOW the date came from a
      // scan. Now the calculator records it and the controller reports it.
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: ddcSourceFor(DdcMethod.ultrasound));
      final s = engine.resolve(JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: c.dueDateFromClinic));
      expect(s.mayInfer(Inferable.gestationalAge), isFalse);
    });

    test('and reports the other way round for a date we counted', () async {
      final c = PregnancyController(now: DateTime(2026, 7, 27));
      await c.setDueDate(DateTime(2027, 1, 10),
          source: ddcSourceFor(DdcMethod.lmp));
      final s = engine.resolve(JourneyInputs(
          stage: LifeStage.pregnancy, dueDateFromClinic: c.dueDateFromClinic));
      expect(s.mayInfer(Inferable.gestationalAge), isTrue);
    });
  });
}
