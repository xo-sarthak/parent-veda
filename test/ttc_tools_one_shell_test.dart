// =============================================================================
//  One shell, one name, for every Tools tile (2026-09-27)
// -----------------------------------------------------------------------------
//  "ParentVeda is one app... we cannot be having same things represented as
//  different." Eight tiles in the Tools hub still opened a plain page under a
//  back bar or a door crumb while their neighbours opened `TtcToolScaffold`
//  (hero field, serif title, white sheet). This pins them onto the shared
//  shell, and pins the naming rule for every tool shell: the hero's small
//  eyebrow IS the Tools tile's name, word for word. Each screen is also laid
//  out at a 360dp phone width in both languages so nothing overflows.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_bmi_screen.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart' show TtcBackBar;
import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journey_map_screen.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_pcos_stand_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_screen.dart';
import 'package:parentveda/screens/ttc/ttc_precheck_summary.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_vaccines_screen.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';

Future<void> _pumpPhone(WidgetTester tester, Widget child,
    {double height = 800}) async {
  // A 360dp-wide phone, the narrowest the app is walked on.
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcSupplementsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });
  tearDown(() => TtcLang.instance.hinglish = false);

  // The screens moved onto the shell today, each with its Tools tile's name
  // (`nameEn` in ttc_tools_screen.dart).
  final moved = <(String, Widget)>[
    ('Supplements', const TtcSupplementsScreen()),
    ('Medical tests', const TtcTestsScreen()),
    ('Vaccinations', const TtcVaccinesScreen()),
    ('Can I...?', const TtcCanIScreen()),
    ("This week's food ideas", const TtcNutritionScreen()),
    ('Journey map', const TtcJourneyMapScreen()),
    // T1/T2 (2026-09-28): BMI folded into Weight, so its eyebrow is
    // Weight's. Kept for revert: ('Weight and fertility', const TtcBmiScreen()),
    ('Weight', const TtcBmiScreen()),
    ('Pre-pregnancy checklist', const TtcPrecheckScreen()),
    ('Pre-pregnancy checklist', const TtcPrecheckSummaryScreen()),
  ];

  // Tools that already wore the shell, whose eyebrow named something else.
  final renamed = <(String, Widget)>[
    ('Medication', const TtcMedicationScreen()),
    // D18 (2026-09-28): one name. Kept for revert: 'See a specialist?'
    ('Should I seek fertility help?', const TtcIvfReadinessScreen()),
    ('PCOS symptom check', const TtcPcosStandScreen()),
  ];

  group('every Tools tile opens the same shell', () {
    for (final (name, screen) in moved) {
      testWidgets('${screen.runtimeType} wears TtcToolScaffold',
          (tester) async {
        await _pumpPhone(tester, screen);
        expect(tester.takeException(), isNull);
        expect(find.byType(TtcToolScaffold), findsOneWidget);
        expect(find.byType(TtcToolClose), findsOneWidget);
        // Kept for revert (2026-09-27): six of these were plain pages with a
        // back bar, which is the shape this test now rules out.
        expect(find.byType(TtcBackBar), findsNothing,
            reason: 'the old plain-page back bar must not come back');
        expect(find.text(name.toUpperCase()), findsOneWidget,
            reason: 'the eyebrow is the Tools tile name, word for word');
      });
    }

    for (final (name, screen) in renamed) {
      testWidgets('${screen.runtimeType} is named as its tile',
          (tester) async {
        await _pumpPhone(tester, screen, height: 2000);
        expect(find.text(name.toUpperCase()), findsOneWidget,
            reason: 'the eyebrow is the Tools tile name, word for word');
      });
    }

    testWidgets('no door crumbs, and one name for vaccinations',
        (tester) async {
      await _pumpPhone(tester, const TtcVaccinesScreen());
      expect(find.text('GETTING READY'), findsNothing,
          reason: 'a crumb naming a door, not the page');
      expect(find.text('Vaccinations before trying'), findsNothing);
      await _pumpPhone(tester, const TtcPrecheckScreen());
      await tester.pumpAndSettle();
      expect(find.text('GETTING READY'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_precheck_next_steps')),
          findsOneWidget,
          reason: '"My next 3 steps" keeps its top-right place');
    });
  });

  group('no overflow at 360dp', () {
    for (final hindi in const [false, true]) {
      for (final (_, screen) in [...moved, ...renamed]) {
        testWidgets('${screen.runtimeType} (${hindi ? 'Hindi' : 'English'})',
            (tester) async {
          TtcLang.instance.hinglish = hindi;
          await _pumpPhone(tester, screen);
          // A RenderFlex overflow is reported as an exception here.
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('the BMI result lays out at 360dp', (tester) async {
      await _pumpPhone(tester, const TtcBmiScreen(), height: 3000);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '160');
      await tester.enterText(find.byType(TextField).at(1), '55');
      await tester.tap(find.text('See my result'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Where your number sits.'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_bmi_save')), findsOneWidget);
    });
  });
}
