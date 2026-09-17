// =============================================================================
//  Saved — one screen, reachable from every home; no tap falls back to classic.
// -----------------------------------------------------------------------------
//  Source-scan tests, because the failure they guard leaves no symptom: a
//  correct SavedScreen that nothing pushes, an old hub still pushed from one
//  forgotten site, or a V3 tap that quietly switches the home to classic and
//  looks like it worked.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/saved_screen.dart';
import 'package:parentveda/services/saved_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String p) => File(p).readAsStringSync();

/// Lines of [src] that are code, not comments — so a "kept for revert" line
/// is never mistaken for a live call site.
Iterable<String> _codeLines(String src) =>
    src.split('\n').where((l) => !l.trimLeft().startsWith('//'));

void main() {
  group('one Saved screen, reached from every home', () {
    const entryPoints = [
      'lib/screens/home_screen_b.dart',
      'lib/screens/profile_screen.dart',
      'lib/screens/post_pregnancy/my_child_screen.dart',
      'lib/screens/post_pregnancy/pp_home_v3.dart',
      'lib/screens/home_v3_screen.dart',
    ];

    test('every entry point pushes SavedScreen', () {
      for (final f in entryPoints) {
        final live = _codeLines(_read(f)).join('\n');
        expect(live.contains('SavedScreen()'), isTrue, reason: f);
      }
    });

    test('neither old hub is pushed from live code anywhere', () {
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final f in files) {
        if (f.path.endsWith('saved_hub_screen.dart') ||
            f.path.endsWith('pp_saved_hub_screen.dart')) {
          continue; // the hubs' own files
        }
        final live = _codeLines(f.readAsStringSync()).join('\n');
        expect(live.contains('SavedHubScreen('), isFalse, reason: f.path);
        expect(live.contains('PpSavedHubScreen('), isFalse, reason: f.path);
      }
    });
  });

  group('V3 is final: no home-surface tap switches to classic', () {
    test('home_v3_screen has no live _open() to a Today/Profile surface', () {
      final live = _codeLines(_read('lib/screens/home_v3_screen.dart')).join('\n');
      // These surfaces map to AppHome.today / .profile in app_structure.dart,
      // and `_open` handles those by setting TodayVersion.classic — the exact
      // "tap the article, land on the classic home" defect.
      for (final id in ['saved', 'daily_reads', 'weekly_snapshot', 'journal', 'todays_video', 'garbh_daily']) {
        expect(live.contains("_open(context, '$id')"), isFalse, reason: id);
      }
      // The reads row opens the read it names.
      expect(live.contains('ReadItemScreen(item: r, controller: pregnancy)'), isTrue);
    });
  });

  group('the opener answers every kind', () {
    test('SavedItemOpener has an arm for every SavedKind', () {
      final src = _read('lib/screens/saved_screen.dart');
      for (final k in SavedKind.values) {
        expect(src.contains('SavedKind.${k.name}'), isTrue, reason: k.name);
      }
    });

    test('each kind has chip copy', () {
      final src = _read('lib/screens/saved_screen.dart');
      for (final k in SavedKind.values) {
        expect(RegExp('_KindCopy\\(SavedKind\\.${k.name},').hasMatch(src), isTrue, reason: k.name);
      }
    });
  });

  group('the screen renders', () {
    setUp(() {
      SavedStore.instance.debugReset();
      SharedPreferences.setMockInitialValues({SavedStore.kImportedKey: true});
    });

    testWidgets('empty: every kind header still renders with its invitation', (t) async {
      await t.pumpWidget(const MaterialApp(home: SavedScreen()));
      await t.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('ARTICLES'), findsOneWidget);
      expect(find.text('VIDEOS'), findsOneWidget);
      expect(find.text('Tap the bookmark on any article to keep it here.'), findsOneWidget);
      expect(find.text('0 items'), findsOneWidget);
    });

    testWidgets('with items: chips carry counts, a stage row appears for two stages', (t) async {
      await SavedStore.instance.load();
      await SavedStore.instance.save(SavedKind.article, 'conception_how_it_works',
          title: 'How conception actually works', stage: 'trying');
      await SavedStore.instance.save(SavedKind.video, 'v1', title: 'A film', stage: 'pregnancy');
      await t.pumpWidget(const MaterialApp(home: SavedScreen()));
      await t.pumpAndSettle();
      expect(find.text('Articles · 1'), findsOneWidget);
      expect(find.text('Videos · 1'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('Every stage'), findsOneWidget);
      expect(find.text('Trying'), findsWidgets);
      // The TTC article is resolvable from its catalogue, so it opens; the
      // snapshot title is shown either way.
      expect(find.textContaining('conception'), findsWidgets);
    });

    testWidgets('search narrows to matching rows and hides empty kinds', (t) async {
      await SavedStore.instance.load();
      await SavedStore.instance.save(SavedKind.article, 'a1', title: 'Folic acid, plainly');
      await SavedStore.instance.save(SavedKind.video, 'v1', title: 'Tummy time');
      await t.pumpWidget(const MaterialApp(home: SavedScreen()));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.search_rounded));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'folic');
      await t.pumpAndSettle();
      expect(find.text('Folic acid, plainly'), findsOneWidget);
      expect(find.text('Tummy time'), findsNothing);
      expect(find.text('VIDEOS'), findsNothing, reason: 'no hit in that kind');
      expect(find.text('Save a film from Watch and it lands here.'), findsNothing);
    });

    testWidgets('unsave from the row removes it and the count follows', (t) async {
      await SavedStore.instance.load();
      await SavedStore.instance.save(SavedKind.tip, 'tip_1', title: 'A tip', stage: 'parenting');
      await t.pumpWidget(const MaterialApp(home: SavedScreen()));
      await t.pumpAndSettle();
      expect(find.text('1 item'), findsOneWidget);
      await t.tap(find.byIcon(Icons.bookmark_rounded).first);
      await t.pumpAndSettle();
      expect(find.text('0 items'), findsOneWidget);
      expect(SavedStore.instance.isSaved(SavedKind.tip, 'tip_1'), isFalse);
    });
  });
}
