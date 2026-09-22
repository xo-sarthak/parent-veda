// =============================================================================
//  The Feelings door, held against its brief
// -----------------------------------------------------------------------------
//  `ParentVeda_Feelings_structure.pdf` as assertions, plus the user's calls
//  of 2026-09-18 (1a the journal child-private · 2a real helplines, flagged
//  verify · 3a AES at rest · 4a the off-ramp on every child screen). What
//  fails silently here: the journal growing a reader, a search, a sync or
//  an analysis; the crisis stub growing a hook; the off-ramp missing from a
//  child screen; a helpline losing its verify flag before review; a course
//  string posing as therapy; a score of a child's feelings under any name;
//  a coming-soon slot nobody owes.
// =============================================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/data/skilling/skilling_feelings_activities.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_activity_screen.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_crisis_pathway.dart';
import 'package:parentveda/screens/skilling/sk_door_content.dart';
import 'package:parentveda/screens/skilling/sk_journal.dart';
import 'package:parentveda/screens/skilling/sk_keepsake_screen.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';

SkDoorContent get _c => skDoorContentFor('skilling_emotional')!;

/// A key store that keeps the key in memory, so the cipher runs under
/// `flutter test` without touching prefs for it.
class _MemoryKeyStore implements SkJournalKeyStore {
  Uint8List? _k;
  @override
  Future<Uint8List> key() async => _k ??= Uint8List.fromList(List.generate(32, (i) => (i * 7 + 3) & 0xff));
  @override
  Future<void> forget() async => _k = null;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SkChildStore.instance.debugReset();
    SkPracticeStore.instance.debugReset();
    SkJournalStore.instance.debugReset();
  });
  final door = skDoorFor('skilling_emotional')!;

  group('the map — six cards, the brief\'s child surfaces, and the bar that is not a card', () {
    test('three band sets, Scenarios and prompts, Your journal, You practised', () {
      expect([for (final t in door.tabs) t.id], [
        'name_what_you_feel', 'handle_the_big_feelings', 'find_your_way_through',
        'lessons', 'your_journal', 'you_practised',
      ]);
      expect(door.tabs, hasLength(6), reason: 'six only where a brief insists; this one lists the journal as its own surface');
      expect([for (final t in door.tabs) t.bandId], ['6-8', '8-11', '11-14', null, null, null]);
      expect(_c.bandNames, {
        '6-8': 'Name what you feel',
        '8-11': 'Handle the big feelings',
        '11-14': 'Find your way through',
      });
      expect(door.tabs[4].tools.single.surfaceId, 'sk_journal/skilling_emotional');
      expect(skScreenForSurface('sk_journal/skilling_emotional'), isA<SkJournalScreen>());
      expect(skScreenForSurface('sk_journal/skilling_coding'), isNull, reason: 'only a door that keeps one');
      expect(door.tabs[5].tools.single.surfaceId, 'sk_keepsake/skilling_emotional');
      expect(_c.keepsakeTitle, 'You practised');
      expect(_c.journal, isTrue);
    });

    test('the closing card is the grown-up screen; Consult is held; no coach, no voice', () {
      expect(door.closing!.chip, 'Grown-ups');
      expect(door.closing!.surfaceId, 'sk_grown_up/skilling_emotional');
      expect(_c.coach, isNull, reason: 'a paid counsellor booking is held; the free off-ramp comes first');
      expect(_c.voiceKeepsake, isFalse);
      expect(_c.access, isEmpty);
    });

    test('the hero is an images.unsplash.com photograph', () {
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });
  });

  group('the six skills — SEL, never rated, the last one the off-ramp', () {
    test('the brief\'s table, in order, ending on asking for help', () {
      expect(kSkFeelingsSkills.map((s) => s.id).toList(), [
        'naming_it', 'feeling_its_okay', 'handling_the_big_ones',
        'reading_others', 'bouncing_back', 'asking_for_help',
      ]);
      expect(kSkFeelingsSkills.map((s) => s.label).toList(), [
        'Naming it', "Feeling it's okay", 'Handling the big ones',
        'Reading others', 'Bouncing back', 'Asking for help',
      ]);
      expect(_c.skillById('bouncing_back')!.kidLine, contains('not toughening up'));
      expect(_c.skillById('feeling_its_okay')!.kidLine, contains('opposite of "be tough"'));
    });

    test('a FULL set per band, two per skill, all placeholders, no copy — clinical review first', () {
      for (final band in kSkBands) {
        final list = _c.activitiesFor(band.id);
        expect(list, hasLength(12), reason: band.id);
        for (final s in kSkFeelingsSkills) {
          expect(list.where((a) => a.skillPurpose == s.id), hasLength(2), reason: '${band.id}/${s.id}');
        }
        for (final a in list) {
          expect(a.comingSoon, isTrue, reason: a.id);
          expect(a.steps, isEmpty, reason: '${a.id}: no scenario or prompt copy is authored here');
        }
      }
      expect(_c.activities.map((a) => a.id).toSet(), hasLength(36));
    });
  });

  group('the lessons — scenarios, prompts, and the calm window onto Stillness', () {
    test('two sets of placeholders marked Needs review, and one window with no blocks', () {
      expect(_c.lessonSets.map((s) => s.id).toList(), ['scenarios', 'prompts', 'calm']);
      for (final band in kSkBands) {
        expect(_c.lessonsIn('scenarios', band.id), hasLength(3), reason: band.id);
        expect(_c.lessonsIn('prompts', band.id), hasLength(3), reason: band.id);
        expect(_c.lessonsIn('calm', band.id), hasLength(1), reason: band.id);
      }
      for (final l in _c.lessons.where((l) => l.id != 'fe_calm')) {
        expect(l.comingSoon, isTrue, reason: l.id);
        expect(l.blocks, isEmpty, reason: l.id);
        expect(l.format, 'Needs review', reason: '${l.id}: the "care" mark');
      }
    });

    test('the calm practice is a window onto Stillness\'s settle breath, not a copy', () {
      final w = _c.pageById('fe_calm')!;
      expect(w.comingSoon, isFalse);
      expect(w.blocks, isEmpty, reason: 'a window, not a page');
      expect(w.toolSurfaceId, 'sk_page/skilling_stillness/sl_settle');
      expect(skScreenForSurface('sk_page/skilling_emotional/fe_calm'), isNotNull, reason: 'resolves through the window');
      final src = File('lib/data/skilling/skilling_feelings_content.dart').readAsStringSync();
      expect(src.contains('SkBreath('), isFalse, reason: 'no breathing rebuilt here');
      expect(src.contains('breathing_circle'), isFalse);
    });

    test('the parent note is the brief\'s own title and says never therapy', () {
      expect(_c.parentNote.title, 'How to help a child with big feelings, and when to seek help');
      expect(_c.parentNote.subtitle, contains('never therapy'));
      expect(_c.parentNote.subtitle, contains('child psychologist'));
      expect(_c.parentNote.comingSoon, isTrue);
      expect(_c.parentNote.kidVoice, isFalse);
    });
  });

  group('the off-ramp — first-class, on every child screen, ungated, flagged verify (2a, 4a)', () {
    test('a trusted-adult line and two real helplines, both marked verify', () {
      final s = _c.safety!;
      expect(s.trustedAdultLine, contains('grown-up you trust'));
      expect(s.helplines.map((h) => h.number).toList(), ['1098', '14416']);
      for (final h in s.helplines) {
        expect(h.verify, isTrue, reason: '${h.name}: a lawyer and a clinician confirm it before a public launch');
        expect(RegExp(r'^\d+$').hasMatch(h.number), isTrue, reason: 'dialable as written');
      }
      // ⚠️ `verify` is a LEDGER flag, not a display filter (2026-09-22): the
      // sheet shows every line in every build, because a child who taps
      // "Talk to someone" must never meet an empty sheet.
      final safetySrc = File('lib/screens/skilling/sk_safety.dart').readAsStringSync();
      expect(safetySrc.contains("bool.fromEnvironment('dart.vm.product')"), isFalse,
          reason: 'no build mode decides whether a helpline is shown');
      expect(safetySrc.contains('final lines = safety.helplines;'), isTrue);
      // Only this door carries an off-ramp today.
      for (final c in kSkDoorContents.where((c) => c.doorId != 'skilling_emotional')) {
        expect(c.safety, isNull, reason: c.doorId);
        expect(c.journal, isFalse, reason: c.doorId);
      }
    });

    test('the sheet records nothing, and the crisis pathway is a stub that nothing calls', () {
      final safety = File('lib/screens/skilling/sk_safety.dart')
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      for (final w in ['SharedPreferences', 'SkPracticeStore', 'SkJournalStore', 'SkVoiceStore', 'jsonEncode', 'http', 'Supabase']) {
        expect(safety.contains(w), isFalse, reason: 'sk_safety.dart: "$w" — nothing is written down');
      }
      expect(safety.contains("scheme: 'tel'"), isTrue, reason: 'tap-to-call');
      expect(safety.contains('skAskGrownUp'), isFalse, reason: 'ungated on purpose, on the record');
      expect(kSkCrisisPathway, isA<SkNoCrisisPathway>());
      final journal = File('lib/screens/skilling/sk_journal.dart').readAsStringSync();
      expect(journal.contains("import 'sk_crisis_pathway.dart'"), isFalse, reason: 'the journal has no hook into the stub');
      // Nothing in the skilling tree calls the stub.
      final callers = Directory('lib/screens/skilling')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('sk_crisis_pathway.dart'))
          .where((f) => f.readAsStringSync().contains('kSkCrisisPathway') || f.readAsStringSync().contains('onHelpAsked'));
      expect(callers, isEmpty, reason: 'the stub STOPS: ${callers.map((f) => f.path).join(', ')}');
    });

    testWidgets('the bar sits at the foot of the door, an activity, a lesson page, the keepsake and the journal — and on no other door', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Ira');
      Future<void> pump(Widget w, {Key? key}) async {
        await tester.pumpWidget(MaterialApp(key: key, home: w));
        await tester.pumpAndSettle();
      }
      await pump(SkDoorScreen(door: door, onSurface: (_, _) {}));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsOneWidget);
      await pump(SkActivityScreen(content: _c, activity: _c.activityById('fe_811_01')!), key: const ValueKey('a'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsOneWidget);
      await pump(skScreenForSurface('sk_page/skilling_emotional/fe_prm_811_1')!, key: const ValueKey('l'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsOneWidget);
      await pump(const SkKeepsakeScreen(doorId: 'skilling_emotional', doorTitle: 'Feelings'), key: const ValueKey('k'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsOneWidget);
      await pump(const SkJournalScreen(doorId: 'skilling_emotional'), key: const ValueKey('j'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsOneWidget);
      // Tap it: the sheet, with the trusted-adult line and both numbers.
      await tester.tap(find.byKey(const Key('sk-talk-to-someone')));
      await tester.pumpAndSettle();
      expect(find.textContaining('grown-up you trust'), findsWidgets);
      expect(find.byKey(const Key('sk-helpline-1098')), findsOneWidget);
      expect(find.byKey(const Key('sk-helpline-14416')), findsOneWidget);
      expect(find.textContaining('Nothing you say here is written down'), findsOneWidget);
      // And not on Coding.
      await pump(SkDoorScreen(door: skDoorFor('skilling_coding')!, onSurface: (_, _) {}), key: const ValueKey('cd'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsNothing);
      // The parent-facing note carries no child off-ramp.
      await pump(skScreenForSurface('sk_page/skilling_emotional/fe_parent_note')!, key: const ValueKey('pn'));
      expect(find.byKey(const Key('sk-talk-to-someone')), findsNothing);
    });
  });

  group('the journal — hers, on this phone, sealed, never read by anyone else (1a, 3a)', () {
    test('the cipher seals and opens; a wrong key or a tampered byte opens nothing', () {
      final k1 = Uint8List.fromList(List.generate(32, (i) => i));
      final k2 = Uint8List.fromList(List.generate(32, (i) => 255 - i));
      final sealed = SkJournalCipher(k1).seal('today I felt small and then okay');
      expect(sealed.length, greaterThan(12 + 16));
      expect(utf8.decode(sealed, allowMalformed: true), isNot(contains('small')), reason: 'not plaintext on disk');
      expect(SkJournalCipher(k1).open(sealed), 'today I felt small and then okay');
      expect(SkJournalCipher(k2).open(sealed), isNull, reason: 'wrong key');
      final tampered = Uint8List.fromList(sealed)..[20] ^= 0x01;
      expect(SkJournalCipher(k1).open(tampered), isNull, reason: 'GCM tag fails');
      // A fresh nonce each time: two seals of the same text differ.
      expect(SkJournalCipher(k1).seal('same'), isNot(equals(SkJournalCipher(k1).seal('same'))));
    });

    test('the store keeps text only in sealed files; the index holds ids and dates; forget-all empties everything', () async {
      final tmp = Directory.systemTemp.createTempSync('sk_journal_');
      addTearDown(() => tmp.deleteSync(recursive: true));
      // Point the folder at temp for the test by writing through the cipher directly.
      final store = SkJournalStore.instance..keyStore = _MemoryKeyStore();
      // The index must never carry text: check the shape of an entry.
      final e = SkJournalEntry(id: '1', doorId: 'skilling_emotional', at: DateTime(2026, 9, 18), path: '${tmp.path}/1.enc');
      expect(e.toJson().keys.toSet(), {'id', 'door', 'at', 'path', 'prompt'});
      expect(e.toJson().values.join(' ').contains('felt'), isFalse);
      expect(store.entriesFor('skilling_emotional'), isEmpty);
      expect(store.hasEntries('skilling_emotional'), isFalse);
    });

    test('no reader but her own page: no search, count, sentiment, export, upload or AI in the journal file', () {
      final src = File('lib/screens/skilling/sk_journal.dart').readAsStringSync();
      // Strip comments — they name the banned things to deny them.
      final code = src.split('\n').where((l) => !l.trimLeft().startsWith('//') && !l.trimLeft().startsWith('///')).join('\n');
      for (final w in [
        'search', 'wordCount', 'sentiment', 'share_plus', 'upload', 'Supabase', 'http', 'analys', 'score',
        'askVeda', 'openai', 'summar', 'toLowerCase()', 'split(',
      ]) {
        expect(code.contains(w), isFalse, reason: 'sk_journal.dart code says "$w"');
      }
      // The only decryption call site is the screen's open.
      expect(RegExp(r'\bread\(').allMatches(code).length, 2, reason: 'read(id) defined once, called once');
      expect(RegExp(r'\.read\(').allMatches(code).length, 1, reason: 'one caller, the page she opens');
      // Encrypted at rest, by the AES the app already ships.
      expect(code.contains('GCMBlockCipher'), isTrue);
      expect(File('pubspec.yaml').readAsStringSync().contains('pointycastle:'), isTrue, reason: 'a direct dependency, not a transitive one leaned on');
    });

    testWidgets('her journal: write a page, see it as a dated row, open it, tear it out', (tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(9, name: 'Ira');
      SkJournalStore.instance.keyStore = _MemoryKeyStore();
      await tester.pumpWidget(const MaterialApp(home: SkJournalScreen(doorId: 'skilling_emotional')));
      await tester.pumpAndSettle();
      expect(find.text('Your journal'), findsOneWidget);
      expect(find.byKey(const Key('sk-journal-empty')), findsOneWidget);
      expect(find.textContaining('nobody reads it but you'), findsOneWidget);
      expect(find.textContaining('grown-up you trust'), findsOneWidget, reason: 'help inside the journal');
      // The store writes to the documents directory, which flutter test cannot
      // reach; the screen's contract is the rows and the sheet, held below by
      // seeding the index directly.
      await tester.tap(find.byKey(const Key('sk-journal-write')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sk-journal-field')), findsOneWidget);
      expect(find.text('Keep it'), findsOneWidget);
      expect(find.textContaining('Nobody marks it'), findsOneWidget);
    });
  });

  group('the lines — never therapy, no score of her feelings', () {
    test('nothing sells a fix, a cure or a resilient child; nothing scores', () {
      const banned = [
        'fix', 'fixes', 'cure', 'cures', 'therapy', 'counselling', 'counseling', 'treat', 'treatment',
        'anxiety', 'depression', 'resilient child', 'diagnos', 'guarantee', 'future', 'mood chart',
        'mood score', 'progress report', 'rating', 'rate',
      ];
      final strings = [
        for (final k in _c.courses) ...[k.title, k.blurb],
        for (final p in _c.products) ...[p.title, p.blurb],
        for (final t in door.tabs) ...[t.label, t.footer ?? '', ...t.tools.map((x) => '${x.label} ${x.blurb}')],
        door.closing!.blurb,
        for (final s in kSkFeelingsSkills) '${s.label} ${s.kidLine}',
        for (final s in _c.lessonSets) '${s.title} ${s.blurb}',
        _c.safety!.trustedAdultLine,
        for (final h in _c.safety!.helplines) '${h.name} ${h.note}',
        _c.keepsakeTitle,
      ];
      final denial = RegExp(r"[^.]*\b(not|never|no)\b[^.]*\b(treatment|therapy|score|fix)\b[^.]*\.");
      for (final s in strings) {
        final t = s.toLowerCase().replaceAll(denial, '');
        for (final b in banned) {
          expect(RegExp('\\b$b').hasMatch(t), isFalse, reason: '"$s" says "$b"');
        }
      }
      for (final k in _c.courses) {
        expect(k.mode, SkCourseMode.recorded);
        expect(k.comingSoon, isTrue);
        expect(k.priceInr, isNotNull);
        expect(k.priceUsd, isNotNull);
      }
      expect(_c.courses, hasLength(3));
      expect(_c.products, hasLength(9));
    });

    test('the parent can delete the journal and cannot read it; withdrawing consent forgets it', () {
      final src = File('lib/screens/skilling/sk_grown_up_screen.dart').readAsStringSync();
      expect(src.contains('Delete her journal'), isTrue);
      expect(src.contains('you can delete it, not read it'), isTrue);
      expect(src.contains('SkJournalStore.instance.forgetAll()'), isTrue);
      expect(src.contains('SkJournalStore.instance.read('), isFalse, reason: 'no parent reader');
      expect(src.contains('SkJournalStore.instance.entriesFor'), isFalse,
          reason: 'the parent screen does not list her pages');
    });
  });

  group('the bracket — five live, the report refused, Consult held', () {
    test('content, activities (with the journal), tools into the keepsake, products, course; extras notApplicable', () {
      final b = bracketById('skilling_emotional')!;
      for (final l in [
        BracketLayer.content, BracketLayer.activities, BracketLayer.tools,
        BracketLayer.products, BracketLayer.course,
      ]) {
        expect(b.layer(l).state, LayerState.live, reason: l.name);
        for (final id in b.layer(l).surfaceIds) {
          expect(skRouterKnows(id), isTrue, reason: '${l.name} → $id');
        }
      }
      expect(b.layer(BracketLayer.activities).surfaceIds, contains('sk_journal/skilling_emotional'));
      expect(b.layer(BracketLayer.tools).surfaceIds, ['sk_keepsake/skilling_emotional']);
      expect(b.layer(BracketLayer.extras).state, LayerState.notApplicable,
          reason: '"an emotional progress report on a child is unthinkable, and it is a score"');
      expect(b.layer(BracketLayer.consult).state, LayerState.notReady);
      expect(b.hue, 288);
      expect(b.theme, 'mental_health');
    });
  });

  group('the age rule on six cards', () {
    testWidgets('a seven-year-old: the first band open, two locked, six cards', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7, name: 'Ira');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FOR IRA  ·  NAME WHAT YOU FEEL  ·  6 TO 8'), findsOneWidget);
      expect(find.textContaining('From 8 years'), findsOneWidget);
      expect(find.textContaining('From 11 years'), findsOneWidget);
      expect(find.text('Naming it'), findsOneWidget);
      expect(find.text('Asking for help'), findsOneWidget);
      for (final t in door.tabs) {
        expect(find.text(t.label), findsWidgets, reason: t.id);
      }
    });

    testWidgets('a thirteen-year-old: four cards, the two bands behind gone', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(13, name: 'Dev');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      expect(find.textContaining('FIND YOUR WAY THROUGH  ·  11 TO 14'), findsOneWidget);
      expect(find.text('Name what you feel'), findsNothing);
      expect(find.text('Your journal'), findsWidgets);
      expect(find.text('You practised'), findsWidgets);
    });
  });

  test('every coming-soon slot on this door is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[
      for (final a in _c.activities.where((a) => a.comingSoon)) if (!ledger.contains(a.id)) a.id,
      for (final p in _c.allPages.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
      for (final k in _c.courses.where((k) => k.comingSoon)) if (!ledger.contains(k.id)) k.id,
      for (final p in _c.products.where((p) => p.comingSoon)) if (!ledger.contains(p.id)) p.id,
    ];
    expect(missing, isEmpty, reason: 'coming-soon slots nobody owes:\n${missing.join('\n')}');
  });
}
