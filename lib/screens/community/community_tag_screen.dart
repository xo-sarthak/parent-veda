// One #tag's feed: route 'community/tag/<tag>', opened from a tag in a post's
// words or from search (0137). Follow puts the tag's posts into her
// Following feed; nobody is told and no count is shown (plan decision 15).
import 'package:flutter/material.dart';

import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';

class CommunityTagScreen extends StatefulWidget {
  const CommunityTagScreen({super.key, required this.tag});

  /// Lower case, without the '#'.
  final String tag;

  @override
  State<CommunityTagScreen> createState() => _CommunityTagScreenState();
}

class _CommunityTagScreenState extends State<CommunityTagScreen> {
  final _store = PvCommunityStore.instance;
  bool _offline = false;

  String get _key => PvCommunityStore.feedKey(scope: 'tag', sort: 'new', room: widget.tag);

  @override
  void initState() {
    super.initState();
    _store.init().then((_) {
      _load();
      if (_store.signedIn) _store.loadFollowing();
    });
  }

  Future<void> _load() async {
    final ok = await _store.loadFeed(scope: 'tag', sort: 'new', room: widget.tag);
    if (mounted) setState(() => _offline = !ok && _store.signedIn);
  }

  Future<void> _toggleFollow() async {
    if (!await communityEnsureMember(context)) return;
    final on = !_store.followsTag(widget.tag);
    final ok = await _store.follow(kind: 'tag', target: widget.tag, on: on);
    if (!mounted) return;
    pvToast(
      context,
      !ok
          ? 'That did not go through. Check your connection and try again.'
          : (on
                ? 'Following #${widget.tag}. Its posts now show in Following.'
                : 'You stopped following #${widget.tag}'),
      kind: ok ? (on ? PvToastKind.done : PvToastKind.info) : PvToastKind.gentle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) {
        final posts = _store.feed(_key);
        final following = _store.followsTag(widget.tag);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: RefreshIndicator(
            color: kPvInk,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Text('#${widget.tag}', style: cmTitle(30)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Every post tagged #${widget.tag}, newest first.',
                          style: cmText(14, color: cmP.ink2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      following
                          ? OutlinedButton.icon(
                              key: const ValueKey('community_tag_following'),
                              onPressed: _toggleFollow,
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Following'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kPvInk,
                                side: const BorderSide(color: kPvInk, width: 1.4),
                                shape: const StadiumBorder(),
                                textStyle: cmText(14, weight: FontWeight.w700),
                              ),
                            )
                          : CommunityInkButton(
                              key: const ValueKey('community_tag_follow'),
                              label: 'Follow',
                              compact: true,
                              onTap: _toggleFollow,
                            ),
                    ],
                  ),
                ),
                if (_offline)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: CommunityStatusLine(
                      icon: Icons.cloud_off_outlined,
                      text: 'Offline. Showing what was saved on your phone. Pull down to try again.',
                    ),
                  ),
                if (posts.isEmpty && _store.isLoading(_key))
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
                  )
                else if (posts.isEmpty)
                  CommunityEmpty(
                    icon: Icons.tag_rounded,
                    title: 'No posts with #${widget.tag} yet',
                    body: 'Add #${widget.tag} to a post and it gathers here, for everyone following it.',
                    action: 'Write a post',
                    onAction: () => openCommunityCompose(context),
                  )
                else
                  for (final p in posts) CommunityPostCard(post: p, showJoin: false),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
