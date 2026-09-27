// =============================================================================
//  The Fertile window door's coverflow selector
// -----------------------------------------------------------------------------
//  `_GroupCarousel` is design 4a, "mist falloff": five group cards on one 3D
//  track, the chosen one forward and the rest receding in three steps — the
//  neighbours at 0.8 scale and 92% opacity, the back pair at 0.6 and 72%,
//  blurred a little and tinted deeper, with the track fading out at both
//  edges. It ships on ONE door — Fertile window — while the other six keep the
//  flat `_GroupRail`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS FILE IS ACTUALLY GUARDING
//  ---------------------------------------------------------------------------
//
//  Three things, and the second is the one that would bite silently.
//
//  **1. That the gate is wired.** A constant reading `'ttc_conceiving'` proves
//  nothing about which widget the door builds. This asserts the widget, on both
//  sides of the branch — the carousel on Fertile window, the rail everywhere
//  else. Asserting only the first half is how a rollout to seven doors gets
//  made by accident and noticed by a user.
//
//  **2. That the back pair are still reachable.** They are drawn now — 4a's
//  whole point over 3a is that nothing is hidden — but at 0.6 scale, half off
//  the track and behind the mask's edge, they are not a tap target, and no
//  card on the track is (see the hit-testing note in the screen). Which leaves
//  the dot row and the swipe as the only ways to them. If either of those
//  breaks, two groups' worth of content becomes unreachable while every widget
//  in the tree is still present and correct, and `find.text` will happily
//  find all of it.
//
//  **3. That the ladder is a ladder.** All five on the track, at three
//  distinct opacities, with the track masked at its edges. A regression that
//  quietly dropped the back pair — 3a's `_visibleSpan` coming back, say —
//  would pass every content test and only show on a handset.
//
//  The second failure is invisible to a content test, invisible to `flutter
//  analyze`, and invisible in a screenshot of the opening state.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/ttc_focus_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

// ---- `Image.network` needs a client that answers, or layout throws ---------
class _StubHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) => _StubClient();
}

class _StubClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _StubRequest();
}

class _StubRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _StubHeaders();

  @override
  Future<HttpClientResponse> close() async => _StubResponse();
}

class _StubHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _StubResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      const Stream<List<int>>.empty()
          .listen(onData, onError: onError, onDone: onDone);
}

/// Let the track finish gliding.
///
/// ⚠️ TWO PUMPS, AND `pumpAndSettle` IS NOT AN OPTION HERE. A `Ticker`
/// started while handling a gesture has no start time yet; the FIRST frame it
/// sees only establishes t₀ and reports zero elapsed, so a single
/// `pump(700ms)` leaves the settle sitting exactly where the finger left it.
/// That is a test artifact — in the app the frames keep coming — but it looks
/// exactly like a broken animation, and it cost an afternoon once.
///
/// `pumpAndSettle` would paper over it and cannot be used: this page carries
/// a placeholder with a looping shimmer, so it never settles.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Fertile window as the carousel was designed and tuned for it: five cards.
///
/// ⚠️ A FIXTURE BUILT FROM THE SHIPPED SECTIONS, AND WHY IT EXISTS
/// (2026-09-26). The door now has six tabs (the gap plan merged "Your window"
/// and "How to try", and added "Waiting and testing" and "Sex and closeness"),
/// and it renders through `TtcDoorScreen`, not this screen. Design 4a is a
/// five-card ladder: its rest positions, its back pair and its dot maths are
/// all about five. So these tests pin the carousel to the shape it was built
/// for, using the door's REAL sections and tiles regrouped by heading, rather
/// than asserting five-card geometry against six cards. The five labels are
/// the ones the tabs had before the merge.
TtcFocusPage fiveCardConceiving() {
  final real = ttcFocusPageFor('ttc_conceiving')!;
  const tabOf = {
    'When should we have sex?': 'window',
    'How many times should we try?': 'trying',
    'Which sex position is best?': 'trying',
    'Does stress stop pregnancy?': 'trying',
    'What he should do': 'his',
    'What you should do': 'hers',
    'When should we see a doctor?': 'doctor',
  };
  final byId = {for (final g in real.groups!) g.id: g};
  return TtcFocusPage(
    bracketId: real.bracketId,
    intro: real.intro,
    heroImageUrl: real.heroImageUrl,
    heroBlurb: real.heroBlurb,
    heroTitle: real.heroTitle,
    headline: real.headline,
    groups: [
      TtcFocusGroup(
          id: 'window', label: 'Your window',
          icon: Icons.center_focus_weak_outlined, hue: 344),
      TtcFocusGroup(
          id: 'trying', label: 'How to try',
          icon: Icons.favorite_border_rounded, hue: 42),
      byId['his']!,
      byId['hers']!,
      byId['doctor']!,
    ],
    sections: [
      for (final s in real.sections)
        if (tabOf[s.heading] case final tab?)
          TtcFocusSection(heading: s.heading, group: tab, tiles: s.tiles),
    ],
  );
}

void main() {
  setUp(() => HttpOverrides.global = _StubHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  /// ⚠️ 360pt, THE NARROWEST SCREEN THE APP IS DESIGNED AGAINST. The back pair
  /// — 172pt cards at 0.6 scale, displaced 170pt — run past the edge of the
  /// track here and are cut by its own mask, which is the design; this is the
  /// width at which that cut would show if the mask's fade ever went missing.
  ///
  /// And unlike the flat rail, WIDTH DOES NOT CHANGE WHAT IS MOUNTED. A
  /// horizontal `ListView` skips children that are off screen, which is why
  /// `ttc_focus_groups_test.dart` has to pump the rail at 820 to tap a late
  /// tab. The track is a `Stack`, so what is mounted depends on the position
  /// round the ring and not on the screen — the questions below are about hit
  /// testing and depth, not about scroll offset.
  Future<void> pump(WidgetTester tester, {String id = 'ttc_conceiving'}) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: TtcFocusScreen(
        page: id == kTtcCarouselBracketId
            ? fiveCardConceiving()
            : ttcFocusPageFor(id)!,
        // The real bracket, not a fixture — the screen reads `bracket.label`
        // for its heading so the tile and the page cannot drift apart.
        bracket: bracketById(id)!,
      ),
    ));
    await settle(tester);
    expect(tester.takeException(), isNull);
  }

  /// The group cards, in the order the data declares them.
  final groups = fiveCardConceiving().groups!;

  /// How far each card on the track is displaced sideways, in paint order.
  ///
  /// Reads the actual matrices, because the transform IS the feature. At rest
  /// these are 0, ±90.6 and ±151.8 — 4a's ±96 and ±170 pulled in by the
  /// perspective divide, see [restX].
  ///
  /// ⚠️ FILTERED ON THE PERSPECTIVE ENTRY, not on `find.byType(Transform)`.
  /// There are other `Transform`s inside a card — the icon is nudged two points
  /// left of centre so it sits on its mark — and counting those made "three
  /// cards on the track" read as six, and put a −2 where a 0 belonged. Entry
  /// [3][2] is set by the card matrix and by nothing else on this screen, so it
  /// identifies the cards without needing a key that exists only for a test.
  List<double> xOffsets(WidgetTester tester) => tester
      .widgetList<Transform>(find.descendant(
        of: find.byKey(kTtcGroupCarouselKey),
        matching: find.byType(Transform),
      ))
      .where((t) => t.transform.entry(3, 2) != 0)
      .map((t) => MatrixUtils.transformPoint(t.transform, Offset.zero).dx)
      .toList();

  /// Where the five cards rest, sorted. 4a puts the neighbour at x 96, z −60
  /// and the card behind it at x 170, z −120, under a 1000pt perspective — so
  /// the divide by `w = 1 + 60/1000` brings 96 back to 90.6, and `1 + 120/1000`
  /// brings 170 back to 151.8. If these come back as ±96 and ±170, the
  /// perspective entry has been dropped and the track is flat.
  const restX = [-170 / 1.12, -96 / 1.06, 0.0, 96 / 1.06, 170 / 1.12];

  /// One card's sideways displacement, by its label. Same filter as
  /// [xOffsets], applied to the label's own `Transform` ancestors.
  double xOf(WidgetTester tester, String label) => tester
      .widgetList<Transform>(
          find.ancestor(of: find.text(label), matching: find.byType(Transform)))
      .where((t) => t.transform.entry(3, 2) != 0)
      .map((t) => MatrixUtils.transformPoint(t.transform, Offset.zero).dx)
      .single;

  /// Which dots are lit, by index. The painted dot stretches from 5pt to 18pt
  /// as its card takes the middle, so anything past halfway is "lit" — and a
  /// correct track has exactly one.
  List<int> litDots(WidgetTester tester) => [
        for (var i = 0; i < groups.length; i++)
          if (tester
                  .widget<SizedBox>(find.descendant(
                      of: find.byKey(ttcCarouselDotKey(i)),
                      matching: find.byType(SizedBox)))
                  .width! >
              11.5)
            i,
      ];

  /// The card `Opacity` that wraps a group's label — the one that carries the
  /// mist. The count under the label has its own `Opacity`, but that one wraps
  /// the count and not the label, so an ancestor search from the label finds
  /// only the card's.
  double cardOpacity(WidgetTester tester, String label) => tester
      .widget<Opacity>(find
          .ancestor(of: find.text(label), matching: find.byType(Opacity))
          .first)
      .opacity;

  // ===========================================================================
  group('the gate is wired, in both directions', () {
    testWidgets('Fertile window builds the carousel and not the rail',
        (tester) async {
      await pump(tester);
      expect(find.byKey(kTtcGroupCarouselKey), findsOneWidget);
      expect(find.byKey(kTtcGroupRailKey), findsNothing,
          reason: 'both selectors rendered — the branch is not exclusive');
    });

    testWidgets('and every other grouped door still builds the rail',
        (tester) async {
      // ⚠️ ENUMERATED FROM THE DATA, NOT TYPED. A door added later is covered
      // the day it is added; a hand-written list would silently stop covering
      // the newest one, which is the door most likely to be wrong.
      final others = [
        for (final p in kTtcFocusPages)
          if (p.groups != null && p.bracketId != kTtcCarouselBracketId)
            p.bracketId,
      ];
      expect(others, isNotEmpty, reason: 'nothing was checked');

      for (final id in others) {
        await pump(tester, id: id);
        expect(find.byKey(kTtcGroupRailKey), findsOneWidget,
            reason: '$id lost its rail');
        expect(find.byKey(kTtcGroupCarouselKey), findsNothing,
            reason: '$id was rolled onto the carousel — that is a decision, '
                'not a tidy-up. See the note on _GroupCarousel.');
      }
    });
  });

  // ===========================================================================
  group('the front card and its neighbours', () {
    testWidgets('it opens on the first group, and its sections are below',
        (tester) async {
      await pump(tester);
      expect(find.text('When should we have sex?'), findsOneWidget);
      expect(find.text('What he should do'), findsNothing,
          reason: 'a section from another group rendered — the group filter '
              'is not filtering');
    });

    testWidgets('tapping the right side brings the next card forward',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselZoneKey(1)));
      await settle(tester);
      expect(tester.takeException(), isNull);

      expect(find.text('How many times should we try?'), findsOneWidget);
      expect(find.text('When should we have sex?'), findsNothing);
    });

    testWidgets('and the left side wraps round to the last card',
        (tester) async {
      // ⚠️ THE TRACK IS A RING, and this is the assertion that says so. Card
      // five sits at offset −1 from card one, not −4, so "See a doctor" is
      // one tap to the LEFT on open. Lose the wrap in `_offsetOf` and this
      // card quietly joins the hidden pair while everything still renders.
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselZoneKey(-1)));
      await settle(tester);

      expect(find.text('When should we see a doctor?'), findsOneWidget);
    });

    testWidgets('the cards themselves take no taps at all', (tester) async {
      // ⚠️ THE REGRESSION THIS EXISTS FOR IS SUBTLE, AND IT SHIPPED ONCE
      // ALREADY. A perspective-transformed widget in Flutter is tappable
      // roughly 18pt from where it is painted, because
      // `removePerspectiveTransform` leaves a residue at matrix entry [3][0]
      // once `rotateY` has coupled x into z. Giving a card back its own
      // `GestureDetector` would restore a control that works most of the time
      // and misses near the edges — the worst kind of failure, because it
      // looks fine in a demo.
      //
      // So no card may be a button. If one becomes one again, this fails.
      await pump(tester);
      final onTrack = groups.where(
          (g) => find.text(g.label).evaluate().isNotEmpty);
      expect(onTrack, hasLength(5), reason: 'expected all five cards on the track');
      for (final g in onTrack) {
        expect(
            find.ancestor(
              of: find.text(g.label),
              matching: find.descendant(
                of: find.byKey(kTtcGroupCarouselKey),
                matching: find.byType(IgnorePointer),
              ),
            ),
            findsWidgets,
            reason: '"${g.label}" is no longer behind an IgnorePointer, so '
                'the card is taking pointers again. Taps belong to the '
                'untransformed zones — see the note on '
                '_GroupCarouselState.build.');
      }
    });
  });

  // ===========================================================================
  group('the back pair are still reachable', () {
    /// The pair at |offset| 2 when the first card is chosen. With five groups
    /// that is indices 2 and 3 — the ring puts index 4 at −1, not +4.
    const hiddenA = 2;
    const hiddenB = 3;

    testWidgets('a side tap moves one card, never straight to a far one',
        (tester) async {
      // The zones stand for the two NEIGHBOURS. If a zone ever came to mean
      // "whichever card is painted under my finger", the right zone would
      // sometimes land on the far card at the edge of the track, and the
      // track would jump two places for one tap.
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselZoneKey(1)));
      await settle(tester);

      expect(find.text('How many times should we try?'), findsOneWidget);
      expect(find.text('What he should do'), findsNothing,
          reason: 'one tap skipped a card — the right zone is resolving to '
              'something other than offset +1');
    });

    testWidgets('the dot row reaches them in one tap', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselDotKey(hiddenA)));
      await settle(tester);
      expect(tester.takeException(), isNull);

      expect(find.text('What he should do'), findsOneWidget,
          reason: 'the dots are the only one-step route to the back pair; '
              'without them two groups need two swipes each');
    });

    testWidgets('and a swipe walks the track one card at a time',
        (tester) async {
      await pump(tester);
      final track = find.byKey(kTtcGroupCarouselKey);

      // Dragging left pulls the next card into the middle, so two drags from
      // the opening card land on index 2 — the first of the back pair.
      //
      // ⚠️ 140pt, OF WHICH THE TRACK SEES ABOUT 122. `tester.drag` spends the
      // first 18pt winning the gesture and reports no delta for it, and a
      // card is 172pt of finger, so 122 is a clear seven tenths — past the
      // halfway point that commits to the next card, with room to spare.
      // 90 would leave 72, which is four tenths and springs back.
      for (var i = 0; i < hiddenA; i++) {
        await tester.drag(track, const Offset(-140, 0));
        await settle(tester);
      }
      expect(tester.takeException(), isNull);
      expect(find.text('What he should do'), findsOneWidget,
          reason: 'two swipes left did not advance two cards — check the '
              'drag divisor and the sign in the drag handler');

      // ⚠️ AND BACK, because a one-way track is a live bug with a passing
      // test. Dragging right returns card by card.
      await tester.drag(track, const Offset(140, 0));
      await settle(tester);
      expect(find.text('How many times should we try?'), findsOneWidget);

      // The ring, from the other end: one more step back from the opening card
      // is the LAST group, not a dead stop.
      await tester.drag(track, const Offset(140, 0));
      await settle(tester);
      await tester.drag(track, const Offset(140, 0));
      await settle(tester);
      expect(find.text('When should we see a doctor?'), findsOneWidget,
          reason: 'dragging back past the first card stopped instead of '
              'wrapping — the far end of the track is a wall');
    });

    testWidgets('all five cards are on the track, in three steps of mist',
        (tester) async {
      // ⚠️ THE WHOLE OF 4a OVER 3a, ASSERTED. 3a built three cards and faded
      // the far pair to nothing; 4a keeps every card on the track and says how
      // far back each one is with opacity — 1, .92, .72 — so distance never
      // means invisible. If this ever reads three, 3a's `_visibleSpan` has come
      // back, and two groups have gone quiet again without a test noticing.
      await pump(tester);
      expect(xOffsets(tester).length, 5,
          reason: 'the track is not drawing all five cards');

      expect(cardOpacity(tester, groups[0].label), closeTo(1, 0.01),
          reason: 'the front card is not at full opacity');
      for (final i in [1, 4]) {
        expect(cardOpacity(tester, groups[i].label), closeTo(0.92, 0.01),
            reason: '"${groups[i].label}" is a neighbour and should sit at '
                '4a\'s 92%');
      }
      for (final i in [hiddenA, hiddenB]) {
        expect(cardOpacity(tester, groups[i].label), closeTo(0.72, 0.01),
            reason: '"${groups[i].label}" is at the back of the ladder and '
                'should sit at 4a\'s 72% — drawn, not hidden');
      }
    });

    testWidgets('and the track is masked at both edges', (tester) async {
      // 4a: *"both track edges fade to 45% so the far cards soften rather than
      // being sliced by the screen."* In Flutter that is a `ShaderMask` AND a
      // `ClipRect` — the mask alone leaves anything painted past the track's
      // own rect untouched, so without the clip the far card's overhang would
      // come through sharp and at full strength, exactly where the design
      // wants it faintest. See the note in `_GroupCarouselState.build`.
      await pump(tester);
      final track = find.byKey(kTtcGroupCarouselKey);
      expect(find.descendant(of: track, matching: find.byType(ShaderMask)),
          findsOneWidget,
          reason: 'the edge fade is gone — the back pair will be sliced by '
              'the screen instead of softening into it');
      expect(find.descendant(of: track, matching: find.byType(ClipRect)),
          findsOneWidget,
          reason: 'the mask has no clip, so paint outside the track is '
              'unmasked');
    });
  });

  // ===========================================================================
  //  ⚠️ THE GROUP THAT WOULD HAVE CAUGHT THE FIRST CUT
  // ---------------------------------------------------------------------------
  //  The first version of this screen had no motion. Every content test above
  //  passed anyway, because the CONTENT was right — tap a side, the sections
  //  below change. What was wrong was that the cards teleported instead of
  //  travelling, for two reasons that hid each other: a `Matrix4Tween` cannot
  //  carry perspective through `decompose`, so every intermediate frame drew
  //  flat; and the depth-sorted `Stack` had no keys, so each slot's element was
  //  reused for a different card every time the order changed.
  //
  //  Neither shows up in a finder. So these read the matrices.
  // ===========================================================================
  group('the track actually moves', () {
    testWidgets('at rest, the cards sit at the five design positions',
        (tester) async {
      await pump(tester);
      final xs = xOffsets(tester)..sort();
      expect(xs, hasLength(5));
      for (var i = 0; i < 5; i++) {
        expect(xs[i], closeTo(restX[i], 1.5),
            reason: 'card $i is not where 4a puts it — either the ladder '
                'numbers have drifted or the perspective divide is not '
                'happening. xs = $xs');
      }
    });

    testWidgets('mid-flight the cards are between positions, not at one',
        (tester) async {
      // ⚠️ THIS IS THE ONE THAT FAILS IF THE ANIMATION IS EVER TWEENED ON THE
      // MATRIX AGAIN. A `Matrix4Tween` decomposes to translate/rotate/scale,
      // which has nowhere to put the perspective row, so the in-between frames
      // come out flat — and a flat frame reads x at the full ±96 and ±170.
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselZoneKey(1)));
      await tester.pump(); // seed the ticker
      await tester.pump(const Duration(milliseconds: 180)); // 4a's .48s, part way

      final xs = xOffsets(tester);
      // A card is "moving" when it is not within a point and a half of ANY
      // resting place — with five rests on the line, "between 4 and 112" would
      // count a neighbour at rest as moving.
      final moving =
          xs.where((x) => restX.every((r) => (x - r).abs() > 1.5));
      expect(moving, isNotEmpty,
          reason: 'every card is already at a resting position 180ms into a '
              '450ms glide — the track is jumping, not travelling. xs = $xs');
    });

    testWidgets('one step left travels one card, never four the other way',
        (tester) async {
      // ⚠️ THE RING, MID-FLIGHT. The end state of a wrap was already asserted
      // above — tap left from the first card, the last card is chosen. This
      // is about how it gets there. `_land` settles the short way round, then
      // the parent's rebuild arrives with `selected == 4` and, in the first
      // cut, restarted the settle toward 4.0 as a plain number — from 0 to 4
      // the LONG way, through every card. The content test passed; the track
      // spun. So: 180ms in, the last card must be between its resting place
      // on the left and the middle, and the first card must be heading right.
      await pump(tester);
      await tester.tap(find.byKey(ttcCarouselZoneKey(-1)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));

      final last = xOf(tester, groups[4].label);
      final first = xOf(tester, groups[0].label);
      expect(last, inExclusiveRange(restX[1], -2),
          reason: 'the last card is not arriving from the left — the settle '
              'went the long way round. x = $last');
      expect(first, greaterThan(2),
          reason: 'the first card is not leaving to the right. x = $first');
    });

    testWidgets('two full laps, and nothing drifts', (tester) async {
      // ⚠️ THE TEST THE ONE-STEP CHECKS COULD NOT BE. Every assertion above
      // takes one step from the opening card, and `_offsetOf` wraps, so a
      // track whose position wanders is indistinguishable from a correct one
      // for the first few steps. The drift only shows once the position has
      // left [0, count) far enough to break something downstream — which is
      // what walking the ring twice does.
      //
      // What actually broke: `_position` grows by ±1 per step forever, and the
      // dot row's wrap — `if (o > n/2) o = n - o` — is only correct while the
      // position is inside one lap. At position −6 it returns a NEGATIVE
      // distance for every dot, every dot clamps to fully lit, and the counter
      // stops saying which card is open. The cards were still right; the row
      // under them was a row of five lit pills.
      await pump(tester);
      for (var lap = 0; lap < 2; lap++) {
        for (var step = 1; step <= 5; step++) {
          await tester.tap(find.byKey(ttcCarouselZoneKey(1)));
          await settle(tester);
          final i = (lap * 5 + step) % 5;

          expect(xOf(tester, groups[i].label), closeTo(0, 1),
              reason: 'lap $lap step $step: ${groups[i].label} should have '
                  'taken the middle of the track');
          expect(litDots(tester), [i],
              reason: 'lap $lap step $step: the dot row should light exactly '
                  'dot $i. If every dot is lit, _position has drifted outside '
                  'one lap and the dots\' wrap has gone negative.');
          expect(xOffsets(tester)..sort(), [
            for (final r in restX) closeTo(r, 1.5)
          ], reason: 'lap $lap step $step: the cards are not at the five '
              'resting places — the ring has stopped being a ring');
        }
      }
    });

    testWidgets('and a lap driven by the finger, not by taps', (tester) async {
      // ⚠️ THE SAME LAP, THROUGH THE OTHER DOOR. A tap goes `_step` → `_land`;
      // a drag writes the position directly and then rounds it at the end, so
      // it reaches `_land` with a fractional position and can land on a
      // different card. The loop has to hold on both paths, and the swipe is
      // the one a thumb actually uses.
      await pump(tester);
      final track = find.byKey(kTtcGroupCarouselKey);
      for (var step = 1; step <= 6; step++) {
        await tester.drag(track, const Offset(-140, 0));
        await settle(tester);
        final i = step % 5;
        expect(litDots(tester), [i],
            reason: 'swipe $step: expected only dot $i lit');
        expect(xOf(tester, groups[i].label), closeTo(0, 1),
            reason: 'swipe $step: ${groups[i].label} should be in the middle');
      }
    });

    testWidgets('and the same lap backwards', (tester) async {
      await pump(tester);
      for (var step = 1; step <= 6; step++) {
        await tester.tap(find.byKey(ttcCarouselZoneKey(-1)));
        await settle(tester);
        final i = ((-step) % 5 + 5) % 5;
        expect(litDots(tester), [i],
            reason: 'step $step backwards: expected only dot $i lit');
      }
    });

    testWidgets('and a drag turns the cards while the finger is still down',
        (tester) async {
      // 4a waits for a 28pt threshold and then animates by itself, because CSS
      // has to. Here the drag writes straight to the position, so half a swipe
      // is half a turn — and letting go halfway puts it back.
      await pump(tester);
      final rest = xOffsets(tester)..sort();

      final drag = await tester.startGesture(
          tester.getCenter(find.byKey(kTtcGroupCarouselKey)));
      // ⚠️ THROUGH THE SLOP FIRST, THEN THE REAL MOVE. `DragStartBehavior.start`
      // — the default — treats the distance that won the gesture as spent and
      // emits no update for it, so a single synthetic `moveBy` fires `onStart`
      // and nothing else, and the track looks frozen. A real finger sends a
      // stream of small moves; `tester.drag` fakes that by splitting at the
      // slop, and a hand-driven gesture has to do the same.
      // 50pt of a 172pt card is under a third of the way — unambiguously "not
      // far enough" to commit, and far enough to see the card move.
      await drag.moveBy(const Offset(-20, 0));
      await drag.moveBy(const Offset(-50, 0));
      await tester.pump();

      final mid = xOffsets(tester)..sort();
      expect(mid[2], isNot(closeTo(rest[2], 1)),
          reason: 'the middle card has not moved with the finger — the drag is '
              'still waiting for a threshold instead of following');

      await drag.up();
      await settle(tester);
      // Not far enough to change card, so the track returns.
      expect(find.text('When should we have sex?'), findsOneWidget,
          reason: 'a short drag changed the selection; it should spring back');
      expect(xOffsets(tester)..sort(),
          orderedEquals([for (final r in rest) closeTo(r, 1)]));
    });
  });

  // ===========================================================================
  testWidgets('the whole door still scrolls to the bottom at 360pt',
      (tester) async {
    // The back pair run past the track's edge on purpose, into its mask. This
    // is the check that the overrun is masked and not an overflow: a
    // `RenderFlex` stripe would throw here, on the narrowest screen we design
    // for.
    await pump(tester);
    for (var i = 0; i < 20; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'threw while scrolling');
    }
  });
}
