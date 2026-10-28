// =============================================================================
//  Add a child: the sheet closes without a red screen (2026-10-02).
//
//  The user, adding an older child from the pregnancy profile: a red screen,
//  "'_dependents.isEmpty': is not true". It is the same bug the Delete account
//  sheet had the day before: the name field's TextEditingController was
//  disposed the instant `showModalBottomSheet` returned, while the sheet was
//  still on screen for its exit animation and its TextField still listening.
//  It now waits 600ms, as the name editor does.
//
//  Closing the sheet runs the same dispose line whether she saved or not, so
//  the quickest honest reproduction is: open, type a name, close.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_names_data.dart' show NameMatchStore;
import 'package:parentveda/screens/profile/pv_you_sheets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> open(WidgetTester t, {bool arrival = false}) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: TextButton(
                onPressed: () => showPvAddChildSheet(ctx, arrival: arrival),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
  }

  testWidgets('opens on the add-a-child sheet', (t) async {
    await open(t);
    expect(find.text('Add a child'), findsOneWidget);
    expect(find.text('Name'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('closing it after typing a name leaves no red screen',
      (t) async {
    await open(t);
    await t.enterText(find.byType(TextField), 'Aarav');
    await t.pump();
    await t.tap(find.byIcon(Icons.close_rounded));
    // The exit animation is where the disposed controller used to be heard.
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(t.takeException(), isNull,
        reason: 'the sheet\'s controller must outlive its exit animation');
    await t.pumpAndSettle();
    await t.pump(const Duration(milliseconds: 700));
    expect(t.takeException(), isNull);
    expect(find.text('Add a child'), findsNothing);
  });

  testWidgets('the newborn arrival sheet closes cleanly too', (t) async {
    await open(t, arrival: true);
    expect(find.text('Welcome to the world'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Aarav');
    await t.tap(find.byIcon(Icons.close_rounded));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    await t.pump(const Duration(milliseconds: 700));
    expect(t.takeException(), isNull);
  });

  // P2 N4 (2026-10-28): the birth sheet offers her chosen name, never fills
  // it in for her, and points to Baby names when she has none.
  group('the name she kept in Baby names', () {
    tearDown(() {
      for (final n in NameMatchStore.instance.liked.toList()) {
        NameMatchStore.instance.clearVote(n);
      }
    });

    testWidgets('her chosen name is offered, and only a tap uses it',
        (t) async {
      NameMatchStore.instance.crown('Inaya');
      await open(t, arrival: true);
      expect(find.text('The name you chose. Use it, or write another.'),
          findsOneWidget);
      final field = t.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      await t.tap(find.byKey(const ValueKey('pv_birth_name_Inaya')));
      await t.pump();
      expect(field.controller!.text, 'Inaya');
      expect(find.text('See more names'), findsOneWidget);
    });

    testWidgets('with no name kept, she is shown where to find one',
        (t) async {
      await open(t, arrival: true);
      expect(find.byKey(const ValueKey('pv_birth_find_name')), findsOneWidget);
      expect(find.text('Still deciding? Find a name'), findsOneWidget);
    });

    testWidgets('adding an older child does not offer a newborn name',
        (t) async {
      NameMatchStore.instance.crown('Inaya');
      await open(t);
      expect(find.byKey(const ValueKey('pv_birth_name_offer')), findsNothing);
    });
  });
}
