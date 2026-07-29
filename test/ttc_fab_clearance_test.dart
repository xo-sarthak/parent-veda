// =============================================================================
//  Nothing may be stranded under the Ask Veda FAB
// -----------------------------------------------------------------------------
//  The FAB is mounted in `MaterialApp.builder`, above every route. That makes it
//  invisible to layout: no screen reserves room for it, no Scaffold knows it is
//  there, and a ListView happily ends its last row underneath a 56px opaque
//  circle.
//
//  On TTC it blocked real tap targets on sixteen screens - the delete on a
//  logged cycle row, a room's Join, a consultation's price. The failure is worse
//  than it looks because it is undiscoverable: from where she is sitting the
//  button is not obscured, it is simply absent, and "scroll down further" is not
//  a thing anyone thinks to try when the list has visibly ended.
//
//  The cause was arithmetic, not carelessness. `ttcBottomInset` was 108, sized
//  for the floating nav pill, and every PUSHED screen - which has no pill -
//  reasonably hardcoded 40. Both numbers were right about the chrome their
//  author was thinking about. Neither knew about the FAB.
//
//  So the reserve is now derived from the FAB's own geometry, and this file
//  stops the literals coming back.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

void main() {
  test('the reserve actually clears the FAB', () {
    // If someone lowers the reserve below the circle's own footprint, the
    // constant is lying and every screen inherits the lie.
    expect(kAskFabReserve,
        greaterThanOrEqualTo(kAskFabRaisedOffset + kAskFabSize));
    expect(ttcBottomInset, greaterThanOrEqualTo(kAskFabReserve));
  });

  test('every TTC page reserves it, and none hardcodes a number', () {
    // Anchored on the scroll view itself, not just on the gutter. An earlier
    // version matched any `fromLTRB(ttcGutter, ...)` and flagged Ask Veda's
    // header and composer - two fixed-height containers that are nowhere near a
    // scroll. A test that cries wolf about correct code gets its exceptions
    // widened until it stops testing anything.
    final pattern = RegExp(
        r'ListView(\.builder)?\(\s*padding:\s*const EdgeInsets\.fromLTRB\(\s*'
        r'ttcGutter,\s*\d+,\s*ttcGutter,\s*([A-Za-z0-9_]+)\)');

    final offenders = <String>[];
    var checked = 0;

    // One named alternative, not a blanket exemption. Ask Veda is the single
    // route the FAB hides over (`kAskVedaRoute` - it will not offer to open the
    // screen you are standing on), so its lists clear the pinned composer
    // instead. Naming the constant here means the exception stays visible; a
    // bare number would just look like another screen that forgot.
    const allowed = {'ttcBottomInset', '_composerInset'};

    for (final f in Directory('lib/screens/ttc')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final text = f.readAsStringSync().replaceAll('\n', ' ');
      for (final m in pattern.allMatches(text)) {
        checked++;
        final inset = m.group(2)!;
        if (!allowed.contains(inset)) {
          offenders.add('${f.uri.pathSegments.last}: $inset');
        }
      }
    }

    expect(checked, greaterThan(20),
        reason: 'the pattern stopped matching - this test went blind');
    expect(offenders, isEmpty,
        reason: 'content will sit under the Ask Veda FAB on these screens');
  });
}
