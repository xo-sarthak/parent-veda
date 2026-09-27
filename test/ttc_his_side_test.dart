// =============================================================================
//  His side, and the rules "Read your semen report" must never break
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE MOST DANGEROUS TOOL IN THE STAGE AND THE TESTS ARE THE SPEC.
//
//  It takes four numbers off a medical report and says something about them. A
//  single careless sentence here does not produce a bad layout — it tells a man
//  alone at midnight that he is infertile, on the strength of one sample, which
//  is both wrong and the exact thing the tool exists to prevent.
//
//  So the rules from the brief are asserted rather than trusted to prose:
//  no score, no verdict, a single low number is never a conclusion, the
//  reference limits have exactly one source, and every path ends at a real
//  andrologist.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_semen_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/focus/ttc_focus_his_side.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_semen_limits.dart';
import 'package:parentveda/ttc/ttc_semen_reading.dart';

/// Everything the tool could ever say, as one string.
String _allText(TtcSemenReading r) => [
      r.headline,
      r.body,
      r.extra ?? '',
      r.abstinenceNote ?? '',
      for (final l in r.lines) l.sentence,
    ].join(' ').toLowerCase();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  group('the reference limits have exactly one source', () {
    test('the four WHO 2021 numbers are what the brief specifies', () {
      expect(ttcSemenLimit('concentration')!.limit, 16);
      expect(ttcSemenLimit('total_motility')!.limit, 42);
      expect(ttcSemenLimit('progressive_motility')!.limit, 30);
      expect(ttcSemenLimit('morphology')!.limit, 4);
    });

    test('and the article prints the same figures, generated not retyped', () {
      // ⚠️ THE WHOLE POINT OF `ttc_semen_limits.dart`. The article used to
      // carry these numbers as hand-written prose; the tool now computes with
      // them. Two copies of a clinical threshold in one app is how an article
      // and a tool quietly disagree after a guideline update.
      final read = ttcReadById('ttc_read_semen_analysis')!;
      final text = [
        for (final s in read.sections) ...[
          ...s.paragraphs.map((p) => p.en),
          ...s.bullets.map((b) => b.en),
        ],
      ].join(' ');
      for (final l in kTtcSemenLimits) {
        expect(text, contains(l.limitText),
            reason: '${l.name} no longer appears in the article it came from');
      }
    });

    test('the framing travels with the numbers', () {
      // A list of four values against four thresholds, with no explanation of
      // what the thresholds are, is a scorecard.
      expect(kTtcSemenNotAPassMark.toLowerCase(), contains('not a pass mark'));
      expect(kTtcSemenLimitsSource, contains('fifth percentile'));
      expect(kTtcSemenBelowLineNote.toLowerCase(),
          contains('not a conclusion'));
    });

    test('morphology carries its own anti-alarm note', () {
      // The number that frightens more men than any other on the page.
      final m = ttcSemenLimit('morphology')!;
      expect(m.note, isNotNull);
      expect(m.note!.toLowerCase(), contains('strictly'));
      expect(m.note!.toLowerCase(), contains('not a borderline'));
    });
  });

  // ===========================================================================
  group('no path ever gives a verdict', () {
    /// Every shape of entry the tool can receive.
    final cases = <String, TtcSemenEntry>{
      'nothing entered': const TtcSemenEntry(),
      'all normal': const TtcSemenEntry(values: {
        'concentration': 40,
        'total_motility': 60,
        'progressive_motility': 45,
        'morphology': 8,
      }),
      'all below': const TtcSemenEntry(values: {
        'concentration': 4,
        'total_motility': 20,
        'progressive_motility': 10,
        'morphology': 1,
      }),
      'one below, first test': const TtcSemenEntry(values: {
        'concentration': 40,
        'morphology': 2,
      }),
      'one below, repeat': const TtcSemenEntry(
          values: {'concentration': 4}, isRepeat: true),
      'azoospermia': const TtcSemenEntry(noSpermFound: true),
      'red flag': const TtcSemenEntry(
          values: {'concentration': 40}, redFlags: {'testosterone'}),
      'short abstinence': const TtcSemenEntry(
          values: {'concentration': 40}, abstinenceDays: 1),
      'long abstinence': const TtcSemenEntry(
          values: {'concentration': 40}, abstinenceDays: 10),
    };

    for (final e in cases.entries) {
      test('${e.key}: says nothing about being fertile or infertile', () {
        final text = _allText(ttcReadSemenReport(e.value));
        for (final banned in [
          'you are fertile',
          'you are infertile',
          'infertile',
          'sterile',
          'your chance',
          'your odds',
          'per cent chance',
          'likelihood of conceiving',
          'score',
        ]) {
          expect(text.contains(banned), isFalse,
              reason: '"$banned" appears on the ${e.key} path');
        }
      });
    }

    test('and the outcome has no field a score could live in', () {
      // Structural, not editorial. `TtcSemenReading` carries a route, the
      // lines, and sentences — there is nowhere to put a number even if
      // somebody wanted to.
      final r = ttcReadSemenReport(const TtcSemenEntry(
          values: {'concentration': 40, 'morphology': 8}));
      expect(r.route, isA<TtcSemenRoute>());
      expect(r.lines, isNotEmpty);
    });
  });

  // ===========================================================================
  group('routing, top to bottom, first match wins', () {
    test('a red flag beats everything, including good numbers', () {
      // ⚠️ ORDER IS THE SAFETY. A man with a lump and a normal count must be
      // told to see somebody about the lump. Reordering these branches is a
      // clinical change, not a refactor.
      final r = ttcReadSemenReport(const TtcSemenEntry(
        values: {
          'concentration': 60,
          'total_motility': 70,
          'progressive_motility': 55,
          'morphology': 10,
        },
        redFlags: {'lump'},
      ));
      expect(r.route, TtcSemenRoute.urgent);
    });

    test('and it always says not to stop a prescribed medicine', () {
      // Testosterone is one of the four flags, and "stop taking it" is exactly
      // what a man reads into this.
      final r = ttcReadSemenReport(
          const TtcSemenEntry(redFlags: {'testosterone'}));
      expect(r.extra, isNotNull);
      expect(r.extra!.toLowerCase(), contains('do not stop'));
      expect(r.extra!.toLowerCase(), contains('prescribed'));
    });

    test('azoospermia beats a low number and routes to a specialist', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(
          noSpermFound: true, values: {'morphology': 1}));
      expect(r.route, TtcSemenRoute.azoospermia);
      // ⚠️ AND IT LEADS WITH THE HOPEFUL PART. "No sperm found" is read as the
      // end of the road by almost everybody, and very often it is not.
      expect(r.body.toLowerCase(), contains('not the end of the road'));
      expect(r.body.toLowerCase(), contains('retrieved'));
    });

    test('a red flag still beats azoospermia', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(
          noSpermFound: true, redFlags: {'lump'}));
      expect(r.route, TtcSemenRoute.urgent);
    });

    test('one number below on a first test asks for a repeat, not a decision',
        () {
      final r = ttcReadSemenReport(
          const TtcSemenEntry(values: {'concentration': 40, 'morphology': 2}));
      expect(r.route, TtcSemenRoute.repeatFirst);
      expect(r.headline.toLowerCase(), contains('repeat'));
      expect(r.body.toLowerCase(), contains('vary'));
    });

    test('on a repeat it asks for both to be read together, not a third', () {
      // Telling a man on his second low result to go and have a third is the
      // app stalling rather than helping.
      final r = ttcReadSemenReport(const TtcSemenEntry(
          values: {'concentration': 4}, isRepeat: true));
      expect(r.route, TtcSemenRoute.repeatFirst);
      expect(r.body.toLowerCase(), contains('side by side'));
      expect(r.headline.toLowerCase(), isNot(contains('repeat')));
    });

    test('all at or above the line does not close the question', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(values: {
        'concentration': 16,
        'total_motility': 42,
        'progressive_motility': 30,
        'morphology': 4,
      }));
      expect(r.route, TtcSemenRoute.usualRange);
      expect(r.anyBelow, isFalse, reason: 'exactly at the line is not below');
      expect(r.body.toLowerCase(), contains('does not guarantee'));
    });

    test('nothing entered guesses nothing', () {
      final r = ttcReadSemenReport(const TtcSemenEntry());
      expect(r.route, TtcSemenRoute.tooLittle);
      expect(r.body.toLowerCase(), contains('guessing'));
      for (final l in r.lines) {
        expect(l.entered, isFalse);
        expect(l.sentence.toLowerCase(), contains('not entered'));
      }
    });
  });

  // ===========================================================================
  group('the abstinence window', () {
    test('outside 2 to 7 days, the numbers are flagged as unreliable', () {
      for (final d in [1, 10]) {
        final r = ttcReadSemenReport(TtcSemenEntry(
            values: const {'concentration': 40}, abstinenceDays: d));
        expect(r.abstinenceNote, isNotNull, reason: '$d days');
        expect(r.abstinenceNote!.toLowerCase(), contains('may not be reliable'));
      }
    });

    test('inside the window, nothing is said', () {
      for (final d in [2, 5, 7]) {
        final r = ttcReadSemenReport(TtcSemenEntry(
            values: const {'concentration': 40}, abstinenceDays: d));
        expect(r.abstinenceNote, isNull, reason: '$d days');
      }
    });

    test('and the flag survives a perfectly normal set of numbers', () {
      // A sample produced after twelve days is not comparable to the reference
      // limits whatever it came out as — including when it came out fine.
      final r = ttcReadSemenReport(const TtcSemenEntry(
        values: {
          'concentration': 60,
          'total_motility': 70,
          'progressive_motility': 55,
          'morphology': 10,
        },
        abstinenceDays: 12,
      ));
      expect(r.route, TtcSemenRoute.usualRange);
      expect(r.abstinenceNote, isNotNull);
    });
  });

  // ===========================================================================
  group('the lines read the way the brief words them', () {
    test('every entered value states the value, the line and which side', () {
      final r = ttcReadSemenReport(
          const TtcSemenEntry(values: {'concentration': 12}));
      final line = r.lines.firstWhere((l) => l.limit.id == 'concentration');
      expect(line.sentence, contains('12'));
      expect(line.sentence, contains('16 million per ml'));
      expect(line.sentence, contains('Below the line'));
    });

    test('exactly at the limit is in the usual range, not below', () {
      final r = ttcReadSemenReport(
          const TtcSemenEntry(values: {'morphology': 4}));
      expect(r.lines.firstWhere((l) => l.limit.id == 'morphology').below,
          isFalse);
    });

    test('five per cent morphology is normal, and nothing says otherwise', () {
      // The brief: "do not let a low-looking morphology number read as bad".
      final r = ttcReadSemenReport(
          const TtcSemenEntry(values: {'morphology': 5}));
      final line = r.lines.firstWhere((l) => l.limit.id == 'morphology');
      expect(line.below, isFalse);
      expect(line.sentence, contains('In the usual range'));
    });
  });

  // ===========================================================================
  group('it renders, and it ends at a person', () {
    testWidgets('the tool builds and reads back', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
          const MaterialApp(home: TtcSemenReportScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Read it back to me'), findsOneWidget);

      await tester.tap(find.text('Read it back to me'));
      await tester.pumpAndSettle();

      // ⚠️ THE TWO ACTIONS EVERY PATH ENDS WITH, from the brief.
      expect(find.text('Have the report read properly'), findsOneWidget);
      expect(find.text('Keep his reports with yours'), findsOneWidget);
    });

    test('the surface resolves', () {
      expect(ttcScreenForSurface('ttc_semen_report'), isNotNull);
    });
  });

  // ===========================================================================
  group('single source, across doors', () {
    test('His side owns male-factor content and others reference it', () {
      // Step 5a. Getting ready's "His part" names a read defined in His side.
      final reads = <String>{};
      for (final page in kTtcFocusPages) {
        for (final tile in page.allTiles) {
          if (tile is TtcArticleTile && tile.readId != null) {
            reads.add(tile.readId!);
          }
          if (tile is TtcGuideTile) reads.add(tile.readId);
        }
      }
      expect(reads, contains('ttc_read_whose_side'));
      for (final id in reads) {
        expect(ttcReadById(id), isNotNull, reason: '"$id" is not in kTtcReads');
      }
    });

    test('"keep the reports" is ONE surface shown in two doors', () {
      // Step 5b. Two records screens that must agree with each other is how
      // records rot.
      final owners = <String>[];
      for (final page in kTtcFocusPages) {
        for (final tile in page.allTiles.whereType<TtcToolTile>()) {
          if (tile.surfaceId == 'ttc_records') owners.add(page.bracketId);
        }
      }
      expect(owners.length, greaterThanOrEqualTo(2),
          reason: 'only one door points at the records folder');
      expect(owners.toSet().length, owners.length,
          reason: 'one door lists the records folder twice');
    });

    test('the course is one offering id, shown twice, not two courses', () {
      // Step 5c.
      final ids = [
        kTtcHisSideFocus.headline!.offeringId,
        for (final t
            in kTtcHisSideFocus.allTiles.whereType<TtcMasterclassTile>())
          t.offeringId,
      ];
      expect(ids.toSet().length, 1, reason: 'two different course ids');
    });

    test('the emotional pointer is a DOOR to Mind and body, and builds nothing',
        () {
      // Step 4b: "a single pointer card that deep-links to the Mind and body
      // focus area. Do not build stress content here." A door, not one of
      // that area's articles — and the door must resolve.
      final tile = kTtcHisSideFocus.allTiles
          .whereType<TtcDoorTile>()
          .firstWhere((t) => t.title == 'His emotional side');
      expect(tile.bracketId, 'ttc_mind_body');
      expect(ttcFocusPageFor(tile.bracketId), isNotNull);
    });
  });

  // ===========================================================================
  //  2026-09-06 — the brief as source of truth, and the substitutions undone
  // ===========================================================================
  group('every tile opens the thing it promises, not the nearest thing', () {
    TtcTile tileTitled(String title) =>
        kTtcHisSideFocus.allTiles.firstWhere((t) => t.title == title);

    test('no two tiles on the page open the same read', () {
      // "The case for testing early" and "What three months looks like"
      // used to open the article next to them. A tile is a promise; two
      // promises that resolve to one page is one broken promise.
      final ids = <String>[
        for (final t in kTtcHisSideFocus.allTiles)
          if (t is TtcArticleTile && t.readId != null)
            t.readId!
          else if (t is TtcGuideTile)
            t.readId,
      ];
      expect(ids.toSet().length, ids.length,
          reason: 'a read is opened by more than one tile: $ids');
    });

    test('"What three months looks like" is a Guide with its own plan', () {
      final t = tileTitled('What three months looks like');
      expect(t, isA<TtcGuideTile>());
      final read = ttcReadById((t as TtcGuideTile).readId)!;
      expect(read.id, isNot('ttc_read_heat_habits'));
      // A plan has weeks in it.
      final headings = [for (final s in read.sections) s.heading?.en ?? ''];
      expect(headings.where((h) => h.startsWith('Week')).length,
          greaterThanOrEqualTo(3));
      expect(headings.firstWhere((h) => h.isNotEmpty), startsWith('Day one'));
    });

    test('"Zinc and CoQ10, honestly" is an Article, and the shelf sits beside it',
        () {
      final article = tileTitled('Zinc and CoQ10, honestly');
      expect(article, isA<TtcArticleTile>());
      expect(ttcReadById((article as TtcArticleTile).readId!), isNotNull);
      final shelf = kTtcHisSideFocus.allTiles.whereType<TtcProductTile>();
      expect(shelf.length, 1);
      expect(shelf.single.category, 'supplements');
      // Article before product, in the same section — the order is the ethics.
      final section = kTtcHisSideFocus.sections
          .firstWhere((s) => s.heading == 'Supplements, honestly');
      expect(section.tiles.first, isA<TtcArticleTile>());
      expect(section.tiles.last, isA<TtcProductTile>());
    });

    test('"The case for testing early" is its own short piece that bridges on',
        () {
      final t = tileTitled('The case for testing early') as TtcArticleTile;
      final read = ttcReadById(t.readId!)!;
      expect(read.id, isNot('ttc_read_semen_analysis'));
      // The bridge into tab 2: the piece hands over to the test article and
      // the tool.
      expect(read.readNext, contains('ttc_read_semen_analysis'));
      expect(read.nextSteps.map((n) => n.surfaceId),
          contains('ttc_semen_report'));
    });

    test('"What he can track" opens HIS tracker, not the tools hub', () {
      final t = tileTitled('What he can track') as TtcToolTile;
      expect(t.surfaceId, 'ttc_partner_health');
      expect(ttcScreenForSurface(t.surfaceId), isNotNull);
    });

    test('both Talk tiles open the andrologist, not the consults shelf', () {
      final talks = kTtcHisSideFocus.allTiles.whereType<TtcTalkTile>();
      expect(talks.length, 2);
      for (final t in talks) {
        expect(t.action, kTtcOfferingAndrologist);
      }
      final offering = ttcOfferingById(kTtcOfferingAndrologist);
      expect(offering, isNotNull);
      expect(offering!.category, 'consults');
      expect(offering.bodyEn.toLowerCase(), contains('andrologist'));
    });

    test('"Reasons to be seen sooner" is pinned on Talk, as a reused callout',
        () {
      // The brief: "calm red-flag card (reuse callout)… keep the red-flag
      // card visible either way".
      final talk = kTtcHisSideFocus.groups!.firstWhere((g) => g.id == 'talk');
      expect(talk.pinnedRedFlagReadIds, isNotEmpty);
      final read = ttcReadById(talk.pinnedRedFlagReadIds.single)!;
      expect(read.whenToSeeSomeone.title.en.toLowerCase(),
          contains('seen sooner'));
    });

    test('no His side read starts folded — Step 7, "remove the accordions"',
        () {
      for (final read in kTtcReads.where((r) => r.kicker.en == 'His side')) {
        for (final s in read.sections) {
          expect(s.collapsible, isFalse,
              reason: '${read.id}: "${s.heading?.en}" is an accordion');
        }
      }
    });
  });

  // ===========================================================================
  group('the tool does what its buttons say', () {
    test('volume is read back, reported and never compared', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(
        values: {'concentration': 20},
        volumeMl: 1.2,
      ));
      expect(r.volumeSentence, contains('1.2 ml'));
      expect(r.volumeSentence!.toLowerCase(), contains('not one of the four'));
      expect(r.volumeSentence!.toLowerCase(), isNot(contains('below')));
    });

    test('the usual-range path, and only that path, points to IVF and IUI',
        () {
      final ok = ttcReadSemenReport(const TtcSemenEntry(values: {
        'concentration': 20,
        'total_motility': 50,
        'progressive_motility': 35,
        'morphology': 5,
      }));
      expect(ok.route, TtcSemenRoute.usualRange);
      expect(ok.coupleReadiness, isTrue);

      final low = ttcReadSemenReport(
          const TtcSemenEntry(values: {'concentration': 10}));
      expect(low.coupleReadiness, isFalse);
      final none = ttcReadSemenReport(const TtcSemenEntry());
      expect(none.coupleReadiness, isFalse);
      final flag = ttcReadSemenReport(const TtcSemenEntry(
        values: {
          'concentration': 20,
          'total_motility': 50,
          'progressive_motility': 35,
          'morphology': 5,
        },
        redFlags: {'lump'},
      ));
      expect(flag.coupleReadiness, isFalse);
    });

    test('the saved record carries every number, in report order, on his side',
        () {
      const e = TtcSemenEntry(
        values: {'concentration': 12, 'progressive_motility': 28.5},
        volumeMl: 2,
        isRepeat: false,
        abstinenceDays: 3,
      );
      final value = ttcSemenRecordValue(e);
      expect(
          value,
          'Concentration 12 million per ml · '
          'Progressive motility 28.5 per cent · Volume 2 ml');
      final note = ttcSemenRecordNote(e);
      expect(note, startsWith('First test'));
      expect(note, contains('3 days'));
      // And nothing is guessed: a value he did not enter is not in the record.
      expect(value.toLowerCase(), isNot(contains('morphology')));
    });

    test('azoospermia saves as the sentence, not as a zero', () {
      expect(ttcSemenRecordValue(const TtcSemenEntry(noSpermFound: true)),
          contains('azoospermia'));
    });

    testWidgets(
        '"Keep his reports with yours" writes ONE record and opens the folder',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = TtcRecordsStore.instance;
      await store.ensureLoaded();
      final before = store.count;

      await tester.pumpWidget(
          const MaterialApp(home: TtcSemenReportScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read it back to me'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep his reports with yours'));
      await tester.pumpAndSettle();

      expect(store.count, before + 1);
      final saved = store.records.first;
      expect(saved.forPartner, isTrue, reason: 'it is HIS report');
      expect(saved.testId, 'semen');
      expect(saved.label, 'Semen analysis');

      // The folder opened on top.
      expect(find.text('Kept with your reports. Open the folder'),
          findsNothing);

      // Back, and a second tap does not write a second row.
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Kept with your reports. Open the folder'),
          findsOneWidget);
      await tester.tap(find.text('Kept with your reports. Open the folder'));
      await tester.pumpAndSettle();
      expect(store.count, before + 1);
    });

    testWidgets('a normal result shows the IVF and IUI gateway', (tester) async {
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
          const MaterialApp(home: TtcSemenReportScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      final good = [20, 50, 35, 5];
      for (var i = 0; i < 4; i++) {
        await tester.enterText(fields.at(i), '${good[i]}');
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read it back to me'));
      await tester.pumpAndSettle();

      expect(find.text('These are in the usual range.'), findsOneWidget);
      expect(find.text('When trying has taken a while'), findsOneWidget);
    });
  });
}
