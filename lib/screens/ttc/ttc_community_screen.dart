// =============================================================================
//  TTC - Community
// -----------------------------------------------------------------------------
//  "Community remains calm. Never competitive. Never comparison driven."
//                                                       - TTC master, §2.10
//
//  Runs on the SHARED social layer, not a third community. `CommunityStore` is
//  keyed by id, so a room joined here stays joined after a positive test and a
//  post saved here is still saved two years later in the parenting feed - which
//  is the whole point of "one brain, two doors".
//
//      "If a capability already exists for another stage, extend it rather than
//       building a parallel one. Two of a thing is what makes an app feel like
//       two apps."                        - Product Reference, rule §12.1.3
//
//  Two things are deliberately different from the pregnancy feed:
//
//   * There is a **Loss & Recovery** room. A product that only holds hope is
//     not honest about this stage.
//   * There are **no like counts on the loss room's posts**... no. Counts stay,
//     because hiding them would be its own kind of statement. What changes is
//     that nothing here is ranked by popularity: rooms are ordered by what the
//     couple joined, and the feed is chronological within that.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/community_data.dart';
import '../../models/community_models.dart';
import '../../services/community_store.dart';
import 'ttc_care_circle_screen.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcCommunityScreen extends StatefulWidget {
  const TtcCommunityScreen({super.key});

  /// Exposed for the tests that assert the rooms this stage must carry.
  static List<Community> get rooms => kTtcCommunities;

  @override
  State<TtcCommunityScreen> createState() => _TtcCommunityScreenState();
}

class _TtcCommunityScreenState extends State<TtcCommunityScreen> {
  /// Null = everything. Otherwise a community id.
  String? _room;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([CommunityStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final store = CommunityStore.instance;

        final joined =
            kTtcCommunities.where((c) => store.isJoined(c.id)).toList();
        final rest =
            kTtcCommunities.where((c) => !store.isJoined(c.id)).toList();

        // Chronological within the selected room. Never ranked by popularity -
        // a feed that promotes the most-liked post in a fertility community
        // promotes whichever story is most dramatic.
        // Her own posts first, then the seeded ones. `createdPosts` is the
        // shared store's list across all three stages, so it is filtered to TTC
        // rooms here rather than kept in a second place.
        final mine = store.createdPosts
            .where((p) => kTtcCommunityIds.contains(p.communityId))
            .where((p) => _room == null || p.communityId == _room);
        final posts = [
          ...mine,
          ...kTtcPosts.where((p) => _room == null || p.communityId == _room),
        ];

        return TtcPage(
          tab: 4,
          header: const TtcHeader(),
          children: [
            ttcSectionTitle(t.communityTitle, eyebrow: t.tabCommunity),
            Text(t.communityBody, style: ttcBody(14, h: 1.6)),
            const SizedBox(height: 18),

            // The Care Circle lives here rather than in Tools: it is about
            // people, and it is the visible half of where every recommendation
            // in the product comes from.
            TtcCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const TtcCareCircleScreen(),
                settings: const RouteSettings(name: 'ttc/care_circle'),
              )),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: ttcPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.diversity_3_rounded,
                      size: 20, color: ttcPurple),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.careCircle, style: ttcJakarta(15.5)),
                        const SizedBox(height: 3),
                        Text(t.careCircleIntro,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ttcBody(12.5, h: 1.4)),
                      ]),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 17, color: ttcMuted),
              ]),
            ),
            const SizedBox(height: 22),

            // ---- rooms ----------------------------------------------------
            if (joined.isNotEmpty) ...[
              ttcSectionTitle(t.communityYourRooms),
              for (final c in joined) ...[
                _RoomCard(community: c, t: t, joined: true),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],

            ttcSectionTitle(
                joined.isEmpty ? t.communityRooms : t.communityMoreRooms),
            for (final c in rest) ...[
              _RoomCard(community: c, t: t, joined: false),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),

            // ---- the feed -------------------------------------------------
            ttcSectionTitle(t.communityFeed,
                trailing: GestureDetector(
                  onTap: () => writeTtcPost(context, room: _room),
                  behavior: HitTestBehavior.opaque,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.edit_outlined, size: 15, color: ttcPurple),
                    const SizedBox(width: 6),
                    Text(t.communityWrite,
                        style:
                            ttcBody(12, color: ttcPurple, w: FontWeight.w800)),
                  ]),
                )),
            _RoomFilter(
              selected: _room,
              t: t,
              onChanged: (id) => setState(() => _room = id),
            ),
            const SizedBox(height: 14),
            if (posts.isEmpty)
              TtcEmpty(
                icon: Icons.forum_outlined,
                title: t.communityEmptyTitle,
                body: t.communityEmptyBody,
              )
            else
              for (final p in posts) ...[
                _PostCard(post: p, t: t),
                const SizedBox(height: 11),
              ],
          ],
        );
      },
    );
  }
}

// ---- writing a post ---------------------------------------------------------
//  Goes through CommunityStore.addPost, the same call the pregnancy and
//  parenting feeds use, so a post written here lives in the one place all three
//  stages read from.
//
//  Anonymity is offered deliberately. This is the stage where people write
//  about a miscarriage, a diagnosis or a marriage under strain, and the seeded
//  Loss & Recovery post is signed "Anonymous" for exactly that reason. A feed
//  that forces a name on those posts simply does not get them.

Future<void> writeTtcPost(BuildContext context, {String? room}) async {
  final t = TtcS.current();
  final controller = TextEditingController();
  var target = room ?? kTtcCommunities.first.id;
  var anonymous = false;

  final posted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: ttcLine, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.communityWriteTitle, style: ttcJakarta(17)),
              ),
              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.communityPickRoom,
                    style: ttcBody(12, color: ttcMuted, w: FontWeight.w800)),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final c in kTtcCommunities)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setSheet(() => target = c.id),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 9),
                            decoration: BoxDecoration(
                              color: target == c.id ? ttcPurple : ttcPanel,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(c.name,
                                style: ttcBody(12,
                                    color: target == c.id
                                        ? Colors.white
                                        : ttcSoft,
                                    w: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 7,
                minLines: 4,
                style: ttcBody(14.5, color: ttcInk, h: 1.6),
                decoration: InputDecoration(
                  hintText: t.communityWriteHint,
                  hintStyle: ttcBody(14, color: ttcMuted),
                  filled: true,
                  fillColor: ttcBg,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ttcBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ttcBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ttcPurple, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: () => setSheet(() => anonymous = !anonymous),
                behavior: HitTestBehavior.opaque,
                child: Row(children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: anonymous ? ttcPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: anonymous ? ttcPurple : ttcBorder, width: 1.6),
                    ),
                    child: anonymous
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.communityAnonymous,
                              style: ttcBody(13,
                                  color: ttcInk, w: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(t.communityAnonymousNote,
                              style: ttcBody(11.5, h: 1.4)),
                        ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.journalCancel,
                          style:
                              ttcBody(14, color: ttcSoft, w: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: ttcPurple,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.communityPost,
                          style: ttcBody(14,
                              color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    ),
  );

  final text = controller.text.trim();
  controller.dispose();
  // An empty post is silently not saved - tapping Post on nothing is a change
  // of mind, not a mistake worth a message.
  if (posted != true || text.isEmpty) return;

  CommunityStore.instance.addPost(CommunityPost(
    id: 'ttcuser_${DateTime.now().microsecondsSinceEpoch}',
    communityId: target,
    author: anonymous ? 'Anonymous' : 'You',
    authorEmoji: '',
    text: text,
    // A question mark is the honest signal for which kind this is; everything
    // else is someone sharing what happened to them.
    type: text.endsWith('?') ? PostType.question : PostType.experience,
    stage: 'Trying',
    isUser: true,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  ));

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.communityPosted),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ---- a room -----------------------------------------------------------------

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.community,
    required this.t,
    required this.joined,
  });

  final Community community;
  final TtcS t;
  final bool joined;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        // Monogram, never an emoji - the TTC and parenting UIs agree on this.
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
          child: Text(community.name.characters.first.toUpperCase(),
              style: ttcJakarta(16, color: ttcPurple)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(community.name, style: ttcJakarta(14.5)),
            const SizedBox(height: 3),
            Text(community.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(12, h: 1.45)),
            const SizedBox(height: 5),
            Text(t.communityMembers(community.members),
                style: ttcBody(10.5, color: ttcMuted, w: FontWeight.w700)),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => CommunityStore.instance.toggleJoin(community.id),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: joined ? ttcPanel : ttcPurple,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(joined ? t.communityJoined : t.communityJoin,
                style: ttcBody(12,
                    color: joined ? ttcPurple : Colors.white,
                    w: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

// ---- the room filter --------------------------------------------------------

class _RoomFilter extends StatelessWidget {
  const _RoomFilter({
    required this.selected,
    required this.t,
    required this.onChanged,
  });

  final String? selected;
  final TtcS t;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String? id) {
      final on = selected == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => onChanged(id),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: on ? ttcPurple : ttcPanel,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(12,
                    color: on ? Colors.white : ttcSoft, w: FontWeight.w700)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(t.communityAll, null),
          for (final c in kTtcCommunities) chip(c.name, c.id),
        ],
      ),
    );
  }
}

// ---- a post -----------------------------------------------------------------

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.t});

  final CommunityPost post;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final room = kTtcCommunities.where((c) => c.id == post.communityId);
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
            child: Text(post.author.characters.first.toUpperCase(),
                style: ttcJakarta(14, color: ttcPurple)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(post.author,
                          overflow: TextOverflow.ellipsis,
                          style: ttcBody(13,
                              color: ttcInk, w: FontWeight.w800)),
                    ),
                    if (post.type == PostType.expert) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded,
                          size: 14, color: ttcPurple),
                    ],
                  ]),
                  if (post.cred.isNotEmpty)
                    Text(post.cred,
                        style: ttcBody(11, color: ttcMuted, w: FontWeight.w600))
                  else if (room.isNotEmpty)
                    Text(room.first.name,
                        style: ttcBody(11, color: ttcMuted, w: FontWeight.w600)),
                ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(post.text, style: ttcBody(13.5, color: ttcInk, h: 1.6)),

        if (post.type == PostType.poll) ...[
          const SizedBox(height: 12),
          for (final option in post.pollOptions) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(option,
                  style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w600)),
            ),
          ],
        ],

        const SizedBox(height: 14),
        ttcDivider(),
        const SizedBox(height: 11),
        Row(children: [
          _action(
            icon: store.isLiked(post.id)
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: '${store.likeCount(post)}',
            on: store.isLiked(post.id),
            onTap: () => store.toggleLike(post.id),
          ),
          const SizedBox(width: 20),
          _action(
            icon: Icons.mode_comment_outlined,
            label: '${store.commentCount(post)}',
            on: false,
            onTap: () => ttcSoon(context, t.communityComment),
          ),
          const Spacer(),
          _action(
            icon: store.isSaved(post.id)
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: '',
            on: store.isSaved(post.id),
            onTap: () => store.toggleSave(post.id),
          ),
        ]),
      ]),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required bool on,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: on ? ttcCoral : ttcMuted),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label,
                style: ttcBody(12,
                    color: on ? ttcCoral : ttcMuted, w: FontWeight.w700)),
          ],
        ]),
      );
}
