import 'dart:io';
// Tools pass, the Other family (29-33), 2026-10-26: what each tool shows and
// where each tap lands. Plan: docs/pp-tool-plans/29-33-other.md.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/pp_buying_guides.dart';
import 'package:parentveda/screens/post_pregnancy/pp_buying_guides_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/products/pv_shelf_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_scripts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart' show kPpSections;
import 'package:parentveda/screens/post_pregnancy/pp_sounds_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sounds_screen.dart';
import 'package:parentveda/screens/post_pregnancy/scripts_library_screen.dart';
import 'package:parentveda/services/raga_audio_store.dart';

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('29 What to say', () {
    test('the words the Tools row sells find scripts', () {
      for (final q in ['tantrum', 'bedtime', 'meltdown', 'honey', 'spoiling']) {
        expect(ppScriptSearch(q), isNotEmpty, reason: '"$q" finds nothing');
      }
    });

    test('the baby tab keeps its promise: four lines for the family', () {
      final infant = ppScriptsForBand('infant').map((s) => s.id).toSet();
      expect(infant, containsAll(['family_spoiling', 'family_let_cry', 'family_milk', 'family_honey']));
      final honey = kPpScripts.firstWhere((s) => s.id == 'family_honey');
      expect(honey.safety, contains('No honey'));
    });

    test('every script has a page that exists', () {
      for (final s in kPpScripts) {
        expect(s.pageId, isNotNull, reason: '${s.id} is a dead end');
        expect(kPpSections.any((sec) => sec.pageById(s.pageId!) != null), isTrue,
            reason: '${s.id} -> ${s.pageId}');
      }
    });

    testWidgets('"Read the whole thing" shows with no opener passed, and opens the page', (tester) async {
      await _phone(tester);
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 90)));
      await tester.pumpWidget(const MaterialApp(home: ScriptsLibraryScreen(initialScriptId: 'family_honey')));
      await tester.pumpAndSettle();
      // Pinned first, with its safety line.
      expect(find.byKey(const ValueKey('pp_script_safety_family_honey')), findsOneWidget);
      final link = find.byKey(const ValueKey('pp_script_read_family_honey'));
      expect(link, findsOneWidget);
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byType(ScriptsLibraryScreen), findsNothing, reason: 'the page opened over it');
    });

    testWidgets('the empty search points at words that find something', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(const MaterialApp(home: ScriptsLibraryScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xylophone');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_scripts_empty')), findsOneWidget);
      expect(find.textContaining('above'), findsNothing);
      expect(ppScriptSearch('hitting'), isNotEmpty);
      expect(ppScriptSearch('bedtime'), isNotEmpty);
    });
  });

  group('30 Sleep Sounds', () {
    tearDown(() => RagaAudioStore.instance.resetForTest());

    testWidgets('the tanpura leads, a track not recorded yet says so, and the safety line says where', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(const MaterialApp(home: PpSoundsScreen()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Sleep Sounds'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_sounds_plays_now')), findsOneWidget);
      expect(find.textContaining('about 2 metres'), findsOneWidget);
      expect(find.textContaining('Never in the cot'), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_sounds_timer_line')), findsOneWidget);
      // A tap on a track with no file is never silent.
      final notYet = kPpSoundCategories.expand((c) => c.tracks).firstWhere((t) => !t.isLive);
      final row = find.text(notYet.title).first;
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pump();
      expect(find.textContaining('still being recorded'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    test('the tanpura is first in the data', () {
      expect(kPpLiveSoundTracks.first.id, 'raga_tanpura');
      expect(kPpLiveSoundTracks.first.minutes, isNot('45 min'));
    });
  });

  group('29 What to say: links land on the script', () {
    test('pp_scripts/<id> opens the tool on that script', () {
      final w = ppScreenForSurface('pp_scripts/shoes');
      expect(w, isA<ScriptsLibraryScreen>());
      expect((w as ScriptsLibraryScreen).initialScriptId, 'shoes');
    });

    test('every pp_scripts/<id> link names a script that exists', () {
      final ids = kPpScripts.map((s) => s.id).toSet();
      final link = RegExp(r"pp_scripts/([a-z_]+)");
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
        for (final m in link.allMatches(f.readAsStringSync())) {
          expect(ids, contains(m[1]), reason: '${f.path} links pp_scripts/${m[1]}');
        }
      }
    });
  });

  group('32 Product guide', () {
    test('the Tools row and the old surface both open the guides', () {
      final row = ppToolGroups().expand((g) => g.tools).firstWhere((t) => t.title == 'Product guide');
      expect(ppScreenForSurface(row.surfaceId), isA<PpBuyingGuidesScreen>());
      expect(ppScreenForSurface('pp_product_guide'), isA<PpBuyingGuidesScreen>());
    });

    test('every guide ends in "Shop this", on a shop shelf', () {
      for (final r in kPpBuyingGuides) {
        final shop = r.nextSteps.where((n) => n.title.en == 'Shop this');
        expect(shop, hasLength(1), reason: r.id);
        expect(shop.single.surfaceId, startsWith('pp_products/'), reason: r.id);
      }
    });

    test("Feeding's breast pump link lands on the breast pump guide", () {
      expect(ppScreenForSurface('pp_buying_guides/breast_pump'), isNotNull);
      expect(File('lib/screens/post_pregnancy/pp_feeding_content.dart').readAsStringSync(),
          contains("surfaceId: 'pp_buying_guides/breast_pump'"));
      expect(ppSurfaceUnavailable('pp_buying_guides/not_written'), isNotNull);
    });

    test('the car seat guide names the Indian standard and uses centimetres', () {
      final car = kPpBuyingGuides.firstWhere((r) => r.id == ppBuyingGuideId('car_seat'));
      final text = car.sections.expand((s) => s.bullets).map((b) => b.en).join(' ');
      expect(text, contains('AIS-072'));
      expect(text, isNot(contains('inch')));
    });
  });

  group('33 Toys and crayons', () {
    test('pp_recos opens one toy shelf of the six kinds, not the whole store', () {
      final w = ppScreenForSurface('pp_recos');
      expect(w, isA<PvShelfScreen>());
      final shelf = w as PvShelfScreen;
      expect(shelf.title, 'Toys and crayons');
      expect(shelf.subIds, hasLength(kPpToysAndCrayonsKinds.length));
    });

    test('the potty books toast no longer says there are no books', () {
      final words = kPpNotYetWords['pp_books/Potty']!;
      expect(words, isNot(contains("haven't put picture books")));
      expect(words, contains('Reading shelf'));
    });
  });
}
