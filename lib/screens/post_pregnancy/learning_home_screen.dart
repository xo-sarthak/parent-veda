// =============================================================================
//  LearningHomeScreen - "Courses & Masterclasses" (parenting · merged Learning)
// -----------------------------------------------------------------------------
//  The single, content-led home that replaces the three old landing pages
//  (Courses, Cohort Courses, Masterclasses). It is NOT expert-led: a parent
//  arrives on a search bar, clickable common-topic chips, and three kind filters
//  (Live cohorts / Recorded courses / Masterclasses), then a YouTube-style grid
//  of every program together - thumbnail + instructor + title - ordered by
//  feature/recency. Tapping a card opens the unified LearningDetailScreen.
//
//  Optional initial filters (instructorId / topic) let other surfaces - e.g. the
//  Watch channel - deep-link into a pre-filtered view.
// =============================================================================

import 'package:flutter/material.dart';

import 'learning_detail_screen.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'pp_learning_data.dart';
import 'pp_section_extras.dart';

class LearningHomeScreen extends StatefulWidget {
  const LearningHomeScreen({super.key, this.instructorId, this.topic});

  /// Open pre-filtered to one instructor (e.g. from a Watch channel).
  final String? instructorId;

  /// Open with one topic chip already selected.
  final String? topic;

  @override
  State<LearningHomeScreen> createState() => _LearningHomeScreenState();
}

class _LearningHomeScreenState extends State<LearningHomeScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _topic;
  String? _instructorId;
  LearningKind? _kind;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
    _instructorId = widget.instructorId;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(LearningProgram p) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LearningDetailScreen(program: p)));

  @override
  Widget build(BuildContext context) {
    final results = filterLearning(kind: _kind, topic: _topic, instructorId: _instructorId, query: _query);
    final instructorName = _instructorId == null ? null : expertById(_instructorId!).name;

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 96),
            children: [
              _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ppBack(context, 'Explore'),
                ppLangToggle(),
              ])),

              // header
              const SizedBox(height: 22),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Learn with the experts'),
                const SizedBox(height: 10),
                Text('Courses & Masterclasses', style: ppFraunces(31, h: 1.12)),
                const SizedBox(height: 12),
                Text(
                    'Live cohorts, self-paced courses and one-evening masterclasses - all in one place. Search a topic, or browse everything below.',
                    style: ppBody(15)),
              ])),

              // instructor deep-link banner
              if (instructorName != null) ...[
                const SizedBox(height: 16),
                _pad(GestureDetector(
                  onTap: () => setState(() => _instructorId = null),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.person_outline_rounded, size: 17, color: ppPurple),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Showing programs by $instructorName', style: ppBody(13, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      const Icon(Icons.close_rounded, size: 16, color: ppMuted),
                    ]),
                  ),
                )),
              ],

              // search
              const SizedBox(height: 18),
              _pad(ppSearchField(
                controller: _search,
                hint: 'Search sleep, solids, an expert…',
                onChanged: (v) => setState(() => _query = v),
              )),

              // kind filters
              const SizedBox(height: 16),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _kindPill(null, 'All'),
                    for (final k in LearningKind.values) _kindPill(k, k.filterLabel),
                  ],
                ),
              ),

              // topic chips
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _topicChip(null, 'All topics'),
                    for (final t in kLearningTopics) _topicChip(t, t),
                  ],
                ),
              ),

              // result count
              const SizedBox(height: 18),
              _pad(Text(
                  results.isEmpty
                      ? 'Nothing matches yet'
                      : '${results.length} ${results.length == 1 ? 'program' : 'programs'}',
                  style: ppEyebrowStyle())),
              const SizedBox(height: 14),

              // grid
              if (results.isEmpty)
                _pad(_emptyState())
              // NO KIND CHOSEN: group by kind rather than pouring live cohorts,
              // recorded courses and masterclasses into one undifferentiated
              // run. Three per section with a way through to the rest, so "All"
              // is browsable instead of a wall you scroll past.
              else if (_kind == null) ...[
                for (final k in LearningKind.values)
                  if (results.where((p) => p.kind == k).isNotEmpty) ...[
                    _pad(Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(
                          child: Text(k.filterLabel.toUpperCase(),
                              style: ppBody(10, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.8)),
                        ),
                        Text('${results.where((p) => p.kind == k).length}',
                            style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
                      ]),
                    )),
                    _pad(Column(children: [
                      for (final p in results.where((p) => p.kind == k).take(3)) _card(p),
                    ])),
                    if (results.where((p) => p.kind == k).length > 3)
                      _pad(GestureDetector(
                        onTap: () => setState(() => _kind = k),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(children: [
                            Text('View more ${k.filterLabel.toLowerCase()}',
                                style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
                          ]),
                        ),
                      ))
                    else
                      const SizedBox(height: 14),
                  ],
              ]
              else
                _pad(Column(children: [for (final p in results) _card(p)])),

              const SizedBox(height: 22),
              _pad(Text('Every program is led by a verified expert. Free or included with ParentVeda+.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),
        ),
      ]),
    );
  }

  // --- filters ----------------------------------------------------------
  Widget _kindPill(LearningKind? k, String label) {
    final on = _kind == k;
    return GestureDetector(
      onTap: () => setState(() => _kind = k),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? ppPurple : ppBorder),
        ),
        child: Text(label, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
      ),
    );
  }

  Widget _topicChip(String? t, String label) {
    final on = _topic == t;
    return GestureDetector(
      onTap: () => setState(() => _topic = t),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? ppInk : ppPanel,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: ppBody(12, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
      ),
    );
  }

  // --- a YouTube-style program card -------------------------------------
  Widget _card(LearningProgram p) {
    final a = p.accent;
    return GestureDetector(
      onTap: () => _open(p),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(children: [
              PpStriped(height: 168, radius: 18, border: true, colorA: a.withValues(alpha: 0.16), colorB: a.withValues(alpha: 0.05)),
              Positioned.fill(child: Center(child: _PlayDisc(48, a))),
              // kind chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                  child: Text(p.kind.label, style: ppBody(10.5, color: a, w: FontWeight.w800)),
                ),
              ),
              // live / duration corner
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: p.isLive ? ppCoral : ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(7)),
                  child: Text(p.isLive ? 'LIVE' : p.durationLabel, style: ppBody(10, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // instructor avatar + text
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
              clipBehavior: Clip.antiAlias,
              child: const PpStriped(height: 42, colorA: ppBorder, colorB: ppStripeB),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, style: ppJakarta(16), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${p.instructor.name} · ${_metaLine(p)}',
                    style: ppBody(12.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(p.price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }

  String _metaLine(LearningProgram p) {
    if (p.isCohort && p.startLabel != null) return p.startLabel!;
    if (p.isLiveScheduled && p.startLabel != null) return p.startLabel!;
    return p.durationLabel.isNotEmpty ? p.durationLabel : p.topics.first;
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 30, color: ppMuted),
          const SizedBox(height: 12),
          Text('No programs match', style: ppJakarta(16)),
          const SizedBox(height: 6),
          Text('Try another topic or clear your filters.', textAlign: TextAlign.center, style: ppBody(13)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() {
              _query = '';
              _search.clear();
              _topic = null;
              _kind = null;
              _instructorId = null;
            }),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
              child: Text('Clear filters', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        ]),
      );
}

// A tiny helper for the uppercased result-count eyebrow.
TextStyle ppEyebrowStyle() => ppBody(11, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 1.2);

class _PlayDisc extends StatelessWidget {
  const _PlayDisc(this.size, this.accent);
  final double size;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: accent, size: size * 0.5),
      );
}
