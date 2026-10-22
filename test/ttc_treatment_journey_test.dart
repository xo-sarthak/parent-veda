// IVF and IUI, step by step (2026-10-22). The user: the door must show "what
// happens at each step", and "vids should be first thing user sees ... dont
// place vid in the last of the rail". See lib/ttc/ttc_treatment_journey.dart
// and lib/screens/ttc/doors/ttc_treatment_journey.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/reads/read_images.dart' show pvFilmStillFor;
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart'
    show ttcDoorVideosFirst, kTtcIvfBracketId;
import 'package:parentveda/screens/ttc/doors/ttc_treatment_journey.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart'
    show ttcInlineToolFor;
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart' show ttcReadById;
import 'package:parentveda/ttc/ttc_treatment_journey.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart' show ttcVideoBySlot;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the steps', () {
    test('every row her round tracker asks about has a step', () {
      for (final kind in TtcJourneyKind.values) {
        final steps = kTtcJourney[kind]!;
        final covered = {for (final s in steps) ...s.steps};
        for (final row in ttcRoundRows(kind.roundKind)) {
          if (row.scans) {
            expect(steps.any((s) => s.scans), isTrue,
                reason: '${kind.name}: the scans have no step');
          } else {
            expect(covered, contains(row.step),
                reason: '${kind.name}: ${row.step} has no step');
          }
        }
      }
    });

    test('every read and every video resolves, and every video has a still',
        () {
      for (final kind in TtcJourneyKind.values) {
        for (final s in kTtcJourney[kind]!) {
          expect(ttcReadById(s.readId), isNotNull, reason: s.readId);
          expect(ttcVideoBySlot(s.videoSlotId), isNotNull,
              reason: s.videoSlotId);
          expect(pvFilmStillFor(s.videoSlotId), isNotNull,
              reason: '${s.videoSlotId} has no still');
        }
      }
    });

    test('keys are unique within a journey', () {
      for (final kind in TtcJourneyKind.values) {
        final keys = [for (final s in kTtcJourney[kind]!) s.key];
        expect(keys.toSet().length, keys.length, reason: kind.name);
      }
    });

    test('no step gives a chance, a dose or a date as hers', () {
      final banned = RegExp(
          r'\byour (chance|chances|odds|success rate)\b|\bper cent\b|\d+\s*%',
          caseSensitive: false);
      for (final kind in TtcJourneyKind.values) {
        for (final s in kTtcJourney[kind]!) {
          final all = '${s.what} ${s.howLong} ${s.hurts} ${s.ask}';
          expect(banned.hasMatch(all), isFalse, reason: s.key);
        }
      }
    });
  });

  group('You are here', () {
    test('follows the round phase, first step that claims it', () {
      int? here(TtcJourneyKind k, TtcRoundPhase p) => ttcJourneyHere(k, p);
      String key(TtcJourneyKind k, int? i) => kTtcJourney[k]![i!].key;
      expect(key(TtcJourneyKind.ivf, here(TtcJourneyKind.ivf, TtcRoundPhase.stimulation)),
          'ivf_injections');
      expect(key(TtcJourneyKind.ivf, here(TtcJourneyKind.ivf, TtcRoundPhase.procedure)),
          'ivf_collection');
      expect(key(TtcJourneyKind.iui, here(TtcJourneyKind.iui, TtcRoundPhase.procedure)),
          'iui_day');
      expect(key(TtcJourneyKind.frozen, here(TtcJourneyKind.frozen, TtcRoundPhase.transfer)),
          'fet_transfer');
      expect(ttcJourneyHere(TtcJourneyKind.ivf, null), isNull);
      expect(ttcJourneyHere(TtcJourneyKind.ivf, TtcRoundPhase.ownCycle), isNull);
    });

    test('each round kind opens its own journey', () {
      for (final k in TtcJourneyKind.values) {
        expect(ttcJourneyKindFor(k.roundKind), k);
      }
      expect(ttcJourneyKindFor(null), TtcJourneyKind.ivf);
    });
  });

  group('the door', () {
    test('Step by step is the first tab, and its body resolves', () {
      final first = kTtcIvfFocus.groups!.first;
      expect(first.id, kTtcIvfStepsGroupId);
      expect(first.inlineSurfaceId, kTtcTreatmentJourneySurface);
      expect(ttcInlineToolFor(first.inlineSurfaceId!), isNotNull,
          reason: 'the tab would open on nothing');
    });

    test('a video leads every rail on the door', () {
      final shown = ttcDoorVideosFirst(kTtcIvfFocus.sections, kTtcIvfBracketId);
      for (final s in shown) {
        var seenOther = false;
        for (final t in s.tiles) {
          if (t is TtcVideoTile) {
            expect(seenOther, isFalse,
                reason: '"${s.heading}": a video after another piece');
          } else {
            seenOther = true;
          }
        }
      }
      // The two that lead their sections now.
      for (final h in [
        'Should we get fertility help?',
        'What will the clinic test, and why?',
        'The wait, and after the result',
      ]) {
        expect(shown.firstWhere((s) => s.heading == h).tiles.first,
            isA<TtcVideoTile>(), reason: h);
      }
    });
  });

  testWidgets('the video sits above every step, and the switch changes the steps',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: TtcTreatmentJourneyBody()))));
    await tester.pump();
    for (final s in kTtcJourney[TtcJourneyKind.ivf]!) {
      final video = find.byKey(ValueKey('ttc_journey_video_${s.key}'));
      expect(video, findsOneWidget, reason: s.key);
      final title = find.descendant(
          of: find.byKey(ValueKey('ttc_journey_step_${s.key}')),
          matching: find.text(s.title));
      expect(tester.getTopLeft(video).dy,
          lessThan(tester.getTopLeft(title).dy),
          reason: '${s.key}: the video is not first');
    }
    expect(find.text('Coming soon · 2 min'), findsWidgets,
        reason: 'an unmade film says so, never a play glyph');
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    await tester.tap(find.byKey(const ValueKey('ttc_journey_kind_iui')));
    await tester.pump();
    expect(find.byKey(const ValueKey('ttc_journey_step_iui_day')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_journey_step_ivf_collection')),
        findsNothing);
    expect(tester.takeException(), isNull);
  });
}
