// =============================================================================
//  Garbh Sanskar: a row under "Your practice for today" opens that practice
//  (2026-10-02).
//
//  The user: "when clicked on any one of them, instead of leaving the user hanging
//  by taking them on the Garbh Sanskar door page, considering it is the daily
//  practice, open it, like open the audio when clicked on Shravan that is meant for
//  that day. Same for all the other 3 pillars, and each screen of all 4 pillars
//  needs updated UI."
//
//  What this holds, on the real screens:
//    · each of the four rows opens ITS practice screen, not the door;
//    · the practice it opens is the one the row NAMES, including when she has
//      picked an earlier day on the home's date strip;
//    · the four screens are on the one pillar shell, draw no emoji, keep their
//      completion rule (a status and a quiet Skip, never a "mark complete"), and
//      hold at 1.5x text on a narrow phone;
//    · Kriya's "stop if" list is always open; Buddhi has no score or timer;
//      Samvad's recording controls are still there.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart' show GarbhJournalStore;
import 'package:parentveda/models/garbh_content.dart' show GarbhKind;
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart' show PvDoorScreen;
import 'package:parentveda/screens/garbh/garbh_daily_shell.dart';
import 'package:parentveda/screens/garbh/garbh_marks.dart';
import 'package:parentveda/screens/garbh/garbh_today_practice.dart';
import 'package:parentveda/screens/garbh_buddhi_screen.dart';
import 'package:parentveda/screens/garbh_samvad_daily.dart';
import 'package:parentveda/screens/garbh_screen.dart';
import 'package:parentveda/services/garbh_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

bool _isEmoji(int r) =>
    r >= 0x1F000 || r == 0xFE0F || (r >= 0x2600 && r <= 0x27BF && r != 0x2713 && r != 0x2714);

List<String> _emojiTexts(WidgetTester t) => [
      for (final w in t.widgetList<Text>(find.byType(Text, skipOffstage: false)))
        if ((w.data ?? w.textSpan?.toPlainText() ?? '').runes.any(_isEmoji))
          w.data ?? w.textSpan!.toPlainText(),
    ];

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final n = DateTime.now();
    c = PregnancyController(
        dueDate: DateTime(n.year, n.month, n.day).add(const Duration(days: 140)));
    await c.load();
    await GarbhStore.instance.init();
  });

  Future<void> pumpHome(WidgetTester t,
      {int? day, int? week, double scale = 1.0, double width = 900}) async {
    t.view.physicalSize = Size(width, 3200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
          body: SingleChildScrollView(
              child: GarbhTodayPractice(pregnancy: c, day: day, week: week))),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapRow(WidgetTester t, String id) async {
    await t.tap(find.byKey(ValueKey('garbh_today_$id')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
  }

  Future<void> leave(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 300));
  }

  group('a row opens its practice, not the door', () {
    final expected = <String, Type>{
      'shravan': ShravanScreen,
      'samvad': GarbhSamvadDailyScreen,
      'buddhi': GarbhBuddhiScreen,
      'kriya': KriyaScreen,
    };
    for (final e in expected.entries) {
      testWidgets('${e.key} opens ${e.value}', (t) async {
        await pumpHome(t);
        await tapRow(t, e.key);
        expect(find.byType(e.value), findsOneWidget);
        expect(find.byType(PvDoorScreen), findsNothing,
            reason: '${e.key} still lands on the door');
        expect(find.byType(GarbhDailyShell), findsOneWidget);
        expect(t.takeException(), isNull);
        await leave(t);
      });
    }

    test('the home row no longer calls the door-at-a-tab opener', () {
      final live = _code('lib/screens/garbh/garbh_today_practice.dart');
      expect(live, contains('garbhOpenToday(context, c, items[i]'));
      expect(live, isNot(contains('onOpen: () => garbhOpenPillar(')));
    });
  });

  group('it is the practice the row names, even for an earlier day', () {
    // Day 30 is week 5: far from today's day, so a screen that read "today"
    // would name a different raga, game or breath.
    const day = 30;
    testWidgets('shravan plays the raga the row names', (t) async {
      final item = garbhTodayItems(day: day, week: garbhWeekForDay(day))
          .firstWhere((i) => i.pillarId == 'shravan');
      await pumpHome(t, day: day, week: garbhWeekForDay(day));
      expect(find.text(item.today), findsOneWidget);
      await tapRow(t, 'shravan');
      expect(find.text(item.today), findsWidgets);
      expect(t.widget<ShravanScreen>(find.byType(ShravanScreen)).day, day);
      await leave(t);
    });

    testWidgets('kriya shows the practice the row names', (t) async {
      final item = garbhTodayItems(day: day, week: garbhWeekForDay(day))
          .firstWhere((i) => i.pillarId == 'kriya');
      await pumpHome(t, day: day, week: garbhWeekForDay(day));
      await tapRow(t, 'kriya');
      expect(find.text(item.today), findsWidgets);
      await leave(t);
    });

    testWidgets('buddhi opens the game the row names', (t) async {
      final item = garbhTodayItems(day: day, week: garbhWeekForDay(day))
          .firstWhere((i) => i.pillarId == 'buddhi');
      await pumpHome(t, day: day, week: garbhWeekForDay(day));
      await tapRow(t, 'buddhi');
      expect(find.byKey(const ValueKey('buddhi_today')), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('buddhi_today')),
              matching: find.text(item.today)),
          findsOneWidget);
      await leave(t);
    });

    testWidgets('samvad reads the piece the row names', (t) async {
      final item = garbhTodayItems(day: day, week: garbhWeekForDay(day))
          .firstWhere((i) => i.pillarId == 'samvad');
      await pumpHome(t, day: day, week: garbhWeekForDay(day));
      await tapRow(t, 'samvad');
      expect(find.text(item.today), findsWidgets);
      await leave(t);
    });

    test('a pregnancy day maps to the week the home uses', () {
      expect(garbhWeekForDay(1), 4); // held to 4..40
      expect(garbhWeekForDay(30), 5);
      expect(garbhWeekForDay(140), 20);
      expect(garbhWeekForDay(280), 40);
    });
  });

  group('the four screens', () {
    for (final id in ['shravan', 'samvad', 'buddhi', 'kriya']) {
      testWidgets('$id: pillar shell, no emoji, a drawn mark, a done status',
          (t) async {
        await pumpHome(t);
        await tapRow(t, id);
        expect(find.byType(GarbhDailyShell), findsOneWidget);
        expect(_emojiTexts(t), isEmpty);
        expect(find.byType(CustomPaint), findsWidgets);
        // The completion rule: a status (or the quiet line and Skip), never a
        // "Mark complete" button.
        expect(find.textContaining('Mark complete', skipOffstage: false), findsNothing);
        expect(
            find.byKey(ValueKey('garbh_notdone_$id'), skipOffstage: false).evaluate().isNotEmpty ||
                find.byKey(ValueKey('garbh_done_$id'), skipOffstage: false).evaluate().isNotEmpty,
            isTrue);
        expect(t.takeException(), isNull);
        await leave(t);
      });

      testWidgets('$id: Skip today marks it done, and says so', (t) async {
        await pumpHome(t);
        await tapRow(t, id);
        final skip = find.byKey(ValueKey('garbh_skip_$id'), skipOffstage: false);
        await t.ensureVisible(skip);
        await t.tap(skip);
        await t.pump(const Duration(milliseconds: 300));
        expect(GarbhStore.instance.isDone(id), isTrue);
        expect(find.byKey(ValueKey('garbh_done_$id'), skipOffstage: false), findsOneWidget);
        expect(find.text('Done for today', skipOffstage: false), findsOneWidget);
        GarbhStore.instance.undoDone(id);
        await leave(t);
      });

      testWidgets('$id: holds at 1.5x text on a narrow phone', (t) async {
        await pumpHome(t, scale: 1.5, width: 360);
        await tapRow(t, id);
        expect(t.takeException(), isNull);
        await leave(t);
      });
    }
  });

  group('what each one keeps', () {
    testWidgets('kriya: the stop-if list is open, the steps and Start are there',
        (t) async {
      await pumpHome(t);
      await tapRow(t, 'kriya');
      expect(find.byType(KriyaStopIfCard, skipOffstage: false), findsOneWidget);
      expect(find.byKey(const ValueKey('kriya_start')), findsOneWidget);
      // On the page, never folded: why this week, and the safety note.
      expect(find.text('WHY THIS WEEK', skipOffstage: false), findsOneWidget);
      expect(find.text(S(c.language).gsSafetyNotes.toUpperCase(), skipOffstage: false),
          findsOneWidget);
      await leave(t);
    });

    testWidgets('kriya: Start leaves the page for the session', (t) async {
      await pumpHome(t);
      await tapRow(t, 'kriya');
      await t.ensureVisible(find.byKey(const ValueKey('kriya_start')));
      await t.tap(find.byKey(const ValueKey('kriya_start')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('kriya_start')), findsNothing);
      await leave(t);
    });

    testWidgets('buddhi: a Play button, the other games, and no score or timer',
        (t) async {
      await pumpHome(t);
      await tapRow(t, 'buddhi');
      expect(find.byKey(const ValueKey('buddhi_play')), findsOneWidget);
      // Every game but today's is a row.
      final today = kPuzzles[c.currentDay % kPuzzles.length];
      for (final pz in kPuzzles) {
        if (pz == today) continue;
        expect(find.byKey(ValueKey('buddhi_game_${pz.title.en}'), skipOffstage: false),
            findsOneWidget, reason: pz.title.en);
      }
      expect(
          find.textContaining(RegExp(r'score|streak|points|timer|leaderboard',
              caseSensitive: false), skipOffstage: false),
          findsNothing);
      await leave(t);
    });

    testWidgets('samvad: the record disc, the passage and the narrator are there',
        (t) async {
      await pumpHome(t);
      await tapRow(t, 'samvad');
      expect(find.byKey(const ValueKey('samvad_record')), findsOneWidget);
      expect(find.byKey(const ValueKey('samvad_passage')), findsOneWidget);
      expect(find.text('Record in your voice'), findsOneWidget);
      expect(find.byKey(const ValueKey('samvad_narrator')), findsOneWidget);
      // Nothing to keep until she has recorded.
      expect(find.byKey(const ValueKey('samvad_keep')), findsNothing);
      await leave(t);
    });

    testWidgets('shravan: the big player and "why today" folded', (t) async {
      await pumpHome(t);
      await tapRow(t, 'shravan');
      expect(find.byKey(const ValueKey('raga_player_large'), skipOffstage: false),
          findsOneWidget);
      expect(find.text(S(c.language).gsWhyToday.toUpperCase(), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const ValueKey('garbh_onward_shravan'), skipOffstage: false),
          findsOneWidget);
      await leave(t);
    });
  });

  group('the stop-if list speaks to her (rebuild brief)', () {
    testWidgets('it opens with "Stop and call your doctor today if...", all six signs',
        (t) async {
      await t.pumpWidget(const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: KriyaStopIfCard()))));
      expect(find.text('Stop and call your doctor today if...'), findsOneWidget);
      expect(find.text('STOP IF'), findsNothing);
      for (final s in [
        'Bleeding, or fluid leaking',
        'Pain in your belly, chest or back that is new',
        'A tight, painful belly that will not settle',
        'Dizziness, a bad headache, or blurred vision',
        'Trouble breathing, or a racing heart that does not slow',
        'Your baby moving noticeably less than usual',
      ]) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('Stop, sit down, and call your doctor today.'), findsOneWidget);
    });

    testWidgets('the daily Kriya screen shows it with the new heading', (t) async {
      await pumpHome(t);
      await tapRow(t, 'kriya');
      expect(find.text('Stop and call your doctor today if...', skipOffstage: false),
          findsOneWidget);
      await leave(t);
    });
  });

  group('pin a raga where she listens (gap 6)', () {
    testWidgets("today's raga has the pin; pinning lists another raga under Your daily",
        (t) async {
      final store = GarbhJournalStore.instance;
      for (final id in List.of(store.pinned)) {
        store.togglePinned(id);
      }
      await pumpHome(t);
      await tapRow(t, 'shravan');
      final today = shravanForDay(c.currentDay);
      final chip = find.byKey(ValueKey('garbh_pin_shravan_${today.id}'));
      expect(chip, findsOneWidget);
      expect(find.text('Add to my daily'), findsOneWidget);
      // Nothing pinned yet: no "Your daily" list.
      expect(find.byKey(const ValueKey('shravan_your_daily'), skipOffstage: false), findsNothing);
      await t.tap(chip);
      await t.pump();
      expect(store.isPinned('shravan_${today.id}'), isTrue);
      expect(find.text('In your daily'), findsOneWidget);
      // Today's own raga is the player, so it is not listed again.
      expect(find.byKey(const ValueKey('shravan_your_daily'), skipOffstage: false), findsNothing);
      // Another pinned raga is listed, and opens its own page.
      final other = kShravan.firstWhere((a) => a.id != today.id && a.kind == GarbhKind.raga);
      store.togglePinned('shravan_${other.id}');
      await t.pump();
      final row = find.byKey(ValueKey('shravan_daily_${other.id}'), skipOffstage: false);
      expect(row, findsOneWidget);
      await t.ensureVisible(row);
      await t.tap(row);
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(ShravanDetailScreen), findsOneWidget);
      // The track's page has the pin too, already on.
      expect(find.byKey(ValueKey('garbh_pin_shravan_${other.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
      for (final id in List.of(store.pinned)) {
        store.togglePinned(id);
      }
      await leave(t);
    });

    test("the pin ids are the browse list's own (one pin, two places)", () {
      final browse = _code('lib/screens/garbh_browse_screen.dart');
      expect(browse, contains("pinId: 'shravan_\${a.id}'"));
      expect(_code('lib/screens/garbh_screen.dart'), contains("GarbhPinChip(pinId: 'shravan_\${audio.id}')"));
    });
  });

  group('the marks and the shell', () {
    testWidgets('each pillar has a drawn mark', (t) async {
      await t.pumpWidget(MaterialApp(
        home: Row(children: [
          for (final id in ['shravan', 'samvad', 'buddhi', 'kriya'])
            garbhPillarMark(id, size: 56),
          garbhPillarMark('something_else', size: 24),
        ]),
      ));
      expect(find.byType(CustomPaint), findsWidgets);
      expect(t.takeException(), isNull);
    });

    test('the old per-screen emoji heroes are no longer built by the daily screens',
        () {
      expect(_code('lib/screens/garbh_samvad_daily.dart'), isNot(contains('.emoji')));
      // Buddhi keeps the old puzzle card for revert: defined, never built.
      final buddhi = _code('lib/screens/garbh_buddhi_screen.dart');
      expect(RegExp(RegExp.escape('_PuzzleCard(')).allMatches(buddhi).length, 1,
          reason: 'the old puzzle card (with its emoji) is built again');
      expect(buddhi, contains('_TodayGame('));
      expect(_code('lib/screens/garbh_screen.dart'), contains('GarbhDailyShell('));
    });
  });
}
