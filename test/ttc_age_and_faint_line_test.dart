// =============================================================================
//  Age asked once, and the faint line drawn (2026-09-26, TTC gap analysis)
// -----------------------------------------------------------------------------
//  What this holds:
//
//    · the age chips in "Trying after 35" write the fertility-help tool's own
//      saved answer, not a second one, so the six-month rule and the tool see
//      it at once;
//    · a band she already gave is shown instead of the question;
//    · the IVF & IUI door puts "Age and second baby" second for 35 and over,
//      keeps its own order otherwise, never moves the first tab and never
//      loses one;
//    · the faint-line drawing lays out at 360dp;
//    · both reads still pass their shape rules;
//    · the WIRING GATE: both TTC reader openers pass the renderer, and the
//      router-built reader really draws the question.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/ttc_read_blocks_view.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_read_blocks.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = _NoNet());

  final store = TtcFertilityHelpStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.load();
    await store.reset();
  });

  Future<void> pump(WidgetTester tester, Widget child,
      {double width = 360}) async {
    tester.view.physicalSize = Size(width, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Widget inReaderColumn(Widget block) => Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [block],
        ),
      );

  // ---------------------------------------------------------------------------
  group('age, asked once', () {
    testWidgets('a chip saves to the fertility-help store, same key',
        (tester) async {
      await pump(tester, inReaderColumn(const TtcAgeBandAsk()));
      expect(find.text('How old are you?'), findsOneWidget);
      expect(
          find.text('So we can tell you the right time to ask for a check. '
              'Nothing else uses it.'),
          findsOneWidget);
      for (final b in FertilityAgeBand.values) {
        expect(find.byKey(ttcAgeBandChipKey(b)), findsOneWidget);
      }

      await tester.tap(
          find.byKey(ttcAgeBandChipKey(FertilityAgeBand.thirtyFiveTo37)));
      await tester.pump(const Duration(milliseconds: 300));

      expect(store.ageBand, FertilityAgeBand.thirtyFiveTo37);
      expect(store.answerFor('age'), 'thirtyFiveTo37');
      expect(store.context.ageBand, FertilityAgeBand.thirtyFiveTo37);
      // The tool will not ask it again.
      expect(store.missingQuestionIds, isNot(contains('age')));
      // One key, the tool's own.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('ttc_fhelp_answers'),
          contains('age:thirtyFiveTo37'));
      expect(prefs.getKeys().where((k) => k.contains('age')), isEmpty,
          reason: 'age must not gain a storage key of its own');

      // Answered: the quiet line, not the question.
      expect(find.byKey(kTtcAgeBandSavedKey), findsOneWidget);
      expect(find.text('How old are you?'), findsNothing);
    });

    testWidgets('a band given in the tool is shown, not asked again',
        (tester) async {
      await store.answer('age', FertilityAgeBand.over40.name);
      await pump(tester, inReaderColumn(const TtcAgeBandAsk()));

      expect(find.text('How old are you?'), findsNothing);
      expect(find.byKey(kTtcAgeBandSavedKey), findsOneWidget);
      expect(find.textContaining("You told us you're over 40."), findsOneWidget);

      // And it can be changed, with the saved band shown as chosen.
      await tester.tap(find.byKey(kTtcAgeBandChangeKey));
      await tester.pump();
      expect(find.text('How old are you?'), findsOneWidget);
      await tester
          .tap(find.byKey(ttcAgeBandChipKey(FertilityAgeBand.under35)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(store.ageBand, FertilityAgeBand.under35);
      expect(find.byKey(kTtcAgeBandSavedKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('the read carries the question at the top', () {
      final read = ttcReadById('ttc_read_age_after_35')!;
      expect(read.sections.first.custom, isA<TtcAgeBandAskBlock>());
    });

    testWidgets('the router-built reader draws it (wiring gate)',
        (tester) async {
      final screen = ttcScreenForSurface('ttc_read/ttc_read_age_after_35');
      expect(screen, isNotNull);
      await pump(tester, screen!);
      await tester.scrollUntilVisible(find.byType(TtcAgeBandAsk), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.byType(TtcAgeBandAsk), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('both TTC openers pass the renderer', () {
      for (final path in [
        'lib/screens/ttc/ttc_surface_router.dart',
        'lib/screens/ttc/ttc_focus_screen.dart',
      ]) {
        expect(File(path).readAsStringSync(),
            contains('customBlock: ttcReadCustomBlock'),
            reason: '$path opens TTC reads without drawing their blocks');
      }
    });
  });

  // ---------------------------------------------------------------------------
  group('the IVF door puts the age tab higher for 35 and over', () {
    final groups = kTtcIvfFocus.groups!;
    List<String> ids(List<TtcFocusGroup> g) => [for (final x in g) x.id];

    test('the door is the bracket the function reads', () {
      expect(kTtcIvfFocus.bracketId, kTtcIvfBracketId);
      expect(ids(groups), contains(kTtcAgeGroupId));
      expect(ids(groups).indexOf(kTtcAgeGroupId), isNot(1),
          reason: 'the test only proves something if age is not already '
              'second by default');
    });

    test('35 and over: age second, first tab unmoved, nothing lost', () {
      for (final band in FertilityAgeBand.values
          .where((b) => b != FertilityAgeBand.under35)) {
        final out = ttcDoorOrderedGroups(groups,
            bracketId: kTtcIvfBracketId, ageBand: band);
        expect(out[1].id, kTtcAgeGroupId, reason: band.name);
        expect(out.first.id, groups.first.id);
        expect(out.length, groups.length);
        expect(ids(out).toSet(), ids(groups).toSet());
        // The others keep their order among themselves.
        expect(ids(out).where((i) => i != kTtcAgeGroupId).toList(),
            ids(groups).where((i) => i != kTtcAgeGroupId).toList());
      }
    });

    test('under 35 or not told: the default order, untouched', () {
      for (final band in [null, FertilityAgeBand.under35]) {
        expect(
            ttcDoorOrderedGroups(groups,
                bracketId: kTtcIvfBracketId, ageBand: band),
            same(groups));
      }
    });

    test('no other door moves', () {
      final pages = [
        for (final id in [
          'ttc_pcos',
          'ttc_conceiving',
          'ttc_not_yet',
          'ttc_after_loss',
        ])
          ?ttcFocusPageFor(id),
      ];
      expect(pages, isNotEmpty);
      for (final page in pages) {
        final g = page.groups;
        if (g == null) continue;
        expect(
            ttcDoorOrderedGroups(g,
                bracketId: page.bracketId, ageBand: FertilityAgeBand.over40),
            same(g));
      }
    });

    test('the door screen uses it and listens to the store', () {
      final src =
          File('lib/screens/ttc/doors/ttc_door_screen.dart').readAsStringSync();
      expect(src, contains('ttcDoorOrderedGroups('));
      expect(src, contains('TtcFertilityHelpStore.instance,'));
    });
  });

  // ---------------------------------------------------------------------------
  group('the faint line, drawn', () {
    for (final width in [360.0, 320.0]) {
      testWidgets('lays out at ${width.toInt()}dp without overflow',
          (tester) async {
        await pump(tester, inReaderColumn(const TtcFaintLineDrawing()),
            width: width);
        expect(tester.takeException(), isNull);
        for (final d in kTtcFaintLineDays) {
          expect(find.text(d.label), findsOneWidget);
        }
        expect(find.text(kTtcFaintLineCaption), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      });
    }

    test('four windows, faint to clear', () {
      expect([for (final d in kTtcFaintLineDays) d.label],
          ['Day due', '+2 days', '+4 days', '+6 days']);
      for (var i = 1; i < kTtcFaintLineDays.length; i++) {
        expect(kTtcFaintLineDays[i].strength,
            greaterThan(kTtcFaintLineDays[i - 1].strength));
      }
      expect(kTtcFaintLineCaption,
          'A faint line that shows up within the reading time usually gets '
          'clearer over a few days.');
    });

    test('the read carries it', () {
      final read = ttcReadById('ttc_read_faint_line')!;
      expect(read.sections.where((s) => s.custom is TtcFaintLineDrawingBlock),
          hasLength(1));
    });

    testWidgets('the router-built reader draws it (wiring gate)',
        (tester) async {
      await pump(tester, ttcScreenForSurface('ttc_read/ttc_read_faint_line')!);
      await tester.scrollUntilVisible(find.byType(TtcFaintLineDrawing), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.byType(TtcFaintLineDrawing), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  test('both reads still pass their shape rules', () {
    for (final id in ['ttc_read_age_after_35', 'ttc_read_faint_line']) {
      final read = ttcReadById(id)!;
      expect(read.assertShape(), isEmpty, reason: id);
      expect(read.wordCount, greaterThanOrEqualTo(600), reason: id);
    }
  });
}
