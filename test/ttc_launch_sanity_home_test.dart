// =============================================================================
//  TTC launch sanity (2026-09-28): the home, the companion and the shop
// -----------------------------------------------------------------------------
//  One small test per row the home helper fixed in docs/TTC-LAUNCH-SANITY.md:
//  H1 (blocker): the home's Period button never starts a new cycle by reflex.
//  H13 (blocker): no seed "What experts say" quote on a TTC product.
//  PR1, PR2: one photo is never two products, and never another brand's.
//  H6, H10, H16: the small rules behind the compact dates, the read marks
//  and the consult count.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/products/pv_product_extras.dart'
    show kPvIllustrativePhotoIds;
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_learn_screen.dart'
    show pvConsultListLead;
import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_period_due.dart' show ttcDayDate;
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpAll(() => HttpOverrides.global = _NoNet());

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
  });

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  // ===========================================================================
  group('H1: the Period button never starts a cycle by reflex', () {
    test('the intent says what Save will do with the day picked', () {
      final a = ago(9);
      expect(ttcHomePeriodIntent(anchor: null, picked: ago(0)),
          TtcHomePeriodIntent.first);
      expect(ttcHomePeriodIntent(anchor: a, picked: a),
          TtcHomePeriodIntent.keep);
      // Close to the logged start: a correction, not a new cycle.
      expect(ttcHomePeriodIntent(anchor: a, picked: ago(0)),
          TtcHomePeriodIntent.move);
      expect(ttcHomePeriodIntent(anchor: a, picked: ago(12)),
          TtcHomePeriodIntent.move);
      // A whole cycle later: a new cycle. Well before: an earlier one.
      expect(ttcHomePeriodIntent(anchor: ago(30), picked: ago(0)),
          TtcHomePeriodIntent.newCycle);
      expect(ttcHomePeriodIntent(anchor: a, picked: ago(60)),
          TtcHomePeriodIntent.earlier);
      expect(
          ttcHomePeriodIntent(anchor: a, picked: ago(40), starts: [ago(40), a]),
          TtcHomePeriodIntent.already);
    });

    Future<void> openSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) => TextButton(
              onPressed: () => showTtcHomePeriodSheet(c),
              child: const Text('Period'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Period'));
      await tester.pumpAndSettle();
    }

    testWidgets('it opens on her logged start and OK changes nothing',
        (tester) async {
      CycleStore.instance
        ..logPeriodStart(ago(37))
        ..logPeriodStart(ago(9));
      await openSheet(tester);

      final line = tester.widget<Text>(
          find.byKey(const ValueKey('ttc_home_period_line')));
      expect(line.data, contains('Your period started on ${ttcShortDate(ago(9))}'));
      final save = find.byKey(const ValueKey('ttc_home_period_save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(CycleStore.instance.periodStarts, [ago(37), ago(9)],
          reason: 'the reflex tap restarted her cycle');
      expect(CycleStore.instance.lastPeriodStart, ago(9));
    });

    testWidgets('a new cycle is asked first, and can be undone',
        (tester) async {
      CycleStore.instance.logPeriodStart(ago(30));
      await openSheet(tester);

      // Pick today on the sheet's own calendar, which opened on her logged
      // start's month.
      if (ago(30).month != DateTime.now().month) {
        await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('${DateTime.now().day}').first);
      await tester.pumpAndSettle();
      final line = tester.widget<Text>(
          find.byKey(const ValueKey('ttc_home_period_line')));
      expect(line.data, contains('Log a new period starting'));

      final save = find.byKey(const ValueKey('ttc_home_period_save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      // Asked, not done.
      expect(find.byKey(const ValueKey('ttc_home_period_confirm')),
          findsOneWidget);
      expect(CycleStore.instance.periodStarts, [ago(30)]);
      await tester.tap(find.byKey(const ValueKey('ttc_home_period_confirm_yes')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(CycleStore.instance.periodStarts, [ago(30), ago(0)]);

      // And the notice offers Undo, which takes it off again.
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(CycleStore.instance.periodStarts, [ago(30)]);
    });
  });

  // ===========================================================================
  group('H13: no seed expert quote on a TTC product', () {
    test('Folic acid carries no seed "What experts say"', () {
      final folic = PvCatalogStore.instance.byId('ttc_folic');
      expect(folic, isNotNull);
      expect(folic!.experts, isEmpty,
          reason: 'a seed persona endorsed a health purchase with a tick');
      for (final p in PvCatalogStore.instance.all
          .where((p) => p.stage == LifeStage.tryingToConceive)) {
        expect(p.experts.where((e) => e.name.contains('Meera')), isEmpty,
            reason: '${p.id} quotes a seed doctor');
      }
    });
  });

  // ===========================================================================
  group('PR1, PR2: a photo shows the product it sits on', () {
    test('no two TTC products share a first photo', () {
      final seen = <String, String>{};
      for (final p in PvCatalogStore.instance.all
          .where((p) => p.stage == LifeStage.tryingToConceive && p.hasImage)) {
        final first = p.images.first;
        expect(seen[first], isNull,
            reason: '${p.id} and ${seen[first]} show the same photograph');
        seen[first] = p.id;
      }
    });

    // Kept for revert (2026-09-29): the strips and the lubricant drew their
    // mark until real photos existed.
    //   expect(PvCatalogStore.instance.byId('ttc_lh_strips')!.hasImage, isFalse);
    //   expect(PvCatalogStore.instance.byId('ttc_lubricant')!.hasImage, isFalse);
    // The user, 2026-09-29: "stop leaving the placeholders". Each now shows a
    // generic object (unbranded strips, a plain white bottle), labelled as an
    // illustration on its page, and still not the pregnancy test's photo.
    test('the strips and the lubricant show an illustrative photo', () {
      for (final id in ['ttc_lh_strips', 'ttc_lubricant']) {
        final p = PvCatalogStore.instance.byId(id)!;
        expect(p.hasImage, isTrue, reason: id);
        expect(kPvIllustrativePhotoIds, contains(id));
      }
      expect(
        PvCatalogStore.instance.byId('ttc_lh_strips')!.images.first,
        isNot(PvCatalogStore.instance.byId('ttc_preg_test')!.images.first),
      );
    });
  });

  // ===========================================================================
  group('H6: rejected dates explain once', () {
    test('one note names only the kinds of gap she has', () {
      expect(ttcCompanionNotCountedNote(), isNull);
      CycleStore.instance
        ..logPeriodStart(ago(40))
        ..logPeriodStart(ago(35))
        ..logPeriodStart(ago(8));
      final note = ttcCompanionNotCountedNote()!;
      expect(note, contains('too short'));
      expect(note, isNot(contains('over 90')));
    });
  });

  // ===========================================================================
  group('H16: the consult list counts people as people', () {
    PvOfferingView v(String name, String mins) => PvOfferingView(
          id: '$name$mins',
          stage: LifeStage.tryingToConceive,
          kind: PvLearnKind.consult,
          title: 't',
          subtitle: 's',
          about: 'a',
          expert: PvLearnExpert(id: name, name: name, role: 'r'),
          hue: 1,
          facts: [PvLearnFact(mins, 'video session')],
        );

    test('two consults of one person are not two people', () {
      expect(
          pvConsultListLead(
              [v('A', '45 min'), v('B', '45 min'), v('A', '45 min')]),
          '3 consults with 2 people · 45-minute video, in the app');
      expect(pvConsultListLead([v('A', '45 min'), v('B', '45 min')]),
          '2 people · 45-minute video, in the app');
      expect(pvConsultListLead([v('A', '45 min'), v('B', '30 min')]),
          '2 people · video, in the app');
    });

    test('a consult with no named person is titled by what it is', () {
      expect(pvLearnHasNoNamedPerson(v('An andrologist', '45 min')), isTrue);
      expect(pvLearnHasNoNamedPerson(v('Dr Ruchika Sood', '45 min')), isFalse);
    });
  });

  // ===========================================================================
  group('M1, M3: a window message reads from its dates', () {
    test('an old frozen message is redrawn with the six-day end date', () {
      final opens = DateTime(2026, 9, 27);
      // What a pre-six-day build stored: "to Sat 3 Oct", "opens today".
      final old = TtcMessage(
        id: 'window:2026-09-27',
        kind: TtcMessageKind.windowOpens,
        at: DateTime(2026, 9, 27, 8),
        title: 'Your fertile window opens today',
        body: 'Going by your dates, your fertile days run from today to '
            'Sat 3 Oct.',
      );
      final (title, body) = old.shownOn(DateTime(2026, 9, 28, 10));
      expect(title, 'Your fertile window is open');
      expect(body, contains('began yesterday'));
      expect(body, contains(ttcDayDate(DateTime(2026, 10, 2))));
      expect(body, isNot(contains('3 Oct')));
      // On its own day it says it opens today, once naming the window.
      final (t0, b0) = ttcWindowMessageText(opens, opens);
      expect(t0, 'Your fertile window opens today');
      expect(b0, contains('Your fertile window is the 6 days'));
      // After it closed, past tense.
      final (t2, _) = old.shownOn(DateTime(2026, 10, 5));
      expect(t2, isNot(contains('today')));
    });
  });

  // ===========================================================================
  group('H12: a cleared value is not brought back by the next sync', () {
    test('clearing leaves a tombstone, logging again lifts it', () {
      final log = TtcLogStore.instance..resetForTest();
      final day = ago(0);
      log.log('symptoms', 'sex_unprotected', 1, on: day);
      log.clear('symptoms', 'sex_unprotected', on: day);
      final key = 'symptoms/sex_unprotected/${TtcLogStore.dayKey(day)}';
      expect(log.clearedKeysForTest, contains(key),
          reason: 'without it the union pull restores the cleared value');
      log.log('symptoms', 'sex_unprotected', 1, on: day);
      expect(log.clearedKeysForTest, isNot(contains(key)));
    });
  });
}
