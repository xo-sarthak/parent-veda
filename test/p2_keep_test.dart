// P2, Pregnancy keep tools (docs/preg-ttc-tool-plans/P2-keep.md, 2026-10-28).
//
// Holds: one journal to look in (D1), the birth plan's Undo, summary and the
// partner read (O1, O2, 0118), the two column contracts the audit found
// missing, and the wiring of every fix against the source.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/birth_plan_data.dart';
import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/services/birth_plan_store.dart';
import 'package:parentveda/services/journal_store.dart';
import 'package:parentveda/services/pp_use_consent.dart';

String _src(String p) => File(p).readAsStringSync().replaceAll('\r\n', '\n');

/// Code only: comment lines (the "kept for revert" copies) dropped.
String _code(String p) => _src(p)
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('D1: Garbh entries show in My Journal, read-through', () {
    final garbh = GarbhJournalStore.instance;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await garbh.init();
      for (final e in List.of(garbh.entries)) {
        await garbh.remove(e.id);
      }
    });

    GarbhJournalEntry e(String id, GarbhEntryKind k, int week, int day,
            {String title = 'Raga Yaman', String? text, String? path}) =>
        GarbhJournalEntry(
          id: id,
          kind: k,
          week: week,
          tsMs: DateTime.now()
              .subtract(Duration(days: day))
              .millisecondsSinceEpoch,
          title: LocalizedText(en: title, hi: title),
          text: text,
          path: path,
        );

    test('voices, letters one by one; "heard" folds to one row a week', () async {
      await garbh.add(e('v1', GarbhEntryKind.myVoice, 22, 3, title: 'Hello', path: '/a.m4a'));
      await garbh.add(e('l1', GarbhEntryKind.letter, 22, 2,
          title: 'Dear one...', text: 'Dear one, the whole letter.'));
      for (var i = 0; i < 5; i++) {
        await garbh.add(e('h$i', GarbhEntryKind.heard, 22, 1));
      }
      await garbh.add(e('h9', GarbhEntryKind.heard, 21, 9, title: 'Raga Bhairav'));

      final out = JournalStore.instance.journalFromGarbh();
      expect(out.every((x) => x.fromGarbh), isTrue);
      expect(out.where((x) => x.id == 'garbh_v1').single.audioUrls, ['/a.m4a']);
      final letter = out.where((x) => x.id == 'garbh_l1').single;
      expect(letter.type, JournalEntryType.noteForBaby);
      expect(letter.description, 'Dear one, the whole letter.');
      final heard = out.where((x) => x.id.startsWith('garbh_heard_')).toList();
      expect(heard, hasLength(2), reason: 'one row per week, not one per listen');
      expect(heard.firstWhere((x) => x.weekNumber == 22).title,
          '5 pieces played this week');
      expect(heard.firstWhere((x) => x.weekNumber == 21).title,
          'Played: Raga Bhairav');
    });

    test('the Journal never writes Garbh data: a Garbh row opens Garbh', () {
      final screen = _code('lib/screens/journal/pv_journal_screen.dart');
      expect(screen, contains('if (e.fromGarbh) {'));
      expect(screen, contains('const GarbhJournalScreen()'));
      expect(screen, contains('GarbhJournalStore.instance, // P2 D1'));
      final store = _code('lib/services/journal_store.dart');
      expect(store, contains('list.addAll(journalFromGarbh());'));
      expect(store, isNot(contains('GarbhJournalStore.instance.add')));
      expect(store, isNot(contains('GarbhJournalStore.instance.remove')));
    });
  });

  group('Birth plan', () {
    test('Start again can be undone: snapshot and restore', () async {
      SharedPreferences.setMockInitialValues({});
      final store = BirthPlanStore.instance;
      await store.init();
      final s = kBirthPlanSections.first;
      final q = s.questions.firstWhere((q) => q.kind != BpKind.text);
      store.applyCloudItems({'c|${q.id}|${q.choices.first.id}': true, 'd|${s.id}': true});
      final before = store.summary();
      final snap = store.snapshot();
      await store.clear();
      expect(store.isEmpty, isTrue);
      await store.restore(snap);
      expect(store.summary(), before);
    });

    test('her phone and her partner\'s word a plan the same way', () {
      final s = kBirthPlanSections.first;
      final q = s.questions.firstWhere((q) => q.kind != BpKind.text);
      final items = {'c|${q.id}|${q.choices.first.id}': true, 'd|${s.id}': true};
      final p = BirthPlanStore.parseItems(items);
      final mine = BirthPlanStore.summaryFrom(p.choices, p.texts, p.discussed);
      BirthPlanStore.instance.applyCloudItems(items);
      expect(BirthPlanStore.instance.summary(), mine);
      expect(mine, contains('• ${q.choices.first.label}'));
      expect(mine, contains('(Talked this through with my doctor.)'));
    });

    test('O1: the doctor summary carries it only after her yes', () {
      expect(PpUseKind.pregBirthPlan.label, 'Your birth plan');
      final notes = _code('lib/screens/profile/pv_doctor_notes_screen.dart');
      expect(notes, contains('PpUseKind.pregBirthPlan'));
      expect(notes, contains("out.add(('Birth preferences'"));
      final screen = _code('lib/screens/pregnancy/birth_plan_screen.dart');
      expect(screen, contains('kind: PpUseKind.pregBirthPlan'));
    });

    test('O2: 0118 shares one row of user_state, read-only', () {
      final sql = _src('supabase/migrations/0118_user_state_partner_birth_plan.sql');
      final live = sql
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('--'))
          .join('\n');
      expect(live, contains('for select'));
      expect(live, contains("store_key = 'birth_plan' and user_id = public.my_partner_id()"));
      expect(live, isNot(contains('for insert')));
      expect(live, isNot(contains('for update')));
      expect(live, isNot(contains('for delete')));
      final repo = _code('lib/services/remote/supabase_repo.dart');
      expect(repo, contains('loadPartnerState('));
      final screen = _code('lib/screens/pregnancy/birth_plan_screen.dart');
      expect(screen, contains('PartnerSide.following'));
      expect(screen, contains('_PartnerPlanView('));
    });
  });

  group('column contracts the audit found missing', () {
    test('bump_photos: every column the app writes exists (0008)', () {
      final sql = _src('supabase/migrations/0008_bump.sql');
      final store = _src('lib/services/bump_store.dart');
      final body = store.substring(store.indexOf('Map<String, dynamic> _toRow(BumpPhoto p)'));
      final row = body.substring(0, body.indexOf('};'));
      final keys = RegExp(r"'(\w+)':").allMatches(row).map((m) => m[1]!).toList();
      expect(keys, containsAll(['id', 'image_url', 'week_number', 'date', 'caption', 'is_favorite']));
      for (final k in keys) {
        expect(RegExp('\\n\\s*$k\\s').hasMatch(sql), isTrue, reason: 'bump_photos.$k');
      }
    });

    test('garbh_journal_entries: key + data (0110)', () {
      final sql = _src('supabase/migrations/0110_state_merge_and_records.sql');
      final t = sql.substring(sql.indexOf('create table if not exists public.garbh_journal_entries'));
      final table = t.substring(0, t.indexOf(');'));
      expect(table, contains('key        text'));
      expect(table, contains('data       jsonb'));
      expect(_src('lib/data/garbh_rebuild_data.dart'),
          contains("{'key': e.id, 'data': e.toJson()}"));
    });
  });

  group('wiring of the fixes', () {
    test('G1/G2/G3: a letter opens, files under her week, and says so', () {
      final g = _code('lib/screens/garbh_journal_screen.dart');
      expect(g, contains('() => _readLetter(context, entry)'));
      expect(g, contains('final p = PregnancyController.current;'));
      expect(g, contains("'Letter kept under week \$week.'"));
    });

    test('J1/U1: after a loss the week clocks stop and baby wording drops', () {
      final j = _code('lib/screens/journal/pv_journal_screen.dart');
      expect(j, contains("salutation: 'What I kept,'"));
      expect(j, contains('if (pregnancyEndWeek(p) == null) ...['));
      final b = _code('lib/screens/belly_skin/bump_ritual_screen.dart');
      expect(b, contains('final week = endWeek ?? controller.currentWeek;'));
      expect(b, contains("'Every photo you kept stays here, in your book.'"));
      expect(_code('lib/services/journal_store.dart'),
          contains('if (endedAt != null && date.isAfter(endedAt)) continue;'));
    });

    test('J2/J3/U3/U4: saves and deletes say what they changed', () {
      final j = _code('lib/screens/journal/pv_journal_screen.dart');
      expect(j, contains("'Memory deleted.'"));
      expect(j, contains('store.restoreEntry(entry)'));
      expect(j, contains('if (!undone) await store.discardFiles(entry);'));
      expect(_code('lib/screens/journal_compose_screen.dart'), contains("'Memory updated.'"));
      final b = _code('lib/screens/belly_skin/bump_ritual_screen.dart');
      expect(b, contains("'Added to week \$chosen, and to your journal.'"));
      expect(b, contains("'Caption saved.'"));
    });

    test('U2: no promise of a notification nothing records', () {
      expect(_code('lib/screens/bump_book_screen.dart'),
          isNot(contains('We will notify you when printed copies are ready.')));
    });

    test('S1/S2: Spiritual reading opens in the one reader, honestly named', () {
      final s = _code('lib/screens/tools/spiritual_reading_screen.dart');
      expect(s, contains('PvReaderScreen('));
      expect(s, contains('pvReadFromSpiritual('));
      expect(_code('lib/screens/tools_hub_screen.dart'),
          isNot(contains("'Short readings to hear, or to read aloud'")));
    });

    test('W3: Ask Veda tool links keep the hub rules, in words', () {
      final v = _code('lib/ask_veda/pv_veda_links.dart');
      expect(v, contains('if (pvVedaToolStepsAside(t.tool!.id) case final why?)'));
      expect(v, isNot(contains("'garbh sanskar', 'mantra'")));
    });

    test('W4: the names list heart unlikes too', () {
      expect(_code('lib/screens/post_pregnancy/name_list_screen.dart'),
          contains('onTap: () => ppToggleNameLike(context, n.name),'));
    });
  });
}
