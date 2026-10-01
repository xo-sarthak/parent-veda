// =============================================================================
//  What the Pre-pregnancy checklist gives back (2026-10-01).
//
//  The user: "when we collect this information then the user might expect
//  something… is that linked anywhere or are we just collecting it?" Five
//  changes, one at a time; this file holds them as they land. Hers only
//  (nothing for his side).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/v2/pv_insight_rail.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_doctor_questions_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_precheck_notes.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_home.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    await TtcPrecheckStore.instance.reset();
    await TtcPrecheckStore.instance.markOpened();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  }

  Future<void> scrollRailTo(WidgetTester tester, Finder f) async {
    if (f.evaluate().isNotEmpty) return;
    final rail = find
        .ancestor(
            of: find.byType(PvInsightTile).first,
            matching: find.byType(Scrollable))
        .first;
    await tester.dragUntilVisible(f, rail, const Offset(-160, 0),
        maxIteration: 40);
  }

  group('1. the home shows her next step', () {
    test('the next step is the checklist\'s first open step', () async {
      final s = ttcPrecheckNextStep();
      expect(s, isNotNull);
      expect(s!.item.id, 'folate',
          reason: 'the strongest-evidence step leads, as in the checklist');
    });

    test('settling it moves the step on; settling all that matters ends it',
        () async {
      final first = ttcPrecheckNextStep()!.item.id;
      await TtcPrecheckStore.instance.setStatus(first, PrecheckStatus.done);
      final second = ttcPrecheckNextStep();
      expect(second, isNotNull);
      expect(second!.item.id, isNot(first));
      // Every item settled: nothing left to nudge about.
      for (final i in kPrecheckItems) {
        await TtcPrecheckStore.instance.setStatus(i.id, PrecheckStatus.done);
      }
      expect(ttcPrecheckNextStep(), isNull);
    });

    testWidgets('the rail has a "Your next step" card, and it opens the list',
        (tester) async {
      await pumpHome(tester);
      final card = find.text('YOUR NEXT STEP', skipOffstage: false);
      await scrollRailTo(tester, card);
      expect(card, findsOneWidget);
      expect(find.text('Folic acid', skipOffstage: false), findsWidgets);
      await tester.ensureVisible(card);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(card, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TtcPrecheckScreen), findsOneWidget);
    });

    testWidgets('no card once everything that matters is settled',
        (tester) async {
      for (final i in kPrecheckItems) {
        await TtcPrecheckStore.instance.setStatus(i.id, PrecheckStatus.done);
      }
      await pumpHome(tester);
      expect(find.text('YOUR NEXT STEP', skipOffstage: false), findsNothing);
    });
  });

  // ===========================================================================
  group('2. the notes go to her visit', () {
    final soon = DateTime.now().toUtc().add(const Duration(days: 9));

    final original = TtcDoctorQuestionsStore.visitsSource;

    setUp(() {
      TtcDoctorQuestionsStore.instance.resetForTest();
      TtcDoctorQuestionsStore.visitsSource = () => [
            TtcVisitRef(id: 'v1', title: 'Dr Rao', startsUtc: soon),
          ];
    });

    tearDown(() {
      TtcDoctorQuestionsStore.visitsSource = original;
    });

    test('her questions go onto the next visit, once', () async {
      await TtcPrecheckStore.instance
          .setStatus('tobacco', PrecheckStatus.needsAttention);
      final notes = ttcPrecheckNotes(AppLanguage.english);
      expect(notes.questions, isNotEmpty);
      final first = ttcAddPrecheckQuestionsToNextVisit(AppLanguage.english);
      expect(first.added, notes.questions.length);
      expect(first.visit?.id, 'v1');
      final onVisit = TtcDoctorQuestionsStore.instance
          .openFor('v1')
          .map((q) => q.text)
          .toSet();
      for (final q in notes.questions) {
        expect(onVisit, contains(q));
      }
      // Again: nothing new, nothing doubled.
      final again = ttcAddPrecheckQuestionsToNextVisit(AppLanguage.english);
      expect(again.added, 0);
    });

    test('with no visit coming they wait, and the answer says so', () {
      TtcDoctorQuestionsStore.visitsSource = () => [];
      final r = ttcAddPrecheckQuestionsToNextVisit(AppLanguage.english);
      expect(r.added, greaterThan(0));
      expect(r.visit, isNull);
    });

    testWidgets('the notes page has the button and says what happened',
        (tester) async {
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: TtcPrecheckSummaryScreen())));
      await tester.pumpAndSettle();
      final button = find.byKey(const ValueKey('ttc_precheck_to_visit'));
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('added.'), findsOneWidget);
      expect(find.textContaining('Dr Rao'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('5. since you were last here', () {
    Future<void> lastVisit(DateTime d) async {
      final p = await SharedPreferences.getInstance();
      await p.setString('ttc_precheck_last_visit', d.toIso8601String());
    }

    test('her own ticks since the previous visit are counted', () async {
      await TtcPrecheckStore.instance
          .setStatus('tobacco', PrecheckStatus.done);
      await TtcPrecheckStore.instance
          .setStatus('alcohol', PrecheckStatus.needsAttention);
      await lastVisit(DateTime.now().subtract(const Duration(days: 5)));
      await TtcPrecheckStore.instance.beginVisit();
      expect(TtcPrecheckStore.instance.settledSinceLastVisit(), 1,
          reason: 'one tick was Done; "Need to do" is not settled');
    });

    test('nothing to say on a first visit', () async {
      await TtcPrecheckStore.instance
          .setStatus('tobacco', PrecheckStatus.done);
      await TtcPrecheckStore.instance.beginVisit();
      expect(TtcPrecheckStore.instance.sinceVisit, isNull);
      expect(TtcPrecheckStore.instance.settledSinceLastVisit(), 0);
    });

    test('nothing to say when she was here earlier today', () async {
      await TtcPrecheckStore.instance
          .setStatus('tobacco', PrecheckStatus.done);
      await lastVisit(DateTime.now().subtract(const Duration(minutes: 20)));
      await TtcPrecheckStore.instance.beginVisit();
      expect(TtcPrecheckStore.instance.settledSinceLastVisit(), 0);
    });

    test('a tick the app made from her records is not hers to be counted',
        () async {
      // No entries at all: folate may read done from her supplements, but
      // nothing was settled in the checklist.
      await lastVisit(DateTime.now().subtract(const Duration(days: 5)));
      await TtcPrecheckStore.instance.beginVisit();
      expect(TtcPrecheckStore.instance.settledSinceLastVisit(), 0);
    });

    testWidgets('the ring card says so, once, with the date', (tester) async {
      await TtcPrecheckStore.instance
          .setStatus('tobacco', PrecheckStatus.done);
      final prev = DateTime.now().subtract(const Duration(days: 5));
      await lastVisit(prev);
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcPrecheckScreen()));
      await tester.pumpAndSettle();
      final since = find.byKey(const ValueKey('ttc_precheck_since'));
      expect(since, findsOneWidget);
      expect(
          (tester.widget(since) as Text).data, startsWith('1 more settled since '));
    });
  });

  // ===========================================================================
  group('4. a cloud copy, hers only', () {
    test('the blob carries every answer, keyed by item', () async {
      final st = TtcPrecheckStore.instance;
      await st.setStatus('tobacco', PrecheckStatus.done);
      await st.setNote('tobacco', 'quit in March');
      final blob = st.cloudData() as Map;
      expect(st.cloudKey, 'ttc_precheck');
      expect(blob.keys, contains('tobacco'));
      expect(blob['tobacco'], contains('quit in March'));
    });

    test('a new phone adopts what the cloud holds', () async {
      final st = TtcPrecheckStore.instance;
      final when = DateTime(2026, 9, 1).toIso8601String();
      st.applyCloudData({'alcohol': 'done|$when|0|'});
      expect(st.entryFor('alcohol')?.status, PrecheckStatus.done);
    });

    test('a merge: the answer settled last wins, per item', () async {
      final st = TtcPrecheckStore.instance;
      await st.setStatus('tobacco', PrecheckStatus.done); // now
      final old = DateTime.now().subtract(const Duration(days: 30));
      final fresh = DateTime.now().add(const Duration(days: 1));
      st.applyCloudData({
        // older than hers: hers stays
        'tobacco': 'needsAttention|${old.toIso8601String()}|0|',
        // newer than nothing: adopted
        'alcohol': 'notSure|${fresh.toIso8601String()}|0|',
      });
      expect(st.entryFor('tobacco')?.status, PrecheckStatus.done,
          reason: 'an older cloud answer must not undo a newer local one');
      expect(st.entryFor('alcohol')?.status, PrecheckStatus.notSure);
    });

    test('a damaged blob is ignored, never a crash', () {
      final st = TtcPrecheckStore.instance;
      st.applyCloudData('not a map');
      st.applyCloudData({'x': 3, 'y': 'garbage'});
      expect(st.entryFor('y'), isNull);
    });

    test('it lives in user_state, which only its owner can read', () {
      // The privacy promise ("nothing for his side") read from the migration:
      // every policy on the table is own-row, and none mentions the partner.
      final sql =
          File('supabase/migrations/0011_user_state.sql').readAsStringSync();
      expect(sql, contains('auth.uid() = user_id'));
      expect(sql, isNot(contains('my_partner_id')));
    });
  });

  // ===========================================================================
  group('3. Ask Veda is told what she has covered', () {
    final screen =
        File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
    final service =
        File('lib/services/remote/ask_veda_service.dart').readAsStringSync();

    test('the request body carries ttc_checklist', () {
      expect(service, contains("'ttc_checklist': ttcChecklist"));
    });

    test('it is hers: never sent from the partner device', () {
      expect(
        RegExp(r'ttcChecklist: widget\.partnerMode\s*\?\s*null')
            .hasMatch(screen),
        isTrue,
      );
    });

    test('nothing answered, nothing sent', () {
      expect(ttcPrecheckAskVedaContext(), isNull);
    });

    test('ids only, and only what SHE answered', () async {
      final st = TtcPrecheckStore.instance;
      await st.setStatus('tobacco', PrecheckStatus.done);
      await st.setStatus('alcohol', PrecheckStatus.needsAttention);
      await st.setNote('alcohol', 'a private worry in her own words');
      final ctx = ttcPrecheckAskVedaContext()!;
      expect(ctx['covered'], contains('tobacco'));
      expect(ctx['flagged'], contains('alcohol'));
      expect(ctx.toString(), isNot(contains('private worry')),
          reason: 'her notes never leave the phone through Ask Veda');
    });

    test('the two-repo handover is written down', () {
      final doc =
          File('docs/ASKVEDA-CHECKLIST-HANDOVER.md').readAsStringSync();
      expect(doc, contains('ttc_checklist'));
      expect(doc, contains('inert'));
    });
  });
}
