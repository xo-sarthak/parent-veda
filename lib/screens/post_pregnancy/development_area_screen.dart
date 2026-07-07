// =============================================================================
//  DevelopmentAreaScreen — one area's journey (a story, not a checklist)
// -----------------------------------------------------------------------------
//  The developmental roadmap for one area (e.g. Gross Motor: head control →
//  rolling → sitting → crawling → walking), with what each skill means, why it
//  matters, activities to encourage it, a brain window and related content. Reads
//  like the child's story unfolding.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'development_activity_screen.dart';
import 'development_common.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_watch_data.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class DevelopmentAreaScreen extends StatelessWidget {
  const DevelopmentAreaScreen({super.key, required this.area});
  final DevArea area;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  Color get _a => area.accent;

  @override
  Widget build(BuildContext context) {
    final activities = activitiesForArea(area.id);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Development')),
            const SizedBox(height: 16),
            _pad(Row(children: [
              Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: _a.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(area.icon, size: 24, color: _a)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(area.name, style: ppFraunces(24, h: 1.1)),
                const SizedBox(height: 4),
                Row(children: [devWordPill(area.word, _a), const SizedBox(width: 8), Flexible(child: Text(area.stage, style: ppBody(12.5, color: _a, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              ])),
            ])),
            const SizedBox(height: 14),
            _pad(Text(area.summary, style: ppBody(14.5, color: ppInk, h: 1.55))),

            // brain window
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

            // the journey
            const SizedBox(height: 26),
            _pad(Text('His journey', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Where he’s been, where he is, and the wonder just ahead.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 18),
            _pad(Column(children: [
              for (int i = 0; i < area.journey.length; i++) _stageRow(context, area.journey[i], first: i == 0, last: i == area.journey.length - 1),
            ])),

            // activities
            if (activities.isNotEmpty) ...[
              const SizedBox(height: 14),
              _pad(Text('Ways to support it', style: ppJakarta(18))),
              const SizedBox(height: 14),
              _pad(Column(children: [for (final act in activities) DevActivityCard(activity: act, onTap: () => _push(context, DevelopmentActivityScreen(activity: act)))])),
            ],

            // related
            const SizedBox(height: 8),
            _pad(_related(context)),
          ],
        ),
      ),
    );
  }

  Widget _stageRow(BuildContext context, DevStage s, {bool first = false, bool last = false}) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 30,
          child: Column(children: [
            SizedBox(height: 3, child: first ? null : Container(width: 2, color: _a.withValues(alpha: 0.25))),
            _node(s.status),
            if (!last) Expanded(child: Container(width: 2, color: _a.withValues(alpha: 0.25))),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: s.status == 'current' ? _a.withValues(alpha: 0.07) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.status == 'current' ? _a.withValues(alpha: 0.4) : ppHair),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(s.name, style: ppJakarta(15, color: s.status == 'future' ? ppMuted : ppInk), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                _tag(s.status),
              ]),
              const SizedBox(height: 6),
              Text(s.meaning, style: ppBody(13, color: s.status == 'future' ? ppMuted : ppInk, h: 1.45)),
              const SizedBox(height: 4),
              Text(s.why, style: ppBody(12, color: ppMuted, h: 1.4)),
              if (s.activities.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final id in s.activities)
                  GestureDetector(
                    onTap: () => _push(context, DevelopmentActivityScreen(activity: devActivityById(id))),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(children: [
                        Icon(Icons.play_arrow_rounded, size: 15, color: _a),
                        const SizedBox(width: 6),
                        Expanded(child: Text(devActivityById(id).title, style: ppBody(12.5, color: _a, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _node(String status) {
    switch (status) {
      case 'mastered':
        return Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: _a, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 13, color: Colors.white));
      case 'current':
        return Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: _a.withValues(alpha: 0.15), border: Border.all(color: _a, width: 2)), child: Container(width: 11, height: 11, decoration: BoxDecoration(color: _a, shape: BoxShape.circle)));
      case 'next':
        return Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: _a, width: 2)), child: Container(width: 7, height: 7, decoration: BoxDecoration(color: _a, shape: BoxShape.circle)));
      default:
        return Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFCFC5DB), width: 1.5)));
    }
  }

  Widget _tag(String status) {
    final (String label, Color c) = switch (status) {
      'mastered' => ('Mastered', _a),
      'current' => ('Practicing now', _a),
      'next' => ('Coming next', _a),
      _ => ('Later', ppMuted),
    };
    return Text(label.toUpperCase(), style: ppBody(9, color: c, w: FontWeight.w800).copyWith(letterSpacing: 0.5));
  }

  Widget _related(BuildContext context) {
    final rows = <(IconData, String, String, VoidCallback)>[
      if (area.relatedArticle != null) (Icons.menu_book_outlined, 'Read', area.relatedArticle!, () => _push(context, const ArticleReaderScreen())),
      if (area.relatedVideoId != null)
        (Icons.play_circle_outline, 'Watch', watchVideoById(area.relatedVideoId!).title, () {
          final v = watchVideoById(area.relatedVideoId!);
          _push(context, v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v));
        }),
      (Icons.auto_awesome_outlined, 'Ask Veda', 'Ask about ${area.name.toLowerCase()}', () => openPpTab(context, 1)),
      (Icons.groups_outlined, 'Community', 'Compare notes with other parents', () => openPpTab(context, 3)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Go deeper', style: ppJakarta(18)),
      const SizedBox(height: 14),
      for (final r in rows)
        GestureDetector(
          onTap: r.$4,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
            child: Row(children: [
              Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(r.$1, size: 18, color: ppPurple)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.$2.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 3),
                  Text(r.$3, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
    ]);
  }
}
