// =============================================================================
//  The learn flow — slot sheet, review sheet, and the one commit
// -----------------------------------------------------------------------------
//  Every sticky bar in `lib/screens/learn/` ends in `pvLearnCommit`. It
//  reads the kind and the engine state and runs one of five short paths:
//
//    play          a free thing, or a recording she owns    → the player
//    buyThenPlay   a recorded thing she does not own        → review · pay · player
//    pickSlot      a dated thing                            → slots · (review · pay) · reserve · Booked
//    buyPack       a class pack                             → review · pay · slots · reserve · Booked
//    openSession   already booked                           → Booked
//
//  Two sheets, from the audit (docs/LEARNING-AUDIT.md §4.4–4.5):
//
//  SLOTS — Alan and Preply for a 1:1 (a week strip, then times grouped
//  morning / afternoon / evening), Airbnb for a group (date cards with the
//  seats left). One sheet; the offering's format picks the layout. It reads
//  the engine's real `Slot`s — the same rows a host sees.
//
//  REVIEW — Alan's four lines: who · when · price · the cancellation rule,
//  then "confirming means you plan to attend", then the pay button. For a
//  recorded thing there is no "when", so it is what · price · access rule.
//  Payment is the store's `PaymentService` (Razorpay, server-side order,
//  signature verified); "not configured" falls through to the no-charge
//  preview so the flow is never a dead end, exactly as `showBookingSheet`
//  did. Nothing about money changed hands-wise; only where it is asked.
//
//  ⚠️ PAY AFTER PICKING, FOR A 1:1. The old sheet sold the credit first and
//  showed times second, so a parent could pay and then find no time that
//  suited. Alan's order — time, then money — is the one a person expects.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../booking/payment_service.dart';
import '../../booking/server_slots.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import 'pv_learn_art.dart';
import 'pv_learn_chrome.dart';
import 'pv_lesson_screen.dart';
import 'pv_offering_content.dart';
import 'pv_session_screen.dart';

/// The one entry every commit bar calls.
Future<void> pvLearnCommit(BuildContext context, PvOfferingView v) async {
  final state = pvLearnStateFor(v);
  final booking = pvLearnBookingFor(v);
  final commit = pvCommitFor(v, state, booking: booking);
  final o = v.offering;
  switch (commit.action) {
    case PvCommitAction.play:
      _play(context, v);
      return;
    case PvCommitAction.openSession:
      if (booking != null) pvOpenSession(context, booking);
      return;
    case PvCommitAction.buyThenPlay:
      if (o == null) {
        _play(context, v);
        return;
      }
      final ok = await showPvReviewSheet(context, v);
      if (!ok || !context.mounted) return;
      BookingStore.instance.purchase(o);
      _play(context, v);
      return;
    case PvCommitAction.buyPack:
      if (o == null) return;
      if (state != PvLearnState.owned) {
        final ok = await showPvReviewSheet(context, v);
        if (!ok || !context.mounted) return;
        BookingStore.instance.purchase(o);
      }
      if (!context.mounted) return;
      final slot = await showPvSlotSheet(context, v);
      if (slot == null || !context.mounted) return;
      await _reserve(context, slot);
      return;
    case PvCommitAction.pickSlot:
      if (o == null) return;
      final slot = await showPvSlotSheet(context, v);
      if (slot == null || !context.mounted) return;
      if (state != PvLearnState.owned) {
        final ok = await showPvReviewSheet(context, v, slot: slot);
        if (!ok || !context.mounted) return;
        BookingStore.instance.purchase(o);
      }
      if (!context.mounted) return;
      await _reserve(context, slot);
      return;
  }
}

void _play(BuildContext context, PvOfferingView v) {
  if (v.lessons.isEmpty) {
    pvSnack(
      context,
      'The lessons are being edited. They land here the day they are ready.',
    );
    return;
  }
  final last = PvLearnProgressStore.instance.lastLesson(v.id);
  var i = last == null ? 0 : v.lessons.indexWhere((l) => l.id == last);
  if (i < 0) i = 0;
  pvOpenLesson(context, v, i);
}

Future<void> _reserve(BuildContext context, Slot slot) async {
  final b = await BookingStore.instance.reserve(slot);
  if (!context.mounted) return;
  if (b == null) {
    pvSnack(context, 'That time just went. Pick another.');
    return;
  }
  pvOpenSession(context, b, justBooked: true);
}

// =============================================================================
//  The slot sheet
// =============================================================================

Future<Slot?> showPvSlotSheet(BuildContext context, PvOfferingView v) {
  final o = v.offering;
  if (o == null) return Future.value(null);
  // Fresh truth before she picks: a doctor's own calendar for a consult,
  // the ledger's seat counts for everything.
  if (o.kind == OfferingKind.consult) {
    DoctorScheduleStore.instance.syncFromServer();
  }
  ServerSlotStore.instance.refresh();
  final p = pvStorePalette;
  return showModalBottomSheet<Slot>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _SlotSheet(view: v),
  );
}

class _SlotSheet extends StatefulWidget {
  const _SlotSheet({required this.view});
  final PvOfferingView view;

  @override
  State<_SlotSheet> createState() => _SlotSheetState();
}

class _SlotSheetState extends State<_SlotSheet> {
  DateTime? _day;

  bool get _oneToOne =>
      widget.view.offering!.format == SessionFormat.liveOneToOne;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final v = widget.view;
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        DoctorScheduleStore.instance,
        ServerSlotStore.instance,
      ]),
      builder: (context, _) {
        final slots = BookingCatalog.instance.slotsFor(v.offering!.id);
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kPvLine,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    _oneToOne ? 'Pick a time' : 'Pick a date',
                    style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: p.ink1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    _oneToOne
                        ? '${v.expert.name} · ${v.facts.isNotEmpty ? v.facts.first.value : ''} · in your time zone'
                        : v.kind == PvLearnKind.cohort
                        ? 'Each date is a full run. The seats are real.'
                        : 'Live, in the app. The seats are real.',
                    style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
                  ),
                ),
                if (slots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Text(
                      _oneToOne
                          ? 'No times published yet. ${v.expert.firstName} sets them from their own calendar; check back in a day.'
                          : 'No dates open right now. The next run is announced here first.',
                      style: pvManrope(
                        fontSize: 14,
                        height: 1.5,
                        color: p.ink2,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: _oneToOne
                        ? _oneToOneBody(p, slots)
                        : _groupBody(p, slots),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- 1:1 — week strip + times by part of day ------------------------------------

  Widget _oneToOneBody(dynamic p, List<Slot> slots) {
    final days = <DateTime>[];
    for (final s in slots) {
      final l = s.startsUtc.toLocal();
      final d = DateTime(l.year, l.month, l.day);
      if (!days.contains(d)) days.add(d);
    }
    final day = _day ?? days.first;
    final today = slots.where((s) {
      final l = s.startsUtc.toLocal();
      return l.year == day.year && l.month == day.month && l.day == day.day;
    }).toList();
    List<Slot> part(int from, int to) => today.where((s) {
      final h = s.startsUtc.toLocal().hour;
      return h >= from && h < to;
    }).toList();
    final groups = [
      ('Morning', part(0, 12)),
      ('Afternoon', part(12, 17)),
      ('Evening', part(17, 24)),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final d = days[i];
              final on = d == day;
              const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return InkWell(
                onTap: () => setState(() => _day = d),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: on ? p.ink1 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: on ? p.ink1 : kPvLine),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        w[d.weekday - 1].toUpperCase(),
                        style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: on ? Colors.white70 : p.ink3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: pvManrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: on ? Colors.white : p.ink1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              for (final (label, list) in groups)
                if (list.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Text(
                      label.toUpperCase(),
                      style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: p.ink3,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in list)
                        PvChip(
                          label: pvLearnTime(s.startsUtc),
                          selected: false,
                          onTap: () => Navigator.of(context).pop(s),
                        ),
                    ],
                  ),
                ],
              // ⚠️ THE LINE EVERY GOOD PICKER CARRIES. Future Pro: "None of
              // these times work for me"; Fresha: "Can't find a suitable
              // time? Join waitlist". A picker with no answer for "none of
              // these" leaves her closing the app to say so.
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'None of these? Times open a week at a time — look again '
                  'tomorrow, or pick someone else from the list.',
                  style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- group — date cards with seats left -------------------------------------------

  Widget _groupBody(dynamic p, List<Slot> slots) => ListView(
    shrinkWrap: true,
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
    children: [
      for (final s in slots.take(8))
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPvLine),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pvLearnDay(s.startsUtc),
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pvLearnTime(s.startsUtc)} – ${pvLearnTime(s.endsUtc)}',
                      style: pvManrope(fontSize: 13, color: p.ink2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.seatsLeft == 1
                          ? '1 seat left'
                          : '${s.seatsLeft} seats left',
                      style: pvManrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: s.seatsLeft <= 3
                            ? const Color(0xFFC6295A)
                            : p.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PvSecondary(
                label: 'Choose',
                onTap: () => Navigator.of(context).pop(s),
              ),
            ],
          ),
        ),
    ],
  );
}

// =============================================================================
//  The review sheet
// =============================================================================

/// True when she may proceed — paid, free, or the payment backend is not
/// configured (the no-charge preview, as before).
Future<bool> showPvReviewSheet(
  BuildContext context,
  PvOfferingView v, {
  Slot? slot,
}) async {
  final p = pvStorePalette;
  final r = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ReviewSheet(view: v, slot: slot),
  );
  return r == true;
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.view, this.slot});
  final PvOfferingView view;
  final Slot? slot;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  bool _busy = false;

  Future<void> _pay() async {
    final o = widget.view.offering!;
    setState(() => _busy = true);
    final result = await PaymentService.instance.checkout(
      o,
      email: SupabaseRepo.userEmail,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.granted || result.outcome == PaymentOutcome.notConfigured) {
      Navigator.of(context).pop(true);
    } else if (result.outcome != PaymentOutcome.cancelled) {
      pvSnack(context, result.message ?? 'Payment did not go through.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final v = widget.view;
    final s = widget.slot;
    final rule = pvTrustRowsFor(v)[1];
    // ⚠️ THE LAST SCREEN BEFORE MONEY IS NOT THE PLACE FOR BORROWED GLYPHS.
    // These four rows wore `person_outline`, `event`, `play_circle` and
    // `replay` — the only Material set left on the paid path. A mark per row,
    // and the person wears her initials, as she does on the list she was
    // picked from and on her own page.
    final rows = <(PvLearnMark?, String, String)>[
      (
        null, // initials
        v.expert.name,
        v.kind == PvLearnKind.consult ? v.expert.role : v.title,
      ),
      if (s != null)
        (
          PvLearnMark.calendar,
          pvLearnDay(s.startsUtc),
          '${pvLearnTime(s.startsUtc)} – ${pvLearnTime(s.endsUtc)}',
        )
      else
        (
          PvLearnMark.recording,
          v.kind == PvLearnKind.classPack
              ? 'Four classes'
              : pvLearnFacts(v).isNotEmpty
              ? pvLearnFacts(v).first.value
              : 'Recorded',
          v.kind == PvLearnKind.classPack
              ? 'Book each one after this'
              : 'Yours to keep',
        ),
      (PvLearnMark.money, v.isFree ? 'Free' : v.priceLabel, v.priceUnit),
      (PvLearnMark.refund, rule.title, rule.line),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kPvLine,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s != null ? 'Your booking' : 'Your purchase',
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 12),
            for (final (mark, a, b) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mark == null)
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.surfaceAlt,
                        ),
                        child: Text(
                          pvLearnInitials(v.expert.name),
                          style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      )
                    else
                      PvLearnRing(mark: mark, p: p, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a,
                            style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b,
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: p.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  PvLearnRing(mark: PvLearnMark.note, p: p, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s != null
                          ? 'Confirming means you plan to attend. The time is held for you.'
                          : 'Signed into this account, on any phone.',
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.4,
                        color: p.ink2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PvCommit(
              label: v.isFree ? 'Confirm' : 'Pay ${v.priceLabel}',
              busy: _busy,
              onTap: _busy ? null : _pay,
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Razorpay · UPI, cards, net banking',
                style: pvManrope(fontSize: 11.5, color: p.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
