// =============================================================================
//  The Scans door is reachable, and so is everything on it
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE WIRING GATE, AND IT IS THE ONE TEST THIS REPO MOST NEEDS.
//
//  Correct-but-unreachable code is the failure ParentVeda has actually hit, and
//  a content door is the worst place for it: a tile is a title, a blurb and a
//  chip, and NONE OF THAT FAILS TO RENDER if the id underneath it is wrong. A
//  dead card looks exactly like a live one until somebody taps it.
//
//  So every assertion below is about reachability rather than about shape:
//  every read id resolves, every surface opens something, every scan id is in
//  the library, and the widget that draws the tabs is actually the widget the
//  door builds.
//
//  ⚠️ AND IT WALKS `kPvDoorPages`, NOT THE SCANS DOOR BY NAME. The next seven
//  briefs inherit every gate here the moment they are registered, and nobody
//  has to remember to add them.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/data/reads/read_adapters.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/data/report_findings_data.dart';
import 'package:parentveda/data/checklists/pv_checklist.dart';
import 'package:parentveda/screens/brackets/scan_timeline_screen.dart'
    show kScanRun;
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  group('every door is wired', () {
    test('the registry is not empty', () {
      // The reverse mistake: a passing suite over zero doors proves nothing,
      // and every assertion below is vacuously true on an empty list.
      expect(kPvDoorPages, isNotEmpty);
      expect(pvDoorPageFor('pregnancy_scans_tests'), isNotNull);
    });

    test('bracket ids are unique', () {
      final ids = kPvDoorPages.map((d) => d.bracketId).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'Two doors on one bracket means the second never opens — '
              'the lookup returns the first match.');
    });

    test('every section belongs to a group that exists', () {
      // ⚠️ A SECTION IN NO TAB LOOKS LIKE NOTHING. It does not throw, does not
      // render and does not warn; the content is simply gone, and the only way
      // to notice is to count the cards on a device.
      for (final door in kPvDoorPages) {
        final groupIds = door.groups.map((g) => g.id).toSet();
        for (final s in door.sections) {
          expect(groupIds, contains(s.group),
              reason: '${door.bracketId}: section "${s.heading}" names group '
                  '"${s.group}", which does not exist.');
        }
      }
    });

    test('every group has something in it', () {
      // A tab with no sections and no inline tool is a card that opens an
      // empty page — which is worse than a missing tab, because she chose it.
      for (final door in kPvDoorPages) {
        for (final g in door.groups) {
          final hasSections = door.sectionsOf(g.id).isNotEmpty;
          expect(hasSections || g.inlineSurfaceId != null, isTrue,
              reason: '${door.bracketId}: tab "${g.label}" is empty.');
        }
      }
    });

    test('group ids are unique within a door', () {
      for (final door in kPvDoorPages) {
        final ids = door.groups.map((g) => g.id).toList();
        expect(ids.toSet().length, ids.length,
            reason: '${door.bracketId} has two tabs with one id, so one tab\'s '
                'sections render under the other.');
      }
    });

    test('every inline surface resolves to a body', () {
      // ⚠️ A SURFACE THE INLINE MAP DOES NOT KNOW RENDERS NOTHING AT ALL, and
      // on a tool tab that is the entire tab.
      final c = PregnancyController();
      for (final door in kPvDoorPages) {
        for (final g in door.groups) {
          if (g.inlineSurfaceId case final s?) {
            expect(pvDoorInlineToolFor(s, c), isNotNull,
                reason: '${door.bracketId}: tab "${g.label}" declares inline '
                    'tool "$s" and nothing builds it.');
          }
        }
      }
    });

    test('every pinned red flag opens somewhere and says something', () {
      for (final door in kPvDoorPages) {
        for (final g in door.groups) {
          if (g.pinnedRedFlag case final f?) {
            expect(f.lines, isNotEmpty,
                reason: '${door.bracketId}: an empty red flag is a coral box '
                    'with a heading.');
            expect(pvDoorSurfaceResolves(f.surfaceId), isTrue,
                reason: '${door.bracketId}: the flag points at '
                    '"${f.surfaceId}", which opens nothing.');
          }
        }
      }
    });
  });

  group('every tile opens something real', () {
    test('every library entry tile names an id that exists', () {
      // ⚠️ ONE ASSERTION FOR NINE LIBRARIES, and it grew from three separate
      // ones when the tile classes collapsed into `PvDoorEntryTile`. A new
      // library inherits this the moment a door uses it.
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          if (t is! PvDoorEntryTile) continue;
          expect(pvDoorEntryResolves(t.library, t.entryId), isTrue,
              reason: '"${t.title}" points at ${t.library.name} '
                  '"${t.entryId}", which is not in that library. The card '
                  'renders perfectly and does nothing.');
        }
      }
    });

    test('every library entry keeps a route name', () {
      // The FAB reads route names to pick which stage's Ask Veda opens and to
      // suppress itself, so an empty name is a silently wrong sparkle button.
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          if (t is! PvDoorEntryTile) continue;
          final route = pvDoorEntryRoute(t.library, t.entryId);
          expect(route.trim(), isNotEmpty);
          expect(route, isNot(contains('null')));
        }
      }
    });

    test('guide and myth tiles name a read that exists', () {
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          final id = switch (t) {
            PvDoorGuideTile(:final readId) => readId,
            PvDoorMythTile(:final readId) => readId,
            _ => null,
          };
          if (id == null) continue;
          expect(pregnancyReadById(id), isNotNull,
              reason: '"${t.title}" points at read "$id", which is not in '
                  'kPregnancyReads.');
        }
      }
    });

    test('a myth tile opens a read whose first section IS the myth', () {
      // ⚠️ THE CHIP IS A PROMISE ABOUT LENGTH AS WELL AS KIND. "Myth vs fact"
      // promises a claim and a correction; opening seven hundred words with
      // the correction buried in section three is a chip that lies. So the
      // claim has to be in the first screenful, and this is what holds it.
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          if (t is! PvDoorMythTile) continue;
          final read = pregnancyReadById(t.readId)!;
          expect(read.sections.first.mythFact, isNotNull,
              reason: '"${t.title}" wears the myth chip, but '
                  '${read.id}\'s opening section carries no myth block.');
        }
      }
    });

    test('every tool, checklist, talk and read tile resolves', () {
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          final id = switch (t) {
            PvDoorToolTile(:final surfaceId) => surfaceId,
            PvDoorChecklistTile(:final surfaceId) => surfaceId,
            PvDoorTalkTile(:final surfaceId) => surfaceId,
            PvDoorReadTile(:final surfaceId) => surfaceId,
            _ => null,
          };
          if (id == null) continue; // the coming-soon read, which has none
          expect(pvDoorSurfaceResolves(id), isTrue,
              reason: '"${t.title}" points at surface "$id", which the router '
                  'does not know. It opens nothing, silently.');
        }
      }
    });

    test('every declared surface actually builds a screen', () {
      // ⚠️ TWO SEPARATE CLAIMS, AND THE FIRST ONE ALONE IS NOT ENOUGH.
      // `pvDoorSurfaceResolves` is a hand-kept list, so it can say yes about an
      // id the builder has never heard of — which is the exact shape of a test
      // that passes while the feature is dead.
      final c = PregnancyController();
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          final id = switch (t) {
            PvDoorToolTile(:final surfaceId) => surfaceId,
            PvDoorChecklistTile(:final surfaceId) => surfaceId,
            PvDoorTalkTile(:final surfaceId) => surfaceId,
            PvDoorReadTile(:final surfaceId) => surfaceId,
            PvDoorAudioTile(:final surfaceId) => surfaceId,
            PvDoorGameTile(:final surfaceId) => surfaceId,
            _ => null,
          };
          if (id == null) continue;
          // A tile that switches tab builds no screen by design — the door
          // screen intercepts it. `pv_door_garbh_test` checks the tab exists.
          if (pvDoorTabTarget(t) != null) continue;
          expect(pvDoorScreenFor(id, c), isNotNull,
              reason: '"$id" is on the resolves list and builds no screen.');
        }
      }
    });

    test('a coming-soon tile has no destination, and the rest all do', () {
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          if (t is PvDoorReadTile && t.comingSoon) {
            expect(t.surfaceId, isNull,
                reason: '"${t.title}" says coming soon and points somewhere. '
                    'One of the two is wrong.');
          }
        }
      }
    });

    test('every tile has a blurb, and no blurb repeats its title', () {
      // A tile whose title has to carry the whole explanation ends up as a
      // sentence in bold; a blurb that restates the title spends the one line
      // that was meant to say what she gets.
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          expect(t.blurb.trim(), isNotEmpty, reason: '"${t.title}" has none.');
          expect(t.blurb.toLowerCase().trim(),
              isNot(equals(t.title.toLowerCase().trim())),
              reason: '"${t.title}" repeats itself.');
        }
      }
    });

    test('no card title repeats the heading it sits under', () {
      // ⚠️ THE SAME FAULT AS ABOVE, ONE LEVEL UP, AND IT HAS SHIPPED TWICE.
      // "Fasting" under "Fasting", then "Diet charts" under "Ready-made diet
      // charts" — both found by looking at a phone, because a card whose words
      // are the words a centimetre above it reads as a label for the rail
      // rather than a thing you tap.
      for (final door in kPvDoorPages) {
        for (final s in door.sections) {
          final heading = s.heading.toLowerCase().trim();
          for (final t in s.tiles) {
            expect(t.title.toLowerCase().trim(), isNot(equals(heading)),
                reason: '"${t.title}" repeats its own heading.');
          }
        }
      }
    });
  });

  group('every door wears a photograph, and it was looked at', () {
    // ⚠️ THIS GROUP CANNOT CHECK THE THING THAT ACTUALLY MATTERS, AND SAYING
    // SO IS THE POINT OF THE COMMENT. The failure this area has really had was
    // a real photograph OF THE WRONG THING — a Western urology clinic with the
    // department legible on a badge, under "Your scans, in one place". No
    // assertion reachable from Dart can see that. `flutter analyze`, the whole
    // suite and a render test all passed with it in place.
    //
    // So the guarantee lives in the process, written down in
    // `pv_door_scans.dart`: download the file, open it, and reject anything
    // carrying signage, a uniform, a badge or a building. Two candidates were
    // rejected that way on 2026-09-10.
    //
    // What CAN be held is the shape around it — that every door has one, that
    // they are distinct, and that the URL is a fixed-size crop rather than a
    // full-resolution original on a phone connection.
    test('every door has one', () {
      for (final door in kPvDoorPages) {
        expect(door.heroImageUrl, isNotNull,
            reason: '${door.bracketId} falls back to the drawn mark.');
      }
    });

    test('no two doors wear the same photograph', () {
      final urls = [for (final d in kPvDoorPages) d.heroImageUrl];
      expect(urls.toSet().length, urls.length,
          reason: 'two doors would look like one screen.');
    });

    test('each is asked for at a phone-sized crop', () {
      // A hero is roughly 360x300 logical. Asking the CDN for the original is
      // several megabytes over an Indian mobile connection for a picture that
      // gets painted at a tenth of the size — and the hero silently renders
      // nothing while it loads, so the cost is paid in a blank hero.
      for (final door in kPvDoorPages) {
        final url = door.heroImageUrl!;
        // A read-table image (StockSnap's 960w rendition, mirrored to R2 at a
        // 1200px long edge) is already phone-sized; only Unsplash needs asking.
        if (url.contains('images.unsplash.com')) {
          expect(url, contains('w=900'), reason: '${door.bracketId} is uncropped.');
          expect(url, contains('fit=crop'), reason: '${door.bracketId} is uncropped.');
        } else {
          // (the Openverse proxy serves StockSnap's 960w rendition — see
          // `openverseImageUrl` in read_images.dart)
          expect(url, anyOf(contains('/960w/'), contains('/960px-'), contains('/thumb/?full_size=true')),
              reason: '${door.bracketId} is uncropped.');
        }
      }
    });
  });

  group('a tile that costs money says so on its face', () {
    // ⚠️ FOUND ON A PHONE WITH A PASSING TEST ALREADY IN PLACE. The Labour
    // door's own test asserted the price was in the course card's BLURB — and
    // a rail card draws the badge, `meta` and the title, never the blurb. The
    // assertion was true and the price was invisible.
    //
    // The general shape, which is worth more than this rule: asserting that a
    // string exists on a model is not asserting that it reaches a screen. When
    // the claim is "she can see X before she taps", the assertion has to name
    // the field the widget actually paints.
    test('every price is in a field the card renders', () {
      final rupee = RegExp(r'₹');
      for (final door in kPvDoorPages) {
        for (final t in door.allTiles) {
          if (!rupee.hasMatch(t.blurb)) continue;
          expect(t.meta, isNotNull,
              reason: '"${t.title}" names a price only in its blurb, which a '
                  'rail card does not draw.');
          expect(rupee.hasMatch(t.meta!), isTrue,
              reason: '"${t.title}" has a meta line that omits the price.');
        }
      }
    });
  });

  group('the Scans door matches the brief', () {
    late PvDoorPage door;

    setUp(() => door = pvDoorPageFor('pregnancy_scans_tests')!);

    test('five sub-tabs, My scans first', () {
      expect(door.groups.length, 5);
      expect(door.groups.first.id, kScansTabMine);
      expect(door.groups.map((g) => g.label), [
        'My scans',
        'Understand a scan',
        'Understand a result',
        'My reports',
        'Talk',
      ]);
    });

    test('sub-tabs 1 and 4 are tool screens, not rails', () {
      // The brief says so by name: "Do not render Sub-tabs 1 or 4 as card
      // rails."
      for (final id in [kScansTabMine, kScansTabReports]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.stack,
            reason: '"${g.label}" is a tool screen and must not be a rail.');
        expect(g.inlineSurfaceId, isNotNull,
            reason: '"${g.label}" is a tool screen with no tool on it.');
      }
    });

    test('sub-tabs 2, 3 and 5 are card rails', () {
      for (final id in [kScansTabScan, kScansTabResult, kScansTabTalk]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.rails);
      }
    });

    test('all nine scans are on Understand a scan, in trimester order', () {
      final scans = [
        for (final s in door.sectionsOf(kScansTabScan))
          for (final t in s.tiles)
            if (t is PvDoorEntryTile && t.library == PvDoorLibrary.scan)
              t.entryId,
      ];
      expect(scans, [
        'blood_tests',
        'dating_scan',
        'nt_scan',
        'nipt',
        'anomaly_scan',
        'ogtt',
        'growth_scan',
        'doppler',
        'gbs',
      ]);
    });

    test('the six card lines the brief writes out are verbatim', () {
      // ⚠️ THE BRIEF GIVES THESE IN QUOTES, so they are a contract rather than
      // a suggestion — they are the plain lines that pair with a medical title,
      // and they are the whole of the language rule in practice.
      const expected = {
        'NT scan': "Checks the baby's early growth and development.",
        'NIPT': 'A blood test that checks for some conditions early.',
        'Anomaly scan':
            'The detailed scan that checks the baby from head to toe.',
        'Sugar test (OGTT)': 'Checks for pregnancy diabetes.',
        'Doppler scan': 'Checks the blood flow to the baby.',
        'Group B Strep':
            'A swab that checks for a common bacteria before birth.',
      };
      final byTitle = {for (final t in door.allTiles) t.title: t.blurb};
      expected.forEach((title, blurb) {
        expect(byTitle[title], blurb, reason: '$title has drifted.');
      });
    });

    test('the Talk tab pins the red flag and nothing else does', () {
      // ⚠️ ONCE, AND ONLY ON TALK. `scans_hub_v2.dart` removed the urgent strip
      // from the old landing because "nobody discovers an emergency by
      // scrolling" and a records screen should not be alarming for the
      // thousands of people who are fine. That argument is honoured by keeping
      // the flag off the four tabs somebody browsing would open.
      final pinned =
          door.groups.where((g) => g.pinnedRedFlag != null).toList();
      expect(pinned.length, 1);
      expect(pinned.single.id, kScansTabTalk);
    });

    test('the pinned flag shows the whole urgent list, untrimmed', () {
      // A red-flag list is shown whole or not at all. Shoulder-tip pain is the
      // classic sign of a ruptured ectopic, it sounds like nothing, and it is
      // the entry a layout compromise would drop first.
      final flag = door.groups
          .firstWhere((g) => g.id == kScansTabTalk)
          .pinnedRedFlag!;
      expect(flag.lines.length, kScanUrgentSignsEn.length);
      expect(flag.lines, kScanUrgentSignsEn);
    });

    test('Ask Veda is not a card anywhere on the door', () {
      // The brief: do not add it as a card, do not build a new entry point.
      for (final t in door.allTiles) {
        expect(t.title.toLowerCase(), isNot(contains('ask veda')));
        expect(t.blurb.toLowerCase(), isNot(contains('ask veda')));
      }
    });

    test('the report parameters live in each scan read, not in a tool tile', () {
      // ⚠️ SINGLE SOURCE, MOVED. The brief's "Your report, line by line" was
      // one tool tile in My reports. Since 2026-09-18 (the door walk) every
      // scan's read carries its own parameters ("What the report will say",
      // `pvReadFromScan`), so the tile is retired: zero tiles name it, and
      // the parameters appear exactly once — inside the read. Two homes for
      // the same table is the copy the brief forbids.
      final tiles = door.allTiles
          .where((t) => t.title == 'Your report, line by line')
          .toList();
      expect(tiles, isEmpty);
      final anomaly = kTestsScans.firstWhere((s) => s.id == 'anomaly_scan');
      final read = pvReadFromScan(anomaly);
      expect(
          read.sections.any((sec) =>
              sec.heading?.en == 'What the report will say' &&
              sec.custom is PvScanParametersBlock),
          isTrue);
    });

    test('every scan card carries the week range the brief annotates', () {
      // ⚠️ THE BRIEF PUTS A WEEK RANGE BESIDE EVERY SCAN and the first build
      // read those as identification rather than as copy. They are both: she
      // is on a tab called "before you go", and "which of these is mine, now"
      // is the question the card has to answer without being tapped.
      const expected = {
        'blood_tests': 'Weeks 6–10',
        'dating_scan': 'Weeks 6–9',
        'nt_scan': 'Weeks 11–13',
        'nipt': 'Weeks 10–14',
        'anomaly_scan': 'Weeks 18–22',
        'ogtt': 'Weeks 24–28',
        'growth_scan': 'Weeks 28–36',
        'doppler': 'Weeks 30–40',
        'gbs': 'Weeks 35–37',
      };
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.scan) continue;
        expect(t.meta, expected[t.entryId],
            reason: '${t.title} shows the wrong week range.');
      }
    });

    test('those week ranges agree with the timeline', () {
      // ⚠️ THE DRIFT THIS CATCHES IS SILENT AND WOULD BE BELIEVED. The card and
      // the timeline are two places showing the same fact, and a card reading
      // "Weeks 11–13" beside a timeline row reading "Week 12–14" is the app
      // disagreeing with itself about her pregnancy. Neither would fail to
      // render.
      //
      // The card's copy is typed rather than derived, because `kScanRun` lives
      // in a screen file and a data file must not import one. So the agreement
      // is asserted instead.
      final runs = {for (final (id, f, t) in kScanRun) id: 'Weeks $f–$t'};
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.scan) continue;
        expect(t.meta, runs[t.entryId],
            reason: '${t.title}: the card says "${t.meta}", the timeline says '
                '"${runs[t.entryId]}".');
      }
    });

    test('the closing line is the timeline footer, kept', () {
      expect(door.closingLine, isNotNull);
      expect(door.closingLine!.toLowerCase(), contains('not a rule'));
    });

    test('the hero line the brief asks to keep is kept', () {
      expect(door.heroTitle, 'Your scans, in one place.');
    });
  });

  group('the decoder no longer shows a topic twice', () {
    test('the popular six are a subset of all findings', () {
      // The premise of the fix: "All topics" contained the popular six, so each
      // appeared under both headings a few hundred points apart. If this ever
      // stops being true, the subtraction in `report_screen.dart` is removing
      // nothing and the fix has quietly become a no-op.
      for (final id in kReportPopular) {
        expect(kReportFindings.any((f) => f.id == id), isTrue,
            reason: '$id is popular and is not in the library.');
      }
    });

    test('breech and cord around neck are among the six', () {
      // The two the brief names by hand. Named here so the test says what it
      // is protecting rather than only how.
      expect(kReportPopular, contains('breech'));
      expect(kReportPopular, contains('nuchal_cord'));
    });
  });

  group('the appointment checklist', () {
    // ⚠️ THE GENERIC ASSERTIONS MOVED TO `pv_door_complications_test.dart` when
    // the checklist system was generalised — id uniqueness, question phrasing
    // and store-key stability now run over EVERY checklist rather than over
    // this one. What stays here is what is specific to the scans list.
    test('it still has its four groups, in visit order', () {
      expect(kScanQuestionsChecklist.groups.map((g) => g.heading), [
        'Before the day',
        'About this scan',
        'When I get the report',
        'What happens next',
      ]);
    });

    test('it names her next scan when there is one', () {
      // The derivation itself is exercised on a device and by the store; what
      // this holds is that the hook exists at all. A checklist with no
      // `subject` is a leaflet, and the difference is the whole design.
      expect(kScanQuestionsChecklist.subject, isNotNull);
      expect(kScanQuestionsChecklist.subjectTitle, isNotNull);
    });
  });

  group('the format chips', () {
    test('every format has a label and an icon', () {
      for (final f in PvDoorFormat.values) {
        expect(f.label.trim(), isNotEmpty);
        expect(pvDoorFormatIcon(f), isNotNull);
      }
    });

    test('no two formats share a label, except the two written ones', () {
      // STILL-OPEN §60.2 (applied 2026-09-17): `read` and `article` both say
      // "Article" — the look-up / read-through difference lives inside the
      // piece, not on the chip, which is where every reader in the Mobbin
      // set puts it. Every other pair still promises something different.
      const written = {
        PvDoorFormat.read,
        PvDoorFormat.guide,
        PvDoorFormat.mythFact,
      };
      final labels = PvDoorFormat.values
          .where((f) => !written.contains(f))
          .map((f) => f.label)
          .toList();
      expect(labels.toSet().length, labels.length,
          reason: 'Two chips reading the same word promise the same thing and '
              'do different things.');
      for (final f in written) {
        expect(f.label, PvDoorFormat.article.label, reason: '$f');
      }
    });
  });
}
