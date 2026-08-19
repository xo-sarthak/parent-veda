// =============================================================================
//  Itching is a safety route, not a skincare page
// -----------------------------------------------------------------------------
//  This is the one page in Belly & Skin whose job is to get a woman to a
//  doctor. Everything else in that section is comfort and cosmetics; this page
//  is the reason the section is allowed to exist next to a shop.
//
//  ⚠️ THE TEST THAT MATTERS MOST IS `no commerce anywhere on this page`.
//
//  Every other rule here fails loudly if broken. That one fails by looking
//  perfectly reasonable: someone adds a moisturiser card to a page about itchy
//  skin, because on any other page in this section that would be correct and
//  helpful. The defect only exists in context, so a reviewer reading the diff
//  will not see it. A test will.
//
//  ⚠️ AND THE SECOND ONE IS THE ICP ROUTE. It was built as a callback seam
//  with a comment saying no destination existed yet. One does now, and nothing
//  joined them, so the page went on offering a bottom sheet instead of the
//  explainer. Nothing failed; she just never reached the page written for her.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/belly_skin_data.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/screens/belly_skin/bs_itching_screen.dart';
import 'package:parentveda/screens/conditions/condition_detail_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
      now: now, dueDate: now.add(Duration(days: (40 - week) * 7)));
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 4200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  //  1 · No commerce. At all.
  // ===========================================================================

  group('this page sells nothing', () {
    test('no product word survives in the itching copy', () {
      // ⚠️ THE SOFT NUDGE IS THE ONE THAT SLIPS THROUGH. There was no product
      // CARD on this page and there never had been - what was here was a
      // bullet reading "a fragrance-free moisturiser or the belly oil ritual",
      // and the ritual is a purchasable surface. A recommendation does not
      // stop being commerce because it is phrased as advice.
      final copy = [
        kBsItchingIntro.en,
        kBsItchingWarningTitle.en,
        kBsItchingWarningBody.en,
        kBsItchingWarningNote.en,
        kBsItchingWarningCta.en,
        for (final b in [...kBsItchingHarmless, ...kBsItchingSoothe]) ...[
          b.heading?.en ?? '',
          ...b.paragraphs.map((x) => x.en),
          ...b.bullets.map((x) => x.en),
        ],
      ].join(' ').toLowerCase();

      for (final w in ['belly oil', 'ritual', 'shop', 'buy', 'brand', '₹']) {
        expect(copy.contains(w), isFalse, reason: 'found "$w"');
      }
    });

    testWidgets('no price, no product card, no shopping affordance renders',
        (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, BsItchingScreen(pregnancy: c));

      expect(
          find.byWidgetPredicate((w) =>
              w is Text && (w.data ?? '').contains('₹')),
          findsNothing);
      for (final label in ['Shop', 'Buy', 'Add to cart', 'Recommended']) {
        expect(find.text(label), findsNothing, reason: label);
      }
    });

    test('a plain moisturiser is still allowed to be mentioned', () {
      // ⚠️ THE LINE IS COMMERCE, NOT SKINCARE. "Use a fragrance-free
      // moisturiser" is medical advice every source gives; it names no product
      // and points at no purchase. Banning the word would make the page
      // useless in the name of a rule about something else.
      final soothe = kBsItchingSoothe
          .expand((b) => b.bullets)
          .map((x) => x.en.toLowerCase())
          .join(' ');
      expect(soothe.contains('moisturiser'), isTrue);
    });
  });

  // ===========================================================================
  //  2 · The shape review asked for
  // ===========================================================================

  group('the page reads in the order a clinician would explain it', () {
    testWidgets('harmless, then soothe, then the warning', (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, BsItchingScreen(pregnancy: c));

      final harmless = t.getTopLeft(find.text('Usually harmless')).dy;
      final soothe = t.getTopLeft(find.text('How to soothe it')).dy;
      final warning =
          t.getTopLeft(find.text(kBsItchingWarningTitle.en)).dy;

      expect(harmless, lessThan(soothe));
      expect(soothe, lessThan(warning));
    });

    testWidgets('the intro no longer contradicts the layout', (t) async {
      // ⚠️ THE BUG THAT PROVED THE ORDER. `kBsItchingIntro` says the warning
      // is "further down this page" while the card used to render above the
      // tips. The copy was written for this order; only the layout had
      // drifted, and nothing could see the mismatch because both halves were
      // individually correct.
      expect(kBsItchingIntro.en.toLowerCase(), contains('further down'));

      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, BsItchingScreen(pregnancy: c));

      final intro = t.getTopLeft(find.text(kBsItchingIntro.en)).dy;
      final warning = t.getTopLeft(find.text(kBsItchingWarningTitle.en)).dy;
      expect(intro, lessThan(warning));
    });

    test('the warning names palms and soles, and names ICP', () {
      // The two facts that make this page worth having. A version that said
      // only "see your doctor if itching is severe" would be useless: the
      // distinguishing sign IS the location, and the word is what lets her
      // ask for the right blood test.
      final body = kBsItchingWarningBody.en.toLowerCase();
      expect(body, contains('palms'));
      expect(body, contains('soles'));
      expect(body, contains('cholestasis'));
      expect(body, contains('icp'));
    });
  });

  // ===========================================================================
  //  3 · Two ways out, and both go somewhere
  // ===========================================================================

  group('the warning offers a doctor AND an explanation', () {
    test('the ICP page it points at actually exists', () {
      // ⚠️ THE ID IS THE JOIN, and an id typed into two files is how a route
      // dies silently. If the Complications library ever renames this entry,
      // this test fails here rather than the page failing on her phone.
      expect(kAllConditions.any((c) => c.id == 'icp_cholestasis'), isTrue);
    });

    testWidgets('Learn about ICP opens the ICP page', (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, BsItchingScreen(pregnancy: c));

      await t.scrollUntilVisible(find.text('Learn about ICP'), 500,
          scrollable: find.byType(Scrollable).first);
      await t.tap(find.text('Learn about ICP'));
      await t.pumpAndSettle();

      expect(find.byType(ConditionDetailScreen), findsOneWidget);
    });

    testWidgets('the doctor action is still there and still first', (t) async {
      final c = _at(30);
      addTearDown(c.dispose);
      await _pump(t, BsItchingScreen(pregnancy: c));

      await t.scrollUntilVisible(find.text('Learn about ICP'), 500,
          scrollable: find.byType(Scrollable).first);

      final doctor = t.getTopLeft(find.text(kBsItchingWarningCta.en)).dy;
      final icp = t.getTopLeft(find.text('Learn about ICP')).dy;
      // Both matter; only one of them is time-sensitive.
      expect(doctor, lessThan(icp));
    });

    testWidgets('with no controller it degrades to the doctor sheet, not a '
        'dead tap', (t) async {
      // ⚠️ A DEAD TAP IS WORSE HERE THAN ANYWHERE ELSE IN THE APP. She has
      // just read that her symptom might be a real complication.
      await _pump(t, const BsItchingScreen());

      await t.scrollUntilVisible(find.text('Learn about ICP'), 500,
          scrollable: find.byType(Scrollable).first);
      await t.tap(find.text('Learn about ICP'));
      await t.pumpAndSettle();

      expect(find.text('Call your doctor today'), findsOneWidget);
      expect(find.byType(ConditionDetailScreen), findsNothing);
    });
  });
}
