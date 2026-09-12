// =============================================================================
//  The Sleep door, held against its rebuild brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Sleep_rebuild.pdf` is a map: seven collections, each page named
//  with the format it SHOULD be, marked [reuse] / [reformat] / [new] / [merge]
//  / [cut] / [reference] / [auto-scope]. This file is that map as assertions,
//  so "does the build match the brief?" is a test run and not a reading of a
//  three-thousand-line data file against a four-page PDF.
//
//  ⚠️ THREE THINGS HERE ARE THE KIND THAT FAIL SILENTLY, which is why they are
//  tests and not review notes:
//
//  * **The age rule.** A band chip is one widget; a link that says "check the
//    range for her exact age" is one row. Either can come back in a later edit
//    without anything breaking, and the brief's rule is absolute: no chooser,
//    anywhere.
//  * **Single source.** The wake-windows tool and the tracker's age-context
//    card both quote a wake window. If one is edited and the other is not, a
//    mother sees two numbers for one baby, and neither screen can tell.
//  * **No second copies.** Four worry articles must be reachable from their
//    slides and from nowhere else. A `linkedOnly` flag dropped by accident
//    re-lists them beside the carousel, and the collection looks fine.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/hubs/hub_registry.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sleep_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sounds_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_story_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_wake_windows_screen.dart';

PpSection get _sleep => ppSectionFor('parenting_sleep')!;

PpArea _area(String id) => _sleep.areas.firstWhere((a) => a.id == id);

PpPage _page(String id) => _sleep.pageById(id)!;

/// The listed pages of an area, in authored order, every band together.
List<String> _listed(String areaId) =>
    [for (final p in _area(areaId).pages) if (!p.linkedOnly) p.id];

/// The brief's badge vocabulary. A page format outside this set is a page the
/// brief did not describe.
const _badges = {
  'CHART',
  'ANIMATION',
  'TOOL',
  'CAROUSEL',
  'CARDS',
  'TABLE',
  'VIDEO',
  'INTERACTIVE',
  'RED FLAG',
  'ARTICLE',
  'ILLUSTRATION',
  'AUDIO LIBRARY',
};

void _ageMonths(int months) {
  ChildProfileStore.instance
      .debugSetDob(DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the map: seven collections, the pages the brief names, in order', () {
    test('the seven collections, in the brief\'s order', () {
      expect([for (final a in _sleep.areas) a.id], [
        'how_much',
        'night_waking',
        'regressions',
        'getting_to_sleep',
        'safe_sleep',
        'worries',
        'music',
      ]);
    });

    test('collection 1: her sleep right now, the animation, the tool, the carousel', () {
      expect(_listed('how_much'), [
        // One chart per band; auto-scope shows exactly one of the five.
        'sleep_newborn',
        'sleep_3_6',
        'sleep_6_12',
        'sleep_toddler',
        'sleep_preschool',
        'baby_vs_adult_sleep',
        'wake_windows',
        'overtired_baby',
      ]);
      for (final id in ['sleep_newborn', 'sleep_3_6', 'sleep_6_12', 'sleep_toddler', 'sleep_preschool']) {
        expect(_page(id).title, 'Her sleep right now', reason: id);
        expect(_page(id).format, 'CHART', reason: id);
        expect(_page(id).bands, hasLength(1),
            reason: '$id must belong to exactly one band, so she sees one chart');
      }
      expect(_page('baby_vs_adult_sleep').format, 'ANIMATION');
      expect(_page('wake_windows').format, 'TOOL');
      expect(_page('overtired_baby').format, 'CAROUSEL');
    });

    test('collection 2: waking, in the brief\'s order', () {
      expect(_listed('night_waking'), [
        'why_babies_wake',
        'normal_waking_by_age',
        'gentle_settling',
        'at_3am',
        'waking_doctor',
      ]);
      expect(_page('why_babies_wake').format, 'CARDS');
      expect(_page('normal_waking_by_age').format, 'TABLE');
      expect(_page('gentle_settling').format, 'VIDEO');
      expect(_page('at_3am').format, 'INTERACTIVE');
      expect(_page('waking_doctor').format, 'RED FLAG');
    });

    test('collection 3: regressions surface at their ages, night weaning from six months', () {
      expect(_listed('regressions'), [
        'what_is_regression',
        'regression_4m',
        'regression_8_10m',
        'regression_toddler',
        'night_weaning',
      ]);
      expect(_page('what_is_regression').bands, isEmpty);
      expect(_page('regression_4m').bands, ['m3_6'],
          reason: 'the brief: "Shows in the 3-6mo band"');
      expect(_page('regression_8_10m').bands, ['m6_12']);
      expect(_page('regression_toddler').bands, ['tod']);
      expect(_page('night_weaning').title, 'Night weaning, gently');
      expect(_page('night_weaning').bands, ['m6_12', 'tod'],
          reason: 'the brief: "Shows from ~6mo"');
    });

    test('collection 4: the stance pinned on top, the routine with the hour before bed inside it', () {
      expect(_listed('getting_to_sleep'), [
        'sleep_training_stance',
        'bedtime_routine',
        'malish',
        'feeding_to_sleep',
        'day_night_confusion',
        'dropping_naps',
        'joint_family_sleep',
        'own_space',
        'sleep_away_from_home',
      ]);
      expect(_page('sleep_training_stance').pinned, isTrue);
      expect(_page('sleep_training_stance').format, 'VIDEO');
      expect(_sleep.allPages.where((p) => p.pinned).length, 1,
          reason: 'one pinned page in the whole section');

      // The merge: the wind-down article lives inside the routine page now,
      // and the old page does not exist.
      expect(_sleep.pageById('wind_down'), isNull,
          reason: '"The hour before bed" is folded in; "Not a separate page."');
      final routine = _page('bedtime_routine');
      expect(
          routine.blocks.whereType<PpArticle>().any((a) => a.heading == 'The hour before bed'),
          isTrue,
          reason: 'the routine page carries the wind-down section');
      expect(_page('malish').format, 'VIDEO');
      expect(_page('own_space').title, 'Moving her to her own cot or room');
      expect(_page('sleep_away_from_home').format, 'CAROUSEL');
    });

    test('collection 5: two illustrations, a video, an interactive checklist', () {
      expect(_listed('safe_sleep'), [
        'safer_bed_sharing',
        'back_to_sleep',
        'swaddling',
        'sleep_surface',
        'overheating',
        'sids_calmly',
      ]);
      expect(_page('safer_bed_sharing').format, 'ILLUSTRATION');
      expect(_page('back_to_sleep').format, 'ILLUSTRATION');
      expect(_page('swaddling').format, 'VIDEO');
      expect(_page('sleep_surface').format, 'INTERACTIVE');
      // The harm-reduction wording stays under the picture.
      final bed = _page('safer_bed_sharing');
      expect(bed.blocks.whereType<PpCards>().length, 2,
          reason: 'what raises the risk, what lowers it');
      expect(
          bed.blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor),
          isTrue,
          reason: 'the nights she needs her own surface');
    });

    test('collection 6: the worry set, snoring, the dummy page', () {
      expect(_listed('worries'), ['worry_set', 'noisy_breathing', 'dummy_soother']);
      expect(_page('worry_set').format, 'CAROUSEL');
      expect(_page('dummy_soother').format, 'ARTICLE');
    });

    test('collection 7: the honest article and the library', () {
      expect(_listed('music'), ['does_music_help', 'sleep_sounds_library']);
      expect(_page('sleep_sounds_library').format, 'AUDIO LIBRARY');
    });

    test('every listed page wears a badge from the brief\'s vocabulary', () {
      for (final p in _sleep.allPages) {
        if (p.linkedOnly) continue;
        expect(_badges, contains(p.format),
            reason: '${p.id} has format "${p.format}", which the brief does not use');
      }
    });
  });

  group('the reformats are real, not relabelled', () {
    test('a carousel or interactive page is only its block: no page between the tap and the thing', () {
      for (final p in _sleep.allPages) {
        final f = p.format?.toUpperCase();
        if (f == 'CAROUSEL') {
          expect(p.blocks, hasLength(1), reason: '${p.id} carries prose nobody can reach');
          expect(p.blocks.single, isA<PpCarousel>(), reason: p.id);
        }
        if (f == 'INTERACTIVE') {
          expect(p.blocks, hasLength(1), reason: '${p.id} carries prose nobody can reach');
          expect(p.blocks.single, isA<PpInteractive>(), reason: p.id);
        }
      }
    });

    test('a slide that links to a page links to a real one', () {
      for (final p in _sleep.allPages) {
        for (final c in p.blocks.whereType<PpCarousel>()) {
          for (final card in c.cards) {
            if (card.pageId == null) continue;
            expect(_sleep.pageById(card.pageId!), isNotNull,
                reason: '${p.id}: slide links to "${card.pageId}"');
          }
        }
      }
    });

    test('a VIDEO page has a video slot at its top', () {
      for (final id in ['gentle_settling', 'malish', 'swaddling', 'sleep_training_stance', 'bedtime_routine']) {
        final p = _page(id);
        expect(p.hasVideo, isTrue, reason: id);
        expect(p.orderedBlocks.first, isA<PpVideoSlot>(), reason: id);
      }
    });

    test('the 3am page is a night step-through that ends on the doctor page', () {
      final i = _page('at_3am').blocks.whereType<PpInteractive>().single;
      expect(i.kind, PpInteractiveKind.night);
      expect(i.items, hasLength(7), reason: 'the same seven steps');
      expect(_sleep.pageById(i.closingPageId!), isNotNull);
    });

    test('the sleep space is a walk-through checklist, in two groups', () {
      final i = _page('sleep_surface').blocks.whereType<PpInteractive>().single;
      expect(i.kind, PpInteractiveKind.checklist);
      expect(i.items, hasLength(11));
      expect({for (final it in i.items) it.group}, {'The surface', 'Clear away'});
    });

    test('the cycle animation keeps the comparison table', () {
      final p = _page('baby_vs_adult_sleep');
      expect(p.blocks.whereType<PpAnimation>().single.kind, PpAnimationKind.sleepCycles);
      expect(p.blocks.whereType<PpTable>(), isNotEmpty,
          reason: 'the brief: "Keep the comparison table"');
    });

    test('the illustrations are labelled', () {
      final bed = _page('safer_bed_sharing').blocks.whereType<PpIllustration>().single;
      expect(bed.kind, PpIllustrationKind.safeBedSetup);
      expect(bed.labels, hasLength(8), reason: 'the eight setup points');
      final back = _page('back_to_sleep').blocks.whereType<PpIllustration>().single;
      expect(back.kind, PpIllustrationKind.backToSleep);
      expect(back.labels.length, greaterThanOrEqualTo(3));
    });

    test('the music myths are a myth-vs-truth carousel', () {
      final c = _page('does_music_help').blocks.whereType<PpCarousel>().single;
      expect(c.cards, hasLength(5));
      expect(c.cards.every((k) => k.myth), isTrue);
      expect(c.cards.every((k) => k.body.isNotEmpty), isTrue,
          reason: 'every myth carries what is true');
    });
  });

  group('the age rule: the app knows her age and never asks', () {
    test('the section auto-scopes and the chart pages cover every band', () {
      expect(_sleep.autoScope, isTrue);
      for (final b in kPpSleepBands.bands) {
        final charts = _area('how_much')
            .pagesFor(b.id)
            .where((p) => p.title == 'Her sleep right now');
        expect(charts, hasLength(1), reason: '${b.id} must see exactly one chart');
      }
    });

    test('no link, anywhere in Sleep, opens the old age checker', () {
      for (final p in _sleep.allPages) {
        for (final b in p.blocks) {
          if (b is PpLink) {
            expect(b.surfaceId, isNot('pp_sleep_check'), reason: p.id);
          }
        }
      }
      expect(_sleep.tools.map((t) => t.surfaceId), isNot(contains('pp_sleep_check')));
    });

    test('no copy asks her to enter or check an exact age', () {
      final banned = ['her exact age', 'enter her age', 'pick an age', 'choose her age'];
      for (final p in _sleep.allPages) {
        for (final b in p.blocks) {
          for (final s in _strings(b)) {
            for (final w in banned) {
              expect(s.toLowerCase().contains(w), isFalse, reason: '${p.id}: "$s"');
            }
          }
        }
      }
    });

    test('every age-arc table and timeline marks her row, and covers every month', () {
      final spans = <String, List<(int, int)>>{
        'normal_waking_by_age': _page('normal_waking_by_age').blocks.whereType<PpTable>().single.rowMonths!,
        'dropping_naps': _page('dropping_naps').blocks.whereType<PpTable>().single.rowMonths!,
        'what_is_regression': _page('what_is_regression').blocks.whereType<PpChartCard>().single.rowMonths!,
      };
      for (final MapEntry(key: id, value: rows) in spans.entries) {
        // Every month a parenting child can be (0 to 5 years) lands on
        // exactly one row. A gap is a table that leads with nothing.
        final top = id == 'what_is_regression' ? 36 : 72;
        for (var m = 0; m < top; m++) {
          final hits = rows.where((r) => m >= r.$1 && m < r.$2).length;
          expect(hits, 1, reason: '$id: month $m lands on $hits rows');
        }
      }
    });

    test('the worry set narrows by age without ever emptying', () {
      final c = _page('worry_set').blocks.whereType<PpCarousel>().single;
      expect(c.cardsFor(1), hasLength(4));
      expect(c.cardsFor(8), hasLength(3), reason: '"sleeps all the time" is a first-six-months worry');
      expect(c.cardsFor(30), hasLength(1), reason: 'early waking is the toddler one');
      expect(c.cardsFor(60), isNotEmpty);
    });
  });

  group('single source, and no second copies', () {
    test('the landing offers one tool: Sleep Sounds', () {
      expect([for (final t in _sleep.tools) t.surfaceId], ['pp_sleep_sounds']);
      // The tracker is the hub's second door, not a tool row.
      final hub = hubFor('parenting_sleep')!;
      expect(hub.needs.map((n) => n.surfaceId), contains('pp_sleep'));
      expect(hub.needs, hasLength(2));
      expect(hub.closing, isNotNull, reason: 'Talk to a sleep expert');
    });

    test('the four worry pages are reachable from their slides and listed nowhere', () {
      final c = _page('worry_set').blocks.whereType<PpCarousel>().single;
      final targets = {for (final k in c.cards) k.pageId!};
      expect(targets, {'only_sleeps_on_me', 'catnapping', 'early_waking', 'sleeping_too_much'});
      for (final id in targets) {
        final p = _page(id);
        expect(p.linkedOnly, isTrue, reason: '$id would be a second copy beside the carousel');
      }
      final linkedOnly = {for (final p in _sleep.allPages) if (p.linkedOnly) p.id};
      expect(linkedOnly, targets, reason: 'nothing else is hidden');
      for (final b in kPpSleepBands.bands) {
        expect(_area('worries').pagesFor(b.id).map((p) => p.id), isNot(contains('catnapping')));
      }
    });

    test('the collection 7 library IS the player\'s library', () {
      final slots = _page('sleep_sounds_library').blocks.whereType<PpAudioSlot>().toList();
      final tracks = [for (final c in kPpSoundCategories) ...c.tracks];
      expect(slots.map((s) => s.slotId).toList(), tracks.map((t) => t.slotId).toList(),
          reason: 'same tracks, same order, same ids');
    });

    test('the tanpura drone shares Shravan\'s file', () {
      final tanpura = [for (final c in kPpSoundCategories) ...c.tracks].firstWhere((t) => t.id == 'raga_tanpura');
      expect(tanpura.isLive, isTrue);
      expect(tanpura.asset, 'audio/raga_drone.wav');
    });
  });

  group('the wake windows tool', () {
    test('resolves as a surface and from its page', () {
      expect(ppScreenForSurface('pp_wake_windows'), isNotNull);
      expect(_page('wake_windows').toolSurfaceId, 'pp_wake_windows');
      expect(ppScreenForSurface(_page('wake_windows').toolSurfaceId!), isNotNull);
    });

    test('every month from birth to five has one window', () {
      for (var m = 0; m < 72; m++) {
        final hits = kPpWakeWindows.where((w) => w.contains(m)).length;
        expect(hits, 1, reason: 'month $m');
      }
      expect(ppWakeWindowFor(0).minMinutes, 45, reason: 'newborn ~45-60 min');
      expect(ppWakeWindowFor(0).maxMinutes, 60);
    });

    test('agrees with the tracker\'s age-context card for the first year', () {
      // The tracker's wakeLabel is "45–60 min" / "1.5–2.5h". Read its two
      // numbers and compare them, in minutes, to the tool's span. Drift in
      // either direction fails here rather than on a phone.
      for (final months in [0, 2, 5, 8, 11]) {
        _ageMonths(months);
        final label = SleepStore.instance.ageContext.wakeLabel;
        final nums = RegExp(r'[\d.]+').allMatches(label).map((m) => double.parse(m.group(0)!)).toList();
        final scale = label.contains('h') ? 60 : 1;
        final w = ppWakeWindowFor(ChildProfileStore.instance.ageInMonths);
        expect((nums[0] * scale).round(), w.minMinutes, reason: 'month $months: tracker "$label"');
        expect((nums[1] * scale).round(), w.maxMinutes, reason: 'month $months: tracker "$label"');
      }
    });
  });

  group('the door shell: five tabs over the seven collections', () {
    final door = ppDoorFor('parenting_sleep')!;

    test('the door exists, with five tabs, like every other door', () {
      expect(door.tabs, hasLength(5));
      expect({for (final t in door.tabs) t.id}, hasLength(5), reason: 'ids unique');
    });

    test('every collection sits on exactly one tab, and no tab names a ghost', () {
      final areas = {for (final a in _sleep.areas) a.id};
      final placed = [for (final t in door.tabs) ...t.areaIds];
      expect(placed.toSet(), areas, reason: 'every area placed, nothing invented');
      expect(placed, hasLength(areas.length), reason: 'no area on two tabs');
    });

    test('the red flag is the doctor page, and it is a RED FLAG page', () {
      final flag = door.tabs.map((t) => t.redFlagPageId).whereType<String>().single;
      expect(flag, 'waking_doctor');
      expect(_page(flag).format, 'RED FLAG');
      expect(door.tabFor('night_waking')!.redFlagPageId, flag);
    });

    test('the landing items survive as tool rows and the closing', () {
      final tools = [for (final t in door.tabs) ...t.tools];
      expect(tools.map((t) => t.surfaceId).toSet(), {'pp_sleep', 'pp_sleep_sounds'});
      for (final t in tools) {
        expect(ppScreenForSurface(t.surfaceId), isNotNull, reason: t.label);
      }
      expect(door.closing, isNotNull);
      expect(ppScreenForSurface(door.closing!.surfaceId), isNotNull);
    });

    test('the tile and every section link open the door, not the library', () {
      // The router: a section with a door resolves to the door, on the tab
      // that holds the area asked for.
      final bare = ppScreenForSurface('pp_section/parenting_sleep');
      expect(bare, isA<PpDoorScreen>());
      final deep = ppScreenForSurface('pp_section/parenting_sleep/regressions');
      expect(deep, isA<PpDoorScreen>());
      expect((deep! as PpDoorScreen).initialTabId, 'waking');
      // The home tile: a source check, because `_openBracket` is private.
      final home = File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
      expect(home.contains('ppDoorFor(bracketId)'), isTrue,
          reason: 'the Start anywhere tile must consult kPpDoors before the hub');
    });

    testWidgets('the shell renders: hero, five cards, a rail, the closing', (tester) async {
      _ageMonths(4);
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('Track and understand sleep'), findsOneWidget);
      expect(find.text('Her sleep right now'), findsOneWidget, reason: 'one chart, hers');
      // Representation B on this door: a sentence with the label in it.
      expect(find.textContaining('Talk to a sleep expert'), findsOneWidget);
      expect(find.textContaining('FOR YOUR BABY'), findsOneWidget, reason: 'the age line');
      for (final b in kPpSleepBands.bands) {
        expect(find.widgetWithText(GestureDetector, b.label), findsNothing,
            reason: 'no age chooser on the door');
      }
    });
  });

  group('on screen', () {
    Future<void> pump(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: w));
      await tester.pumpAndSettle();
    }

    testWidgets('the landing draws no age chips, and says which age it shows', (tester) async {
      _ageMonths(4);
      await pump(tester, PpSectionScreen(section: _sleep, onSurface: (_, _) {}));
      for (final b in kPpSleepBands.bands) {
        expect(find.text(b.label), findsNothing, reason: 'a chip for ${b.id} is a chooser');
      }
      expect(find.textContaining('3 TO 6 MONTHS'), findsOneWidget,
          reason: 'the "for her, at this age" line');
    });

    testWidgets('the story screen advances on tap and offers the linked page', (tester) async {
      String? opened;
      await pump(
          tester,
          PpStoryScreen(
            title: 'Test',
            hue: 188,
            cards: const [
              PpCarouselCard('First slide', 'one'),
              PpCarouselCard.linked('Second slide', 'two', pageId: 'catnapping'),
            ],
            onPage: (_, id) => opened = id,
          ));
      expect(find.text('First slide'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Second slide'), findsOneWidget);
      await tester.tap(find.text('Swipe up for the full page'));
      await tester.pumpAndSettle();
      expect(opened, 'catnapping');
    });

    testWidgets('an interactive is a story: one step per slide, the doctor page last', (tester) async {
      final block = _page('at_3am').blocks.whereType<PpInteractive>().single;
      final slides = ppInteractiveAsSlides(block);
      expect(slides, hasLength(block.items.length + 1), reason: 'seven steps and the closing');
      expect(slides.last.pageId, 'waking_doctor', reason: 'the closing swipes up to the doctor page');
      await pump(tester, PpStoryScreen(
        title: block.title, cards: slides, hue: block.hue,
        coverTitle: block.title, coverBlurb: block.blurb,
        dim: true, onPage: (_, _) {},
      ));
      expect(find.text(block.title), findsWidgets);
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text(block.items[0].title), findsOneWidget);
      expect(find.text('Done'), findsNothing, reason: 'no buttons; it is a story');
      expect(find.text('Not yet'), findsNothing);
    });

    test('the checklist kinds become stories too', () {
      final block = _page('sleep_surface').blocks.whereType<PpInteractive>().single;
      final slides = ppInteractiveAsSlides(block);
      expect(slides, hasLength(block.items.length + 1));
      expect(slides.first.body, contains('The surface'), reason: 'the group rides in the body');
    });
  });
}

Iterable<String> _strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) return [?b.heading, for (final s in b.steps) ...[s.title, ?s.detail]];
  if (b is PpCards) return [?b.heading, for (final c in b.cards) ...[c.title, c.line]];
  if (b is PpTable) return [?b.heading, ...b.columns, for (final r in b.rows) ...r];
  if (b is PpChartCard) return [b.title, ?b.subtitle, ?b.note, for (final (l, v) in b.rows) ...[l, v]];
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpVideoSlot) return [b.title, ?b.subtitle];
  if (b is PpLink) return [b.label, ?b.blurb];
  if (b is PpCarousel) return [?b.coverTitle, ?b.coverBlurb, for (final c in b.cards) ...[c.title, c.body]];
  if (b is PpInteractive) return [b.title, ?b.blurb, ?b.closing, for (final i in b.items) ...[i.title, ?i.detail]];
  if (b is PpAnimation) return [b.title, ?b.caption];
  if (b is PpIllustration) return [b.title, ?b.caption, for (final l in b.labels) ...[l.title, ?l.detail]];
  return const [];
}
