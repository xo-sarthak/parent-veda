// =============================================================================
//  PvSessionScreen — the booked thing: the confirmation AND the return page
// -----------------------------------------------------------------------------
//  Peloton's scheduled class and Zocdoc's upcoming visit, folded into one
//  (docs/LEARNING-AUDIT.md §3.6): nothing in the app had this page. A booking
//  was a toast, then a row in My bookings, and the row carried the Join
//  button and nothing else — no way to prepare, no calendar, no partner.
//
//  Big time · the expert · the thing · a countdown that becomes JOIN NOW in
//  the window · add to calendar · prepare · the partner line · reschedule and
//  cancel with the rule stated · and after it has happened, the doctor's
//  notes and a way to book again.
//
//  ⚠️ THE ROOM IS DERIVED, NOT LINKED. `pvOpenCall` is the one door to the
//  three call screens (consult → green room, class → straight in, else the
//  plain call), lifted from My bookings so both surfaces open the same room
//  the same way. There is no link to paste; the server derives the room
//  from the booking's slot.
//
//  ⚠️ THE PARTNER JOINS ON HER BOOKING, FROM HIS PHONE. Decision 4 of the
//  audit, the user's call. A household is one seat; the paired account reads
//  her bookings (RLS, the family model) and opens the same room. No second
//  seat is claimed — that is the honest reading of "two seats per booking",
//  and the page says exactly that. A class pack is the exception: one mat.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../booking/call_prejoin_screen.dart';
import '../../booking/call_screen.dart';
import '../../booking/group_call_screen.dart';
import '../../booking/prescription.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/notification_service.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kCallRoute;
import '../post_pregnancy/pp_experts_data.dart' show expertById;
import '../post_pregnancy/prescription_view_screen.dart';
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_learn_flow.dart';
import 'pv_offering_content.dart';
import 'pv_offering_screen.dart';

const String kPvSessionRoutePrefix = 'learn/session/';

void pvOpenSession(BuildContext context, Booking b, {bool justBooked = false}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '$kPvSessionRoutePrefix${b.id}'),
      builder: (_) => PvSessionScreen(bookingId: b.id, justBooked: justBooked),
    ),
  );
}

/// The one door to a room. Lifted from My bookings unchanged in behaviour.
void pvOpenCall(BuildContext context, Booking b) {
  final o = BookingCatalog.instance.offeringById(b.offeringId);
  final expertId = o?.expertId;
  final who = (expertId == null || expertId.isEmpty)
      ? null
      : expertById(expertId).name;
  final consult = o?.kind == OfferingKind.consult;
  final group =
      o?.kind == OfferingKind.masterclass || o?.kind == OfferingKind.cohort;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kCallRoute),
      builder: (_) => consult
          ? CallPrejoinScreen(
              bookingId: b.id,
              title: b.title,
              waitingFor: who,
              startsUtc: b.startsUtc,
            )
          : group
          ? GroupCallScreen(title: b.title, bookingId: b.id, hostName: who)
          : CallScreen(bookingId: b.id, title: b.title, waitingFor: who),
    ),
  );
}

/// A stable id in its own band, so booking reminders never collide with
/// vaccine or medicine ones. Same formula as My bookings.
int pvBookingReminderId(String bookingId) =>
    700000 + (bookingId.hashCode & 0x3ffff);

/// ⚠️ ONE CANCEL, TWO PLACES (2026-09-29). Lifted out of the session page so
/// the Bookings list's cards can offer Cancel on the card (TheFork, Zocdoc)
/// without a second copy of the rule. Asks, states the credit rule, and
/// releases through the server (`BookingStore.release`: the seat is freed
/// server-side, never decided here). True when it was cancelled.
Future<bool> pvConfirmCancelBooking(
  BuildContext context,
  Booking b,
  PvOfferingView? v,
) async {
  final p = pvStorePalette;
  final rule = v == null
      ? 'Your credit goes back so you can rebook any time.'
      : pvTrustRowsFor(v)[1].line;
  final yes = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancel this booking?',
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${b.title} · ${pvLearnDay(b.startsUtc)}, ${pvLearnTime(b.startsUtc)}',
              style: pvManrope(fontSize: 13.5, color: p.ink2),
            ),
            const SizedBox(height: 10),
            Text(
              rule,
              style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PvSecondary(
                    label: 'Keep it',
                    onTap: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PvCommit(
                    label: 'Cancel booking',
                    onTap: () => Navigator.of(ctx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (yes != true) return false;
  await BookingStore.instance.release(b.id);
  return true;
}

/// Reschedule, lifted out of the session page with [pvConfirmCancelBooking]
/// (2026-09-29): pick a new slot, release the old one, claim the new one.
/// Returns the new booking, or null (no slot picked, or the time just went,
/// in which case she is told and her credit is back).
Future<Booking?> pvRescheduleBooking(
  BuildContext context,
  Booking b,
  PvOfferingView v,
) async {
  final slot = await showPvSlotSheet(context, v);
  if (slot == null || !context.mounted) return null;
  // Release first, then claim: the credit returns and is spent again.
  await BookingStore.instance.release(b.id);
  if (!context.mounted) return null;
  final nb = await BookingStore.instance.reserve(slot);
  if (!context.mounted) return null;
  if (nb == null) {
    pvSnack(
      context,
      'That time just went. Your credit is back — pick another.',
    );
  }
  return nb;
}

class PvSessionScreen extends StatefulWidget {
  const PvSessionScreen({
    super.key,
    required this.bookingId,
    this.justBooked = false,
  });
  final String bookingId;
  final bool justBooked;

  @override
  State<PvSessionScreen> createState() => _PvSessionScreenState();
}

class _PvSessionScreenState extends State<PvSessionScreen> {
  @override
  void initState() {
    super.initState();
    // The one-hour reminder, idempotent by id.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final b = BookingStore.instance.byId(widget.bookingId);
      if (b == null || !b.isUpcoming) return;
      NotificationService.instance.scheduleOneOff(
        id: pvBookingReminderId(b.id),
        title: b.title,
        body: 'Starts in an hour — ${pvLearnTime(b.startsUtc)}.',
        when: b.startsUtc.toLocal().subtract(const Duration(hours: 1)),
      );
    });
  }

  // Both lifted to top-level functions below the imports (2026-09-29) so the
  // Bookings cards share them. Kept for revert: the two private bodies are
  // the functions' bodies, unchanged but for how they end.
  Future<void> _cancel(Booking b, PvOfferingView? v) async {
    final done = await pvConfirmCancelBooking(context, b, v);
    if (done && mounted) Navigator.of(context).maybePop();
  }

  Future<void> _reschedule(Booking b, PvOfferingView v) async {
    final nb = await pvRescheduleBooking(context, b, v);
    if (!mounted) return;
    if (nb == null) {
      // Only a lost slot released the old booking; then leave its page.
      if (BookingStore.instance.byId(b.id)?.isUpcoming != true) {
        Navigator.of(context).maybePop();
      }
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '$kPvSessionRoutePrefix${nb.id}'),
        builder: (_) => PvSessionScreen(bookingId: nb.id, justBooked: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        PrescriptionStore.instance,
      ]),
      builder: (context, _) {
        final b = BookingStore.instance.byId(widget.bookingId);
        if (b == null) {
          return Scaffold(
            backgroundColor: p.ground,
            body: Column(
              children: [
                const PvLearnTopBar(title: 'Booking'),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'This booking is no longer here.',
                    style: pvManrope(fontSize: 14, color: p.ink2),
                  ),
                ),
              ],
            ),
          );
        }
        final v = PvLearnCatalog.instance.byOfferingId(b.offeringId);
        final past = !b.isUpcoming || DateTime.now().toUtc().isAfter(b.endsUtc);
        final joinable = b.joinableAt(DateTime.now());
        final countdown = pvLearnCountdown(b.startsUtc, b.endsUtc);
        final rx = PrescriptionStore.instance.forBooking(b.id);
        final partner = PregnancyController.current?.partnerName;
        final mayJoin = v == null || pvPartnerMayJoin(v);
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PvLearnTopBar(
                  title: widget.justBooked
                      ? 'Booked'
                      : (past ? 'Your session' : 'Coming up'),
                  eyebrow: v?.kind.label ?? 'Booking',
                ),
              ),
              // ---- the big time --------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pvLearnTime(b.startsUtc),
                        style: pvFraunces(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: -1,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pvLearnDay(b.startsUtc)} · ${b.durationMin} min',
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: p.ink2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        b.title,
                        style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: p.ink1,
                        ),
                      ),
                      if (v != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${v.expert.name} · ${v.expert.role}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 13.5, color: p.ink2),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (!past)
                        Row(
                          children: [
                            Expanded(
                              child: PvCommit(
                                label: joinable
                                    ? 'Join now'
                                    : 'Starts $countdown',
                                icon: joinable
                                    ? Icons.videocam_rounded
                                    : Icons.schedule_rounded,
                                onTap: joinable
                                    ? () => pvOpenCall(context, b)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      if (!past) ...[
                        const SizedBox(height: 8),
                        Text(
                          joinable
                              ? 'The room is open. Nothing to install, no link to find.'
                              : 'The room opens ten minutes before. We remind you an hour ahead.',
                          style: pvManrope(
                            fontSize: 12.5,
                            height: 1.4,
                            color: p.ink3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // ---- the round actions (Zocdoc) ---------------------------------------------
              if (!past)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: Row(
                      children: [
                        _round(
                          p,
                          Icons.calendar_month_outlined,
                          'Calendar',
                          () => _calendar(b),
                        ),
                        if (v != null &&
                            v.offering != null &&
                            v.kind != PvLearnKind.cohort)
                          _round(
                            p,
                            Icons.edit_calendar_outlined,
                            'Reschedule',
                            () => _reschedule(b, v),
                          ),
                        _round(
                          p,
                          Icons.close_rounded,
                          'Cancel',
                          () => _cancel(b, v),
                        ),
                      ],
                    ),
                  ),
                ),
              // ---- prepare ------------------------------------------------------------------
              if (!past && v != null && v.prepare.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: PvLearnHead('Before it starts'),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PvTickList(v.prepare),
                  ),
                ),
              ],
              // ---- the partner ---------------------------------------------------------------
              if (!past)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPvLine),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            mayJoin
                                ? Icons.people_outline_rounded
                                : Icons.person_outline_rounded,
                            size: 20,
                            color: p.ink1,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mayJoin
                                  ? (partner == null || partner.isEmpty
                                        ? 'Your partner can join this on their own phone once you are paired — one booking, two of you.'
                                        : '$partner can join this from their phone — one booking, two of you.')
                                  : 'One mat, one seat. Your partner books their own class.',
                              style: pvManrope(
                                fontSize: 13,
                                height: 1.45,
                                color: p.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // ---- after it happened ---------------------------------------------------------
              if (past) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      b.status == BookingStatus.cancelled
                          ? 'Cancelled. The credit went back.'
                          : b.status == BookingStatus.missed
                          ? 'Missed — the time was held for you, so the session is spent.'
                          : 'Done. What was said is below, when the expert has written it up.',
                      style: pvManrope(
                        fontSize: 13.5,
                        height: 1.45,
                        color: p.ink2,
                      ),
                    ),
                  ),
                ),
                if (rx != null) ...[
                  const SliverToBoxAdapter(
                    child: PvLearnHead('Notes from the session'),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PvSecondary(
                        label: 'Open the notes',
                        icon: Icons.description_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PrescriptionViewScreen(
                              prescription: rx,
                              title: b.title,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (v != null &&
                    v.recordingIncluded &&
                    v.lessons.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: PvLearnHead('The recording')),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PvSecondary(
                        label: 'Watch',
                        icon: Icons.play_arrow_rounded,
                        onTap: () => pvOpenOffering(context, v),
                      ),
                    ),
                  ),
                ],
                if (v != null) ...[
                  const SliverToBoxAdapter(child: PvLearnHead('Again')),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PvSecondary(
                        label: 'Book again',
                        icon: Icons.replay_rounded,
                        onTap: () => pvOpenOffering(context, v),
                      ),
                    ),
                  ),
                ],
              ],
              // ---- the thing itself -------------------------------------------------------------
              if (v != null) ...[
                const SliverToBoxAdapter(child: PvLearnHead('What you booked')),
                SliverToBoxAdapter(
                  child: PvLearnRow(
                    view: v,
                    tag: v.kind.label,
                    title: v.title,
                    sub: v.subtitle,
                    onTap: () => pvOpenOffering(context, v),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _round(dynamic p, IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: kPvLine),
                ),
                child: Icon(icon, size: 20, color: p.ink1),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: p.ink2,
                ),
              ),
            ],
          ),
        ),
      );

  void _calendar(Booking b) {
    // The OS calendar needs a platform channel or a share; the reminder is
    // already scheduled. Say what is true.
    pvSnack(
      context,
      'Reminder set for an hour before. Calendar export is coming.',
    );
  }
}
