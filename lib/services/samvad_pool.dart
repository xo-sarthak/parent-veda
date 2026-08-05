// =============================================================================
//  Samvad pool - the unified "read to your baby" content for Garbh Sanskar
// -----------------------------------------------------------------------------
//  After the "Read to your baby" feature was folded into Garbh Sanskar › Samvad,
//  ONE shared pool drives every surface:
//    • Mother - daily Samvad (today's piece + Customize)         → samvadTodaysPiece
//    • Mother - Tools Samvad library (segregated groups)         → samvadLibraryGroups
//    • Father - daily "Read to your baby" card (mirror of mom)   → samvadTodaysPiece
//
//  The mother's ReadToBabyStore is the single owner of customization. The father
//  has NO controls of his own - he simply reads the same pool, so whatever the
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
  const SamvadPiece(
      {this.title,
      required this.body,
      required this.group,
      String? saveKey})
      // The lint suggests `this._saveKey`, which does not compile: a named
      // parameter cannot be private, so the field and the parameter have to
      // be spelled differently. Call sites keep the readable `saveKey:`.
      // ignore: prefer_initializing_formals
      : _saveKey = saveKey;

  final String? title;
  final String body;
  final String group; // the group label this piece belongs to
  final String? _saveKey;

  /// A stable key for bookmarking, invariant across languages.
  ///
  /// This is a VIEW record - [title] and [body] are already resolved to the
  /// language on screen, so neither can identify anything. Callers whose
  /// source data is bilingual pass the English string as [saveKey].
  ///
  /// The fallback below is the pre-migration behaviour, and it is sharper than
  /// it looks: an untitled speaking card keys on its ENTIRE BODY. That is
  /// harmless only while those cards are still English-only. Any data file
  /// feeding this must pass an explicit [saveKey] as it gains Hindi, or every
  /// bookmark in it silently re-keys on the language toggle.
  String get saveKey =>
      _saveKey ??
      ((title != null && title!.trim().isNotEmpty) ? title! : body);
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
      pool.add(SamvadPiece(body: p.text.now, group: 'Speaking cards'));
    }
  }
  void addCat(String cat, String group) {
    for (final p in readAloudByCategory(cat)) {
      pool.add(SamvadPiece(
          title: p.title.now,
          body: p.body.now,
          group: group,
          saveKey: p.saveKey));
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
          pool.add(SamvadPiece(title: r.title.now, body: r.body.now, group: t.name.now));
        }
      }
    }
  }
  return pool;
}

/// The segregated library view for Tools - each enabled category becomes one or
/// more headed groups (speaking splits into its three classic sub-sets).
List<SamvadGroup> samvadLibraryGroups(ReadToBabyStore store, int trimester) {
  final groups = <SamvadGroup>[];
  if (store.isCategoryOn(kRtbSpeaking)) {
    groups.add(SamvadGroup(
        heading: 'Affirmations',
        pieces: [
          for (final p in kSamvadT1)
            SamvadPiece(body: p.text.now, group: 'Affirmations')
        ]));
    groups.add(SamvadGroup(
        heading: 'Read-aloud scripts',
        pieces: [
          for (final p in kSamvadT2)
            SamvadPiece(body: p.text.now, group: 'Read-aloud scripts')
        ]));
    groups.add(SamvadGroup(
        heading: 'Visualizations',
        pieces: [
          for (final p in kSamvadT3)
            SamvadPiece(body: p.text.now, group: 'Visualizations')
        ]));
  }
  void addGroup(String cat, String heading) {
    final items = readAloudByCategory(cat);
    if (items.isEmpty) return;
    groups.add(SamvadGroup(
        heading: heading,
        pieces: [
          for (final p in items)
            SamvadPiece(
                title: p.title.now,
                body: p.body.now,
                group: heading,
                saveKey: p.saveKey)
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
                SamvadPiece(title: r.title.now, body: r.body.now, group: t.name.now)
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
