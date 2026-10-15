// The Garbh pillars pass (2026-10-15): Shravan as a player, Samvad as a
// recorder bar, Buddhi and Kriya in drawn marks, breathing as a calm room.
// The user's rule over all of it: every screen easy to use and understand,
// calm, and responsive.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/garbh_content.dart' show GarbhKind;
import 'package:parentveda/screens/garbh_browse_screen.dart';
import 'package:parentveda/screens/garbh_samvad_daily.dart';
import 'package:parentveda/screens/garbh_screen.dart';
import 'package:parentveda/services/garbh_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/shravan_library.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final n = DateTime.now();
    c = PregnancyController(
        dueDate: DateTime(n.year, n.month, n.day).add(const Duration(days: 140)));
    await c.load();
    await GarbhStore.instance.init();
  });

  Future<void> pump(WidgetTester t, Widget w, {double scale = 1.0}) async {
    t.view.physicalSize = const Size(360, 780);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: w,
    ));
    await t.pump(const Duration(milliseconds: 400));
  }

  group('Samvad: a recorder bar, not a disc', () {
    testWidgets('ready, it is one ink pill, about a button high', (t) async {
      await pump(t, GarbhSamvadDailyScreen(controller: c));
      final rec = find.byKey(const ValueKey('samvad_record'));
      expect(rec, findsOneWidget);
      expect(find.text('Record in your voice'), findsOneWidget);
      // The old disc was 148px; the bar stays a button's height.
      expect(t.getSize(rec).height, lessThanOrEqualTo(60));
      expect(find.byKey(const ValueKey('samvad_keep')), findsNothing);
    });

    test('the disc is kept for revert, not drawn', () {
      final src = _code('lib/screens/garbh_samvad_daily.dart');
      expect(src.contains('_SamvadRecorder('), isTrue);
      expect(RegExp(r'_RecordDisc\(\s*recording').hasMatch(src), isFalse);
    });
  });

  group('Shravan: a player', () {
    testWidgets('the full player steps through the ragas', (t) async {
      final first = kShravan.firstWhere((a) => a.kind != GarbhKind.guided);
      await pump(t, ShravanDetailScreen(audio: first, controller: c));
      expect(find.byKey(const ValueKey('raga_player_large')), findsOneWidget);
      expect(find.byKey(const ValueKey('raga_prev')), findsOneWidget);
      expect(find.byKey(const ValueKey('raga_next')), findsOneWidget);
      expect(find.text(first.title.now), findsWidgets);
      await t.tap(find.byKey(const ValueKey('raga_next')));
      await t.pump(const Duration(milliseconds: 400));
      final run = kShravan.where((a) => a.kind != GarbhKind.guided).toList();
      expect(find.text(run[1].title.now), findsWidgets);
      // Let the autoplay and the audio plugin settle before the tree goes.
      await t.pump(const Duration(seconds: 1));
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    });

    testWidgets('the daily screen plays one track: no previous / next', (t) async {
      await pump(t, ShravanScreen(controller: c, daily: true));
      expect(find.byKey(const ValueKey('raga_player_large')), findsOneWidget);
      expect(find.byKey(const ValueKey('raga_prev')), findsNothing);
      expect(find.byKey(const ValueKey('raga_next')), findsNothing);
    });

    testWidgets('the list plays the recording, not the drone', (t) async {
      ShravanLibrary.instance.loadFromJson(
          File('assets/audio/shravan_manifest.json').readAsStringSync());
      final screen = shravanBrowse(AppLanguage.english, Colors.black, onOpen: (_) {});
      for (final g in screen.groups) {
        for (final i in g.items) {
          final a = kShravan.firstWhere((x) => x.title.en == i.title);
          if (a.kind == GarbhKind.guided) continue;
          if (ShravanLibrary.instance.trackFor(a.id) == null) continue;
          expect(i.playKey, isNot(kGarbhRagaAsset), reason: i.title);
        }
      }
    });
  });

  group('Buddhi and Kriya: drawn, not Material, where meaning lives', () {
    test('the games and their tiles carry no Material icons but chrome verbs', () {
      // Back, close and backspace are chrome verbs the app draws in Material
      // (DESIGN-SYSTEM §3.4); every other picture is a drawn mark.
      const allowed = {
        'Icons.arrow_back_rounded',
        'Icons.backspace_outlined',
        'Icons.chevron_right_rounded',
      };
      for (final f in [
        'lib/screens/tools/games/game_chrome.dart',
        'lib/screens/tools/garbh_sudoku.dart',
        'lib/screens/tools/garbh_nonogram.dart',
        'lib/screens/garbh_buddhi_screen.dart',
      ]) {
        final used = RegExp(r'Icons\.[a-z_]+').allMatches(_code(f)).map((m) => m.group(0)!);
        expect(used.where((i) => !allowed.contains(i)).toSet(), isEmpty, reason: f);
      }
    });

    testWidgets('breathing is a calm room: no app bar, one Finish, a Pause', (t) async {
      final practice = kKriya.firstWhere((k) => k.id != 'relax');
      await pump(t, KriyaDetailScreen(practice: practice, controller: c));
      await t.scrollUntilVisible(find.byKey(const ValueKey('kriya_begin')), 200);
      await t.tap(find.byKey(const ValueKey('kriya_begin')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byType(AppBar), findsNothing);
      expect(find.byKey(const ValueKey('breath_finish')), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('breath_pause')));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Resume'), findsOneWidget);
    });
  });
}
