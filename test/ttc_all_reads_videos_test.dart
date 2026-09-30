// =============================================================================
//  More's "Read and watch": All articles and All videos (2026-09-29)
// -----------------------------------------------------------------------------
//  The user: "In the More tab we also need a separate section for all the
//  videos… if someone wants to read all the articles or watch all the videos,
//  that section should also be made."
//
//  What this file holds:
//    1. More shows the section, and both rows land on their pages by route.
//    2. The article count is `kTtcReads`, less the intimacy reads while the
//       shared-phone switch is on, on More and on the page.
//    3. Search and a topic chip narrow the list; the sort orders it.
//    4. Every video row is honest: no play glyph on a film that is not made,
//       a clock and "Coming soon" instead, and the page says films are being
//       made while none is.
//    5. Nothing twice: every read once, every film once.
//    6. Nothing overflows at 360dp, at 1x and 1.5x text.
//    7. A read opens in the one reader on `ttc_read/<id>`; a film opens the
//       sheet its door tile opens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_all_reads_screen.dart';
import 'package:parentveda/screens/ttc/ttc_all_videos_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart' show kTtcShelfFilmPreview;

const _more = TtcMoreTab(bottomNav: TtcBottomNav(active: 4, v3: true));

class _Names extends NavigatorObserver {
  _Names(this.onName);
  final void Function(String?) onName;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onName(route.settings.name);
}

Key _readRow(String id) => ValueKey('ttc_all_reads_row_$id');
Key _filmRow(String id) => ValueKey('ttc_all_videos_row_$id');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcContentPrefs.instance.resetForTest();
    await TtcContentPrefs.instance.init();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
  });
  tearDown(() {
    TtcPartnerMode.instance.on = false;
    TtcContentPrefs.instance.resetForTest();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double width = 392,
    double height = 20000,
    double textScale = 1.0,
    List<NavigatorObserver> observers = const [],
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      key: UniqueKey(),
      navigatorObservers: observers,
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: w!,
      ),
      home: child,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  int intimateReads() =>
      kTtcReads.where((r) => kTtcIntimateReadIds.contains(r.id)).length;

  // ===========================================================================
  group('1. More: the section and its two rows', () {
    // Your journey left More on 2026-09-30; Benefits follows now.
    testWidgets('Read and watch sits after Groups, before Your journey',
        (tester) async {
      await pump(tester, _more);
      expect(tester.takeException(), isNull);
      final y = [
        kTtcMoreGroupsHeading,
        kTtcMoreReadWatchHeading,
        // Kept for revert (off More since 2026-09-30): kTtcMoreJourneyHeading,
        kTtcMoreBenefitsHeading,
      ].map((h) => tester.getTopLeft(find.text(h)).dy).toList();
      expect(y[0] < y[1] && y[1] < y[2], isTrue, reason: '$y');
      expect(find.byKey(const ValueKey('ttc_more_row_all_reads')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_more_row_all_videos')),
          findsOneWidget);
      // Our drawn marks, never a Material icon as row art.
      for (final id in ['all_reads', 'all_videos']) {
        expect(
            find.descendant(
                of: find.byKey(ValueKey('ttc_more_row_$id')),
                matching: find.byType(CustomPaint)),
            findsWidgets);
      }
    });

    testWidgets('both rows land on their pages, by route name',
        (tester) async {
      for (final (id, route, type) in [
        ('all_reads', kTtcAllReadsRoute, TtcAllReadsScreen),
        ('all_videos', kTtcAllVideosRoute, TtcAllVideosScreen),
      ]) {
        final names = <String?>[];
        await pump(tester, _more, observers: [_Names(names.add)]);
        names.clear();
        final row = find.byKey(ValueKey('ttc_more_row_$id'));
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pumpAndSettle();
        expect(names, [route], reason: id);
        expect(find.byType(type), findsOneWidget);
        // The way back is an arrow, and it returns to More.
        await tester.tap(find.byKey(TtcCatalogHeader.backKey));
        await tester.pumpAndSettle();
        expect(find.byType(type), findsNothing);
      }
    });

    test('the two routes are new and unique', () {
      expect(kTtcAllReadsRoute, 'ttc/all_reads');
      expect(kTtcAllVideosRoute, 'ttc/all_videos');
      expect(kTtcAllReadsRoute, isNot(kTtcAllVideosRoute));
    });
  });

  // ===========================================================================
  group('2. the article count', () {
    testWidgets('matches kTtcReads, on More and on the page', (tester) async {
      expect(ttcAllReadsCount(), kTtcReads.length);
      await pump(tester, _more);
      expect(find.text('${ttcArticlesLabel(kTtcReads.length)}, by topic'),
          findsOneWidget);
      await pump(tester, const TtcAllReadsScreen());
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('ttc_all_reads_count')))
              .data,
          ttcArticlesLabel(kTtcReads.length));
      for (final r in kTtcReads) {
        expect(find.byKey(_readRow(r.id)), findsOneWidget, reason: r.id);
      }
    });

    testWidgets('less the intimacy reads while the switch is on',
        (tester) async {
      expect(intimateReads(), greaterThan(0));
      await TtcContentPrefs.instance.setHideIntimate(true);
      final want = kTtcReads.length - intimateReads();
      expect(ttcAllReadsCount(), want);
      await pump(tester, _more);
      expect(find.text('${ttcArticlesLabel(want)}, by topic'), findsOneWidget);
      await pump(tester, const TtcAllReadsScreen());
      for (final id in kTtcIntimateReadIds) {
        expect(find.byKey(_readRow(id)), findsNothing, reason: id);
      }
      // Typing the word cannot bring a hidden read back.
      await tester.enterText(find.byType(TextField), 'lubricant');
      await tester.pump();
      for (final id in kTtcIntimateReadIds) {
        expect(find.byKey(_readRow(id)), findsNothing, reason: id);
      }
    });
  });

  // ===========================================================================
  group('3. search, a topic, and the sort', () {
    testWidgets('search narrows the list, best match first', (tester) async {
      await pump(tester, const TtcAllReadsScreen());
      await tester.enterText(find.byType(TextField), 'semen');
      await tester.pump();
      final shown = [
        for (final r in kTtcReads)
          if (find.byKey(_readRow(r.id)).evaluate().isNotEmpty) r,
      ];
      expect(shown, isNotEmpty);
      expect(shown.length, lessThan(kTtcReads.length));
      expect(find.byKey(const ValueKey('ttc_all_reads_sort')), findsNothing,
          reason: 'while she types the list is best match first');
      await tester.enterText(find.byType(TextField), 'zzqqxx');
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_all_reads_empty')), findsOneWidget);
    });

    testWidgets('a topic chip narrows to that door\'s reads', (tester) async {
      final topics = ttcAllReadTopics();
      final pcos = topics.firstWhere((t) => t.label == 'PCOS');
      await pump(tester, const TtcAllReadsScreen());
      await tester.tap(find.byKey(TtcCatalogChips.chipKey(pcos.key)));
      await tester.pump();
      for (final r in kTtcReads) {
        expect(find.byKey(_readRow(r.id)).evaluate().isNotEmpty,
            pcos.reads.contains(r),
            reason: r.id);
      }
      // And "All" brings everything back.
      await tester.tap(find.byKey(TtcCatalogChips.chipKey(null)));
      await tester.pump();
      expect(find.byKey(_readRow(kTtcReads.first.id)), findsOneWidget);
    });

    testWidgets('grouped by topic, or A to Z', (tester) async {
      await pump(tester, const TtcAllReadsScreen());
      final topics = ttcAllReadTopics();
      for (final t in topics) {
        expect(find.byKey(ValueKey('ttc_all_reads_group_${t.key}')),
            findsOneWidget);
      }
      await tester.tap(find.byKey(const ValueKey('ttc_all_reads_sort')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_all_reads_sort_az')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('ttc_all_reads_group_${topics.first.key}')),
          findsNothing);
      final sorted = [...kTtcReads]..sort((a, b) =>
          a.title.en.toLowerCase().compareTo(b.title.en.toLowerCase()));
      final y = [
        for (final r in sorted.take(6))
          tester.getTopLeft(find.byKey(_readRow(r.id))).dy,
      ];
      for (var i = 1; i < y.length; i++) {
        expect(y[i], greaterThan(y[i - 1]));
      }
    });

    testWidgets('his side: his door first, the same library', (tester) async {
      TtcPartnerMode.instance.on = true;
      final topics = ttcAllReadTopics();
      expect(topics.first.bracketId, 'ttc_male_fertility');
      expect([for (final t in topics) ...t.reads].length, kTtcReads.length);
      final films = ttcAllFilms();
      expect(films.first.door?.id, 'ttc_male_fertility');
    });
  });

  // ===========================================================================
  group('4. every video row is honest', () {
    testWidgets('no play glyph on a film that is not made', (tester) async {
      final films = ttcAllFilms();
      expect(films, isNotEmpty);
      await pump(tester, const TtcAllVideosScreen());
      expect(tester.takeException(), isNull);
      final noneLive = !films.any((f) => f.live);
      expect(find.byKey(const ValueKey('ttc_all_videos_being_made')),
          noneLive ? findsOneWidget : findsNothing);
      if (noneLive) expect(find.text(kTtcFilmsBeingMade), findsOneWidget);
      for (final f in films) {
        final row = find.byKey(_filmRow(f.slotId));
        expect(row, findsOneWidget, reason: f.slotId);
        final play = find.descendant(
            of: row, matching: find.byIcon(Icons.play_arrow_rounded));
        // ⚠️ THE PREVIEW (kTtcShelfFilmPreview, the user on build 23-24:
        // every film shows its play mark and a length, made or not, until
        // launch). While it is on, an unmade film looks like a made one.
        if (f.live || kTtcShelfFilmPreview) {
          expect(play, findsOneWidget, reason: f.slotId);
        } else {
          expect(play, findsNothing, reason: '${f.slotId} is not made');
          expect(
              find.descendant(
                  of: row, matching: find.byIcon(Icons.schedule_rounded)),
              findsOneWidget,
              reason: f.slotId);
          expect(find.descendant(of: row, matching: find.text('Coming soon')),
              findsOneWidget,
              reason: f.slotId);
        }
        // Its door is named in its caption.
        expect(
            find.descendant(
                of: row,
                matching: find.textContaining('${f.doorLabel} · ')),
            findsOneWidget,
            reason: f.slotId);
      }
    });

    testWidgets('the More line says how many, and that they are coming',
        (tester) async {
      final n = ttcAllFilms().length;
      expect(ttcAllVideosLine(), '$n videos, coming soon');
      await pump(tester, _more);
      expect(find.text('$n videos, coming soon'), findsOneWidget);
    });

    testWidgets('a film opens the sheet its door tile opens', (tester) async {
      final names = <String?>[];
      await pump(tester, const TtcAllVideosScreen(),
          observers: [_Names(names.add)]);
      final f = ttcAllFilms().first;
      names.clear();
      await tester.tap(find.byKey(_filmRow(f.slotId)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_film_coming_soon')), findsOneWidget);
    });

    testWidgets('search and a door chip narrow the films', (tester) async {
      final films = ttcAllFilms();
      await pump(tester, const TtcAllVideosScreen());
      await tester.enterText(find.byType(TextField), 'PCOS');
      await tester.pump();
      final shown = [
        for (final f in films)
          if (find.byKey(_filmRow(f.slotId)).evaluate().isNotEmpty) f,
      ];
      expect(shown, isNotEmpty);
      expect(shown.length, lessThan(films.length));
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      final door = films.first.door!;
      await tester.tap(find.byKey(TtcCatalogChips.chipKey(door.id)));
      await tester.pump();
      for (final f in films) {
        expect(find.byKey(_filmRow(f.slotId)).evaluate().isNotEmpty,
            f.door?.id == door.id,
            reason: f.slotId);
      }
    });
  });

  // ===========================================================================
  group('5. nothing twice', () {
    test('every read once, every film once', () {
      final ids = [for (final t in ttcAllReadTopics()) ...t.reads.map((r) => r.id)];
      expect(ids.toSet().length, ids.length);
      expect(ids.toSet(), {for (final r in kTtcReads) r.id});
      final slots = [for (final f in ttcAllFilms()) f.slotId];
      expect(slots.toSet().length, slots.length);
      // Every film slot the stage has is on the page.
      for (final v in kTtcVideos) {
        expect(slots, contains(v.id), reason: v.id);
      }
      final titles = [for (final f in ttcAllFilms()) f.tile.title];
      expect(titles.toSet().length, titles.length,
          reason: 'one film under two slots: $titles');
    });
  });

  // ===========================================================================
  group('6. it holds', () {
    for (final (w, scale) in [(360.0, 1.0), (360.0, 1.5)]) {
      testWidgets('${w.toInt()}dp at ${scale}x', (tester) async {
        await pump(tester, const TtcAllReadsScreen(),
            width: w, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'articles, by topic');
        await tester.tap(find.byKey(const ValueKey('ttc_all_reads_sort')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'the sort sheet');
        await tester.tap(find.byKey(const ValueKey('ttc_all_reads_sort_az')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'articles, A to Z');
        await pump(tester, const TtcAllVideosScreen(),
            width: w, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'videos');
        TtcPartnerMode.instance.on = true;
        await pump(tester, const TtcAllVideosScreen(),
            width: w, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'his videos');
        await pump(tester, _more, width: w, height: 6000, textScale: scale);
        expect(tester.takeException(), isNull, reason: 'his More');
      });
    }
  });

  // ===========================================================================
  group('7. where a read lands', () {
    testWidgets('the one reader, on ttc_read/<id>', (tester) async {
      final names = <String?>[];
      await pump(tester, const TtcAllReadsScreen(),
          observers: [_Names(names.add)]);
      final r = kTtcReads.first;
      names.clear();
      final row = find.byKey(_readRow(r.id));
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(names, ['ttc_read/${r.id}']);
      tester.takeException();
    });
  });
}
