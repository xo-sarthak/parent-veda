// =============================================================================
//  The Sanskar page's intro sits as one calm block under its title
// -----------------------------------------------------------------------------
//  The user on build 17 (2026-09-28), of "Picked for your fertile days. Tap a
//  part to open its practice.": "the positioning and the font, it's not placed
//  well." The page had a hero intro AND a second grey line jammed against the
//  sheet's top edge, with a paler tap hint under it in a third style. Now the
//  chapter's reason and the time it takes are one paragraph in the hero's
//  intro slot, and the tap hint is gone (every part is a card with a chevron).
//
//  These hold it, in every chapter, on her own cycle and on a treatment round,
//  at 360dp and at 1.5x text: one Text, in the intro style, on the title's
//  gutter, clear of the first card, with no overflow and no "tap" fragment.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_cue_sounds.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_mind_today.dart' show ttcSanskarItems;
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double scale = 1.0}) async {
  tester.view.physicalSize = const Size(360, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: c!,
    ),
    home: child,
  ));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcCueSounds.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  test('the intro names the part of her month, then the time it takes', () {
    expect(ttcRitualIntro(TtcChapter.tryingTogether),
        'Picked for your fertile days. Each part takes about a minute, and '
        'doing any one part is enough for today.');
  });

  test('a treatment round never hears "fertile days" from us', () {
    for (final c in TtcChapter.values) {
      final line = ttcRitualIntro(c, clinicOwned: true);
      expect(line.contains('fertile'), isFalse, reason: c.name);
    }
    expect(ttcRitualIntro(TtcChapter.tryingTogether, clinicOwned: true),
        startsWith('Picked for this stage of your treatment round.'));
    expect(ttcRitualIntro(TtcChapter.theWaitingDays, clinicOwned: true),
        startsWith("Picked for the wait before your clinic's test."));
  });

  test('no intro leans on "it", "this one" or "here"', () {
    for (final clinic in [false, true]) {
      for (final c in TtcChapter.values) {
        final line = ttcRitualIntro(c, clinicOwned: clinic);
        expect(RegExp(r'\b(it|here)\b').hasMatch(line), isFalse,
            reason: line);
      }
    }
  });

  for (final scale in [1.0, 1.5]) {
    for (final clinic in [false, true]) {
      for (final c in TtcChapter.values) {
        testWidgets(
            'x$scale, ${clinic ? 'treatment round' : 'her cycle'}, ${c.name}: '
            'one intro block, set right', (tester) async {
          await _pump(
              tester, TtcRitualScreen(chapter: c, clinicOwned: clinic),
              scale: scale);
          expect(tester.takeException(), isNull, reason: 'no overflow');

          final line = ttcRitualIntro(c, clinicOwned: clinic);
          final intro = find.text(line);
          expect(intro, findsOneWidget,
              reason: 'the reason and the time are ONE Text');

          // The chrome's intro style: Manrope body, 13.5 on 1.6, ink1 since
          // 2026-09-29 (ink2 measured under 4.5:1 on the hero field; see
          // test/ttc_palette_consistency_test.dart). Kept for revert:
          //   expect(style.color, V2PaletteStore.instance.current.ink2);
          final style = tester.widget<Text>(intro).style!;
          expect(style.fontSize, 13.5);
          expect(style.height, 1.6);
          expect(style.color, V2PaletteStore.instance.current.ink1);

          // On the title's gutter, under it.
          final title = find.text('Five small things for today');
          expect(tester.getTopLeft(intro).dx, tester.getTopLeft(title).dx);
          expect(tester.getTopLeft(intro).dy,
              greaterThan(tester.getBottomLeft(title).dy));

          // Clear of the sheet: the first part's card starts well below the
          // intro (the hero's 18 foot and the sheet's 22 top).
          final first = ttcSanskarItems(c).first.part.title(false);
          expect(
              tester.getTopLeft(find.text(first).first).dy -
                  tester.getBottomLeft(intro).dy,
              greaterThanOrEqualTo(40));

          // No second chapter line and no tap hint left on the sheet.
          expect(find.textContaining('Tap a part'), findsNothing);
          expect(find.textContaining('Picked for'), findsOneWidget);
        });
      }
    }
  }

  testWidgets('with a part done, the done line sits between intro and cards',
      (tester) async {
    final items = ttcSanskarItems(TtcChapter.tryingTogether);
    TtcRitualStore.instance.toggle(items.first.part);
    await _pump(
        tester,
        const TtcRitualScreen(
            chapter: TtcChapter.tryingTogether, clinicOwned: false));
    expect(tester.takeException(), isNull);
    final done = find.textContaining('Done today:');
    expect(done, findsOneWidget);
    final intro = find.text(ttcRitualIntro(TtcChapter.tryingTogether));
    expect(tester.getTopLeft(done).dy,
        greaterThan(tester.getBottomLeft(intro).dy));
  });
}
