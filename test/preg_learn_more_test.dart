// The pregnancy structure pass (2026-09-29): the bar is Today · Learn ·
// Products · Tools · More, the trying-to-conceive bar in its order; Learn has
// "Explore by topic" and a shelf per door; More holds what the bar dropped
// (Calendar) and not what is held back (Community); Tools is her tools only,
// grouped; the three unmade courses say "Opening soon" with no price; and his
// journal starts empty.
//
// ⚠️ SOURCE CHECKS WHERE THE CLAIM IS ABOUT WIRING. "Calendar is reachable"
// and "Community is not" are claims about call sites, which a count of
// passing widget tests says nothing about (CLAUDE.md, "Wiring gate").
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/brackets/pregnancy_brackets.dart';
import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/pregnancy/preg_learn_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_more_screen.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

String _read(String p) => File(p).readAsStringSync().replaceAll('\r\n', '\n');

/// The file without its comment lines, so a "kept for revert" line does not
/// count as a live call site.
String _code(String p) => _read(p)
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pregnancy = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  Future<void> pump(WidgetTester tester, Widget w, {double height = 780}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('the bar', () {
    test('Today · Learn · Products · Tools · More, in that order', () {
      final src = _code('lib/screens/main_scaffold.dart');
      final order = [
        'TodayHomeScreen(',
        'PregLearnScreen(',
        'PvStoreScreen(chrome: PvStoreChrome.embedded)',
        'ToolsHubScreen(',
        'PregMoreScreen(',
      ].map(src.indexOf).toList();
      expect(order.every((i) => i >= 0), isTrue, reason: '$order');
      for (var i = 1; i < order.length; i++) {
        expect(order[i], greaterThan(order[i - 1]));
      }
      expect(src, contains("PvTab(Icons.menu_book_outlined, 'Learn')"));
      expect(src, contains("PvTab(Icons.grid_view_outlined, 'More')"));
      expect(kPregTabLearn, 1);
      expect(kPregTabMore, 4);
    });

    test('Calendar and Community left the bar', () {
      final src = _code('lib/screens/main_scaffold.dart');
      expect(src, isNot(contains('CalendarScreen(')));
      expect(src, isNot(contains('CommunityScreen(')));
    });

    test('Calendar still has a home: More opens it, and so does a home tap', () {
      expect(_code('lib/screens/pregnancy/preg_more_screen.dart'), contains('CalendarScreen('));
      expect(_code('lib/screens/home_v3_screen.dart'), contains('CalendarScreen('));
    });

    test('Community is held back at every pregnancy entry point', () {
      for (final f in [
        'lib/screens/main_scaffold.dart',
        'lib/screens/global_search.dart',
        'lib/screens/pregnancy/preg_more_screen.dart',
        'lib/screens/pregnancy/preg_learn_screen.dart',
        'lib/screens/tools_hub_screen.dart',
      ]) {
        expect(_code(f), isNot(contains('CommunityScreen(')), reason: f);
      }
      // Ask Veda: the answer's community block and its coming-soon line.
      final veda = _code('lib/screens/tools/ask_veda_screen.dart');
      expect(veda, isNot(contains('_viewCommunity(v.community')));
      expect(veda, isNot(contains('        _feedCommunityComingSoon(),')));
    });
  });

  group('Learn', () {
    test('every door has a topic, including the two reached from inside others', () {
      final ids = {for (final t in pregLearnTopics()) t.bracket.id};
      for (final d in kPvDoorPages) {
        expect(ids, contains(d.bracketId), reason: d.bracketId);
      }
      expect(ids, containsAll([kPregAfterLossBracket.id, kPregTwinsBracket.id, kPregIsItSafeBracketId]));
      // The home's tiles lead, in the home's order.
      final first = pregLearnTopics().take(kPregnancyBrackets.length).map((t) => t.bracket.id);
      expect(first, [
        for (final b in kPregnancyBrackets)
          if (pvDoorPageFor(b.id) != null || b.id == kPregIsItSafeBracketId) b.id,
      ]);
    });

    test('every written piece on a door is on its shelf, once', () {
      for (final t in pregLearnTopics()) {
        final page = t.page;
        if (page == null) continue;
        final written = page.allTiles.where(pregLearnIsWritten).toList();
        expect(t.pieces, isNotEmpty, reason: t.bracket.id);
        for (final w in written) {
          expect(t.pieces.any((x) => identical(x.tile, w) || x.tile.title == w.title || x.readId != null),
              isTrue,
              reason: '${t.bracket.id}: ${w.title}');
        }
        final keys = [for (final x in t.pieces) x.readId ?? x.tile.title];
        expect(keys.toSet().length, keys.length, reason: '${t.bracket.id} lists a piece twice');
      }
    });

    test('Pregnancy 101 is seven real reads, each with a short answer to offer', () {
      expect(pregLearnStartHere().length, kPregLearnStartIds.length);
      expect(kPregLearnStartIds.length, 7);
      for (final id in kPregLearnStartIds) {
        expect(pregnancyReadById(id), isNotNull, reason: id);
      }
      expect(pregLearnFaqs(), isNotEmpty);
    });

    testWidgets('draws at 360dp: title, search, Explore by topic, a shelf', (tester) async {
      await pump(tester, PregLearnScreen(pregnancy: pregnancy));
      expect(tester.takeException(), isNull);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Search reads, scans and questions'), findsOneWidget);
      expect(find.text('Explore by topic'), findsOneWidget); // the serif section heading
      expect(find.byKey(const ValueKey('preg_learn_topic_pregnancy_scans_tests')), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Pregnancy 101'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Pregnancy 101'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('READS FROM THE DOOR').first, 300,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the whole page lays out at 360dp with nothing overflowing', (tester) async {
      await pump(tester, PregLearnScreen(pregnancy: pregnancy), height: 20000);
      expect(tester.takeException(), isNull);
      expect(find.text('Short answers'), findsOneWidget);
      expect(find.text('Go deeper, with someone who knows'), findsOneWidget);
    });

    testWidgets('a topic tile opens its door', (tester) async {
      await pump(tester, PregLearnScreen(pregnancy: pregnancy));
      await tester.tap(find.byKey(const ValueKey('preg_learn_topic_pregnancy_scans_tests')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(PvDoorScreen), findsOneWidget);
    });

    testWidgets('typing searches every door', (tester) async {
      await pump(tester, PregLearnScreen(pregnancy: pregnancy));
      await tester.enterText(find.byType(TextField), 'NT scan');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Ask Veda about "NT scan"'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('More', () {
    testWidgets('the TTC headings, in order, and no Community', (tester) async {
      await pump(tester, PregMoreScreen(pregnancy: pregnancy), height: 4000);
      expect(tester.takeException(), isNull);
      expect(find.text('More'), findsOneWidget);
      final keys = [
        'preg_more_experts',
        'preg_more_courses',
        'preg_more_groups',
        'preg_more_read_watch',
        'preg_more_journey',
        'preg_more_benefits',
        'preg_more_all_programmes',
      ];
      double? last;
      for (final k in keys) {
        final f = find.byKey(ValueKey(k), skipOffstage: false);
        expect(f, findsOneWidget, reason: k);
        final y = tester.getTopLeft(f).dy;
        if (last != null) expect(y, greaterThan(last), reason: k);
        last = y;
      }
      expect(find.text('Calendar', skipOffstage: false), findsOneWidget);
      expect(find.text('Community', skipOffstage: false), findsNothing);
    });
  });

  group('Tools', () {
    testWidgets('her tools only, grouped Track · Get ready · Keep, with a birth plan',
        (tester) async {
      await pump(tester, ToolsHubScreen(controller: pregnancy), height: 3000);
      expect(tester.takeException(), isNull);
      // The groups are TTC's violet caps eyebrows now (2026-10-02). Kept for
      // revert: the serif headings 'Track', 'Get ready', 'Keep', 'Ask'.
      for (final h in ['TRACK', 'GET READY', 'KEEP', 'ASK']) {
        expect(find.text(h, skipOffstage: false), findsOneWidget, reason: h);
      }
      expect(find.text('Birth plan', skipOffstage: false), findsOneWidget);
      for (final gone in ['Launches', 'Brand Studio', "Father's Journal", 'Product Guide']) {
        expect(find.text(gone, skipOffstage: false), findsNothing, reason: gone);
      }
    });

    testWidgets('"Find a tool" narrows the list', (tester) async {
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      await tester.enterText(find.byType(TextField), 'contra');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Birth plan'), findsNothing);
      expect(find.textContaining('Contraction'), findsWidgets);
    });
  });

  group('trust', () {
    test('the opening-soon courses are real programmes, with no rating or review', () {
      final byId = {for (final p in kPrepPrograms) p.id: p};
      for (final id in kPrepOpeningSoon) {
        final p = byId[id];
        expect(p, isNotNull, reason: id);
        expect(p!.rating, 0, reason: id);
        expect(p.reviews, isEmpty, reason: id);
        expect(p.about.en.toLowerCase(), isNot(contains('reviewed by obstetricians')), reason: id);
      }
    });

    testWidgets('an opening-soon card shows no price', (tester) async {
      final v = PvLearnCatalog.instance
          .all(stage: LifeStage.pregnancy)
          .firstWhere((v) => kPrepOpeningSoon.contains(v.id));
      await pump(tester, Center(child: PregCourseCard(view: v, openingSoon: true, onTap: () {})));
      expect(find.textContaining('Opening soon'), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
      expect(v.kind, PvLearnKind.course);
    });

    test("his journal starts empty: the two seed entries are commented out", () {
      final src = _code('lib/screens/father/father_daily_screen.dart');
      expect(src, isNot(contains('Felt the first kick against my palm tonight')));
      expect(src, contains('final List<_Entry> _entries = [];'));
    });
  });

  test('the three doors the user named are on the benchmark rail', () {
    for (final id in ['pregnancy_labour', 'pregnancy_mental_health', 'pregnancy_belly_skin']) {
      expect(kPvDoorRailDoors, contains(id));
    }
  });
}
