// =============================================================================
//  Learn — one page for five kinds (docs/LEARNING-AUDIT.md)
// -----------------------------------------------------------------------------
//  What this file holds, and why each is a test rather than a comment:
//
//    1. THE PAGE IS FIXED. Ten sections, one order, whichever kind. A course
//       and a consult may skip a section; neither may reorder one. Asserted
//       by reading the rendered heads top to bottom on one view of every
//       kind and checking they are a subsequence of the canonical list.
//
//    2. THE VERB IS THE KIND'S. Five kinds, five verbs, and the free stage
//       switch of a "sales page" tone never creeps back.
//
//    3. THE CATALOGUE IS COMPLETE. Every engine offering the learn kinds
//       cover has a view, every view has a fact strip, and ids are unique —
//       so no bookable thing can render on the Learn home and then have no
//       page (the "visible and inert" defect the engine's bridge names).
//
//    4. IT IS REACHABLE, and the classics are not. The wiring gate: the
//       twenty-four retired screens are facades over the new ones, nothing
//       pushes a `…Classic`, and the doctor page's rows and Book pill go
//       through the new flow — the user's specific complaint.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/data/learn/pv_learn_images.dart';
import 'package:parentveda/screens/products/pv_review_block.dart';
import 'package:parentveda/screens/learn/pv_learn_catalog.dart';
import 'package:parentveda/screens/learn/pv_learn_screen.dart';
import 'package:parentveda/screens/learn/pv_my_learning_screen.dart';
import 'package:parentveda/screens/learn/pv_offering_content.dart';
import 'package:parentveda/screens/learn/pv_offering_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_learn_progress_store.dart';

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The heads, in the one order. A kind may skip; none may reorder.
const kOrder = [
  "What you'll take away",
  'What a session covers',
  // E — the structure, by kind
  'The lessons',
  'The class',
  'The evening',
  'In the recording',
  'Week by week',
  'How it works',
  'The rhythm',
  // F
  'Who teaches it',
  'Who leads it',
  // G
  'What parents said',
  // H
  'Questions',
  // I
  'More like this',
  'Other experts',
];

/// Canonical rank: sections that are alternatives of one another share it.
int _rank(String head) {
  if (head.startsWith('What you') || head.startsWith('What a session')) {
    return 0;
  }
  if (const {
    'The lessons',
    'The class',
    'The evening',
    'In the recording',
    'Week by week',
    'How it works',
    'The rhythm',
  }.contains(head)) {
    return 1;
  }
  if (head.startsWith('Who ')) return 2;
  if (head == 'What parents said') return 3;
  if (head == 'Questions') return 4;
  return 5;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    BookingStore.instance.resetAll();
    PvLearnProgressStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
  });

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  List<String> heads(WidgetTester tester) {
    final found = <(double, String)>[];
    for (final e in find.byType(Text).evaluate()) {
      final t = (e.widget as Text).data;
      if (t == null || !kOrder.contains(t)) continue;
      found.add((tester.getTopLeft(find.byWidget(e.widget)).dy, t));
    }
    found.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final f in found) f.$2];
  }

  PvOfferingView oneOf(PvLearnKind k) =>
      PvLearnCatalog.instance.all(kind: k).first;

  // ===========================================================================
  group('one page, five kinds', () {
    for (final k in PvLearnKind.values) {
      testWidgets('${k.name}: the sections keep the one order', (tester) async {
        final v = oneOf(k);
        await pumpTall(tester, PvOfferingScreen(view: v));
        expect(tester.takeException(), isNull);
        // A consult page is titled with the person, not "Consult with X"
        // over a photograph of X (2026-09-22).
        expect(
          find.text(k == PvLearnKind.consult ? v.expert.name : v.title),
          findsWidgets,
        );
        final hs = heads(tester);
        expect(hs, isNotEmpty, reason: '${k.name} rendered no section heads');
        for (var i = 1; i < hs.length; i++) {
          expect(
            _rank(hs[i]) >= _rank(hs[i - 1]),
            isTrue,
            reason:
                '${k.name} reordered the page: ${hs[i - 1]} before ${hs[i]}',
          );
        }
        // The structure block is always there — it IS the kind.
        expect(
          hs.any((h) => _rank(h) == 1),
          isTrue,
          reason: '${k.name} has no structure block',
        );
      });
    }
  });

  // ===========================================================================
  group('the verb is the kind\'s', () {
    test('five kinds, five verbs, nothing bought', () {
      expect(
        pvCommitFor(oneOf(PvLearnKind.consult), PvLearnState.none).verb,
        'See availability',
      );
      expect(
        pvCommitFor(oneOf(PvLearnKind.cohort), PvLearnState.none).verb,
        'Join the cohort',
      );
      expect(
        pvCommitFor(oneOf(PvLearnKind.classPack), PvLearnState.none).verb,
        'Get the pack',
      );
      final course = PvLearnCatalog.instance
          .all(kind: PvLearnKind.course)
          .firstWhere((v) => !v.isFree);
      expect(pvCommitFor(course, PvLearnState.none).verb, 'Start the course');
      final live = PvLearnCatalog.instance
          .all(kind: PvLearnKind.masterclass)
          .firstWhere((v) => v.isLive);
      expect(pvCommitFor(live, PvLearnState.none).verb, 'Reserve a seat');
    });

    test('a free course plays; nothing on it sells', () {
      final v = PvLearnCatalog.instance.byId(kPvTtcGarbhCourseId)!;
      expect(v.isFree, isTrue);
      expect(v.offering?.priceMinor ?? 0, 0);
      expect(pvLearnStateFor(v), PvLearnState.watching);
      expect(pvCommitFor(v, PvLearnState.watching).verb, 'Start the course');
      expect(v.lessons.length, greaterThanOrEqualTo(8));
      expect(
        v.lessons.every((l) => l.open != null),
        isTrue,
        reason: 'TTC sessions open their own practice screen',
      );
    });

    test('no sales-page words on any verb or note', () {
      for (final v in PvLearnCatalog.instance.all()) {
        for (final s in PvLearnState.values) {
          final c = pvCommitFor(v, s);
          final text = '${c.verb} ${c.note ?? ''}'.toLowerCase();
          expect(text.contains('guarantee'), isFalse, reason: '${v.id}: $text');
          expect(text.contains('hurry'), isFalse, reason: '${v.id}: $text');
          expect(
            text.contains('only today'),
            isFalse,
            reason: '${v.id}: $text',
          );
        }
      }
    });
  });

  // ===========================================================================
  group('the catalogue', () {
    test('ids are unique and every view has a fact strip', () {
      final all = PvLearnCatalog.instance.all();
      expect(all, isNotEmpty);
      expect(
        all.map((v) => v.id).toSet().length,
        all.length,
        reason: 'duplicate view ids',
      );
      for (final v in all) {
        expect(
          v.facts.length,
          inInclusiveRange(1, 4),
          reason: '${v.id} has ${v.facts.length} facts',
        );
        expect(v.title, isNotEmpty);
        expect(v.expert.name, isNotEmpty, reason: '${v.id} has no expert name');
      }
    });

    test('every learn-kind engine offering has a page', () {
      for (final o in BookingCatalog.instance.offerings()) {
        if (o.id.startsWith('off_mm_')) continue; // Mind and Mood keeps its tab
        expect(
          PvLearnCatalog.instance.byOfferingId(o.id),
          isNotNull,
          reason:
              '${o.id} (${o.title}) is bookable but has no page — visible and inert',
        );
      }
    });

    test(
      'every stage has something, and the price a page shows is the engine\'s',
      () {
        for (final s in [
          LifeStage.tryingToConceive,
          LifeStage.pregnancy,
          LifeStage.parenting,
        ]) {
          expect(
            PvLearnCatalog.instance.all(stage: s),
            isNotEmpty,
            reason: '${s.name} has nothing to learn',
          );
        }
        for (final v in PvLearnCatalog.instance.all()) {
          if (v.offering != null) {
            expect(
              v.priceMinor,
              v.offering!.priceMinor,
              reason: '${v.id} shows a price the engine will not charge',
            );
          }
        }
      },
    );
  });

  // ===========================================================================
  group('the Learn home and My learning', () {
    for (final s in [
      LifeStage.tryingToConceive,
      LifeStage.pregnancy,
      LifeStage.parenting,
    ]) {
      testWidgets('${s.name}: renders with the kind filter', (tester) async {
        await pumpTall(tester, PvLearnScreen(stage: s));
        expect(tester.takeException(), isNull);
        expect(find.text('Learn'), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Live this week'), findsOneWidget);
      });
    }

    testWidgets('My learning renders empty with an invitation', (tester) async {
      await pumpTall(tester, const PvMyLearningScreen());
      // Since 2026-09-29 the Upcoming section always draws and says so
      // itself, with a way to book (test/pv_store_consistency_test.dart).
      // Kept for revert:
      //   expect(find.textContaining('Nothing here yet'), findsOneWidget);
      expect(find.text('Nothing booked yet.'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('reachable, and the classics are not', () {
    const facades = {
      'lib/screens/post_pregnancy/courses_explore_screen.dart':
          'PvLearnScreen(',
      'lib/screens/prepare/courses_cohorts_screen.dart': 'PvLearnScreen(',
      'lib/screens/post_pregnancy/courses_screen.dart': 'PvLearnScreen(',
      'lib/screens/post_pregnancy/masterclasses_screen.dart': 'PvLearnScreen(',
      'lib/screens/prepare/masterclasses_screen.dart': 'PvLearnScreen(',
      'lib/screens/prepare/cohorts_screen.dart': 'PvLearnScreen(',
      'lib/screens/post_pregnancy/cohort_courses_screen.dart': 'PvLearnScreen(',
      'lib/screens/prepare/consultations_screen.dart': 'PvLearnScreen(',
      'lib/screens/ttc/ttc_prepare_screen.dart': 'PvLearnScreen(',
      'lib/screens/prepare/birthing_classes_screen.dart': 'PvOfferingScreen(',
      'lib/screens/post_pregnancy/learning_detail_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/prepare/program_detail_screen.dart': 'PvOfferingScreen(',
      'lib/screens/post_pregnancy/course_funnel_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/post_pregnancy/masterclass_funnel_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/post_pregnancy/cohort_funnel_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/post_pregnancy/course_detail_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/post_pregnancy/course_lesson_screen.dart': 'PvLessonScreen(',
      'lib/screens/prepare/masterclass_detail_screen.dart': 'PvOfferingScreen(',
      'lib/screens/prepare/cohort_detail_screen.dart': 'PvOfferingScreen(',
      'lib/screens/prepare/consultation_detail_screen.dart':
          'PvOfferingScreen(',
      'lib/screens/post_pregnancy/yoga_class_screen.dart': 'PvOfferingScreen(',
      'lib/screens/ttc/ttc_garbh_course_screen.dart': 'PvOfferingScreen(',
      'lib/screens/post_pregnancy/my_bookings_screen.dart':
          'PvMyLearningScreen(',
      'lib/screens/post_pregnancy/booking_sheet.dart': 'pvLearnCommit(',
      'lib/screens/post_pregnancy/provider_booking_sheet.dart':
          'pvLearnCommit(',
    };
    for (final e in facades.entries) {
      test('${e.key.split('/').last} is a facade', () {
        expect(
          _src(e.key),
          contains(e.value),
          reason: '${e.key} no longer opens the unified screen',
        );
      });
    }

    test(
      'the doctor page opens the one page from its rows and the one flow from its pill',
      () {
        final s = _src(
          'lib/screens/post_pregnancy/provider_profile_screen.dart',
        );
        expect(s, contains('pvOpenOffering(context, v)'));
        expect(s, contains('pvLearnCommit(context, v)'));
        expect(s, contains('PvLearnCatalog.instance.forExpert('));
      },
    );

    test('nothing pushes a learn Classic body', () {
      // The learn classics only — the store's older facades have their own
      // rule. Its own constructor and its own facade's fallback are the only
      // legitimate mentions, and both live in the defining file.
      // A name may be defined twice (MasterclassesScreen exists on both
      // stages), so each maps to every file that defines it.
      final defining = <String, Set<String>>{};
      for (final path in facades.keys) {
        final s = _src(path);
        for (final m in RegExp(
          r'class ([A-Z][A-Za-z]+Classic) ',
        ).allMatches(s)) {
          (defining[m.group(1)!] ??= {}).add(path);
        }
      }
      expect(defining.length, greaterThanOrEqualTo(20));
      for (final f in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final s = _src(f.path);
        final norm = f.path.replaceAll(r'\', '/');
        for (final e in defining.entries) {
          if (!RegExp('\\b${e.key}\\(').hasMatch(s)) continue;
          expect(
            e.value.any(norm.endsWith),
            isTrue,
            reason: '${f.path} pushes ${e.key} from outside its file',
          );
        }
      }
    });
  });

  // ===========================================================================
  //  5 · THE WALK OF 2026-09-22 — the four things the phone caught
  // ===========================================================================
  group('the walk of 2026-09-22', () {
    test('no learn cover is a stock photo invented from a keyword', () {
      // ⚠️ THE ONE THAT ACTUALLY SHIPPED WRONG. `pvLearnCoverFor` keyed a
      // free Unsplash photo off a TOPIC WORD, so four programmes sharing
      // "Birth & Labour" shared one picture — of two toddlers with a tablet
      // — stacked in one scroll. A photograph is welcome (`kPvLearnCovers`
      // is the seam and it is checked first); SYNTHESISING one is not, and
      // the difference is not visible in a screenshot of the code.
      for (final v in PvLearnCatalog.instance.all()) {
        if (v.cover == null) continue;
        expect(
          kPvLearnCovers.containsValue(v.cover),
          isTrue,
          reason:
              '${v.id} has a cover that is not in kPvLearnCovers — a photo '
              'must be chosen for that programme, never derived from a word',
        );
      }
    });

    test('every view has a drawn cover, and topics pick it', () {
      // The floor: a kind always answers, so a programme added tomorrow
      // still has a face rather than a blank pastel.
      for (final v in PvLearnCatalog.instance.all()) {
        expect(pvLearnMarkFor(v.topics, v.kind), isNotNull);
      }
      // And the topic beats the kind, which is the whole point of the map.
      expect(
        pvLearnMarkFor(const ['Birth & Labour'], PvLearnKind.course),
        isNot(pvLearnMarkFor(const [], PvLearnKind.course)),
      );
      expect(
        pvLearnMarkFor(const ['Breastfeeding'], PvLearnKind.masterclass),
        isNot(
          pvLearnMarkFor(const ['Birth & Labour'], PvLearnKind.masterclass),
        ),
      );
    });

    testWidgets('an owned thing shows progress, never a price unit', (t) async {
      // "Yours / yours to keep" under a hero already tagged "Yours" — one
      // fact three times, in the slot that should say how far in she is.
      SharedPreferences.setMockInitialValues({});
      await PvLearnProgressStore.instance.init();
      final v = PvLearnCatalog.instance
          .all(stage: LifeStage.pregnancy, kind: PvLearnKind.course)
          .firstWhere((x) => x.lessons.isNotEmpty);
      await t.pumpWidget(MaterialApp(home: PvOfferingScreen(view: v)));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('yours to keep'), findsNothing);
      // The exact string, not `textContaining` — this course's own subtitle
      // ends "...taught properly, once." and the old assertion caught it.
      expect(find.text('once'), findsNothing);
      expect(find.text('Yours'), findsNothing);
    });

    testWidgets('a lone review is one card, not a rail with a hole', (t) async {
      // The rail equalises card heights with a Spacer; with one card there
      // is nothing to equalise and the gap reads as a loading state.
      const one = [
        PvReviewVoice(
          name: 'Sneha K.',
          context: '28 weeks',
          quote: 'The one place that told me what to actually do.',
        ),
      ];
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PvReviewBlock(
                title: 'What mothers said',
                rating: 4.9,
                countLabel: '240 mothers',
                voices: one,
              ),
            ),
          ),
        ),
      );
      await t.pump();
      expect(find.text('Sneha K.'), findsOneWidget);
      // Her context is on its own line, not folded into the byline.
      expect(find.text('28 weeks'), findsOneWidget);
      // A five-star card draws no stars; the headline carries the average.
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    });
  });
}
