// =============================================================================
//  DevStageDetailScreen - one skill / milestone, in full
// -----------------------------------------------------------------------------
//  The real destination for a skill box on a development-area screen, and for a
//  milestone row on the My Child home. Same content either way: what the skill /
//  milestone is, why it matters, where it sits on the journey, and the small,
//  doable ways to help it along. Honest and supportive - never a checklist.
// =============================================================================

import 'package:flutter/material.dart';

import 'development_activity_screen.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';

class DevStageDetailScreen extends StatelessWidget {
  const DevStageDetailScreen({
    super.key,
    required this.area,
    required this.stage,
    this.kindLabel = 'Skill',
  });

  final DevArea area;
  final DevStage stage;
  final String kindLabel; // 'Skill' or 'Milestone'

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  Color get _a => area.accent;

  (String, Color) get _statusTag => switch (stage.status) {
        'mastered' => ('Mastered', _a),
        'current' => ('Practising now', _a),
        'next' => ('Coming next', _a),
        _ => ('Further ahead', ppMuted),
      };

  @override
  Widget build(BuildContext context) {
    final acts = stage.activities.map(devActivityById).toList();
    final (tagLabel, tagColor) = _statusTag;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, area.name)),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Flexible(child: ppEyebrow('$kindLabel · ${area.name}', color: _a, spacing: 1.1)),
            ])),
            const SizedBox(height: 8),
            _pad(Text(stage.name, style: ppFraunces(29, h: 1.12))),
            const SizedBox(height: 10),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(tagLabel, style: ppBody(11.5, color: tagColor, w: FontWeight.w700)),
            )),

            const SizedBox(height: 20),
            _pad(Text('What it is', style: ppJakarta(16))),
            const SizedBox(height: 8),
            _pad(Text(stage.meaning, style: ppBody(14.5, color: ppInk, h: 1.6))),

            const SizedBox(height: 20),
            _pad(Text('Why it matters', style: ppJakarta(16))),
            const SizedBox(height: 8),
            _pad(Text(stage.why, style: ppBody(14.5, color: ppInk, h: 1.6))),

            // area brain-window note, for a little extra depth
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _a.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.psychology_outlined, size: 17, color: _a),
                const SizedBox(width: 11),
                Expanded(child: Text(area.brainNote, style: ppBody(13, color: ppInk, h: 1.55))),
              ]),
            )),

            // ways to help it along
            _pad(ppSectionDivider()),
            _pad(Text('Ways to help it along', style: ppJakarta(17))),
            const SizedBox(height: 6),
            _pad(Text(acts.isEmpty
                ? 'The best support is simple: notice it, make gentle room for it, and follow his lead — there is nothing to drill.'
                : 'A few small, playful things that gently encourage it. No pressure, no schedule.', style: ppBody(12.5, color: ppMuted))),
            if (acts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _pad(Column(children: [
                for (final act in acts)
                  GestureDetector(
                    onTap: () => _push(context, DevelopmentActivityScreen(activity: act)),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
                      child: Row(children: [
                        Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: _a.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(Icons.play_arrow_rounded, size: 19, color: _a)),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(act.title, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${act.minutes} min · ${act.difficulty}', style: ppBody(12, color: ppMuted)),
                          ]),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                      ]),
                    ),
                  ),
              ])),
            ],

            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.favorite_border, size: 17, color: ppCoral),
                const SizedBox(width: 11),
                Expanded(child: Text('Every baby arrives at each skill in his own week. This is a window into what he\'s working on — never a test he can be behind on.', style: ppBody(13, color: ppInk, h: 1.55))),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}
