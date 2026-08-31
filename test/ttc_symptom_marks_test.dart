// =============================================================================
//  Every symptom has a drawn mark
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE WIRING GATE APPLIED TO ARTWORK, and it exists because the
//  failure it catches is invisible. `TtcSymptomMark` falls back to a Material
//  icon when a symptom has neither a mood face nor a drawn glyph — which is
//  correct behaviour for a half-finished symptom and catastrophic as a resting
//  state, because the fallback RENDERS. Nothing crashes, nothing logs, and a
//  chip quietly drawn in a different visual language sits in a card for months
//  until someone happens to look at that group.
//
//  A mixed set does not read as "some of these are custom". It reads as
//  unfinished, which is exactly what it is.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/ttc_mood_face.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_mark.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';

void main() {
  final all = [
    for (final g in kTtcSymptomGroups) ...g.symptoms,
  ];

  test('every symptom resolves to a face or a glyph, never to the fallback',
      () {
    final bare = [
      for (final s in all)
        if (ttcMoodFor(s.id) == null && ttcGlyphFor(s.id) == null) s.id,
    ];
    expect(bare, isEmpty,
        reason: 'these would fall back to a Material icon and look like a '
            'different app inside their own card: $bare');
  });

  test('the eight feelings are the only ones drawn as faces', () {
    // ⚠️ A FACE IS A CLAIM ABOUT AN EXPRESSION, so it belongs only where the
    // subject is genuinely how she felt. A smiling face on "cramping" would be
    // the app editorialising about a symptom.
    final faces = [for (final s in all) if (ttcMoodFor(s.id) != null) s.id];
    expect(faces.length, 8);
    final feelings =
        kTtcSymptomGroups.firstWhere((g) => g.id == kTtcFeelingGroup);
    expect(faces.toSet(), feelings.symptoms.map((s) => s.id).toSet());
  });

  test('a glyph shared between two symptoms is shared deliberately', () {
    // ⚠️ TWO SYMPTOMS DRAWN THE SAME ARE INDISTINGUISHABLE ON A CHIP, so the
    // only acceptable sharing is between symptoms that never appear together.
    // The test stick is the sole case: ovulation and pregnancy tests are the
    // same object read the same way, and they live in separate cards whose
    // headings say which test it is.
    final byGlyph = <TtcGlyph, List<String>>{};
    for (final s in all) {
      final g = ttcGlyphFor(s.id);
      if (g != null) byGlyph.putIfAbsent(g, () => []).add(s.id);
    }
    final shared = byGlyph.entries.where((e) => e.value.length > 1);
    for (final e in shared) {
      final prefixes = e.value.map((id) => id.split('_').first).toSet();
      expect(prefixes, {'ov', 'pt'},
          reason: 'two symptoms in reach of each other draw the same mark: '
              '${e.value}');
    }
  });

  testWidgets('every mark paints without throwing, at both sizes used',
      (tester) async {
    // 12pt on the home day strip, 30pt on the logger's mood bubbles. A painter
    // whose geometry only holds at one size is a bug that ships.
    for (final size in [12.0, 30.0]) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Wrap(children: [
            for (final s in all)
              TtcSymptomMark(symptom: s, size: size, ink: Colors.black),
          ]),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'threw at ${size}pt');
    }
  });
}
