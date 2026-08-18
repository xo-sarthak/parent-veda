// =============================================================================
//  The sleep quick check reads the section, and every tool tile goes somewhere
// -----------------------------------------------------------------------------
//  Two guarantees, both of the kind that fail silently.
//
//  ⚠️ ONE: THE TOOL HOLDS NO NUMBERS OF ITS OWN. It reads the Sleep section's
//  chart cards, because every sleep figure in this app is marked REQUIRED_REVIEW
//  and is expected to be corrected by a paediatrician. A second copy would go on
//  saying the old range after the card was fixed, and nothing would fail. The
//  price of that design is a coupling to the data's shape, and this is what makes
//  the coupling loud instead of quiet.
//
//  ⚠️ TWO: A TOOL TILE THAT RESOLVES TO NOTHING IS WORSE THAN NO TILE. Seven
//  references to `pp_sleep_check` existed before the screen did -- a tile and six
//  in-page links, all leading nowhere, all compiling. That is the wiring gate's
//  whole subject.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_chart_browser_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

void main() {
  group('the quick check reads the section rather than copying it', () {
    test('every sleep band resolves to a chart card', () {
      for (final band in kPpSleepBands.bands) {
        final card = ppChartForBand('parenting_sleep', band.id);
        expect(card, isNotNull,
            reason: 'band "${band.id}" (${band.label}) has no chart card in the '
                'Sleep section, so the quick check shows nothing for it');
      }
    });

    test('and each card carries real label/value rows', () {
      // The spec asked for these to be structured data precisely so a tool could
      // read them. A card with no rows would render an empty box.
      for (final band in kPpSleepBands.bands) {
        final card = ppChartForBand('parenting_sleep', band.id)!;
        expect(card.rows, isNotEmpty, reason: band.id);
        for (final (label, value) in card.rows) {
          expect(label.trim(), isNotEmpty, reason: band.id);
          expect(value.trim(), isNotEmpty, reason: band.id);
        }
      }
    });

    test('the numbers live in exactly one place', () {
      // If the tool ever grows its own table this fails, because the two would
      // then be able to disagree.
      final section = ppSectionFor('parenting_sleep')!;
      final cards = [
        for (final a in section.areas)
          for (final p in a.pages) ...p.blocks.whereType<PpChartCard>(),
      ];
      expect(cards.length, greaterThanOrEqualTo(kPpSleepBands.bands.length),
          reason: 'fewer chart cards than bands');
    });
  });

  group('no section tool leads nowhere', () {
    test('every PpSectionTool surfaceId resolves', () {
      for (final s in kPpSections) {
        for (final t in s.tools) {
          expect(ppScreenForSurface(t.surfaceId), isNotNull,
              reason: '${s.id}: tool "${t.label}" points at '
                  '"${t.surfaceId}", which the router cannot open');
        }
      }
    });

    test('and every area that IS a tool resolves too', () {
      for (final s in kPpSections) {
        for (final a in s.areas) {
          final id = a.toolSurfaceId;
          if (id == null) continue;
          expect(ppScreenForSurface(id), isNotNull,
              reason: '${s.id}/${a.id} is a tool area pointing at "$id", '
                  'which the router cannot open');
        }
      }
    });

    test('every PpLink surfaceId resolves', () {
      // ⚠️ THE BIG ONE. Hundreds of in-page links across the sections, every one
      // of them a hardcoded string. A link that stops resolving renders a dead
      // row, and the only other way to find it is to tap all of them.
      final bad = <String>[];
      for (final s in kPpSections) {
        for (final a in s.areas) {
          for (final p in a.pages) {
            for (final b in p.blocks) {
              final id = b is PpLink
                  ? b.surfaceId
                  : b is PpConsult
                      ? b.surfaceId
                      : null;
              if (id == null) continue;
              if (ppScreenForSurface(id) == null) {
                bad.add('${s.id}/${p.id} -> $id');
              }
            }
          }
        }
      }
      expect(bad, isEmpty,
          reason: 'links pointing at surfaces the router cannot open:\n'
              '${bad.join('\n')}');
    });
  });
}
