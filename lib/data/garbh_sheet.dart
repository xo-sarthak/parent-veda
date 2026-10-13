// =============================================================================
//  Garbh Sanskar.xlsx — the user's daily scripts, stories and prayers
// -----------------------------------------------------------------------------
//  2026-10-13. The user's prepared Garbh Sanskar workbook, the source of truth
//  for what it covers. Generated into lib/data/garbh_sheet/ by
//  `tools/garbh_content/xlsx_to_dart.py`; a hand edit there is lost on the next
//  run — fix the sheet and re-run.
//
//  WHAT IS HERE, AND WHERE IT SHOWS
//    · kGarbhSheetDays — one entry per day of pregnancy, 1–280:
//        mother  → her "Talking to your baby" today (`promptForDay`)
//        father  → his read-to-baby card today
//        story   → "Today's story" in Talk & read
//    · kGarbhMantras* — each faith's prayers in the spiritual library
//    · kGarbhSacredStories, kGarbhGitaConversations — Hinduism's library
//
//  WHAT IS NOT, ON PURPOSE (the user's decisions, 2026-10-13)
//    · the sheet's "Developmental Focus", "Intent" and "Prenatal Intent"
//      columns — claims about the body and the baby's development, which the
//      Garbh door never makes (garbh_rebuild_data.dart);
//    · the raga sheet — no recordings exist; docs/GARBH-AUDIO-OWED.md is the
//      brief for them;
//    · Bible text in the NIV wording — replaced with the World English Bible,
//      which is in the public domain.
// =============================================================================

import 'garbh_sheet/garbh_days.dart';
import 'garbh_sheet/garbh_mantras.dart';

export 'garbh_sheet/garbh_days.dart' show kGarbhSheetDays;
export 'garbh_sheet/garbh_mantras.dart';
export 'garbh_sheet/garbh_sacred.dart';

/// One day of pregnancy.
class GarbhSheetDay {
  const GarbhSheetDay(this.day, this.mother, this.father, this.storyTitle, this.story, this.storyClose);
  final int day;

  /// The mother's affirmation, said to her baby.
  final String mother;

  /// The father's script ("Paternal Echo"), said to the baby.
  final String father;
  final String storyTitle;
  final String story;

  /// The line the story closes on, said to the baby.
  final String storyClose;
}

/// A prayer, mantra, shabad, dua or verse, with what it means.
class GarbhMantra {
  const GarbhMantra(this.name, this.text, this.meaning, this.trimesters);
  final String name;
  final String text;

  /// Empty when the sheet's only line was a claim (dropped).
  final String meaning;
  final List<int> trimesters;
}

/// A sacred story or a Gita conversation, retold to read aloud.
class GarbhSacredStory {
  const GarbhSacredStory(this.title, this.source, this.trimesters, this.story, this.moral);
  final String title;

  /// "Mahabharata", "Bhagavad Gita, Chapter 17, Verse 3".
  final String source;
  final List<int> trimesters;
  final String story;
  final String moral;
}

/// The sheet's entry for pregnancy [day] (held to 1–280).
GarbhSheetDay garbhSheetDay(int day) => kGarbhSheetDays[day.clamp(1, 280) - 1];

/// Each faith's prayers, keyed by the spiritual library's tradition id.
const Map<String, List<GarbhMantra>> kGarbhMantrasByTradition = {
  'hindu': kGarbhMantrasHindu,
  'sikh': kGarbhMantrasSikh,
  'islam': kGarbhMantrasMuslim,
  'christian': kGarbhMantrasChristian,
};
