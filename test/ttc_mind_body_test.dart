// =============================================================================
//  Mind & body — the rules the rebuild brief is emphatic about
// -----------------------------------------------------------------------------
//  ⚠️ THIS DOOR IS DIFFERENT FROM THE OTHER SIX, AND THE DIFFERENCE IS A
//  POSITION RATHER THAN A FEATURE. Its brief carries a long note on where garbh
//  sanskar sits: the market sells preconception practice on promises about a
//  baby's intelligence and about better odds, and our whole argument is that we
//  teach the same practice and refuse the promises.
//
//  A position like that is one careless sentence from being abandoned, and the
//  sentence would look helpful when somebody wrote it. So most of this file
//  scans the area's own strings rather than checking that widgets exist.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/brackets/ttc_brackets.dart';
import 'package:parentveda/data/hubs/hub_registry.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart';
import 'package:parentveda/screens/ttc/ttc_practice_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/focus/ttc_focus_mind_body.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart';

/// Every string the area shows, in one bag.
///
/// [skipDenials] drops the cards whose whole job is to STATE a claim in order
/// to refuse it — currently the "Does it make a smarter baby?" myth card. A
/// scanner cannot tell quoting from asserting, and the alternative is a myth
/// card that has to talk around the myth, which is a worse card.
String _allCopy({bool skipDenials = false}) {
  final b = StringBuffer();
  for (final p in kTtcPractices) {
    b.writeln('${p.title} ${p.blurb} ${p.setting} ${p.skipIf} '
        '${p.steps.join(' ')}');
  }
  for (final s in kTtcMindBodyFocus.sections) {
    b.writeln(s.heading);
    for (final t in s.tiles) {
      if (skipDenials && t is TtcMythTile && t.title.contains('smarter')) {
        continue;
      }
      b.writeln('${t.title} ${t.blurb}');
      if (t case TtcMythTile(:final myth, :final fact)) b.writeln('$myth $fact');
    }
  }
  b.writeln(kTtcMindBodyFocus.intro);
  b.writeln(kTtcMindBodyFocus.heroBlurb ?? '');
  b.writeln(kTtcMindBodyFocus.closingLine ?? '');
  return b.toString().toLowerCase();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final page = kTtcMindBodyFocus;

  // ===========================================================================
  group('the position holds, in the copy', () {
    test('nothing claims the practice makes conception happen', () {
      // ⚠️ THE ONE CLAIM THE ENTIRE MARKET IS BUILT ON. Every competitor named
      // in the brief sells preconception practice on better odds; the brief's
      // rule is "no claim anywhere that the practice makes conception happen".
      //
      // This scans for the SHAPE of the claim rather than a word list, because
      // the damaging version is never "this makes you pregnant" — it is
      // "improves your chances", tucked into a card blurb by somebody being
      // encouraging.
      final banned = RegExp(
        r'(improve|boost|increase|raise|better|higher)\s+'
        r'(your\s+)?(chance|chances|odds|fertility|likelihood)'
        r'|helps?\s+you\s+conceive'
        r'|(chance|chances|odds)\s+of\s+(conceiving|getting pregnant)',
      );
      final copy = _allCopy();
      expect(banned.hasMatch(copy), isFalse,
          reason: 'something in Mind & body now promises a better chance. '
              'That is the claim this area exists to refuse — see the '
              'position note in the rebuild brief.');
    });

    test('nothing claims it shapes the baby', () {
      // The second half of the same pitch, and the one iMumz leads with.
      final banned = RegExp(
        r"(baby|child|child's|baby's)[^.]{0,40}"
        r'(iq|eq|intelligen|smarter|brighter|temperament|nature)'
        r'|(smarter|brighter)\s+(baby|child)',
      );
      // ⚠️ THE MYTH CARD IS ALLOWED TO SAY IT, BECAUSE IT IS DENYING IT.
      // "Does it make a smarter baby?" has to state the claim in order to
      // answer it, which is the difference between quoting and asserting — so
      // it is the one card excluded. Everything else is scanned.
      expect(banned.hasMatch(_allCopy(skipDenials: true)), isFalse,
          reason: 'Mind & body now makes a claim about a baby outside the myth '
              'card that exists to refuse it');
    });

    test('nothing sells a detox, a cleanse, herbs or a date', () {
      // The brief's list of what we leave out because we cannot stand behind
      // it, and the line to hold if challenged.
      final banned =
          RegExp(r'detox|cleanse|panchakarma|purif|auspicious|astrolog');
      expect(banned.hasMatch(_allCopy()), isFalse);
    });

    test('the closing line is there, and it is the brief\'s own', () {
      expect(page.closingLine, isNotNull);
      expect(page.closingLine, contains('spending the wait well'));
    });
  });

  // ===========================================================================
  group('Today is a do-it screen, and cannot become a rail', () {
    test('the first tab renders a tool, not sections', () {
      final today = page.groups!.first;
      expect(today.id, 'today', reason: 'Today must be the default tab');
      expect(today.toolSurfaceId, 'ttc_mind_today');

      // ⚠️ THE STRUCTURAL HALF OF THE RULE. A group with a tool surface draws
      // that surface INSTEAD of its rails, so a section tagged 'today' would
      // render nowhere at all — silently. This asserts nobody has added one
      // believing it would show.
      final tagged = page.sections.where((s) => s.group == 'today');
      expect(tagged, isEmpty,
          reason: 'a section is tagged "today", but that tab renders a tool '
              'instead of sections — the section draws nowhere');
    });

    test('Today resolves to a body that can render inside the tab', () {
      expect(ttcInlineToolFor('ttc_mind_today'), isNotNull);
    });

    test('no streak, anywhere', () {
      // Forbidden four separate times in the brief. The data would support one
      // — the rows are date-keyed — which is exactly why this is asserted.
      final banned = RegExp(r'streak|in a row|day \d+ of|badge|points|trophy');
      expect(banned.hasMatch(_allCopy()), isFalse);
    });

    test('and no tool or tracker was added to the door', () {
      // "Do not add a tool or tracker; this area has none." The Today surface
      // is a group tool, which is a different thing from a tile promising one.
      //
      // ⚠️ ONE NAMED EXCEPTION, 2026-09-26: the "My period came" chat on Hard
      // days (TTC gap plan). It rides a Tool tile because the model has no
      // chat format, but it measures nothing and records nothing: a few
      // scripted lines of kindness and a way on. The rule is about trackers
      // and instruments, and a `ttc_chat/` surface is neither.
      for (final s in page.sections) {
        for (final t in s.tiles) {
          if (t case TtcToolTile(:final surfaceId)
              when surfaceId == 'ttc_chat/period_came') {
            continue;
          }
          expect(t, isNot(isA<TtcToolTile>()),
              reason: '"${t.title}" is a Tool tile on a door with no tools');
          expect(t, isNot(isA<TtcChecklistTile>()));
        }
      }
    });
  });

  // ===========================================================================
  group('the twelve practices exist once', () {
    test('six of each, and the ids are unique', () {
      expect(ttcPracticesOfKind(TtcPracticeKind.move), hasLength(6));
      expect(ttcPracticesOfKind(TtcPracticeKind.breathe), hasLength(6));
      final ids = kTtcPractices.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every Do tile on the door resolves to a real practice', () {
      // ⚠️ THE WIRING GATE. A `ttc_practice/<id>` naming nothing renders a
      // perfectly good card that opens nothing at all.
      for (final s in page.sections) {
        for (final t in s.tiles) {
          if (t case TtcDoTile(:final surfaceId)) {
            if (!surfaceId.startsWith('ttc_practice/')) continue;
            final id = surfaceId.substring('ttc_practice/'.length);
            expect(ttcPracticeById(id), isNotNull,
                reason: '"${t.title}" opens $surfaceId, which resolves to '
                    'nothing');
          }
        }
      }
    });

    test('the door does not name a practice title the library does not own',
        () {
      // The duplication check, stated the other way round: if somebody types a
      // thirteenth practice straight into the focus page, its title will not
      // be in the library and this fails.
      final libTitles = kTtcPractices.map((p) => p.title).toSet();
      for (final s in page.sections.where((s) => s.group == 'practice')) {
        for (final t in s.tiles) {
          if (t is! TtcDoTile) continue;
          if (!t.surfaceId.startsWith('ttc_practice/')) continue;
          expect(libTitles, contains(t.title),
              reason: '"${t.title}" is a practice card whose title is not in '
                  'ttc_practice_data.dart — it has been typed twice');
        }
      }
    });

    test('every practice has steps, a time, a place and a caution', () {
      for (final p in kTtcPractices) {
        expect(p.steps.length, greaterThanOrEqualTo(3),
            reason: '${p.id} has too few steps to follow');
        expect(p.duration.trim(), isNotEmpty);
        expect(p.setting.trim(), isNotEmpty);
        // ⚠️ NEVER EMPTY, AND SEVERAL SAY "Nothing to skip". The brief
        // writes that line rather than omitting the section, and it is right:
        // a card with no safety note reads as one nobody checked, and the
        // reader cannot tell that from a card that is genuinely safe.
        expect(p.skipIf.trim(), isNotEmpty,
            reason: '${p.id} has no "skip it if" line');
        expect(p.anim.seconds, greaterThan(0));
        expect(p.anim.seconds, lessThanOrEqualTo(600),
            reason: '${p.id} is no longer a short practice');
      }
    });

    test('the safety line is on the tab, and on no card', () {
      // ⚠️ THE BRIEF PUTS THIS IN A HEADING: "Safety line shown once on the
      // practice tab, not on every card." The first build put it on all
      // twelve, which is the reflex — and a warning repeated twelve times
      // stops being read by the third.
      final practice =
          page.groups!.firstWhere((g) => g.id == 'practice');
      expect(practice.note, kTtcPracticeSafety);

      for (final g in page.groups!) {
        if (g.id == 'practice') continue;
        expect(g.note, isNull,
            reason: '"${g.label}" also carries the practice safety line');
      }
      for (final p in kTtcPractices) {
        expect(p.skipIf, isNot(contains('Keep all of this gentle')),
            reason: '${p.id} repeats the tab-level safety line');
      }
    });

    test('every breathing card can be played today, with no artwork', () {
      // The brief's honest split: six run in code now, six need drawn figures.
      for (final p in ttcPracticesOfKind(TtcPracticeKind.breathe)) {
        expect(p.anim, isNot(isA<TtcFigureAnim>()),
            reason: '${p.id} was given a figure animation it does not need');
      }
    });

    test('the six drawn animations are listed with their briefs', () {
      // ⚠️ DERIVED, NOT MAINTAINED. The brief asks for this list in the
      // output summary; a hand-written one is wrong the first time a card
      // changes.
      final owed = ttcAnimationsOwed();
      expect(owed.length, 5,
          reason: 'the walk needs no figure, so five of the six movement '
              'cards are owed artwork');
      for (final (id, _, seconds, brief) in owed) {
        expect(brief.trim(), isNotEmpty, reason: '$id has no commissioning note');
        expect(seconds, greaterThan(0));
      }
    });

    test('box breathing is the only square, and the only one that holds', () {
      for (final p in kTtcPractices) {
        if (p.anim case TtcBreathAnim(:final square, :final hold)) {
          expect(square, p.id == 'mb_box');
          expect(hold > 0, p.id == 'mb_box',
              reason: '${p.id} holds the breath. Retention is the part of '
                  'this tradition that wants a teacher in the room');
        }
      }
    });
  });

  // ===========================================================================
  group('the rotation', () {
    test('cycles through the whole library before repeating', () {
      // The brief asks for no repeat within seven days and each library holds
      // six, which is arithmetically impossible — see `ttcPracticeOfTheDay`.
      // Six distinct days is the strongest available, and this asserts it.
      final start = DateTime(2026, 1, 1);
      for (final kind in TtcPracticeKind.values) {
        final seen = [
          for (var d = 0; d < 6; d++)
            ttcPracticeOfTheDay(kind, on: start.add(Duration(days: d))).id,
        ];
        expect(seen.toSet().length, 6,
            reason: '$kind repeated inside one six-day cycle');
      }
    });

    test('the same day always gives the same card', () {
      // It is a pure function of the date, so a reinstall does not reshuffle
      // somebody's day.
      final d = DateTime(2026, 3, 14);
      expect(ttcPracticeOfTheDay(TtcPracticeKind.move, on: d).id,
          ttcPracticeOfTheDay(TtcPracticeKind.move, on: d).id);
    });

    test('the partner is never on the same card', () {
      final start = DateTime(2026, 1, 1);
      for (var d = 0; d < 12; d++) {
        final day = start.add(Duration(days: d));
        for (final kind in TtcPracticeKind.values) {
          expect(
              ttcPracticeOfTheDay(kind, on: day).id,
              isNot(ttcPracticeOfTheDay(kind,
                      on: day, offset: kTtcPartnerOffset)
                  .id));
        }
      }
    });
  });

  // ===========================================================================
  group('reuse, promote and reference all point at something real', () {
    test('every readId on the door exists', () {
      for (final s in page.sections) {
        for (final t in s.tiles) {
          final id = switch (t) {
            TtcArticleTile(:final readId) => readId,
            TtcGuideTile(:final readId) => readId,
            _ => null,
          };
          if (id == null) continue;
          expect(ttcReadById(id), isNotNull,
              reason: '"${t.title}" opens $id, which is not a read');
        }
      }
    });

    test('every promote anchor is a heading that exists in its article', () {
      // ⚠️ THE FAILURE THIS CATCHES IS INVISIBLE. `openAtHeading` matches on
      // text; a heading that has been reworded since the tile was written does
      // not throw, it simply opens the article at the top — and the person who
      // tapped "Where stress does have a real effect" is left hunting.
      for (final s in page.sections) {
        for (final t in s.tiles) {
          final (id, at) = switch (t) {
            TtcArticleTile(:final readId, :final atHeading) => (readId, atHeading),
            TtcGuideTile(:final readId, :final atHeading) => (readId, atHeading),
            _ => (null, null),
          };
          if (id == null || at == null) continue;
          final read = ttcReadById(id)!;
          final headings = [
            for (final sec in read.sections)
              if (sec.heading != null) sec.heading!.en,
          ];
          expect(headings, contains(at),
              reason: '"${t.title}" promotes "$at" from $id, and that article '
                  'has no such heading');
        }
      }
    });

    test('every video slot exists in the catalogue', () {
      for (final s in page.sections) {
        for (final t in s.tiles) {
          if (t case TtcVideoTile(:final slotId)) {
            expect(ttcVideoBySlot(slotId), isNotNull,
                reason: '"${t.title}" names $slotId, which is not a film');
          }
        }
      }
    });

    test('the door tile opens a door that exists', () {
      final doors = [
        for (final s in page.sections)
          for (final t in s.tiles)
            if (t is TtcDoorTile) t,
      ];
      expect(doors, isNotEmpty, reason: '"His part of this" has gone');
      for (final d in doors) {
        expect(ttcFocusPageFor(d.bracketId), isNotNull,
            reason: '"${d.title}" opens ${d.bracketId}, which has no page');
      }
    });

    test('the two locked articles are reused, not retitled', () {
      // "Do not edit or re-title the two locked articles or the course."
      final titles = [
        for (final s in page.sections)
          for (final t in s.tiles) t.title,
      ];
      expect(titles, contains('Stress, and the thing everyone says about it'));
      expect(titles, contains('Preconception garbh sanskar, honestly'));
    });

    test('Getting ready still owns food, habits and tests', () {
      // ⚠️ THE RE-TEACHING CHECK. The brief forbids this area teaching food,
      // supplements, smoking, alcohol, weight or tests — it must reference
      // them. So every tile in those three sections has to carry a read that
      // another door owns, which in practice means a `ttc_read_*` id that is
      // NOT one of this area's own.
      final ours = {
        'ttc_read_stress_fertility',
        'ttc_read_garbh_sanskar',
        'ttc_read_sleep_trying',
        'ttc_read_bedtime',
        'ttc_read_family_asking',
        'ttc_read_bringing_him_in',
      };
      const referencing = [
        'Food and supplements',
        'Habits worth changing',
        'Checks worth doing',
      ];
      for (final s in page.sections.where((s) => referencing.contains(s.heading))) {
        for (final t in s.tiles) {
          if (t is TtcDoorTile) continue; // "His part of this"
          final id = switch (t) {
            TtcArticleTile(:final readId) => readId,
            TtcGuideTile(:final readId) => readId,
            _ => null,
          };
          expect(id, isNotNull,
              reason: '"${t.title}" in "${s.heading}" is not a reference to '
                  'another door — this area must not teach it');
          expect(ours, isNot(contains(id)),
              reason: '"${t.title}" points at one of our own reads, which '
                  'means Mind & body has started teaching it');
        }
      }
    });
  });

  // ===========================================================================
  group('it is reachable, and the old landing is not', () {
    test('the bracket opens the page, and the hub is unregistered', () {
      expect(ttcFocusPageFor('ttc_mind_body'), isNotNull);
      expect(hubFor('ttc_mind_body'), isNull,
          reason: 'the old two-door hub is registered again, so there are two '
              'descriptions of this area');
    });

    test('every door in the stage is now a focus page', () {
      // The seventh completes it. If a bracket is added later without a page,
      // this says so rather than letting it quietly open a hub.
      // Nine since 2026-09-26: the gap plan's Body and cycle and "Trying, but
      // not pregnant yet?" doors, both registered with a bracket.
      expect(kTtcFocusPages, hasLength(9));
      expect(kTtcFocusPages.length, kTtcBrackets.length,
          reason: 'a TTC bracket has no door, or a door has no bracket');
    });

    testWidgets('the page builds, and opens on Today', (tester) async {
      tester.view.physicalSize = const Size(1200, 14000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final bracket = bracketById('ttc_mind_body')!;
      await tester.pumpWidget(
          MaterialApp(home: TtcFocusScreen(page: page, bracket: bracket)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      for (final g in page.groups!) {
        expect(find.text(g.label), findsWidgets,
            reason: '"${g.label}" is not on the rail');
      }
      // Today is open, so its own content is on screen rather than a rail.
      expect(find.text("TODAY'S MOVEMENT"), findsOneWidget);
      expect(find.text(page.closingLine!), findsOneWidget);
    });
  });

  // ===========================================================================
  //  ⚠️ THE TAB WAS CORRECT AND LOOKED BROKEN, WHICH NO TEST HERE COULD SEE.
  //  Reported as "the user interface looks very bad starting from today's
  //  movement". Everything above passed throughout: the right practice, the
  //  right copy, no streak, the tool rendering in place of a rail. What was
  //  wrong was geometry — the focus screen insets its own children by 18 and
  //  hands a group tool through untouched, and this one did not inset itself,
  //  so every card on the default tab of this door ran edge to edge under
  //  headings that did not.
  //
  //  These are the cheapest possible guards against that returning: where the
  //  content starts, and whether anything overflows at the narrowest width we
  //  design for. Neither is a substitute for looking at it.
  group('Today is laid out like the page it sits inside', () {
    Future<void> pumpDoor(WidgetTester tester, {double width = 360}) async {
      tester.view.physicalSize = Size(width, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bracket = bracketById('ttc_mind_body')!;
      await tester.pumpWidget(
          MaterialApp(home: TtcFocusScreen(page: page, bracket: bracket)));
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('its cards sit in the page gutter, not against the edge',
        (tester) async {
      await pumpDoor(tester);
      expect(tester.takeException(), isNull);

      // The heading and the card under it have to start at the same x. That is
      // the entire bug, stated as an assertion.
      final heading =
          tester.getTopLeft(find.text("TODAY'S MOVEMENT")).dx;
      final title = tester.getTopLeft(
          find.text(ttcTodaysMove().title, skipOffstage: false));
      expect(heading, greaterThan(0),
          reason: 'the label is flush against the screen edge');
      // The card's own inner padding puts its title a little further in than
      // the heading; what must never happen is the card starting LEFT of it.
      expect(title.dx, greaterThanOrEqualTo(heading),
          reason: "today's movement card is outdented past its own heading — "
              'the tab is drawing without the page gutter again');
    });

    testWidgets('nothing overflows at 360dp', (tester) async {
      // ⚠️ 360 IS THE NARROWEST SCREEN THIS APP IS DESIGNED AGAINST, and the
      // door's own tests run at 1200 where a wide row cannot show up. Both of
      // Today's practice blocks carry a duration AND a setting on one line,
      // which is the row most likely to run out of space.
      await pumpDoor(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every practice card opens and renders at 360dp',
        (tester) async {
      // ⚠️ TWELVE SCREENS THROUGH ONE WIDGET, so an overflow on the one card
      // nobody opens is an overflow nobody sees. The body scan is the reason
      // this exists: its player is the only one that grows with its caption.
      for (final practice in kTtcPractices) {
        tester.view.physicalSize = const Size(360, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
            MaterialApp(home: TtcPracticeScreen(practice: practice)));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull,
            reason: '${practice.id} does not render at phone width');
        expect(find.text(practice.skipIf), findsOneWidget,
            reason: '${practice.id} hides its "skip it if" note');
      }
    });
  });
}
