// =============================================================================
//  ttc_age_rank.dart - her age decides ORDER, never what she can see
// =============================================================================
//
// The user (walk 2026-10-20): "If she picked 35 to 37, content about that age
// should come first. Over 40, the over-40 content first. We don't hide
// anything, it's all about the order." Before this, her age band moved one tab
// on one door (the IVF door's "Age and second baby") and nothing else.
//
// ⚠️ A PERMUTATION, ALWAYS. The output holds exactly the input, in a new
// order: content for her age first, everything else after in its own order
// (a stable sort). Under 35, or with no age given, nothing moves. Same rule
// as Parenting's relevance brain (pp_relevance.dart) for the same reason: a
// feature is never hidden, and content is part of the feature.
//
// ⚠️ IT ORDERS, IT DOES NOT ADVISE. Lifting "Trying after 35" says nothing
// about her chances; the reads themselves carry the population facts and the
// "your doctor decides" line (CLAUDE.md, never a personalised probability).
//
// ⚠️ BY ID, NOT BY WORDS (relevance round 2, 2026-10-28, TTC-GAP 29). This
// file used to match words ("35", "40", "age", "AMH") in a card's title,
// blurb or keywords. Over 40 that lifted "Ten everyday recipes" and tagged it
// "For your age", because its blurb says "under 40 minutes"; it lifted the
// clinic glossary for mentioning AMH, and tagged "Does his age matter?" as
// being about HER age. Words in copy are written for a reader, not for a
// matcher, so any edit to a blurb could move a card. The lists below name each
// card, read and section once. The trade-off: a new page about age is added
// here by hand. `ttc_age_rank_test.dart` fails if an id stops existing.
// Parenting's doors made the same move (PP item 12, 518ea8a).
//
// The word matcher, kept for revert, is at the bottom of this file.

import '../models/pv_read.dart' show PvRead;
import 'ttc_fertility_help_rules.dart' show FertilityAgeBand;
import 'ttc_focus_data.dart';

/// Door cards her age lifts, by card id, at 35 and over.
const Set<String> kTtcAgeCards35 = {
  'ttc_tile_trying_after_35',
  'ttc_tile_how_age_changes_how_long_trying_takes',
  // AMH falls with age, and the read says what the number cannot tell her.
  'ttc_tile_a_low_amh_result',
};

/// Over 40: the same, plus the over-40 page.
const Set<String> kTtcAgeCards40 = {
  ...kTtcAgeCards35,
  'ttc_tile_trying_after_40',
};

/// Learn's shelves list reads, not cards: the same pages by read id.
const Set<String> kTtcAgeReads35 = {'ttc_read_age_after_35', 'ttc_read_low_amh'};
const Set<String> kTtcAgeReads40 = {...kTtcAgeReads35, 'ttc_read_age_after_40'};

/// Sections that lead their tab at 35 and over. A heading is a section's only
/// name, so it is matched whole, never by a word inside it.
const Set<String> kTtcAgeSections = {
  'Does age change how we try?',
  'Does age change things?',
};

/// The cards her age band lifts; empty under 35 or with no age given.
Set<String> ttcAgeCards(FertilityAgeBand? band) => switch (band) {
      FertilityAgeBand.thirtyFiveTo37 ||
      FertilityAgeBand.thirtyEightTo40 =>
        kTtcAgeCards35,
      FertilityAgeBand.over40 => kTtcAgeCards40,
      _ => const {},
    };

/// The reads her age band lifts on Learn; empty under 35.
Set<String> ttcAgeReads(FertilityAgeBand? band) => switch (band) {
      FertilityAgeBand.thirtyFiveTo37 ||
      FertilityAgeBand.thirtyEightTo40 =>
        kTtcAgeReads35,
      FertilityAgeBand.over40 => kTtcAgeReads40,
      _ => const {},
    };

/// The id a card is known by: its own id, else the read it opens.
String? ttcTileKey(TtcTile t) =>
    t.id ??
    switch (t) {
      TtcArticleTile(:final readId) => readId,
      TtcGuideTile(:final readId) => readId,
      _ => null,
    };

/// Whether [t] is a card her age lifted: the same test that lifts it, so the
/// "For your age" tag (2026-10-22) and the order can never disagree. False
/// under 35 or with no age given, where nothing moves.
bool ttcIsForAge(TtcTile t, FertilityAgeBand? band) =>
    ttcAgeCards(band).contains(ttcTileKey(t));

/// A stable sort that puts the [up] items first. A permutation, always: the
/// output holds exactly the input.
List<T> ttcLiftFirst<T>(List<T> items, bool Function(T) up) {
  if (items.length < 2) return items;
  final lifted = <T>[], rest = <T>[];
  for (final x in items) {
    (up(x) ? lifted : rest).add(x);
  }
  if (lifted.isEmpty || rest.isEmpty) return items;
  return [...lifted, ...rest];
}

/// Learn's shelf for her age: the reads about it first.
List<PvRead> ttcAgeOrderReads(List<PvRead> reads, FertilityAgeBand? band) {
  final ids = ttcAgeReads(band);
  if (ids.isEmpty) return reads;
  return ttcLiftFirst(reads, (r) => ids.contains(r.id));
}

/// A door's sections for her age: sections about age first, and inside each
/// section the cards about age first.
List<TtcFocusSection> ttcAgeOrderSections(
    List<TtcFocusSection> sections, FertilityAgeBand? band) {
  if (ttcAgeCards(band).isEmpty) return sections;
  // `withTiles` keeps the phase tags the door ranks by next (2026-10-23).
  final inner = [
    for (final s in sections)
      s.withTiles(ttcLiftFirst(s.tiles, (t) => ttcIsForAge(t, band))),
  ];
  return ttcLiftFirst(inner, (s) => kTtcAgeSections.contains(s.heading));
}

// =============================================================================
//  A child at home (relevance round 2, 2026-10-28, TTC-GAP 28)
// -----------------------------------------------------------------------------
//  Trying for a second baby is its own situation (secondary infertility,
//  breastfeeding, the count starting again), and nothing in TTC knew she had
//  a child. The fact is the child she added: `ChildProfileStore.hasRealChild`.
//  NOT "trying again", which also follows a loss. Order only, as above, and
//  the card says why with a tag.
// =============================================================================

/// The tag on a card her child at home lifted.
const String kTtcWithChildAtHome = 'With a child at home';

/// Cards a child at home lifts, by card id.
const Set<String> kTtcChildAtHomeCards = {
  'ttc_tile_why_a_second_baby_can_take_longer',
};

/// Sections that lead their tab when she has a child at home.
const Set<String> kTtcChildAtHomeSections = {'What about a second baby?'};

/// Whether [t] is a card her child at home lifted.
bool ttcIsForChildAtHome(TtcTile t, bool childAtHome) =>
    childAtHome && kTtcChildAtHomeCards.contains(ttcTileKey(t));

/// A door's sections with the second-baby cards and sections first.
List<TtcFocusSection> ttcChildAtHomeOrderSections(
    List<TtcFocusSection> sections, bool childAtHome) {
  if (!childAtHome) return sections;
  final inner = [
    for (final s in sections)
      s.withTiles(
          ttcLiftFirst(s.tiles, (t) => ttcIsForChildAtHome(t, true))),
  ];
  return ttcLiftFirst(
      inner, (s) => kTtcChildAtHomeSections.contains(s.heading));
}

// -----------------------------------------------------------------------------
//  Kept for revert (round 2, 2026-10-28): the word matcher.
// -----------------------------------------------------------------------------
// // Matched by words in a title, blurb or keywords, the way Parenting matches,
// // so a new read about age is lifted without a table edit. Pure; tested.
//
// import 'ttc_fertility_help_rules.dart' show FertilityAgeBand;
// import 'ttc_focus_data.dart';
//
// /// The words that mark content as being about age, per band.
// List<String> ttcAgeWords(FertilityAgeBand? band) => switch (band) {
//       FertilityAgeBand.thirtyFiveTo37 ||
//       FertilityAgeBand.thirtyEightTo40 =>
//         const ['after 35', 'over 35', '35', 'egg reserve', 'amh', 'ovarian reserve', 'age'],
//       FertilityAgeBand.over40 =>
//         const ['over 40', 'after 40', '40', 'after 35', 'over 35', 'egg reserve', 'amh', 'ovarian reserve', 'age'],
//       _ => const [],
//     };
//
// bool _matches(String text, List<String> words) {
//   final t = ' ${text.toLowerCase()} ';
//   for (final w in words) {
//     // Whole words only, so "35" never matches "350 mg" and "age" never
//     // matches "stage" or "message".
//     if (RegExp('(^|[^a-z0-9])${RegExp.escape(w)}([^a-z0-9]|\$)').hasMatch(t)) {
//       return true;
//     }
//   }
//   return false;
// }
//
// /// Whether [text] is about her age band: the same test that lifts it, so the
// /// "For your age" tag (2026-10-22) and the order can never disagree. False
// /// under 35 or with no age given, where nothing moves.
// bool ttcIsForAge(String text, FertilityAgeBand? band) {
//   final words = ttcAgeWords(band);
//   return words.isNotEmpty && _matches(text, words);
// }
//
// /// The words a door tile is matched on.
// String ttcTileAgeText(TtcTile t) =>
//     '${t.title} ${t.blurb} ${t.keywords.join(' ')}';
//
// /// A stable sort that lifts [items] about her age to the front.
// List<T> ttcAgeOrder<T>(
//     List<T> items, FertilityAgeBand? band, String Function(T) textOf) {
//   final words = ttcAgeWords(band);
//   if (words.isEmpty || items.length < 2) return items;
//   final lifted = <T>[], rest = <T>[];
//   for (final x in items) {
//     (_matches(textOf(x), words) ? lifted : rest).add(x);
//   }
//   if (lifted.isEmpty || rest.isEmpty) return items;
//   return [...lifted, ...rest];
// }
//
// /// A door's sections for her age: sections about age first, and inside each
// /// section the tiles about age first.
// List<TtcFocusSection> ttcAgeOrderSections(
//     List<TtcFocusSection> sections, FertilityAgeBand? band) {
//   if (ttcAgeWords(band).isEmpty) return sections;
//   // Kept for revert (2026-10-22, shared with the tag):
//   //   String tileText(TtcTile t) =>
//   //       '${t.title} ${t.blurb} ${t.keywords.join(' ')}';
//   const tileText = ttcTileAgeText;
//   // Kept for revert (2026-10-23): a hand-built copy, which dropped the
//   // phase tags the door ranks by next (ttc_phase_rank.dart).
//   //   TtcFocusSection(
//   //     heading: s.heading,
//   //     group: s.group,
//   //     tiles: ttcAgeOrder(s.tiles, band, tileText),
//   //   ),
//   final inner = [
//     for (final s in sections) s.withTiles(ttcAgeOrder(s.tiles, band, tileText)),
//   ];
//   return ttcAgeOrder(inner, band, (s) => s.heading);
// }
