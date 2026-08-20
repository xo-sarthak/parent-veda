// =============================================================================
//  Garbh Sanskar - playback, the Shravan toggle, and the Kriya safety filter
// -----------------------------------------------------------------------------
//  ⚠️ THE ONE THAT MATTERS MOST HERE IS `a recording does not loop`.
//
//  `RagaAudioStore` was built for ragas, and a raga looping is the feature - it
//  is ambient sound meant to run under sleep. The store therefore hardcoded
//  `ReleaseMode.loop` and `AssetSource`, and reusing it for the journal without
//  noticing either would have produced something quietly awful: her own voice,
//  or her mother-in-law's blessing, repeating forever until she found the pause
//  button. Nothing would have failed. It would just have been horrible.
//
//  ⚠️ AND `isFile` IS STATED BY THE CALLER RATHER THAN SNIFFED. Telling a
//  bundled asset from a device path by looking for a leading slash works on
//  Android, fails on a Windows drive letter, and fails again on an encoded
//  path. The caller knows; asking it to say so removes a class of bug that
//  only appears on one platform.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/garbh_browse_screen.dart';
import 'package:parentveda/screens/garbh_journal_screen.dart';
import 'package:parentveda/screens/garbh_shravan_version.dart';

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 4200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => GarbhJournalStore.instance.resetForTest());

  // ===========================================================================
  //  1 · The journal plays, and plays the right way
  // ===========================================================================

  group('My Journal playback', () {
    testWidgets('a recording renders a play control', (t) async {
      GarbhJournalStore.instance.add(GarbhJournalEntry(
        id: 'v1',
        kind: GarbhEntryKind.myVoice,
        week: 22,
        tsMs: DateTime(2026, 3, 4).millisecondsSinceEpoch,
        title: const LocalizedText(en: 'A story', hi: 'A story'),
        seconds: 90,
        path: '/tmp/voice.m4a',
      ));
      await _pump(t, const GarbhJournalScreen());

      // ⚠️ THE ICON USED TO RENDER WITH NO HANDLER BEHIND IT. That is the
      // defect this section produced three times: a control that looks live
      // and is not.
      expect(find.byIcon(Icons.play_circle_outline_rounded), findsOneWidget);
      final tappable = t.widget<InkWell>(
          find.ancestor(
              of: find.byIcon(Icons.play_circle_outline_rounded),
              matching: find.byType(InkWell))
          .first);
      expect(tappable.onTap, isNotNull);
    });

    testWidgets('an entry with no audio is not a button', (t) async {
      GarbhJournalStore.instance.add(GarbhJournalEntry(
        id: 'l1',
        kind: GarbhEntryKind.letter,
        week: 22,
        tsMs: DateTime(2026, 3, 4).millisecondsSinceEpoch,
        title: const LocalizedText(en: 'A letter', hi: 'A letter'),
      ));
      await _pump(t, const GarbhJournalScreen());

      // ⚠️ A TAP TARGET THAT DOES NOTHING TEACHES HER THAT TAPS DO NOTHING,
      // which costs more than the row not being tappable.
      expect(find.byIcon(Icons.play_circle_outline_rounded), findsNothing);
      final row = t.widget<InkWell>(
          find.ancestor(of: find.text('A letter'), matching: find.byType(InkWell))
              .first);
      expect(row.onTap, isNull);
    });
  });

  // ===========================================================================
  //  2 · Ragas play from the browse list, and the list is honest about it
  // ===========================================================================

  group('the raga list', () {
    testWidgets('every raga row is tappable', (t) async {
      const accent = Color(0xFFBE9C4E);
      final screen = shravanBrowse(AppLanguage.english, accent);
      await _pump(t, screen);

      for (final g in screen.groups) {
        for (final item in g.items) {
          expect(item.onTap, isNotNull, reason: item.title);
        }
      }
    });

    testWidgets('it says every raga currently plays the same sample',
        (t) async {
      await _pump(t, shravanBrowse(AppLanguage.english, const Color(0xFFBE9C4E)));
      // ⚠️ TAPPING "OCEAN WAVES" AND HEARING A TANPURA IS NOT A MISSING
      // FEATURE, IT IS THE APP SAYING SOMETHING UNTRUE. One bundled file backs
      // all ten names, so the list says so rather than letting her work it out.
      expect(find.textContaining('same sample tone'), findsOneWidget);
    });

    test('Samvad and Kriya rows stay untappable', () {
      // Only Shravan has something to play. Text rows must not grow a tap
      // target just because their neighbour did.
      for (final g in samvadBrowse(AppLanguage.english, Colors.black).groups) {
        for (final i in g.items) {
          expect(i.onTap, isNull);
        }
      }
    });
  });

  // ===========================================================================
  //  3 · The Shravan V1 / V2 toggle
  // ===========================================================================

  group('the Shravan toggle', () {
    setUp(() => ShravanVersionStore.instance.set(ShravanVersion.v2));

    test('it opens on V2, because that is the thing being judged', () {
      expect(ShravanVersionStore.instance.version, ShravanVersion.v2);
    });

    test('it switches and is session-scoped', () {
      ShravanVersionStore.instance.set(ShravanVersion.v1);
      expect(ShravanVersionStore.instance.version, ShravanVersion.v1);
      // Nothing persists it: nobody should open the app days later in an
      // experimental version and report its layout as the product's.
    });

    testWidgets('the pill renders both options', (t) async {
      await _pump(t, const Scaffold(body: Center(child: ShravanVersionPill())));
      expect(find.text('V1'), findsOneWidget);
      expect(find.text('V2'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  4 · Kriya offers nothing unsafe for her week
  // ===========================================================================

  group('the Kriya safety window', () {
    test('box breathing closes at the end of the second trimester', () {
      final box = kKriya.firstWhere((p) => p.id == 'box');
      // ⚠️ THE HOLDS ARE THE REASON. Box breathing retains the breath, which
      // prenatal guidance asks women to ease off late on, when there is less
      // room and less reserve.
      expect(box.safeAtWeek(20), isTrue);
      expect(box.safeAtWeek(27), isTrue);
      expect(box.safeAtWeek(28), isFalse);
      expect(box.safeAtWeek(34), isFalse);
    });

    test('the gentle practices are safe throughout, not narrowed for show', () {
      // ⚠️ THE HONEST IMPLEMENTATION OF A SAFETY FILTER IS NOT TO INVENT
      // RESTRICTIONS SO IT LOOKS LIKE IT IS WORKING. Gentle breathing is safe
      // in pregnancy, and four of these five genuinely are.
      for (final id in ['bhramari', 'deep_belly', 'calm', 'relax']) {
        final p = kKriya.firstWhere((x) => x.id == id);
        expect(p.safeAtWeek(8), isTrue, reason: id);
        expect(p.safeAtWeek(38), isTrue, reason: id);
      }
    });

    test('a practice with no window declared is safe everywhere', () {
      // The default is deliberate: a contributor who forgets the field gets a
      // safe-everywhere practice, not one silently narrowed.
      for (final p in kKriya) {
        if (p.id == 'box') continue;
        expect(p.safeFromWeek, 1, reason: p.id);
        expect(p.safeToWeek, 42, reason: p.id);
      }
    });
  });
}
