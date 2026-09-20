// =============================================================================
//  PvMyLearningScreen — Continue · Upcoming · Credits · Past, one list
// -----------------------------------------------------------------------------
//  `MyBookingsScreen` had the bookings and nothing about the recorded things
//  she was part-way through; Udemy's *My learning* has both. This is the
//  bookings screen grown to include her courses, on the one chrome, reading
//  the one stage-tagged history — a fertility consult booked while trying
//  and a postnatal yoga pack two years later sit in the same list, each with
//  a small stage word, as the engine intended.
//
//  Reached from You → Your things · Bookings, and from the Learn home's
//  bookmark. `MyBookingsScreen` is a facade over it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_lesson_screen.dart';
import 'pv_offering_screen.dart';
import 'pv_session_screen.dart';

class PvMyLearningScreen extends StatefulWidget {
  const PvMyLearningScreen({super.key});

  @override
  State<PvMyLearningScreen> createState() => _PvMyLearningScreenState();
}

class _PvMyLearningScreenState extends State<PvMyLearningScreen> {
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
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        PvLearnProgressStore.instance,
      ]),
      builder: (context, _) {
        final store = BookingStore.instance;
        final progress = PvLearnProgressStore.instance;
        final upcoming = store.upcoming();
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
              const SliverToBoxAdapter(
                child: PvLearnTopBar(title: 'Your learning', eyebrow: 'Learn'),
              ),
              if (empty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'Nothing here yet. A course you start, a class you book or a consult you pay for appears here, across every stage.',
                      style: pvManrope(
                        fontSize: 14,
                        height: 1.5,
                        color: p.ink2,
                      ),
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
                              sub: left <= 0
                                  ? 'All ${v.lessons.length} lessons done'
                                  : '$left of ${v.lessons.length} lessons left',
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
              // ---- upcoming ---------------------------------------------------------------------
              if (upcoming.isNotEmpty) ...[
                const SliverToBoxAdapter(child: PvLearnHead('Upcoming')),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      for (final b in upcoming)
                        PvLearnRow(
                          leadTop: pvLearnDay(b.startsUtc).toUpperCase(),
                          leadBottom: pvLearnTime(b.startsUtc),
                          tag: _stageWord(b.stage),
                          title: b.title,
                          sub: b.joinableAt(DateTime.now())
                              ? 'The room is open'
                              : 'Starts ${pvLearnCountdown(b.startsUtc, b.endsUtc)}',
                          onTap: () => pvOpenSession(context, b),
                          trailing: b.joinableAt(DateTime.now())
                              ? Text(
                                  'Join',
                                  style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.ink1,
                                  ),
                                )
                              : null,
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
              // ---- past ---------------------------------------------------------------------------
              if (past.isNotEmpty) ...[
                const SliverToBoxAdapter(child: PvLearnHead('Past')),
                SliverToBoxAdapter(
                  child: Column(
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
