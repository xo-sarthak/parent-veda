// =============================================================================
//  The pregnancy reads keep their shape
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE ANTI-SHALLOWNESS MECHANISM, and without it the required
//  fields on `PvRead` only guarantee that something was typed into them.
//
//  It is a second file rather than an extension of `pv_read_shape_test.dart`
//  for one reason: that one walks `kTtcReads` and is edited by whoever is
//  building a TTC door. Two stages appending to one test file is the same
//  collision the reads libraries were split to avoid, one layer up.
//
//  The RULES are not duplicated — both files call the same `assertShape()` on
//  the same model, so there is one definition of "deep enough" and two lists
//  walked through it.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';

void main() {
  group('every pregnancy read is deep enough to be worth opening', () {
    test('none fails its own shape rules', () {
      final problems = <String>[];
      for (final r in kPregnancyReads) {
        problems.addAll(r.assertShape());
      }
      expect(problems, isEmpty,
          reason: 'These reads are not ready:\n  ${problems.join('\n  ')}');
    });

    test('ids are unique', () {
      final ids = kPregnancyReads.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'A duplicate id means one article is unreachable — the '
              'lookup returns the first match and the second never opens.');
    });

    test('the library is not empty', () {
      // Guards the reverse mistake: a passing suite over zero articles proves
      // nothing, and every assertion above is vacuously true on an empty list.
      expect(kPregnancyReads, isNotEmpty);
    });

    test('every readNext id resolves', () {
      // ⚠️ A DEAD LINK IN A CHAIN RENDERS NOTHING AND REPORTS NOTHING. The
      // reader drops a card whose id does not resolve, which is the right
      // behaviour for a user and invisible to everyone else — so the end of an
      // article quietly loses its onward route and no test, analyzer or crash
      // ever mentions it.
      final missing = <String>[];
      for (final r in kPregnancyReads) {
        for (final id in r.readNext) {
          if (pregnancyReadById(id) == null) missing.add('${r.id} → $id');
        }
      }
      expect(missing, isEmpty,
          reason: 'read-next links pointing nowhere:\n  '
              '${missing.join('\n  ')}');
    });

    test('nothing links to itself', () {
      for (final r in kPregnancyReads) {
        expect(r.readNext, isNot(contains(r.id)),
            reason: '${r.id} offers itself as the next thing to read.');
      }
    });
  });

  group('the clinical floor', () {
    test('every read carries a named source', () {
      // Required by `assertShape` too, but asserted here in its own words
      // because it is the rule most likely to be relaxed under time pressure.
      // An unsourced claim in pregnancy content is indistinguishable from the
      // content this product exists to replace.
      for (final r in kPregnancyReads) {
        expect(r.evidence, isNotNull, reason: '${r.id} has no evidence note.');
        expect(r.evidence!.en.trim(), isNotEmpty);
      }
    });

    test('no read attaches a probability to the reader', () {
      // ⚠️ CLAUDE.md: never a personalised probability. Population statistics
      // stay allowed where they reduce pressure rather than set a target; what
      // is banned is a possessive next to a chance word.
      //
      // ⚠️ THE SHAPE IS DESCRIBED, NOT ASSEMBLED. Spelling a banned phrase out
      // here — even to test for it — puts one copy of it in the repo, one
      // paste away from being a string. The scanner therefore looks for the
      // pattern rather than for a list of examples.
      final possessive = RegExp(r'\byour\b', caseSensitive: false);
      final chance =
          RegExp(r'\b(chance|odds|risk|likelihood|probability)\b',
              caseSensitive: false);

      final hits = <String>[];
      for (final r in kPregnancyReads) {
        for (final s in r.sections) {
          for (final para in [
            ...s.paragraphs.map((t) => t.en),
            ...s.bullets.map((t) => t.en),
          ]) {
            for (final sentence in para.split(RegExp(r'(?<=[.!?])\s+'))) {
              if (possessive.hasMatch(sentence) &&
                  chance.hasMatch(sentence)) {
                hits.add('${r.id}: $sentence');
              }
            }
          }
        }
      }
      expect(hits, isEmpty,
          reason: 'A possessive beside a chance word reads as a probability '
              'about this reader:\n  ${hits.join('\n  ')}');
    });

    test('every read ends at a person', () {
      for (final r in kPregnancyReads) {
        expect(r.whenToSeeSomeone.body.en.trim(), isNotEmpty,
            reason: '${r.id} has an empty when-to-see-someone.');
      }
    });
  });
}
