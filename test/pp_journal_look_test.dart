// =============================================================================
//  The parenting journal as the pregnancy journal's keepsake (2026-10-17)
// -----------------------------------------------------------------------------
//  Was (2026-10-07): the journal on the shared tool shell, no floating button.
//  Now it is the same book as the pregnancy journal: paper, the shared cover
//  and question card, and the pregnancy journal's "Add a memory" that floats
//  in once the question card has scrolled away.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';
import 'package:parentveda/widgets/journal/journal_keepsake.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('the keepsake: paper, cover, question, add button, no overflow at 360dp ${scale}x', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const MaterialApp(home: PpJournalScreen())));
      await t.pumpAndSettle();
      expect(find.byType(JournalCover), findsOneWidget);
      expect(find.byType(JournalDotStrip), findsOneWidget);
      expect(find.byType(JournalQuestionCard), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_journal_add')), findsOneWidget);
      final scaffold = t.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, kJournalPaper);
      expect(t.takeException(), isNull);
    });
  }
}
