// "One ParentVeda" on the pregnancy screens (2026-09-30, after main's TTC
// builds): one ink #2F2C30 for everything pressable, no violet chrome, one
// serif section heading. A source scan, like main's
// `ttc_one_heading_style_test.dart` and `pv_store_consistency_test.dart`: a
// colour is a decision a later edit can quietly undo, and no widget test looks
// at every screen.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/pregnancy/preg_theme.dart';
import 'package:parentveda/theme/app_theme.dart';
import 'package:parentveda/screens/pregnancy/preg_chrome.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart' show kPvInk;

/// The file without comment lines, so a "kept for revert" note is allowed.
String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final files = [
    for (final f in Directory('lib/screens/pregnancy').listSync())
      if (f.path.endsWith('.dart')) f.path,
  ]..sort();

  test('no brand violet or plum on any pregnancy screen', () {
    for (final f in files) {
      final src = _code(f);
      for (final banned in ['p.action', 'AppTheme.primary', '0xFF6A30B6']) {
        expect(src, isNot(contains(banned)), reason: '$f uses $banned');
      }
    }
  });

  test('the one ink is #2F2C30, and the one heading is the serif at 21 / w600', () {
    expect(kPvInk.toARGB32(), 0xFF2F2C30);
    final src = _code('lib/screens/pregnancy/preg_chrome.dart');
    expect(src, contains('fontSize: 21'));
    expect(src, contains('fontWeight: FontWeight.w600'));
    expect(src, contains('letterSpacing: -0.45'));
    expect(pregFilledStyle().backgroundColor?.resolve({}), kPvInk);
  });

  test('More and Learn head their sections with the one heading', () {
    // Tools left this list on 2026-10-02 (the user: match Tools to TTC's
    // format): its groups take TTC's violet caps eyebrow, pinned in
    // test/preg_tools_more_ttc_format_test.dart.
    for (final f in [
      'lib/screens/pregnancy/preg_more_screen.dart',
      'lib/screens/pregnancy/preg_learn_screen.dart',
    ]) {
      expect(_code(f), contains('PregSectionHeading('), reason: f);
    }
    // More's rows open somewhere, so they carry drawn marks, not line icons.
    expect(_code('lib/screens/pregnancy/preg_more_screen.dart'), isNot(contains('PvYouRow(')));
  });

  // ---------------------------------------------------------------------------
  //  The restyle (2026-09-30): every live pregnancy screen, not only the new ones
  // ---------------------------------------------------------------------------

  test('the pregnancy theme swaps the violet for the ink, and main.dart picks it by stage', () {
    // A plain violet theme stands in for AppTheme's: building the real one
    // fetches its fonts, which a test cannot. The swap is the same function.
    final t = pregThemeFrom(ThemeData(
        colorScheme: const ColorScheme.light(primary: AppTheme.primary500)));
    expect(t.colorScheme.primary, kPvInk);
    expect(t.floatingActionButtonTheme.backgroundColor, kPvInk);
    final main = _code('lib/main.dart');
    expect(main, contains('pregThemeFrom(AppTheme.lightFor('));
    expect(main, contains('_pregnancyStage'));
  });

  test('no pregnancy-side screen carries the brand violet or a plum tint', () {
    // Other stages' folders and shared screens are not pregnancy's to change;
    // unreached leftovers are left until they are deleted (STILL-OPEN §81.12).
    const otherStages = ['/ttc/', '/post_pregnancy/', '/skilling/', '/enterprise/', '/doctor/',
        '/brand', '/auth/', '/profile/', '/products/', '/learn/', '/sk_'];
    const leftOrShared = [
      'week_flow_screen', 'home_screen_b', 'week5_full_flow', 'week6_preview', 'hospital_bag_screen',
      'hospital_bag_v2_screen', 'bump_journey_screen', 'tools_screen.dart', '/home_screen.dart',
      'nutrition_home_screen', 'problem_hub_screen', 'memory_personalize_screen', 'v3_daily.dart',
      'nutrition_recipes_screen', 'community_screen', 'saved_screen.dart', 'products_screen', 'v2_palette',
      '/product_guide/', '/reader/', 'hub_owed_screen', 'memories_home_screen', 'invite_nudge_card', 'prepare_common',
    ];
    // Visibly violet: a real amount of colour (chroma), in the violet hues. A
    // near-white or near-black has a hue on paper and none to the eye.
    bool violet(String hex) {
      final c = Color(int.parse(hex));
      final r = c.r, g = c.g, b = c.b;
      final chroma = [r, g, b].reduce((a, x) => a > x ? a : x) - [r, g, b].reduce((a, x) => a < x ? a : x);
      final h = HSLColor.fromColor(c);
      return chroma > 0.06 && h.hue >= 250 && h.hue <= 300;
    }
    final hexRe = RegExp(r'0x[Ff]{2}[0-9A-Fa-f]{6}');
    for (final f in Directory('lib/screens').listSync(recursive: true)) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart')) continue;
      if (otherStages.any(path.contains) || leftOrShared.any(path.contains)) continue;
      final src = _code(path);
      expect(src, isNot(matches(RegExp(r'AppTheme\.primary\d'))), reason: path);
      for (final m in hexRe.allMatches(src)) {
        expect(violet(m.group(0)!), isFalse, reason: '$path: ${m.group(0)}');
      }
    }
  });
}
