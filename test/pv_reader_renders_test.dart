// =============================================================================
//  Every TTC read actually renders
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE A LAYOUT CRASH SHIPPED THROUGH A GREEN SUITE, and the
//  gap it exposes is worth stating plainly: 2,935 tests passed while the
//  article reader threw `BoxConstraints forces an infinite height` on every
//  read that had a "What you can do with this" section — which is most of them.
//
//  Nothing caught it because nothing PUMPED the reader with real content. The
//  read tests assert on the data (`pv_read_shape_test` counts sections,
//  headings, FAQs, words) and `ttc_reader_test` pumps a daily insight, which
//  takes a different path. Every one of them would have kept passing while the
//  screen they describe was unable to lay itself out.
//
//  The specific mistake was `Row(crossAxisAlignment: CrossAxisAlignment.stretch)`
//  inside a `Column` inside a `ListView`. `stretch` asks children to fill the
//  Row's cross-axis extent, so the Row must know its own height first; in an
//  unbounded column there is no height, and it passes `h=Infinity` down. This
//  is a compile-clean, analyzer-clean, silently-catastrophic combination, and
//  it is easy to write twice — it was, in the same batch.
//
//  ⚠️ SO THE ASSERTION IS "IT LAYS OUT", NOTHING CLEVERER. A render test that
//  looks for particular strings is a content test wearing a widget test's
//  clothes. This one exercises the thing no data test can: the layout.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// `Image.network` in a widget test otherwise fetches and fails; the reader's
/// hero uses one on the reads that carry a photo.
class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpAll(() => HttpOverrides.global = _NoNet());

  Future<void> pump(WidgetTester tester, Widget child) async {
    // ⚠️ A NARROW VIEWPORT ON PURPOSE. A 1200pt-wide test surface hides
    // overflows that a 360pt phone shows, and the next-step tiles sit two
    // across — the exact place a real device runs out of width first.
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('the reader lays out for every TTC read', () {
    for (final read in kTtcReads) {
      testWidgets(read.id, (tester) async {
        await pump(
            tester, PvReaderScreen(read: read, lang: AppLanguage.english));
        expect(tester.takeException(), isNull,
            reason: '"${read.id}" could not lay itself out');
      });
    }
  });

  testWidgets('and it scrolls to the bottom without throwing', (tester) async {
    // ⚠️ SCROLLING IS PART OF THE TEST, not politeness. A `ListView` only builds
    // what is near the viewport, so the sections that crashed — next steps,
    // evidence, read-next — are genuinely absent until something scrolls them
    // into range. A render test that never scrolls proves the masthead works.
    final read = kTtcReads.firstWhere((r) => r.nextSteps.isNotEmpty);
    await pump(tester, PvReaderScreen(read: read, lang: AppLanguage.english));

    for (var i = 0; i < 25; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull,
          reason: 'threw while scrolling "${read.id}"');
    }
  });
}
