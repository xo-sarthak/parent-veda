// =============================================================================
//  The Ask Veda reveal (2026-10-10): the answer types in, a tap finishes it,
//  reduced motion shows it at once, and an answer seen before never types
//  again. Plus the follow-up picker and the fade-in that follows the text.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/ask_veda/pv_veda_reveal.dart';

const _long = 'Round ligament pain is a sharp pull low in the belly that many '
    'women feel in the second trimester as the uterus grows. It usually '
    'passes in a few seconds. Changing position slowly, a warm bath and '
    'rest can help. If the pain is constant, or comes with bleeding or '
    'fever, call your doctor.';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: ListView(children: [child])),
      ),
    );

void main() {
  setUp(pvVedaResetRevealed);

  testWidgets('it types in, then shows the whole text and says so once',
      (t) async {
    var done = 0;
    await t.pumpWidget(_host(PvTypewriterText(_long,
        style: const TextStyle(fontSize: 14), onDone: () => done++)));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text(_long), findsNothing, reason: 'should still be typing');
    expect(done, 0);

    await t.pump(const Duration(seconds: 3));
    await t.pump();
    expect(find.text(_long), findsOneWidget);
    expect(done, 1);

    // A rebuild does not type it again, nor call back again.
    await t.pumpWidget(_host(PvTypewriterText(_long,
        style: const TextStyle(fontSize: 14), onDone: () => done++)));
    await t.pump();
    expect(find.text(_long), findsOneWidget);
    expect(done, 1);
  });

  testWidgets('a tap finishes it at once', (t) async {
    var done = 0;
    await t.pumpWidget(_host(PvTypewriterText(_long,
        style: const TextStyle(fontSize: 14), onDone: () => done++)));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text(_long), findsNothing);
    await t.tap(find.byKey(const ValueKey('pv_typewriter')));
    await t.pump();
    await t.pump();
    expect(find.text(_long), findsOneWidget);
    expect(done, 1);
  });

  testWidgets('reduced motion shows it instantly', (t) async {
    var done = 0;
    await t.pumpWidget(_host(
        PvTypewriterText(_long,
            style: const TextStyle(fontSize: 14), onDone: () => done++),
        reduceMotion: true));
    expect(find.text(_long), findsOneWidget);
    await t.pump();
    expect(done, 1);
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('an answer seen before shows instantly the next time',
      (t) async {
    await t.pumpWidget(_host(
        PvTypewriterText(_long, style: const TextStyle(fontSize: 14))));
    await t.pump(const Duration(seconds: 4));
    expect(pvVedaAlreadyRevealed(_long), isTrue);

    // A fresh widget (the cached answer opened again) does not retype.
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(_host(PvTypewriterText(_long,
        key: UniqueKey(), style: const TextStyle(fontSize: 14))));
    expect(find.text(_long), findsOneWidget);
  });

  testWidgets('what follows fades in only when told, and stays tappable',
      (t) async {
    var taps = 0;
    Widget page(bool show) => _host(PvVedaFadeIn(
          show: show,
          index: 2,
          child: TextButton(onPressed: () => taps++, child: const Text('card')),
        ));
    await t.pumpWidget(page(false));
    double opacity() =>
        t.widget<Opacity>(find.ancestor(
            of: find.text('card'), matching: find.byType(Opacity))).opacity;
    expect(opacity(), 0);
    await t.tap(find.text('card'));
    expect(taps, 1, reason: 'a hidden card must never be dead to a tap');

    await t.pumpWidget(page(true));
    await t.pump(const Duration(seconds: 1));
    expect(opacity(), 1);
  });

  testWidgets('the thinking state holds still under reduced motion',
      (t) async {
    await t.pumpWidget(_host(
        const PvVedaThinking(
          lines: ['Looking through ParentVeda…', 'Putting it together…'],
          color: Colors.black,
          textStyle: TextStyle(fontSize: 14),
        ),
        reduceMotion: true));
    expect(find.text('Looking through ParentVeda…'), findsOneWidget);
    expect(t.hasRunningAnimations, isFalse);
  });

  test('all three Ask Veda screens use the reveal (wiring gate)', () {
    for (final f in [
      'lib/screens/tools/ask_veda_screen.dart',
      'lib/screens/post_pregnancy/askveda_screen.dart',
      'lib/screens/ttc/ttc_askveda_screen.dart',
    ]) {
      final src = File(f).readAsStringSync();
      for (final needle in [
        'PvTypewriterText(answer',
        'PvVedaThinking(',
        'PvVedaFadeIn(',
        'pvVedaFollowUps(',
      ]) {
        expect(src, contains(needle), reason: '$f: $needle');
      }
    }
  });

  test('follow-ups leave out the question asked and lead with related ones',
      () {
    final got = pvVedaFollowUps('Is papaya safe in pregnancy?', [
      'Is papaya safe in pregnancy?',
      'How much water should I drink?',
      'Which fruits are safe in pregnancy?',
      'When do I feel kicks?',
    ]);
    expect(got, isNot(contains('Is papaya safe in pregnancy?')));
    expect(got.first, 'Which fruits are safe in pregnancy?');
    expect(got.length, 3);
  });
}
