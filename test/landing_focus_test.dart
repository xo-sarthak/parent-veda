// =============================================================================
//  The landing focus reorders Today, and does nothing else
// -----------------------------------------------------------------------------
//  The feature is small. The constraint around it is not, and it is the reason
//  these tests exist:
//
//      "Personalisation changes content, ranking and order — never structure.
//       Everyone learns one ParentVeda."                        — CLAUDE.md
//
//  A focus that hid a tab, moved a screen or unlocked something would give
//  every parent a different app. Then no two mothers could help each other, no
//  screenshot in the community would match anybody else's, and no support
//  answer would be true twice. That is a product failure long before it is a
//  code one, and it is the kind that arrives one reasonable-looking commit at a
//  time — which is exactly what a test is for.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/app_structure.dart';
import 'package:parentveda/services/landing_focus.dart';
import 'package:parentveda/services/life_stage_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LandingFocus.instance.choose(null);
  });

  // ---------------------------------------------------------------------------
  //  1. THE CONSTRAINT
  // ---------------------------------------------------------------------------
  group('focus changes order, never structure', () {
    test('every focus leaves the five tabs and Profile exactly as they are', () {
      // Whatever the focus, the destinations are the same six. If a future
      // change makes a tab conditional, this is where it should hurt.
      final before = AppHome.values.toList();
      for (final f in TodayFocus.values) {
        LandingFocus.instance.choose(f);
        expect(AppHome.values, before,
            reason: 'focus $f changed the set of destinations');
      }
    });

    test('every surface keeps its home under every focus', () {
      final baseline = {for (final s in kAppSurfaces) s.id: s.home};
      for (final f in TodayFocus.values) {
        LandingFocus.instance.choose(f);
        for (final s in kAppSurfaces) {
          expect(homeFor(s.id), baseline[s.id],
              reason: '${s.id} moved tab under focus $f');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  //  2. THE DEFAULTS
  // ---------------------------------------------------------------------------
  group('phase defaults', () {
    test('each stage lands somewhere sensible without being asked', () {
      expect(LandingFocus.defaultFor(LifeStage.tryingToConceive),
          TodayFocus.bodyAndMind);
      expect(
          LandingFocus.defaultFor(LifeStage.pregnancy), TodayFocus.weeklyGrowth);
    });

    test('parenting splits at the named constant, on both sides', () {
      expect(
          LandingFocus.defaultFor(LifeStage.parenting,
              babyAgeMonths: kProblemToActivityMonths - 1),
          TodayFocus.problemLed);
      expect(
          LandingFocus.defaultFor(LifeStage.parenting,
              babyAgeMonths: kProblemToActivityMonths),
          TodayFocus.activityLed);
    });

    test('an unknown age reads as newborn, which is the safer wrong answer', () {
      // Showing sleep and feeding to the parent of a one-year-old is a mild
      // mismatch. Showing activities to someone who has not slept is worse.
      expect(LandingFocus.defaultFor(LifeStage.parenting),
          TodayFocus.problemLed);
    });

    test('no stage recorded still resolves, and does not throw', () {
      expect(LandingFocus.defaultFor(null), TodayFocus.weeklyGrowth);
    });
  });

  // ---------------------------------------------------------------------------
  //  3. THE OVERRIDE
  // ---------------------------------------------------------------------------
  group('her choice', () {
    test('beats the phase default', () async {
      await LandingFocus.instance.choose(TodayFocus.keepMeCalm);
      expect(LandingFocus.instance.effective(LifeStage.pregnancy),
          TodayFocus.keepMeCalm,
          reason: 'pregnancy defaults to weeklyGrowth; she said otherwise');
    });

    test('clearing returns her to the default rather than a third state', () async {
      await LandingFocus.instance.choose(TodayFocus.keepMeCalm);
      await LandingFocus.instance.choose(null);
      expect(LandingFocus.instance.override, isNull);
      expect(LandingFocus.instance.effective(LifeStage.pregnancy),
          TodayFocus.weeklyGrowth);
    });

    test('survives a restart', () async {
      await LandingFocus.instance.choose(TodayFocus.prepareForBirth);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('pv_landing_focus'), TodayFocus.prepareForBirth.id);
    });

    test('a persisted value we no longer recognise falls back, never throws', () async {
      // An uninitialised or corrupt store must behave exactly like a clean
      // install — the local-first rule. A renamed enum value in a future build
      // is the realistic way this happens.
      SharedPreferences.setMockInitialValues(
          <String, Object>{'pv_landing_focus': 'a_focus_from_2027'});
      final fresh = LandingFocus.instance;
      await fresh.choose(null);
      expect(fresh.effective(LifeStage.pregnancy), TodayFocus.weeklyGrowth);
    });
  });

  // ---------------------------------------------------------------------------
  //  4. THE OPTIONS SHE IS OFFERED
  // ---------------------------------------------------------------------------
  group('the question', () {
    test('offers a short list, and never an empty one', () {
      for (final stage in [
        null,
        LifeStage.tryingToConceive,
        LifeStage.pregnancy,
        LifeStage.parenting,
      ]) {
        final o = LandingFocus.optionsFor(stage);
        expect(o, isNotEmpty, reason: 'nothing offered for $stage');
        expect(o.length, lessThanOrEqualTo(4),
            reason: 'a list long enough to scroll turns a question into a form');
        expect(o.toSet().length, o.length, reason: 'duplicate option for $stage');
      }
    });

    test('every option is in the parent\'s words, not the product\'s', () {
      for (final f in TodayFocus.values) {
        expect(f.label.trim(), isNotEmpty);
        expect(f.blurb.trim(), isNotEmpty);
        // Feature names would make this a settings screen. If one creeps in,
        // the question has stopped being "what are you here for?".
        //
        // WHOLE WORDS. A substring check failed "Sleep and feeding" on "feed",
        // which is a parent feeding a baby, not a content feed — the same
        // mistake as grepping for a word and matching the middle of another.
        final words = f.label.toLowerCase().split(RegExp(r'[^a-z]+'));
        for (final jargon in ['module', 'card', 'tab', 'feed', 'widget']) {
          expect(words.contains(jargon), isFalse,
              reason: '"${f.label}" names the product, not the need');
        }
      }
    });

    test('the persisted id round-trips for every value', () {
      for (final f in TodayFocus.values) {
        expect(TodayFocusCopy.fromId(f.id), f);
      }
      expect(TodayFocusCopy.fromId('nonsense'), isNull);
      expect(TodayFocusCopy.fromId(null), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  //  4b. THE WIRING GATE
  // ---------------------------------------------------------------------------
  //  Both the route cards and the "also" chips shipped rendering a chevron, a
  //  destination name, and NO onTap. They looked like doors and were pictures of
  //  doors — found by tapping one on a phone, not by reading the file, because
  //  a missing GestureDetector looks exactly like a Container that never needed
  //  one.
  //
  //  This is a source scan rather than a widget test on purpose: the thing that
  //  went wrong was the absence of a handler, and the cheapest reliable way to
  //  assert a handler exists is to look for it.
  group('nothing on the focus screen is a picture of a button', () {
    final src =
        File('lib/screens/home_focus_screen.dart').readAsStringSync();
    final live = src
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');

    // ⚠️ THIS TEST WAS REWRITTEN, and the reason is worth more than the fix.
    //
    // It used to grep for one literal — `onTap: () => _open(context, surfaceId)`
    // — which was the handler on the route-card widget that existed when it was
    // written. The Focus screen later replaced those cards with the block grid,
    // every tile of which has a handler, and the test went red while the thing
    // it protects was perfectly fine.
    //
    // The lesson: a source scan that asserts a STRING breaks whenever the code
    // is refactored, and each false alarm makes the next real one easier to
    // wave through. A source scan that asserts the SHAPE — "every tile declares
    // a handler" — survives the refactor and still catches the bug it was
    // written for, which was a tile that looked like a door and was a picture.
    //
    // Both grid-led homes are scanned. V3 carries the same grid, so the same
    // failure is available to it, and a guard that only covers one of two
    // identical surfaces is half a guard.
    for (final file in const [
      'lib/screens/home_focus_screen.dart',
      'lib/screens/home_v3_screen.dart',
    ]) {
      test('every door in ${file.split('/').last} opens something', () {
        final body = File(file)
            .readAsStringSync()
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');

        // Split on the constructor and check each block's own argument list.
        // Chunk 0 is whatever precedes the first block, so it is skipped.
        final chunks = body.split('V2Block(');
        expect(chunks.length, greaterThan(1),
            reason: '$file declares no blocks — has the grid moved?');
        for (var i = 1; i < chunks.length; i++) {
          final label = RegExp(r"label:\s*'([^']*)'").firstMatch(chunks[i]);
          expect(chunks[i].contains('onTap:'), isTrue,
              reason: 'the "${label?.group(1) ?? 'block #$i'}" tile in $file '
                  'has no handler — a tile with a label and no onTap is a '
                  'picture of a door');
        }
      });
    }

    test('the also chips open something', () {
      expect(live.contains('onTap: () => _open(context, id)'), isTrue);
    });

    test('_open handles every destination, so no tap is a silent no-op', () {
      for (final h in AppHome.values) {
        expect(live.contains('AppHome.${h.name}:'), isTrue,
            reason: '${h.name} has no branch in _open — tapping it does nothing');
      }
    });
  });

  // ---------------------------------------------------------------------------
  //  5. THE STRUCTURE FILE ITSELF
  // ---------------------------------------------------------------------------
  group('app structure', () {
    test('no surface is declared twice', () {
      final ids = kAppSurfaces.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'a surface with two homes is the drift this file prevents');
    });

    test('an undeclared surface returns null rather than guessing', () {
      expect(homeFor('something_nobody_declared'), isNull);
    });

    test('every destination answers exactly one question, and owns something',
        () {
      for (final h in AppHome.values) {
        expect(h.question.trim(), isNotEmpty);
        expect(h.label.trim(), isNotEmpty);
        expect(surfacesIn(h), isNotEmpty,
            reason: '${h.label} is a destination with nothing in it');
      }
    });
  });
}
