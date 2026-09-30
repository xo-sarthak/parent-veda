// "One ParentVeda" on the pregnancy screens (2026-09-30, after main's TTC
// builds): one ink #2F2C30 for everything pressable, no violet chrome, one
// serif section heading. A source scan, like main's
// `ttc_one_heading_style_test.dart` and `pv_store_consistency_test.dart`: a
// colour is a decision a later edit can quietly undo, and no widget test looks
// at every screen.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/pregnancy/preg_chrome.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart' show kPvInk;

/// The file without comment lines, so a "kept for revert" note is allowed.
String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
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

  test('More, Tools and Learn head their sections with the one heading', () {
    for (final f in [
      'lib/screens/pregnancy/preg_more_screen.dart',
      'lib/screens/pregnancy/preg_learn_screen.dart',
      'lib/screens/tools_hub_screen.dart',
    ]) {
      expect(_code(f), contains('PregSectionHeading('), reason: f);
    }
    // More's rows open somewhere, so they carry drawn marks, not line icons.
    expect(_code('lib/screens/pregnancy/preg_more_screen.dart'), isNot(contains('PvYouRow(')));
  });
}
