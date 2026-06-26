// =============================================================================
//  ParentVeda Community — data models
// -----------------------------------------------------------------------------
//  A personalized parenting social layer (prototype): communities feed into one
//  algorithmic feed. Every post carries multi-dimensional metadata (community,
//  topics, stage) so the feed can be ranked and discovery can work. This is a
//  front-end prototype over seeded data + local persistence (no backend yet:
//  real ranking ML, moderation queue, live expert sessions and DMs are stubbed).
// =============================================================================

import 'package:flutter/foundation.dart';

/// Post content types (a subset of the spec's list, enough for the prototype).
enum PostType { question, experience, poll, photo, milestone, expert, parentVeda }

/// Community-pulse card kinds (the lightweight "you are not alone" layer).
enum PulseType { cohort, poll, trending, benchmark, expert }

@immutable
class Community {
  const Community({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.members,
    this.auto = false,
    this.topics = const [],
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final int members;

  /// Auto-joined for the user's stage (cohort / trimester / location).
  final bool auto;
  final List<String> topics;
}

@immutable
class CommunityComment {
  const CommunityComment({
    required this.author,
    required this.emoji,
    required this.text,
    this.likes = 0,
  });
  final String author;
  final String emoji;
  final String text;
  final int likes;
}

@immutable
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.author,
    required this.authorEmoji,
    required this.text,
    required this.type,
    this.topics = const [],
    this.stage = 'Pregnancy',
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.upvotes = 0,
    this.pollOptions = const [],
    this.image = '',
    this.imageUrls = const [],
    this.isUser = false,
    this.cred = '',
    this.endorsedBy = '',
    this.endorsedByCred = '',
    this.expertEndorseCount = 0,
    this.wantsVerification = false,
    this.preferredSpecialty = '',
    this.createdAt = 0,
  });

  final String id;
  final String communityId;
  final String author;
  final String authorEmoji;
  final String text;
  final PostType type;
  final List<String> topics;
  final String stage;
  final int likes;
  final int comments;
  final int saves;
  final int upvotes; // expert-post endorsements ("upvote", experts only)
  final List<String> pollOptions; // non-empty only for polls
  final String image; // emoji stand-in for a photo; '' otherwise
  final List<String> imageUrls; // real attached photo file paths (user posts)
  final bool isUser; // created by the user this session

  /// Author's professional credential (e.g. "IBCLC", "OB-GYN"). Non-empty marks
  /// this author as a verified expert — rendered with the gradient seal avatar.
  final String cred;

  /// A member experience that a verified expert has publicly backed. When set,
  /// the card shows the trust-building endorsement banner + highlighted styling.
  final String endorsedBy; // expert's name, '' if not endorsed
  final String endorsedByCred; // that expert's credential

  /// How many OTHER verified experts have also backed this — drives the
  /// "+ N other experts" credibility line (Facebook "liked by … and N others").
  final int expertEndorseCount;

  /// The author asked for an expert to review/confirm this post. Only such posts
  /// surface the "Verify this" button to experts (and an expert "Needs
  /// verification" filter) — experts don't get a verify button on every post.
  final bool wantsVerification;

  /// When [wantsVerification], the specialty of doctor the author prefers (e.g.
  /// 'gynae', 'pediatric', or 'all'). Curates which experts the request reaches.
  final String preferredSpecialty;

  /// Creation time (epoch ms) for user-made posts — newest float to the top.
  /// 0 for seed posts (which have no real timestamp).
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'communityId': communityId,
        'author': author,
        'authorEmoji': authorEmoji,
        'text': text,
        'type': type.name,
        'topics': topics,
        'stage': stage,
        'likes': likes,
        'comments': comments,
        'saves': saves,
        'upvotes': upvotes,
        'pollOptions': pollOptions,
        'image': image,
        'imageUrls': imageUrls,
        'isUser': isUser,
        'cred': cred,
        'endorsedBy': endorsedBy,
        'endorsedByCred': endorsedByCred,
        'expertEndorseCount': expertEndorseCount,
        'wantsVerification': wantsVerification,
        'preferredSpecialty': preferredSpecialty,
        'createdAt': createdAt,
      };

  factory CommunityPost.fromJson(Map<String, dynamic> j) => CommunityPost(
        id: j['id'] as String,
        communityId: j['communityId'] as String? ?? '',
        author: j['author'] as String? ?? '',
        authorEmoji: j['authorEmoji'] as String? ?? '🙂',
        text: j['text'] as String? ?? '',
        type: PostType.values.firstWhere((t) => t.name == j['type'],
            orElse: () => PostType.experience),
        topics: (j['topics'] as List?)?.cast<String>() ?? const [],
        stage: j['stage'] as String? ?? 'Pregnancy',
        likes: j['likes'] as int? ?? 0,
        comments: j['comments'] as int? ?? 0,
        saves: j['saves'] as int? ?? 0,
        upvotes: j['upvotes'] as int? ?? 0,
        pollOptions: (j['pollOptions'] as List?)?.cast<String>() ?? const [],
        image: j['image'] as String? ?? '',
        imageUrls: (j['imageUrls'] as List?)?.cast<String>() ?? const [],
        isUser: j['isUser'] as bool? ?? false,
        cred: j['cred'] as String? ?? '',
        endorsedBy: j['endorsedBy'] as String? ?? '',
        endorsedByCred: j['endorsedByCred'] as String? ?? '',
        expertEndorseCount: j['expertEndorseCount'] as int? ?? 0,
        wantsVerification: j['wantsVerification'] as bool? ?? false,
        preferredSpecialty: j['preferredSpecialty'] as String? ?? '',
        createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
      );
}

@immutable
class PulseCard {
  const PulseCard({
    required this.type,
    required this.title,
    required this.body,
    this.options = const [],
    this.linkPostId,
  });
  final PulseType type;
  final String title;
  final String body;
  final List<String> options; // poll options for PulseType.poll
  final String? linkPostId; // for trending → opens a post
}
