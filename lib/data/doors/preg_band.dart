// =============================================================================
//  PregBand — the weeks a piece of door content belongs to, and the ranking
// -----------------------------------------------------------------------------
//  The pregnancy twin of `ppRelevanceOrder` (2026-10-23, global pass phase 1).
//  The user, at week 30: "I come on the door, I start from the first trimester
//  always." Every door listed its sections in the order they were written, and
//  the only week hook (`PvDoorSection.lead`) could move one entry tile.
//
//  ⚠️ RANKING, NEVER STRUCTURE (CLAUDE.md). Nothing is hidden or added. Past
//  content sinks, it never vanishes; untagged content keeps its exact place.
//
//  ⚠️ PURE DATA. No controller import: the screen passes the week, or null
//  when there is no real due date. A null week returns the list untouched -
//  the week-20 placeholder must never reorder anything.
// =============================================================================

/// An inclusive week range, e.g. 28 to 42 for "the last three months".
class PregBand {
  const PregBand(this.from, this.to);
  final int from;
  final int to;

  static const firstTrimester = PregBand(1, 13);
  static const secondTrimester = PregBand(14, 27);
  static const thirdTrimester = PregBand(28, 42);

  bool contains(int week) => week >= from && week <= to;

  /// Reads the week range a tile's `meta` already prints: "Weeks 28 to 36",
  /// "Weeks 28–36", "Weeks 24 to 28 (OGTT)", "Weeks 28 to birth",
  /// "After week 20". Anything else (a date, "Any time", "Later scans")
  /// is null, which means "keep its place".
  static PregBand? parse(String? meta) {
    if (meta == null) return null;
    final range = RegExp(r'[Ww]eeks?\s+(\d{1,2})\s*(?:to|–|-)\s*(\d{1,2}|birth)')
        .firstMatch(meta);
    if (range != null) {
      final a = int.parse(range.group(1)!);
      final b = range.group(2) == 'birth' ? 42 : int.parse(range.group(2)!);
      return a <= b ? PregBand(a, b) : null;
    }
    final after = RegExp(r'[Aa]fter week\s+(\d{1,2})').firstMatch(meta);
    if (after != null) return PregBand(int.parse(after.group(1)!), 42);
    return null;
  }
}

/// Orders [items] for a woman at [week].
///
/// Banded items are re-sorted among the slots banded items already occupy:
/// the band she is in, then upcoming bands (nearest first), then past bands
/// (most recent first). Then the first current item moves to the front of
/// the whole list, so a single banded section among untagged ones ("The last
/// months" on Getting Ready) still leads when it is hers.
///
/// Stable within a rank. Untagged items keep their index, except for the one
/// shift the hoist causes. A null [week] returns [items] unchanged.
List<T> pregRelevanceOrder<T>(
  List<T> items,
  PregBand? Function(T) bandOf,
  int? week,
) {
  if (week == null || items.length < 2) return items;
  final slots = <int>[];
  for (var i = 0; i < items.length; i++) {
    if (bandOf(items[i]) != null) slots.add(i);
  }
  if (slots.isEmpty) return items;

  int rank(PregBand b) {
    if (b.contains(week)) return 0;
    if (b.from > week) return 1000 + (b.from - week); // upcoming, nearest first
    return 2000 + (week - b.to); // past, most recent first
  }

  final banded = [for (final i in slots) items[i]];
  final order = List<int>.generate(banded.length, (i) => i)
    ..sort((x, y) {
      final c = rank(bandOf(banded[x])!).compareTo(rank(bandOf(banded[y])!));
      return c != 0 ? c : x.compareTo(y);
    });
  final out = List<T>.of(items);
  for (var k = 0; k < slots.length; k++) {
    out[slots[k]] = banded[order[k]];
  }

  final current = out.indexWhere((t) {
    final b = bandOf(t);
    return b != null && b.contains(week);
  });
  if (current > 0) out.insert(0, out.removeAt(current));
  return out;
}
