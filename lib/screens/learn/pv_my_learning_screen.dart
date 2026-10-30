// =============================================================================
//  PvMyLearningScreen — Your bookings: Upcoming · Continue · Credits · Past
// -----------------------------------------------------------------------------
//  `MyBookingsScreen` had the bookings and nothing about the recorded things
//  she was part-way through; Udemy's *My learning* has both. This is the
//  bookings screen grown to include her courses, on the one chrome, reading
//  the one stage-tagged history — a fertility consult booked while trying
//  and a postnatal yoga pack two years later sit in the same list, each with
//  a small stage word, as the engine intended.
//
//  Reached from Profile › Your bookings and More › Bookings (route
//  'bookings'), and from the Learn home's bookmark (route 'learn/mine', where
//  it keeps the title "Your learning"). `MyBookingsScreen` is a facade over
//  it.
//
//  ⚠️ ELEVATED 2026-09-29 (the one-app pass on the store). An upcoming
//  booking was one row: a date, a title and "Starts in 3 days". She could not
//  see who, or how to join, without opening it. Now each is a card that
//  answers the four questions in the order Zocdoc and Practo answer them:
//
//    WHEN  the day and time in serif, with the time zone and the length
//    WHAT  the consult or class, with its kind as a tag
//    WHO   the expert's name and specialty beside a MONOGRAM (her initials),
//          never a stock face: a picture that is not of the person reads as
//          her (the 2026-09-22 walk's rule, `PvLearnRow.initials`)
//    HOW   "Video call in the app" and ONE ink Join button, live from ten
//          minutes before (the engine's `joinableAt`), and before that the
//          same button, disabled, saying when it opens
//
//  and under them Reschedule and Cancel, outlined, only where the session
//  page offers them (the same condition, the same functions:
//  `pvRescheduleBooking` and `pvConfirmCancelBooking`). Money and seats are
//  decided server-side (`BookingStore.release` and `reserve` call the
//  server); this page only asks.
//
//  Past bookings fold under one row (Uber's Activity, Tripadvisor's Past):
//  what already happened should not push what is next off the screen.
//  With nothing upcoming, the section says so and offers a way to book
//  (Uber: "You have no upcoming trips · Reserve your ride"), because an empty
//  section is the feature's advertisement.
//
//  Mobbin:
//    · Zocdoc, Appointments "Up next": the date and time large, the doctor
//      and specialty under it, one outlined "Book an appointment" below.
//      https://mobbin.com/screens/14e7f095-1b94-4e03-96e3-1b3fec5c9aa5
//    · TheFork, Bookings: an Upcoming card with Modify and Cancel as two
//      outlined buttons on the card.
//      https://mobbin.com/screens/0a4043a9-cf05-4172-9110-ad0dae6cbf20
//    · Future, Kickoff call: the coach by name, the time, the call's length
//      and medium on one card, with Reschedule on it.
//      https://mobbin.com/screens/2b5839c4-0519-4df7-9341-bd7fd3a0f60b
//    · Uber, Activity: Upcoming with an honest empty state and a way to book,
//      Past under it.
//      https://mobbin.com/screens/2c41d986-0dab-44d9-b14a-8921c2dcf1e6
//    · Beli, Your reservations: a date block, then Past.
//      https://mobbin.com/screens/03cb7619-68e6-4030-91ec-70b6a18cae7c
//  What was not taken: photographs on the cards (Peerspace, Booking.com); a
//  consult has no picture of its own, and a stock one would be a face.
//
//  L2c (2026-10-29, L.22): PAYMENTS. Every payment and refund she has made,
//  in every stage, read from the server (`my_purchases()`, 0126) and cached
//  on the phone, so a reinstall or a new phone shows the same history. Each
//  row opens its receipt: amount, date, payment id, status, and what the
//  refund rule says today. The rule is the SERVER's verdict (`_refund_check`)
//  shown, never re-derived; "Request a refund" asks `request_refund` and shows
//  its answer. Shop orders stay in Your orders. Prototype screen 8, signed off
//  2026-10-29.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_community_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_learn_screen.dart' show openPvLearn;
import 'pv_lesson_screen.dart';
import 'pv_offering_screen.dart';
import 'pv_recording_screen.dart';
import 'pv_session_screen.dart';

/// The route this screen is opened under from the Learn home's bookmark.
/// Under any other route (Profile, More: 'bookings') it is "Your bookings".
const String kPvMyLearningRoute = 'learn/mine';

class PvMyLearningScreen extends StatefulWidget {
  const PvMyLearningScreen({super.key});

  @override
  State<PvMyLearningScreen> createState() => _PvMyLearningScreenState();
}

class _PvMyLearningScreenState extends State<PvMyLearningScreen> {
  /// Past bookings start folded (2026-09-29).
  bool _pastOpen = false;

  @override
  void initState() {
    super.initState();
    BookingStore.instance.init();
    PvLearnProgressStore.instance.init();
    // Settle anything that has finished, from whether she actually joined.
    BookingStore.instance.settleAttendance();
    // Payments are the server's record; re-read them each time she looks.
    BookingStore.instance.syncPurchases();
    // (L3) And which past sessions she can watch again.
    BookingStore.instance.syncRecordings();
    // (0137, LA-22) A class the server moved says so on its card, read from
    // the pinned notice in that course's discussion.
    final programmes = {
      for (final b in BookingStore.instance.upcoming())
        if (b.slotId.startsWith('ps_')) PvLearnCatalog.instance.byOfferingId(b.offeringId)?.id,
    }.whereType<String>();
    PvCommunityStore.instance.init().then((_) {
      for (final id in programmes) {
        PvCommunityStore.instance.loadCourseNotices(id);
      }
    });
  }

  /// "Watch" on a past row whose recording is ready. Nothing otherwise: the
  /// row's quieter line already says whether one is on its way.
  Widget? _watchButton(
      BuildContext context, Booking b, Map<String, dynamic>? rec) {
    if (rec == null || rec['status'] != 'ready') return null;
    return TextButton(
      key: ValueKey('pv_bookings_watch_${b.id}'),
      onPressed: () => pvOpenRecording(context,
          title: (rec['title'] ?? b.title).toString(),
          recordingId: rec['id'].toString()),
      child: const Text('Watch'),
    );
  }

  static String _stageWord(ServiceStage s) => switch (s) {
    ServiceStage.tryingToConceive => 'Trying',
    ServiceStage.pregnancy => 'Pregnancy',
    ServiceStage.parenting => 'Parenting',
  };

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final learning =
        ModalRoute.of(context)?.settings.name == kPvMyLearningRoute;
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        PvLearnProgressStore.instance,
        PvCommunityStore.instance,
      ]),
      builder: (context, _) {
        final store = BookingStore.instance;
        final progress = PvLearnProgressStore.instance;
        final now = DateTime.now();
        // `upcoming()` is by status; one whose end has passed but is not yet
        // settled belongs with the past, as the old list already counted it.
        final upcoming = store
            .upcoming()
            .where((b) => now.toUtc().isBefore(b.endsUtc))
            .toList();
        final past =
            store
                .bookings()
                .where(
                  (b) =>
                      !b.isUpcoming ||
                      DateTime.now().toUtc().isAfter(b.endsUtc),
                )
                .toList()
              ..sort((a, b) => b.startsUtc.compareTo(a.startsUtc));
        final credits = store
            .entitlements()
            .where((e) => e.canBook && e.creditsTotal > 1)
            .toList();
        final courses = <PvOfferingView>[
          for (final id in progress.recentCourses)
            if (PvLearnCatalog.instance.byId(id) case final v?)
              if (v.lessons.isNotEmpty) v,
        ];
        final empty =
            upcoming.isEmpty &&
            past.isEmpty &&
            credits.isEmpty &&
            courses.isEmpty;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              // Kept for revert (2026-09-29): one title for every door,
              //   const PvLearnTopBar(title: 'Your learning', eyebrow: 'Learn'),
              SliverToBoxAdapter(
                child: learning
                    ? const PvLearnTopBar(
                        title: 'Your learning',
                        eyebrow: 'Learn',
                      )
                    : const PvLearnTopBar(title: 'Your bookings'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Text(
                    'Consults, classes and courses you have booked, across every stage.',
                    style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2),
                  ),
                ),
              ),
              // Kept for revert (2026-09-29): with nothing at all, one line,
              //   'Nothing here yet. A course you start, a class you book or a
              //   consult you pay for appears here, across every stage.'
              // Now the Upcoming section always draws, and says so itself.
              // ---- upcoming ---------------------------------------------------------------------
              const SliverToBoxAdapter(child: PvLearnHead('Upcoming')),
              if (upcoming.isEmpty)
                SliverToBoxAdapter(child: _EmptyUpcoming(first: empty))
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final b in upcoming) ...[
                          PvBookingCard(
                            booking: b,
                            stageWord: _stageWord(b.stage),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              // ---- continue ---------------------------------------------------------------------
              if (courses.isNotEmpty) ...[
                const SliverToBoxAdapter(child: PvLearnHead('Continue')),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      for (final v in courses)
                        Builder(
                          builder: (context) {
                            final done = progress.doneCount(v.id);
                            final left = v.lessons.length - done;
                            return PvLearnRow(
                              view: v,
                              title: v.title,
                              sub: pvLearnLeftLine(done, v.lessons.length),
                              onTap: () {
                                final last = progress.lastLesson(v.id);
                                final i = last == null
                                    ? 0
                                    : v.lessons.indexWhere((l) => l.id == last);
                                pvOpenLesson(context, v, i < 0 ? 0 : i);
                              },
                              trailing: Text(
                                left <= 0 ? 'Done' : 'Continue',
                                style: pvManrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
              // ---- credits ----------------------------------------------------------------------
              if (credits.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: PvLearnHead(
                    'Credits',
                    lead: 'Bought, not yet booked.',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      for (final e in credits)
                        PvLearnRow(
                          view: PvLearnCatalog.instance.byOfferingId(
                            e.offeringId,
                          ),
                          leadTop:
                              PvLearnCatalog.instance.byOfferingId(
                                    e.offeringId,
                                  ) ==
                                  null
                              ? 'LEFT'
                              : null,
                          leadBottom:
                              PvLearnCatalog.instance.byOfferingId(
                                    e.offeringId,
                                  ) ==
                                  null
                              ? '${e.creditsLeft}'
                              : null,
                          tag: _stageWord(e.stage),
                          title: e.title,
                          sub:
                              '${e.creditsLeft} of ${e.creditsTotal} left${e.expiresUtc == null ? '' : ' · until ${pvLearnDay(e.expiresUtc!)}'}',
                          onTap: () {
                            final v = PvLearnCatalog.instance.byOfferingId(
                              e.offeringId,
                            );
                            if (v != null) pvOpenOffering(context, v);
                          },
                        ),
                    ],
                  ),
                ),
              ],
              // ---- payments (L2c, L.22) ---------------------------------------------------------
              // Always drawn: the empty line is the section's advertisement.
              const SliverToBoxAdapter(
                child: PvLearnHead(
                  'Payments',
                  lead: 'Every payment and refund, with its receipt.',
                ),
              ),
              SliverToBoxAdapter(
                child: _Payments(
                  purchases: store.purchases,
                  stageWord: _stageWord,
                ),
              ),
              // ---- past, folded -------------------------------------------------------------------
              if (past.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: _PastFold(
                      count: past.length,
                      open: _pastOpen,
                      onTap: () => setState(() => _pastOpen = !_pastOpen),
                    ),
                  ),
                ),
                if (_pastOpen)
                  SliverToBoxAdapter(
                    child: Column(
                      key: const ValueKey('pv_bookings_past_list'),
                      children: [
                        for (final b in past.take(30))
                          PvLearnRow(
                            leadTop: pvLearnDay(b.startsUtc).toUpperCase(),
                            leadBottom: pvLearnTime(b.startsUtc),
                            tag: _stageWord(b.stage),
                            title: b.title,
                            // (L3, L.22) Attendance is the server's since
                            // 0128: what LiveKit saw, the phone as fallback.
                            sub: pvPastStatusLine(b),
                            foot: pvPastRecordingLine(
                                store.recordingForSlot(b.slotId)),
                            trailing: _watchButton(context, b,
                                store.recordingForSlot(b.slotId)),
                            onTap: () => pvOpenSession(context, b),
                          ),
                      ],
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
}

/// A past booking's status, in her words (L3). A session the host never
/// joined says so, and says what happened next, instead of a bare
/// "Cancelled" that reads as if she cancelled it.
String pvPastStatusLine(Booking b) {
  if (b.hostMissed) {
    return "The host couldn't make it. Your seat or credit is back";
  }
  return switch (b.status) {
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.missed => 'Missed',
    BookingStatus.attended => 'Attended',
    BookingStatus.upcoming => 'Done',
  };
}

/// The recording's state under a past row, or null when there is none.
String? pvPastRecordingLine(Map<String, dynamic>? rec) {
  if (rec == null) return null;
  return switch (rec['status']) {
    'ready' => 'Recording ready to watch',
    'recording' || 'uploaded' || 'importing' =>
      'Recording on its way, usually within the hour',
    _ => null,
  };
}

/// The local time zone, short: "IST", else "GMT+5:30" (a device can report
/// "India Standard Time", which is a sentence, not a label).
String pvBookingZone(DateTime utc) {
  final d = utc.toLocal();
  final name = d.timeZoneName;
  if (name.isNotEmpty && name.length <= 5 && !name.contains(' ')) return name;
  final o = d.timeZoneOffset;
  final sign = o.isNegative ? '-' : '+';
  final m = o.inMinutes.abs();
  final mm = m % 60;
  return 'GMT$sign${m ~/ 60}${mm == 0 ? '' : ':${mm.toString().padLeft(2, '0')}'}';
}

/// One upcoming booking: when, what, who, how to join, and what she can
/// change. Tapping the card opens the session page (prepare, calendar,
/// partner line), as the old row did.
class PvBookingCard extends StatelessWidget {
  const PvBookingCard({
    super.key,
    required this.booking,
    required this.stageWord,
    this.now,
  });
  final Booking booking;
  final String stageWord;

  /// For tests: the clock the Join button is judged by.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final b = booking;
    final v = PvLearnCatalog.instance.byOfferingId(b.offeringId);
    final at = now ?? DateTime.now();
    final joinable = b.joinableAt(at);
    final opens = b.startsUtc.subtract(const Duration(minutes: 10));
    // The same condition as the session page's round buttons.
    final canReschedule =
        v != null && v.offering != null && v.kind != PvLearnKind.cohort;
    final who = v?.expert;
    final big = MediaQuery.textScalerOf(context).scale(10) / 10 > 1.3;
    return Semantics(
      container: true,
      child: InkWell(
        key: ValueKey('pv_booking_card_${b.id}'),
        onTap: () => pvOpenSession(context, b),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPvLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WHEN
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PvKindTag(v?.kind.label ?? 'Booking'),
                  PvKindTag(stageWord),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${pvLearnDay(b.startsUtc)}, ${pvLearnTime(b.startsUtc)}',
                style: pvFraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${pvBookingZone(b.startsUtc)} · ${b.durationMin} min',
                style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: p.ink2,
                ),
              ),
              // (0137, LA-22) The same words as the team notice.
              if (PvCommunityStore.instance.movedFrom(b.slotId) case final was?) ...[
                const SizedBox(height: 4),
                Text(
                  'Moved from ${pvLearnDay(was.toUtc())}, ${pvLearnTime(was.toUtc())}',
                  key: ValueKey('pv_booking_moved_${b.id}'),
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC6295A),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // WHAT
              Text(
                b.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: p.ink1,
                ),
              ),
              // WHO
              if (who != null && who.name.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.surfaceAlt,
                      ),
                      child: Text(
                        pvLearnInitials(who.name),
                        style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: p.ink1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            who.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                          if (who.role.isNotEmpty)
                            Text(
                              who.role,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                fontSize: 12.5,
                                height: 1.35,
                                color: p.ink2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              // HOW
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.videocam_outlined, size: 17, color: p.ink1),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      joinable
                          ? 'Video call in the app. The room is open.'
                          : 'Video call in the app. Nothing to install.',
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.35,
                        color: p.ink2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PvCommit(
                key: ValueKey('pv_booking_join_${b.id}'),
                label: joinable
                    ? 'Join video call'
                    : 'Join from ${pvLearnTime(opens)}',
                icon: joinable ? Icons.videocam_rounded : null,
                onTap: joinable ? () => pvOpenCall(context, b) : null,
              ),
              const SizedBox(height: 8),
              // Side by side; stacked at large text, so "Reschedule" is never
              // cut to "Resched…" (360dp at 1.5x).
              Flex(
                direction: big ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: big
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [
                  if (canReschedule) ...[
                    _grow(
                      big,
                      _SmallOutline(
                        key: ValueKey('pv_booking_reschedule_${b.id}'),
                        label: 'Reschedule',
                        onTap: () async {
                          final nb = await pvRescheduleBooking(context, b, v);
                          if (nb != null && context.mounted) {
                            pvOpenSession(context, nb, justBooked: true);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8, height: 8),
                  ],
                  _grow(
                    big,
                    _SmallOutline(
                      key: ValueKey('pv_booking_cancel_${b.id}'),
                      label: 'Cancel',
                      onTap: () => pvConfirmCancelBooking(context, b, v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _grow(bool big, Widget child) =>
    big ? child : Expanded(child: child);

/// The card's secondary actions: outlined ink, shorter than the Join pill so
/// the one filled button stays the one filled button.
class _SmallOutline extends StatelessWidget {
  const _SmallOutline({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: kPvInk, width: 1.2),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: pvManrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: kPvInk,
          ),
        ),
      ),
    ),
  );
}

/// Nothing upcoming: say so, and offer the way to book.
class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming({required this.first});

  /// Nothing at all yet (no past, no courses): the first-visit words.
  final bool first;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      key: const ValueKey('pv_bookings_empty'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            first ? 'Nothing booked yet.' : 'Nothing coming up.',
            style: pvManrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Book a private video consult with a specialist, or a live class. '
            'It shows here with its time, who it is with and a Join button.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
          ),
          const SizedBox(height: 14),
          PvSecondary(
            key: const ValueKey('pv_bookings_find'),
            label: 'Find a consult or class',
            icon: Icons.search_rounded,
            onTap: () =>
                openPvLearn(context, stage: LifeStageStore.instance.stage),
          ),
        ],
      ),
    );
  }
}

/// The folded Past heading: one row with the count and a chevron.
class _PastFold extends StatelessWidget {
  const _PastFold({
    required this.count,
    required this.open,
    required this.onTap,
  });
  final int count;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Semantics(
      button: true,
      expanded: open,
      child: InkWell(
        key: const ValueKey('pv_bookings_past_fold'),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: kPvLine),
              bottom: BorderSide(color: kPvLine),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Past bookings · $count',
                  style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: p.ink1,
                  ),
                ),
              ),
              Icon(
                open
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: p.ink1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- kept for revert (2026-09-29): the upcoming list as rows -------------------
//
//   if (upcoming.isNotEmpty) ...[
//     const SliverToBoxAdapter(child: PvLearnHead('Upcoming')),
//     SliverToBoxAdapter(child: Column(children: [
//       for (final b in upcoming)
//         PvLearnRow(
//           leadTop: pvLearnDay(b.startsUtc).toUpperCase(),
//           leadBottom: pvLearnTime(b.startsUtc),
//           tag: _stageWord(b.stage),
//           title: b.title,
//           sub: b.joinableAt(DateTime.now())
//               ? 'The room is open'
//               : 'Starts ${pvLearnCountdown(b.startsUtc, b.endsUtc)}',
//           onTap: () => pvOpenSession(context, b),
//           trailing: b.joinableAt(DateTime.now())
//               ? Text('Join', style: pvManrope(fontSize: 12.5,
//                   fontWeight: FontWeight.w800, color: p.ink1))
//               : null,
//         ),
//     ])),
//   ],
//
// and Past, always open, under `const PvLearnHead('Past')`, the same rows as
// the fold draws now.


// =============================================================================
//  Payments (L2c, L.22)
// =============================================================================

/// Rupees from paise, Indian grouping: 149900 -> "₹1,499".
String pvRupees(int minor) {
  final s = (minor ~/ 100).toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹${parts.join(',')},$last3';
}

/// The one line under a payment: what happened to it, then what the refund
/// rule says. Both are the server's words, put into hers.
String pvPurchaseLine(Purchase p) {
  final what = switch (p.status) {
    'refund_requested' => 'Refund requested · access ended',
    'refunded' => 'Refunded',
    'revoked' => 'Ended',
    _ => p.provider == 'free'
        ? 'Free'
        : p.isTest
        ? 'Paid · test purchase'
        : 'Paid',
  };
  if (!p.isActive || !p.refundEligible) return what;
  final until = p.refundUntilUtc;
  return until == null
      ? '$what · refundable'
      : '$what · refundable until ${pvLearnDay(until)}';
}

class _Payments extends StatelessWidget {
  const _Payments({required this.purchases, required this.stageWord});
  final List<Purchase> purchases;
  final String Function(ServiceStage) stageWord;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    if (purchases.isEmpty) {
      return Padding(
        key: const ValueKey('pv_payments_empty'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Text(
          SupabaseRepo.isLoggedIn
              ? 'Nothing paid yet. Every course, class or consult you buy '
                    'shows here, with its receipt and its refund rule.'
              : 'Sign in to see your payments. They are kept on your '
                    'account, so they follow you to a new phone.',
          style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2),
        ),
      );
    }
    return Column(
      key: const ValueKey('pv_payments_list'),
      children: [
        for (final x in purchases.take(50))
          PvLearnRow(
            leadTop: pvLearnDay(x.paidUtc).toUpperCase(),
            leadBottom: x.provider == 'free' ? 'Free' : pvRupees(x.amountMinor),
            tag: x.stage == null ? null : stageWord(x.stage!),
            title: x.title.isEmpty ? 'Purchase' : x.title,
            sub: pvPurchaseLine(x),
            onTap: () => showPvReceiptSheet(context, x),
          ),
      ],
    );
  }
}

/// The receipt: what was paid, when, the payment id, the status, the refund
/// rule's verdict, and - only where that verdict says yes - the refund button.
Future<void> showPvReceiptSheet(BuildContext context, Purchase x) {
  final p = pvStorePalette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ReceiptSheet(purchase: x),
  );
}

class _ReceiptSheet extends StatefulWidget {
  const _ReceiptSheet({required this.purchase});
  final Purchase purchase;

  @override
  State<_ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends State<_ReceiptSheet> {
  /// Asking is two taps: the first shows what a refund ends (L.12: the
  /// seat, the recording and the discussion), the second asks the server.
  bool _confirming = false;
  bool _busy = false;

  Future<void> _refund() async {
    setState(() => _busy = true);
    final answer = await BookingStore.instance.requestRefund(widget.purchase);
    if (!mounted) return;
    final messenger = context;
    Navigator.of(context).pop();
    if (messenger.mounted) pvSnack(messenger, answer);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final x = widget.purchase;
    Widget line(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(k, style: pvManrope(fontSize: 13, color: p.ink3)),
          ),
          Expanded(
            child: Text(
              v,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: p.ink1,
              ),
            ),
          ),
        ],
      ),
    );
    final rule = x.isActive && !x.refundEligible && x.refundReason.isNotEmpty
        ? pvRefundRefusal(x.refundReason)
        : null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              x.title.isEmpty ? 'Receipt' : x.title,
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 14),
            line('Amount', x.provider == 'free' ? 'Free' : pvRupees(x.amountMinor)),
            line('Date', '${pvLearnDay(x.paidUtc)}, ${pvLearnTime(x.paidUtc)}'),
            line('Status', pvPurchaseLine(x)),
            if (x.refundedUtc != null)
              line(
                'Refunded',
                '${pvLearnDay(x.refundedUtc!)}${x.refundMinor == null ? '' : ' · ${pvRupees(x.refundMinor!)}'}',
              ),
            if (x.paymentId != null && x.paymentId!.isNotEmpty)
              line('Payment id', x.paymentId!),
            if (x.isTest)
              line('Note', 'A test purchase. No money moved.'),
            if (rule != null) ...[
              const SizedBox(height: 4),
              Text(
                rule,
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
              ),
            ],
            if (x.isActive && x.refundEligible) ...[
              const SizedBox(height: 12),
              if (_confirming)
                Text(
                  'A refund ends the seat, the recording and the discussion '
                  'that came with this.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PvSecondary(
                      label: _confirming ? 'Keep it' : 'Close',
                      onTap: () => _confirming
                          ? setState(() => _confirming = false)
                          : Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PvCommit(
                      key: const ValueKey('pv_receipt_refund'),
                      label: _busy
                          ? 'Asking...'
                          : _confirming
                          ? 'Yes, refund'
                          : 'Request a refund',
                      onTap: _busy
                          ? null
                          : () => _confirming
                                ? _refund()
                                : setState(() => _confirming = true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
