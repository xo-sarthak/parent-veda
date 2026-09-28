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
import '../../services/life_stage_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import 'pv_learn_catalog.dart';
import '../products/pv_review_block.dart';
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
                  // ⚠️ NOT FOR A PERSON — 2026-09-22, the walk. A consult's four facts
                  // read "30 min · MBBS, MD (OB-GY… · English · 4.9 rated": her
                  // qualification truncated mid-word, and her role and her rating
                  // printed a second time under a header that had just said both.
                  // Zocdoc puts the same facts on ONE line under the name. The strip
                  // stays for courses, classes and cohorts, where those four numbers
                  // ARE the offer.
                  if (v.facts.isNotEmpty && v.kind != PvLearnKind.consult)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: PvFactStrip(facts: pvLearnFacts(v)),
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
                  if (v.reviews.isNotEmpty || v.rating != null)
                    SliverToBoxAdapter(
                      child: PvReviewBlock(
                        // Who is on the other end changes the word. A
                        // masterclass on latch is read by mothers; a
                        // parenting cohort by both of them.
                        title: v.stage == LifeStage.parenting
                            ? 'What parents said'
                            : 'What mothers said',
                        rating: v.rating,
                        countLabel: v.reviewsLabel,
                        hue: v.hue,
                        sourceLine: v.kind == PvLearnKind.consult
                            ? 'Only people who finished a consult with her can leave one.'
                            : 'Only people who took this can leave one.',
                        voices: [
                          for (final r in v.reviews.take(6))
                            PvReviewVoice(
                              name: r.name,
                              context: r.who,
                              quote: r.quote,
                              stars: r.stars,
                            ),
                        ],
                      ),
                    ),
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
                // ⚠️ ONCE SHE OWNS IT, THIS IS NOT A PRICE SLOT — the user,
                // 2026-09-22: "I'm inside a course. What is this Yours tag?
                // And at the bottom, Yours, yours to keep. What does this
                // even mean?" Right, and the bug is conceptual rather than a
                // bad string: the bar's left column was built to say WHAT IT
                // COSTS, and when there was nothing left to charge it kept
                // the shape and filled it with the only other word to hand.
                // "Yours" over "yours to keep" is one fact said twice, under
                // a hero already wearing a "Yours" tag — three times, in a
                // column that could have been useful.
                //
                // A slot that has run out of its own question should take
                // the next one, not repeat the last answer. Before she
                // starts, that question is how much of this there is; after
                // she starts, how far in she got. So it becomes progress.
                //
                // Kept for revert:
                //   price: owns ? (v.isFree ? 'Free' : 'Yours') : v.priceLabel,
                //   unit:  owns ? 'yours to keep' : v.priceUnit,
                price: _leftTitle(v, state),
                unit: _leftUnit(v, state),
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
            // H17 (TTC launch sanity, 2026-09-28): a 1:1 consult with a
            // named person and no photo opens on her monogram on the page's
            // own colour, not a speech-bubble drawing that reads as a
            // template. Kept for revert: PvLearnCover(view: v, radius: 0).
            child: pvShowsConsultMonogram(v)
                ? PvConsultMonogramCover(view: v)
                : PvLearnCover(view: v, radius: 0),
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
              // A person's page is titled with her name. "Consult with Dr.
              // Aparna Joshi" over a photograph of Dr. Aparna Joshi says it
              // twice; the booking still carries the long title, because a
              // history row needs to say what was bought.
              v.kind == PvLearnKind.consult ? v.expert.name : v.title,
              style: pvFraunces(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                height: 1.15,
                letterSpacing: -0.3,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 6),
            if (!_saidTwice(v))
              Text(
                v.kind == PvLearnKind.consult ? v.expert.role : v.subtitle,
                style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2),
              ),
            const SizedBox(height: 10),
            if (v.kind == PvLearnKind.consult)
              // Zocdoc's one line under the name: how good, how long in the
              // job, what she speaks. Everything the strip used to repeat.
              Row(
                children: [
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
                    if (v.reviewsLabel.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        '· ${v.reviewsLabel}',
                        style: pvManrope(fontSize: 12.5, color: p.ink3),
                      ),
                    ],
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      [
                        for (final f in v.facts)
                          if (f.label == 'video session' ||
                              f.label == 'experience' ||
                              f.label == 'speaks')
                            f.value,
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 13, color: p.ink2),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  // Her initials, not a borrowed person glyph — the same
                  // disc the consult rows wear, so one page and the list it
                  // came from name her the same way.
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.surfaceAlt,
                    ),
                    child: Text(
                      pvLearnInitials(v.expert.name),
                      style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: p.ink2,
                      ),
                    ),
                  ),
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

  /// True when the About paragraph already opens with the subtitle — the
  /// same words, punctuation and case ignored.
  static bool _saidTwice(PvOfferingView v) {
    if (v.kind == PvLearnKind.consult) return false;
    String flat(String x) =>
        x.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
    final sub = flat(v.subtitle);
    if (sub.length < 12) return false;
    return flat(v.about).startsWith(sub.substring(0, sub.length ~/ 2));
  }

  /// The bar's left column, top line. A price before she owns it; how much
  /// of it there is, or how far in she is, after.
  static String _leftTitle(PvOfferingView v, PvLearnState state) {
    final owns = state == PvLearnState.owned || state == PvLearnState.watching;
    if (state == PvLearnState.booked) return 'Booked';
    if (!owns) return v.isFree ? 'Free' : v.priceLabel;
    final lessons = v.lessons.length;
    if (lessons == 0) return v.durationLabel.isEmpty ? 'Open' : v.durationLabel;
    final done = PvLearnProgressStore.instance.doneCount(v.id);
    if (done == 0) return '$lessons lessons';
    if (done >= lessons) return 'Finished';
    return '$done of $lessons';
  }

  /// The quiet line under it. Never the payment unit once there is no
  /// payment left to describe — see the note at the call site.
  static String _leftUnit(PvOfferingView v, PvLearnState state) {
    final owns = state == PvLearnState.owned || state == PvLearnState.watching;
    if (state == PvLearnState.booked) return 'you are on the list';
    if (!owns) return v.isFree ? 'always' : v.priceUnit;
    final lessons = v.lessons.length;
    if (lessons == 0) return 'yours to keep';
    final done = PvLearnProgressStore.instance.doneCount(v.id);
    if (done == 0) return 'none watched yet';
    if (done >= lessons) return 'watch any of it again';
    return 'lessons watched';
  }

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
            // ⚠️ TWO FIXES, 2026-09-22 — the user on the walk: "the questions
            // dropdown should have an effect that makes it smooth, and it has
            // that not-needed purple overlay behind, with sharp edges".
            //
            //  1. THE SHARP PURPLE. An `InkWell` with no `borderRadius`
            //     splashes a RECTANGLE. Inside a container rounded to 16 with
            //     a hairline border, that rectangle paints over the rounded
            //     corners — square corners appearing on a round card the
            //     instant you touch it. The colours are named here too rather
            //     than left to the ambient theme, because a themed default is
            //     one `Theme` wrapper away from coming back as brand violet,
            //     and DESIGN-SYSTEM §4.0 is explicit that a ripple is
            //     ink-grey and never the brand colour.
            //  2. NO ANIMATION. The answer appeared and vanished between two
            //     frames, which reads as a glitch rather than as opening.
            //     `AnimatedSize` gives the row its height over 220ms and
            //     `AnimatedRotation` turns one chevron instead of swapping
            //     two glyphs — so the arrow that pointed down is the same
            //     arrow now pointing up, which is what "smooth" means here.
            InkWell(
              onTap: () => setState(
                () =>
                    _faqOpen.contains(i) ? _faqOpen.remove(i) : _faqOpen.add(i),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(i == 0 ? 15 : 0),
                bottom: Radius.circular(
                  i == faqs.length - 1 || i == 4 ? 15 : 0,
                ),
              ),
              splashColor: p.ink1.withValues(alpha: 0.05),
              highlightColor: p.ink1.withValues(alpha: 0.03),
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
                        AnimatedRotation(
                          turns: _faqOpen.contains(i) ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 20,
                            color: p.ink3,
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _faqOpen.contains(i)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                faqs[i].a,
                                style: pvManrope(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: p.ink2,
                                ),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
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

/// Whether the consult page opens on the person's monogram (H17): a Trying to
/// conceive consult, with a named person, and no photograph of anyone.
bool pvShowsConsultMonogram(PvOfferingView v) =>
    v.kind == PvLearnKind.consult &&
    v.stage == LifeStage.tryingToConceive &&
    v.cover == null &&
    !pvLearnHasNoNamedPerson(v);

/// The person's initials, large, in a disc on the page's own two-tone field:
/// the place a photograph goes, honestly empty of one. Swapped for her photo
/// the day the roster carries one (set `cover`).
class PvConsultMonogramCover extends StatelessWidget {
  const PvConsultMonogramCover({super.key, required this.view});
  final PvOfferingView view;

  @override
  Widget build(BuildContext context) {
    final a = HSLColor.fromAHSL(1, view.hue, 0.34, 0.945).toColor();
    final b = HSLColor.fromAHSL(1, view.hue, 0.30, 0.875).toColor();
    final ink = HSLColor.fromAHSL(1, view.hue, 0.40, 0.28).toColor();
    return Container(
      key: const ValueKey('pv_consult_monogram'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a, b],
        ),
      ),
      alignment: const Alignment(0, 0.1),
      child: Container(
        width: 128,
        height: 128,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
        ),
        child: Text(
          pvLearnInitials(view.expert.name),
          style: pvFraunces(
            fontSize: 44,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
            color: ink,
          ),
        ),
      ),
    );
  }
}
