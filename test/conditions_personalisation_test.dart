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
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/screens/prepare/consultations_screen.dart';
import 'package:parentveda/data/hubs/pregnancy_hubs.dart';
import 'package:parentveda/data/journeys/journey_registry.dart';
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
  _conditionLibraryHasADoor();
  _widenedSignals();
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

      // ⚠️ THIS TEST USED TO USE ICP/CHOLESTASIS, WHICH NOW HAS A SIGNAL.
      // The principle it guards is unchanged; only the example went stale, and
      // it went stale in the good direction. Dengue replaces it because dengue
      // is refused on a durable ground rather than an accidental one: it
      // RESOLVES, and `FamilyProfileStore` has no expiry, so recording it would
      // still be telling Ask Veda about it three months later. See
      // `PregCondition`'s comment for the full list and the state-vs-event rule
      // that produced it - which is why this example cannot go stale the way
      // the last one did.
      ConditionsStore.instance.toggleAddedToJourney('dengue_pregnancy');

      // ⚠️ NULL IS A REAL ANSWER. The alternative — forcing it into the
      // nearest enum value — would tell Ask Veda she has something she does
      // not, which is worse than telling it nothing.
      expect(fp.pregConditions.length, before);
      // ...but her own record still holds it, or the tap did nothing at all.
      expect(ConditionsStore.instance.isAddedToJourney('dengue_pregnancy'),
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

  // ===========================================================================
  //  "Talk to a doctor" — the offer that fell out of the hub, and the tap
  // ===========================================================================
  //
  //  ⚠️ THE HISTORY IS THE POINT. The review asked to remove "Track my
  //  readings". It did not ask to remove the consult offer — but removing that
  //  door left the hub with ONE door, a one-door hub renders no hub screen at
  //  all, and so the closing offer it carried stopped existing. A deletion
  //  nobody requested, produced as a side effect of one somebody did.
  //
  //  ⚠️ AND RENDERING IT IS HALF THE JOB. "Make sure it actually helps when
  //  they click it" — so the tap is asserted, not just the card. A card naming
  //  a gynaecologist that opens an unfiltered list of five specialists is the
  //  wiring gate this app has already shipped once, on the scans page.
  group('talk to a doctor is offered, and the tap lands somewhere useful', () {
    testWidgets('an ordinary condition page closes with the offer', (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));
      expect(find.text('Ask a gynaecologist about your own case'),
          findsOneWidget);
    });

    testWidgets('tapping it opens the list filtered to the obstetrician',
        (t) async {
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(t,
          ConditionDetailScreen(entry: _byId('gdm'), pregnancy: pregnancy));

      await t.tap(find.text('Ask a gynaecologist about your own case'));
      await t.pumpAndSettle();

      // ⚠️ THE ASSERTION IS ON THE FILTER, NOT ON ARRIVAL. Landing on the
      // consultations screen at all would pass a weaker test and still ship the
      // exact defect: she is told "a gynaecologist" and shown five specialists.
      final screen = t.widget<ConsultationsScreen>(
          find.byType(ConsultationsScreen));
      expect(screen.onlyRole, kConditionConsultRole);
    });

    testWidgets('the role it names is a specialist that actually exists',
        (t) async {
      // A filter matching nothing falls back to showing everyone, so a typo in
      // the role would never render an empty screen — it would silently undo
      // the filter and nothing above would fail.
      expect(kSpecialists.map((x) => x.id), contains(kConditionConsultRole));
    });

    testWidgets('miscarriage is not sold anything', (t) async {
      // ⚠️ `highAnxiety` GATES THIS, AND MISCARRIAGE IS WHY THE FLAG EXISTS.
      // A woman reading this page has quite possibly just lost a pregnancy.
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(t, ConditionDetailScreen(
          entry: _byId('miscarriage'), pregnancy: pregnancy));
      expect(find.text('Ask a gynaecologist about your own case'), findsNothing);
    });

    testWidgets('preeclampsia is not sold anything either', (t) async {
      // Different reason from miscarriage, same answer: this page carries
      // call-now instructions. At 2am the right response is her doctor's phone
      // number, not a booking that resolves next week.
      ConditionsStore.instance.setDoor(ConditionDoorAnswer.diagnosed);
      await _pump(t, ConditionDetailScreen(
          entry: _byId('preeclampsia'), pregnancy: pregnancy));
      expect(find.text('Ask a gynaecologist about your own case'), findsNothing);
    });

    test('exactly two conditions are exempt, so the flag has not spread', () {
      // If this number grows, someone has used highAnxiety as a general "no
      // commerce" switch, which would quietly change the tone rules the flag
      // also governs.
      expect(kAllConditions.where((c) => c.highAnxiety).length, 2);
    });
  });

}

// =============================================================================
//  The widened signal set — what it records, what it refuses, and what it
//  must never turn into
// -----------------------------------------------------------------------------
//  Three separate promises, easy to blur into one:
//
//    1. Every mapped condition reaches a real enum value.
//    2. The RECORDED set may grow; the ASKED set may not, silently.
//    3. Events never become state.
//
//  (3) is the one with teeth. `FamilyProfileStore` has no expiry: nothing ever
//  clears a condition. So a value that is true for a fortnight is true forever,
//  and the failure lands as Ask Veda being told in March about January's
//  dengue — or, far worse, addressing a pregnant woman about a pregnancy that
//  ended in a miscarriage she read about once.
// =============================================================================

void _widenedSignals() {
  test('every mapped condition resolves to a real signal', () {
    final mapped = kAllConditions.where((c) => c.pregSignal != null).toList();
    expect(mapped.length, greaterThanOrEqualTo(12),
        reason: 'signals were removed rather than added');
    for (final c in mapped) {
      expect(PregCondition.values, contains(c.pregSignal), reason: c.id);
    }
  });

  test('the asked chip list stays seven and stays askable', () {
    // ⚠️ THE ASSERTION THAT PROTECTS ONBOARDING. Both chip surfaces iterate
    // `askable`, so this number is what a mother actually sees. It is pinned
    // exactly - not `lessThan` - because the failure mode is drift by one, a
    // value at a time, each individually defensible.
    expect(PregConditionX.askable.length, 7);
    for (final c in PregConditionX.askable) {
      expect(c.isAskable, isTrue, reason: c.name);
    }
  });

  test('recorded-only signals are never asked', () {
    const recorded = [
      PregCondition.pcos,
      PregCondition.hyperemesis,
      PregCondition.cholestasis,
      PregCondition.iugr,
      PregCondition.rhNegative,
      PregCondition.cervicalIncompetence,
      PregCondition.fibroids,
    ];
    for (final c in recorded) {
      expect(c.isAskable, isFalse,
          reason: '${c.name} became a chip - she already declared it on a '
              'condition page, so asking again is the app not listening');
    }
  });

  test('losses and acute events map to no signal, deliberately', () {
    // ⚠️ THIS TEST IS THE DECISION, NOT A SIDE EFFECT OF IT. Each of these has
    // a full condition page and could plausibly earn a signal; each is refused
    // because it is an event rather than ongoing state, and the profile cannot
    // express "this was true for three weeks".
    //
    // Ectopic and miscarriage are the ones that matter most: persisting either
    // would have the app talking to a woman about a pregnancy that has ended.
    const mustStayNull = [
      'ectopic', 'miscarriage', // losses
      'placental_abruption', 'hellp', 'vasa_previa', // acute emergencies
      'covid_pregnancy', 'dengue_pregnancy', 'uti', // resolve
      'breech', // a position; most babies turn
      'polyhydramnios', 'low_amniotic_fluid', // a measurement at a moment
      'piles', 'varicose_veins', // symptoms, another bracket
      'preeclampsia', // clinical call, parked for review
    ];
    for (final id in mustStayNull) {
      final c = kAllConditions.firstWhere((x) => x.id == id);
      expect(c.pregSignal, isNull,
          reason: '$id gained a signal. If that was deliberate, the enum '
              'needs an expiry mechanism first - see PregCondition.');
    }
  });

  test('no two conditions claim the same signal', () {
    // Two pages writing one value means untoggling either clears both, and the
    // button on the other page silently lies about its own state.
    final seen = <PregCondition, String>{};
    for (final c in kAllConditions.where((x) => x.pregSignal != null)) {
      final prev = seen[c.pregSignal!];
      expect(prev, isNull,
          reason: '${c.id} and $prev both map to ${c.pregSignal!.name}');
      seen[c.pregSignal!] = c.id;
    }
  });

  test('every wire label is non-empty and lower-caseable', () {
    // `veda_context.dart` sends `label.en.toLowerCase()`. An empty or
    // whitespace label reaches the service as a blank condition, which is worse
    // than sending nothing: it looks like an answer.
    for (final c in PregCondition.values) {
      expect(c.label.en.trim(), isNotEmpty, reason: c.name);
    }
  });

}

// =============================================================================
//  The condition library has a door — the wiring gate, as an assertion
// -----------------------------------------------------------------------------
//  ⚠️ THE DEFECT: `conditionsHomeScreen(...)` had ZERO call sites in the app.
//  Twenty-seven condition pages, a search, grouped shelves, a two-way "add to
//  my journey", a consult offer at the foot of twenty-five of them, and a full
//  test file — reachable by nothing.
//
//  ⚠️ WHY EVERY EXISTING TEST PASSED. They construct `ConditionDetailScreen`
//  and `ConditionsHomeScreen` directly, which is the right way to test what a
//  screen renders and says nothing at all about whether she can get to it. That
//  gap is exactly the wiring gate CLAUDE.md names, and it is why "test counts
//  are not evidence that a feature is reachable" is written there.
//
//  ⚠️ THE MECHANISM IS WORTH KEEPING. `_hubAction` calls `journeyFor(action)`
//  BEFORE its switch and returns early if a journey exists. So registering a
//  journey in `kPregnancyJourneys` silently overrides the switch — from another
//  file, with nothing at the switch to indicate it. The superseded journey was
//  never unregistered when the library replaced it, so the switch-case for this
//  door had never once run.
//
//  These assert the two halves that must stay true together: the door is not
//  claimed by a journey, and the destination it falls through to exists.
// =============================================================================

void _conditionLibraryHasADoor() {
  test('no journey intercepts the condition-library door', () {
    // ⚠️ THE ASSERTION THAT ACTUALLY CATCHES THE BUG. If someone re-registers
    // `kPgUnderstandCondition`, the library goes dark again and nothing else in
    // the suite notices - the journey renders perfectly well.
    expect(journeyFor(kPgActConditionLibrary), isNull,
        reason: 'a registered journey wins over the switch, so the library '
            'would be unreachable again');
  });

  test('the superseded journey is out of the registry, not deleted', () {
    // Comment out, never delete: the config still compiles and can be restored.
    // What must not happen is it being restored INTO the registry by accident.
    for (final j in kPregnancyJourneys.values) {
      expect(j.doorId, isNot(kPgActConditionLibrary), reason: j.title.en);
    }
  });

  test('the hub door still points at the library action', () {
    // The other half. If the door's action were renamed, the test above would
    // keep passing while the door led nowhere.
    final doors = kPgComplications.needs.map((n) => n.action).toList();
    expect(doors, contains(kPgActConditionLibrary));
  });

  test('the library screen builds from its documented entry point', () {
    // `conditionsHomeScreen(pregnancy:)` is the form the integrator note names,
    // and the form the dispatch now calls. A zero-argument variant existed and
    // is the wrong one.
    final c = PregnancyController();
    addTearDown(c.dispose);
    expect(conditionsHomeScreen(pregnancy: c), isA<ConditionsHomeScreen>());
  });
}
