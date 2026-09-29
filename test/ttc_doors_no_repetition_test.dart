// =============================================================================
//  No random repetition — the nine TTC doors, Learn and the reads (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "make sure in app there is no random repetition going on." A
//  door is data, and every repeat the walk found was a data repeat that
//  rendered perfectly: the same eight garbh sanskar sessions on two tabs of
//  one door, "Reading a semen report" beside "Read your semen report", a read
//  offered under "What you can do with this" and again in the Read next rail
//  below it, the same FAQ in two reads of one door. None of these fails to
//  build, so each rule is held here, against the data, for every door at once.
//
//  What counts as the same piece is its DESTINATION, not its title: a read
//  and the heading it opens at, a tool's surface, a film's slot, a product, a
//  consult. A myth, a story or an infographic carries its content in the tile,
//  so its title is its identity.
//
//  ⚠️ WHAT IS ALLOWED, AND WHY
//    · The same read on one door at DIFFERENT headings. That is the "promote"
//      pattern the After a loss and Mind and body briefs asked for: one source
//      shown twice, never copied, each card landing on its own section
//      ("Ectopic signs that need a hospital today" opens the ectopic read at
//      its signs; "Ectopic pregnancy" opens it at the top). So a photo may
//      repeat across two tabs only when both cards open the same read.
//    · A tool on two doors. Each door is allowed to feel complete, so "The
//      full test library" is on several; twice on ONE tab is the failure.
//    · The two pairs in [_kCrossTabRepeats], one destination on two tabs of
//      one door, each for a reason written beside it.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart'
    show photoForTile;
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// Where a tile lands. Two tiles with one key are the same piece.
String destinationOf(TtcTile t) => switch (t) {
  TtcToolTile(:final surfaceId) => 'surface:$surfaceId',
  TtcChecklistTile(:final surfaceId) => 'surface:$surfaceId',
  TtcCommunityTile(:final surfaceId) => 'surface:$surfaceId',
  TtcDoTile(:final surfaceId) => 'surface:$surfaceId',
  TtcArticleTile(:final readId, :final moreReadId, :final atHeading) =>
    'read:${readId ?? 'sheet>$moreReadId'}#${atHeading ?? ''}',
  TtcGuideTile(:final readId, :final atHeading) =>
    'read:$readId#${atHeading ?? ''}',
  TtcVideoTile(:final slotId) => 'film:$slotId',
  TtcProductTile(:final productId, :final category) =>
    'product:${productId ?? 'shelf>$category'}',
  TtcTalkTile(:final action) => 'consult:$action',
  TtcBookingTile(:final action) => 'consult:$action',
  TtcMasterclassTile(:final offeringId) => 'course:$offeringId',
  TtcRecipeTile(:final recipeId) => 'recipe:$recipeId',
  TtcDoorTile(:final bracketId, :final group) => 'door:$bracketId/$group',
  // Content that lives in the tile itself: its title is its identity.
  TtcMythTile() || TtcCarouselTile() || TtcInfographicTile() =>
    '${t.runtimeType}:${t.title}',
};

/// The read a tile opens, whatever heading it opens at, or null.
String? readOf(TtcTile t) => switch (t) {
  TtcArticleTile(:final readId) => readId,
  TtcGuideTile(:final readId) => readId,
  _ => null,
};

/// One destination on two tabs of one door, on purpose. `door › destination`.
const Map<String, String> _kCrossTabRepeats = {
  // His side: the andrologist is offered where he reads his report ("Have an
  // andrologist read the report") and again on the tab about talking to
  // someone. The same person, for two different reasons, on two tabs.
  'ttc_male_fertility › consult:ttc_consult_androl':
      'the report tab and the talk tab',
  // Mind and body: the long out-breath is a practice on Move and breathe and
  // "A calming breath for bedtime" on Sleep and routine, retitled for the
  // night. One practice, framed for the tab it sits on.
  'ttc_mind_body › surface:ttc_practice/mb_longout':
      'the practice tab and the sleep tab',
};

/// Content words of a title, lightly stemmed, for "near the same".
Set<String> _words(String s) {
  const stop = {
    'a', 'an', 'the', 'and', 'or', 'of', 'to', 'in', 'on', 'for', 'your',
    'you', 'it', 'is', 'do', 'does', 'can', 'what', 'when', 'how', 'why',
    'with', 'are', 'be', 'at', 'by', 'this', 'that', 'my', 'our', 'we',
    'his', 'her', 'if', 'not', 'no', 'i', 'should', 'about',
  };
  return {
    for (final w in RegExp(r'[a-z0-9]+').allMatches(s.toLowerCase()))
      if (!stop.contains(w[0]!))
        w[0]!.replaceAll(RegExp(r'(ing|s)$'), ''),
  };
}

String _norm(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();

/// The cards the door draws: every section's tiles.
///
/// ⚠️ NOT `allTiles`, which adds the page's `headline` course. The door
/// (`TtcDoorScreen`) never draws the headline; only the retired
/// `TtcFocusScreen` did, so counting it would report "The PCOS programme"
/// twice on a door that shows it once.
List<TtcTile> _shown(TtcFocusPage page) =>
    [for (final s in page.sections) ...s.tiles];

/// Every tab of [page] with its sections. A page with no tabs is one tab.
Map<String?, List<TtcFocusSection>> _tabs(TtcFocusPage page) {
  final out = <String?, List<TtcFocusSection>>{};
  for (final s in page.sections) {
    out.putIfAbsent(s.group, () => []).add(s);
  }
  return out;
}

void main() {
  group('on every door', () {
    test('no piece twice on one tab', () {
      final twice = <String>[];
      for (final page in kTtcFocusPages) {
        for (final MapEntry(key: tab, value: sections)
            in _tabs(page).entries) {
          final seen = <String, String>{};
          for (final s in sections) {
            for (final t in s.tiles) {
              final d = destinationOf(t);
              if (seen[d] case final other?) {
                twice.add('${page.bracketId} › $tab: "${t.title}" repeats '
                    '"$other" ($d)');
              }
              seen[d] = t.title;
            }
          }
        }
      }
      expect(twice, isEmpty, reason: twice.join('\n'));
    });

    test('one destination on two tabs only where it is written down', () {
      final found = <String>{};
      final unexplained = <String>[];
      for (final page in kTtcFocusPages) {
        final tabsOf = <String, Set<String?>>{};
        for (final s in page.sections) {
          for (final t in s.tiles) {
            tabsOf.putIfAbsent(destinationOf(t), () => {}).add(s.group);
          }
        }
        for (final MapEntry(key: d, value: tabs) in tabsOf.entries) {
          if (tabs.length < 2) continue;
          final key = '${page.bracketId} › $d';
          found.add(key);
          if (!_kCrossTabRepeats.containsKey(key)) unexplained.add(key);
        }
      }
      expect(unexplained, isEmpty,
          reason: 'a piece on two tabs of one door with no reason given: '
              '$unexplained');
      // The list names only repeats that still exist.
      expect(_kCrossTabRepeats.keys.where((k) => !found.contains(k)), isEmpty);
    });

    test('a photo repeats on a door only for one read shown twice', () {
      final bad = <String>[];
      for (final page in kTtcFocusPages) {
        final byPhoto = <String, List<TtcTile>>{};
        for (final s in page.sections) {
          for (final t in s.tiles) {
            final url = photoForTile(t);
            if (url == null) continue;
            byPhoto.putIfAbsent(url, () => []).add(t);
          }
        }
        for (final tiles in byPhoto.values) {
          if (tiles.length < 2) continue;
          final reads = {for (final t in tiles) readOf(t)};
          if (reads.length != 1 || reads.single == null) {
            bad.add('${page.bracketId}: '
                '${[for (final t in tiles) t.title].join(' / ')}');
          }
        }
      }
      expect(bad, isEmpty, reason: 'the same photo on unrelated cards: $bad');
    });

    test('no two cards on a door with the same or near-same title', () {
      final near = <String>[];
      for (final page in kTtcFocusPages) {
        final tiles = _shown(page);
        for (var i = 0; i < tiles.length; i++) {
          for (var j = i + 1; j < tiles.length; j++) {
            final a = tiles[i], b = tiles[j];
            if (_norm(a.title) == _norm(b.title)) {
              near.add('${page.bracketId}: "${a.title}" twice');
              continue;
            }
            final wa = _words(a.title), wb = _words(b.title);
            if (wa.length < 2 || wb.length < 2) continue;
            final shared = wa.intersection(wb).length;
            final score = shared / wa.union(wb).length;
            if (score >= 0.75) {
              near.add('${page.bracketId}: "${a.title}" / "${b.title}"');
            }
          }
        }
      }
      expect(near, isEmpty, reason: near.join('\n'));
    });

    test('no two sections on a door share a heading', () {
      final twice = <String>[];
      for (final page in kTtcFocusPages) {
        final seen = <String>{};
        for (final s in page.sections) {
          if (!seen.add(_norm(s.heading))) {
            twice.add('${page.bracketId}: "${s.heading}"');
          }
        }
      }
      expect(twice, isEmpty, reason: twice.join('\n'));
    });

    test('no section repeats its neighbour on a tab', () {
      final same = <String>[];
      for (final page in kTtcFocusPages) {
        for (final sections in _tabs(page).values) {
          for (var i = 1; i < sections.length; i++) {
            final a = {for (final t in sections[i - 1].tiles) destinationOf(t)};
            final b = {for (final t in sections[i].tiles) destinationOf(t)};
            if (a.isNotEmpty && a.containsAll(b) && b.containsAll(a)) {
              same.add('${page.bracketId}: "${sections[i - 1].heading}" and '
                  '"${sections[i].heading}"');
            }
          }
        }
      }
      expect(same, isEmpty, reason: same.join('\n'));
    });

    test('a stable tile id names one card on its door', () {
      // The id is the photo key and Ask Veda's fallback slug
      // (`ttcTileBySlug`), so two cards on one door with one id would share
      // a photo and a deep link.
      final twice = <String>[];
      for (final page in kTtcFocusPages) {
        final seen = <String>{};
        for (final t in _shown(page)) {
          if (t.id case final id?) {
            if (!seen.add(id)) twice.add('${page.bracketId}: $id');
          }
        }
      }
      expect(twice, isEmpty, reason: twice.join('\n'));
    });

    test('an old Ask Veda slug still finds a retitled card', () {
      // "Every day or not?" became "Sex every day, or every other day?"
      // (2026-09-28); the pool exported under the old title must still land.
      final page = ttcFocusPageFor('ttc_conceiving')!;
      final hit = ttcTileBySlug(page, 'every-day-or-not');
      expect(hit, isNotNull);
      expect(hit!.$1.title, 'Sex every day, or every other day?');
      // The new title's own slug wins where both exist.
      expect(
        ttcTileBySlug(page, ttcTileSlug(hit.$1))!.$1,
        same(hit.$1),
      );
    });
  });

  group('the reads', () {
    test('Read next never lists the read itself, or one read twice', () {
      final bad = <String>[];
      for (final r in kTtcReads) {
        if (r.readNext.contains(r.id)) bad.add('${r.id} lists itself');
        if (r.readNext.toSet().length != r.readNext.length) {
          bad.add('${r.id} lists a read twice: ${r.readNext}');
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('Read next never repeats a read the next steps already offer', () {
      final bad = <String>[];
      for (final r in kTtcReads) {
        for (final n in r.nextSteps) {
          final s = n.surfaceId ?? '';
          if (!s.startsWith('ttc_read/')) continue;
          final id = s.substring('ttc_read/'.length);
          if (id == r.id) bad.add('${r.id}: a next step opens itself');
          if (r.readNext.contains(id)) {
            bad.add('${r.id}: "$id" is a next step and in Read next');
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('no two next steps in a read go to one place', () {
      final bad = <String>[];
      for (final r in kTtcReads) {
        final seen = <String>{};
        for (final n in r.nextSteps) {
          final d = n.surfaceId ?? n.action ?? n.title.en;
          if (!seen.add(d)) bad.add('${r.id}: $d twice');
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('no question is asked in two reads', () {
      // Stage-wide, which is stricter than "two reads of one door": the
      // library, Learn's Common questions and Ask Veda all list FAQs out of
      // their read, where two identical questions read as one printed twice.
      final byQuestion = <String, List<String>>{};
      for (final r in kTtcReads) {
        for (final PvReadFaq f in r.faqs) {
          byQuestion.putIfAbsent(_norm(f.question.en), () => []).add(r.id);
        }
      }
      final twice = [
        for (final MapEntry(key: q, value: ids) in byQuestion.entries)
          if (ids.length > 1) '"$q" in $ids',
      ];
      expect(twice, isEmpty, reason: twice.join('\n'));
    });
  });

  group('Learn', () {
    test('every read sits on one shelf, once', () {
      final seen = <String, String>{};
      final twice = <String>[];
      for (final s in ttcLearnShelves()) {
        for (final r in s.reads) {
          if (seen[r.id] case final other?) {
            twice.add('${r.id} on "$other" and "${s.key}"');
          }
          seen[r.id] = s.key;
        }
      }
      expect(twice, isEmpty, reason: twice.join('\n'));
    });

    test('Start here, the stories and the questions list nothing twice', () {
      final start = [for (final r in ttcLearnStartHere()) r.id];
      expect(start.toSet().length, start.length, reason: '$start');

      final stories = [for (final (t, _) in ttcLearnStories()) t.title];
      expect(stories.toSet().length, stories.length, reason: '$stories');

      final faqs = ttcLearnFaqs();
      final questions = [for (final (f, _) in faqs) _norm(f.question.en)];
      final reads = [for (final (_, r) in faqs) r.id];
      expect(questions.toSet().length, questions.length);
      expect(reads.toSet().length, reads.length,
          reason: 'one read gave two of the common questions');
    });
  });
}
