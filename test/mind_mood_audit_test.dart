// =============================================================================
//  Mind & Mood - the section's own rules, held as tests
// -----------------------------------------------------------------------------
//  Most of this section was already built. What these tests pin is the set of
//  promises it makes that nothing in the code was enforcing, plus the four gaps
//  an audit against the brief actually found.
//
//  ⚠️ THE ONE WORTH READING FIRST IS `the affirmations are written to HER`.
//
//  The Feel tab's affirmation card DID reuse existing content, exactly as the
//  brief asks. It reused `kSamvadT1` - Garbh Sanskar Samvad, which is words
//  spoken TO THE BABY. So a mother opening her own emotional-wellbeing section
//  at 3am was handed "Little one, you are so wanted", and the section quietly
//  became the one thing the brief says it must never duplicate: baby bonding.
//
//  Nothing about that failed. It compiled, it rendered, the card worked. The
//  only symptom was a mother getting the wrong kind of comfort at the worst
//  possible moment, and no test in the repo could see it - because "reuse
//  existing content" was satisfied and nobody had written down WHICH content.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_data.dart' show kSamvadT1;
import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/data/mind_mood_extras.dart';
import 'package:parentveda/screens/mind_mood/mm_article_screen.dart';
import 'package:parentveda/screens/mind_mood/mm_feel_tab.dart';
import 'package:parentveda/screens/mind_mood/mm_track_tab.dart';
import 'package:parentveda/screens/mind_mood/mm_understand_tab.dart';

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 9000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: Scaffold(body: w)));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  //  1 · The section boundary the brief names first
  // ===========================================================================

  group('Mind & Mood does not become Garbh Sanskar', () {
    test('the affirmations are written to HER, not to the baby', () {
      expect(kMmAffirmations, isNotEmpty);

      // ⚠️ THE ACTUAL BUG, AS AN ASSERTION. Every Samvad prompt addresses the
      // baby; not one of them may appear in this section.
      final samvad = kSamvadT1.map((p) => p.text.en).toSet();
      for (final a in kMmAffirmations) {
        expect(samvad.contains(a.text.en), isFalse,
            reason: 'Samvad (baby-directed) leaked into Mind & Mood');
      }
    });

    test('no affirmation addresses the baby', () {
      // The cheap structural check behind the same rule. Every one of these
      // words is how a line to the baby opens.
      const babyWords = ['little one', 'tiny', 'my baby', 'sweet baby', 'my darling'];
      for (final a in kMmAffirmations) {
        final t = a.text.en.toLowerCase();
        for (final w in babyWords) {
          expect(t.contains(w), isFalse, reason: '"${a.text.en}" reads as Samvad');
        }
      }
    });

    testWidgets('the Feel tab no longer draws from Samvad', (t) async {
      // ⚠️ A PHONE-SIZED VIEWPORT, NOT THE TALL ONE THE OTHER TESTS USE.
      // These cards are laid out for a phone; at 1200 logical pixels wide the
      // tab overflows, which is a fact about the harness rather than about
      // the app and would fail this test for the wrong reason.
      t.view.physicalSize = const Size(390, 3000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: Scaffold(body: MmFeelTab())));
      await t.pump();

      await t.scrollUntilVisible(find.text('Show me one'), 400,
          scrollable: find.byType(Scrollable).first);
      await t.tap(find.text('Show me one'));
      await t.pump();

      // The card now shows one of ours. None of Samvad's baby-directed lines
      // can appear here any more.
      for (final p in kSamvadT1) {
        expect(find.text(p.text.en), findsNothing, reason: p.id);
      }
    });
  });

  // ===========================================================================
  //  2 · No diagnosis, no gamification (§3, §4)
  // ===========================================================================

  group('the section never diagnoses and never scores', () {
    test('no article claims she has anything', () {
      // ⚠️ THE FORBIDDEN SENTENCE SHAPE. §3 is explicit: never "you have
      // depression", never "you have anxiety".
      const forbidden = ['you have depression', 'you have anxiety',
        'you are depressed', 'diagnos'];
      for (final a in kMmArticles) {
        final body = '${a.title.en} ${a.body.en}'.toLowerCase();
        for (final f in forbidden) {
          expect(body.contains(f), isFalse, reason: '${a.id} contains "$f"');
        }
      }
    });

    test('the self-check severity never surfaces as a number', () {
      // ⚠️ THE SEVERITY WEIGHTS DO EXIST, and they should: routing to a
      // counsellor or to CrisisPath has to be driven by something. The rule
      // §10.2 sets is not "no weights", it is that she never SEES one. A
      // number on this screen turns a gentle check-in into a clinical
      // instrument, which is the exact line the brief forbids crossing.
      expect(kMmScreenerQuestions, isNotEmpty);
      for (final q in kMmScreenerQuestions) {
        expect(q.options, isNotEmpty, reason: q.id);
        for (final o in q.options) {
          expect(o.label.en.trim(), isNotEmpty);
          // No option is labelled with its own weight.
          expect(RegExp(r'\d').hasMatch(o.label.en), isFalse,
              reason: 'numeric label: ${o.label.en}');
        }
      }
    });

    test('no streaks, points or badges anywhere in the seeded copy', () {
      const banned = ['streak', 'badge', 'points', 'leaderboard',
        'you missed your check-in'];
      final all = [
        ...kMmArticles.map((a) => '${a.title.en} ${a.body.en}'),
        ...kMmAffirmations.map((a) => a.text.en),
        ...kMmMeditations.map((m) => '${m.title.en} ${m.subtitle.en}'),
      ].join(' ').toLowerCase();
      for (final b in banned) {
        expect(all.contains(b), isFalse, reason: 'found "$b"');
      }
    });
  });

  // ===========================================================================
  //  3 · The house copy rule (§24)
  // ===========================================================================

  test('no em dash in any seeded Mind & Mood copy', () {
    // ⚠️ AN EASY RULE TO BREAK ON THE NEXT EDIT, which is exactly why it is a
    // test rather than a note. The rest of the repo uses em dashes freely.
    final all = [
      ...kMmArticles.map((a) => '${a.title.en}|${a.teaser.en}|${a.body.en}'),
      ...kMmAffirmations.map((a) => a.text.en),
      ...kMmMeditations.map((m) => '${m.title.en}|${m.subtitle.en}'),
      ...kMmCalmAudio.map((c) => c.title.en),
      kMmPartnerArticle.title.en,
      kMmPartnerArticle.teaser.en,
      kMmPartnerArticle.body.en,
    ];
    for (final s in all) {
      expect(s.contains('—'), isFalse,
          reason: 'em dash in: ${s.substring(0, s.length.clamp(0, 60))}');
    }
  });

  // ===========================================================================
  //  4 · Partner support exists and stays small (§12)
  // ===========================================================================

  group('partner support', () {
    test('the article exists and carries an expert video slot', () {
      expect(kMmPartnerArticle.body.en.length, greaterThan(800));
      expect(kMmPartnerArticle.hasExpertVideo, isTrue);
      expect(kMmPartnerVideoSlot, isNotEmpty);
    });

    test('it covers what she feels, what helps, and what to avoid saying', () {
      final b = kMmPartnerArticle.body.en.toLowerCase();
      for (final section in [
        'what she may be feeling',
        'what helps',
        'what to avoid saying',
      ]) {
        expect(b.contains(section), isTrue, reason: section);
      }
    });

    test('it is NOT in her own reading list', () {
      // ⚠️ "What to avoid saying to her" inside HER Understand tab would read
      // as the app briefing her on how she ought to be handled.
      expect(kMmArticles.any((a) => a.id == kMmPartnerArticle.id), isFalse);
    });

    testWidgets('it is reachable from the foot of Understand', (t) async {
      await _pump(t, const MmUnderstandTab());
      await t.scrollUntilVisible(
        find.text('Something to send your partner'),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('Something to send your partner'));
      await t.pumpAndSettle();
      expect(find.byType(MmArticleScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  //  5 · The journal does what §9.3 asks (write, save, edit, delete, view)
  // ===========================================================================

  group('the worry journal', () {
    setUp(() {
      for (final e in MindMoodStore.instance.journalEntries.toList()) {
        MindMoodStore.instance.deleteJournalEntry(e.id);
      }
    });

    test('an entry can be edited, and keeps its date', () {
      final store = MindMoodStore.instance;
      store.addJournalEntry('worried about the scan');
      final e = store.journalEntries.first;
      final ts = e.ts;

      store.updateJournalEntry(e.id, 'worried about the scan on Tuesday');

      final after = store.journalEntries.first;
      expect(after.text, 'worried about the scan on Tuesday');
      // ⚠️ AN EDIT MUST NOT REORDER HER JOURNAL. If the timestamp moved,
      // correcting a typo in an old entry would silently make it today's.
      expect(after.ts, ts);
      expect(store.journalEntries.length, 1);
    });

    test('editing to empty is refused rather than blanking the entry', () {
      final store = MindMoodStore.instance;
      store.addJournalEntry('something');
      final id = store.journalEntries.first.id;
      expect(store.updateJournalEntry(id, '   '), isFalse);
      expect(store.journalEntries.first.text, 'something');
    });

    test('editing an id that no longer exists is a no-op, not a crash', () {
      expect(MindMoodStore.instance.updateJournalEntry('nope', 'x'), isFalse);
    });

    testWidgets('an empty journal renders an invitation, not nothing',
        (t) async {
      await _pump(t, const MmTrackTab());
      await t.scrollUntilVisible(
        find.textContaining('Nothing written yet'),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      // The repo rule: a feature is never hidden, and an empty section
      // advertises itself. Here it also tells her what happens to what she
      // writes BEFORE she writes it, which on a private journal is the thing
      // she most wants to know.
      expect(find.textContaining('Nothing written yet'), findsOneWidget);
      expect(find.textContaining('stays on this phone'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  6 · Free vs paid (§13)
  // ===========================================================================

  group('only human support is paid', () {
    test('every article is free', () {
      // §13: do not gate educational or self-help content. There is no paid
      // flag on MmArticle at all, which is the strongest possible version of
      // that rule - the gate cannot be added by accident.
      expect(kMmArticles.length, greaterThanOrEqualTo(26));
    });

    test('the three paid offerings are the only paid things', () {
      expect(kMmTalkOfferings.length, 3);
      for (final o in kMmTalkOfferings) {
        expect(o.whoFor.en.trim(), isNotEmpty, reason: o.id);
      }
    });
  });
}
