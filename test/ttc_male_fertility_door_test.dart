// =============================================================================
//  The Male fertility door: its name, its reads, and the string that joins them
// -----------------------------------------------------------------------------
//  docs/MALE-FERTILITY-DOOR-PLAN.md, built 2026-10-29. The door was "His
//  side" until then, which read as his half of the app.
//
//  ⚠️ WHY THIS FILE EXISTS. A read belongs to a door because
//  `read.kicker.en == bracket.label.en`. That string join runs in Learn
//  (shelves, marks, hues), the all-films screen and the home. Rename the
//  label without the kickers and the door's Learn shelf silently empties:
//  it compiles, nothing crashes, and the shelf is simply gone. So the label
//  and every kicker are pinned together here.
//
//  The real fix is joining by bracket id, not by a display string. That is
//  recorded in STILL-OPEN, not done here.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/brackets/ttc_brackets.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart'
    show ttcLearnShelves;
import 'package:parentveda/ttc/focus/ttc_focus_his_side.dart';
import 'package:parentveda/ttc/reads/ttc_reads_his_side.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

void main() {
  final bracket = kTtcBrackets.singleWhere((b) => b.id == 'ttc_male_fertility');

  // The two reads that live in ttc_reads_extra.dart but belong to this door.
  const extraIds = {'ttc_read_his_side_pressure', 'ttc_read_his_age'};

  group('the name', () {
    test('the door is called Male fertility, in both languages', () {
      expect(bracket.label.en, 'Male fertility');
      // The Hindi side was Latin-script Hinglish ('Unki taraf'); it now
      // matches title.hi rather than carrying a defect.
      expect(bracket.label.hi, bracket.title.hi);
    });

    test('the door headline names it', () {
      expect(kTtcHisSideFocus.heroTitle, 'Male fertility, in plain words.');
    });
  });

  group('the join', () {
    test('every read of the door carries the label as its kicker', () {
      for (final r in kTtcReadsHisSide) {
        expect(r.kicker.en, bracket.label.en, reason: r.id);
      }
      for (final id in extraIds) {
        expect(ttcReadById(id)?.kicker.en, bracket.label.en, reason: id);
      }
    });

    test('no read still carries the old name', () {
      final stale = [
        for (final r in kTtcReads)
          if (r.kicker.en == 'His side') r.id,
      ];
      expect(stale, isEmpty);
    });

    test("the door's Learn shelf is there, and holds every one of its reads",
        () {
      final shelf =
          ttcLearnShelves().where((s) => s.bracket?.id == bracket.id).toList();
      expect(shelf, hasLength(1), reason: 'the shelf emptied: kicker != label');
      final onShelf = {for (final r in shelf.single.reads) r.id};
      expect(onShelf, containsAll(kTtcReadsHisSide.map((r) => r.id)));
      expect(onShelf, containsAll(extraIds));
    });
  });

  group('the options read (Step 2)', () {
    test('is in the stage, on the door, after "If no sperm is found"', () {
      final read = ttcReadById('ttc_read_his_options');
      expect(read, isNotNull);
      expect(read!.reviewed, isFalse, reason: 'no sign-off id: the desk byline');

      final tiles = [
        for (final s in kTtcHisSideFocus.sections)
          if (s.group == 'test') ...s.tiles,
      ];
      final ids = [
        for (final t in tiles)
          if (t case TtcArticleTile(:final readId?)) readId,
      ];
      expect(ids, contains('ttc_read_his_options'));
      expect(ids.indexOf('ttc_read_his_options'),
          ids.indexOf('ttc_read_azoospermia') + 1);
    });

    test('names sperm retrieval, which nothing else did', () {
      final text = _all(ttcReadById('ttc_read_his_options')!);
      for (final term in ['PESA', 'TESA', 'Micro-TESE', 'varicocele', 'ICSI']) {
        expect(text, contains(term));
      }
    });

    test("uses the IVF door's prices, not a second set", () {
      final costs = _all(ttcReadById('ttc_read_ivf_costs')!);
      final text = _all(ttcReadById('ttc_read_his_options')!);
      for (final range in [
        '₹15,000 to ₹35,000',
        '₹1.5 to ₹2.5 lakh',
        '₹15,000 to ₹45,000',
      ]) {
        expect(text, contains(range));
        expect(costs, contains(range), reason: '$range left the IVF page');
      }
    });

    test('links to the ICSI and cost pages that exist', () {
      final read = ttcReadById('ttc_read_his_options')!;
      for (final step in read.nextSteps) {
        final id = step.surfaceId!.replaceFirst('ttc_read/', '');
        expect(ttcReadById(id), isNotNull, reason: id);
      }
      for (final id in read.readNext) {
        expect(ttcReadById(id), isNotNull, reason: id);
      }
    });
  });

  group('saving it up (Step 3)', () {
    test('heat and habits answers it, and points at the timing page', () {
      final read = ttcReadById('ttc_read_heat_habits')!;
      expect(read.sections.map((s) => s.heading?.en),
          contains('Does saving it up help?'));
      expect(read.nextSteps.map((s) => s.surfaceId),
          contains('ttc_read/ttc_read_timing_myths'));
      expect(ttcReadById('ttc_read_timing_myths'), isNotNull);
    });
  });
}

/// Every English word a read shows.
String _all(PvRead r) => [
      r.title.en,
      r.shortAnswer?.en ?? '',
      for (final s in r.sections) ...[
        s.heading?.en ?? '',
        for (final p in s.paragraphs) p.en,
        for (final b in s.bullets) b.en,
        s.callout?.body.en ?? '',
        s.tip?.body.en ?? '',
      ],
      for (final f in r.faqs) '${f.question.en} ${f.answer.en}',
    ].join('\n');
