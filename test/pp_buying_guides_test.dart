// =============================================================================
//  What to buy › How to choose: guides, not lists (gap analysis P3)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/data/reads/pp_buying_guides.dart';
import 'package:parentveda/screens/post_pregnancy/pp_buying_guides_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('six guides: car seat, cot, pram, carrier, high chair, first shoes', () {
    expect(kPpBuyingGuides.map((r) => r.title.en), [
      'Choosing a car seat',
      'Choosing a cot and mattress',
      'Choosing a pram or stroller',
      'Choosing a baby carrier',
      'Choosing a high chair',
      'Choosing first shoes',
    ]);
  });

  test('what matters, what to skip, and no brand or ranking words', () {
    // Ranking words only: "best" as a plain adverb ("protects the neck best")
    // is fine; "the best car seat" is a list.
    final banned = RegExp(r'\b(the best|best buy|top \d|top pick|number one|brand)\b', caseSensitive: false);
    for (final r in kPpBuyingGuides) {
      final heads = r.sections.map((s) => s.heading?.en).toList();
      expect(heads, containsAll(['What matters', 'What you can skip']), reason: r.id);
      final text = [
        r.title.en,
        r.teaser.en,
        for (final s in r.sections) ...[for (final b in s.bullets) b.en, for (final p in s.paragraphs) p.en],
      ].join(' ');
      expect(banned.hasMatch(text), isFalse, reason: r.id);
      expect(r.reviewed, isFalse, reason: 'no reviewer is claimed');
    }
  });

  test('inside What to buy', () {
    expect(kPpBuying.needs.any((n) => n.surfaceId == 'pp_buying_guides'), isTrue);
    expect(ppScreenForSurface('pp_buying_guides'), isA<PpBuyingGuidesScreen>());
  });

  testWidgets('a guide opens in the one reader; 360 at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: PpBuyingGuidesScreen())));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.tap(find.byKey(ValueKey('pp_buy_row_${ppBuyingGuideId('car_seat')}')));
    await t.pumpAndSettle();
    expect(find.byType(PvReaderScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
