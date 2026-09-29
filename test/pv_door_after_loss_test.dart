// =============================================================================
//  The After a loss door (pregnancy): reachable, deep enough, and gentle
// -----------------------------------------------------------------------------
//  Added 2026-09-29 with the door (gap analysis P1). Stands on its own: it
//  walks `kAfterLossDoor` and `kPregnancyReadsLoss` directly, so it holds
//  before and after the lead registers either in the shared indexes.
//
//  Three things are pinned here:
//
//    · **Structure.** Four tabs in the order the gap analysis gives, every
//      guide tile resolving to a read in this door's library, and every read
//      reachable from a tile (the wiring gate, CLAUDE.md).
//    · **Depth and honesty.** Every read passes `assertShape`, carries a short
//      answer, and is `reviewed: false` with the editorial byline until a
//      doctor and a counsellor have read it.
//    · **Voice.** This is the most sensitive writing in the app. No dash as
//      punctuation, no exclamation mark, no PREG-VOICE §4 word, and none of
//      the phrases that make a loss smaller or turn it into a baby card. The
//      same check covers the "My pregnancy ended" screen words.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads_loss.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';

/// PREG-VOICE §4, the banned words and phrases, plus this door's own list.
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
  // This door's own: the lines that make a loss smaller, and a baby card.
  'at least',
  'everything happens for a reason',
  'baby is the size',
  'congratulations',
];

/// Every string a reader of this door can see, with where it came from.
List<(String, String)> _allStrings() {
  final out = <(String, String)>[];
  void add(String where, String? s) {
    if (s != null) out.add((where, s));
  }

  final d = kAfterLossDoor;
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

  final b = kPregAfterLossBracket;
  add('bracket label', b.label.en);
  add('bracket title', b.title.en);
  add('bracket blurb', b.blurb.en);

  add('kPregEndedRowTitle', kPregEndedRowTitle);
  add('kPregEndedRowSub', kPregEndedRowSub);
  add('kPregEndedTitle', kPregEndedTitle);
  for (final p in kPregEndedBody) {
    add('kPregEndedBody', p);
  }
  add('kPregEndedConfirm', kPregEndedConfirm);
  add('kPregEndedCancel', kPregEndedCancel);
  add('kPregEndedUndoTitle', kPregEndedUndoTitle);
  for (final p in kPregEndedUndoBody) {
    add('kPregEndedUndoBody', p);
  }
  add('kPregEndedUndoConfirm', kPregEndedUndoConfirm);
  add('kPregEndedUndoCancel', kPregEndedUndoCancel);
  add('kPregEndedHomeTitle', kPregEndedHomeTitle);
  add('kPregEndedDone', kPregEndedDone);
  for (final e in kPregEndedTabLines.entries) {
    add('kPregEndedTabLines ${e.key}', e.value);
  }
  add('kPregEndedPartnerTitle', kPregEndedPartnerTitle);
  add('kPregEndedPartnerBody', kPregEndedPartnerBody);
  add('kPregEndedUndoLink', kPregEndedUndoLink);

  for (final r in kPregnancyReadsLoss) {
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
  final byId = {for (final r in kPregnancyReadsLoss) r.id: r};

  group('structure', () {
    test('four tabs, in the order the gap analysis gives, body first', () {
      expect(kAfterLossDoor.groups.map((g) => g.id),
          ['body', 'understand', 'support', 'again']);
      expect(kAfterLossDoor.groups.map((g) => g.label),
          ['Your body', 'Understand', 'Support', 'Trying again']);
    });

    test('the door and its bracket agree, and the bracket is not a home tile',
        () {
      expect(kAfterLossDoor.bracketId, kPregAfterLossBracket.id);
      expect(kPregAfterLossBracket.id, 'pregnancy_after_loss');
      expect(pvDoorPageFor('pregnancy_after_loss'), anyOf(isNull, same(kAfterLossDoor)));
    });

    test('every layer is declared, and products never ship', () {
      for (final l in BracketLayer.values) {
        expect(kPregAfterLossBracket.layers.containsKey(l), isTrue,
            reason: 'layer $l undeclared');
      }
      expect(kPregAfterLossBracket.layer(BracketLayer.products).state,
          LayerState.notApplicable);
    });

    test('no baby photograph behind the hero', () {
      expect(kAfterLossDoor.heroImageUrl, isNull);
    });

    test('every section sits in a tab that exists, and no tab is empty', () {
      final ids = kAfterLossDoor.groups.map((g) => g.id).toSet();
      for (final s in kAfterLossDoor.sections) {
        expect(ids, contains(s.group), reason: s.heading);
        expect(s.tiles, isNotEmpty, reason: s.heading);
      }
      for (final g in kAfterLossDoor.groups) {
        expect(kAfterLossDoor.sectionsOf(g.id), isNotEmpty, reason: g.id);
      }
    });

    test('every guide tile opens a read in this door', () {
      final missing = [
        for (final t in kAfterLossDoor.allTiles.whereType<PvDoorGuideTile>())
          if (!byId.containsKey(t.readId)) t.readId,
      ];
      expect(missing, isEmpty);
    });

    test('every read is on a tile', () {
      final onTiles = {
        for (final t in kAfterLossDoor.allTiles.whereType<PvDoorGuideTile>())
          t.readId,
      };
      final orphans = [
        for (final r in kPregnancyReadsLoss)
          if (!onTiles.contains(r.id)) r.id,
      ];
      expect(orphans, isEmpty, reason: 'correct but unreachable reads');
    });

    test('the other tiles open something that exists', () {
      for (final t in kAfterLossDoor.allTiles) {
        switch (t) {
          case PvDoorEntryTile(:final library, :final entryId):
            expect(pvDoorEntryResolves(library, entryId), isTrue,
                reason: '$library/$entryId');
          case PvDoorToolTile(:final surfaceId) ||
                PvDoorTalkTile(:final surfaceId):
            // ⚠️ THE STAGE SWITCH IS OWED BY THE LEAD, who wires the surface
            // (a confirm, then the move to trying to conceive). Everything
            // else must already resolve.
            if (surfaceId == kAfterLossSurfaceTryAgain) continue;
            expect(pvDoorSurfaceResolves(surfaceId), isTrue,
                reason: surfaceId);
          default:
            break;
        }
      }
      for (final g in kAfterLossDoor.groups) {
        final f = g.pinnedRedFlag;
        if (f != null) {
          expect(pvDoorSurfaceResolves(f.surfaceId), isTrue,
              reason: f.surfaceId);
        }
      }
    });

    test('the condition pages it links back to exist', () {
      for (final id in ['miscarriage', 'ectopic']) {
        expect(kAllConditions.any((c) => c.id == id), isTrue, reason: id);
      }
    });

    test('the Trying again tab offers the stage switch', () {
      final tiles = [
        for (final s in kAfterLossDoor.sectionsOf('again')) ...s.tiles,
      ];
      expect(
          tiles.whereType<PvDoorToolTile>().map((t) => t.surfaceId),
          contains(kAfterLossSurfaceTryAgain));
      expect(kAfterLossSurfaceTryAgain, 'after_loss/try_again');
    });

    test('the "My pregnancy ended" page has a line for every tab', () {
      expect(kPregEndedTabLines.keys.toSet(),
          kAfterLossDoor.groups.map((g) => g.id).toSet());
      expect(kPregEndedBody.length, inInclusiveRange(2, 3));
      expect(kPregEndedConfirm, 'Yes, update ParentVeda');
      expect(kPregEndedCancel, 'Not now');
    });
  });

  group('the reads', () {
    test('about fourteen, ids prefixed and unique', () {
      expect(kPregnancyReadsLoss.length, greaterThanOrEqualTo(14));
      final ids = kPregnancyReadsLoss.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id.startsWith('preg_loss_read_'), isTrue, reason: id);
      }
    });

    test('each passes its shape rules', () {
      final problems = [
        for (final r in kPregnancyReadsLoss) ...r.assertShape(),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('each has a short answer, and is honest about review', () {
      for (final r in kPregnancyReadsLoss) {
        expect(r.shortAnswer?.en.trim(), isNotEmpty, reason: r.id);
        expect(r.reviewed, isFalse, reason: r.id);
        expect(r.author.en, 'ParentVeda editorial', reason: r.id);
        expect(r.whenToSeeSomeone.tone, PvCalloutTone.urgent, reason: r.id);
      }
    });

    test('read-next links stay inside the door and never loop', () {
      for (final r in kPregnancyReadsLoss) {
        for (final id in r.readNext) {
          expect(byId.containsKey(id), isTrue, reason: '${r.id} → $id');
          expect(id, isNot(r.id));
        }
      }
    });

    test('no sentence attaches a chance to the reader', () {
      // The same pattern `pregnancy_reads_shape_test.dart` scans for, run
      // here too so it holds before the lead spreads these reads.
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

    test('the helpline number is the one the app uses everywhere', () {
      final all = _allStrings().map((e) => e.$2).join(' ');
      expect(all, contains('Tele-MANAS on 14416'));
    });
  });

  group('voice', () {
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
        final lower = s.toLowerCase();
        for (final b in _banned) {
          if (lower.contains(b)) bad.add('$where: "$b" in $s');
        }
        if (lower.trimLeft().startsWith('remember')) {
          bad.add('$where: opens with remember');
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('nothing about learning the baby\'s sex', () {
      final sex = RegExp(r"\b(boy or girl|baby's sex|gender of)\b",
          caseSensitive: false);
      final bad = [
        for (final (where, s) in _allStrings())
          if (sex.hasMatch(s)) '$where: $s',
      ];
      expect(bad, isEmpty);
    });
  });
}
