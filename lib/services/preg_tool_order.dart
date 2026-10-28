// =============================================================================
//  The order of the Pregnancy Tools tab, by her week — relevance Batch 4
// -----------------------------------------------------------------------------
//  docs/door-relevance/PREGNANCY-GAP.md, PREG 8: at week 8 the first row of the
//  Tools tab was the kick counter, and "Get ready" (the bag, the birth plan,
//  the contraction timer) sat above everything she keeps. The groups and rows
//  were a fixed list; only her onboarding answers moved anything.
//
//  THE RULE IS WRITTEN ON EACH ROW, NEVER AS POSITIONS. A group may carry a
//  week from which it LEADS; a row may carry a week from which it is IN ITS
//  TIME. That is all. A row with no week keeps its place, so a row the tools
//  terminal adds later slots in without anyone editing this file (agreed
//  2026-10-27, docs/door-relevance/README.md, the seams table).
//
//  THE TWO KINDS DIFFER ON PURPOSE:
//   - a GROUP only lifts. Before 28 "Get ready" keeps its place (second), so
//     the due-date row inside it is where she has always found it;
//   - a ROW lifts from its week and WAITS before it, after the rows with no
//     week: a kick counter at week 8 is not wrong to have, but it is not the
//     first thing a mother at week 8 needs.
//
//  ⚠️ ORDER, NEVER HIDING. Every item given comes back once. "A feature is
//  never hidden" (CLAUDE.md); which rows exist is the tools terminal's call.
//
//  ⚠️ ONLY A REAL WEEK. With no due date the week is the week-20 stand-in, so
//  [week] is null and nothing moves.
//
//  Pure on purpose: a week in, a list out, so a test pins every week without
//  building the screen.
// =============================================================================

/// From this week "Get ready" leads the tab, and the kick counter is in its
/// time: the third trimester, when the Getting ready door turns to the bag
/// and the home, and when a mother is asked to know her baby's usual pattern
/// of movements and to call the same day if it changes (NHS; RCOG GTG 57).
const int kPregToolsThirdTrimesterFrom = 28;

/// From this week the contraction timer leads its group: term, the week the
/// Labour door opens on the timer (`pv_door_labour.dart`, Batch 2).
const int kPregToolsTimerFrom = 37;

/// 0 leads, 1 keeps its place, 2 waits. [fromWeek] null, or no real [week]:
/// 1. With [liftOnly] an item before its week keeps its place instead of
/// waiting.
int pregToolWeekTier(int? fromWeek, int? week, {bool liftOnly = false}) {
  if (fromWeek == null || week == null) return 1;
  if (week >= fromWeek) return 0;
  return liftOnly ? 1 : 2;
}

/// [items] in the order the tab shows them at [week]: a stable sort on
/// [pregToolWeekTier], so inside a tier the order given (her onboarding
/// answers first, then the list's own) stands.
List<T> orderPregToolsByWeek<T>(
  List<T> items,
  int? Function(T) fromWeek, {
  required int? week,
  bool liftOnly = false,
}) {
  final scored = [
    for (var i = 0; i < items.length; i++)
      (pregToolWeekTier(fromWeek(items[i]), week, liftOnly: liftOnly), i, items[i]),
  ]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  return [for (final s in scored) s.$3];
}
