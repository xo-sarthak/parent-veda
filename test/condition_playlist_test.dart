// A condition's video series is a playlist, and no condition page shows a
// "coming soon" read (user, 2026-10-12).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/widgets/pv_placeholders.dart';

void main() {
  test('every series has one title per part, and every series has titles', () {
    for (final c in kAllConditions) {
      if (c.watchEpisodes > 1) {
        expect(c.watchEpisodeTitles.length, c.watchEpisodes, reason: c.id);
      } else {
        expect(c.watchEpisodeTitles, isEmpty, reason: c.id);
      }
    }
  });

  testWidgets('the playlist draws every part and marks the first',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PvSeriesList(episodes: const [
          ('One', 'First line.'),
          ('Two', 'Second line.'),
          ('Three', 'Third line.'),
        ]),
      ),
    ));
    expect(find.text('IN THIS SERIES'), findsOneWidget);
    expect(find.text('PART 1  ·  SHOWN ABOVE'), findsOneWidget);
    expect(find.text('PART 3'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });

  test('the condition page no longer draws the read placeholders', () {
    final src = File('lib/screens/conditions/condition_detail_screen.dart')
        .readAsStringSync();
    final live = src
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(live.contains('if (entry.showReadMore)'), isFalse);
    expect(live.contains('PvSeriesList(episodes: parts)'), isTrue);
  });

  test('a journey leaves owed reads out instead of showing them as soon', () {
    final src =
        File('lib/screens/brackets/hub/journey_screen.dart').readAsStringSync();
    expect(src.contains('e.type == SolutionType.read && !e.owed'), isTrue);
  });
}
