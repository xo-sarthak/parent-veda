// =============================================================================
//  HomeDay model (Daily Moment content, bilingual)
// -----------------------------------------------------------------------------
//  Parses lib/data/homeDailyContent.json - the daily Home Screen content. Each
//  day is a self-contained "Daily Moment": Grow, Read To Your Baby, Talk To Your
//  Baby, Garbh Sanskar, A Moment For You (Nurture), and (Week 28+) Baby Movement.
//  Every text leaf is a {en, hi} LocalizedText, mirroring WeekContent.
//
//  Prototype scope: a single representative day for week 20. The schema is built
//  to scale to all 280 days (4–40) without change.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _loc(Object? v) => LocalizedText.fromJson(v);

String _s(Object? v, [String d = '']) => v == null ? d : v.toString();
int _i(Object? v, [int d = 0]) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? d;
bool _b(Object? v, [bool d = false]) => v is bool ? v : d;

// ---------------------------------------------------------------------------
//  1 · Grow - parenting wisdom
// ---------------------------------------------------------------------------

@immutable
class GrowContent {
  const GrowContent({
    required this.title,
    required this.insight,
    required this.expanded,
    required this.deepDive,
    required this.remember,
  });

  /// Short headline ("Children Borrow Calm From Adults").
  final LocalizedText title;

  /// Card-layer insight (3–5 seconds).
  final LocalizedText insight;

  /// Expanded insight shown behind "Read More" (30–60 seconds).
  final LocalizedText expanded;

  /// Optional deep dive (research / expert notes). May be empty.
  final LocalizedText? deepDive;

  /// One memorable line.
  final LocalizedText remember;

  factory GrowContent.fromJson(Map? j) {
    j ??= {};
    return GrowContent(
      title: _loc(j['title']),
      insight: _loc(j['insight']),
      expanded: _loc(j['expanded']),
      deepDive: j['deepDive'] == null ? null : _loc(j['deepDive']),
      remember: _loc(j['remember']),
    );
  }
}

// ---------------------------------------------------------------------------
//  2 · Read To Your Baby - story + bonding
// ---------------------------------------------------------------------------

@immutable
class ReadStory {
  const ReadStory({
    required this.title,
    required this.summary,
    required this.body,
    required this.audioAvailable,
  });

  final LocalizedText title;
  final LocalizedText summary;

  /// Full story text for the "Read" view (paragraphs separated by \n\n).
  final LocalizedText body;

  /// Whether a "Listen" affordance is offered (placeholder TTS for now).
  final bool audioAvailable;

  factory ReadStory.fromJson(Map? j) {
    j ??= {};
    return ReadStory(
      title: _loc(j['title']),
      summary: _loc(j['summary']),
      body: _loc(j['body']),
      audioAvailable: _b(j['audioAvailable'], true),
    );
  }
}

// ---------------------------------------------------------------------------
//  3 · Talk To Your Baby - memory creation
// ---------------------------------------------------------------------------

@immutable
class TalkPrompt {
  const TalkPrompt({required this.title, required this.motivation});

  /// The conversation prompt ("Tell your baby about your favourite memory.").
  final LocalizedText title;

  /// The gentle "why" beneath it.
  final LocalizedText motivation;

  factory TalkPrompt.fromJson(Map? j) {
    j ??= {};
    return TalkPrompt(
      title: _loc(j['title']),
      motivation: _loc(j['motivation']),
    );
  }
}

// ---------------------------------------------------------------------------
//  4 · Garbh Sanskar - spiritual / emotional ritual
// ---------------------------------------------------------------------------

enum GarbhType { raga, meditation, affirmation }

GarbhType _garbhType(Object? v) {
  switch (_s(v).toLowerCase()) {
    case 'meditation':
      return GarbhType.meditation;
    case 'affirmation':
      return GarbhType.affirmation;
    default:
      return GarbhType.raga;
  }
}

@immutable
class GarbhSanskarDaily {
  const GarbhSanskarDaily({
    required this.type,
    required this.title,
    required this.durationMinutes,
    required this.description,
    required this.affirmation,
    required this.introduction,
    required this.closingThought,
    required this.about,
    required this.howToUse,
  });

  final GarbhType type;

  /// Raga / meditation name, or short affirmation title.
  final LocalizedText title;

  /// 0 for affirmation-only days.
  final int durationMinutes;

  /// One-line mood / purpose ("Evening raga for peace").
  final LocalizedText description;

  /// The day's affirmation line (shown on every type).
  final LocalizedText affirmation;

  /// Meditation lead-in (meditation type only; otherwise empty).
  final LocalizedText introduction;

  /// Meditation closing thought (meditation type only; otherwise empty).
  final LocalizedText closingThought;

  /// "What is this & why it matters" - for the little "i" info sheet.
  final LocalizedText about;

  /// "How to use it during pregnancy" - for the "i" info sheet.
  final LocalizedText howToUse;

  bool get hasTimedAudio =>
      type == GarbhType.raga || type == GarbhType.meditation;

  factory GarbhSanskarDaily.fromJson(Map? j) {
    j ??= {};
    return GarbhSanskarDaily(
      type: _garbhType(j['type']),
      title: _loc(j['title']),
      durationMinutes: _i(j['durationMinutes']),
      description: _loc(j['description']),
      affirmation: _loc(j['affirmation']),
      introduction: _loc(j['introduction']),
      closingThought: _loc(j['closingThought']),
      about: _loc(j['about']),
      howToUse: _loc(j['howToUse']),
    );
  }
}

// ---------------------------------------------------------------------------
//  5 · A Moment For You (Nurture) - mother self-care
// ---------------------------------------------------------------------------

enum NurtureType { affirm, breathe, food }

NurtureType _nurtureType(Object? v) {
  switch (_s(v).toLowerCase()) {
    case 'breathe':
      return NurtureType.breathe;
    case 'food':
      return NurtureType.food;
    default:
      return NurtureType.affirm;
  }
}

@immutable
class NurtureContent {
  const NurtureContent({
    required this.type,
    required this.title,
    required this.content,
    required this.remember,
    required this.durationMinutes,
  });

  final NurtureType type;
  final LocalizedText title;
  final LocalizedText content;
  final LocalizedText remember;

  /// Only meaningful for breathe items; 0 otherwise.
  final int durationMinutes;

  factory NurtureContent.fromJson(Map? j) {
    j ??= {};
    return NurtureContent(
      type: _nurtureType(j['type']),
      title: _loc(j['title']),
      content: _loc(j['content']),
      remember: _loc(j['remember']),
      durationMinutes: _i(j['durationMinutes']),
    );
  }
}

// ---------------------------------------------------------------------------
//  Day
// ---------------------------------------------------------------------------

@immutable
class HomeDay {
  const HomeDay({
    required this.day,
    required this.week,
    required this.babyLearning,
    required this.grow,
    required this.story,
    required this.talk,
    required this.garbhSanskar,
    required this.nurture,
  });

  /// Day of pregnancy (1–280).
  final int day;

  /// Gestational week this day belongs to.
  final int week;

  /// Short "learning to…" phrase for the header callout.
  final LocalizedText babyLearning;

  final GrowContent grow;
  final ReadStory story;
  final TalkPrompt talk;
  final GarbhSanskarDaily garbhSanskar;
  final NurtureContent nurture;

  /// Baby Movement Check-In is shown only from week 28 onward.
  bool get showsMovementCheckIn => week >= 28;

  factory HomeDay.fromJson(Map<String, dynamic> j) {
    return HomeDay(
      day: _i(j['day']),
      week: _i(j['week']),
      babyLearning: _loc(j['babyLearning']),
      grow: GrowContent.fromJson(j['grow'] as Map?),
      story: ReadStory.fromJson(j['readToBaby'] as Map?),
      talk: TalkPrompt.fromJson(j['talkToBaby'] as Map?),
      garbhSanskar: GarbhSanskarDaily.fromJson(j['garbhSanskar'] as Map?),
      nurture: NurtureContent.fromJson(j['nurture'] as Map?),
    );
  }
}
