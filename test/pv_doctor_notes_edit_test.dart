// =============================================================================
//  Notes for your doctor: a way to edit from the page, and the real logo on a
//  memory card (2026-10-02).
//
//  The user, on the doctor notes screen: "I know we can edit these from the
//  profile; when the user is on this screen they might get confused: do I have
//  to go back and find the option? Provide a gate from here, to where the
//  information is actually edited."
//
//  The page stays READ-ONLY by design (it repeats her entries and interprets
//  nothing), so the gate is a door to the place that owns each section, never
//  an editor here. Each label names its place ("Edit your details", "Open
//  weight tracker"), because a bare "Edit" says nothing about where it goes.
//  And the page must show the change when she comes back, so it is checked
//  that it rebuilds.
//
//  And the user, on a memory card: "ParentVeda is written but the logo is not
//  used; there is a leaf". Every template's footer now draws the brand mark.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/memories/memory_models.dart';
import 'package:parentveda/memories/memory_templates.dart';
import 'package:parentveda/screens/memories/memory_card.dart';
import 'package:parentveda/screens/profile/pv_details_screen.dart';
import 'package:parentveda/screens/profile/pv_doctor_notes_screen.dart';
import 'package:parentveda/screens/tools/baby_movement_screen.dart';
import 'package:parentveda/screens/tools/medicine_tracker_screen.dart';
import 'package:parentveda/screens/tools/weight_tracker_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/tools_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notes for your doctor', () {
    late PregnancyController controller;

    // Real async work (load) belongs here: awaited inside testWidgets it hangs
    // under fake time.
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = PregnancyController(
          dueDate: DateTime.now().add(const Duration(days: 140)));
      await controller.load();
    });

    Future<void> pump(WidgetTester t, LifeStage stage) async {
      PregnancyController.current = controller;
      t.view.physicalSize = const Size(900, 3200);
      t.view.devicePixelRatio = 1.0;
      addTearDown(() {
        t.view.reset();
        PregnancyController.current = null;
      });
      await t.pumpWidget(MaterialApp(home: PvDoctorNotesScreen(stage: stage)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('pregnancy: every section that can be edited has a named gate',
        (t) async {
      await pump(t, LifeStage.pregnancy);
      for (final (title, label) in [
        ('About', 'Edit your details'),
        ('Weight', 'Open weight tracker'),
        ('Movements', 'Open movement tracker'),
        ('Medicines and supplements', 'Open medicines'),
      ]) {
        final b = find.byKey(ValueKey('notes_edit_$title'));
        expect(b, findsOneWidget, reason: '$title has no way to edit it');
        expect(find.descendant(of: b, matching: find.text(label)),
            findsOneWidget, reason: title);
      }
      // A bare "Edit" says nothing about where it goes.
      expect(find.text('Edit'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('"Edit your details" opens the screen the profile edits in',
        (t) async {
      await pump(t, LifeStage.pregnancy);
      await t.tap(find.byKey(const ValueKey('notes_edit_About')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(PvDetailsScreen), findsOneWidget);
      final screen = t.widget<PvDetailsScreen>(find.byType(PvDetailsScreen));
      expect(screen.stageId, 'pregnancy');
    });

    for (final (title, type) in [
      ('Weight', WeightTrackerScreen),
      ('Movements', BabyMovementScreen),
      ('Medicines and supplements', MedicineTrackerScreen),
    ]) {
      testWidgets('the $title gate opens its tracker', (t) async {
        await pump(t, LifeStage.pregnancy);
        await t.ensureVisible(find.byKey(ValueKey('notes_edit_$title')));
        await t.tap(find.byKey(ValueKey('notes_edit_$title')));
        await t.pump();
        await t.pump(const Duration(milliseconds: 600));
        expect(find.byType(type), findsOneWidget, reason: title);
      });
    }

    testWidgets('coming back shows what she changed', (t) async {
      await pump(t, LifeStage.pregnancy);
      expect(find.text('Before pregnancy: 71.5 kg'), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('notes_edit_Weight')));
      await t.tap(find.byKey(const ValueKey('notes_edit_Weight')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      // She changes it in the tracker...
      await ToolsStore.instance.setWeightProfile(71.5, 160);
      // ...and comes back.
      t.state<NavigatorState>(find.byType(Navigator)).pop();
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Before pregnancy: 71.5 kg'), findsOneWidget,
          reason: 'the page did not rebuild when she came back');
    });

    testWidgets('trying to conceive: its own gates, by name', (t) async {
      await pump(t, LifeStage.tryingToConceive);
      expect(find.byKey(const ValueKey('notes_edit_About')), findsOneWidget);
      expect(find.text('Edit your details'), findsWidgets);
      expect(find.text('Open records'), findsOneWidget);
      expect(find.text('Open appointments'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('the memory card carries the real logo', () {
    for (final tpl in kMemoryTemplates) {
      testWidgets('${tpl.id}: the brand mark, not a leaf', (t) async {
        final d = MemoryData(type: tpl.type)
          ..coupleNames = 'Priya & Arjun'
          ..babyName = 'Aarav';
        t.view.physicalSize = const Size(1200, 2200);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MemoryCard(template: tpl, data: d))),
        ));
        await t.pump();
        final mark = find.byKey(const ValueKey('memory_brand_mark'));
        if (mark.evaluate().isEmpty) {
          // A template with no footer (none today) would not carry it.
          fail('${tpl.id} has no brand mark in its footer');
        }
        final img = t.widget<Image>(mark);
        expect((img.image as ResizeImage).imageProvider,
            isA<AssetImage>().having((a) => a.assetName, 'asset', kMemoryBrandMark));
        expect(find.byIcon(Icons.eco_rounded), findsNothing);
      });
    }
  });
}
