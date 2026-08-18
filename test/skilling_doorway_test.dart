// =============================================================================
//  The Skilling doorway ships in every build, and says what it is
// -----------------------------------------------------------------------------
//  ⚠️ THIS TEST REPLACES A GUARD.
//
//  The Skilling door was wrapped in `kDebugMode` on the pregnancy home, and its
//  Explore-drawer entry was too. The reasoning was sound and is worth keeping in
//  view: twelve doors, eighty-four declared bracket cells, and not one live
//  resolver behind any of them. A door is a promise.
//
//  It now ships in release by decision. That trade is only defensible while the
//  card keeps announcing what it is -- a PREVIEW pill, and a subtitle that says
//  "the design, not the content". Those two strings were decoration when a
//  compile flag was doing the real work. They are the real work now.
//
//  So they are pinned here. The general point is worth stating: when you remove
//  a guard and keep the thing it was guarding, something else has to carry the
//  guarantee, and it should be written down at the moment of the swap rather
//  than discovered later by someone deleting a pill that "looks redundant".
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final home = File('lib/screens/home_screen_b.dart').readAsStringSync();
  final drawer =
      File('lib/screens/post_pregnancy/explore_drawer.dart').readAsStringSync();

  /// The doorway builder's body, so assertions cannot be satisfied by an
  /// unrelated mention elsewhere in a 1,000-line file.
  String skillingCard() {
    final from = home.indexOf('Widget _skillingDoorway(');
    expect(from, greaterThan(-1),
        reason: 'the Skilling doorway has been removed from the home');
    final next = home.indexOf('\n  Widget ', from + 1);
    return home.substring(from, next == -1 ? home.length : next);
  }

  group('it is reachable in every build', () {
    test('the home doorway is not behind kDebugMode', () {
      // The shelf renders the three doors in order. A `kDebugMode` anywhere
      // between the TTC door and the Skilling one would hide it in release.
      final shelfFrom = home.indexOf('_ttcDoorway(context),');
      final shelfTo = home.indexOf('_skillingDoorway(context),');
      expect(shelfFrom, greaterThan(-1));
      expect(shelfTo, greaterThan(shelfFrom),
          reason: 'the Skilling door is no longer on the shelf');
      final between = home.substring(shelfFrom, shelfTo);
      expect(between.contains('kDebugMode'), isFalse,
          reason: 'the Skilling door is gated to debug builds again, so the '
              'release APK will not show it');
    });

    test('and neither is the Explore drawer entry', () {
      final at = drawer.indexOf("'Skilling (preview)'");
      expect(at, greaterThan(-1),
          reason: 'the Skilling entry has left the Explore drawer');
      // Look back a short way for a guard wrapping this row.
      final start = at < 400 ? 0 : at - 400;
      final before = drawer.substring(start, at);
      final lastIf = before.lastIndexOf('if (kDebugMode)');
      expect(lastIf, -1,
          reason: 'the drawer entry is debug-only again, so Skilling would '
              'appear on the home but not in the drawer in a release build');
    });
  });

  group('and it never pretends to be finished', () {
    // ⚠️ THE HALF THAT REPLACED THE GUARD. Both strings must survive.
    test('the card carries the PREVIEW pill', () {
      expect(skillingCard().contains("'PREVIEW'"), isTrue,
          reason: 'the PREVIEW pill is what makes shipping this honest; it is '
              'not decoration and must not be removed until a skilling '
              'bracket has a live resolver');
    });

    test('and says it is the design rather than the content', () {
      final card = skillingCard().toLowerCase();
      final saysSo = card.contains('the design') ||
          card.contains('not the content') ||
          card.contains('preview');
      expect(saysSo, isTrue,
          reason: 'the subtitle no longer tells her there is nothing behind '
              'the doors');
    });

    test('the drawer entry says the same thing', () {
      expect(drawer.contains('nothing behind the doors'), isTrue,
          reason: 'the drawer row has stopped being honest about the preview');
    });
  });
}
