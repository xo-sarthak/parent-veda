// =============================================================================
//  FatherDay model (Father Mode "Daily Moment", bilingual)
// -----------------------------------------------------------------------------
//  Parses lib/data/father/fatherDailyContent.json — the Father Mode daily moment.
//  Father Mode is a fatherhood-transformation experience, NOT pregnancy
//  education, so each day carries exactly three modules:
//
//    1 · Learn         — a fatherhood lesson (3 layers: card → expanded → deep dive)
//    2 · Talk To Baby  — a bonding prompt (story / value / memory, never baby-talk)
//    3 · Mission       — one small, real-world action (1–10 minutes)
//
//  Every text leaf is a {en, hi} LocalizedText, mirroring HomeDay / WeekContent.
//  Prototype scope: a single representative day for week 20 (day 143). The schema
//  scales to all 280 days (weeks 4–40) without change.
//
//  SOURCE-OF-TRUTH RULE: every Father day is authored against the matching Mother
//  week so milestones never contradict (see the Father content spec).
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _loc(Object? v) => LocalizedText.fromJson(v);

int _i(Object? v, [int d = 0]) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? d;

// ---------------------------------------------------------------------------
//  1 · Learn — a fatherhood lesson
// ---------------------------------------------------------------------------

@immutable
class FatherLesson {
  const FatherLesson({
    required this.module,
    required this.title,
    required this.insight,
    required this.expanded,
    required this.deepDive,
    required this.remember,
  });

  /// Curriculum chapter this lesson belongs to, shown as the card eyebrow
  /// ("Becoming A Father", "Building The Bond", …). See the Learn curriculum.
  final LocalizedText module;

  /// Short headline ("Presence Over Provision").
  final LocalizedText title;

  /// Layer 1 — the daily card line (3–5 seconds).
  final LocalizedText insight;

  /// Layer 2 — expanded insight behind "Open" (30–60 seconds).
  final LocalizedText expanded;

  /// Layer 3 — optional deep dive (older-and-wiser perspective). May be empty.
  final LocalizedText? deepDive;

  /// One line worth carrying through the day.
  final LocalizedText remember;

  factory FatherLesson.fromJson(Map? j) {
    j ??= {};
    return FatherLesson(
      module: _loc(j['module']),
      title: _loc(j['title']),
      insight: _loc(j['insight']),
      expanded: _loc(j['expanded']),
      deepDive: j['deepDive'] == null ? null : _loc(j['deepDive']),
      remember: _loc(j['remember']),
    );
  }
}

// ---------------------------------------------------------------------------
//  2 · Talk To Your Baby — bonding before birth
// ---------------------------------------------------------------------------

@immutable
class FatherTalkPrompt {
  const FatherTalkPrompt({
    required this.title,
    required this.prompt,
    required this.motivation,
  });

  /// Short headline shown on the card ("Your Biggest Life Lesson").
  final LocalizedText title;

  /// The actual prompt ("Tell your baby about the one lesson that changed…").
  final LocalizedText prompt;

  /// The gentle "why" beneath it.
  final LocalizedText motivation;

  factory FatherTalkPrompt.fromJson(Map? j) {
    j ??= {};
    return FatherTalkPrompt(
      title: _loc(j['title']),
      prompt: _loc(j['prompt']),
      motivation: _loc(j['motivation']),
    );
  }
}

// ---------------------------------------------------------------------------
//  3 · Mission — turn intention into action
// ---------------------------------------------------------------------------

@immutable
class FatherMission {
  const FatherMission({
    required this.title,
    required this.action,
    required this.durationMinutes,
  });

  /// Short headline ("The Quiet Support").
  final LocalizedText title;

  /// The concrete action ("Bring her a glass of water without being asked.").
  final LocalizedText action;

  /// Rough effort in minutes (1–10); 0 if not applicable.
  final int durationMinutes;

  factory FatherMission.fromJson(Map? j) {
    j ??= {};
    return FatherMission(
      title: _loc(j['title']),
      action: _loc(j['action']),
      durationMinutes: _i(j['durationMinutes']),
    );
  }
}

// ---------------------------------------------------------------------------
//  Day
// ---------------------------------------------------------------------------

@immutable
class FatherDay {
  const FatherDay({
    required this.day,
    required this.week,
    required this.intro,
    required this.learn,
    required this.talk,
    required this.mission,
  });

  /// Day of pregnancy (1–280).
  final int day;

  /// Gestational week this day belongs to.
  final int week;

  /// One warm line under "Today's Moment" ("A moment to build the father you
  /// want to be.").
  final LocalizedText intro;

  final FatherLesson learn;
  final FatherTalkPrompt talk;
  final FatherMission mission;

  factory FatherDay.fromJson(Map<String, dynamic> j) {
    return FatherDay(
      day: _i(j['day']),
      week: _i(j['week']),
      intro: _loc(j['intro']),
      learn: FatherLesson.fromJson(j['learn'] as Map?),
      talk: FatherTalkPrompt.fromJson(j['talkToBaby'] as Map?),
      mission: FatherMission.fromJson(j['mission'] as Map?),
    );
  }
}
