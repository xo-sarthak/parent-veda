// =============================================================================
//  PushBookings - which evenings the server has given to a campaign
// -----------------------------------------------------------------------------
//  Phase 6b, B5 (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "As built: B5".
//
//  The server books a campaign for 19:00 on an evening the phone said was free
//  (`push_audience.busy_evenings`, B2/B3). That copy can be a few hours stale:
//  she opens the app at 9:00, the server books tonight at 10:00, and at 13:00
//  she logs a period, which makes a TTC message for 19:30. Without this store
//  she would get two that evening. With it, the phone reads its own bookings
//  (push_sends, own-select RLS, 0143) and THE CAMPAIGN GETS THE EVENING: the
//  three planners (`familyPhonePlan`, `parentingPhonePlan`, `ttcPhonePlan`)
//  leave that evening's capped message in Messages without ringing.
//
//  What the cap never governed still rings: a TTC treatment message (her
//  clinic's dates) and, with no pregnancy, a child's moment ("moments always
//  ring", 2026-10-29). An offer never silences care.
//
//  House pattern: singleton `ChangeNotifier`, private constructor, lazy load,
//  `shared_preferences` as a cache so a re-arm with no network still knows
//  tonight is taken. A cloud failure keeps the cache; never a crash.
//
//  ⚠️ THE CACHE IS HER ACCOUNT'S. It is stored with the user id and ignored
//  for anyone else, and the in-memory list is forgotten on sign-out
//  (`SyncRegistry.registerReset`). The phone's dates are local; the server's
//  `send_on` is an IST date. The app is India-first, so they agree; a phone
//  set to another zone could give the wrong evening away, and B7 revisits it.
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ttc/ttc_messages_store.dart' show TtcMessagesStore;
import 'family_phone_plan.dart' show FamilyPhone;
import 'notification_link.dart';
import 'push_wire.dart';
import 'remote/sync_registry.dart';

/// One evening the server has given to a campaign.
@immutable
class PushBooking {
  const PushBooking({
    required this.rowId,
    required this.day,
    required this.status,
    this.title,
    this.body,
    this.linkKind,
    this.linkId,
  });

  /// push_sends.id: the tap's row_id.
  final String rowId;

  /// The evening, as a local date at midnight.
  final DateTime day;

  /// `queued` or `sent`.
  final String status;

  /// The campaign's text, when RLS let her read it (approved and booked).
  final String? title;
  final String? body;
  final String? linkKind;
  final String? linkId;

  /// A tap opens this, or nothing when the campaign was not readable.
  NotificationLink? get link => (linkKind == null || linkKind!.isEmpty)
      ? null
      : NotificationLink(linkKind!, linkId ?? '');

  /// Whether Messages can show it: it has words to show.
  bool get showable => (title ?? '').isNotEmpty;

  /// A row from [PushWire.bookings], or null when it cannot be read.
  static PushBooking? fromRow(Map<String, dynamic> r) {
    final id = r['id'];
    final day = _parseDay(r['send_on']);
    final status = r['status'];
    if (id is! String || day == null || status is! String) return null;
    final c = r['push_campaigns'];
    final camp = c is Map ? c : (c is List && c.isNotEmpty && c.first is Map ? c.first as Map : null);
    String? str(String k) => camp?[k] is String ? camp![k] as String : null;
    return PushBooking(
      rowId: id,
      day: day,
      status: status,
      title: str('title'),
      body: str('body'),
      linkKind: str('link_kind'),
      linkId: str('link_id'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': rowId,
    'send_on': PushWire.dateKey(day),
    'status': status,
    'push_campaigns': {
      'title': title,
      'body': body,
      'link_kind': linkKind,
      'link_id': linkId,
    },
  };

  static DateTime? _parseDay(Object? v) {
    if (v is! String) return null;
    final d = DateTime.tryParse(v);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  @override
  bool operator ==(Object other) =>
      other is PushBooking &&
      other.rowId == rowId &&
      other.day == day &&
      other.status == status &&
      other.title == title &&
      other.body == body &&
      other.linkKind == linkKind &&
      other.linkId == linkId;

  @override
  int get hashCode =>
      Object.hash(rowId, day, status, title, body, linkKind, linkId);
}

/// The evenings in [bookings] that hold a campaign, from [now]'s day on, as
/// local dates at midnight. What the three planners take. Pure.
Set<DateTime> pushBookedEvenings(Iterable<PushBooking> bookings, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return {
    for (final b in bookings)
      if (PushWire.bookingsHolding.contains(b.status) && !b.day.isBefore(today))
        b.day,
  };
}

/// Whether [at] falls in the evening of a booked day: the half of the day the
/// campaign takes (from [eveningFromHour], the planners' own split). Pure.
bool pushEveningBooked(DateTime at, Set<DateTime> booked, int eveningFromHour) =>
    at.hour >= eveningFromHour &&
    booked.contains(DateTime(at.year, at.month, at.day));

class PushBookings extends ChangeNotifier {
  PushBookings._();
  static final PushBookings instance = PushBookings._();

  static const prefsKey = 'push_bookings_v1';

  final List<PushBooking> _all = [];
  bool _loaded = false;
  bool _started = false;

  /// Every booking still holding an evening, soonest first.
  List<PushBooking> get all => List.unmodifiable(_all);

  bool get isLoaded => _loaded;

  /// Re-plans every stage's phone after the bookings changed. TTC arms itself;
  /// FamilyPhone arms Pregnancy and Parenting. Swapped in tests.
  @visibleForTesting
  static Future<void> Function() rearm = () async {
    await TtcMessagesStore.instance.refresh();
    await FamilyPhone.instance.rearm();
  };

  /// The evenings the planners give to a campaign.
  Set<DateTime> bookedEvenings({DateTime? now}) =>
      pushBookedEvenings(_all, now ?? DateTime.now());

  /// Tonight's campaign, for Messages, or null.
  PushBooking? tonight({DateTime? now}) {
    final t = now ?? DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    for (final b in _all) {
      if (b.day == today && b.showable) return b;
    }
    return null;
  }

  /// Once, from `PushService.init`: the cache, then the server. Registers the
  /// refresh with the resume sync and the reset with sign-out.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    SyncRegistry.register(refresh);
    SyncRegistry.registerReset(_forget);
    await _load();
    if (_all.isNotEmpty) unawaited(_rearmQuietly());
    unawaited(refresh());
  }

  /// Reads her bookings from today on. A failure keeps what is cached.
  Future<void> refresh({DateTime? now}) async {
    final uid = PushWire.userId();
    if (uid == null) return;
    final t = now ?? DateTime.now();
    List<Map<String, dynamic>> rows;
    try {
      rows = await PushWire.bookings(PushWire.dateKey(t));
    } catch (e) {
      debugPrint('[push] bookings not read: $e');
      return;
    }
    if (PushWire.userId() != uid) return; // she signed out meanwhile
    final next = [for (final r in rows) PushBooking.fromRow(r)].nonNulls.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    if (listEquals(next, _all)) return;
    _all
      ..clear()
      ..addAll(next);
    _loaded = true;
    await _persist(uid);
    notifyListeners();
    await _rearmQuietly();
  }

  Future<void> _rearmQuietly() async {
    try {
      await rearm();
    } catch (e) {
      debugPrint('[push] re-arm after bookings failed: $e');
    }
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(prefsKey);
      final uid = PushWire.userId();
      if (raw == null || uid == null) return;
      final j = jsonDecode(raw);
      if (j is! Map || j['user'] != uid || j['rows'] is! List) return;
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      _all
        ..clear()
        ..addAll([
          for (final r in j['rows'] as List)
            if (r is Map) PushBooking.fromRow(Map<String, dynamic>.from(r)),
        ].nonNulls.where((b) => !b.day.isBefore(start)));
      notifyListeners();
    } catch (e) {
      debugPrint('[push] bookings cache unreadable: $e');
    } finally {
      _loaded = true;
    }
  }

  Future<void> _persist(String uid) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(prefsKey, jsonEncode({
        'user': uid,
        'rows': [for (final b in _all) b.toJson()],
      }));
    } catch (e) {
      debugPrint('[push] bookings not cached: $e');
    }
  }

  void _forget() {
    _all.clear();
    notifyListeners();
  }

  /// Test seam: set the bookings directly.
  @visibleForTesting
  void debugSet(List<PushBooking> bookings) {
    _all
      ..clear()
      ..addAll(bookings);
    _loaded = true;
    notifyListeners();
  }

  /// Test seam: forget everything, including that [init] ran.
  @visibleForTesting
  void debugReset() {
    _all.clear();
    _loaded = false;
    _started = false;
  }
}
