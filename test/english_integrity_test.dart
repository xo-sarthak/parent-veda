// =============================================================================
//  The English app must be unchanged by the Hindi work
// -----------------------------------------------------------------------------
//  Every string is `_p(english, hindi)`, and English mode returns the first
//  argument untouched — so English is preserved by construction, right up until
//  something damages the first argument.
//
//  That has already happened once. Lifting inline copy into the table captured
//  `\'` as two real characters and escaped them a second time, so
//  "EXPLORE MORE IF YOU'D LIKE" rendered a visible backslash and two strings
//  rendered a literal \n where a line break was meant. It compiled. It passed
//  every test that existed. It was caught by a widget test overflowing seven
//  pixels — which is not a way to find bugs.
//
//  These assertions are cheap and they run on the whole table, so the next one
//  fails here instead.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _backslash = r'\';

/// Every `_p(a, b)` in the string table, as raw source arguments.
List<(String, String)> _pairs() {
  final src =
      File('lib/localization/app_language.dart').readAsStringSync();
  final out = <(String, String)>[];
  // Single-literal pairs only. Ternaries and concatenations are hand-written
  // and are checked by the tests that cover their screens.
  final re = RegExp(
      r"""_p\(\s*(?:'((?:\\.|[^'])*)'|"((?:\\.|[^"])*)")\s*,\s*"""
      r"""(?:'((?:\\.|[^'])*)'|"((?:\\.|[^"])*)")\s*\)""",
      dotAll: true);
  for (final m in re.allMatches(src)) {
    final en = m.group(1) ?? m.group(2);
    final hi = m.group(3) ?? m.group(4);
    if (en != null && hi != null) out.add((en, hi));
  }
  return out;
}

void main() {
  final pairs = _pairs();

  test('the string table is large enough that this test is looking at it', () {
    // Guards against the regex silently matching nothing and every assertion
    // below passing vacuously.
    expect(pairs.length, greaterThan(1500),
        reason: 'only ${pairs.length} pairs parsed — the matcher is broken, '
            'not the table');
  });

  test('no English string was left empty', () {
    final empty = pairs.where((p) => p.$1.trim().isEmpty).toList();
    expect(empty, isEmpty,
        reason: '${empty.length} strings would render blank in English');
  });

  test('no English string carries a doubled backslash', () {
    // The double-escape signature. A real backslash in UI copy would be
    // remarkable; two in a row is always the bug.
    final bad =
        pairs.where((p) => p.$1.contains(_backslash + _backslash)).toList();
    expect(bad, isEmpty,
        reason: 'double-escaped English: '
            '${bad.take(3).map((p) => p.$1).join(" | ")}');
  });

  test('no Hindi string carries a doubled backslash', () {
    final bad =
        pairs.where((p) => p.$2.contains(_backslash + _backslash)).toList();
    expect(bad, isEmpty,
        reason: 'double-escaped Hindi: '
            '${bad.take(3).map((p) => p.$2).join(" | ")}');
  });

  test('a translated string keeps the placeholders its English carries', () {
    // A string that loses its $n still compiles and still passes every other
    // test. It just shows the mother the wrong number.
    final interp = RegExp(r'\$\{[^}]*\}|\$\w+');
    // One deliberate exception: a call site may hold the language-specific
    // fragment in a local named `en` and its twin in one named `hi`, so the
    // two sides legitimately interpolate different variables. Treating them
    // as the same slot keeps this test honest without special-casing a name.
    String slot(String s) => s == r'$en' || s == r'$hi' ? r'$lang' : s;
    final mismatched = <String>[];
    for (final (en, hi) in pairs) {
      final a = interp.allMatches(en).map((m) => slot(m.group(0)!)).toList()
        ..sort();
      final b = interp.allMatches(hi).map((m) => slot(m.group(0)!)).toList()
        ..sort();
      if (a.join(',') != b.join(',')) mismatched.add('$en  =>  $hi');
    }
    expect(mismatched, isEmpty,
        reason: '${mismatched.length} placeholder mismatches, e.g. '
            '${mismatched.take(2).join("  ///  ")}');
  });
}
