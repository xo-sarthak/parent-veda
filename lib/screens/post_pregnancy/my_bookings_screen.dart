// =============================================================================
//  MyBookingsScreen — the one place a mother sees everything she has booked
// -----------------------------------------------------------------------------
//  The "never miss a class" surface. It reads the one stage-tagged history from
//  BookingStore: her remaining credits at the top, her upcoming sessions next
//  (soonest first, with a reminder quietly scheduled for each), and her past
//  ones below. Pregnancy and parenting bookings live in the SAME list — that is
//  the whole point of one engine — each carrying a small tag so she can tell
//  which journey a session belongs to.
//
//  The live-call button is intentionally honest: until a joinUrl exists (the
//  Zoom decision is still open) a session in its join window shows "Link coming"
//  rather than a dead button. Everything else — credits, reminders, cancel —
//  is fully live today.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../services/notification_service.dart';
import 'pp_common.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule (idempotently) a reminder for every upcoming booking. Same
    // notification id each time — derived from the booking id — so re-entering
    // the screen re-arms rather than duplicates.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleReminders());
  }

  void _scheduleReminders() {
    for (final b in BookingStore.instance.upcoming()) {
      final remindAt = b.startsUtc.toLocal().subtract(const Duration(hours: 1));
      NotificationService.instance.scheduleOneOff(
        id: _reminderId(b.id),
        title: b.title,
        body: 'Starts in an hour — ${_timeLabel(b.startsUtc)}.',
        when: remindAt,
      );
    }
  }

  // A stable positive int in a band of its own, so booking reminders never
  // collide with vaccine / medication / test-notification ids.
  int _reminderId(String bookingId) => 700000 + (bookingId.hashCode & 0x3ffff);

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: BookingStore.instance,
          builder: (context, _) {
            final store = BookingStore.instance;
            final credits = store
                .entitlements()
                .where((e) => e.creditsLeft > 0 && !e.isExpired)
                .toList();
            final upcoming = store.upcoming();
            final past = store
                .bookings()
                .where((b) => !b.isUpcoming || b.endsUtc
                    .isBefore(DateTime.now().toUtc()))
                .toList();

            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Explore')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('My bookings', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Your classes & sessions',
                    style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                _pad(Text(
                    'Everything you have booked, across pregnancy and parenting, in one place.',
                    style: ppBody(14, h: 1.5))),
                const SizedBox(height: 22),

                if (credits.isNotEmpty) ...[
                  _pad(_sectionLabel('Credits')),
                  const SizedBox(height: 10),
                  for (final e in credits) _pad(_creditCard(e)),
                  const SizedBox(height: 18),
                ],

                _pad(_sectionLabel('Upcoming')),
                const SizedBox(height: 10),
                if (upcoming.isEmpty)
                  _pad(_emptyUpcoming())
                else
                  for (final b in upcoming) _pad(_upcomingCard(b)),

                if (past.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _pad(_sectionLabel('Past')),
                  const SizedBox(height: 10),
                  for (final b in past) _pad(_pastRow(b)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t.toUpperCase(),
      style: ppBody(11, color: ppMuted, w: FontWeight.w800)
          .copyWith(letterSpacing: 1.0));

  // ---- credits --------------------------------------------------------------

  Widget _creditCard(Entitlement e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: ppPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppPurple.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.title,
                  style: ppJakarta(15, color: ppTitleInk),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(
                  e.expiresUtc == null
                      ? '${e.creditsLeft} of ${e.creditsTotal} left'
                      : '${e.creditsLeft} of ${e.creditsTotal} left · expires ${_dateLabel(e.expiresUtc!)}',
                  style: ppBody(12, color: ppSoft)),
            ]),
          ),
          _stageChip(e.stage),
        ]),
      );

  // ---- upcoming -------------------------------------------------------------

  Widget _upcomingCard(Booking b) {
    final now = DateTime.now();
    final joinable = b.joinableAt(now);
    return ppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(b.title,
                style: ppJakarta(15.5, color: ppTitleInk),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          _stageChip(b.stage),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.event_rounded, size: 14, color: ppPurple),
          const SizedBox(width: 6),
          Text(_whenLabel(b.startsUtc),
              style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _joinButton(b, joinable)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _confirmCancel(b),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Text('Cancel',
                  style: ppBody(12.5, color: ppSoft, w: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _joinButton(Booking b, bool joinable) {
    // joinUrl is null until the live-call provider is settled. Be honest about
    // it rather than showing a button that does nothing.
    final hasLink = (b.joinUrl ?? '').isNotEmpty;
    final live = joinable && hasLink;
    final label = live
        ? 'Join now'
        : joinable
            ? 'Link coming'
            : 'Reminder set';
    final icon = live
        ? Icons.videocam_rounded
        : joinable
            ? Icons.hourglass_top_rounded
            : Icons.notifications_active_outlined;
    return Opacity(
      opacity: live ? 1 : 0.75,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: live ? ppPurple : ppPanel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: live ? Colors.white : ppSoft),
          const SizedBox(width: 7),
          Text(label,
              style: ppBody(13,
                  color: live ? Colors.white : ppSoft, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ---- past -----------------------------------------------------------------

  Widget _pastRow(Booking b) {
    final cancelled = b.status == BookingStatus.cancelled;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ppHair),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.title,
                style: ppBody(13.5, color: ppInk, w: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(_dateLabel(b.startsUtc), style: ppBody(11.5, color: ppMuted)),
          ]),
        ),
        Text(cancelled ? 'Cancelled' : 'Attended',
            style: ppBody(11.5,
                color: cancelled ? ppMuted : ppPurple, w: FontWeight.w700)),
      ]),
    );
  }

  // ---- bits -----------------------------------------------------------------

  Widget _stageChip(ServiceStage s) {
    final label = s == ServiceStage.pregnancy ? 'Pregnancy' : 'Parenting';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: ppPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: ppBody(10, color: ppSoft, w: FontWeight.w700)
              .copyWith(letterSpacing: 0.3)),
    );
  }

  Widget _emptyUpcoming() => Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppHair),
        ),
        child: Column(children: [
          const Icon(Icons.self_improvement_rounded, size: 28, color: ppMuted),
          const SizedBox(height: 10),
          Text('Nothing booked yet',
              style: ppJakarta(15, color: ppTitleInk)),
          const SizedBox(height: 4),
          Text('Classes and sessions you book will show up here.',
              textAlign: TextAlign.center,
              style: ppBody(12.5, color: ppSoft, h: 1.4)),
        ]),
      );

  Future<void> _confirmCancel(Booking b) async {
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: ppLine, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Cancel this booking?',
              style: ppFraunces(21, color: ppTitleInk)),
          const SizedBox(height: 8),
          Text('${b.title}\n${_whenLabel(b.startsUtc)}',
              textAlign: TextAlign.center,
              style: ppBody(13, color: ppSoft, h: 1.5)),
          const SizedBox(height: 6),
          Text('Your credit goes back so you can rebook any time.',
              textAlign: TextAlign.center,
              style: ppBody(12, color: ppMuted, h: 1.4)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ppPanel, borderRadius: BorderRadius.circular(14)),
                  child: Text('Keep it',
                      style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ppPurple, borderRadius: BorderRadius.circular(14)),
                  child: Text('Cancel booking',
                      style: ppBody(13.5,
                          color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
    if (yes == true) {
      await BookingStore.instance.release(b.id);
    }
  }

  // ---- date/time labels (no intl dependency) --------------------------------

  static const _wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _timeLabel(DateTime utc) {
    final d = utc.toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  String _dateLabel(DateTime utc) {
    final d = utc.toLocal();
    return '${_wk[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';
  }

  /// "Today · 7:00 AM" / "Tomorrow · 6:30 PM" / "Fri 25 Jul · 6:30 PM".
  String _whenLabel(DateTime utc) {
    final d = utc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.difference(today).inDays;
    final prefix = diff == 0
        ? 'Today'
        : diff == 1
            ? 'Tomorrow'
            : _dateLabel(utc);
    return '$prefix · ${_timeLabel(utc)}';
  }
}
