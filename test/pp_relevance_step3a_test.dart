// =============================================================================
//  Parenting relevance, Step 3a (docs/door-relevance/PARENTING-GAP.md, PP 7)
// -----------------------------------------------------------------------------
//  PP 7. "No single lead action, especially after 12 months." Approved in the
//  Artifact prototype with the user's changes (2026-10-28):
//
//    - an urgent "Something changed?" answer, for its first week, sits above
//      the Today rail, and its own "You told us" row steps aside;
//    - a visit within a week leads today's block under "Explore by topic",
//      and the visit card above the grid steps aside;
//    - the first of today's three is raised, and the rows hold the other two.
//
//  Found on the way: a child whose vaccines were never ticked here showed
//  "DUE NOW: the birth visit" on the home for ever. A visit now shows for a
//  week after its date at most.
//
//  Source scans pin the wiring: a correct helper nobody calls is the failure
//  this repo has hit.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_changes_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_today.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_visit_card.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/pp_use_consent.dart';

String _src(String path) => File(path).readAsStringSync();

WcConcern _concern(String id) => kWcConcerns.firstWhere((c) => c.id == id);

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final kids = ChildProfileStore.instance;
  final changes = PpChangesStore.instance;
  final consent = PpUseConsent.instance;
  final p = V2PaletteStore.instance.current;
  final now = DateTime.now();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    kids.resetForTest();
    kids.debugSetDob(now.subtract(const Duration(days: 70)));
    changes.debugReset();
    consent.debugReset();
    VaxStore.instance.debugReset();
  });

  // ==========================================================================
  //  The urgent follow-up
  // ==========================================================================
  group('PP 7: an urgent answer leads for a week', () {
    test('an urgent answer from yesterday leads', () {
      consent.set(PpUseKind.changes, true);
      changes.note(_concern('vomiting'), WcTone.urgent, at: now.subtract(const Duration(days: 1)));
      expect(ppUrgentFollowUp(now: now)?.concernId, 'vomiting');
    });

    test('after 7 days it is an ordinary row again', () {
      consent.set(PpUseKind.changes, true);
      changes.note(_concern('vomiting'), WcTone.urgent, at: now.subtract(const Duration(days: 8)));
      expect(ppUrgentFollowUp(now: now), isNull);
      expect(changes.active(now: now), hasLength(1), reason: 'still active for its three weeks');
    });

    test('a calm or caution answer never leads', () {
      consent.set(PpUseKind.changes, true);
      changes.note(_concern('spitting_up'), WcTone.calm, at: now);
      changes.note(_concern('cough'), WcTone.caution, at: now);
      expect(ppUrgentFollowUp(now: now), isNull);
    });

    test('without her yes, nothing is used', () {
      consent.set(PpUseKind.changes, false);
      changes.note(_concern('vomiting'), WcTone.urgent, at: now);
      expect(ppUrgentFollowUp(now: now), isNull);
    });

    testWidgets('the card says what she told us, why it is first, and routes to a doctor', (t) async {
      var better = 0, worried = 0;
      final c = PpChange(childId: 'x', concernId: 'vomiting', at: now.subtract(const Duration(days: 1)), tone: WcTone.urgent);
      await t.pumpWidget(_host(PpUrgentFollowUpCard(
        change: c,
        childName: 'Aarav',
        p: p,
        now: now,
        onOpen: () {},
        onBetter: () => better++,
        onWorried: () => worried++,
      )));
      expect(find.text('YOU TOLD US · YESTERDAY'), findsOneWidget);
      expect(find.text('Has Aarav been seen?'), findsOneWidget);
      expect(find.text('First here, because the check said Aarav should be seen.'), findsOneWidget);
      expect(find.textContaining("We can't tell you what it is"), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('pp_home_urgent_better')));
      await t.tap(find.byKey(const ValueKey('pp_home_urgent_worried')));
      expect((better, worried), (1, 1));
      expect(t.takeException(), isNull);
    });
  });

  // ==========================================================================
  //  The visit within a week
  // ==========================================================================
  group('PP 7: a visit within a week leads today\'s block', () {
    // The 6-week visit falls on day 42.
    void ageDays(int d) {
      kids.debugSetDob(now.subtract(Duration(days: d)));
      VaxStore.instance.markDone('birth');
    }

    test('six days ahead: it leads, and says so', () {
      ageDays(36);
      final v = ppVisitLead(now: now);
      expect(v?.id, 'wk6');
      expect(ppDaysToVisit(v!, now: now), 6);
      expect(ppVisitLeadWhy(6), 'First here, because the visit is in 6 days.');
    });

    test('today leads; tomorrow says tomorrow', () {
      ageDays(42);
      expect(ppVisitLead(now: now)?.id, 'wk6');
      expect(ppVisitLeadWhy(0), 'First here, because the visit is today.');
      expect(ppVisitLeadWhy(1), 'First here, because the visit is tomorrow.');
    });

    test('eight days ahead: the card above the grid, not the lead', () {
      ageDays(34);
      expect(ppVisitLead(now: now), isNull);
      expect(ppVisitCardFor(now: now)?.id, 'wk6');
    });

    test('only ahead, never overdue: two days past is the card above the grid', () {
      ageDays(44);
      expect(ppVisitLead(now: now), isNull);
      expect(ppVisitCardFor(now: now)?.id, 'wk6');
    });

    test('a visit marked done never leads', () {
      ageDays(38);
      VaxStore.instance.markDone('wk6');
      expect(ppVisitLead(now: now)?.id, isNot('wk6'));
    });

    test('found: nothing ticked no longer shows the birth visit to a two-year-old', () {
      kids.debugSetDob(now.subtract(const Duration(days: 730)));
      expect(ppVisitCardFor(now: now), isNull);
      expect(ppVisitLead(now: now), isNull);
    });

    testWidgets('the questions open in place', (t) async {
      ageDays(38);
      final v = ppVisitLead(now: now)!;
      await t.pumpWidget(_host(PpVisitLeadCard(visit: v, days: 4, p: p, onOpen: () {})));
      expect(find.text('The 6 weeks visit'), findsOneWidget);
      expect(find.text('First here, because the visit is in 4 days.'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_home_visit_q_0')), findsNothing);
      await t.tap(find.byKey(const ValueKey('pp_home_visit_questions')));
      await t.pump();
      expect(find.byKey(const ValueKey('pp_home_visit_q_0')), findsOneWidget);
      expect(find.text('Hide the questions'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ==========================================================================
  //  The raised first activity
  // ==========================================================================
  group('PP 7: the first of the three, raised', () {
    testWidgets('its tick is the one tick, and it fits at 1.5x on 360', (t) async {
      final a = kDevActivities.first;
      var done = 0;
      t.view.physicalSize = const Size(360 * 3, 900 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: _host(PpFirstActivityCard(
          activity: a,
          leading: const SizedBox(width: 56, height: 56),
          done: false,
          p: p,
          onOpen: () {},
          onDone: () => done++,
          onSwap: () {},
        )),
      ));
      expect(find.text('START HERE'), findsOneWidget);
      await t.tap(find.byKey(ValueKey('pp_home_activity_done_${a.id}')));
      expect(done, 1);
      expect(t.takeException(), isNull);
    });
  });

  // ==========================================================================
  //  The rail under one
  // ==========================================================================
  group('PP 7: a tip that matches her, with its reason', () {
    test('a breastfeeding mother at 17 weeks gets a tip about her, never today\'s', () {
      kids.debugSetDob(now.subtract(const Duration(days: 17 * 7 + 2)));
      final sit = PpSituation(ageMonths: 4, daysOld: 121, signals: {PpSignal.breastfeeding});
      final tip = ppHomeSituationTip(sit, on: now);
      expect(tip, isNotNull);
      expect(tip!.eyebrow, ppRelevanceWhy(sit, '${tip.tip.title} ${tip.tip.body}', tip.id.replaceFirst('atip_', '')));
      expect(tip.id, isNot(ppHomeInsights(on: now).first.id));
    });

    test('nothing about her situation: no tile', () {
      kids.debugSetDob(now.subtract(const Duration(days: 17 * 7 + 2)));
      expect(ppHomeSituationTip(const PpSituation(ageMonths: 4, daysOld: 121), on: now), isNull);
      expect(ageTipsFor(17), isNotEmpty);
    });
  });

  // ==========================================================================
  //  Wiring: the home calls all of it, in the agreed places
  // ==========================================================================
  group('PP 7: wired into the home', () {
    final home = _src('lib/screens/post_pregnancy/pp_home_v3.dart');

    test('urgent above the rail; its row steps aside', () {
      final card = home.indexOf('_pad(PpUrgentFollowUpCard(');
      final rail = home.indexOf('PvInsightRail(tiles: [');
      expect(home, contains('final urgent = ppUrgentFollowUp(now: now);'));
      expect(card, greaterThan(0));
      expect(rail, greaterThan(card));
      expect(home, contains('if (c.concernId != urgent?.concernId) c'));
    });

    test('visit lead and the raised activity under the grid, before the rows', () {
      final explore = home.indexOf("title: 'Explore by topic'");
      final visit = home.indexOf('_pad(PpVisitLeadCard(');
      final first = home.indexOf('_pad(PpFirstActivityCard(');
      final rows = home.indexOf('activities: activities.skip(1).toList(),');
      expect(visit, greaterThan(explore));
      expect(first, greaterThan(visit));
      expect(rows, greaterThan(first));
      expect(home, contains('if (ppVisitCardFor(now: now) case final visit? when visitLead == null)'));
    });

    test('under one: growing now and her tip on the rail', () {
      expect(home, contains("key: const ValueKey('pp_home_growing_now')"));
      expect(home, contains('[?ppHomeSituationTip(sit, on: now), ...insights.take(1)]'));
      expect(home, contains('for (final c in railTips)'));
    });
  });
}
