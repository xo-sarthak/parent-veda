// =============================================================================
//  Age phases — the structure has to hold before the content matters
// -----------------------------------------------------------------------------
//  These replaced the Wonder Weeks leaps, which failed replication. The point of
//  the change is evidence-alignment, so the tests check the things that make it
//  defensible: no gaps, no overlaps, AAP checkpoints present, and every phase
//  carrying the honesty that stops a milestone list reading as a deadline.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';

void main() {
  group('the age range is covered exactly once', () {
    test('phases are contiguous from birth to five years', () {
      expect(kPhases.first.startMonth, 0);
      expect(kPhases.last.endMonth, 60);
      for (var i = 1; i < kPhases.length; i++) {
        expect(
          kPhases[i].startMonth,
          kPhases[i - 1].endMonth,
          reason: 'gap or overlap between "${kPhases[i - 1].name}" and '
              '"${kPhases[i].name}" — the source document had exactly this '
              'problem at 31–35 months',
        );
      }
    });

    test('every month from 0 to 59 lands in exactly one phase', () {
      for (var m = 0; m < 60; m++) {
        final hits = kPhases.where((p) => p.covers(m.toDouble())).length;
        expect(hits, 1, reason: 'month $m matched $hits phases');
      }
    });

    test('lookup clamps rather than crashing outside the range', () {
      expect(() => phaseIndexForMonths(-3), returnsNormally);
      expect(() => phaseIndexForMonths(200), returnsNormally);
      expect(phaseIndexForMonths(200), kPhases.length - 1);
    });

    test('phase numbers are sequential', () {
      for (var i = 0; i < kPhases.length; i++) {
        expect(kPhases[i].number, i + 1);
      }
    });
  });

  group('it follows the AAP framework it claims to', () {
    test('the AAP well-visit checkpoints all exist as phases', () {
      // 2m, 4m, 6m, 9m, 12m, 15m, 18m, 24m, 30m, 4y, 5y.
      for (final m in [2, 4, 6, 9, 12, 15, 18, 24, 30, 48, 59]) {
        final p = kPhases[phaseIndexForMonths(m.toDouble())];
        expect(p.checkpoint, isTrue,
            reason: 'month $m is an AAP checkpoint but lands in "${p.name}", '
                'which is not marked as one');
      }
    });

    test('the universal screening points carry a screening note', () {
      // AAP recommends developmental screening at 9, 18 and 30 months, and
      // autism-specific screening at 18 and 24 months.
      for (final m in [9, 18, 24, 30]) {
        final p = kPhases[phaseIndexForMonths(m.toDouble())];
        expect(p.screeningNote, isNotNull,
            reason: 'month $m is a screening point but "${p.name}" says nothing '
                'about it');
      }
    });

    test('milestones are spread across the five AAP domains', () {
      final used = <PhaseDomain>{};
      for (final p in kPhases) {
        for (final m in p.milestones) {
          used.add(m.domain);
        }
      }
      expect(used.length, PhaseDomain.values.length,
          reason: 'AAP organises milestones under five domains; some are unused');
    });
  });

  group('nothing here reads as a deadline', () {
    test('every phase has a reassurance line', () {
      for (final p in kPhases) {
        expect(p.reassurance.trim(), isNotEmpty,
            reason: '"${p.name}" has no reassurance — a milestone list without '
                'one reads as a test the child can fail');
      }
    });

    test('every phase says where its boundary came from', () {
      for (final p in kPhases) {
        expect(p.source.trim(), isNotEmpty,
            reason: '"${p.name}" cites no source, so we cannot defend it');
      }
    });

    test('no phase is named after a number', () {
      // "Leap 5" for every baby at the same week was the thing this replaced.
      for (final p in kPhases) {
        expect(p.name.toLowerCase(), isNot(contains('phase ')),
            reason: '"${p.name}" names a number rather than what is happening');
        expect(p.name.toLowerCase(), isNot(contains('leap')));
      }
    });

    test('every phase has milestones and something to work on', () {
      for (final p in kPhases) {
        expect(p.milestones, isNotEmpty, reason: '"${p.name}" has no milestones');
        expect(p.workingOn, isNotEmpty, reason: '"${p.name}" has nothing to work on');
      }
    });
  });

  group('journey progress', () {
    test('runs 0 to 1 across the whole five years', () {
      expect(kPhases.first.progressAt(0), 0);
      expect(kPhases.last.progressAt(60), 1);
    });

    test('a phase reports progress within itself, clamped', () {
      final p = kPhases[phaseIndexForMonths(6)];
      expect(p.progressAt(p.startMonth), 0);
      expect(p.progressAt(p.endMonth + 99), 1);
    });
  });
}
