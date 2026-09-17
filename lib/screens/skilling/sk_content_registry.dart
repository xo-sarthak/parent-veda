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

/// Every door with content. Adding a door is a line here and a line in
/// `kSkDoors`.
final List<SkDoorContent> kSkDoorContents = [
  kSkCodingContent,
  kSkCommunicationContent,
  kSkConfidenceContent,
];

SkDoorContent? skDoorContentFor(String doorId) {
  for (final c in kSkDoorContents) {
    if (c.doorId == doorId) return c;
  }
  return null;
}
