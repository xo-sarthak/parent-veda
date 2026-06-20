// =============================================================================
//  ParentVeda Community (Tools tab) — prototype
// -----------------------------------------------------------------------------
//  A personalized parenting social layer over seeded data: a stories-style row
//  of joined communities, recommended communities, a Community Pulse strip, and
//  one algorithmic feed. Tapping a post opens a YouTube-style detail with
//  comments + related discussions + suggested communities (retention loops).
//  Pregnancy-adapted; no gender communities.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/community_data.dart';
import '../localization/app_language.dart';
import '../models/community_models.dart';
import '../services/community_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';

const Color _accent = AppTheme.primary500;
const Color _like = AppTheme.secondary500;

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

({IconData icon, Color color, String key}) _typeVisual(PostType t) {
  switch (t) {
    case PostType.question:
      return (icon: Icons.help_outline_rounded, color: _accent, key: 'question');
    case PostType.experience:
      return (icon: Icons.favorite_border_rounded, color: _like, key: 'experience');
    case PostType.poll:
      return (icon: Icons.bar_chart_rounded, color: const Color(0xFF18A39B), key: 'poll');
    case PostType.photo:
      return (icon: Icons.photo_camera_outlined, color: const Color(0xFF3B82C4), key: 'photo');
    case PostType.milestone:
      return (icon: Icons.celebration_outlined, color: const Color(0xFFE6A817), key: 'milestone');
    case PostType.expert:
      return (icon: Icons.verified_rounded, color: const Color(0xFF7A4FC2), key: 'expert');
    case PostType.parentVeda:
      return (icon: Icons.auto_awesome_rounded, color: _accent, key: 'parentVeda');
  }
}

// ===========================================================================
//  Home
// ===========================================================================

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key, required this.controller});
  final PregnancyController controller;

  Future<void> _search(BuildContext context, AppLanguage lang) async {
    await showSearch<void>(
      context: context,
      delegate: _CommunitySearchDelegate(lang, controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        title: Text(s.cmTitle,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _search(context, lang),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        onPressed: () => _push(context, CreatePostScreen(controller: controller)),
        icon: const Icon(Icons.edit_rounded),
        label: Text(s.cmCreatePost),
      ),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final joined = store.joinedCommunities;
          final recommended = store.recommendedCommunities;
          final feed = store.feed();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              // Joined communities (stories style)
              if (joined.isNotEmpty) ...[
                _sectionTitle(context, s.cmJoinedSection),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: joined.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => _StoryCircle(
                      community: joined[i],
                      hasActivity: store.postsForCommunity(joined[i].id).isNotEmpty,
                      onTap: () => _push(context,
                          CommunityDetailScreen(community: joined[i], controller: controller)),
                      onLong: () => _communitySheet(context, joined[i], s, joined: true),
                    ),
                  ),
                ),
              ],
              // Recommended
              if (recommended.isNotEmpty) ...[
                _sectionTitle(context, s.cmRecommended),
                SizedBox(
                  height: 178,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: recommended.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _RecommendedCard(
                      community: recommended[i],
                      lang: lang,
                      onTap: () => _push(context,
                          CommunityDetailScreen(community: recommended[i], controller: controller)),
                      onJoin: () => store.toggleJoin(recommended[i].id),
                    ),
                  ),
                ),
              ],
              // Pulse
              _sectionTitle(context, s.cmPulse),
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.86),
                  itemCount: kPulse.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 6, 0),
                    child: _PulseCardView(card: kPulse[i], lang: lang, controller: controller),
                  ),
                ),
              ),
              // Feed
              _sectionTitle(context, s.cmFeed),
              for (final p in feed)
                _PostCard(
                  post: p,
                  lang: lang,
                  onTap: () => _push(context, PostDetailScreen(post: p, controller: controller)),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    );

void _communitySheet(BuildContext context, Community c, S s, {required bool joined}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) {
      final store = CommunityStore.instance;
      return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(store.isMuted(c.id)
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded),
            title: Text(store.isMuted(c.id) ? s.cmUnmute : s.cmMute),
            onTap: () {
              store.toggleMute(c.id);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(s.cmLeave),
            onTap: () {
              store.toggleJoin(c.id);
              Navigator.of(context).pop();
            },
          ),
        ]),
      );
    },
  );
}

// --- story circle ---
class _StoryCircle extends StatelessWidget {
  const _StoryCircle({
    required this.community,
    required this.hasActivity,
    required this.onTap,
    required this.onLong,
  });
  final Community community;
  final bool hasActivity;
  final VoidCallback onTap;
  final VoidCallback onLong;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLong,
      child: SizedBox(
        width: 70,
        child: Column(children: [
          Stack(children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: hasActivity
                      ? [_accent, _like]
                      : [AppTheme.outlineVariant, AppTheme.outlineVariant],
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Text(community.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            if (hasActivity)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: _like,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.scaffoldBackground, width: 2),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          Text(community.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(height: 1.1)),
        ]),
      ),
    );
  }
}

// --- recommended card ---
class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({
    required this.community,
    required this.lang,
    required this.onTap,
    required this.onJoin,
  });
  final Community community;
  final AppLanguage lang;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(community.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(community.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 2),
          Text(s.cmMembers(community.members),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onJoin,
              child: Text(s.cmJoin, style: text.labelMedium?.copyWith(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

// --- pulse card ---
class _PulseCardView extends StatelessWidget {
  const _PulseCardView({required this.card, required this.lang, required this.controller});
  final PulseCard card;
  final AppLanguage lang;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withValues(alpha: 0.12), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.title.toUpperCase(),
            style: text.labelSmall?.copyWith(
                color: _accent, letterSpacing: 0.8, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Expanded(
          child: Text(card.body,
              style: text.titleMedium?.copyWith(height: 1.3, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        _pulseAction(context, s),
      ]),
    );
  }

  Widget _pulseAction(BuildContext context, S s) {
    final store = CommunityStore.instance;
    final text = Theme.of(context).textTheme;
    switch (card.type) {
      case PulseType.poll:
        final voted = store.votedOption(kPulseKicksPollId);
        if (voted != null) {
          return Text('${s.cmVoted} · $voted',
              style: text.labelMedium?.copyWith(color: AppTheme.neutral600));
        }
        return Wrap(
          spacing: 8,
          children: [
            for (final o in card.options)
              GestureDetector(
                onTap: () => store.vote(kPulseKicksPollId, o),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(o,
                      style: text.labelMedium?.copyWith(
                          color: _accent, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        );
      case PulseType.trending:
        return GestureDetector(
          onTap: () {
            final p = store.postById(card.linkPostId ?? '');
            if (p != null) _push(context, PostDetailScreen(post: p, controller: controller));
          },
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.cmViewDiscussion,
                style: text.labelMedium?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
            const Icon(Icons.chevron_right_rounded, size: 18, color: _accent),
          ]),
        );
      case PulseType.expert:
        return GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.cmComingSoon))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.notifications_active_rounded, size: 16, color: _accent),
            const SizedBox(width: 6),
            Text(s.cmRemindMe,
                style: text.labelMedium?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
          ]),
        );
      case PulseType.cohort:
      case PulseType.benchmark:
        return const SizedBox.shrink();
    }
  }
}

// ===========================================================================
//  Post card (feed + detail)
// ===========================================================================

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.lang,
    this.onTap,
    this.detailed = false,
  });
  final CommunityPost post;
  final AppLanguage lang;
  final VoidCallback? onTap;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final store = CommunityStore.instance;
    final community = communityById(post.communityId);
    final tv = _typeVisual(post.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // author row
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _accent.withValues(alpha: 0.12),
              child: Text(post.authorEmoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(post.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  if (post.type == PostType.expert || post.type == PostType.parentVeda) ...[
                    const SizedBox(width: 6),
                    Icon(tv.icon, size: 15, color: tv.color),
                  ],
                ]),
                if (community != null)
                  Text('${community.emoji} ${community.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tv.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s.cmPostType(tv.key),
                  style: text.labelSmall?.copyWith(color: tv.color, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          // body
          Text(post.text,
              maxLines: detailed ? null : 4,
              overflow: detailed ? TextOverflow.visible : TextOverflow.ellipsis,
              style: text.bodyLarge?.copyWith(height: 1.45)),
          if (post.image.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(post.image, style: const TextStyle(fontSize: 56)),
            ),
          ],
          if (post.pollOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PollBlock(post: post, lang: lang),
          ],
          if (post.topics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in post.topics)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('#$t',
                        style: text.labelSmall?.copyWith(color: AppTheme.neutral600)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          // actions
          Row(children: [
            _ActionButton(
              icon: store.isLiked(post.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: store.isLiked(post.id) ? _like : AppTheme.neutral500,
              label: '${store.likeCount(post)}',
              onTap: () => store.toggleLike(post.id),
            ),
            _ActionButton(
              icon: Icons.mode_comment_outlined,
              color: AppTheme.neutral500,
              label: '${store.commentCount(post)}',
              onTap: onTap ?? () {},
            ),
            _ActionButton(
              icon: store.isSaved(post.id)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: store.isSaved(post.id) ? _accent : AppTheme.neutral500,
              label: '${store.saveCount(post)}',
              onTap: () => store.toggleSave(post.id),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label, style: text.labelMedium?.copyWith(color: AppTheme.neutral600)),
        ]),
      ),
    );
  }
}

class _PollBlock extends StatelessWidget {
  const _PollBlock({required this.post, required this.lang});
  final CommunityPost post;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final store = CommunityStore.instance;
    final voted = store.votedOption(post.id);
    return Column(
      children: [
        for (final o in post.pollOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: voted == null ? () => store.vote(post.id, o) : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: voted == o
                      ? _accent.withValues(alpha: 0.14)
                      : AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voted == o ? _accent : Colors.transparent,
                    width: 1.4,
                  ),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(o,
                        style: text.bodyMedium?.copyWith(
                            fontWeight: voted == o ? FontWeight.w800 : FontWeight.w500)),
                  ),
                  if (voted == o) const Icon(Icons.check_circle_rounded, size: 18, color: _accent),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

// ===========================================================================
//  Community detail
// ===========================================================================

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key, required this.community, required this.controller});
  final Community community;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(community.name)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final posts = store.postsForCommunity(community.id);
          final joined = store.isJoined(community.id);
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              // banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent.withValues(alpha: 0.16), AppTheme.surface],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _accent.withValues(alpha: 0.18)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(community.emoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 10),
                  Text(community.name,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(s.cmMembers(community.members),
                      style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
                  const SizedBox(height: 10),
                  Text(community.description,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.45)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: joined ? AppTheme.surfaceContainerHigh : _accent,
                        foregroundColor: joined ? AppTheme.neutral700 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => store.toggleJoin(community.id),
                      child: Text(joined ? s.cmJoinedBadge : s.cmJoin),
                    ),
                  ),
                ]),
              ),
              _sectionTitle(context, s.cmPosts),
              if (posts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(s.cmEmptyComments,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
                )
              else
                for (final p in posts)
                  _PostCard(
                    post: p,
                    lang: lang,
                    onTap: () => _push(context, PostDetailScreen(post: p, controller: controller)),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
//  Post detail (YouTube-style: post + comments + related + suggested)
// ===========================================================================

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post, required this.controller});
  final CommunityPost post;
  final PregnancyController controller;
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
    final lang = widget.controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final post = widget.post;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.cmTitle)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final seed = seedCommentsFor(post.id);
          final mine = store.userComments(post.id);
          // related: other posts sharing a topic
          final related = store
              .feed()
              .where((p) => p.id != post.id && p.topics.any(post.topics.contains))
              .take(3)
              .toList();
          // suggested: recommended communities sharing a topic
          final suggested = store.recommendedCommunities
              .where((c) => c.topics.any(post.topics.contains))
              .take(3)
              .toList();
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            children: [
              _PostCard(post: post, lang: lang, detailed: true),
              _sectionTitle(context, s.cmComments),
              if (seed.isEmpty && mine.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                  child: Text(s.cmEmptyComments,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
                ),
              for (final c in seed) _commentTile(context, c.emoji, c.author, c.text),
              for (final c in mine)
                _commentTile(context, '🙂', widget.controller.motherName, c),
              // add comment
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: s.cmAddComment,
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: _accent),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _send,
                  ),
                ]),
              ),
              if (related.isNotEmpty) ...[
                _sectionTitle(context, s.cmRelated),
                for (final p in related)
                  ListTile(
                    leading: Text(communityById(p.communityId)?.emoji ?? '💬',
                        style: const TextStyle(fontSize: 22)),
                    title: Text(p.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _push(context,
                        PostDetailScreen(post: p, controller: widget.controller)),
                  ),
              ],
              if (suggested.isNotEmpty) ...[
                _sectionTitle(context, s.cmSuggested),
                for (final c in suggested)
                  ListTile(
                    leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                    title: Text(c.name, style: text.titleSmall),
                    subtitle: Text(s.cmMembers(c.members),
                        style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                    trailing: TextButton(
                      onPressed: () => store.toggleJoin(c.id),
                      child: Text(store.isJoined(c.id) ? s.cmJoinedBadge : s.cmJoin),
                    ),
                    onTap: () => _push(context,
                        CommunityDetailScreen(community: c, controller: widget.controller)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Widget _commentTile(BuildContext context, String emoji, String author, String text) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: _accent.withValues(alpha: 0.12),
        child: Text(emoji, style: const TextStyle(fontSize: 15)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(author, style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(text, style: t.bodyMedium?.copyWith(height: 1.4)),
          ]),
        ),
      ),
    ]),
  );
}

// ===========================================================================
//  Create post
// ===========================================================================

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textCtrl = TextEditingController();
  String? _communityId;
  PostType _type = PostType.question;

  @override
  void initState() {
    super.initState();
    final joined = CommunityStore.instance.joinedCommunities;
    if (joined.isNotEmpty) _communityId = joined.first.id;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _share(S s) {
    final t = _textCtrl.text.trim();
    if (t.isEmpty || _communityId == null) return;
    final post = CommunityPost(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      communityId: _communityId!,
      author: widget.controller.motherName,
      authorEmoji: '🙂',
      text: t,
      type: _type,
      isUser: true,
    );
    CommunityStore.instance.addPost(post);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.cmPosted)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final joined = CommunityStore.instance.joinedCommunities;
    const types = [
      PostType.question,
      PostType.experience,
      PostType.milestone,
      PostType.photo,
    ];
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.cmCreatePost),
        actions: [
          TextButton(
            onPressed: () => _share(s),
            child: Text(s.cmShare,
                style: text.labelLarge?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(s.cmPostTo, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in joined)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: _communityId == c.id,
                  onSelected: (_) => setState(() => _communityId = c.id),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(s.cmTypeLabel,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in types)
                ChoiceChip(
                  label: Text(s.cmPostType(_typeVisual(t).key)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _textCtrl,
            minLines: 5,
            maxLines: 12,
            autofocus: true,
            decoration: InputDecoration(
              hintText: s.cmShareSomething,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _CommunitySearchDelegate extends SearchDelegate<void> {
  _CommunitySearchDelegate(this.lang, this.controller);
  final AppLanguage lang;
  final PregnancyController controller;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
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
    final text = Theme.of(context).textTheme;
    if (q.isEmpty) return const SizedBox.shrink();
    final comms = kCommunities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    final posts = CommunityStore.instance
        .feed()
        .where((p) =>
            p.text.toLowerCase().contains(q) ||
            p.author.toLowerCase().contains(q) ||
            p.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    return ListView(
      children: [
        for (final c in comms)
          ListTile(
            leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
            title: Text(c.name),
            subtitle: Text(S(lang).cmMembers(c.members),
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            onTap: () {
              close(context, null);
              _push(context, CommunityDetailScreen(community: c, controller: controller));
            },
          ),
        for (final p in posts)
          ListTile(
            leading: const Icon(Icons.mode_comment_outlined),
            title: Text(p.text, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              close(context, null);
              _push(context, PostDetailScreen(post: p, controller: controller));
            },
          ),
      ],
    );
  }
}
