// =============================================================================
//  No controller is disposed the moment its sheet or dialog closes (2026-10-02).
//
//  The user hit a red screen, "'_dependents.isEmpty': is not true", on Delete
//  account and again on Add a child. Both were the same mechanism, and a scan
//  found eighteen more places with it.
//
//  THE MECHANISM, because it travels: `await showModalBottomSheet(...)` (or
//  `showDialog`) completes when the route is POPPED, but the route stays on
//  screen for its exit animation, and its TextField is still listening to the
//  controller. A `controller.dispose()` on the very next line frees it while it
//  is being listened to, and the framework asserts in debug and paints the red
//  screen. Release builds survive by luck. The fix is to dispose after the
//  animation (600ms), as the name editor always did.
//
//  This reads the source, because the claim is about a line's position, which
//  no widget test of one screen says anything about for the other twenty.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final lib = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  test('no bare controller.dispose() follows an awaited sheet or dialog', () {
    final bad = <String>[];
    final bare = RegExp(r'^(\s*)(\w+)\.dispose\(\);\s*$');
    final route = RegExp(
        r'await\s+show(Dialog|ModalBottomSheet|GeneralDialog|DatePicker|CupertinoDialog|CupertinoModalPopup)|showModalBottomSheet|showDialog');
    for (final f in lib) {
      final lines = f.readAsStringSync().replaceAll('\r\n', '\n').split('\n');
      for (var i = 0; i < lines.length; i++) {
        final m = bare.firstMatch(lines[i]);
        if (m == null) continue;
        final name = m.group(2)!;
        // A State's own dispose() is the right place.
        var inDispose = false;
        for (var j = i; j >= 0 && i - j < 40; j--) {
          if (RegExp(r'\bvoid dispose\(\)').hasMatch(lines[j])) {
            inDispose = true;
            break;
          }
        }
        if (inDispose) continue;
        // A local controller declared above, with a route awaited between.
        int? decl;
        for (var k = i - 1; k >= 0 && i - k < 250; k--) {
          if (RegExp(r'(TextEditingController|FocusNode|ScrollController)\(')
                  .hasMatch(lines[k]) &&
              RegExp('\\b$name\\b').hasMatch(lines[k])) {
            decl = k;
            break;
          }
        }
        if (decl == null) continue;
        final between = lines.sublist(decl, i).join('\n');
        if (route.hasMatch(between)) {
          bad.add('${f.path.replaceAll('\\', '/')}:${i + 1}  $name.dispose()');
        }
      }
    }
    expect(bad, isEmpty,
        reason: 'These dispose a controller right after its route closes; '
            'wrap it in Future<void>.delayed(const Duration(milliseconds: '
            '600), x.dispose):\n${bad.join('\n')}');
  });

  test('no whenComplete(controller.dispose) on a sheet or dialog', () {
    final bad = <String>[];
    final re = RegExp(r'\.whenComplete\(\s*\w+\.dispose\s*\)');
    for (final f in lib) {
      final src = f.readAsStringSync();
      if (re.hasMatch(src)) bad.add(f.path.replaceAll('\\', '/'));
    }
    expect(bad, isEmpty,
        reason: '`.whenComplete(ctl.dispose)` frees the controller while the '
            'closing route still listens to it:\n${bad.join('\n')}');
  });
}
