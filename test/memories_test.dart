// =============================================================================
//  Memories — templates, the saved timeline, and the home
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/memories/memories_store.dart';
import 'package:parentveda/memories/memory_models.dart';
import 'package:parentveda/memories/memory_photos.dart';
import 'package:parentveda/memories/memory_templates.dart';
import 'package:parentveda/screens/memories/memories_home_screen.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final store = MemoriesStore.instance;
  setUp(store.resetAll);
  tearDown(store.resetAll);

  test('templates cover both milestones, correctly bucketed', () {
    expect(templatesFor(MemoryType.expecting), isNotEmpty);
    expect(templatesFor(MemoryType.welcomeBaby), isNotEmpty);
    expect(kMemoryTemplates.length, greaterThanOrEqualTo(12));
    for (final t in templatesFor(MemoryType.expecting)) {
      expect(t.type, MemoryType.expecting);
    }
    for (final t in templatesFor(MemoryType.welcomeBaby)) {
      expect(t.type, MemoryType.welcomeBaby);
    }
  });

  test('a saved memory round-trips through the store', () {
    final d = MemoryData(type: MemoryType.welcomeBaby)
      ..babyName = 'Vivaan'
      ..birthDate = '12 Jul 2026'
      ..message = 'Our whole world.';
    final m = store.save(templateId: 'wb_blush_min', data: d);

    expect(store.all.first.id, m.id);
    final back = SavedMemory.fromMap(m.toMap());
    expect(back.data.babyName, 'Vivaan');
    expect(back.data.message, 'Our whole world.');
    expect(back.templateId, 'wb_blush_min');
    expect(back.data.type, MemoryType.welcomeBaby);
  });

  test('MemoryData.copy is a deep, independent copy', () {
    final d = MemoryData(type: MemoryType.expecting)..coupleNames = 'A & B';
    final c = d.copy()..coupleNames = 'X & Y';
    expect(d.coupleNames, 'A & B');
    expect(c.coupleNames, 'X & Y');
  });

  // A memory card is exported as an IMAGE at a fixed size - it can never
  // scroll, so it must never overflow. Sage Bloom / Floral overflowed by 11px
  // on a real device with a photo and two short lines. Every template is
  // rendered against four shapes of content: empty, the reported case, long
  // text, and long text WITH a photo.
  group('no template overflows', () {
    // A REAL 1x1 png on disk: the photo frame is what tips these layouts over
    // (the reported overflow only happened on a card WITH a photo), and
    // Image.file needs a file that actually loads or it errors for the wrong
    // reason and masks the layout assertion.
    // Written eagerly, NOT in setUpAll: the `cases` map below is built while
    // the group is being declared, long before setUpAll would have run.
    final dir = Directory.systemTemp.createTempSync('pv_memories_test');
    final photoPath = '${dir.path}/px.png';
    File(photoPath).writeAsBytesSync(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
        'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='));
    tearDownAll(() => dir.deleteSync(recursive: true));

    final cases = <String, MemoryData>{
      'empty': MemoryData(type: MemoryType.expecting),
      // The exact reported failure: a photo + short names + empty message.
      'photo': MemoryData(type: MemoryType.expecting)
        ..coupleNames = 'he she'
        ..dueMonth = 'dec'
        ..babyName = 'he she'
        ..photo = MemoryPhoto(photoPath),
      'photo+maximal': MemoryData(type: MemoryType.expecting)
        ..coupleNames = 'Aaravdeep Singh Chowdhury & Meeratanya Krishnamurthy'
        ..dueMonth = 'December 2026'
        ..babyName = 'Vivaanraj Singh Chowdhury'
        ..birthDate = '12 December 2026'
        ..birthTime = '6:40 AM'
        ..weight = '3.2 kg'
        ..length = '49 cm'
        ..parentNames = 'Aaravdeep & Meeratanya'
        ..photo = MemoryPhoto(photoPath)
        ..message =
            'We waited so long for you, and every single day of that waiting '
                'turned out to be worth it the moment we finally saw your face.',
      'maximal': MemoryData(type: MemoryType.expecting)
        ..coupleNames = 'Aaravdeep Singh Chowdhury & Meeratanya Krishnamurthy'
        ..dueMonth = 'December 2026'
        ..babyName = 'Vivaanraj Singh Chowdhury'
        ..birthDate = '12 December 2026'
        ..birthTime = '6:40 AM'
        ..weight = '3.2 kg'
        ..length = '49 cm'
        ..parentNames = 'Aaravdeep & Meeratanya'
        ..message =
            'We waited so long for you, and every single day of that waiting '
                'turned out to be worth it the moment we finally saw your face.',
    };

    for (final t in kMemoryTemplates) {
      for (final entry in cases.entries) {
        testWidgets('${t.id} (${entry.key})', (tester) async {
          tester.view.physicalSize = const Size(1400, 2400);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final data = entry.value.copy()..type = t.type;
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: Center(child: t.builder(t, data)),
            ),
          ));
          await tester.pump();

          expect(tester.takeException(), isNull,
              reason: '${t.id} overflowed with ${entry.key} content');
        });
      }
    }
  });

  // image_picker returns a CACHE path that Android can purge, so a saved memory
  // must never hold it. These pin the copy-out behaviour.
  group('picked photos are copied out of the picker cache', () {
    late Directory docs;
    // Restored after each test: google_fonts also reaches for path_provider to
    // cache fonts, so leaving a stub pointing at a deleted temp dir behind
    // breaks every later widget test in this file.
    late PathProviderPlatform realProvider;
    setUp(() {
      realProvider = PathProviderPlatform.instance;
      docs = Directory.systemTemp.createTempSync('pv_docs');
      // Stand in for getApplicationDocumentsDirectory() in tests.
      PathProviderPlatform.instance = _FakePathProvider(docs.path);
    });
    tearDown(() {
      PathProviderPlatform.instance = realProvider;
      docs.deleteSync(recursive: true);
    });

    test('the copy survives the source file being deleted', () async {
      final cache = Directory.systemTemp.createTempSync('pv_cache');
      final src = File('${cache.path}/picked.jpg')
        ..writeAsBytesSync(const [1, 2, 3, 4, 5]);

      final stored = await MemoryPhotos.importPicked(src.path);

      expect(stored, isNot(src.path), reason: 'still pointing at the cache');
      expect(MemoryPhotos.isPersisted(stored), isTrue);

      // Android purging the cache must not take the memory's photo with it.
      cache.deleteSync(recursive: true);
      expect(File(stored).existsSync(), isTrue);
      expect(File(stored).readAsBytesSync(), [1, 2, 3, 4, 5]);
    });

    test('a missing source returns the original path instead of throwing',
        () async {
      final missing = '${docs.path}/nope.jpg';
      expect(await MemoryPhotos.importPicked(missing), missing);
    });
  });

  testWidgets('the memories home shows both milestone cards', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: MemoriesHomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text("We're Expecting"), findsOneWidget);
    expect(find.text('Welcome Baby'), findsOneWidget);
  });
}

/// Minimal path_provider stub so importPicked() has a documents dir in tests.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
  @override
  Future<String?> getTemporaryPath() async => root;
  @override
  Future<String?> getApplicationSupportPath() async => root;
}
