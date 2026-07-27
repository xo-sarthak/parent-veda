// =============================================================================
//  Care pathway — who owns the timing
// -----------------------------------------------------------------------------
//  The refactor these tests exist for: treatment type was the wrong thing to
//  branch on. The same treatment behaves in opposite ways depending on whether
//  a clinic is watching, so the cases below are the specification.
//
//    Case 1  letrozole, no monitoring, no trigger  → we SHOULD estimate
//    Case 2  letrozole, scans, trigger             → we must NOT
//
//  Both are "ovulation induction". If those two ever produce the same answer
//  again, the refactor has been undone.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('the two cases that broke the old model', () {
    test('Case 1 — unmonitored letrozole: her body owns the timing', () {
      const p = TtcCarePathway(
        path: TtcPath.ovulationInduction,
        clinicMonitors: false,
        medicationControlsOvulation: false,
      );
      expect(p.ownership, TimingOwnership.parentveda);
      expect(ttcBehaviourFor(p).showsFertilityWindow, isTrue,
          reason: 'the old model withheld this, which was the over-correction');
      expect(ttcBehaviourFor(p).predictsOvulation, isTrue);
    });

    test('Case 2 — monitored letrozole with a trigger: the clinic owns it', () {
      const p = TtcCarePathway(
        path: TtcPath.ovulationInduction,
        clinicMonitors: true,
        medicationControlsOvulation: true,
      );
      expect(p.ownership, TimingOwnership.clinicControlled);
      expect(ttcBehaviourFor(p).showsFertilityWindow, isFalse);
    });

    test('same treatment, opposite behaviour — which is the whole point', () {
      const one = TtcCarePathway(
          path: TtcPath.ovulationInduction,
          clinicMonitors: false,
          medicationControlsOvulation: false);
      const two = TtcCarePathway(
          path: TtcPath.ovulationInduction,
          clinicMonitors: true,
          medicationControlsOvulation: true);
      expect(one.path, two.path);
      expect(one.ownership, isNot(two.ownership));
    });

    test('natural-cycle FET is guided, not controlled', () {
      // Her own ovulation is tracked and the transfer timed to it - so we do
      // not predict, but her signals still matter.
      const p = TtcCarePathway(
        path: TtcPath.frozenEmbryoTransfer,
        clinicMonitors: true,
        medicationControlsOvulation: false,
      );
      expect(p.ownership, TimingOwnership.clinicGuided);
      expect(ttcBehaviourFor(p).logsBodySignals, isTrue);
      expect(ttcBehaviourFor(p).predictsOvulation, isFalse);
    });

    test('a medicated FET is controlled', () {
      const p = TtcCarePathway(
        path: TtcPath.frozenEmbryoTransfer,
        clinicMonitors: true,
        medicationControlsOvulation: true,
      );
      expect(p.ownership, TimingOwnership.clinicControlled);
      expect(ttcBehaviourFor(p).logsBodySignals, isFalse);
    });
  });

  // ===========================================================================
  group('medication is the strongest signal', () {
    test('it decides regardless of the treatment name', () {
      for (final path in TtcPath.values) {
        final p = TtcCarePathway(
          path: path,
          clinicMonitors: false,
          medicationControlsOvulation: true,
        );
        expect(p.ownership, TimingOwnership.clinicControlled, reason: '$path');
      }
    });

    test('monitoring alone is the middle tier, never the top', () {
      for (final path in TtcPath.values) {
        final p = TtcCarePathway(
          path: path,
          clinicMonitors: true,
          medicationControlsOvulation: false,
        );
        expect(p.ownership, TimingOwnership.clinicGuided, reason: '$path');
      }
    });

    test('neither, and her body owns it — whatever she is nominally on', () {
      for (final path in TtcPath.values) {
        final p = TtcCarePathway(
          path: path,
          clinicMonitors: false,
          medicationControlsOvulation: false,
        );
        expect(p.ownership, TimingOwnership.parentveda, reason: '$path');
      }
    });
  });

  // ===========================================================================
  group('defaults are the safer side until she answers', () {
    test('trying naturally assumes nobody else is involved', () {
      const p = TtcCarePathway(path: TtcPath.natural);
      expect(p.ownership, TimingOwnership.parentveda);
      expect(p.isAnswered, isFalse);
    });

    test('IVF assumes clinic-controlled without being asked', () {
      const p = TtcCarePathway(path: TtcPath.ivf);
      expect(p.ownership, TimingOwnership.clinicControlled);
    });

    test('ovulation induction defaults to withholding, not to guessing', () {
      // Genuinely split in practice, so the default errs toward not showing a
      // window - wrongly showing one is worse than wrongly hiding one.
      const p = TtcCarePathway(path: TtcPath.ovulationInduction);
      expect(p.ownership, TimingOwnership.clinicGuided);
      expect(ttcBehaviourFor(p).showsFertilityWindow, isFalse);
    });

    test('and her answer overrides that default', () {
      const p = TtcCarePathway(
          path: TtcPath.ovulationInduction,
          clinicMonitors: false,
          medicationControlsOvulation: false);
      expect(ttcBehaviourFor(p).showsFertilityWindow, isTrue);
      expect(p.isAnswered, isTrue);
    });

    test('we only ask where the answer changes something', () {
      // Asking on trying-naturally or IVF would collect data we would not act
      // on, which the product refuses to do.
      expect(TtcPath.natural.answersMatter, isFalse);
      expect(TtcPath.ivf.answersMatter, isFalse);
      expect(TtcPath.ovulationInduction.answersMatter, isTrue);
      expect(TtcPath.iui.answersMatter, isTrue);
      expect(TtcPath.frozenEmbryoTransfer.answersMatter, isTrue);
    });
  });

  // ===========================================================================
  group('the behaviour flags', () {
    test('only her own cycle gets predictions and a window', () {
      for (final o in TimingOwnership.values) {
        final b = TtcPathwayBehaviour(o);
        final own = o == TimingOwnership.parentveda;
        expect(b.predictsOvulation, own, reason: '$o');
        expect(b.showsFertilityWindow, own, reason: '$o');
        expect(b.countsToPeriod, own, reason: '$o');
        expect(b.sendsOvulationReminders, own, reason: '$o');
      }
    });

    test('logging survives the middle tier — the improvement', () {
      expect(
          TtcPathwayBehaviour(TimingOwnership.clinicGuided).logsBodySignals,
          isTrue);
      expect(
          TtcPathwayBehaviour(TimingOwnership.clinicControlled).logsBodySignals,
          isFalse);
    });

    test('the clinic timeline appears whenever a clinic is involved', () {
      expect(
          TtcPathwayBehaviour(TimingOwnership.parentveda).showsClinicTimeline,
          isFalse);
      for (final o in [
        TimingOwnership.clinicGuided,
        TimingOwnership.clinicControlled
      ]) {
        expect(TtcPathwayBehaviour(o).showsClinicTimeline, isTrue, reason: '$o');
      }
    });

    test('period and beta countdowns are never both on', () {
      for (final o in TimingOwnership.values) {
        final b = TtcPathwayBehaviour(o);
        expect(b.countsToPeriod && b.countsToBeta, isFalse, reason: '$o');
      }
    });
  });

  // ===========================================================================
  group('the store', () {
    test('changing pathway clears her answers', () {
      final s = TtcStore.instance;
      s.setPath(TtcPath.iui);
      s.setClinicMonitors(false);
      s.setMedicationControlsOvulation(false);
      expect(s.ownership, TimingOwnership.parentveda);

      s.setPath(TtcPath.ivf);
      // A stale "my clinic does not scan me" from an old IUI round must not
      // follow her into IVF.
      expect(s.pathwayAnswered, isFalse);
      expect(s.ownership, TimingOwnership.clinicControlled);
    });

    test('an answer can be taken back to "not sure"', () {
      final s = TtcStore.instance;
      s.setPath(TtcPath.iui);
      s.setClinicMonitors(false);
      expect(s.pathway.clinicMonitors, isFalse);
      s.setClinicMonitors(null);
      expect(s.pathway.clinicMonitors, isNull);
      expect(s.pathwayAnswered, isFalse);
    });

    test('unmonitored IUI gives her the window back', () {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 12)));
      final s = TtcStore.instance;
      s.setPath(TtcPath.iui);
      expect(s.today.fertility, isNull, reason: 'default is to withhold');
      s.setClinicMonitors(false);
      s.setMedicationControlsOvulation(false);
      expect(s.today.fertility, isNotNull,
          reason: 'her answer should have restored it');
    });
  });

  // ===========================================================================
  group('ownership travels', () {
    test('the id round-trips, and is stable', () {
      for (final o in TimingOwnership.values) {
        expect(TimingOwnershipCopy.fromId(o.id), o);
      }
      // Pinned: renaming these needs a migration, since they are stored and
      // sent to Ask Veda.
      expect(TimingOwnership.parentveda.id, 'parentveda');
      expect(TimingOwnership.clinicGuided.id, 'clinic_guided');
      expect(TimingOwnership.clinicControlled.id, 'clinic_controlled');
    });

    test('an unknown id is null rather than a guess', () {
      expect(TimingOwnershipCopy.fromId('something_else'), isNull);
      expect(TimingOwnershipCopy.fromId(null), isNull);
    });

    test('each tier explains itself in both languages, differently', () {
      for (final o in TimingOwnership.values) {
        for (final hi in [true, false]) {
          expect(o.title(hi), isNotEmpty, reason: '$o');
          expect(o.body(hi), isNotEmpty, reason: '$o');
        }
        expect(o.body(true), isNot(o.body(false)), reason: '$o');
      }
      // The two clinic tiers must not share copy - "keep logging" and "nothing
      // of your natural cycle applies" are different messages.
      expect(TimingOwnership.clinicGuided.body(false),
          isNot(TimingOwnership.clinicControlled.body(false)));
    });

    test('Ask Veda receives ownership, not just the treatment name', () {
      final screen =
          File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
      expect(screen.contains('timingOwnership: s.ownership.id'), isTrue,
          reason: 'the service would branch on the weaker signal');
    });

    test('the migration knows the same three values', () {
      final sql = File('supabase/migrations/0044_ttc_care_pathway.sql')
          .readAsStringSync();
      for (final o in TimingOwnership.values) {
        expect(sql.contains("'${o.id}'"), isTrue, reason: o.id);
      }
      // Nullable on purpose - "not asked" is a real third state.
      expect(sql.contains('clinic_monitors     boolean'), isTrue);
      expect(sql.contains('medication_controls boolean'), isTrue);
    });
  });
}
