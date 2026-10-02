// =============================================================================
//  The pregnancy home's fold — day strip, the week hero, My daily insights
// -----------------------------------------------------------------------------
//  docs/PREG-HOME-HERO-PLAN.md, Tier 1, built 2026-09-21. The TTC fold lifted
//  into shared widgets (PvDayStrip, PvInsightRail) and the pregnancy home
//  restructured onto them. These pin:
//
//    · the strip renders with today marked, keyed per date, and NO future
//      day (her future weeks are the reveal; a dead cell is worse than none)
//    · the hero's title says the week and the day ONCE — the subtitle no
//      longer repeats it ("Today three times" was rejected on Nutrition)
//    · the size line reads "About the size of a …" and opens the sheet
//    · the insights heading names the day the cards are computed for, and
//      moves when the strip does
//    · which cards a day earns — the pure function, on seeded stores
//    · every insight `go` is resolved (the exhaustive switch compiles)
//    · the rail runs edge to edge — not inside the page gutter
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/preg_size_sets.dart';
import 'package:parentveda/models/scan_appointment.dart';
import 'package:parentveda/screens/home_v3_screen.dart';
import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/screens/preg_week_screen.dart';
import 'package:parentveda/screens/v2/pv_day_strip.dart';
import 'package:parentveda/screens/v2/pv_insight_rail.dart';
import 'package:parentveda/screens/weekly_card_stack_screen.dart';
import 'package:parentveda/services/home_content_controller.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/preg_size_set_store.dart';
import 'package:parentveda/services/scans_store.dart';
import 'package:parentveda/services/symptom_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PregnancyController pregnancy;
  late HomeContentController home;

  /// Week 20, day 3 of it, today.
  ///
  /// ⚠️ SAVED, NOT PASSED. `load()` restores the due date from prefs and
  /// falls back to the moving week-20 placeholder when none is saved — the
  /// constructor's argument does not survive it.
  Future<void> loadControllers() async {
    final now = _dayOnly(DateTime.now());
    // day 136 = week 20, day 3 → due date is 280 - 136 = 144 days ahead
    final due = now.add(const Duration(days: 144));
    SharedPreferences.setMockInitialValues({
      PregnancyController.kDueDateKey: due.toIso8601String(),
    });
    pregnancy = PregnancyController(dueDate: due);
    await pregnancy.load();
    home = HomeContentController();
    await home.load();
  }

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Under a Scaffold, as `TodayHomeScreen` hosts it — the hero's InkWell
    // needs the Material.
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: HomeV3Screen(pregnancy: pregnancy, home: home))));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    // The daily tip arrives as a dialog on first open (one-shot per launch).
    // Wave it away, as she would, so the taps below reach the page.
    final tip = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_TipDialog');
    if (tip.evaluate().isNotEmpty) {
      await tester.tapAt(const Offset(4, 4));
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  group('the fold', () {
    setUpAll(loadControllers);

    testWidgets('the day strip is on the hero, today marked, keyed per date',
        (tester) async {
      await pumpHome(tester);
      expect(find.byType(PvDayStrip), findsOneWidget);
      final n = _dayOnly(DateTime.now());
      expect(find.byKey(ValueKey('preg_day_${n.year}-${n.month}-${n.day}')),
          findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
    });

    testWidgets('six days ahead are drawn so today sits in the centre, as TTC',
        (tester) async {
      await pumpHome(tester);
      final n = _dayOnly(DateTime.now());
      for (final d in [-1, 1, 3]) {
        final t = n.add(Duration(days: d));
        expect(find.byKey(ValueKey('preg_day_${t.year}-${t.month}-${t.day}')),
            findsOneWidget, reason: 'day $d');
      }
      final far = n.add(const Duration(days: 7));
      expect(find.byKey(ValueKey('preg_day_${far.year}-${far.month}-${far.day}')),
          findsNothing);
    });

    testWidgets('the TTC structure: avatar · date · saved, then the strip, then the baby',
        (tester) async {
      // The user, 2026-09-22: "Trying to Conceive looks 1000 times better …
      // top left, top right the profile and the calendar; the date at the
      // top; then the horizontal scroll bar."
      await pumpHome(tester);
      expect(find.textContaining('Good '), findsNothing, reason: 'no greeting');
      expect(find.text('Early days.'), findsNothing, reason: 'no milestone line wandering');
      final n = _dayOnly(DateTime.now());
      const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      final date = tester.getRect(find.text('${n.day} ${months[n.month - 1]}'));
      final strip = tester.getRect(find.byType(PvDayStrip));
      final title = tester.getRect(find.text('Week 20'));
      expect(date.top, lessThan(strip.top), reason: 'the date row is first');
      expect(strip.top, lessThan(title.top), reason: 'then the strip, then the baby and the week');
      expect(date.top, lessThan(80));
      // The date is centred between the two round buttons.
      expect((date.center.dx - 180).abs(), lessThan(4));
    });

    testWidgets('the hero says the week and the day once', (tester) async {
      await pumpHome(tester);
      expect(find.text('Week 20'), findsOneWidget);
      expect(find.text('Day 3'), findsOneWidget);
      // The subtitle used to say "Week 20, day 3. The anomaly scan window."
      // — gone with the greeting (2026-09-22).
      expect(find.textContaining('Week 20, day'), findsNothing);
      // The old chip is gone from the hero.
      expect(find.text('WEEK 20 · DAY 136'), findsNothing);
    });

    testWidgets('Details opens the week page: the figure, the week chips, the words',
        (tester) async {
      // Flo's Details (2026-09-22): no size line and no "This week" pill on
      // the hero any more — the figure and the pill open the page.
      await pumpHome(tester);
      expect(find.textContaining('About the size of'), findsNothing,
          reason: 'the hero no longer says the size; the card and the page do');
      expect(find.text('This week'), findsNothing);
      pregnancy.unlockAllWeeks = false;
      addTearDown(() => pregnancy.unlockAllWeeks = true);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byType(PregWeekScreen), findsOneWidget);
      // ⚠️ `skipOffstage: false` on this page: the pushed route's ListView
      // reports its second sliver child off-stage to the default finder even
      // though it is laid out at y≈1126 of a 2400 viewport. Geometry is
      // asserted elsewhere; here the words are what matter.
      Finder t(String s) => find.text(s, skipOffstage: false);
      expect(t('What happens in week 20'), findsOneWidget);
      expect(t('LENGTH'), findsOneWidget);
      expect(t('WEIGHT'), findsOneWidget);
      expect(t('ABOUT THE SIZE OF'), findsWidgets); // the page's tile (and the card behind)
      expect(t('20 weeks'), findsOneWidget);
      // A week ahead is dimmed and does not open; a week behind does.
      // (`unlockAllWeeks` ships true for review; the page follows `isLocked`,
      // read when the page builds — so the flag is set before Details.)
      await tester.tap(t('21 weeks'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(t('What happens in week 20'), findsOneWidget, reason: 'locked');
      await tester.tap(t('19 weeks'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(t('What happens in week 19'), findsOneWidget);
      expect(t('For you this week'), findsOneWidget);
    });

    testWidgets('the insights heading names the day, and follows the strip',
        (tester) async {
      await pumpHome(tester);
      expect(find.text('My daily insights'.toUpperCase()), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      final y = _dayOnly(DateTime.now()).subtract(const Duration(days: 1));
      await tester.tap(
          find.byKey(ValueKey('preg_day_${y.year}-${y.month}-${y.day}')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Yesterday'), findsOneWidget);
      // Yesterday was day 2 of the week.
      expect(find.text('Day 2'), findsOneWidget);
    });

    testWidgets('the rail runs edge to edge — it is not inside the gutter',
        (tester) async {
      await pumpHome(tester);
      final rail = find.byType(PvInsightRail);
      expect(rail, findsOneWidget);
      final box = tester.getRect(rail);
      expect(box.left, 0, reason: 'the rail must start at the screen edge');
      expect(box.width, 360, reason: 'and span it');
    });

    testWidgets('every card is the trying-to-conceive card: one clean colour, '
        'the value centred, no corner mark', (tester) async {
      // 2026-10-02, the user: "look at the same section in trying to conceive,
      // the design is a little different for the cards in the rail; implement
      // the same UI." TTC draws `PvInsightTile(showArt: false, centreValue:
      // true)`; the pregnancy rail did not, and a logged symptom also wore a
      // glyph in the corner. Same tile, same size, now the same settings.
      await pumpHome(tester);
      final tiles = tester
          .widgetList<PvInsightTile>(find.byType(PvInsightTile))
          .toList();
      expect(tiles, isNotEmpty);
      for (final t in tiles) {
        expect(t.showArt, isFalse, reason: '${t.eyebrow} draws a mark');
        expect(t.centreValue, isTrue, reason: '${t.eyebrow} is not centred');
        expect(t.artWidget, isNull, reason: '${t.eyebrow} wears a corner glyph');
        expect(t.large, isFalse, reason: 'the size is the TTC one, unchanged');
      }
      // The tile is the TTC size, so nothing resized to get here.
      final first = tester.getSize(find.byType(PvInsightTile).first);
      expect(first.width, PvInsightTile.width);
      expect(first.height, PvInsightTile.height);
      expect(tester.takeException(), isNull);
    });

    test('the pregnancy and TTC rails pass the same card settings', () {
      String code(String p) => File(p)
          .readAsStringSync()
          .replaceAll('\r\n', '\n')
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      final preg = code('lib/screens/home_v3_screen.dart');
      final ttc = code('lib/screens/ttc/ttc_home_v3.dart');
      for (final setting in ['showArt: false', 'centreValue: true']) {
        expect(ttc, contains(setting), reason: 'TTC lost $setting');
        expect(preg, contains(setting), reason: 'pregnancy is not like TTC: $setting');
      }
    });

    testWidgets('the learning line left the hero for the first week card',
        (tester) async {
      await pumpHome(tester);
      expect(find.byKey(const ValueKey('preg_insight_forming')), findsOneWidget);
    });

    testWidgets('nothing on the fold opens the week stack — the wire is cut',
        (tester) async {
      // The user, 2026-09-21: the pill and the photograph led to the weekly
      // card stack, "which we don't need at all … cut the wire". They open
      // the week sheet instead.
      await pumpHome(tester);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byType(PregWeekScreen), findsOneWidget);
      expect(find.byType(WeeklyCardStackScreen), findsNothing);
    });
  });

  group('which cards a day earns', () {
    setUpAll(loadControllers);

    List<PregInsight> cardsFor(DateTime date, {DateTime? today}) {
      final t = today ?? _dayOnly(DateTime.now());
      final day = pregnancy.dayForDate(date);
      final week = (((day - 1) ~/ 7) + 1).clamp(4, 40);
      return pregInsightsFor(
        date: date,
        today: t,
        day: day,
        week: week,
        homeDay: home.dayFor(day, week),
        weekContent: pregnancy.weekData(week),
        reads: const [],
      );
    }

    test('today: the invitation to log leads, then the week', () {
      final ids = cardsFor(_dayOnly(DateTime.now())).map((c) => c.id).toList();
      expect(ids.first, 'log');
      expect(ids, contains('forming'));
      expect(ids, contains('size'));
      expect(ids.where((i) => i.startsWith('eat_')), isNotEmpty);
      expect(ids.where((i) => i.startsWith('safe_')), isNotEmpty);
    });

    test('yesterday: no invitation — the companion logs against the clock',
        () {
      final y = _dayOnly(DateTime.now()).subtract(const Duration(days: 1));
      expect(cardsFor(y).map((c) => c.id), isNot(contains('log')));
    });

    test('a symptom she logged today replaces the invitation', () async {
      await SymptomStore.instance.init();
      await SymptomStore.instance.log(
          symptomId: 'nausea',
          severity: 'mild',
          addToJournal: false,
          week: 20,
          journalTitle: '');
      final ids = cardsFor(_dayOnly(DateTime.now())).map((c) => c.id).toList();
      expect(ids.first, 'symptom_nausea');
      expect(ids, isNot(contains('log')));
      final card = cardsFor(_dayOnly(DateTime.now())).first;
      expect(card.go, PregInsightGo.symptom);
      expect(card.symptomId, 'nausea');
    });

    test('a scan in the next fortnight is a card; one in a month is not',
        () async {
      await ScansStore.instance.init();
      await ScansStore.instance.clearAllForTesting();
      final t = _dayOnly(DateTime.now());
      expect(cardsFor(t).map((c) => c.id), isNot(contains('scan')));

      await ScansStore.instance.addAppointment(Appointment(
          id: 'a1',
          title: 'Anomaly scan',
          dateIso: t.add(const Duration(days: 40)).toIso8601String()));
      expect(cardsFor(t).map((c) => c.id), isNot(contains('scan')),
          reason: 'forty days out is not today\'s business');

      await ScansStore.instance.addAppointment(Appointment(
          id: 'a2',
          title: 'Growth scan',
          dateIso: t.add(const Duration(days: 3)).toIso8601String()));
      final scan = cardsFor(t).where((c) => c.id == 'scan').single;
      expect(scan.value, 'Growth scan');
      expect(scan.caption, 'In 3 days');
      await ScansStore.instance.clearAllForTesting();
    });

    test('the size card reads as a sentence; the store answers fruit while the toggle is off', () async {
      PregInsight sizeCard() => cardsFor(_dayOnly(DateTime.now()))
          .where((c) => c.id == 'size')
          .single;
      await PregSizeSetStore.instance.choose(PregSizeSet.fruit);
      expect(sizeCard().eyebrow, 'About the size of');
      expect(sizeCard().value, 'a banana', reason: 'week 20, fruit & veg');
      expect(sizeCard().caption, isNotEmpty);

      // The other sets are written and wait for their pictures.
      await PregSizeSetStore.instance.choose(PregSizeSet.kitchen);
      expect(sizeCard().value, kPregSizeToggle ? 'a tawa' : 'a banana');
      expect(pregSizeFor(20, PregSizeSet.kitchen)?.name, 'a tawa');
      expect(pregSizeFor(20, PregSizeSet.sweets)?.eyebrow, 'About as heavy as');
      await PregSizeSetStore.instance.choose(PregSizeSet.fruit);
    });

    test('every week 4–40 has all three comparisons, each with its article',
        () {
      for (var w = 4; w <= 40; w++) {
        final row = kPregSizes[w];
        expect(row, isNotNull, reason: 'week $w');
        for (final item in [row!.fruit, row.kitchen, row.sweets]) {
          expect(item.name, matches(RegExp('^(a|an|the|[a-z]+) ')),
              reason: 'week $w: "${item.name}" should read as a phrase');
          expect(item.name.trim(), item.name);
        }
        // Sweets compare by length while small, by weight once they cannot.
        expect(row.sweets.by,
            w < 14 ? PregSizeBy.length : PregSizeBy.weight,
            reason: 'week $w sweets');
        expect(row.fruit.by, PregSizeBy.length);
        expect(row.kitchen.by, PregSizeBy.length);
      }
      // No two weeks share a comparison within a set — the whole point of a
      // weekly line is that it changes.
      for (final pick in [
        (PregSizeItem i) => i.name,
      ]) {
        for (final set in PregSizeSet.values) {
          final names = [for (var w = 4; w <= 40; w++) pick(pregSizeFor(w, set)!)];
          expect(names.toSet().length, names.length,
              reason: '$set repeats a comparison');
        }
      }
    });

    test('the fallback is the week content\'s own fruit, with an article', () {
      expect(pregSizeOrFallback(3, PregSizeSet.fruit, 'peach')?.name, 'a peach');
      expect(pregSizeOrFallback(3, PregSizeSet.fruit, '')?.name, isNull);
      expect(pregSizeOrFallback(14, PregSizeSet.fruit, 'peach')?.name, 'a guava');
    });

    test('the article', () {
      expect(pregArticle('peach'), 'a peach');
      expect(pregArticle('orange'), 'an orange');
      expect(pregArticle('a lime'), 'a lime');
      expect(pregArticle(''), '');
    });

    test('the pregnancy day of a date, and back', () {
      final due = _dayOnly(DateTime.now()).add(const Duration(days: 144));
      expect(pregnancy.dayForDate(due), 280);
      expect(pregnancy.dayForDate(_dayOnly(DateTime.now())), 136);
      expect(pregnancy.dateForDay(136), _dayOnly(DateTime.now()));
      expect(pregnancy.dayForDate(due.add(const Duration(days: 30))), 280,
          reason: 'clamped');
      expect(pregnancy.dayForDate(due.subtract(const Duration(days: 400))), 1,
          reason: 'clamped');
    });
  });
}
