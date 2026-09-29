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
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_learn_screen.dart' show openPvLearn;
import 'pv_lesson_screen.dart';
import 'pv_offering_screen.dart';
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
                            sub: switch (b.status) {
                              BookingStatus.cancelled => 'Cancelled',
                              BookingStatus.missed => 'Missed',
                              BookingStatus.attended => 'Attended',
                              BookingStatus.upcoming => 'Done',
                            },
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
