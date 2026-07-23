// =============================================================================
//  showBookingSheet — the one buy → pick a slot → booked flow
// -----------------------------------------------------------------------------
//  The single sheet every paid surface opens once its catalogue item is bridged
//  to an Offering. It runs the whole engine flow in one place, so a yoga class,
//  a masterclass and (later) a consult all book the same way:
//
//    not owned  -> show the price + what buying grants -> Buy (purchase)
//    owned      -> show credits left + real upcoming slots -> tap to reserve
//    reserved   -> a confirmation, with a route into My Bookings
//
//  "Buy" is a mock purchase for now (no gateway) — it mints the entitlement so
//  the rest of the flow is real and testable. "Reserve" goes through
//  BookingStore.reserve(), which claims the seat server-side when logged in
//  (0029) and falls back to a local optimistic booking offline.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../booking/payment_service.dart';
import 'my_bookings_screen.dart';
import 'pp_common.dart';

Future<void> showBookingSheet(BuildContext context, Offering offering) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _BookingSheet(offering: offering),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.offering});
  final Offering offering;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  Booking? _justBooked;
  bool _busy = false;

  Offering get o => widget.offering;

  /// Buy → Razorpay checkout (order + pay + verify) → mint the entitlement.
  /// A free offering skips payment; if the payment backend is not reachable it
  /// falls back to the no-charge preview so the flow is never a dead end.
  Future<void> _buy() async {
    setState(() => _busy = true);
    final result = await PaymentService.instance.checkout(o);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.granted || result.outcome == PaymentOutcome.notConfigured) {
      BookingStore.instance.purchase(o);
    } else if (result.outcome != PaymentOutcome.cancelled) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(result.message ?? 'Payment failed.')));
    }
  }

  Future<void> _reserve(Slot slot) async {
    final b = await BookingStore.instance.reserve(slot);
    if (!mounted) return;
    if (b != null) setState(() => _justBooked = b);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BookingStore.instance,
      builder: (context, _) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: ppLine,
                            borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 18),
                Flexible(child: _body()),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    if (_justBooked != null) return _confirmView(_justBooked!);
    final ent = BookingStore.instance.activeEntitlementFor(o.id);
    return ent == null ? _buyView() : _pickView(ent);
  }

  // ---- not owned: buy -------------------------------------------------------

  Widget _buyView() {
    final g = o.grant;
    final perks = <String>[
      if (g.credits == 1) '1 session'
      else if (g.credits > 1) '${g.credits} sessions to book',
      if (g.validFor != null) 'use within ${g.validFor!.inDays} days',
      if (g.recordingAccess) 'recording to keep',
      if (g.discussionThread) 'private discussion group',
    ];
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(o.title, style: ppFraunces(23, color: ppTitleInk, h: 1.15)),
          const SizedBox(height: 6),
          Text(_kindLabel(o.kind), style: ppBody(13, color: ppSoft)),
          const SizedBox(height: 16),
          for (final p in perks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 17, color: ppPurple),
                const SizedBox(width: 9),
                Expanded(child: Text(p, style: ppBody(13.5, color: ppInk))),
              ]),
            ),
          const SizedBox(height: 14),
          _primary(
            _busy
                ? 'Opening checkout…'
                : '${_price(o.priceMinor)}  ·  ${g.credits > 1 ? "Buy pack" : "Buy"}',
            _busy ? null : _buy,
          ),
        ]);
  }

  // ---- owned: pick a slot ---------------------------------------------------

  Widget _pickView(Entitlement ent) {
    final slots = BookingCatalog.instance.slotsFor(o.id);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(o.title, style: ppFraunces(22, color: ppTitleInk, h: 1.15)),
          const SizedBox(height: 6),
          Text(
              ent.creditsTotal > 1
                  ? '${ent.creditsLeft} of ${ent.creditsTotal} credits left · pick a time'
                  : 'Pick a time',
              style: ppBody(13, color: ppSoft)),
          const SizedBox(height: 16),
          if (slots.isEmpty)
            _note(o.grant.recordingAccess
                ? 'No live sessions scheduled. Your recording is in My Bookings.'
                : 'No upcoming sessions right now — check back soon.')
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: slots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _slotRow(slots[i]),
              ),
            ),
        ]);
  }

  Widget _slotRow(Slot s) => GestureDetector(
        onTap: () => _reserve(s),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppHair),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_whenLabel(s.startsUtc),
                        style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                        s.capacity == 1
                            ? '1:1 · ${s.durationMin} min'
                            : '${s.seatsLeft} seats left · ${s.durationMin} min',
                        style: ppBody(11.5, color: ppSoft)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppPurple),
          ]),
        ),
      );

  // ---- reserved: confirmation ----------------------------------------------

  Widget _confirmView(Booking b) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration:
              const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 28, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text("You're booked in", style: ppFraunces(24, h: 1.15)),
        const SizedBox(height: 8),
        Text('${b.title}\n${_whenLabel(b.startsUtc)}',
            style: ppBody(14, color: ppInk, h: 1.6)),
        const SizedBox(height: 6),
        Text("We'll remind you an hour before it starts.",
            style: ppBody(12.5, color: ppMuted, h: 1.4)),
        const SizedBox(height: 20),
        _primary('View in My Bookings', () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const MyBookingsScreen()));
        }),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Done',
                  style: ppBody(13.5, color: ppSoft, w: FontWeight.w700)),
            ),
          ),
        ),
      ]);

  // ---- bits -----------------------------------------------------------------

  Widget _primary(String label, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: onTap == null ? 0.7 : 1,
          child: Container(
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPurple, borderRadius: BorderRadius.circular(16)),
            child: Text(label,
                style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
          ),
        ),
      );

  Widget _note(String t) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: ppPanel, borderRadius: BorderRadius.circular(14)),
        child: Text(t, style: ppBody(13, color: ppSoft, h: 1.5)),
      );

  String _kindLabel(OfferingKind k) => switch (k) {
        OfferingKind.masterclass => 'Masterclass',
        OfferingKind.consult => '1:1 session',
        OfferingKind.cohort => 'Guided cohort',
        OfferingKind.classPack => 'Class pack',
        OfferingKind.subscription => 'Membership',
      };

  String _price(int minor) => '₹${(minor / 100).round()}';

  static const _wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _whenLabel(DateTime utc) {
    final d = utc.toLocal();
    final now = DateTime.now();
    final diff = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final day = diff == 0
        ? 'Today'
        : diff == 1
            ? 'Tomorrow'
            : '${_wk[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$day · $h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
