// =============================================================================
//  Relevance Batch 6: content (2026-10-28)
// -----------------------------------------------------------------------------
//  docs/door-relevance/README.md, Batch 6. The demand gaps in PREGNANCY-GAP §4
//  and TTC-GAP fault 20, written as reads in each door's voice and sent to Ask
//  Veda. What this file holds is the WIRING: a read that no door, no hero and
//  no export reaches is the failure this repo has hit before (CLAUDE.md,
//  Wiring gate). The shape of each read (sections, sources, the urgent close,
//  no personal probability) is held by the shape tests every read already
//  passes through.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ask_veda/pv_veda_corpus.dart';
import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/can_i_data.dart';
import 'package:parentveda/data/doors/preg_band.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_symptoms.dart';
import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/data/reads/can_i_read.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/data/symptoms/symptom_normal.dart';
import 'package:parentveda/screens/can_i/can_i_answer.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart';
import 'package:parentveda/screens/pregnancy/preg_learn_screen.dart';
import 'package:parentveda/ttc/focus/ttc_focus_not_yet.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// The read ids every guide and myth tile on a Pregnancy door opens.
Set<String> _pregReadIds(PvDoorPage page) => {
  for (final t in page.allTiles) ?pvDoorTileReadImageId(t),
};

/// The read ids a TTC door's article tiles open, by tab.
Set<String> _ttcReadIds(TtcFocusPage page, {String? group}) => {
  for (final s in page.sections)
    if (group == null || s.group == group)
      for (final t in s.tiles)
        if (t case TtcArticleTile(:final readId?)) readId,
};

void main() {
  group('the six new reads exist, and each is on its door', () {
    test('Pregnancy: counting, travel, movements', () {
      for (final id in [
        'preg_first_read_counting',
        'preg_ready_read_travel',
        'preg_sym_read_movements',
      ]) {
        expect(pregnancyReadById(id), isNotNull, reason: id);
      }
      expect(
        _pregReadIds(kFirstWeeksDoor),
        contains('preg_first_read_counting'),
      );
      expect(
        _pregReadIds(kGettingReadyDoor),
        contains('preg_ready_read_travel'),
      );
      expect(_pregReadIds(kSymptomsDoor), contains('preg_sym_read_movements'));
    });

    test('TTC: low AMH, twins, and treatment that has not worked', () {
      for (final id in [
        'ttc_read_low_amh',
        'ttc_read_ivf_twins',
        'ttc_read_when_rounds_dont_work',
      ]) {
        expect(ttcReadById(id), isNotNull, reason: id);
      }
      expect(
        _ttcReadIds(kTtcIvfFocus, group: 'understand'),
        containsAll(['ttc_read_low_amh', 'ttc_read_ivf_twins']),
      );
      expect(
        _ttcReadIds(kTtcNotYetFocus, group: 'check'),
        contains('ttc_read_low_amh'),
      );
    });

    test(
      '"when it has not worked" sits where a result is, so it leads then',
      () {
        // The section's round steps include the result and between rounds,
        // which is what lifts it on a clinic cycle (Batch 4's rule).
        final s = kTtcIvfFocus.sections.firstWhere(
          (s) => s.tiles.any(
            (t) =>
                t is TtcArticleTile &&
                t.readId == 'ttc_read_when_rounds_dont_work',
          ),
        );
        expect(
          s.steps.map((p) => p.name),
          containsAll(['result', 'betweenRounds']),
        );
      },
    );

    test('Conceiving links "trying after 35" where she tries (rank 4)', () {
      expect(
        _ttcReadIds(kTtcConceivingFocus, group: 'trying'),
        containsAll(['ttc_read_age_after_35', 'ttc_read_age_after_40']),
      );
    });
  });

  group('Symptoms: the movements section follows her week', () {
    final section = kSymptomsDoor.sections.firstWhere(
      (s) => s.heading == "Your baby's movements",
    );

    test('it is on By symptom, banded 16 to 30 weeks', () {
      expect(section.group, kSymTabLibrary);
      expect(section.weeks?.from, 16);
      expect(section.weeks?.to, 30);
    });

    test('it leads the tab at week 20, and keeps its place at week 10', () {
      String first(int week) =>
          kSymptomsDoor.sectionsFor(kSymTabLibrary, week).first.heading;
      expect(first(20), "Your baby's movements");
      expect(first(10), isNot("Your baby's movements"));
    });
  });

  group('weeks, months and trimesters agree everywhere', () {
    final read = pregnancyReadById('preg_first_read_counting')!;

    test('the month list is pregMonthFor, week for week', () {
      final months = read.sections
          .firstWhere((s) => s.heading?.en == 'Which month is each week?')
          .bullets
          .map((b) => b.en)
          .toList();
      expect(months, hasLength(9));
      for (var w = 1; w <= 40; w++) {
        final m = pregMonthFor(w);
        final row = months[m - 1];
        final nums = RegExp(
          r'\d+',
        ).allMatches(row).map((x) => int.parse(x[0]!)).toList();
        // "Month m: weeks a to b": m, a, b.
        expect(nums[0], m);
        expect(
          w >= nums[1] && w <= nums[2],
          isTrue,
          reason: 'week $w in "$row"',
        );
      }
    });

    test('the trimester list is pregTrimesterFor', () {
      final rows = read.sections
          .firstWhere((s) => s.heading?.en == 'Which trimester is each week?')
          .bullets
          .map((b) => b.en)
          .toList();
      expect(
        rows[0],
        'First trimester: weeks 1 to ${_lastWeekOf('First trimester')}',
      );
      expect(rows[1], startsWith('Second trimester: weeks 13 to 27'));
      expect(rows[2], startsWith('Third trimester: week 28'));
    });

    test('the due-date read says the same weeks as the week page', () {
      final due = pregnancyReadById('preg_first_read_due_date')!;
      final text = due.sections
          .expand((s) => s.paragraphs)
          .map((p) => p.en)
          .join(' ');
      expect(
        text,
        contains('to the end of week 12, the second from week 13 to 27'),
      );
      expect(text, isNot(contains('end of week 13')));
    });

    test('the hero line', () {
      expect(pregMonthLine(23), 'Month 6 · Second trimester');
      expect(pregMonthLine(8), 'Month 2 · First trimester');
      expect(pregMonthLine(13), 'Month 3 · Second trimester');
      expect(pregMonthLine(36), 'Month 9 · Third trimester');
    });

    test('the home passes it, and only with a real due date', () {
      final src = File('lib/screens/home_v3_screen.dart').readAsStringSync();
      expect(src, contains('monthLine: pregnancy.isDueDateSet'));
      expect(src, contains('pregMonthLine(_pageWeek(week))'));
    });

    test('the "how your weeks are counted" sheet opens the read', () {
      expect(pregnancyReadById(kPregCountingReadId), isNotNull);
      final src = File(
        'lib/screens/pregnancy/preg_hero_extras.dart',
      ).readAsStringSync();
      expect(src, contains('openPvDoorRead(context, kPregCountingReadId, c)'));
    });
  });

  group('Is it safe? ends the travel answers with the guide', () {
    for (final id in ['flight_travel', 'long_travel']) {
      test(id, () {
        final e = canIById(id)!;
        final r = pvReadFromCanI(e);
        expect(r.readNext.first, 'preg_ready_read_travel');
        // A missing guide fails here, not as a silent tap (Terminal B's ask).
        expect(canIResolveRead(r.readNext.first), isNotNull);
      });
    }

    test('another answer still resolves first', () {
      expect(canIResolveRead('cani_flight_travel')?.id, 'cani_flight_travel');
    });

    test('every guide in the table resolves', () {
      for (final MapEntry(:key, :value) in kCanIGuideReads.entries) {
        expect(canIById(key), isNotNull, reason: key);
        expect(pregnancyReadById(value), isNotNull, reason: value);
      }
    });
  });

  group('Pregnancy 101 teaches counting and movements', () {
    test('both are in the course, and every id resolves', () {
      expect(
        kPregLearnStartIds,
        containsAll(['preg_first_read_counting', 'preg_sym_read_movements']),
      );
      expect(
        kPregLearnStartIds.indexOf('preg_sym_read_movements'),
        lessThan(kPregLearnStartIds.indexOf('preg_cond_read_less_movement')),
      );
      expect(pregLearnStartHere(), hasLength(kPregLearnStartIds.length));
    });

    test('the halfway read leads to the movements guide', () {
      final halfway = pregnancyReadById('${kPregWeekReadPrefix}halfway')!;
      expect(halfway.readNext.first, 'preg_sym_read_movements');
    });
  });

  group('Ask Veda sees what the Symptoms door says', () {
    final corpus = buildPregnancyVedaCorpus();
    Map<String, dynamic> doc(String id) =>
        corpus.firstWhere((d) => d['doc_id'] == id, orElse: () => {});

    String cardId(String title) {
      final t = kSymptomsDoor.allTiles.firstWhere((t) => t.title == title);
      return pvVedaDoorId(kSymptomsBracketId, t);
    }

    test('a symptom card carries its whole page, warning lines included', () {
      final discharge = doc(cardId('More vaginal discharge'));
      expect(discharge, isNotEmpty);
      final body = discharge['body'] as String;
      expect(body, contains('fishy smell'));
      expect(body, contains('it may be your waters'));

      final cramps = doc(cardId('Belly cramps'))['body'] as String;
      expect(cramps, contains('Which cramps are normal?'));
      expect(cramps, contains('Regular tightenings that get stronger'));
    });

    test('each "Is this normal?" answer is its own document, and opens', () {
      // PREGNANCY-GAP 28, after Terminal B's P2 (01f33b1) freed the resolver.
      for (final q in kNormalQuestions) {
        final id = pvVedaReadId('normal_${q.id}');
        final d = doc(id);
        expect(d, isNotEmpty, reason: '$id is not exported');
        expect(d['body'] as String, startsWith(q.question));
        expect(d['body'] as String, contains(q.whenItChanges));
        expect(pvVedaDocResolves(id), isTrue, reason: '$id does not resolve');
      }
      expect(pvVedaDocResolves(pvVedaReadId('normal_no_such_question')), isFalse);
    });

    test('the door document names the questions, not the answers again', () {
      final door = doc(pvVedaDoorId(kSymptomsBracketId))['body'] as String;
      for (final q in kNormalQuestions) {
        expect(door, contains(q.question), reason: q.id);
        expect(door, isNot(contains(q.whenItChanges)), reason: q.id);
      }
    });

    test('every exported id still resolves (the id contract)', () {
      // Only the ids this batch changed or added, so a failure names us.
      for (final id in [
        cardId('More vaginal discharge'),
        cardId('Belly cramps'),
        pvVedaDoorId(kSymptomsBracketId),
        pvVedaReadId('preg_first_read_counting'),
        pvVedaReadId('preg_ready_read_travel'),
        pvVedaReadId('preg_sym_read_movements'),
      ]) {
        expect(doc(id), isNotEmpty, reason: '$id is not exported');
        expect(pvVedaDocResolves(id), isTrue, reason: '$id does not resolve');
      }
    });

    test('the new TTC reads are in the list the TTC export walks', () {
      final ids = {for (final r in kTtcReads) r.id};
      expect(
        ids,
        containsAll([
          'ttc_read_low_amh',
          'ttc_read_ivf_twins',
          'ttc_read_when_rounds_dont_work',
        ]),
      );
    });
  });

  test('PregBand is the type the section uses', () {
    // Guards the import the Symptoms door now needs.
    expect(const PregBand(16, 30).contains(20), isTrue);
  });
}

int _lastWeekOf(String name) => [
  for (var w = 1; w <= 40; w++)
    if (pregTrimesterFor(w) == name) w,
].last;
