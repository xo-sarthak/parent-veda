// =============================================================================
//  The Move & rest door: four tabs, every read on a card, every card a read
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis ("New section: Move &
//  rest", P1). The door-wide gates (every surface resolves, every door wears
//  a photograph) live in `pv_door_scans_test.dart` and walk `kPvDoorPages`;
//  this door inherits them the day it is registered there.
//
//  ⚠️ THIS FILE IMPORTS THE DOOR AND ITS READS DIRECTLY, so it holds on its
//  own before the lead wires `kMoveDoor` into `kPvDoorPages` and
//  `kPregnancyReadsMove` into `kPregnancyReads`. That is also why it runs
//  `assertShape()` itself: until the reads are spread into the shared index,
//  `pregnancy_reads_shape_test.dart` cannot see them.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_move.dart';
import 'package:parentveda/data/reads/pregnancy_reads_move.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_read.dart';

/// The read id a tile opens, or null for a tile that opens a tool.
String? _readIdOf(PvDoorTile t) => switch (t) {
      PvDoorGuideTile(:final readId) => readId,
      PvDoorMythTile(:final readId) => readId,
      _ => null,
    };

/// Every English string the door shows her.
List<String> _doorStrings(PvDoorPage d) => [
      d.heroTitle,
      d.heroBlurb,
      if (d.closingLine != null) d.closingLine!,
      for (final g in d.groups) g.label,
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

void main() {
  final door = kMoveDoor;
  final readIds = {for (final r in kPregnancyReadsMove) r.id};

  group('the door keeps the benchmark shape', () {
    test('it opens from the Yoga & fitness tile', () {
      expect(door.bracketId, 'pregnancy_fitness');
    });

    test('four tabs, in order', () {
      expect(door.groups.map((g) => g.id),
          [kMoveTabMove, kMoveTabPelvic, kMoveTabRest, kMoveTabClasses]);
      expect(door.groups.map((g) => g.label), [
        'Move safely',
        'Pelvic floor',
        'Sleep and rest',
        'Classes and tools',
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

  group('the two tools', () {
    List<String> surfacesOn(String tab) => [
          for (final s in door.sectionsOf(tab))
            for (final t in s.tiles)
              if (t is PvDoorToolTile) t.surfaceId,
        ];

    test('yoga is on Move safely and on Classes and tools', () {
      expect(surfacesOn(kMoveTabMove), contains(kMoveSurfaceYoga));
      expect(surfacesOn(kMoveTabClasses), contains(kMoveSurfaceYoga));
    });

    test('Kegel Care is on Pelvic floor and on Classes and tools', () {
      expect(surfacesOn(kMoveTabPelvic), contains(kMoveSurfaceKegel));
      expect(surfacesOn(kMoveTabClasses), contains(kMoveSurfaceKegel));
    });

    test('the surface ids are the ones the router is told about', () {
      expect(kMoveSurfaceYoga, 'move/yoga');
      expect(kMoveSurfaceKegel, 'move/kegel');
      final all = {
        for (final t in door.allTiles)
          if (t is PvDoorToolTile) t.surfaceId,
      };
      expect(all, {kMoveSurfaceYoga, kMoveSurfaceKegel},
          reason: 'a tool tile names a surface the lead has not been asked '
              'to wire.');
    });
  });

  group('every card opens a read, and every read has a card', () {
    test('every guide and myth tile names a read in kPregnancyReadsMove', () {
      for (final t in door.allTiles) {
        final id = _readIdOf(t);
        if (id == null) continue;
        expect(readIds, contains(id),
            reason: '"${t.title}" points at "$id", which does not exist.');
      }
    });

    test('every read in kPregnancyReadsMove is on at least one tile', () {
      final onDoor = {
        for (final t in door.allTiles) ?_readIdOf(t),
      };
      expect(readIds.difference(onDoor), isEmpty,
          reason: 'these reads are unreachable from the door.');
    });

    test('a myth tile opens a read whose first section is the myth', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorMythTile) continue;
        final r = moveReadById(t.readId)!;
        expect(r.sections.first.mythFact, isNotNull, reason: r.id);
      }
    });

    test('every atHeading matches a heading in its read', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile || t.atHeading == null) continue;
        final r = moveReadById(t.readId)!;
        expect(r.toc.map((h) => h.en), contains(t.atHeading),
            reason: '"${t.title}" would open ${r.id} at the top.');
      }
    });
  });

  group('the reads', () {
    test('there are about fourteen, all preg_move_read_*, ids unique', () {
      expect(kPregnancyReadsMove.length, greaterThanOrEqualTo(14));
      expect(readIds.length, kPregnancyReadsMove.length);
      for (final id in readIds) {
        expect(id, startsWith('preg_move_read_'));
      }
    });

    test('each passes the shared shape rules', () {
      final problems = [
        for (final r in kPregnancyReadsMove) ...r.assertShape(),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('each has a short answer, and is honest about review', () {
      for (final r in kPregnancyReadsMove) {
        expect(r.shortAnswer?.en.trim() ?? '', isNotEmpty,
            reason: '${r.id} has no short answer.');
        expect(r.reviewed, isFalse,
            reason: '${r.id} claims a clinical review nobody has done.');
        expect(r.author.en, 'ParentVeda editorial');
      }
    });

    test('each ends at a person, with the urgent tone', () {
      for (final r in kPregnancyReadsMove) {
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent);
        final line = '${r.whenToSeeSomeone.title.en} '
            '${r.whenToSeeSomeone.body.en}';
        expect(line, anyOf(contains('doctor'), contains('hospital')),
            reason: r.id);
      }
    });

    test('every readNext resolves inside this file, and none is itself', () {
      for (final r in kPregnancyReadsMove) {
        expect(r.readNext, isNot(contains(r.id)));
        for (final id in r.readNext) {
          expect(readIds, contains(id), reason: '${r.id} → $id');
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
      for (final r in kPregnancyReadsMove) {
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
      for (final r in kPregnancyReadsMove) ..._readStrings(r),
    ];

    test('no em dashes, spaced hyphens or exclamation marks', () {
      final hits = [
        for (final (where, s) in all)
          if (s.contains('—') || s.contains(' - ') || s.contains('!'))
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
  });
}
