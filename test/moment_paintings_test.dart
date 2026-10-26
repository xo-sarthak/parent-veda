// =============================================================================
//  Moment paintings (2026-10-26): every celebration page has its own painting,
//  with the phase painting it borrowed as the fallback until the file lands.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/v2/pv_moment_paintings.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  test('every shipped moment has its file on disk', () {
    for (final m in kMomentPaintings) {
      expect(File(m.assetPath).existsSync(), isTrue, reason: m.assetPath);
    }
  });

  test('the folder is in pubspec, so a file needs no pubspec change', () {
    expect(_code('pubspec.yaml'), contains('- assets/moments/'));
    expect(Directory('assets/moments').existsSync(), isTrue);
  });

  test('wiring gate: every celebration page passes its moment painting', () {
    const callers = {
      'lib/screens/v2/pv_celebration.dart': 'PvMoment.birth',
      'lib/screens/v2/pv_try_again.dart': 'PvMoment.tryAgain',
      'lib/screens/v2/pv_add_pregnancy.dart': 'PvMoment.newPregnancy',
      'lib/screens/skilling/sk_turning_six.dart': 'PvMoment.turningSix',
      'lib/screens/post_pregnancy/pp_milestones_screen.dart': 'PvMoment.milestone',
    };
    callers.forEach((path, moment) {
      expect(_code(path), contains('PvMomentPainting(moment: $moment'), reason: path);
    });
    // No caller left behind: every PvCelebrationScreen( in lib/ is one of them.
    final users = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => _code(f.path).contains('PvCelebrationScreen('))
        .map((f) => f.path.replaceAll('\\', '/'))
        .toSet();
    expect(users, callers.keys.toSet());
  });

  test('all five moments have landed (2026-10-26)', () {
    expect(kMomentPaintings, PvMoment.values.toSet());
  });

  testWidgets('a shipped moment draws its painting, not the fallback', (tester) async {
    const fallback = ColoredBox(key: ValueKey('fallback'), color: Colors.white);
    for (final m in PvMoment.values) {
      await tester.pumpWidget(
          MaterialApp(home: PvMomentPainting(moment: m, fallback: fallback)));
      expect(find.byKey(ValueKey('pv_moment_${m.file}')), findsOneWidget, reason: m.name);
      expect(find.byKey(const ValueKey('fallback')), findsNothing, reason: m.name);
    }
  });
}
