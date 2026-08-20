// =============================================================================
//  The reads keep their shape
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE IS THE ANTI-SHALLOWNESS MECHANISM, and without it the required
//  fields on `PvRead` only guarantee that something was typed into them.
//
//  The conditions page proved the principle: a fixed required order is what
//  forces depth, because a thin piece then visibly fails rather than quietly
//  looking finished. `PvRead.assertShape()` states the rules; this runs them
//  over every article so a new one cannot ship at three paragraphs and a
//  heading.
//
//  ⚠️ AND IT CLOSES THE WIRING GATE FOR VIDEO SLOTS. A `videoSlot` naming an
//  entry that does not exist renders NOTHING — the reader returns
//  `SizedBox.shrink()` rather than an empty box, which is right for the user
//  and invisible to everyone else. A typo'd slot id would therefore silently
//  delete a video from an article and no test, no analyzer and no crash would
//  ever mention it. That is precisely the correct-but-unreachable failure this
//  repo has hit before, so it is asserted here.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart';

void main() {
  group('every TTC read is deep enough to be worth opening', () {
    test('none fails its own shape rules', () {
      final problems = <String>[];
      for (final r in kTtcReads) {
        problems.addAll(r.assertShape());
      }
      expect(problems, isEmpty,
          reason: 'These reads are not ready:\n  ${problems.join('\n  ')}');
    });

    test('ids are unique', () {
      final ids = kTtcReads.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'A duplicate id means one article is unreachable — the '
              'lookup returns the first match and the second never opens.');
    });

    test('the library is not empty', () {
      // Guards the reverse mistake: a passing suite over zero articles proves
      // nothing, and every assertion above is vacuously true on an empty list.
      expect(kTtcReads, isNotEmpty);
    });
  });

  group('every declared video slot resolves', () {
    test('slots named inside a read exist in the catalogue', () {
      final missing = <String>[];
      for (final r in kTtcReads) {
        for (final slot in [
          if (r.heroVideoSlot != null) r.heroVideoSlot!,
          ...r.relatedVideoSlots,
          for (final s in r.sections)
            if (s.videoSlot != null) s.videoSlot!,
        ]) {
          if (ttcVideoBySlot(slot) == null) missing.add('${r.id} -> $slot');
        }
      }
      expect(missing, isEmpty,
          reason: 'A slot with no entry renders nothing at all, silently:\n'
              '  ${missing.join('\n  ')}');
    });

    test('video ids are unique', () {
      final ids = kTtcVideos.map((v) => v.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('no video claims to play', () {
      // ⚠️ THE HONESTY ASSERTION. `url != null` makes the placeholder tappable
      // everywhere at once. Nothing is filmed yet, so a non-null url here means
      // someone wired a play control to a file that does not exist — which
      // teaches her that taps do nothing, across the whole app and not just
      // this screen. Delete this test on the day the first file actually lands.
      for (final v in kTtcVideos) {
        expect(v.isLive, isFalse,
            reason: '${v.id} claims a playable url; no TTC video is filmed.');
      }
    });

    test('every video carries chapters and takeaways', () {
      // What makes a placeholder page useful on the day it ships rather than
      // only on the day the file arrives.
      for (final v in kTtcVideos) {
        expect(v.chapters, isNotEmpty, reason: '${v.id} has no chapter list');
        expect(v.takeaways, isNotEmpty, reason: '${v.id} has no takeaways');
      }
    });
  });

  group('the clinical rules survive contact with prose', () {
    test('no read states a personalised probability', () {
      // Population figures are allowed and several are used deliberately. The
      // banned shape is a number attached to HER — "your chance", "your odds".
      // Deliberately narrow: this catches the phrasing, and the source-scanning
      // ttc_clinical_review_test remains the broader guard.
      final banned = RegExp(
          r'\byour (chance|chances|odds|probability|success rate)\b',
          caseSensitive: false);
      for (final r in kTtcReads) {
        final all = [
          r.title.en,
          r.teaser.en,
          r.scaleSetter.en,
          r.whenToSeeSomeone.body.en,
          for (final s in r.sections) ...[
            ...s.paragraphs.map((p) => p.en),
            ...s.bullets.map((b) => b.en),
            if (s.callout != null) s.callout!.body.en,
            if (s.tip != null) s.tip!.body.en,
            if (s.mythFact != null) s.mythFact!.fact.en,
          ],
          for (final f in r.faqs) f.answer.en,
        ].join(' ');
        expect(banned.hasMatch(all), isFalse,
            reason: '${r.id} addresses a probability to her personally.');
      }
    });

    test('every read routes to a clinician', () {
      for (final r in kTtcReads) {
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent);
        expect(r.whenToSeeSomeone.body.en.trim(), isNotEmpty);
      }
    });

    test('every read names where it came from', () {
      for (final r in kTtcReads) {
        expect(r.evidence, isNotNull, reason: '${r.id} has no evidence note');
        // "studies show" with nothing named is the shape this rules out.
        expect(r.evidence!.en.length, greaterThan(40),
            reason: '${r.id} names no actual source');
      }
    });
  });
}
