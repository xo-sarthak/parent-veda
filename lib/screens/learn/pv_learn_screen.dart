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
import '../../services/life_stage_store.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_store.dart';
import '../post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import '../profile/pv_you_screen.dart' show openPvYou;
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

class PvLearnScreen extends StatefulWidget {
  const PvLearnScreen({super.key, this.stage, this.kind, this.topic});

  /// Null = her current stage.
  final LifeStage? stage;

  /// Set = the list of one kind ("View all").
  final PvLearnKind? kind;
  final String? topic;

  @override
  State<PvLearnScreen> createState() => _PvLearnScreenState();
}

class _PvLearnScreenState extends State<PvLearnScreen> {
  late PvLearnKind? _kind = widget.kind;
  late String? _topic = widget.topic;

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
        final topics = _topics(all);
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
        final listMode = _kind != null || _topic != null;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PvLearnTopBar(
                  title: 'Learn',
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
              // ---- 1 · hers first ---------------------------------------------------------------
              if (!listMode) SliverToBoxAdapter(child: _yours(p, all)),
              // ---- 2 · kind filter --------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
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
                            onTap: () =>
                                setState(() => _kind = _kind == k ? null : k),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // ---- 3 · topics -------------------------------------------------------------------
              if (topics.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in topics)
                          PvChip(
                            label: t,
                            selected: _topic?.toLowerCase() == t.toLowerCase(),
                            onTap: () => setState(
                              () => _topic =
                                  _topic?.toLowerCase() == t.toLowerCase()
                                  ? null
                                  : t,
                            ),
                          ),
                      ],
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
      if (v != null &&
          v.lessons.isNotEmpty &&
          progress.doneCount(id) < v.lessons.length) {
        cont = v;
        break;
      }
    }
    final credits = store
        .entitlements()
        .where((e) => e.canBook && e.creditsTotal > 1)
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
          line:
              '${cont.lessons.length - progress.doneCount(cont.id)} of ${cont.lessons.length} lessons left',
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
              Icon(Icons.school_outlined, size: 20, color: p.ink1),
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

  List<Widget> _list(dynamic p, List<PvOfferingView> shown) => [
    SliverToBoxAdapter(
      child: PvLearnHead(
        _kind?.plural ?? _topic ?? 'Everything',
        lead: shown.isEmpty
            ? 'Nothing here yet for this stage. It is coming; the other kinds are below.'
            : '${shown.length} on this stage',
      ),
    ),
    SliverToBoxAdapter(
      child: Column(
        children: [
          for (final v in shown)
            PvLearnRow(
              view: v,
              tag: v.kind.label,
              live: v.isLive && v.kind != PvLearnKind.consult,
              title: v.title,
              sub:
                  '${v.expert.name} · ${v.facts.isNotEmpty ? v.facts.first.value : v.durationLabel} · ${v.priceLabel}',
              onTap: () => _open(v),
            ),
        ],
      ),
    ),
  ];

  // ---- small ----------------------------------------------------------------------------

  static List<String> _topics(List<PvOfferingView> all) {
    final count = <String, int>{};
    for (final v in all) {
      for (final t in v.topics) {
        final k = t.trim();
        if (k.isEmpty || k.length > 22) continue;
        count[k] = (count[k] ?? 0) + 1;
      }
    }
    final keys = count.keys.toList()
      ..sort((a, b) => count[b]!.compareTo(count[a]!));
    return keys.take(8).toList();
  }

  /// The eyebrow says where she is. On trying, that is her chapter — the
  /// stage's own rule ("PREPARE alone said nothing she did not already
  /// know", test/ttc_polish_test.dart); elsewhere the stage word.
  static String _stageWord(LifeStage s) => switch (s) {
    LifeStage.tryingToConceive => TtcStore.instance.today.chapter.title(false),
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
