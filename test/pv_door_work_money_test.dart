// =============================================================================
//  The Work, money and rights door: three tabs, every read on a card, every
//  card a read
// -----------------------------------------------------------------------------
//  Built 2026-09-29 from the pregnancy gap analysis ("New section: Work, money
//  and rights", P2). The door-wide gates (every surface resolves, every door
//  wears a photograph) live in `pv_door_scans_test.dart` and walk
//  `kPvDoorPages`; this door inherits them the day it is registered there.
//
//  ⚠️ THIS FILE IMPORTS THE DOOR AND ITS READS DIRECTLY, so it holds on its
//  own before the lead wires `kWorkMoneyDoor` into `kPvDoorPages` and
//  `kPregnancyReadsWork` into `kPregnancyReads`. That is also why it runs
//  `assertShape()` itself.
//
//  ⚠️ THE LEGAL AND MONEY LINE IS HELD HERE TOO: the Act is named where the
//  26 weeks are, the delivery-cost read says "written estimate" beside its
//  one rough range, and no read offers a rupee figure for a private delivery
//  without calling it rough.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads_work.dart';
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
  final door = kWorkMoneyDoor;
  final readIds = {for (final r in kPregnancyReadsWork) r.id};

  group('the door keeps the benchmark shape', () {
    test('it opens from the Work, money and rights bracket', () {
      expect(door.bracketId, 'pregnancy_work_money');
    });

    test('three tabs, in order', () {
      expect(door.groups.map((g) => g.id),
          [kWorkMoneyTabWork, kWorkMoneyTabLeave, kWorkMoneyTabMoney]);
      expect(door.groups.map((g) => g.label),
          ['Work', 'Leave and rights', 'Money']);
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

    test('a hero, a photograph, and a closing line that sends her to check',
        () {
      expect(door.heroTitle.trim(), isNotEmpty);
      expect(door.heroBlurb.trim(), isNotEmpty);
      expect(door.heroImageUrl, isNotNull,
          reason: 'pv_door_scans_test fails the day this door is registered '
              'without one.');
      expect(door.closingLine, allOf(contains('HR'), contains('doctor')));
    });

    test('no other door wears the same photograph', () {
      for (final other in kPvDoorPages) {
        if (other.bracketId == door.bracketId) continue;
        expect(other.heroImageUrl, isNot(door.heroImageUrl),
            reason: '${other.bracketId} already uses this photograph.');
      }
    });

    test('the leave and money tabs say rules change, and to check', () {
      for (final id in [kWorkMoneyTabLeave, kWorkMoneyTabMoney]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.note, isNotNull, reason: '${g.label} has no note.');
        expect(g.note!.toLowerCase(), contains('check'));
      }
    });

    test('every tile has a blurb that is not its title', () {
      for (final t in door.allTiles) {
        expect(t.blurb.trim(), isNotEmpty, reason: '"${t.title}" has none.');
        expect(t.blurb.toLowerCase(), isNot(t.title.toLowerCase()));
      }
    });

    test('no tool tiles: the budget sheet is owed, not built', () {
      expect(door.allTiles.whereType<PvDoorToolTile>(), isEmpty);
    });
  });

  group('every card opens a read, and every read has a card', () {
    test('every guide and myth tile names a read in kPregnancyReadsWork', () {
      for (final t in door.allTiles) {
        final id = _readIdOf(t);
        if (id == null) continue;
        expect(readIds, contains(id),
            reason: '"${t.title}" points at "$id", which does not exist.');
      }
    });

    test('every read in kPregnancyReadsWork is on at least one tile', () {
      final onDoor = {
        for (final t in door.allTiles) ?_readIdOf(t),
      };
      expect(readIds.difference(onDoor), isEmpty,
          reason: 'these reads are unreachable from the door.');
    });

    test('a myth tile opens a read whose first section is the myth', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorMythTile) continue;
        final r = workReadById(t.readId)!;
        expect(r.sections.first.mythFact, isNotNull, reason: r.id);
      }
    });

    test('every atHeading matches a heading in its read', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile || t.atHeading == null) continue;
        final r = workReadById(t.readId)!;
        expect(r.toc.map((h) => h.en), contains(t.atHeading),
            reason: '"${t.title}" would open ${r.id} at the top.');
      }
    });
  });

  group('the reads', () {
    test('there are about twelve, all preg_work_read_*, ids unique', () {
      expect(kPregnancyReadsWork.length, greaterThanOrEqualTo(12));
      expect(readIds.length, kPregnancyReadsWork.length);
      for (final id in readIds) {
        expect(id, startsWith('preg_work_read_'));
      }
    });

    test('each passes the shared shape rules', () {
      final problems = [
        for (final r in kPregnancyReadsWork) ...r.assertShape(),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('each has a short answer, and is honest about review', () {
      for (final r in kPregnancyReadsWork) {
        expect(r.shortAnswer?.en.trim() ?? '', isNotEmpty,
            reason: '${r.id} has no short answer.');
        expect(r.reviewed, isFalse,
            reason: '${r.id} claims a review nobody has done.');
        expect(r.author.en, 'ParentVeda editorial');
      }
    });

    test('each ends at a person, with the urgent tone', () {
      for (final r in kPregnancyReadsWork) {
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent);
        final line = '${r.whenToSeeSomeone.title.en} '
            '${r.whenToSeeSomeone.body.en}';
        expect(line, anyOf(contains('doctor'), contains('hospital')),
            reason: r.id);
      }
    });

    test('every read names where its facts come from', () {
      for (final r in kPregnancyReadsWork) {
        expect(r.evidence?.en.trim() ?? '', isNotEmpty, reason: r.id);
      }
    });

    test('every readNext resolves inside this file, and none is itself', () {
      for (final r in kPregnancyReadsWork) {
        expect(r.readNext, isNot(contains(r.id)));
        for (final id in r.readNext) {
          expect(readIds, contains(id), reason: '${r.id} → $id');
        }
      }
    });

    test('no sentence puts "your" beside a chance word', () {
      final possessive = RegExp(r'\byour\b', caseSensitive: false);
      final chance = RegExp(r'\b(chance|odds|risk|likelihood|probability)\b',
          caseSensitive: false);
      final hits = <String>[];
      for (final r in kPregnancyReadsWork) {
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

  group('the legal and money line', () {
    PvRead read(String id) => workReadById(id)!;
    String all(PvRead r) => _readStrings(r).map((e) => e.$2).join(' ');

    test('the 26 weeks are tied to the Act that gives them', () {
      final r = read('preg_work_read_maternity_leave');
      expect(r.shortAnswer!.en, contains('Maternity Benefit Act'));
      expect(r.shortAnswer!.en, contains('26 weeks'));
      expect(r.shortAnswer!.en, contains('may be entitled'));
      expect(r.evidence!.en, contains('Maternity Benefit Act, 1961'));
    });

    test('the private delivery range is called rough, beside a written '
        'estimate', () {
      final r = read('preg_work_read_delivery_cost');
      final text = all(r);
      expect(text, contains('very rough guide'));
      expect(text, contains('written estimate'));
    });

    test('a private delivery price appears nowhere else', () {
      // The one range lives in the delivery-cost read. A lakh figure
      // anywhere else is an unmarked price.
      for (final r in kPregnancyReadsWork) {
        if (r.id == 'preg_work_read_delivery_cost') continue;
        for (final (where, s) in _readStrings(r)) {
          if (s.contains('lakh')) {
            expect(s, anyOf(contains('₹5 lakh per family'),
                contains('under ₹8 lakh')),
                reason: '$where names a price: $s');
          }
        }
      }
    });

    test('every money read says care in a government hospital is free', () {
      for (final r in kPregnancyReadsWork) {
        if (r.kicker.en != 'Money') continue;
        expect(r.whenToSeeSomeone.body.en, contains('JSSK'), reason: r.id);
      }
    });
  });

  group('the voice (docs/PREG-VOICE.md)', () {
    final all = <(String, String)>[
      for (final s in _doorStrings(door)) ('door', s),
      for (final g in door.groups)
        if (g.note != null) ('note', g.note!),
      for (final r in kPregnancyReadsWork) ..._readStrings(r),
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

    test('nothing about learning the baby\'s sex', () {
      final sex = RegExp(r'\b(gender|boy or girl|sex of)\b',
          caseSensitive: false);
      final hits = [
        for (final (where, s) in all)
          if (sex.hasMatch(s)) '$where: $s',
      ];
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  });
}
