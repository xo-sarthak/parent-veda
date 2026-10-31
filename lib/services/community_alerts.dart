// =============================================================================
//  CommunityAlerts - her Community alert switches, on the phone (C3-2, 0147)
// -----------------------------------------------------------------------------
//  The server decides who gets an alert and when (0147: the triggers, the
//  queue, the limits). This store only holds what she chose and lets her
//  change it, through three functions: `community_alerts_get`,
//  `community_alerts_set`, `community_post_mute`.
//
//  ⚠️ THE SWITCHES LIVE ON THE SERVER, NOT HERE. A reply alert is queued by a
//  trigger the moment someone replies, while her phone may be off. So her
//  "no" has to be where the trigger can read it. A switch flips on screen at
//  once (optimistic) and flips back with a toast if the server did not take
//  it: a switch that shows "off" while the server still says "on" would be
//  a lie with a buzz attached.
//
//  ⚠️ ASKED ONCE (C8, P0-1). The sheet after her first live post is shown
//  once. "Not now" is recorded on the server as replies = off, which also
//  marks her as asked, and on this phone, so an offline "Not now" is still
//  never asked again here.
//
//  Android channels: "Replies", "Your bookings", "Moderation" (0147's
//  community_push_due names them). Created at start in the parent app only;
//  the doctor app never calls [init] (no push there, 6B decision 6).
//
//  Test: test/community_alerts_test.dart.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote/supabase_repo.dart';
import 'remote/sync_registry.dart';

/// The words her lock screen shows (C2). Fixed in 0147's community_push_text;
/// shown in the app as the preview. No room, title, words or name.
const String kAlertReplyTitle = 'New reply in ParentVeda Community';
const String kAlertReplyBody = 'Someone replied to your post.';
const String kAlertMovedTitle = 'A session you booked has moved';
const String kAlertMovedBody = 'Tap to see the new time.';
const String kAlertModTitle = 'A post may need a moderator now';
const String kAlertModBody = 'Open Moderation to see it.';

/// A post she muted, as Community alerts lists it.
@immutable
class CommunityMutedPost {
  const CommunityMutedPost({
    required this.postId,
    required this.title,
    this.room,
    this.mine = false,
  });
  final String postId;
  final String title;
  final String? room;
  final bool mine;

  static CommunityMutedPost? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['post_id'];
    if (id is! String || id.isEmpty) return null;
    return CommunityMutedPost(
      postId: id,
      title: '${raw['title'] ?? ''}',
      room: raw['room'] as String?,
      mine: raw['mine'] == true,
    );
  }
}

class CommunityAlerts extends ChangeNotifier {
  // Registered when the singleton is first built, so a reset exists from the
  // moment there is anything in memory to forget (see _resetForAccount).
  CommunityAlerts._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final CommunityAlerts instance = CommunityAlerts._();

  // ---- the three server functions (0147) ----------------------------------
  static const fnGet = 'community_alerts_get';
  static const fnSet = 'community_alerts_set';
  static const fnMute = 'community_post_mute';

  /// The switch kinds, as `community_push_consent.kind` spells them.
  static const kindReplies = 'replies';
  static const kindBookings = 'bookings';
  static const kindModeration = 'moderation';

  // ---- the Android channels 0147 names -------------------------------------
  static const channelReplies = 'community_replies';
  static const channelBookings = 'community_bookings';
  static const channelModeration = 'community_moderation';

  /// id -> (name, description). The names are what Android's settings show.
  static const Map<String, (String, String)> channels = {
    channelReplies: (
      'Replies',
      'When someone replies to your post in the Community',
    ),
    channelBookings: (
      'Your bookings',
      'When a session you booked moves to a new time',
    ),
    channelModeration: (
      'Moderation',
      'Moderators only: a post that may need a moderator now',
    ),
  };

  /// This phone already asked (or she answered) the reply-alerts question.
  static const askedKey = 'pv_community_alerts_asked';

  // ---- seams (tests) ---------------------------------------------------------

  @visibleForTesting
  Future<dynamic> Function(String fn, Map<String, dynamic> params)?
  debugBackend;
  @visibleForTesting
  bool? debugSignedIn;

  /// Whether the phone lets ParentVeda notify at all. Swapped in tests.
  static Future<bool> Function() phoneAllows = _phoneAllows;

  /// Android's own "Allow notifications?" question. Only the notification
  /// permission: not NotificationService.requestPermission, which also asks
  /// for exact alarms and can open a settings page mid-sheet. Swapped in
  /// tests.
  static Future<bool> Function() askPhone = _askPhone;

  /// Creates one Android channel. Swapped in tests.
  @visibleForTesting
  static Future<void> Function(String id, String name, String description)
  makeChannel = _makeChannel;

  bool get signedIn => debugSignedIn ?? SupabaseRepo.isLoggedIn;

  Future<dynamic> _call(String fn, [Map<String, dynamic> params = const {}]) {
    final b = debugBackend;
    if (b != null) return b(fn, params);
    return SupabaseRepo.rpcJson(fn, params);
  }

  // ---- state -----------------------------------------------------------------

  bool _loaded = false;
  bool get isLoaded => _loaded;

  bool _replies = false;
  bool _bookings = true;
  bool? _moderation;
  bool _askedServer = false;
  bool _askedHere = false;
  List<CommunityMutedPost> _muted = const [];
  bool _phoneOn = true;

  /// Reply alerts. Off until she says yes (C8).
  bool get replies => _replies;

  /// Moved-session alerts. On from the moment she books (C3).
  bool get bookings => _bookings;

  /// Moderator alerts, or null for a member (the switch is not drawn).
  bool? get moderation => _moderation;

  List<CommunityMutedPost> get muted => _muted;

  /// False when the phone itself blocks ParentVeda's notifications.
  bool get phoneOn => _phoneOn;

  bool isMuted(String postId) => _muted.any((m) => m.postId == postId);

  bool _started = false;

  /// Parent app only, once, from main.dart: the channels, so they exist
  /// before the first push names one. Android sends a push naming an unknown
  /// channel to its default "Miscellaneous", where she could not silence
  /// replies on their own.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    for (final e in channels.entries) {
      try {
        await makeChannel(e.key, e.value.$1, e.value.$2);
      } catch (e) {
        debugPrint('[community alerts] channel not made: $e');
      }
    }
  }

  /// Reads her switches and muted posts. Quiet on failure: the screen keeps
  /// what it had.
  Future<bool> load() async {
    try {
      _phoneOn = await phoneAllows();
    } catch (_) {
      _phoneOn = true;
    }
    final p = await SharedPreferences.getInstance();
    _askedHere = p.getBool(askedKey) ?? false;
    if (!signedIn) {
      _loaded = true;
      notifyListeners();
      return false;
    }
    try {
      final res = await _call(fnGet);
      if (res is Map && res['signed_in'] == true) {
        _replies = res['replies'] == true;
        _bookings = res['bookings'] != false;
        final mod = res['moderation'];
        _moderation = mod is bool ? mod : null;
        _askedServer = res['asked'] == true;
        _muted = [
          for (final m in (res['muted'] as List? ?? const []))
            ?CommunityMutedPost.fromJson(m),
        ];
      }
      _loaded = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[community alerts] not loaded: $e');
      _loaded = true;
      notifyListeners();
      return false;
    }
  }

  /// Should the reply-alerts sheet open now? Only after her own post is live,
  /// only once, only signed in, and never once she has answered anywhere.
  Future<bool> shouldAsk({required bool postIsMineAndLive}) async {
    if (!postIsMineAndLive || !signedIn) return false;
    final p = await SharedPreferences.getInstance();
    if (p.getBool(askedKey) ?? false) return false;
    if (!_loaded) await load();
    return !_askedServer && !_askedHere && !_replies;
  }

  /// Her answer to the sheet. Recorded on this phone first, so an offline
  /// answer is still never asked again here. True when the server took it.
  Future<bool> answerAsk({required bool yes}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(askedKey, true);
    _askedHere = true;
    return setSwitch(kindReplies, yes);
  }

  /// One switch. Optimistic; rolled back if the server did not take it.
  Future<bool> setSwitch(String kind, bool on) async {
    final before = (_replies, _bookings, _moderation);
    _apply(kind, on);
    notifyListeners();
    if (!signedIn) {
      _restore(before);
      return false;
    }
    try {
      final res = await _call(fnSet, {'p_kind': kind, 'p_on': on});
      if (res is Map && res['ok'] == true) {
        if (kind == kindReplies) _askedServer = true;
        return true;
      }
    } catch (e) {
      debugPrint('[community alerts] switch not saved: $e');
    }
    _restore(before);
    return false;
  }

  void _apply(String kind, bool on) {
    switch (kind) {
      case kindReplies:
        _replies = on;
      case kindBookings:
        _bookings = on;
      case kindModeration:
        if (_moderation != null) _moderation = on;
    }
  }

  void _restore((bool, bool, bool?) s) {
    _replies = s.$1;
    _bookings = s.$2;
    _moderation = s.$3;
    notifyListeners();
  }

  /// "Turn off replies for this post", or back on. Optimistic, rolled back
  /// on failure.
  Future<bool> mute(
    String postId, {
    required bool on,
    String title = '',
    String? room,
    bool mine = false,
  }) async {
    final before = _muted;
    _muted = on
        ? [
            CommunityMutedPost(
              postId: postId,
              title: title,
              room: room,
              mine: mine,
            ),
            ..._muted.where((m) => m.postId != postId),
          ]
        : [..._muted.where((m) => m.postId != postId)];
    notifyListeners();
    if (signedIn) {
      try {
        final res = await _call(fnMute, {'p_post': postId, 'p_on': on});
        if (res is Map && res['ok'] == true) return true;
      } catch (e) {
        debugPrint('[community alerts] mute not saved: $e');
      }
    }
    _muted = before;
    notifyListeners();
    return false;
  }

  /// A sign-out, or another account signing in (sync log step 12): forget her
  /// switches, her muted posts and "already asked" in memory. The singleton
  /// lives as long as the process, so without this the next account would see
  /// the last one's switches until `load()` replaced them. The Android
  /// channels (`_started`) belong to the phone, not to her, and stay.
  void _resetForAccount() {
    _loaded = false;
    _replies = false;
    _bookings = true;
    _moderation = null;
    _askedServer = false;
    _askedHere = false;
    _muted = const [];
    notifyListeners();
  }

  /// Test seam: forget everything.
  @visibleForTesting
  void debugReset() {
    _resetForAccount();
    _phoneOn = true;
    _started = false;
    debugBackend = null;
    debugSignedIn = null;
  }
}

Future<bool> _phoneAllows() async {
  try {
    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? true;
  } catch (_) {
    return true;
  }
}

Future<bool> _askPhone() async {
  try {
    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.requestNotificationsPermission() ?? true;
  } catch (_) {
    return true;
  }
}

Future<void> _makeChannel(String id, String name, String description) async {
  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        AndroidNotificationChannel(
          id,
          name,
          description: description,
          // Moderation is louder: someone may be at risk (P0-3).
          importance: id == CommunityAlerts.channelModeration
              ? Importance.high
              : Importance.defaultImportance,
        ),
      );
}
