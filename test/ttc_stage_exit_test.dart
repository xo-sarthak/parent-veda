// =============================================================================
//  Leaving the TTC stage
// -----------------------------------------------------------------------------
//  Two doors lead out of trying-to-conceive and both were dead:
//
//    * the button after a positive test showed a "coming soon" toast, even
//      though the Transition Engine had ALREADY flipped the life stage, written
//      the due date and added two timeline entries. The app knew she was
//      pregnant and refused to show her the pregnancy.
//    * "Go to pregnancy" in the Profile popped to the first route - which, for
//      anyone booted into TTC by the splash, was TTC. It set the stage correctly
//      and never moved.
//
//  Neither was catchable by reading the widgets: both LOOKED wired, and 1,586
//  tests passed over the top of them. So these assert the destination, not the
//  presence of a handler, and one of them reads the source to make sure the
//  stub never comes back.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/services/app_shell.dart';

class _FakeShell extends StatelessWidget {
  const _FakeShell();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('pregnancy shell'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  var built = 0;
  void registerShell() {
    built = 0;
    AppShell.register(pregnancy: () {
      built++;
      return MaterialPageRoute<void>(builder: (_) => const _FakeShell());
    });
  }

  setUp(AppShell.resetForTest);
  tearDown(AppShell.resetForTest);

  /// A stack that starts AT ttc/today - what the splash builds for a couple who
  /// declared "trying". There is nothing behind it.
  Future<GlobalKey<NavigatorState>> bootedIntoTtc(WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: ttcHomeRoute),
        builder: (_) => const Scaffold(body: Text('ttc home')),
      ),
    ));
    return key;
  }

  /// A stack entered through the doorway on the pregnancy Home - the pregnancy
  /// shell is still alive underneath.
  Future<GlobalKey<NavigatorState>> enteredThroughTheDoor(
      WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      home: const Scaffold(body: Text('the live pregnancy home')),
    ));
    unawaited(key.currentState!.push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: ttcHomeRoute),
      builder: (_) => const Scaffold(body: Text('ttc home')),
    )));
    await tester.pumpAndSettle();
    return key;
  }

  // ===========================================================================
  group('the registry', () {
    test('is empty until main.dart registers', () {
      expect(AppShell.canOpenPregnancy, isFalse);
    });

    test('and reports itself once it has', () {
      registerShell();
      expect(AppShell.canOpenPregnancy, isTrue);
    });
  });

  // ===========================================================================
  group('booted straight into TTC', () {
    testWidgets('the pregnancy shell replaces the whole stack', (tester) async {
      registerShell();
      final key = await bootedIntoTtc(tester);

      expect(leaveTtcForPregnancy(key.currentState!), isTrue);
      await tester.pumpAndSettle();

      expect(find.byType(_FakeShell), findsOneWidget);
      expect(find.text('ttc home'), findsNothing);
    });

    testWidgets('and it becomes the FIRST route, so back exits the app',
        (tester) async {
      // The bug this prevents is subtler than the dead button: if TTC stayed
      // underneath, the system back gesture from her new pregnancy home would
      // drop her into the stage she just left, on the day she left it.
      registerShell();
      final key = await bootedIntoTtc(tester);
      leaveTtcForPregnancy(key.currentState!);
      await tester.pumpAndSettle();

      expect(key.currentState!.canPop(), isFalse);
    });

    testWidgets('with nothing registered it admits failure rather than'
        ' appearing to work', (tester) async {
      final key = await bootedIntoTtc(tester);
      expect(leaveTtcForPregnancy(key.currentState!), isFalse);
      await tester.pumpAndSettle();
      // Still here - and the caller shows the "reopen the app" line, which is
      // true, because the stage is already on disk.
      expect(find.text('ttc home'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('entered through the door on the pregnancy Home', () {
    testWidgets('we pop back to the LIVE shell, not a fresh one',
        (tester) async {
      // Rebuilding would throw away her tab, her scroll position and three
      // loaded controllers, to arrive at the same screen.
      registerShell();
      final key = await enteredThroughTheDoor(tester);

      expect(leaveTtcForPregnancy(key.currentState!), isTrue);
      await tester.pumpAndSettle();

      expect(find.text('the live pregnancy home'), findsOneWidget);
      expect(built, 0, reason: 'a second shell was built for no reason');
    });

    testWidgets('and it works with no registry at all', (tester) async {
      final key = await enteredThroughTheDoor(tester);
      expect(leaveTtcForPregnancy(key.currentState!), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('the live pregnancy home'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('both doors are actually wired to it', () {
    // The wiring gate. Correct-but-unreachable is the failure mode here, and
    // the transition button in particular LOOKED wired for as long as it has
    // existed - it had an onTap, it just went nowhere.

    test('the positive-test button no longer shows a coming-soon toast', () {
      const src = 'lib/screens/ttc/ttc_transition_screen.dart';
      final text = File(src).readAsStringSync();
      expect(text, contains('leaveTtcForPregnancy'));
      expect(text, isNot(contains('ttcSoon(context, t.transitionNext)')),
          reason: 'the most important tap in the product is a stub again');
    });

    test('and the Profile stage switch goes through the same door', () {
      const src = 'lib/screens/ttc/ttc_profile_screen.dart';
      final text = File(src).readAsStringSync();
      expect(text, contains('leaveTtcForPregnancy'));
    });

    test('main.dart is the only place that registers a shell', () {
      // If a second registration appears, two parts of the app disagree about
      // what "the pregnancy app" is - and the last one to run wins silently.
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('AppShell.register('))
          .map((f) => f.path)
          .toList();
      expect(hits.length, 1, reason: 'registered in: $hits');
      expect(hits.single, endsWith('main.dart'));
    });
  });
}

/// Local `unawaited` so this file does not need dart:async for one call.
void unawaited(Future<void> f) {}
