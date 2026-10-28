// Community home: route 'community'. Flo Secret Chats' shape (pills over one
// feed, a rail of rooms) in the app's own look. docs/COMMUNITY.md §Screens.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_motion.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

enum _Tab { forYou, rooms, saved, mine }

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  final _store = PvCommunityStore.instance;
  final _scroll = ScrollController();
  _Tab _tab = _Tab.forYou;
  bool _offline = false;
  bool _fabWide = true;

  String get _scope => switch (_tab) {
        _Tab.forYou => 'for_you',
        _Tab.rooms => 'rooms',
        _Tab.saved => 'ids',
        _Tab.mine => 'mine',
      };
  String get _sort => _tab == _Tab.forYou || _tab == _Tab.rooms ? 'top' : 'new';
  String get _key => PvCommunityStore.feedKey(scope: _scope, sort: _sort);

  @override
  void initState() {
    super.initState();
    _store.init().then((_) {
      _store.refreshMe();
      _load();
    });
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // The compose button folds to a circle while she scrolls down (X, Reddit)
    // so it never sits on the words she is reading.
    final dir = _scroll.position.userScrollDirection;
    final next = _scroll.offset < 40 || dir == ScrollDirection.forward
        ? true
        : (dir == ScrollDirection.reverse ? false : _fabWide);
    if (next != _fabWide) setState(() => _fabWide = next);
    if (_scroll.position.extentAfter < 600 && _store.hasMore(_key) && !_store.isLoading(_key)) {
      _store.loadFeed(scope: _scope, sort: _sort, more: true);
    }
  }

  Future<void> _load() async {
    final ok = await _store.loadFeed(scope: _scope, sort: _sort);
    if (mounted) setState(() => _offline = !ok && _store.signedIn);
  }

  Future<void> _refresh() async {
    await _store.refreshMe();
    await _load();
    if (mounted && _offline) {
      pvToast(context, 'No connection. Showing what was saved on your phone.', kind: PvToastKind.gentle);
    }
  }

  void _setTab(_Tab t) {
    if (t == _tab) return;
    setState(() => _tab = t);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) {
        final posts = _store.feed(_key);
        final me = _store.me;
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _ComposeFab(wide: _fabWide, onTap: () => openCommunityCompose(context)),
          body: RefreshIndicator(
            color: kPvInk,
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  actions: [
                    if (me.isMod)
                      IconButton(
                        tooltip: 'Moderation',
                        icon: const Icon(Icons.shield_outlined, color: kPvInk),
                        onPressed: () => openCommunityModeration(context),
                      ),
                    IconButton(
                      tooltip: me.joined ? 'Your community profile' : 'Your profile',
                      icon: me.joined
                          ? CommunityFaceMark(author: _store.myFace(anon: true), size: 28)
                          : const Icon(Icons.person_outline_rounded, color: kPvInk),
                      onPressed: () => openCommunityProfile(context),
                    ),
                    IconButton(
                      tooltip: me.unread > 0 ? '${me.unread} new replies' : 'Replies to you',
                      icon: Badge(
                        isLabelVisible: me.unread > 0,
                        backgroundColor: const Color(0xFFC6295A),
                        label: Text('${me.unread}'),
                        child: const Icon(Icons.notifications_none_rounded, color: kPvInk),
                      ),
                      onPressed: () => openCommunityActivity(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Text('Community', style: cmTitle(32)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Parents at your stage, talking honestly. Post under your community name or your own.',
                      style: cmText(14, color: cmP.ink2),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PillsHeader(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(children: [
                        for (final (t, l) in const [
                          (_Tab.forYou, 'For you'),
                          (_Tab.rooms, 'My rooms'),
                          (_Tab.saved, 'Saved'),
                          (_Tab.mine, 'My posts'),
                        ]) ...[
                          CommunityPill(label: l, selected: _tab == t, onTap: () => _setTab(t)),
                          const SizedBox(width: 8),
                        ],
                      ]),
                    ),
                  ),
                ),
                if (!_store.signedIn)
                  SliverToBoxAdapter(
                    child: CommunityEmpty(
                      icon: Icons.lock_outline_rounded,
                      title: 'Sign in to join the conversation',
                      body: 'The community is for signed-in members, so every room stays moderated and kind.',
                      action: 'Sign in',
                      onAction: () => openCommunitySignIn(context),
                    ),
                  ),
                if (_offline)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: CommunityStatusLine(
                        icon: Icons.cloud_off_outlined,
                        text: 'Offline. Showing what was saved on your phone. Pull down to try again.',
                      ),
                    ),
                  ),
                if (_tab == _Tab.forYou && _store.rooms.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                      child: Row(children: [
                        Expanded(child: Text('Rooms for you', style: cmText(17, weight: FontWeight.w800))),
                        Text('Your stage first', style: cmText(12.5, color: cmP.ink3)),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(child: _RoomRail(rooms: _store.rooms)),
                ],
                ..._feed(posts),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _feed(List<PvCommunityPost> posts) {
    if (posts.isEmpty) {
      if (_store.isLoading(_key)) {
        return [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
            ),
          ),
        ];
      }
      if (!_store.signedIn) return const [];
      final (title, body, action) = switch (_tab) {
        _Tab.forYou => (
            'Be one of the first voices here',
            'Ask something, or share what helped you. Parents at your stage will see it.',
            'Write a post',
          ),
        _Tab.rooms => (
            'Join a room to fill this',
            'Rooms for your stage are above. Their posts gather here.',
            null,
          ),
        _Tab.saved => (
            'Nothing saved yet',
            'Tap the bookmark on any post to keep it here, and in your Saved list.',
            null,
          ),
        _Tab.mine => (
            'You have not posted yet',
            'Ask something, or share what helped you. You can post under your community name.',
            'Write a post',
          ),
      };
      return [
        SliverToBoxAdapter(
          child: CommunityEmpty(
            icon: _tab == _Tab.saved ? Icons.bookmark_border_rounded : Icons.forum_outlined,
            title: title,
            body: body,
            action: action,
            onAction: action == null ? null : () => openCommunityCompose(context),
          ),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: posts.length + (_store.isLoading(_key) ? 1 : 0),
        itemBuilder: (_, i) => i >= posts.length
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
              )
            : CommunityEnter(
                key: ValueKey(posts[i].id),
                index: i,
                child: CommunityPostCard(post: posts[i], showJoin: _tab == _Tab.forYou),
              ),
      ),
    ];
  }
}

class _PillsHeader extends SliverPersistentHeaderDelegate {
  _PillsHeader({required this.child});
  final Widget child;
  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: Colors.white, child: Align(alignment: Alignment.centerLeft, child: child));
  @override
  bool shouldRebuild(_PillsHeader old) => true;
}

class _RoomRail extends StatelessWidget {
  const _RoomRail({required this.rooms});
  final List<PvCommunityRoom> rooms;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          itemCount: rooms.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final r = rooms[i];
            return Semantics(
              button: true,
              label: '${r.title}${r.joined ? ', joined' : ''}',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => openCommunityRoom(context, r.id),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cmP.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CommunityRoomMark(mark: r.mark, hue: r.hue, size: 40),
                    const Spacer(),
                    Text(r.title, maxLines: 2, style: cmText(13.5, weight: FontWeight.w800, height: 1.25)),
                    const SizedBox(height: 2),
                    Text(r.joined ? 'Joined' : (communityMembersLine(r.members) ?? 'Tap to look in'),
                        style: cmText(12, color: cmP.ink3)),
                  ]),
                ),
              ),
            );
          },
        ),
      );
}

/// "Write a post", folding to a round pen while she scrolls.
class _ComposeFab extends StatelessWidget {
  const _ComposeFab({required this.wide, required this.onTap});
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Write a post',
        child: Material(
          color: kPvInk,
          elevation: 6,
          shadowColor: Colors.black38,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => unawaited(Future.sync(onTap)),
            child: AnimatedSize(
              duration: PvMotion.resize,
              curve: PvMotion.arrive,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 16, vertical: 16),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  if (wide) ...[
                    const SizedBox(width: 8),
                    Text('Write a post', style: cmText(15, weight: FontWeight.w700, color: Colors.white)),
                  ],
                ]),
              ),
            ),
          ),
        ),
      );
}
