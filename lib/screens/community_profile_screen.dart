// =============================================================================
//  CommunityProfileScreen — an X/Twitter-style author profile
// -----------------------------------------------------------------------------
//  Tapping a post's avatar/name opens this. Experts get a Follow button + bio +
//  stats; regular members get a simpler "Member" profile. Below the header, the
//  author's own posts are rendered with the shared CommunityPostCard.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/community_data.dart';
import '../localization/app_language.dart';
import '../models/community_models.dart';
import '../services/community_store.dart';
import '../services/expert_follow_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'community_screen.dart';

const Color _proInk = Color(0xFF2C1A45);
const Color _proPurple = Color(0xFF7C3AED);
const Color _proPurpleDeep = Color(0xFF6D28D9);

String _handleOf(String author) {
  var h = author.toLowerCase().replaceAll('dr.', '').replaceAll('dr ', '');
  h = h.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return h.isEmpty ? 'member' : h;
}

String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

class CommunityProfileScreen extends StatelessWidget {
  const CommunityProfileScreen(
      {super.key, required this.post, required this.controller});
  final CommunityPost post;
  final PregnancyController controller;

  bool get _isExpert => post.cred.isNotEmpty || post.type == PostType.expert;

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final author = post.author;
    final handle = _handleOf(author);
    final h = author.hashCode.abs();
    final followers = _isExpert ? (3200 + h % 46000) : (40 + h % 900);
    final followingN = 80 + h % 600;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        title: Text(author,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: _proInk)),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [CommunityStore.instance, ExpertFollowStore.instance]),
        builder: (context, _) {
          final store = CommunityStore.instance;
          final ef = ExpertFollowStore.instance;
          final posts = [...store.createdPosts, ...kSeedPosts]
              .where((p) => p.author == author)
              .toList();
          final following = ef.isFollowing(author);
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _avatar(72),
                            const Spacer(),
                            if (_isExpert)
                              _followButton(s, ef, author, following),
                          ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Flexible(
                          child: Text(author,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _proInk)),
                        ),
                        if (_isExpert) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded,
                              size: 18, color: _proPurple),
                        ],
                      ]),
                      Text('@$handle',
                          style: GoogleFonts.manrope(
                              fontSize: 13.5, color: AppTheme.neutral500)),
                      const SizedBox(height: 10),
                      if (_isExpert) ...[
                        if (post.cred.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _proPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(post.cred,
                                style: GoogleFonts.manrope(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: _proPurpleDeep)),
                          ),
                        const SizedBox(height: 8),
                        Text(s.cmExpertBio,
                            style: GoogleFonts.manrope(
                                fontSize: 13.5,
                                height: 1.45,
                                color: _proInk.withValues(alpha: 0.8))),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('🌸 ${s.cmMember}',
                              style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.neutral600)),
                        ),
                      const SizedBox(height: 14),
                      Row(children: [
                        _stat('${posts.length}', s.cmPostsCount),
                        const SizedBox(width: 20),
                        _stat(_fmt(followers), s.cmFollowers),
                        const SizedBox(width: 20),
                        _stat(_fmt(followingN), s.cmFollowingCount),
                      ]),
                    ]),
              ),
              const Divider(height: 1, color: Color(0x14512D77)),
              if (posts.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                  child: Center(
                    child: Text(s.cmNoPostsYet,
                        style: GoogleFonts.manrope(
                            fontSize: 13.5, color: AppTheme.neutral500)),
                  ),
                )
              else
                for (final p in posts)
                  CommunityPostCard(
                    post: p,
                    lang: lang,
                    controller: controller,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            PostDetailScreen(post: p, controller: controller))),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _avatar(double size) {
    final initial = post.author.isNotEmpty ? post.author[0].toUpperCase() : '?';
    if (_isExpert) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [_proPurple, Color(0xFFA855F7)]),
        ),
        child: Text(initial,
            style: GoogleFonts.fraunces(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: _proPurple.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: Text(initial,
          style: GoogleFonts.fraunces(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
              color: _proPurpleDeep)),
    );
  }

  Widget _followButton(
      S s, ExpertFollowStore ef, String author, bool following) {
    return GestureDetector(
      onTap: () => ef.toggleFollow(author),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: following ? Colors.transparent : _proPurple,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: following ? AppTheme.outlineVariant : _proPurple),
        ),
        child: Text(following ? s.cmFollowingState : s.cmFollow,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: following ? _proInk : Colors.white)),
      ),
    );
  }

  Widget _stat(String value, String label) => Row(children: [
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: _proInk)),
        const SizedBox(width: 4),
        Text(label,
            style:
                GoogleFonts.manrope(fontSize: 12.5, color: AppTheme.neutral500)),
      ]);
}
