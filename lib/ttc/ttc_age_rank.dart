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
// Matched by words in a title, blurb or keywords, the way Parenting matches,
// so a new read about age is lifted without a table edit. Pure; tested.

import 'ttc_fertility_help_rules.dart' show FertilityAgeBand;
import 'ttc_focus_data.dart';

/// The words that mark content as being about age, per band.
List<String> ttcAgeWords(FertilityAgeBand? band) => switch (band) {
      FertilityAgeBand.thirtyFiveTo37 ||
      FertilityAgeBand.thirtyEightTo40 =>
        const ['after 35', 'over 35', '35', 'egg reserve', 'amh', 'ovarian reserve', 'age'],
      FertilityAgeBand.over40 =>
        const ['over 40', 'after 40', '40', 'after 35', 'over 35', 'egg reserve', 'amh', 'ovarian reserve', 'age'],
      _ => const [],
    };

bool _matches(String text, List<String> words) {
  final t = ' ${text.toLowerCase()} ';
  for (final w in words) {
    // Whole words only, so "35" never matches "350 mg" and "age" never
    // matches "stage" or "message".
    if (RegExp('(^|[^a-z0-9])${RegExp.escape(w)}([^a-z0-9]|\$)').hasMatch(t)) {
      return true;
    }
  }
  return false;
}

/// A stable sort that lifts [items] about her age to the front.
List<T> ttcAgeOrder<T>(
    List<T> items, FertilityAgeBand? band, String Function(T) textOf) {
  final words = ttcAgeWords(band);
  if (words.isEmpty || items.length < 2) return items;
  final lifted = <T>[], rest = <T>[];
  for (final x in items) {
    (_matches(textOf(x), words) ? lifted : rest).add(x);
  }
  if (lifted.isEmpty || rest.isEmpty) return items;
  return [...lifted, ...rest];
}

/// A door's sections for her age: sections about age first, and inside each
/// section the tiles about age first.
List<TtcFocusSection> ttcAgeOrderSections(
    List<TtcFocusSection> sections, FertilityAgeBand? band) {
  if (ttcAgeWords(band).isEmpty) return sections;
  String tileText(TtcTile t) =>
      '${t.title} ${t.blurb} ${t.keywords.join(' ')}';
  final inner = [
    for (final s in sections)
      TtcFocusSection(
        heading: s.heading,
        group: s.group,
        tiles: ttcAgeOrder(s.tiles, band, tileText),
      ),
  ];
  return ttcAgeOrder(inner, band, (s) => s.heading);
}
