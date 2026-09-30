// =============================================================================
//  You — one profile, four stages (docs/PROFILE-AUDIT.md)
// -----------------------------------------------------------------------------
//  Three things this file holds, each because the repo has been bitten by its
//  absence before:
//
//    1. THE SKELETON IS FIXED. Eight sections, same order, on every stage. A
//       stage may change what is inside a section, never which sections exist
//       or where. The test reads the rendered eyebrows in order and compares
//       the four lists — so a "small" per-stage exception fails the build.
//
//    2. IT IS REACHABLE. The wiring gate (CLAUDE.md): correct-but-unreachable
//       is the failure this repo actually hits. The avatar on every home must
//       open You, and the two retired profiles must be facades over it. This
//       is asserted against the SOURCE, because a widget test that pumps the
//       screen directly proves nothing about the door.
//
//    3. THE FORWARD ACTION IS NOT A SWITCH. Each stage has at most ONE way on
//       (a positive test, a birth, another child) and skilling has none — a
//       child's chapter is not a stage she enters. The free switch lives under
//       Developer, debug-only.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_data_privacy_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/profile_screen.dart';
import 'package:parentveda/screens/ttc/ttc_profile_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The eight eyebrows, as `PvYouSection` upper-cases them, plus the Things
/// block which draws its own. Developer is debug-only and excluded on purpose:
/// it is not part of the product's skeleton.
const kSkeleton = [
  'YOUR JOURNEY',
  'FAMILY',
  'YOUR DETAILS',
  'YOUR THINGS',
  'PREFERENCES',
  'SUPPORT',
  'ACCOUNT',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
  });

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The section eyebrows in the order they were laid out, top to bottom.
  List<String> eyebrows(WidgetTester tester) {
    final found = <(double, String)>[];
    for (final e in find.byType(Text).evaluate()) {
      final t = (e.widget as Text).data;
      if (t == null || !kSkeleton.contains(t)) continue;
      found.add((tester.getTopLeft(find.byWidget(e.widget)).dy, t));
    }
    found.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final f in found) f.$2];
  }

  // ===========================================================================
  group('one skeleton', () {
    for (final stage in LifeStage.values) {
      testWidgets('${stage.name}: every section, in the one order', (
        tester,
      ) async {
        await pumpTall(tester, PvYouScreen(stage: stage));
        expect(tester.takeException(), isNull);
        // TTC's is titled Profile since 2026-09-29 (the avatar's page; the
        // fifth tab is More, test/ttc_more_profile_test.dart). Kept for
        // revert: expect(find.text('You'), findsWidgets); on every stage.
        expect(
          find.text(stage == LifeStage.tryingToConceive ? 'Profile' : 'You'),
          findsWidgets,
        );
        // ⚠️ TRYING TO CONCEIVE IS SHORT AND GROUPED (2026-09-27, the user's
        // choice after the launch walk): "Your details" folds into a "Your
        // answers" row, so that one section is absent there. Every other
        // section is where it was, in the same order.
        //
        // ⚠️ AND SINCE 2026-09-28 TRYING TO CONCEIVE IS THE MORE TAB, A BENTO
        // (test/pv_more_bento_test.dart holds it): each section is a tile
        // that opens its rows, so no eyebrow is drawn at the top level.
        // Kept for revert, the 2026-09-27 expectation:
        //   final expected = stage == LifeStage.tryingToConceive
        //       ? [for (final e in kSkeleton) if (e != 'YOUR DETAILS') e]
        //       : kSkeleton;
        //
        // ⚠️ AND SINCE 2026-09-29 TRYING TO CONCEIVE IS HER PROFILE (the
        // bento retired): Family and Your things are sections again, her
        // journey is "Your stage", her details are "Your answers", and
        // Preferences, Support and Account sit behind one Settings row.
        // Kept for revert, the 2026-09-28 expectation:
        //   final expected = stage == LifeStage.tryingToConceive
        //       ? const <String>[]
        //       : kSkeleton;
        //
        // ⚠️ AND SINCE V3 (2026-09-29, build 19): a hero leads, the chapter
        // stepper is gone, "Your journey" is a heading again (it holds "I got
        // a positive test") and Family is "Family and partner". Kept for
        // revert, the V2 expectation:
        //   ? const ['FAMILY', 'YOUR THINGS']
        final expected = stage == LifeStage.tryingToConceive
            ? const ['YOUR JOURNEY', 'YOUR THINGS']
            : kSkeleton;
        expect(
          eyebrows(tester),
          expected,
          reason:
              '${stage.name} bent the skeleton — a stage changes what is '
              'inside a section, never which sections exist or where',
        );
        // Kept for revert (2026-09-28): the bento's tiles
        //   'journey', 'family', 'things', 'experts_and_courses',
        //   'preferences', 'support', 'account' as `pv_more_tile_<id>`.
        if (stage == LifeStage.tryingToConceive) {
          // Kept for revert (V2): 'pv_profile_stage' in place of the hero
          // and the journey.
          for (final id in [
            'pv_profile_hero',
            'pv_profile_answers',
            'pv_profile_doctor',
            'pv_profile_journey',
            'pv_profile_family',
            'pv_profile_things',
          ]) {
            expect(
              find.byKey(ValueKey(id)),
              findsOneWidget,
              reason: 'the profile has no "$id" section',
            );
          }
          expect(find.byKey(kPvProfileSettingsRowKey), findsOneWidget);
        }
      });
    }

    testWidgets('a stage with no children still shows the Children row', (
      tester,
    ) async {
      // A feature is never hidden: the empty state is the invitation.
      await pumpTall(tester, const PvYouScreen(stage: LifeStage.pregnancy));
      expect(find.text('Children'), findsOneWidget);
    });

    testWidgets('the partner card is on every stage', (tester) async {
      for (final stage in LifeStage.values) {
        await pumpTall(tester, PvYouScreen(stage: stage));
        expect(
          find.textContaining('partner'),
          findsWidgets,
          reason: '${stage.name} lost the partner card',
        );
      }
    });
  });

  // ===========================================================================
  group('the one forward action', () {
    test('at most one per stage, none for skilling', () {
      expect(
        pvYouContentFor(LifeStage.tryingToConceive).action?.label,
        'I got a positive test',
      );
      expect(
        pvYouContentFor(LifeStage.pregnancy).action?.label,
        'Baby has arrived',
      );
      expect(pvYouContentFor(LifeStage.parenting).action?.label, 'Add a child');
      expect(
        pvYouContentFor(LifeStage.skilling).action,
        isNull,
        reason: 'a child\'s chapter is not a stage she enters',
      );
    });

    test('the free stage switch is not in the content table', () {
      // The switch is a Developer affordance, kDebugMode only. If it ever
      // shows up as a stage's action, someone has turned a testing aid into a
      // product decision.
      for (final s in LifeStage.values) {
        final a = pvYouContentFor(s).action;
        expect(a?.label.toLowerCase().contains('go to'), isNot(true));
        expect(a?.label.toLowerCase().contains('switch'), isNot(true));
      }
    });

    test('every stage says what it stores', () {
      for (final s in LifeStage.values) {
        expect(pvYouContentFor(s).whatWeStore, isNotEmpty);
        expect(pvYouContentFor(s).childrenInvitation, isNotEmpty);
        // ⚠️ TTC HAS ONE SINCE 2026-09-28: the journal left the stage, and
        // Orders moved under the More tab's "Bookings and orders" tile, which
        // names it. Saved stays. Kept for revert: 3 on every stage, then 2.
        // (2026-09-29: Orders is now the profile's own "Your orders" tile
        // under the hero, drawn by the screen, not a content tile, so this
        // count is unchanged. test/ttc_more_profile_test.dart holds it.)
        expect(
          pvYouContentFor(s).tiles.length,
          s == LifeStage.tryingToConceive ? 1 : 3,
          reason: 'three tiles is the row; ${s.name} has a different count',
        );
      }
    });
  });

  // ===========================================================================
  group('data and privacy', () {
    testWidgets('download is present and says Coming', (tester) async {
      // Present because a feature is never hidden; "Coming" because only a
      // server function can gather her rows into one file and it is owed
      // (STILL-OPEN §67). A row that pretends to work would be worse.
      await pumpTall(
        tester,
        const PvDataPrivacyScreen(stage: LifeStage.pregnancy),
      );
      expect(find.text('Download my data'), findsOneWidget);
      expect(find.text('Coming'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the facades', () {
    testWidgets('TtcProfileScreen opens You', (tester) async {
      await pumpTall(tester, const TtcProfileScreen());
      expect(find.byType(PvYouScreen), findsOneWidget);
    });

    test('the classic bodies are both kept', () {
      // Kept for revert, never pushed. The classes must still exist.
      expect(ProfileScreenClassic, isNotNull);
      expect(TtcProfileScreenClassic, isNotNull);
    });
  });

  // ===========================================================================
  group('reachable from every home', () {
    // The avatar on each stage's home is the one door. Asserted against the
    // source: test counts are not evidence that a screen is reachable.
    const doors = {
      'pregnancy': 'lib/screens/home_v3_screen.dart',
      'parenting': 'lib/screens/post_pregnancy/pp_home_v3.dart',
      'skilling': 'lib/screens/skilling/skilling_preview_screen.dart',
    };
    for (final e in doors.entries) {
      test('${e.key} home avatar → openPvYou', () {
        expect(
          _src(e.value),
          contains('openPvYou('),
          reason: '${e.value} no longer opens You from its avatar',
        );
      });
    }

    test('TTC home reaches You through openTtcProfile', () {
      expect(
        _src('lib/screens/ttc/ttc_home_v3.dart'),
        contains('openTtcProfile('),
      );
      expect(
        _src('lib/screens/ttc/ttc_profile_screen.dart'),
        contains('openPvYou('),
      );
    });

    test(
      'the parenting More sheet and the skilling grown-up page reach it',
      () {
        expect(
          _src('lib/screens/post_pregnancy/pp_more_sheet.dart'),
          contains('PvYouScreen('),
        );
        expect(
          _src('lib/screens/skilling/sk_grown_up_screen.dart'),
          contains('openPvYou('),
        );
      },
    );

    test('the retired profiles are facades, not second profiles', () {
      final preg = _src('lib/screens/profile_screen.dart');
      expect(preg, contains('class ProfileScreenClassic'));
      expect(
        RegExp(
          r'class ProfileScreen extends[\s\S]*?PvYouScreen\(',
        ).hasMatch(preg),
        isTrue,
        reason: 'ProfileScreen must build PvYouScreen',
      );
      final ttc = _src('lib/screens/ttc/ttc_profile_screen.dart');
      expect(ttc, contains('class TtcProfileScreenClassic'));
      // Nothing may push the kept bodies. The two defining files are skipped
      // — their constructors are the only legitimate mention.
      for (final f in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final norm = f.path.replaceAll(r'\', '/');
        if (norm.endsWith('lib/screens/profile_screen.dart') ||
            norm.endsWith('lib/screens/ttc/ttc_profile_screen.dart')) {
          continue;
        }
        final s = _src(f.path);
        expect(
          s.contains('ProfileScreenClassic('),
          isFalse,
          reason: '${f.path} pushes the retired pregnancy profile',
        );
        expect(
          s.contains('TtcProfileScreenClassic('),
          isFalse,
          reason: '${f.path} pushes the retired TTC profile',
        );
      }
    });
  });
}
