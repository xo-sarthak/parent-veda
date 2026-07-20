// =============================================================================
//  CommunityScreen - Community (parenting app)
// -----------------------------------------------------------------------------
//  A FAITHFUL parenting replica of the pre-birth Community: the SAME structure
//  and functioning - "Your communities" + "Recommended communities" cards, a
//  For-you / Following segmented pill, openable rooms -> detail, X/Twitter-style
//  post cards (polls + photos + like/comment/repost/save/share), post detail
//  with comments + related + suggested, a full composer (post types / photo /
//  mic / request-verification), doctor test-mode + "needs verification" triage +
//  endorse-by-commenting, my activity, my bookmarks and a search delegate.
//
//  It reuses the shared social layer (CommunityStore + community_models) exactly
//  as the pregnancy screen does; only the CONTENT differs (parenting rooms +
//  posts, read from kParenting*). The pregnancy feed is left completely untouched
//  because every list here is computed from the parenting data + the store's
//  per-id state. English-only (hardcoded) to avoid the localization dependency;
//  pp-themed, monogram/icon avatars (no emojis).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/community_data.dart';
import '../../models/community_models.dart';
import '../../services/community_store.dart';
import '../../services/expert_follow_store.dart';
import '../../brand/sponsored_community_campaign.dart';
import 'pp_common.dart';
import 'pp_community_activity_screen.dart';
import 'pp_community_detail_screen.dart';
import 'pp_create_post_screen.dart';
import 'pp_post_detail_screen.dart';
import 'pp_section_extras.dart';

// The identity used while testing "Doctor mode" for the parenting side (until
// real doctor logins exist). Display-only - the store's endorsement bookkeeping
// is keyed by post id, not by this name, so it doesn't touch shared behaviour.
const String kPpDoctorName = 'Dr. (You)';
const String kPpDoctorCred = 'Paediatrician';

// Auto-join the parenting stage communities once per app session (module flag).
bool _seededParentingAutos = false;

const List<List<Color>> _ppBadgeGradients = [
  [ppPurple, Color(0xFF9B5DE0)],
  [Color(0xFF7A45C6), Color(0xFFB07BE6)],
  [Color(0xFF5C2AA6), Color(0xFF8E5AD6)],
];

void ppPush(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => w));

void ppToast(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(
      content: Text(m),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1400)));

// ===========================================================================
//  Parenting data queries. The shared CommunityStore's OWN list getters read
//  the pregnancy seed (kCommunities / kSeedPosts); these compute the same
//  shapes from the PARENTING seed + user posts, so the two feeds never mix.
// ===========================================================================

CommunityStore get _store => CommunityStore.instance;

/// All parenting posts: user-created (this stage) first, then seed.
List<CommunityPost> ppAllPosts() => [
      ..._store.createdPosts.where((p) => p.stage == 'Parenting'),
      ...kParentingPosts,
    ];

CommunityPost? ppPostById(String id) {
  for (final p in ppAllPosts()) {
    if (p.id == id) return p;
  }
  return null;
}

/// The parenting feed - algorithmic (not chronological): user posts pinned,
/// then joined communities, ordered by base engagement (stable under taps).
List<CommunityPost> ppFeed() {
  final all = ppAllPosts().where((p) => !_store.isHidden(p.id)).toList();
  int score(CommunityPost p) {
    var sc = p.likes + p.comments * 2 + p.saves * 3;
    if (p.isUser) sc += 1000000;
    if (_store.isJoined(p.communityId)) sc += 5000;
    return sc;
  }

  all.sort((a, b) {
    final by = score(b).compareTo(score(a));
    return by != 0 ? by : b.createdAt.compareTo(a.createdAt);
  });
  return all;
}

List<CommunityPost> ppPostsForCommunity(String id) =>
    ppAllPosts().where((p) => p.communityId == id).toList();

List<Community> ppJoinedCommunities() => kParentingCommunities
    .where((c) => _store.isJoined(c.id) && !_store.isMuted(c.id))
    .toList();

List<Community> ppRecommendedCommunities() =>
    kParentingCommunities.where((c) => !_store.isJoined(c.id)).toList();

List<CommunityPost> ppSavedPosts() =>
    ppAllPosts().where((p) => _store.isSaved(p.id)).toList();
List<CommunityPost> ppLikedPosts() =>
    ppAllPosts().where((p) => _store.isLiked(p.id)).toList();
List<CommunityPost> ppUpvotedPosts() =>
    ppAllPosts().where((p) => _store.isUpvoted(p.id)).toList();
List<CommunityPost> ppCommentedPosts() =>
    ppAllPosts().where((p) => _store.userComments(p.id).isNotEmpty).toList();

List<CommunityComment> ppSeedComments(String postId) =>
    kParentingComments[postId] ?? const [];

/// A two-letter monogram, skipping leading numbers ("1 Year Olds" -> "YO").
String ppMono(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !RegExp(r'^[0-9]').hasMatch(w))
      .toList();
  if (words.isEmpty) return name.isNotEmpty ? name[0].toUpperCase() : '?';
  if (words.length == 1) {
    final w = words.first;
    return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

String ppHandle(String author) {
  var h = author.toLowerCase().replaceAll('dr.', '').replaceAll('dr ', '');
  h = h.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return h.isEmpty ? 'parent' : h;
}

String ppTimeAgo(CommunityPost post) {
  if (post.isUser) return 'now';
  final h = post.id.hashCode.abs() % 47;
  if (h == 0) return 'now';
  if (h < 24) return '${h}h';
  return '${(h / 24).ceil()}d';
}

String ppViews(CommunityPost post) {
  final v = post.likes * 241 + post.comments * 90 + 431;
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 100000 ? 0 : 1)}K';
  return '$v';
}

bool ppIsExpert(CommunityPost post) =>
    post.cred.isNotEmpty || post.type == PostType.expert;

String ppSpecialtyLabel(String code) {
  switch (code) {
    case 'pediatric':
      return 'Paediatrician';
    case 'lactation':
      return 'Lactation';
    case 'nutrition':
      return 'Nutrition';
    case 'sleep':
      return 'Sleep';
    case 'development':
      return 'Development';
    case 'mental':
      return 'Mental health';
    default:
      return 'Any expert';
  }
}

String ppTypeLabel(PostType t) {
  switch (t) {
    case PostType.question:
      return 'Question';
    case PostType.experience:
      return 'Experience';
    case PostType.poll:
      return 'Poll';
    case PostType.photo:
      return 'Photo';
    case PostType.milestone:
      return 'Milestone';
    case PostType.expert:
      return 'Expert';
    case PostType.parentVeda:
      return 'ParentVeda';
  }
}

void ppSharePost(CommunityPost post) =>
    Share.share('"${post.text}"\n\n- ${post.author} · via ParentVeda Community');

// ===========================================================================
//  Shared avatars + trust language
// ===========================================================================

Widget ppAuthorAvatar(CommunityPost post, {double size = 42}) {
  final initial = post.author.isNotEmpty ? post.author[0].toUpperCase() : '?';
  if (ppIsExpert(post)) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ppPurple, Color(0xFF9B5DE0)])),
          child: Text(initial, style: ppJakarta(size * 0.4, color: Colors.white)),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.42,
            height: size * 0.42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: ppBg)),
            child: Icon(Icons.verified_rounded,
                size: size * 0.33, color: ppPurple),
          ),
        ),
      ]),
    );
  }
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
    child: Text(initial, style: ppJakarta(size * 0.38, color: ppPurple)),
  );
}

Widget _ppSeal(String name, {double size = 34}) {
  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return SizedBox(
    width: size,
    height: size,
    child: Stack(clipBehavior: Clip.none, children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [ppPurple, Color(0xFF9B5DE0)])),
        child: Text(initial, style: ppJakarta(size * 0.44, color: Colors.white)),
      ),
      Positioned(
        right: -2,
        bottom: -2,
        child: Container(
          padding: const EdgeInsets.all(1),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.verified_rounded, size: size * 0.38, color: ppPurple),
        ),
      ),
    ]),
  );
}

/// Bottom sheet: the verified experts who've backed a post (builds trust).
void ppShowExpertsSheet(BuildContext context, int total) {
  final shown = kParentingExperts;
  final more = (total - shown.length).clamp(0, total);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: ppLine, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Row(children: [
            const Icon(Icons.verified_rounded, size: 20, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Experts who verified · $total', style: ppJakarta(16))),
          ]),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 10),
            children: [
              for (final e in shown)
                ListTile(
                  leading: _ppSeal(e.name, size: 38),
                  title: Text(e.name,
                      style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  subtitle: Text('${e.cred} · ${e.specialty}',
                      style: ppBody(12, color: ppMuted)),
                ),
              if (more > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Text('and $more more experts',
                      style: ppBody(12.5, color: ppMuted, w: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ]),
    ),
  );
}

/// A subtle "verified by an expert" hint. Taps (when other experts also backed
/// the post) open the "who verified" sheet.
Widget _ppVerifiedHint(BuildContext context, CommunityPost post) {
  final byDoctorOnly = post.endorsedBy.isEmpty;
  final name = byDoctorOnly ? kPpDoctorName : post.endorsedBy;
  final others = byDoctorOnly ? 0 : _store.endorseCount(post);
  final tappable = others > 0;
  return GestureDetector(
    onTap: tappable ? () => ppShowExpertsSheet(context, others) : null,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: ppPurple.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified_rounded, size: 13, color: ppPurple),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            tappable
                ? 'Verified by $name and $others more'
                : 'Verified by $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ppBody(11.5, color: ppPurple, w: FontWeight.w700),
          ),
        ),
        if (tappable)
          const Icon(Icons.chevron_right_rounded, size: 14, color: ppPurple),
      ]),
    ),
  );
}

/// The verification-requested tag. Members see "Awaiting [specialty]
/// verification"; a doctor sees "Comment to verify this post".
Widget _ppPendingVerifyTag(CommunityPost post, {bool doctor = false}) {
  final sp = (post.preferredSpecialty.isEmpty || post.preferredSpecialty == 'all')
      ? null
      : ppSpecialtyLabel(post.preferredSpecialty);
  final label = doctor
      ? 'Comment to verify this post'
      : (sp == null ? 'Awaiting verification' : 'Awaiting $sp verification');
  final icon =
      doctor ? Icons.rate_review_outlined : Icons.hourglass_bottom_rounded;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: ppPurple.withValues(alpha: doctor ? 0.08 : 0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ppPurple.withValues(alpha: 0.22)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: ppPurple),
      const SizedBox(width: 5),
      Flexible(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
      ),
    ]),
  );
}

/// The ⋯ menu on a post (Follow expert / Not interested / Mute / Report).
void ppShowPostMenu(BuildContext context, CommunityPost post) {
  final ef = ExpertFollowStore.instance;
  final expert = ppIsExpert(post);
  final handle = '@${ppHandle(post.author)}';
  void done(String m) {
    Navigator.of(context).pop();
    ppToast(context, m);
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
                color: ppLine, borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 8),
        if (expert)
          AnimatedBuilder(
            animation: ef,
            builder: (_, _) {
              final following = ef.isFollowing(post.author);
              return _ppMenuRow(
                ctx,
                following
                    ? Icons.person_remove_alt_1_outlined
                    : Icons.person_add_alt_1_outlined,
                '${following ? 'Unfollow' : 'Follow'} $handle',
                () {
                  ef.toggleFollow(post.author);
                  done(following ? 'Unfollowed $handle' : 'Following $handle');
                },
                pop: false,
              );
            },
          ),
        _ppMenuRow(ctx, Icons.do_not_disturb_on_outlined, 'Not interested',
            () => done('We\'ll show fewer like this'),
            pop: false, extra: () => _store.hidePost(post.id)),
        _ppMenuRow(
            ctx,
            Icons.notifications_off_outlined,
            'Mute this community',
            () => done('Muted'),
            pop: false,
            extra: () => _store.toggleMute(post.communityId)),
        _ppMenuRow(ctx, Icons.flag_outlined, 'Report',
            () => done('Thanks - our team will take a look'),
            pop: false),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

Widget _ppMenuRow(BuildContext ctx, IconData i, String label, VoidCallback onTap,
        {bool pop = true, VoidCallback? extra}) =>
    GestureDetector(
      onTap: () {
        if (pop) Navigator.of(ctx).pop();
        extra?.call();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(children: [
          Icon(i, size: 20, color: ppPurple),
          const SizedBox(width: 14),
          Text(label, style: ppBody(14.5, color: ppInk, w: FontWeight.w600)),
        ]),
      ),
    );

// ===========================================================================
//  Post card (feed + detail) - X/Twitter-style
// ===========================================================================

class PpCommunityPostCard extends StatelessWidget {
  const PpCommunityPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.detailed = false,
  });
  final CommunityPost post;
  final VoidCallback? onTap;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final community = parentingCommunityById(post.communityId);
    final endorsed = _store.isEndorsed(post);
    final liked = _store.isLiked(post.id);
    final saved = _store.isSaved(post.id);
    final reposted = _store.isReposted(post.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ppAuthorAvatar(post, size: 44),
            const SizedBox(width: 11),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Row(children: [
                      Flexible(
                        child: Text(post.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ppBody(14, color: ppInk, w: FontWeight.w800)),
                      ),
                      if (ppIsExpert(post)) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: ppPurple),
                      ],
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text('@${ppHandle(post.author)} · ${ppTimeAgo(post)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ppBody(12, color: ppMuted)),
                      ),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () => ppShowPostMenu(context, post),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 4),
                      child:
                          Icon(Icons.more_horiz_rounded, size: 18, color: ppMuted),
                    ),
                  ),
                ]),
                if (community != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text('in ${community.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ppBody(11.5, color: ppMuted)),
                  ),
                const SizedBox(height: 6),
                Text(post.text,
                    maxLines: detailed ? null : 7,
                    overflow: detailed
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: ppBody(14.5, color: ppInk, h: 1.5)),
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _PpPostPhotos(paths: post.imageUrls),
                ] else if (post.type == PostType.photo ||
                    post.image.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const PpStriped(height: 170, radius: 16, border: true),
                ],
                if (post.pollOptions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  PpPollBlock(post: post),
                ],
                if (post.topics.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    for (final t in post.topics)
                      Text('#${t.replaceAll(' ', '')}',
                          style: ppBody(12.5, color: ppPurple, w: FontWeight.w600)),
                  ]),
                ],
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PpEngage(
                          icon: Icons.mode_comment_outlined,
                          label: '${_store.commentCount(post)}',
                          color: ppSoft,
                          onTap: onTap ?? () {}),
                      _PpEngage(
                          icon: Icons.repeat_rounded,
                          label: '${_store.repostCount(post)}',
                          color: reposted ? ppPurple : ppSoft,
                          onTap: () {
                            _store.toggleRepost(post.id);
                            ppToast(
                                context,
                                _store.isReposted(post.id)
                                    ? 'Reposted'
                                    : 'Repost removed');
                          }),
                      _PpEngage(
                          icon: liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: '${_store.likeCount(post)}',
                          color: liked ? ppCoral : ppSoft,
                          onTap: () => _store.toggleLike(post.id)),
                      _PpEngage(
                          icon: Icons.bar_chart_rounded,
                          label: ppViews(post),
                          color: ppSoft,
                          onTap: onTap ?? () {}),
                      _PpEngage(
                          icon: saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          label: '',
                          color: saved ? ppPurple : ppSoft,
                          onTap: () => _store.toggleSave(post.id)),
                      _PpEngage(
                          icon: Icons.ios_share_rounded,
                          label: '',
                          color: ppSoft,
                          onTap: () => ppSharePost(post)),
                    ]),
                if (endorsed) ...[
                  const SizedBox(height: 8),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: _ppVerifiedHint(context, post)),
                ] else if (post.wantsVerification) ...[
                  const SizedBox(height: 8),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: _ppPendingVerifyTag(post,
                          doctor: _store.doctorMode)),
                ],
              ]),
            ),
          ]),
        ),
      ),
      const Divider(height: 1, thickness: 1, color: ppHair),
    ]);
  }
}

class _PpEngage extends StatelessWidget {
  const _PpEngage(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 17, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: ppBody(12, color: color, w: FontWeight.w600)),
            ],
          ]),
        ),
      );
}

class PpPollBlock extends StatelessWidget {
  const PpPollBlock({super.key, required this.post});
  final CommunityPost post;
  @override
  Widget build(BuildContext context) {
    final voted = _store.votedOption(post.id);
    const weights = [46, 34, 20];
    return Column(children: [
      for (int i = 0; i < post.pollOptions.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap:
                voted == null ? () => _store.vote(post.id, post.pollOptions[i]) : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(children: [
              Container(
                height: 42,
                decoration: BoxDecoration(
                    color: ppPanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: voted == post.pollOptions[i]
                            ? ppPurple
                            : Colors.transparent,
                        width: 1.4)),
              ),
              if (voted != null)
                FractionallySizedBox(
                  widthFactor: weights[i % weights.length] / 100,
                  child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                          color: ppPurple.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12))),
                ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(children: [
                    Expanded(
                        child: Text(post.pollOptions[i],
                            style: ppBody(13.5,
                                color: ppInk,
                                w: voted == post.pollOptions[i]
                                    ? FontWeight.w800
                                    : FontWeight.w600))),
                    if (voted != null)
                      Text('${weights[i % weights.length]}%',
                          style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
    ]);
  }
}

class _PpPostPhotos extends StatelessWidget {
  const _PpPostPhotos({required this.paths});
  final List<String> paths;

  Widget _broken(double? w, double h) => Container(
        width: w,
        height: h,
        color: ppPanel,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: ppMuted),
      );

  @override
  Widget build(BuildContext context) {
    if (paths.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(paths.first),
            height: 210,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _broken(null, 210)),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(File(paths[i]),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _broken(150, 150)),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Home
// ===========================================================================

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  CommunityStore get _s => CommunityStore.instance;
  final ExpertFollowStore _ef = ExpertFollowStore.instance;

  bool _following = false; // For you (false) vs Following (true)
  bool _needsVerifyOnly = false; // doctor-mode triage filter

  @override
  void initState() {
    super.initState();
    if (_seededParentingAutos) return;
    // Auto-join the default parenting rooms once, AFTER the first frame (a
    // toggleJoin() during initState would fire notifyListeners mid-build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _seededParentingAutos) return;
      _seededParentingAutos = true;
      for (final c in kParentingCommunities) {
        if (c.auto && !_s.isJoined(c.id)) _s.toggleJoin(c.id);
      }
    });
  }

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  void _openCompose() => ppPush(context, const PpCreatePostScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: Listenable.merge([_s, _ef]),
            builder: (context, _) {
              final joined = ppJoinedCommunities();
              final recommended = ppRecommendedCommunities();
              final feed = (_following
                      ? ppFeed().where((p) =>
                          _s.isJoined(p.communityId) || _ef.isFollowing(p.author))
                      : ppFeed())
                  .where((p) => !_needsVerifyOnly ||
                      (p.wantsVerification && !_s.isEndorsed(p)))
                  .toList();
              return ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 150),
                children: [
                  _utilityRow(),
                  _header(),
                  if (_s.doctorMode) ...[
                    const SizedBox(height: 12),
                    _pad(_doctorBanner()),
                  ],
                  // Your communities. Like Recommended below, this ALWAYS
                  // renders (header + either the list or a note): hiding it from
                  // someone who hasn't joined anything would hide the very idea
                  // that joining exists.
                  _label('Your communities'),
                  if (joined.isNotEmpty)
                    SizedBox(
                      height: 136,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: joined.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => _PpCommunityCard(
                          community: joined[i],
                          gradient:
                              _ppBadgeGradients[i % _ppBadgeGradients.length],
                          unread: ppPostsForCommunity(joined[i].id).length,
                          onTap: () => ppPush(context,
                              PpCommunityDetailScreen(community: joined[i])),
                          onLong: () => _communitySheet(joined[i]),
                        ),
                      ),
                    )
                  else
                    _ppEmptyNote(Icons.groups_outlined,
                        "You haven't joined any communities yet - pick one below and its posts land in your feed."),
                  // Recommended communities (always renders header + fallback)
                  _label('Recommended communities'),
                  if (recommended.isNotEmpty)
                    SizedBox(
                      height: 208,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: recommended.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => _PpRecommendedCard(
                          community: recommended[i],
                          joined: _s.isJoined(recommended[i].id),
                          onTap: () => ppPush(context,
                              PpCommunityDetailScreen(community: recommended[i])),
                          onJoin: () => _s.toggleJoin(recommended[i].id),
                        ),
                      ),
                    )
                  else
                    _ppEmptyNote(Icons.celebration_outlined,
                        "You've joined them all - your feed is fully personalised."),
                  // BRAND PRODUCT 11 - a sponsored community challenge, sitting
                  // between the communities and the feed. It renders NOTHING
                  // unless a campaign resolves for this parent, and the
                  // participation is the point: the brand funds it, is named
                  // for it, and never sees who took part.
                  const SizedBox(height: 18),
                  _pad(const SponsoredCommunityCampaign()),

                  _pad(_feedTabs()),
                  if (_s.doctorMode) _pad(_verifyFilterChip()),
                  const SizedBox(height: 6),
                  _pad(ppSectionDivider()),
                  if (feed.isEmpty && _needsVerifyOnly)
                    _emptyFeed(Icons.verified_outlined,
                        'No verification requests right now.')
                  else if (feed.isEmpty && _following)
                    _emptyFeed(Icons.group_outlined,
                        'Join a room or follow an expert to fill this feed.')
                  else
                    for (final p in feed)
                      PpCommunityPostCard(
                        key: ValueKey(p.id),
                        post: p,
                        onTap: () =>
                            ppPush(context, PpPostDetailScreen(post: p)),
                      ),
                  const SizedBox(height: 24),
                  _pad(_sponsored()),
                ],
              );
            },
          ),
        ),
        // soft top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 36,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [ppBg, Color(0x00FBF9FE)])),
            ),
          ),
        ),
        Positioned(right: 20, bottom: 168, child: _composeFab()),
        const PpAskVedaFab(bottom: 96),
        const Positioned(
            left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 3)),
      ]),
    );
  }

  // ---- header + utility ---------------------------------------------------
  Widget _utilityRow() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 10, 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(
            tooltip: 'Doctor mode (test)',
            visualDensity: VisualDensity.compact,
            color: _s.doctorMode ? ppPurple : ppInk,
            icon: Icon(
                _s.doctorMode
                    ? Icons.medical_services_rounded
                    : Icons.medical_services_outlined,
                size: 21),
            onPressed: () {
              _s.setDoctorMode(!_s.doctorMode);
              ppToast(
                  context,
                  _s.doctorMode
                      ? 'Doctor mode on - you can verify by replying'
                      : 'Doctor mode off');
            },
          ),
          IconButton(
            tooltip: 'My bookmarks',
            visualDensity: VisualDensity.compact,
            color: ppInk,
            icon: const Icon(Icons.bookmark_border_rounded, size: 22),
            onPressed: () => ppPush(context, const PpMyBookmarksScreen()),
          ),
          IconButton(
            tooltip: 'My activity',
            visualDensity: VisualDensity.compact,
            color: ppInk,
            icon: const Icon(Icons.person_outline_rounded, size: 22),
            onPressed: () => ppPush(context, const PpMyActivityScreen()),
          ),
          IconButton(
            tooltip: 'Search',
            visualDensity: VisualDensity.compact,
            color: ppInk,
            icon: const Icon(Icons.search_rounded, size: 22),
            onPressed: () =>
                showSearch<void>(context: context, delegate: _PpSearchDelegate()),
          ),
        ]),
      );

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Community', color: ppCoral),
          const SizedBox(height: 6),
          Text('Walking together.', style: ppFraunces(32, w: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Your rooms, already full - now for this stage.',
              style: ppBody(13.5, color: ppSoft)),
        ]),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Text(t, style: ppJakarta(17)),
      );

  // What a section shows INSTEAD of vanishing when it has nothing to list, so
  // the feature stays visible (and learnable) to someone who has never used it.
  Widget _ppEmptyNote(IconData icon, String text) => _pad(Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ppBorder)),
        child: Row(children: [
          Icon(icon, size: 20, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: ppBody(13, color: ppInk, h: 1.4))),
        ]),
      ));

  Widget _doctorBanner() => Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [ppPurple, Color(0xFF9B5DE0)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.medical_services_rounded,
              size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'Viewing as a verified doctor. Reply to a post that asked for verification to endorse it.',
                style: ppBody(12.5, color: Colors.white, w: FontWeight.w700, h: 1.3)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _s.setDoctorMode(false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Exit',
                  style: ppBody(12, color: Colors.white, w: FontWeight.w800)),
            ),
          ),
        ]),
      );

  Widget _feedTabs() {
    Widget chip(String label, bool active, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? ppPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                boxShadow: active
                    ? const [
                        BoxShadow(
                            color: Color(0x336A30B6),
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ]
                    : null,
              ),
              child: Text(label,
                  style: ppBody(13.5,
                      color: active ? Colors.white : ppSoft,
                      w: FontWeight.w700)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ppBorder),
      ),
      child: Row(children: [
        chip('For you', !_following, () => setState(() => _following = false)),
        chip('Following', _following, () => setState(() => _following = true)),
      ]),
    );
  }

  Widget _verifyFilterChip() => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () => setState(() => _needsVerifyOnly = !_needsVerifyOnly),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: _needsVerifyOnly
                    ? ppPurple
                    : ppPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: ppPurple.withValues(
                        alpha: _needsVerifyOnly ? 0 : 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    _needsVerifyOnly
                        ? Icons.verified_rounded
                        : Icons.verified_outlined,
                    size: 15,
                    color: _needsVerifyOnly ? Colors.white : ppPurple),
                const SizedBox(width: 6),
                Text('Needs verification',
                    style: ppBody(12.5,
                        color: _needsVerifyOnly ? Colors.white : ppPurple,
                        w: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      );

  Widget _emptyFeed(IconData icon, String msg) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
        child: Column(children: [
          Icon(icon, size: 40, color: ppPurple),
          const SizedBox(height: 12),
          Text(msg,
              textAlign: TextAlign.center,
              style: ppBody(14, color: ppSoft, w: FontWeight.w600, h: 1.4)),
        ]),
      );

  /// A sponsored community campaign, resolved through the Brand Studio.
  ///
  /// This used to be a hardcoded brand ("Nunu - breathable muslin swaddles")
  /// with hand-written "Sponsored" wording and no campaign, no targeting, no
  /// schedule and no disclosure standard — live brand content routed around
  /// BrandStudio.resolve(). That is precisely the drift the Studio exists to
  /// prevent, so it now goes through the front door like everything else and
  /// renders nothing at all when no campaign is live.
  Widget _sponsored() => const SponsoredCommunityCampaign();

  Widget _composeFab() => GestureDetector(
        onTap: _openCompose,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _s.doctorMode ? const Color(0xFF5C2AA6) : ppPurple,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                  color: Color(0x336A30B6), blurRadius: 18, offset: Offset(0, 8))
            ],
          ),
          child: Icon(
              _s.doctorMode
                  ? Icons.medical_services_rounded
                  : Icons.edit_outlined,
              size: 22,
              color: Colors.white),
        ),
      );

  void _communitySheet(Community c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: ppLine, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 8),
          _ppMenuRow(
              ctx,
              _s.isMuted(c.id)
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              _s.isMuted(c.id) ? 'Unmute' : 'Mute',
              () {},
              extra: () => _s.toggleMute(c.id)),
          _ppMenuRow(ctx, Icons.logout_rounded, 'Leave community', () {},
              extra: () => _s.toggleJoin(c.id)),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Community cards
// ===========================================================================

class _PpCommunityCard extends StatelessWidget {
  const _PpCommunityCard({
    required this.community,
    required this.gradient,
    required this.unread,
    required this.onTap,
    required this.onLong,
  });
  final Community community;
  final List<Color> gradient;
  final int unread;
  final VoidCallback onTap;
  final VoidCallback onLong;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLong,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ppBorder),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14512D77), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient),
                    borderRadius: BorderRadius.circular(14)),
                child: Text(ppMono(community.name),
                    style: ppJakarta(15, color: Colors.white)),
              ),
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
            ]),
            const Spacer(),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: ppPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$unread new',
                    style: ppBody(10.5, color: ppPurple, w: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 12),
          Text(community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ppBody(14.5, color: ppInk, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${ppMembers(community.members)} members',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ppBody(11.5, color: ppMuted)),
        ]),
      ),
    );
  }
}

class _PpRecommendedCard extends StatelessWidget {
  const _PpRecommendedCard({
    required this.community,
    required this.joined,
    required this.onTap,
    required this.onJoin,
  });
  final Community community;
  final bool joined;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 208,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ppBorder),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14512D77), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPurple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14)),
            child: Text(ppMono(community.name),
                style: ppJakarta(15, color: ppPurple)),
          ),
          const SizedBox(height: 10),
          Text(community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ppBody(14.5, color: ppInk, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${ppMembers(community.members)} members',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ppBody(11.5, color: ppMuted)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(community.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ppBody(12, color: ppSoft, h: 1.35)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onJoin,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: joined ? Colors.white : ppPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: joined ? ppBorder : ppPurple),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (joined) ...[
                  const Icon(Icons.check_rounded, size: 16, color: ppPurple),
                  const SizedBox(width: 6),
                ],
                Text(joined ? 'Joined' : 'Join',
                    style: ppBody(13,
                        color: joined ? ppPurple : Colors.white,
                        w: FontWeight.w800)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

String ppMembers(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
  return '$n';
}

// ===========================================================================
//  Search
// ===========================================================================

class _PpSearchDelegate extends SearchDelegate<void> {
  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        scaffoldBackgroundColor: ppBg,
        appBarTheme: const AppBarTheme(backgroundColor: ppBg, foregroundColor: ppInk),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const SizedBox.shrink();
    final comms = kParentingCommunities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    final posts = ppFeed()
        .where((p) =>
            p.text.toLowerCase().contains(q) ||
            p.author.toLowerCase().contains(q) ||
            p.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    return Container(
      color: ppBg,
      child: ListView(
        children: [
          for (final c in comms)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ppPurple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(ppMono(c.name),
                    style: ppJakarta(14, color: ppPurple)),
              ),
              title: Text(c.name, style: ppBody(14.5, color: ppInk, w: FontWeight.w700)),
              subtitle: Text('${ppMembers(c.members)} members',
                  style: ppBody(12, color: ppMuted)),
              onTap: () {
                close(context, null);
                ppPush(context, PpCommunityDetailScreen(community: c));
              },
            ),
          for (final p in posts)
            ListTile(
              leading: const Icon(Icons.mode_comment_outlined, color: ppMuted),
              title: Text(p.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ppBody(14, color: ppInk)),
              onTap: () {
                close(context, null);
                ppPush(context, PpPostDetailScreen(post: p));
              },
            ),
        ],
      ),
    );
  }
}
