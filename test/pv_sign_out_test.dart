// Sign out, walked as a tap (2026-10-10, the user's note "test signout
// button").
//
// What it pins, each one a defect the old code had:
//   · the back stack is REPLACED, so back cannot return into the signed-in
//     app (it used to push onboarding on top of it);
//   · the local auth flag is cleared even though the backend never
//     initialised (one shared `try` used to skip it when
//     `Supabase.instance` threw), and nothing crashes;
//   · the Ask Veda button is lowered for the sign-in screens.
//
// No mocking framework: Supabase is simply never initialised here, which is
// the "uninitialised backend behaves like logged out" case itself.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/auth/auth_flow_screen.dart'
    show kAuthCompletedKey;
import 'package:parentveda/screens/profile/pv_account_actions.dart';
import 'package:parentveda/services/app_shell.dart';
import 'package:parentveda/widgets/global_ask_fab.dart' show FabState;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({kAuthCompletedKey: true});
    AppShell.resetForTest();
    AppShell.register(
      pregnancy: () => MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('PREGNANCY')),
      ),
      signedOut: () => MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'splash'),
        builder: (_) => const Scaffold(body: Text('SIGNED OUT')),
      ),
    );
  });

  tearDown(AppShell.resetForTest);

  testWidgets('sign out replaces the stack, clears the flag, never crashes',
      (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navKey,
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(children: [
            const Text('STAGE HOME'),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => Scaffold(
                    body: TextButton(
                      onPressed: () => pvSignOut(ctx),
                      child: const Text('Sign out'),
                    ),
                  ),
                ),
              ),
              child: const Text('Open You'),
            ),
          ]),
        ),
      ),
    ));

    FabState.instance.markAppLive();
    await tester.tap(find.text('Open You'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('SIGNED OUT'), findsOneWidget);
    expect(find.text('STAGE HOME'), findsNothing);
    expect(find.text('Sign out'), findsNothing);
    // Nothing underneath: back leaves the app instead of re-entering it.
    expect(navKey.currentState!.canPop(), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kAuthCompletedKey), isFalse);
    expect(FabState.instance.visible, isFalse);
  });

  test('every You screen signs out through the shared action', () {
    // Wiring gate: the rows that say "Sign out" call pvSignOut, and main.dart
    // registers where it lands.
    // (Source scan rather than a pump: the You screen needs the stores.)
    final you = _read('lib/screens/profile/pv_you_screen.dart');
    final privacy = _read('lib/screens/profile/pv_data_privacy_screen.dart');
    final main = _read('lib/main.dart');
    expect(you.contains('pvSignOut(context)'), isTrue);
    expect(privacy.contains('pvSignOut(context)'), isTrue);
    expect(main.contains('signedOut: () =>'), isTrue);
  });
}

String _read(String path) => File(path).readAsStringSync();
