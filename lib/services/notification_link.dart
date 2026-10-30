// =============================================================================
//  NotificationLink - what a notification tap opens, carried IN the notification
// -----------------------------------------------------------------------------
//  Phase 6b, B0 (2026-10-30). Two fields, named the way a server push names
//  them in its data (`link_kind`, `link_id`, docs/NOTIFICATIONS-6B-PLAN.md),
//  so a local notification's payload and a push's data are one shape and one
//  opener ([NotificationOpener] in lib/screens/notification_opener.dart)
//  reads both.
//
//  ⚠️ THE ADDRESS TRAVELS WITH THE MESSAGE. Before B0 a tap gave back only the
//  OS id, and each stage guessed the message from it ("the newest of that
//  kind"): yesterday's tip still in the tray opened today's. A push has no
//  local id at all. Now the notification says what it is about, and the app
//  does not have to remember.
//
//  Pure: no Flutter, no plugin, so a test can pin it.
// =============================================================================

import 'dart:convert';

/// What a stage message tap says when it cannot open its page (B0). The same
/// words in all three stages, so a gap reads the same everywhere.
const String kNotifMessageGone = "That message isn't here any more. Here are your messages.";
const String kNotifPageMissing = "That page isn't available right now. Here are your messages.";
const String kNotifProfileClosed = "That message belongs to a profile that isn't open now.";

class NotificationLink {
  const NotificationLink(this.kind, this.id);

  /// What sort of thing it opens: one of the constants below.
  final String kind;

  /// Which one. Empty when only the kind is known (an old notification whose
  /// message could not be matched).
  final String id;

  // ---- the vocabulary ------------------------------------------------------
  // The stages' own messages (6a). The id is the message id, which is stable:
  // `tip:2026-10-30`, `window:2026-11-02`, `child:<id>|phase:4`.
  static const String ttcMessage = 'ttc_message';
  static const String pregMessage = 'preg_message';
  static const String ppMessage = 'pp_message';

  // What a campaign push links to (6b), the kinds SavedItemOpener already
  // maps. A build that meets a kind it does not know says so (no silent tap).
  static const String product = 'product';
  static const String course = 'course';
  static const String expert = 'expert';
  static const String read = 'read';

  /// The payload string a local notification carries.
  String get payload => jsonEncode({'link_kind': kind, 'link_id': id});

  /// From a local notification's payload. Null for a notification scheduled
  /// before B0 (no payload) or one that is not ours.
  static NotificationLink? parse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final data = jsonDecode(payload);
      return data is Map ? fromData(data) : null;
    } catch (_) {
      return null;
    }
  }

  /// From a push's data map (B1 onwards), the same two keys.
  static NotificationLink? fromData(Map<dynamic, dynamic> data) {
    final kind = data['link_kind'];
    if (kind is! String || kind.isEmpty) return null;
    final id = data['link_id'];
    return NotificationLink(kind, id is String ? id : '');
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationLink && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => 'NotificationLink($kind, $id)';
}
