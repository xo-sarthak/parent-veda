// Relevance Batch 3 (2026-10-27): TTC doors open on the right KIND of thing.
// GLOBAL-CHANGES #16: an information door teaches first; an action door opens
// on the activity. docs/door-relevance/TTC-GAP.md §4, faults 3, 5, 7, 8, 9.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/ttc/focus/ttc_focus_body_cycle.dart';
import 'package:parentveda/ttc/focus/ttc_focus_getting_ready.dart';
import 'package:parentveda/ttc/focus/ttc_focus_ivf.dart' show kTtcIvfStepsGroupId;
import 'package:parentveda/ttc/focus/ttc_focus_mind_body.dart';
import 'package:parentveda/ttc/focus/ttc_focus_not_yet.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

TtcFocusSection _first(TtcFocusPage page, String group) =>
    page.sections.firstWhere((s) => s.group == group);

void main() {
  group('information doors teach first', () {
    test('IVF opens on Understand, and Understand on the plain beginning', () {
      final groups = kTtcIvfFocus.groups!;
      expect(groups.first.id, 'understand');
      final lead = _first(kTtcIvfFocus, 'understand');
      expect(lead.heading, 'What are IVF and IUI?');
      final tile = lead.tiles.first as TtcArticleTile;
      expect(tile.readId, 'ttc_read_ivf_iui_beginning');
    });

    test('during a round, Step by step still leads (2026-10-22 decision)', () {
      final ordered = ttcDoorOrderedGroups(kTtcIvfFocus.groups!,
          bracketId: kTtcIvfBracketId, ageBand: null, roundRunning: true);
      expect(ordered.first.id, kTtcIvfStepsGroupId);
    });

    test('Body and cycle opens on how a cycle works', () {
      final lead = _first(kTtcBodyCycleFocus, 'cycle');
      final tile = lead.tiles.first as TtcArticleTile;
      expect(tile.readId, 'ttc_read_cycle_phase_by_phase');
    });

    test('both explainers exist, are long, and answer the demand', () {
      for (final id in [
        'ttc_read_ivf_iui_beginning',
        'ttc_read_cycle_phase_by_phase',
      ]) {
        final r = ttcReadById(id);
        expect(r, isNotNull, reason: id);
        expect(r!.assertShape(), isEmpty, reason: id);
        // Written well, not short (user, 2026-10-27): well above the
        // stage's long reads, which run about 1,000 to 1,100 words.
        expect(r.wordCount, greaterThan(1200), reason: id);
      }
      final cycle = ttcReadById('ttc_read_cycle_phase_by_phase')!;
      final heads = cycle.sections.map((s) => s.heading?.en ?? '').join(' ');
      expect(heads, contains('luteal phase'),
          reason: 'the top TTC question (ranked_ttc.csv #1)');
    });
  });

  group('action doors open on the activity', () {
    test('Getting ready opens on the checklist', () {
      expect(kTtcGettingReadyFocus.groups!.first.id, 'checklist');
    });

    test('Not yet opens on the doctor check', () {
      final lead = _first(kTtcNotYetFocus, 'time');
      expect(lead.tiles.first, isA<TtcToolTile>());
      expect((lead.tiles.first as TtcToolTile).surfaceId, 'ttc_fertility_help');
    });

    test('Mind and body: the fixed action headings open a practice', () {
      for (final h in ['Start a daily practice', 'Sleep better while trying']) {
        final s = kTtcMindBodyFocus.sections.firstWhere((s) => s.heading == h);
        final t = s.tiles.first;
        expect(t is TtcDoTile || t is TtcToolTile, isTrue, reason: h);
      }
    });
  });

  test('Conceiving: the best-days card is true on a clinic cycle', () {
    final card = _first(kTtcConceivingFocus, 'trying').tiles.first;
    expect(card.blurb, contains('clinic'));
  });
}
