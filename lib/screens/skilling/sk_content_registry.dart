// =============================================================================
//  The skilling content registry — every door's content, by bracket id
// -----------------------------------------------------------------------------
//  The parenting `pp_section_registry.dart` idea: one list, one lookup, so
//  the router and the wiring tests walk every door without knowing their
//  names. A door's content is one `SkDoorContent` assembled here from its
//  four data files (`lib/data/skilling/skilling_<door>_*.dart`), which is
//  where the brief's file names land.
// =============================================================================

import '../../data/skilling/skilling_coding_activities.dart';
import '../../data/skilling/skilling_coding_content.dart';
import '../../data/skilling/skilling_coding_course.dart';
import '../../data/skilling/skilling_coding_products.dart';
import '../../data/skilling/skilling_communication_activities.dart';
import '../../data/skilling/skilling_communication_content.dart';
import '../../data/skilling/skilling_communication_course.dart';
import '../../data/skilling/skilling_communication_products.dart';
import '../../data/skilling/skilling_confidence_activities.dart';
import '../../data/skilling/skilling_confidence_content.dart';
import '../../data/skilling/skilling_confidence_course.dart';
import '../../data/skilling/skilling_confidence_products.dart';
import '../../data/skilling/skilling_feelings_activities.dart';
import '../../data/skilling/skilling_feelings_content.dart';
import '../../data/skilling/skilling_feelings_course.dart';
import '../../data/skilling/skilling_feelings_products.dart';
import '../../data/skilling/skilling_making_activities.dart';
import '../../data/skilling/skilling_making_content.dart';
import '../../data/skilling/skilling_making_course.dart';
import '../../data/skilling/skilling_making_products.dart';
import '../../data/skilling/skilling_stillness_activities.dart';
import '../../data/skilling/skilling_stillness_content.dart';
import '../../data/skilling/skilling_stillness_course.dart';
import '../../data/skilling/skilling_stillness_products.dart';
import '../../data/skilling/skilling_thinking_activities.dart';
import '../../data/skilling/skilling_thinking_content.dart';
import '../../data/skilling/skilling_thinking_course.dart';
import '../../data/skilling/skilling_thinking_products.dart';
import 'sk_door_content.dart';

final SkDoorContent kSkCodingContent = SkDoorContent(
  doorId: 'skilling_coding',
  bandNames: kSkCodingBandNames,
  skills: kSkCodingSkills,
  lessonSets: kSkCodingLessonSets,
  lessons: kSkCodingLessons,
  activities: kSkCodingActivities,
  courses: kSkCodingCourses,
  products: kSkCodingProducts,
  parentNote: kSkCodingParentNote,
  crossBandSetId: 'ai',
  access: kSkCodingAccess,
);

final SkDoorContent kSkCommunicationContent = SkDoorContent(
  doorId: 'skilling_communication',
  bandNames: kSkCommunicationBandNames,
  skills: kSkCommunicationSkills,
  lessonSets: kSkCommunicationLessonSets,
  lessons: kSkCommunicationLessons,
  activities: kSkCommunicationActivities,
  courses: kSkCommunicationCourses,
  products: kSkCommunicationProducts,
  parentNote: kSkCommunicationParentNote,
  boundaryNote: kSkCommunicationBoundaryNote,
  voiceKeepsake: true,
);

final SkDoorContent kSkConfidenceContent = SkDoorContent(
  doorId: 'skilling_confidence',
  bandNames: kSkConfidenceBandNames,
  skills: kSkConfidenceSkills,
  lessonSets: kSkConfidenceLessonSets,
  lessons: kSkConfidenceLessons,
  activities: kSkConfidenceActivities,
  courses: kSkConfidenceCourses,
  products: kSkConfidenceProducts,
  parentNote: kSkConfidenceParentNote,
  boundaryNote: kSkConfidenceBoundaryNote,
  voiceKeepsake: true,
  voiceSelfReview: true,
  voiceTitle: 'Your talks, saved',
  voiceBlurb: 'The turns {name} stood up and took, and what {she} tried. It '
      'all stays on this phone; nobody marks it.',
  voiceEmptyLine: 'Say one line to the room, or give a whole talk. Tap Record '
      'something and it lands here, just for you.',
  coach: kSkConfidenceCoach,
);

final SkDoorContent kSkThinkingContent = SkDoorContent(
  doorId: 'skilling_critical_thinking',
  bandNames: kSkThinkingBandNames,
  skills: kSkThinkingSkills,
  lessonSets: kSkThinkingLessonSets,
  lessons: kSkThinkingLessons,
  activities: kSkThinkingActivities,
  courses: kSkThinkingCourses,
  products: kSkThinkingProducts,
  parentNote: kSkThinkingParentNote,
  // The brief's extras reshape: the certificate becomes a "you kept
  // thinking" keepsake — the shared one, under this name.
  keepsakeTitle: 'You kept thinking',
);

final SkDoorContent kSkStillnessContent = SkDoorContent(
  doorId: 'skilling_stillness',
  bandNames: kSkStillnessBandNames,
  skills: kSkStillnessSkills,
  lessonSets: kSkStillnessLessonSets,
  lessons: kSkStillnessLessons,
  activities: kSkStillnessActivities,
  courses: kSkStillnessCourses,
  products: kSkStillnessProducts,
  parentNote: kSkStillnessParentNote,
  // The brief's reshape of the streak: "a gentle 'want to sit again?'
  // invitation and a shelf of quiet moments taken. Never a chain."
  keepsakeTitle: 'Quiet moments taken',
  keepsakeInvite: 'Want to sit again? Whenever you like. There is no chain '
      'to keep and no day to miss.',
);

final SkDoorContent kSkFeelingsContent = SkDoorContent(
  doorId: 'skilling_emotional',
  bandNames: kSkFeelingsBandNames,
  skills: kSkFeelingsSkills,
  lessonSets: kSkFeelingsLessonSets,
  lessons: kSkFeelingsLessons,
  activities: kSkFeelingsActivities,
  courses: kSkFeelingsCourses,
  products: kSkFeelingsProducts,
  parentNote: kSkFeelingsParentNote,
  keepsakeTitle: 'You practised',
  // Her private journal (1a) and the off-ramp on every screen (4a).
  journal: true,
  safety: kSkFeelingsSafety,
);

final SkDoorContent kSkMakingContent = SkDoorContent(
  doorId: 'skilling_creativity',
  bandNames: kSkMakingBandNames,
  skills: kSkMakingSkills,
  lessonSets: kSkMakingLessonSets,
  lessons: kSkMakingLessons,
  activities: kSkMakingActivities,
  courses: kSkMakingCourses,
  products: kSkMakingProducts,
  parentNote: kSkMakingParentNote,
  keepsakeTitle: 'What I made',
  // The recorder for the music she makes (reused), and the portfolio that
  // keeps photos of what she made (new) — the brief's "reuses the keepsake
  // and recorder; photo capture is new; no score".
  voiceKeepsake: true,
  voiceTitle: 'Your recordings',
  voiceBlurb: 'The tunes and beats {name} made, and what {she} tried. It '
      'all stays on this phone; nobody marks it.',
  voiceEmptyLine: 'Clap a beat, hum a tune, play the thing you made. Tap '
      'Record something and it lands here.',
  portfolio: true,
);

/// Every door with content. Adding a door is a line here and a line in
/// `kSkDoors`.
final List<SkDoorContent> kSkDoorContents = [
  kSkCodingContent,
  kSkCommunicationContent,
  kSkConfidenceContent,
  kSkThinkingContent,
  kSkStillnessContent,
  kSkFeelingsContent,
  kSkMakingContent,
];

SkDoorContent? skDoorContentFor(String doorId) {
  for (final c in kSkDoorContents) {
    if (c.doorId == doorId) return c;
  }
  return null;
}
