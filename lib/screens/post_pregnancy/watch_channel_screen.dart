// =============================================================================
//  WatchChannelScreen - an expert's channel (YouTube-style, learning-first)
// -----------------------------------------------------------------------------
//  Everything one expert has made, in one place: an "about the expert" header
//  with a Subscribe button, then tabs for Videos, Podcasts, Shorts, Courses and
//  Masterclasses. Buckets are derived from the shared catalog (pp_channels_data),
//  so the page fills itself. Subscribe reuses WatchStore (shared with Follow).
//
//  COURSES / MASTERCLASSES are display-only here: the unified Courses &
//  Masterclasses section is being rebuilt in parallel, so tapping one calls the
//  openExpertCourses(context, expertId) STUB at the bottom of this file. The
//  integrator rewires that single function to the real section.
// =============================================================================

import 'package:flutter/material.dart';

import 'learning_home_screen.dart';
import 'pp_channels_data.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'pp_watch_data.dart';
import 'provider_profile_screen.dart';
import 'watch_common.dart';
import 'watch_player_screen.dart';
import 'watch_shorts_screen.dart';

class WatchChannelScreen extends StatefulWidget {
  const WatchChannelScreen({super.key, required this.expertId});
  final String expertId;

  @override
  State<WatchChannelScreen> createState() => _WatchChannelScreenState();
}

class _WatchChannelScreenState extends State<WatchChannelScreen> {
  int _tab = 0; // 0 Videos · 1 Podcasts · 2 Shorts · 3 Courses · 4 Masterclasses

  static const List<String> _tabs = ['Videos', 'Podcasts', 'Shorts', 'Courses', 'Masterclasses'];

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _openVideo(WatchVideo v) => v.quick && !v.isPodcast
      ? _push(WatchShortsScreen(startId: v.id))
      : _push(WatchPlayerScreen(video: v));

  @override
  Widget build(BuildContext context) {
    final channel = channelById(widget.expertId);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: WatchStore.instance,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                _pad(ppBack(context, 'Watch')),
                const SizedBox(height: 14),
                _header(channel),
                const SizedBox(height: 20),
                _tabBar(channel),
                const SizedBox(height: 20),
                ..._body(channel),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- header -------------------------------------------------------------
  Widget _header(WatchChannel channel) {
    final e = channel.expert;
    final subscribed = WatchStore.instance.isSubscribed(e.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // banner
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PpStriped(height: 104, colorA: ppPanel, colorB: ppStripeB, border: true),
        ),
      ),
      Transform.translate(
        offset: const Offset(0, -30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), color: Colors.white),
              clipBehavior: Clip.antiAlias,
              child: const PpStriped(height: 72, colorA: ppBorder, colorB: ppStripeB),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.name, style: ppFraunces(23, h: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(channel.handle, style: ppBody(12.5, color: ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
          ]),
        ),
      ),
      Transform.translate(
        offset: const Offset(0, -18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.credential, style: ppBody(13, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              const Text('★', style: TextStyle(color: ppCoral, fontSize: 13)),
              const SizedBox(width: 5),
              Text(e.rating, style: ppBody(12.5, color: ppInk, w: FontWeight.w700)),
              const SizedBox(width: 6),
              Flexible(child: Text('· ${e.reviewsCount}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Text(channel.statsLine, style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
            const SizedBox(height: 14),
            Text(ppFill(e.why), style: ppBody(13.5, h: 1.55), maxLines: 4, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(flex: 3, child: _subscribeButton(e, subscribed)),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _push(ProviderProfileScreen(expert: e)),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text('View profile',
                        style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _subscribeButton(Expert e, bool subscribed) => GestureDetector(
        onTap: () => WatchStore.instance.toggleSubscribe(e.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: subscribed ? Colors.transparent : ppPurple,
            borderRadius: BorderRadius.circular(999),
            border: subscribed ? Border.all(color: ppBorder) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(subscribed ? Icons.check_rounded : Icons.add_rounded, size: 18, color: subscribed ? ppSoft : Colors.white),
            const SizedBox(width: 7),
            Flexible(
              child: Text(subscribed ? 'Subscribed' : 'Subscribe',
                  style: ppBody(13.5, color: subscribed ? ppSoft : Colors.white, w: FontWeight.w800),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      );

  // ---- tab bar ------------------------------------------------------------
  Widget _tabBar(WatchChannel channel) {
    final counts = [
      channel.videos.length,
      channel.podcasts.length,
      channel.shorts.length,
      channel.courses.length,
      channel.masterclasses.length,
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final on = i == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? ppPurple : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? ppPurple : ppHair),
              ),
              child: Text('${_tabs[i]}${counts[i] > 0 ? '  ${counts[i]}' : ''}',
                  style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }

  // ---- body ---------------------------------------------------------------
  List<Widget> _body(WatchChannel channel) {
    switch (_tab) {
      case 1:
        return _podcasts(channel.podcasts);
      case 2:
        return _shorts(channel.shorts);
      case 3:
        return _courses(channel.courses, 'No courses yet - new ones are in the works.');
      case 4:
        return _courses(channel.masterclasses, 'No live masterclasses scheduled yet.');
      default:
        return _videos(channel.videos);
    }
  }

  Widget _empty(String msg) => _pad(Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(msg, style: ppBody(13.5, color: ppMuted)),
      ));

  List<Widget> _videos(List<WatchVideo> vids) {
    if (vids.isEmpty) return [_empty('No videos yet - new lessons are on the way.')];
    return [
      _pad(Column(children: [
        for (final v in vids)
          WatchListCard(
            video: v,
            onTap: () => _openVideo(v),
            progress: _liveProgress(v.id),
          ),
      ])),
    ];
  }

  List<Widget> _podcasts(List<WatchVideo> pods) {
    if (pods.isEmpty) return [_empty('No podcast episodes yet - stay tuned.')];
    return [
      for (final p in pods) _pad(_podcastRow(p)),
    ];
  }

  Widget _podcastRow(WatchVideo p) => GestureDetector(
        onTap: () => _openVideo(p),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.headphones_rounded, size: 22, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('PODCAST', style: ppBody(9.5, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(width: 8),
                  Text(p.durationLabel, style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                Text(p.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(p.topic, style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_outline_rounded, size: 26, color: ppPurple),
          ]),
        ),
      );

  List<Widget> _shorts(List<WatchVideo> shorts) {
    if (shorts.isEmpty) return [_empty('No shorts yet - quick clips are coming.')];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(builder: (context, c) {
          const gap = 12.0;
          final w = (c.maxWidth - gap * 2) / 3;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final s in shorts)
                GestureDetector(
                  onTap: () => _push(WatchShortsScreen(startId: s.id)),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: w,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      WatchThumb(seed: s.seed, height: w * 1.55, duration: s.durationLabel, quick: true),
                      const SizedBox(height: 7),
                      Text(s.title, style: ppBody(12, color: ppInk, w: FontWeight.w600, h: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
            ],
          );
        }),
      ),
    ];
  }

  List<Widget> _courses(List<ChannelCourse> items, String emptyMsg) {
    if (items.isEmpty) return [_empty(emptyMsg)];
    return [
      _pad(Text('Opens in the Courses & Masterclasses section.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 14),
      for (final c in items) _pad(_courseCard(c)),
    ];
  }

  Widget _courseCard(ChannelCourse c) => GestureDetector(
        onTap: () => openExpertCourses(context, widget.expertId),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          clipBehavior: Clip.antiAlias,
          child: Row(children: [
            SizedBox(width: 108, child: WatchThumb(seed: c.seed, height: 92, radius: 0, showPlay: false)),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.masterclass ? 'MASTERCLASS' : 'COURSE',
                      style: ppBody(9.5, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  Text(c.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(c.subtitle, style: ppBody(12, color: ppSoft), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(c.masterclass ? '~${c.lessons} min live' : '${c.lessons} lessons',
                      style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
                ]),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted)),
          ]),
        ),
      );

  double? _liveProgress(String id) {
    final p = WatchStore.instance.progressOf(id);
    return p > 0.02 && p < 0.98 ? p : null;
  }
}

// =============================================================================
//  openExpertCourses - INTEGRATION STUB
// -----------------------------------------------------------------------------
//  TODO(integration): the Courses & Masterclasses module is being rebuilt in
//  parallel. This stub is intentionally a placeholder - REWIRE it to open the
//  unified Courses & Masterclasses section for [expertId] (e.g. push the section
//  filtered to this expert). It is called from the Channel screen's Courses and
//  Masterclasses tabs. Keeping it here means one obvious edit point at
//  integration time; nothing else in Watch imports the Courses module.
// =============================================================================
void openExpertCourses(BuildContext context, String expertId) {
  // Wired at integration: open the unified Courses & Masterclasses section,
  // pre-filtered to this expert's programs.
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => LearningHomeScreen(instructorId: expertId),
  ));
}
