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
//  STALE NOTE, CORRECTED. This used to say a session shows "Link coming" until
//  a joinUrl exists, "while the Zoom decision is still open". Both are history:
//  the call is LiveKit and in-app, and there is no link at all — the room is
//  derived from the booking's slot server-side, so the two parties converge
//  without one. `Booking.joinUrl` survives as a null field for that reason.
//
//  What the button is honest about NOW is the clock. A consultation is joinable
//  from ten minutes before until it ends, and outside that it says when it
//  opens; a class stays joinable throughout, unchanged. See _upcomingCard.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../booking/call_prejoin_screen.dart';
import '../../booking/call_screen.dart';
import '../../booking/group_call_screen.dart';
import '../../booking/prescription.dart';
import '../../booking/prescription_watch.dart';
import '../../services/notification_service.dart';
import '../../widgets/global_ask_fab.dart' show kCallRoute;
import 'problem_solver_screen.dart';
import 'yoga_home_screen.dart';
import '../../services/remote/supabase_repo.dart';
import '../auth/auth_flow_screen.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'prescription_view_screen.dart';

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
    // Pull any prescriptions the doctor has written for these consults.
    PrescriptionStore.instance.refresh();
    // And the bookings themselves, from booking_bookings. Opening this screen
    // is the clearest possible statement of "show me my bookings", so it is the
    // right moment to ask the server rather than trust whatever is cached.
    BookingStore.instance.refreshFromServer();
    // And settle anything that has finished, from whether she actually joined
    // rather than from the clock alone. See BookingStore.settleAttendance.
    BookingStore.instance.settleAttendance();
  }

  Future<void> _pullToRefresh() async {
    await Future.wait([
      BookingStore.instance.refreshFromServer(),
      BookingStore.instance.settleAttendance(),
      // force: a deliberate pull is exactly the moment to skip the throttle.
      PrescriptionWatch.instance.check(force: true),
    ]);
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
          animation: Listenable.merge(
              [BookingStore.instance, PrescriptionStore.instance]),
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

            return RefreshIndicator(
              onRefresh: _pullToRefresh,
              color: ppPurple,
              child: ListView(
              // alwaysScrollable so the pull gesture works even when the list
              // is short — an empty "no bookings yet" screen is exactly when
              // someone most wants to pull it down again.
              physics: const AlwaysScrollableScrollPhysics(),
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

                // A FRESH PRESCRIPTION, ABOVE EVERYTHING.
                //
                // Its only home used to be a link on a row in the PAST list,
                // below credits, below every upcoming session. Something a
                // doctor wrote this morning about medicine to take today does
                // not belong at the bottom of a history.
                ..._freshPrescription(),

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

                // HISTORY IS NEVER HIDDEN. This used to render only when there
                // was something in it, so a parent with no past sessions saw
                // no sign that a record was being kept — and a parent whose
                // history had silently failed to load saw the same nothing.
                // Two very different situations, one blank screen. The empty
                // copy is the feature's advertisement (CLAUDE.md).
                const SizedBox(height: 20),
                _pad(_sectionLabel('Past')),
                const SizedBox(height: 10),
                if (past.isEmpty)
                  _pad(_emptyPast())
                else
                  for (final b in past) _pad(_pastRow(b)),
              ],
            ),
            );
          },
        ),
      ),
    );
  }

  /// How long a prescription counts as "fresh" and gets top billing.
  ///
  /// Seven days is roughly the length of a short course, and long enough that a
  /// mother who did not open the app for a few days still finds it waiting
  /// rather than filed. After that it is history, and history has a section.
  static const _freshFor = Duration(days: 7);

  List<Widget> _freshPrescription() {
    final now = DateTime.now().toUtc();
    Prescription? newest;
    Booking? forBooking;
    for (final b in BookingStore.instance.bookings()) {
      final rx = PrescriptionStore.instance.forBooking(b.id);
      if (rx == null) continue;
      if (now.difference(rx.createdUtc) > _freshFor) continue;
      if (newest == null || rx.createdUtc.isAfter(newest.createdUtc)) {
        newest = rx;
        forBooking = b;
      }
    }
    if (newest == null || forBooking == null) return const [];

    final rx = newest;
    final b = forBooking;
    final n = rx.items.where((i) => !i.isEmpty).length;
    return [
      _pad(GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) =>
                PrescriptionViewScreen(prescription: rx, title: b.title))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: ppPurple.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppPurple.withValues(alpha: 0.22)),
          ),
          child: Row(children: [
            const Icon(Icons.medication_outlined, size: 20, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your prescription is ready',
                        style: ppJakarta(14.5, color: ppTitleInk)),
                    const SizedBox(height: 3),
                    Text(
                      n == 0
                          ? 'Advice from ${b.title}'
                          : n == 1
                              ? '1 medicine · ${b.title}'
                              : '$n medicines · ${b.title}',
                      style: ppBody(12, color: ppSoft),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppPurple),
          ]),
        ),
      )),
      const SizedBox(height: 18),
    ];
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

  /// Is this booking a one-to-one consultation?
  ///
  /// The switch for everything that changed in the consult pass. A class takes
  /// the path it always took — including the always-joinable behaviour below,
  /// which is wrong for a consult and is deliberately still there for a class.
  bool _isConsult(Booking b) =>
      BookingCatalog.instance.offeringById(b.offeringId)?.kind ==
      OfferingKind.consult;

  /// A masterclass or a cohort — one voice and an audience, not a conversation.
  bool _isGroupSession(Booking b) {
    final kind = BookingCatalog.instance.offeringById(b.offeringId)?.kind;
    return kind == OfferingKind.masterclass || kind == OfferingKind.cohort;
  }

  Widget _upcomingCard(Booking b) {
    // WHY THIS IS NOW TWO RULES.
    //
    // It used to be `b.isUpcoming` for everything, with a note saying to
    // tighten it later. `isUpcoming` is a pure STATUS check, and the list this
    // card is built from has already filtered to future sessions — so the
    // condition was always true, every upcoming booking showed a live
    // "Join now", and the `Reminder set` branch below was unreachable.
    //
    // For a class that is harmless and arguably friendly. For a consult it
    // meant a parent could walk into her doctor's room three weeks early, sit
    // alone with a running timer, and be told the app was "waiting for Dr.
    // Neha" — for an appointment that had not happened. Booking.joinableAt()
    // has described the right window all along and had no callers.
    //
    // The server agrees with this rule rather than trusting it: 0076 refuses a
    // consult outside the same window. This is the affordance, not the gate.
    // AND THE SAME RULE NOW COVERS A CLASS. 0079 applies the window to group
    // sessions too — before it, a masterclass booked for next Thursday could be
    // "joined" today, alone, forever. Leaving the button always-live would mean
    // a cheerful "Join now" that the server answers with a refusal.
    //
    // Anything that is neither keeps `isUpcoming`, unchanged.
    final joinable = (_isConsult(b) || _isGroupSession(b))
        ? b.joinableAt(DateTime.now())
        : b.isUpcoming;
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
    // "Join now" is live in the join window — the LiveKit room is derived from
    // the booking server-side, so no link is needed.
    //
    // Outside the window it used to read "Reminder set", which was both
    // unreachable (see _upcomingCard) and a claim rather than an answer: it
    // told her what WE had done instead of what SHE can do. Now the closed
    // state says when the door opens, which is the only thing she wants from
    // a button she cannot press. The 1-hour reminder is still scheduled — see
    // _scheduleReminders — it just no longer has to be the button's excuse.
    final label = joinable ? 'Join now' : _opensLabel(b);
    final icon = joinable
        ? Icons.videocam_rounded
        : Icons.notifications_active_outlined;
    return GestureDetector(
      onTap: joinable ? () => _openCall(b) : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: joinable ? 1 : 0.75,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: joinable ? ppPurple : ppPanel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: joinable ? Colors.white : ppSoft),
            const SizedBox(width: 7),
            Text(label,
                style: ppBody(13,
                    color: joinable ? Colors.white : ppSoft, w: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  /// What the button says when the room is not open yet.
  ///
  /// A time, not a status. "Opens 4:50 PM" answers the question; "Reminder set"
  /// answers a different one nobody asked.
  String _opensLabel(Booking b) {
    if (!b.isUpcoming) return 'Closed';
    final opens = b.startsUtc.subtract(const Duration(minutes: 10));
    final wait = opens.difference(DateTime.now().toUtc());
    if (wait.isNegative) return 'Closed';
    if (wait.inMinutes < 60) {
      final m = wait.inMinutes < 1 ? 1 : wait.inMinutes;
      return 'Opens in $m min';
    }
    return 'Opens ${_timeLabel(b.startsUtc.subtract(const Duration(minutes: 10)))}';
  }

  void _openCall(Booking b) {
    // Who she is waiting for, by name. Derived from the offering rather than
    // stored on the booking: the booking records WHAT was bought, and the
    // catalogue already knows who delivers it — copying the name onto the row
    // would be a second place for it to go stale.
    final expertId = BookingCatalog.instance.offeringById(b.offeringId)?.expertId;
    final who = (expertId == null || expertId.isEmpty)
        ? null
        : expertById(expertId).name;

    // THREE DOORS, BECAUSE THERE ARE THREE KINDS OF ROOM.
    //
    // A CONSULT gets a green room first: camera and microphone consent, a look
    // at yourself, and the choice of what the doctor sees — decided before
    // going live rather than discovered by being on air.
    //
    // A CLASS goes straight in, and that is not laziness. An attendee at a
    // masterclass cannot publish anything, so there is no camera to check, no
    // microphone to test, and no permission to ask for. A green room with no
    // decisions in it is a delay pretending to be a step.
    //
    // Anything else keeps the original path untouched.
    final consult = _isConsult(b);
    final group = _isGroupSession(b);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Named so GlobalAskFab suppresses itself — it floats above the
        // Navigator and would otherwise sit on the doctor's face.
        settings: const RouteSettings(name: kCallRoute),
        builder: (_) => consult
            ? CallPrejoinScreen(
                bookingId: b.id,
                title: b.title,
                waitingFor: who,
                startsUtc: b.startsUtc,
              )
            : group
                ? GroupCallScreen(
                    title: b.title,
                    bookingId: b.id,
                    hostName: who,
                  )
                : CallScreen(bookingId: b.id, title: b.title, waitingFor: who),
      ),
    );
  }

  // ---- past -----------------------------------------------------------------

  Widget _pastRow(Booking b) {
    final cancelled = b.status == BookingStatus.cancelled;
    final rx = PrescriptionStore.instance.forBooking(b.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ppHair),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        if (rx != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) =>
                    PrescriptionViewScreen(prescription: rx, title: b.title))),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                  color: ppPurple.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.description_outlined,
                    size: 15, color: ppPurple),
                const SizedBox(width: 6),
                Text('View prescription',
                    style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  // ---- bits -----------------------------------------------------------------

  Widget _stageChip(ServiceStage s) {
    // A switch rather than a ternary: with three stages a two-way test silently
    // mislabels the third, and this chip is the only thing telling a parent
    // which part of their journey a booking came from.
    final label = switch (s) {
      ServiceStage.tryingToConceive => 'Trying to conceive',
      ServiceStage.pregnancy => 'Pregnancy',
      ServiceStage.parenting => 'Parenting',
    };
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

  void _push(Widget s) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => s));

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
          // THE EMPTY STATE IS THE FEATURE'S ADVERTISEMENT (CLAUDE.md). This
          // card described the emptiness and then stopped, so the one parent
          // guaranteed to see it - the one who has never booked - had nowhere
          // to go from it.
          const SizedBox(height: 14),
          _emptyCta('Browse classes', () => _push(const YogaHomeScreen())),
        ]),
      );

  /// The way out of an empty state. Quiet, not a hero button - this is an
  /// invitation, not a demand.
  Widget _emptyCta(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 14, color: ppPurple),
          ]),
        ),
      );

  /// "No history" and "cannot see your history" are different sentences, and
  /// this card used to say the first when it meant the second.
  ///
  /// The history lives in `booking_bookings`, and _hydrateFromServer() opens
  /// with `if (!SupabaseRepo.isLoggedIn) return;` — so a signed-out phone reads
  /// only what that device happens to have cached locally. A parent who booked
  /// on another device, or who reinstalled, was told flatly that she had never
  /// had a consultation, while the doctor's app listed six with her.
  ///
  /// The store is right to return nothing; a booking is not the app's to show
  /// without an account. What was wrong was the sentence on top of it.
  Widget _emptyPast() {
    final signedIn = SupabaseRepo.isLoggedIn;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ppHair),
      ),
      child: Column(children: [
        Icon(signedIn ? Icons.history_rounded : Icons.cloud_off_rounded,
            size: 26, color: ppMuted),
        const SizedBox(height: 10),
        Text(signedIn ? 'No past sessions yet' : 'Sign in to see your history',
            style: ppJakarta(15, color: ppTitleInk),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
            signedIn
                ? 'Every session you attend stays here — with the doctor, the '
                    'date, and any prescription they wrote.'
                : 'Consultations you booked on another device are kept against '
                    'your account, not this phone. Signing in brings them back.',
            textAlign: TextAlign.center,
            style: ppBody(12.5, color: ppSoft, h: 1.4)),
        const SizedBox(height: 14),
        signedIn
            ? _emptyCta('Find an expert', () => _push(const ProblemSolverScreen()))
            : _emptyCta(
                'Sign in',
                () => Navigator.of(context).push(MaterialPageRoute<void>(
                      // onDone just closes it. Signing in is the whole job
                      // here; the store's own listener repopulates the list,
                      // and this screen already refreshes from the server when
                      // it rebuilds.
                      builder: (_) => AuthFlowScreen(
                        onDone: (_, _) => Navigator.of(context).maybePop(),
                      ),
                    ))),
      ]),
    );
  }

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
