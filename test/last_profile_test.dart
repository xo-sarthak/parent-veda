// =============================================================================
//  F6: open on the last profile used, and a tapped reminder opens its own
//  profile (2026-10-25, STAGE-TRANSITIONS M47-M49)
// -----------------------------------------------------------------------------
//  What is saved is which home was on top ('parenting', 'learning', 'root'),
//  read from the route stack; which child is already saved by its own store.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/last_profile.dart';
import 'package:parentveda/screens/v2/pv_family_switch.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

FamilyProfile _child(String id, FamilyHome home) =>
    FamilyProfile(id: id, kind: FamilyProfileKind.child, name: id, line: '', home: home);

const _pregnancy = FamilyProfile(
    id: 'pregnancy', kind: FamilyProfileKind.pregnancy, name: 'Baby-to-be', line: '', home: FamilyHome.pregnancy);

void main() {
  group('M47 which home is on top', () {
    test('the root alone is the root, whatever its name', () {
      expect(lastHomeFromStack([null]), kLastHomeRoot);
      expect(lastHomeFromStack(['pp/my_child']), kLastHomeRoot);
      expect(lastHomeFromStack(['skilling']), kLastHomeRoot);
      expect(lastHomeFromStack([]), kLastHomeRoot);
    });

    test("a child's home over the root, and pages over that home, count as the child", () {
      expect(lastHomeFromStack([null, 'pp/my_child']), kLastHomeParenting);
      expect(lastHomeFromStack(['ttc/today', 'pp/my_child', 'pp/vaccines', null]), kLastHomeParenting);
      expect(lastHomeFromStack(['pp/my_child', 'skilling']), kLastHomeLearning);
    });

    test('the highest home wins', () {
      expect(lastHomeFromStack(['ttc/today', 'pp/my_child', 'skilling']), kLastHomeLearning);
    });

    test('pages over the root are the root', () {
      expect(lastHomeFromStack([null, 'pregnancy/week', 'tools/movement']), kLastHomeRoot);
    });
  });

  group('M48 what the launch reopens', () {
    final kids = [_pregnancy, _child('a', FamilyHome.parenting), _child('b', FamilyHome.learning)];

    FamilyProfile? reopen(String? saved,
            {FamilyHome root = FamilyHome.pregnancy, String? active = 'a', String? open = 'b'}) =>
        profileToReopen(saved: saved, all: kids, root: root, activeChildId: active, learningOpenId: open);

    test('a parenting home over the pregnancy root opens the open child', () {
      expect(reopen(kLastHomeParenting)?.id, 'a');
    });

    test('a learning space opens the open learning child', () {
      expect(reopen(kLastHomeLearning)?.id, 'b');
    });

    test('nothing saved, or the root saved, stays on the root', () {
      expect(reopen(null), isNull);
      expect(reopen(kLastHomeRoot), isNull);
      expect(reopen('garbage'), isNull);
    });

    test('that home is the root now (the stage moved): nothing is pushed', () {
      expect(reopen(kLastHomeParenting, root: FamilyHome.parenting), isNull);
      expect(reopen(kLastHomeLearning, root: FamilyHome.learning), isNull);
    });

    test('the child is gone, or is no longer on that home: the root', () {
      expect(reopen(kLastHomeParenting, active: 'gone'), isNull);
      expect(reopen(kLastHomeParenting, active: null), isNull);
      // 'b' is on the learning space now, so a saved parenting home does not
      // reopen her there.
      expect(reopen(kLastHomeParenting, active: 'b'), isNull);
      // A learning yes taken back: her profile is on Parenting.
      expect(
          profileToReopen(
              saved: kLastHomeLearning,
              all: [_pregnancy, _child('b', FamilyHome.parenting)],
              root: FamilyHome.pregnancy,
              activeChildId: 'b',
              learningOpenId: 'b'),
          isNull);
    });

    test('a pregnancy or trying profile is never reopened over a root', () {
      final ids = [
        for (final s in [kLastHomeParenting, kLastHomeLearning])
          profileToReopen(
              saved: s,
              all: const [_pregnancy],
              root: FamilyHome.parenting,
              activeChildId: 'pregnancy',
              learningOpenId: 'pregnancy')
      ];
      expect(ids, [null, null]);
    });
  });

  group('M48 the observer saves what is on top', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LastProfile.instance.debugReset();
    });

    Future<NavigatorState> host(WidgetTester t, LastProfileObserver o) async {
      final key = GlobalKey<NavigatorState>();
      await t.pumpWidget(MaterialApp(
        navigatorKey: key,
        navigatorObservers: [o],
        home: const Text('root'),
      ));
      return key.currentState!;
    }

    void push(NavigatorState nav, String? name) => nav.push(MaterialPageRoute<void>(
        settings: RouteSettings(name: name), builder: (_) => Text(name ?? 'page')));

    Future<String?> saved() async => (await SharedPreferences.getInstance()).getString(kLastHomeKey);

    testWidgets('nothing is saved before the home is shown (the saved value survives the splash)', (t) async {
      final nav = await host(t, LastProfileObserver());
      push(nav, 'pp/my_child');
      await t.pumpAndSettle();
      expect(LastProfile.instance.onTop, kLastHomeParenting);
      expect(await saved(), isNull);
      expect(LastProfile.instance.homeShown, isFalse);
    });

    testWidgets("a child's home on top is saved; back to the root saves the root", (t) async {
      final nav = await host(t, LastProfileObserver());
      LastProfile.instance.markHomeShown();
      await t.pumpAndSettle();
      expect(await saved(), kLastHomeRoot);
      push(nav, 'pp/my_child');
      await t.pumpAndSettle();
      expect(await saved(), kLastHomeParenting);
      push(nav, 'pp/vaccines');
      await t.pumpAndSettle();
      expect(await saved(), kLastHomeParenting);
      nav.popUntil((r) => r.isFirst);
      await t.pumpAndSettle();
      expect(await saved(), kLastHomeRoot);
      push(nav, 'skilling');
      await t.pumpAndSettle();
      expect(await saved(), kLastHomeLearning);
    });

    testWidgets('sign out: taps wait again', (t) async {
      await host(t, LastProfileObserver());
      LastProfile.instance.markHomeShown();
      expect(LastProfile.instance.homeShown, isTrue);
      LastProfile.instance.markSignedOut();
      expect(LastProfile.instance.homeShown, isFalse);
    });
  });

  group('wiring (the wiring gate)', () {
    test('the observer is on the app navigator', () {
      expect(_code('lib/main.dart'), contains('navigatorObservers: [fabRouteObserver, lastProfileObserver]'));
    });

    test('the splash restores after both ways in, the partner skipped', () {
      final code = _code('lib/screens/splash_screen.dart');
      expect(code, contains("unawaited(restoreLastProfile(nav, father: role == 'father'));"));
      expect(code, contains('unawaited(restoreLastProfile(nav, father: isFather));'));
      final svc = _code('lib/services/last_profile.dart');
      expect(svc, contains('if (father || NotificationService.instance.launchedFromTap) return;'));
      // The home is marked shown however the restore ends.
      expect(svc, contains('} finally {\n    LastProfile.instance.markHomeShown();'));
      // It never moves the stage (M40's allow-list holds).
      expect(svc, isNot(contains('setStage(')));
      expect(svc, contains('openFamilyProfile(nav.context, to, root)'));
    });

    test('a launching tap is remembered', () {
      expect(_code('lib/services/notification_service.dart'), contains('launchedFromTap = true;\n          _deliverTap(id);'));
    });

    test('sign out lowers the flag on both paths', () {
      final code = _code('lib/screens/profile/pv_account_actions.dart');
      expect('LastProfile.instance.markSignedOut();'.allMatches(code).length, 2);
    });

    test("every push of a child's home uses the two names the observer reads", () {
      final pp = RegExp(r'PpHomeScreen\(');
      final sk = RegExp(r'SkillingPreviewScreen\(');
      // The two preview doors from before profiles existed open the space
      // without a child; they are not profiles, so not read.
      const previews = {
        'lib/screens/home_screen_b.dart': "'skilling/preview'",
        'lib/screens/post_pregnancy/explore_drawer.dart': "'Skilling (preview)'",
      };
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        final path = f.path.replaceAll('\\', '/');
        if (!path.endsWith('.dart')) continue;
        final lines = _code(path).split('\n');
        for (var i = 0; i < lines.length; i++) {
          final isPp = pp.hasMatch(lines[i]) && !lines[i].contains('const PpHomeScreen({');
          final isSk = sk.hasMatch(lines[i]) && !lines[i].contains('const SkillingPreviewScreen({');
          if (!isPp && !isSk) continue;
          final near = lines.sublist((i - 4).clamp(0, lines.length), (i + 4).clamp(0, lines.length)).join('\n');
          if (isSk && previews.containsKey(path)) {
            expect(near, contains(previews[path]!), reason: '$path:${i + 1}');
            continue;
          }
          expect(near, contains(isPp ? "name: 'pp/my_child'" : "name: 'skilling'"), reason: '$path:${i + 1}');
        }
      }
    });
  });

  group('M49 a tapped reminder opens its own profile', () {
    test('a pregnancy message goes back to the pregnancy home instead of being dropped', () {
      final code = _code('lib/screens/pregnancy/preg_messages_screen.dart');
      final body = code.substring(code.indexOf('void pregOpenMessageFromPhone'), code.indexOf('IntentMark _markFor'));
      expect(body, contains('!LastProfile.instance.homeShown'));
      expect(body, contains('(away && !pregnant)'));
      expect(body, contains('openStageDoor(ctx, StageDoor.pregnancy);'));
    });

    test("a TTC message leaves a child's home first", () {
      final code = _code('lib/screens/ttc/ttc_messages_screen.dart');
      final body = code.substring(code.indexOf('void ttcOpenMessageFromPhone'), code.indexOf('IntentMark ttcMessageMark'));
      expect(body, contains('!LastProfile.instance.homeShown'));
      expect(body, contains('LastProfile.instance.onTop != kLastHomeRoot'));
      expect(body, contains('popUntil((r) => r.settings.name == ttcHomeRoute || r.isFirst)'));
    });

    test('a parenting message waits for the home (it already opens its own child, F3)', () {
      final code = _code('lib/screens/post_pregnancy/pp_messages_screen.dart');
      final body = code.substring(code.indexOf('void ppOpenMessageFromPhone'), code.indexOf('IntentMark _markFor'));
      expect(body, contains('!LastProfile.instance.homeShown'));
    });
  });
}
