// =============================================================================
//  One section-heading style across Trying to Conceive (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, on build 20, Tools > Records and reports: "The headings are of a
//  different font than usual ... look elsewhere also for headings of a
//  different size or a different font."
//
//  THE RULE: a page's section heading is our serif (Newsreader via
//  `pvFraunces`) at 21 / w600 / -0.45 / ink1, drawn by `TtcSectionHeading`
//  (or `ttcSectionTitle`, which wraps it). A small grey caps label is for a
//  group label inside a list or card only. See the note above
//  `ttcSectionHeadingStyle` in lib/screens/ttc/ttc_common.dart.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart'
    show ttcDoorHeadingStyle;
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

String _live(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .map((l) => l.trimLeft().startsWith('//') ? '' : l)
    .join('\n');

/// A literal-titled Text in the display or title face at 17 or more, sitting
/// after a section gap (a SizedBox of 20 or more): the shape an ad-hoc section
/// heading takes. Each hit must use the shared style or be allow-listed below
/// with the reason it is not a page section.
final _textStart = RegExp(r"""Text\(\s*(t\(|'|"|k[A-Z]\w*)""");
final _style = RegExp(
    r'(pvFraunces|ttcFraunces|pvJakarta|ttcJakarta)\(\s*(?:fontSize:\s*)?(\d+(?:\.\d+)?)');
final _gap = RegExp(r'SizedBox\(height:\s*(\d+)');

/// file -> the heading text's opening words, and why it is not a section.
const Map<String, Map<String, String>> _allowed = {
  'ttc_fertility_help_screen.dart': {
    'kFertilityHelpPatternBreak': 'an editorial pull line between two '
        'sections, set larger on purpose; not a heading over content',
  },
  'ttc_shop_v3.dart': {
    "'Nothing picked yet.'": 'the compare page state title (hero line)',
    "'One picked. Pick one more.'": 'the compare page state title',
    "'Side by side.'": 'the compare page state title',
    "'Filters'": 'a bottom sheet title, not a page section',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the one style', () {
    testWidgets('serif 21 / w600 / -0.45 / ink1', (tester) async {
      final s = ttcSectionHeadingStyle();
      expect(s.fontSize, 21);
      expect(s.fontWeight, FontWeight.w600);
      expect(s.letterSpacing, -0.45);
      expect(s.height, 1.2);
      expect(s.color, V2PaletteStore.instance.current.ink1);
    });

    testWidgets('the door heading IS the shared style', (tester) async {
      final p = V2PaletteStore.instance.current;
      final d = ttcDoorHeadingStyle(p);
      final s = ttcSectionHeadingStyle(color: p.ink1);
      expect(d.fontSize, s.fontSize);
      expect(d.fontWeight, s.fontWeight);
      expect(d.letterSpacing, s.letterSpacing);
      expect(d.fontFamily, s.fontFamily);
    });

    testWidgets('ttcSectionTitle draws the serif heading, as a heading',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ttcSectionTitle('Your results'))));
      final t = tester.widget<Text>(find.text('Your results'));
      final want = ttcSectionHeadingStyle();
      expect(t.style!.fontSize, want.fontSize);
      expect(t.style!.fontWeight, want.fontWeight);
      expect(t.style!.fontFamily, want.fontFamily,
          reason: 'the serif, not the Manrope it used to be');
      expect(find.byType(TtcSectionHeading), findsOneWidget);
      expect(
          tester.getSemantics(find.text('Your results')),
          matchesSemantics(label: 'Your results', isHeader: true));
    });

    testWidgets("Learn's and the store's shelf heading matches it",
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: PvSectionHead(title: 'Start here'))));
      final t = tester.widget<Text>(find.text('Start here'));
      final want = ttcSectionHeadingStyle();
      expect(t.style!.fontSize, want.fontSize);
      expect(t.style!.fontWeight, want.fontWeight);
      expect(t.style!.letterSpacing, want.letterSpacing);
    });
  });

  group('no hand-rolled section headings in the stage', () {
    test('the old Manrope section title is gone', () {
      for (final f in Directory('lib/screens/ttc')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        expect(_live(f.path), isNot(contains('ttcJakarta(17.5)')),
            reason: f.path);
      }
    });

    test('every section heading converted on 2026-09-29 uses the shared one',
        () {
      const converted = [
        'ttc_appointments_screen.dart',
        'ttc_askveda_screen.dart',
        'ttc_bmi_screen.dart',
        'ttc_dose_parts.dart',
        'ttc_fertility_help_screen.dart',
        'ttc_fertility_help_summary.dart',
        'ttc_ovulation_screen.dart',
        'ttc_pcos_check_result.dart',
        'ttc_precheck_summary.dart',
        'ttc_symptom_log_screen.dart',
        'ttc_tracker_screen.dart',
        'ttc_treatment_screen.dart',
        'ttc_home_v3.dart',
        'ttc_more_tab.dart',
        'doors/ttc_door_screen.dart',
      ];
      for (final f in converted) {
        final src = _live('lib/screens/ttc/$f');
        expect(
            src.contains('TtcSectionHeading') ||
                src.contains('ttcSectionHeadingStyle'),
            isTrue,
            reason: f);
      }
    });

    test('a literal heading after a section gap uses the shared style', () {
      final hits = <String>[];
      for (final f in Directory('lib/screens/ttc')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final name = f.path
            .replaceAll('\\', '/')
            .split('lib/screens/ttc/')
            .last;
        final lines = _live(f.path).split('\n');
        for (var i = 0; i < lines.length; i++) {
          final m = _textStart.firstMatch(lines[i]);
          if (m == null) continue;
          final window =
              lines.sublist(i, (i + 7).clamp(0, lines.length)).join('\n');
          final sm = _style.firstMatch(window);
          if (sm == null) continue;
          if (double.parse(sm.group(2)!) < 17) continue;
          final before = lines
              .sublist((i - 4).clamp(0, i), i)
              .where((l) => l.trim().isNotEmpty);
          final gapped = before.any((l) => _gap
              .allMatches(l)
              .any((g) => int.parse(g.group(1)!) >= 20));
          if (!gapped) continue;
          final allow = _allowed[name] ?? const {};
          if (allow.keys.any((k) => lines[i].contains(k))) continue;
          hits.add('$name:${i + 1}: ${lines[i].trim()}');
        }
      }
      expect(hits, isEmpty,
          reason: 'use TtcSectionHeading (or ttcSectionTitle), or add the '
              'line to _allowed with the reason it is not a page section');
    });
  });
}
