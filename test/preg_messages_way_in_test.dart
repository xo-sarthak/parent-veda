// Two small things (2026-09-30): the Messages inbox gets a second door on Today
// (an envelope top right, beside Saved), and a mother past her due date lands on
// the week 41 or 42 page instead of week 40.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/screens/v2/v3_preg_hero.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the week page past the due date', () {
    test("41 from 41 weeks, 42 from 42 weeks, and week 40's own page before that", () {
      expect(pregPastDueWeek(5), isNull);
      expect(pregPastDueWeek(0), isNull, reason: 'the due date itself is still week 40');
      expect(pregPastDueWeek(-1), isNull, reason: '"40 weeks and 1 day" is still week 40');
      expect(pregPastDueWeek(-6), isNull);
      expect(pregPastDueWeek(-7), 41);
      expect(pregPastDueWeek(-13), 41);
      expect(pregPastDueWeek(-14), 42);
      expect(pregPastDueWeek(-40), 42, reason: 'there is no page past 42; it stays on the last');
    });

    test('it moves in step with the hero count, day for day', () {
      for (var over = 1; over <= 20; over++) {
        final count = pregPastDueCount(-over)!;
        final weeks = int.parse(RegExp(r'^(\d+) weeks').firstMatch(count)!.group(1)!);
        expect(pregPastDueWeek(-over) ?? 40, weeks, reason: 'day $over past: "$count"');
      }
    });

    test('the pages it opens exist', () {
      for (final w in [41, 42]) {
        expect(pregSpecialPageFor(w), isNotNull, reason: 'week $w');
      }
      expect(pregSpecialPageFor(41)!.title, 'One week past your due date');
      expect(pregSpecialPageFor(42)!.title, 'Two weeks past your due date');
    });

    test('the home opens them, and the hero says the same week', () {
      final home = _code('lib/screens/home_v3_screen.dart');
      expect(home, contains('int _pageWeek(int week)'));
      expect(home, contains('pregPastDueWeek(_daysToDue(_today))'));
      expect(RegExp(r'openPregWeek\(context, pregnancy, _pageWeek\(week\)\)').allMatches(home).length, 3,
          reason: 'Details, the week card and the size card');
      expect(home, contains('week: _pageWeek(week),'));
    });
  });

  group('the envelope', () {
    Future<void> pump(WidgetTester t, {VoidCallback? onMessages, int unread = 0, double width = 360, double scale = 1}) async {
      t.view.physicalSize = Size(width, 900);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 900), textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: V3PregHero(
                p: V2PaletteStore.instance.current,
                week: 20,
                day: 134,
                selected: DateTime(2026, 9, 30),
                today: DateTime(2026, 9, 30),
                daysBack: 30,
                onSelectDay: (_) {},
                markFor: (_, _) => null,
                initial: 'A',
                onMessages: onMessages,
                unreadMessages: unread,
              ),
            ),
          ),
        ),
      ));
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('sits top right beside Saved, and opens the inbox', (t) async {
      var opened = 0;
      await pump(t, onMessages: () => opened++);
      final env = find.byKey(const ValueKey('preg_hero_messages'));
      expect(env, findsOneWidget);
      final saved = find.bySemanticsLabel('Saved');
      expect(t.getTopRight(env).dx, lessThan(t.getTopLeft(saved).dx + 1), reason: 'the envelope is left of Saved');
      expect(t.getTopLeft(env).dy, closeTo(t.getTopLeft(saved).dy, 1), reason: 'on the same row');
      await t.tap(env);
      expect(opened, 1);
    });

    testWidgets('an unread count is a small ink badge, capped at 9+, and none when zero', (t) async {
      await pump(t, onMessages: () {}, unread: 0);
      expect(find.byKey(const ValueKey('preg_hero_messages_count')), findsNothing);
      await pump(t, onMessages: () {}, unread: 3);
      final badge = find.byKey(const ValueKey('preg_hero_messages_count'));
      expect(badge, findsOneWidget);
      expect(find.descendant(of: badge, matching: find.text('3')), findsOneWidget);
      await pump(t, onMessages: () {}, unread: 14);
      expect(find.descendant(of: find.byKey(const ValueKey('preg_hero_messages_count')), matching: find.text('9+')),
          findsOneWidget);
    });

    testWidgets('the date stays centred with the envelope beside Saved', (t) async {
      await pump(t, onMessages: () {}, unread: 2);
      final d = DateTime(2026, 9, 30);
      final date = t.getRect(find.text('${d.day} September'));
      expect((date.center.dx - 180).abs(), lessThan(4));
    });

    testWidgets('no callback, no envelope', (t) async {
      await pump(t);
      expect(find.byKey(const ValueKey('preg_hero_messages')), findsNothing);
    });

    testWidgets('fits at 320 wide with large text', (t) async {
      await pump(t, onMessages: () {}, unread: 5, width: 320, scale: 1.3);
      expect(t.takeException(), isNull);
    });

    test('the home wires it and listens for the count', () {
      final home = _code('lib/screens/home_v3_screen.dart');
      expect(home, contains('onMessages: () => openPregMessages(context, pregnancy)'));
      expect(home, contains('unreadMessages: PregMessagesStore.instance.unreadCount'));
      expect(home, contains('PregMessagesStore.instance,'), reason: 'a message read must redraw the badge');
    });
  });
}
