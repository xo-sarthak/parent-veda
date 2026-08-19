// =============================================================================
//  Complications & conditions — the promises the section makes about HER
// -----------------------------------------------------------------------------
//  ⚠️ THE DEFECT THESE EXIST FOR: "Add to my journey" wrote into a
//  `Set<String>` inside `ConditionsStore` that nothing anywhere read. Its only
//  two consumers were the label and the icon of the button that had just been
//  tapped, so the entire observable effect of asking the app to personalise
//  around a diagnosis was that a button said "Added to your journey".
//
//  That is worse than a missing feature, because it looks finished from every
//  angle available to a reviewer: the store persists, the screen rebuilds, the
//  copy is right, and nothing fails. The only way to see it is to ask who
//  READS the field — which is the wiring gate CLAUDE.md names, applied to data
//  rather than to a route.
//
//  The fix is not a new personalisation engine. `FamilyProfileStore
//  .pregConditions` already existed and is already fed into every Ask Veda
//  question by `veda_context.dart`; the section had simply grown a second,
//  private answer to "which conditions does she have". So these tests pin the
//  BRIDGE — that the two stores hold one fact between them, in both
//  directions, and that the mapping never invents a condition she never named.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/data/hubs/pregnancy_hubs.dart';
import 'package:parentveda/data/journeys/pregnancy_journeys.dart';
import 'package:parentveda/screens/conditions/condition_detail_screen.dart';
import 'package:parentveda/screens/conditions/conditions_home_screen.dart';
import 'package:parentveda/services/family_profile.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

ConditionEntry _byId(String id) => kAllConditions.firstWhere((c) => c.id == id);

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 6000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late PregnancyController pregnancy;

  setUp(() {
    pregnancy = PregnancyController();
    FamilyProfileStore.instance.clearPregConditions();
    // Clear anything a previous test added to the journey.
    for (final c in ConditionsStore.instance.addedConditions.toList()) {
      ConditionsStore.instance.toggleAddedToJourney(c.id);
    }
  });
  tearDown(() => pregnancy.dispose());

  // ===========================================================================
  //  1 · The bridge — one fact, two stores
  // ===========================================================================

  group('adding a condition reaches the app\'s real personalisation axis', () {
    test('adding writes through to FamilyProfileStore', () {
      final fp = FamilyProfileStore.instance;
      expect(fp.hasPregCondition(PregCondition.gestationalDiabetes), isFalse);

      ConditionsStore.instance.toggleAddedToJourney('gdm');

      // ⚠️ THE ASSERTION THAT WOULD HAVE FAILED BEFORE THE FIX, AND THE ONLY
      // ONE THAT PROVES ANYTHING HAPPENED. `isAddedToJourney` was already true
      // and already meant nothing.
      expect(fp.hasPregCondition(PregCondition.gestationalDiabetes), isTrue);
      expect(ConditionsStore.instance.isAddedToJourney('gdm'), isTrue);
    });

    test('removing it takes the signal back out', () {
      final fp = FamilyProfileStore.instance;
      ConditionsStore.instance.toggleAddedToJourney('thyroid');
      expect(fp.hasPregCondition(PregCondition.thyroid), isTrue);

      ConditionsStore.instance.toggleAddedToJourney('thyroid');
      expect(fp.hasPregCondition(PregCondition.thyroid), isFalse);
    });

    test('adding twice does not toggle the shared signal off', () {
      // ⚠️ THE BUG THE `hasPregCondition(...) != added` GUARD PREVENTS.
      // `togglePregCondition` FLIPS, so mirroring blindly would mean a second
      // "add" silently un-declares the condition. Two screens writing one fact
      // must agree on its VALUE, not take turns inverting it.
      final fp = FamilyProfileStore.instance;
      fp.togglePregCondition(PregCondition.anemia); // set from the Profile screen
      expect(fp.hasPregCondition(PregCondition.anemia), isTrue);

      ConditionsStore.instance.toggleAddedToJourney('anemia'); // now added here
      expect(fp.hasPregCondition(PregCondition.anemia), isTrue);
    });

    test('a condition with no counterpart sends nothing downstream', () {
      final fp = FamilyProfileStore.instance;
      final before = fp.pregConditions.length;

      // ICP/cholestasis is real, in the library, and has no `PregCondition`.
      ConditionsStore.instance.toggleAddedToJourney('icp_cholestasis');

      // ⚠️ NULL IS A REAL ANSWER. The alternative — forcing it into the
      // nearest enum value — would tell Ask Veda she has something she does
      // not, which is worse than telling it nothing.
      expect(fp.pregConditions.length, before);
      // ...but her own record still holds it, or the tap did nothing at all.
      expect(ConditionsStore.instance.isAddedToJourney('icp_cholestasis'),
          isTrue);
    });
  });

  // ===========================================================================
  //  2 · The mapping is honest
  // ===========================================================================

  group('the condition -> profile mapping never guesses', () {
    test('every mapped signal is an exact match, not an approximation', () {
      const expected = <String, PregCondition>{
        'gdm': PregCondition.gestationalDiabetes,
        'thyroid': PregCondition.thyroid,
        'anemia': PregCondition.anemia,
        'placenta_previa': PregCondition.lowLyingPlacenta,
        'high_bp': PregCondition.hypertension,
      };
      for (final e in expected.entries) {
        expect(_byId(e.key).pregSignal, e.value, reason: e.key);
      }
    });

    test('nothing is ever auto-labelled high risk', () {
      // ⚠️ THE DELIBERATE OMISSION, PINNED SO IT IS NOT "FIXED" LATER.
      //
      // `PregCondition.highRisk` would swallow a dozen entries here — IUGR,
      // HELLP, abruption, vasa previa, cervical incompetence. It is left
      // unmapped on purpose: "high risk" is a clinician's judgement about her
      // whole pregnancy, not something to infer from her reading a page. That
      // inference is exactly the failure the two-way door exists to prevent —
      // an unconfirmed fear becoming a profile entry — arriving through the
      // back of the same section.
      for (final c in kAllConditions) {
        expect(c.pregSignal, isNot(PregCondition.highRisk), reason: c.id);
      }
    });

    test('nothing maps to previousCsection either', () {
      // Not a complication in this library at all — it is a history fact she
      // states, and no page here implies it.
      for (final c in kAllConditions) {
        expect(c.pregSignal, isNot(PregCondition.previousCsection),
            reason: c.id);
      }
    });
  });

  // ===========================================================================
  //  3 · She can see that it did something
  // ===========================================================================

  group('the personalisation is visible, not just stored', () {
    testWidgets('added conditions surface first, and the eight still follow',
        (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      ConditionsStore.instance.toggleAddedToJourney('gdm');

      await _pump(t, ConditionsHomeScreen(pregnancy: pregnancy));

      expect(find.text('What you are managing'), findsOneWidget);

      // ⚠️ ORDER CHANGES, STRUCTURE DOES NOT. Every one of the common eight is
      // still on the page — `test/landing_focus_test.dart` holds this line for
      // the whole app, and a section that quietly hid six conditions because
      // she named one would break it here.
      expect(find.text('Most common'), findsOneWidget);
      for (final c in kCommonConditions) {
        expect(find.text(c.name.en), findsWidgets, reason: c.id);
      }
    });

    testWidgets('with nothing added, the strip does not render', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(t, ConditionsHomeScreen(pregnancy: pregnancy));
      expect(find.text('What you are managing'), findsNothing);
    });
  });

  // ===========================================================================
  //  4 · The door still gates what it always gated
  // ===========================================================================

  group('a curious visit saves nothing', () {
    testWidgets('no "add to my journey" behind the browsing door', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.curious);
      await _pump(
          t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));

      // ⚠️ THIS MATTERS MORE NOW THAN IT DID. Before the bridge, showing the
      // button to a curious reader would have written to a dead set. It now
      // writes into the profile Ask Veda reads — so the door is the thing
      // standing between "I looked up a scary word" and "the app believes I
      // have this".
      expect(find.text('Add to my journey'), findsNothing);
    });

    testWidgets('the diagnosed door shows it', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(
          t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));
      expect(find.text('Add to my journey'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  5 · The page opens on the film
  // ===========================================================================

  group('the video is at the top of a condition page', () {
    testWidgets('above "What this is", below the safety frame', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.curious);
      await _pump(
          t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));

      final frame = t.getTopLeft(find.textContaining('does not replace')).dy;
      final video =
          t.getTopLeft(find.textContaining('start to finish')).dy;
      final what = t.getTopLeft(find.text('What this is')).dy;

      // ⚠️ THE FRAME STAYS FIRST. A video is the element most likely to be
      // mistaken for a second opinion, so the line that says we are not one
      // has to be read before it.
      expect(frame, lessThan(video));
      expect(video, lessThan(what));
    });

    testWidgets('a series shows the playlist count, a single video does not',
        (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.curious);

      await _pump(
          t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));
      expect(_byId('gdm').watchEpisodes, 4);
      expect(find.text('1 / 4'), findsOneWidget);
      expect(find.text('4-part series  ·  see all'), findsOneWidget);

      await _pump(
          t,
          ConditionDetailScreen(entry: _byId('pcos'), pregnancy: pregnancy));
      expect(_byId('pcos').watchEpisodes, 1);
      expect(find.textContaining('part series'), findsNothing);
    });

    testWidgets('a condition that never earned a video still has none',
        (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.curious);
      final quiet = kAllConditions.firstWhere((c) => !c.showWatch);
      await _pump(
          t, ConditionDetailScreen(entry: quiet, pregnancy: pregnancy));

      // ⚠️ MOVING AN ELEMENT UP MUST NOT PROMOTE IT EVERYWHERE. Depth varies by
      // condition; a rare one that gets two honest sentences does not acquire
      // a hero video because the common ones did.
      expect(find.text('Watch'), findsNothing);
      expect(find.text('Watch this explained'), findsNothing);
    });
  });

  // ===========================================================================
  //  6 · Copy and shape fixes
  // ===========================================================================

  group('the copy says things a person would say', () {
    test('the passive "given a name for something" line is gone', () {
      for (final text in [
        kPgUnderstandCondition.intro.en,
        kPgComplications.hero.en,
      ]) {
        expect(text.toLowerCase(), isNot(contains('given a name')),
            reason: text);
      }
    });

    test('Complications has one door, and it is the understanding one', () {
      // ⚠️ "Track my readings" is off. Two doors made the hub read as a choice
      // between understanding and logging, at the one moment when only one of
      // those is the need.
      expect(kPgComplications.needs.length, 1);
      expect(kPgComplications.needs.first.action, kPgActConditionLibrary);
    });
  });

  // ===========================================================================
  //  7 · The grouping the spec asked for is actually rendered
  // ===========================================================================

  group('the library is grouped, not a wall of 27 names', () {
    test('the front is exactly the common eight', () {
      expect(kCommonConditions.length, 8);
      for (final c in kCommonConditions) {
        expect(c.group, ConditionGroup.common, reason: c.id);
      }
    });

    test('everything else has a group, and every group has a title', () {
      for (final c in kAllConditions) {
        expect(c.group.title.en.trim(), isNotEmpty, reason: c.id);
      }
    });

    testWidgets('see-more reveals the grouped shelves', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.curious);
      await _pump(t, ConditionsHomeScreen(pregnancy: pregnancy));

      // Collapsed: the grouped shelves are not on the page.
      expect(find.text(ConditionGroup.placentaBleeding.title.en), findsNothing);

      await t.tap(find.text('See more'));
      await t.pumpAndSettle();

      for (final g in kSeeMoreGroups.keys) {
        expect(find.text(g.title.en), findsOneWidget, reason: g.name);
      }
    });
  });
}
