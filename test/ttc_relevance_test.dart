// The user's relevance rule, held (TTC launch walk, 2026-09-27): everything on a
// screen serves that screen, and every tap lands where its label promises. "If I
// filter a bakery for cakes, I should not get a pizza." These checks cover what
// code can check: a tile's destination exists, a tile that names a section of a
// read lands on a real one, a consult tile opens a real consult, and a door
// link names a real tab.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/hubs/ttc_hubs.dart' show kTtcActConsult;
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

String _norm(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

void main() {
  final tiles = [
    for (final page in kTtcFocusPages)
      for (final s in page.sections)
        for (final t in s.tiles) (page, s, t),
  ];

  test('a tile that opens a section of a read finds that section', () {
    for (final (page, s, t) in tiles) {
      final (readId, heading) = switch (t) {
        TtcArticleTile(:final readId, :final atHeading) => (readId, atHeading),
        TtcGuideTile(:final readId, :final atHeading) => (readId, atHeading),
        _ => (null, null),
      };
      if (readId == null || heading == null) continue;
      final r = ttcReadById(readId);
      expect(r, isNotNull, reason: '${page.bracketId} › "${t.title}"');
      expect(r!.toc.any((h) => _norm(h.en) == _norm(heading)), isTrue,
          reason: '${page.bracketId} › ${s.heading} › "${t.title}" names '
              '"$heading", which is not a heading of $readId');
    }
  });

  test('a consult tile opens a real consult', () {
    for (final (page, s, t) in tiles) {
      final action = switch (t) {
        TtcTalkTile(:final action) => action,
        TtcBookingTile(:final action) => action,
        _ => null,
      };
      if (action == null) continue;
      expect(action == kTtcActConsult || ttcOfferingById(action) != null, isTrue,
          reason: '${page.bracketId} › ${s.heading} › "${t.title}" → $action');
    }
  });

  test('a door link that names a tab names a real one', () {
    for (final (page, s, t) in tiles) {
      if (t is! TtcDoorTile) continue;
      final target = ttcFocusPageFor(t.bracketId);
      expect(target, isNotNull, reason: '"${t.title}" → ${t.bracketId}');
      if (t.group == null) continue;
      expect(target!.groups?.any((g) => g.id == t.group), isTrue,
          reason: '"${t.title}" → ${t.bracketId} tab ${t.group}');
    }
  });

  test('Taking a while sends her to Mind and body\'s Hard days', () {
    final link = tiles
        .where((x) => x.$1.bracketId == 'ttc_not_yet')
        .map((x) => x.$3)
        .whereType<TtcDoorTile>()
        .firstWhere((t) => t.bracketId == 'ttc_mind_body');
    expect(link.group, 'hard');
  });
}
