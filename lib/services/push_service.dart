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
//  B2 (2026-10-30): THE TOKEN. Only when [ready], and only while signed in,
//  the FCM token goes to `pv_push_register` on each app open and sign-in, and
//  again when FCM rotates it. A lost register is simply redone on the next
//  open, so it is sent once and not queued. [signOut] runs from `pvSignOut`
//  BEFORE the session goes: the queued consent first, then
//  `pv_push_unregister`, then FCM's own `deleteToken`. A session that dies on
//  its own (an expired refresh token) has no session left to unregister with,
//  so only the token is deleted on the phone; FCM then answers UNREGISTERED to
//  the next send and B4 drops the row. Consent goes through `PushConsent`
//  whether or not Firebase started: her answer is hers, not this build's.
//
//  Kept for revert (B5 built the second): "Not here yet: permission (the app
//  already asks through flutter_local_notifications), and showing a push that
//  arrives while the app is open (B5). Android first; iPhone is B7."
//
//  B5 (2026-10-30): FOUR MORE THINGS, all only when [ready].
//   * The "Offers and news" channel ([offersChannel]) is created at start, so
//     it exists before the first campaign names it (0146's pv_push_due does).
//   * A push that arrives while the app is OPEN is shown ([showForeground]):
//     FCM draws nothing then, and before B5 it was lost.
//   * A tap on a campaign fills push_sends.tapped_at ([recordTap], through
//     0146's pv_push_tapped), from the `queue` and `row_id` B4 puts in the
//     push data. Only the push_sends queue; a push_tests tap is you checking.
//   * [PushBookings] starts, so the phone gives a booked evening to the
//     campaign.
//  Not here yet: permission (the app already asks through
//  flutter_local_notifications). Android first; iPhone is B7.
//
//  Tests: test/push_b1_test.dart, test/push_b2_contract_test.dart,
//  test/push_b5_test.dart.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_link.dart';
import 'notification_service.dart';
import 'push_bookings.dart';
import 'push_consent.dart';
import 'push_wire.dart';

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

  /// Which link kinds this build's opener knows (`NotificationOpener`).
  /// Sent with the token, so the server can skip a build too old to open a
  /// campaign's link. RAISE IT BY ONE when the opener learns a new kind.
  /// 1 = B0's kinds: the stage messages, product, course, expert, read.
  /// 2 = Community C3-2 (0147): community_post, booking, community_moderation.
  static const int linkVersion = 2;

  /// The Android channel campaigns arrive on (6b B5). 0146's pv_push_due
  /// returns this id for push_sends and push_tests; the contract test pins
  /// the two together. She can turn it off in Android's settings without
  /// losing her care messages, which sit on 'reminders'.
  static const offersChannel = 'offers_news';
  static const offersChannelName = 'Offers and news';
  static const offersChannelDescription =
      'Classes, offers and new things in ParentVeda. Only if you said yes.';

  /// A foreground push's notification id: this band plus a hash of its tag,
  /// so a repeat of the same push replaces itself (as the Android tag does
  /// for a background one) and never lands on a stage message's id.
  static const foregroundIdBase = 939000;

  /// Wires a push that arrives while the app is open. Swapped in tests.
  @visibleForTesting
  static Future<void> Function(
          void Function(String? title, String? body, Map<String, dynamic> data,
                  String? channel)
              onMessage)
      listenForeground = _listenForeground;

  /// This install's id. In LocalWipe.keep: it names the phone, not a person.
  static const deviceIdKey = 'push_device_id';

  /// The FCM token, or null. Swapped in tests.
  ///
  /// ⚠️ DEPRECATED ON PURPOSE. firebase_messaging 17 deprecates the token for
  /// register() / onRegistered, which hand back a Firebase Installation ID for
  /// a newer direct-send path. B4 sends through the HTTP v1 API, whose
  /// documented target is this token. Moving to the installation id is a B4
  /// decision, taken with the sender, not here on its own.
  @visibleForTesting
  static Future<String?> Function() fetchToken =
      // ignore: deprecated_member_use
      () => FirebaseMessaging.instance.getToken();

  /// Deletes this phone's FCM token, so the old one is dead. Swapped in tests.
  @visibleForTesting
  static Future<void> Function() dropToken =
      // ignore: deprecated_member_use
      () => FirebaseMessaging.instance.deleteToken();

  /// Wires sign-in, sign-out and token rotation to this class. Swapped in
  /// tests, where Supabase and Firebase never start.
  @visibleForTesting
  static void Function(PushService s) watchAccount = _watchAccount;

  /// Called once, from `main.dart`, not awaited: a slow or failing Firebase
  /// must never hold the first frame.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    // Kept for revert (B1): a failed start returned here, before anything
    // else. B2 still sends consent with no Firebase, so it falls through.
    try {
      await startFirebase();
      _ready = true;
    } catch (e) {
      debugPrint('[push] off on this build: $e');
    }
    if (_ready) {
      // B5: the channel first, so it exists before any push names it.
      await NotificationService.instance.createChannel(
        id: offersChannel,
        name: offersChannelName,
        description: offersChannelDescription,
      );
      NotificationService.instance.onPayloadTapped = recordTapPayload;
      try {
        await listenForTaps(handleTap);
      } catch (e) {
        debugPrint('[push] tap wiring failed: $e');
      }
      try {
        await listenForeground(showForeground);
      } catch (e) {
        debugPrint('[push] foreground wiring failed: $e');
      }
      // A phone with no Firebase gets no campaign, so it gives no evening
      // away: only a ready build reads bookings.
      unawaited(PushBookings.instance.init());
    }
    // Consent is sent with or without Firebase; the token only with it.
    try {
      watchAccount(this);
    } catch (e) {
      debugPrint('[push] account watch not started: $e');
    }
  }

  /// A session exists (app open, or a sign-in): send any queued consent and,
  /// when Firebase is up, register this install's token.
  Future<void> onSignedIn() async {
    unawaited(PushConsent.instance.flush());
    // B5: tonight may be booked. Only a build that can receive one.
    if (_ready) unawaited(PushBookings.instance.refresh());
    await register();
  }

  /// The session is gone without `pvSignOut` (it expired). There is no
  /// session to unregister with, so the token dies on the phone instead.
  Future<void> onSessionLost() async {
    if (!_ready) return;
    try {
      await dropToken();
    } catch (e) {
      debugPrint('[push] token not deleted: $e');
    }
  }

  /// Registers this install's token. Sent once: a lost register is redone at
  /// the next app open. [token] is FCM's rotated one, when it rotated.
  Future<void> register({String? token}) async {
    if (!_ready || PushWire.userId() == null) return;
    try {
      final t = token ?? await fetchToken();
      if (t == null || t.isEmpty) return;
      await PushWire.call(
        PushWire.register,
        PushWire.registerParams(
          deviceId: await deviceId(),
          token: t,
          platform:
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          linkVersion: linkVersion,
        ),
      );
    } catch (e) {
      debugPrint('[push] token not registered: $e');
    }
  }

  /// From `pvSignOut`, BEFORE `auth.signOut()`: afterwards there is no
  /// session to prove whose row it is. Each step has its own guard and a
  /// time limit, so a dead network never holds the sign-out.
  Future<void> signOut() async {
    const limit = Duration(seconds: 5);
    try {
      await PushConsent.instance.flush().timeout(limit);
    } catch (e) {
      debugPrint('[push] consent still queued at sign-out: $e');
    }
    if (!_ready) return;
    if (PushWire.userId() != null) {
      try {
        await PushWire.call(
          PushWire.unregister,
          PushWire.unregisterParams(await deviceId()),
        ).timeout(limit);
      } catch (e) {
        debugPrint('[push] not unregistered: $e');
      }
    }
    try {
      await dropToken().timeout(limit);
    } catch (e) {
      debugPrint('[push] token not deleted: $e');
    }
  }

  /// This install's id, minted once: 128 random bits as hex.
  static Future<String> deviceId() async {
    final p = await SharedPreferences.getInstance();
    final had = p.getString(deviceIdKey);
    if (had != null && had.isNotEmpty) return had;
    final r = Random.secure();
    final id = [
      for (var i = 0; i < 16; i++)
        r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    await p.setString(deviceIdKey, id);
    return id;
  }

  /// A push was tapped. Its data names the page; the one opener opens it,
  /// and holds it if the app is still starting (a tap that launched the app).
  /// A push with no link only brings the app forward, as the OS already has.
  static void handleTap(Map<String, dynamic> data) {
    recordTap(data);
    final link = NotificationLink.fromData(data);
    if (link == null) return;
    NotificationService.instance.openLink(link);
  }

  /// B5: a tap on a campaign booking fills its tapped_at, once (0146's
  /// pv_push_tapped; the server keeps the first). Fire-and-forget: a tap
  /// lost offline costs one count in a measurement, nothing she sees.
  /// Returns whether a call was made, for tests.
  static bool recordTap(Map<dynamic, dynamic> data) {
    if (data['queue'] != PushWire.queueBookings) return false;
    final rowId = data['row_id'];
    if (rowId is! String || rowId.isEmpty) return false;
    if (PushWire.userId() == null) return false;
    try {
      PushWire.call(PushWire.tapped, PushWire.tappedParams(rowId)).then(
        (_) {},
        onError: (Object e) => debugPrint('[push] tap not recorded: $e'),
      );
    } catch (e) {
      debugPrint('[push] tap not recorded: $e');
    }
    return true;
  }

  /// B5: a tapped local notification's payload. A foreground push carries the
  /// push data as its payload, so its tap is recorded here; a stage message's
  /// payload has no `queue` and passes by.
  static void recordTapPayload(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data is Map) recordTap(data);
    } catch (_) {/* not a push's payload */}
  }

  /// B5: a push that arrived while the app is open. FCM draws nothing then,
  /// so it is shown here: same text, the channel it names (campaigns:
  /// [offersChannel]), the push data as the payload so the tap opens the
  /// page and is recorded. A booking that just went out also refreshes
  /// [PushBookings], so Messages shows it.
  static Future<void> showForeground(String? title, String? body,
      Map<String, dynamic> data, String? channel) async {
    if ((title ?? '').isEmpty && (body ?? '').isEmpty) return;
    final tag = (data['row_id'] as Object?)?.toString() ?? '$title|$body';
    final ch = (channel == null || channel.isEmpty) ? offersChannel : channel;
    await NotificationService.instance.showPush(
      id: foregroundIdBase + foregroundIdOffset(tag),
      title: title ?? '',
      body: body ?? '',
      channelId: ch,
      channelName: ch == offersChannel ? offersChannelName : ch,
      payload: jsonEncode({
        for (final e in data.entries) e.key: e.value?.toString(),
      }),
    );
    if (data['queue'] == PushWire.queueBookings) {
      unawaited(PushBookings.instance.refresh());
    }
  }

  /// A stable 0..999 from [tag]. Not `String.hashCode`, which Dart does not
  /// promise is the same across runs. Pure.
  static int foregroundIdOffset(String tag) {
    var h = 0;
    for (final c in tag.codeUnits) {
      h = (h * 31 + c) % 1000;
    }
    return h;
  }

  /// Test seam: forget that [init] ran.
  @visibleForTesting
  void debugReset() {
    _started = false;
    _ready = false;
  }
}

void _watchAccount(PushService s) {
  Supabase.instance.client.auth.onAuthStateChange.listen((state) {
    switch (state.event) {
      // App open with a session, or a fresh sign-in.
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        if (state.session != null) unawaited(s.onSignedIn());
      case AuthChangeEvent.signedOut:
        unawaited(s.onSessionLost());
      default:
        break;
    }
  }, onError: (Object e) => debugPrint('[push] auth stream: $e'));
  if (s.ready) {
    // ignore: deprecated_member_use
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (t) => unawaited(s.register(token: t)),
      onError: (Object e) => debugPrint('[push] token refresh: $e'),
    );
  }
}

Future<void> _listenForeground(
    void Function(String? title, String? body, Map<String, dynamic> data,
            String? channel)
        onMessage) async {
  FirebaseMessaging.onMessage.listen(
    (m) => onMessage(m.notification?.title, m.notification?.body, m.data,
        m.notification?.android?.channelId),
    onError: (Object e) => debugPrint('[push] foreground message: $e'),
  );
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
