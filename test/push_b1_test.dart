// =============================================================================
//  Phase 6b B1: Firebase in the app, and a build with no config still starts
// -----------------------------------------------------------------------------
//  What this file holds, in order of how much it would hurt to lose:
//
//    1. No config is not a crash. Firebase failing to start leaves push off
//       (`ready == false`, the logged-out shape) and wires nothing.
//    2. The Gradle side of the same rule: the Google services plugin is
//       applied only when google-services.json exists, so a checkout without
//       it still builds.
//    3. A push tap opens through B0's one opener, by `link_kind` / `link_id`.
//    4. The wiring: main.dart starts it; the doctor and partner apps do not.
//    5. The secrets stay out of git.
//
//  The real proof of (1) and (2) together is a build with the file moved
//  away, started on a phone. That is the B1 phone check, on the user's word.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/notification_link.dart';
import 'package:parentveda/services/notification_service.dart';
import 'package:parentveda/services/push_service.dart';

String _code(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final realStart = PushService.startFirebase;
  final realListen = PushService.listenForTaps;
  late List<NotificationLink> opened;

  setUp(() {
    PushService.instance.debugReset();
    NotificationService.instance.debugResetLinkOpener();
    opened = [];
    NotificationService.instance.setLinkOpener(opened.add);
  });

  tearDown(() {
    PushService.startFirebase = realStart;
    PushService.listenForTaps = realListen;
    PushService.instance.debugReset();
    NotificationService.instance.debugResetLinkOpener();
  });

  group('no config', () {
    test('Firebase failing to start is caught, push stays off, no taps wired',
        () async {
      var wired = false;
      PushService.startFirebase =
          () async => throw Exception('no google-services.json');
      PushService.listenForTaps = (_) async => wired = true;

      await PushService.instance.init();

      expect(PushService.instance.ready, isFalse);
      expect(wired, isFalse);
    });

    test('a throw before the first await is caught too', () async {
      PushService.startFirebase = () => throw StateError('no platform');
      await PushService.instance.init();
      expect(PushService.instance.ready, isFalse);
    });

    test('the real Firebase, with no platform at all, does not throw',
        () async {
      // flutter test has no Android, no plugin and no config: the harshest
      // "unconfigured" there is.
      TestWidgetsFlutterBinding.ensureInitialized();
      await PushService.instance.init();
      expect(PushService.instance.ready, isFalse);
    });
  });

  group('configured', () {
    test('ready, and taps wired once however often init is called', () async {
      var wired = 0;
      PushService.startFirebase = () async {};
      PushService.listenForTaps = (_) async => wired++;

      await PushService.instance.init();
      await PushService.instance.init();

      expect(PushService.instance.ready, isTrue);
      expect(wired, 1);
    });

    test('broken tap wiring does not take init down', () async {
      PushService.startFirebase = () async {};
      PushService.listenForTaps = (_) async => throw Exception('channel');
      await PushService.instance.init();
      expect(PushService.instance.ready, isTrue);
    });
  });

  group('a push tap', () {
    test('opens its link through the one opener', () async {
      PushService.startFirebase = () async {};
      PushService.listenForTaps = (onTap) async =>
          onTap({'link_kind': 'course', 'link_id': 'c-42'});

      await PushService.instance.init();

      expect(opened, [const NotificationLink(NotificationLink.course, 'c-42')]);
    });

    test('a tap that launched the app is held until the opener exists', () {
      NotificationService.instance.debugResetLinkOpener();
      PushService.handleTap({'link_kind': 'product', 'link_id': 'p-1'});
      expect(opened, isEmpty);

      NotificationService.instance.setLinkOpener(opened.add);
      expect(opened, [const NotificationLink(NotificationLink.product, 'p-1')]);
    });

    test('a push with no link opens nothing extra', () {
      PushService.handleTap({'title': 'hello'});
      expect(opened, isEmpty);
    });

    test('the real tap paths: background and launched', () {
      final src = _code('lib/services/push_service.dart');
      expect(src, contains('FirebaseMessaging.onMessageOpenedApp.listen'));
      expect(src, contains('FirebaseMessaging.instance.getInitialMessage()'));
      expect(src,
          contains('NotificationService.instance.openLink(link)'));
    });
  });

  group('Gradle: no file, still a build', () {
    test('the plugin is declared, never applied unconditionally', () {
      final settings = _code('android/settings.gradle.kts');
      expect(settings,
          contains('id("com.google.gms.google-services") version "4.5.0" apply false'));

      final app = _code('android/app/build.gradle.kts');
      expect(app, contains('id("com.google.gms.google-services") apply false'));
      expect(
          app,
          contains('if (file("google-services.json").exists()) {\n'
              '    apply(plugin = "com.google.gms.google-services")\n'
              '}'));
      // Exactly one apply, and it is the guarded one.
      expect('apply(plugin = "com.google.gms.google-services")'
          .allMatches(app)
          .length, 1);
    });

    test('every flavour id is named as needing registration', () {
      final app = _code('android/app/build.gradle.kts');
      for (final suffix in ['".doctor"', '".partners"']) {
        expect(app, contains('applicationIdSuffix = $suffix'),
            reason: 'a flavour id changed: register it in Firebase, '
                're-download google-services.json, update this test');
      }
      expect(RegExp(r'create\("').allMatches(app).length, 3,
          reason: 'a new flavour: register its app id in Firebase first, '
              'or the Google services plugin fails its build');
    });
  });

  group('wiring', () {
    test('main.dart starts push after registering the opener', () {
      final main = _code('lib/main.dart');
      final opener = main.indexOf('setLinkOpener(NotificationOpener.open)');
      final push = main.indexOf('PushService.instance.init()');
      expect(opener, greaterThan(0));
      expect(push, greaterThan(opener));
    });

    test('the doctor and partner apps do not start push (decision 6)', () {
      for (final f in ['lib/main_doctor.dart', 'lib/main_partner.dart']) {
        expect(_code(f), isNot(contains('PushService')), reason: f);
      }
    });
  });

  group('secrets', () {
    test('the key and the config are ignored', () {
      final ignore = _code('.gitignore').split('\n').map((l) => l.trim());
      expect(ignore, contains('*firebase-adminsdk*.json'));
      expect(ignore, contains('android/app/google-services.json'));
    });
  });
}
