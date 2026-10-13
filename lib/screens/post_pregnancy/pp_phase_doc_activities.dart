// =============================================================================
//  The phase docs' activities, as the app's activities (2026-10-13)
// -----------------------------------------------------------------------------
//  Every activity in the user's My Child phase docs (lib/data/pp_phase_docs.dart)
//  becomes a `DevActivity`, so it joins the one activity pool: the home's
//  Today, the Brain tab, an area's rail, and `DevelopmentActivityScreen` all
//  draw it with no second kind of activity to know about.
//
//  The doc is the source of truth, so nothing is invented to fill the older
//  shape: no duration (`minutes: 0` reads "At your pace") and no difficulty.
//  The doc's own blocks the older shape lacks — the intro, things to
//  remember, variations, linked milestones — ride on `DevActivity`'s optional
//  fields and the screen draws them in the doc's order.
//
//  The age tag is the phase's own band, so `growSuitsAge` treats a phase's
//  activities as an exact fit for a child in that phase, and
//  `PpHomeActivitiesStore` puts the child's own phase first (the user,
//  2026-10-13: "into Today, this phase first").
// =============================================================================

import '../../data/pp_phase_docs.dart';
import 'pp_development_data.dart';
import 'pp_phases_data.dart' show kPhasesAuthored;

/// The doc domain's development area (`devAreaById`).
String ppDocAreaId(PpDocDomain d) => switch (d) {
      PpDocDomain.brain => 'cognitive',
      PpDocDomain.physical => 'gross_motor',
      PpDocDomain.language => 'language',
      PpDocDomain.emotional => 'emotional',
      PpDocDomain.nutrition => 'selfcare',
    };

String _slug(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');

/// "ph001_slow_face_tracking".
String ppDocActivityId(PpPhaseDoc doc, PpPhaseActivity a) =>
    '${doc.code.toLowerCase()}_${_slug(a.title)}';

/// "0–1 mo", "13–15 mo": the phase's months, inclusive, as `growAgeRange` reads them.
String _ageTag(int phase) {
  final p = kPhasesAuthored.firstWhere((x) => x.number == phase);
  final start = p.startMonth.round();
  final last = p.endMonth.round() - 1;
  return last > start ? '$start–$last mo' : '$start–${p.endMonth.round()} mo';
}

final List<DevActivity> kPhaseDocActivities = [
  for (final doc in kPpPhaseDocList)
    for (var i = 0; i < doc.activities.length; i++)
      _toDev(doc, doc.activities[i], i),
];

DevActivity _toDev(PpPhaseDoc doc, PpPhaseActivity a, int i) => DevActivity(
      id: ppDocActivityId(doc, a),
      title: a.title,
      areaId: ppDocAreaId(a.domain),
      minutes: 0,
      difficulty: '',
      ageTag: _ageTag(doc.phase),
      materials: a.need,
      skills: a.builds,
      safety: a.safe,
      benefit: a.why,
      steps: a.steps,
      seed: doc.phase * 10 + i,
      intro: a.intro,
      remember: a.remember,
      variations: a.variations.isEmpty ? null : a.variations,
      linkedMilestones: a.linked,
    );

/// The app activity for a doc activity named [title] in [doc], or null when
/// the doc names one it never wrote (PH015's "Naming All the Feelings").
DevActivity? ppDocActivityNamed(PpPhaseDoc doc, String title) {
  for (final a in doc.activities) {
    if (a.title.toLowerCase() == title.toLowerCase()) {
      final id = ppDocActivityId(doc, a);
      return kPhaseDocActivities.firstWhere((x) => x.id == id);
    }
  }
  return null;
}

/// True when [a] is a doc activity written for the phase a child of
/// [ageMonths] is in — the first tier of Today's ranking.
bool ppIsOwnPhaseDocActivity(DevActivity a, int ageMonths) {
  if (!a.fromPhaseDoc) return false;
  for (final p in kPhasesAuthored) {
    if (p.covers(ageMonths.toDouble())) {
      return a.id.startsWith('ph${p.number.toString().padLeft(3, '0')}_');
    }
  }
  return false;
}
