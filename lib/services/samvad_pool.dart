// =============================================================================
//  Samvad pool — the unified "read to your baby" content for Garbh Sanskar
// -----------------------------------------------------------------------------
//  After the "Read to your baby" feature was folded into Garbh Sanskar › Samvad,
//  ONE shared pool drives every surface:
//    • Mother — daily Samvad (today's piece + Customize)         → samvadTodaysPiece
//    • Mother — Tools Samvad library (segregated groups)         → samvadLibraryGroups
//    • Father — daily "Read to your baby" card (mirror of mom)   → samvadTodaysPiece
//
//  The mother's ReadToBabyStore is the single owner of customization. The father
//  has NO controls of his own — he simply reads the same pool, so whatever the
//  mother enables is exactly what he sees.
//
//  Categories (all toggled via the one Customize sheet):
//    speaking      → the trimester speaking cards (kSamvadT1/T2/T3)
//    stories       → children's stories  (read_to_baby_data)
//    rhymes        → rhymes & lullabies  (read_to_baby_data)
//    affirmations  → affirmations & blessings (read_to_baby_data)
//    spiritual     → chosen traditions / sub-sections (spiritual_reading_data)
//
//  English-first headings, consistent with the rest of the English-first Garbh
//  content (Hindi can be layered later).
// =============================================================================

import '../data/garbh_data.dart';
import '../data/read_to_baby_data.dart';
import '../data/spiritual_reading_data.dart';
import 'read_to_baby_store.dart';

/// One read-aloud piece. [title] is null for the bare speaking cards (which are
/// just a line to say); stories / rhymes / spiritual reads carry a title.
class SamvadPiece {
  const SamvadPiece({this.title, required this.body, required this.group});
  final String? title;
  final String body;
  final String group; // the group label this piece belongs to

  /// A stable key for bookmarking (saved hub keys by title).
  String get saveKey =>
      (title != null && title!.trim().isNotEmpty) ? title! : body;
}

/// A labelled, segregated group for the Tools library view.
class SamvadGroup {
  const SamvadGroup({required this.heading, required this.pieces});
  final String heading;
  final List<SamvadPiece> pieces;
}

/// The flat daily pool the mother's daily Samvad and the father's card both draw
/// from. [trimester] only changes the speaking-cards subset (the read-aloud
/// scripts are trimester-aware); the read-to-baby categories are stage-neutral.
List<SamvadPiece> samvadDailyPool(ReadToBabyStore store, int trimester) {
  final pool = <SamvadPiece>[];
  if (store.isCategoryOn(kRtbSpeaking)) {
    for (final p in samvadForTrimester(trimester)) {
      pool.add(SamvadPiece(body: p.text, group: 'Speaking cards'));
    }
  }
  void addCat(String cat, String group) {
    for (final p in readAloudByCategory(cat)) {
      pool.add(SamvadPiece(title: p.title, body: p.body, group: group));
    }
  }

  if (store.isCategoryOn(kRtbStories)) addCat(kRtbStories, "Children's stories");
  if (store.isCategoryOn(kRtbRhymes)) addCat(kRtbRhymes, 'Rhymes & lullabies');
  if (store.isCategoryOn(kRtbAffirmations)) {
    addCat(kRtbAffirmations, 'Affirmations & blessings');
  }
  if (store.isCategoryOn(kRtbSpiritual)) {
    for (final t in kSpiritualTraditions) {
      if (!store.isReligionOn(t.id)) continue;
      for (var i = 0; i < t.sections.length; i++) {
        if (!store.isSectionOn(t.id, i)) continue;
        for (final r in t.sections[i].reads) {
          pool.add(SamvadPiece(title: r.title, body: r.body, group: t.name));
        }
      }
    }
  }
  return pool;
}

/// The segregated library view for Tools — each enabled category becomes one or
/// more headed groups (speaking splits into its three classic sub-sets).
List<SamvadGroup> samvadLibraryGroups(ReadToBabyStore store, int trimester) {
  final groups = <SamvadGroup>[];
  if (store.isCategoryOn(kRtbSpeaking)) {
    groups.add(SamvadGroup(
        heading: 'Affirmations',
        pieces: [
          for (final p in kSamvadT1)
            SamvadPiece(body: p.text, group: 'Affirmations')
        ]));
    groups.add(SamvadGroup(
        heading: 'Read-aloud scripts',
        pieces: [
          for (final p in kSamvadT2)
            SamvadPiece(body: p.text, group: 'Read-aloud scripts')
        ]));
    groups.add(SamvadGroup(
        heading: 'Visualizations',
        pieces: [
          for (final p in kSamvadT3)
            SamvadPiece(body: p.text, group: 'Visualizations')
        ]));
  }
  void addGroup(String cat, String heading) {
    final items = readAloudByCategory(cat);
    if (items.isEmpty) return;
    groups.add(SamvadGroup(
        heading: heading,
        pieces: [
          for (final p in items)
            SamvadPiece(title: p.title, body: p.body, group: heading)
        ]));
  }

  if (store.isCategoryOn(kRtbStories)) {
    addGroup(kRtbStories, "Children's stories");
  }
  if (store.isCategoryOn(kRtbRhymes)) addGroup(kRtbRhymes, 'Rhymes & lullabies');
  if (store.isCategoryOn(kRtbAffirmations)) {
    addGroup(kRtbAffirmations, 'Affirmations & blessings');
  }
  if (store.isCategoryOn(kRtbSpiritual)) {
    for (final t in kSpiritualTraditions) {
      if (!store.isReligionOn(t.id)) continue;
      for (var i = 0; i < t.sections.length; i++) {
        if (!store.isSectionOn(t.id, i)) continue;
        final reads = t.sections[i].reads;
        if (reads.isEmpty) continue;
        groups.add(SamvadGroup(
            heading: '${t.symbol} ${t.name} · ${t.sections[i].title}',
            pieces: [
              for (final r in reads)
                SamvadPiece(title: r.title, body: r.body, group: t.name)
            ]));
      }
    }
  }
  return groups;
}

/// Today's piece for [day] (1-based pregnancy day), rotating gently and stably.
/// [offset] lets the UI cycle to "another" piece. Returns null when nothing is
/// enabled (the caller shows a "customize" nudge instead).
SamvadPiece? samvadTodaysPiece(ReadToBabyStore store, int trimester, int day,
    {int offset = 0}) {
  final pool = samvadDailyPool(store, trimester);
  if (pool.isEmpty) return null;
  final idx = ((day.clamp(1, 280) - 1) + offset) % pool.length;
  return pool[idx];
}
