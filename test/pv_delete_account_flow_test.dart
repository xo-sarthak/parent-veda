// =============================================================================
//  Delete account: the dialog and the failure path (2026-10-01).
//
//  The user, in TTC Settings: tapping Delete account gave a red screen,
//  "'_dependents.isEmpty': is not true". Cause: the typed-keyword sheet's text
//  controller was disposed the instant the sheet was popped, while the sheet
//  was still on screen for its exit animation and still listening to it. It
//  now waits, as the name editor does.
//
//  This drives the real function through its whole failure path (nobody is
//  signed in in a test, so the server call is refused, exactly as it is when
//  the edge function is not deployed): open, type the keyword, confirm, and
//  end on a plain message, with the account untouched and no exception.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_account_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester t) async {
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
                onPressed: () => pvDeleteAccount(ctx),
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

  testWidgets('the sheet asks for the keyword and stays disabled until typed',
      (t) async {
    await pump(t);
    expect(find.text('Delete your account'), findsOneWidget);
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
    // Not typed yet: tapping does nothing and the sheet stays.
    await t.tap(find.text('Delete my account'));
    await t.pumpAndSettle();
    expect(find.text('Delete your account'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('a refused delete ends on a plain message, with no exception',
      (t) async {
    await pump(t);
    await t.enterText(find.byType(TextField), 'delete');
    await t.pumpAndSettle();
    await t.tap(find.text('Delete my account'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 700));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull,
        reason: 'the sheet\'s controller must outlive its exit animation');
    expect(find.text('Could not delete the account. Please try again.'),
        findsOneWidget);
    expect(find.text('Delete your account'), findsNothing);
  });

  testWidgets('closing the sheet without deleting is quiet', (t) async {
    await pump(t);
    await t.tap(find.byIcon(Icons.close_rounded));
    await t.pumpAndSettle();
    await t.pump(const Duration(milliseconds: 700));
    expect(t.takeException(), isNull);
    expect(find.text('Delete your account'), findsNothing);
  });
}
