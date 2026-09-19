// =============================================================================
//  The Making door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Creativity_structure.pdf` as assertions, plus the user's calls
//  of 2026-09-18 (1a the showcase private · 2a the least commercial door,
//  kept so · 3a the showcase as a show mode on this phone · 4a photo
//  capture built, on-device, the voice posture). What fails silently here:
//  a like, a rank or a featured wall creeping into the portfolio; a photo
//  kept without the parent's switch; the portfolio growing a judgement of
//  her work; the six moves drifting from the brief's table; a course
//  string selling an artist; a coming-soon slot nobody owes.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_making_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_portfolio.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/screens/skilling/sk_voice_keepsake.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_creativity')!;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
    SkVoiceStore.instance.debugReset();
    SkPortfolioStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_creativity')!;

  group('the map — five cards, the brief\'s child surfaces', () {
    test('three band sets, Prompts, and the portfolio as the keepsake card', () {
      expect([for (final t in door.tabs) t.id], [
        'just_make_it', 'make_it_yours', 'make_something_real', 'prompts', 'your_portfolio',
      ]);
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null]);
      expect(_c.bandNames, {
        '6-8': 'Just make it',
        '8-11': 'Make it yours',
        '11-14': 'Make something real',
      });
      expect(door.tabs.last.tools.single.surfaceId, 'sk_portfolio/skilling_creativity');
      expect(skScreenForSurface('sk_portfolio/skilling_creativity'), isA<SkPortfolioScreen>());
      expect(skScreenForSurface('sk_portfolio/skilling_coding'), isNull, reason: 'only a door that keeps one');
      expect(_c.portfolio, isTrue);
      expect(_c.voiceKeepsake, isTrue, reason: 'the recorder, reused for the music she makes');
      expect(skScreenForSurface('sk_voice/skilling_creativity'), isNotNull);
      expect(skScreenForSurface('sk_keepsake/skilling_creativity'), isNotNull);
      expect(_c.keepsakeTitle, 'What I made');
    });

    test('the closing card is the grown-up screen; Consult is held; no coach, no journal, no off-ramp', () {
      expect(door.closing!.chip, 'Grown-ups');
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_creativity');
      expect(_c.coach, isNull, reason: '"an art or music teacher, rarely. Held."');
      expect(_c.journal, isFalse);
      expect(_c.safety, isNull);
      expect(_c.access, isEmpty);
    });

    test('the hero is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six moves — not a ladder', () {
    test('the brief\'s table, in order, ending on showing it', () {
      expect(kSkMakingSkills.map((s) => s.id).toList(), [
        'starting', 'imagining', 'your_own_way', 'playing_with_stuff', 'finishing', 'showing_it',
      ]);
      expect(kSkMakingSkills.map((s) => s.label).toList(), [
        'Starting', 'Imagining', 'Your own way', 'Playing with stuff', 'Finishing', 'Showing it',
      ]);
      expect(_c.skillById('showing_it')!.kidLine, contains('without it having to be good'));
      expect(_c.skillById('your_own_way')!.kidLine, contains('instead of copying'));
    });

    test('a FULL set per band, two per move, all placeholders, no copy', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkMakingSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
        for (final a in list) {
          expect(a.comingSoon, isTrue, reason: a.id);
          expect(a.steps, isEmpty, reason: '${a.id}: no prompt or activity copy is authored here');
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });
  });

  group('the prompts — art, music AND making', () {
    test('three sets across every band, three placeholders per band per set', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['art', 'music', 'making']);
      for (final band in kSkBands) {
        for (final set in ['art', 'music', 'making']) {
          expect(_c.lessonsIn(set, band.id), hasLength(3), reason: '$set/${band.id}');
        }
      }
      expect(_c.lessons, hasLength(27));
      for (final l in _c.lessons) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
      }
      // India first, no supplies: the sets say so in their own words.
      final blurbs = _c.lessonSets.map((s) => s.blurb).join(' ');
      expect(blurbs, contains('Rangoli'));
      expect(blurbs, contains('kitchen'));
      expect(blurbs, contains('dupatta'));
    });

    test('the parent note is the brief\'s own title', () {
      expect(_c.parentNote.title, 'Why this is a real skill, in plain words');
      expect(_c.parentNote.subtitle, contains('never marked'));
      expect(_c.parentNote.comingSoon, isTrue);
      expect(_c.parentNote.kidVoice, isFalse);
    });
  });

  group('the portfolio — keeps everything, judges nothing (1a, 3a, 4a)', () {
    test('the store keeps ids, dates, captions and paths; no score, no like, no rank, no analysis', () {
      final src = File('lib/screens/skilling/sk_portfolio.dart').readAsStringSync();
      final code = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      for (final w in [
        'like', 'Like', 'rank', 'rating', 'score', 'featured', 'Supabase', 'http', 'upload', 'analys',
        'vision', 'openai', 'askVeda', 'share_plus', 'Share.',
      ]) {
        expect(code.contains(w), isFalse, reason: 'sk_portfolio.dart code says "$w"');
      }
      // No numeric public member — the "a few / lots" helper is private.
      expect(RegExp(r'^\s*(int|double|num)\s+(get\s+)?[a-z]\w*', multiLine: true).hasMatch(code), isFalse);
      // The picked file is copied out of the cache into documents.
      expect(code.contains('getApplicationDocumentsDirectory'), isTrue);
      expect(code.contains('src.copy('), isTrue, reason: 'the memory_photos lesson: never keep the picker\'s cache path');
      // Nothing is sent: no invite link, no web half.
      expect(code.contains('parentveda.in'), isFalse);
      expect(code.contains("Uri("), isFalse);
      // The entry shape.
      final ph = SkPortfolioPhoto(id: '1', doorId: 'skilling_creativity', path: '/x/1.jpg', at: DateTime(2026, 9, 18), caption: 'a tiger');
      expect(ph.toJson().keys.toSet(), {'id', 'door', 'path', 'at', 'caption', 'item'});
      expect(SkPortfolioPhoto.fromJson(ph.toJson())!.caption, 'a tiger');
    });

    testWidgets('photos wait on the parent\'s switch; then the add row, the grid, and Show it', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Ira');
      expect(SkChildStore.instance.photosAllowed, isFalse, reason: 'off by default');
      await tester.pumpWidget(MaterialApp(home: SkPortfolioScreen(doorId: 'skilling_creativity', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.text('What I made'), findsOneWidget);
      expect(find.byKey(const Key('sk-photos-off')), findsOneWidget);
      expect(find.byKey(const Key('sk-photo-add')), findsNothing);
      // The reused halves are there regardless.
      expect(find.byKey(const Key('sk-portfolio-voice')), findsOneWidget);
      expect(find.byKey(const Key('sk-portfolio-words')), findsOneWidget);
      // The parent turns photos on.
      SkChildStore.instance.setPhotosAllowed(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-photos-off')), findsNothing);
      expect(find.byKey(const Key('sk-photo-add')), findsOneWidget);
      expect(find.byKey(const Key('sk-photos-empty')), findsOneWidget);
      expect(find.byKey(const Key('sk-show-it')), findsNothing, reason: 'nothing to show yet');
      // A photo (the file need not exist for the grid; the tile shows a placeholder).
      SkPortfolioStore.instance.debugAdd(SkPortfolioPhoto(
          id: 'p1', doorId: 'skilling_creativity', path: '/nowhere/p1.jpg', at: DateTime(2026, 9, 18), caption: 'a tiger'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-photo-grid')), findsOneWidget);
      expect(find.text('a tiger'), findsOneWidget);
      expect(find.byKey(const Key('sk-show-it')), findsOneWidget);
      // Show it: a black screen, her name, the who-for chips, the pager. Nothing else.
      await tester.tap(find.byKey(const Key('sk-show-it')));
      await tester.pumpAndSettle();
      expect(find.text('Made by Ira'), findsOneWidget);
      expect(find.byKey(const Key('sk-show-pager')), findsOneWidget);
      expect(find.byKey(const Key('sk-show-to-Dadi')), findsOneWidget);
      await tester.tap(find.byKey(const Key('sk-show-to-Dadi')));
      await tester.pumpAndSettle();
      expect(find.text('For Dadi, made by Ira'), findsOneWidget);
      for (final w in ['Like', 'Share', 'Send', 'Post']) {
        expect(find.textContaining(w), findsNothing, reason: w);
      }
      SkChildStore.instance.setPhotosAllowed(false);
    });

    test('the parent has the switch and the delete; withdrawing consent forgets the photos', () {
      final src = File('lib/screens/skilling/sk_grown_up_screen.dart').readAsStringSync();
      expect(src.contains("Key('sk-photos-switch')"), isTrue);
      expect(src.contains('Let her keep photos of what she made'), isTrue);
      expect(src.contains('Delete her photos'), isTrue);
      expect(src.contains('SkPortfolioStore.instance.forgetAll()'), isTrue);
      // Never a parent-side judgement of the work either.
      expect(src.contains('SkPortfolioStore.instance.photosFor'), isFalse, reason: 'the grown-up screen does not browse her gallery');
    });
  });

  group('the lines — the least commercial door, and nothing judged', () {
    test('a light class shelf; nothing sells an artist, a talent or a level', () {
      expect(_c.courses, hasLength(6));
      for (final band in kSkBands) {
        expect(_c.coursesFor(band.id).map((k) => k.id.split('_').last).toList(), ['art', 'music'], reason: band.id);
      }
      const banned = [
        'artist', 'talent', 'talented', 'gifted', 'level', 'levels', 'ladder', 'future', 'guarantee',
        'good drawing', 'best', 'competition', 'contest', 'prize', 'certificate', 'progress report',
        'like', 'likes', 'featured', 'rank',
      ];
      final strings = [
        for (final k in _c.courses) ...[k.title, k.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
        for (final t in door.tabs) ...[t.label, t.footer ?? '', ...t.tools.map((x) => '${x.label} ${x.blurb}')],
        door.closing!.blurb,
        for (final s in kSkMakingSkills) '${s.label} ${s.kidLine}',
        for (final s in _c.lessonSets) '${s.title} ${s.blurb}',
        _c.keepsakeTitle, _c.voiceTitle, _c.voiceBlurb, _c.voiceEmptyLine,
      ];
      for (final s in strings) {
        for (final b in banned) {
          expect(RegExp('\\b$b\\b').hasMatch(s.toLowerCase()), isFalse, reason: '"$s" says "$b"');
        }
      }
      for (final k in _c.courses) {
        expect(k.comingSoon, isTrue);
        expect(k.priceInr, isNotNull);
        expect(k.priceUsd, isNotNull);
      }
      // Products: always optional, never a gate — every blurb names the free path.
      expect(_c.products, hasLength(12));
      for (final p in _c.products) {
        expect(p.blurb.toLowerCase(), contains('optional'), reason: p.id);
        expect(p.blurb.toLowerCase(), matches(RegExp(r'works? too')), reason: '${p.id}: the no-supplies path');
      }
    });
  });

  group('the bracket — six live, the portfolio a portfolio, Consult held', () {
    test('content, activities, tools (the portfolio), products, course, extras (the private showcase); every surface resolves', () {
      final b = bracketById('skilling_creativity')!;
      for (final l in [
        BracketLayer.content, BracketLayer.activities, BracketLayer.tools,
        BracketLayer.products, BracketLayer.course, BracketLayer.extras,
      ]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skRouterKnows(id), isTrue, reason: '${l.name} → $id');
        }
      }
      expect(b.layer(BracketLayer.tools).surfaceIds, ['sk_portfolio/skilling_creativity']);
      expect(b.layer(BracketLayer.extras).surfaceIds, ['sk_portfolio/skilling_creativity'],
          reason: 'the showcase, kept private, inside the portfolio');
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
      expect(b.hue, 12);
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
      expect(find.textContaining('FOR IRA  ·  JUST MAKE IT  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Starting'), findsOneWidget);
      expect(find.text('Showing it'), findsOneWidget);
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
      expect(find.textContaining('MAKE SOMETHING REAL  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Just make it'), findsNothing);
      expect(find.text('Your portfolio'), findsWidgets);
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
