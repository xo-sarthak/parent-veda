// =============================================================================
//  The Thinking door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Thinking_structure.pdf` as assertions, plus the user's calls
//  of 2026-09-17 (1a careful framing · 2a spotting-fake as a headline
//  strand · 3a a "Just for fun" set for the extras reshape). What fails
//  silently here: the six moves drifting from the brief's table or losing
//  their last one ("the heart of the whole door"); the keepsake growing a
//  second store or a thinking score; a course string selling a "critical
//  thinker"; the door framed as arguing with elders; a Consult appearing
//  before its hold is lifted; a coming-soon slot nobody owes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_thinking_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_keepsake_screen.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_critical_thinking')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_critical_thinking')!;

  group('the map — five cards, the brief\'s child surfaces', () {
    test('three band sets, Lessons, and the keepsake under the door\'s name', () {
      expect([for (final t in door.tabs) t.id], [
        'ask_lots_of_whys', 'work_out_how_it_works', 'think_for_yourself', 'lessons', 'you_kept_thinking',
      ]);
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null]);
      expect(_c.bandNames, {
        '6-8': 'Ask lots of whys',
        '8-11': 'Work out how it works',
        '11-14': 'Think for yourself',
      });
      expect(door.tabs.last.tools.single.surfaceId, 'sk_keepsake/skilling_critical_thinking');
      expect(skScreenForSurface('sk_keepsake/skilling_critical_thinking'), isA<SkKeepsakeScreen>());
      // The extras reshape: "the certificate becomes a 'you kept thinking'
      // keepsake" — the shared keepsake, this door's title.
      expect(_c.keepsakeTitle, 'You kept thinking');
      expect(skDoorContentFor('skilling_coding')!.keepsakeTitle, "What I've made and tried",
          reason: 'the default is untouched');
    });

    test('the closing card is the grown-up screen; Consult is held; no voice, no coach, no boundary note', () {
      expect(door.closing!.chip, 'Grown-ups');
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_critical_thinking');
      expect(_c.coach, isNull, reason: '"a reasoning or debate coach, rarely. Held."');
      expect(_c.voiceKeepsake, isFalse);
      expect(_c.boundaryNote, isNull);
      expect(_c.access, isEmpty, reason: 'nothing to install');
    });

    test('the hero is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six moves — practised on real things, the last one the point', () {
    test('the brief\'s table, in order, ending on changing your mind', () {
      expect(kSkThinkingSkills.map((s) => s.id).toList(), [
        'asking_why', 'breaking_it_down', 'checking_if_true',
        'seeing_the_other_side', 'spotting_a_bad_argument', 'changing_your_mind',
      ]);
      expect(kSkThinkingSkills.map((s) => s.label).toList(), [
        'Asking why', 'Breaking it down', "Checking if it's true",
        'Seeing the other side', 'Spotting a bad argument', 'Changing your mind',
      ]);
      expect(_c.skillById('changing_your_mind')!.kidLine, contains('heart of the whole door'));
      expect(_c.skillById('checking_if_true')!.kidLine, contains('fake forward'));
    });

    test('a FULL set per band, two per move, all placeholders, no copy', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkThinkingSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
        for (final a in list) {
          expect(a.comingSoon, isTrue, reason: a.id);
          expect(a.steps, isEmpty, reason: '${a.id}: no puzzle or activity copy is authored here');
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });
  });

  group('the lessons — puzzles, why-chains, the spotting-fake strand, and the fun extras', () {
    test('four sets across every band; the strand is a headline set, not a footnote (2a)', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['puzzles', 'why_chains', 'is_it_true', 'fun']);
      for (final band in kSkBands) {
        expect(_c.lessonsIn('puzzles', band.id), hasLength(3), reason: band.id);
        expect(_c.lessonsIn('why_chains', band.id), hasLength(3), reason: band.id);
        expect(_c.lessonsIn('is_it_true', band.id), hasLength(3), reason: band.id);
        // 3a: a riddle and a friendly debate per band, optional.
        expect(_c.lessonsIn('fun', band.id), hasLength(2), reason: band.id);
      }
      expect(_c.lessons, hasLength(33));
      for (final l in _c.lessons) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: '${l.id}: nothing is authored here');
      }
    });

    test('the spotting-fake strand references Coding\'s AI literacy and does not re-author it', () {
      final strand = _c.lessonSets.firstWhere((s) => s.id == 'is_it_true');
      expect(strand.blurb, contains('Coding door'), reason: 'the cross-link slot, named');
      // Coding's AI set is itself coming soon — the brief\'s prompt: leave a
      // cross-link slot and list it.
      final coding = skDoorContentFor('skilling_coding')!;
      expect(coding.lessonsIn('ai', '11-14'), isNotEmpty);
      expect(coding.lessonsIn('ai', '11-14').every((p) => p.comingSoon), isTrue);
      final src = File('lib/data/skilling/skilling_thinking_content.dart').readAsStringSync();
      expect(src.contains('skilling_coding_content.dart'), isFalse, reason: 'referenced, not imported');
      for (final w in ['deepfake', 'large language', 'training data', 'hallucinat']) {
        expect(src.toLowerCase().contains(w), isFalse, reason: 'AI-literacy mechanism ("$w") is Coding\'s to author');
      }
    });

    test('the fun set counts nothing; the parent note is the brief\'s own title', () {
      final fun = _c.lessonSets.firstWhere((s) => s.id == 'fun');
      expect(fun.blurb, contains('Nothing counts'));
      expect(_c.parentNote.title, 'How to raise a questioner without raising an arguer');
      expect(_c.parentNote.comingSoon, isTrue);
      expect(_c.parentNote.kidVoice, isFalse);
    });
  });

  group('courses and products — the honesty guardrail', () {
    test('a reasoning class per level, light debate for the top band only; nothing sells a critical thinker', () {
      expect(_c.coursesFor('6-8'), hasLength(1));
      expect(_c.coursesFor('8-11'), hasLength(1));
      expect(_c.coursesFor('11-14'), hasLength(2), reason: 'debate lives in Think for yourself');
      expect(_c.coursesFor('11-14').map((k) => k.id).toList(), ['th_course_1114_reasoning', 'th_course_1114_debate']);
      for (final k in _c.courses) {
        expect(k.comingSoon, isTrue);
        expect(k.priceInr, isNotNull);
        expect(k.priceUsd, isNotNull);
        expect(k.noOutcomeClaims, isTrue);
      }
      const banned = [
        'critical thinker', 'smarter', 'sharper', 'brain boost', 'genius', 'iq', 'future', 'guarantee',
        'transfer', 'upgrade', 'rank', 'certificate', 'progress report',
      ];
      final strings = [
        for (final k in _c.courses) ...[k.title, k.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
      ];
      for (final s in strings) {
        for (final b in banned) {
          expect(RegExp('\\b$b\\b').hasMatch(s.toLowerCase()), isFalse, reason: '"$s" says "$b"');
        }
      }
    });

    test('a puzzle book, a logic game and brain-teaser cards per band; skilling\'s own shelf', () {
      for (final band in kSkBands) {
        final at = _c.productsFor(band.id);
        expect(at, hasLength(3), reason: band.id);
        expect(at.map((p) => p.id.split('_').last).toList(), ['book', 'game', 'cards']);
        for (final p in at) {
          expect(p.comingSoon, isTrue);
        }
      }
      final src = File('lib/data/skilling/skilling_thinking_products.dart').readAsStringSync();
      expect(src.contains('pp_products'), isFalse, reason: 'the standing call: skilling\'s own shelf until the engines unify');
    });
  });

  group('the lines — question ideas, not people; no score of her thinking', () {
    test('no door copy frames questioning as arguing with elders, parents or teachers (1a)', () {
      final copy = [
        door.tabs.map((t) => '${t.label} ${t.footer ?? ''} ${t.tools.map((x) => '${x.label} ${x.blurb}').join(' ')}').join(' '),
        door.closing!.blurb,
        for (final s in kSkThinkingSkills) '${s.label} ${s.kidLine}',
        for (final s in _c.lessonSets) '${s.title} ${s.blurb}',
        for (final k in _c.courses) '${k.title} ${k.blurb}',
        _c.parentNote.title, _c.parentNote.subtitle ?? '',
      ].join(' ').toLowerCase();
      for (final b in ['argue with', 'defy', 'disobey', 'talk back', 'question your parents', 'question your teacher', 'question your elders']) {
        expect(copy.contains(b), isFalse, reason: 'says "$b"');
      }
      // The frame says what she questions: claims, forwards, arguments.
      expect(copy, contains('claim'));
      expect(copy, contains('forward'));
    });

    test('the keepsake is the shared store under a new title: no second store, no thinking score', () {
      final src = File('lib/data/doors/sk_door_thinking.dart').readAsStringSync();
      expect(src.contains('sk_keepsake/'), isTrue);
      final tabSrc = door.tabs.last.tools.single.blurb.toLowerCase();
      expect(tabSrc, contains('never a thinking score'));
      // Nothing under lib/data/skilling/skilling_thinking_* mentions a store.
      for (final f in [
        'lib/data/skilling/skilling_thinking_activities.dart',
        'lib/data/skilling/skilling_thinking_content.dart',
      ]) {
        final s = File(f).readAsStringSync();
        expect(s.contains('Store'), isFalse, reason: '$f: data, not a tracker');
      }
    });
  });

  group('the bracket — six live, Consult held', () {
    test('content, activities, tools (into the keepsake), products, course, extras (reshaped); every surface resolves', () {
      final b = bracketById('skilling_critical_thinking')!;
      for (final l in [
        BracketLayer.content, BracketLayer.activities, BracketLayer.tools,
        BracketLayer.products, BracketLayer.course, BracketLayer.extras,
      ]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skRouterKnows(id), isTrue, reason: '${l.name} → $id');
        }
      }
      expect(b.layer(BracketLayer.tools).surfaceIds, ['sk_keepsake/skilling_critical_thinking'],
          reason: 'the rubric tracker, refused into the keepsake');
      expect(b.layer(BracketLayer.extras).surfaceIds,
          ['sk_lessons/skilling_critical_thinking', 'sk_keepsake/skilling_critical_thinking'],
          reason: 'optional fun (the set) and the "you kept thinking" keepsake; the progress report is dropped');
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
      expect(b.hue, 268);
    });
  });

  group('the age rule on five cards', () {
    testWidgets('a seven-year-old: the first band open, two locked', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7, name: 'Ira');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FOR IRA  ·  ASK LOTS OF WHYS  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Asking why'), findsOneWidget);
      expect(find.text('Changing your mind'), findsOneWidget);
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
    });

    testWidgets('a thirteen-year-old: three cards, the two bands behind gone', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(13, name: 'Dev');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('THINK FOR YOURSELF  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Ask lots of whys'), findsNothing);
      expect(find.text('Work out how it works'), findsNothing);
      expect(find.text('You kept thinking'), findsWidgets);
    });

    testWidgets('the keepsake screen wears the door\'s title', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Ira');
      await tester.pumpWidget(const MaterialApp(
          home: SkKeepsakeScreen(doorId: 'skilling_critical_thinking', doorTitle: 'Thinking')));
      await tester.pumpAndSettle();
      expect(find.text('You kept thinking'), findsOneWidget);
      expect(find.text("What I've made and tried"), findsNothing);
      // Words, not marks — the empty state is the invitation.
      expect(find.textContaining('Words, not marks'), findsOneWidget);
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
