// =============================================================================
//  Her own history moves the doors (final review item 12, 2026-10-28).
//
//  What she has lived through, not only the child's age, decides what comes
//  first: a loss before this baby, treatment, a second child at home, a
//  child's diagnosis, and (already) twins, born early, a C-section. Order and
//  content only: nothing is added, removed or hidden, and a door that leads
//  with something on purpose (You, Maa's check-in, First 40's days) keeps it.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/profile/pv_you_sheets.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/pregnancy_records.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_store.dart';

PpPage? _anyPage(String id) {
  for (final d in kPpDoors) {
    final p = ppSectionFor(d.sectionId)?.pageById(id);
    if (p != null) return p;
  }
  return null;
}

DateTime _monthsAgo(int m) =>
    DateTime.now().subtract(Duration(days: (m * 30.44).round() + 3));

void _clean() {
  ChildProfileStore.instance.resetForTest();
  PregnancyRecords.instance.debugReset();
  TtcStore.instance.setPath(TtcPath.natural);
  final fam = FamilyProfileStore.instance;
  fam.clearConditions();
  fam.setGentle(null);
  fam.setBirth(multiple: false, premature: false, nicu: false);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _clean();
  });
  tearDown(_clean);

  group('the lists', () {
    test('every page a signal names exists, and every tab it leads', () {
      for (final s in PpSignal.values) {
        for (final id in s.pageIds) {
          expect(_anyPage(id), isNotNull, reason: '${s.name}: $id');
        }
        for (final MapEntry(key: door, value: tab) in s.leadTabs.entries) {
          final d = kPpDoors.where((x) => x.sectionId == door).firstOrNull;
          expect(d, isNotNull, reason: '${s.name}: door $door');
          expect(d!.tabs.map((t) => t.id), contains(tab), reason: '${s.name}: $door/$tab');
          expect(s.because, isNotNull, reason: '${s.name} leads a tab, so it says why');
        }
      }
    });

    test('no lead tab in the doors that open on purpose', () {
      for (final s in PpSignal.values) {
        expect(s.leadTabs.keys, isNot(contains('parenting_maternal')), reason: s.name);
        expect(s.leadTabs.keys, isNot(contains('parenting_first_40')), reason: s.name);
      }
    });

    test('an id moves a page its title does not name', () {
      const title = 'Bringing home a small or early baby';
      expect(PpSignal.bornEarly.matches(title), isFalse);
      expect(PpSignal.bornEarly.matches(title, ['f40_small_or_early']), isTrue);
      const sit = PpSituation(ageMonths: 1, daysOld: 30, signals: {PpSignal.bornEarly});
      expect(ppRelevanceWhy(sit, title, 'f40_small_or_early'), 'Born early');
      expect(ppRelevanceWhy(sit, title), isNull);
    });

    test('the two new pages lead their area for her, and nothing is dropped', () {
      final mind = ppSectionFor('parenting_maternal')!
          .areas
          .firstWhere((a) => a.id == 'your_mind')
          .pages;
      for (final (signal, id) in [
        (PpSignal.afterLoss, 'mind_after_loss'),
        (PpSignal.afterTreatment, 'mind_after_trying'),
      ]) {
        final sit = PpSituation(ageMonths: 2, daysOld: 60, signals: {signal});
        final out = ppRelevanceOrder(mind,
            situation: sit, text: (p) => p.title, ids: (p) => [p.id]);
        expect(out.toSet(), mind.toSet());
        final at = out.indexWhere((p) => p.id == id);
        for (final p in out.skip(at + 1)) {
          expect(sit.signalFor(p.title, [p.id]), isNull,
              reason: '$id comes before every page not about her');
        }
        // With no signal the writers' order stands.
        expect(
            ppRelevanceOrder(mind,
                situation: const PpSituation(ageMonths: 2, daysOld: 60),
                text: (p) => p.title,
                ids: (p) => [p.id]),
            mind);
      }
    });

    test('the new pages: free help above the doctor box, links land, for every band', () {
      final you = ppSectionFor('parenting_maternal')!;
      for (final id in ['mind_after_loss', 'mind_after_trying']) {
        final page = you.pageById(id)!;
        expect(page.bands.length, you.bandSet!.bands.length, reason: id);
        final callouts = page.blocks.whereType<PpCallout>().toList();
        final free = callouts.indexWhere((c) => c.text.contains('14416'));
        final doctor = callouts.indexWhere((c) => c.kind == PpCalloutKind.doctor);
        expect(free, greaterThanOrEqualTo(0), reason: id);
        expect(free, lessThan(doctor), reason: id);
        for (final l in page.blocks.whereType<PpLink>()) {
          final target = you.pageById(l.pageId!);
          expect(target, isNotNull, reason: '$id -> ${l.pageId}');
          expect(l.label, target!.title, reason: 'a link label is its page\'s title');
        }
      }
    });
  });

  group('derived from the stores, never asked', () {
    test('a loss before this child, from the record or her own answer', () async {
      final kid = await ChildProfileStore.instance
          .addChild(name: 'Asha', isBoy: false, dob: _monthsAgo(3));
      expect(PpSituation.now().signals, isNot(contains(PpSignal.afterLoss)));
      PregnancyRecords.instance.debugReset(rows: [
        PregnancyRecord(
            id: 'preg_a',
            startedOn: DateTime(2024, 1, 1),
            endedOn: DateTime(2024, 3, 1),
            outcome: PregnancyOutcome.loss),
        PregnancyRecord(
            id: 'preg_b',
            startedOn: DateTime(2025, 1, 1),
            outcome: PregnancyOutcome.birth,
            childId: kid.id),
      ]);
      expect(PregnancyRecords.instance.lossBefore(kid.id), isTrue);
      expect(PpSituation.now().signals, contains(PpSignal.afterLoss));

      PregnancyRecords.instance.debugReset();
      FamilyProfileStore.instance.setGentle('loss');
      expect(PpSituation.now().signals, contains(PpSignal.afterLoss));
    });

    test('treatment, from an IVF-dated pregnancy or her TTC path', () async {
      final kid = await ChildProfileStore.instance
          .addChild(name: 'Kabir', isBoy: true, dob: _monthsAgo(2));
      expect(PpSituation.now().signals, isNot(contains(PpSignal.afterTreatment)));
      PregnancyRecords.instance.debugReset(rows: [
        PregnancyRecord(
            id: 'preg_b',
            startedOn: DateTime(2025, 1, 1),
            outcome: PregnancyOutcome.birth,
            dueDateSource: 'ivfTransfer',
            childId: kid.id),
      ]);
      expect(PpSituation.now().signals, contains(PpSignal.afterTreatment));

      PregnancyRecords.instance.debugReset();
      TtcStore.instance.setPath(TtcPath.iui);
      expect(PpSituation.now().signals, contains(PpSignal.afterTreatment));
    });

    test('two at home: a newborn with an older child, not twins', () async {
      final kids = ChildProfileStore.instance;
      final older = await kids.addChild(name: 'Riya', isBoy: false, dob: _monthsAgo(36));
      final baby = await kids.addChild(name: 'Dev', isBoy: true, dob: _monthsAgo(1));
      await kids.switchTo(baby.id);
      expect(PpSituation.now().signals, contains(PpSignal.twoAtHome));
      expect(PpSituation.now().leadTabFor('parenting_family')?.$2, 'second');
      await kids.switchTo(older.id);
      expect(PpSituation.now().signals, isNot(contains(PpSignal.twoAtHome)));

      kids.resetForTest();
      final twinA = await kids.addChild(name: 'Ira', isBoy: false, dob: _monthsAgo(1));
      await kids.addChild(name: 'Ila', isBoy: false, dob: twinA.dob);
      expect(PpSituation.now().signals, isNot(contains(PpSignal.twoAtHome)));
    });

    test('a diagnosis in the family profile', () {
      expect(PpSituation.now().signals, isNot(contains(PpSignal.extraSupport)));
      FamilyProfileStore.instance.toggleCondition(HealthCondition.hearing);
      expect(PpSituation.now().signals, contains(PpSignal.extraSupport));
      expect(PpSituation.now().leadTabFor('parenting_special_care')?.$2, 'more');
    });
  });

  group('the door opens on her tab, and says why', () {
    Future<void> pump(WidgetTester t, String sectionId, int months) async {
      t.view.physicalSize = const Size(360, 780);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      ChildProfileStore.instance.debugSetDob(_monthsAgo(months));
      await t.pumpWidget(MaterialApp(
        home: PpDoorScreen(door: ppDoorFor(sectionId)!, onSurface: (_, _) {}),
      ));
      await t.pumpAndSettle();
    }

    Finder firstCard(String label) => find.descendant(
        of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(label));

    testWidgets('a twins mother of a two-year-old lands on Twins', (t) async {
      await pump(t, 'parenting_special_care', 26);
      expect(firstCard('Extra support'), findsOneWidget, reason: 'by age, without twins');
      expect(find.byKey(const ValueKey('pp_door_why_first')), findsNothing);

      FamilyProfileStore.instance.setBirth(multiple: true);
      await t.pumpWidget(const SizedBox());
      await pump(t, 'parenting_special_care', 26);
      expect(firstCard('Twins'), findsOneWidget);
      expect(find.text('First here, because you have twins'), findsOneWidget);
    });

    testWidgets('a tab that leads by age anyway gets no reason line', (t) async {
      FamilyProfileStore.instance.setBirth(premature: true);
      await pump(t, 'parenting_special_care', 2);
      expect(firstCard('Preemies and NICU'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_door_why_first')), findsNothing);
    });
  });

  group('the birth sheet', () {
    testWidgets('the arrival asks the two optional rows; adding a child does not', (t) async {
      for (final arrival in [true, false]) {
        t.view.physicalSize = const Size(1080, 2400);
        t.view.devicePixelRatio = 3.0;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          key: ValueKey(arrival),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => showPvAddChildSheet(ctx, arrival: arrival),
                child: const Text('go'),
              ),
            ),
          ),
        ));
        await t.tap(find.text('go'));
        await t.pumpAndSettle();
        final rows = [
          find.text('How was your baby born?'),
          find.text('Did your baby need the NICU?'),
        ];
        for (final r in rows) {
          expect(r, arrival ? findsOneWidget : findsNothing);
        }
        if (arrival) {
          await t.tap(find.byKey(const ValueKey('pv_birth_mode_cSection')));
          await t.tap(find.byKey(const ValueKey('pv_birth_nicu_true')));
          await t.pump();
          expect(t.takeException(), isNull);
        }
      }
    });

    test('the save carries twins over and keeps both answers (wiring)', () {
      final src = File('lib/screens/profile/pv_you_sheets.dart').readAsStringSync();
      expect(src, contains('fam.setBirthDetails(mode: mode)'));
      expect(src, contains('fam.setBirth(nicu: nicu)'));
      expect(src, contains('if (fam.expectingTwins)'));
      expect(src, contains('birthMode: arrival ? mode?.name : null'));
    });
  });
}
