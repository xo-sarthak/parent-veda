// PREGNANCY-GAP 27 (2026-10-28): Ask Veda gets each library card's whole
// page, not its one-line blurb. Batch 6 did it for symptoms; this does it for
// scans, conditions, report findings, the nutrition libraries, belly and skin
// and Mind's reads.
//
// What these hold: every library card that opens a page exports that page;
// the scan's red flags and report table ride along (the adapter's defaults
// would drop both); a page on two doors goes out once; and every door card id
// still resolves.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/pv_veda_corpus.dart';
import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/scan_extras.dart' show kScanRedFlags;
import 'package:parentveda/data/tests_scans_reports_data.dart' show kTestsScans;

void main() {
  final corpus = buildPregnancyVedaCorpus();
  final byId = {for (final d in corpus) d['doc_id'] as String: d};

  // Every entry card that becomes a document, with the door it sits on.
  final cards = <(PvDoorPage, PvDoorEntryTile)>[
    for (final page in kPvDoorPages)
      for (final t in page.allTiles)
        if (t is PvDoorEntryTile && pvVedaTileIsDocument(t)) (page, t),
  ];

  const noPage = {PvDoorLibrary.recipe, PvDoorLibrary.dietChart, PvDoorLibrary.symptomNormal};

  test('every library card that opens a page has one to export', () {
    for (final (_, t) in cards) {
      if (noPage.contains(t.library)) continue;
      expect(pvVedaEntryRead(t.library, t.entryId), isNotNull,
          reason: '${t.library.name}:${t.entryId} opens a page the export cannot build');
    }
  });

  test('each page is exported once, on the first card that shows it', () {
    final firstCard = <String, String>{};
    for (final (page, t) in cards) {
      final page0 = pvVedaEntryPageBody(t);
      if (page0 == null) continue;
      final key = '${t.library.name}:${t.entryId}';
      final id = pvVedaDoorId(page.bracketId, t);
      firstCard.putIfAbsent(key, () => id);
      final holders = [
        for (final d in corpus)
          if ((d['body'] as String).contains(page0)) d['doc_id'],
      ];
      expect(holders, [firstCard[key]], reason: '$key went out as $holders');
    }
  });

  test('a page on two doors: the later card keeps its blurb and where to find it', () {
    final ectopic = [
      for (final (page, t) in cards)
        if (t.library == PvDoorLibrary.condition && t.entryId == 'ectopic') (page, t),
    ];
    expect(ectopic.length, greaterThan(1), reason: 'ectopic is on one door now; pick another pair');
    final (page, t) = ectopic.last;
    final body = byId[pvVedaDoorId(page.bracketId, t)]!['body'] as String;
    expect(body, contains(t.blurb));
    expect(body, contains('Find it in the app'));
    expect(body, isNot(contains(pvVedaEntryPageBody(t)!)));
  });

  test("a scan card carries the screen's red flags and its report table", () {
    var checked = 0;
    for (final (page, t) in cards) {
      if (t.library != PvDoorLibrary.scan) continue;
      final scan = kTestsScans.firstWhere((s) => s.id == t.entryId);
      final body = byId[pvVedaDoorId(page.bracketId, t)]!['body'] as String;
      expect(body, contains(scan.why.en), reason: scan.id);
      for (final f in kScanRedFlags[scan.id] ?? const []) {
        expect(body, contains(f.en), reason: '${scan.id} lost a red flag');
      }
      for (final p in scan.parameters) {
        expect(body, contains(p.name.en), reason: '${scan.id} lost ${p.name.en}');
        if (p.typicalRange case final r?) expect(body, contains(r.en));
      }
      if (scan.understandingReport.en.isNotEmpty) {
        expect(body, contains(scan.understandingReport.en), reason: scan.id);
      }
      checked++;
    }
    expect(checked, greaterThan(0));
  });

  test('every door card id still resolves (the id contract)', () {
    for (final (page, t) in cards) {
      final id = pvVedaDoorId(page.bracketId, t);
      if (!byId.containsKey(id)) continue; // a same-titled twin on one door
      expect(pvVedaDocResolves(id), isTrue, reason: '$id does not resolve');
    }
  });
}
