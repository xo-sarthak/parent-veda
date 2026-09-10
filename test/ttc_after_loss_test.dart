// =============================================================================
//  After a loss — the rules this area is built under
// -----------------------------------------------------------------------------
//  ⚠️ TWO OF THESE TESTS EXIST BECAUSE THE FAILURE WOULD BE INVISIBLE.
//
//  An `atHeading` that no longer matches opens the article at the top — which
//  is the safe failure, and it is also a silent one. Six cards would still
//  render, still open something, and quietly stop doing the thing that made
//  them worth building.
//
//  And a red flag pinned by read id renders the article's own callout. If that
//  read is renamed, the pin disappears and the page still looks fine — with the
//  self-harm routing gone from the Support tab.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/ttc/focus/ttc_focus_after_loss.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final page = kTtcAfterLossFocus;
  List<TtcTile> tiles() => page.allTiles;

  // ===========================================================================
  group('promote is real, not six cards opening one article at the top', () {
    test('every atHeading matches a section that exists', () {
      var anchored = 0;
      for (final tile in tiles()) {
        final (id, heading) = switch (tile) {
          TtcGuideTile(:final readId, :final atHeading) => (readId, atHeading),
          TtcArticleTile(:final readId, :final atHeading) => (readId, atHeading),
          _ => (null, null),
        };
        if (id == null || heading == null) continue;
        anchored++;

        final read = ttcReadById(id);
        expect(read, isNotNull, reason: '"${tile.title}" names read "$id"');
        expect(read!.sections.any((s) => s.heading?.en == heading), isTrue,
            reason: '"${tile.title}" anchors to "$heading", which is no longer '
                'a heading in "$id". It would open at the top instead — which '
                'is safe and silent, and stops the card doing the one thing it '
                'was built for.');
      }
      expect(anchored, greaterThanOrEqualTo(5),
          reason: 'the promoted cards have stopped being anchored');
    });

    test('and no two promoted cards land in the same place', () {
      // Two cards opening one paragraph is the fake promotion the anchor exists
      // to prevent. It is why "What recurrent-loss investigation looks like"
      // is not built — see the note in the door, and STILL-OPEN §26.
      final seen = <String>[];
      for (final tile in tiles()) {
        final (id, heading) = switch (tile) {
          TtcGuideTile(:final readId, :final atHeading) => (readId, atHeading),
          TtcArticleTile(:final readId, :final atHeading) => (readId, atHeading),
          _ => (null, null),
        };
        if (id == null || heading == null) continue;
        seen.add('$id#$heading');
      }
      expect(seen.toSet().length, seen.length,
          reason: 'two cards open the same section: $seen');
    });

    test('the two articles are the single source, and nothing is copied', () {
      // Every read this area names is one of the two Dr. Ananya Rao pieces.
      final ids = <String>{};
      for (final tile in tiles()) {
        if (tile is TtcGuideTile) ids.add(tile.readId);
        if (tile is TtcArticleTile && tile.readId != null) {
          ids.add(tile.readId!);
        }
      }
      expect(ids, {'ttc_read_loss_recovery', 'ttc_read_trying_again'});
    });
  });

  // ===========================================================================
  group('the red flags are pinned, and they are the articles own words', () {
    test('two tabs pin one, and both reads exist', () {
      final pinned = page.groups!
          .where((g) => g.pinnedRedFlagReadIds.isNotEmpty)
          .toList();
      expect(pinned.map((g) => g.id).toSet(), {'body', 'support'});
      for (final g in pinned) {
        final read = ttcReadById(g.pinnedRedFlagReadIds.first);
        expect(read, isNotNull, reason: '${g.id} pins a read that is gone');
        expect(read!.whenToSeeSomeone.tone, PvCalloutTone.urgent);
      }
    });

    test('the Support flag still carries the self-harm routing', () {
      // ⚠️ THE BRIEF SAYS IN AS MANY WORDS THAT THIS MUST NOT BE LOST OR
      // BURIED. It is a sentence inside a doctor-written callout, and the way
      // it gets lost is not deletion — it is somebody excerpting the callout
      // to make a tidier card.
      final support =
          page.groups!.firstWhere((g) => g.id == 'support');
      final body = ttcReadById(support.pinnedRedFlagReadIds.first)!
          .whenToSeeSomeone
          .body
          .en
          .toLowerCase();
      expect(body, contains('harming yourself'));
      expect(body, contains('today'));
    });

    test('and the hospital flag names what to act on', () {
      final bodyTab = page.groups!.firstWhere((g) => g.id == 'body');
      final flag = ttcReadById(bodyTab.pinnedRedFlagReadIds.first)!.whenToSeeSomeone;
      expect(flag.title.en.toLowerCase(), contains('hospital'));
      final body = flag.body.en.toLowerCase();
      for (final sign in ['pads', 'fever', 'faint']) {
        expect(body, contains(sign), reason: sign);
      }
    });
  });

  // ===========================================================================
  group('what this area deliberately does not have', () {
    test('no tool, no tracker, no self-check', () {
      // ⚠️ NOT AN OVERSIGHT AND NOT A GAP TO FILL LATER. Every other TTC door
      // has a tool. The only candidate here is a recovery tracker, and turning
      // miscarriage recovery into a number to log is the one place a tool does
      // harm rather than help.
      for (final g in page.groups!) {
        expect(g.toolSurfaceId, isNull,
            reason: '${g.id} has grown a tool');
      }
      expect(tiles().whereType<TtcToolTile>(), isEmpty);
      expect(tiles().whereType<TtcDoTile>(), isEmpty);
      expect(tiles().whereType<TtcChecklistTile>(), isEmpty);
    });

    test('nothing is sold from the top of the page', () {
      // A course in the headline slot, on a page somebody opened three days
      // after a miscarriage, is the worst placement of a price in this product.
      expect(page.headline, isNull);
    });

    test('the one paid thing is last, and it is the existing cohort', () {
      final last = page.sections.last.tiles.last;
      expect(last, isA<TtcMasterclassTile>());
      final id = (last as TtcMasterclassTile).offeringId;
      expect(ttcOfferingById(id), isNotNull,
          reason: 'the cohort "$id" is not in the catalogue, so a second one '
              'has been invented rather than the Prepare-tab group reused');
      // And its blurb carries no price — the bracket's own rule: reached
      // through a person, not a product row.
      expect(last.blurb, isNot(contains('₹')));
      expect(last.blurb.toLowerCase(), isNot(contains('rs ')));
    });
  });

  // ===========================================================================
  group('the shape the brief asked for', () {
    test('four tabs, Your body first', () {
      expect(page.groups!.map((g) => g.id).toList(),
          ['body', 'understand', 'again', 'support']);
    });

    test('and the hero is kept word for word', () {
      expect(page.intro, contains('No rush'));
      expect(page.intro, contains('no timeline you have to keep'));
    });

    test('every section belongs to a tab that exists', () {
      final ids = page.groups!.map((g) => g.id).toSet();
      for (final s in page.sections) {
        expect(s.group, isNotNull, reason: '"${s.heading}" has no tab');
        expect(ids, contains(s.group), reason: '"${s.heading}"');
      }
    });

    testWidgets('the page builds', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(page.allTiles, isNotEmpty);
    });
  });
}
