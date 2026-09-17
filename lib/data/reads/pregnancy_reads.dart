// =============================================================================
//  Pregnancy reads — the stage's long-form library
// -----------------------------------------------------------------------------
//  Written to `PvRead`, the same model TTC writes to and the same
//  `PvReaderScreen` renders. That reader is stage-neutral by construction — it
//  takes `openRead`, `openSurface` and `readTitle` as callbacks rather than
//  importing a library — which is precisely what lets pregnancy start its own
//  library without touching a TTC file.
//
//  ⚠️ THIS IS THE FIRST NON-TTC `PvRead` LIBRARY, AND IT STARTS AT THE SAME
//  BAR. `assertShape()` is on the model, so a thin piece fails rather than
//  quietly looking finished, and `test/pregnancy_reads_shape_test.dart` runs it
//  over everything here. Four sections, three headings, an FAQ, six hundred
//  words of actual prose, a named source and an urgent when-to-see-someone.
//
//  The temptation on a "short guide" is to write two paragraphs and call it
//  done. The floor exists because that piece then sits on a rail beside nine
//  rich scan pages and reads as the one nobody finished.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES, WHICH DO NOT RELAX FOR PROSE
//  ---------------------------------------------------------------------------
//
//  · **Never a diagnosis.** Every read carries `whenToSeeSomeone`, required on
//    the model so it cannot be the thing that got left off.
//  · **Never contradict her own clinician.** Where a doctor owns a decision we
//    explain it, remind about it, or help her prepare for it. We do not
//    recreate it. A read may say what a scan measures; it may not tell her what
//    her scan meant.
//  · **Named sources, never "studies show".** `evidence` is required by the
//    shape rules.
//  · **Costs carry a date.** A rupee figure with no year on it is worse than no
//    figure — she plans around it, quotes it at a counter, and it rots
//    silently. Every price range below says when it was checked.
//
//  ---------------------------------------------------------------------------
//  ⚠️ `LocalizedText` WITH `_en(...)`, WHICH IS NOT A CONTRADICTION OF THE
//  ENGLISH-ONLY POLICY
//  ---------------------------------------------------------------------------
//
//  New copy is English — CLAUDE.md, 2026-08-27 — and every string here renders
//  English today. The wrapper is the MODEL's, not a choice made here: `PvRead`
//  is `LocalizedText` throughout because the two models that chose bare
//  `String` (`ReadArticle`, `WeekArticle`) both hit the wall and neither
//  migration was ever started.
//
//  `_en(...)` rather than `_t(x, x)` for the same reason it is used in TTC: an
//  identical pair reads as finished work to every audit, and `grep -c '_en('`
//  is the only greppable form of "English now". It is a marker, not a promise —
//  the policy says Hindi is not owed unless it is asked for.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pregnancy_reads_conditions.dart';
import 'pregnancy_reads_labour.dart';
import 'pregnancy_reads_nutrition.dart';
import 'pregnancy_reads_scans.dart';
import 'pregnancy_reads_weekly_a.dart';
import 'pregnancy_reads_weekly_b.dart';
import 'pregnancy_reads_weekly_c.dart';
import 'pregnancy_reads_weekly_d.dart';

export 'pregnancy_reads_conditions.dart';
export 'pregnancy_reads_labour.dart';
export 'pregnancy_reads_nutrition.dart';
export 'pregnancy_reads_scans.dart';
export 'pregnancy_reads_weekly_a.dart';
export 'pregnancy_reads_weekly_b.dart';
export 'pregnancy_reads_weekly_c.dart';
export 'pregnancy_reads_weekly_d.dart';

/// Every pregnancy read, in door order.
///
/// ⚠️ THE SPREAD IS THE ONLY SHARED LINE IN THE LIBRARY. Everything a door
/// build touches is its own file, which is what makes parallel work on several
/// briefs safe.
final List<PvRead> kPregnancyReads = [
  ...kPregnancyReadsScans,
  ...kPregnancyReadsConditions,
  ...kPregnancyReadsNutrition,
  ...kPregnancyReadsLabour,
  // The weekly reads, written out 2026-09-18 — see pregnancy_reads_weekly_a.
  ...kPregnancyReadsWeeklyA,
  ...kPregnancyReadsWeeklyB,
  ...kPregnancyReadsWeeklyC,
  ...kPregnancyReadsWeeklyD,
];

/// The full read behind a weekly `ReadItem`, or null when the item has not
/// been written out yet (the adapter then draws what the seed carries).
PvRead? pregnancyWeeklyReadFor(String readItemId) =>
    pregnancyReadById('$kPregWeekReadPrefix$readItemId');

/// Lookup by id. Null is a real answer — the door router opens nothing rather
/// than guessing at a near match, and the wiring test makes sure no shipped
/// tile can reach that branch.
PvRead? pregnancyReadById(String id) {
  for (final r in kPregnancyReads) {
    if (r.id == id) return r;
  }
  return null;
}

/// Title for a read-next card, without handing the reader the whole library.
LocalizedText? pregnancyReadTitle(String id) => pregnancyReadById(id)?.title;
