// One room: route 'community/room/<id>'. Reddit's community page, calmed:
// the room's mark and blurb, Join, then Top / New over its posts.
import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_home_screen.dart';
import 'community_marks.dart';
import 'community_offering_thread.dart';

class CommunityRoomScreen extends StatefulWidget {
  const CommunityRoomScreen({super.key, required this.roomId});
  final String roomId;

  @override
  State<CommunityRoomScreen> createState() => _CommunityRoomScreenState();
}

class _CommunityRoomScreenState extends State<CommunityRoomScreen> {
  final _store = PvCommunityStore.instance;
  String _sort = 'top';

  /// (0137) A course room can narrow to one lesson or session.
  PvPostAbout? _about;

  /// Every "about" seen in this room's newest posts, for the pills.
  final List<PvPostAbout> _abouts = [];

  String get _key => PvCommunityStore.feedKey(scope: 'room', sort: _sort, room: widget.roomId, about: _about);

  @override
  void initState() {
    super.initState();
    _store.init().then((_) {
      if (_store.room(widget.roomId) == null) _store.refreshMe();
      _load();
      // Opening the room is reading it: the unread count clears.
      _store.roomSeen(widget.roomId);
    });
  }

  Future<void> _load() async {
    await _store.loadFeed(scope: 'room', sort: _sort, room: widget.roomId, about: _about);
    if (_about == null && mounted) {
      final seen = <PvPostAbout>{
        for (final p in _store.feed(PvCommunityStore.feedKey(scope: 'room', sort: _sort, room: widget.roomId)))
          ?p.about,
      };
      setState(() => _abouts
        ..clear()
        ..addAll(seen));
    }
  }

  Future<void> _menu() async {
    final r = _store.room(widget.roomId);
    if (r == null) return;
    final a = await showCommunitySheet<String>(
      context,
      (c) => ListView(shrinkWrap: true, children: [
        // B3: the team voice, for moderators, in any room including a course.
        if (_store.me.isMod)
          CommunitySheetRow(
            icon: Icons.campaign_outlined,
            label: 'Post as ParentVeda team',
            note: 'Members see the team, never your name',
            onTap: () => Navigator.pop(c, 'team'),
          ),
        if (r.joined)
          CommunitySheetRow(
            icon: r.muted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
            label: r.muted ? 'Unmute this room' : 'Mute this room',
            note: r.muted ? 'Its posts come back to For you' : 'Stay a member, but its posts leave For you',
            onTap: () => Navigator.pop(c, 'mute'),
          ),
        CommunitySheetRow(
          icon: Icons.health_and_safety_outlined,
          label: 'House rules',
          onTap: () => Navigator.pop(c, 'rules'),
        ),
        // A course room is held by her seat, not by Join, so there is no
        // Leave: she would be put back the next time the course page opens.
        if (r.joined && !r.isOffering)
          CommunitySheetRow(
            icon: Icons.logout_rounded,
            label: 'Leave room',
            danger: true,
            onTap: () => Navigator.pop(c, 'leave'),
          ),
      ]),
    );
    if (!mounted || a == null) return;
    switch (a) {
      case 'team':
        await openCommunityCompose(context, roomId: r.id, asTeam: true);
      case 'mute':
        final ok = await _store.setRoom(r.id, join: true, mute: !r.muted);
        if (mounted) {
          pvToast(
            context,
            !ok
                ? 'That did not go through. Try again.'
                : (r.muted ? '${r.title} is back in For you' : '${r.title} is muted. Its posts leave For you.'),
            kind: ok ? PvToastKind.done : PvToastKind.gentle,
          );
        }
      case 'rules':
        await showCommunitySheet<void>(context, (_) => const _RulesSheet());
      case 'leave':
        await communityJoinRoom(context, r.id, leave: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) {
        final r = _store.room(widget.roomId);
        final posts = _store.feed(_key);
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'community-room-compose',
            backgroundColor: kPvInk,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            onPressed: () => openCommunityCompose(context, roomId: widget.roomId),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text('Write a post', style: cmText(15, weight: FontWeight.w700, color: Colors.white)),
          ),
          body: RefreshIndicator(
            color: kPvInk,
            onRefresh: _load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  leading: IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Room options',
                      icon: const Icon(Icons.more_horiz_rounded, color: kPvInk),
                      onPressed: _menu,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: r == null
                        ? Text('Room', style: cmTitle(30))
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Hero(
                              tag: 'community-room-${r.id}',
                              child: CommunityRoomMark(mark: r.mark, hue: r.hue, size: 52),
                            ),
                            const SizedBox(height: 12),
                            Text(r.title, style: cmTitle(30)),
                            const SizedBox(height: 6),
                            if (r.isOffering)
                              // No Join: her seat is her membership (B1).
                              CommunityStatusLine(
                                key: const ValueKey('community_room_offering_line'),
                                icon: Icons.lock_outline_rounded,
                                text: '${communityDiscussionTitle(r)} · only people in this batch can see it · moderated',
                              )
                            else ...[
                            Text(r.blurb, style: cmText(14.5, color: cmP.ink2)),
                            const SizedBox(height: 14),
                            Row(children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: r.joined
                                    ? OutlinedButton.icon(
                                        key: const ValueKey('joined'),
                                        onPressed: () => communityJoinRoom(context, r.id, leave: true),
                                        icon: const Icon(Icons.check_rounded, size: 18),
                                        label: const Text('Joined'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: kPvInk,
                                          side: const BorderSide(color: kPvInk, width: 1.4),
                                          shape: const StadiumBorder(),
                                          textStyle: cmText(14, weight: FontWeight.w700),
                                        ),
                                      )
                                    : CommunityInkButton(
                                        key: const ValueKey('join'),
                                        label: 'Join room',
                                        compact: true,
                                        onTap: () => communityJoinRoom(context, r.id),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  [
                                    ?communityMembersLine(r.members),
                                    'Moderated',
                                    if (r.muted) 'Muted',
                                  ].join(' · '),
                                  style: cmText(12.5, color: cmP.ink3),
                                ),
                              ),
                            ]),
                            ],
                          ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Row(children: [
                      CommunityPill(
                        label: 'Top',
                        selected: _sort == 'top',
                        onTap: () {
                          setState(() => _sort = 'top');
                          _load();
                        },
                      ),
                      const SizedBox(width: 8),
                      CommunityPill(
                        label: 'New',
                        selected: _sort == 'new',
                        onTap: () {
                          setState(() => _sort = 'new');
                          _load();
                        },
                      ),
                      // (0137) What a course post is about: one room per
                      // batch, filtered by lesson, beats a row of empty
                      // per-lesson rooms (L.2).
                      if (r?.isOffering == true)
                        for (final a in _abouts) ...[
                          const SizedBox(width: 8),
                          CommunityPill(
                            label: communityAboutLabel(r!.programmeId, a),
                            selected: _about == a,
                            onTap: () {
                              setState(() => _about = _about == a ? null : a);
                              _load();
                            },
                          ),
                        ],
                    ]),
                  ),
                ),
                if (r == null && _store.rooms.isNotEmpty)
                  SliverToBoxAdapter(
                    child: CommunityEmpty(
                      icon: Icons.meeting_room_outlined,
                      title: 'This room is not open',
                      body: 'It may have moved. Rooms for your stage are waiting in the community.',
                      action: 'See all rooms',
                      onAction: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                        builder: (_) => const CommunityHomeScreen(),
                        settings: const RouteSettings(name: kCommunityRoute),
                      )),
                    ),
                  )
                else if (posts.isEmpty)
                  SliverToBoxAdapter(
                    child: _store.isLoading(_key)
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                          )
                        : CommunityEmpty(
                            title: 'Be the first to start this conversation',
                            body: 'Questions here reach parents at the same point as you.',
                            action: 'Write a post',
                            onAction: () => openCommunityCompose(context, roomId: widget.roomId),
                          ),
                  )
                else
                  SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder: (_, i) => CommunityEnter(
                      key: ValueKey(posts[i].id),
                      index: i,
                      child: CommunityPostCard(post: posts[i], showRoom: false),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('House rules', style: cmTitle(26)),
          const SizedBox(height: 14),
          for (final (t, b) in const [
            ('Be kind, always', 'Everyone here is going through something. Disagree gently.'),
            ('Share what helped you, not orders',
                'Talk about your own experience. For anything medical, your doctor has the final word.'),
            ('What is shared here stays here',
                'No screenshots of other people\'s stories, and no trying to find out who someone is.'),
            ('No selling, no links, no phone numbers',
                'Posts with links or numbers wait for a moderator before anyone sees them.'),
          ]) ...[
            Text(t, style: cmText(15, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(b, style: cmText(13.5, color: cmP.ink2)),
            const SizedBox(height: 12),
          ],
          Text(
            'Moderators remove posts that break these rules. Repeated breaks pause posting for a while.',
            style: cmText(12.5, color: cmP.ink3),
          ),
          const SizedBox(height: 4),
          const CommunityGrievanceLine(),
        ]),
      );
}
