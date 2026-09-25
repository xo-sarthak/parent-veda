// =============================================================================
//  Garbh Sanskar door — what its brief promised, held
// -----------------------------------------------------------------------------
//  The registry-wide invariants (every section in a group, every surface
//  resolves, every section is a rail, nothing overflows at 360dp) walk
//  `kPvDoorPages`; this door inherited them on registration. What is here is
//  what only this brief asked for: a launcher that switches tabs, a rail that
//  reads a store, the honesty line that must not soften, the STOP IF list
//  whole and in her voice, and no score anywhere.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/garbh/garbh_today_practice.dart' show garbhTodayItems;
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_garbh.dart';
import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/data/read_to_baby_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/surface_router.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PvDoorPage door;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    door = pvDoorPageFor('pregnancy_garbh')!;
  });

  Future<void> pump(WidgetTester tester, {String? initialGroup}) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: PvDoorScreen(
          page: door,
          bracket: bracketById('pregnancy_garbh')!,
          pregnancy: PregnancyController(),
          initialGroup: initialGroup),
    ));
    await tester.pump();
  }

  group('the door matches the brief', () {
    test('five sub-tabs, Today first', () {
      expect(door.groups.map((g) => g.label), [
        'Today',
        'Listen',
        'Talk and read',
        'For you',
        'My Journal',
      ]);
      expect(door.groups.first.id, kGarbhTabToday);
    });

    test('Today is a launcher: its four pillars open tabs, not screens', () {
      // 2026-09-23: the four cards became the home's own component, drawn
      // inline (garbh_symmetry_test.dart holds the two equal). The targets
      // are unchanged — Listen, Talk and read, For you, For you.
      final today = door.groups.first;
      expect(today.id, kGarbhTabToday);
      expect(today.inlineSurfaceId, kGarbhSurfaceToday);
      expect(garbhTodayItems(day: 140, week: 20).map((i) => i.tab), [
        kGarbhTabListen,
        kGarbhTabRead,
        kGarbhTabForYou,
        kGarbhTabForYou,
      ]);
      // And every tab a card names exists on this door.
      final ids = door.groups.map((g) => g.id).toSet();
      for (final t in door.allTiles) {
        if (pvDoorTabTarget(t) case final target?) {
          expect(ids, contains(target), reason: '"${t.title}" names no tab.');
        }
      }
    });

    test('Today does not repeat the libraries', () {
      // No track, no affirmation, no game by name on Today — those live on
      // their own tabs. Today is the practice (the tab's tool), then two rails: her ritual, the
      // journal shortcut.
      final titles = door
          .sectionsOf(kGarbhTabToday)
          .expand((s) => s.tiles)
          .map((t) => t.title)
          .toList();
      for (final a in kShravan) {
        expect(titles, isNot(contains(a.title.en)));
      }
      for (final a in kGarbhDoorAffirmations) {
        expect(titles, isNot(contains(a)));
      }
      for (final p in kPuzzles) {
        expect(titles, isNot(contains(p.title.en)));
      }
      expect(door.sectionsOf(kGarbhTabToday).length, 2); // the practice is the tab's tool
    });

    test('the week line is a function of her week, about what is forming',
        () {
      final g = door.groups.first;
      expect(g.note, isNull);
      expect(g.noteFor, isNotNull);
      expect(g.noteFor!(6), garbhWeekReason(6).en);
      expect(g.noteFor!(24), garbhWeekReason(24).en);
      expect(g.noteFor!(6), isNot(g.noteFor!(24)));
    });

    test('Listen: today\'s pick, then every track by kind, in library order',
        () {
      final sections = door.sectionsOf(kGarbhTabListen);
      expect(sections.map((s) => s.heading), [
        "Today's pick",
        'Ragas',
        'Nature sounds',
        'Guided',
        'Where these sounds come from', // since Shravan to final
      ]);
      final onDoor = sections.skip(1).take(3).expand((s) => s.tiles).toList();
      expect(onDoor.length, kShravan.length);
      for (final t in onDoor) {
        expect(t, isA<PvDoorAudioTile>());
        expect(t.comingSoon, isFalse,
            reason: 'the player exists; "${t.title}" must open it');
      }
      expect(sections[1].tiles.map((t) => t.title), [
        'Morning Calm Raga',
        'Baby Bonding Raga',
        'Evening Raga',
        'Sleep Raga',
        'Relaxation Raga',
      ]);
    });

    test('Talk and read: the six affirmations exist and open her record screen',
        () {
      final s = door
          .sectionsOf(kGarbhTabRead)
          .firstWhere((s) => s.heading == 'Affirmations and blessings');
      expect(s.tiles.map((t) => t.title), kGarbhDoorAffirmations);
      final library = kReadAloudPieces
          .where((p) => p.category == kRtbAffirmations)
          .map((p) => p.title.en);
      for (final title in kGarbhDoorAffirmations) {
        expect(library, contains(title));
      }
      for (final t in s.tiles) {
        expect(pvDoorSurfaceResolves((t as PvDoorReadTile).surfaceId!), isTrue);
      }
    });

    test('For you: the honesty line is the note, unsoftened', () {
      final g = door.groups.firstWhere((g) => g.id == kGarbhTabForYou);
      expect(g.note,
          'This one is for you, and it will not make your baby cleverer.');
    });

    test('For you: STOP IF is pinned, whole, and opens with her line', () {
      final g = door.groups.firstWhere((g) => g.id == kGarbhTabForYou);
      final f = g.pinnedRedFlag!;
      expect(f.title, startsWith('Stop and call your doctor today if'));
      expect(f.lines.length, 6);
      expect(f.lines.map((l) => l.text), [
        'Bleeding, or fluid leaking',
        'Pain in your belly, chest or back that is new',
        'A tight, painful belly that will not settle',
        'Dizziness, a bad headache, or blurred vision',
        'Trouble breathing, or a racing heart that does not slow',
        'Your baby moving noticeably less than usual',
      ]);
      expect(f.footer, contains('Support your bump'));
      for (final other in door.groups.where((g) => g.id != kGarbhTabForYou)) {
        expect(other.pinnedRedFlag, isNull);
      }
    });

    test('the four games are games, by name', () {
      final s = door
          .sectionsOf(kGarbhTabForYou)
          .firstWhere((s) => s.heading == 'A few quiet minutes');
      expect(s.tiles.map((t) => t.title),
          ['Word Search', 'Sudoku', 'Logic Puzzle', 'Memory Match']);
      for (final t in s.tiles) {
        expect(t.format, PvDoorFormat.game);
        expect(t.format.label, 'Game');
      }
    });

    test('My Journal is the tool, with the keeps-after-birth note', () {
      final g = door.groups.firstWhere((g) => g.id == kGarbhTabJournal);
      expect(g.inlineSurfaceId, kGarbhSurfaceJournal);
      expect(door.sectionsOf(kGarbhTabJournal), isEmpty);
      expect(g.note, contains('does not disappear after the birth'));
    });

    test('the one new note is the closing line, and it claims nothing', () {
      final line = door.closingLine!;
      expect(line, startsWith('Where this comes from'));
      expect(line, contains('your voice'));
      expect(line, contains('promises nothing'));
      expect(line.toLowerCase(), isNot(contains('smarter')));
    });

    test('no streak, no score, no Ask Veda card', () {
      for (final t in door.allTiles) {
        final l = t.title.toLowerCase();
        expect(l, isNot(contains('streak')));
        expect(l, isNot(contains('score')));
        expect(l, isNot(contains('ask veda')));
      }
    });

    test('nothing on this door is coming soon', () {
      // Every screen exists; the placeholders are inside them (the pillars
      // brief's job, listed in DOOR-CONTENT-OWED §7).
      for (final t in door.allTiles) {
        expect(t.comingSoon, isFalse, reason: '"${t.title}"');
      }
    });
  });

  group('every surface the door names opens the thing it names', () {
    test('tracks, pieces, shelves, games', () {
      final c = PregnancyController();
      for (final a in kShravan) {
        expect(pvDoorScreenFor(garbhSurfaceListen(a.id), c), isNotNull);
      }
      for (final title in kGarbhDoorAffirmations) {
        expect(pvDoorScreenFor(garbhSurfacePiece(garbhSlug(title)), c),
            isNotNull);
      }
      for (var i = 0; i < 4; i++) {
        expect(pvDoorScreenFor(garbhSurfaceShelf(i), c), isNotNull);
      }
      expect(pvDoorSurfaceResolves(garbhSurfaceShelf(4)), isFalse);
      for (final p in kPuzzles) {
        expect(pvDoorScreenFor(garbhSurfaceGame(garbhSlug(p.title.en)), c),
            isNotNull);
      }
      expect(pvDoorSurfaceResolves(garbhSurfaceGame('chess')), isFalse);
      expect(pvDoorSurfaceResolves(garbhSurfaceListen('nope')), isFalse);
    });

    test('the retired landing surface opens the door', () {
      final w = screenForSurface(
          'garbh_daily', PregnancyController(), AppLanguage.english);
      expect(w, isA<PvDoorScreen>());
      expect((w as PvDoorScreen).page.bracketId, 'pregnancy_garbh');
    });
  });

  test('the journal store is loaded at startup — the phone found it was not',
      () {
    // `GarbhJournalStore.init()` existed and nothing called it, so rituals,
    // the japa count and every recording saved and never loaded. A source
    // check, because no widget test starts the app.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('GarbhJournalStore.instance.init()'));
  });

  group('on a phone', () {
    testWidgets('a Today card switches tab instead of pushing',
        (tester) async {
      await pump(tester);
      expect(find.byKey(const ValueKey('garbh_today_shravan')), findsOneWidget);
      final card = find.byKey(const ValueKey('garbh_today_shravan'));
      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tap(card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // Listen's first rail is on screen, inside the same door.
      expect(find.text("Today's pick"), findsOneWidget);
      expect(find.text('Ragas'), findsOneWidget);
      expect(find.byType(PvDoorScreen), findsOneWidget);
    });

    testWidgets('the ritual rail follows the store', (tester) async {
      await pump(tester);
      await tester.ensureVisible(find.text('Your own practice'));
      expect(find.text('Do you already have a daily practice?'),
          findsOneWidget);
      expect(find.text('Japa'), findsNothing);

      GarbhJournalStore.instance.toggleRitual('japa');
      await tester.pump();
      expect(find.text('Change what you do daily'), findsOneWidget);
      expect(find.text('Japa'), findsOneWidget);

      GarbhJournalStore.instance.toggleRitual('japa');
      await tester.pump();
      expect(find.text('Japa'), findsNothing);
    });

    testWidgets('My Journal draws in place with its two actions as cards',
        (tester) async {
      await pump(tester, initialGroup: kGarbhTabJournal);
      expect(find.text('Write a letter to your baby'), findsOneWidget);
      expect(find.text('Invite someone to record'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget); // the door's, not a nested one
      expect(tester.takeException(), isNull);
    });
  });
}
