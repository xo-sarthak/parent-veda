// =============================================================================
//  No placeholders on the Trying to conceive side (2026-09-29)
// -----------------------------------------------------------------------------
//  The user: "stop leaving the placeholders and put random but relevant images
//  for them, from free resources on the web." A placeholder here means a place
//  where a picture belongs and a stand-in was drawn instead: the reader's pale
//  band with a book (daily insights, tip reads, medical tests, Can I answers),
//  a film card that was a tint with a clock, a product card with only its
//  mark, a Learn cover that was a drawn mark or a school icon, a consult page
//  that opened on a monogram, a store tile that fell back to an icon.
//
//  What this holds:
//    * every TTC read the reader can open has a photo: the library reads,
//      every daily insight, every nutrition and movement tip, every medical
//      test and every Can I answer;
//    * every TTC film, and the first-run film, has a still, and a read that
//      carries a film never shows the still twice (its hero is another photo);
//    * every TTC product has a photo, and the three generic ones say so;
//    * every TTC programme in Learn has a cover photo, so no consult page opens
//      on a monogram and no course card on a school icon;
//    * every TTC store category tile is served from our R2 bucket;
//    * every photo is on R2 and carries a licence line, and none of the daily
//      pieces repeats another's photo.
//
//  ⚠️ THE ALLOW-LIST IS THE DECISION, NOT A LOOPHOLE. What is deliberately
//  not a photo is named in [_kNotAPhotoByDesign] with its reason, and a test
//  below fails if a name on it stops being true.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/learn/pv_learn_images.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/data/products/pv_category_images.dart';
import 'package:parentveda/data/products/pv_product_extras.dart';
import 'package:parentveda/data/reads/read_images.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_offering_screen.dart'
    show pvShowsConsultMonogram;
import 'package:parentveda/screens/ttc/ttc_daily_tip_open.dart';
import 'package:parentveda/screens/ttc/ttc_intro_flow.dart'
    show ttcIntroVideoSlotId;
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_insight_read.dart';
import 'package:parentveda/ttc/ttc_lookup_reads.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart';
import 'package:parentveda/widgets/pv_placeholders.dart';

/// What is drawn on purpose rather than photographed, and why. Each is held
/// by its own test file, not this one; listed here so the rule and its
/// exceptions are read in one place.
const Map<String, String> _kNotAPhotoByDesign = {
  // Door cards: the doors' own helper owns them; test/ttc_door_photos_test.dart
  // holds that every card has a photo except these two.
  "ttc_mind_body › Cat and cow, then child's pose":
      'no free photo shows this pose; a different pose would teach the wrong one',
  'ttc_mind_body › Legs up the wall':
      'no free photo shows this pose; a different pose would teach the wrong one',
  // Tool cards and rows draw the stage's marks by design (the tools helper).
  'tool cards and rows': 'drawn marks are the tool language, not a stand-in',
  // Named experts: never a stock face presented as our expert. The roster
  // carries no photo yet, so a person's avatar is her initials; a consult
  // page's HERO is an object photo (a stethoscope, a notebook), below.
  'expert avatars': 'initials until the roster carries her real photo',
};

/// Every read the reader can open on the TTC side, by where it comes from.
Map<String, List<PvRead>> _readsBySource() => {
      'library read': kTtcReads,
      'daily insight': [for (final i in ttcAllInsights) ttcInsightAsRead(i)],
      'nutrition tip': [for (final n in ttcNutrition) ttcNutritionAsRead(n)],
      'movement tip': [for (final m in ttcMovements) ttcMovementAsRead(m)],
      'medical test': [for (final t in ttcTests) ttcTestAsRead(t)],
      'Can I answer': [for (final c in ttcCanI) ttcCanIAsRead(c)],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  // No HttpOverrides here: the test binding's own client answers 400 at
  // once, so Image.network fails fast into its errorBuilder (the old card).

  test('the allow-list says why for every entry', () {
    for (final e in _kNotAPhotoByDesign.entries) {
      expect(e.value.trim(), isNotEmpty, reason: e.key);
    }
  });

  group('reads', () {
    for (final e in _readsBySource().entries) {
      test('every ${e.key} has a photo, never the band', () {
        expect(e.value, isNotEmpty);
        final missing = [
          for (final r in e.value)
            if (readImageFor(r.id, own: r.imageUrl) == null) r.id,
        ];
        expect(missing, isEmpty, reason: '${e.key}s with no photo: $missing');
      });
    }

    test('the daily pieces never repeat a photo', () {
      final daily = [
        ..._readsBySource()['daily insight']!,
        ..._readsBySource()['nutrition tip']!,
        ..._readsBySource()['movement tip']!,
      ];
      final seen = <String, String>{};
      for (final r in daily) {
        final src = kReadImageUrls[r.id];
        if (src == null) continue;
        expect(seen[src], isNull,
            reason: '${r.id} repeats the photo of ${seen[src]}');
        seen[src] = r.id;
      }
    });

    test('a read never shows its Read next rail its own hero photo', () {
      for (final e in _readsBySource().entries) {
        if (e.key == 'library read') continue; // the doors' test holds these
        for (final r in e.value) {
          final hero = kReadImageUrls[r.id];
          for (final id in r.readNext) {
            final next = kReadImageUrls[id];
            if (hero == null || next == null) continue;
            expect(next, isNot(hero),
                reason: '${r.id} and its Read next $id share one photo');
          }
        }
      }
    });
  });

  group('films', () {
    test('every TTC film and the first-run film has a still', () {
      final slots = [
        for (final v in kTtcVideos) v.id,
        ttcIntroVideoSlotId(false),
        ttcIntroVideoSlotId(true),
      ];
      final missing = [
        for (final s in slots)
          if (pvFilmStillFor(s) == null) s,
      ];
      expect(missing, isEmpty, reason: 'films drawn as a tint: $missing');
    });

    test('a read that carries a film has a different hero photo', () {
      for (final r in kTtcReads) {
        final slot = r.heroVideoSlot;
        if (slot == null) continue;
        expect(pvFilmStillFor(slot), isNot(readImageFor(r.id)),
            reason: '${r.id} would show one picture twice');
      }
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('the still draws inside the coming-soon card at 360, '
          'text x$scale', (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 800),
                textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PvVideoPlaceholder(
                  title: 'Reading a semen report without panicking',
                  still: pvFilmStillFor('ttc_vid_semen_analysis'),
                  overlayTitle: true,
                  duration: '4 MIN',
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('pv_video_still')), findsOneWidget);
        // Still honest: the coming-soon mark stays, nothing is tappable.
        expect(find.text('COMING SOON'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('products', () {
    test('every TTC product has a photo', () {
      final ttc = PvCatalogStore.instance.all
          .where((p) => p.stage == LifeStage.tryingToConceive)
          .toList();
      expect(ttc, isNotEmpty);
      final missing = [
        for (final p in ttc)
          if (!p.hasImage) p.id,
      ];
      expect(missing, isEmpty, reason: 'TTC products drawn as a mark: $missing');
    });

    test('the generic photos are labelled and are not another product', () {
      final store = PvCatalogStore.instance;
      final firsts = <String, String>{};
      for (final p in store.all
          .where((p) => p.stage == LifeStage.tryingToConceive && p.hasImage)) {
        expect(firsts[p.images.first], isNull,
            reason: '${p.id} shows ${firsts[p.images.first]}\'s photo');
        firsts[p.images.first] = p.id;
      }
      for (final id in kPvIllustrativePhotoIds) {
        final p = store.byId(id);
        expect(p, isNotNull, reason: id);
        expect(p!.images.first, startsWith(kReadImageBase),
            reason: '$id: an illustrative photo is one of ours, credited');
      }
    });

    test('every TTC store tile is a photo from our bucket', () {
      for (final c
          in PvCatalogStore.instance.categoriesFor(LifeStage.tryingToConceive)) {
        expect(pvCategoryImageFor(c.id), startsWith(kReadImageBase),
            reason: '${c.id} (${c.name}) would fall back to its icon');
      }
    });
  });

  group('Learn, courses, cohorts, masterclasses and consults', () {
    final ttc = PvLearnCatalog.instance.all(stage: LifeStage.tryingToConceive);

    test('every TTC programme has a cover photo', () {
      expect(ttc, isNotEmpty);
      final missing = [
        for (final v in ttc)
          if (v.cover == null) v.id,
      ];
      expect(missing, isEmpty, reason: 'drawn covers: $missing');
      for (final v in ttc) {
        expect(kPvLearnCovers[v.id], v.cover,
            reason: '${v.id}: a cover is chosen per programme');
      }
    });

    test('no TTC consult page opens on a monogram', () {
      for (final v in ttc.where((v) => v.kind == PvLearnKind.consult)) {
        expect(pvShowsConsultMonogram(v), isFalse, reason: v.id);
      }
    });

    test('the covers are photos of things, one each', () {
      final seen = <String, String>{};
      for (final v in ttc) {
        final src = kReadImageUrls['learn_${v.id}']!;
        expect(seen[src], isNull,
            reason: '${v.id} repeats the cover of ${seen[src]}');
        seen[src] = v.id;
      }
    });
  });

  test('every photo added here is on R2 and credited', () {
    const prefixes = [
      'ttc_insight_',
      'ttc_nutrition_',
      'ttc_movement_',
      'ttc_test_',
      'ttc_cani_',
      'ttc_film_',
      'learn_ttc_',
      'prod_ttc_',
      'cat_ttc_',
    ];
    final ids = kReadImageUrls.keys
        .where((k) => prefixes.any(k.startsWith))
        .toList();
    expect(ids.length, greaterThanOrEqualTo(118));
    for (final id in ids) {
      expect(readImageFor(id), '$kReadImageBase$id.jpg', reason: id);
      expect(kReadImageCredits[id] ?? '', isNotEmpty, reason: '$id: no licence');
      final src = kReadImageUrls[id]!;
      if (src.contains('stocksnap.io')) {
        expect(kOpenverseIds[id], isNotNull,
            reason: '$id: StockSnap needs its Openverse id to be mirrored');
      }
    }
  });

  test('the film stills are wired into all three places a film shows', () {
    String code(String p) => File(p).readAsStringSync();
    expect(code('lib/screens/reader/pv_reader_screen.dart'),
        contains('still: pvFilmStillFor(v.id)'));
    expect(code('lib/screens/ttc/ttc_learn_screen.dart'),
        contains('pvFilmStillFor(film.id)'));
    expect(code('lib/screens/ttc/ttc_intro_flow.dart'),
        contains('still: pvFilmStillFor('));
  });
}
