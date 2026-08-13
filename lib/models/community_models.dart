// =============================================================================
//  ParentVeda Community - data models
// -----------------------------------------------------------------------------
//  A personalized parenting social layer (prototype): communities feed into one
//  algorithmic feed. Every post carries multi-dimensional metadata (community,
//  topics, stage) so the feed can be ranked and discovery can work. This is a
//  front-end prototype over seeded data + local persistence (no backend yet:
//  real ranking ML, moderation queue, live expert sessions and DMs are stubbed).
// =============================================================================

import 'package:flutter/foundation.dart';
import '../localization/app_language.dart';

/// Post content types (a subset of the spec's list, enough for the prototype).
enum PostType { question, experience, poll, photo, milestone, expert, parentVeda }

/// Community-pulse card kinds (the lightweight "you are not alone" layer).
enum PulseType { cohort, poll, trending, benchmark, expert }

// ---------------------------------------------------------------------------
//  TOPICS — one vocabulary, keyed by the ENGLISH name
// ---------------------------------------------------------------------------
//  A topic tag does three jobs at once: it is drawn as a chip, it is compared
//  against other posts' tags to find related reading, and it is searched. Once
//  the chip is bilingual those jobs stop agreeing, so they are split the way
//  BACKEND-PATTERNS §13 splits any widened field:
//
//    identity  ->  `.en`   never changes, so matching and persistence survive
//                          a language toggle and need no data migration
//    display   ->  `.now`  may change per language, and only ever reaches a
//                          Text() widget
//
//  The English half is the identity because every topic already persisted IS
//  an English name: `inferTopics()` produces the keys of `_topicKeywords`, and
//  those rows are already in prefs and in Supabase. Choosing `.en` makes the
//  reader migrate itself (see `CommunityPost._topicFromJson`).
//
//  This table lives beside the field it types rather than in community_data.dart
//  so `CommunityPost.fromJson` can reach it without a models -> data import
//  cycle. The English keys are IDs, not copy — never translate a key.
const Map<String, LocalizedText> kTopicNames = {
  // --- Pregnancy ---
  'Pregnancy Symptoms':
      LocalizedText(en: 'Pregnancy Symptoms', hi: 'गर्भावस्था के लक्षण'),
  'Labor': LocalizedText(en: 'Labor', hi: 'लेबर'),
  'Nutrition': LocalizedText(en: 'Nutrition', hi: 'खानपान'),
  'Brain Development':
      LocalizedText(en: 'Brain Development', hi: 'दिमाग़ का विकास'),
  'Breastfeeding': LocalizedText(en: 'Breastfeeding', hi: 'स्तनपान'),
  // 'fitness' stays Latin: prepare_data.dart already treats it as a word she
  // meets in English, and the Hindi would be an invention nobody says.
  'Pregnancy Fitness':
      LocalizedText(en: 'Pregnancy Fitness', hi: 'गर्भावस्था में fitness'),
  'Vaccination': LocalizedText(en: 'Vaccination', hi: 'टीकाकरण'),
  'Sleep': LocalizedText(en: 'Sleep', hi: 'नींद'),

  // --- Trying to conceive ---
  'Cycles': LocalizedText(en: 'Cycles', hi: 'मासिक चक्र'),
  'Emotional': LocalizedText(en: 'Emotional', hi: 'भावनाएँ'),
  // Identical by nature - acronyms and a term she reads off a report, not a
  // translation we owe. The same judgement kSeedPosts makes with _same().
  'PCOS': LocalizedText(en: 'PCOS', hi: 'PCOS'),
  'Endometriosis': LocalizedText(en: 'Endometriosis', hi: 'Endometriosis'),
  'IVF': LocalizedText(en: 'IVF', hi: 'IVF'),
  'IUI': LocalizedText(en: 'IUI', hi: 'IUI'),
  'Male fertility': LocalizedText(en: 'Male fertility', hi: 'पुरुष fertility'),
  'Loss': LocalizedText(en: 'Loss', hi: 'खोना'),
  'Partner': LocalizedText(en: 'Partner', hi: 'साथी'),
  'Medical': LocalizedText(en: 'Medical', hi: 'डॉक्टरी सलाह'),

  // --- Parenting ---
  'Feeding': LocalizedText(en: 'Feeding', hi: 'दूध-खाना'),
  'Milestones': LocalizedText(en: 'Milestones', hi: 'पड़ाव'),
  'Behaviour': LocalizedText(en: 'Behaviour', hi: 'बर्ताव'),
  'Health': LocalizedText(en: 'Health', hi: 'सेहत'),
  'Development': LocalizedText(en: 'Development', hi: 'विकास'),
};

/// The bilingual name for a topic id.
///
/// An id we have no Hindi for comes back English on both sides rather than
/// being dropped: a post must never lose a tag because the vocabulary is
/// behind. That is a runtime fallback, not authored copy — the house rule
/// against `_t(x, x)` is about pretending a translation is finished, and
/// nothing counts this pair.
LocalizedText topicNamed(String id) =>
    kTopicNames[id] ?? LocalizedText(en: id, hi: id);

/// A topic's IDENTITY as a hashtag — English, spaces removed.
///
/// [HashtagFeedScreen] matches this against `#tags` typed into post bodies and
/// against other posts' topics, so it must not move when the language does.
String topicTagId(LocalizedText topic) => topic.en.replaceAll(' ', '');

/// A topic as she READS it, without the leading '#'.
///
/// English keeps the run-together hashtag convention (`PregnancySymptoms`) —
/// a reader parses the capitals. Devanagari has no capitals to parse, so
/// `गर्भावस्थाकेलक्षण` is simply unreadable and the spaces stay. Same value,
/// two scripts, two typographic rules — exactly the per-language text surgery
/// BACKEND-PATTERNS §13 warns a widening drags in.
String topicTagLabel(LocalizedText topic, AppLanguage lang) =>
    lang.isEnglish ? topicTagId(topic) : topic.hi;

/// Does [t] contain [lowerQuery] in EITHER language?
///
/// Both halves, always. Searching only `.now` makes the box silently narrower
/// in one language than the other, and the mismatch is invisible: she reads in
/// Hindi, types the English word she saw on a bottle, and gets nothing. Same
/// rule `prepare_data.filterPrograms` already follows.
///
/// Deliberately general and deliberately local: it says nothing about topics,
/// so it also serves a room's `name`. It lives here rather than beside
/// LocalizedText because community is the only caller today - move it up the
/// moment a second feature wants it.
bool localizedMatches(LocalizedText t, String lowerQuery) =>
    t.en.toLowerCase().contains(lowerQuery) ||
    t.hi.toLowerCase().contains(lowerQuery);

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
  final LocalizedText name;
  final String emoji;
  final LocalizedText description;
  final int members;

  /// Auto-joined for the user's stage (cohort / trimester / location).
  final bool auto;

  /// Topic tags. Never serialised (a room is a static definition), but still
  /// compared by `.en` so a room and a post agree on what "Nutrition" is.
  final List<LocalizedText> topics;
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

  /// Topic tags — bilingual for display, matched and persisted on `.en`.
  /// See the kTopicNames note above; `text` deliberately stays a plain String,
  /// because a post she wrote has no second language and never will.
  final List<LocalizedText> topics;
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
  /// this author as a verified expert - rendered with the gradient seal avatar.
  final String cred;

  /// A member experience that a verified expert has publicly backed. When set,
  /// the card shows the trust-building endorsement banner + highlighted styling.
  final String endorsedBy; // expert's name, '' if not endorsed
  final String endorsedByCred; // that expert's credential

  /// How many OTHER verified experts have also backed this - drives the
  /// "+ N other experts" credibility line (Facebook "liked by … and N others").
  final int expertEndorseCount;

  /// The author asked for an expert to review/confirm this post. Only such posts
  /// surface the "Verify this" button to experts (and an expert "Needs
  /// verification" filter) - experts don't get a verify button on every post.
  final bool wantsVerification;

  /// When [wantsVerification], the specialty of doctor the author prefers (e.g.
  /// 'gynae', 'pediatric', or 'all'). Curates which experts the request reaches.
  final String preferredSpecialty;

  /// Creation time (epoch ms) for user-made posts - newest float to the top.
  /// 0 for seed posts (which have no real timestamp).
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'communityId': communityId,
        'author': author,
        'authorEmoji': authorEmoji,
        'text': text,
        'type': type.name,
        // BOTH halves, never the rendered one. A store that resolved a
        // language here would write whichever script happened to be on screen
        // at save time and throw the other away — permanently, and differently
        // per row. That is BACKEND-PATTERNS §13 "the codec that silently kept
        // one language", already learned twice.
        'topics': [
          for (final t in topics) {'en': t.en, 'hi': t.hi}
        ],
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

  /// Reads one topic out of a row, tolerating both shapes of the schema.
  ///
  /// A row written by an older build holds a bare English string, because
  /// `inferTopics()` produced exactly a `kTopicNames` key. So the old value IS
  /// the new field's lookup key, and the migration is a `??` in [topicNamed]:
  /// nothing to backfill, no version column, and the row gains its Hindi half
  /// the first time it is read. A row an even older build never tagged at all
  /// comes back empty rather than throwing — a post must survive its metadata.
  static LocalizedText _topicFromJson(Object? v) =>
      v is Map ? LocalizedText.fromJson(v) : topicNamed(v?.toString() ?? '');

  factory CommunityPost.fromJson(Map<String, dynamic> j) => CommunityPost(
        id: j['id'] as String,
        communityId: j['communityId'] as String? ?? '',
        author: j['author'] as String? ?? '',
        authorEmoji: j['authorEmoji'] as String? ?? '🙂',
        text: j['text'] as String? ?? '',
        type: PostType.values.firstWhere((t) => t.name == j['type'],
            orElse: () => PostType.experience),
        topics: ((j['topics'] as List?) ?? const [])
            .map(_topicFromJson)
            .toList(),
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
  final LocalizedText title;
  final LocalizedText body;

  /// Poll options for [PulseType.poll]. AUTHORED seed copy — there is no
  /// user-creation path for a pulse card, so widening these carries none of
  /// the risk `CommunityPost.pollOptions` would (that one is still a plain
  /// String, and a vote is stored under the option's text).
  ///
  /// Rendering reads `.now`; the vote itself must be filed under `.en`, or the
  /// same answer is recorded twice under two names.
  final List<LocalizedText> options;
  final String? linkPostId; // for trending → opens a post
}
