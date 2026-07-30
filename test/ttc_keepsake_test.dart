// =============================================================================
//  One keepsake, in one place, offered rather than prompted
// -----------------------------------------------------------------------------
//  §3.3 asked where share cards should be reachable from. They were built and
//  complete — templates, a ×3 capture to a 1080px PNG, gallery save, the native
//  share sheet, no server anywhere — and reachable from the parenting Explore
//  drawer and the pregnancy Profile. Not from TTC at all, which meant the stage
//  reached its most significant moment with nothing to make from it.
//
//  The answer was NOT "add them everywhere the other stages have them". Almost
//  all of the design here is in what was left out, so that is what these pin.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/memories/memory_models.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_milestones.dart';

String codeOf(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  const transition = 'lib/screens/ttc/ttc_transition_screen.dart';

  // ===========================================================================
  group('TTC needs no card type of its own', () {
    test('because its final moment IS the expecting announcement', () {
      // MemoryType is {expecting, welcomeBaby} and the enum comment invites
      // future ones. Adding `ttcPositiveTest` would have produced a third type
      // that renders the same card for the same event under a different name.
      expect(MemoryType.values.length, 2);
      expect(MemoryType.values, contains(MemoryType.expecting));
    });

    test('and it opens that type directly', () {
      final src = codeOf(transition);
      expect(src, contains('MemoryType.expecting'));
      expect(src, contains('MemoryPersonalizeScreen'));
    });
  });

  // ===========================================================================
  group('and exactly one milestone earns one', () {
    test('there are eleven, and ten of them must not offer a card', () {
      // A shareable graphic for "cycle 6 logged" would be grotesque, and more
      // to the point most people trying to conceive are deliberately private
      // about it. A card at every milestone turns a private year into something
      // with a publish button on it.
      expect(ttcMilestones.length, greaterThan(5));

      // The offer lives on the transition screen and nowhere else in the stage.
      final ttcFiles = Directory('lib/screens/ttc')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final offering = [
        for (final f in ttcFiles)
          if (codeOf(f.path).contains('MemoryPersonalizeScreen'))
            f.uri.pathSegments.last
      ];
      expect(offering, ['ttc_transition_screen.dart'],
          reason: 'the keepsake leaked into the rest of the stage');
    });

    test('the milestone list itself offers nothing', () {
      // Data, not UI - if a card ever gets attached to a milestone it will be
      // attached here, to all of them at once, which is the mistake.
      final src = codeOf('lib/ttc/ttc_milestones.dart');
      expect(src, isNot(contains('Memory')));
    });
  });

  // ===========================================================================
  group('offered, never prompted', () {
    test('the copy leaves it entirely up to her', () {
      // Plenty of people reach a positive test carrying a previous loss and
      // will not announce anything for weeks. "If you want to" is load-bearing.
      const en = TtcS(false);
      const hi = TtcS(true);
      expect(en.transitionMakeCard.toLowerCase(), contains('if you want to'));
      expect(en.transitionMakeCard, isNot(hi.transitionMakeCard));

      // Nothing celebratory, nothing imperative.
      final s = en.transitionMakeCard.toLowerCase();
      expect(s, isNot(contains('congratulations')));
      expect(s, isNot(contains('share the news')));
      expect(s, isNot(contains('tell everyone')));
    });

    test('it sits below the primary action, not above it', () {
      // Going on to the pregnancy is the point of the screen. The keepsake is
      // secondary and has to read that way.
      final src = codeOf(transition);
      final onward = src.indexOf('_toPregnancy(context)');
      final card = src.indexOf('MemoryPersonalizeScreen');
      expect(onward, greaterThan(-1));
      expect(card, greaterThan(onward),
          reason: 'the keepsake is competing with the reason she is here');
    });

    test('and it is not on the way IN to the transition', () {
      // `recordPositiveTest` runs the confirm dialog and the engine. A keepsake
      // offered there would be asking her to announce a pregnancy she has not
      // finished recording.
      final src = codeOf(transition);
      final confirm = src.substring(
          src.indexOf('Future<bool> recordPositiveTest'),
          src.indexOf('class TtcTransitionScreen'));
      expect(confirm, isNot(contains('Memory')));
    });
  });

  // ===========================================================================
  test('the keepsake still needs no backend', () {
    // The whole reason this was buildable under a no-schema constraint: the
    // card is made, rendered and shared entirely on the device. §3.1 and §3.2
    // are about syncing to a SECOND device and do not gate making one today.
    final src = codeOf('lib/memories/memory_export.dart');
    expect(src, isNot(contains('SupabaseRepo')));
    expect(src, isNot(contains('StorageService')));
  });
}
