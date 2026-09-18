// =============================================================================
//  The Stillness door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Stillness_structure.pdf` as assertions, plus the user's calls
//  of 2026-09-17 (1a refuse the streak · 2a engines reused, sessions
//  kid-authored · 3a the invitation is one line on the keepsake, never a
//  notification · 4a the settle breath is the one built page). What fails
//  silently here: a streak, count or chain creeping in under another name;
//  a second breathing circle or audio player; the six practices drifting
//  from the brief's table; a course string selling a calmer child; the
//  settle page losing the circle; a coming-soon slot nobody owes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_stillness_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_keepsake_screen.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_stillness')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_stillness')!;

  group('the map — five cards, the brief\'s child surfaces', () {
    test('three band sets, Sessions, and the keepsake as Quiet moments taken', () {
      expect([for (final t in door.tabs) t.id], [
        'breathe_and_wiggle', 'sit_and_settle', 'find_your_calm', 'sessions', 'quiet_moments',
      ]);
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null]);
      expect(_c.bandNames, {
        '6-8': 'Breathe and wiggle',
        '8-11': 'Sit and settle',
        '11-14': 'Find your calm',
      });
      expect(door.tabs.last.tools.single.surfaceId, 'sk_keepsake/skilling_stillness');
      expect(skScreenForSurface('sk_keepsake/skilling_stillness'), isA<SkKeepsakeScreen>());
      expect(_c.keepsakeTitle, 'Quiet moments taken');
    });

    test('the closing card is the grown-up screen; Consult is held; no voice, no coach, no access rail', () {
      expect(door.closing!.chip, 'Grown-ups');
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_stillness');
      expect(_c.coach, isNull, reason: '"a kids\' yoga or meditation teacher, rarely. Held."');
      expect(_c.voiceKeepsake, isFalse);
      expect(_c.boundaryNote, isNull, reason: 'the boundary is in the parent note\'s subtitle: real distress goes to a professional');
      expect(_c.access, isEmpty);
    });

    test('the hero is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six practices — non-striving, never measured', () {
    test('the brief\'s table, in order', () {
      expect(kSkStillnessSkills.map((s) => s.id).toList(), [
        'settling', 'breathing', 'noticing', 'gentle_moving', 'calming_down', 'resting',
      ]);
      expect(kSkStillnessSkills.map((s) => s.label).toList(), [
        'Settling', 'Breathing', 'Noticing', 'Gentle moving', 'Calming down', 'Resting',
      ]);
      expect(_c.skillById('noticing')!.kidLine, contains('without having to fix anything'));
    });

    test('a FULL set per band, two per practice, all placeholders, no script', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkStillnessSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
        for (final a in list) {
          expect(a.comingSoon, isTrue, reason: a.id);
          expect(a.steps, isEmpty, reason: '${a.id}: no meditation script is authored here');
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });
  });

  group('the sessions — adapt or kid-native, and the one built page (2a, 4a)', () {
    test('three sets across every band, each card saying whether it is adapted or written for her', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['sits', 'moving', 'resting']);
      for (final band in kSkBands) {
        // The sits set carries the settle page for every band, plus three slots.
        expect(_c.lessonsIn('sits', band.id), hasLength(4), reason: band.id);
        expect(_c.lessonsIn('sits', band.id).first.id, 'sl_settle', reason: 'the settle breath leads');
        expect(_c.lessonsIn('moving', band.id), hasLength(3), reason: band.id);
        expect(_c.lessonsIn('resting', band.id), hasLength(2), reason: band.id);
      }
      for (final l in _c.lessons.where((l) => l.id != 'sl_settle')) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
        expect(l.format, anyOf('Kid-native', 'Adapted'), reason: '${l.id}: the call 2a mark');
      }
      expect(_c.lessonsIn('sits', '6-8').last.format, 'Kid-native', reason: 'a sit is written for her, not shrunk');
      expect(_c.lessonsIn('moving', '6-8').first.format, 'Adapted', reason: 'yoga transfers from Garbh');
      expect(_c.lessonsIn('resting', '6-8').first.format, 'Adapted', reason: 'the Kriya body-scan transfers');
    });

    test('the settle page is the app\'s one circle, the source the other doors borrow', () {
      final s = _c.pageById('sl_settle')!;
      expect(s.comingSoon, isFalse);
      expect(s.blocks.single, isA<SkBreath>());
      expect((s.blocks.single as SkBreath).pattern.steps.map((x) => x.seconds).toList(), [3, 5]);
      expect(s.bands, isEmpty, reason: 'every band');
      expect(skRouterKnows('sk_page/skilling_stillness/sl_settle'), isTrue);
      // Confidence's breath page already borrows this breath; same circle, same numbers.
      final cf = skDoorContentFor('skilling_confidence')!.pageById('cf_breath')!;
      expect((cf.blocks.single as SkBreath).pattern, same((s.blocks.single as SkBreath).pattern));
    });

    test('the engines are verified and reused, not rebuilt', () {
      for (final f in [
        'lib/widgets/breathing_circle.dart',
        'lib/services/raga_audio_store.dart',
        'lib/data/kriya_relaxation_data.dart',
        'lib/data/garbh_data.dart',
      ]) {
        expect(File(f).existsSync(), isTrue, reason: '$f: named by the brief, must exist');
      }
      expect(bracketById('skilling_stillness')!.theme, 'garbh');
      for (final f in Directory('lib/data/skilling').listSync().whereType<File>().where((f) => f.path.contains('stillness'))) {
        final src = f.readAsStringSync();
        expect(src.contains('CustomPainter'), isFalse, reason: '${f.path}: no second circle');
        expect(src.contains('AudioPlayer('), isFalse, reason: '${f.path}: no second player');
        expect(RegExp(r"import\s+'[^']*breathing_circle\.dart'").hasMatch(src), isFalse,
            reason: '${f.path}: the circle comes through SkBreath, not a second import');
      }
    });

    test('the parent note is the brief\'s own title and holds the boundary', () {
      expect(_c.parentNote.title, 'How stillness helps, without over-selling it');
      expect(_c.parentNote.subtitle, contains('not a treatment'));
      expect(_c.parentNote.subtitle, contains('no streak'));
      expect(_c.parentNote.comingSoon, isTrue);
      expect(_c.parentNote.kidVoice, isFalse);
    });
  });

  group('the streak — refused, on the record (1a), and the invitation (3a)', () {
    test('no streak, count, chain or days-in-a-row anywhere in the door\'s files or strings', () {
      final banned = RegExp(r"\b(streak|streaks|days in a row|day \d+|chain to keep|missed a day|keep it up|don't break)\b");
      final strings = [
        for (final t in door.tabs) '${t.label} ${t.footer ?? ''} ${t.tools.map((x) => '${x.label} ${x.blurb}').join(' ')}',
        door.closing!.blurb,
        for (final s in kSkStillnessSkills) '${s.label} ${s.kidLine}',
        for (final s in _c.lessonSets) '${s.title} ${s.blurb}',
        for (final k in _c.courses) '${k.title} ${k.blurb}',
        for (final p in _c.products) '${p.title} ${p.blurb}',
        _c.keepsakeTitle, _c.keepsakeInvite ?? '',
      ].join(' ').toLowerCase();
      // A sentence that DENIES a streak is the one permitted use.
      final denial = RegExp(r'[^.]*\b(no|never|without)\b[^.]*\b(chain|streak|count|day to miss|missed)\b[^.]*\.');
      expect(banned.hasMatch(strings.replaceAll(denial, '')), isFalse, reason: 'a streak under another name');
      // The invitation is one line with no number in it, never a notification.
      expect(_c.keepsakeInvite, isNotNull);
      expect(RegExp(r'\d').hasMatch(_c.keepsakeInvite!), isFalse, reason: 'no number, ever');
      expect(_c.keepsakeInvite, contains('Want to sit again?'));
      for (final f in ['lib/data/doors/sk_door_stillness.dart', 'lib/screens/skilling/sk_keepsake_screen.dart']) {
        final src = File(f).readAsStringSync();
        expect(src.contains('NotificationService'), isFalse, reason: '$f: no push');
        expect(src.contains('flutter_local_notifications'), isFalse, reason: '$f: no push');
      }
      // No other door carries an invitation.
      for (final c in kSkDoorContents.where((c) => c.doorId != 'skilling_stillness')) {
        expect(c.keepsakeInvite, isNull, reason: c.doorId);
      }
    });

    test('nothing sells a calmer child or a cure', () {
      const banned = [
        'calmer child', 'cure', 'cures', 'anxiety', 'fixes', 'focus', 'sleep better', 'guarantee',
        'future', 'treatment for', 'therapy', 'adhd', 'behaviour problem',
      ];
      final strings = [
        for (final k in _c.courses) ...[k.title, k.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
        for (final t in door.tabs) t.footer ?? '',
        door.closing!.blurb,
      ];
      for (final s in strings) {
        for (final b in banned) {
          expect(RegExp('\\b$b\\b').hasMatch(s.toLowerCase()), isFalse, reason: '"$s" says "$b"');
        }
      }
      for (final k in _c.courses) {
        expect(k.mode, SkCourseMode.recorded, reason: 'a longer guided series is a recording; the brief says small');
        expect(k.comingSoon, isTrue);
        expect(k.priceInr, isNotNull);
        expect(k.priceUsd, isNotNull);
      }
      expect(_c.courses, hasLength(3));
      expect(_c.products, hasLength(9));
    });
  });

  group('the bracket — six live, the streak refused into the keepsake, Consult held', () {
    test('content, activities, tools, products, course, extras; every surface resolves', () {
      final b = bracketById('skilling_stillness')!;
      for (final l in [
        BracketLayer.content, BracketLayer.activities, BracketLayer.tools,
        BracketLayer.products, BracketLayer.course, BracketLayer.extras,
      ]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skRouterKnows(id), isTrue, reason: '${l.name} → $id');
        }
      }
      expect(b.layer(BracketLayer.tools).surfaceIds, ['sk_keepsake/skilling_stillness']);
      expect(b.layer(BracketLayer.extras).surfaceIds, ['sk_keepsake/skilling_stillness']);
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
      expect(b.hue, 232);
    });
  });

  group('the age rule on five cards, and the keepsake\'s words', () {
    testWidgets('a seven-year-old: the first band open, two locked', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7, name: 'Ira');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FOR IRA  ·  BREATHE AND WIGGLE  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Settling'), findsOneWidget);
      expect(find.text('Resting'), findsOneWidget);
    });

    testWidgets('a thirteen-year-old: three cards, the two bands behind gone', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(13, name: 'Dev');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FIND YOUR CALM  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Breathe and wiggle'), findsNothing);
      expect(find.text('Quiet moments taken'), findsWidgets);
    });

    testWidgets('the keepsake wears the door\'s title and the one invitation, empty or not', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Ira');
      await tester.pumpWidget(const MaterialApp(
          home: SkKeepsakeScreen(doorId: 'skilling_stillness', doorTitle: 'Stillness')));
      await tester.pumpAndSettle();
      expect(find.text('Quiet moments taken'), findsOneWidget);
      expect(find.byKey(const Key('sk-keepsake-invite')), findsOneWidget);
      expect(find.textContaining('Want to sit again?'), findsOneWidget);
      // After a practice, the same words — no "day 2", no "keep it up".
      SkPracticeStore.instance.record(
          doorId: 'skilling_stillness', itemId: 'sl_68_01', title: 'Practice 1', kind: SkPractice.tried);
      await tester.pumpAndSettle();
      expect(find.textContaining('Want to sit again?'), findsOneWidget);
      expect(find.textContaining('Practice 1'), findsOneWidget);
      for (final w in ['day 1', 'day 2', 'keep it up', 'in a row', 'streak']) {
        expect(find.textContaining(w), findsNothing, reason: w);
      }
      // The Coding keepsake carries no invitation.
      await tester.pumpWidget(const MaterialApp(
          home: SkKeepsakeScreen(key: ValueKey('cd'), doorId: 'skilling_coding', doorTitle: 'Coding')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-keepsake-invite')), findsNothing);
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
