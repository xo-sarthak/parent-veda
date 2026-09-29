// =============================================================================
//  TTC practice cue sounds (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "wherever in the trying to conceive side there is anything that
//  indicates a sound, a countdown or something that indicates a sound, have a
//  sound." Every TTC countdown is `TtcPracticeSession`, so these hold that:
//   · the service is silent and never throws under test, and a failing
//     player never reaches the page;
//   · each kind of session asks for the right cue at the right moment (a
//     tone per breath phase, a tap per timed step, a chime at the end);
//   · the "Sound cues" switch is on by default, is drawn wherever a session
//     is, silences the cues, and is remembered;
//   · the five files are declared, exist, and are small, soft WAVs;
//   · no other stage's player or the shared circle reaches the service.
//
//  `audioplayers` has no implementation under `flutter test`, so nothing here
//  plays audio: a fake player records what it was asked to play.
// =============================================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_practice_player.dart';
import 'package:parentveda/screens/ttc/ttc_practice_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ritual_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_cue_sounds.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_garbh_course_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

/// Records every cue. Optionally throws, to prove nothing reaches the page.
class _FakeCues implements TtcCuePlayer {
  _FakeCues({this.fail = false});
  final bool fail;
  final played = <TtcCue>[];
  var preloaded = 0;
  var disposed = 0;

  @override
  Future<void> preload() async {
    preloaded++;
    if (fail) throw StateError('no audio');
  }

  @override
  Future<void> play(TtcCue cue) {
    if (fail) throw StateError('no audio');
    played.add(cue);
    return Future.value();
  }

  @override
  Future<void> dispose() async {
    disposed++;
    if (fail) throw StateError('no audio');
  }
}

DateTime _now = DateTime(2026, 9, 28, 9);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump(const Duration(milliseconds: 300));
}

/// A bare session on a page, the way the ritual and the course draw one.
Widget _session(Widget s) =>
    Scaffold(body: SingleChildScrollView(child: s));

/// Moves the wall clock by [seconds], one tick at a time.
Future<void> _run(WidgetTester tester, int seconds) async {
  for (var i = 0; i < seconds * 2; i++) {
    _now = _now.add(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 110));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCues fake;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TtcStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcGarbhCourseStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcCueSounds.instance.resetForTest();
    fake = _FakeCues();
    TtcCueSounds.instance.playerFactory = () => fake;
    _now = DateTime(2026, 9, 28, 9);
    ttcPracticeNow = () => _now;
  });
  tearDown(() {
    ttcPracticeNow = DateTime.now;
    TtcCueSounds.instance.resetForTest();
  });

  // ===========================================================================
  group('the service', () {
    test('under flutter test with no fake, it makes no player and is silent',
        () {
      TtcCueSounds.instance.resetForTest();
      final cues = TtcCueSounds.instance;
      cues.open();
      expect(cues.hasPlayer, isFalse,
          reason: 'there is no audio plugin under test');
      expect(() => cues.play(TtcCue.done), returnsNormally);
      cues.close();
      expect(cues.holders, 0);
    });

    test('a player that throws never throws out of the service', () async {
      final bad = _FakeCues(fail: true);
      TtcCueSounds.instance.playerFactory = () => bad;
      final cues = TtcCueSounds.instance;
      expect(cues.open, returnsNormally);
      for (final c in TtcCue.values) {
        expect(() => cues.play(c), returnsNormally);
      }
      expect(cues.close, returnsNormally);
      await Future<void>.delayed(Duration.zero);
      expect(bad.disposed, 1);
    });

    test('a factory that throws leaves it silent, not broken', () {
      TtcCueSounds.instance.playerFactory = () => throw StateError('x');
      final cues = TtcCueSounds.instance;
      expect(cues.open, returnsNormally);
      expect(cues.hasPlayer, isFalse);
      expect(() => cues.play(TtcCue.step), returnsNormally);
    });

    test('loads once for several sessions and unloads after the last', () {
      final cues = TtcCueSounds.instance;
      cues.open();
      cues.open();
      expect(fake.preloaded, 1, reason: 'the second session shares the tones');
      cues.close();
      expect(cues.hasPlayer, isTrue,
          reason: 'one session is still on screen');
      cues.close();
      expect(cues.hasPlayer, isFalse);
      expect(fake.disposed, 1);
    });

    test('off means silent, and the choice is remembered', () async {
      final cues = TtcCueSounds.instance;
      cues.open();
      expect(cues.enabled, isTrue, reason: 'on by default');
      cues.setEnabled(false);
      cues.play(TtcCue.done);
      expect(fake.played, isEmpty);
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(TtcCueSounds.prefsKey), isFalse);
      cues.close();
    });
  });

  // ===========================================================================
  group('each player asks for the right cue', () {
    testWidgets('box breathing: in, hold, out, hold, then the end chime',
        (tester) async {
      final box = ttcPracticeById('mb_box')!;
      await _pump(tester, _session(TtcPracticeSession(practice: box)));
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await _run(tester, 1);
      expect(fake.played, [TtcCue.breatheIn],
          reason: 'the first in-breath sounds as she starts');
      await _run(tester, 16);
      expect(fake.played.take(5), [
        TtcCue.breatheIn,
        TtcCue.hold,
        TtcCue.breatheOut,
        TtcCue.hold,
        TtcCue.breatheIn,
      ]);
      expect(fake.played, isNot(contains(TtcCue.step)),
          reason: 'a breath has phases, not steps');
      await _run(tester, 60);
      expect(fake.played.last, TtcCue.done);
      expect(fake.played.where((c) => c == TtcCue.done).length, 1,
          reason: 'one chime, once');
    });

    testWidgets('a movement: a tap per step, none at Start, then the chime',
        (tester) async {
      final move = ttcPracticeById('mb_loosen')!;
      final n = move.steps.length;
      await _pump(tester, TtcPracticeScreen(practice: move));
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await _run(tester, 2);
      expect(fake.played, isEmpty, reason: 'Start was her own tap');
      await _run(tester, move.anim.seconds + 2);
      expect(fake.played.where((c) => c == TtcCue.step).length, n - 1,
          reason: 'one tap as each of the steps after the first begins');
      expect(fake.played.last, TtcCue.done);
      expect(fake.played, isNot(contains(TtcCue.breatheIn)));
    });

    testWidgets('moving the steps by hand stops the step taps',
        (tester) async {
      final move = ttcPracticeById('mb_loosen')!;
      await _pump(tester, TtcPracticeScreen(practice: move));
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await tester.tap(find.text('Next step'));
      await tester.pump();
      await _run(tester, 70);
      expect(fake.played, isNot(contains(TtcCue.step)),
          reason: 'the timer no longer moves the steps, so nothing taps');
      await tester.tap(find.text('Pause'));
      await tester.pump();
    });

    testWidgets('the body scan taps as it moves to the next part',
        (tester) async {
      final scan = ttcPracticeById('mb_bodyrelax')!;
      await _pump(tester, TtcPracticeScreen(practice: scan));
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await _run(tester, scan.anim.seconds + 2);
      final parts = scan.steps.length > 2
          ? scan.steps.length - 2
          : scan.steps.length;
      expect(fake.played.where((c) => c == TtcCue.step).length, parts - 1);
      expect(fake.played.last, TtcCue.done);
    });

    testWidgets('a course sit: only the end chime', (tester) async {
      await _pump(tester, _session(TtcPracticeSession.sit(seconds: 10)));
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await _run(tester, 12);
      expect(fake.played, [TtcCue.done]);
    });

    testWidgets('with Sound cues off, the same session is silent',
        (tester) async {
      await _pump(tester, _session(TtcPracticeSession.sit(seconds: 10)));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      fake.played.clear();
      await tester.tap(find.text('Start timer'));
      await tester.pump();
      await _run(tester, 12);
      expect(fake.played, isEmpty);
    });

    testWidgets('the session loads the tones on open and frees them on close',
        (tester) async {
      await _pump(tester, _session(TtcPracticeSession.sit(seconds: 10)));
      expect(TtcCueSounds.instance.hasPlayer, isTrue);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(TtcCueSounds.instance.hasPlayer, isFalse);
      expect(fake.disposed, 1);
    });
  });

  // ===========================================================================
  group('the Sound cues switch', () {
    Finder soundSwitch() => find.descendant(
        of: find.byType(TtcSoundSwitch), matching: find.byType(Switch));

    testWidgets('on by default beside the vibration, and remembered',
        (tester) async {
      await _pump(tester,
          TtcPracticeScreen(practice: ttcPracticeById('mb_longout')!));
      expect(find.byType(TtcVibrateSwitch), findsOneWidget);
      expect(find.byType(TtcSoundSwitch), findsOneWidget,
          reason: 'one switch: the session leaves it to the settings panel');
      expect(find.text('Sound cues'), findsOneWidget);
      expect(tester.widget<Switch>(soundSwitch()).value, isTrue);
      await tester.tap(soundSwitch());
      await tester.pump();
      expect(tester.widget<Switch>(soundSwitch()).value, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ttc_practice_sound'), isFalse);
    });

    testWidgets('a saved "off" is read back on the next open',
        (tester) async {
      SharedPreferences.setMockInitialValues({'ttc_practice_sound': false});
      TtcCueSounds.instance.resetForTest();
      TtcCueSounds.instance.playerFactory = () => fake;
      await _pump(tester,
          TtcPracticeScreen(practice: ttcPracticeById('mb_longout')!));
      expect(tester.widget<Switch>(soundSwitch()).value, isFalse);
    });

    testWidgets('every practice page carries it, movement ones too',
        (tester) async {
      for (final pr in kTtcPractices) {
        await _pump(tester, TtcPracticeScreen(practice: pr));
        expect(find.byType(TtcSoundSwitch), findsOneWidget, reason: pr.id);
        expect(tester.takeException(), isNull, reason: pr.id);
      }
    });

    testWidgets('the Sanskar breath part carries it',
        (tester) async {
      await _pump(
          tester,
          const TtcRitualScreen(
              chapter: TtcChapter.tryingTogether,
              focus: TtcRitualPart.breath,
              clinicOwned: false));
      // The vibration switch comes only with a breathing ring; today's
      // breath can be the listening or body-scan practice, which has none.
      expect(find.byType(TtcSoundSwitch), findsOneWidget);
    });

    testWidgets('a course sit carries it', (tester) async {
      await _pump(tester, _session(TtcPracticeSession.sit(seconds: 120)));
      expect(find.byType(TtcSoundSwitch), findsOneWidget);
      expect(find.byType(TtcVibrateSwitch), findsNothing);
    });
  });

  // ===========================================================================
  group('the files', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('the folder is declared in pubspec.yaml', () {
      expect(pubspec, contains('- assets/audio/cues/'));
    });

    for (final cue in TtcCue.values) {
      test('${cue.file} exists, is small, and is a soft 44.1 kHz mono WAV',
          () {
        final f = File(cue.assetPath);
        expect(f.existsSync(), isTrue);
        final bytes = f.readAsBytesSync();
        expect(bytes.length, lessThan(60 * 1024));
        final h = ByteData.sublistView(bytes);
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
        expect(h.getUint16(22, Endian.little), 1, reason: 'mono');
        expect(h.getUint32(24, Endian.little), 44100);
        expect(h.getUint16(34, Endian.little), 16);
        // No click: it starts and ends on silence, and nothing is loud.
        final n = (bytes.length - 44) ~/ 2;
        final first = h.getInt16(44, Endian.little);
        final last = h.getInt16(44 + (n - 1) * 2, Endian.little);
        expect(first.abs(), lessThan(40));
        expect(last.abs(), lessThan(40));
        var peak = 0;
        for (var i = 0; i < n; i++) {
          final v = h.getInt16(44 + i * 2, Endian.little).abs();
          if (v > peak) peak = v;
        }
        expect(peak, lessThan(32767 * 0.4), reason: 'about -10 dBFS at most');
      });
    }
  });

  // ===========================================================================
  group('only TTC reaches it', () {
    test('the shared breathing circle is untouched', () {
      final src = File('lib/widgets/breathing_circle.dart').readAsStringSync();
      expect(src.contains('ttc_cue_sounds'), isFalse);
    });

    test('only the TTC practice session plays cues', () {
      final users = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final live = f
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        if (live.contains('TtcCueSounds.instance.play(') ||
            live.contains('TtcCueSounds.instance.open(')) {
          users.add(f.path.replaceAll('\\', '/'));
        }
      }
      expect(users, ['lib/screens/ttc/ttc_practice_player.dart']);
    });
  });
}
