// =============================================================================
//  PvOfferingScreen — one page for a course, a masterclass, a cohort, a
//  consult and a class pack
// -----------------------------------------------------------------------------
//  The finding of the learning audit (docs/LEARNING-AUDIT.md §3.1): Udemy's
//  course, MasterClass's class, Peloton's program, Airbnb's experience and
//  Alan's therapist are ONE page with a different fact strip. We had built
//  it eight times — `CourseFunnelScreen`, `MasterclassFunnelScreen`,
//  `CohortFunnelScreen`, `CourseDetailScreen`, `MasterclassDetailScreen`,
//  `CohortDetailScreen`, `ConsultationDetailScreen`, `YogaClassScreen`, and
//  two "unified" ones per stage on top — with three section orders.
//
//  THE RULE. Ten sections, fixed, in this order:
//
//    A hero · B facts · C trust · D take away · E THE STRUCTURE · F expert
//    G proof · H FAQ · I related · J the sticky bar
//
//  The kind changes what is INSIDE B, C, E and J, through
//  `pv_offering_content.dart`; this file never switches on kind except to
//  pick which structure widget draws E. A section with nothing to say is
//  skipped, never replaced with a different section.
//
//  Ownership changes only B's last fact and J. Nothing else on the page moves
//  when she buys — the page she read is the page she owns.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_store.dart';
import '../../booking/server_slots.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_learn_flow.dart';
import 'pv_lesson_screen.dart';
import 'pv_offering_content.dart';

void pvOpenOffering(BuildContext context, PvOfferingView v) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '$kPvOfferingRoutePrefix${v.id}'),
      builder: (_) => PvOfferingScreen(view: v),
    ),
  );
}

/// By catalogue id — what every facade does.
bool pvOpenOfferingById(BuildContext context, String id) {
  final v = PvLearnCatalog.instance.byId(id);
  if (v == null) return false;
  pvOpenOffering(context, v);
  return true;
}

class PvOfferingScreen extends StatefulWidget {
  const PvOfferingScreen({super.key, required this.view});
  final PvOfferingView view;

  @override
  State<PvOfferingScreen> createState() => _PvOfferingScreenState();
}

class _PvOfferingScreenState extends State<PvOfferingScreen> {
  bool _aboutOpen = false;
  final Set<int> _faqOpen = {};

  PvOfferingView get v => widget.view;

  @override
  void initState() {
    super.initState();
    BookingStore.instance.init();
    PvLearnProgressStore.instance.init();
    if (v.isLive) ServerSlotStore.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        PvLearnProgressStore.instance,
        ServerSlotStore.instance,
      ]),
      builder: (context, _) {
        final state = pvLearnStateFor(v);
        final booking = pvLearnBookingFor(v);
        final commit = pvCommitFor(v, state, booking: booking);
        final related = PvLearnCatalog.instance
            .all(stage: v.stage, kind: v.kind)
            .where((x) => x.id != v.id)
            .take(6)
            .toList();
        final faqs = v.faqs.isNotEmpty ? v.faqs : pvDefaultFaqs(v);
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ---- A · hero ----------------------------------------------------------------
                  SliverToBoxAdapter(child: _hero(p, state)),
                  // ---- B · facts ---------------------------------------------------------------
                  if (v.facts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: PvFactStrip(facts: v.facts),
                      ),
                    ),
                  // ---- about ---------------------------------------------------------------------
                  SliverToBoxAdapter(child: _about(p)),
                  // ---- C · trust ----------------------------------------------------------------
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        children: [
                          for (final t in pvTrustRowsFor(v)) PvTrustRow(t),
                        ],
                      ),
                    ),
                  ),
                  // ---- D · take away ------------------------------------------------------------
                  if (v.takeaways.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: PvLearnHead(
                        v.kind == PvLearnKind.consult
                            ? 'What a session covers'
                            : "What you'll take away",
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PvTickList(v.takeaways),
                      ),
                    ),
                  ],
                  // ---- E · THE STRUCTURE ----------------------------------------------------------
                  ..._structure(p, state),
                  // ---- F · expert ---------------------------------------------------------------
                  if (v.kind != PvLearnKind.consult) ...[
                    SliverToBoxAdapter(
                      child: PvLearnHead(
                        v.kind == PvLearnKind.cohort
                            ? 'Who leads it'
                            : 'Who teaches it',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PvExpertCard(
                          expert: v.expert,
                          line: v.expert.bio.isNotEmpty
                              ? v.expert.bio
                              : v.expert.role,
                          onTap: v.expert.expert == null
                              ? null
                              : () => openExpertProfile(
                                  context,
                                  v.expert.expert!,
                                ),
                        ),
                      ),
                    ),
                  ],
                  // ---- G · proof ----------------------------------------------------------------
                  if (v.reviews.isNotEmpty || v.rating != null) ...[
                    SliverToBoxAdapter(
                      child: PvLearnHead(
                        'What parents said',
                        lead: v.rating == null
                            ? null
                            : '${v.rating!.toStringAsFixed(1)} of 5${v.reviewsLabel.isEmpty ? '' : ' · ${v.reviewsLabel}'}',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            for (final r in v.reviews.take(3))
                              PvLearnReviewCard(r),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // ---- H · FAQ ------------------------------------------------------------------
                  if (faqs.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: PvLearnHead('Questions')),
                    SliverToBoxAdapter(child: _faq(p, faqs)),
                  ],
                  // ---- I · related --------------------------------------------------------------
                  if (related.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: PvLearnHead(
                        v.kind == PvLearnKind.consult
                            ? 'Other experts'
                            : 'More like this',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: PvLearnRail(
                        views: related,
                        onOpen: (x) => pvOpenOffering(context, x),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SizedBox(height: kPvStickyBarClearance),
                  ),
                ],
              ),
              // ---- J · the sticky bar ----------------------------------------------------------
              PvLearnCommitBar(
                price:
                    state == PvLearnState.watching ||
                        state == PvLearnState.owned ||
                        state == PvLearnState.booked
                    ? (v.isFree ? 'Free' : 'Yours')
                    : v.priceLabel,
                unit: v.isFree ? 'always' : v.priceUnit,
                note: commit.note,
                verb: commit.verb,
                onTap: () => pvLearnCommit(context, v),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---- A --------------------------------------------------------------------------------

  Widget _hero(dynamic p, PvLearnState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: PvLearnCover(view: v, radius: 0),
          ),
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 10,
            child: PvRoundIcon(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 14,
            child: PvKindTag(
              v.kind.label,
              onPhoto: true,
              live: v.isLive && v.kind != PvLearnKind.consult,
            ),
          ),
          if (state == PvLearnState.booked)
            Positioned(
              right: 16,
              bottom: 14,
              child: PvKindTag('Booked', onPhoto: true),
            )
          else if (state == PvLearnState.owned ||
              (state == PvLearnState.watching && !v.isFree))
            Positioned(
              right: 16,
              bottom: 14,
              child: PvKindTag('Yours', onPhoto: true),
            ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v.title,
              style: pvFraunces(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.15,
                letterSpacing: -0.3,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              v.subtitle,
              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 16, color: p.ink3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    v.kind == PvLearnKind.consult
                        ? v.expert.role
                        : 'with ${v.expert.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink2,
                    ),
                  ),
                ),
                if (v.rating != null) ...[
                  Icon(Icons.star_rounded, size: 15, color: kPvStar),
                  const SizedBox(width: 3),
                  Text(
                    v.rating!.toStringAsFixed(1),
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _about(dynamic p) {
    if (v.about.isEmpty) return const SizedBox.shrink();
    final long = v.about.length > 220;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v.about,
            maxLines: _aboutOpen || !long ? null : 4,
            overflow: _aboutOpen || !long
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1),
          ),
          if (long)
            GestureDetector(
              onTap: () => setState(() => _aboutOpen = !_aboutOpen),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _aboutOpen ? 'Show less' : 'Show more',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---- E --------------------------------------------------------------------------------

  List<Widget> _structure(dynamic p, PvLearnState state) {
    final title = pvStructureTitle(v);
    final progress = PvLearnProgressStore.instance;
    // Recorded: the lessons.
    if (v.lessons.isNotEmpty) {
      final done = progress.doneCount(v.id);
      return [
        SliverToBoxAdapter(
          child: PvLearnHead(
            title,
            lead: v.lessons.length == 1
                ? null
                : '${v.lessons.length} lessons${v.totalMinutes > 0 ? ' · ${v.totalMinutes} min' : ''}${done > 0 ? ' · $done done' : ''}'
                      '${state == PvLearnState.none && !v.isFree ? ' · first lesson free' : ''}',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (var i = 0; i < v.lessons.length; i++)
                  PvLessonRow(
                    index: i + 1,
                    lesson: v.lessons[i],
                    done: progress.isDone(v.lessons[i].id),
                    gated: pvLessonGated(v, i),
                    onTap: () => pvLessonGated(v, i)
                        ? pvLearnCommit(context, v)
                        : pvOpenLesson(context, v, i),
                  ),
              ],
            ),
          ),
        ),
      ];
    }
    // Live: the weeks / the evening / how it works.
    final sessions = v.sessions.isNotEmpty ? v.sessions : pvHowItWorks(v);
    if (sessions.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: PvLearnHead(
          title,
          lead: v.rhythm.isNotEmpty && v.kind == PvLearnKind.cohort
              ? v.rhythm.join(' · ')
              : null,
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var i = 0; i < sessions.length; i++)
                PvWeekCard(sessions[i], index: i),
            ],
          ),
        ),
      ),
    ];
  }

  // ---- H --------------------------------------------------------------------------------

  Widget _faq(dynamic p, List<PvLearnFaq> faqs) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPvLine),
      ),
      child: Column(
        children: [
          for (var i = 0; i < faqs.length && i < 5; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: kPvLine,
                indent: 14,
                endIndent: 14,
              ),
            InkWell(
              onTap: () => setState(
                () =>
                    _faqOpen.contains(i) ? _faqOpen.remove(i) : _faqOpen.add(i),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            faqs[i].q,
                            style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                        ),
                        Icon(
                          _faqOpen.contains(i)
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: p.ink3,
                        ),
                      ],
                    ),
                    if (_faqOpen.contains(i)) ...[
                      const SizedBox(height: 6),
                      Text(
                        faqs[i].a,
                        style: pvManrope(
                          fontSize: 13.5,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
