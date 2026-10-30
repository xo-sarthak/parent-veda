// =============================================================================
//  PushService - Firebase Cloud Messaging on the phone, or quietly nothing
// -----------------------------------------------------------------------------
//  Phase 6b, B1 (2026-10-30). Starts Firebase and routes a push tap to the one
//  opener B0 built: `NotificationService.openLink(NotificationLink.fromData(
//  message.data))`. A push carries `link_kind` / `link_id` in its data, the
//  same two keys a local notification's payload carries, so both open through
//  `NotificationOpener.open` and nothing here knows about pages.
//
//  ⚠️ NO CONFIG IS NOT AN ERROR. A build with no `google-services.json` (a
//  fresh checkout, CI, the doctor and partner apps, which never call this) has
//  no Firebase settings, and `Firebase.initializeApp()` throws. That is caught
//  and push stays off, exactly like being logged out: the app starts, local
//  notifications work, and nothing asks for a token. The Gradle side holds the
//  same rule: android/app/build.gradle.kts applies the Google services plugin
//  only when the file exists, so a missing file cannot fail the build either.
//
//  Not here yet: the token and its upload to Supabase (B2), permission (the
//  app already asks through flutter_local_notifications), and showing a push
//  that arrives while the app is open (B5). Android first; iPhone is B7.
//
//  Test: test/push_b1_test.dart.
// =============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_link.dart';
import 'notification_service.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _started = false;
  bool _ready = false;

  /// True once Firebase has started on this build. False with no config,
  /// which is the logged-out shape: B2 registers a token only when true.
  bool get ready => _ready;

  /// Starts Firebase. Swapped in tests, where there is no platform.
  @visibleForTesting
  static Future<void> Function() startFirebase = _startFirebase;

  /// Wires the two tap paths to [onTap]. Swapped in tests.
  @visibleForTesting
  static Future<void> Function(void Function(Map<String, dynamic> data) onTap)
      listenForTaps = _listenForTaps;

  /// Called once, from `main.dart`, not awaited: a slow or failing Firebase
  /// must never hold the first frame.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    try {
      await startFirebase();
    } catch (e) {
      debugPrint('[push] off on this build: $e');
      return;
    }
    _ready = true;
    try {
      await listenForTaps(handleTap);
    } catch (e) {
      debugPrint('[push] tap wiring failed: $e');
    }
  }

  /// A push was tapped. Its data names the page; the one opener opens it,
  /// and holds it if the app is still starting (a tap that launched the app).
  /// A push with no link only brings the app forward, as the OS already has.
  static void handleTap(Map<String, dynamic> data) {
    final link = NotificationLink.fromData(data);
    if (link == null) return;
    NotificationService.instance.openLink(link);
  }

  /// Test seam: forget that [init] ran.
  @visibleForTesting
  void debugReset() {
    _started = false;
    _ready = false;
  }
}

Future<void> _startFirebase() async {
  await Firebase.initializeApp();
}

Future<void> _listenForTaps(
    void Function(Map<String, dynamic> data) onTap) async {
  // The app was in the background and the push was tapped.
  FirebaseMessaging.onMessageOpenedApp.listen((m) => onTap(m.data));
  // The app was closed and the tap launched it. Asked once, at start.
  final first = await FirebaseMessaging.instance.getInitialMessage();
  if (first != null) onTap(first.data);
}
