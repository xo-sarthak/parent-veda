// =============================================================================
//  Shravan to final — the manifest, its provenance, and the player it feeds
// -----------------------------------------------------------------------------
//  The SHARED block's licensing rule is strict and non-negotiable: royalty-
//  free, CC0 or public domain only, every asset's licence verified and
//  written down. So the manifest is checked as data: every track a named
//  recordist, a public-domain licence, a source page, a real URL, a length
//  that agrees with the app's own list. And the one guided track is a
//  script, not a file.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_garbh.dart';
import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/kriya_relaxation_data.dart';
import 'package:parentveda/models/garbh_content.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/garbh_relaxation_screen.dart';
import 'package:parentveda/screens/garbh_shravan_surfaces.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/shravan_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final raw = File('assets/audio/shravan_manifest.json').readAsStringSync();
  final manifest = jsonDecode(raw) as Map<String, dynamic>;
  final tracks = (manifest['tracks'] as List).cast<Map<String, dynamic>>();

  group('the manifest', () {
    test('one entry per non-guided track in kShravan, and no strays', () {
      final ids = tracks.map((t) => t['id'] as String).toSet();
      final expected = kShravan
          .where((a) => a.kind != GarbhKind.guided)
          .map((a) => a.id)
          .toSet();
      expect(ids, expected);
    });

    test('every track names a recordist, a public-domain licence, a source '
        'page and a playable URL', () {
      for (final t in tracks) {
        final id = t['id'];
        expect((t['attribution'] as String).trim(), isNotEmpty, reason: '$id');
        expect((t['attribution'] as String), contains('—'), reason: '$id');
        final lic = (t['licence'] as String).toLowerCase();
        expect(
            lic.contains('public domain') || lic.contains('cc0'), isTrue,
            reason: '$id: $lic is not a public-domain dedication');
        expect(t['sourceUrl'] as String, startsWith('https://'), reason: '$id');
        expect(t['file'] as String, startsWith('https://'), reason: '$id');
        expect(t['file'] as String, endsWith('.mp3'), reason: '$id');
        expect((t['durationSec'] as num).toInt(), greaterThan(60),
            reason: '$id');
      }
    });

    test('the app\'s minutes agree with the recordings', () {
      for (final t in tracks) {
        final a = shravanById(t['id'] as String)!;
        final mins = ((t['durationSec'] as num) / 60).round();
        expect(a.minutes, mins, reason: '${a.id}: data says ${a.minutes}');
      }
    });

    test('no film music, no rip: every source is an archive.org item page',
        () {
      for (final t in tracks) {
        expect(t['sourceUrl'] as String, startsWith('https://archive.org/details/'));
      }
    });
  });

  group('the library', () {
    test('parses the manifest and answers what plays', () {
      final lib = ShravanLibrary.instance;
      lib.loadFromJson(raw);
      expect(lib.tracks.length, tracks.length);
      final p = lib.playableFor('bells')!;
      expect(p.isFile, isFalse);
      // On R2 since 2026-09-13; the item page stays on archive.org.
      expect(p.source, startsWith('https://pub-'));
      expect(p.source, contains('.r2.dev/shravan/'));
      expect(lib.isCached('bells'), isFalse);
      expect(lib.trackFor('nope'), isNull);
      expect(lib.playableFor('bodyscan'), isNull); // a script, not a file
      expect(lib.trackFor('bells')!.minutes, 3);
    });
  });

  group('the guided track is a session', () {
    test('the door and the library both open the body-awareness script', () {
      final c = PregnancyController();
      final w = pvDoorScreenFor(garbhSurfaceListen('bodyscan'), c);
      expect(w, isA<GarbhRelaxationScreen>());
      expect((w as GarbhRelaxationScreen).session, same(kKriyaBodyAwareness));
    });

    test('nine minutes, head to toe, claims nothing', () {
      const s = kKriyaBodyAwareness;
      expect(s.totalSeconds, 540);
      final body = s.steps.where((st) => st.part != 0.5).toList();
      for (var i = 1; i < body.length; i++) {
        expect(body[i].part, greaterThan(body[i - 1].part));
      }
      for (final st in s.steps) {
        final t = st.script.toLowerCase();
        for (final w in ['smarter', 'cleverer', 'brain', 'develop', 'healthier']) {
          expect(t, isNot(contains(w)), reason: st.title);
        }
      }
      // ⚠️ ITS KEYS DO NOT COLLIDE WITH THE RELAXATION'S. Both scripts have
      // a `face` and a `belly`; a recording of one must never play for the
      // other. The key carries the session id.
      final a = kKriyaRelaxation.steps.map(kKriyaRelaxation.narrationKeyFor).toSet();
      final b = s.steps.map(s.narrationKeyFor).toSet();
      expect(a.intersection(b), isEmpty);
      expect(b, contains('kriya.body_awareness.arrive'));
    });
  });

  group('the screens', () {
    Future<void> pump(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: w));
      await tester.pump();
    }

    testWidgets('the credits screen lists every recordist', (tester) async {
      ShravanLibrary.instance.loadFromJson(raw);
      await pump(tester, const ShravanCreditsScreen());
      expect(find.text('Where these sounds come from'), findsOneWidget);
      expect(find.textContaining('Veena Kinhal'), findsWidgets);
      expect(find.textContaining('Piotrek Zyla'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a manifest track draws the real player with its credit and '
        'an offline pill; the guided track draws Begin', (tester) async {
      ShravanLibrary.instance.loadFromJson(raw);
      final c = PregnancyController();
      await pump(
          tester,
          Scaffold(
              body: ShravanTrackPlayer(
                  audio: shravanById('bells')!, controller: c)));
      expect(find.text('Temple Bells'), findsOneWidget);
      expect(find.textContaining('Prakrti temple'), findsOneWidget);
      expect(find.text('Save for offline'), findsOneWidget);
      expect(find.textContaining('sample'), findsNothing);
      expect(tester.takeException(), isNull);

      await pump(
          tester,
          Scaffold(
              body: ShravanTrackPlayer(
                  audio: shravanById('bodyscan')!, controller: c)));
      expect(find.text('Body Awareness'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('the door\'s Listen tab has the credits card and the manifest loads at '
      'startup', () {
    final door = pvDoorPageFor('pregnancy_garbh')!;
    final titles = door.sectionsOf(kGarbhTabListen).map((s) => s.heading);
    expect(titles, contains('Where these sounds come from'));
    expect(pvDoorSurfaceResolves(kGarbhSurfaceCredits), isTrue);
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('ShravanLibrary.instance.init()'));
  });
}
