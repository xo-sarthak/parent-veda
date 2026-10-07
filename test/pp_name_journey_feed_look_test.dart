// =============================================================================
//  The baby-name journey (quiz, primer, swipe deck) in the one ParentVeda look
//  (2026-10-07)
// -----------------------------------------------------------------------------
//  NameJourneyFeedScreen's quiz and primer moved onto PregToolScaffold; the
//  swipe deck kept its gesture and moved onto the white ground with ink
//  buttons. The primer's round back returns to the quiz, not out of the
//  journey; nothing overflows at 360dp and 1.5x text in any phase.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/name_journey_feed_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: quiz -> primer -> back -> primer -> deck, no overflow', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const NameJourneyFeedScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.text('Just show me names'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.ensureVisible(find.text('Start discovering'));
      await t.tap(find.text('Start discovering'));
      await t.pumpAndSettle();
      expect(find.text('Discover names one by one'), findsOneWidget);
      expect(t.takeException(), isNull);

      // The round back returns to the quiz, as the old "Back" did.
      await t.tap(find.byKey(const ValueKey('preg_tool_back')));
      await t.pumpAndSettle();
      expect(find.text('Start discovering'), findsOneWidget);

      await t.ensureVisible(find.text('Start discovering'));
      await t.tap(find.text('Start discovering'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text("Let's begin"));
      await t.tap(find.text("Let's begin"));
      await t.pumpAndSettle();
      expect(find.text('Tap for the full story'), findsOneWidget);
      expect(find.text('We like this'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.tap(find.text('Not for us'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
