// =============================================================================
//  Product Guide — the CTAs actually go somewhere
// -----------------------------------------------------------------------------
//  Compare, the expert videos and Ask Veda were all "coming soon" snackbars
//  sitting on a page whose whole job is to be trustworthy - and two of them had
//  live Brand Studio sponsorship slots on top of them. These tests exist so a
//  dead CTA cannot come back unnoticed.
//
//  The lesson is recorded: build the host feature before its sponsorship.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/product_guide/product_guide_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_watch_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';

void main() {
  group('the guide catalogue is wired to real things', () {
    test('every expert video id resolves to a real video', () {
      for (final g in kProductGuides) {
        for (final e in g.experts) {
          final id = e.videoId;
          if (id == null) continue; // honest "still being filmed"
          expect(
            kWatchVideos.any((v) => v.id == id),
            isTrue,
            reason: '${g.name}: expert ${e.name} points at "$id", which is not '
                'in the Watch catalogue - the card would open nothing',
          );
        }
      }
    });

    test('the sponsored expert surface has hosts to sponsor', () {
      // BrandSlot.productGuideExpert sells this surface. If no guide has a real
      // video, we are selling inventory that sits on top of nothing.
      final withVideo = kProductGuides
          .where((g) => g.experts.any((e) => e.videoId != null))
          .length;
      expect(withVideo, greaterThan(0),
          reason: 'live sponsorship needs at least one real expert video');
    });

    test('related guide ids all resolve', () {
      for (final g in kProductGuides) {
        for (final id in g.relatedIds) {
          expect(pgById(id), isNotNull,
              reason: '${g.name} links to guide "$id", which does not exist');
        }
      }
    });

    test('guides can pre-fill the Compare tray', () {
      // A guide names a TYPE ("Fragrance-free baby lotion"); the catalogue
      // names SKUs ("Soothe Baby Lotion"). Matching on the whole string finds
      // nothing - which is exactly what this test caught - so the screen
      // matches on the meaningful noun. If that stops working, Compare opens
      // an untouched tray and the CTA becomes decorative again.
      const nouns = [
        'lotion', 'wash', 'wipe', 'diaper', 'nappy', 'sterilis', 'steriliz',
        'pump', 'formula', 'carrier', 'stroller', 'bottle', 'cream', 'sunscreen',
      ];
      final matched = kProductGuides.where((g) {
        final gn = g.name.toLowerCase();
        final noun = nouns.where(gn.contains);
        return noun.isNotEmpty &&
            kPpProducts.any((p) => noun.any((n) => p.name.toLowerCase().contains(n)));
      }).length;
      expect(matched, greaterThan(0),
          reason: 'no guide can pre-fill Compare, so the CTA is decorative');
    });
  });

  group('the guide keeps its promises', () {
    test('every guide answers the 10-second question', () {
      for (final g in kProductGuides) {
        expect(g.verdict.trim(), isNotEmpty, reason: '${g.name} has no verdict');
        expect(g.verdict.split(' ').length, lessThanOrEqualTo(24),
            reason: '${g.name}: the verdict must be scannable, not a paragraph');
        expect(g.beforeYouBuy.trim(), isNotEmpty,
            reason: '${g.name} has no "before you buy" line - the one thing '
                'that makes this page ParentVeda rather than a shop');
      }
    });

    test('the honest look stays honest — and short', () {
      for (final g in kProductGuides) {
        expect(g.watchOut.length, lessThanOrEqualTo(3),
            reason: '${g.name}: at most three things to watch out for');
        expect(g.whyLike.length, lessThanOrEqualTo(3),
            reason: '${g.name}: at most three reasons to like it');
        // A guide that only praises is an advert.
        if (g.reco != PgReco.notRecommended) {
          expect(g.watchOut, isNotEmpty,
              reason: '${g.name} lists nothing to watch out for, which reads '
                  'as marketing rather than guidance');
        }
      }
    });
  });
}
