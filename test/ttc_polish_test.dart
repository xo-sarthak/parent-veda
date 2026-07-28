// =============================================================================
//  The last pass - read times, the questions worth asking, and Prepare
// -----------------------------------------------------------------------------
//  Deliberately NOT here: pregnancy's "A little deeper" panel. TtcInsight has
//  no field for it, so adding one means authoring twenty-four new explainers
//  about fertility - content commissioning, not a UI change, and not something
//  to invent. Recorded in the audit as outstanding rather than half-done.
//
//  What "Remember" does on the pregnancy reader, "Today's takeaway" already
//  does here. That half of the finding was satisfied before I got to it.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_prepare_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_chapter_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('read time comes from the writing, not a default', () {
    test('every insight declared 45 seconds regardless of length', () {
      // The old field is still there as a fallback; nothing should rely on it.
      final lengths = ttcInsights.map((i) => i.readTime(false)).toSet();
      expect(lengths.length, greaterThan(1),
          reason: 'every piece still claims the same length');
    });

    test('a short piece never claims to be instant', () {
      for (final i in ttcInsights) {
        expect(i.readTime(false), greaterThanOrEqualTo(15), reason: i.id);
      }
    });

    test('and a longer piece reads as longer', () {
      final sorted = [...ttcInsights]
        ..sort((a, b) => a.bodyEn.length.compareTo(b.bodyEn.length));
      expect(sorted.last.readTime(false),
          greaterThan(sorted.first.readTime(false)));
    });
  });

  // ===========================================================================
  group('the suggested questions include the hard ones', () {
    test('every chapter offers something beyond the factual', () {
      // The suggestions define what feels askable. Three clinical questions
      // per chapter quietly said the emotional ones do not belong here - in a
      // stage whose own Ask Veda card promises "the questions that feel awkward
      // to ask out loud".
      for (final c in TtcChapter.values) {
        final qs = ttcChapterContent[c]!.askVeda(false).join(' ').toLowerCase();
        final human = ['normal', 'scared', 'anxious', 'fault', 'how long',
            'stress', 'task', 'get through'];
        expect(human.any(qs.contains), isTrue,
            reason: '$c offers only clinical questions');
      }
    });

    test('and at least one names him', () {
      final all = [
        for (final c in TtcChapter.values)
          ...ttcChapterContent[c]!.askVeda(false)
      ].join(' ').toLowerCase();
      expect(all, contains('he '),
          reason: 'nothing invited a question about his half');
    });

    test('every chapter is bilingual and balanced', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.askVeda(false).length, content.askVeda(true).length,
            reason: '$c has a different number of questions per language');
        expect(content.askVeda(false).length, greaterThanOrEqualTo(5),
            reason: '$c');
      }
    });
  });

  // ===========================================================================
  group('Prepare says where she is', () {
    testWidgets('the eyebrow carries the chapter, not just the tab name',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(key: UniqueKey(), home: const TtcPrepareScreen()));
      await tester.pumpAndSettle();

      final chapter =
          TtcStore.instance.today.chapter.title(false).toUpperCase();
      expect(find.textContaining(chapter), findsWidgets,
          reason: '"PREPARE" alone said nothing she did not already know');
    });
  });
}
