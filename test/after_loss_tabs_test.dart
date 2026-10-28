// =============================================================================
//  R3 (2026-10-25): after a loss, still in pregnancy, Learn, Tools and More
//  stop speaking in weeks. The After a loss door leads; the week's videos,
//  Pregnancy 101, the birth tools, kicks, the weight range, Week by week and
//  the Journey map step aside. The undo brings every one back.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/pregnancy/preg_learn_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_more_screen.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PregnancyEndedStore.instance.resetForTest();
    pregnancy = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  tearDown(() => PregnancyEndedStore.instance.resetForTest());

  Future<void> pump(WidgetTester tester, Widget w, {double height = 4000}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: w)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder text(String t) => find.text(t, skipOffstage: false);

  group('Tools', () {
    testWidgets('pregnant: the birth tools are there', (tester) async {
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      expect(text('GET READY'), findsOneWidget);
      expect(text('Birth plan'), findsOneWidget);
    });

    testWidgets('after a loss: no birth tools, no kicks; what looks after her stays', (tester) async {
      await PregnancyEndedStore.instance.markEnded();
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      expect(tester.takeException(), isNull);
      // P3 D5 (user, 2026-10-28, "everything stays, baby wording dropped"):
      // Get ready stays for the due date; its birth rows step aside until P4.
      // Kept for revert: expect(text('GET READY'), findsNothing);
      expect(text('GET READY'), findsOneWidget);
      // P4 D4 (2026-10-28): the birth rows stay too, their lines without the
      // baby. Kept for revert: expect(text('Birth plan'), findsNothing);
      expect(text('Birth plan'), findsOneWidget);
      expect(find.textContaining('get ready for the birth', skipOffstage: false), findsNothing);
      expect(find.textContaining('look after your health', skipOffstage: false), findsOneWidget);
      for (final h in ['TRACK', 'KEEP', 'ASK']) {
        expect(text(h), findsOneWidget, reason: h);
      }
      expect(text('Blood pressure & sugar'), findsOneWidget);
    });

    testWidgets('the undo brings them back', (tester) async {
      await PregnancyEndedStore.instance.markEnded();
      await pump(tester, ToolsHubScreen(controller: pregnancy));
      await PregnancyEndedStore.instance.undo();
      await tester.pump();
      expect(text('Birth plan'), findsOneWidget);
    });
  });

  group('More', () {
    testWidgets('after a loss: the After a loss door replaces Week by week and the Journey map', (tester) async {
      await PregnancyEndedStore.instance.markEnded();
      await pump(tester, PregMoreScreen(pregnancy: pregnancy));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('preg_more_after_loss'), skipOffstage: false), findsOneWidget);
      expect(text('Week by week'), findsNothing);
      expect(text('Journey map'), findsNothing);
      expect(text('What we sent you before'), findsOneWidget);
      // Her appointments still matter.
      expect(text('Calendar'), findsOneWidget);
    });

    testWidgets('pregnant: as before', (tester) async {
      await pump(tester, PregMoreScreen(pregnancy: pregnancy));
      expect(find.byKey(const ValueKey('preg_more_after_loss'), skipOffstage: false), findsNothing);
      expect(text('Week by week'), findsOneWidget);
    });
  });

  group('Learn', () {
    testWidgets('after a loss: After a loss leads; no week videos, no Pregnancy 101', (tester) async {
      await PregnancyEndedStore.instance.markEnded();
      await pump(tester, PregLearnScreen(pregnancy: pregnancy), height: 20000);
      expect(tester.takeException(), isNull);
      expect(text('Pregnancy 101'), findsNothing);
      expect(find.textContaining('Videos for week', skipOffstage: false), findsNothing);
      // The first door shelf is After a loss.
      final shelves = find.text('READS FROM THE DOOR', skipOffstage: false);
      expect(shelves, findsWidgets);
      final firstShelfY = tester.getTopLeft(shelves.first).dy;
      final afterLoss = find.text('After a loss', skipOffstage: false);
      expect(afterLoss, findsWidgets);
      final ys = [for (final e in afterLoss.evaluate()) tester.getTopLeft(find.byWidget(e.widget).first).dy];
      expect(ys.any((y) => (y - firstShelfY).abs() < 60), isTrue,
          reason: 'After a loss is the first door shelf');
    });

    testWidgets('pregnant: Pregnancy 101 is there', (tester) async {
      await pump(tester, PregLearnScreen(pregnancy: pregnancy), height: 20000);
      expect(text('Pregnancy 101'), findsOneWidget);
    });
  });
}
