// =============================================================================
//  Getting ready, checked against the brief that specified it
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS BECAUSE FOUR FORMATS SHIPPED WRONG AND WERE FOUND BY EYE.
//
//  `getting_ready_rebuild.pdf` gives a format for every row. Four were built as
//  "the nearest existing surface" instead:
//
//    * "Folic acid and preconception supplements" — Product, built as Tool, and
//      the tool it pointed at was the supplements TRACKER. A card about what to
//      buy opened a record of what she took today.
//    * "Track what you're working on" — Tool, built as Do.
//    * "Your pre-pregnancy checklist" — Checklist, built as Tool.
//    * "Talk to someone before you start" — Talk, built as Booking.
//
//  Every existing test passed throughout. `ttc_focus_page_test.dart` checks
//  that ids resolve, that blurbs exist and that formats are handled — all true
//  of a tile pointing confidently at the wrong screen. Reachability tests
//  cannot see a WRONG destination, only a missing one.
//
//  So this file transcribes the brief and compares. It is deliberately dull and
//  deliberately duplicative of the door file: the point is that the expected
//  value comes from the PDF rather than from the code, so the code cannot
//  quietly become its own specification.
//
//  ⚠️ IF THE PRODUCT CHANGES ON PURPOSE, CHANGE THIS TABLE AND SAY SO IN THE
//  COMMIT. A failure here is either a regression or a decision; it must never
//  be edited to match the code without one of those two sentences attached.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/focus/ttc_focus_getting_ready.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_products_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// The brief's own table: tab, title, format.
const _brief = <(String, String, TtcTileFormat)>[
  // 1) Diet and supplements
  // ⚠️ CHANGED ON PURPOSE 2026-09-27 (relevance audit). "The three months
  // before" moved to Before you start and the eating question now opens the
  // same read at "What should I eat?"; "What to cut before trying" moved to
  // Weight and habits; "Eating, day to day" came off, because Meal plan's
  // "Plan your own week" opens the same tool. Kept for revert:
  // ('diet', 'The three months before', TtcTileFormat.article),
  // ('diet', 'Eating, day to day', TtcTileFormat.tool),
  // ('diet', 'What to cut before trying', TtcTileFormat.article),
  ('diet', 'What to eat and avoid', TtcTileFormat.article),
  ('diet', 'Folic acid and preconception supplements', TtcTileFormat.product),
  ('diet', 'When to start what, and how early', TtcTileFormat.article),

  // 1b) Meal plan — ADDED ON PURPOSE 2026-09-26, from the TTC gap analysis
  // (docs/TTC-GAP-PLAN.md §3 A, "Getting ready › Meal plan"). A decision, not
  // a drift: the gap analysis is now the brief for this door.
  ('meals', 'A week of Indian meals for trying', TtcTileFormat.article),
  ('meals', 'Ten everyday recipes', TtcTileFormat.article),
  ('meals', 'Plan your own week', TtcTileFormat.tool),
  ('meals', 'Iron before pregnancy', TtcTileFormat.article),
  ('meals', 'Omega-3 without fish', TtcTileFormat.article),
  ('meals', 'Ask a dietitian: ten questions', TtcTileFormat.article),

  // 2) Tests and vaccines
  ('tests', 'Tests and vaccines worth doing first', TtcTileFormat.article),
  ('tests', 'The carrier screening that matters in India',
      TtcTileFormat.guide),
  ('tests', 'Check your vaccinations', TtcTileFormat.tool),
  ('tests', 'The full test library', TtcTileFormat.tool),

  // 3) Weight and habits
  ('habits', 'Weight before pregnancy, said kindly', TtcTileFormat.article),
  ('habits', 'Habits worth building now', TtcTileFormat.practice),
  ('habits', "Track what you're working on", TtcTileFormat.tool),
  // Moved here from diet, 2026-09-27 (relevance audit).
  ('habits', 'What to cut before trying', TtcTileFormat.article),

  // 4) Before you start
  // Moved here from diet, 2026-09-27 (relevance audit).
  ('before', 'The three months before', TtcTileFormat.article),
  ('before', 'Coming off birth control', TtcTileFormat.article),
  ('before', 'Medicines and conditions to check with a doctor',
      TtcTileFormat.article),
  ('before', 'His part', TtcTileFormat.article),
  // ADDED ON PURPOSE 2026-09-26, same source as the meal plan rows above.
  ('before', 'Your first gynaecologist visit', TtcTileFormat.article),
  ('before', 'Can a past abortion affect trying now?', TtcTileFormat.article),
  ('before', 'Money before a baby', TtcTileFormat.article),

  // 5) Your checklist
  ('checklist', 'Your pre-pregnancy checklist', TtcTileFormat.checklist),
  ('checklist', 'Talk to someone before you start', TtcTileFormat.talk),
  // ADDED ON PURPOSE 2026-09-27 (relevance audit): the consults shelf has no
  // nutritionist, so the one Talk tile promised a person it could not open.
  ('checklist', 'Talk to a nutritionist', TtcTileFormat.talk),
];

void main() {
  final page = kTtcGettingReadyFocus;

  /// Every tile, with the group of the section it sits in.
  List<(String, TtcTile)> tiles() => [
        for (final s in page.sections)
          for (final t in s.tiles) (s.group ?? '', t),
      ];

  // ===========================================================================
  group('every row the brief specifies is on the page, in its own format', () {
    for (final (group, title, format) in _brief) {
      test('$group · $title → ${format.label}', () {
        final match = tiles().where((e) => e.$2.title == title).toList();
        expect(match, hasLength(1),
            reason: 'the brief asks for a tile called "$title" and the page '
                'has ${match.length}');
        expect(match.first.$1, group,
            reason: '"$title" belongs in the "$group" tab');
        expect(match.first.$2.format, format,
            reason: '"$title" is a ${match.first.$2.format.label} and the '
                'brief says ${format.label}. A chip is the promise about what '
                'happens when she taps it.');
      });
    }
  });

  // ===========================================================================
  //  ⚠️ THE ASSERTION THAT WAS MISSING, AND IT IS THE ONE THAT MATTERED.
  //
  //  The group above checks that every row the brief asks for is PRESENT and
  //  correctly formatted. It passed the whole time — while the door carried
  //  four tiles the brief never lists: two films, a records tile and a stress
  //  article. "Everything specified is here" and "nothing else is here" are
  //  different claims, and only the first was being made.
  //
  //  Each addition had a reasonable argument behind it. That is exactly why
  //  the count has to be asserted rather than trusted: a plausible reason is
  //  precisely what makes an unrequested tile survive review.
  // ===========================================================================
  group('and nothing the brief did not ask for', () {
    test("the page carries exactly the brief's rows, no more", () {
      final built = tiles().map((e) => e.$2.title).toSet();
      final asked = _brief.map((b) => b.$2).toSet();
      final extra = built.difference(asked);
      expect(extra, isEmpty,
          reason: 'these are on the page and not in the brief: $extra. If one '
              'of them belongs, add it to the table above and say so in the '
              'commit — do not delete this expectation.');
    });

    test('and each section holds exactly its own rows', () {
      final want = <String, int>{};
      for (final (group, _, _) in _brief) {
        want[group] = (want[group] ?? 0) + 1;
      }
      final got = <String, int>{};
      for (final (group, _) in tiles()) {
        got[group] = (got[group] ?? 0) + 1;
      }
      expect(got, want);
    });
  });

  // ===========================================================================
  group('the four that shipped wrong, each held individually', () {
    test('the supplements card opens the SHELF, not the tracker', () {
      // The specific failure: `ttc_supplements` is the tracker — "a record of
      // what they actually take, and whether they took it today". A product
      // card must not land there.
      final tile = tiles()
          .map((e) => e.$2)
          .whereType<TtcProductTile>()
          .firstWhere((t) => t.title.startsWith('Folic acid and'));
      expect(tile.category, 'supplements',
          reason: 'it must open the supplements shelf');
      expect(tile.productId, isNull,
          reason: 'a shelf tile names a category, never one product');
      expect(ttcProductsIn('supplements'), isNotEmpty,
          reason: 'the shelf it opens has nothing on it');
    });

    test('and the tracker is NOT on this section — the brief lists two rows',
        () {
      // ⚠️ THIS TEST ASSERTED THE OPPOSITE AND WAS WRONG. I had added the
      // supplements tracker back as a third card "as itself", and wrote a test
      // requiring it — which is how a decision nobody asked for becomes a
      // rule. The brief's Supplements section is two rows: one Product, one
      // Article. The tracker is a real screen and it is reachable from the
      // Tools hub; "it would be useful here" is not "the brief asks for it".
      //
      // Third time a third card appeared in this section. Hence a test.
      final section = page.sections
          .firstWhere((s) => s.heading == 'Supplements');
      expect(section.tiles, hasLength(2),
          reason: 'the brief lists exactly two rows under Supplements');
      expect(
          section.tiles.map((t) => t.format),
          containsAll(<TtcTileFormat>[
            TtcTileFormat.product,
            TtcTileFormat.article,
          ]));
      expect(
          section.tiles.whereType<TtcToolTile>(), isEmpty,
          reason: 'no tool belongs on this section');
    });

    test('the habit practice and the habit tracker are different formats', () {
      final practice = tiles()
          .map((e) => e.$2)
          .firstWhere((t) => t.title == 'Habits worth building now');
      final tracker = tiles()
          .map((e) => e.$2)
          .firstWhere((t) => t.title == "Track what you're working on");
      expect(practice.format, TtcTileFormat.practice);
      expect(tracker.format, TtcTileFormat.tool);
    });

    test('the page still closes on a person', () {
      final last = page.sections.last.tiles.last;
      expect(last, isA<TtcTalkTile>());
    });
  });

  // ===========================================================================
  group('and everything it opens exists', () {
    test('every surface resolves', () {
      for (final (_, tile) in tiles()) {
        final id = switch (tile) {
          TtcToolTile(:final surfaceId) => surfaceId,
          TtcChecklistTile(:final surfaceId) => surfaceId,
          TtcDoTile(:final surfaceId) => surfaceId,
          _ => null,
        };
        // A guide resolves against the read library, not the router.
        if (tile is TtcGuideTile) {
          expect(ttcReadById(tile.readId), isNotNull,
              reason: '"${tile.title}" opens read "${tile.readId}", which is '
                  'not in the library');
        }
        if (id == null) continue;
        expect(ttcScreenForSurface(id), isNotNull,
            reason: '"${tile.title}" opens "$id", which the router does not '
                'resolve');
      }
    });

    test('every product tile names a real category or a real product', () {
      final cats = ttcProductCategories.map((c) => c.$1).toSet();
      for (final tile in tiles().map((e) => e.$2).whereType<TtcProductTile>()) {
        if (tile.category != null) {
          expect(cats, contains(tile.category), reason: tile.title);
        } else {
          expect(ttcProducts.any((p) => p.id == tile.productId), isTrue,
              reason: tile.title);
        }
      }
    });
  });
}
