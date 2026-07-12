// =============================================================================
//  PpCommunityDetailScreen - one parenting room (banner + composer + posts)
// -----------------------------------------------------------------------------
//  The parenting mirror of the pregnancy CommunityDetailScreen: a gradient
//  banner (monogram badge, name, members, description, Join/Joined), a composer
//  entry to write into this room, and the room's posts (each opening the post
//  detail). Reuses the shared CommunityStore + the parenting query helpers.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/community_models.dart';
import '../../services/community_store.dart';
import 'community_screen.dart';
import 'pp_common.dart';
import 'pp_create_post_screen.dart';
import 'pp_post_detail_screen.dart';

class PpCommunityDetailScreen extends StatelessWidget {
  const PpCommunityDetailScreen({super.key, required this.community});
  final Community community;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final gradient = [ppPurple, const Color(0xFF9B5DE0)];
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final posts = ppPostsForCommunity(community.id);
            final joined = store.isJoined(community.id);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ppBack(context, 'Community'),
                ),
                const SizedBox(height: 14),
                // banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ppPurple.withValues(alpha: 0.12),
                          Colors.white
                        ]),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: ppBorder),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradient),
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(ppMono(community.name),
                              style: ppJakarta(19, color: Colors.white)),
                        ),
                        const SizedBox(height: 14),
                        Text(community.name, style: ppFraunces(26, w: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${ppMembers(community.members)} members',
                            style: ppBody(12.5, color: ppMuted)),
                        const SizedBox(height: 10),
                        Text(community.description,
                            style: ppBody(14, color: ppInk, h: 1.5)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => store.toggleJoin(community.id),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: joined ? Colors.white : ppPurple,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: joined ? ppBorder : ppPurple),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (joined) ...[
                                    const Icon(Icons.check_rounded,
                                        size: 17, color: ppPurple),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(joined ? 'Joined' : 'Join community',
                                      style: ppBody(14,
                                          color: joined ? ppPurple : Colors.white,
                                          w: FontWeight.w800)),
                                ]),
                          ),
                        ),
                      ]),
                ),
                const SizedBox(height: 14),
                // composer entry
                if (joined)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => ppPush(
                          context,
                          PpCreatePostScreen(
                              initialCommunityId: community.id)),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ppBorder)),
                        child: Row(children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: ppPanel, shape: BoxShape.circle),
                            child: Text('Y', style: ppJakarta(13, color: ppPurple)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Share something with this room...',
                                style: ppBody(13.5, color: ppMuted)),
                          ),
                          const Icon(Icons.photo_camera_outlined,
                              size: 21, color: ppPurple),
                        ]),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                  child: Text('Posts', style: ppJakarta(17)),
                ),
                if (posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Text(
                        joined
                            ? 'No posts yet - be the first to start a conversation here.'
                            : 'Join to see and add posts in this room.',
                        textAlign: TextAlign.center,
                        style: ppBody(13.5, color: ppMuted, h: 1.4)),
                  )
                else
                  for (final p in posts)
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
