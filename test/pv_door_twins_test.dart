// =============================================================================
//  The Twins and more door (pregnancy): reachable, deep enough, and calm
// -----------------------------------------------------------------------------
//  Added 2026-09-29 with the door (gap analysis P3). Stands on its own: it
//  walks `kTwinsDoor` and `kPregnancyReadsTwins` directly, so it holds before
//  and after the lead registers either in the shared indexes. That is also
//  why it runs `assertShape()` itself: until the reads are spread into
//  `kPregnancyReads`, `pregnancy_reads_shape_test.dart` cannot see them.
//
//  Pinned here:
//
//    · **Structure.** Four tabs in order, every guide tile resolving to a read
//      in this door's library, every read reachable from a tile (the wiring
//      gate, CLAUDE.md), every `atHeading` matching a real heading.
//    · **Depth and honesty.** Every read passes `assertShape`, carries a short
//      answer, and is `reviewed: false` with the editorial byline.
//    · **Clinical floor.** No sentence puts "your" beside a chance word, and
//      nothing touches learning the babies' sex (PCPNDT Act).
//    · **Voice.** No dash as punctuation, no exclamation mark, no PREG-VOICE
//      §4 word.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/data/reads/pregnancy_reads_twins.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/life_stage_store.dart';

/// PREG-VOICE §4, the banned words and phrases.
const _banned = [
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

/// The read id a tile opens, or null for a tile that opens something else.
String? _readIdOf(PvDoorTile t) => switch (t) {
      PvDoorGuideTile(:final readId) => readId,
      PvDoorMythTile(:final readId) => readId,
      _ => null,
    };

/// Every string a reader of this door can see, with where it came from.
List<(String, String)> _allStrings() {
  final out = <(String, String)>[];
  void add(String where, String? s) {
    if (s != null) out.add((where, s));
  }

  final d = kTwinsDoor;
  add('hero title', d.heroTitle);
  add('hero blurb', d.heroBlurb);
  add('closing line', d.closingLine);
  for (final g in d.groups) {
    add('tab ${g.id}', g.label);
    add('tab ${g.id} note', g.note);
    final f = g.pinnedRedFlag;
    if (f != null) {
      add('tab ${g.id} flag', f.title);
      add('tab ${g.id} flag footer', f.footer);
      for (final l in f.lines) {
        add('tab ${g.id} flag line', l.text);
      }
    }
  }
  for (final s in d.sections) {
    add('section', s.heading);
    for (final t in s.tiles) {
      add('tile', t.title);
      add('tile blurb', t.blurb);
      add('tile meta', t.meta);
    }
  }

  final b = kPregTwinsBracket;
  add('bracket label', b.label.en);
  add('bracket title', b.title.en);
  add('bracket blurb', b.blurb.en);

  for (final r in kPregnancyReadsTwins) {
    final w = r.id;
    add('$w title', r.title.en);
    add('$w kicker', r.kicker.en);
    add('$w teaser', r.teaser.en);
    add('$w shortAnswer', r.shortAnswer?.en);
    add('$w scaleSetter', r.scaleSetter.en);
    add('$w author', r.author.en);
    add('$w authorRole', r.authorRole.en);
    add('$w evidence', r.evidence?.en);
    add('$w callout title', r.whenToSeeSomeone.title.en);
    add('$w callout body', r.whenToSeeSomeone.body.en);
    for (final s in r.sections) {
      add('$w heading', s.heading?.en);
      add('$w summary', s.summary?.en);
      for (final p in s.paragraphs) {
        add('$w paragraph', p.en);
      }
      for (final p in s.bullets) {
        add('$w bullet', p.en);
      }
      add('$w tip title', s.tip?.title.en);
      add('$w tip body', s.tip?.body.en);
      add('$w myth', s.mythFact?.myth.en);
      add('$w fact', s.mythFact?.fact.en);
      add('$w section callout title', s.callout?.title.en);
      add('$w section callout body', s.callout?.body.en);
    }
    for (final f in r.faqs) {
      add('$w faq q', f.question.en);
      add('$w faq a', f.answer.en);
    }
  }
  return out;
}

void main() {
  final door = kTwinsDoor;
  final byId = {for (final r in kPregnancyReadsTwins) r.id: r};

  group('structure', () {
    test('four tabs, in order', () {
      expect(door.groups.map((g) => g.id), [
        kTwinsTabCarrying,
        kTwinsTabCare,
        kTwinsTabBirth,
        kTwinsTabTwo,
      ]);
      expect(door.groups.map((g) => g.label), [
        'Carrying twins',
        'Your care',
        'The birth',
        'Getting ready for two',
      ]);
    });

    test('the door and its bracket agree, and the bracket is its own', () {
      expect(door.bracketId, kPregTwinsBracket.id);
      expect(kPregTwinsBracket.id, 'pregnancy_twins');
      expect(kPregTwinsBracket.stage, LifeStage.pregnancy);
      expect(kPregTwinsBracket.theme, 'twins');
      expect(pvDoorPageFor('pregnancy_twins'), anyOf(isNull, same(door)));
    });

    test('every layer is declared', () {
      for (final l in BracketLayer.values) {
        expect(kPregTwinsBracket.layers.containsKey(l), isTrue,
            reason: 'layer $l undeclared');
      }
    });

    test('a hero, a photograph no other door wears, and a closing line that '
        'defers to her doctor', () {
      expect(door.heroTitle.trim(), isNotEmpty);
      expect(door.heroBlurb.trim(), isNotEmpty);
      expect(door.heroImageUrl, isNotNull);
      for (final other in kPvDoorPages) {
        if (other.bracketId == door.bracketId) continue;
        expect(other.heroImageUrl, isNot(door.heroImageUrl),
            reason: '${other.bracketId} already uses this photograph.');
      }
      expect(door.closingLine, contains('doctor'));
    });

    test('every section sits in a tab that exists, and no tab is empty', () {
      final ids = door.groups.map((g) => g.id).toSet();
      for (final s in door.sections) {
        expect(ids, contains(s.group), reason: s.heading);
        expect(s.tiles, isNotEmpty, reason: s.heading);
      }
      for (final g in door.groups) {
        expect(door.sectionsOf(g.id), isNotEmpty, reason: g.id);
      }
    });

    test('every tile has a blurb that is not its title', () {
      for (final t in door.allTiles) {
        expect(t.blurb.trim(), isNotEmpty, reason: '"${t.title}" has none.');
        expect(t.blurb.toLowerCase(), isNot(t.title.toLowerCase()));
      }
    });

    test('Your care pins the signs, and each line says how soon', () {
      final care = door.groups.firstWhere((g) => g.id == kTwinsTabCare);
      final flag = care.pinnedRedFlag;
      expect(flag, isNotNull);
      for (final l in flag!.lines) {
        expect(
            l.text,
            anyOf(contains('straight away'), contains('same day'),
                contains('today'), contains('go to hospital')),
            reason: l.text);
      }
    });
  });

  group('every card opens something that exists', () {
    test('every guide tile opens a read in this door', () {
      final missing = [
        for (final t in door.allTiles)
          if (_readIdOf(t) case final id? when !byId.containsKey(id)) id,
      ];
      expect(missing, isEmpty);
    });

    test('every read is on a tile', () {
      final onTiles = {for (final t in door.allTiles) ?_readIdOf(t)};
      final orphans = [
        for (final r in kPregnancyReadsTwins)
          if (!onTiles.contains(r.id)) r.id,
      ];
      expect(orphans, isEmpty, reason: 'correct but unreachable reads');
    });

    test('every atHeading matches a heading in its read', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile || t.atHeading == null) continue;
        final r = twinsReadById(t.readId)!;
        expect(r.toc.map((h) => h.en), contains(t.atHeading),
            reason: '"${t.title}" would open ${r.id} at the top.');
      }
    });

    test('entry, tool and flag surfaces resolve', () {
      for (final t in door.allTiles) {
        switch (t) {
          case PvDoorEntryTile(:final library, :final entryId):
            expect(pvDoorEntryResolves(library, entryId), isTrue,
                reason: '$library/$entryId');
          case PvDoorToolTile(:final surfaceId) ||
                PvDoorTalkTile(:final surfaceId):
            expect(pvDoorSurfaceResolves(surfaceId), isTrue,
                reason: surfaceId);
          default:
            break;
        }
      }
      for (final g in door.groups) {
        final f = g.pinnedRedFlag;
        if (f == null) continue;
        expect(pvDoorSurfaceResolves(f.surfaceId), isTrue,
            reason: f.surfaceId);
        for (final l in f.lines) {
          final c = l.conditionId;
          if (c == null) continue;
          expect(kAllConditions.any((x) => x.id == c), isTrue, reason: c);
        }
      }
    });

    test('the only tool is the shipped hospital bag', () {
      final tools = {
        for (final t in door.allTiles)
          if (t is PvDoorToolTile) t.surfaceId,
      };
      expect(tools, {kLabourSurfaceBag});
    });
  });

  group('the reads', () {
    test('about nine, ids prefixed and unique', () {
      expect(kPregnancyReadsTwins.length, greaterThanOrEqualTo(9));
      final ids = kPregnancyReadsTwins.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id, startsWith('preg_twins_read_'));
      }
    });

    test('each passes its shape rules', () {
      final problems = [
        for (final r in kPregnancyReadsTwins) ...r.assertShape(),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('each has a short answer, and is honest about review', () {
      for (final r in kPregnancyReadsTwins) {
        expect(r.shortAnswer?.en.trim() ?? '', isNotEmpty, reason: r.id);
        expect(r.reviewed, isFalse,
            reason: '${r.id} claims a clinical review nobody has done.');
        expect(r.author.en, 'ParentVeda editorial', reason: r.id);
      }
    });

    test('each ends at a person, with the urgent tone', () {
      for (final r in kPregnancyReadsTwins) {
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent, reason: r.id);
        final line = '${r.whenToSeeSomeone.title.en} '
            '${r.whenToSeeSomeone.body.en}';
        expect(line, anyOf(contains('doctor'), contains('hospital')),
            reason: r.id);
      }
    });

    test('read-next links stay inside the door and never loop', () {
      for (final r in kPregnancyReadsTwins) {
        expect(r.readNext, isNotEmpty, reason: r.id);
        for (final id in r.readNext) {
          expect(byId.containsKey(id), isTrue, reason: '${r.id} → $id');
          expect(id, isNot(r.id));
        }
      }
    });
  });

  group('the clinical floor', () {
    test('no sentence attaches a chance to the reader', () {
      final possessive = RegExp(r'\byour\b', caseSensitive: false);
      final chance = RegExp(r'\b(chance|odds|risk|likelihood|probability)\b',
          caseSensitive: false);
      final hits = <String>[];
      for (final (where, s) in _allStrings()) {
        for (final sentence in s.split(RegExp(r'(?<=[.!?])\s+'))) {
          if (possessive.hasMatch(sentence) && chance.hasMatch(sentence)) {
            hits.add('$where: $sentence');
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test("nothing about the babies' sex", () {
      final sex = RegExp(
          r"\b(boy or girl|boys? and girls?|girl or boy|baby's sex|babies' "
          r'sex|same sex|sex of|gender)\b',
          caseSensitive: false);
      final bad = [
        for (final (where, s) in _allStrings())
          if (sex.hasMatch(s)) '$where: $s',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  group('voice (docs/PREG-VOICE.md)', () {
    test('no dash as punctuation, and no exclamation mark', () {
      final bad = [
        for (final (where, s) in _allStrings())
          if (s.contains('—') ||
              s.contains('–') ||
              s.contains(' - ') ||
              s.contains('!'))
            '$where: $s',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('no banned word or phrase', () {
      final bad = <String>[];
      for (final (where, s) in _allStrings()) {
        for (final w in _banned) {
          final re = RegExp('(?<![A-Za-z])${RegExp.escape(w)}(?![A-Za-z])',
              caseSensitive: false);
          if (re.hasMatch(s)) bad.add('$where: "$w" in $s');
        }
        for (final sentence in s.split(RegExp(r'(?<=[.?:])\s+'))) {
          if (sentence.trimLeft().toLowerCase().startsWith('remember')) {
            bad.add('$where: opens with "Remember"');
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });
}
