// Relevance Batch 4 (2026-10-28): the homes and the other screens follow where
// she is. docs/door-relevance/README.md, PREGNANCY-GAP.md and TTC-GAP.md hold
// the faults; each group below names the one it pins.
//
// Most of it is pure rules (an order, a tier, a tie-break) tested with inputs;
// where the rule only lives on a screen, the test reads the source for the
// call, because correct-but-unwired code is the failure this repo has hit
// (CLAUDE.md, wiring gate).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/can_i_data.dart';
import 'package:parentveda/data/can_i_groups.dart';
import 'package:parentveda/data/learn/pv_learn_view.dart';
import 'package:parentveda/data/product_data.dart';
import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/models/read_item.dart';
import 'package:parentveda/models/week_content.dart';
import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
import 'package:parentveda/screens/reader/pv_read_offer.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_stage_search.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart' show LifeStage;
import 'package:parentveda/services/bracket_resolver.dart' show bracketById;
import 'package:parentveda/services/preg_tool_order.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart' show kTtcFocusPages;
import 'package:parentveda/services/pv_catalog_store.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';

String _src(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ===========================================================================
  //  PREGNANCY
  // ===========================================================================

  group('PREG 8 · the Tools tab by her week', () {
    test('a row in its time leads; before it, it waits behind the rest', () {
      final rows = ['weight', 'kicks', 'medicines'];
      int? from(String r) => r == 'kicks' ? kPregToolsThirdTrimesterFrom : null;
      expect(orderPregToolsByWeek(rows, from, week: 8), ['weight', 'medicines', 'kicks']);
      expect(orderPregToolsByWeek(rows, from, week: 28), ['kicks', 'weight', 'medicines']);
      expect(orderPregToolsByWeek(rows, from, week: null), rows,
          reason: 'no due date: the week-20 stand-in moves nothing');
    });

    test('a group only lifts: before its week it keeps its place', () {
      final groups = ['Track', 'Get ready', 'Keep', 'Ask'];
      int? from(String g) => g == 'Get ready' ? kPregToolsThirdTrimesterFrom : null;
      expect(orderPregToolsByWeek(groups, from, week: 10, liftOnly: true), groups);
      expect(orderPregToolsByWeek(groups, from, week: 30, liftOnly: true),
          ['Get ready', 'Track', 'Keep', 'Ask']);
    });

    test('order, never hiding: every item back once, at every week', () {
      final rows = List.generate(7, (i) => 'r$i');
      int? from(String r) => switch (r) { 'r1' => 28, 'r4' => 37, _ => null };
      for (var w = 1; w <= 42; w++) {
        final o = orderPregToolsByWeek(rows, from, week: w);
        expect(o.length, rows.length);
        expect(o.toSet(), rows.toSet());
      }
    });

    test('wired: the tab orders groups and rows through the rule', () {
      final s = _src('lib/screens/tools_hub_screen.dart');
      expect(s, contains('orderPregToolsByWeek(groups'));
      expect(s, contains('(t) => t.fromWeek'));
      expect(s, contains("leadsFromWeek: kPregToolsThirdTrimesterFrom"));
      expect(s, contains('fromWeek: kPregToolsTimerFrom'));
      expect(s, contains('controller.isDueDateSet ? controller.currentWeek : null'));
    });
  });

  // The rail's inputs, as the other rail tests build them.
  final weeks = {
    for (final j in jsonDecode(File('lib/data/weekContent.json').readAsStringSync()) as List)
      (j as Map)['week'] as int: WeekContent.fromJson(j.cast<String, dynamic>()),
  };
  List<PregInsight> cards(int week, {bool stale = false}) {
    final d = DateTime(2026, 10, 28);
    return pregInsightsFor(
      date: d,
      today: d,
      day: week * 7,
      week: week,
      homeDay: null,
      weekContent: weeks[week],
      reads: const [],
      dueDateMayBeStale: stale,
    );
  }

  group('PREG 12 · "Is it safe?" for her trimester', () {
    test('the card picks from entries with a note for her trimester', () {
      for (final w in [8, 20, 34]) {
        final c = cards(w).where((x) => x.go == PregInsightGo.safe).firstOrNull;
        expect(c, isNotNull, reason: 'week $w');
        expect(canINoteForWeek(c!.entry!, w), isNotNull,
            reason: 'week $w picked ${c.entry!.id}, which says nothing for her trimester');
      }
    });

    test('every trimester has entries to pick from', () {
      for (final w in [8, 20, 34]) {
        expect(canIForTrimester(w), isNotEmpty, reason: 'week $w');
      }
      expect(kCanIEntries, isNotEmpty);
    });
  });

  group('PREG 13 · a dating scan date, on the home', () {
    bool has(List<PregInsight> c) => c.any((x) => x.id == 'due_date_scan');
    test('from 14 while our date may be stale, and only up to 27', () {
      expect(has(cards(16, stale: true)), isTrue);
      expect(has(cards(27, stale: true)), isTrue);
      expect(has(cards(28, stale: true)), isFalse,
          reason: 'later scans measure growth, they do not re-date');
      expect(has(cards(16)), isFalse, reason: 'a clinic date, or not stale');
    });

    test('wired: the home passes the flag and the tap opens the due-date page', () {
      final s = _src('lib/screens/home_v3_screen.dart');
      expect(s, contains('dueDateMayBeStale: pregnancy.dueDateMayBeStale'));
      expect(s, contains('case PregInsightGo.dueDate:'));
    });

    test('his side never gets it', () {
      final s = _src('lib/screens/pregnancy/preg_partner_home.dart');
      expect(s.contains("'due_date_scan'"), isFalse,
          reason: 'his rail is a whitelist; the date is hers');
    });
  });

  group('PREG 14 · products by how close they are to her week', () {
    PvProduct prod(int? from) => PvProduct(
        id: 'p$from', stage: LifeStage.pregnancy, categoryId: 'c', name: 'n', weekFrom: from);
    test('due about now, then any week, then further off', () {
      expect(pvWeekTier(prod(36), 34), 0);
      expect(pvWeekTier(prod(30), 34), 0);
      expect(pvWeekTier(prod(null), 34), 1);
      expect(pvWeekTier(prod(20), 34), 2);
    });

    test("the home's categories: nearest start first", () {
      final at36 = recommendedCategories(36);
      expect(at36, isNotEmpty);
      final gaps = [for (final c in at36) (c.fromWeek - 36).abs()];
      expect(gaps, [...gaps]..sort(), reason: 'week 36 led with week-12 categories');
      // Ranking, never a filter.
      expect(at36.toSet(), {
        for (final c in kProductCategories) if (c.relevantAt(36)) c,
      });
    });

    test('wired: forYou ranks by the tier', () {
      expect(_src('lib/services/pv_catalog_store.dart'), contains('pvWeekTier(a, week)'));
    });
  });

  group('handed over by the tools terminal (P1)', () {
    test("the home's readings tile opens the readings log, not Weight", () {
      final s = _src('lib/screens/home_v3_screen.dart');
      expect(s, contains('''case kPgActTrackReadings:
        _openSurfaceScreen(context, 'readings');'''));
      expect(_src('lib/services/surface_router.dart'), contains("'readings' =>"));
    });

    test('the ingredient checker promises ingredients, not products', () {
      final s = _src('lib/data/doors/pv_door_belly_skin.dart');
      expect(s, contains("heading: 'Check an ingredient',"));
    });
  });

  group('PREG 7 · past 40 the labels follow the hero', () {
    test('the home titles and More use the past-due week', () {
      final home = _src('lib/screens/home_v3_screen.dart');
      for (final t in [
        "'Your baby in week \${_pageWeek(week)}'",
        "'Reads for week \${_pageWeek(week)}'",
        "'Picked for week \${_pageWeek(week)}'",
      ]) {
        expect(home, contains(t));
      }
      expect(_src('lib/screens/pregnancy/preg_more_screen.dart'),
          contains('pregPastDueWeek(-_c.daysPastDue) ?? _c.currentWeek'));
    });
  });

  group('PREG 15 · search ties go to her week', () {
    test('wired: every search passes her real week', () {
      final s = _src('lib/screens/search/pv_search_screen.dart');
      expect(s, contains('weeks: s.weeks'));
      expect('week: pvSearchWeekOf(widget.pregnancy)'.allMatches(s).length, 2);
      final d = _src('lib/screens/doors/pv_door_screen.dart');
      expect(RegExp(r'pvSearch\([^;]*week:').allMatches(d).length, 3);
    });
  });

  group('PREG 24 · reads padded with the nearest weeks', () {
    test('padding never skips a closer read for a further one', () {
      int gap(ReadItem r, int w) =>
          w < r.weekStart ? r.weekStart - w : (w > r.weekEnd ? w - r.weekEnd : 0);
      final articles = [for (final r in kReadItems) if (r.type == ReadType.article) r];
      for (var w = 4; w <= 40; w++) {
        final got = dailyArticleReads(w, 0);
        final worst = got.map((r) => gap(r, w)).fold(0, (a, b) => a > b ? a : b);
        final closerLeftOut = articles
            .where((r) => !got.contains(r))
            .where((r) => gap(r, w) < worst);
        expect(closerLeftOut, isEmpty, reason: 'week $w');
      }
    });
  });

  // ===========================================================================
  //  TTC
  // ===========================================================================

  group('TTC 4 · the Store needs, quieter in a round or after a loss', () {
    final needs = [
      'product:ttc_folic',
      'shelf:ttc_kits',
      'shelf:ttc_tests',
      'shelf:ttc_supplements',
      'shelf:ttc_books',
    ];
    test('kits and tests go last, every row stays', () {
      expect(pvTtcNeedsInOrder(needs, (n) => n, quieter: false), needs);
      final q = pvTtcNeedsInOrder(needs, (n) => n, quieter: true);
      expect(q.take(3), ['product:ttc_folic', 'shelf:ttc_supplements', 'shelf:ttc_books']);
      expect(q.toSet(), needs.toSet());
    });

    test('wired: the Store and the home rail read the same rule', () {
      expect(_src('lib/screens/products/pv_store_screen.dart'),
          contains('quieter: ttcHomeHidesQuickRow(DateTime.now()) ||'));
      expect(_src('lib/screens/ttc/ttc_home_v3.dart'), contains('pvTtcNeedsInOrder('));
    });
  });

  group('TTC 6 · the check card reads the doctor check', () {
    (String, String)? card(FertilityHelpContext c,
            {bool own = true, bool inCare = false, bool pregnant = false}) =>
        ttcHomeCheckFrom(evaluateFertilityHelp(c),
            ownCycle: own, inCare: inCare, pregnant: pregnant);

    test('two losses bring it up, with no months at all', () {
      final c = card(const FertilityHelpContext(
          daysTrying: 30, ageBand: FertilityAgeBand.under35, priorMiscarriages: 2));
      expect(c, isNotNull);
      expect(c!.$2, contains('two or more losses'));
    });

    test('over 40 brings it up from the start', () {
      expect(
          card(const FertilityHelpContext(daysTrying: 10, ageBand: FertilityAgeBand.over40)),
          isNotNull);
    });

    test('the months still do: a year under 35', () {
      expect(
          card(const FertilityHelpContext(daysTrying: 370, ageBand: FertilityAgeBand.under35)),
          isNotNull);
      expect(
          card(const FertilityHelpContext(daysTrying: 100, ageBand: FertilityAgeBand.under35)),
          isNull);
    });

    test('never when pregnant, in care, or while a clinic owns the cycle', () {
      const c = FertilityHelpContext(
          daysTrying: 30, ageBand: FertilityAgeBand.under35, priorMiscarriages: 2);
      expect(card(c, pregnant: true), isNull);
      expect(card(c, inCare: true), isNull);
      expect(card(c, own: false), isNull);
    });

    test('wired: the home shows ttcHomeCheckNow', () {
      final s = _src('lib/screens/ttc/ttc_home_v3.dart');
      expect(s, contains(': ttcHomeCheckNow();'));
      expect(s, contains('TtcCheckCard(p: p, title: check.\$1, body: check.\$2)'));
    });
  });

  group('TTC 10 · the Tools tab on a clinic cycle', () {
    test('Care and medicines leads, the round, medicines and visits first', () {
      final o = ttcToolsInOrder(him: false, clinicCycle: true);
      expect(o.first.titleEn, 'Care and medicines');
      expect(o.first.tools.take(3).map((t) => t.id), kTtcClinicCycleLeadIds);
    });

    test('her own cycle: the list as written', () {
      expect(ttcToolsInOrder(him: false, clinicCycle: false), same(ttcToolGroups));
    });

    test('order only: every group and every tool, once', () {
      for (final him in [false, true]) {
        final a = ttcToolGroupsFor(him: him);
        final b = ttcToolsInOrder(him: him, clinicCycle: true);
        expect(b.map((g) => g.titleEn).toSet(), a.map((g) => g.titleEn).toSet());
        expect([for (final g in b) ...g.tools.map((t) => t.id)]..sort(),
            [for (final g in a) ...g.tools.map((t) => t.id)]..sort());
      }
    });

    test('wired: the tab asks who owns the cycle', () {
      expect(_src('lib/screens/ttc/ttc_tools_screen.dart'),
          contains('clinicCycle: TtcStore.instance.ownership != TimingOwnership.parentveda'));
    });
  });

  group('TTC 12 · one start on day one', () {
    test('the checklist step waits for a period; 101 waits for the film', () {
      final s = _src('lib/screens/ttc/ttc_home_v3.dart');
      expect(s, contains('todayState.noEstimate != TtcNoEstimate.noPeriodLogged &&'));
      expect(s, contains('!TtcIntroGate.cardShowing()) ...['));
    });
  });

  group('TTC 13 · Learn follows the home', () {
    test('her topics come in the order given; his own door still leads his', () {
      final reversed = ttcLearnTopics(
              him: false, order: (ids) => ids.reversed.toList())
          .map((t) => t.bracket.id)
          .toList();
      final straight =
          ttcLearnTopics(him: false, order: (ids) => ids).map((t) => t.bracket.id).toList();
      expect(reversed, straight.reversed.toList());
      expect(ttcLearnTopics(him: true).map((t) => t.bracket.id).take(2), kTtcHisLearnFirst);
    });
  });

  group('TTC 14 · no report card on a clinic cycle', () {
    test('the card is gated on her own cycle', () {
      final s = _src('lib/screens/ttc/ttc_home_v3.dart');
      final i = s.indexOf("id: 'report',");
      expect(s.substring(i - 400, i),
          contains('if (TtcStore.instance.ownership == TimingOwnership.parentveda)'));
    });
  });

  group('TTC 15 · no clinician offered mid-round', () {
    LocalizedText l(String s) => LocalizedText(en: s, hi: s);
    PvOfferingView offer(String id, PvLearnKind kind, String title) => PvOfferingView(
          id: id,
          stage: LifeStage.tryingToConceive,
          kind: kind,
          title: title,
          subtitle: '',
          about: '',
          expert: const PvLearnExpert(id: 'x', name: 'X', role: ''),
          hue: 0,
        );
    final catalog = [
      offer('doc', PvLearnKind.consult, 'Fertility specialist consult'),
      offer('course', PvLearnKind.course, 'IVF from the start'),
      offer('gyn', PvLearnKind.consult, 'Gynaecologist consult'),
    ];
    final read = PvRead(
      id: 'ttc_ivf_x',
      kicker: l(''),
      title: l('Your IVF fertility questions'),
      teaser: l(''),
      scaleSetter: l(''),
      author: l('ParentVeda team'),
      authorRole: l(''),
      hue: 0,
      sections: [PvReadSection(heading: l('One'), paragraphs: [l('Text.')])],
      whenToSeeSomeone: kPvShortPieceCallout,
      faqs: const [],
    );

    test('own cycle: the fertility doctor; clinic cycle: the course instead', () {
      expect(pvReadOfferFor(read, catalog: catalog)?.id, 'doc');
      expect(pvReadOfferFor(read, catalog: catalog, clinicOwnsCycle: true)?.id, 'course');
    });

    test('wired: the reader passes the clinic state for TTC reads', () {
      expect(_src('lib/screens/reader/pv_reader_screen.dart'),
          contains('pvReadClinicOwnsCycleNow()'));
    });
  });

  group('TTC 16 · test day leads with the result', () {
    test('Tell result is the main button on testDay; no duplicate otherwise', () {
      final s = _src('lib/screens/ttc/ttc_treatment_round_screens.dart');
      expect(s, contains('''primary: phase == TtcRoundPhase.testDay
              ? (kTtcRoundTellResult'''));
      expect(s, contains(''': null,
        );'''));
    });
  });

  group('TTC 17 · yoga is gentle in a round or after a loss', () {
    test('no Fertility yoga rail then', () {
      final s = _src('lib/screens/post_pregnancy/yoga_home_screen.dart');
      expect(s, contains("if (!gentle) ..._rail(p, 'Fertility yoga'"));
      expect(s, contains('ttcHomeRoundPhaseOn(now)?.isRunning'));
      expect(s, contains('lossRecentlyClosed(now: now)'));
    });
  });

  group('TTC 18 · search ties go to her moment', () {
    test('equal scores come in the order of her doors', () {
      List<String> backwards(List<String> ids) => ids.reversed.toList();
      // Door labels, in the (backwards) order the search is handed.
      final labels = [
        for (final id in backwards([for (final p in kTtcFocusPages) p.bracketId]))
          if (bracketById(id) case final b?) b.label.en,
      ];
      final rank = {for (var i = 0; i < labels.length; i++) labels[i]: i};
      for (final q in ['cycle', 'ivf', 'sleep', 'test', 'period']) {
        final hits = ttcStageSearch(q, order: backwards, perKind: 50);
        final ids = labels;
        for (var i = 1; i < hits.length; i++) {
          final a = hits[i - 1], b = hits[i];
          if (a.kind != b.kind || a.score != b.score) continue;
          final ra = rank[a.door] ?? ids.length, rb = rank[b.door] ?? ids.length;
          expect(ra <= rb, isTrue, reason: '"$q": ${a.title} before ${b.title}');
        }
      }
    });
  });
}
