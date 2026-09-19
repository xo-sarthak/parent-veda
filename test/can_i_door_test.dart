// =============================================================================
//  Is it safe? door — 2026-09-19
// -----------------------------------------------------------------------------
//  What this pins, and why each line exists:
//
//   1. Every entry sits in exactly one group — a new entry cannot ship
//      ungrouped (it would be reachable by search and invisible on a shelf).
//   2. A swap is always safe, never the entry itself, and never empty under
//      an Avoid — the "no" that ends in nothing is the failure the rail exists
//      to prevent.
//   3. The trimester note chosen is hers — weeks 1–13 / 14–27 / 28+.
//   4. The read the reader opens: verdict block first, swaps only when there
//      are some, "also asked" never repeats a swap.
//   5. The matcher: a product name lands on the entry it means, a brand word
//      does not, an unknown thing is null (never a guess).
//   6. Reachability — the home surface opens the door body, the door body
//      reaches scan and snap, the answer opens in the one reader. Test counts
//      are not evidence a feature is reachable; the source is.
//   7. The misses contract: the columns the client writes exist in 0086.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/can_i_data.dart';
import 'package:parentveda/data/can_i_groups.dart';
import 'package:parentveda/data/reads/can_i_read.dart';
import 'package:parentveda/models/can_i_entry.dart';
import 'package:parentveda/screens/can_i/can_i_identify.dart';
import 'package:parentveda/services/can_i_activity_store.dart';

void main() {
  group('groups', () {
    test('every entry is in exactly one group, every grouped id exists', () {
      final seen = <String, int>{};
      for (final g in kCanIGroups) {
        for (final id in g.entryIds) {
          seen[id] = (seen[id] ?? 0) + 1;
          expect(canIById(id), isNotNull, reason: '$id in group ${g.id} is not an entry');
          expect(canIById(id)!.category, g.category, reason: '$id is filed under the wrong category');
        }
      }
      for (final e in kCanIEntries) {
        expect(seen[e.id], 1, reason: '${e.id} is in ${seen[e.id] ?? 0} groups, needs exactly 1');
      }
    });

    test('the asked-most dozen exist and are twelve', () {
      expect(kCanIAskedMost.length, 12);
      for (final id in kCanIAskedMost) {
        expect(canIById(id), isNotNull, reason: id);
      }
    });
  });

  group('swaps', () {
    test('a swap is safe, is not the entry, and an Avoid always has one', () {
      for (final e in kCanIEntries) {
        final swaps = canIInsteadOf(e);
        for (final s in swaps) {
          expect(s.verdict, CanIVerdict.safe, reason: '${e.id} -> ${s.id}');
          expect(s.id, isNot(e.id));
        }
        if (e.verdict == CanIVerdict.safe) {
          expect(swaps, isEmpty, reason: '${e.id} is safe; nothing to swap it for');
        } else {
          expect(swaps, isNotEmpty, reason: '${e.id} (${e.verdict.name}) has no swap');
        }
      }
    });
  });

  group('her week', () {
    test('the note chosen follows the trimester', () {
      final e = kCanIEntries.firstWhere((x) => x.t1 != null && x.t3 != null);
      expect(canINoteForWeek(e, 8), e.t1);
      expect(canINoteForWeek(e, 20), e.t2);
      expect(canINoteForWeek(e, 30), e.t3);
      expect(canITrimester(13), 1);
      expect(canITrimester(14), 2);
      expect(canITrimester(28), 3);
    });
  });

  group('the read', () {
    test('verdict first, swaps only when there are some, also-asked never repeats a swap', () {
      for (final e in kCanIEntries) {
        final r = pvReadFromCanI(e, week: 20);
        expect(r.id, 'cani_${e.id}');
        expect(r.sections.first.custom, isA<PvCanIVerdictBlock>());
        final instead = r.sections.where((s) => s.custom is PvCanIInsteadBlock).length;
        expect(instead, canIInsteadOf(e).isEmpty ? 0 : 1, reason: e.id);
        expect(r.sections.last.custom, isA<PvCanIDoctorBlock>());
        final swapIds = {for (final s in canIInsteadOf(e)) 'cani_${s.id}'};
        for (final id in r.readNext) {
          expect(swapIds.contains(id), isFalse, reason: '${e.id}: $id is both a swap and also-asked');
        }
        expect(r.nextSteps.any((s) => s.action == 'cani_share'), isTrue);
        expect(r.nextSteps.any((s) => s.action == 'cani_askveda'), isTrue);
      }
    });

    test('with no week there is no personal line', () {
      final e = kCanIEntries.firstWhere((x) => x.t2 != null);
      final block = pvReadFromCanI(e).sections.first.custom as PvCanIVerdictBlock;
      expect(block.week, isNull);
      expect(block.noteForHer, isNull);
    });
  });

  group('matching', () {
    test('a product name lands on the entry it means', () {
      expect(canIMatch('Maggi 2-Minute Masala Noodles · Nestlé')?.id, 'instant_noodles');
      expect(canIMatch('Tender coconut water 200ml')?.id, 'coconut_water');
      expect(canIMatch('Amul Paneer 200g')?.id, 'paneer');
      expect(canIMatch('Crocin 500')?.id, 'paracetamol');
    });

    test('nothing recognisable is null, never a guess', () {
      expect(canIMatch('Parle-G Glucose Biscuits 800g'), isNull);
      expect(canIMatch(''), isNull);
    });

    test('the field matches on word starts, not on what a word contains', () {
      final ids = canIFind('pa').map((e) => e.id).toList();
      expect(ids, containsAll(['papaya', 'paneer', 'paracetamol']));
      expect(canIFind('nt'), isEmpty);
      expect(canIFind('papita').map((e) => e.id), contains('papaya'));
    });
  });

  group('reachability', () {
    final screen = File('lib/screens/can_i_screen.dart').readAsStringSync();
    final door = File('lib/screens/can_i/can_i_door.dart').readAsStringSync();
    final router = File('lib/services/surface_router.dart').readAsStringSync();
    final saved = File('lib/screens/saved_screen.dart').readAsStringSync();

    test('the can_i surface opens CanIScreen, whose build is the door body', () {
      expect(router, contains("'can_i' => CanIScreen(controller: c)"));
      expect(screen, contains('Widget build(BuildContext context) => CanIDoorBody(controller: controller);'));
    });

    test('the door reaches scan, snap, the shelves and the answer', () {
      expect(door, contains('openCanIScan(context, widget.controller)'));
      expect(door, contains('_chooseCamera'));
      expect(door, contains('canISnap(context, widget.controller)'));
      expect(door, contains('CanIGroupScreen(category: cat'));
      expect(door, contains('openCanIAnswer(context, e, widget.controller)'));
    });

    test('an answer opens the verdict page, not the reader', () {
      final answer = File('lib/screens/can_i/can_i_answer.dart').readAsStringSync();
      expect(answer, contains('const bool kCanIAnswerAsVerdict = true;'));
      expect(answer, contains('CanIVerdictScreen(entry: entry, controller: c)'));
    });

    test('the saved screen still opens the same answer', () {
      expect(saved, contains("import 'can_i_screen.dart' show openCanIAnswer;"));
      expect(screen, contains('door.openCanIAnswer(context, entry, c)'));
    });
  });

  group('the misses contract', () {
    test('every column the client writes exists in 0086', () {
      final sql = File('supabase/migrations/0086_can_i_misses.sql').readAsStringSync();
      expect(sql, contains('create table if not exists public.${CanIActivityStore.missesTable}'));
      for (final c in CanIActivityStore.missesColumns) {
        expect(RegExp('^\\s+$c\\s', multiLine: true).hasMatch(sql), isTrue, reason: 'column $c');
      }
      for (final s in ['typed', 'barcode', 'photo']) {
        expect(sql, contains("'$s'"));
      }
    });
  });
}
