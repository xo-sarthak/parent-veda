// =============================================================================
//  CoursesCohortsScreen - Prepare › Courses & Cohorts (unified "V2")
// -----------------------------------------------------------------------------
//  The single, content-led home that replaces the old separate Masterclasses and
//  Cohort Programs landing pages. Mirrors the post-pregnancy V2 "Courses &
//  Masterclasses" experience (learning_home_screen.dart), adapted to pregnancy
//  data + the mother/purple "Warm Nest" theme: a search bar, three kind filters
//  (Courses / Cohorts / Masterclasses), clickable topic chips, then a
//  YouTube-style grid of every program together. Tapping a card opens the
//  unified ProgramDetailScreen.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';
import 'program_detail_screen.dart';

class CoursesCohortsScreen extends StatefulWidget {
  const CoursesCohortsScreen({super.key, this.topic});

  /// Open with one topic chip already selected (optional deep-link).
  final String? topic;

  @override
  State<CoursesCohortsScreen> createState() => _CoursesCohortsScreenState();
}

class _CoursesCohortsScreenState extends State<CoursesCohortsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _topic;
  PrepKind? _kind;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(PrepProgram p) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProgramDetailScreen(program: p)));

  @override
  Widget build(BuildContext context) {
    final results = filterPrograms(kind: _kind, topic: _topic, query: _query);

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 96),
          children: [
            _pad(pvTopBar(context, backLabel: 'Prepare')),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pvEyebrow('Learn with the experts'),
              const SizedBox(height: 10),
              Text('Courses & Cohorts', style: pvHeroStyle()),
              const SizedBox(height: 12),
              Text(
                  'Self-paced courses, small live cohorts and one-evening masterclasses - all in one place. Search a topic, or browse everything below.',
                  style: pvSubStyle()),
            ])),

            // search
            const SizedBox(height: 18),
            _pad(pvSearchField(
              controller: _search,
              hint: 'Search birth, breathing, an expert…',
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
                  for (final k in PrepKind.values) _kindPill(k, k.filterLabel),
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
                  for (final t in kPrepTopics) _topicChip(t, t),
                ],
              ),
            ),

            // result count
            const SizedBox(height: 18),
            _pad(Text(
                results.isEmpty
                    ? 'NOTHING MATCHES YET'
                    : '${results.length} ${results.length == 1 ? 'PROGRAM' : 'PROGRAMS'}',
                style: pvBody(kMuted, 11).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2))),
            const SizedBox(height: 14),

            if (results.isEmpty)
              _pad(_emptyState())
            else
              _pad(Column(children: [for (final p in results) _card(p)])),

            const SizedBox(height: 22),
            _pad(Text('Every program is led by a verified expert. Free or included with ParentVeda+.',
                textAlign: TextAlign.center, style: pvBody(kMuted, 12).copyWith(height: 1.55))),
          ],
        ),
      ),
    );
  }

  // --- filters ----------------------------------------------------------
  Widget _kindPill(PrepKind? k, String label) {
    final on = _kind == k;
    return GestureDetector(
      onTap: () => setState(() => _kind = k),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? kPurple : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? kPurple : kBorder),
        ),
        child: Text(label,
            style: pvBody(on ? Colors.white : kInk, 12.5).copyWith(fontWeight: FontWeight.w700)),
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
          color: on ? kInk : kPanel,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: pvBody(on ? Colors.white : kSoft, 12).copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // --- a YouTube-style program card -------------------------------------
  Widget _card(PrepProgram p) {
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
              PvStriped(
                height: 168,
                radius: 18,
                colorA: a.withValues(alpha: 0.16),
                colorB: a.withValues(alpha: 0.05),
              ),
              Positioned.fill(child: Center(child: _PlayDisc(48, a))),
              // kind chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999)),
                  child: Text(p.kind.label, style: pvBody(a, 10.5).copyWith(fontWeight: FontWeight.w800)),
                ),
              ),
              // live / duration corner
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: p.isLive ? kCoral : kInk.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text(p.isLive ? 'LIVE' : p.durationLabel,
                      style: pvBody(Colors.white, 10).copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pvAvatar(38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, style: pvTitleStyle(16), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${p.instructorName} · ${_metaLine(p)}',
                    style: pvBody(kSoft, 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(p.price, style: pvBody(kInk, 13).copyWith(fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }

  String _metaLine(PrepProgram p) {
    if (p.isLive && p.startLabel != null) return p.startLabel!;
    return p.durationLabel.isNotEmpty ? p.durationLabel : p.topics.first;
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 30, color: kMuted),
          const SizedBox(height: 12),
          Text('No programs match', style: pvTitleStyle(16)),
          const SizedBox(height: 6),
          Text('Try another topic or clear your filters.', textAlign: TextAlign.center, style: pvBody(kSoft, 13)),
          const SizedBox(height: 16),
          pvPrimaryButton('Clear filters', () => setState(() {
                _query = '';
                _search.clear();
                _topic = null;
                _kind = null;
              })),
        ]),
      );
}

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
