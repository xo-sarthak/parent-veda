// =============================================================================
//  The Coding door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Coding_structure_v2.pdf` (11 Sep 2026) as assertions, plus the
//  user's calls of 2026-09-14. What fails silently here: a sixth surface
//  creeping onto the selector; a band with fewer than twelve activity slots
//  or a skill with fewer than two; a lesson set losing its band; a course or
//  product string promising a future; a coming-soon slot nobody owes; the
//  keepsake growing a number; the door opening in a release build; a child
//  under six seeing an open child tab; an age picker appearing anywhere.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_coding_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_activity_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_consent_verifier.dart';
import 'package:parentveda/screens/skilling/sk_content.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_grown_up_gate.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_coding')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_coding')!;

  group('the map', () {
    test('five tabs, the brief\'s five child surfaces, in the brief\'s order', () {
      expect([for (final t in door.tabs) t.id],
          ['today', 'things_to_do', 'lessons', 'ai', 'made_and_tried']);
      expect([for (final t in door.tabs) t.kind], [
        SkTabKind.today,
        SkTabKind.activities,
        SkTabKind.lessons,
        SkTabKind.crossBand,
        SkTabKind.keepsake,
      ]);
      expect(door.tabs.length, 5);
      expect(door.tabs.map((t) => t.id).toSet(), hasLength(5));
    });

    test('the parent surfaces are behind the gate, reached from the closing card', () {
      final c = door.closing!;
      expect(c.grownUp, isTrue);
      expect(c.chip, 'Grown-ups');
      expect(c.surfaceId, 'sk_grown_up/skilling_coding');
      expect(skScreenForSurface(c.surfaceId), isNotNull);
      for (final id in ['sk_courses/skilling_coding', 'sk_products/skilling_coding', 'sk_gate']) {
        expect(skScreenForSurface(id), isNotNull, reason: id);
      }
    });

    test('the hero photo is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
      expect(door.heroImageUrl, isNot(contains('plus.unsplash')));
    });

    test('the keepsake is the tool card on the fifth tab', () {
      final t = door.tabs.last;
      expect(t.tools.single.surfaceId, 'sk_keepsake/skilling_coding');
      expect(t.tools.single.chip, 'Keepsake');
      expect(skScreenForSurface(t.tools.single.surfaceId), isNotNull);
    });
  });

  group('the activities, the heart', () {
    test('a FULL set per band: twelve slots, two per thinking skill, six skills', () {
      expect(kSkCodingSkills.map((s) => s.id).toList(),
          ['sequencing', 'pattern', 'debugging', 'decomposition', 'logic', 'persistence']);
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkCodingSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2),
              reason: '${band.id} / ${s.id}');
        }
        for (final a in list) {
          expect(_c.skillById(a.skillPurpose), isNotNull, reason: a.id);
          expect(skBandById(a.band), isNotNull, reason: a.id);
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });

    test('the scaffold authors no activity copy', () {
      for (final a in _c.activities) {
        expect(a.comingSoon, isTrue, reason: a.id);
        expect(a.oneLine, isEmpty, reason: a.id);
        expect(a.steps, isEmpty, reason: a.id);
        expect(a.whatYouPractised, isEmpty, reason: a.id);
        expect(a.theThinking, isEmpty, reason: a.id);
      }
    });

    test('the model carries every field the task PDFs name', () {
      const a = SkActivity(
        id: 'x', band: '6-8', skillPurpose: 'sequencing', title: 't',
        oneLine: 'o', materials: 'm', steps: ['s'], theThinking: 'th',
        whatYouPractised: 'w', tool: 'Scratch', multiSession: true,
      );
      expect(a.materials, 'm');
      expect(a.tool, 'Scratch');
      expect(a.multiSession, isTrue);
    });

    test('today is derived from the date, never asked, and stays inside her band', () {
      for (final band in kSkBands) {
        final a = _c.todayFor(band.id, now: DateTime(2026, 9, 14));
        expect(a, isNotNull);
        expect(a!.band, band.id);
        expect(_c.todayFor(band.id, now: DateTime(2026, 9, 14)), same(a), reason: 'same all day');
        expect(_c.todayFor(band.id, now: DateTime(2026, 9, 15)), isNot(same(a)), reason: 'changes daily');
      }
    });
  });

  group('the lessons and the AI set', () {
    test('three sets, one per band, plus the AI set across all', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['unplugged', 'blocks', 'projects', 'ai']);
      expect(_c.setById('unplugged')!.bands, ['6-8']);
      expect(_c.setById('blocks')!.bands, ['8-11']);
      expect(_c.setById('projects')!.bands, ['11-14']);
      expect(_c.setById('ai')!.bands, isEmpty, reason: 'spans every band');
      expect(_c.crossBandSetId, 'ai');
      for (final band in kSkBands) {
        expect(_c.lessonSetsFor(band.id).map((s) => s.id).toList(), [_c.bandName(band.id).toLowerCase()],
            reason: 'her band sees its own set on the Lessons tab');
        expect(_c.lessonsIn('ai', band.id), isNotEmpty, reason: 'the AI set has cards for ${band.id}');
        for (final s in _c.lessonSetsFor(band.id)) {
          expect(_c.lessonsIn(s.id, band.id), isNotEmpty, reason: '${s.id} for ${band.id}');
        }
      }
      expect(_c.bandNames, {'6-8': 'Unplugged', '8-11': 'Blocks', '11-14': 'Projects'});
    });

    test('every lesson is a placeholder with no copy', () {
      for (final l in _c.lessons) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
        expect(l.set, isNotNull, reason: l.id);
        expect(_c.setById(l.set!), isNotNull, reason: l.id);
      }
      expect(_c.parentNote.comingSoon, isTrue);
      expect(_c.parentNote.kidVoice, isFalse, reason: 'the note is for the parent');
    });
  });

  group('courses and products', () {
    test('leveled, live and recorded, priced in both currencies, and coming soon', () {
      expect(_c.courses, hasLength(6));
      for (final band in kSkBands) {
        final at = _c.coursesFor(band.id);
        expect(at.map((c) => c.mode).toSet(), {SkCourseMode.live, SkCourseMode.recorded}, reason: band.id);
        for (final c in at) {
          expect(c.priceInr, isNotNull, reason: c.id);
          expect(c.priceUsd, isNotNull, reason: c.id);
          expect(c.noOutcomeClaims, isTrue);
          expect(c.comingSoon, isTrue, reason: 'placeholder programme');
        }
      }
    });

    test('kits, robotics and books, age-tagged, coming soon', () {
      for (final band in kSkBands) {
        final at = _c.productsFor(band.id);
        expect(at.map((p) => p.kind).toSet(),
            {SkProductKind.kit, SkProductKind.robotics, SkProductKind.book}, reason: band.id);
        for (final p in at) {
          expect(p.bands, isNotEmpty, reason: '${p.id} is age-tagged');
          expect(p.comingSoon, isTrue, reason: p.id);
        }
      }
    });

    test('nothing on either shelf promises a future', () {
      const banned = [
        'future', 'genius', 'ahead of', 'guarantee', 'will become', 'career',
        'rank', 'top of', 'certified', 'job-ready', 'next einstein',
      ];
      final strings = [
        for (final c in _c.courses) ...[c.title, c.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
      ];
      for (final s in strings) {
        for (final b in banned) {
          expect(s.toLowerCase().contains(b), isFalse, reason: '"$s" contains "$b"');
        }
      }
    });
  });

  group('the bracket', () {
    test('five layers live to named surfaces; extras and consult stay notReady', () {
      final b = bracketById('skilling_coding')!;
      for (final l in [
        BracketLayer.content, BracketLayer.activities, BracketLayer.tools,
        BracketLayer.course, BracketLayer.products,
      ]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        expect(b.layer(l).reason, isNotEmpty, reason: '${l.name} keeps the workbook text');
        for (final id in b.layer(l).surfaceIds) {
          expect(id, startsWith('sk_'), reason: id);
          expect(skScreenForSurface(id), isNotNull, reason: '${l.name} -> $id');
        }
      }
      expect(b.layer(BracketLayer.extras).state, LayerState.notReady);
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
    });

    test('the door stays behind kDebugMode; the preview tile falls back to the plan sheet', () {
      final router = File('lib/screens/skilling/sk_surface_router.dart').readAsStringSync();
      final body = router.substring(router.indexOf('bool skOpenDoor('));
      expect(body.contains('if (!kDebugMode) return false;'), isTrue,
          reason: 'the stage stays gated until the briefs say otherwise');
      final preview = File('lib/screens/skilling/skilling_preview_screen.dart').readAsStringSync();
      expect(preview.contains('if (!skOpenDoor(context, b.id)) _showPlan(context, b, p);'), isTrue,
          reason: 'a tile that cannot open its door shows the plan, never nothing');
    });
  });

  group('the age rule', () {
    testWidgets('a nine-year-old sees five open tabs, her band on the hero, no picker', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Meera');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-door-age-line')), findsOneWidget);
      expect(find.textContaining('FOR MEERA  ·  BLOCKS  ·  8 TO 11'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget, reason: 'only the closing card\'s lock');
      expect(find.byKey(const Key('sk-door-locked-panel')), findsNothing);
      expect(find.text('One thing to try today'), findsOneWidget);
      expect(find.text('For the grown-up'), findsOneWidget, reason: 'the closing, under every tab');
      expect(find.textContaining('Show every age'), findsNothing);
      expect(find.byType(DropdownButton<String>), findsNothing, reason: 'no age picker on a child screen');
      expect(find.byType(Slider), findsNothing);
      // The activity tab: one rail per skill, twelve coming-soon cards.
      await tester.pumpWidget(MaterialApp(
          home: SkDoorScreen(key: const ValueKey('acts'), door: door, onSurface: (_, _) {}, initialTabId: 'things_to_do')));
      await tester.pumpAndSettle();
      for (final s in kSkCodingSkills) {
        expect(find.text(s.label), findsOneWidget, reason: s.id);
      }
      expect(find.text('Coming soon'), findsWidgets);
    });

    testWidgets('a five-year-old sees every child tab locked from 6, and the grown-up card open', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(5, name: 'Kabir');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('From 6 years'), findsNWidgets(5), reason: 'every child tab is locked');
      expect(find.byKey(const Key('sk-door-locked-panel')), findsOneWidget);
      expect(find.text('This opens when Kabir turns 6.'), findsOneWidget);
      expect(find.text('One thing to try today'), findsNothing);
      expect(find.text('For the grown-up'), findsOneWidget, reason: 'the parent side stays open');
      expect(find.textContaining('FROM 6 YEARS'), findsWidgets);
    });

    test('bands: inclusive lower, exclusive upper, floor at six, ceiling reads the top band', () {
      expect(skBandFor(5), isNull);
      expect(skBandFor(6)!.id, '6-8');
      expect(skBandFor(7)!.id, '6-8');
      expect(skBandFor(8)!.id, '8-11');
      expect(skBandFor(10)!.id, '8-11');
      expect(skBandFor(11)!.id, '11-14');
      expect(skBandFor(13)!.id, '11-14');
      expect(skBandFor(15)!.id, '11-14', reason: 'no fourth band yet; the top rung is the honest content');
    });
  });

  group('no score, anywhere', () {
    test('the keepsake store exposes words and bools, never a number', () {
      final src = File('lib/screens/skilling/sk_practice_store.dart').readAsStringSync();
      final code = src.split('\n').where((l) => !l.trimLeft().startsWith('//') && !l.trimLeft().startsWith('///')).join('\n');
      final numeric = RegExp(r'^\s*(int|double|num)\s+(get\s+)?[a-z]\w*', multiLine: true);
      expect(numeric.hasMatch(code), isFalse,
          reason: 'a public int/double member on the keepsake is a score waiting to be drawn');
      expect(code.contains('.length'), isFalse, reason: 'no count leaks out as a length');
    });

    test('recording writes a word; the furthest word wins; nothing else is derivable', () {
      final s = SkPracticeStore.instance;
      expect(s.wordFor('skilling_coding', 'cd_68_01'), '');
      expect(s.hasPractised('skilling_coding'), isFalse);
      s.record(doorId: 'skilling_coding', itemId: 'cd_68_01', title: 'Be My Robot', kind: SkPractice.tried);
      expect(s.wordFor('skilling_coding', 'cd_68_01'), 'Tried');
      s.record(doorId: 'skilling_coding', itemId: 'cd_68_01', title: 'Be My Robot', kind: SkPractice.made);
      s.record(doorId: 'skilling_coding', itemId: 'cd_68_01', title: 'Be My Robot', kind: SkPractice.practisedAgain);
      expect(s.wordFor('skilling_coding', 'cd_68_01'), 'Made', reason: 'the furthest, not the latest');
      expect(s.hasPractised('skilling_coding'), isTrue);
      expect(s.hasPractised('skilling_maths'), isFalse);
      final lines = s.entriesFor('skilling_coding');
      expect(lines.single.word, 'Made');
      expect(lines.single.title, 'Be My Robot');
    });

    testWidgets('the activity screen: three words, the honest line, the parent line behind the gate', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7);
      const a = SkActivity(
        id: 'demo', band: '6-8', skillPurpose: 'sequencing', title: 'Be My Robot',
        oneLine: 'You are the boss.', materials: 'Nothing.',
        steps: ['Pick a tiny job.', 'Give your steps out loud.'],
        theThinking: 'This is sequencing.',
        whatYouPractised: 'You gave steps in the right order.',
      );
      await tester.pumpWidget(MaterialApp(home: SkActivityScreen(content: _c, activity: a)));
      await tester.pumpAndSettle();
      expect(find.text('PUTTING STEPS IN ORDER'), findsOneWidget);
      expect(find.text('This is sequencing.'), findsNothing, reason: 'the parent line is not in the kid flow');
      expect(find.byKey(const Key('sk-what-you-practised')), findsNothing);
      await tester.tap(find.byKey(const Key('sk-practice-tried')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-what-you-practised')), findsOneWidget);
      expect(find.text('You gave steps in the right order.'), findsOneWidget);
      expect(find.textContaining('TRIED'), findsOneWidget);
      // Behind the gate.
      await tester.tap(find.textContaining('For the grown-up'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-gate-question')), findsOneWidget);
      expect(find.text('This is sequencing.'), findsNothing);
    });
  });

  group('the grown-up gate', () {
    test('the sum is in words and needs the number', () {
      final q = SkGrownUpSum.random();
      expect(q.question, startsWith('What is '));
      expect(RegExp(r'\d').hasMatch(q.question), isFalse, reason: 'words, so a young child cannot read it');
      expect(q.check('${q.answer}'), isTrue);
      expect(q.check('${q.answer + 1}'), isFalse);
    });

    test('a PIN, once set, is what the gate checks', () {
      final s = SkChildStore.instance;
      expect(s.hasPin, isFalse);
      s.setPin('4321');
      expect(s.hasPin, isTrue);
      expect(s.checkPin('4321'), isTrue);
      expect(s.checkPin('1234'), isFalse);
      s.setPin(null);
      expect(s.hasPin, isFalse);
    });
  });

  group('the parent gate and the child record', () {
    test('no record: not consented; the door routes to the gate first', () {
      expect(SkChildStore.instance.consented, isFalse);
      final router = File('lib/screens/skilling/sk_surface_router.dart').readAsStringSync();
      expect(router.contains('if (!SkChildStore.instance.consented)'), isTrue);
      expect(router.contains('SkParentGateScreen('), isTrue);
    });

    test('consent keeps a name, a date of birth and the verifier\'s word; forget clears all', () {
      final s = SkChildStore.instance;
      s.consent(name: 'Meera', dob: DateTime(2018, 3, 2), verification: SkVerification.stub);
      expect(s.consented, isTrue);
      expect(s.name, 'Meera');
      expect(s.band, isNotNull);
      s.forget();
      expect(s.consented, isFalse);
      expect(s.ageYears, isNull);
    });

    test('the verifier is an interface with a stub, and the stub says so', () {
      final src = File('lib/screens/skilling/sk_consent_verifier.dart').readAsStringSync();
      expect(src.contains('abstract class SkConsentVerifier'), isTrue);
      expect(src.contains('class SkStubConsentVerifier implements SkConsentVerifier'), isTrue);
      expect(src.toLowerCase().contains('legal review'), isTrue);
      for (final provider in ['digilocker', 'aadhaar', 'otp']) {
        expect(RegExp('class \\w*$provider\\w*', caseSensitive: false).hasMatch(src), isFalse,
            reason: 'no provider is hard-wired');
      }
    });
  });

  test('every coming-soon slot on this door is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[
      for (final a in _c.activities.where((a) => a.comingSoon)) if (!ledger.contains(a.id)) a.id,
      for (final p in _c.allPages.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
      for (final c in _c.courses.where((c) => c.comingSoon)) if (!ledger.contains(c.id)) c.id,
      for (final p in _c.products.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
    ];
    expect(missing, isEmpty, reason: 'coming-soon slots nobody owes:\n${missing.join('\n')}');
  });
}
