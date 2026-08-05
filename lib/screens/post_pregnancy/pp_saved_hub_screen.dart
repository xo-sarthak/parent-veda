// =============================================================================
//  PpSavedHubScreen — everything saved on the parenting side, in one place.
// -----------------------------------------------------------------------------
//  The pregnancy home has had a bookmark button beside its search icon for a
//  while (SavedHubScreen, opened from home_screen_b). The parenting side had
//  the same SAVE affordances scattered across Watch, Learn and now the daily
//  pop-up, and nowhere at all to see what you had saved. So a parent could
//  bookmark a video and then never find it again — which makes the bookmark a
//  button that appears to do nothing.
//
//  This is the parenting counterpart, reached from the bookmark icon in the My
//  Child header.
//
//  EVERY GROUP ALWAYS RENDERS ITS HEADER, copied deliberately from the
//  pregnancy hub's own rule: an empty group shows a line saying where you would
//  save that kind of thing. A parent who has only ever saved videos still
//  learns that reads and tips are savable. A feature is never hidden for being
//  empty — the empty state is the feature's advertisement.
//
//  IT OWNS NO STATE. Everything here is read from the stores that already hold
//  it — WatchStore, ReadingStore, DailyTipStore — so a video saved in the Watch
//  tab, from a rail, or out of the daily pop-up is one saved video in one
//  place, not three lists that drift.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart' show kAskFabReserve;

import 'daily_tip_popup.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';
import 'pp_reading_data.dart';
import 'pp_watch_data.dart';
import 'reading_reader_screen.dart';
import 'reading_home_screen.dart';
import 'watch_home_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class PpSavedHubScreen extends StatelessWidget {
  const PpSavedHubScreen({super.key});

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _push(BuildContext c, Widget s) =>
      Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        WatchStore.instance,
        ReadingStore.instance,
        DailyTipStore.instance,
      ]),
      builder: (context, _) {
        final videos = kWatchVideos
            .where((v) => WatchStore.instance.isSaved(v.id))
            .toList();
        final reads = kReadArticles
            .where((a) => ReadingStore.instance.isSaved(a.id))
            .toList();
        final tips = _savedTips();
        final total = videos.length + reads.length + tips.length;

        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
              children: [
                _pad(ppBack(context, 'My Child')),
                const SizedBox(height: 20),
                _pad(ppEyebrow('Saved', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Your collection', style: ppFraunces(30, h: 1.05))),
                const SizedBox(height: 8),
                _pad(Text(
                    total == 0
                        ? 'Nothing saved yet. The bookmark on a video, a read or '
                            'the daily card puts it here.'
                        : '$total saved — kept for whenever you have a minute.',
                    style: ppBody(14, h: 1.55))),

                const SizedBox(height: 26),
                ..._group(
                  context,
                  'Videos',
                  'Saved from Watch, a rail, or the daily card.',
                  videos.length,
                  emptyCta: 'Browse videos',
                  onEmptyCta: () => _push(context, const WatchHomeScreen()),
                  children: [
                    for (final v in videos)
                      _row(
                        context,
                        Icons.play_circle_outline_rounded,
                        v.title,
                        '${v.durationLabel} · ${v.expert.name}',
                        () => _push(
                            context,
                            v.quick
                                ? QuickLearnScreen(startId: v.id)
                                : WatchPlayerScreen(video: v)),
                        onUnsave: () => WatchStore.instance.toggleSave(v.id),
                      ),
                  ],
                ),

                const SizedBox(height: 22),
                ..._group(
                  context,
                  'Reads',
                  'Articles you kept for later.',
                  reads.length,
                  emptyCta: 'Browse reads',
                  onEmptyCta: () => _push(context, const ReadingHomeScreen()),
                  children: [
                    for (final a in reads)
                      _row(
                        context,
                        Icons.auto_stories_outlined,
                        a.title,
                        '${a.minutes} min · ${a.author}',
                        () => _push(context, ReadingReaderScreen(article: a)),
                        onUnsave: () => ReadingStore.instance.toggleSave(a.id),
                      ),
                  ],
                ),

                const SizedBox(height: 22),
                ..._group(
                  context,
                  'Daily tips',
                  'Kept from the card that opens with the app.',
                  tips.length,
                  emptyCta: 'See today\'s',
                  onEmptyCta: () => showDailyTip(context),
                  children: [
                    for (final t in tips)
                      _row(
                        context,
                        Icons.wb_twilight_rounded,
                        t.$2.title,
                        t.$2.why.isEmpty ? 'A daily tip' : 'With the reason why',
                        () => _push(context, _SavedTipScreen(tip: t.$2)),
                        onUnsave: () =>
                            DailyTipStore.instance.toggleSaved(t.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saved tips, resolved from their stored ids.
  ///
  /// The id encodes an index into kDailyTips, so a saved tip survives the list
  /// growing at the end. Ids that no longer resolve are dropped silently rather
  /// than rendering a blank row — a tip removed from the catalogue should
  /// disappear, not become an empty line a parent cannot get rid of.
  List<(String, DailyTip)> _savedTips() {
    final out = <(String, DailyTip)>[];
    for (final id in DailyTipStore.instance.saved) {
      final n = int.tryParse(id.replaceFirst('tip_', ''));
      if (n == null || n < 0 || n >= kDailyTips.length) continue;
      out.add((id, kDailyTips[n]));
    }
    return out;
  }

  List<Widget> _group(
    BuildContext context,
    String title,
    String sub,
    int count, {
    required List<Widget> children,
    required String emptyCta,
    required VoidCallback onEmptyCta,
  }) =>
      [
        _pad(Row(children: [
          Expanded(child: Text(title, style: ppJakarta(17))),
          if (count > 0)
            Text('$count', style: ppBody(12.5, color: ppMuted)),
        ])),
        const SizedBox(height: 4),
        _pad(Text(sub, style: ppBody(12.5, color: ppMuted))),
        const SizedBox(height: 12),
        if (count == 0)
          _pad(GestureDetector(
            onTap: onEmptyCta,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ppPanel,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(children: [
                Expanded(
                  child: Text('Nothing here yet.',
                      style: ppBody(13, color: ppSoft)),
                ),
                Text(emptyCta,
                    style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: ppPurple),
              ]),
            ),
          ))
        else
          ...children,
      ];

  Widget _row(BuildContext context, IconData icon, String title, String sub,
          VoidCallback onTap,
          {required VoidCallback onUnsave}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _pad(GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ppBorder),
            ),
            child: Row(children: [
              Icon(icon, size: 19, color: ppPurple),
              const SizedBox(width: 13),
              Expanded(
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: ppJakarta(13.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(sub, style: ppBody(11.5, color: ppMuted)),
                ]),
              ),
              // Unsaving from the list it is IN. Anything else means going back
              // to wherever it came from to undo a bookmark, which nobody does.
              GestureDetector(
                onTap: onUnsave,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.bookmark_rounded, size: 18, color: ppPurple),
                ),
              ),
            ]),
          ),
        )),
      );
}

/// A saved tip, opened on its own.
///
/// The pop-up is a moment; this is the same content as a page you came looking
/// for, so it opens expanded rather than hiding the reason behind a tap.
class _SavedTipScreen extends StatelessWidget {
  const _SavedTipScreen({required this.tip});
  final DailyTip tip;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ppBg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            children: [
              ppBack(context, 'Saved'),
              const SizedBox(height: 22),
              Text(tip.title, style: ppFraunces(28, h: 1.1)),
              const SizedBox(height: 14),
              Text(tip.body, style: ppBody(15, h: 1.65)),
              if (tip.why.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Why this works', style: ppJakarta(16)),
                const SizedBox(height: 8),
                Text(tip.why, style: ppBody(14, h: 1.6)),
              ],
              if (tip.source.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ppPanel,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text('Based on ${tip.source}',
                      style: ppBody(12.5, color: ppSoft, h: 1.5)),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                  'General guidance for this stage — not advice about your '
                  'child in particular.',
                  style: ppBody(11.5, color: ppMuted, h: 1.5)),
            ],
          ),
        ),
      );
}
