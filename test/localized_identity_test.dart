// =============================================================================
//  Identity reads .en; only display reads .now
// -----------------------------------------------------------------------------
//  The Hindi migration's recurring bug, six times over: ONE string doing both
//  display and identity. Once a field widens to LocalizedText, `.now` is the
//  obvious suffix everywhere - and it is wrong anywhere the value is persisted,
//  compared, switched on, or used as a key.
//
//    _valueName              stripped a "ParentVeda " prefix
//    _fromCohort             stripped a "^Week N · " prefix
//    SavedRtbPiece           keyed a bookmark on its displayed title
//    ragaTimeBadge           matched English hints against a translated string
//    the puzzle switch       dispatched to a game widget on a translated title
//    SpiritualPrefsStore     persisted 'interested' marks under a display title
//
//  None of these fail to compile: both sides are LocalizedText, so the type
//  system cannot tell them apart. None of them fail a normal test either -
//  they produce a plausible wrong answer. The only symptoms reach the mother:
//  bookmarks that vanish on the language toggle, every raga badged Morning,
//  every puzzle opening Word Search.
//
//  So the rule is pinned against the SOURCE, the way the clinical invariants
//  are. This is a guard, not a proof - it knows the identity-bearing calls it
//  is told about, listed below. Add to that list when a new one appears.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Calls whose argument identifies something rather than showing it.
const _identityCalls = [
  'isSaved',
  'toggleSave',
  'isInterested',
  'toggleInterested',
  'setNotInterested',
  'rank',
  // A community poll vote is persisted under the option's text and synced to
  // Supabase. Once PulseCard.options widened to LocalizedText, `vote(id, o)`
  // would have filed the same answer under two names - one per language.
  'vote',
];

Iterable<File> _dartFiles(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

void main() {
  test('no identity-bearing call is given a .now value', () {
    // `.now` resolves to whatever language is on screen. Handing that to a
    // store means the same item is filed under a different name per language.
    final pattern = RegExp(
      '(${_identityCalls.join('|')})' r'\([^)]*\.now',
    );

    final offenders = <String>[];
    for (final file in _dartFiles('lib')) {
      final lines = file.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'These pass a display string where an identity is wanted. Use '
          '.en - the English text never changes, so it keys the same row in '
          'both languages and needs no data migration.\n'
          '${offenders.join('\n')}',
    );
  });

  test('no identity-bearing call is built by interpolation', () {
    // LocalizedText.toString() returns .now, so `'$title'` renders correctly -
    // and silently resolves to the language on screen. That is right for
    // display and wrong for a key, so the two must not meet.
    final pattern = RegExp(
      '(${_identityCalls.join('|')})' r'\([^)]*\$\{?\w',
    );
    final offenders = <String>[];
    for (final file in _dartFiles('lib')) {
      final lines = file.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'An interpolated key resolves to whatever language is on '
            'screen. Build keys from .en explicitly.\n'
            '${offenders.join('\n')}');
  });

  test('the saved-piece key is documented as language-invariant', () {
    // The comment is the only thing telling the next person WHY a key sits
    // beside a title that looks like it would do. If it goes, the next
    // widening quietly merges them again.
    final src =
        File('lib/services/read_to_baby_saved_store.dart').readAsStringSync();
    expect(src.contains('final String key;'), isTrue,
        reason: 'SavedRtbPiece must keep an identity separate from its title');
    expect(src.contains("j['k'] as String? ?? title"), isTrue,
        reason: 'rows written before the key existed must still migrate '
            'themselves - dropping this orphans every existing bookmark');
  });
}
