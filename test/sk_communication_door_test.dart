// =============================================================================
//  The Communication door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Communication_structure.pdf` (11 Sep 2026) as assertions, plus
//  the user's calls of 2026-09-15 (1a 2A 3a 4a 5a). What fails silently
//  here: a Today tab creeping onto a selector the brief drew without one; a
//  band tab that does not lock ahead or drop behind; the six skills drifting
//  from the brief's table; a course string selling fluency; the voice
//  keepsake reaching for the cloud; the boundary note becoming a course; a
//  coming-soon slot nobody owes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_communication_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_activity_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/screens/skilling/sk_voice_keepsake.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_communication')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
    SkVoiceStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_communication')!;

  group('the map — the brief\'s surface table, literally', () {
    test('five cards: the three band sets, Lessons, Your voice, saved; no Today', () {
      expect([for (final t in door.tabs) t.id],
          ['say_it_out_loud', 'tell_and_explain', 'say_what_you_think', 'lessons', 'your_voice']);
      expect([for (final t in door.tabs) t.kind], [
        SkTabKind.activities, SkTabKind.activities, SkTabKind.activities,
        SkTabKind.lessons, SkTabKind.keepsake,
      ]);
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null]);
      expect(door.tabs.any((t) => t.kind == SkTabKind.today), isFalse, reason: 'the brief drew no Today');
      expect(door.tabs.any((t) => t.kind == SkTabKind.crossBand), isFalse, reason: 'no cross-band set here');
      // The band names are the brief's, spoken to the child.
      expect(_c.bandNames, {'6-8': 'Say it out loud', '8-11': 'Tell it and explain it', '11-14': 'Say what you think'});
      for (final t in door.tabs.take(3)) {
        expect(t.label, _c.bandName(t.bandId!));
      }
    });

    test('the keepsake is Your voice, saved, and it opens the voice screen', () {
      final t = door.tabs.last;
      expect(t.tools.single.surfaceId, 'sk_voice/skilling_communication');
      expect(t.tools.single.chip, 'Keepsake');
      expect(skScreenForSurface(t.tools.single.surfaceId), isA<SkVoiceKeepsakeScreen>());
      expect(_c.voiceKeepsake, isTrue);
      // A door without the voice keepsake does not get the surface.
      expect(skScreenForSurface('sk_voice/skilling_coding'), isNull);
    });

    test('the parent side, behind the gate, from the closing card; consult held', () {
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_communication');
      expect(door.closing!.grownUp, isTrue);
      expect(door.closing!.chip, isNot('Consult'), reason: 'the brief holds Consult');
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six real skills', () {
    test('the brief\'s table, in its order', () {
      expect(kSkCommunicationSkills.map((s) => s.id).toList(),
          ['clarity', 'listening', 'describing', 'storytelling', 'right_word', 'putting_your_point']);
      expect(kSkCommunicationSkills.map((s) => s.label).toList(),
          ['Clarity', 'Listening', 'Describing', 'Storytelling', 'The right word', 'Putting your point']);
    });

    test('a FULL set per band, two per skill; all three bands filled', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkCommunicationSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
      // Tasks 7 and 8 of 36, filled 2026-09-15; Task 9, written by Claude
      // Code at the user's instruction (it sits with the other task PDFs)
      // and filled 2026-09-17.
      for (final a in _c.activities) {
        expect(a.comingSoon, isFalse, reason: a.id);
        expect(a.oneLine, isNotEmpty, reason: a.id);
        expect(a.materials, isNotEmpty, reason: '${a.id}: "Nothing", or the household items');
        expect(a.steps, hasLength(4), reason: a.id);
        expect(a.theThinking, isNotEmpty, reason: a.id);
        expect(a.whatYouPractised, isNotEmpty, reason: a.id);
        expect(a.whatYouPractised.startsWith('You '), isTrue, reason: a.id);
        expect(a.tool, isNull, reason: a.id);
        expect(a.breathPageId, isNull, reason: '${a.id}: the breath is Confidence\'s');
      }
      // The tasks' spot checks.
      expect(_c.activityById('cm_68_01')!.title, 'Say It So I Get It');
      expect(_c.activityById('cm_68_12')!.title, 'I Heard You, and...');
      expect(_c.activityById('cm_811_01')!.title, 'Explain How It Works');
      expect(_c.activityById('cm_811_12')!.title, 'Disagree Nicely');
      expect(_c.activityById('cm_1114_01')!.title, 'Explain the Hard Thing');
      expect(_c.activityById('cm_1114_12')!.title, 'Hold a Real Back-and-Forth');
    });

    test('the 11 to 14 copy holds the band\'s brief line and the door\'s boundaries', () {
      // The task sits outside the repo with the other PDFs, so it cannot be
      // read here; the Dart was generated from it and diffed by script at
      // the fill. These are the lines that carry the band's shape.
      // The band's brief line, honoured by the capstone.
      expect(_c.activityById('cm_1114_12')!.oneLine, contains('change your mind out loud'));
      // Craft, not logic: the two point activities hand reasoning to Thinking.
      expect(_c.activityById('cm_1114_11')!.theThinking, contains('Thinking door'));
      expect(_c.activityById('cm_1114_12')!.theThinking, contains('Thinking door'));
      // Listening carries weight: the fourth waits for "yes, that is it".
      expect(_c.activityById('cm_1114_04')!.steps[2], contains('yes, that is it'));
    });

    test('the tasks\' rules: no nerve or audience, listening carries weight, any language, no outcome', () {
      const banned = ['future', 'genius', 'guarantee', 'career', 'ahead of', 'correct accent', 'stage voice', 'leaderboard'];
      for (final a in _c.activities.where((a) => !a.comingSoon)) {
        final copy = [a.title, a.oneLine, a.materials, ...a.steps, a.whatYouPractised].join(' ').toLowerCase();
        for (final b in banned) {
          expect(copy.contains(b), isFalse, reason: '${a.id} says "$b"');
        }
        // The child-facing copy never asks for courage or an audience — that
        // is Confidence. (The parent line may name the contrast.)
        for (final b in ['be brave', 'audience', 'in front of people', 'louder']) {
          expect(copy.contains(b), isFalse, reason: '${a.id} says "$b" — that is the Confidence door');
        }
      }
      // The right-word activities explicitly allow any language.
      final anyLang = _c.activities.where((a) => a.skillPurpose == 'right_word' && !a.comingSoon);
      expect(anyLang.any((a) => [...a.steps, a.theThinking].join(' ').toLowerCase().contains('any language')), isTrue);
      expect(anyLang.any((a) => [...a.steps, a.theThinking].join(' ').toLowerCase().contains('every language')), isTrue);
    });

    test('offersRecording is the tasks\' six, and only those', () {
      final offered = _c.activities.where((a) => a.offersRecording).map((a) => a.id).toList();
      expect(offered, ['cm_68_07', 'cm_68_08', 'cm_811_07', 'cm_811_08', 'cm_1114_07', 'cm_1114_08']);
      expect(_c.activityById('cm_68_07')!.title, 'Tell Me What Happened');
      expect(_c.activityById('cm_68_08')!.title, 'Once Upon a Time');
      expect(_c.activityById('cm_811_07')!.title, 'Retell the Movie');
      expect(_c.activityById('cm_811_08')!.title, 'Make It Exciting');
      expect(_c.activityById('cm_1114_07')!.title, 'Tell It So It Lands');
      expect(_c.activityById('cm_1114_08')!.title, 'Short Version, Long Version');
      for (final a in _c.activities.where((a) => a.offersRecording)) {
        expect(a.skillPurpose, 'storytelling', reason: a.id);
      }
    });
  });

  group('the lesson set', () {
    test('three sets across every band, three cards per band per set, no copy', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['prompts', 'story_frames', 'describe_explain']);
      for (final s in _c.lessonSets) {
        expect(s.bands, isEmpty, reason: '${s.id} spans every band');
      }
      expect(_c.crossBandSetId, isNull);
      for (final band in kSkBands) {
        expect(_c.lessonSetsFor(band.id), hasLength(3), reason: band.id);
        for (final s in _c.lessonSets) {
          expect(_c.lessonsIn(s.id, band.id), hasLength(3), reason: '${s.id}/${band.id}');
        }
      }
      for (final l in _c.lessons) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
      }
    });
  });

  group('courses and products — the user\'s calls 4a and 5a', () {
    test('the brief\'s three per level plus one English slot; nothing sells fluency', () {
      for (final band in kSkBands) {
        final at = _c.coursesFor(band.id);
        expect(at, hasLength(4), reason: band.id);
        expect(at.where((k) => k.id.endsWith('_english')), hasLength(1), reason: 'one English slot per level');
        for (final k in at) {
          expect(k.comingSoon, isTrue);
          expect(k.priceInr, isNotNull);
          expect(k.priceUsd, isNotNull);
          final s = '${k.title} ${k.blurb}'.toLowerCase();
          for (final b in ['fluent in', 'fluency in', 'future', 'guarantee', 'rank', 'career', 'ahead of']) {
            expect(s.contains(b), isFalse, reason: '${k.id} says "$b"');
          }
        }
      }
      final english = _c.courses.where((k) => k.id.endsWith('_english'));
      for (final k in english) {
        expect(k.title.toLowerCase(), contains('too'), reason: 'named for what it adds, not what it promises');
        expect(k.blurb.toLowerCase(), contains('own language'), reason: 'mother tongue first');
      }
    });

    test('the product shelf is skilling\'s own: deck, book, game, puppet per band', () {
      for (final band in kSkBands) {
        final at = _c.productsFor(band.id);
        expect(at, hasLength(4), reason: band.id);
        expect(at.every((p) => p.comingSoon), isTrue);
      }
      final src = File('lib/data/skilling/skilling_communication_products.dart').readAsStringSync();
      expect(src.contains('pp_products'), isFalse, reason: 'the parenting shop is not wired (question 5, a)');
    });
  });

  group('the boundary note and the parent note', () {
    test('both exist, both parent-facing, both coming soon; the boundary is not a course', () {
      expect(_c.parentNote.kidVoice, isFalse);
      expect(_c.parentNote.comingSoon, isTrue);
      final bn = _c.boundaryNote!;
      expect(bn.kidVoice, isFalse);
      expect(bn.comingSoon, isTrue);
      expect(bn.id, 'cm_boundary_note');
      expect(_c.courses.any((k) => k.title.toLowerCase().contains('stammer') || k.title.toLowerCase().contains('speech')), isFalse,
          reason: 'speech delay is not a course');
      expect(_c.allPages.map((p) => p.id), contains('cm_boundary_note'));
    });
  });

  group('the voice keepsake — the user\'s call 1a', () {
    test('records on this phone only: no cloud in the file, no numeric member on the store', () {
      final src = File('lib/screens/skilling/sk_voice_keepsake.dart').readAsStringSync();
      final code = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      for (final cloud in ['SupabaseRepo', 'StorageService', 'JournalStore', 'supabase']) {
        expect(code.contains(cloud), isFalse, reason: 'the keepsake reaches for $cloud');
      }
      expect(code.contains('package:record/record.dart'), isTrue, reason: 'the same mechanism as the journal');
      expect(code.contains('package:audioplayers/audioplayers.dart'), isTrue);
      final numeric = RegExp(r'^\s*(int|double|num)\s+(get\s+)?[a-z]\w*', multiLine: true);
      expect(numeric.hasMatch(code), isFalse, reason: 'no count of recordings');
      // The pregnancy journal is untouched.
      final journal = File('lib/widgets/journal/journal_create.dart').readAsStringSync();
      expect(journal.contains('skilling'), isFalse);
    });

    test('the store keeps clips by door, newest first, and forget-all empties it', () {
      final s = SkVoiceStore.instance;
      expect(s.hasClips('skilling_communication'), isFalse);
      s.add(SkVoiceClip(id: 'a', doorId: 'skilling_communication', title: 'One', path: '/x/a.m4a', at: DateTime(2026, 9, 1)));
      s.add(SkVoiceClip(id: 'b', doorId: 'skilling_communication', title: 'Two', path: '/x/b.m4a', at: DateTime(2026, 9, 2)));
      s.add(SkVoiceClip(id: 'c', doorId: 'skilling_coding', title: 'Other', path: '/x/c.m4a', at: DateTime(2026, 9, 3)));
      expect(s.clipsFor('skilling_communication').map((c) => c.id).toList(), ['b', 'a']);
      expect(s.hasClips('skilling_coding'), isTrue);
      s.forgetAll();
      expect(s.hasClips('skilling_communication'), isFalse);
    });

    test('the gate names recordings in what is kept', () {
      final gate = File('lib/screens/skilling/sk_parent_gate_screen.dart').readAsStringSync();
      expect(gate.contains('Recordings she makes'), isTrue);
    });

    testWidgets('the record row: only where offered, only once a parent turns it on, never on Coding', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7);
      final story = _c.activityById('cm_68_08')!; // Once Upon a Time, offersRecording
      final plain = _c.activityById('cm_68_01')!; // Say It So I Get It
      // Off by default: no row even where offered.
      expect(SkChildStore.instance.voiceAllowed, isFalse, reason: 'off by default');
      await tester.pumpWidget(MaterialApp(home: SkActivityScreen(content: _c, activity: story)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-row')), findsNothing);
      // The parent turns it on.
      SkChildStore.instance.setVoiceAllowed(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-row')), findsOneWidget);
      expect(find.text('Say it in your voice'), findsOneWidget);
      // Not on an activity that does not offer it.
      await tester.pumpWidget(MaterialApp(home: SkActivityScreen(key: const ValueKey('p'), content: _c, activity: plain)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-row')), findsNothing);
      // Never on a door without the keepsake.
      await tester.pumpWidget(MaterialApp(
          home: SkActivityScreen(key: const ValueKey('cd'), content: skDoorContentFor('skilling_coding')!, activity: story)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-row')), findsNothing);
      SkChildStore.instance.setVoiceAllowed(false);
    });

    testWidgets('the keepsake screen invites the grown-up while recording is off', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7);
      await tester.pumpWidget(const MaterialApp(home: SkVoiceKeepsakeScreen(doorId: 'skilling_communication')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-off')), findsOneWidget);
      expect(find.text('Record something'), findsNothing);
      SkChildStore.instance.setVoiceAllowed(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-voice-off')), findsNothing);
      expect(find.text('Record something'), findsOneWidget);
      SkChildStore.instance.setVoiceAllowed(false);
    });
  });

  group('the bracket', () {
    test('five layers live, the rubric tracker refused into the voice keepsake; extras and consult held', () {
      final b = bracketById('skilling_communication')!;
      for (final l in [BracketLayer.content, BracketLayer.activities, BracketLayer.tools, BracketLayer.course, BracketLayer.products]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skScreenForSurface(id), isNotNull, reason: '${l.name} -> $id');
        }
      }
      expect(b.layer(BracketLayer.tools).surfaceIds, ['sk_voice/skilling_communication']);
      expect(b.layer(BracketLayer.extras).state, LayerState.notReady);
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
    });
  });

  group('the age rule on band-pinned tabs', () {
    testWidgets('a six-year-old: the first band open, the next two locked From 8 and From 11', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(6, name: 'Anaya');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FOR ANAYA  ·  SAY IT OUT LOUD  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Clarity'), findsOneWidget, reason: 'her band\'s first rail');
      expect(find.text('Say It So I Get It'), findsOneWidget, reason: 'filled');
      expect(find.text('Coming soon'), findsNothing, reason: 'the 6 to 8 band is filled');
      // Landing on the 11 to 14 tab shows the panel, not its rails.
      await tester.pumpWidget(MaterialApp(
          home: SkDoorScreen(key: const ValueKey('l'), door: door, onSurface: (_, _) {}, initialTabId: 'say_what_you_think')));
      await tester.pumpAndSettle();
      expect(find.text('This opens when Anaya turns 11.'), findsOneWidget);
      expect(find.text('Clarity'), findsNothing);
    });

    testWidgets('a twelve-year-old: the two bands behind her are gone; three cards remain', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(12, name: 'Vihaan');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('SAY WHAT YOU THINK  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Say it out loud'), findsNothing, reason: 'grown past, dropped');
      expect(find.text('Tell it and explain it'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget, reason: 'only the closing card');
      expect(find.text('Your voice, saved'), findsWidgets);
    });

    testWidgets('a five-year-old: everything locked from 6, the grown-up card open', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(5, name: 'Zoya');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('From 6 years'), findsNWidgets(5));
      expect(find.text('For the grown-up'), findsOneWidget);
    });
  });

  test('every coming-soon slot on this door is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[
      for (final a in _c.activities.where((a) => a.comingSoon)) if (!ledger.contains(a.id)) a.id,
      for (final p in _c.allPages.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
      for (final k in _c.courses.where((k) => k.comingSoon)) if (!ledger.contains(k.id)) k.id,
      for (final p in _c.products.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
    ];
    expect(missing, isEmpty, reason: 'coming-soon slots nobody owes:\n${missing.join('\n')}');
  });
}
