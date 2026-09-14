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

/// Every door with content. Adding a door is a line here and a line in
/// `kSkDoors`.
final List<SkDoorContent> kSkDoorContents = [
  kSkCodingContent,
];

SkDoorContent? skDoorContentFor(String doorId) {
  for (final c in kSkDoorContents) {
    if (c.doorId == doorId) return c;
  }
  return null;
}
