// =============================================================================
//  PpMyActivityScreen + PpMyBookmarksScreen (parenting Community)
// -----------------------------------------------------------------------------
//  The parenting mirror of the pregnancy MyActivityScreen / MyBookmarksScreen:
//  "My activity" groups your posts, replies, likes and expert upvotes; "My
//  bookmarks" lists every post you saved. Both read the shared CommunityStore
//  through the parenting query helpers so the two feeds never mix.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/community_models.dart';
import '../../services/community_store.dart';
import 'community_screen.dart';
import 'pp_common.dart';
import 'pp_post_detail_screen.dart';

class PpMyActivityScreen extends StatelessWidget {
  const PpMyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final posts = store.createdPosts
                .where((p) => p.stage == 'Parenting')
                .toList();
            final commented = ppCommentedPosts();
            final liked = ppLikedPosts();
            final upvoted = ppUpvotedPosts();
            final empty = posts.isEmpty &&
                commented.isEmpty &&
                liked.isEmpty &&
                upvoted.isEmpty;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ppBack(context, 'Community'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('My activity', style: ppFraunces(28, w: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                if (empty)
                  _empty(Icons.forum_outlined,
                      'Your posts, replies and likes will gather here.')
                else ...[
                  _section(context, 'Your posts', posts),
                  _section(context, 'You replied to', commented),
                  _section(context, 'You liked', liked),
                  _section(context, 'You upvoted', upvoted),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<CommunityPost> list) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: Text(title, style: ppJakarta(17)),
      ),
      for (final p in list)
        PpCommunityPostCard(
          post: p,
          onTap: () => ppPush(context, PpPostDetailScreen(post: p)),
        ),
    ]);
  }
}

class PpMyBookmarksScreen extends StatelessWidget {
  const PpMyBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final saved = ppSavedPosts();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ppBack(context, 'Community'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Text('My bookmarks', style: ppFraunces(28, w: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                if (saved.isEmpty)
                  _empty(Icons.bookmark_border_rounded,
                      'Tap the bookmark on any post to save it for later.')
                else
                  for (final p in saved)
                    PpCommunityPostCard(
                      post: p,
                      onTap: () => ppPush(context, PpPostDetailScreen(post: p)),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _empty(IconData icon, String msg) => Padding(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
      child: Column(children: [
        Icon(icon, size: 48, color: ppMuted),
        const SizedBox(height: 16),
        Text(msg,
            textAlign: TextAlign.center,
            style: ppBody(14, color: ppSoft, h: 1.4)),
      ]),
    );
