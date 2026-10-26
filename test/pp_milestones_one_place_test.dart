// =============================================================================
//  R10: Milestones, one place, one list, one save (2026-10-26)
// -----------------------------------------------------------------------------
//  Holds what the build promised (STAGE-TRANSITIONS R10):
//    * one list: the snapshot and area-stage maps point only at real
//      catalogue ids, and at titles that really exist;
//    * one save: a milestone saved anywhere is one record, and the journal
//      switch keeps ONE memory however often it is saved;
//    * her own milestones round-trip and never break the catalogue readers;
//    * the sync columns: photo_path and title are sent only when set (so a
//      row is valid before migration 0116 is run) and exist in 0116;
//    * "you are here" follows the child's age;
//    * the checklist words are gone from the touched screens;
//    * wiring: every way in reaches the one place (the source, read).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/pp_phase_docs/index.dart';
import 'package:parentveda/screens/post_pregnancy/development_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_screen.dart';
import 'package:parentveda/services/pp_use_consent.dart';

String live(String path) => File(path)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MilestoneStore.instance.debugReset();
    PpJournalStore.instance.debugReset();
    PpUseConsent.instance.applyCloudItems(const {});
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  void ageDays(int days) =>
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: days)));

  Future<void> pump(WidgetTester t, Widget w, {double h = 4200}) async {
    t.view.physicalSize = Size(360 * 3, h * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pumpAndSettle();
  }

  group('one list (DV2)', () {
    final ids = {for (final m in kMilestones) m.id};

    test('catalogue ids are unique, and the three R10 gaps are filled', () {
      expect(ids.length, kMilestones.length);
      for (final id in ['lang_voice', 'gm_pullup', 'soc_point']) {
        expect(ids, contains(id));
      }
    });

    test('every snapshot the map names exists, and points at a real milestone', () {
      final titles = <String>{
        for (final doc in kPpPhaseDocList)
          for (final s in doc.snapshot) s.title,
      };
      kSnapshotMilestone.forEach((title, id) {
        expect(titles, contains(title), reason: 'no snapshot titled "$title"');
        expect(ids, contains(id), reason: '$title -> $id');
      });
    });

    test('every area stage the map names exists, and points at a real milestone', () {
      final stages = <String>{
        for (final a in kDevAreas)
          for (final s in a.journey) '${a.id}|${s.name}',
      };
      kDevStageMilestone.forEach((key, id) {
        expect(stages, contains(key), reason: 'no stage "$key" (renamed?)');
        expect(ids, contains(id), reason: '$key -> $id');
      });
    });

    test('every domain has an area on the screen', () {
      for (final d in DevDomain.values) {
        expect(kMsAreaLabel[msAreaOf(d)], isNotNull);
      }
    });
  });

  group('the store', () {
    test('a milestone of her own round-trips and the catalogue readers survive it', () {
      ageDays(200);
      final ms = MilestoneStore.instance;
      final id = ms.markOwn('First time at Nani\'s', note: 'She laughed all day');
      ms.markObserved('gm_roll', date: DateTime.now().subtract(const Duration(days: 30)));
      expect(id, startsWith(kOwnMilestonePrefix));
      expect(ms.observation(id)!.title, 'First time at Nani\'s');
      // `achieved` used to map every id through byId, which threw on own_.
      expect(ms.achieved.map((m) => m.id), ['gm_roll']);
      expect(ms.seen.map((s) => s.id), [id, 'gm_roll'], reason: 'newest first, both kinds');
      expect(ms.newest!.title, 'First time at Nani\'s');
      expect(ms.seenIn(null), 2);
      expect(ms.seenIn(MsArea.moving), 1);
      expect(ms.seenIn(MsArea.talking), 0);
    });

    test('the doctor visit lists her own milestones too', () {
      ageDays(200);
      PpUseConsent.instance.set(PpUseKind.development, true);
      MilestoneStore.instance.markOwn('Waved bye-bye');
      expect(ppDoctorVisitDevelopmentLine(), contains('Waved bye-bye'));
    });

    test('photo_path and title are sent only when set (valid before 0116 runs)', () {
      final bare = MilestoneStore.debugCols('gm_roll', MilestoneObs(date: DateTime.utc(2026, 10, 1)));
      expect(bare.keys, unorderedEquals(['milestone_id', 'observed_on', 'note']));
      final full = MilestoneStore.debugCols('own_1',
          MilestoneObs(date: DateTime.utc(2026, 10, 1), photo: 'u/milestones/a.jpg', title: 'Mine'));
      expect(full['photo_path'], 'u/milestones/a.jpg');
      expect(full['title'], 'Mine');
    });

    test('migration 0116 adds exactly the columns the app sends', () {
      final sql = File('supabase/migrations/0116_pp_milestone_photo.sql').readAsStringSync();
      expect(sql, contains('alter table public.pp_milestone_observations'));
      expect(sql, contains('add column if not exists photo_path text'));
      expect(sql, contains('add column if not exists title      text'));
      final src = live('lib/screens/post_pregnancy/pp_milestones_data.dart');
      expect(src, contains("if (obs.photo != null) 'photo_path': obs.photo"));
      expect(src, contains("if (obs.title != null) 'title': obs.title"));
      expect(src, contains("photo: r['photo_path']?.toString()"));
    });
  });

  group('the one save', () {
    testWidgets('saving from the screen lands once, with one journal memory, and a re-save adds none', (t) async {
      ageDays(185);
      await pump(t, const PpMilestonesScreen());
      final m = MilestoneStore.instance.emerging.first;
      await t.ensureVisible(find.byKey(ValueKey('pp_ms_saw_${m.id}')));
      await t.tap(find.byKey(ValueKey('pp_ms_saw_${m.id}')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_ms_save')));
      await t.pumpAndSettle();
      expect(MilestoneStore.instance.isObserved(m.id), isTrue);
      expect(PpJournalStore.instance.hasMilestone(m.id), isTrue);
      // The moment page says what changed.
      expect(find.text('Kept in the journal too, as one memory'), findsOneWidget);
      await t.tap(find.text('Back to Milestones'));
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('pp_ms_seen_${m.id}')), findsOneWidget);

      // Edit it: same record, still one journal memory.
      await t.tap(find.byKey(ValueKey('pp_ms_seen_${m.id}')));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, 'Did it again');
      await t.tap(find.byKey(const ValueKey('pp_ms_save')));
      await t.pumpAndSettle();
      expect(MilestoneStore.instance.observation(m.id)!.note, 'Did it again');
      final memories = PpJournalStore.instance.entries.where((e) => e.title == m.title).toList();
      expect(memories, hasLength(1));
      expect(memories.single.body, 'Did it again');
    });

    testWidgets('with the journal switch off, no memory is kept', (t) async {
      ageDays(185);
      await pump(t, const PpMilestonesScreen());
      final m = MilestoneStore.instance.emerging.first;
      await t.ensureVisible(find.byKey(ValueKey('pp_ms_saw_${m.id}')));
      await t.tap(find.byKey(ValueKey('pp_ms_saw_${m.id}')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_ms_save_journal')));
      await t.tap(find.byKey(const ValueKey('pp_ms_save')));
      await t.pumpAndSettle();
      expect(MilestoneStore.instance.isObserved(m.id), isTrue);
      expect(PpJournalStore.instance.hasMilestone(m.id), isFalse);
      expect(find.text('Not added to the journal'), findsOneWidget);
    });

    testWidgets('one of her own, from the picker', (t) async {
      ageDays(185);
      await pump(t, const PpMilestonesScreen(startSave: true));
      await t.enterText(find.byKey(const ValueKey('pp_ms_picker_search')), 'First trip to the sea');
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('pp_ms_picker_own')));
      await t.pumpAndSettle();
      expect(find.text('First trip to the sea'), findsOneWidget, reason: 'the title carries over');
      await t.tap(find.byKey(const ValueKey('pp_ms_save')));
      await t.pumpAndSettle();
      expect(MilestoneStore.instance.newest!.title, 'First trip to the sea');
      expect(MilestoneStore.instance.newest!.isOwn, isTrue);
    });

    testWidgets('empty: the page invites rather than hides', (t) async {
      ageDays(185);
      await pump(t, const PpMilestonesScreen());
      expect(find.text('Milestones'), findsWidgets);
      expect(find.byKey(const ValueKey('pp_milestones_seen_empty')), findsOneWidget);
      expect(find.text('Might appear soon'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_milestones_to_doctor')), findsOneWidget);
    });
  });

  group('the Development Map', () {
    test('"you are here" follows the age', () {
      expect(devMapBandFor(0), 0);
      expect(devMapBandFor(4), 1);
      expect(devMapBandFor(10), 3);
      expect(devMapBandFor(30), 5);
      expect(devMapBandFor(70), 7);
    });

    testWidgets('a ten-month-old is on 9-12 months, and a saved one shows there', (t) async {
      ageDays(305);
      MilestoneStore.instance.markObserved('soc_point');
      await pump(t, const DevelopmentMapScreen(), h: 6000);
      expect(find.text('YOU ARE HERE'), findsOneWidget);
      final here = t.getTopLeft(find.text('YOU ARE HERE')).dy;
      final band3 = t.getTopLeft(find.byKey(const ValueKey('devmap_band_3'))).dy;
      final band4 = t.getTopLeft(find.byKey(const ValueKey('devmap_band_4'))).dy;
      expect(here, greaterThan(band3));
      expect(here, lessThan(band4));
      await t.tap(find.byKey(const ValueKey('devmap_band_3')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('devmap_ms_soc_point')), findsOneWidget);
      expect(find.textContaining('Seen '), findsWidgets);
    });
  });

  group('words and wiring', () {
    test('no checklist words on the touched screens', () {
      for (final f in [
        'lib/screens/post_pregnancy/pp_milestones_screen.dart',
        'lib/screens/post_pregnancy/pp_month_checklist_screen.dart',
        'lib/screens/post_pregnancy/development_map_screen.dart',
      ]) {
        final src = live(f).toLowerCase();
        for (final w in ['overdue', 'tap the circle', 'not ticked', "this month's checklist", 'skills coming in now']) {
          expect(src, isNot(contains(w)), reason: '$f says "$w"');
        }
      }
      expect(live('lib/data/doors/pp_door_development.dart'), isNot(contains("label: 'On track'")));
      expect(live('lib/screens/post_pregnancy/development_checkin_screen.dart'),
          isNot(contains("title: 'A gentle check-in'")));
    });

    test('every way in reaches the one place', () {
      final home = live('lib/screens/post_pregnancy/pp_home_v3.dart');
      expect(home, contains("ValueKey('pp_home_milestones')"), reason: 'the row under Today');
      expect(home, contains("_openSurface(context, 'pp_milestones')"));
      expect(home, contains('PpMilestonesScreen(\n                                    startSave: true)'),
          reason: "the journal's quick action is the one save");
      final router = live('lib/screens/post_pregnancy/pp_surface_router.dart');
      expect(router, contains("'pp_milestones' => const PpMilestonesScreen(),"));
      expect(router, contains("'pp_on_track' => const PpMilestonesScreen(),"));
      expect(live('lib/screens/post_pregnancy/pp_brain_tab.dart'), contains('_push(const PpMilestonesScreen()'));
      // An old link that still builds the journey lands on the same place.
      expect(live('lib/screens/post_pregnancy/milestone_journey_screen.dart'),
          contains('Widget build(BuildContext context) => const PpMilestonesScreen();'));
      expect(live('lib/screens/post_pregnancy/pp_month_checklist_screen.dart'), contains('openMilestoneSave('));
      expect(live('lib/screens/post_pregnancy/development_map_screen.dart'), contains('openMilestoneSave('));
    });
  });
}
