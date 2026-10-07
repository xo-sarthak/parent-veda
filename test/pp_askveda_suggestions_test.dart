// =============================================================================
//  Ask Veda suggestions for the child's age, with the right pronoun (gap P2)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_faqs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a girl of ten months: this age first, never "he"', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 310)));
    ChildProfileStore.instance.active
      ..isBoy = false
      ..sexGiven = true;
    t.view.physicalSize = const Size(360 * 3, 3000 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: AskVedaScreen()));
    await t.pumpAndSettle();
    expect(find.text('For this age'), findsOneWidget);
    final first = phaseFaqs(currentPhase().number, count: 1).first.question;
    expect(find.text(ppFillChild(first)), findsWidgets);
    expect(find.textContaining(RegExp(r'\b(he|him|his)\b')), findsNothing);
    expect(find.textContaining('4 months'), findsNothing);
    expect(t.takeException(), isNull);
  });
}
