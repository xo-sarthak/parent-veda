// =============================================================================
//  The baby movement tracker, redrawn around one control (2026-10-02).
//
//  The user, after the contraction timer: "do the same for the baby movement
//  tracker: the Mobbin pass, the UI, UX and usability. And the two articles at
//  the bottom should be small squares with thumbnails, the way it is at the end
//  of each article."
//
//  What this holds, on the real screen:
//    · the heart is the control: idle it starts a session, in one it carries
//      the count, and a tap logs a movement;
//    · there is NO target anywhere (the tool is awareness, not counting);
//    · the chips of times became a timeline, and the times are one tap away;
//    · the note folds, and still saves to Dear Baby;
//    · the line she must not miss ("fewer, weaker or different: call the same
//      day") is always on the idle page, with its paragraph folded;
//    · the two reads are the reader's own rail, tile for tile, and open the
//      reader; they are not drawn during a session;
//    · history shows each session as a line, with its times folded.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/reader/pv_read_tile.dart' show PvReadNextRail, PvReadTile;
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/tools/baby_movement_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/tools_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

const _reads = ['${kPregWeekReadPrefix}movement_awareness', 'preg_cond_read_less_movement'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;
  late S s;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 80)));
    await c.load();
    await ToolsStore.instance.init();
    await ToolsStore.instance.endMovementSession();
    s = S(c.language);
  });

  Future<void> pump(WidgetTester t, {double scale = 1.0, double width = 900}) async {
    t.view.physicalSize = Size(width, 2800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: BabyMovementScreen(controller: c),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  /// Dispose the screen so its timer does not outlive the test.
  Future<void> done(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump();
  }

  group('idle', () {
    testWidgets('one disc starts a session; no filled button is left', (t) async {
      await pump(t);
      expect(find.byKey(const ValueKey('bm_disc_idle')), findsOneWidget);
      expect(find.text(s.startSession), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('the line she must not miss is on the page; its paragraph is folded',
        (t) async {
      await pump(t);
      const line = 'Fewer, weaker or different movements? Call the same day';
      expect(find.text(line), findsOneWidget);
      const para = 'You do not need to count unless your doctor asks you to.';
      expect(find.textContaining(para), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('bm_fold_toggle_pattern')));
      await t.tap(find.byKey(const ValueKey('bm_fold_toggle_pattern')));
      await t.pumpAndSettle();
      expect(find.textContaining(para), findsOneWidget);
      // The doctor-first disclaimer never moved.
      expect(find.text(s.movementDisclaimer), findsOneWidget);
      await done(t);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      await pump(t, scale: 1.5, width: 360);
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('the two reads are the reader\'s own rail', () {
    testWidgets('small tiles, one per read, with their pictures slot, below', (t) async {
      await pump(t);
      final rail = find.byKey(const ValueKey('movement_read_next'), skipOffstage: false);
      expect(rail, findsOneWidget);
      expect(t.widget(rail), isA<PvReadNextRail>());
      expect(find.text('Read next', skipOffstage: false), findsOneWidget);
      expect(find.byType(PvReadTile, skipOffstage: false), findsNWidgets(2));
      // Each of the two reads is there by its own title.
      for (final id in _reads) {
        expect(find.text(pregnancyReadById(id)!.title.en, skipOffstage: false),
            findsOneWidget, reason: id);
      }
      // The old rows, a heading and a card of text rows, are gone.
      expect(find.text("Knowing your baby's pattern"), findsNothing);
      expect(find.byKey(const ValueKey('movement_read_awareness')), findsNothing);
      await done(t);
    });

    testWidgets('a tile opens the reader on that read', (t) async {
      await pump(t);
      final first = find.byType(PvReadTile, skipOffstage: false).first;
      await t.ensureVisible(first);
      await t.tap(first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(PvReaderScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('during a session the rail is not drawn, so the heart stays up',
        (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('movement_read_next'), skipOffstage: false),
          findsNothing);
      await done(t);
    });
  });

  group('a session', () {
    testWidgets('start: the heart carries the count, and invites the first tap',
        (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('bm_disc_active')), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byKey(const ValueKey('bm_empty')), findsOneWidget);
      // Nothing to read yet: no strip, no list.
      expect(find.byKey(const ValueKey('bm_strip')), findsNothing);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('a tap logs a movement: the count, the timeline, the times', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 3; i++) {
        await t.tap(find.byKey(const ValueKey('bm_disc_active')));
        await t.pump(const Duration(milliseconds: 1400));
      }
      expect(ToolsStore.instance.currentSessionCount, 3);
      expect(t.widget<Text>(find.byKey(const ValueKey('bm_count'))).data, '3');
      expect(find.byKey(const ValueKey('bm_strip')), findsOneWidget);
      expect(find.byKey(const ValueKey('bm_empty')), findsNothing);
      // The times are folded, with their count, one tap away.
      expect(find.byKey(const ValueKey('bm_fold_times')), findsOneWidget);
      await t.ensureVisible(find.byKey(const ValueKey('bm_fold_toggle_times')));
      await t.tap(find.byKey(const ValueKey('bm_fold_toggle_times')));
      await t.pumpAndSettle();
      expect(find.text(s.lastMovementAt(s.formatClock(
              ToolsStore.instance.currentSessionMovements.last))),
          findsNothing, reason: 'the chips carry the clock, not a sentence');
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('no target: nothing says how many she should feel', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 11; i++) {
        await t.tap(find.byKey(const ValueKey('bm_disc_active')));
        await t.pump(const Duration(milliseconds: 50));
      }
      await t.pump(const Duration(milliseconds: 1500));
      // (The disclaimer's own "perfectly normal" is the existing doctor-first
      // note, not a count; everything else on the page is checked.)
      expect(find.textContaining(RegExp(r'\b(goal|target|of 10|10 movements|enough)\b',
              caseSensitive: false)), findsNothing);
      await done(t);
    });

    testWidgets('the note is folded, opens, and still saves to Dear Baby', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('bm_note_field')), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('bm_fold_toggle_note')));
      await t.tap(find.byKey(const ValueKey('bm_fold_toggle_note')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('bm_note_field')), findsOneWidget);
      await t.enterText(find.byKey(const ValueKey('bm_note_field')), 'She kicked at the song');
      await t.ensureVisible(find.text(s.talkSaveCta));
      await t.tap(find.text(s.talkSaveCta));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text(s.movementNoteSaved), findsOneWidget);
      await done(t);
    });

    testWidgets('ending saves the session and goes back to the idle disc', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.byKey(const ValueKey('bm_disc_active')));
      await t.pump(const Duration(milliseconds: 1400));
      await t.ensureVisible(find.byKey(const ValueKey('bm_end')));
      await t.tap(find.byKey(const ValueKey('bm_end')));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('bm_disc_idle')), findsOneWidget);
      expect(ToolsStore.instance.movementSessionHistory, isNotEmpty);
      expect(find.text(s.sessionSavedMsg), findsOneWidget);
      await done(t);
    });

    testWidgets('holds at 1.5x text, in a session, on a narrow phone', (t) async {
      await pump(t, scale: 1.5, width: 360);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 4; i++) {
        await t.tap(find.byKey(const ValueKey('bm_disc_active')));
        await t.pump(const Duration(milliseconds: 100));
      }
      await t.pump(const Duration(milliseconds: 1500));
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('history', () {
    testWidgets('a session is a line, with its times folded', (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('bm_disc_idle')));
      await t.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 2; i++) {
        await t.tap(find.byKey(const ValueKey('bm_disc_active')));
        await t.pump(const Duration(milliseconds: 1400));
      }
      await t.ensureVisible(find.byKey(const ValueKey('bm_end')));
      await t.tap(find.byKey(const ValueKey('bm_end')));
      await t.pump(const Duration(milliseconds: 300));
      await t.ensureVisible(find.byKey(const ValueKey('movement_records_row')));
      await t.tap(find.byKey(const ValueKey('movement_records_row')));
      await t.pumpAndSettle();
      final rec = ToolsStore.instance.movementSessionHistory.first;
      expect(find.byKey(ValueKey('bm_hist_${rec.id}')), findsOneWidget);
      expect(find.text(s.movementsLoggedCount(2)), findsOneWidget);
      // The strip's own labels carry the clock, so count inside this card:
      // opening the fold adds one pill per time.
      Finder clocks() => find.descendant(
          of: find.byKey(ValueKey('bm_hist_${rec.id}')),
          matching: find.text(s.formatClock(rec.times.first)));
      final before = clocks().evaluate().length;
      await t.tap(find.byKey(ValueKey('bm_hist_toggle_${rec.id}')));
      await t.pumpAndSettle();
      expect(clocks().evaluate().length, greaterThan(before),
          reason: 'the times were not folded');
      expect(t.takeException(), isNull);
    });
  });

  group('wiring', () {
    test('the live build uses the disc, the strip and the shared rail; the old '
        'build is kept but not built', () {
      final live = _code('lib/screens/tools/baby_movement_screen.dart');
      expect(live, contains('_MovementDisc('));
      expect(live, contains('_MovementStrip('));
      expect(live, contains('pregToolReadNext('));
      expect(live, contains('PregFoldRow('));
      expect(live, contains('..._liveViews(context)'));
      expect(live, contains('..._idleViews(context)'));
      // The old pieces are referenced only from `_buildClassic` (a definition
      // and that one call), and `_buildClassic` itself is never called.
      for (final old in ['_startViews(', '_activeViews(', '_tapCircle(', '_memoryCard(']) {
        expect(RegExp(RegExp.escape(old)).allMatches(live).length, 2,
            reason: '$old is built again');
      }
      expect(RegExp(RegExp.escape('_buildClassic(')).allMatches(live).length, 1,
          reason: 'the classic build is called again');
    });

    test('both tools use the one shared fold and the shared rail names real reads', () {
      expect(_code('lib/screens/tools/contraction_tracker_screen.dart'),
          contains('extends PregFoldRow'));
      for (final id in _reads) {
        expect(pregnancyReadById(id), isNotNull, reason: id);
      }
    });
  });
}
