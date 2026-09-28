// =============================================================================
//  A photo on every card — every Trying to conceive door (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: the "How conception works" card, a photograph with its title and
//  "7 min read", "looks clean… I like that card"; the text-only cards beside
//  it "look empty". So every card on the Fertile window door carries a
//  free-licence photo, mirrored to our R2 bucket and credited in
//  `kReadImageCredits` — and since the launch sanity walk (D1, H10) the other
//  eight doors and the home's "Recommended reads" do too.
//
//  What this holds, on all nine doors:
//    * every card resolves a photo (`photoForTile`), except the few named in
//      `_kTextOnly`, where no honest photograph fits (a yoga pose that no
//      free photo shows, rather than a different pose that would mislead);
//    * every photo that comes from the table is served from R2 and has a
//      licence line, because a CC BY picture without its credit is not free;
//    * no photo repeats inside one tab, so a rail never shows a twin;
//    * every read the home's rail can pick, by phase or by treatment step,
//      has a photo, so "Recommended reads" never shows two identical marks.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/reads/read_images.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart'
    show photoForTile, ttcTilePhotoId;
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_phase_reads.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_treatment_content.dart';

/// Cards left text-only on purpose, as "door › card title". Each one is a
/// card where every candidate photograph either showed something else or
/// showed the thing in a way that does not suit a calm app. Adding a name
/// here is a decision, not a fix: say why in the comment beside it.
const Set<String> _kTextOnly = {
  // No free photo shows this pose; a different pose would teach the wrong
  // one.
  'ttc_mind_body › Cat and cow, then child\'s pose',
  'ttc_mind_body › Legs up the wall',
};

void main() {
  // Kept for revert (2026-09-28, all nine doors): the Fertile window door
  // alone, `const page = kTtcConceivingFocus;`.

  test('the nine doors are the ones this test walks', () {
    expect(kTtcFocusPages.length, 9);
    expect(kTtcFocusPages, contains(kTtcConceivingFocus));
  });

  test('every card on every door has a photo', () {
    final missing = [
      for (final page in kTtcFocusPages)
        for (final s in page.sections)
          for (final t in s.tiles)
            if (photoForTile(t) == null &&
                !_kTextOnly.contains('${page.bracketId} › ${t.title}'))
              '${page.bracketId} › ${s.heading} › ${t.title}',
    ];
    expect(missing, isEmpty, reason: 'text-only cards: $missing');
  });

  test('every card on the Fertile window door has a photo', () {
    final missing = [
      for (final s in kTtcConceivingFocus.sections)
        for (final t in s.tiles)
          if (photoForTile(t) == null) '${s.heading} › ${t.title}',
    ];
    expect(missing, isEmpty,
        reason: 'text-only cards on the Fertile window door: $missing');
  });

  test('the text-only list names cards that exist and still have no photo',
      () {
    final all = {
      for (final page in kTtcFocusPages)
        for (final s in page.sections)
          for (final t in s.tiles) '${page.bracketId} › ${t.title}': t,
    };
    for (final name in _kTextOnly) {
      expect(all[name], isNotNull, reason: '$name is not a card any more');
      expect(photoForTile(all[name]!), isNull,
          reason: '$name has a photo now; take it off the text-only list');
    }
  });

  test('every table photo is on R2 and credited', () {
    final uncredited = <String>[];
    void check(String id) {
      if (!kReadImageUrls.containsKey(id)) return;
      expect(readImageFor(id), '$kReadImageBase$id.jpg', reason: id);
      if ((kReadImageCredits[id] ?? '').isEmpty) uncredited.add(id);
    }

    for (final page in kTtcFocusPages) {
      for (final s in page.sections) {
        for (final t in s.tiles) {
          check(ttcTilePhotoId(t));
          if (t case TtcArticleTile(:final readId?)) check(readId);
          if (t case TtcGuideTile(:final readId)) check(readId);
        }
      }
    }
    for (final id in _homeReadIds()) {
      check(id);
    }
    expect(uncredited, isEmpty, reason: 'photos with no licence line');
  });

  test('no photo repeats inside one tab, on any door', () {
    for (final page in kTtcFocusPages) {
      final groups = page.groups;
      final tabs = <String?, String>{
        if (groups == null) null: page.bracketId,
        if (groups != null)
          for (final g in groups) g.id: g.label,
      };
      for (final MapEntry(key: tab, value: label) in tabs.entries) {
        final seen = <String, String>{};
        for (final s in page.sections.where((s) => s.group == tab)) {
          for (final t in s.tiles) {
            final url = photoForTile(t);
            if (url == null) continue;
            expect(seen[url], isNull,
                reason: '"${t.title}" repeats the photo of "${seen[url]}" '
                    'on ${page.bracketId} › $label');
            seen[url] = t.title;
          }
        }
      }
    }
  });

  test('every read the home can recommend has a photo', () {
    final missing = [
      for (final id in _homeReadIds())
        if (readImageFor(id, own: ttcReadById(id)?.imageUrl) == null) id,
    ];
    expect(missing, isEmpty,
        reason: 'reads the home can show with only a drawn mark: $missing');
  });

  test('a tile photo key is the title, lower case, joined by _', () {
    const t = TtcMythTile(
      title: 'Every day or not?',
      blurb: '',
      myth: '',
      fact: '',
    );
    expect(ttcTilePhotoId(t), 'ttc_tile_every_day_or_not');
  });
}

/// Every read the home's "Recommended reads" rows can pick: the phase lists
/// (`ttcReadIdsForPhase`) and the treatment-step lists
/// (`ttcTreatmentReadIdsFor`), the two sources `ttcHomeReadIdsFor` draws on.
Set<String> _homeReadIds() => {
      for (final ids in kTtcPhaseReadIds.values) ...ids,
      for (final ids in kTtcTreatmentPhaseReadIds.values) ...ids,
    };
