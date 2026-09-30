// His side of the pregnancy app (2026-09-30, gap analysis "Partner (his side)"):
// the For partners door, the week by week guide, the Learn tab, and the small
// things on her side that reach him. The skeleton and the words; the skin is a
// later pass.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_partner.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/data/reads/pregnancy_reads_partner.dart';
import 'package:parentveda/models/week_content.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/father/father_learn_screen.dart';
import 'package:parentveda/screens/father/father_week_guide_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

import 'dart:convert';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

List<WeekContent> _weeks() => [
      for (final j in jsonDecode(File('lib/data/weekContent.json').readAsStringSync()) as List)
        WeekContent.fromJson((j as Map).cast<String, dynamic>()),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController loaded;

  // Loaded once, outside the widget tests' fake-async zone, as preg_week_page_test
  // does: a `load()` inside `testWidgets` never completes.
  setUpAll(() async {
    final due = DateTime.now().add(const Duration(days: 140));
    SharedPreferences.setMockInitialValues({
      PregnancyController.kDueDateKey: DateTime(due.year, due.month, due.day).toIso8601String(),
    });
    loaded = PregnancyController(dueDate: due);
    await loaded.load();
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the door', () {
    test('has five tabs, each with something in it', () {
      expect(kPartnerDoor.groups.map((g) => g.id),
          [kPartnerTabWeek, kPartnerTabSupport, kPartnerTabBirth, kPartnerTabYou, kPartnerTabReady]);
      for (final g in kPartnerDoor.groups) {
        expect(kPartnerDoor.sections.where((s) => s.group == g.id), isNotEmpty, reason: g.id);
      }
      expect(kPartnerDoor.closingLine, contains('Her doctor decides'));
    });

    test('every guide tile opens a read that exists', () {
      final tiles = kPartnerDoor.allTiles.whereType<PvDoorGuideTile>().toList();
      expect(tiles.length, greaterThan(10));
      for (final t in tiles) {
        expect(pregnancyReadById(t.readId), isNotNull, reason: '${t.title}: ${t.readId}');
      }
    });

    test('every tool tile opens a surface that resolves', () {
      for (final t in kPartnerDoor.allTiles.whereType<PvDoorToolTile>()) {
        expect(pvDoorSurfaceResolves(t.surfaceId), isTrue, reason: '${t.title}: ${t.surfaceId}');
      }
      expect(pvDoorSurfaceResolves(kPartnerSurfaceDoor), isTrue);
      expect(pvDoorSurfaceResolves(kPartnerSurfaceWeekGuide), isTrue);
    });

    test('the partner reads are all on a tile, all honest, and none is a labour read we already have', () {
      final onTiles = {for (final t in kPartnerDoor.allTiles.whereType<PvDoorGuideTile>()) t.readId};
      for (final id in kPartnerReadIds) {
        expect(onTiles, contains(id), reason: '$id is on no tile');
        final r = pregnancyReadById(id)!;
        expect(r.reviewed, isFalse, reason: '$id claims a review that did not happen');
        expect(r.shortAnswer?.en.trim(), isNotEmpty, reason: id);
      }
      expect(onTiles, contains('preg_labour_read_partner'), reason: 'the labour job read is linked, not rewritten');
      expect(kPartnerReadIds, isNot(contains('preg_partner_read_labour')));
    });

    test('it is not a home tile, and it opens from his side', () {
      expect(_code('lib/data/brackets/pregnancy_brackets.dart'), isNot(contains('pregnancy_partner')));
      expect(_code('lib/screens/doors/pv_door_router.dart'), contains('kPartnerSurfaceDoor => PvDoorScreen('));
    });
  });

  group('the week by week guide', () {
    test('groups every week that has a partner line into the three trimesters, in order', () {
      final groups = fatherGuideGroups(_weeks());
      expect(groups.map((g) => g.$1), ['First trimester', 'Second trimester', 'Third trimester']);
      final all = [for (final g in groups) ...g.$2.map((w) => w.week)];
      expect(all.length, 37);
      expect(all, [...all]..sort());
      for (final g in groups) {
        for (final w in g.$2) {
          expect(w.partner.whatYouCanDo.en.trim(), isNotEmpty, reason: 'week ${w.week}');
        }
      }
    });

    testWidgets('opens on this week, toggles, and offers to share the week', (t) async {
      t.view.physicalSize = const Size(360, 2600);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final c = loaded;
      await t.pumpWidget(MaterialApp(home: FatherWeekGuideScreen(controller: c)));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Your week, week by week'), findsOneWidget);
      expect(find.text('First trimester'), findsOneWidget);
      expect(find.byKey(ValueKey('partner_week_share_${c.currentWeek}')), findsOneWidget,
          reason: "this week's row is open and shareable");
      await t.ensureVisible(find.byKey(const ValueKey('partner_week_5')));
      await t.tap(find.byKey(const ValueKey('partner_week_5')));
      await t.pump();
      expect(find.byKey(const ValueKey('partner_week_share_5')), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('the Learn tab', () {
    test('its topics are the door\'s own tabs', () {
      final ids = kPartnerDoor.groups.map((g) => g.id).toSet();
      for (final t in kFatherLearnTopics) {
        expect(ids, contains(t.tab), reason: t.title);
      }
      expect(kFatherLearnTopics.map((t) => t.tab).toSet().length, kFatherLearnTopics.length);
    });

    testWidgets('lists the guide, the five topics and the old reads one tap in', (t) async {
      t.view.physicalSize = const Size(360, 1200);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
      await t.pumpWidget(MaterialApp(home: Scaffold(body: FatherLearnScreen(controller: c))));
      await t.pump();
      expect(find.byKey(const ValueKey('father_learn_week_guide')), findsOneWidget);
      for (final tt in kFatherLearnTopics) {
        expect(find.byKey(ValueKey('father_learn_${tt.tab}')), findsOneWidget, reason: tt.title);
      }
      expect(find.byKey(const ValueKey('father_learn_more_reads')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    test('the partner bar uses it, and the old Reads list is still reachable', () {
      final s = _code('lib/screens/main_scaffold.dart');
      expect(s, contains('FatherLearnScreen(controller: widget.pregnancy)'));
      expect(s, contains("PvTab(Icons.menu_book_rounded, 'Learn')"));
      expect(_code('lib/screens/father/father_learn_screen.dart'), contains('const FatherReadsScreen()'));
    });
  });

  group('the small things that reach him', () {
    test("his Today shows this week's part and the way into the guide and the door", () {
      final s = _code('lib/screens/father/father_daily_screen.dart');
      expect(s, contains('_weekGuideCard(p)'));
      expect(s, contains('openFatherWeekGuide(context, c)'));
      expect(s, contains('kPartnerSurfaceDoor'));
    });

    test('his journal starts empty and says so, and the seed entries stay out', () {
      final j = _code('lib/screens/father/father_journal_screen.dart');
      expect(j, contains("'Write the first line'"));
      expect(j, contains("'She will not see it unless you share it.'"));
      expect(_code('lib/screens/father/father_daily_screen.dart'), isNot(contains('Felt the first kick against my palm tonight')));
    });

    test('her week page can share the partner line, and the pairing screen says what the switch does', () {
      expect(_code('lib/screens/preg_week_screen.dart'), contains("ValueKey('week_share_partner')"));
      final p = _code('lib/screens/profile/pv_partner_screen.dart');
      expect(p, contains('Turn this off whenever you like'));
      expect(p.toLowerCase(), isNot(contains('unpair at any time')), reason: 'unpairing is not self-serve, so we do not promise it');
    });
  });
}
