// =============================================================================
//  PvLearnScreen — Learn: the one home for courses, masterclasses, cohorts
//  and consults, on every stage
// -----------------------------------------------------------------------------
//  Replaces five landings (`CoursesExploreScreen`, `CoursesCohortsScreen`,
//  the three older per-kind ones, the learning half of `TtcPrepareScreen`),
//  which each opened on a banner or a search bar and treated a paying
//  customer like a browser. The audit (docs/LEARNING-AUDIT.md §3.8, §4.1):
//
//    1 hers first     Continue · Next session · Credits — only when true;
//                     empty, the strip is the invitation
//    2 kind filter    All · Courses · Masterclasses · Cohorts · Consults
//    3 topic chips    the existing topics, untouched
//    4 rails          Live this week · Chosen for you · one per kind
//    5 experts        a rail of faces, last
//
//  The stage decides which catalogue feeds it and nothing else — the same
//  skeleton on trying, pregnancy and parenting. `kind` set = the "View all"
//  list of one kind, same page, rows instead of rails.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../experts/expert.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../services/life_stage_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
// Unused since the eyebrow names the stage (2026-09-27); kept for revert:
// import '../../ttc/ttc_chapter.dart';
// Unused since the eyebrow names the stage (2026-09-27); kept for revert:
// import '../../ttc/ttc_store.dart';
import '../post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import '../profile/pv_you_screen.dart' show openPvYou;
import 'pv_learn_art.dart';
import 'pv_learn_catalog.dart';
import 'pv_learn_chrome.dart';
import 'pv_lesson_screen.dart';
import 'pv_my_learning_screen.dart';
import 'pv_offering_screen.dart';
import 'pv_session_screen.dart';

void openPvLearn(
  BuildContext context, {
  LifeStage? stage,
  PvLearnKind? kind,
  String? topic,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: kind == null ? kPvLearnRoute : '$kPvLearnRoute/${kind.name}',
      ),
      builder: (_) => PvLearnScreen(stage: stage, kind: kind, topic: topic),
    ),
  );
}

/// The word a person would filter a clinician by — "Obstetrician",
/// "Paediatrician" — taken from the credential's first part. Public so a
/// door can ask for the role of the specialist it names rather than
/// hard-coding the word and watching it drift out of the roster.
String pvLearnRoleOf(PvOfferingView v) {
  final r = v.expert.role.split('·').first.trim();
  if (r.isEmpty) return 'Other';
  return r[0].toUpperCase() + r.substring(1);
}

class PvLearnScreen extends StatefulWidget {
  const PvLearnScreen({
    super.key,
    this.stage,
    this.kind,
    this.topic,
    this.role,
    this.title,
    this.lead,
  });

  /// Null = her current stage.
  final LifeStage? stage;

  /// Set = the list of one kind ("View all").
  final PvLearnKind? kind;
  final String? topic;

  /// A consult list opened from a door names the kind of clinician it
  /// promised — "a gynaecologist" — so that role starts selected and the
  /// others stay one tap away. A door that says a word must keep it.
  final String? role;

  /// What the door called this, and why she is here. Without them the
  /// screen says "Learn" to someone who tapped "have a doctor go through
  /// it with you", which is not what she asked for.
  final String? title;
  final String? lead;

  @override
  State<PvLearnScreen> createState() => _PvLearnScreenState();
}

class _PvLearnScreenState extends State<PvLearnScreen> {
  late PvLearnKind? _kind = widget.kind;
  late String? _topic = widget.topic;
  late String? _role = widget.role;

  LifeStage get _stage =>
      widget.stage ?? LifeStageStore.instance.stage ?? LifeStage.pregnancy;

  @override
  void initState() {
    super.initState();
    BookingStore.instance.init();
    PvLearnProgressStore.instance.init();
  }

  void _open(PvOfferingView v) => pvOpenOffering(context, v);

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookingStore.instance,
        PvLearnProgressStore.instance,
        LifeStageStore.instance,
      ]),
      builder: (context, _) {
        final all = PvLearnCatalog.instance.all(stage: _stage);
        final kindsHere = [
          for (final k in PvLearnKind.values)
            if (all.any((v) => v.kind == k)) k,
        ];
        var shown = all;
        if (_kind != null) shown = shown.where((v) => v.kind == _kind).toList();
        if (_topic != null) {
          shown = shown
              .where(
                (v) => v.topics.any(
                  (t) => t.toLowerCase() == _topic!.toLowerCase(),
                ),
              )
              .toList();
        }
        if (_role != null) {
          shown = shown
              .where(
                (v) => pvLearnRoleOf(v).toLowerCase() == _role!.toLowerCase(),
              )
              .toList();
        }
        final listMode = _kind != null || _topic != null;
        // ⚠️ ONE FILTER ROW, NOT FOUR — 2026-09-22, the user's walk: "all the
        // filters listed so carelessly with no format whatsoever". The screen
        // drew the kind chips AND a `Wrap` of every topic, which on pregnancy
        // ran to four lines, held "breathing" and "Breathing" as two chips,
        // and pushed the first doctor below the fold. Mobbin, same day: Alan's
        // Medical team, Zocdoc, CVS Find care and Future Pro all show ONE row
        // — or one Filters button — then a count, then rows worth choosing
        // from. So: one scrollable row of the dimension that matters here.
        // On the home that is the kind; inside a kind it is what divides that
        // kind — the clinician's role for consults, the topic otherwise.
        final subFilters = listMode
            ? _subFilters(shown, all)
            : const <String>[];
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PvLearnTopBar(
                  title: widget.title ?? 'Learn',
                  eyebrow: _stageWord(_stage),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PvRoundIcon(
                        icon: Icons.bookmark_border_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            settings: const RouteSettings(name: 'learn/mine'),
                            builder: (_) => const PvMyLearningScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // The profile door every TTC tab carries (its shell has
                      // no other way to a language control or a sign-out).
                      PvRoundIcon(
                        icon: Icons.person_outline_rounded,
                        onTap: () => openPvYou(context, stage: _stage),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- what she came for -----------------------------------------------------------
              if (widget.lead != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                    child: Text(
                      widget.lead!,
                      style: pvManrope(
                        fontSize: 14.5,
                        height: 1.5,
                        color: p.ink2,
                      ),
                    ),
                  ),
                ),
              // ---- 1 · hers first ---------------------------------------------------------------
              if (!listMode) SliverToBoxAdapter(child: _yours(p, all)),
              // ---- 2 · the one filter row -------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: listMode
                          ? [
                              PvChip(
                                label:
                                    'All ${(_kind?.plural ?? 'of these').toLowerCase()}',
                                selected: _role == null && _topic == null,
                                onTap: () => setState(() {
                                  _role = null;
                                  _topic = null;
                                }),
                              ),
                              for (final f in subFilters) ...[
                                const SizedBox(width: 8),
                                PvChip(
                                  label: f,
                                  selected: _isSub(f),
                                  onTap: () => setState(() => _toggleSub(f)),
                                ),
                              ],
                            ]
                          : [
                              PvChip(
                                label: 'All',
                                selected: _kind == null,
                                onTap: () => setState(() => _kind = null),
                              ),
                              for (final k in kindsHere) ...[
                                const SizedBox(width: 8),
                                PvChip(
                                  label: k.plural,
                                  selected: _kind == k,
                                  onTap: () => setState(
                                    () => _kind = _kind == k ? null : k,
                                  ),
                                ),
                              ],
                            ],
                    ),
                  ),
                ),
              ),
              // ---- the body: rails, or one list ----------------------------------------------------
              if (listMode) ..._list(p, shown) else ..._rails(p, all),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  // ---- 1 --------------------------------------------------------------------------------

  Widget _yours(dynamic p, List<PvOfferingView> all) {
    final store = BookingStore.instance;
    final progress = PvLearnProgressStore.instance;
    final next = store.nextUp;
    final nextView = next == null
        ? null
        : PvLearnCatalog.instance.byOfferingId(next.offeringId);
    PvOfferingView? cont;
    for (final id in progress.recentCourses) {
      final v = PvLearnCatalog.instance.byId(id);
      // ⚠️ THIS STAGE'S COURSES ONLY (TTC launch walk, 2026-09-27): the
      // trying Learn page offered "Continue · The Complete Pregnancy Guide".
      // The same leak the booking strip below closed on 2026-09-22.
      // Kept for revert: the check without `v.stage == _stage`.
      if (v != null &&
          v.stage == _stage &&
          v.lessons.isNotEmpty &&
          progress.doneCount(id) < v.lessons.length) {
        cont = v;
        break;
      }
    }
    // ⚠️ TWO LEAKS IN ONE CARD, found on the walk (2026-09-22): the
    // pregnancy home offered "Preconception garbh sanskar · 8 classes left
    // · Book".
    //
    //  · WRONG STAGE. `entitlements()` with no stage returns the whole
    //    history — that is right for My learning, which is deliberately one
    //    list across the journey, and wrong here, where the strip is about
    //    what she can do on the stage she is standing in.
    //  · WRONG KIND. The free course's engine row grants one credit per
    //    session, so buying it at ₹0 minted eight "classes" to book — but a
    //    recorded course has no slot to spend them on. A credit is only a
    //    credit when there is a time to spend it at.
    final credits = store
        .entitlements(stage: _serviceStage(_stage))
        .where((e) => e.canBook && e.creditsTotal > 1)
        .where((e) {
          final v = PvLearnCatalog.instance.byOfferingId(e.offeringId);
          return v != null && v.isLive && !v.isFree;
        })
        .toList();
    final cards = <Widget>[
      if (next != null)
        _yoursCard(
          p,
          eyebrow: 'Next session',
          title: next.title,
          line:
              '${pvLearnDay(next.startsUtc)} · ${pvLearnTime(next.startsUtc)} · ${pvLearnCountdown(next.startsUtc, next.endsUtc)}',
          verb: next.joinableAt(DateTime.now()) ? 'Join now' : 'Open',
          view: nextView,
          onTap: () => pvOpenSession(context, next),
        ),
      if (cont != null)
        _yoursCard(
          p,
          eyebrow: 'Continue',
          title: cont.title,
          line: pvLearnLeftLine(
            progress.doneCount(cont.id),
            cont.lessons.length,
          ),
          verb: 'Continue',
          view: cont,
          onTap: () {
            final last = progress.lastLesson(cont!.id);
            final i = last == null
                ? 0
                : cont.lessons.indexWhere((l) => l.id == last);
            pvOpenLesson(context, cont, i < 0 ? 0 : i);
          },
        ),
      for (final e in credits.take(2))
        _yoursCard(
          p,
          eyebrow: 'Credits',
          title: e.title,
          line: e.creditsLeft == 1
              ? '1 class left'
              : '${e.creditsLeft} classes left',
          verb: 'Book',
          view: PvLearnCatalog.instance.byOfferingId(e.offeringId),
          onTap: () {
            final v = PvLearnCatalog.instance.byOfferingId(e.offeringId);
            if (v != null) _open(v);
          },
        ),
    ];
    if (cards.isEmpty) {
      // The invitation: the soonest live thing on this stage, by name.
      final soon = _liveSoon(all).take(1).toList();
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPvLine),
          ),
          child: Row(
            children: [
              PvLearnRing(mark: PvLearnMark.learn, p: p),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  soon.isEmpty
                      ? 'Nothing booked yet. Everything here is taught by someone whose name you can read.'
                      : 'Nothing booked yet. The next live session is ${soon.first.$2} — ${soon.first.$1.title}.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 132,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            SizedBox(
              width: cards.length == 1
                  ? MediaQuery.of(context).size.width - 40
                  : 280,
              child: cards[i],
            ),
          ],
        ],
      ),
    );
  }

  Widget _yoursCard(
    dynamic p, {
    required String eyebrow,
    required String title,
    required String line,
    required String verb,
    PvOfferingView? view,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPvLine),
      ),
      child: Row(
        children: [
          if (view != null)
            SizedBox(
              width: 64,
              height: 64,
              child: PvLearnCover(view: view, radius: 12),
            ),
          if (view != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.action,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12, color: p.ink3),
                ),
                const SizedBox(height: 6),
                Text(
                  verb,
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  // ---- 4 --------------------------------------------------------------------------------

  /// Live things with a slot in the next seven days, soonest first, with
  /// the slot's day as a word.
  List<(PvOfferingView, String, Slot)> _liveSoon(List<PvOfferingView> all) {
    final now = DateTime.now().toUtc();
    final week = now.add(const Duration(days: 7));
    final out = <(PvOfferingView, String, Slot)>[];
    for (final v in all) {
      final o = v.offering;
      if (o == null || !v.isLive || v.kind == PvLearnKind.consult) continue;
      final slots = BookingCatalog.instance.slotsFor(o.id, now: now);
      if (slots.isEmpty || slots.first.startsUtc.isAfter(week)) continue;
      out.add((v, pvLearnDay(slots.first.startsUtc), slots.first));
    }
    out.sort((a, b) => a.$3.startsUtc.compareTo(b.$3.startsUtc));
    return out;
  }

  List<Widget> _rails(dynamic p, List<PvOfferingView> all) {
    final live = _liveSoon(all);
    final chosen = all.where((v) => v.featured).toList()
      ..sort((a, b) => b.recency.compareTo(a.recency));
    final experts = <Expert>[];
    for (final v in all) {
      final e = v.expert.expert;
      if (e != null && !experts.any((x) => x.id == e.id)) experts.add(e);
    }
    return [
      // Live this week — Peloton's schedule rows.
      SliverToBoxAdapter(
        child: PvLearnHead(
          'Live this week',
          lead: live.isEmpty
              ? 'Nothing live in the next seven days. The recorded things below never wait.'
              : null,
        ),
      ),
      if (live.isNotEmpty)
        SliverToBoxAdapter(
          child: Column(
            children: [
              for (final (v, day, s) in live.take(5))
                PvLearnRow(
                  leadTop: day.toUpperCase(),
                  leadBottom: pvLearnTime(s.startsUtc),
                  tag: v.kind.label,
                  live: true,
                  title: v.title,
                  sub: '${v.expert.name} · ${s.seatsLeft} seats left',
                  onTap: () => _open(v),
                ),
            ],
          ),
        ),
      // Chosen for you.
      if (chosen.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: PvLearnHead(
            'Chosen for you',
            lead: 'Picked for where you are, not for what sells.',
          ),
        ),
        SliverToBoxAdapter(
          child: PvLearnRail(views: chosen.take(6).toList(), onOpen: _open),
        ),
      ],
      // One rail per kind.
      for (final k in PvLearnKind.values)
        if (all.any((v) => v.kind == k)) ...[
          SliverToBoxAdapter(
            child: PvLearnHead(
              k.plural,
              lead: _kindLead(k),
              action: 'View all',
              onAction: () => setState(() => _kind = k),
            ),
          ),
          SliverToBoxAdapter(
            child: PvLearnRail(
              views: all.where((v) => v.kind == k).take(8).toList(),
              onOpen: _open,
            ),
          ),
        ],
      // Experts, last.
      if (experts.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: PvLearnHead(
            'The people',
            lead:
                'Every name here opens a page with their qualifications and what they offer.',
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (var i = 0; i < experts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _expertChip(p, experts[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    ];
  }

  Widget _expertChip(dynamic p, Expert e) {
    final initials = e.name
        .replaceAll('Dr. ', '')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return InkWell(
      onTap: () => openExpertProfile(context, e),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surfaceAlt,
                border: Border.all(color: kPvLine),
              ),
              child: Text(
                initials.toUpperCase(),
                style: pvManrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: p.ink1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              e.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.ink1,
              ),
            ),
            Text(
              e.credential,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 11, height: 1.3, color: p.ink3),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _list(dynamic p, List<PvOfferingView> shown) {
    final consults = _kind == PvLearnKind.consult;
    final others = !consults || _role == null
        ? const <PvOfferingView>[]
        : PvLearnCatalog.instance
              .all(stage: _stage, kind: PvLearnKind.consult)
              .where((v) => !shown.contains(v))
              .toList();
    return [
      SliverToBoxAdapter(
        child: PvLearnHead(
          widget.title != null && consults
              ? 'Who can help'
              : (_kind?.plural ?? _topic ?? 'Everything'),
          // Zocdoc's "265 In-network providers": say what she is looking at
          // before she looks at it.
          lead: shown.isEmpty
              ? 'Nothing here yet for this stage. Tap ${(_kind?.plural ?? 'All').toLowerCase()} above to widen it.'
              : consults
              // H16 (TTC launch sanity, 2026-09-28): people are counted as
              // people and the length comes from the consults' own records.
              // Kept for revert:
              // '${shown.length} ${shown.length == 1 ? 'person' : 'people'} · 30-minute video, in the app'
              ? pvConsultListLead(shown)
              : '${shown.length} on this stage',
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            for (final v in shown)
              if (consults)
                // A person: her initials, her name, what she is, her fee.
                // Never "Consult with X" over "X · 30 min" — the walk found
                // the name said twice on every row.
                // H16 (2026-09-28): a consult the roster has no named
                // person for is titled by what it is ("Male fertility
                // consultation · An andrologist"), not as a nameless person
                // with initials. Kept for revert: the person row always.
                pvLearnHasNoNamedPerson(v)
                    ? PvLearnRow(
                        view: v,
                        title: v.title,
                        sub: v.expert.name,
                        foot: _footLine(v),
                        price: v.priceLabel,
                        onTap: () => _open(v),
                      )
                    : PvLearnRow(
                        initials: pvLearnInitials(v.expert.name),
                        title: v.expert.name,
                        sub: _roleLine(v),
                        foot: _footLine(v),
                        price: v.priceLabel,
                        onTap: () => _open(v),
                      )
              else
                PvLearnRow(
                  view: v,
                  // The kind tag is noise on a list that is all one kind.
                  tag: _kind == null ? v.kind.label : null,
                  live: v.isLive && v.kind != PvLearnKind.consult,
                  title: v.title,
                  sub:
                      '${v.expert.name} · ${v.facts.isNotEmpty ? v.facts.first.value : v.durationLabel}',
                  price: v.priceLabel,
                  onTap: () => _open(v),
                ),
          ],
        ),
      ),
      // ⚠️ NEVER ONE ROW OVER AN EMPTY PAGE. A door that names a role can
      // leave two names on a screen built for twenty (the walk: one
      // obstetrician above 1,400 px of white). The rest of the stage's
      // clinicians follow under their own head — Zocdoc's "similar
      // providers" — so the filter narrows without emptying, and she can
      // see who else there is without undoing her own choice.
      if (consults && _role != null && others.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: PvLearnHead(
            'Others who can help',
            lead:
                'Not ${_article(_role!)} ${_role!.toLowerCase()}, but on your stage.',
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              for (final v in others)
                pvLearnHasNoNamedPerson(v)
                    ? PvLearnRow(
                        view: v,
                        title: v.title,
                        sub: v.expert.name,
                        foot: _footLine(v),
                        price: v.priceLabel,
                        onTap: () => _open(v),
                      )
                    : PvLearnRow(
                        initials: pvLearnInitials(v.expert.name),
                        title: v.expert.name,
                        sub: _roleLine(v),
                        foot: _footLine(v),
                        price: v.priceLabel,
                        onTap: () => _open(v),
                      ),
            ],
          ),
        ),
      ],
      // ⚠️ THE LINE A CONSULT LIST OWES HER. Alan pins "Is it an emergency?
      // Call 15" under its consultation list; ours says the same in our own
      // words, and never sells against it.
      if (consults)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PvLearnRing(mark: PvLearnMark.note, p: p, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a conversation, not an emergency service. If '
                    'something feels wrong now, call your own doctor or go in.',
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.5,
                      color: p.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  static String _article(String w) =>
      'aeiou'.contains(w.trim().isEmpty ? 'x' : w.trim()[0].toLowerCase())
      ? 'an'
      : 'a';

  /// ⚠️ THE FACT THAT DECIDES IT — Zocdoc's "Next available: Mon, Jun 8",
  /// the one element on their row a person actually reads. Ours is the
  /// engine's own next free slot, so it is true rather than decorative; in
  /// ink rather than Zocdoc's yellow bar (colour as container was declined
  /// on the scans pass). No slot published yet, no line — never a guess.
  static String? _nextLine(PvOfferingView v) {
    final o = v.offering;
    if (o == null) return null;
    final slots = BookingCatalog.instance.slotsFor(o.id);
    if (slots.isEmpty) return null;
    return 'Next ${pvLearnDay(slots.first.startsUtc).toLowerCase()}, ${pvLearnTime(slots.first.startsUtc)}';
  }

  /// ⚠️ WHAT FITS, NOT WHAT FILLS — the user, 2026-09-22: shrink the type
  /// only when the words cannot be shortened first. The row carried role ·
  /// years · languages and ran off the edge as "…· All tri…", which tells
  /// her less than the two facts that fit. So: the role, then the years
  /// behind it. Rating and the next free time have their own line below.
  static String _roleLine(PvOfferingView v) {
    final role = v.expert.role.trim();
    if (role.isEmpty) return v.subtitle;
    // The credential after the role is on the person's own page; on a row
    // of eight people the role and the experience are what separate them.
    final head = role.split('·').first.trim();
    final years = v.facts
        .where((f) => f.label == 'experience' || f.label == 'qualified')
        .map((f) => f.value)
        .where((x) => x.length <= 18);
    return [head, ...years.take(1)].join(' · ');
  }

  /// Rating and the next free time, in one quiet line. Either may be
  /// missing; both missing means no line at all.
  static String? _footLine(PvOfferingView v) {
    final bits = <String>[
      if (v.rating != null) '★ ${v.rating!.toStringAsFixed(1)}',
      ?_nextLine(v),
    ];
    return bits.isEmpty ? null : bits.join('  ·  ');
  }

  bool _isSub(String f) => _kind == PvLearnKind.consult
      ? _role?.toLowerCase() == f.toLowerCase()
      : _topic?.toLowerCase() == f.toLowerCase();

  void _toggleSub(String f) {
    if (_kind == PvLearnKind.consult) {
      _role = _isSub(f) ? null : f;
    } else {
      _topic = _isSub(f) ? null : f;
    }
  }

  /// What divides the kind she is looking at: a clinician's role for
  /// consults, the topic otherwise. Deduped case-insensitively — the walk
  /// found "breathing" and "Breathing" as two chips — Title Case, and
  /// ordered by how many things carry it.
  List<String> _subFilters(
    List<PvOfferingView> shown,
    List<PvOfferingView> all,
  ) {
    final pool = _kind == null
        ? all
        : all.where((v) => v.kind == _kind).toList();
    final count = <String, String>{};
    final n = <String, int>{};
    void add(String raw) {
      final t = raw.trim();
      if (t.isEmpty || t.length > 22) return;
      final key = t.toLowerCase();
      count[key] ??= t[0].toUpperCase() + t.substring(1);
      n[key] = (n[key] ?? 0) + 1;
    }

    for (final v in pool) {
      if (_kind == PvLearnKind.consult) {
        add(pvLearnRoleOf(v));
      } else {
        for (final t in v.topics) {
          add(t);
        }
      }
    }
    // One chip for one thing is not a filter, it is a label.
    final keys = n.keys.where((k) => n[k]! > 0).toList()
      ..sort((a, b) => n[b]!.compareTo(n[a]!));
    if (keys.length < 2) return const [];
    var out = [for (final k in keys.take(8)) count[k]!];
    // ⚠️ THE SELECTED ONE COMES FIRST. A door that arrives with a role
    // already chosen put it third on the walk (2026-09-22), off the edge of
    // a 390-px phone: the list was filtered and the filter was invisible.
    final sel = _kind == PvLearnKind.consult ? _role : _topic;
    if (sel != null) {
      final i = out.indexWhere((x) => x.toLowerCase() == sel.toLowerCase());
      if (i > 0) out = [out[i], ...out..removeAt(i)];
    }
    return out;
  }

  // ---- small ----------------------------------------------------------------------------

  /// The eyebrow says where she is. On trying, that is her chapter — the
  /// stage's own rule ("PREPARE alone said nothing she did not already
  /// know", test/ttc_polish_test.dart); elsewhere the stage word.
  static ServiceStage _serviceStage(LifeStage s) => switch (s.shopStage) {
    LifeStage.tryingToConceive => ServiceStage.tryingToConceive,
    LifeStage.parenting => ServiceStage.parenting,
    _ => ServiceStage.pregnancy,
  };

  static String _stageWord(LifeStage s) => switch (s) {
    // ⚠️ THE STAGE, NOT THE CHAPTER (the user, 2026-09-27: "why is the
    // eyebrow Trying Together… that word is not making any sense, especially
    // for this section"). A chapter name over a list of experts explained
    // nothing and read as a heading of its own. Kept for revert:
    //   LifeStage.tryingToConceive => TtcStore.instance.today.chapter.title(false),
    LifeStage.tryingToConceive => 'Trying to conceive',
    LifeStage.pregnancy => 'Pregnancy',
    LifeStage.parenting => 'Parenting',
    LifeStage.skilling => 'Parenting',
  };

  static String? _kindLead(PvLearnKind k) => switch (k) {
    PvLearnKind.course =>
      'Recorded, yours to keep. Watch at 2 am if that is when there is time.',
    PvLearnKind.masterclass => 'One evening, live, with questions.',
    PvLearnKind.cohort => 'A few weeks with the same small group.',
    PvLearnKind.consult =>
      'Half an hour with someone whose registration we checked.',
    PvLearnKind.classPack => 'Four live classes, booked one at a time.',
  };
}

/// The line under "Who can help" on a consult list (TTC launch sanity H16,
/// 2026-09-28). It said "6 people · 30-minute video" over six consults with
/// five people (one doctor runs two) whose own pages say 45 minutes. Now it
/// counts people as people, says how many consults when that differs, and
/// takes the length from the consults' own records, saying one only when
/// they all agree. A list whose records carry no length keeps the old words.
String pvConsultListLead(List<PvOfferingView> shown) {
  final people = shown.map((v) => v.expert.name).toSet().length;
  String n(int k, String one, String many) => '$k ${k == 1 ? one : many}';
  final who = people == shown.length
      ? n(people, 'person', 'people')
      : '${n(shown.length, 'consult', 'consults')} with '
          '${n(people, 'person', 'people')}';
  final mins = shown.map(pvConsultMinutes).toSet();
  final String length;
  if (mins.length == 1 && mins.first != null) {
    length = '${mins.first}-minute video';
  } else if (mins.every((m) => m == null)) {
    length = '30-minute video';
  } else {
    length = 'video';
  }
  return '$who · $length, in the app';
}

/// A consult's length in minutes, from its record: its duration label, or a
/// fact such as "45 min · video session". Null when the record says none.
int? pvConsultMinutes(PvOfferingView v) {
  for (final s in [v.durationLabel, for (final f in v.facts) f.value]) {
    final m = RegExp(r'^(\d+)\s*min').firstMatch(s.trim());
    if (m != null) return int.parse(m.group(1)!);
  }
  return null;
}
