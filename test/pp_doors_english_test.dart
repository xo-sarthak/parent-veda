// =============================================================================
//  The parenting doors speak English (2026-10-07)
// -----------------------------------------------------------------------------
//  The user, on the device: "In the doors, the tab headings are in Hinglish.
//  They need to be in English. Like 'Din by din' inside the First 40 days door
//  makes no sense. Keep it all English and easy to understand."
//
//  A source scan, not a render: every `label:` and `title:` in the door data
//  files and the door content files, outside comments, is checked for the
//  Latin-script Hindi words the brief named (whole word, any case).
//
//  Two rules, matching the brief:
//    * a TAB LABEL (lib/data/doors/) carries none of them, not even in
//      brackets. "Never in a tab heading."
//    * a TITLE may carry the Indian name in brackets after an English
//      description, where the name is the thing a parent searches for:
//      "The first rice feeding (annaprashan)". So bracketed text is ignored
//      for titles, and only for titles.
//
//  Devanagari is never touched by this test (shipped Hindi stays; CLAUDE.md),
//  and ids, page ids and surface ids are not display text, so only the values
//  of `label:` and `title:` are read.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const List<String> _banned = [
  'din by din',
  'ziddi',
  'bachcha',
  'nuskhe',
  'nuskha',
  'dadi',
  'nani',
  'maalish',
  'malish',
  'maalishwali',
  'sutak',
  'chhatti',
  'chatti',
  'chhathi',
  'mundan',
  'annaprashan',
  'jaapa',
  'japa',
  'panjiri',
  'ajwain',
  'ghutti',
  'kajal',
  'laddoo',
  'laddoos',
  'maa',
  'beta',
  'samjho',
  'dekhbhaal',
  'puchho',
  'su-su',
  'katori',
  'razai',
  'jhula',
];

/// The door data files and the content files the doors read.
List<File> _files() {
  final out = <File>[];
  for (final e in Directory('lib/data/doors').listSync()) {
    if (e is File && RegExp(r'pp_door_\w+\.dart$').hasMatch(e.path)) out.add(e);
  }
  for (final e in Directory('lib/screens/post_pregnancy').listSync()) {
    if (e is! File) continue;
    final name = e.uri.pathSegments.last;
    if (RegExp(r'^pp_\w+_content\.dart$').hasMatch(name) ||
        name == 'pp_content.dart' ||
        name == 'pp_behaviour_bands.dart' ||
        name == 'pp_behaviour_more.dart') {
      out.add(e);
    }
  }
  return out;
}

/// Source with block comments and whole-line `//` comments removed. Kept-for-
/// revert blocks are commented out, and they are not on screen.
String _code(String src) {
  final noBlocks = src.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  return noBlocks
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
}

final RegExp _field = RegExp(
    r'''\b(label|title):\s*(?:_en\()?('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")''');

String? _hit(String text) {
  final lower = text.toLowerCase();
  for (final w in _banned) {
    final re = RegExp('(^|[^a-z])${RegExp.escape(w)}([^a-z]|\$)');
    if (re.hasMatch(lower)) return w;
  }
  return null;
}

void main() {
  test('the scan finds the door files it is meant to read', () {
    final names = _files().map((f) => f.uri.pathSegments.last).toSet();
    expect(names, containsAll(['pp_door_first40.dart', 'pp_first40_content.dart', 'pp_traditions_content.dart', 'pp_behaviour_bands.dart']));
  });

  test('no tab label in a parenting door carries a Hinglish word, even in brackets', () {
    final bad = <String>[];
    for (final f in _files().where((f) => f.path.contains('doors'))) {
      final src = _code(f.readAsStringSync());
      for (final m in _field.allMatches(src)) {
        if (m.group(1) != 'label') continue;
        final value = m.group(2)!;
        final w = _hit(value);
        if (w != null) bad.add('${f.uri.pathSegments.last}: $value  [$w]');
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('no door title or label is Hinglish outside an explanatory bracket', () {
    final bad = <String>[];
    for (final f in _files()) {
      final src = _code(f.readAsStringSync());
      for (final m in _field.allMatches(src)) {
        final value = m.group(2)!;
        final bare = value.replaceAll(RegExp(r'\([^)]*\)'), '');
        final w = _hit(bare);
        if (w != null) bad.add('${f.uri.pathSegments.last}: $value  [$w]');
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('the First 40 days tabs read in plain English', () {
    final src = _code(File('lib/data/doors/pp_door_first40.dart').readAsStringSync());
    expect(src, contains("label: 'Day by day'"));
    expect(src, contains("label: 'Your recovery'"));
    expect(src, contains("label: 'Understanding your newborn'"));
    expect(src.toLowerCase(), isNot(contains('din by din')));
  });
}
