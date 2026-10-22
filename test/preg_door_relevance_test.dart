// Pregnancy doors open on HER weeks (2026-10-23, global pass phase 1).
//
// The user, at week 30: "I come on the door, I start from the first trimester
// always." A section banded to her weeks now leads its tab, upcoming follows,
// past sinks; nothing is hidden, and the week-20 placeholder moves nothing.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/preg_band.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';

List<String> headings(PvDoorPage page, String tab, int? week) =>
    [for (final s in page.sectionsFor(tab, week)) s.heading];

void main() {
  group('PregBand.parse reads the ranges the cards already print', () {
    for (final (meta, from, to) in [
      ('Weeks 28 to 36', 28, 36),
      ('Weeks 28–36', 28, 36),
      ('Weeks 24 to 28 (OGTT)', 24, 28),
      ('Weeks 28 to birth', 28, 42),
      ('After week 20', 20, 42),
    ]) {
      test(meta, () {
        final b = PregBand.parse(meta)!;
        expect((b.from, b.to), (from, to));
      });
    }
    test('anything else keeps its place', () {
      for (final m in ['Any time', 'Later scans', 'First booking bloods', null]) {
        expect(PregBand.parse(m), isNull, reason: '$m');
      }
    });
  });

  group('pregRelevanceOrder', () {
    PregBand? band(String s) => switch (s) {
          'early' => PregBand.firstTrimester,
          'mid' => PregBand.secondTrimester,
          'late' => PregBand.thirdTrimester,
          _ => null,
        };
    test('no real due date: nothing moves', () {
      final xs = ['early', 'mid', 'late', 'twins'];
      expect(pregRelevanceOrder(xs, band, null), xs);
    });
    test('hers first, upcoming next, past most recent first', () {
      expect(pregRelevanceOrder(['early', 'mid', 'late', 'twins'], band, 30),
          ['late', 'mid', 'early', 'twins']);
      expect(pregRelevanceOrder(['early', 'mid', 'late', 'twins'], band, 20),
          ['mid', 'late', 'early', 'twins']);
      expect(pregRelevanceOrder(['early', 'mid', 'late', 'twins'], band, 8),
          ['early', 'mid', 'late', 'twins']);
    });
    test('one banded item among untagged leads only when it is hers', () {
      expect(pregRelevanceOrder(['a', 'late', 'b'], band, 30), ['late', 'a', 'b']);
      expect(pregRelevanceOrder(['a', 'late', 'b'], band, 10), ['a', 'late', 'b']);
    });
  });

  group('the doors the user named', () {
    test('Scans: understand a scan opens on her trimester', () {
      expect(headings(kScansDoor, kScansTabScan, 8).first, 'First three months');
      expect(headings(kScansDoor, kScansTabScan, 22).first, 'Middle three months');
      expect(headings(kScansDoor, kScansTabScan, 34).first, 'Last three months');
      // Nothing hidden, and the folded background reading stays last.
      final h = headings(kScansDoor, kScansTabScan, 34);
      expect(h.toSet(), headings(kScansDoor, kScansTabScan, null).toSet());
      expect(h.last, 'Before any scan');
    });

    test('Scans: no due date keeps the written order', () {
      expect(headings(kScansDoor, kScansTabScan, null),
          [for (final s in kScansDoor.sectionsOf(kScansTabScan)) s.heading]);
    });

    test('Complications: her months lead, and her rail is ordered by week', () {
      expect(headings(kComplicationsDoor, kCondTabWhen, 32).first, 'Later months');
      final later = kComplicationsDoor
          .sectionsFor(kCondTabWhen, 32)
          .first
          .tilesFor(32);
      final first = PregBand.parse(later.first.meta);
      expect(first == null || first.contains(32) || first.from > 32, isTrue,
          reason: 'a past card leads the later-months rail at week 32');
    });

    test('Move: month by month leads with her trimester', () {
      final s = kMoveDoor
          .sectionsOf(kMoveTabMove)
          .firstWhere((s) => s.heading == 'Month by month');
      expect(s.tilesFor(30).first.title, 'Moving in the last three months');
      expect(s.tilesFor(5).first.title, 'Moving in the first three months');
      expect(s.tilesFor(30, weekKnown: false).first.title,
          'Moving in the first three months');
    });

    test('Getting Ready: the last months lead only in the last months', () {
      expect(headings(kGettingReadyDoor, kReadyTabHome, 30).first, 'The last months');
      expect(headings(kGettingReadyDoor, kReadyTabHome, 12).first,
          'Getting the home ready');
    });
  });

  test('wiring: the door screen ranks by her real week', () {
    final src = File('lib/screens/doors/pv_door_screen.dart').readAsStringSync();
    expect(src.contains('page.sectionsFor('), isTrue);
    expect(src.contains('weekKnown: _knownWeek != null'), isTrue);
    expect(src.contains('widget.pregnancy.isDueDateSet'), isTrue);
  });
}
