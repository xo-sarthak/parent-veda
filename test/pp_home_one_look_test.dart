// =============================================================================
//  The parenting home in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "the whole home screen UI ... looks very inconsistent. Make sure
//  to use right marks and glyphs". Every door tile has a drawn mark; the
//  resource rail and quick strip draw the TTC family's marks; the phase film
//  is pregnancy's; nothing overflows at 360dp and 1.5x text.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_reads.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_v3.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_film.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import 'package:parentveda/screens/v2/pv_insight_rail.dart';
import 'package:parentveda/screens/v2/v3_daily_tip.dart' show kDailyTipEnabled;
import 'package:parentveda/screens/v2/v3_bracket_art.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every parenting door has a drawn mark', () {
    for (final b in bracketsFor(LifeStage.parenting)) {
      expect(bracketMarkFor(b.id), isNotNull, reason: b.id);
    }
  });

  test('the home draws TTC marks and pregnancy\'s phase film', () {
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('TtcMarkLeading(tab: m'));
    expect(home, contains('PpPhaseFilm('));
    expect(File('lib/screens/post_pregnancy/pp_home_quick.dart').readAsStringSync(), contains('TtcMarkLeading('));
  });

  for (final scale in [1.0, 1.5]) {
    testWidgets('no overflow at 360dp, ${scale}x', (t) async {
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 130)));
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.toString());
      t.view.physicalSize = const Size(360 * 3, 6000 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const MaterialApp(home: Scaffold(body: PpHomeV3()))));
      await t.pump(const Duration(milliseconds: 800));
      FlutterError.onError = old;
      expect(errors.where((e) => e.contains('overflowed')), isEmpty);
    });
  }

  // ==========================================================================
  //  2026-10-07, the user's six points on the home (brief H)
  // ==========================================================================

  /// The source of one class (or one method), from its header to [end].
  String slice(String src, String start, String end) {
    final a = src.indexOf(start);
    expect(a, greaterThanOrEqualTo(0), reason: 'missing $start');
    final b = src.indexOf(end, a + start.length);
    expect(b, greaterThan(a), reason: 'missing $end after $start');
    return src.substring(a, b);
  }

  test('every insight card opens something: a door page or the tip in the reader', () {
    for (final weeks in [0, 3, 8, 20, 40, 60, 100, 160, 250, 320]) {
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: weeks * 7 + 1)));
      final cards = ppHomeInsights();
      expect(cards, isNotEmpty, reason: '$weeks weeks');
      for (final c in cards) {
        if (c.link case final link?) {
          expect(ppScreenForSurface(link), isNotNull, reason: '${c.id} -> $link');
        } else {
          expect(ppTipAsRead(c.id, c.tip).title.en, isNotEmpty);
        }
        expect(c.value, isNotEmpty);
      }
    }
  });

  test('the full phase in the reader keeps every section the home used to unroll', () {
    for (final phase in kPhases) {
      final read = ppPhaseAsRead(phase);
      final headings = {for (final s in read.sections) if (s.heading != null) s.heading!.en};
      for (final s in phase.sections) {
        if (s.heading.toLowerCase() == 'when to call the doctor') {
          expect(read.whenToSeeSomeone.body.en, s.paragraphs.join(' '));
        } else {
          expect(headings, contains(s.heading), reason: 'phase ${phase.number}');
        }
      }
      expect(read.teaser.en, phase.summary);
      expect(read.scaleSetter.en, phase.reassurance);
    }
  });

  test('the activity marks are TTC drawn marks, one per area', () {
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    expect(home, contains('tab: ppActivityMark(area.id).\$1'));
    final marks = {
      for (final a in ['cognitive', 'language', 'gross_motor', 'fine_motor', 'emotional', 'social', 'creativity', 'selfcare'])
        ppActivityMark(a).$1
    };
    expect(marks.length, 8, reason: 'one mark per area');
    expect(marks, everyElement(isA<TtcTabMark>()));
  });

  test('the FAQ group and the ahead card carry no purple, lavender or coloured bar', () {
    final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
    final faq = slice(home, 'class _FaqRowState', '// The tinted-pill row');
    final ahead = slice(home, 'class _AheadCard extends', '// The accent-spine card');
    final group = slice(home, "key: const ValueKey('pp_home_faqs')", 'const SizedBox(height: 32)');
    for (final (name, src) in [('faq row', faq), ('ahead card', ahead), ('faq group', group)]) {
      for (final banned in ['p.action', 'surfaceAlt', 'accent', 'ppPurple', 'Positioned(', '0xFF6A30B6', 'Colors.purple', 'deepPurple']) {
        expect(src, isNot(contains(banned)), reason: '$name uses $banned');
      }
    }
  });

  testWidgets('the insight rail is on the home, and a card opens a page', (t) async {
    // The app-open tip is a dialog route of its own; off, so the only push
    // counted is the card's.
    kDailyTipEnabled = false;
    addTearDown(() => kDailyTipEnabled = true);
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 130)));
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final pushed = <Route<dynamic>>[];
    await t.pumpWidget(MaterialApp(
        navigatorObservers: [_Observer(pushed)],
        home: const Scaffold(body: PpHomeV3())));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('pp_home_insights')), findsOneWidget);
    // The age tips only: under one, the feed and sleep logs lead the rail
    // and open their trackers (2026-10-07).
    final tiles = find.byWidgetPredicate((w) =>
        w is PvInsightTile && w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('pp_insight_'));
    expect(tiles, findsWidgets);
    pushed.clear();
    await t.tap(tiles.first);
    await t.pump(const Duration(milliseconds: 600));
    expect(pushed, isNotEmpty, reason: 'the card opened nothing');
    final name = pushed.last.settings.name ?? '';
    expect(name.startsWith('pp_page/') || name.startsWith('pp/tip/'), isTrue, reason: name);
    expect(t.takeException(), isNull);
  });

  testWidgets('Read the full description opens the phase in the reader', (t) async {
    kDailyTipEnabled = false;
    addTearDown(() => kDailyTipEnabled = true);
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 130)));
    t.view.physicalSize = const Size(360 * 3, 6000 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final pushed = <Route<dynamic>>[];
    await t.pumpWidget(MaterialApp(
        navigatorObservers: [_Observer(pushed)],
        home: const Scaffold(body: PpHomeV3())));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('pp_phase_glance')), findsOneWidget);
    pushed.clear();
    await t.tap(find.byKey(const ValueKey('pp_phase_read_more')));
    await t.pump(const Duration(milliseconds: 600));
    expect(pushed.map((r) => r.settings.name), contains(startsWith('pp/phase_read/')));
    expect(find.byType(PvReaderScreen, skipOffstage: false), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}

class _Observer extends NavigatorObserver {
  _Observer(this.pushed);
  final List<Route<dynamic>> pushed;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => pushed.add(route);
}
