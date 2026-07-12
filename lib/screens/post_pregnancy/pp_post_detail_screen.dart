// =============================================================================
//  PpPostDetailScreen - one parenting post (post + comments + related)
// -----------------------------------------------------------------------------
//  The parenting mirror of the pregnancy PostDetailScreen: the full post, its
//  comment thread (seed + the user's own; a doctor-mode reply posts AS the
//  verified doctor and endorses a post that asked for verification), a reply
//  composer, related discussions and suggested rooms - the retention loop.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/community_models.dart';
import '../../services/community_store.dart';
import 'community_screen.dart';
import 'pp_common.dart';
import 'pp_community_detail_screen.dart';

class PpPostDetailScreen extends StatefulWidget {
  const PpPostDetailScreen({super.key, required this.post});
  final CommunityPost post;
  @override
  State<PpPostDetailScreen> createState() => _PpPostDetailScreenState();
}

class _PpPostDetailScreenState extends State<PpPostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final t = _commentCtrl.text.trim();
    if (t.isEmpty) return;
    CommunityStore.instance.addComment(widget.post.id, t);
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final post = widget.post;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final seed = ppSeedComments(post.id);
            final mine = store.userComments(post.id);
            final related = ppFeed()
                .where((p) =>
                    p.id != post.id && p.topics.any(post.topics.contains))
                .take(3)
                .toList();
            final suggested = ppRecommendedCommunities()
                .where((c) => c.topics.any(post.topics.contains))
                .take(3)
                .toList();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ppBack(context, 'Post'),
                ),
                const SizedBox(height: 8),
                PpCommunityPostCard(post: post, detailed: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Text('Replies', style: ppJakarta(17)),
                ),
                if (seed.isEmpty && mine.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text('Be the first to reply - a kind word helps.',
                        style: ppBody(13.5, color: ppMuted)),
                  ),
                for (final c in seed) _comment(c.author, c.text),
                for (final c in mine)
                  _comment(
                      store.doctorMode ? kPpDoctorName : 'You', c,
                      expert: store.doctorMode),
                // reply composer
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: ppHair)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _commentCtrl,
                          minLines: 1,
                          maxLines: 4,
                          style: ppBody(14, color: ppInk),
                          decoration: InputDecoration(
                            filled: false,
                            isDense: true,
                            hintText: store.doctorMode
                                ? 'Reply as a verified doctor...'
                                : 'Add a reply...',
                            hintStyle: ppBody(14, color: ppMuted),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: ppPurple, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_upward_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ]),
                ),
                if (related.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text('Related discussions', style: ppJakarta(17)),
                  ),
                  for (final p in related)
                    GestureDetector(
                      onTap: () => ppPush(context, PpPostDetailScreen(post: p)),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(children: [
                          const Icon(Icons.mode_comment_outlined,
                              size: 18, color: ppMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(p.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ppBody(13.5, color: ppInk, h: 1.4)),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: ppMuted),
                        ]),
                      ),
                    ),
                ],
                if (suggested.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Text('Rooms you might like', style: ppJakarta(17)),
                  ),
                  for (final c in suggested)
                    GestureDetector(
                      onTap: () =>
                          ppPush(context, PpCommunityDetailScreen(community: c)),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: ppPurple.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(ppMono(c.name),
                                style: ppJakarta(14, color: ppPurple)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ppBody(14,
                                          color: ppInk, w: FontWeight.w700)),
                                  Text('${ppMembers(c.members)} members',
                                      style: ppBody(11.5, color: ppMuted)),
                                ]),
                          ),
                          GestureDetector(
                            onTap: () => store.toggleJoin(c.id),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color:
                                    store.isJoined(c.id) ? Colors.white : ppPurple,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: store.isJoined(c.id)
                                        ? ppBorder
                                        : ppPurple),
                              ),
                              child: Text(store.isJoined(c.id) ? 'Joined' : 'Join',
                                  style: ppBody(12.5,
                                      color: store.isJoined(c.id)
                                          ? ppPurple
                                          : Colors.white,
                                      w: FontWeight.w800)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _comment(String author, String text, {bool expert = false}) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: expert ? ppPurple : ppPanel, shape: BoxShape.circle),
            child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?',
                style: ppJakarta(13, color: expert ? Colors.white : ppPurple)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ppHair)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                      ),
                      if (expert) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 13, color: ppPurple),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(text, style: ppBody(13.5, color: ppInk, h: 1.5)),
                  ]),
            ),
          ),
        ]),
      );
}
