// =============================================================================
//  PvLiveSearch — the search bar's flow, shared by every door
// -----------------------------------------------------------------------------
//  Built on Is it safe? and lifted out on 2026-09-20 at the user's ask:
//  "create this flow as a template so it can be reused for every door
//  wherever the search bar is." These tests hold the three states and the
//  two consumers, so a door that grows its own field again fails here.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/doors/pv_live_search.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void main() {
  group('the three states', () {
    test('idle → recalling on focus → searching on text → idle on release', () {
      final s = PvLiveSearch();
      expect(s.idle, isTrue);
      expect(s.recalling, isFalse);
      expect(s.searching, isFalse);

      s.ctl.text = 'nt';
      expect(s.searching, isTrue);
      expect(s.recalling, isFalse);
      expect(s.idle, isFalse);
      expect(s.query, 'nt');

      s.ctl.text = '   ';
      expect(s.searching, isFalse, reason: 'whitespace is not a query');

      s.run('scan');
      expect(s.query, 'scan');
      expect(s.ctl.selection.baseOffset, 4, reason: 'the caret sits after the words');

      s.release();
      expect(s.query, isEmpty);
      expect(s.idle, isTrue);
      s.dispose();
    });

    test('a listener hears the text change', () {
      final s = PvLiveSearch();
      var n = 0;
      s.addListener(() => n++);
      s.ctl.text = 'a';
      expect(n, 1);
      s.dispose();
    });
  });

  group('Back, twice', () {
    testWidgets('the scope refuses the pop while searching, and releases the field', (tester) async {
      final s = PvLiveSearch();
      addTearDown(s.dispose);
      await tester.pumpWidget(MaterialApp(
        home: PvLiveSearchScope(search: s, child: const Scaffold(body: SizedBox())),
      ));
      s.ctl.text = 'papaya';
      await tester.pump();
      final scope = tester.widget<PopScope>(find.byWidgetPredicate((w) => w is PopScope));
      expect(scope.canPop, isFalse, reason: 'the first Back stays on the page');
      scope.onPopInvokedWithResult!(false, null);
      expect(s.idle, isTrue, reason: 'and returns the page to idle');
    });
  });

  group('the pinned bar (2026-10-10)', () {
    Future<(PvLiveSearch, ScrollController)> pump(WidgetTester tester) async {
      final s = PvLiveSearch();
      final c = ScrollController();
      addTearDown(s.dispose);
      addTearDown(c.dispose);
      final p = V2PaletteStore.instance.current;
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
              size: Size(400, 800), padding: EdgeInsets.only(top: 30)),
          child: PvLiveSearchScope(
            search: s,
            child: Scaffold(
              body: Stack(children: [
                ListView(controller: c, padding: EdgeInsets.zero, children: [
                  const SizedBox(height: 260),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PvLiveSearchField(
                        key: const ValueKey('hero-field'),
                        search: s,
                        p: p,
                        hint: 'Search Food'),
                  ),
                  const SizedBox(height: 2000),
                ]),
                PvDoorPinnedBar(controller: c, search: s, p: p, title: 'Food'),
              ]),
            ),
          ),
        ),
      ));
      await tester.pump();
      return (s, c);
    }

    testWidgets('focus moves the one field onto a solid band under the status bar',
        (tester) async {
      final (s, c) = await pump(tester);
      final bar = find.byType(PvDoorPinnedBar);
      expect(find.descendant(of: bar, matching: find.byType(TextField)), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(s.focus.hasFocus, isTrue, reason: 'the move keeps focus');
      final inBar = find.descendant(of: bar, matching: find.byType(TextField));
      expect(inBar, findsOneWidget, reason: 'the field rides in the bar');
      expect(find.byType(TextField), findsOneWidget, reason: 'one field, moved');
      expect(tester.getTopLeft(inBar.first).dy, greaterThanOrEqualTo(30 + 10),
          reason: 'clear of the status bar, not hugging it');
      expect(tester.getRect(find.byKey(s.fieldKey)).top, 40);
      expect(tester.getRect(find.byKey(s.fieldKey)).left, 20,
          reason: 'the hero gutters, so the slide is straight up');
      expect(c.offset, closeTo(260 - 40, 0.5),
          reason: 'the list brings the empty slot under the pinned field');

      await tester.enterText(inBar, 'iron');
      await tester.pump();
      expect(s.query, 'iron', reason: 'typing still reaches the search');

      s.release();
      await tester.pumpAndSettle();
      expect(find.descendant(of: bar, matching: find.byType(TextField)), findsNothing);
      expect(find.descendant(of: find.byKey(const ValueKey('hero-field')),
          matching: find.byType(TextField)), findsOneWidget,
          reason: 'released, the field is back in the hero');
      expect(c.offset, 0, reason: 'and the list is back where she was');
    });

    testWidgets('scrolled idle, the compact bar fades in with back and the name',
        (tester) async {
      final (_, c) = await pump(tester);
      double opacity() => tester
          .widget<Opacity>(find
              .descendant(of: find.byType(PvDoorPinnedBar), matching: find.byType(Opacity))
              .first)
          .opacity;
      expect(opacity(), 0);
      c.jumpTo(600);
      await tester.pump();
      await tester.pump();
      expect(opacity(), 1);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Search Food'), findsOneWidget);
    });
  });

  group('the consumers', () {
    String read(String p) => File(p).readAsStringSync();

    test('the door shell and Is it safe? both use the template, not fields of their own', () {
      for (final path in ['lib/screens/doors/pv_door_screen.dart', 'lib/screens/can_i/can_i_door.dart']) {
        final src = read(path);
        expect(src, contains('PvLiveSearch()'), reason: path);
        expect(src, contains('PvLiveSearchScope('), reason: path);
        expect(src, contains('PvLiveSearchWords('), reason: path);
        expect(src, contains('PvLiveSearchField('), reason: path);
        // No second FocusNode for a search field, no hand-rolled fade or PopScope.
        expect(src, isNot(contains('FocusNode()')), reason: '$path grew its own focus node');
        expect(src, isNot(contains('AnimatedOpacity(')), reason: '$path grew its own fade');
        expect(src, isNot(contains('PopScope(')), reason: '$path grew its own Back');
      }
    });

    test('the door searches its own index and hands "everywhere" to the search screen', () {
      final door = read('lib/screens/doors/pv_door_screen.dart');
      expect(door, contains('pvSearch(q, pvSearchIndexOf(page))'));
      expect(door, contains('PvSearchHitRow('));
      expect(door, contains("Search everywhere for"));
      expect(door, contains("Ask Veda about"));
      expect(door, contains('PvSearchStore.instance.recent'));
    });
  });
}
