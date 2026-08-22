// =============================================================================
//  The script library reaches what it points at
// -----------------------------------------------------------------------------
//  The behaviour section had no tools at all while its own header claimed
//  three. This tool is the first, and it is the one a parent uses mid-crisis,
//  so the things it can get wrong are worth naming.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_behaviour_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_scripts_data.dart';

void main() {
  test('every script page link resolves to a real behaviour page', () {
    for (final s in kPpScripts) {
      final id = s.pageId;
      if (id == null) continue;
      expect(kPpBehaviourSection.pageById(id), isNotNull,
          reason: 'Script "${s.situation}" links to "$id", which is not a page '
              'in the behaviour section. `_openPageById` does NOTHING for an '
              'unknown id rather than throwing, so this fails silently on a '
              'phone and never in a build.');
    }
  });

  test('every script has words for both halves', () {
    for (final s in kPpScripts) {
      expect(s.sayThis, isNotEmpty, reason: '${s.id} has nothing to say');
      expect(s.notThis, isNotEmpty,
          reason: '${s.id} has no "rather than". The contrast is half the '
              'tool, and the harder half to write.');
      expect(s.principle.length, greaterThan(60),
          reason: '${s.id} explains nothing about why');
    }
  });

  test('nothing in the library blames the parent', () {
    // The tool is opened at the worst moment of somebody's day. Copy that
    // scolds is worse than no copy, and it is easy to write by accident when
    // describing what not to say.
    for (final s in kPpScripts) {
      final t = s.principle.toLowerCase();
      for (final banned in ['you should never', 'bad parent', 'your fault', 'stop doing']) {
        expect(t.contains(banned), isFalse,
            reason: '"${s.situation}" principle reads as a telling-off');
      }
    }
  });

  test('every band has something in it', () {
    // The section is age-banded, so a parent whose child is in a band with no
    // scripts opens an empty tool. Empty is worse here than approximate.
    for (final band in ['infant', 'toddler_1', 'toddler_2', 'preschool']) {
      expect(ppScriptsForBand(band), isNotEmpty,
          reason: 'no scripts for "$band"');
    }
  });

  test('search finds a script by a word inside it, not just the title', () {
    // A parent types what is happening. The word she uses is usually in the
    // lines rather than in the heading.
    expect(ppScriptSearch('bite').map((s) => s.id), contains('bit_baby'));
    expect(ppScriptSearch('timer').map((s) => s.id), contains('screen_off'));
    expect(ppScriptSearch('zzzzz'), isEmpty);
  });
}
