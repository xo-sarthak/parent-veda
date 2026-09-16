// =============================================================================
//  The Confidence door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Confidence_structure.pdf` (11 Sep 2026) as assertions, plus
//  the user's calls of 2026-09-16 (1a 2a 3b 4a). What fails silently here:
//  the six cards collapsing to five; the coach becoming a Consult closing
//  card or a real booking before a coach exists; a course string promising
//  a confident child; the breath page growing a second circle; the
//  self-review growing a field; the six skills drifting from the brief's
//  table; a coming-soon slot nobody owes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_confidence_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/screens/skilling/sk_voice_keepsake.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_confidence')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
    SkVoiceStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_confidence')!;

  group('the map — six cards, the brief\'s six child surfaces', () {
    test('three band sets, Lessons, Hear yourself back, Your talks, saved', () {
      expect([for (final t in door.tabs) t.id], [
        'use_your_voice', 'stand_up_and_say_it', 'give_a_real_talk',
        'lessons', 'hear_yourself_back', 'your_talks',
      ]);
      expect(door.tabs, hasLength(6), reason: 'six only where a brief insists; this one lists six');
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null, null]);
      expect(_c.bandNames, {'6-8': 'Use your voice', '8-11': 'Stand up and say it', '11-14': 'Give a real talk'});
      // The two halves of one screen.
      expect(door.tabs[4].tools.single.surfaceId, 'sk_record/skilling_confidence');
      expect(door.tabs[5].tools.single.surfaceId, 'sk_voice/skilling_confidence');
      final rec = skScreenForSurface('sk_record/skilling_confidence');
      expect(rec, isA<SkVoiceKeepsakeScreen>());
      expect((rec as SkVoiceKeepsakeScreen).openRecorder, isTrue);
      expect((skScreenForSurface('sk_voice/skilling_confidence') as SkVoiceKeepsakeScreen).openRecorder, isFalse);
      expect(_c.voiceTitle, 'Your talks, saved');
    });

    test('the coach is on the parent side, not a Consult closing card', () {
      expect(door.closing!.chip, 'Grown-ups');
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_confidence');
      final coach = _c.coach!;
      expect(coach.comingSoon, isTrue, reason: 'a placeholder until a coach is onboarded (1a)');
      expect(coach.priceInr, isNotNull);
      expect(coach.priceUsd, isNotNull);
      expect(coach.noOutcomeClaims, isTrue);
      // Not wired to the booking engine yet.
      final src = File('lib/screens/skilling/sk_grown_up_screen.dart').readAsStringSync();
      expect(src.contains('booking/'), isFalse, reason: 'the booking engine is the named next pass');
    });

    test('the hero is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six real skills — delivery and nerve, not meaning', () {
    test('the brief\'s table, in its order', () {
      expect(kSkConfidenceSkills.map((s) => s.id).toList(), [
        'speaking_up', 'being_heard', 'facing_the_room', 'steadying_nerves', 'keeping_going', 'being_yourself',
      ]);
      expect(kSkConfidenceSkills.map((s) => s.label).toList(), [
        'Speaking up', 'Being heard', 'Facing the room', 'Steadying nerves', 'Keeping going', 'Being yourself',
      ]);
      // Nerves are the point, not a bug.
      expect(_c.skillById('steadying_nerves')!.kidLine, contains('going anyway'));
    });

    test('a FULL set per band, two per skill, all placeholders, no copy', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkConfidenceSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
        for (final a in list) {
          expect(a.comingSoon, isTrue, reason: a.id);
          expect(a.steps, isEmpty, reason: a.id);
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });
  });

  group('the lessons and the breath', () {
    test('two sets across every band, three placeholders per band per set, plus the one built page', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['prompts', 'stage']);
      for (final band in kSkBands) {
        expect(_c.lessonsIn('prompts', band.id), hasLength(3), reason: band.id);
        // The stage set carries the breath page for every band, plus three slots.
        expect(_c.lessonsIn('stage', band.id), hasLength(4), reason: band.id);
        expect(_c.lessonsIn('stage', band.id).first.id, 'cf_breath', reason: 'the breath leads the stage set');
      }
      for (final l in _c.lessons.where((l) => l.id != 'cf_breath')) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
      }
    });

    test('the breath page is the app\'s one circle, in for three and out for five, and no second circle', () {
      final b = _c.pageById('cf_breath')!;
      expect(b.comingSoon, isFalse);
      expect(b.blocks.single, isA<SkBreath>());
      final breath = b.blocks.single as SkBreath;
      expect(breath.pattern.steps.map((s) => s.seconds).toList(), [3, 5]);
      final src = File('lib/screens/skilling/sk_content.dart').readAsStringSync();
      expect(src.contains("import '../../widgets/breathing_circle.dart';"), isTrue,
          reason: 'the ONE breathing circle, reused');
      expect(src.contains('CustomPainter'), isFalse, reason: 'no circle painted here');
      expect(File('lib/screens/skilling/sk_content.dart').readAsStringSync().contains('pp_content_art'), isFalse,
          reason: 'the parenting shell is not imported');
    });
  });

  group('courses and products — the paid door, held to one line', () {
    test('one live with a coach and one recorded per level; nothing promises a confident child', () {
      for (final band in kSkBands) {
        final at = _c.coursesFor(band.id);
        expect(at.map((k) => k.mode).toSet(), {SkCourseMode.live, SkCourseMode.recorded}, reason: band.id);
        for (final k in at) {
          expect(k.comingSoon, isTrue);
          expect(k.priceInr, isNotNull);
          expect(k.priceUsd, isNotNull);
        }
      }
      const banned = ['confident child', 'fearless', 'stage-ready', 'stage ready', 'future', 'guarantee', 'rank', 'personality development'];
      final strings = [
        for (final k in _c.courses) ...[k.title, k.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
        _c.coach!.title, _c.coach!.blurb,
      ];
      for (final s in strings) {
        for (final b in banned) {
          expect(s.toLowerCase().contains(b), isFalse, reason: '"$s" says "$b"');
        }
      }
    });

    test('a toy mic, prompt cards and a stage timer per band; the app never times her', () {
      for (final band in kSkBands) {
        expect(_c.productsFor(band.id), hasLength(3), reason: band.id);
      }
      final src = File('lib/screens/skilling/sk_activity_screen.dart').readAsStringSync();
      expect(src.contains('Timer('), isFalse, reason: 'no timer on a child screen');
      expect(src.contains('Stopwatch'), isFalse);
    });
  });

  group('recording — the brief\'s call 2, as Communication, plus the self-review', () {
    test('the flags: keepsake on, self-review on, and the prompt stores nothing', () {
      expect(_c.voiceKeepsake, isTrue);
      expect(_c.voiceSelfReview, isTrue);
      expect(skDoorContentFor('skilling_communication')!.voiceSelfReview, isFalse);
      final src = File('lib/screens/skilling/sk_voice_keepsake.dart').readAsStringSync();
      final code = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      // The prompt is a Text, never a TextField, and no notice is persisted.
      final noticeIdx = code.indexOf("Key('sk-voice-notice')");
      expect(noticeIdx, greaterThan(-1));
      final around = code.substring(noticeIdx, noticeIdx + 700);
      expect(around.contains('TextField'), isFalse, reason: 'notice one thing is a prompt, not a field');
      expect(code.contains('notice'), isTrue);
      expect(code.contains("'notice':"), isFalse, reason: 'nothing noticed is written to the index');
      for (final cloud in ['SupabaseRepo', 'StorageService', 'JournalStore']) {
        expect(code.contains(cloud), isFalse);
      }
    });

    testWidgets('Hear yourself back opens on the recorder only once a parent turns recording on', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9);
      await tester.pumpWidget(MaterialApp(home: skScreenForSurface('sk_record/skilling_confidence')!));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-off')), findsOneWidget, reason: 'off by default');
      expect(find.byKey(const Key('sk-voice-record')), findsNothing, reason: 'no sheet while off');
      expect(find.text('Your talks, saved'), findsOneWidget, reason: 'the door\'s own title');
      SkChildStore.instance.setVoiceAllowed(true);
      // A new key, so the screen is built afresh and its initState opens the
      // sheet; the same widget type at the root would be updated, not made.
      await tester.pumpWidget(MaterialApp(
          key: const ValueKey('on'), home: skScreenForSurface('sk_record/skilling_confidence')!));
      // The microphone pre-check has no platform here and waits out its
      // ninety-second bound before the sheet opens.
      await tester.pump(const Duration(seconds: 91));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-record')), findsOneWidget, reason: 'the sheet is up');
      SkChildStore.instance.setVoiceAllowed(false);
    });
  });

  group('the bracket — the first live Consult', () {
    test('six layers live; extras notReady; every surface resolves', () {
      final b = bracketById('skilling_confidence')!;
      for (final l in BracketLayer.values.where((l) => l != BracketLayer.extras)) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skScreenForSurface(id), isNotNull, reason: '${l.name} -> $id');
        }
      }
      expect(b.layer(BracketLayer.consult).reason, 'Speaking coach');
      expect(b.layer(BracketLayer.extras).state, LayerState.notReady);
    });
  });

  group('the age rule on six cards', () {
    testWidgets('a seven-year-old: the first band open, two locked, six cards on the selector', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7, name: 'Ira');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FOR IRA  ·  USE YOUR VOICE  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Speaking up'), findsOneWidget);
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
    });

    testWidgets('a thirteen-year-old: four cards, the two bands behind gone', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(13, name: 'Dev');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('GIVE A REAL TALK  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Use your voice'), findsNothing);
      expect(find.text('Stand up and say it'), findsNothing);
      expect(find.text('Hear yourself back'), findsWidgets);
      expect(find.text('Your talks, saved'), findsWidgets);
    });
  });

  test('every coming-soon slot on this door is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[
      for (final a in _c.activities.where((a) => a.comingSoon)) if (!ledger.contains(a.id)) a.id,
      for (final p in _c.allPages.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
      for (final k in _c.courses.where((k) => k.comingSoon)) if (!ledger.contains(k.id)) k.id,
      for (final p in _c.products.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
      if (_c.coach!.comingSoon && !ledger.contains(_c.coach!.id)) _c.coach!.id,
    ];
    expect(missing, isEmpty, reason: 'coming-soon slots nobody owes:\n${missing.join('\n')}');
  });
}
