// =============================================================================
//  The Papers and money door, held against its plan (door 14)
// -----------------------------------------------------------------------------
//  `docs/pp-door-plans/14-papers.md`, PM1 to PM7, as assertions. What fails
//  silently here, and must not: a 4-year-old's parent meeting the birth
//  certificate before the Aadhaar update that is due at five; a link to a
//  whole section instead of the page it names; a reminder that rings on the
//  wrong day, or a tap that sets nothing and says nothing; a figure with no
//  date on it; and legal aid, leave or PMMVY written a second time when
//  another door already owns them.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/baby_documents_screen.dart';
import 'package:parentveda/screens/post_pregnancy/calendar/pp_cal_data.dart';
import 'package:parentveda/screens/post_pregnancy/doors/pp_door_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_aadhaar_reminder.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_papers_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/widgets/pv_toast.dart';

PpSection get _pm => ppSectionFor('parenting_papers')!;
PpPage _page(String id) => _pm.pageById(id)!;
Iterable<PpLink> _links(PpPage p) => p.blocks.whereType<PpLink>();
List<String?> _surfaces(PpPage p) => [for (final l in _links(p)) l.surfaceId];

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

String _text(PpPage p) => [
      for (final b in p.blocks)
        if (b is PpIntro) b.text
        else if (b is PpArticle) ...[if (b.heading != null) b.heading!, ...b.paragraphs]
        else if (b is PpSteps) ...[if (b.heading != null) b.heading!, for (final s in b.steps) '${s.title} ${s.detail ?? ''}']
        else if (b is PpCards) ...[if (b.heading != null) b.heading!, for (final c in b.cards) '${c.title} ${c.line}']
        else if (b is PpCallout) '${b.title ?? ''} ${b.text}'
        else if (b is PpIndiaNote) b.text
        else if (b is PpWhenLine) b.text
        else if (b is PpLink) '${b.label} ${b.blurb ?? ''}',
    ].join(' ');

Future<void> _pump(WidgetTester t, PpDoor door,
    {required int months, String? tab, List<String>? opened}) async {
  _ageMonths(months);
  await t.pumpWidget(MaterialApp(
      home: PpDoorScreen(
          key: ValueKey('$months/$tab'),
          door: door,
          onSurface: (_, s) => opened?.add(s),
          initialTabId: tab)));
  await t.pumpAndSettle();
}

const _p = 'pp_page/parenting_papers/';

/// Every link in the door, page by page, exactly. A new link fails here until
/// it has a row, so a fallback target (a whole section, a door's home)
/// cannot slip in.
const _exact = <String, List<String>>{
  'pm_birth_certificate': [
    '${_p}pm_aadhaar',
    'pp_page/parenting_early_learning/school_admission',
    'pp_page/parenting_maternal/people_separated',
    'pp_page/parenting_family/fam_on_your_own',
  ],
  'pm_aadhaar': ['pp_baby_documents'],
  'pm_passport': ['${_p}pm_birth_certificate', 'pp_page/parenting_safety/safety_travel'],
  'pm_schemes': [
    'pp_page/parenting_health/vax_schedule',
    'pp_page/parenting_early_learning/school_admission',
    'pp_page/parenting_special_care/sc_nicu',
    'pp_page/parenting_special_care/sc_help_india',
    'pp_page/parenting_maternal/work_schemes',
  ],
  'pm_health_insurance': [
    'pp_page/parenting_health/vax_schedule',
    'pp_page/parenting_special_care/sc_therapies',
  ],
  'pm_planning_ahead': [
    'pp_page/parenting_maternal/work_your_entitlement',
    'pp_page/parenting_family/fam_on_your_own',
  ],
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final door = ppDoorFor('parenting_papers')!;

  group('PM1: each age opens on what fits', () {
    test('the tab order for every band', () {
      const fromOne = ['docs', 'insurance', 'saving', 'schemes', 'ahead'];
      expect(door.tabOrder, {
        'infant': ['docs', 'schemes', 'insurance', 'saving', 'ahead'],
        'toddler_1': fromOne,
        'toddler_2': fromOne,
        'preschool': fromOne,
      });
      expect(door.tabOrder.keys.toSet(), {for (final b in _pm.bandSet!.bands) b.id});
    });

    test('every page\'s age: every page for every age', () {
      // A new page fails here until it has a row: every age is a choice. A
      // late registration or a correction can happen at any age (PM1).
      const tags = <String, List<String>>{};
      for (final p in _pm.allPages) {
        expect(p.bands, tags[p.id] ?? isEmpty, reason: p.id);
      }
      for (final a in _pm.areas) {
        expect(a.bands, isEmpty, reason: a.id);
      }
    });

    test('from three, Baal Aadhaar leads Documents; the authored list is untouched', () {
      final docs = door.tabs.firstWhere((t) => t.id == 'docs');
      expect(docs.ageRail.keys, ['preschool']);
      expect(docs.ageRail['preschool']!.pageIds,
          ['pm_aadhaar', 'pm_birth_certificate', 'pm_passport']);
      final area = _pm.areas.firstWhere((a) => a.id == 'documents');
      expect(area.pages.map((p) => p.id), ['pm_birth_certificate', 'pm_aadhaar', 'pm_passport']);
    });

    testWidgets('first view: the birth certificate first at 3 months, Baal Aadhaar first at 40', (t) async {
      t.view.physicalSize = const Size(1200, 7000);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      double x(String s) => t.getTopLeft(find.text(s).first).dx;
      const birth = 'The birth certificate: the first and most important';
      const aadhaar = 'Baal Aadhaar for your child';

      await _pump(t, door, months: 3);
      expect(x(birth), lessThan(x(aadhaar)));
      expect(find.text('Schemes for mothers and young children'), findsNothing,
          reason: 'Documents opens; Schemes is the second tab');

      await _pump(t, door, months: 40);
      expect(x(aadhaar), lessThan(x(birth)), reason: 'the update is due at five');
      // The vault comes after every page, and nothing after it: no closing.
      expect(x('Document vault'), greaterThan(x('A passport for your baby')));
      expect(find.byKey(const ValueKey('pp_door_closing_card')), findsNothing);
    });
  });

  group('PM2: links, each on its exact page', () {
    test('every link in the door, exactly, and each lands', () {
      final actual = {
        for (final p in _pm.allPages)
          if (_links(p).isNotEmpty) p.id: _surfaces(p),
      };
      expect(actual, _exact);
      for (final p in _pm.allPages) {
        for (final l in _links(p)) {
          final s = l.surfaceId;
          // pp_gap_doors_test asks every link for a screen through surfaceId!.
          expect(s, isNotNull, reason: '${p.id}: a link names a surface, never pageId');
          expect(ppSurfaceUnavailable(s!), isNull, reason: '${p.id} -> $s');
          expect(ppScreenForSurface(s), isNotNull, reason: '${p.id} -> $s');
          if (s.startsWith('pp_page/')) {
            final [_, section, page] = s.split('/');
            final target = ppSectionFor(section)!.pageById(page);
            expect(target, isNotNull, reason: '${p.id} -> $s');
            // A link label that is another page's title keeps that title.
            expect(l.label, target!.title, reason: '${p.id} -> $s');
          }
        }
      }
    });

    test('leave goes to the page, not the whole You, Maa section', () {
      for (final p in _pm.allPages) {
        for (final s in _surfaces(p)) {
          expect(s, isNot(startsWith('pp_section/')), reason: p.id);
        }
      }
    });

    test('pm_schemes is a story again, and every link is on a slide', () {
      // Door 14 opened it in the reader because the deck dropped links to
      // other doors. The deck keeps every link now (2026-10-27, option A).
      expect(_page('pm_schemes').format, 'CARDS');
      final slides = ppCardsAsSlides(_page('pm_schemes'))!;
      final onSlides = {
        for (final s in slides) ?s.surfaceId,
        for (final s in slides) ?s.pageId,
      };
      for (final s in _surfaces(_page('pm_schemes')).nonNulls) {
        expect(onSlides, contains(s), reason: 'a link the story drops');
      }
    });

    test('the pages that link here still do', () {
      for (final (section, page, to) in [
        ('parenting_family', 'fam_on_your_own', 'pm_birth_certificate'),
        ('parenting_family', 'fam_on_your_own', 'pm_planning_ahead'),
        ('parenting_safety', 'safety_travel', 'pm_passport'),
        ('parenting_safety', 'safety_travel', 'pm_birth_certificate'),
        ('parenting_traditional', 'namkaran', 'pm_birth_certificate'),
      ]) {
        final p = ppSectionFor(section)!.pageById(page)!;
        expect(_surfaces(p), contains('$_p$to'), reason: '$page -> $to');
      }
    });
  });

  group('PM3 and PM4: the answers, each said once', () {
    test('insurance answers vaccines, OPD and therapy', () {
      final p = _page('pm_health_insurance');
      final group = p.blocks.whereType<PpCards>()
          .singleWhere((c) => c.heading == 'Vaccines, doctor visits and therapy');
      expect(group.cards.map((c) => c.title), ['Vaccines', 'Doctor visits (OPD)', 'Therapy', 'Who to ask']);
      expect(_text(p), contains('TPA'));
    });

    test('the passport: yes from birth, the name, the photo, Tatkal, one parent', () {
      final p = _page('pm_passport');
      expect((p.blocks.first as PpIntro).text, startsWith('Yes, even a newborn'));
      final words = _text(p);
      for (final w in ['match the birth certificate', 'under four', 'Tatkal', 'single parent']) {
        expect(words, contains(w));
      }
    });

    test('the birth certificate: corrections, and a single parent\'s forms, never legal aid', () {
      final words = _text(_page('pm_birth_certificate'));
      expect(words, contains('If something is wrong, or the name comes late'));
      expect(words, contains('Annexure C'));
      // You, Maa's people_separated owns maintenance and free legal aid.
      for (final p in _pm.allPages) {
        expect(_text(p), isNot(contains('NALSA')), reason: p.id);
        expect(_text(p), isNot(contains('15100')), reason: p.id);
      }
    });

    test('PMMVY exact, the disability card, and tax under the old regime', () {
      final schemes = _text(_page('pm_schemes'));
      expect(schemes, contains('₹5,000 for the first child, in two instalments'));
      expect(schemes, contains('₹6,000'));
      expect(schemes, contains('If your child has a disability'));
      final saving = _text(_page('pm_saving'));
      expect(saving, contains('Tax, if you file under the old regime'));
      expect(saving, contains('80C'));
      expect(saving, contains('80D'));
    });

    test('no leave page (PM2): You, Maa owns it', () {
      expect(_pm.allPages.map((p) => p.id),
          ['pm_birth_certificate', 'pm_aadhaar', 'pm_passport', 'pm_schemes',
           'pm_health_insurance', 'pm_saving', 'pm_planning_ahead']);
    });

    test('kept on purpose: no provider named, rupees only, the two money lines', () {
      final all = [for (final p in _pm.allPages) _text(p)].join(' ');
      expect(all, contains('not advice on any product'));
      expect(all, contains('Keep insurance and saving separate'));
      expect(all, isNot(contains(r'$')), reason: 'money in rupees only');
      for (final name in ['LIC', 'HDFC', 'ICICI', 'SBI', 'Star Health', 'Niva', 'Medi Assist', 'Bajaj']) {
        expect(all, isNot(contains(name)), reason: 'no provider named');
      }
    });

    test('no when-line: the reader draws it as "When to see a doctor"', () {
      for (final p in _pm.allPages) {
        expect(p.blocks.whereType<PpWhenLine>(), isEmpty, reason: p.id);
      }
    });
  });

  group('PM7: the date on every page', () {
    test('"Checked October 2026" and where to confirm, right after the intro', () {
      for (final p in _pm.allPages) {
        expect(p.blocks.first, isA<PpIntro>(), reason: p.id);
        final c = p.blocks[1];
        expect(c, isA<PpCallout>(), reason: p.id);
        expect((c as PpCallout).title, kPpPapersChecked, reason: p.id);
        expect(c.text, startsWith('Rules change, so confirm'), reason: p.id);
      }
      expect(kPpPapersChecked, 'Checked October 2026');
    });
  });

  group('PM5: the vault and the reminder', () {
    test('pp_baby_documents opens the vault; its tool is last on Documents', () {
      expect(ppScreenForSurface('pp_baby_documents'), isA<BabyDocumentsScreen>());
      expect(ppSurfaceUnavailable('pp_baby_documents'), isNull);
      final docs = door.tabs.firstWhere((t) => t.id == 'docs');
      final tool = docs.tools.single;
      expect(tool.label, 'Document vault');
      expect(tool.surfaceId, 'pp_baby_documents');
      expect(tool.atEnd, isTrue);
      expect(tool.bands, isNull, reason: 'every age');
    });

    test('the call site: the router names the route, the page carries the button', () {
      final router = File('lib/screens/post_pregnancy/pp_surface_router.dart').readAsStringSync();
      expect(router, contains("'pp_baby_documents' => const BabyDocumentsScreen()"));
      expect(_page('pm_aadhaar').blocks.whereType<PpAadhaarReminder>(), hasLength(1));
      final view = File('lib/screens/post_pregnancy/pp_content.dart').readAsStringSync();
      expect(view, contains('if (b is PpAadhaarReminder) return const PpAadhaarReminderView();'));
    });

    test('no closing card: no expert fits this door', () {
      expect(door.closing, isNull);
      for (final t in door.tabs) {
        expect(t.expert, isNull, reason: t.id);
        expect(t.closing, isNull, reason: t.id);
      }
    });

    test('the date: one month before the fifth birthday', () {
      expect(ppAadhaarReminderDate(DateTime(2026, 6, 12)), DateTime(2031, 5, 12));
      expect(ppAadhaarReminderDate(DateTime(2026, 1, 20)), DateTime(2030, 12, 20),
          reason: 'January goes back to the December before');
      expect(ppAadhaarReminderDate(DateTime(2026, 3, 31)), DateTime(2031, 2, 28),
          reason: 'a day February does not have takes its last day');
      expect(ppAadhaarDateLabel(DateTime(2031, 5, 12)), '12 May 2031');
      expect(ppAadhaarDueNow(DateTime(2026, 6, 12), DateTime(2031, 5, 11)), isFalse);
      expect(ppAadhaarDueNow(DateTime(2026, 6, 12), DateTime(2031, 5, 12)), isTrue);
    });

    group('on the page', () {
      final scheduled = <DateTime>[];
      setUp(() {
        SharedPreferences.setMockInitialValues({});
        ChildProfileStore.instance.resetForTest();
        PpApptReminders.instance.debugReset();
        scheduled.clear();
        PpApptReminders.schedule =
            ({required int id, required String title, String? body, required DateTime when}) async =>
                scheduled.add(when);
      });
      tearDown(() {
        PpApptReminders.instance.debugReset();
        PvToast.instance.dismiss();
      });

      Future<void> pumpView(WidgetTester t, DateTime now) async {
        await t.pumpWidget(MaterialApp(
            home: Scaffold(body: Center(child: PpAadhaarReminderView(now: now)))));
        await t.pump();
      }

      testWidgets('a tap sets it for the right day and says so', (t) async {
        final now = DateTime(2026, 10, 26, 10);
        ChildProfileStore.instance.debugSetDob(DateTime(2024, 6, 12));
        await pumpView(t, now);
        await t.tap(find.byKey(const ValueKey('pp_aadhaar_remind')));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        // Rings on the day itself, 7 pm.
        expect(scheduled, [DateTime(2029, 5, 12, 19)]);
        expect(PpApptReminders.instance.isOn(
            ppAadhaarReminderId(ChildProfileStore.instance.activeChildId!)), isTrue);
        expect(find.text(ppAadhaarSetLine(DateTime(2029, 5, 12))), findsWidgets);
        expect(find.textContaining('Reminder set for 12 May 2029'), findsWidgets);
        expect(find.byKey(const ValueKey('pp_aadhaar_remind')), findsNothing);
      });

      testWidgets('no birth date saved: nothing is set, and the toast says why', (t) async {
        expect(ChildProfileStore.instance.hasRealChild, isFalse);
        await pumpView(t, DateTime(2026, 10, 26));
        await t.tap(find.byKey(const ValueKey('pp_aadhaar_remind')));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        expect(scheduled, isEmpty);
        expect(find.text(kPpAadhaarNoDate), findsOneWidget);
        expect(find.text('Add the date'), findsOneWidget);
      });

      testWidgets('five already: the line says it is due now, and there is no button', (t) async {
        ChildProfileStore.instance.debugSetDob(DateTime(2021, 3, 1));
        await pumpView(t, DateTime(2026, 10, 26));
        expect(find.text(kPpAadhaarDueNow), findsOneWidget);
        expect(find.byKey(const ValueKey('pp_aadhaar_remind')), findsNothing);
        expect(scheduled, isEmpty);
      });

      testWidgets('inside the last month before five: due now too', (t) async {
        ChildProfileStore.instance.debugSetDob(DateTime(2021, 11, 10));
        await pumpView(t, DateTime(2026, 10, 26));
        expect(find.text(kPpAadhaarDueNow), findsOneWidget);
      });

      testWidgets('at 360dp and 1.5x the button wraps instead of overflowing', (t) async {
        t.view.physicalSize = const Size(360, 800);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);
        ChildProfileStore.instance.debugSetDob(DateTime(2025, 1, 1));
        await t.pumpWidget(MaterialApp(
            home: MediaQuery(
                data: const MediaQueryData(size: Size(360, 800), textScaler: TextScaler.linear(1.5)),
                child: Scaffold(
                    body: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PpAadhaarReminderView(now: DateTime(2026, 10, 26)))))));
        await t.pump();
        expect(t.takeException(), isNull);
        expect(find.text(kPpAadhaarRemindLabel), findsOneWidget);
      });
    });
  });

  group('PM6 and names', () {
    test('the tab names', () {
      expect([for (final t in door.tabs) t.label],
          ['Child\'s documents', 'Schemes to claim', 'Health insurance', 'Saving for your child', 'Planning ahead']);
    });

    test('no film slotted until one exists (S4); the hero', () {
      expect([for (final p in _pm.allPages) ...p.blocks.whereType<PpVideoSlot>()], isEmpty);
      expect(door.heroImageUrl, startsWith('https://images.unsplash.com/'));
    });

    test('off the home rail on purpose', () {
      final rail = File('lib/screens/post_pregnancy/pp_home_reads.dart').readAsStringSync();
      final start = rail.indexOf('_kNotForTheRail');
      expect(start, greaterThanOrEqualTo(0));
      expect(rail.substring(start, rail.indexOf('}', start)), contains("'parenting_papers'"));
    });
  });
}
