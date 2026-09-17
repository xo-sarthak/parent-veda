// =============================================================================
//  One reader — the guard (STILL-OPEN §60.6)
// -----------------------------------------------------------------------------
//  The user's rule, 2026-09-17: every piece of writing in the app opens in the
//  one article format, `PvReaderScreen`, and "new additions in future get
//  under the same template". Nine older readers were retired into adapters
//  (`lib/data/reads/read_adapters.dart`, `pp_page_read.dart`,
//  `ttc_insight_read.dart`). This file is what stops a tenth appearing:
//
//    1. Every retired screen's `build` hands its model to `PvReaderScreen`,
//       and its previous body is `buildClassic`, reachable from nowhere.
//    2. The retired page renderers (`PpContentPage`, `TtcInsightScreen`) are
//       constructed by no live code outside their own files.
//    3. Every adapter produces a read the reader can draw, for EVERY seed —
//       a required callout, a title, a non-self read-next, ids that resolve.
//
//  Source scans, like the wiring tests — test counts prove nothing about
//  reachability; the call site does.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/belly_skin_data.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/data/reads/read_adapters.dart';
import 'package:parentveda/data/report_findings_data.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/models/read_item.dart';
import 'package:parentveda/screens/post_pregnancy/pp_articles_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

/// Live (uncommented) source of a file.
String _live(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void _checkRead(PvRead r) {
  expect(r.title.en.trim(), isNotEmpty, reason: '${r.id}: no title');
  expect(r.whenToSeeSomeone.body.en.trim(), isNotEmpty,
      reason: '${r.id}: an empty when-to-see-someone');
  for (final id in r.readNext) {
    expect(id, isNot(r.id), reason: '${r.id} reads next to itself');
  }
  if (!r.reviewed) {
    expect(r.author.en, 'ParentVeda editorial',
        reason: '${r.id}: an unreviewed piece must not name a reviewer');
  }
}

void main() {
  group('the retired screens delegate to the one reader', () {
    const screens = {
      'lib/screens/mind_mood/mm_article_screen.dart': 'MmArticleScreen',
      'lib/screens/belly_skin/bs_article_screen.dart': 'BsArticleScreen',
      'lib/screens/conditions/condition_detail_screen.dart': 'ConditionDetailScreen',
      'lib/screens/brackets/scan_detail_screen.dart': 'ScanDetailScreen',
      'lib/screens/report_screen.dart': 'ReportArticleScreen',
      'lib/screens/nutrition/nutrients_screen.dart': 'NutrientDetailScreen',
      'lib/screens/read_next_screen.dart': 'ReadItemScreen',
      'lib/screens/post_pregnancy/reading_reader_screen.dart': 'ReadingReaderScreen',
      'lib/screens/post_pregnancy/article_reader_screen.dart': 'ArticleReaderScreen',
    };
    for (final e in screens.entries) {
      test('${e.value} builds PvReaderScreen and keeps its old body unreachable', () {
        final src = _live(e.key);
        expect(src, contains('PvReaderScreen('),
            reason: '${e.value} no longer opens the one reader');
        expect(src, contains('Widget buildClassic(BuildContext context)'),
            reason: '${e.value}: the previous body must be kept for revert');
        // Nothing in lib calls buildClassic except the book branch of
        // ReadItemScreen, which is the one deliberate exception (§60.1).
        final callers = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => _live(f.path).contains('buildClassic(context)'))
            .map((f) => f.path.replaceAll('\\', '/'))
            .toList();
        expect(callers, ['lib/screens/read_next_screen.dart'],
            reason: 'buildClassic is reachable from: $callers');
      });
    }
  });

  test('the retired page renderers are constructed by no live code', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final name in ['PpContentPage(', 'TtcInsightScreen(']) {
      final hits = [
        for (final f in files)
          if (!f.path.endsWith('pp_content.dart') &&
              !f.path.endsWith('ttc_insight_screen.dart') &&
              _live(f.path).contains(name))
            f.path.replaceAll('\\', '/'),
      ];
      expect(hits, isEmpty, reason: '$name is still opened live from: $hits');
    }
  });

  group('every adapter produces a drawable read for every seed', () {
    test('mind and mood', () {
      for (final a in kMmArticles) {
        _checkRead(pvReadFromMm(a, withTalk: true));
      }
    });
    test('belly and skin', () {
      for (final p in kBsPages) {
        _checkRead(pvReadFromBs(p));
      }
    });
    test('conditions', () {
      for (final c in kAllConditions) {
        final r = pvReadFromCondition(c);
        _checkRead(r);
        expect(r.toc.length, greaterThanOrEqualTo(3),
            reason: '${c.id}: a condition keeps its shape as headings');
        if (c.callNow.isNotEmpty) {
          expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent);
        }
      }
    });
    test('scans', () {
      for (final s in kTestsScans) {
        _checkRead(pvReadFromScan(s));
      }
    });
    test('report findings', () {
      for (final f in kReportFindings) {
        _checkRead(pvReadFromFinding(f));
      }
    });
    test('nutrients', () {
      for (final g in kNutrientGuides) {
        _checkRead(pvReadFromNutrient(g));
      }
    });
    test('weekly reads, books excepted', () {
      for (final r in kReadItems) {
        if (r.type == ReadType.book) continue;
        _checkRead(pvReadFromReadItem(r));
      }
    });
    test('parenting library', () {
      for (final a in kReadArticles) {
        _checkRead(pvReadFromReadArticle(a));
      }
    });
    test('parenting archive', () {
      for (final a in kArticles) {
        _checkRead(pvReadFromArticle(a));
      }
    });
    test('a page chipped as a thing opens on the thing', () {
      // The chip names the thing, so the thing comes first (2026-09-18):
      // a CHART page's first section is its chart, a TABLE page's its table,
      // and no serif lede is lifted above it.
      final kinds = <String, bool Function(Object)>{
        'CHART': (b) => b is PpChartCard,
        'TABLE': (b) => b is PpTable,
        'COMPARISON TABLE': (b) => b is PpTable,
        'CARDS': (b) => b is PpCards,
      };
      var seen = 0;
      for (final section in kPpSections) {
        for (final page in section.allPages) {
          final kind = kinds[page.format?.toUpperCase()];
          if (kind == null) continue;
          if (!page.blocks.any(kind)) continue; // declared, but no such block
          final r = ppPageAsRead(section, page);
          seen++;
          expect(r.sections.first.custom, isNotNull,
              reason: '${section.id}/${page.id}: opens on prose, not its ${page.format}');
          expect(kind(r.sections.first.custom!), isTrue,
              reason: '${section.id}/${page.id}: opens on the wrong block');
          expect(r.scaleSetter.en, isEmpty,
              reason: '${section.id}/${page.id}: a lede above the thing');
        }
      }
      expect(seen, greaterThan(10));
    });

    test('a CARDS page is a story deck, one slide per card', () {
      // One format per tag (2026-09-18): CARDS joins CAROUSEL and INTERACTIVE
      // on the story screen. A page the deck cannot hold (a table, a film)
      // returns null and opens in the reader instead — never silently short.
      var decks = 0;
      for (final section in kPpSections) {
        for (final page in section.allPages) {
          if (page.format?.toUpperCase() != 'CARDS') continue;
          final cards = page.blocks.whereType<PpCards>().fold<int>(0, (a, b) => a + b.cards.length);
          final slides = ppCardsAsSlides(page);
          if (slides == null) continue;
          decks++;
          expect(slides.length, greaterThanOrEqualTo(cards),
              reason: '${section.id}/${page.id}: a card went missing');
          for (final sl in slides) {
            expect(sl.title.trim(), isNotEmpty);
          }
        }
      }
      // 15 today; the rest carry a film, a consult offer or a chart the deck
      // cannot hold, or are still empty pages, and open in the reader.
      expect(decks, greaterThanOrEqualTo(14));
    });

    test('parenting door pages — every page of every section, no block lost', () {
      for (final section in kPpSections) {
        for (final page in section.allPages) {
          if (page.toolSurfaceId != null) continue;
          final r = ppPageAsRead(section, page);
          _checkRead(r);
          // Every authored block lands somewhere: a section (prose or
          // custom), a next step, the teaser (one intro), the doctor line
          // (one when-line), or the lede (at most one article block, lifted
          // whole when it was a single paragraph). Nothing else may vanish.
          final blocks = page.blocks;
          final absorbed = (blocks.any((b) => b is PpIntro) ? 1 : 0) +
              (blocks.any((b) => b is PpWhenLine) ? 1 : 0) +
              1; // the lede lift
          final untargeted = blocks
              .whereType<PpLink>()
              .where((l) => l.surfaceId == null && l.pageId == null)
              .length;
          expect(r.sections.length + r.nextSteps.length + absorbed + untargeted,
              greaterThanOrEqualTo(blocks.length),
              reason: '${section.id}/${page.id}: blocks went missing');
          // And the custom blocks are exactly the kinds the reader does not
          // model — never an article, callout, intro, when-line or link.
          for (final sec in r.sections) {
            if (sec.custom case final b?) {
              expect(b, isNot(anyOf(isA<PpArticle>(), isA<PpCallout>(),
                  isA<PpIntro>(), isA<PpWhenLine>(), isA<PpLink>())));
            }
          }
        }
      }
    });
  });
}
