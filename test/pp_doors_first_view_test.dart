// What a parent sees first, on every parenting door, at every age (step 0 ·
// S7, 2026-10-25; GLOBAL-CHANGES #15 for parenting).
//
// The shell rules every door plan stands on, held once here:
//   * S9  no tab is ever locked. A tab for a later age sits last, says
//         "For later" on its card, and opens on its own pages.
//   * S1  a door's `tabOrder` for her band decides where she lands; without
//         one the door's own order stands.
//   * S11 the rail never overflows, at normal text and at 1.5x, on a 360dp
//         phone, because the card grows instead of cutting the name.
//   * S10 a red-flag list she has read is still first in its rail.
//   * S8a a film or a recording not made yet answers a tap.
//   * S3  a door with a closing draws its consult card; one without ends on
//         the doctor sentence.
//   * S6  parenting words reach the course that fits, and a page with its
//         own consult gets no second pitch.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/models/pv_read.dart' show PvNextKind;
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_page_read.dart' show ppPageAsRead;
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart'
    show ppScreenForSurface, ppSurfaceUnavailable;
import 'package:parentveda/screens/products/pv_shelf_screen.dart' show PvShelfScreen;
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/services/pv_read_store.dart';
import 'package:parentveda/widgets/pv_placeholders.dart';

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

Future<void> _pump(WidgetTester t, PpDoor door, int months,
    {double scale = 1.0}) async {
  t.view.physicalSize = const Size(360, 780);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  _ageMonths(months);
  await t.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: PpDoorScreen(
        key: ValueKey('${door.sectionId}_${months}_$scale'),
        door: door,
        onSurface: (_, _) {}),
  ));
  await t.pumpAndSettle();
}

/// One age inside each band of the door's section: its start, a little in.
List<int> _ages(PpDoor door) {
  final set = ppSectionFor(door.sectionId)!.bandSet;
  if (set == null) return const [6];
  return {for (final b in set.bands) b.fromMonths + (b.fromMonths == 0 ? 1 : 0)}
      .toList();
}

Finder _firstCardSays(String label) => find.descendant(
    of: find.byKey(pvDoorRailCardKey(0)), matching: find.text(label));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('every door, every age', () {
    for (final door in kPpDoors) {
      testWidgets('${door.sectionId}: no lock, no overflow at 1x and 1.5x',
          (t) async {
        for (final months in _ages(door)) {
          for (final scale in [1.0, 1.5]) {
            await _pump(t, door, months, scale: scale);
            expect(find.byIcon(Icons.lock_outline_rounded), findsNothing,
                reason: '${door.sectionId} at $months months: no tab locks (S9)');
            expect(t.takeException(), isNull,
                reason: '${door.sectionId} at $months months, ${scale}x');
          }
        }
      });
    }
  });

  testWidgets('a door with a closing draws the consult card; one without ends on the sentence (S3)', (t) async {
    final withClosing = kPpDoors.firstWhere((d) => d.closing != null);
    await _pump(t, withClosing, 6);
    expect(find.byKey(const ValueKey('pp_door_closing_card')), findsOneWidget);
    expect(find.text(withClosing.closing!.label), findsOneWidget);
    final without =
        kPpDoors.firstWhere((d) => d.closing == null && d.closingLine == null);
    await _pump(t, without, 6);
    expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
    expect(find.byKey(const ValueKey('pp_door_closing_line')), findsOneWidget);
  });

  testWidgets('a door\'s tabOrder for her band picks where she lands (S1)', (t) async {
    // Family's last tab, named first for every band, opens first.
    final family = kPpDoors.firstWhere((d) => d.sectionId == 'parenting_family');
    final set = ppSectionFor(family.sectionId)!.bandSet!;
    final last = family.tabs.last;
    final door = PpDoor(
      sectionId: family.sectionId,
      tabs: family.tabs,
      tabOrder: {
        for (final b in set.bands) b.id: [last.id],
      },
    );
    await _pump(t, door, 30);
    expect(_firstCardSays(last.label), findsOneWidget,
        reason: 'the first card is the tab the order names');
    // Without an order, the door's own order stands.
    await _pump(t, family, 30);
    expect(_firstCardSays(family.tabs.first.label), findsOneWidget);
  });

  test('a red-flag list she has read stays first in its rail (S10)', () {
    PvReadStore.instance.setProgress('read_flag', 1.0);
    final items = ['Go now', 'Bedtime', 'Naps'];
    final out = ppRelevanceOrder(items,
        situation: const PpSituation(ageMonths: 7, daysOld: 210),
        text: (x) => x,
        readId: (x) => x == 'Go now' ? 'read_flag' : null,
        alwaysFirst: (x) => x == 'Go now');
    expect(out.first, 'Go now');
    // Without the exemption it sinks, as any finished read does.
    final sunk = ppRelevanceOrder(items,
        situation: const PpSituation(ageMonths: 7, daysOld: 210),
        text: (x) => x,
        readId: (x) => x == 'Go now' ? 'read_flag' : null);
    expect(sunk.last, 'Go now');
  });

  test('every RED FLAG and FLAGGED page counts as a red flag (S10)', () {
    for (final door in kPpDoors) {
      for (final page in ppSectionFor(door.sectionId)!.allPages) {
        final f = (page.format ?? '').toUpperCase();
        if (f == 'RED FLAG' || f == 'FLAGGED') {
          expect(ppIsRedFlagPage(page), isTrue, reason: page.id);
        }
      }
    }
  });

  testWidgets('a film not made yet answers a tap and still does not press (S8a)', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
          body: Center(
              child: SizedBox(
                  width: 320,
                  child: PvVideoPlaceholder(title: 'Burping, shown')))),
    ));
    await t.tap(find.byType(PvVideoPlaceholder));
    await t.pump();
    expect(find.text(kPvFilmPendingNote), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
  });

  testWidgets('a recording not made yet answers a tap (S8a)', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(body: PvAudioPlaceholder(title: 'Lori')),
    ));
    await t.tap(find.byType(PvAudioPlaceholder));
    await t.pump();
    expect(find.text(kPvAudioPendingNote), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
  });

  test('a parenting page with its own consult gets no second pitch (S6)', () {
    final sleep = ppSectionFor('parenting_sleep')!;
    final withConsult =
        sleep.allPages.firstWhere((p) => p.blocks.any((b) => b is PpConsult));
    final read = ppPageAsRead(sleep, withConsult);
    expect(read.nextSteps.any((n) => n.kind == PvNextKind.consult), isTrue);
    expect(pvReadOfferFor(read), isNull, reason: withConsult.id);
  });

  test('parenting words reach the course that fits (S6)', () {
    final sleep = ppSectionFor('parenting_sleep')!;
    final naps = sleep.allPages.firstWhere((p) =>
        p.title.toLowerCase().contains('nap') &&
        !p.blocks.any((b) => b is PpConsult));
    expect(pvReadOfferFor(ppPageAsRead(sleep, naps))?.title.toLowerCase(),
        contains('sleep'),
        reason: naps.title);
  });

  group('no silent tap: the one opener says why (S8)', () {
    test('an expert type we have opens; one we don\'t names the nearest (S8b)', () {
      expect(ppSurfaceUnavailable('pp_experts/Pediatrician'), isNull);
      expect(ppSurfaceUnavailable('pp_experts/Lactation expert'), isNull);
      expect(ppSurfaceUnavailable('pp_experts/Audiologist'),
          allOf(contains('audiologists'), contains('paediatrician')));
      expect(ppSurfaceUnavailable('pp_experts/Feeding therapist'),
          contains('speech therapist'));
    });

    test('a stocked shelf opens; an unstocked one says we are still choosing (S8c)', () {
      final stocked = PvCatalogStore.instance.all
          .firstWhere((p) => p.subId != null && p.subId!.isNotEmpty);
      expect(ppSurfaceUnavailable('pp_products/${stocked.subId}'), isNull);
      expect(ppScreenForSurface('pp_products/${stocked.subId}'), isA<PvShelfScreen>());
      expect(ppSurfaceUnavailable('pp_products/Moon boots for babies'),
          contains('still choosing'));
    });

    test('a class that is not open says so (S8d), and anything unknown is never silent', () {
      expect(ppSurfaceUnavailable('pp_class/Baby first aid'), contains("isn't open yet"));
      expect(ppSurfaceUnavailable('pp_nothing_here'), contains("isn't ready yet"));
    });

    test('every door tool and closing opens a real screen today (wiring gate)', () {
      final missing = <String>[
        for (final door in kPpDoors) ...[
          for (final tab in door.tabs)
            for (final tool in tab.tools)
              if (ppSurfaceUnavailable(tool.surfaceId) != null)
                '${door.sectionId}/${tab.id}: ${tool.surfaceId}',
          if (door.closing case final c?)
            if (ppSurfaceUnavailable(c.surfaceId) != null)
              '${door.sectionId} closing: ${c.surfaceId}',
        ],
      ];
      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('no parenting opener is silent any more', () {
      for (final f in [
        'lib/screens/post_pregnancy/pp_search.dart',
        'lib/screens/post_pregnancy/pp_home_v3.dart',
        'lib/screens/post_pregnancy/pp_tools_tab.dart',
        'lib/screens/post_pregnancy/pp_wake_windows_screen.dart',
        'lib/screens/post_pregnancy/pp_what_to_feed_screen.dart',
      ]) {
        final live = File(f)
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live.contains('if (screen == null) return;'), isFalse, reason: f);
      }
    });
  });

  test('the rail card grows with the text size, never below its design (S11)', () {
    expect(PvDoorRail.heightFor(TextScaler.noScaling), PvDoorRail.cardHeight);
    expect(PvDoorRail.heightFor(const TextScaler.linear(1.5)),
        greaterThan(PvDoorRail.cardHeight));
    expect(PvDoorRail.heightFor(const TextScaler.linear(1.5), withLine: true),
        greaterThan(PvDoorRail.heightFor(const TextScaler.linear(1.5))));
  });
}
