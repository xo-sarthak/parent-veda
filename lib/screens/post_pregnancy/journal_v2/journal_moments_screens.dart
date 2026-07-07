// =============================================================================
//  My Journal V2 - moments (memory detail, timeline, search, letters)
// =============================================================================

import 'package:flutter/material.dart';

import 'jv2_common.dart';
import 'jv2_data.dart';

void _snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

void openMemory(BuildContext context, JvMemory m) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MemoryDetailScreen(memory: m)));

// ---- Memory Detail ----------------------------------------------------------
class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({super.key, this.memory = jvFeatured});
  final JvMemory memory;

  @override
  Widget build(BuildContext context) {
    final isLetter = memory.kind == JvKind.letter;
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Stack(children: [
            JvPhoto(seed: memory.seed, height: 320, dim: true),
            Positioned(
              top: 52,
              left: 20,
              child: _circleBtn(Icons.arrow_back, () => Navigator.of(context).maybePop()),
            ),
            Positioned(
              top: 52,
              right: 20,
              child: _circleBtn(Icons.favorite_border, () => _snack(context, 'Saved to favourites')),
            ),
          ]),
          Transform.translate(
            offset: const Offset(0, -26),
            child: Container(
              decoration: const BoxDecoration(color: ppBg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(memory.title, style: ppFraunces(30, h: 1.15)),
                const SizedBox(height: 8),
                Row(children: [
                  Text(memory.date, style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(width: 3, height: 3, decoration: const BoxDecoration(color: ppMuted, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(memory.age, style: ppBody(13, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 16),
                Text(memory.body, style: ppBody(15, h: 1.7).copyWith(fontStyle: isLetter ? FontStyle.italic : FontStyle.normal)),
                if (!isLetter && memory.mediaCount > 1) ...[
                  const SizedBox(height: 24),
                  Text('Media', style: ppJakarta(14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: JvPhoto(seed: memory.seed + i, height: 68, radius: 12)),
                    ],
                  ]),
                ],
                const SizedBox(height: 24),
                Row(children: [
                  _action(Icons.edit_outlined, 'Edit', () => _snack(context, 'Editing coming soon')),
                  const SizedBox(width: 22),
                  _action(Icons.ios_share_rounded, 'Share', () => _snack(context, 'Share coming soon')),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: ppInk),
        ),
      );

  Widget _action(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: ppPurple),
          const SizedBox(width: 7),
          Text(label, style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
        ]),
      );
}

// ---- Timeline ---------------------------------------------------------------
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});
  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  int _tab = 0;
  static const _tabs = ['All', 'This Year', 'This Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(jvTopBar(context, title: 'Timeline')),
          const SizedBox(height: 18),
          SizedBox(
            height: 36,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
              for (var i = 0; i < _tabs.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(right: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: i == _tab ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text(_tabs[i], style: ppBody(12, color: i == _tab ? Colors.white : ppSoft, w: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 20),
          jvPad(Text('2025', style: ppJakarta(15, color: ppMuted))),
          const SizedBox(height: 4),
          for (final m in jvMemories) jvPad(_row(context, m)),
          const SizedBox(height: 14),
          jvPad(Text('2023', style: ppJakarta(15, color: ppMuted))),
          const SizedBox(height: 4),
          for (var i = 0; i < jvMilestones.length - 1; i++) jvPad(_milestoneRow(jvMilestones[i], seed: i)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, JvMemory m) => GestureDetector(
        onTap: () => openMemory(context, m),
        behavior: HitTestBehavior.opaque,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(width: 11, height: 11, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: ppCoral, shape: BoxShape.circle, border: Border.all(color: ppCoralTint, width: 3))),
              Expanded(child: Container(width: 2, color: ppHair)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${m.date} · ${m.age}', style: ppBody(11, color: ppMuted)),
                  const SizedBox(height: 3),
                  Text(m.title, style: ppJakarta(15)),
                  const SizedBox(height: 2),
                  Text(m.body, style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            JvPhoto(seed: m.seed, height: 52, width: 52, radius: 12),
          ]),
        ),
      );

  Widget _milestoneRow(JvMilestone m, {required int seed}) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 11, height: 11, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: ppPurple, shape: BoxShape.circle, border: Border.all(color: ppPanel, width: 3))),
            Expanded(child: Container(width: 2, color: ppHair)),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.date, style: ppBody(11, color: ppMuted)),
                const SizedBox(height: 3),
                Text(m.title, style: ppJakarta(15)),
              ]),
            ),
          ),
        ]),
      );
}

// ---- Search -----------------------------------------------------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moments = jvMemories.where((m) => m.kind == JvKind.moment || m.kind == JvKind.guided).toList();
    final stories = jvMemories.where((m) => m.kind == JvKind.story).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 18, color: ppMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Search memories, stories, letters', hintStyle: ppBody(13, color: ppMuted)),
                      style: ppBody(13, color: ppInk),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: Text('Cancel', style: ppBody(13, color: ppPurple, w: FontWeight.w700))),
          ])),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
              for (var i = 0; i < 4; i++) _chip(['All', 'Photos', 'Stories', 'Letters'][i], i == 0),
            ]),
          ),
          const SizedBox(height: 10),
          _group(context, 'Memories', moments),
          _group(context, 'Stories', stories),
          _group(context, 'Letters', jvLetters),
          const SizedBox(height: 8),
          Center(child: GestureDetector(onTap: () => _snack(context, 'Full search coming soon'), child: Text('See all results', style: ppBody(13, color: ppPurple, w: FontWeight.w700)))),
        ],
      ),
    );
  }

  Widget _chip(String t, bool on) => Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(12, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
      );

  Widget _group(BuildContext context, String title, List<JvMemory> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        jvPad(Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(title, style: ppJakarta(13, color: ppMuted)))),
        for (final m in items)
          jvPad(GestureDetector(
            onTap: () => openMemory(context, m),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                JvPhoto(seed: m.seed, height: 44, width: 44, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.title, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(m.date, style: ppBody(11, color: ppMuted)),
                  ]),
                ),
              ]),
            ),
          )),
      ]);
}

// ---- Letters ----------------------------------------------------------------
class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(jvTopBar(context, title: 'Letters to $jvChild')),
          const SizedBox(height: 8),
          jvPad(Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text('Words for them to read one day.', style: ppBody(13)))),
          const SizedBox(height: 8),
          for (final l in jvLetters)
            jvPad(GestureDetector(
              onTap: () => openMemory(context, l),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: jvPaper, borderRadius: BorderRadius.circular(20), border: Border.all(color: jvPaperLine)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.favorite, size: 14, color: ppCoral),
                    const SizedBox(width: 8),
                    Text(l.date, style: ppBody(11, color: jvSepia, w: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Text(l.title, style: ppFraunces(19, h: 1.2)),
                  const SizedBox(height: 8),
                  Text(l.body.replaceAll('\n', ' '), style: ppFraunces(14, color: ppSoft, h: 1.6).copyWith(fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              ),
            )),
        ],
      ),
    );
  }
}
