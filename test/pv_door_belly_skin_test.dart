// =============================================================================
//  The Belly & skin door reuses the whole area, and keeps four tabs
// -----------------------------------------------------------------------------
//  The reachability gates live in `pv_door_scans_test.dart`, which walks
//  `kPvDoorPages`; this door inherited them on registration.
//
//  What is here is the two things specific to this brief:
//
//    · **Coverage.** Its map says *"the cards named are the visible ones, not
//      the full inventory"* and *"+ any other reads already built, reuse in
//      place."* So the rails are built FROM `kBsPages` and these tests assert
//      the door shows every page in each area — a door that shows eighteen of
//      nineteen is not broken, it has just made one page unreachable.
//    · **The two retitles**, which are the only content change in the area.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/belly_skin_data.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

/// Every entry tile on the door from the belly-skin library, by section.
List<String> _idsIn(PvDoorPage door, String heading) => [
      for (final s in door.sections)
        if (s.heading == heading)
          for (final t in s.tiles)
            if (t is PvDoorEntryTile) t.entryId,
    ];

void main() {
  late PvDoorPage door;
  setUp(() => door = pvDoorPageFor('pregnancy_belly_skin')!);

  group('four tabs, and the fourth is the keepsake', () {
    test('four, not five, and Skin changes is first', () {
      // ⚠️ THE FIRST BRIEF TO ARGUE AGAINST THE SHAPE. There is no paid consult
      // in this area and one medical flag, which the brief keeps inside the
      // Itching read rather than pulling onto a thin Talk tab. A fifth tab
      // built to match the other doors would be the content-management view of
      // a product.
      expect(door.groups.length, 4);
      expect(door.groups.first.id, kBsTabSkin);
      expect(door.groups.map((g) => g.label), [
        'Skin changes',
        "What's safe to use",
        'Belly care',
        'The bump ritual',
      ]);
    });

    test('the keepsake is the tab, not a card that opens it', () {
      final g = door.groups.firstWhere((g) => g.id == kBsTabRitual);
      expect(g.inlineSurfaceId, kBsSurfaceRitual);
      expect(g.layout, PvDoorLayout.stack);
      expect(door.sectionsOf(kBsTabRitual), isEmpty);
    });

    test('no pinned red flag anywhere, and the absence is the decision', () {
      // The one real warning in this area — intense itching of the palms and
      // soles with no rash — lives inside `BsItchingScreen`, where somebody
      // reading about itching meets it. A woman reading about stretch marks
      // does not need it above her rail.
      for (final g in door.groups) {
        expect(g.pinnedRedFlag, isNull, reason: '${g.label} pins a flag.');
      }
    });

    test('an even ring still shows every card', () {
      // ⚠️ THIS IS THE ONE THAT WOULD HAVE SHIPPED BROKEN. On a five-ring no
      // card ever rests at the seam; on a four-ring one always does, and the
      // carousel's seam fade rendered it at zero — three cards under four dots.
      // The render test catches the drawing; this catches the arithmetic.
      expect(door.groups.length.isEven, isTrue,
          reason: 'if this door ever gains a fifth tab, the even-ring branch '
              'in pv_door_carousel.dart is no longer exercised by anything.');
    });
  });

  group('the whole area is on the door', () {
    test('every stretch-mark read', () {
      final want = [
        for (final p in kBsPages)
          if (p.area == BsArea.stretchMarks) p.id,
      ];
      expect(_idsIn(door, 'Stretch marks'), want);
    });

    test('every pigmentation read', () {
      final want = [
        for (final p in kBsPages)
          if (p.area == BsArea.pigmentation) p.id,
      ];
      expect(_idsIn(door, 'Pigmentation and skin changes'), want);
    });

    test('every safe-skincare read', () {
      final want = [
        for (final p in kBsPages)
          if (p.area == BsArea.safeSkincare) p.id,
      ];
      expect(_idsIn(door, 'Safe skincare'), want);
    });

    test('every belly-care read', () {
      final want = [
        for (final p in kBsPages)
          if (p.area == BsArea.bellyCare) p.id,
      ];
      expect(_idsIn(door, 'Oiling, support and comfort'), want);
    });

    test('nothing in kBsPages is unreachable from this door', () {
      // ⚠️ THE COVERAGE CLAIM, STATED ONCE OVER THE WHOLE LIBRARY. The four
      // assertions above check each rail against its area; this checks that
      // between them they account for every page. Add a page in a fifth area
      // and this fails — which is correct, because that area has no rail.
      final onDoor = {
        for (final t in door.allTiles)
          if (t is PvDoorEntryTile && t.library == PvDoorLibrary.bellySkin)
            t.entryId,
      };
      expect(onDoor, kBsPages.map((p) => p.id).toSet());
    });

    test('the checker and the itching read are each one card', () {
      // ⚠️ NO SECOND CHECKER. The brief's boundary: the Ingredient Safety
      // Checker owns skincare and salon verdicts, and the Can I? area
      // references it rather than answering. Two cards here would be the first
      // step toward two checkers.
      final surfaces = [
        for (final t in door.allTiles)
          if (t is PvDoorToolTile) t.surfaceId,
      ];
      expect(surfaces.where((s) => s == kBsSurfaceChecker).length, 1);
      expect(surfaces.where((s) => s == kBsSurfaceItching).length, 1);
    });
  });

  group('the only content change is two titles', () {
    test('both are plain-first now', () {
      final byId = {for (final p in kBsPages) p.id: p.title.en};
      expect(byId['pg_linea_nigra'], 'The dark line (linea nigra)');
      expect(byId['pg_melasma'], 'The pregnancy mask (melasma)');
    });

    test('no page title in the area leads with a medical word', () {
      // The locked rule across the pregnancy briefs: a medical name may follow
      // the plain phrase, in brackets, and never lead it.
      const medical = ['linea nigra', 'melasma'];
      for (final p in kBsPages) {
        final lower = p.title.en.toLowerCase();
        for (final w in medical) {
          final at = lower.indexOf(w);
          if (at < 0) continue;
          expect(lower.substring(0, at), contains('('),
              reason: '"${p.title.en}" leads with "$w".');
        }
      }
    });

    test('the door writes no read of its own', () {
      // ⚠️ THE REUSE RULE, AS A COUNT. This area's brief is the strictest of
      // the four so far — "the ONLY change to content is two retitles" — so a
      // guide tile here means somebody wrote an article on a door that was
      // supposed to write none.
      for (final t in door.allTiles) {
        expect(t, isNot(isA<PvDoorGuideTile>()),
            reason: '"${t.title}" is a new read on a reuse-only door.');
        expect(t, isNot(isA<PvDoorMythTile>()));
      }
    });

    test('every card line is the page\'s own', () {
      // The blurbs come from `videoSubtitle`, which is where the brief's own
      // map was written from. If a card's line is not the page's line,
      // somebody has typed copy onto the door.
      final byId = {for (final p in kBsPages) p.id: p};
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.bellySkin) {
          continue;
        }
        final page = byId[t.entryId]!;
        expect(t.blurb, page.videoSubtitle?.en ?? page.videoTitle.en,
            reason: '"${t.title}" carries a line the page does not.');
        expect(t.title, page.title.en);
      }
    });
  });

  group('every surface builds', () {
    test('inline where a tab declares one, and pushed either way', () {
      final c = PregnancyController();
      for (final g in door.groups) {
        if (g.inlineSurfaceId case final s?) {
          expect(pvDoorInlineToolFor(s, c), isNotNull,
              reason: 'tab "${g.label}" declares inline "$s".');
          expect(pvDoorScreenFor(s, c), isNotNull,
              reason: '"$s" renders inline and cannot be pushed.');
        }
      }
      for (final t in door.allTiles) {
        if (t is PvDoorToolTile) {
          expect(pvDoorScreenFor(t.surfaceId, c), isNotNull,
              reason: '"${t.title}" opens nothing.');
        }
      }
    });

    test('every read resolves in the belly-skin library', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile) continue;
        expect(pvDoorEntryResolves(t.library, t.entryId), isTrue,
            reason: '"${t.title}" points at "${t.entryId}".');
      }
    });
  });
}
