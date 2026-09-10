// =============================================================================
//  The free garbh sanskar course — the rules its brief is emphatic about
// -----------------------------------------------------------------------------
//  ⚠️ THE COURSE IS THE FORMAT THE MARKET USES TO SELL THE CLAIMS WE REFUSE.
//  Every competitor named in the Mind & body position note runs a preconception
//  programme; theirs promise better odds and a child's intelligence, and ours
//  teaches the same breathing and says plainly that it does neither. That
//  difference lives entirely in strings, so most of this file scans strings.
//
//  ⚠️ AND THE OTHER HALF IS THE WIRING GATE. This course existed as a catalogue
//  card for weeks — reachable, tappable, and landing on a description of eight
//  sessions rather than on eight sessions. Every test below that pushes a screen
//  is there because "the tile opens something" was true the whole time.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_garbh_course_screen.dart';
import 'package:parentveda/screens/ttc/ttc_prepare_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/focus/ttc_focus_mind_body.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';

/// Every word the course shows, in one bag.
String _allCopy() {
  final b = StringBuffer()
    ..writeln(kTtcCourseHow)
    ..writeln(kTtcCourseFrame)
    ..writeln(kTtcCourseNever)
    ..writeln(kTtcCourseSkipNote);
  for (final s in kTtcCourseSessions) {
    b.writeln('${s.title} ${s.duration} ${s.setting} ${s.intro} '
        '${s.saidPlainly} ${s.steps.join(' ')}');
  }
  return b.toString().toLowerCase();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(TtcGarbhCourseStore.instance.resetForTest);

  // ===========================================================================
  group('the position holds, in the course\'s own copy', () {
    test('nothing claims the practice makes conception happen', () {
      // The one claim the whole category is built on. `kTtcCourseFrame` and
      // `kTtcCourseNever` DENY it, and a scanner cannot tell denial from
      // assertion — so they are excluded here and asserted on their own below.
      final banned = RegExp(
          r'improve your chances|better odds|increase.{0,20}fertility|'
          r'help you conceive|makes conception|boost.{0,20}chance');
      for (final s in kTtcCourseSessions) {
        final copy = '${s.title} ${s.intro} ${s.saidPlainly} '
                '${s.steps.join(' ')}'
            .toLowerCase();
        expect(banned.hasMatch(copy), isFalse,
            reason: 'session ${s.number} promises an outcome');
      }
    });

    test('nothing claims it shapes the baby', () {
      final banned = RegExp(
          r"baby's (intelligence|iq|brain)|smarter baby|shape.{0,20}child's "
          r'(intelligence|nature)|sanskar.{0,20}iq');
      for (final s in kTtcCourseSessions) {
        final copy = '${s.title} ${s.intro} ${s.saidPlainly} '
                '${s.steps.join(' ')}'
            .toLowerCase();
        expect(banned.hasMatch(copy), isFalse,
            reason: 'session ${s.number} makes a claim about a child');
      }
    });

    test('no session sells a detox, a cleanse, herbs or a date', () {
      // Session copy only — `kTtcCourseNever` names all four in order to refuse
      // them, which is the whole point of that string.
      final banned =
          RegExp(r'detox|cleanse|panchakarma|auspicious|muhurat|astrolog');
      for (final s in kTtcCourseSessions) {
        final copy = '${s.title} ${s.intro} ${s.saidPlainly} '
                '${s.steps.join(' ')}'
            .toLowerCase();
        expect(banned.hasMatch(copy), isFalse,
            reason: 'session ${s.number} names something we do not sell');
      }
    });

    test('the four refusals are stated, not merely implied', () {
      // ⚠️ THE INVERSE OF THE TEST ABOVE, AND IT MATTERS MORE. Leaving detox
      // out is not the same as saying we leave it out — the second is the thing
      // a reader can check us on, and the brief writes all four down.
      final never = kTtcCourseNever.toLowerCase();
      for (final word in ['detox', 'panchakarma', 'herbs', 'astrology']) {
        expect(never, contains(word),
            reason: '"$word" is no longer refused by name');
      }
      // And the clinical one: the failure mode that costs someone years.
      expect(never.toLowerCase(),
          contains('alternative to fertility treatment'));
    });

    test('the honest frame denies both claims outright', () {
      final frame = kTtcCourseFrame.toLowerCase();
      expect(frame, contains('will not make a pregnancy happen'));
      expect(frame, contains('does not shape a child'));
      expect(frame, contains('belief is optional'));
    });

    test('no price, no upsell, no lock', () {
      // "The course is free and must never show a price, an upsell, or a locked
      // session."
      final banned = RegExp(r'₹|rs\.? ?\d|upgrade|premium|unlock|locked|'
          r'subscri|only ₹|per session');
      expect(banned.hasMatch(_allCopy()), isFalse);
    });

    test('no streak, no badge, no certificate', () {
      // ⚠️ ONE STRING IS EXCLUDED, AND IT IS THE ONE THAT SAYS THERE IS NO
      // STREAK. Session 8's "said plainly" note reads *"There is no streak and
      // nothing to maintain"*, which a scanner reads as the word appearing in
      // the product. Same compromise the Mind & body myth cards need: a
      // scanner cannot tell denial from assertion, and a course that had to
      // talk around the word in order to refuse it would be a worse course.
      // ⚠️ NOT A BARE 'points'. It matched *"this session points there"* —
      // the verb, in session six, pointing at Getting ready. A scanner for
      // gamification has to name gamification, or it fails on English.
      final banned = RegExp(
          r'streak|badge|certificate|trophy|leaderboard|reward|'
          r'\d+ points|points earned|in a row|day \d+ of|\d+% complete');
      final eight =
          kTtcCourseSessions.firstWhere((s) => s.number == 8).saidPlainly;
      expect(banned.hasMatch(_allCopy().replaceAll(eight.toLowerCase(), '')),
          isFalse);

      // And the excluded string has to keep doing its job, or the exclusion
      // above quietly becomes a hole.
      expect(eight.toLowerCase(), contains('no streak'));
    });
  });

  // ===========================================================================
  group('the eight sessions', () {
    test('there are eight, numbered one to eight, with unique ids', () {
      expect(kTtcCourseSessions, hasLength(8));
      expect([for (final s in kTtcCourseSessions) s.number],
          [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(
          {for (final s in kTtcCourseSessions) s.id}.length, 8);
    });

    test('every session teaches something and says something plainly', () {
      for (final s in kTtcCourseSessions) {
        expect(s.steps, isNotEmpty, reason: '${s.id} has no steps');
        expect(s.saidPlainly.trim(), isNotEmpty,
            reason: '${s.id} has no "said plainly" note');
        expect(s.duration.trim(), isNotEmpty);
        expect(s.setting.trim(), isNotEmpty);
        expect(s.intro.trim(), isNotEmpty);
      }
    });

    test('every practice a session names is a real practice', () {
      // ⚠️ THE REUSE RULE, ENFORCED. "Reuse, do not rebuild" is only true while
      // the ids resolve; the moment one does not, the session silently teaches
      // nothing and looks identical in review.
      for (final s in kTtcCourseSessions) {
        for (final id in s.practiceIds) {
          expect(ttcPracticeById(id), isNotNull,
              reason: 'session ${s.number} names practice "$id", which the '
                  'library does not own');
        }
      }
    });

    test('the sessions that reuse the practice library actually do', () {
      // The brief maps these by name. A session that quietly stopped pointing
      // at the library would be a session that grew its own copy of a practice.
      Map<int, List<String>> want = {
        2: ['mb_longout', 'mb_nostril'],
        3: ['mb_bodyrelax'],
        4: ['mb_listen'],
        5: ['mb_loosen', 'mb_catcow'],
        7: ['mb_together'],
      };
      for (final entry in want.entries) {
        final s =
            kTtcCourseSessions.firstWhere((s) => s.number == entry.key);
        expect(s.practiceIds, entry.value,
            reason: 'session ${entry.key} no longer teaches from the library');
      }
    });

    test('only three sessions ask you to keep anything', () {
      // Five, six and eight. Everything else produces nothing but the doing of
      // it, and a fourth `TtcCourseAction` appearing here is a feature nobody
      // asked for.
      final keeping = {
        for (final s in kTtcCourseSessions)
          if (s.action != TtcCourseAction.none) s.number: s.action
      };
      expect(keeping, {
        5: TtcCourseAction.setTimes,
        6: TtcCourseAction.setMeals,
        8: TtcCourseAction.assemble,
      });
    });

    test('four sessions say better together, and none of them locks', () {
      expect([
        for (final s in kTtcCourseSessions)
          if (s.betterTogether) s.number
      ], [1, 5, 7, 8]);
    });
  });

  // ===========================================================================
  group('session eight writes into Today', () {
    test('a chosen practice replaces the rotation, and can be undone', () {
      final store = TtcGarbhCourseStore.instance;
      final day = DateTime(2026, 3, 14);
      final rotatedMove = ttcPracticeOfTheDay(TtcPracticeKind.move, on: day);

      // Before session 8: the calendar decides.
      expect(ttcTodaysMove(on: day).id, rotatedMove.id);
      expect(ttcTodayIsHerPractice, isFalse);

      // Pick something the rotation would not have given today.
      final other = ttcPracticesOfKind(TtcPracticeKind.move)
          .firstWhere((p) => p.id != rotatedMove.id);
      store.setDailyPractice(moveId: other.id, breatheId: 'mb_box');

      expect(ttcTodaysMove(on: day).id, other.id);
      expect(ttcTodaysBreathe(on: day).id, 'mb_box');
      expect(ttcTodayIsHerPractice, isTrue);

      // ⚠️ AND THE WAY BACK WORKS. Without this the only way to undo session 8
      // is to redo session 8, which is a settings screen with extra steps.
      store.clearDailyPractice();
      expect(ttcTodaysMove(on: day).id, rotatedMove.id);
      expect(ttcTodayIsHerPractice, isFalse);
    });

    test('a stored id that no longer resolves falls back, it does not blank',
        () {
      // The wiring gate again, on persisted data: a practice renamed in a
      // release must not leave somebody with an empty Today.
      TtcGarbhCourseStore.instance
          .setDailyPractice(moveId: 'mb_deleted', breatheId: 'mb_gone');
      final day = DateTime(2026, 5, 2);
      expect(ttcTodaysMove(on: day).id,
          ttcPracticeOfTheDay(TtcPracticeKind.move, on: day).id);
      expect(ttcTodaysBreathe(on: day).id,
          ttcPracticeOfTheDay(TtcPracticeKind.breathe, on: day).id);
    });

    test('a move id cannot be served as the breath card', () {
      // The two libraries are picked from separate lists on session 8, and
      // crossing them would put a ten-minute walk under "Today's breath".
      TtcGarbhCourseStore.instance.setDailyPractice(breatheId: 'mb_walk');
      final day = DateTime(2026, 5, 2);
      expect(ttcTodaysBreathe(on: day).kind, TtcPracticeKind.breathe);
    });

    test('choosing only a couple part is still a practice', () {
      TtcGarbhCourseStore.instance
          .setDailyPractice(couple: TtcCoupleDaily.gratitude);
      expect(TtcGarbhCourseStore.instance.hasPractice, isTrue);
      expect(TtcGarbhCourseStore.instance.couple, TtcCoupleDaily.gratitude);
    });
  });

  // ===========================================================================
  group('progress is "opened", and nothing more', () {
    test('opening a session records it, and there is no un-opening', () {
      final store = TtcGarbhCourseStore.instance;
      expect(store.openedCount, 0);
      store.markOpened('gs_breath');
      store.markOpened('gs_breath');
      expect(store.openedCount, 1);
      expect(store.isOpened('gs_breath'), isTrue);
      expect(store.isOpened('gs_food'), isFalse);
    });

    test('sessions can be opened in any order', () {
      // ⚠️ THE LOCK TEST. There is no ordering to break because there is no
      // ordering — asserted so that adding one becomes a failing test rather
      // than a helpful improvement.
      final store = TtcGarbhCourseStore.instance;
      store.markOpened('gs_together');
      expect(store.isOpened('gs_together'), isTrue);
      expect(store.openedCount, 1);
    });
  });

  // ===========================================================================
  group('it is reachable, and it opens the course rather than a description',
      () {
    test('the door\'s Go deeper tile opens the course itself', () {
      // ⚠️ THE BUG THIS WHOLE FILE EXISTS FOR. This tile opened `ttc_prepare` —
      // the catalogue the course is LISTED in — so a tile reading "taught
      // properly rather than described" landed on the description.
      final tile = kTtcMindBodyFocus.sections
          .expand((s) => s.tiles)
          .whereType<TtcDoTile>()
          .firstWhere((t) => t.title.contains('garbh sanskar course'));
      expect(tile.surfaceId, 'ttc_garbh_course');
      expect(ttcScreenForSurface(tile.surfaceId), isA<TtcGarbhCourseScreen>());
    });

    test('every session has its own route, and a bad one opens nothing', () {
      for (final s in kTtcCourseSessions) {
        expect(ttcScreenForSurface('ttc_garbh_course/${s.id}'),
            isA<TtcCourseSessionScreen>());
      }
      expect(ttcScreenForSurface('ttc_garbh_course/gs_nope'), isNull);
    });

    testWidgets(
        'the free offering opens the course, not a booking with a zero price',
        (tester) async {
      // Four places construct `TtcOfferingScreen`; the redirect lives inside it
      // so none of them has to remember. Pumped rather than called, because
      // what matters is what a person sees when one of those four pushes it.
      final offering = ttcOfferingById(kTtcOfferingGarbhCourse);
      expect(offering, isNotNull);
      expect(offering!.priceMinor, 0,
          reason: 'the one free thing in a priced catalogue is no longer free');

      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(home: TtcOfferingScreen(offering: offering)));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TtcGarbhCourseScreen), findsOneWidget);
      // And no price anywhere on it. `priceLabel` for a free offering is the
      // word "Free", which would pass a bare "no ₹" check while a Buy button
      // sat underneath it.
      expect(find.text('Buy'), findsNothing);
    });
  });

  // ===========================================================================
  group('it renders', () {
    Future<void> pump(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('the course home lists all eight', (tester) async {
      await pump(tester, const TtcGarbhCourseScreen());
      for (final s in kTtcCourseSessions) {
        expect(find.text(s.title), findsWidgets,
            reason: 'session ${s.number} is not on the course home');
      }
    });

    testWidgets('every session renders at phone width', (tester) async {
      for (final s in kTtcCourseSessions) {
        await pump(tester, TtcCourseSessionScreen(session: s));
        expect(find.text(s.saidPlainly), findsOneWidget,
            reason: 'session ${s.number} hides its "said plainly" note');
      }
    });

    testWidgets('opening a session marks it opened', (tester) async {
      expect(TtcGarbhCourseStore.instance.isOpened('gs_sound'), isFalse);
      await pump(tester,
          TtcCourseSessionScreen(session: ttcCourseSessionById('gs_sound')!));
      expect(TtcGarbhCourseStore.instance.isOpened('gs_sound'), isTrue);
    });
  });
}
