// =============================================================================
//  Checklists — a thing you tick, take into a room, and send to someone
// -----------------------------------------------------------------------------
//  ⚠️ GENERALISED FROM THE SCANS ONE, AND THE TIMING IS THE POINT. The Scans
//  door shipped `scan_questions_data.dart` + `ScanQuestionsStore` +
//  `ScanQuestionsScreen` — three scan-shaped files. Complications asks for the
//  same object with different questions, and every remaining brief has a
//  "before your appointment" tab.
//
//  Generalising at the SECOND caller is the whole trick. At one caller it is
//  speculation; at three it is a migration nobody schedules — and this repo has
//  the receipts, in `PvRead`'s own header, on two models that chose `String`
//  and were never widened.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT A CHECKLIST IS, AS OPPOSED TO A FORM
//  ---------------------------------------------------------------------------
//
//  It never scores, ranks, congratulates or counts down. No progress bar, no
//  "4 of 18", no streak — a counter on a list of things somebody is nervous
//  enough to write down is a debt statement, and both briefs' DO NOT lists end
//  with "no streak or gamification".
//
//  The one number shown is on the share button, where it says how long the
//  message is about to be.
//
//  ⚠️ AND NOTHING IN A CHECKLIST ASKS US TO INTERPRET ANYTHING. Every item is a
//  question for her clinician. None is a threshold, a self-assessment or a
//  symptom to grade. That is CLAUDE.md's clinical-ownership rule in its purest
//  form: where a doctor owns a decision we may help her PREPARE for it.
// =============================================================================

import '../../services/pregnancy_controller.dart';
import 'pv_checklist_conditions.dart';
import 'pv_checklist_nutrition.dart';
import 'pv_checklist_scans.dart';

export 'pv_checklist_conditions.dart';
export 'pv_checklist_nutrition.dart';
export 'pv_checklist_scans.dart';

/// One question, in a group.
class PvChecklistItem {
  const PvChecklistItem(this.id, this.text);

  /// ⚠️ PERSISTED VERBATIM BY `PvChecklistStore`, SO IT IS AN IDENTITY. Reword
  /// the text freely; renaming an id strands whatever she had ticked. Worse, it
  /// strands it SILENTLY — the row simply comes back unticked and looks like it
  /// never was.
  final String id;

  /// Written the way she would say it out loud, not the way a form would ask
  /// it. Short enough to read off a phone in a corridor.
  final String text;
}

/// A heading and the questions under it.
class PvChecklistGroup {
  const PvChecklistGroup(this.heading, this.items);
  final String heading;
  final List<PvChecklistItem> items;
}

/// One checklist.
class PvChecklist {
  const PvChecklist({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.shareHeader,
    required this.groups,
    this.subject,
    this.subjectTitle,
    this.subjectIntro,
  });

  /// The storage key. An identity — see [PvChecklistItem.id].
  final String id;

  /// Small, letterspaced, above the title.
  final String eyebrow;

  /// The heading when nothing specific is known about her yet.
  final String title;

  /// What this is for, and what it is not, before the first tick.
  final String intro;

  /// The first line of the shared message when nothing specific is known.
  final String shareHeader;

  final List<PvChecklistGroup> groups;

  /// What this checklist is about RIGHT NOW, worked out from her own data.
  ///
  /// ⚠️ THIS IS THE DIFFERENCE BETWEEN A LEAFLET AND HER LIST. The same twenty
  /// lines under "What to ask at your next scan" is a leaflet; under "What to
  /// ask at your anomaly scan" it is hers. Nothing is asked for — it is derived
  /// from the timeline or the conditions she has added, which is CLAUDE.md's
  /// derive-never-ask rule in the place it is cheapest to honour.
  ///
  /// ⚠️ RETURNS NULL AND THAT IS A REAL ANSWER. A fresh install, or everything
  /// already ticked off, or nothing added — the checklist falls back to [title]
  /// and still works completely. An empty state here is not a special case; it
  /// is the same screen with one line less.
  ///
  /// ⚠️ A FUNCTION IN A DATA FILE, WHICH MAKES THE REGISTRY `final` RATHER THAN
  /// `const`. That is the price of the list knowing about her without the
  /// screen knowing about scans, and it is the right way round: the screen
  /// stays general, each checklist reads its own source.
  ///
  /// ⚠️ IT TAKES THE CONTROLLER, AND THE NUTRITION LIST IS WHY. The scans and
  /// conditions subjects read singleton stores and ignore the argument; the
  /// diet one needs her WEEK, and `PregnancyController` is deliberately not a
  /// singleton in this app — it is passed. A subject that reached for a global
  /// week would be the one place in the engine that guessed instead of being
  /// told.
  final String? Function(PregnancyController)? subject;

  /// Builds the heading from [subject]'s answer. "What to ask at your $s".
  final String Function(String subject)? subjectTitle;

  /// Builds the intro from [subject]'s answer.
  final String Function(String subject)? subjectIntro;

  /// Every item, flattened.
  List<PvChecklistItem> get items => [for (final g in groups) ...g.items];
}

/// ⚠️ `final`, NOT `const` — see [PvChecklist.subject].
final List<PvChecklist> kPvChecklists = [
  kScanQuestionsChecklist,
  kConditionQuestionsChecklist,
  kDietQuestionsChecklist,
];

/// Null is a real answer; the router opens nothing rather than guessing.
PvChecklist? pvChecklistById(String id) {
  for (final c in kPvChecklists) {
    if (c.id == id) return c;
  }
  return null;
}
