// P1 Wave 1 (docs/preg-ttc-tool-plans/P1-lookups-records.md, 2026-10-28):
// PG1, one id per screen (D7), and the Pregnancy consent kinds (D5).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/journeys/pregnancy_journeys.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_use_consent.dart';

String _src(String p) => File(p).readAsStringSync();

void main() {
  final router = _src('lib/services/surface_router.dart');

  group('PG1: the readings log has a surface and the journey opens it', () {
    test('screenForSurface knows readings', () {
      expect(router, contains("'readings' => ReadingsLogScreen(controller: c)"));
    });

    test('"Log it now" under Track my readings opens readings, not weight', () {
      final logIt = kPgTrackReadings.steps
          .expand((s) => s.elements)
          .where((e) => e.title.en == 'Log it now')
          .single;
      expect(logIt.surfaceId, 'readings');
    });

    test('no Pregnancy journey element sends a readings step to Weight', () {
      for (final j in kPregnancyJourneys.values) {
        for (final e in j.steps.expand((s) => s.elements)) {
          final t = '${e.title.en} ${e.value.en}'.toLowerCase();
          if (t.contains('reading')) {
            expect(e.surfaceId, isNot('weight'), reason: e.title.en);
          }
        }
      }
    });
  });

  group('D7: callers that mean the decoder name it', () {
    test('report_decoder opens the decoder', () {
      expect(router, contains("'report_decoder' => ReportScreen(controller: c)"));
    });

    test('journeys and the Scans hub no longer use bare reports', () {
      for (final j in kPregnancyJourneys.values) {
        for (final e in j.steps.expand((s) => s.elements)) {
          expect(e.surfaceId, isNot('reports'), reason: e.title.en);
        }
      }
      expect(_src('lib/data/hubs/scans_hub.dart'),
          isNot(contains(RegExp(r"^\s*surfaceId: 'reports',", multiLine: true))));
    });
  });

  group('D5: Pregnancy consent kinds live in PpUseConsent', () {
    // Five since P2 O1 (2026-10-28): pregBirthPlan, the birth plan in the
    // doctor-visit summary.
    test('five Pregnancy kinds, each with a label, a why and a stage', () {
      final preg = PpUseKind.values.where((k) => k.stage == LifeStage.pregnancy);
      expect(preg.map((k) => k.name), [
        'pregReadings',
        'pregConditions',
        'pregReports',
        'pregDoctorCalls',
        'pregBirthPlan',
      ]);
      for (final k in preg) {
        expect(k.label, isNotEmpty);
        expect(k.why, contains('doctor'));
        expect(k.saidYes, contains('summary'));
      }
    });

    test("Parenting's five keep their names and stage (stored rows untouched)", () {
      final pp = PpUseKind.values.where((k) => k.stage == LifeStage.parenting);
      expect(pp.map((k) => k.name),
          ['feeds', 'nappies', 'changes', 'development', 'foods']);
      expect(PpUseKind.feeds.saidYes, contains('what you see first'));
    });

    test('a Pregnancy answer round-trips through the merge items', () {
      final c = PpUseConsent.instance..debugReset();
      c.applyCloudItems({'pregReadings': 'yes', 'feeds': 'no'});
      expect(c.allows(PpUseKind.pregReadings), isTrue);
      expect(c.unasked(PpUseKind.pregReports), isTrue);
      expect(c.cloudItems(), {'pregReadings': 'yes', 'feeds': 'no'});
      c.debugReset();
    });
  });
}
