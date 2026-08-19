// =============================================================================
//  Garbh Sanskar browse lists, the Symptoms strip, and one card title
// -----------------------------------------------------------------------------
//  Three unrelated review items, and one thread running through two of them:
//  a screen that hands her exactly one thing implies the app HAS exactly one
//  thing. The daily pillar pages give her today's raga and no way to see the
//  other nine; "Try it now" names nothing, so the card only reads correctly in
//  the one position it was written for.
//
//  ⚠️ THE BROWSE TESTS ASSERT REACHABILITY, NOT LAYOUT. `GarbhBrowseScreen` is
//  one screen behind four configurations, so the thing that can silently break
//  is a pillar losing its link — the screen would still exist, still be
//  correct, and simply have no door. That is the wiring gate, and it is why
//  every pillar is checked rather than one being taken as proof of the rest.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/journeys/pregnancy_journeys.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/garbh_content.dart';
import 'package:parentveda/screens/garbh_browse_screen.dart';
import 'package:parentveda/screens/tools/symptom_companion_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 9000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  const en = AppLanguage.english;
  const accent = Color(0xFFBE9C4E);

  // ===========================================================================
  //  1 · Every pillar can show everything it has
  // ===========================================================================

  group('the browse list holds no content of its own', () {
    testWidgets('Shravan lists every raga, grouped by kind', (t) async {
      await _pump(t, shravanBrowse(en, accent));

      // ⚠️ EVERY ONE, read from `kShravan` at call time. A second copy here
      // would go on saying "7 min" after the audio was re-cut, and nothing
      // would fail.
      for (final a in kShravan) {
        expect(find.text(a.title.en), findsOneWidget, reason: a.id);
      }
      // The kinds are genuinely different wants — rain sounds and a guided
      // body scan are not the same choice.
      expect(find.text('RAGAS'), findsOneWidget);
      expect(find.text('NATURE SOUNDS'), findsOneWidget);
      expect(find.text('GUIDED'), findsOneWidget);
    });

    testWidgets('the minutes are shown, because "how long" is question two',
        (t) async {
      await _pump(t, shravanBrowse(en, accent));
      final first = kShravan.first;
      expect(find.text('${first.minutes} min'), findsWidgets);
    });

    testWidgets('Vichara lists every reflection and invents no categories',
        (t) async {
      await _pump(t, vicharaBrowse(en, accent));
      for (final s in kVichara) {
        expect(find.text(s.title.en), findsOneWidget, reason: s.id);
      }
      // ⚠️ NO GROUP HEADINGS. Eight reflections do not need a taxonomy, and
      // inventing one to look organised is how a calm screen becomes a filing
      // system.
      expect(find.text('RAGAS'), findsNothing);
    });

    testWidgets('Kriya lists every practice', (t) async {
      await _pump(t, kriyaBrowse(en, accent));
      for (final k in kKriya) {
        expect(find.text(k.title.en), findsOneWidget, reason: k.id);
      }
    });

    testWidgets('Samvad shows all three trimesters, not only hers', (t) async {
      await _pump(t, samvadBrowse(en, accent));

      expect(find.text('FIRST TRIMESTER'), findsOneWidget);
      expect(find.text('SECOND TRIMESTER'), findsOneWidget);
      expect(find.text('THIRD TRIMESTER'), findsOneWidget);

      // ⚠️ DELIBERATELY UNFILTERED. This is the browse screen; the daily view
      // is where personalisation belongs. Someone at 12 weeks reading what she
      // will say at 30 is the point of a list like this.
      expect(find.text(kSamvadT1.first.text.en), findsOneWidget);
      expect(find.text(kSamvadT3.first.text.en), findsOneWidget);
    });

    testWidgets('every list ends by saying it is not a list to finish',
        (t) async {
      // ⚠️ NOT DECORATION. A list of everything available is exactly where a
      // practice starts to feel like a backlog, and this pillar's whole value
      // is that it does not.
      for (final s in [
        shravanBrowse(en, accent),
        vicharaBrowse(en, accent),
        samvadBrowse(en, accent),
        kriyaBrowse(en, accent),
      ]) {
        await _pump(t, s);
        // ⚠️ SCROLLED TO, NOT ASSUMED VISIBLE. Samvad is ~48 prompts of full
        // sentences and runs well past any viewport a test can set, so a plain
        // `find` here would pass on three lists and fail on the long one — for
        // a reason that has nothing to do with the copy being present.
        await t.scrollUntilVisible(
          find.textContaining('a list to finish'),
          600,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('a list to finish'), findsOneWidget);
      }
    });

    testWidgets('no ticks, no progress, no streaks anywhere', (t) async {
      // Garbh Sanskar's tone depends on this being a menu she is browsing
      // rather than a syllabus she is behind on.
      for (final s in [
        shravanBrowse(en, accent),
        vicharaBrowse(en, accent),
        kriyaBrowse(en, accent),
      ]) {
        await _pump(t, s);
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(
            find.byWidgetPredicate((w) =>
                w is Text &&
                (w.data ?? '').toLowerCase().contains('streak')),
            findsNothing);
      }
    });

    test('the four configurations read live data, not copies', () {
      // If any of these ever stops matching, someone has pasted a list into
      // the browse screen — which is the exact drift this screen exists to
      // avoid.
      expect(kShravan.where((a) => a.kind == GarbhKind.raga), isNotEmpty);
      expect(kVichara, isNotEmpty);
      expect(kKriya, isNotEmpty);
      expect(kSamvadT1, isNotEmpty);
      expect(kSamvadT2, isNotEmpty);
      expect(kSamvadT3, isNotEmpty);
    });
  });

  // ===========================================================================
  //  2 · Symptoms no longer asks about her diagnoses
  // ===========================================================================

  group('the Symptoms screen asks nothing before it helps', () {
    testWidgets('the "has your doctor mentioned" strip is gone', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, SymptomCompanionScreen(controller: c));

      // ⚠️ SHE OPENED THIS BECAUSE SOMETHING HURTS. The strip put a question
      // about her medical history between her and the one about right now.
      expect(find.textContaining('Has your doctor mentioned'), findsNothing);
      expect(find.text('Not now'), findsNothing);
    });

    testWidgets('the screen itself still works', (t) async {
      final c = PregnancyController();
      addTearDown(c.dispose);
      await _pump(t, SymptomCompanionScreen(controller: c));
      expect(t.takeException(), isNull);
    });
  });

  // ===========================================================================
  //  3 · A card that names its tool
  // ===========================================================================

  group('the contraction-timer card names the tool', () {
    test('"Try it now" is gone', () {
      final step = kPgBirthPrep.steps
          .expand((s) => s.elements)
          .where((e) => e.surfaceId == 'contractions')
          .toList();
      expect(step, isNotEmpty, reason: 'the timer card still exists');

      // ⚠️ A TITLE THAT ONLY READS CORRECTLY IN ITS ORIGINAL POSITION is a
      // title that will eventually be wrong — search, a saved list and a
      // notification all surface a card away from the thing "it" referred to.
      for (final e in step) {
        expect(e.title.en, isNot('Try it now'));
        expect(e.title.en.toLowerCase(), contains('contraction timer'));
      }
    });
  });
}
