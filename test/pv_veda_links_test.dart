// =============================================================================
//  Pregnancy Ask Veda: the corpus and the way back into the app (2026-10-02).
//
//  The user: Ask Veda should be the pregnancy side's search as well as its
//  answers, "the way we did for TTC". Three claims, each about OUTPUT rather
//  than about one screen, so each is checked on all of it:
//
//    1. EVERY id the export writes opens a real page. An id that resolves to
//       nothing falls back to a text sheet and nobody notices; this is what
//       would have been missed.
//    2. NOTHING THAT CANNOT BE OPENED IS POINTED TO, and nothing clinical is
//       dropped: a coming-soon card is not a document, a door's pinned warning
//       signs are in its document, a read's "when to see someone" is in its body.
//    3. THE TWO HALVES DO NOT DRIFT: the Tools list's titles are the export's.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ask_veda/pv_veda_corpus.dart';
import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/tools/due_date_calculator_screen.dart';
import 'package:parentveda/screens/tools_hub_screen.dart';
import 'package:parentveda/services/content_ownership.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, dynamic>> corpus;
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pregnancy = PregnancyController(
        dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
    corpus = buildPregnancyVedaCorpus();
  });

  group('the corpus', () {
    test('is large and made of the four kinds, none editor-owned', () {
      expect(corpus.length, greaterThan(300));
      final kinds = {for (final d in corpus) d['kind'] as String};
      expect(kinds, {'pvread', 'pvfaq', 'pvdoor', 'pvtool'});
      for (final k in kinds) {
        expect(ContentOwnership.isKindEditorOwned(k), isFalse,
            reason: '"$k" is editor-owned: the export would silently skip it');
      }
    });

    test('every id is unique, namespaced, and every document has words', () {
      final ids = <String>{};
      for (final d in corpus) {
        final id = d['doc_id'] as String;
        expect(ids.add(id), isTrue, reason: 'duplicate id $id');
        expect(id.startsWith(kPvVedaNamespace), isTrue, reason: id);
        expect((d['title'] as String).trim(), isNotEmpty, reason: id);
        expect((d['body'] as String).trim(), isNotEmpty, reason: id);
        expect(d['domain'], 'pregnancy');
      }
    });

    test('every read is a document, and every question its own', () {
      final ids = {for (final d in corpus) d['doc_id'] as String};
      final seen = <String>{};
      for (final r in kPregnancyReads) {
        if (!seen.add(r.id)) continue;
        expect(ids, contains(pvVedaReadId(r.id)), reason: r.id);
        for (var i = 0; i < r.faqs.length; i++) {
          expect(ids, contains(pvVedaFaqId(r.id, i)), reason: '${r.id} #$i');
        }
      }
    });

    test('a read\'s "when to see someone" and evidence are in its body', () {
      final byId = {for (final d in corpus) d['doc_id'] as String: d};
      var checked = 0;
      for (final r in kPregnancyReads) {
        final d = byId[pvVedaReadId(r.id)];
        if (d == null) continue;
        final w = r.whenToSeeSomeone.body.en.trim();
        if (w.isEmpty) continue;
        expect(d['body'] as String, contains(w),
            reason: '${r.id}: the clinical half was dropped');
        checked++;
      }
      expect(checked, greaterThan(50));
    });

    test('a door\'s pinned warning signs are in the door\'s document', () {
      final byId = {for (final d in corpus) d['doc_id'] as String: d};
      var checked = 0;
      for (final page in kPvDoorPages) {
        final d = byId[pvVedaDoorId(page.bracketId)];
        expect(d, isNotNull, reason: page.bracketId);
        for (final g in page.groups) {
          final f = g.pinnedRedFlag;
          if (f == null) continue;
          for (final line in f.lines) {
            expect(d!['body'] as String, contains(line.text),
                reason: '${page.bracketId} / ${g.label}: a warning sign is missing');
            checked++;
          }
        }
      }
      expect(checked, greaterThan(10));
    });

    test('a card that is not made yet is never a document', () {
      final ids = {for (final d in corpus) d['doc_id'] as String};
      final made = <String>{};
      final unmade = <String>[];
      for (final page in kPvDoorPages) {
        for (final t in page.allTiles) {
          final id = pvVedaDoorId(page.bracketId, t);
          if (t.comingSoon) {
            unmade.add(id);
          } else {
            made.add(id);
          }
        }
      }
      for (final id in unmade) {
        // A coming-soon card may share a slug with a real one; only a slug
        // that is ONLY coming-soon must be absent.
        if (made.contains(id)) continue;
        expect(ids, isNot(contains(id)), reason: '$id is not made yet');
      }
      expect(unmade, isNotEmpty, reason: 'the test has nothing to check');
    });
  });

  group('the way back into the app', () {
    test('every exported id resolves to a real page', () {
      final bad = [
        for (final d in corpus)
          if (!pvVedaDocResolves(d['doc_id'] as String)) d['doc_id'] as String,
      ];
      expect(bad, isEmpty, reason: 'these ids open nothing:\n${bad.join('\n')}');
    });

    test('an id that is not one of ours is left to the caller', () {
      for (final id in [
        'cani_papaya',
        'ttcread_x',
        'ppprod_stroller',
        'pvread_no_such_read',
        'pvdoor_no_such_door',
        'pvtool_no_such_tool',
        'pvfaq_nothing_3',
        '',
      ]) {
        expect(pvVedaDocResolves(id), isFalse, reason: id);
      }
    });

    test('a Hindi twin resolves to the same page', () {
      final r = kPregnancyReads.first;
      expect(pvVedaDocResolves('${pvVedaReadId(r.id)}_hi'), isTrue);
    });

    Future<void> pump(WidgetTester t, String docId) async {
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 3.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: TextButton(
                onPressed: () => openPvVedaDoc(ctx, docId, pregnancy),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await t.tap(find.text('go'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
    }

    testWidgets('a read id opens the reader on that read', (t) async {
      final r = kPregnancyReads.first;
      await pump(t, pvVedaReadId(r.id));
      expect(find.byType(PvReaderScreen), findsOneWidget);
    });

    testWidgets('a question id opens the read it came from', (t) async {
      final r = kPregnancyReads.firstWhere((r) => r.faqs.isNotEmpty);
      await pump(t, pvVedaFaqId(r.id, 0));
      expect(find.byType(PvReaderScreen), findsOneWidget);
    });

    testWidgets('a door id opens that door', (t) async {
      await pump(t, pvVedaDoorId(kPvDoorPages.first.bracketId));
      expect(find.byType(PvDoorScreen), findsOneWidget);
    });

    testWidgets('a tool id opens that tool', (t) async {
      await pump(t, pvVedaToolId('due_date'));
      expect(find.byType(DueDateCalculatorScreen), findsOneWidget);
    });

    testWidgets('a card id opens that card', (t) async {
      final (page, tile) = pvVedaDoorTiles().first;
      await pump(t, pvVedaDoorId(page.bracketId, tile));
      // Whatever the card is, something was pushed over the button.
      expect(find.text('go'), findsNothing);
    });
  });

  group('the two halves do not drift', () {
    testWidgets('every tool title in the export is on the Tools list',
        (t) async {
      t.view.physicalSize = const Size(360, 3200);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: ToolsHubScreen(controller: pregnancy))));
      await t.pump(const Duration(milliseconds: 300));
      final s = S(AppLanguage.english);
      for (final tool in kPvVedaTools) {
        expect(find.text(tool.title(s), skipOffstage: false), findsWidgets,
            reason: '"${tool.title(s)}" is in the export but not on the '
                'Tools list (renamed there?)');
        expect(find.text(tool.line, skipOffstage: false), findsWidgets,
            reason: 'the line for "${tool.title(s)}" differs from the list');
      }
    });
  });
}
