// =============================================================================
//  One notice, everywhere (toasts pass, 2026-10-15)
// -----------------------------------------------------------------------------
//  The user: "our app lacks toasts a lot", asking for the motion and the
//  smoothness of the apps on Mobbin. Every notice now goes through `pvToast`
//  (lib/widgets/pv_toast.dart): one overlay card that rises with a settle,
//  morphs into the next instead of cutting it, swipes away and holds while
//  pressed. Before this pass there were ~190 raw `showSnackBar` calls in two
//  looks, which is how the app ended up with two kinds of notice.
//
//  This test reads the source so it stays one: no `showSnackBar(`,
//  `SnackBar(` or `SnackBarAction(` in lib/ outside commented-out code. A new
//  notice is `pvToast(context, 'words', kind: PvToastKind.done)`.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final RegExp _raw = RegExp(r'showSnackBar\(|\bSnackBar\(|\bSnackBarAction\(');

/// Files that may still hold a raw call, with how many. May only shrink.
const Map<String, int> kRawSnackAllowed = {};

void main() {
  test('every notice goes through pvToast', () {
    final found = <String, int>{};
    final where = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      final path = f.path.replaceAll(r'\', '/');
      var inBlock = false; // inside a /* kept for revert */ block
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (inBlock) {
          if (line.contains('*/')) inBlock = false;
          continue;
        }
        final open = line.indexOf('/*');
        if (open >= 0 && !line.contains('*/', open)) inBlock = true;
        final m = _raw.firstMatch(line);
        if (m != null && open >= 0 && open < m.start) continue;
        if (m == null) continue;
        final code = line.substring(0, m.start);
        if (code.contains('//') || code.trimLeft().startsWith('*')) continue;
        found[path] = (found[path] ?? 0) + 1;
        where.add('$path:${i + 1}');
      }
    }
    final over = <String>[
      for (final e in found.entries)
        if (e.value > (kRawSnackAllowed[e.key] ?? 0)) '${e.key} (${e.value})',
    ];
    expect(over, isEmpty,
        reason: 'Raw SnackBars found; use pvToast instead:\n${where.join('\n')}');
  });
}
