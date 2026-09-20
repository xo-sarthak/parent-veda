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
