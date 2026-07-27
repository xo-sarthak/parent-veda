// =============================================================================
//  Deriving a father's week from the mother's week
// -----------------------------------------------------------------------------
//  father_week.dart already states the rule:
//
//     "every Father week is authored from the matching Mother week
//      (lib/data/weekContent.json) so milestones never contradict"
//
//  That was a rule an author had to remember. This makes it something the code
//  does, which matters because the failure mode is silent: a father reading
//  about an anomaly scan at week 34 sees nothing obviously wrong, and neither
//  does anyone reviewing it.
//
//  THREE OF HIS FOUR SECTIONS ALREADY EXIST IN HER DATA. `partnerCorner` was
//  written for the father from the start — whatSheMayFeel, whatYouCanDo,
//  oneMission — for all 37 weeks, in both languages, and it is content that has
//  already been reviewed. Deriving from it is not a shortcut around writing;
//  it is refusing to write a second, drifting copy of reviewed medical content.
//
//  The fourth, `father_insight`, is the only one that is genuinely his rather
//  than a view onto hers, so it is the only one authored per week.
//
//  PRECEDENCE: anything the JSON supplies WINS. A hand-authored week (week 20
//  today, and every week once real copy arrives) overrides the derivation
//  section by section, so this degrades away as content lands rather than
//  having to be removed.
// =============================================================================

import '../localization/app_language.dart';
import 'father_week.dart';
import 'week_content.dart';

/// True when a section carries nothing worth rendering.
bool _isBlank(FatherWeekSection? s) =>
    s == null || (s.title.en.trim().isEmpty && s.title.hi.trim().isEmpty);

extension FatherWeekDerive on FatherWeek {
  /// Fill any blank section from [mother]. Authored sections are untouched.
  FatherWeek filledFrom(WeekContent? mother) {
    if (mother == null) return this;
    return FatherWeek(
      week: week,
      // Never derived. If nobody wrote it, it stays blank and the UI can say
      // so honestly rather than putting her words in his mouth.
      insight: insight,
      support: _isBlank(support) ? _support(mother) : support,
      connect: _isBlank(connect) ? _connect(mother) : connect,
      mission: _isBlank(mission) ? _mission(mother) : mission,
    );
  }

  /// "Supporting your partner" — what she may feel, and what he can do about
  /// it. Both already written per week in partnerCorner.
  static FatherWeekSection _support(WeekContent m) => FatherWeekSection(
        title: m.partner.whatSheMayFeel,
        body: m.partner.whatYouCanDo,
      );

  /// "Connecting with your baby" — the baby's own line for the week, plus the
  /// fun fact when there is one. Deliberately the SAME facts she is reading, so
  /// the two of them are never told different things about the same baby.
  static FatherWeekSection _connect(WeekContent m) => FatherWeekSection(
        title: m.development.whatImDoing,
        body: m.development.funFact,
      );

  /// "This week's mission" — partnerCorner.oneMission is exactly this, written
  /// for him, week by week.
  ///
  /// The share message rides along as the body when it exists: it is a line he
  /// can actually send her, which is the most concrete thing this screen can
  /// hand him.
  static FatherWeekSection _mission(WeekContent m) {
    final share = m.partner.shareMessage;
    final hasShare = share.en.trim().isNotEmpty || share.hi.trim().isNotEmpty;
    return FatherWeekSection(
      title: m.partner.oneMission,
      body: hasShare ? share : null,
    );
  }
}

/// Build a father's week entirely from the mother's, for a week with no
/// authored file at all. Only `insight` is left blank — see above.
FatherWeek fatherWeekFromMother(WeekContent mother) => FatherWeek(
      week: mother.week,
      insight: const FatherWeekSection(title: LocalizedText(en: '', hi: '')),
      support: FatherWeekDerive._support(mother),
      connect: FatherWeekDerive._connect(mother),
      mission: FatherWeekDerive._mission(mother),
    ).filledFrom(mother);
