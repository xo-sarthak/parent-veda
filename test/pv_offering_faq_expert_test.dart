// =============================================================================
//  The offering page: more questions, and a doctor's name that opens
//  something (2026-09-30).
//
//  The user, on Talk to an expert, Courses and Cohorts in More: "the FAQs are
//  very less… questions should be more. This page should be converting", and
//  "the doctor page does not open up for that particular doctor".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_offering_content.dart';
import 'package:parentveda/screens/learn/pv_offering_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_learn_progress_store.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    BookingStore.instance.resetAll();
    PvLearnProgressStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
  });

  group('the questions', () {
    for (final k in PvLearnKind.values) {
      test('${k.name}: six to eight, none said twice, all answered', () {
        final v = PvLearnCatalog.instance.all(kind: k).first;
        final faqs = pvFaqsFor(v);
        expect(faqs.length, inInclusiveRange(6, kPvFaqMax));
        final qs = faqs.map((f) => f.q.toLowerCase()).toList();
        expect(qs.toSet().length, qs.length, reason: 'a question is repeated');
        for (final f in faqs) {
          expect(f.q.trim(), isNotEmpty);
          expect(f.a.trim().length, greaterThan(20), reason: f.q);
        }
      });
    }

    test('the source\'s own questions come first, unchanged', () {
      final v = PvLearnCatalog.instance
          .all(kind: PvLearnKind.consult)
          .firstWhere((x) => x.faqs.isNotEmpty,
              orElse: () => PvLearnCatalog.instance
                  .all(kind: PvLearnKind.consult)
                  .first);
      final faqs = pvFaqsFor(v);
      for (var i = 0; i < v.faqs.length; i++) {
        expect(faqs[i].q, v.faqs[i].q);
      }
    });

    test('no answer promises a refund window the trust rows do not', () {
      // The refund answers repeat the page's own rows: 7 days (course),
      // 24 hours (masterclass, consult), before the first call (cohort).
      String refund(PvLearnKind k) => pvFaqsFor(
              PvLearnCatalog.instance.all(kind: k).first)
          .where((f) => f.q.toLowerCase().contains('refund') ||
              f.q.toLowerCase().contains('cancel') ||
              f.q.toLowerCase().contains('not for me'))
          .map((f) => f.a)
          .join(' ');
      expect(refund(PvLearnKind.masterclass), contains('24 hours'));
      expect(refund(PvLearnKind.consult), contains('24 hours'));
      expect(refund(PvLearnKind.cohort), contains('before the first call'));
    });
  });

  group('the doctor', () {
    testWidgets(
        'on a trying-to-conceive consult, the name opens a sheet with the '
        'sessions they lead', (tester) async {
      final v = PvLearnCatalog.instance
          .all(kind: PvLearnKind.consult)
          .firstWhere((x) => x.expert.expert == null && x.expert.name.isNotEmpty);
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PvOfferingScreen(view: v)));
      await tester.pump(const Duration(milliseconds: 500));
      // The expert card names the doctor; tap the first one that does.
      // A consult page is titled with the person and draws no expert card,
      // so the way in is the "View profile" link under the name.
      final card = find.byKey(const ValueKey('pv_consult_view_profile'));
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.tap(card, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      // Either a full profile opened (a record exists) or the sheet did.
      final sheet = find.byKey(const ValueKey('pv_expert_sheet_name'));
      final anything = sheet.evaluate().isNotEmpty ||
          find.byType(PvOfferingScreen).evaluate().length == 1;
      expect(anything, isTrue);
      expect(sheet, findsOneWidget,
          reason: 'a clinician with no record opens the profile sheet');
      expect(find.text(v.expert.name), findsWidgets);
    });
  });
}
