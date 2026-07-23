// =============================================================================
//  BookingStore — the mother's entitlements, bookings and one history
// -----------------------------------------------------------------------------
//  Holds what SHE owns: the entitlements she has bought and the slots she has
//  booked, across BOTH stages, in one place. Shared data — the offerings and
//  the live seat counts on each slot — does not live here; that is backend, and
//  the booking action itself will go through a server RPC so a seat cap is
//  enforced against everyone at once, not just this device. This store is the
//  local-first record of her side of it, synced per-user via CloudSyncedStore
//  exactly like BrandStudioStore, so her history follows her across devices.
//
//  Until the backend RPC lands, [book] records optimistically against a slot
//  passed in and spends a credit locally — enough to build and demo the whole
//  flow. When the RPC arrives, [book] gains a server round-trip in front of the
//  same local write; nothing else in the app changes.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_synced_store.dart';
import '../services/remote/supabase_repo.dart';
import 'booking_models.dart';

class BookingStore extends ChangeNotifier with CloudSyncedStore {
  BookingStore._();
  static final BookingStore instance = BookingStore._();

  static const _key = 'booking_v1';

  @override
  String get cloudKey => _key;

  /// Monotonic tie-breaker. microsecondsSinceEpoch alone collides when two
  /// records are minted in the same microsecond — two quick taps, or a test —
  /// and the collision silently overwrites the first in the map. The counter
  /// makes every id unique regardless of clock resolution.
  int _seq = 0;
  String _uid(String prefix, DateTime at) =>
      '${prefix}_${at.microsecondsSinceEpoch}_${_seq++}';

  /// entitlementId -> entitlement.
  final Map<String, Entitlement> _entitlements = {};

  /// bookingId -> booking. Both stages; filter on read.
  final Map<String, Booking> _bookings = {};

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {/* start fresh */}
    _loaded = true;
    _reconcileStatuses();
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  // ---- reads ----------------------------------------------------------------

  /// Every entitlement, newest purchase first.
  List<Entitlement> entitlements({ServiceStage? stage}) {
    final all = _entitlements.values
        .where((e) => stage == null || e.stage == stage)
        .toList()
      ..sort((a, b) => b.purchasedUtc.compareTo(a.purchasedUtc));
    return all;
  }

  /// The active entitlement for an offering that still has credits, if any.
  Entitlement? activeEntitlementFor(String offeringId) {
    final matches = _entitlements.values
        .where((e) => e.offeringId == offeringId && e.canBook)
        .toList()
      ..sort((a, b) => a.purchasedUtc.compareTo(b.purchasedUtc)); // spend oldest first
    return matches.isEmpty ? null : matches.first;
  }

  bool ownsRecording(String offeringId) => _entitlements.values.any(
      (e) => e.offeringId == offeringId && e.recordingAccess && !e.isExpired);

  bool hasThread(String offeringId) => _entitlements.values.any(
      (e) => e.offeringId == offeringId && e.discussionThread && !e.isExpired);

  /// The one history — every booking, newest session first, optionally by stage.
  List<Booking> bookings({ServiceStage? stage}) {
    final all = _bookings.values
        .where((b) => stage == null || b.stage == stage)
        .toList()
      ..sort((a, b) => b.startsUtc.compareTo(a.startsUtc));
    return all;
  }

  /// Upcoming only, soonest first — what "My Bookings" leads with.
  List<Booking> upcoming({ServiceStage? stage}) {
    final now = DateTime.now().toUtc();
    final all = _bookings.values
        .where((b) =>
            b.status == BookingStatus.upcoming &&
            b.endsUtc.isAfter(now) &&
            (stage == null || b.stage == stage))
        .toList()
      ..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));
    return all;
  }

  /// The very next session across both stages, or null. What a home-screen
  /// "your next class" card reads.
  Booking? get nextUp {
    final u = upcoming();
    return u.isEmpty ? null : u.first;
  }

  bool alreadyBookedSlot(String slotId) =>
      _bookings.values.any((b) =>
          b.slotId == slotId && b.status != BookingStatus.cancelled);

  // ---- writes ---------------------------------------------------------------

  /// Record a purchase. Mints an entitlement from the offering's grant. (The
  /// real charge happens before this once payments are live; for now it is the
  /// purchase.) Returns the new entitlement.
  Entitlement purchase(Offering offering, {DateTime? at}) {
    final now = (at ?? DateTime.now()).toUtc();
    final e = Entitlement(
      id: _uid('ent', now),
      offeringId: offering.id,
      stage: offering.stage,
      title: offering.title,
      creditsTotal: offering.grant.credits,
      creditsUsed: 0,
      purchasedUtc: now,
      expiresUtc: offering.grant.validFor == null
          ? null
          : now.add(offering.grant.validFor!),
      recordingAccess: offering.grant.recordingAccess,
      discussionThread: offering.grant.discussionThread,
    );
    _entitlements[e.id] = e;
    _save();
    return e;
  }

  /// Spend one credit to claim a slot. Returns the booking, or null if she has
  /// no bookable entitlement, the slot is full, or she already holds it.
  ///
  /// Optimistic + local for now; the server RPC will front this with an atomic
  /// seat-claim and hand back the authoritative row, which replaces this one.
  Booking? book(Slot slot, {DateTime? at}) {
    if (alreadyBookedSlot(slot.id)) return null;
    if (slot.isFull) return null;
    final ent = activeEntitlementFor(slot.offeringId);
    if (ent == null) return null;

    final now = (at ?? DateTime.now()).toUtc();
    final b = Booking(
      id: _uid('bkg', now),
      offeringId: slot.offeringId,
      slotId: slot.id,
      stage: ent.stage,
      title: ent.title,
      startsUtc: slot.startsUtc,
      durationMin: slot.durationMin,
      status: BookingStatus.upcoming,
      bookedUtc: now,
      joinUrl: slot.joinUrl,
    );
    _bookings[b.id] = b;
    _entitlements[ent.id] = ent.copyWith(creditsUsed: ent.creditsUsed + 1);
    _save();
    return b;
  }

  /// Book, going through the SERVER seat-claim when logged in (0029's
  /// book_slot RPC), and falling back to the local optimistic [book] when
  /// offline or logged out. This is what the UI calls.
  ///
  /// Logged in: the RPC is the authority on the seat, so we only record locally
  /// AFTER it grants one — no optimistic row that a full slot would strand.
  /// Offline: exactly the old local behaviour, reconciled on the next sync.
  Future<Booking?> reserve(Slot slot, {DateTime? at}) async {
    if (alreadyBookedSlot(slot.id)) return null;
    if (slot.isFull) return null;
    final ent = activeEntitlementFor(slot.offeringId);
    if (ent == null) return null;

    if (!SupabaseRepo.isLoggedIn) return book(slot, at: at);

    final now = (at ?? DateTime.now()).toUtc();
    final bookingId = _uid('bkg', now);
    final granted = await SupabaseRepo.bookSlot(
      bookingId: bookingId,
      slotId: slot.id,
      offeringId: slot.offeringId,
      expertId: slot.expertId,
      startsUtc: slot.startsUtc,
      durationMin: slot.durationMin,
      capacity: slot.capacity,
      stage: ent.stage.name,
      title: ent.title,
      joinUrl: slot.joinUrl,
    );
    if (!granted) return null; // server refused the seat

    final b = Booking(
      id: bookingId,
      offeringId: slot.offeringId,
      slotId: slot.id,
      stage: ent.stage,
      title: ent.title,
      startsUtc: slot.startsUtc,
      durationMin: slot.durationMin,
      status: BookingStatus.upcoming,
      bookedUtc: now,
      joinUrl: slot.joinUrl,
    );
    _bookings[b.id] = b;
    _entitlements[ent.id] = ent.copyWith(creditsUsed: ent.creditsUsed + 1);
    _save();
    return b;
  }

  /// Cancel through the server (frees the seat via cancel_booking) then locally.
  Future<bool> release(String bookingId) async {
    await SupabaseRepo.cancelBooking(bookingId);
    return cancel(bookingId);
  }

  /// Cancel an upcoming booking and refund its credit. Returns true if a
  /// booking was cancelled.
  bool cancel(String bookingId, {bool refundCredit = true}) {
    final b = _bookings[bookingId];
    if (b == null || b.status != BookingStatus.upcoming) return false;
    _bookings[bookingId] = b.copyWith(status: BookingStatus.cancelled);
    if (refundCredit) {
      final ent = activeEntitlementForCancel(b.offeringId);
      if (ent != null && ent.creditsUsed > 0) {
        _entitlements[ent.id] = ent.copyWith(creditsUsed: ent.creditsUsed - 1);
      }
    }
    _save();
    return true;
  }

  /// The entitlement to refund a credit back onto — the most recently spent one
  /// for this offering.
  @visibleForTesting
  Entitlement? activeEntitlementForCancel(String offeringId) {
    final matches = _entitlements.values
        .where((e) => e.offeringId == offeringId && e.creditsUsed > 0)
        .toList()
      ..sort((a, b) => b.purchasedUtc.compareTo(a.purchasedUtc));
    return matches.isEmpty ? null : matches.first;
  }

  /// Move past bookings out of "upcoming": anything whose session has ended is
  /// marked attended (we cannot yet know real attendance, so ended == attended;
  /// the RPC will carry true attendance later). Runs at startup.
  void _reconcileStatuses() {
    final now = DateTime.now().toUtc();
    var changed = false;
    for (final entry in _bookings.entries.toList()) {
      final b = entry.value;
      if (b.status == BookingStatus.upcoming && b.endsUtc.isBefore(now)) {
        _bookings[entry.key] = b.copyWith(status: BookingStatus.attended);
        changed = true;
      }
    }
    if (changed) _save();
  }

  @visibleForTesting
  void resetAll() {
    _entitlements.clear();
    _bookings.clear();
    _save();
  }

  // ---- persistence ----------------------------------------------------------

  Map<String, Object?> _toMap() => {
        'entitlements': _entitlements.values.map((e) => e.toMap()).toList(),
        'bookings': _bookings.values.map((b) => b.toMap()).toList(),
      };

  void _apply(Map data) {
    _entitlements.clear();
    _bookings.clear();
    for (final raw in (data['entitlements'] as List? ?? const [])) {
      final e = Entitlement.fromMap(raw as Map);
      _entitlements[e.id] = e;
    }
    for (final raw in (data['bookings'] as List? ?? const [])) {
      final b = Booking.fromMap(raw as Map);
      _bookings[b.id] = b;
    }
  }

  Future<void> _save() async {
    notifyListeners(); // CloudSyncedStore pushes the blob on notify
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort local cache */}
  }

  // ---- CloudSyncedStore ------------------------------------------------------

  @override
  Object cloudData() => _toMap();

  @override
  void applyCloudData(Object data) => _apply(data as Map);

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
