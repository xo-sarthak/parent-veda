// One header order on every home (2026-10-31).
//
//   LEFT   profile avatar, Messages
//   CENTRE the date
//   RIGHT  Search, Calendar
//
// Trying to Conceive, Pregnancy and Parenting each draw their own header (three
// stages, deliberately isolated), so the order cannot be one widget. It is held
// here instead, at the source, because three hand-drawn rows drift: the TTC row
// had Messages on the right and a Talk button on the left, Pregnancy had Talk
// and Messages on opposite sides, and Parenting a third arrangement.
//
// "Talk to an expert" left all three headers and is the first row of You (held
// in preg_his_side_test.dart). Skilling's header is not part of this and keeps
// its own order.
//
// ⚠️ WIRING GATE (CLAUDE.md): a Search button that draws and goes nowhere is the
// failure this repo has actually hit, so each Search's onTap is followed from
// the home call site to the screen its opener pushes.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_search_screen.dart';

/// A source file with its whole-line comments removed, so code kept for revert
/// in a comment is never mistaken for what is drawn.
String _live(String path) => File(
  path,
).readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n');

/// The text of [src] from `start` up to (not including) the next [end].
String _between(String src, String start, String end) {
  final a = src.indexOf(start);
  expect(a, greaterThanOrEqualTo(0), reason: 'missing $start');
  final b = src.indexOf(end, a + start.length);
  return src.substring(a, b < 0 ? src.length : b);
}

void _inOrder(String region, List<String> markers, String stage) {
  var at = -1;
  for (final m in markers) {
    final i = region.indexOf(m);
    expect(
      i,
      greaterThanOrEqualTo(0),
      reason: '$stage: $m is not drawn in the header',
    );
    expect(
      i,
      greaterThan(at),
      reason:
          '$stage: $m is out of order (avatar < messages < date < search < calendar)',
    );
    at = i;
  }
}

void main() {
  group('the header order, source level', () {
    test(
      'Trying to Conceive: avatar < messages < date < search < calendar',
      () {
        final src = _live('lib/screens/ttc/ttc_home_v3.dart');
        final header = _between(src, 'class _CycleHeader extends', '\nclass ');
        _inOrder(header, [
          'onTap: onProfile',
          'TtcMessagesButton(',
          'PvFamilyTitle(',
          "ValueKey('ttc_home_search')",
          'onTap: onCalendar',
        ], 'ttc');
        expect(
          header,
          isNot(contains('onTalk')),
          reason: 'Talk to an expert left the header',
        );
      },
    );

    test('Pregnancy: avatar < messages < date < search < calendar', () {
      final src = _live('lib/screens/v2/v3_preg_hero.dart');
      final hero = _between(src, 'class _V3PregHeroState', '\nclass ');
      _inOrder(hero, [
        "semantic: 'You'",
        "ValueKey('preg_hero_messages')",
        'PvFamilyTitle(',
        "ValueKey('preg_hero_search')",
        "semantic: 'Calendar'",
      ], 'pregnancy');
      expect(hero, isNot(contains('onTalk')));
      // His side has no calendar: Saved takes its corner, still after Search.
      expect(
        hero.indexOf("ValueKey('preg_hero_search')"),
        lessThan(hero.indexOf("semantic: 'Saved'")),
      );
    });

    test('Parenting: avatar < messages < date < search < calendar', () {
      final src = _live('lib/screens/post_pregnancy/pp_home_v3.dart');
      final hero = _between(src, 'class _PaintedHero extends', '\nclass ');
      _inOrder(hero, [
        "semantic: 'Profile'",
        "ValueKey('pp_hero_messages')",
        'PvFamilyTitle(',
        "ValueKey('pp_hero_search')",
        "ValueKey('pp_hero_calendar')",
      ], 'parenting');
      expect(hero, isNot(contains('onTalk')));
    });

    test('Skilling keeps its own header, Talk included', () {
      final code = File(
        'lib/screens/skilling/skilling_preview_screen.dart',
      ).readAsStringSync();
      expect(code, contains("semantic: 'Talk to an expert'"));
    });
  });

  group(
    'wiring gate: each Search reaches its opener, and the opener pushes a screen',
    () {
      test('Trying to Conceive', () {
        final home = _live('lib/screens/ttc/ttc_home_v3.dart');
        expect(
          home,
          contains('onSearch: () => openTtcSearch(context, him: him)'),
        );
        // The header's button calls what the home handed it.
        expect(
          _between(home, "ValueKey('ttc_home_search')", ')'),
          contains('onTap: onSearch'),
        );
        final screen = _live('lib/screens/ttc/ttc_search_screen.dart');
        expect(screen, contains('builder: (_) => TtcSearchScreen('));
        expect(screen, contains("name: kTtcSearchRoute"));
        expect(kTtcSearchRoute, 'ttc/search');
        expect(
          screen,
          contains('ttcStageSearch('),
          reason: 'results come from the stage search',
        );
        expect(
          screen,
          contains('openTtcAskVeda(context, initialQuery: q'),
          reason: 'the no-result way on',
        );
      });

      test('Pregnancy', () {
        final home = _live('lib/screens/home_v3_screen.dart');
        expect(
          home,
          contains('onSearch: () => openPvSearch(context, pregnancy)'),
        );
        expect(
          _live('lib/screens/v2/v3_preg_hero.dart'),
          contains('onTap: widget.onSearch!'),
        );
        final search = _live('lib/screens/search/pv_search_screen.dart');
        expect(search, contains('void openPvSearch('));
        expect(search, contains('builder: (_) => PvSearchScreen('));
      });

      test('Parenting', () {
        final home = _live('lib/screens/post_pregnancy/pp_home_v3.dart');
        expect(home, contains('onSearch: () => openPpSearch(context)'));
        expect(
          _between(home, "ValueKey('pp_hero_search')", ')'),
          contains('onTap: onSearch'),
        );
        final search = _live('lib/screens/post_pregnancy/pp_search.dart');
        expect(search, contains('void openPpSearch('));
        expect(search, contains('builder: (_) => PpSearchScreen('));
      });
    },
  );

  group('TtcSearchScreen', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> pump(WidgetTester t, {String? query}) async {
      t.view.physicalSize = const Size(360, 900);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: TtcSearchScreen(query: query)));
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('an empty box offers places to start', (t) async {
      await pump(t);
      expect(find.text('Places to start'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('ttc_search_start_ovulation')),
        findsOneWidget,
      );
    });

    testWidgets(
      'a known word finds hits, each with the Ask Veda way on below',
      (t) async {
        await pump(t, query: 'ovulation');
        expect(find.byKey(ttcSearchHitKey(0)), findsOneWidget);
        expect(
          find.text('Ask Veda about "ovulation"', skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets('a nonsense word says so calmly and still offers Ask Veda', (
      t,
    ) async {
      await pump(t, query: 'zzqxv');
      expect(find.text('Nothing by that name yet'), findsOneWidget);
      expect(find.byKey(ttcSearchHitKey(0)), findsNothing);
      expect(
        find.text('Ask Veda about "zzqxv"', skipOffstage: false),
        findsOneWidget,
      );
    });
  });
}
