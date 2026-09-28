// One switch for the whole parent app (the user, 2026-09-28: "sometimes it's
// purple, sometimes it's black; keep it one, make it black"). The theme draws a
// switch black (ink) when on; no screen sets its own switch colours. The doctor
// app (lib/screens/doctor) keeps its own design.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no parent-app screen sets its own switch colours', () {
    final offenders = <String>[];
    final colourArg = RegExp(
        r'^\s*(activeTrackColor|activeThumbColor|inactiveTrackColor|inactiveThumbColor):');
    for (final f in Directory('lib/screens')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.replaceAll('\\', '/').contains('/doctor/'))) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (!colourArg.hasMatch(lines[i])) continue;
        // A slider's theme uses the same names; only switches count.
        final window = lines
            .sublist((i - 8).clamp(0, lines.length), i)
            .join('\n');
        if (window.contains('Switch')) {
          offenders.add('${f.path}:${i + 1} ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'a switch sets its own colour; the theme draws every switch '
            'black when on:\n${offenders.join('\n')}');
  });

  test('the theme draws a switch in ink when on', () {
    final theme = File('lib/theme/app_theme.dart').readAsStringSync();
    expect(theme, contains('? scheme.onSurface'));
    expect(theme, contains('trackOutlineColor'));
  });
}
