// =============================================================================
//  FatherWeek model (Father Mode "Weekly Journey", bilingual)
// -----------------------------------------------------------------------------
//  The deeper, once-a-week fatherhood experience (Week 4–40, 37 weeks). It is
//  deliberately small — exactly FOUR sections, each a short line (+ optional
//  body): Father Insight, Supporting Your Partner, Connecting With Your Baby,
//  This Week's Mission. NOT pregnancy education.
//
//  SOURCE-OF-TRUTH RULE: every Father week is authored from the matching Mother
//  week (lib/data/weekContent.json) so milestones never contradict.
//
//  JSON per week (one object per file, lib/data/father/journey_week_NN.json):
//    { "week": 20,
//      "father_insight":       { "title": {en,hi}, "body": {en,hi}? },
//      "supporting_partner":   { ... },
//      "connecting_with_baby": { ... },
//      "mission":              { ... } }
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _loc(Object? v) => LocalizedText.fromJson(v);
int _i(Object? v, [int d = 0]) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? d;

/// One of the four weekly sections: a short content line, with an optional
/// second supporting line.
@immutable
class FatherWeekSection {
  const FatherWeekSection({required this.title, this.body});

  /// The section's main line (a sentence, e.g. "Both of you are becoming parents").
  final LocalizedText title;

  /// Optional supporting line.
  final LocalizedText? body;

  bool get hasBody => body != null && (body!.en.isNotEmpty || body!.hi.isNotEmpty);

  factory FatherWeekSection.fromJson(Map? j) {
    j ??= {};
    return FatherWeekSection(
      title: _loc(j['title']),
      body: j['body'] == null ? null : _loc(j['body']),
    );
  }
}

@immutable
class FatherWeek {
  const FatherWeek({
    required this.week,
    required this.insight,
    required this.support,
    required this.connect,
    required this.mission,
  });

  /// Gestational week (4–40).
  final int week;

  final FatherWeekSection insight; // Father Insight
  final FatherWeekSection support; // Supporting Your Partner
  final FatherWeekSection connect; // Connecting With Your Baby
  final FatherWeekSection mission; // This Week's Mission

  factory FatherWeek.fromJson(Map<String, dynamic> j) => FatherWeek(
        week: _i(j['week']),
        insight: FatherWeekSection.fromJson(j['father_insight'] as Map?),
        support: FatherWeekSection.fromJson(j['supporting_partner'] as Map?),
        connect: FatherWeekSection.fromJson(j['connecting_with_baby'] as Map?),
        mission: FatherWeekSection.fromJson(j['mission'] as Map?),
      );
}
