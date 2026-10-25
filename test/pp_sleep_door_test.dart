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
//
//  Then door plan 07 (`docs/pp-door-plans/07-sleep.md`, built 2026-10-25) as
//  "door 7: the plan, held". What fails silently there: a toddler's parent
//  seeing SIDS again after a retag; the tracker's numbers drifting from the
//  chart; a sounds link offering tracks that don't play before the one that
//  does; a product on the SIDS, bed-sharing or red-flag page; a nest or a
//  swing linked as a place to sleep; the Tonight row drawn twice.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/hubs/hub_registry.dart';
import 'package:parentveda/services/raga_audio_store.dart';
import 'package:parentveda/widgets/pv_toast.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_inline_tools.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sleep_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sounds_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sounds_screen.dart';
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
        expect(_page(id).title, 'Sleep at this age', reason: id);
        expect(_page(id).format, 'CHART', reason: id);
        // One chart per band is held below ("the chart pages cover every
        // band"). Since SL2 split the toddler band at two, the toddler chart
        // is both halves'. Was `bands, hasLength(1)` for every chart.
        expect(_page(id).bands,
            id == 'sleep_toddler' ? ['tod_1_2', 'tod_2_3'] : hasLength(1),
            reason: '$id must belong to its own band(s), so she sees one chart');
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
        'sick_or_head_bump', // SL10
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
      expect(_page('regression_toddler').bands, ['tod_1_2', 'tod_2_3']);
      expect(_page('night_weaning').title, 'Night weaning, gently');
      expect(_page('night_weaning').bands, ['m6_12', 'tod_1_2', 'tod_2_3'],
          reason: 'the brief: "Shows from ~6mo"');
    });

    test('collection 4: the stance pinned on top, the routine with the hour before bed inside it', () {
      expect(_listed('getting_to_sleep'), [
        'sleep_training_stance',
        'bedtime_routine',
        'malish',
        'feeding_to_sleep',
        'day_night_confusion',
        'jhula_safety', // SL7
        'dropping_naps',
        'joint_family_sleep',
        'own_space',
        'sleep_away_from_home',
      ]);
      expect(_page('sleep_training_stance').pinned, isTrue);
      expect(_page('sleep_training_stance').format, 'VIDEO');
      // Two since SL10: the stance, and the sick-or-bump warning list, which
      // never sinks once read (S10). Was one.
      expect([for (final p in _sleep.allPages) if (p.pinned) p.id],
          ['sick_or_head_bump', 'sleep_training_stance'],
          reason: 'the stance, and one warning list');

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
      expect(_page('own_space').title, 'Moving to a separate cot or room');
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
        'safe_sleep_after_one', // SL7
        'hot_nights', // SL7
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
      expect(_listed('worries'), ['worry_set', 'noisy_breathing', 'dummy_soother', 'night_fears', 'sleep_talk_walk']);
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
      expect(i.items, hasLength(12), reason: 'eleven, and nests and swings (SL7)');
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
            .where((p) => p.title == 'Sleep at this age');
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
      final page = _page('sleep_sounds_library');
      final slots = page.blocks.whereType<PpAudioSlot>().toList();
      // A recorded track is a link that opens the player, not an inert slot
      // (tools pass 30, 2026-10-26); the rest are slots, in the player's order.
      final tracks = [for (final c in kPpSoundCategories) ...c.tracks.where((t) => !t.isLive)];
      expect(slots.map((s) => s.slotId).toList(), tracks.map((t) => t.slotId).toList(),
          reason: 'same tracks, same order, same ids');
      final live = [for (final c in kPpSoundCategories) ...c.tracks.where((t) => t.isLive)];
      final links = page.blocks.whereType<PpLink>().where((l) => l.surfaceId == 'pp_sleep_sounds');
      for (final t in live) {
        expect(links.any((l) => l.label.startsWith(t.title)), isTrue, reason: '${t.title} plays from the page');
      }
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

    test('agrees with the tracker\'s age-context card at every month to five', () {
      // The tracker's wakeLabel is "45–60 min" / "1.5–2.5h". Read its two
      // numbers and compare them, in minutes, to the tool's span. Drift in
      // either direction fails here rather than on a phone.
      // Every month since SL3 (was the first year: 0, 2, 5, 8, 11).
      for (var months = 0; months < 72; months++) {
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
      // + the 7-day history, 2026-10-07 (gap analysis P2).
      expect(tools.map((t) => t.surfaceId).toSet(), {'pp_sleep', 'pp_care_history', 'pp_sleep_sounds'});
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
      // On How much sleep: since SL1 a four-month-old opens on Getting to
      // sleep, and the tracker row is one tab away.
      await tester.pumpWidget(MaterialApp(
          home: PpDoorScreen(
              door: door, initialTabId: 'how_much', onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
      expect(find.text('Track and understand sleep'), findsOneWidget);
      expect(find.text('Sleep at this age'), findsOneWidget, reason: 'one chart, hers');
      // Representation B on this door: a sentence with the label in it.
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget); // the consult card again (step 0 · S3, 2026-10-25); was the closing line (2026-10-21)
      expect(find.textContaining('For your baby'), findsOneWidget, reason: 'the age line');
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

  _door7();
}

// =============================================================================
//  Door 7: the plan, held (`docs/pp-door-plans/07-sleep.md`, SL1 to SL10)
// =============================================================================

/// A month in each band, and the tab that band opens on (SL1).
const _opens = {1: 'safe', 4: 'getting', 8: 'getting', 18: 'getting', 30: 'getting', 48: 'getting'};

/// The Tonight row by band, as SL1's table gives it.
const _tonight = {
  'nb': ['Set up a safe sleep space', 'Swaddling', 'Day and night', 'Gentle settling', 'Tanpura to sleep'],
  'm3_6': ['The bedtime routine', 'Wake windows', 'Malish before bed', 'Gentle settling', 'Tanpura to sleep'],
  'm6_12': ['The bedtime routine', 'Wake windows', 'Malish before bed', 'Gentle settling', 'Tanpura to sleep'],
  'tod_1_2': ['The bedtime routine', 'Screens off, story on', 'Dropping naps', 'Tanpura to sleep'],
  'tod_2_3': ['The bedtime routine', 'Screens off, story on', 'Dropping naps', 'Tanpura to sleep'],
  'pre': ['The bedtime routine', 'Screens off, story on', 'Night fears', 'Dropping naps', 'Tanpura to sleep'],
};

const _infantSafeSleep = [
  'sids_calmly', 'back_to_sleep', 'safer_bed_sharing', 'sleep_surface', 'overheating', 'swaddling',
];

Iterable<PpLink> _links(String id) => _page(id).blocks.whereType<PpLink>();

String _src(String path) => File(path).readAsStringSync();

/// The two numbers of a range, "14 to 17 hours" or "14–17h".
List<int> _range(String s) =>
    RegExp(r'\d+').allMatches(s).map((m) => int.parse(m.group(0)!)).take(2).toList();

void _door7() {
  final door = ppDoorFor('parenting_sleep')!;
  PpDoorTab tab(String id) => door.tabs.firstWhere((t) => t.id == id);

  group('door 7: the plan, held', () {
    test('SL1: the tab order for each age', () {
      expect(door.tabOrder, {
        'nb': ['safe', 'how_much', 'waking', 'getting', 'worries'],
        'm3_6': ['getting', 'waking', 'how_much', 'safe', 'worries'],
        'm6_12': ['getting', 'waking', 'how_much', 'safe', 'worries'],
        'tod_1_2': ['getting', 'waking', 'worries', 'how_much', 'safe'],
        'tod_2_3': ['getting', 'waking', 'worries', 'how_much', 'safe'],
        'pre': ['getting', 'waking', 'worries', 'how_much', 'safe'],
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in kPpSleepBands.bands) b.id},
          reason: 'every band has an order');
    });

    test('SL1: Tonight is the plan\'s cards for each age, and every one opens', () {
      for (final b in kPpSleepBands.bands) {
        final picks = ppSleepTonightPicks(band: b.id);
        expect([for (final c in picks) c.name], _tonight[b.id], reason: b.id);
        expect(picks.last.surfaceId, 'pp_sleep_sounds', reason: '${b.id}: the tanpura, last');
        for (final c in picks) {
          if (c.pageId case final id?) {
            expect(_page(id).inBand(b.id), isTrue, reason: '${b.id}: $id is for this age');
          } else {
            expect(ppSurfaceUnavailable(c.surfaceId!), isNull, reason: c.name);
            expect(ppScreenForSurface(c.surfaceId!), isNotNull, reason: c.name);
          }
        }
      }
      // "Screens off, story on" is Early Learning's bedtime tales, which exist.
      final el = ppSectionFor('parenting_early_learning')!;
      expect(el.areas.any((a) => a.id == 'bedtime_tales'), isTrue);
    });

    test('SL1: Tonight draws on the tab her age opens, and nowhere else', () {
      for (final b in kPpSleepBands.bands) {
        final hosts = [
          for (final t in door.tabs)
            if (t.inlineSurfaceId case final id? when ppSleepShelfShows(id, band: b.id)) t.id,
        ];
        expect(hosts, [door.tabOrder[b.id]!.first], reason: b.id);
      }
    });

    test('SL2: the toddler band split at two, the same split as Potty', () {
      expect([for (final b in kPpSleepBands.bands) b.id], ['nb', 'm3_6', 'm6_12', 'tod_1_2', 'tod_2_3', 'pre']);
      expect(kPpSleepBands.bandFor(13).id, 'tod_1_2');
      expect(kPpSleepBands.bandFor(35).id, 'tod_2_3');
      for (final p in _sleep.allPages) {
        expect(p.bands, isNot(contains('tod')), reason: '${p.id} names a band that is gone');
      }
    });

    test('SL2: the first-year pages are tagged, and no toddler sees infant safe sleep', () {
      for (final id in [..._infantSafeSleep, 'gentle_settling', 'malish', 'feeding_to_sleep', 'at_3am', 'jhula_safety']) {
        expect(_page(id).bands.toSet().difference({'nb', 'm3_6', 'm6_12'}), isEmpty, reason: id);
        expect(_page(id).bands, isNotEmpty, reason: '$id is for every age again');
      }
      expect(_page('sleep_training_stance').bands, ['m6_12', 'tod_1_2', 'tod_2_3', 'pre']);
      for (final b in ['tod_1_2', 'tod_2_3', 'pre']) {
        final safe = _area('safe_sleep').pagesFor(b).map((p) => p.id).toList();
        for (final id in _infantSafeSleep) {
          expect(safe, isNot(contains(id)), reason: '$b sees $id');
        }
        expect(safe, containsAll(['safe_sleep_after_one', 'hot_nights']), reason: b);
        expect(_area('getting_to_sleep').pagesFor(b).map((p) => p.id), isNot(contains('malish')), reason: b);
      }
      // A newborn's safe-sleep tab is the infant pages, not the toddler one.
      expect(_area('safe_sleep').pagesFor('nb').map((p) => p.id), isNot(contains('safe_sleep_after_one')));
    });

    test('SL3: the tracker\'s numbers are the door\'s own chart, at every month to five', () {
      for (var m = 0; m < 72; m++) {
        _ageMonths(m);
        final band = kPpSleepBands.active.id;
        final chart = _area('how_much').pagesFor(band).singleWhere((p) => p.title == 'Sleep at this age');
        final card = chart.blocks.whereType<PpChartCard>().single;
        final (_, total) = card.rows.firstWhere((r) => r.$1 == 'Total sleep in 24 hours');
        final ctx = SleepStore.instance.ageContext;
        expect(_range(ctx.totalLabel), _range(total), reason: 'month $m: tracker "${ctx.totalLabel}", chart "$total"');
      }
      // The numbers the plan names.
      _ageMonths(14);
      expect(SleepStore.instance.ageContext.totalLabel, '11–14h');
      expect(SleepStore.instance.ageContext.napsLabel, '1–2 naps');
      _ageMonths(48);
      expect(SleepStore.instance.ageContext.totalLabel, '10–13h');
    });

    test('SL4: the tanpura first, lori named, and an honest word on the rest', () {
      expect(kPpLiveSoundTracks.map((t) => t.id), ['raga_tanpura']);
      expect(kPpSoundCategories.first.label, 'Lullabies and lori');
      expect(_area('music').title.toLowerCase(), contains('lori'));
      expect(ppSoundNotYetLine('lori'), 'This lullaby is still being recorded. The tanpura plays now.');
      expect(ppSoundNotYetLine('stories'), startsWith('This story'));
      // Every link and row that offers sounds names the tanpura first.
      final offers = <(String, String)>[
        for (final p in _sleep.allPages)
          for (final l in p.blocks.whereType<PpLink>())
            if (l.surfaceId == 'pp_sleep_sounds') ('${p.id}: ${l.label}', '${l.label} ${l.blurb ?? ''}'),
        for (final t in _sleep.tools) if (t.surfaceId == 'pp_sleep_sounds') ('section tool', t.blurb),
        for (final dt in door.tabs)
          for (final t in dt.tools) if (t.surfaceId == 'pp_sleep_sounds') ('door tool', t.blurb),
      ];
      expect(offers, isNotEmpty);
      for (final (where, words) in offers) {
        expect(words.toLowerCase(), contains('tanpura'), reason: where);
      }
    });

    testWidgets('SL4: the player leads with what plays, and a silent track says why', (tester) async {
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: PpSoundsScreen()));
      await tester.pumpAndSettle();
      final now = tester.getTopLeft(find.text('Plays now')).dy;
      final lori = tester.getTopLeft(find.text('Lullabies and lori')).dy;
      expect(now, lessThan(lori), reason: 'what plays comes first');
      await tester.tap(find.text('Chanda Mama'));
      await tester.pump();
      expect(find.text('This lullaby is still being recorded. The tanpura plays now.'), findsOneWidget);
      // The player arms its sleep timer on arrival, and the toast holds a
      // timer of its own; neither may outlive the test.
      PvToast.instance.dismiss();
      RagaAudioStore.instance.setSleepTimer(null);
      await tester.pumpAndSettle();
    });

    test('SL5: a thing to buy next to the step that needs it, one a page, never on the hard pages', () {
      final wanted = {
        'jhula_safety': 'pp_products/pvs_smart_cribs_and_bassinets',
        'swaddling': 'pp_products/pvs_muslin_swaddle_cloths',
        'overheating': 'pp_products/sleepwear_and_sacks',
        'does_music_help': 'pp_products/soothers_and_white_noise',
        'early_waking': 'pp_products/bedding_and_blackout',
        'safe_sleep_after_one': 'pp_products/Mosquito nets',
        'hot_nights': 'pp_products/Room thermometers',
        'night_fears': 'pp_products/Night lights',
      };
      final found = <String, String>{};
      for (final p in _sleep.allPages) {
        final shop = [
          for (final l in p.blocks.whereType<PpLink>())
            if ((l.surfaceId ?? '').startsWith('pp_products')) l.surfaceId!,
        ];
        expect(shop.length, lessThanOrEqualTo(1), reason: '${p.id}: one a page');
        if (shop.isNotEmpty) found[p.id] = shop.single;
        for (final s in shop) {
          expect(s.toLowerCase(), isNot(matches(RegExp('nest|swing|bouncer'))),
              reason: '${p.id}: never a nest, swing or bouncer for sleep');
        }
      }
      expect(found, wanted);
      for (final id in ['sids_calmly', 'safer_bed_sharing', 'waking_doctor', 'sick_or_head_bump']) {
        expect(found.containsKey(id), isFalse, reason: '$id sells nothing');
      }
      // Stocked shelves open; the three we don't stock say so, with a tip.
      for (final id in ['jhula_safety', 'swaddling', 'overheating', 'does_music_help', 'early_waking']) {
        expect(ppSurfaceUnavailable(wanted[id]!), isNull, reason: '${wanted[id]} is stocked');
      }
      expect(ppSurfaceUnavailable('pp_products/Night lights'), contains('dim, warm'));
      expect(ppSurfaceUnavailable('pp_products/Room thermometers'), contains("haven't picked"));
      expect(ppSurfaceUnavailable('pp_products/Mosquito nets'), contains('chemist'));
    });

    test('SL6: a sleep expert on Waking, and the three courses on their pages', () {
      final e = tab('waking').expert!;
      expect(e.surfaceId, 'pp_experts/Sleep expert');
      expect('${e.label} ${e.blurb}', allOf(contains('sleep expert'), contains('Nights wearing you down')));
      expect(ppSurfaceUnavailable(e.surfaceId), isNull);
      expect(ppScreenForSurface(e.surfaceId), isNotNull);
      for (final t in door.tabs.where((t) => t.id != 'waking')) {
        expect(t.expert, isNull, reason: '${t.id}: one row, next to the worry');
      }
      for (final (page, course) in [
        ('regression_4m', 'mc_sleepreg'),
        ('sleep_training_stance', 'rc_sleep'),
        ('what_is_regression', 'co_sleep'),
      ]) {
        final id = 'pp_learn/$course';
        expect(_links(page).map((l) => l.surfaceId), contains(id), reason: page);
        expect(ppSurfaceUnavailable(id), isNull, reason: '$course exists');
        expect(ppScreenForSurface(id), isNotNull, reason: course);
      }
    });

    test('SL7: the three new pages, in place, with their doctor line and review mark', () {
      expect(_page('jhula_safety').bands, ['nb', 'm3_6', 'm6_12']);
      expect(_page('safe_sleep_after_one').bands, ['tod_1_2', 'tod_2_3', 'pre']);
      expect(_page('hot_nights').bands, isEmpty, reason: 'every age');
      for (final id in ['jhula_safety', 'hot_nights']) {
        expect(_page(id).blocks.whereType<PpCallout>().any((c) => c.kind == PpCalloutKind.doctor), isTrue, reason: id);
      }
      final src = _src('lib/screens/post_pregnancy/pp_sleep_content.dart');
      for (final id in ['jhula_safety', 'safe_sleep_after_one', 'hot_nights', 'sick_or_head_bump']) {
        final at = src.indexOf("id: '$id'");
        final note = src.lastIndexOf('REQUIRED_REVIEW', at);
        expect(note, greaterThan(src.lastIndexOf('PpPage(', at - 1) - 900), reason: '$id carries its review mark');
      }
      // Nests and swings named as not for sleep.
      final items = _page('sleep_surface').blocks.whereType<PpInteractive>().single.items;
      expect(items.any((i) => (i.detail ?? '').contains('are not for sleep')), isTrue);
      // The thin page, rewritten (was about 630 characters).
      final talk = [for (final s in _page('sleep_talk_walk').blocks.expand(_strings)) s].join(' ');
      expect(talk.length, greaterThan(800), reason: 'it was about 630');
    });

    test('SL7: links land on the page they name', () {
      final health = ppSectionFor('parenting_health')!;
      final feeding = ppSectionFor('parenting_feeding')!;
      final first40 = ppSectionFor('parenting_first_40')!;
      for (final (page, target) in [
        ('feeding_to_sleep', 'pp_page/parenting_feeding/bf_how_often'),
        ('sids_calmly', 'pp_page/parenting_health/health_go_now'),
        ('noisy_breathing', 'pp_page/parenting_health/ill_throat'),
        ('swaddling', 'pp_page/parenting_first_40/f40_swaddle'),
        ('malish', 'pp_page/parenting_first_40/f40_malish'),
        ('day_night_confusion', 'pp_page/parenting_first_40/f40_day_night'),
      ]) {
        expect(_links(page).map((l) => l.surfaceId), contains(target), reason: page);
        expect(ppScreenForSurface(target), isNotNull, reason: target);
      }
      for (final p in _sleep.allPages) {
        for (final l in p.blocks.whereType<PpLink>()) {
          expect(l.surfaceId, isNot(anyOf('pp_section/parenting_health', 'pp_section/parenting_feeding')),
              reason: '${p.id}: a whole section is not a page');
        }
      }
      expect(feeding.pageById('bf_how_often'), isNotNull);
      expect(health.pageById('health_go_now'), isNotNull);
      // Health's "gentle settling" opens the page, not Sleep's first tab.
      final healthLinks = [
        for (final p in health.allPages)
          for (final l in p.blocks.whereType<PpLink>())
            if (l.label == 'Gentle settling, in more detail') l.surfaceId,
      ];
      expect(healthLinks, ['pp_page/parenting_sleep/gentle_settling']);
      // First 40 still links the three Sleep pages it named (ids kept).
      final f40 = _src('lib/screens/post_pregnancy/pp_first40_content.dart');
      for (final id in ['back_to_sleep', 'swaddling', 'malish']) {
        expect(f40, contains('pp_page/parenting_sleep/$id'));
        expect(_sleep.pageById(id), isNotNull, reason: '$id is still there');
      }
      expect(first40.pageById('f40_swaddle'), isNotNull);
    });

    test('SL8: the eleven film slots stay; the intro waits for its film (S4)', () {
      final slots = {
        for (final p in _sleep.allPages)
          for (final v in p.blocks.whereType<PpVideoSlot>()) v.slotId,
      };
      expect(slots.where((s) => s.startsWith('sleep/')), hasLength(11));
      expect(slots, isNot(contains('sleep/door_intro')));
    });

    test('SL10: sick nights and head bumps, the go-now list first, and the side named', () {
      final p = _page('sick_or_head_bump');
      expect(p.title, "When he's sick, or after a bump on the head");
      expect(p.bands, ['m6_12', 'tod_1_2', 'tod_2_3', 'pre']);
      expect(p.pinned, isTrue, reason: 'never sinks (S10)');
      expect(ppIsRedFlagPage(p), isTrue);
      // Oriented first (every page opens with an intro), then the list.
      expect(p.blocks.first, isA<PpIntro>());
      final first = p.blocks[1] as PpCallout;
      expect(first.kind, PpCalloutKind.doctor);
      expect(first.title, contains('Call 112'));
      expect(_links('sick_or_head_bump').map((l) => l.surfaceId), containsAll([
        'pp_page/parenting_safety/safety_falls',
        'pp_page/parenting_health/ill_head_bump',
        'pp_section/parenting_health/fever',
      ]));
      for (final l in _links('sick_or_head_bump')) {
        expect(ppScreenForSurface(l.surfaceId!), isNotNull, reason: l.surfaceId);
      }
      expect(p.blocks.whereType<PpConsult>(), isEmpty, reason: 'nothing sold on a go-now page');
      final intro = _page('back_to_sleep').blocks.whereType<PpIntro>().first.text;
      expect(intro, startsWith('On the back, for every sleep, day and night. Not on the side'));
    });
  });

  group('door 7: on screen', () {
    Future<void> pump(WidgetTester t, int months, {String? tab, List<String>? opened}) async {
      _ageMonths(months);
      t.view.physicalSize = const Size(1200, 9000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
          home: PpDoorScreen(
              key: ValueKey('sleep_${months}_$tab'),
              door: door,
              initialTabId: tab,
              onSurface: (_, id) => opened?.add(id))));
      await t.pumpAndSettle();
    }

    testWidgets('every age opens on its tab, on Tonight, each card once', (t) async {
      for (final MapEntry(key: m, value: opens) in _opens.entries) {
        await pump(t, m);
        final band = kPpSleepBands.active.id;
        expect(find.descendant(of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(tab(opens).label)),
            findsOneWidget, reason: '$m months opens on $opens');
        expect(find.byKey(const ValueKey('pp_sleep_tonight_shelf')), findsOneWidget, reason: '$m');
        expect(find.text('Tonight'), findsOneWidget, reason: '$m');
        for (final c in ppSleepTonightPicks()) {
          expect(find.text(c.name), findsOneWidget, reason: '$m: ${c.name}');
          // Never drawn twice on one tab: the rails skip the row's pages.
          if (c.pageId case final id? when tab(opens).areaIds.contains(_sleep.areas.firstWhere((a) => a.pages.any((p) => p.id == id)).id)) {
            expect(find.text(_page(id).title), findsNothing, reason: '$m: $id is on the row, not the rail too');
          }
        }
        expect(_tonight[band], isNotNull);
        expect(t.takeException(), isNull);
      }
    });

    testWidgets('a toddler\'s Safe sleep tab is the toddler pages, not SIDS', (t) async {
      await pump(t, 18, tab: 'safe');
      expect(find.text('Safe sleep after one'), findsOneWidget);
      expect(find.text('Hot nights and power cuts'), findsOneWidget);
      expect(find.text('SIDS, explained calmly'), findsNothing);
      expect(find.text('On the back, every sleep'), findsNothing);
      expect(find.byKey(const ValueKey('pp_sleep_tonight_shelf')), findsNothing, reason: 'not the opening tab');
    });

    testWidgets('Waking: the red flag, then the rail, then the sleep expert', (t) async {
      final opened = <String>[];
      await pump(t, 8, tab: 'waking', opened: opened);
      final row = find.byKey(const ValueKey('pp_door_tab_expert'));
      expect(row, findsOneWidget);
      expect(find.text('When he\'s sick, or after a bump on the head'), findsWidgets);
      await t.ensureVisible(row);
      await t.tap(row);
      await t.pumpAndSettle();
      expect(opened, ['pp_experts/Sleep expert']);
    });

    testWidgets('a Tonight card opens its page; the tanpura opens the player', (t) async {
      final opened = <String>[];
      await pump(t, 30, opened: opened);
      await t.tap(find.byKey(const ValueKey('pp_sleep_tonight_card_pp_sleep_sounds')));
      await t.pumpAndSettle();
      expect(opened, ['pp_sleep_sounds']);
      await t.tap(find.byKey(const ValueKey('pp_sleep_tonight_card_bedtime_routine')));
      await t.pumpAndSettle();
      expect(find.byType(PpDoorScreen), findsNothing, reason: 'the reader is on top');
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
