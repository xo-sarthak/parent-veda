// =============================================================================
//  Base UI follow-ups on shared surfaces (2026-09-29)
// -----------------------------------------------------------------------------
//  Three shared pieces still wore the old violet or lavender look after the
//  "one app" pass, and every stage shows them:
//    1. the reward celebration sheet (opens over Invite and Birth Club);
//    2. the employer-benefit activation flow and its `EnterpriseButton`;
//    3. `PvWell` lavender slabs in profile (Partner, the addresses sheet);
//    4. the review quote card (`PvReviewRail`), on the product page and Learn.
//  THE RULES they now hold (memory: one-button-style-and-contrast): one
//  button colour, the switches' black #2F2C30 (`AppTheme.neutral900`), in a
//  pill; drawn marks from the door family, not Material glyphs in tinted
//  squares; and no tinted slab behind text.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/enterprise/activation_flow_screen.dart';
import 'package:parentveda/screens/enterprise/enterprise_common.dart';
import 'package:parentveda/screens/products/pv_review_block.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/referral/reward_celebration.dart';
import 'package:parentveda/screens/ttc/doors/ttc_tab_art.dart';
import 'package:parentveda/theme/app_theme.dart';

/// Live lines only: `//` comments dropped.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .map((l) => l.split(RegExp(r'(?<!:)//')).first)
    .join('\n');

Future<void> _phone(WidgetTester tester, Widget w, {double scale = 1}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: w,
  ));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  group('1. the reward celebration', () {
    Future<void> open(WidgetTester tester, {double scale = 1}) async {
      await _phone(
        tester,
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showRewardCelebration(ctx,
                    title: 'You earned 1 free consultation',
                    body: 'A friend you invited finished setting up.',
                    footnote: 'It is on your profile under Bookings.'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        scale: scale,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
    }

    testWidgets('a white sheet, a drawn mark, the one ink pill',
        (tester) async {
      await open(tester);
      final sheet = tester.widget<Container>(find
          .ancestor(
              of: find.text('You earned 1 free consultation'),
              matching: find.byType(Container))
          .last);
      expect((sheet.decoration! as BoxDecoration).color, Colors.white);
      expect(find.byType(TtcTabArt), findsOneWidget,
          reason: 'the Invite page\'s drawn mark, not a Material gift');
      expect(find.byIcon(Icons.card_giftcard_rounded), findsNothing);
      final button = tester.widget<Material>(find.byKey(kRewardDoneKey));
      expect(button.color, AppTheme.neutral900);
      expect(button.shape, isA<StadiumBorder>());
      // The footnote is a line on the white, not in a slab.
      final foot = find.text('It is on your profile under Bookings.');
      for (final el in find
          .ancestor(of: foot, matching: find.byType(Container))
          .evaluate()) {
        final d = (el.widget as Container).decoration;
        if (d is BoxDecoration && d.color != null) {
          expect(d.color, Colors.white,
              reason: 'the footnote sits on a tinted slab');
        }
      }
      await tester.tap(find.byKey(kRewardDoneKey));
      await tester.pumpAndSettle();
      expect(find.text('You earned 1 free consultation'), findsNothing);
    });

    testWidgets('no overflow at 360dp and 1.5x', (tester) async {
      await open(tester, scale: 1.5);
      expect(tester.takeException(), isNull);
    });

    test('no violet left in the live source', () {
      final src = _code('lib/screens/referral/reward_celebration.dart');
      for (final bad in ['7C3FC4', '9B6FDD', 'ppPurple', 'ppBg', 'ppPanel']) {
        expect(src.contains(bad), isFalse, reason: bad);
      }
    });
  });

  // ===========================================================================
  group('2. the activation flow', () {
    testWidgets('EnterpriseButton is the ink pill', (tester) async {
      await _phone(
          tester,
          Scaffold(
              body: EnterpriseButton(label: 'Continue', onTap: () {})));
      final m = tester.widget<Material>(find
          .descendant(
              of: find.byType(EnterpriseButton),
              matching: find.byType(Material))
          .first);
      expect(m.color, AppTheme.neutral900);
      expect(m.shape, isA<StadiumBorder>());
      expect(tester.widget<Text>(find.text('Continue')).style?.color,
          Colors.white);
    });

    testWidgets('white, a drawn mark, no violet, and it fits at 1.5x',
        (tester) async {
      await _phone(tester, const ActivationFlowScreen(), scale: 1.5);
      expect(tester.takeException(), isNull);
      final s = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(s.backgroundColor, Colors.white);
      expect(find.byType(TtcTabArt), findsOneWidget,
          reason: 'each step leads with a drawn mark');
      expect(find.text('What your employer never sees'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    test('no violet or lilac in the live source', () {
      final src = _code('lib/screens/enterprise/activation_flow_screen.dart');
      for (final bad in [
        'primary600',
        'primary100',
        'surfaceContainer',
        'EnterpriseCard(',
      ]) {
        expect(src.contains(bad), isFalse, reason: bad);
      }
      final common = _code('lib/screens/enterprise/enterprise_common.dart');
      final button = common.substring(
          common.indexOf('class EnterpriseButton'),
          common.indexOf('class EnterpriseNotice'));
      expect(button.contains('primary600'), isFalse);
    });
  });

  // ===========================================================================
  group('3. no PvWell slab in profile', () {
    test('every profile screen is off PvWell', () {
      for (final e in Directory('lib/screens/profile').listSync()) {
        if (e is! File || !e.path.endsWith('.dart')) continue;
        expect(_code(e.path).contains('PvWell('), isFalse,
            reason: '${e.path} draws text on the lavender slab');
      }
    });
  });

  // ===========================================================================
  group('4. review quote cards', () {
    const voices = [
      PvReviewVoice(
          name: 'Asha R.',
          context: 'Trying for a year',
          quote: 'The one place that told me what to actually do next.'),
      PvReviewVoice(
          name: 'Meera K.',
          context: 'First baby',
          quote: 'Short, kind and it said when to see a doctor.'),
    ];

    for (final n in [1, 2]) {
      testWidgets('$n card${n == 1 ? '' : 's'}: white with a hairline',
          (tester) async {
        await _phone(
            tester,
            Scaffold(
                body: ListView(children: [
              PvReviewRail(voices: voices.take(n).toList()),
            ])));
        final cards = find.byKey(const ValueKey('pv_review_voice_card'));
        expect(cards, findsNWidgets(n));
        for (final el in cards.evaluate()) {
          final d = (el.widget as Container).decoration! as BoxDecoration;
          expect(d.color, Colors.white);
          expect((d.border! as Border).top.color, kPvLine);
        }
      });
    }
  });
}
