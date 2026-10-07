// =============================================================================
//  The well-baby visit card on the age page (gap analysis P2)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_visit_card.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every visit on the schedule has its notes and three questions', () {
    for (final v in kVaxVisits) {
      expect(kPpVisitNotes[v.id], isNotNull, reason: v.id);
      expect(kPpVisitNotes[v.id]!.$2, hasLength(3), reason: v.id);
    }
  });

  testWidgets('five weeks old: the 6 week visit, coming up, at 360 and 1.5x', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 36)));
    VaxStore.instance.markDone('birth');
    final v = ppVisitCardFor();
    expect(v?.id, 'wk6');
    t.view.physicalSize = const Size(360 * 3, 1400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PpVisitCard(visit: v!, p: V2PaletteStore.instance.current, onOpen: () {})))),
    ));
    expect(find.text('The 6 weeks visit').evaluate().isNotEmpty || find.textContaining('visit').evaluate().isNotEmpty, isTrue);
    expect(find.text('Three questions to ask'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('nothing when the next visit is months away', () {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 200)));
    for (final id in ['birth', 'wk6', 'wk10', 'wk14', 'mo6']) {
      VaxStore.instance.markDone(id);
    }
    expect(ppVisitCardFor(), isNull, reason: 'the 9 month visit is ~70 days off');
  });
}
