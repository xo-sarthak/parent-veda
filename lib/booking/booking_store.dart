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
//
//  L2c (2026-10-29): WHAT SHE OWNS IS THE SERVER'S ANSWER. Signed in, an
//  entitlement is DERIVED from a server receipt (`my_purchases()`, 0126) plus
//  the gift credits a reward grants - never from a row the phone minted.
//  [acquire] is the one way to buy: it asks the server to write the receipt
//  (verify, a free claim, or the stub preview) and then reads it back.
//  [purchase] stays for the signed-out / test seam only; it has no production
//  caller. The general shape: the phone holds a CACHE of a server decision,
//  and a cache that can grant something is not a cache (LEARNING-ARCHITECTURE
//  section 1, LA-5).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/cloud_synced_store.dart';
import '../services/remote/supabase_repo.dart';
import '../care_partner/care_journey.dart';
import 'booking_catalog.dart';
import 'booking_models.dart';
import 'payment_service.dart';

/// What [BookingStore.acquire] came back with.
enum AcquireStatus {
  /// The server holds an active receipt and the phone has read it.
  owned,

  /// Money was taken and verified, but the receipt has not reached the phone
  /// yet (verify's write failed and the webhook will retry). Never "failed":
  /// telling her a payment failed when it did not is the worse error.
  pending,

  /// Nothing was granted. [AcquireResult.message] says why, in her words.
  refused,

  /// She closed the payment sheet. Say nothing.
  cancelled,
}

class AcquireResult {
  const AcquireResult(this.status, [this.message]);
  final AcquireStatus status;
  final String? message;
  bool get owned => status == AcquireStatus.owned;
}

/// Her sentence for a refund the rule refused. The reasons are 0126's
/// `_refund_check` words; the rule itself is never re-derived on the phone.
String pvRefundRefusal(String reason) => switch (reason) {
      'window_closed' => 'The refund window for this has closed.',
      'lessons_opened' =>
        'A course can be refunded while you have opened no more than lesson 1.',
      'support_only' =>
        'Consults and class packs are refunded by our support team. Write to '
            'us from Help and we will sort it.',
      'nothing_paid' => 'This was free, so there is nothing to refund.',
      'refund_requested' => 'A refund is already on its way.',
      'refunded' => 'This has already been refunded.',
      _ => "We couldn't refund this from the app. Write to us from Help.",
    };

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

  /// The server's receipts (`my_purchases()`), newest first. A cache: written
  /// only from the server's answer, kept in prefs so the page renders offline,
  /// and NOT in the synced blob - the server already holds the record, and a
  /// second copy in user_state is a second place for it to disagree.
  final List<Purchase> _receipts = [];
  static const _receiptsKey = 'booking_receipts_v1';

  /// Whose receipts these are. The cache is per ACCOUNT, not per phone: a
  /// sign-out and a different sign-in must never show the last person's
  /// purchases for the second it takes to re-read them. Receipts count only
  /// while this matches the signed-in user.
  String? _receiptsUid;

  /// Tests only: who is "signed in", without a Supabase session. Unset in the
  /// app, where the signed-in user is [SupabaseRepo.userId].
  @visibleForTesting
  String? debugUid;

  String? get _who => debugUid ?? SupabaseRepo.userId;
  bool get _signedIn => _who != null;

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
      final rc = prefs.getString(_receiptsKey);
      if (rc != null) {
        final m = jsonDecode(rc) as Map;
        _applyReceipts(m['rows'] as List? ?? const [], m['uid']?.toString());
      }
    } catch (_) {/* start fresh */}
    _loaded = true;
    _reconcileStatuses();
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
    // AFTER the blob, deliberately. syncStateFromCloud adopts the cached blob
    // with "cloud wins", which CLEARS _bookings and refills from it; hydrating
    // first would be undone a line later.
    try {
      await _hydrateFromServer();
    } catch (e) {
      debugPrint('[booking] server hydrate failed: $e');
    }
    await syncPurchases();
  }

  // ---- receipts (L2c) --------------------------------------------------------

  /// Re-read `my_purchases()`. Returns false when the server could not be
  /// asked (signed out, offline) - the cached receipts then stand, because
  /// "we could not check" is not "she owns nothing".
  Future<bool> syncPurchases() async {
    if (!SupabaseRepo.isLoggedIn) return false;
    try {
      final uid = SupabaseRepo.userId;
      final res = await SupabaseRepo.rpcJson('my_purchases');
      if (res is! List) return false;
      _applyReceipts(res, uid);
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _receiptsKey, jsonEncode({'uid': uid, 'rows': res}));
      } catch (_) {/* best-effort cache */}
      return true;
    } catch (e) {
      debugPrint('[booking] my_purchases failed: $e');
      return false;
    }
  }

  // ---- recordings (0128, L.22) ---------------------------------------------
  //
  // Which past sessions have a recording she may watch, keyed by slot. Held
  // in memory only, on purpose: a recording plays over the network anyway,
  // so an offline Past row that says nothing about it loses nothing, and a
  // cached "ready" could outlive a refund. Never a playback id: that is
  // handed out signed and short-lived by recording-playback.
  final Map<String, Map<String, dynamic>> _recordingsBySlot = {};

  /// The recording of [slotId] she may watch, or null. Keys: id, status
  /// (recording | uploaded | importing | ready), title, duration_s.
  Map<String, dynamic>? recordingForSlot(String slotId) =>
      _recordingsBySlot[slotId];

  Future<void> syncRecordings() async {
    if (!SupabaseRepo.isLoggedIn) return;
    final rows = await SupabaseRepo.myRecordings();
    _recordingsBySlot
      ..clear()
      ..addEntries(rows
          .where((r) => (r['slot_id'] ?? '').toString().isNotEmpty)
          .map((r) => MapEntry(r['slot_id'].toString(), r)));
    notifyListeners();
  }

  void _applyReceipts(List rows, String? uid) {
    _receiptsUid = uid;
    _receipts
      ..clear()
      ..addAll(rows.whereType<Map>().map(Purchase.fromRow))
      ..sort((a, b) => b.paidUtc.compareTo(a.paidUtc));
  }

  /// Every receipt, newest first: Your bookings' Payments section (L.22).
  /// Empty when signed out, or until this account's receipts have been read.
  List<Purchase> get purchases => _mine.toList(growable: false);

  Iterable<Purchase> get _mine => _signedIn && _receiptsUid == _who
      ? _receipts
      : const <Purchase>[];

  /// Buy [offering] after checkout answered [paid]. The ONE way the app comes
  /// to own something.
  ///
  /// Every branch ends with the server's receipt or with nothing:
  ///
  ///   paid / alreadyOwned  verify (or the webhook) wrote it; read it back
  ///   free                 `claim_free_offering` writes a real receipt
  ///   notConfigured        `record_stub_purchase` - the no-charge preview,
  ///                        which the SERVER refuses once payment_mode is live
  ///
  /// The last one is LA-7's fix. Before L2c the phone decided that "payments
  /// are not configured" meant "free"; a release build could do it. Now the
  /// phone only asks, and one row on the server answers for every build.
  Future<AcquireResult> acquire(Offering offering, PaymentResult paid) async {
    switch (paid.outcome) {
      case PaymentOutcome.cancelled:
        return const AcquireResult(AcquireStatus.cancelled);
      case PaymentOutcome.failed:
        return AcquireResult(AcquireStatus.refused,
            paid.message ?? 'Payment did not go through.');
      case PaymentOutcome.signedOut:
        return const AcquireResult(AcquireStatus.refused,
            'Sign in to buy. What you buy is kept on your account, so it '
            'follows you to a new phone.');
      case PaymentOutcome.unpriced:
        return const AcquireResult(AcquireStatus.refused,
            "This opens when a specialist joins. We'll add them here.");
      case PaymentOutcome.paid:
      case PaymentOutcome.alreadyOwned:
        break;
      case PaymentOutcome.free:
        final r = await _ask('claim_free_offering', offering.id);
        if (r != null) return r;
      case PaymentOutcome.notConfigured:
        final r = await _ask('record_stub_purchase', offering.id);
        if (r != null) return r;
    }

    await syncPurchases();
    if (_activeReceiptFor(offering.id) != null) {
      if (paid.outcome != PaymentOutcome.alreadyOwned) CareJourney.purchased();
      return const AcquireResult(AcquireStatus.owned);
    }
    if (paid.outcome == PaymentOutcome.paid) {
      return const AcquireResult(AcquireStatus.pending,
          'Your payment went through. It can take a minute to show here; '
          'it will appear in Your bookings.');
    }
    return const AcquireResult(AcquireStatus.refused,
        "We couldn't confirm that just now. Nothing was charged. Try again.");
  }

  /// Call a 0126 grant function. Null when it granted; a refusal otherwise.
  Future<AcquireResult?> _ask(String fn, String offeringId) async {
    try {
      final res =
          await SupabaseRepo.rpcJson(fn, {'p_offering_id': offeringId});
      if (res is Map && res['ok'] == true) return null;
      final reason = res is Map ? (res['reason'] ?? '').toString() : '';
      return AcquireResult(AcquireStatus.refused, switch (reason) {
        'live_mode' => 'Payments are switching on. Try again in a moment.',
        'unknown_offering' =>
          "This opens when a specialist joins. We'll add them here.",
        'not_free' => 'This one has a price now. Open it again to see it.',
        'not_signed_in' || '' => 'Sign in to buy.',
        _ => "We couldn't confirm that just now. Nothing was charged.",
      });
    } catch (e) {
      debugPrint('[booking] $fn failed: $e');
      return const AcquireResult(AcquireStatus.refused,
          "We couldn't reach ParentVeda. Nothing was charged. Try again.");
    }
  }

  /// Ask for a refund (L.12). The server applies the rule and answers; the
  /// phone shows the answer. Returns her sentence.
  Future<String> requestRefund(Purchase p) async {
    try {
      final res = await SupabaseRepo.rpcJson(
          'request_refund', {'p_purchase_id': p.id});
      // Both halves: the receipt's new status, and the upcoming seats a
      // refund cancels (refreshFromServer re-reads receipts as well).
      await refreshFromServer();
      if (res is Map && res['ok'] == true) {
        return res['status'] == 'refunded'
            ? 'Refunded. This was a test purchase, so no money moved.'
            : 'Refund requested. Your access has ended, and the money reaches '
                'your account in 5 to 7 working days.';
      }
      final reason = res is Map ? (res['reason'] ?? '').toString() : '';
      return pvRefundRefusal(reason);
    } catch (e) {
      debugPrint('[booking] request_refund failed: $e');
      return "We couldn't reach ParentVeda. Nothing has changed. Try again.";
    }
  }

  /// Tell the server a lesson was opened. The course refund rule counts these
  /// (0126 `_refund_check`: refundable while no more than lesson 1 is opened),
  /// so this is what makes "7 days, if you have opened no more than lesson
  /// 1" true. Fire-and-forget: a lesson must never wait on the network.
  void recordLessonOpen(String programmeId, String lessonId) {
    if (!SupabaseRepo.isLoggedIn) return;
    SupabaseRepo.rpcJson('record_lesson_open', {
      'p_programme_id': programmeId,
      'p_lesson_id': lessonId,
    }).catchError((_) => null);
  }

  Purchase? _activeReceiptFor(String offeringId) {
    for (final p in _mine) {
      if (p.offeringId == offeringId && p.isActive) return p;
    }
    return null;
  }

  /// The entitlements the receipts imply. DERIVED, never stored: credits used
  /// is counted from her bookings each time, so a cancelled booking hands its
  /// credit back without anyone remembering to.
  List<Entitlement> _fromReceipts() {
    final out = <Entitlement>[];
    final byOffering = <String, List<Purchase>>{};
    for (final p in _mine.where((p) => p.isActive)) {
      byOffering.putIfAbsent(p.offeringId, () => []).add(p);
    }
    byOffering.forEach((offeringId, list) {
      list.sort((a, b) => a.paidUtc.compareTo(b.paidUtc)); // spend oldest first
      var used = _bookings.values
          .where((b) =>
              b.offeringId == offeringId && b.status != BookingStatus.cancelled)
          .length;
      final o = BookingCatalog.instance.offeringById(offeringId);
      for (final p in list) {
        final grant = o?.grant ?? _grantForKind(p.kind);
        final total = grant.credits;
        final take = used.clamp(0, total);
        used -= take;
        out.add(Entitlement(
          id: 'ent_rcp_${p.id}',
          offeringId: offeringId,
          stage: o?.stage ?? p.stage ?? ServiceStage.parenting,
          title: o?.title ?? p.title,
          creditsTotal: total,
          creditsUsed: take,
          purchasedUtc: p.paidUtc,
          expiresUtc:
              grant.validFor == null ? null : p.paidUtc.add(grant.validFor!),
          recordingAccess: grant.recordingAccess,
          discussionThread: grant.discussionThread,
        ));
      }
    });
    return out;
  }

  /// A receipt for something this build's catalogue no longer lists (a panel
  /// programme, or one retired): the grant its server kind implies (L.13).
  static EntitlementGrant _grantForKind(String kind) => switch (kind) {
        'course' => const EntitlementGrant(recordingAccess: true),
        'masterclass' => const EntitlementGrant(
            credits: 1, recordingAccess: true, discussionThread: true),
        'cohort' => const EntitlementGrant(credits: 1, discussionThread: true),
        _ => const EntitlementGrant(credits: 1),
      };

  /// What counts as hers. Signed in: receipts plus gift credits. Signed out
  /// (and in tests): the local entitlements, as before L2c - a signed-out
  /// phone cannot buy any more, so the only rows it can hold are a reward or
  /// a test's.
  ///
  /// The phone-minted entitlements of the pre-L2c preview stay in the blob
  /// untouched (kept, not deleted) but stop counting once she is signed in.
  Iterable<Entitlement> get _owned sync* {
    if (!_signedIn) {
      yield* _entitlements.values;
      return;
    }
    yield* _entitlements.values.where((e) => e.id.startsWith('ent_gift_'));
    yield* _fromReceipts();
  }

  /// Re-read the server's bookings on demand — pull-to-refresh, or returning
  /// to the app. Public because "wait for the next launch" is not an answer a
  /// parent should ever be given about their own appointment.
  Future<void> refreshFromServer() async {
    try {
      await _hydrateFromServer();
    } catch (e) {
      debugPrint('[booking] refresh failed: $e');
    }
    await syncPurchases(); // L2c: what she owns is the server's too
    await syncRecordings(); // L3: what she may watch again
  }

  /// Adopt the authoritative `booking_bookings` rows for this user.
  ///
  /// WHY THIS EXISTS — the bug it fixes is worth stating, because the symptom
  /// pointed away from the cause. A parent booked, the doctor saw it, and on
  /// the parent's next launch "nothing booked yet". Two sources of truth:
  ///
  ///     doctor  -> expert_roster()  -> booking_bookings   (the table)
  ///     parent  -> user_state blob  -> whatever was last pushed  (a cache)
  ///
  /// The blob push is fire-and-forget (`.catchError((_) {})`), so a failed
  /// push is silent — and `syncStateFromCloud` then re-adopts the OLDER blob
  /// on every start, wiping the booking from the phone while the row sat
  /// untouched in Postgres. A cache that can overwrite the record is not a
  /// cache; that is the actual defect, and this is the line that ends it.
  ///
  /// THE MERGE IS IDEMPOTENT because the APP generates the booking id, so a
  /// local row and its server copy share one identity — the rule stated in
  /// CLAUDE.md. Nothing here needs to guess whether two rows are "the same
  /// booking", which is what makes re-running this safe.
  ///
  /// WHAT THE SERVER IS NOT ALLOWED TO DO. It may add a booking this device
  /// has never seen, and it may CANCEL one. It may NOT push a booking back to
  /// `upcoming` once this device has marked it attended: _reconcileStatuses()
  /// calls CareJourney.consultationDone() exactly once on that transition, and
  /// re-opening a finished booking would let the count climb by one on every
  /// launch. (Superseded 2026-10-29: "the server does not track attendance
  /// yet" stopped being true with 0078 and 0128; it may now settle attended
  /// and missed, see the branch below. Still never back to upcoming.)
  ///
  /// Local-only bookings — made offline, never granted a seat — are left
  /// alone. Absence from the server is not evidence of deletion when the
  /// device may simply not have reached it yet.
  Future<void> _hydrateFromServer() async {
    if (!SupabaseRepo.isLoggedIn) return;
    final rows = await SupabaseRepo.fetch('booking_bookings');
    if (rows.isEmpty) return;

    var changed = false;
    for (final r in rows) {
      final remote = Booking.fromRow(r);
      if (remote.id.isEmpty) continue;
      final local = _bookings[remote.id];

      if (local == null) {
        _bookings[remote.id] = remote; // the case that was being lost
        changed = true;
      } else if (remote.status == BookingStatus.cancelled &&
          (local.status != BookingStatus.cancelled ||
              local.cancelReason != remote.cancelReason)) {
        // Cancelled elsewhere — a seat this device must stop offering to join.
        // (0128) With the server's reason, so Past can say "the host could
        // not make it" instead of a bare "Cancelled".
        _bookings[remote.id] = local.copyWith(
            status: remote.status, cancelReason: remote.cancelReason);
        changed = true;
      } else if ((remote.status == BookingStatus.missed &&
              local.status != BookingStatus.missed &&
              local.status != BookingStatus.cancelled) ||
          (remote.status == BookingStatus.attended &&
              local.status == BookingStatus.missed)) {
        // (0128, LA-16) The server now settles attendance from what LiveKit
        // saw, so on THIS field it knows more than the device, which can only
        // guess "ended == attended". Adopt its attended / missed verdict,
        // with one exception kept from the rule above: upcoming -> attended
        // is left to _reconcileStatuses below, because that transition is
        // what fires CareJourney.consultationDone() exactly once. Never back
        // to upcoming.
        _bookings[remote.id] = local.copyWith(status: remote.status);
        changed = true;
      }
    }

    if (changed) {
      // Newly adopted rows may already be in the past on this device's clock.
      _reconcileStatuses();
      await _save(); // writes the local cache AND re-pushes the blob
    }
  }

  // ---- reads ----------------------------------------------------------------

  /// Every entitlement, newest purchase first.
  List<Entitlement> entitlements({ServiceStage? stage}) {
    final all = _owned
        .where((e) => stage == null || e.stage == stage)
        .toList()
      ..sort((a, b) => b.purchasedUtc.compareTo(a.purchasedUtc));
    return all;
  }

  /// An entitlement bought FOR this specific offering, if any.
  Entitlement? _exactEntitlementFor(String offeringId) {
    final matches = _owned
        .where((e) => e.offeringId == offeringId && e.canBook)
        .toList()
      ..sort((a, b) => a.purchasedUtc.compareTo(b.purchasedUtc)); // spend oldest first
    return matches.isEmpty ? null : matches.first;
  }

  Entitlement? activeEntitlementFor(String offeringId) {
    final exact = _exactEntitlementFor(offeringId);
    if (exact != null) return exact;

    // FLOATING CREDITS. A referral reward is "a free consultation", not a free
    // consultation with one particular doctor - so it is minted against
    // [kAnyConsultOffering] and spends on any consult. Bought credits are
    // preferred (checked first) so a parent's own purchase is used before the
    // gift they were given, which is the order that leaves them better off.
    final offering = BookingCatalog.instance.offeringById(offeringId);
    if (offering?.kind != OfferingKind.consult) return null;
    return _exactEntitlementFor(kAnyConsultOffering);
  }

  bool ownsRecording(String offeringId) => _owned.any(
      (e) => e.offeringId == offeringId && e.recordingAccess && !e.isExpired);

  bool hasThread(String offeringId) => _owned.any(
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
  /// One booking by its id, or null. The map has always been keyed this way;
  /// nothing outside the store could reach it.
  Booking? byId(String id) => _bookings[id];

  Booking? get nextUp {
    final u = upcoming();
    return u.isEmpty ? null : u.first;
  }

  bool alreadyBookedSlot(String slotId) =>
      _bookings.values.any((b) =>
          b.slotId == slotId && b.status != BookingStatus.cancelled);

  // ---- writes ---------------------------------------------------------------

  /// Grant a floating consultation credit — a REWARD, not a purchase.
  ///
  /// [sourceId] makes this idempotent: the entitlement id is derived from it,
  /// so re-syncing the same referral reward from the server overwrites the same
  /// row instead of minting a second free consultation. Getting this wrong is
  /// how a referral system quietly gives away unlimited credit.
  Entitlement grantFloatingCredit({
    required String sourceId,
    required String title,
    int credits = 1,
    Duration? validFor = const Duration(days: 90),
    DateTime? at,
  }) {
    final id = 'ent_gift_$sourceId';
    final existing = _entitlements[id];
    if (existing != null) return existing; // already granted — never twice

    final now = (at ?? DateTime.now()).toUtc();
    final e = Entitlement(
      id: id,
      offeringId: kAnyConsultOffering,
      stage: ServiceStage.pregnancy,
      title: title,
      creditsTotal: credits,
      creditsUsed: 0,
      purchasedUtc: now,
      expiresUtc: validFor == null ? null : now.add(validFor),
    );
    _entitlements[id] = e;
    _save();
    notifyListeners();
    return e;
  }

  /// MAKE the local floating credit for [sourceId] equal [credits].
  ///
  /// Not a grant — a mirror. [grantFloatingCredit] is deliberately grant-once:
  /// it returns the existing row untouched, because minting a referral reward
  /// twice is how a referral system gives away unlimited credit.
  ///
  /// That is exactly wrong for a copy of a server-side number (0066). A credit
  /// that has been spent, voided or has expired must stop being advertised, and
  /// a grant-once helper can only ever count upward — leaving a Book button on
  /// screen that fails at the last step, which is worse than never offering it.
  ///
  /// So: sets the total, and REMOVES the row at zero. Passing 0 is meaningful
  /// here and refused there, which is the whole difference between the two.
  void mirrorFloatingCredit({
    required String sourceId,
    required String title,
    required int credits,
    Duration? validFor = const Duration(days: 365),
    DateTime? at,
  }) {
    final id = 'ent_gift_$sourceId';
    final existing = _entitlements[id];

    if (credits <= 0) {
      if (existing == null) return;
      _entitlements.remove(id);
      _save();
      notifyListeners();
      return;
    }

    if (existing != null &&
        existing.creditsTotal == credits &&
        existing.creditsUsed == 0) {
      return; // already correct — do not churn listeners on every launch
    }

    final now = (at ?? DateTime.now()).toUtc();
    _entitlements[id] = Entitlement(
      id: id,
      offeringId: kAnyConsultOffering,
      stage: ServiceStage.pregnancy,
      title: title,
      creditsTotal: credits,
      // Always zero: "how many are left" is the server's answer now, and
      // tracking spends locally as well would create a second number that
      // disagrees with it the first time a booking is cancelled.
      creditsUsed: 0,
      purchasedUtc: existing?.purchasedUtc ?? now,
      expiresUtc: validFor == null ? null : now.add(validFor),
    );
    _save();
    notifyListeners();
  }

  /// Record a purchase LOCALLY. Mints an entitlement from the offering's grant.
  ///
  /// NO PRODUCTION CALLER SINCE L2c (2026-10-29). The flows call [acquire],
  /// which reads the server's receipt. This stays for the signed-out seam the
  /// engine tests drive, and for revert; signed in, what it mints does not
  /// count (see [_owned]).
  @visibleForTesting
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
    CareJourney.purchased();
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
    _spend(ent);
    _save();
    CareJourney.consultationBookedNow();
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
      // L2c: the seat's value is the server's (0126 price_offering), so the
      // phone no longer sends one. Kept for revert:
      // priceMinor: BookingCatalog.instance.offeringById(slot.offeringId)?.priceMinor,
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
    _spend(ent);
    _save();
    return b;
  }

  /// Count a credit as used. Only a STORED entitlement keeps a count; one
  /// derived from a receipt counts her bookings instead, so writing it into
  /// the map would turn a derivation into a second record.
  void _spend(Entitlement ent) {
    if (!_entitlements.containsKey(ent.id)) return;
    _entitlements[ent.id] = ent.copyWith(creditsUsed: ent.creditsUsed + 1);
  }

  /// Cancel through the server (frees the seat via cancel_booking) then locally.
  Future<bool> release(String bookingId) async {
    await SupabaseRepo.cancelBooking(bookingId);
    return cancel(bookingId);
  }

  /// The DOCTOR's version: cancel, or mark a no-show, for a booking they host.
  ///
  /// Returns the server's own status code — 'ok', 'already_cancelled',
  /// 'not_your_patient', … — so the caller can say what actually happened
  /// instead of guessing.
  ///
  /// WHY IT DOES NOT REUSE [cancel]. That method is local-only and keyed on
  /// this device's `_bookings` map, which never contains a booking made on the
  /// parent's phone. The doctor app calling it therefore wrote nothing and
  /// returned false for every real appointment, while the screen announced a
  /// cancellation. It is kept for the parent's own path, where the row IS local
  /// and the optimistic update is correct.
  ///
  /// [expert_cancel_booking] (0077) is authorised through my_expert_ids(), so
  /// there is nothing to check here — asking the database is the check.
  ///
  /// The local mirror is updated only on 'ok', and only if this device happens
  /// to hold the row (it usually does not). `DoctorRoster.refresh()` is what
  /// actually repaints the doctor's list, from the server.
  Future<String> expertResolve(String bookingId, DoctorOutcome outcome) async {
    final code = await SupabaseRepo.expertCancelBooking(bookingId, outcome.wire);
    if (code == 'ok') {
      final b = _bookings[bookingId];
      if (b != null) {
        _bookings[bookingId] = b.copyWith(
          status: outcome == DoctorOutcome.cancelled
              ? BookingStatus.cancelled
              : BookingStatus.missed,
        );
        _save();
        notifyListeners();
      }
    }
    return code;
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

  /// Ask the SERVER to settle past bookings from attendance evidence, then
  /// re-read them.
  ///
  /// `settle_my_bookings` (0078) marks each ended booking attended or missed
  /// depending on whether a `consult_sessions` row shows this user actually
  /// joined the room. That is the fact [_reconcileStatuses] below has always
  /// had to guess at, and guessed wrong in the one direction that matters: a
  /// consultation nobody joined was written into her history as ATTENDED.
  ///
  /// Best-effort and offline-safe: if it does not run, [_reconcileStatuses]
  /// still runs locally and the app behaves exactly as it did before. The
  /// server's answer simply overwrites the guess on the next sync, because it
  /// is the better one — and `refreshFromServer` already treats the cloud
  /// status as authoritative.
  Future<void> settleAttendance() async {
    final n = await SupabaseRepo.settleMyBookings();
    if (n > 0) {
      debugPrint('[booking] settled $n past booking(s) from attendance');
      await refreshFromServer();
    }
  }

  /// Move past bookings out of "upcoming": anything whose session has ended is
  /// marked attended.
  ///
  /// ⚠️ THIS IS THE FALLBACK NOW, NOT THE TRUTH. It cannot know whether anyone
  /// joined, so it assumes ended == attended — which writes "attended" into a
  /// mother's permanent history for a consultation nobody turned up to, and is
  /// why `BookingStatus.missed` had never once been written.
  ///
  /// [settleAttendance] above asks the server, which does know. This stays
  /// because it runs at startup with no network and keeps the list sane
  /// offline; where the two disagree, the server wins on the next sync.
  void _reconcileStatuses() {
    final now = DateTime.now().toUtc();
    var changed = false;
    for (final entry in _bookings.entries.toList()) {
      final b = entry.value;
      if (b.status == BookingStatus.upcoming && b.endsUtc.isBefore(now)) {
        _bookings[entry.key] = b.copyWith(status: BookingStatus.attended);
        changed = true;
        // Exactly-once by construction: a booking crosses upcoming -> attended
        // one time and never goes back, so the Care Partner's count cannot
        // drift upward on every app launch. Consults only - a yoga class is
        // not a consultation, whatever the tile is called.
        if (BookingCatalog.instance.offeringById(b.offeringId)?.kind ==
            OfferingKind.consult) {
          CareJourney.consultationDone();
        }
      }
    }
    if (changed) _save();
  }

  @visibleForTesting
  void resetAll() {
    _entitlements.clear();
    _bookings.clear();
    _receipts.clear();
    _receiptsUid = null;
    _recordingsBySlot.clear();
    debugUid = null;
    _save();
  }

  /// Load receipts as if `my_purchases()` had answered, for tests.
  @visibleForTesting
  void seedReceipts(List<Map<String, Object?>> rows, {String? uid}) {
    _applyReceipts(rows, uid);
    notifyListeners();
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

  /// What a sign-out resets this store to (2026-10-17): the blob of a store nobody has used.
  @override
  Object get cloudEmptyData => const <String, Object?>{'entitlements': <Object>[], 'bookings': <Object>[]};

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
