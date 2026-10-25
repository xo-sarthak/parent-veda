// =============================================================================
//  Wave 8 (2026-10-23): "Something changed?" remembered and feeding the
//  relevance brain, the phase video list, and the activity paintings.
//  Approved in claude.ai/artifact/RwVWyxCE6VzYoFFJCakaCP.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/pp_phase_videos.dart';
import 'package:parentveda/screens/post_pregnancy/pp_activity_paintings.dart';
import 'package:parentveda/screens/post_pregnancy/pp_changes_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/services/pp_use_consent.dart';

WcConcern _concern(String id) => kWcConcerns.firstWhere((c) => c.id == id);

String _live(String path) =>
    File(path).readAsLinesSync().where((l) => !l.trimLeft().startsWith('//')).join('\n');

const _titles = [
  'Your baby\'s first vaccines',
  'A bottle set for the first months',
  'Why babies wake at night',
  'Tummy time without tears',
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpChangesStore.instance.debugReset();
    // Read only after her yes (tools pass H3, 2026-10-25).
    PpUseConsent.instance.debugReset();
    PpUseConsent.instance.set(PpUseKind.changes, true);
  });

  group('the store', () {
    test('a change is remembered, active for three weeks, then lapses', () {
      final s = PpChangesStore.instance;
      s.note(_concern('wake_2h'), WcTone.calm);
      expect(s.isActive('wake_2h'), isTrue);
      expect(s.active().single.concernId, 'wake_2h');
      final later = DateTime.now().add(kPpChangeActiveFor + const Duration(days: 1));
      expect(s.active(now: later), isEmpty);
    });

    test('"Better now" forgets it', () {
      final s = PpChangesStore.instance;
      s.note(_concern('wake_2h'), WcTone.calm);
      s.clear('wake_2h');
      expect(s.active(), isEmpty);
    });

    test('it syncs one item per child and concern, and reads back', () {
      final s = PpChangesStore.instance;
      s.note(_concern('wake_2h'), WcTone.caution);
      final items = s.cloudItems();
      expect(items.keys.single, startsWith('c|'));
      expect(items.keys.single, endsWith('|wake_2h'));
      s.debugReset();
      s.applyCloudItems(items);
      expect(s.active().single.tone, WcTone.caution);
    });
  });

  group('the brain', () {
    PpSituation told(WcTone tone) {
      final s = PpChangesStore.instance..note(_concern('wake_2h'), tone);
      return PpSituation(ageMonths: 1, daysOld: 30, changes: s.active());
    }

    test('what she told us lifts matching pages and says why, dropping nothing', () {
      final sit = told(WcTone.calm);
      final out = ppRelevanceOrder(_titles.toList(), situation: sit, text: (t) => t);
      expect(out.first, 'Why babies wake at night');
      expect(out.toSet(), _titles.toSet());
      expect(ppRelevanceWhy(sit, 'Why babies wake at night'), startsWith('Because you said: '));
    });

    test('an urgent change never lifts a product', () {
      final sit = told(WcTone.urgent);
      const products = ['Baby carrier', 'Night light for sleep'];
      expect(ppRelevanceOrder(products.toList(), situation: sit, text: (t) => t, commerce: true), products);
      // ...but it still lifts the reads.
      expect(ppRelevanceOrder(_titles.toList(), situation: sit, text: (t) => t).first, 'Why babies wake at night');
    });
  });

  test('wired: the flow saves, the home shows it, the brain reads it', () {
    expect(_live('lib/screens/post_pregnancy/what_changed_screen.dart'), contains('PpChangesStore.instance.note('));
    expect(_live('lib/screens/post_pregnancy/pp_home_v3.dart'), contains("ValueKey('pp_home_told')"));
    expect(_live('lib/screens/post_pregnancy/pp_relevance.dart'), contains('PpChangesStore.instance.active()'));
    expect(_live('lib/main.dart'), contains('PpChangesStore.instance.init()'));
  });

  test('phase videos: the list leads the pick, and a length reads as m:ss', () {
    expect(_live('lib/screens/post_pregnancy/pp_home_reads.dart'), contains('kPhaseVideos[phase.number]'));
    expect(ppVideoLength(220), '3:40');
    expect(ppVideoLength(65), '1:05');
  });

  testWidgets('an activity with no painting keeps its mark', (t) async {
    await t.pumpWidget(const MaterialApp(
        home: PpActivityThumb(activityId: 'no_such_activity', fallback: Text('mark'))));
    expect(find.text('mark'), findsOneWidget);
    expect(ppActivityPainting('no_such_activity'), isNull);
  });

  test('wired: all three activity lists and the reader use the painting', () {
    for (final f in [
      'lib/screens/post_pregnancy/pp_home_v3.dart',
      'lib/screens/post_pregnancy/pp_phase_page.dart',
      'lib/screens/post_pregnancy/development_all_activities_screen.dart',
    ]) {
      expect(_live(f), contains('PpActivityThumb('), reason: f);
    }
    expect(_live('lib/screens/post_pregnancy/pp_activity_read.dart'), contains('imageUrl: ppActivityPainting(a.id)'));
  });
}
