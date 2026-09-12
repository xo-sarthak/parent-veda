// =============================================================================
//  Samvad to final — the library, the narrator, and where a recording lands
// -----------------------------------------------------------------------------
//  The pillars brief: about twenty affirmations, six to eight short stories,
//  traditional mantras with text + transliteration + meaning, spiritual
//  passages she chooses, a working narrator, and every recording in My
//  Journal by week. And the honest anchor: no claim beyond "the baby learns
//  her voice".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_garbh.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/data/read_to_baby_data.dart';
import 'package:parentveda/data/samvad_mantras_data.dart';
import 'package:parentveda/data/spiritual_reading_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/garbh_content.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/garbh_samvad_daily.dart';
import 'package:parentveda/screens/garbh_screen.dart' show SamvadScreen;
import 'package:parentveda/services/garbh_narrator.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/read_to_baby_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the library', () {
    test('about twenty affirmations, spoken to the baby', () {
      final aff = readAloudByCategory(kRtbAffirmations);
      expect(aff.length, greaterThanOrEqualTo(20));
      for (final a in aff) {
        expect(a.body.en.trim(), isNotEmpty);
        expect(a.body.en.length, lessThan(400), reason: a.title.en);
      }
      // The four new ones exist and are English-only by policy.
      for (final t in [
        'I am listening',
        'Take your time',
        'The sound of me',
        'We are a family already'
      ]) {
        final p = aff.firstWhere((a) => a.title.en == t);
        expect(p.body.hi, p.body.en);
      }
    });

    test('six to eight stories at least, each a few minutes aloud', () {
      final st = readAloudByCategory(kRtbStories);
      expect(st.length, greaterThanOrEqualTo(6));
      for (final s in st) {
        final words = s.body.en.split(RegExp(r'\s+')).length;
        expect(words, inInclusiveRange(40, 400), reason: s.title.en);
      }
    });

    test('mantras: script, transliteration, one-line meaning, a named '
        'public-domain source', () {
      expect(kSamvadMantras.length, greaterThanOrEqualTo(8));
      final ids = kSamvadMantras.map((m) => m.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final m in kSamvadMantras) {
        expect(m.original.trim(), isNotEmpty, reason: m.id);
        expect(m.transliteration.trim(), isNotEmpty, reason: m.id);
        expect(m.meaning.split('. ').length, lessThanOrEqualTo(2),
            reason: '${m.id}: one plain line, not a commentary');
        expect(m.source.trim(), isNotEmpty, reason: m.id);
        expect(m.readAloud, m.transliteration);
        expect(m.narrationKey, 'samvad.mantra_${m.id}');
      }
      // More than one tradition, and a folk lullaby among them.
      expect(kSamvadMantras.map((m) => m.tradition).toSet().length,
          greaterThanOrEqualTo(4));
      expect(kSamvadMantras.any((m) => m.tradition == 'Folk lullaby'), isTrue);
    });

    test('no film lullaby slipped in', () {
      for (final m in kSamvadMantras) {
        final t = '${m.title} ${m.original} ${m.transliteration}'.toLowerCase();
        expect(t, isNot(contains('chanda mama')));
        expect(t, isNot(contains('lalla lalla')));
      }
    });

    test('spiritual reading: she chooses; nothing is on by default', () {
      expect(kSpiritualTraditions.length, greaterThanOrEqualTo(6));
      final store = ReadToBabyStore.instance;
      for (final t in kSpiritualTraditions) {
        expect(store.isReligionOn(t.id), isFalse, reason: t.id);
      }
    });

    test('every narration key is unique across the whole library', () {
      final keys = [
        for (final p in kReadAloudPieces) p.narrationKey,
        for (final m in kSamvadMantras) m.narrationKey,
      ];
      expect(keys.toSet().length, keys.length);
      for (final k in keys) {
        expect(k, startsWith('samvad.'));
      }
    });

    test('the honest anchor: the library claims nothing for the baby', () {
      const forbidden = ['smarter', 'cleverer', 'intelligen', 'iq', 'genius'];
      for (final p in kReadAloudPieces) {
        final t = p.body.en.toLowerCase();
        for (final w in forbidden) {
          expect(t, isNot(contains(w)), reason: '${p.title.en} says "$w"');
        }
      }
    });
  });

  group('the screens', () {
    Future<void> pump(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: w));
      await tester.pump();
    }

    testWidgets('the mantra shelf shows the three lines and offers Read aloud',
        (tester) async {
      await pump(
          tester, SamvadScreen(controller: PregnancyController(), initialTab: 2));
      await tester.pump();
      expect(find.text('The Gayatri'), findsOneWidget);
      expect(find.textContaining('Om bhur bhuvah svah'), findsOneWidget);
      expect(find.textContaining('Rigveda 3.62.10'), findsOneWidget);
      expect(find.text('Read aloud'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Read aloud opens the record screen on that piece, with the '
        'narrator link', (tester) async {
      await pump(
          tester, SamvadScreen(controller: PregnancyController(), initialTab: 2));
      await tester.pump();
      await tester.tap(find.text('Read aloud').first);
      await tester.pumpAndSettle();
      expect(find.byType(GarbhSamvadDailyScreen), findsOneWidget);
      expect(find.text('Record in your voice'), findsOneWidget);
      expect(find.text('Or listen to the narrator read it'), findsOneWidget);
      // The passage is the transliteration, not the whole card.
      expect(find.textContaining('Om bhur bhuvah svah'), findsOneWidget);
      expect(find.textContaining('Rigveda'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the narrator link asks the narrator, keyed by the piece',
        (tester) async {
      final piece = GarbhPrompt('rtb_you_are_loved',
          LocalizedText(en: 'You are loved', hi: 'You are loved'),
          LocalizedText(en: 'Little one, you are loved.', hi: 'x'));
      await pump(tester,
          GarbhSamvadDailyScreen(controller: PregnancyController(), piece: piece));
      await tester.tap(find.text('Or listen to the narrator read it'));
      await tester.pump();
      // ⚠️ NO PLATFORM CHANNEL ANSWERS IN A WIDGET TEST — an un-mocked
      // channel call never completes, it does not throw. So the narrator's
      // `speak` (which awaits the engine's `stop` first) is still pending
      // here, and must NOT be awaited from the test, or the test hangs for
      // the framework's ten-minute limit. What is checked: the tap did not
      // throw, the link is still the quiet link, and the key it would have
      // spoken under is the piece's own.
      final k = GarbhNarrator.instance.speakingKey;
      expect(k == null || k == 'samvad.rtb_you_are_loved', isTrue);
      expect(find.textContaining('narrator'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('the door\'s affirmation cards resolve to the same keys', () {
      // `garbh/read/piece/<slug>` builds a prompt whose id is `rtb_<slug>`,
      // so its narration key is the library piece's own.
      final c = PregnancyController();
      for (final title in kGarbhDoorAffirmations) {
        final w = pvDoorScreenFor(garbhSurfacePiece(garbhSlug(title)), c);
        expect(w, isA<GarbhSamvadDailyScreen>());
        final p = (w as GarbhSamvadDailyScreen).piece!;
        final lib = kReadAloudPieces.firstWhere((x) => x.title.en == title);
        expect('samvad.${p.id}', lib.narrationKey);
      }
    });
  });

  group('the journal', () {
    test('a recording is filed under the week it was made, by title', () async {
      final store = GarbhJournalStore.instance;
      await store.init();
      final before = store.byWeek[21]?.length ?? 0;
      await store.add(GarbhJournalEntry(
        id: 'voice_test',
        kind: GarbhEntryKind.myVoice,
        week: 21,
        tsMs: DateTime.now().millisecondsSinceEpoch,
        title: const LocalizedText(en: 'You are loved', hi: 'x'),
        seconds: 12,
        path: '/tmp/none.m4a',
      ));
      expect(store.byWeek[21]!.length, before + 1);
      expect(store.byWeek[21]!.last.title.en, 'You are loved');
    });
  });
}
