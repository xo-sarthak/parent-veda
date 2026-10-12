// His side of trying to conceive IS her home (2026-10-10, the user: "it should
// not look like a different application ... just a few things are less").
// Flo for Partners: view-only cycle, insights about her, nothing to log.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_daily_insights.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_partner_home.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_window_screen.dart' show ttcWindowForHim;
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_home_hero.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final now = DateTime.now();
  DateTime day(int ago) {
    final d = now.subtract(Duration(days: ago));
    return DateTime(d.year, d.month, d.day);
  }

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    CycleStore.instance
      ..logPeriodStart(day(68))
      ..logPeriodStart(day(40))
      ..logPeriodStart(day(12));
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(360, 5200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(key: UniqueKey(), home: const TtcHomeV3()));
    await t.pump(const Duration(milliseconds: 400));
    expect(t.takeException(), isNull);
  }

  testWidgets('his home: same header and doors, nothing to log, his block',
      (t) async {
    TtcPartnerMode.instance.on = true;
    await pump(t);
    for (final k in [
      'ttc_home_quick_period',
      'ttc_home_quick_symptoms',
      'ttc_home_quick_sex',
      'ttc_home_quick_test',
    ]) {
      expect(find.byKey(ValueKey(k)), findsNothing, reason: k);
    }
    expect(find.byKey(const ValueKey('ttc_partner_view_only')), findsOneWidget);
    expect(find.textContaining(RegExp('insights about her', caseSensitive: false)), findsOneWidget);
    expect(find.text('Your part today'), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_partner_mission')), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_partner_support')), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_partner_your_half')), findsOneWidget);
    expect(find.text('Explore by topic'), findsOneWidget,
        reason: 'the same doors as hers: one app');
  });

  testWidgets('her home is unchanged', (t) async {
    TtcPartnerMode.instance.on = false;
    await pump(t);
    expect(find.byKey(const ValueKey('ttc_home_quick_period')), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_partner_view_only')), findsNothing);
    expect(find.textContaining(RegExp('my daily insights', caseSensitive: false)), findsOneWidget);
    expect(find.text('Your part today'), findsNothing);
  });

  test('his rail keeps her cycle and what is for both, never her logs', () {
    const cards = [
      TtcInsightCard(id: 'cycle_day', eyebrow: 'DAY OF YOUR CYCLE', value: '12',
          caption: 'Counted from day 1 of your period', hue: 0,
          art: TtcInsightArt.number, go: TtcInsightGo.read),
      TtcInsightCard(id: 'symptom', eyebrow: 'YOU LOGGED', value: 'Cramps',
          hue: 0, art: TtcInsightArt.number, go: TtcInsightGo.read),
      TtcInsightCard(id: 'discharge', eyebrow: 'DISCHARGE', value: 'Egg white',
          hue: 0, art: TtcInsightArt.droplet, go: TtcInsightGo.read),
      TtcInsightCard(id: 'myth', eyebrow: "TODAY'S MYTH", value: 'A myth',
          hue: 0, art: TtcInsightArt.number, go: TtcInsightGo.read),
    ];
    final his = ttcRailForHim(cards);
    expect(his.map((c) => c.id), ['cycle_day', 'myth']);
    expect(his.first.eyebrow, 'DAY OF HER CYCLE');
    expect(his.first.caption, 'Counted from day 1 of her period');
  });

  test('the hero speaks to him, about her, and never about chances', () {
    final (lead, sub) = ttcHeroForHim(TtcHeroState.windowLastDay,
        'Your fertile days', "The last fertile day this cycle. If today doesn't suit you...");
    expect(lead, 'Her fertile days');
    expect(sub, contains('her fertile days'));
    for (final s in TtcHeroState.values) {
      final (l, b) = ttcHeroForHim(s, 'Your period may start', '');
      expect('$l $b'.toLowerCase(), isNot(contains('chance')), reason: s.name);
    }
  });

  test('his tools: the same bar as hers, and her window never offers him her log', () {
    final host = File('lib/screens/ttc/ttc_tab_host.dart').readAsStringSync();
    expect(host, contains('slate: false,'));
    final win = File('lib/screens/ttc/ttc_window_screen.dart').readAsStringSync();
    expect(win, contains("title: 'Her fertile days appear when she logs her period'"));
    TtcPartnerMode.instance.on = true;
    expect(ttcWindowForHim("Your best day is 4 Oct, the day you're likely to release an egg"),
        "Her best day is 4 Oct, the day she's likely to release an egg");
    TtcPartnerMode.instance.on = false;
    expect(ttcWindowForHim('Your fertile days'), 'Your fertile days');
  });

  test('the window screen speaks about her on his side, every line', () {
    TtcPartnerMode.instance.on = true;
    expect(ttcWindowForHim('Why six days: sperm can live inside you for about five days'),
        'Why six days: sperm can live inside her for about five days');
    expect(ttcWindowForHim('The dot is ovulation. The dashes show where you are today.'),
        'The dot is ovulation. The dashes show where she is today.');
    expect(ttcWindowForHim('THE 28 DAYS OF YOUR CYCLE'), 'THE 28 DAYS OF HER CYCLE');
    expect(ttcWindowForHim('Today is day 9 of your cycle'), 'Today is day 9 of her cycle');
    // Every string a user sees on the screen, other than her-only empty
    // states, goes through the rewrite (source check, 2026-10-12).
    final src = File('lib/screens/ttc/ttc_window_screen.dart').readAsStringSync();
    for (final line in [
      'Why six days: sperm can live inside you',
      "Ovulation: the day you're likely to release an egg",
      'One whole cycle, from the first day of your period',
      'About six days, ending on the day you ovulate. Sperm survive',
    ]) {
      final at = src.indexOf(line);
      expect(at, greaterThan(0), reason: line);
      expect(src.substring(at - 80, at).contains('ttcWindowForHim('), isTrue, reason: line);
    }
  });
}
