// =============================================================================
//  The Your first weeks door: four tabs, every read on a card, every card a read
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis ("New section: Your first
//  weeks", P2). The door-wide gates (every surface resolves, every door wears
//  a photograph) live in `pv_door_scans_test.dart` and walk `kPvDoorPages`;
//  this door inherits them the day it is registered there.
//
//  ⚠️ THIS FILE IMPORTS THE DOOR AND ITS READS DIRECTLY, so it holds on its
//  own before the lead wires `kFirstWeeksDoor` into `kPvDoorPages` and
//  `kPregnancyReadsFirst` into `kPregnancyReads`. That is also why it runs
//  `assertShape()` itself: until the reads are spread into the shared index,
//  `pregnancy_reads_shape_test.dart` cannot see them.
//
//  Pinned here beyond the Move door's checks:
//    · the first-visit tile opens Scans & tests' read, so the visit is never
//      written twice (and likewise every borrowed read in `_borrowed`);
//    · every early-worry read carries all five hospital signs;
//    · the Early worries tab pins those signs, whole;
//    · nothing suggests learning the baby's sex.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_mind.dart'
    show kMindSurfaceHelplines, mindSurfaceOffer;
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';

/// The read id a tile opens, or null for a tile that opens something else.
String? _readIdOf(PvDoorTile t) => switch (t) {
      PvDoorGuideTile(:final readId) => readId,
      PvDoorMythTile(:final readId) => readId,
      _ => null,
    };

/// Reads this door opens that other doors own. Each is written once, where it
/// lives; the door points at it rather than copying it.
const Set<String> _borrowed = {
  'preg_scan_read_first_visit', // Scans & tests
  'preg_scan_read_early_bloods', // Scans & tests
  'preg_scan_read_sex_law', // Scans & tests
  'preg_week_read_first_trimester', // weekly reads
  'preg_week_read_managing_nausea', // weekly reads
  'preg_loss_read_next_pregnancy_care', // After a loss
  'preg_work_read_telling_your_boss', // Work & money
  'preg_ready_read_older_child', // Getting ready
};

/// A borrowed read, from the shared index (`kPregnancyReads`).
PvRead? _borrowedRead(String id) => pregnancyReadById(id);

/// Every English string the door shows her, flag and notes included.
List<String> _doorStrings(PvDoorPage d) => [
      d.heroTitle,
      d.heroBlurb,
      if (d.closingLine != null) d.closingLine!,
      for (final g in d.groups) ...[
        g.label,
        if (g.note != null) g.note!,
        if (g.pinnedRedFlag case final f?) ...[
          f.title,
          if (f.footer != null) f.footer!,
          for (final l in f.lines) l.text,
        ],
      ],
      for (final s in d.sections) ...[
        s.heading,
        for (final t in s.tiles) ...[
          t.title,
          t.blurb,
          if (t.meta != null) t.meta!,
        ],
      ],
    ];

/// Every English string a read shows her, with where it came from.
List<(String, String)> _readStrings(PvRead r) {
  final out = <(String, String)>[];
  void add(String where, LocalizedText? t) {
    if (t != null) out.add(('${r.id} $where', t.en));
  }

  add('kicker', r.kicker);
  add('title', r.title);
  add('teaser', r.teaser);
  add('shortAnswer', r.shortAnswer);
  add('scaleSetter', r.scaleSetter);
  add('author', r.author);
  add('authorRole', r.authorRole);
  add('evidence', r.evidence);
  for (final s in r.sections) {
    add('heading', s.heading);
    add('summary', s.summary);
    for (final p in s.paragraphs) {
      add('paragraph', p);
    }
    for (final b in s.bullets) {
      add('bullet', b);
    }
    add('tip', s.tip?.title);
    add('tip', s.tip?.body);
    add('myth', s.mythFact?.myth);
    add('fact', s.mythFact?.fact);
    add('callout', s.callout?.title);
    add('callout', s.callout?.body);
  }
  add('whenToSeeSomeone', r.whenToSeeSomeone.title);
  add('whenToSeeSomeone', r.whenToSeeSomeone.body);
  for (final f in r.faqs) {
    add('faq', f.question);
    add('faq', f.answer);
  }
  return out;
}

/// `docs/PREG-VOICE.md` §4, the words and phrases. Matched on word
/// boundaries, case-insensitive.
const List<String> _banned = [
  'journey',
  'navigate',
  'empower',
  'delve',
  'embark',
  'holistic',
  'game-changer',
  'crucial',
  "you've got this",
  'rest assured',
  'we understand how you feel',
  "it's important to note",
  "it's worth noting",
  "let's dive in",
  'genuinely',
  'actually',
  'quietly',
  'simply',
  'truly',
  'the single most',
  'the one thing nobody tells you',
  "here's the thing",
  'mama',
  'mommy',
  'momma',
  'miracle',
  'magical',
  'blessed',
  "don't worry",
];

/// Phrases that would point her towards learning the baby's sex (PCPNDT).
const List<String> _sexFinding = [
  'gender reveal',
  'predict the sex',
  'predict the gender',
  'find out the sex',
  'find out the gender',
  'know the sex',
  'guess the sex',
  'sex determination',
];

/// The five early-pregnancy hospital signs, as the words that must appear.
final Map<String, RegExp> _fiveSigns = {
  'heavy bleeding': RegExp(r'bleeding heavily|heavy bleeding',
      caseSensitive: false),
  'one-sided pain': RegExp(r'one side', caseSensitive: false),
  'shoulder-tip pain': RegExp(r'tip of your shoulder', caseSensitive: false),
  'fainting': RegExp(r'faint', caseSensitive: false),
  'fever': RegExp(r'fever', caseSensitive: false),
};

void main() {
  final door = kFirstWeeksDoor;
  final readIds = {for (final r in kPregnancyReadsFirst) r.id};

  group('the door keeps the benchmark shape', () {
    test('it opens from the Your first weeks tile', () {
      expect(door.bracketId, 'pregnancy_first_weeks');
    });

    test('four tabs, in order', () {
      expect(door.groups.map((g) => g.id), [
        kFirstTabFoundOut,
        kFirstTabVisit,
        kFirstTabWorries,
        kFirstTabTelling,
      ]);
      expect(door.groups.map((g) => g.label), [
        'Just found out',
        'Your first visit',
        'Early worries',
        'Telling people',
      ]);
    });

    test('every section belongs to a tab, and every tab has something', () {
      final ids = {for (final g in door.groups) g.id};
      for (final s in door.sections) {
        expect(ids, contains(s.group),
            reason: '"${s.heading}" names a tab that does not exist.');
      }
      for (final g in door.groups) {
        expect(door.sectionsOf(g.id), isNotEmpty,
            reason: '"${g.label}" is an empty tab.');
      }
    });

    test('a hero, a photograph and a closing line that defers to her doctor',
        () {
      expect(door.heroTitle.trim(), isNotEmpty);
      expect(door.heroBlurb.trim(), isNotEmpty);
      expect(door.heroImageUrl, isNotNull,
          reason: 'pv_door_scans_test fails the day this door is registered '
              'without one.');
      expect(door.closingLine, contains('doctor'));
    });

    test('no other door wears the same photograph', () {
      for (final other in kPvDoorPages) {
        if (other.bracketId == door.bracketId) continue;
        expect(other.heroImageUrl, isNot(door.heroImageUrl),
            reason: '${other.bracketId} already uses this photograph.');
      }
    });

    test('every tile has a blurb that is not its title', () {
      for (final t in door.allTiles) {
        expect(t.blurb.trim(), isNotEmpty, reason: '"${t.title}" has none.');
        expect(t.blurb.toLowerCase(), isNot(t.title.toLowerCase()));
      }
    });
  });

  group('the Early worries flag', () {
    final worries =
        door.groups.firstWhere((g) => g.id == kFirstTabWorries);

    test('is pinned, and only there', () {
      expect(worries.pinnedRedFlag, isNotNull);
      for (final g in door.groups) {
        if (g.id == kFirstTabWorries) continue;
        expect(g.pinnedRedFlag, isNull, reason: g.label);
      }
    });

    test('carries all five hospital signs, and the ambulance number', () {
      final f = worries.pinnedRedFlag!;
      final text = [f.title, ...f.lines.map((l) => l.text), f.footer ?? '']
          .join(' ');
      for (final MapEntry(:key, :value) in _fiveSigns.entries) {
        expect(value.hasMatch(text), isTrue, reason: 'the flag lacks $key');
      }
      expect(f.footer, contains('108'));
      expect(f.title, contains('hospital'));
    });
  });

  group('every tile goes somewhere', () {
    test('every own guide tile names a read in kPregnancyReadsFirst; '
        'every borrowed one exists in the pregnancy library', () {
      for (final t in door.allTiles) {
        final id = _readIdOf(t);
        if (id == null) continue;
        if (_borrowed.contains(id)) {
          expect(_borrowedRead(id), isNotNull,
              reason: '"${t.title}" borrows "$id", which does not exist.');
        } else {
          expect(readIds, contains(id),
              reason: '"${t.title}" points at "$id", which does not exist.');
        }
      }
    });

    test('the first visit is opened from Scans & tests, never rewritten', () {
      final visitTiles = [
        for (final s in door.sectionsOf(kFirstTabVisit))
          for (final t in s.tiles) ?_readIdOf(t),
      ];
      expect(visitTiles, contains('preg_scan_read_first_visit'));
      for (final r in kPregnancyReadsFirst) {
        expect(r.title.en.toLowerCase(),
            isNot(contains('your first antenatal visit')),
            reason: '${r.id} duplicates the Scans & tests read.');
      }
    });

    test('every read in kPregnancyReadsFirst is on at least one tile', () {
      final onDoor = {
        for (final t in door.allTiles) ?_readIdOf(t),
      };
      expect(readIds.difference(onDoor), isEmpty,
          reason: 'these reads are unreachable from the door.');
    });

    test('every atHeading matches a heading in its read', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile || t.atHeading == null) continue;
        final r = firstWeeksReadById(t.readId) ?? _borrowedRead(t.readId);
        expect(r, isNotNull);
        expect(r!.toc.map((h) => h.en), contains(t.atHeading),
            reason: '"${t.title}" would open ${r.id} at the top.');
      }
    });

    test('every library tile resolves', () {
      for (final t in door.allTiles) {
        if (t case PvDoorEntryTile(:final library, :final entryId)) {
          expect(pvDoorEntryResolves(library, entryId), isTrue,
              reason: '"${t.title}" → $entryId');
        }
      }
    });

    test('the surfaces are the ones the lead is told about', () {
      expect(kFirstSurfaceDueDate, 'first_weeks/due_date');
      final all = {
        for (final t in door.allTiles)
          if (t case PvDoorToolTile(:final surfaceId)) surfaceId
          else if (t case PvDoorTalkTile(:final surfaceId)) surfaceId,
      };
      expect(all, {
        kFirstSurfaceDueDate,
        kMindSurfaceHelplines,
        mindSurfaceOffer('perinatal_counselling'),
      });
      // The two Mind surfaces are already wired; the due date one is the
      // lead's to add.
      expect(pvDoorSurfaceResolves(kMindSurfaceHelplines), isTrue);
      expect(
          pvDoorSurfaceResolves(mindSurfaceOffer('perinatal_counselling')),
          isTrue);
    });
  });

  group('the reads', () {
    test('there are at least twelve, all preg_first_read_*, ids unique', () {
      // Thirteen own reads; the door opens six more that other doors own.
      expect(kPregnancyReadsFirst.length, greaterThanOrEqualTo(12));
      expect(readIds.length, kPregnancyReadsFirst.length);
      for (final id in readIds) {
        expect(id, startsWith('preg_first_read_'));
      }
    });

    test('each passes the shared shape rules', () {
      final problems = [
        for (final r in kPregnancyReadsFirst) ...r.assertShape(),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('each has a short answer, and is honest about review', () {
      for (final r in kPregnancyReadsFirst) {
        expect(r.shortAnswer?.en.trim() ?? '', isNotEmpty,
            reason: '${r.id} has no short answer.');
        expect(r.reviewed, isFalse,
            reason: '${r.id} claims a clinical review nobody has done.');
        expect(r.author.en, 'ParentVeda editorial');
      }
    });

    test('each ends at a person, with the urgent tone', () {
      for (final r in kPregnancyReadsFirst) {
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent);
        final line = '${r.whenToSeeSomeone.title.en} '
            '${r.whenToSeeSomeone.body.en}';
        expect(line, anyOf(contains('doctor'), contains('hospital')),
            reason: r.id);
      }
    });

    test('every early-worry read carries all five hospital signs', () {
      final worryIds = {
        for (final s in door.sectionsOf(kFirstTabWorries))
          for (final t in s.tiles)
            if (_readIdOf(t) case final id? when readIds.contains(id)) id,
      };
      expect(worryIds, isNotEmpty);
      for (final id in worryIds) {
        final r = firstWeeksReadById(id)!;
        final line = '${r.whenToSeeSomeone.title.en} '
            '${r.whenToSeeSomeone.body.en}';
        for (final MapEntry(:key, :value) in _fiveSigns.entries) {
          expect(value.hasMatch(line), isTrue,
              reason: '$id does not name $key in its callout.');
        }
      }
    });

    test('every readNext resolves, and none is itself', () {
      for (final r in kPregnancyReadsFirst) {
        expect(r.readNext, isNot(contains(r.id)));
        for (final id in r.readNext) {
          final ok = readIds.contains(id) ||
              (_borrowed.contains(id) && _borrowedRead(id) != null);
          expect(ok, isTrue, reason: '${r.id} → $id');
        }
      }
    });

    test('no sentence puts "your" beside a chance word', () {
      // The rule `pregnancy_reads_shape_test.dart` holds for paragraphs and
      // bullets, applied here to every string a read shows.
      final possessive = RegExp(r'\byour\b', caseSensitive: false);
      final chance = RegExp(r'\b(chance|odds|risk|likelihood|probability)\b',
          caseSensitive: false);
      final hits = <String>[];
      for (final r in kPregnancyReadsFirst) {
        for (final (where, text) in _readStrings(r)) {
          for (final s in text.split(RegExp(r'(?<=[.!?])\s+'))) {
            if (possessive.hasMatch(s) && chance.hasMatch(s)) {
              hits.add('$where: $s');
            }
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  });

  group('the voice (docs/PREG-VOICE.md)', () {
    final all = <(String, String)>[
      for (final s in _doorStrings(door)) ('door', s),
      for (final r in kPregnancyReadsFirst) ..._readStrings(r),
    ];

    test('no em dashes, en dashes, spaced hyphens or exclamation marks', () {
      final hits = [
        for (final (where, s) in all)
          if (s.contains('—') ||
              s.contains('–') ||
              s.contains(' - ') ||
              s.contains('!'))
            '$where: $s',
      ];
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('none of the banned words', () {
      final hits = <String>[];
      for (final (where, s) in all) {
        for (final w in _banned) {
          final re = RegExp('(?<![A-Za-z])${RegExp.escape(w)}(?![A-Za-z])',
              caseSensitive: false);
          if (re.hasMatch(s)) hits.add('$where: "$w" in $s');
        }
        // "Remember" is banned as an opener.
        for (final sentence in s.split(RegExp(r'(?<=[.?:])\s+'))) {
          if (sentence.trimLeft().toLowerCase().startsWith('remember')) {
            hits.add('$where: opens with "Remember"');
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('nothing points her towards learning the baby\'s sex', () {
      final hits = <String>[];
      for (final (where, s) in all) {
        for (final p in _sexFinding) {
          if (s.toLowerCase().contains(p)) hits.add('$where: "$p" in $s');
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  });
}
