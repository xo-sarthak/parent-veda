// =============================================================================
//  Door names are never cut off
// -----------------------------------------------------------------------------
//  The user, 2026-10-24, on a tab card that read "When will my baby...": "make
//  sure to keep names in such a way that this doesn't happen". Two ways a name
//  ends in dots on screen, and one test each:
//   1. the name itself ends in "..." or "…", so it reads as cut off even when
//      it fits. Scanned in the source of every door, both stages' kinds.
//      Only names (`label:`): a heading that leads into a list, like Garbh's
//      "Stop and call your doctor today if...", is a sentence, not a name.
//   2. the name is too long for the carousel card (156 wide, 13 padding each
//      side, Fraunces 16, two lines, ellipsis). The font loads at run time
//      from google_fonts, so a test cannot measure it; this wraps at 15
//      characters a line, which is what the card holds on a phone.
//   3. (S11 / Sleep SL9, 2026-10-25) the TAB card on the door's rail, at a
//      large text size. That card is narrower than the carousel card: 150
//      wide, padding 14 and 10, a 6 gap and a 20 chevron beside the name,
//      so the name has 100 points, in Manrope 700 at 14. Test 2's fifteen
//      characters were the wrong card for it, and three names already took
//      three lines at the normal size. Measured here with Manrope's own
//      advance widths (taken from the font file with fontTools), not a
//      character count, at 1.0 and at 1.3 (Android's largest standard step,
//      and where the old one-line rule used to start).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';

/// Lines a name takes when wrapped word by word at [width] characters.
int _lines(String s, int width) {
  var lines = 1;
  var cur = 0;
  for (final word in s.split(' ')) {
    if (cur == 0) {
      cur = word.length;
    } else if (cur + 1 + word.length <= width) {
      cur += 1 + word.length;
    } else {
      lines++;
      cur = word.length;
    }
  }
  return lines;
}

void main() {
  test('no door name ends in dots', () {
    final named = RegExp(r"""^\s*(label):\s*'([^']*)'""");
    final bad = <String>[];
    for (final f in Directory('lib/data/doors').listSync().whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final line in f.readAsLinesSync()) {
        final m = named.firstMatch(line);
        if (m == null) continue;
        final v = m.group(2)!.trimRight();
        if (v.endsWith('...') || v.endsWith('…')) bad.add('${f.path}: $v');
      }
    }
    expect(bad, isEmpty, reason: 'a name ending in dots reads as cut off');
  });

  test('every parenting tab name fits its card in two lines', () {
    final tooLong = [
      for (final d in kPpDoors)
        for (final t in d.tabs)
          if (_lines(t.label, 15) > 2) '${d.sectionId}: ${t.label}',
    ];
    expect(tooLong, isEmpty, reason: 'the card cuts a third line with dots');
  });

  test('every parenting tab name fits the rail card in two lines, at normal and large text', () {
    final failing = <String, String>{
      for (final d in kPpDoors)
        for (final t in d.tabs)
          for (final scale in [1.0, kLargeText])
            if (!_railFits(t.label, scale)) '${d.sectionId}/${t.id}': t.label,
    };
    // Every name that fails is owed a shorter one, and named here; a new
    // failure fails the build.
    expect(failing.keys.toSet().difference(_kOwedShorterNames.keys.toSet()), isEmpty,
        reason: 'a tab name that takes three lines on the rail card: $failing');
    // And the list only shrinks: a name fixed comes off it.
    expect(_kOwedShorterNames.keys.toSet().difference(failing.keys.toSet()), isEmpty,
        reason: 'fits now; take it off _kOwedShorterNames');
    // Sleep, the door that asked for this, fits everywhere.
    for (final t in ppDoorFor('parenting_sleep')!.tabs) {
      for (final s in [1.0, kLargeText]) {
        expect(_railFits(t.label, s), isTrue, reason: '${t.label} at $s');
      }
    }
  });

  testWidgets('at a large text size the rail card keeps its width and two lines, and grows taller', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1200, 6000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    final door = ppDoorFor('parenting_sleep')!;
    await t.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(kLargeText)),
            child: PpDoorScreen(door: door, onSurface: (_, _) {}))));
    await t.pumpAndSettle();
    for (var i = 0; i < door.tabs.length; i++) {
      final card = find.byKey(pvDoorRailCardKey(i));
      expect(t.getSize(card).width, PvDoorRail.cardWidth, reason: 'the width never changes (SL9)');
      expect(t.getSize(card).height,
          PvDoorRail.heightFor(const TextScaler.linear(kLargeText), withLine: false),
          reason: 'taller instead of cut');
      final name = t.widgetList<Text>(find.descendant(of: card, matching: find.byType(Text))).first;
      expect(name.maxLines, 2, reason: '${name.data}: two lines at every size');
    }
  });
}

/// The large text size the rail is held at (SL9).
const double kLargeText = 1.3;

/// ⚠️ OWED: TAB NAMES THAT TAKE THREE LINES ON THE RAIL CARD (found by SL9,
/// 2026-10-25), each with the shorter name proposed. The rule is the user's
/// ("shortened, not squeezed"); the new words are theirs to choose, door by
/// door, so they wait here instead of being changed inside the Sleep build.
/// The first three are cut at the NORMAL size today.
const Map<String, String> _kOwedShorterNames = {
  'parenting_potty/bumpy': 'Accidents', // 3 lines at 1.0
  'parenting_first_40/samjho': 'Your newborn', // 3 lines at 1.0
  // 'parenting_family/care': 'Childcare', // door 13 (FM4): 'Care while you work'
  'parenting_feeding/cooking': 'Family cooking',
  'parenting_first_40/feeding_rest': 'Feeding and sleep',
  // 'parenting_papers/schemes': 'Schemes', // door 14: 'Schemes to claim' (the user's word)
  'parenting_potty/su_su': 'Early wees', // never "su-su" on a tab
  // 'parenting_safety/road': 'Road and heat', // door 11 (SF8): 'Travel and heat'
  // 'parenting_special_care/early': 'Born early', // door 12 (SC7): 'Preemies and NICU'
  // 'parenting_special_care/you': 'Caring for you', // door 12 (SC7): 'Looking after you'
  'parenting_maternal/people': 'Your people',
  'parenting_health/records': 'Records and checks',
  // 'parenting_papers/docs': 'Documents', // door 14: "Child's documents" ("Documents" breaks mid-word at 1.3)
  // One word wider than the line at 1.3, broken mid-word.
  'parenting_health/wrong': 'Feeling unwell', // was "Something's wrong"
  // 'parenting_family/grand': 'Grandma, grandpa', // door 13: 'Grandma, grandpa' (the user's word)
};

/// Manrope 700's advance widths for ASCII 32 to 126, in font units (2000 to
/// the em), from `manrope-latin-700-normal` (design-kit/node_modules/
/// @fontsource/manrope). The font loads at run time from google_fonts, so a
/// test cannot lay it out; its own widths are the next best thing.
const List<int> _kManrope700 = [
  400, 721, 934, 1863, 1256, 1801, 1337, 521, 906, 906, 929, 1143, 607, 840, 607, 866, //
  1316, 876, 1191, 1163, 1217, 1172, 1243, 1067, 1225, 1243, 685, 687, 1275, 1500, 1275, 1106, //
  1827, 1341, 1262, 1477, 1401, 1170, 1047, 1464, 1443, 561, 1001, 1294, 1067, 1710, 1436, 1499, //
  1277, 1499, 1320, 1315, 1213, 1440, 1281, 1951, 1311, 1223, 1327, 847, 866, 847, 1361, 1320, //
  1077, 1152, 1232, 1151, 1234, 1204, 756, 1232, 1251, 561, 577, 1076, 561, 1798, 1251, 1236, //
  1232, 1234, 798, 1083, 866, 1251, 1106, 1605, 1108, 1119, 1067, 898, 601, 898, 1432, //
];

/// The name's width on the tab card, in points: 14pt, letter spacing -0.1.
double _railWidth(String s, double scale) {
  var w = 0.0;
  for (final c in s.codeUnits) {
    final units = c >= 32 && c <= 126 ? _kManrope700[c - 32] : 1200;
    w += units / 2000 * 14 * scale - 0.1;
  }
  return w;
}

/// Lines the name takes on the tab card, wrapped word by word.
int _railLines(String s, double scale) {
  const width = _railText;
  var lines = 1;
  var cur = '';
  for (final word in s.split(' ')) {
    final next = cur.isEmpty ? word : '$cur $word';
    if (_railWidth(next, scale) <= width) {
      cur = next;
    } else {
      if (cur.isNotEmpty) lines++;
      cur = word;
    }
  }
  return lines;
}

/// The rail card's text width: 150 wide, padding 14 + 10, a 6 gap and the
/// 20 chevron.
const double _railText = PvDoorRail.cardWidth - 24 - 26;

/// Two lines at most, and no word wider than a line: Flutter breaks such a
/// word mid-word ("Somethin / g's wrong" at 1.3), which is a cut name too.
bool _railFits(String s, double scale) =>
    _railLines(s, scale) <= 2 &&
    s.split(' ').every((w) => _railWidth(w, scale) <= _railText);
