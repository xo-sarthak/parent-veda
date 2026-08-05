// =============================================================================
//  The 2026-08-04 refinement pass, pinned
// -----------------------------------------------------------------------------
//  A device walk of the parenting app and ParentVeda+ turned up a long list of
//  small wrongnesses. Most were cosmetic and need no test. These are the ones
//  that were RULES rather than pixels — where a plausible future edit would put
//  the bug straight back, and where the bug was invisible in code review because
//  the code looked perfectly reasonable.
//
//  Each test names the symptom, not the fix, so a failure explains itself.
//
//  See docs/REFINEMENT-PASS.md for the full list and for the items still held
//  for a decision.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/community_screen.dart'
    show ppMono;
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

/// Source of a lib file, for the reachability checks below.
String _src(String path) => File('lib/$path').readAsStringSync();

void main() {
  // ---------------------------------------------------------------------------
  //  1. The placeholder name must not shout from inside a sentence
  // ---------------------------------------------------------------------------
  group('child name placeholder', () {
    test('reads lowercase mid-sentence, so "How your baby is doing" is right',
        () {
      final seed = Child(
        id: '',
        name: Child.placeholder,
        isBoy: true,
        dob: DateTime.now(),
        weightKg: 0,
        heightCm: 0,
        headCm: 0,
      );
      expect(seed.name, 'Your baby',
          reason: 'standalone and sentence-initial uses still capitalise');
      expect(seed.nameMid, 'your baby',
          reason: 'mid-sentence must not carry a stray capital');
    });

    test('a REAL name is a proper noun and keeps its capital', () {
      final aarav = Child(
        id: 'c1',
        name: 'Aarav',
        isBoy: true,
        dob: DateTime.now(),
        weightKg: 0,
        heightCm: 0,
        headCm: 0,
      );
      expect(aarav.nameMid, 'Aarav',
          reason: 'lowercasing a real name would be worse than the bug');
    });
  });

  // ---------------------------------------------------------------------------
  //  2. Community monograms must stay distinct
  // ---------------------------------------------------------------------------
  //  The original rule dropped every word beginning with a digit, which is right
  //  for "November 2026 Moms" and catastrophic for the age rooms: "1 Year Olds"
  //  and "2 Year Olds" both monogrammed as YO. Two rooms, one badge.
  //
  //  The rule lives in TWO files — the pregnancy Community screen and the
  //  parenting one, which is a deliberate replica. Both had the bug.
  group('community monograms', () {
    // CALLS THE REAL FUNCTION. An earlier version of this test re-implemented
    // the rule locally and passed while the parenting screen — the one actually
    // showing YE / YO / YO on a phone — was still broken. There are two
    // community screens with two copies of this logic, and a test that owns its
    // own copy cannot tell you that. This is the wiring gate: assert against
    // what ships, not against a description of it.
    const mono = ppMono;

    test('the parenting age rooms do not collide', () {
      final names = ['0–1 Year', '1 Year Olds', '2 Year Olds', '3 Year Olds'];
      final monos = names.map(mono).toList();
      expect(monos.toSet().length, names.length,
          reason: 'these four rooms produced YE / YO / YO before: $monos');
    });

    test('a mid-name year is still dropped', () {
      expect(mono('November 2026 Moms'), 'NM');
      expect(mono('Delhi Moms'), 'DM');
    });

    test('a leading age number is kept, because it IS the identity', () {
      expect(mono('2 Year Olds'), '2Y');
    });
  });

  // ---------------------------------------------------------------------------
  //  3. Category keys vs the words a person reads
  // ---------------------------------------------------------------------------
  group('find-help labels', () {
    test('display text is Indian English', () {
      expect(needLabel('Pediatrician'), 'Paediatrician');
      expect(needLabel('Gynecologist'), 'Gynaecologist');
      expect(needLabel('Child derma'), 'Child dermatologist');
    });

    test('the MATCHING KEY is untouched, so nothing unmaps', () {
      // Correcting the spelling in place would have silently emptied these.
      expect(expertsForNeed('Pediatrician'), isNotEmpty);
      expect(expertsForNeed('Gynecologist'), isNotEmpty);
      expect(expertsForNeed('Child derma'), isNotEmpty);
    });

    test('an unknown category still renders something', () {
      expect(needLabel('Astrologer'), 'Astrologer');
    });
  });

  // ---------------------------------------------------------------------------
  //  4. No decorative emoji in chrome
  // ---------------------------------------------------------------------------
  //  ppBadgeIcon existed, was captioned "no decorative emoji", and was never
  //  called — so 🏆 and 💰 shipped anyway. This is the wiring gate: a correct
  //  helper nobody wired up is worth nothing.
  group('product badges', () {
    test('every badge has a line icon', () {
      for (final b in ['Best overall', 'Best value', 'Premium', 'Gentle',
        'Budget', '']) {
        expect(ppBadgeIcon(b), isA<IconData>());
      }
    });

    test('the badge chip calls ppBadgeIcon, not ppBadgeEmoji', () {
      final s = _src('screens/post_pregnancy/pp_product_widgets.dart');
      final live = s
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live.contains('ppBadgeIcon(badge)'), isTrue,
          reason: 'the line-icon helper must actually be called');
      expect(live.contains('Text(ppBadgeEmoji(badge)'), isFalse,
          reason: 'the emoji version is kept for revert, commented out');
    });
  });

  // ---------------------------------------------------------------------------
  //  5. Parenting scroll views reserve room for the Ask Veda FAB
  // ---------------------------------------------------------------------------
  //  global_ask_fab.dart states the contract in a comment and only TTC ever
  //  honoured it. Every FAB overlap in the parenting app was that one omission,
  //  repeated across fifteen screens.
  group('Ask Veda FAB reserve', () {
    test('the constant clears the button and the chrome under it', () {
      expect(kAskFabReserve, greaterThan(kAskFabBottomOffset + kAskFabSize));
    });

    test('the parenting screens that overlapped now reserve it', () {
      const screens = [
        'my_child_screen',
        'recipes_explore_screen',
        'reco_explore_screen',
        'read_explore_screen',
        'courses_explore_screen',
        'watch_home_screen',
        'pp_saved_hub_screen',
        'tools_hub_screen',
      ];
      final missing = <String>[];
      for (final s in screens) {
        final src = _src('screens/post_pregnancy/$s.dart');
        if (!src.contains('kAskFabReserve')) missing.add(s);
      }
      expect(missing, isEmpty,
          reason: 'these screens strand their last row under the FAB');
    });
  });

  // ---------------------------------------------------------------------------
  //  6. A Switch has to show which way it is set
  // ---------------------------------------------------------------------------
  //  activeThumbColor: ppPurple painted a purple thumb on M3's purple active
  //  track. The knob vanished and the control became a featureless pill — on
  //  the doctor app's "Taking bookings" and Brand Studio's "Demo mode".
  test('no Switch paints its thumb the same colour as its active track', () {
    const files = [
      'screens/doctor/doctor_schedule_screen.dart',
      'screens/post_pregnancy/wallet_v2_screens.dart',
      'brand/brand_preview_screen.dart',
      'screens/brand_showcase_screen.dart',
      'screens/community_screen.dart',
    ];
    final offenders = <String>[];
    for (final f in files) {
      for (final line in _src(f).split('\n')) {
        final l = line.trim();
        if (l.startsWith('//')) continue;
        // A brand-coloured thumb with no track colour beside it is the bug.
        if (l.startsWith('activeThumbColor:') &&
            !l.contains('Colors.white') &&
            !l.contains('Colors.black')) {
          offenders.add('$f: $l');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'colour the TRACK and leave the thumb white:\n'
            '${offenders.join('\n')}');
  });

  // ---------------------------------------------------------------------------
  //  7. The Explore kit is one kit
  // ---------------------------------------------------------------------------
  group('shared Explore kit', () {
    test('the search field opts out of the global filled decoration', () {
      final s = _src('screens/post_pregnancy/pp_explore_kit.dart');
      expect(s.contains('filled: false'), isTrue,
          reason: 'AppTheme sets filled:true app-wide, so without this the kit '
              'paints a second, nested search box inside the first');
    });

    test('one link label, not two', () {
      final kit = _src('screens/post_pregnancy/pp_explore_kit.dart');
      expect(kit.contains("this.seeMoreLabel = 'View all'"), isTrue);
      for (final s in ['read_explore_screen', 'courses_explore_screen']) {
        final src = _src('screens/post_pregnancy/$s.dart');
        final live =
            src.split('\n').where((l) => !l.trimLeft().startsWith('//'));
        expect(live.any((l) => l.contains("seeMoreLabel:")), isFalse,
            reason: '$s overrides the shared label again');
      }
    });

    test('the trust banner keeps ONE icon across every screen', () {
      // It makes the same claim everywhere, so it must look the same
      // everywhere. Per-section glyphs described the content instead.
      //
      // Scoped to the ExpertCuratedBanner( call. A bare search for
      // "icon: Icons." matches empty states, section headers and every recipe
      // category — this assertion has to be about the banner alone.
      for (final s in [
        'read_explore_screen',
        'courses_explore_screen',
        'reco_explore_screen',
        'recipes_explore_screen',
      ]) {
        final lines = _src('screens/post_pregnancy/$s.dart').split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('ExpertCuratedBanner(')) continue;
          // The call is short; its arguments end at the closing paren.
          final block = <String>[];
          for (var j = i; j < lines.length && j < i + 12; j++) {
            block.add(lines[j]);
            if (lines[j].trim().startsWith(')')) break;
          }
          final override = block
              .where((l) => !l.trimLeft().startsWith('//'))
              .any((l) => l.contains('icon: Icons.'));
          expect(override, isFalse,
              reason: '$s overrides the shared trust icon at line ${i + 1}');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  //  8. Chips must be able to size to their content
  // ---------------------------------------------------------------------------
  //  A Container with a non-null alignment wraps its child in an Align, and an
  //  Align with no widthFactor fills the width it is offered. Inside a Wrap that
  //  is the FULL row, so all fifteen Watch category chips went full-width and
  //  stacked one per line, pushing every video a thousand pixels down the page.
  testWidgets('a chip in a Wrap sizes to its label, not the row', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: Wrap(spacing: 8, children: [
            for (final label in ['All', 'Sleep', 'Feeding'])
              Container(
                key: ValueKey(label),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                    mainAxisSize: MainAxisSize.min, children: [Text(label)]),
              ),
          ]),
        ),
      ),
    ));
    final w = t.getSize(find.byKey(const ValueKey('All'))).width;
    expect(w, lessThan(200),
        reason: 'a chip that fills the row means one chip per line');
  });
}
