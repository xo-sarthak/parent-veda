// =============================================================================
//  The Complications door is wired, and its language rule holds
// -----------------------------------------------------------------------------
//  The reachability gates live in `pv_door_scans_test.dart`, which walks
//  `kPvDoorPages` — so this door inherited every one of them the moment it was
//  registered, and none of them is repeated here.
//
//  What IS here is the two things this brief adds that no test could have
//  anticipated:
//
//    · **The language rule.** It is the strictest in the app and it is entirely
//      a property of strings, which means nothing about it fails to compile. A
//      card reading "Low-lying placenta (the placenta is sitting low)" renders
//      perfectly and breaks the rule the brief states twice.
//    · **The assembled red flag.** "No new medical advice; assemble only" is a
//      claim about provenance, and provenance is exactly the kind of thing that
//      rots quietly — a line reworded here and there, and six months later a
//      pinned safety list says something no condition page does.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/checklists/pv_checklist.dart';
import 'package:parentveda/data/conditions_data.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/report_findings_data.dart';
import 'package:parentveda/data/same_day_signs_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  late PvDoorPage door;
  setUp(() => door = pvDoorPageFor('pregnancy_complications')!);

  group('the door matches the brief', () {
    test('five sub-tabs, Find a condition first', () {
      expect(door.groups.length, 5);
      expect(door.groups.first.id, kCondTabFind);
      expect(door.groups.map((g) => g.label), [
        'Find a condition',
        'When it comes up',
        'Get help now',
        'Living with it',
        'Talk',
      ]);
    });

    test('sub-tab 1 is a search screen, not a rail', () {
      // The brief says so by name, and its DO NOT list repeats it.
      final g = door.groups.firstWhere((g) => g.id == kCondTabFind);
      expect(g.layout, PvDoorLayout.stack);
      expect(g.inlineSurfaceId, kCondSurfaceFind);
      // And it carries no cards — the search, the chip and the Most-common list
      // ARE the tab.
      expect(door.sectionsOf(kCondTabFind), isEmpty);
    });

    test('sub-tabs 2, 3, 4 and 5 are card rails', () {
      for (final id in [
        kCondTabWhen,
        kCondTabHelp,
        kCondTabLiving,
        kCondTabTalk
      ]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.rails, reason: '${g.label} is a rail');
      }
    });

    test('the eleven browse cards the brief lists, in its order', () {
      final titles = [
        for (final s in door.sectionsOf(kCondTabWhen))
          for (final t in s.tiles) t.title,
      ];
      expect(titles, [
        'Pregnancy in the wrong place (ectopic)',
        'Severe vomiting (hyperemesis)',
        'Thyroid gland off (thyroid in pregnancy)',
        'Low blood, low iron (anemia)',
        'Pregnancy sugar goes high (gestational diabetes)',
        'Placenta sitting low (low-lying placenta)',
        'PCOS in pregnancy',
        'Blood pressure needs watching (high BP)',
        'Baby lying feet-down (breech)',
        'Less water around the baby (low fluid)',
        'Cord looped around the neck (cord around neck)',
      ]);
    });

    test('two flags, and they are different lists', () {
      // ⚠️ ONE DOOR, TWO PINNED FLAGS, ON PURPOSE. Get-help-now carries the
      // assembled condition list; Talk carries the stage's standing pregnancy
      // list, which is the same object the Scans door pins. Collapsing them
      // would either put condition-specific lines on a general warning or drop
      // the general ones from a safety tab.
      final help = door.groups.firstWhere((g) => g.id == kCondTabHelp);
      final talk = door.groups.firstWhere((g) => g.id == kCondTabTalk);
      expect(help.pinnedRedFlag, isNotNull);
      expect(talk.pinnedRedFlag, isNotNull);
      expect(help.pinnedRedFlag!.title, 'Signs to get help the same day');
      expect(talk.pinnedRedFlag!.title, 'Call your doctor if');
      expect(help.pinnedRedFlag!.lines.length,
          isNot(equals(talk.pinnedRedFlag!.lines.length)));
    });

    test('no other tab pins a flag', () {
      for (final g in door.groups) {
        if (g.id == kCondTabHelp || g.id == kCondTabTalk) continue;
        expect(g.pinnedRedFlag, isNull,
            reason: '${g.label} should not be alarming.');
      }
    });

    test('the report locker is linked, not rebuilt', () {
      // The brief: "links to My reports in Scans (single source)."
      final tile = door.allTiles
          .firstWhere((t) => t.title == 'Keep your reports for this');
      expect((tile as PvDoorToolTile).surfaceId, 'scans/reports');
    });
  });

  group('the language rule', () {
    /// The medical words this brief names. A bare one may appear ONLY as a
    /// condition page title, and in a browse card only inside brackets, second.
    const medical = [
      'gestational diabetes',
      'hyperemesis',
      'low-lying placenta',
      'ectopic',
      'breech',
      'anemia',
      'anaemia',
      'preeclampsia',
      'placenta previa',
      'oligohydramnios',
      'nuchal cord',
      'hypothyroid',
    ];

    test('no browse card leads with a medical word', () {
      // ⚠️ THE BRIEF STATES IT TWICE: *"the card LEADS with the plain phrase
      // and puts the medical name in brackets after it."* So a medical word is
      // allowed in a title and only after an opening bracket.
      for (final s in door.sectionsOf(kCondTabWhen)) {
        for (final t in s.tiles) {
          final lower = t.title.toLowerCase();
          for (final word in medical) {
            final at = lower.indexOf(word);
            if (at < 0) continue;
            expect(lower.substring(0, at), contains('('),
                reason: '"${t.title}" leads with "$word". The plain phrase '
                    'goes first and the name in brackets after it.');
          }
        }
      }
    });

    test('no section heading on this door carries a medical word', () {
      // *"Never put a bare medical word as a list label, a section heading, or
      // a red-flag line."*
      for (final s in door.sections) {
        final lower = s.heading.toLowerCase();
        for (final word in medical) {
          expect(lower, isNot(contains(word)),
              reason: 'heading "${s.heading}" carries "$word".');
        }
      }
    });

    test('no tab label carries a medical word', () {
      for (final g in door.groups) {
        final lower = g.label.toLowerCase();
        for (final word in medical) {
          expect(lower, isNot(contains(word)),
              reason: 'tab "${g.label}" carries "$word".');
        }
      }
    });

    test('no red-flag line on either flag carries a medical word', () {
      for (final g in door.groups) {
        final flag = g.pinnedRedFlag;
        if (flag == null) continue;
        for (final line in flag.lines) {
          final lower = line.text.toLowerCase();
          for (final word in medical) {
            expect(lower, isNot(contains(word)),
                reason: 'red-flag line "${line.text}" carries "$word".');
          }
        }
      }
    });

    test('no checklist item carries a medical word', () {
      for (final item in kConditionQuestionsChecklist.items) {
        final lower = item.text.toLowerCase();
        for (final word in medical) {
          expect(lower, isNot(contains(word)),
              reason: '"${item.text}" carries "$word".');
        }
      }
    });
  });

  group('every condition has a plain line, and the brief\'s ten are verbatim',
      () {
    test('all of them, not just the named ten', () {
      // ⚠️ REQUIRED ON THE MODEL, ASSERTED HERE FOR CONTENT. A list where some
      // rows explain themselves and some do not is worse than one where none
      // does — and the ones without would be exactly the rarer conditions,
      // where a mother is least likely to know the word.
      for (final c in kAllConditions) {
        expect(c.plainLine.en.trim(), isNotEmpty, reason: '${c.id} has none.');
        expect(c.plainLine.en, isNot(equals(c.name.en)),
            reason: '${c.id} repeats its own name.');
      }
    });

    test('the ten the brief writes out', () {
      const expected = {
        'gdm': 'Pregnancy sugar goes high.',
        'thyroid': 'The neck gland is off, fixed with a daily tablet.',
        'anemia': 'Low blood, low iron.',
        'hyperemesis': 'Severe pregnancy vomiting.',
        'placenta_previa': 'The placenta is sitting low.',
        'high_bp': 'Blood pressure needs watching.',
        'ectopic': 'The pregnancy is growing in the wrong place.',
        'breech': 'The baby is lying feet-down.',
        'low_amniotic_fluid': 'Less water around the baby.',
      };
      final byId = {for (final c in kAllConditions) c.id: c.plainLine.en};
      expected.forEach((id, line) {
        expect(byId[id], line, reason: '$id has drifted from the brief.');
      });
    });

    test('a plain line is plain', () {
      const jargon = [
        'gestational',
        'hyperemesis',
        'polyhydramnios',
        'oligohydramnios',
        'previa',
        'eclampsia',
      ];
      for (final c in kAllConditions) {
        final lower = c.plainLine.en.toLowerCase();
        for (final word in jargon) {
          expect(lower, isNot(contains(word)),
              reason: '${c.id}\'s plain line says "$word".');
        }
      }
    });
  });

  group('the same-day list is assembled, not authored', () {
    test('every sign names a condition that exists', () {
      for (final s in kSameDaySigns) {
        expect(kAllConditions.any((c) => c.id == s.conditionId), isTrue,
            reason: '"${s.line}" opens "${s.conditionId}", which is not a '
                'condition.');
        expect(kAllConditions.any((c) => c.id == s.because), isTrue,
            reason: '"${s.line}" claims to come from "${s.because}".');
      }
    });

    test('every sign is drawn from a condition that really says it', () {
      // ⚠️ THE PROVENANCE CHECK, AND IT IS THE POINT OF THIS FILE. The brief:
      // "assembled from the existing CALL NOW sections… No new medical advice."
      // A line reworded until it no longer matches its source is exactly how a
      // pinned safety list comes to say something no reviewed page does.
      //
      // It matches on the SUBJECT WORD rather than on the sentence, because the
      // wording is deliberately plainer here than on a condition page — that is
      // the language rule, not a drift. What must hold is that the source page
      // genuinely lists this sign.
      const keyword = {
        'placenta_previa': 'bleeding',
        'preeclampsia': 'headache',
        'iugr': 'moving',
        'uti': 'fever',
        'cervical_incompetence': 'fluid',
      };
      for (final s in kSameDaySigns) {
        final source = kAllConditions.firstWhere((c) => c.id == s.because);
        final callNow =
            source.callNow.map((l) => l.en.toLowerCase()).join(' | ');
        final word = keyword[s.because];
        expect(word, isNotNull,
            reason: 'no provenance keyword recorded for ${s.because} — add '
                'one when you add a sign.');
        expect(callNow, contains(word!),
            reason: '${s.because}\'s call-now list does not mention "$word", '
                'so "${s.line}" is not assembled from it.');
      }
    });

    test('the five the brief names, in its order', () {
      expect(kSameDaySigns.length, 5);
      final lines = kSameDaySigns.map((s) => s.line.toLowerCase()).toList();
      expect(lines[0], contains('bleeding'));
      expect(lines[1], contains('headache'));
      expect(lines[2], contains('moving less'));
      expect(lines[3], contains('fever'));
      expect(lines[4], contains('water'));
    });

    test('the footer says a list is not a permission slip', () {
      // The brief asks for it in so many words. The clause that matters most is
      // the last one — a list of five without it reads as licence to ignore a
      // sixth thing.
      expect(kSameDayFooter.toLowerCase(), contains('never replaces'));
      expect(kSameDayFooter.toLowerCase(), contains('call anyway'));
    });

    test('the flag carries every sign, and each line keeps its page', () {
      final flag = pvDoorPageFor('pregnancy_complications')!
          .groups
          .firstWhere((g) => g.id == kCondTabHelp)
          .pinnedRedFlag!;
      expect(flag.lines.length, kSameDaySigns.length);
      for (final line in flag.lines) {
        expect(line.conditionId, isNotNull,
            reason: '"${line.text}" is on the same-day list and opens '
                'nothing. The brief: "Each line opens the fuller page."');
      }
    });

    test('the pregnancy flag has no per-line targets, and that is right', () {
      // These are symptoms of a pregnancy rather than of a named condition.
      // Bleeding does not have "a page"; the flag as a whole has the screen.
      for (final line in kPregnancyUrgentFlag.lines) {
        expect(line.conditionId, isNull);
      }
    });
  });

  group('linking across the two libraries', () {
    test('the two finding tiles point at findings that exist', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.finding) {
          continue;
        }
        expect(kReportFindings.any((f) => f.id == t.entryId), isTrue,
            reason: '"${t.title}" points at finding "${t.entryId}".');
      }
    });

    test('and they are the two Complications does not own', () {
      // ⚠️ THE RULE THIS GUARDS IS `docs/PREGNANCY-DOOR-BUILD.md` §4a: one page
      // per QUESTION, not one page per word. A finding tile is legitimate ONLY
      // where no condition page answers the same question — otherwise it is the
      // second copy the brief forbids, wearing a different class name.
      final linked = [
        for (final t in door.allTiles)
          if (t is PvDoorEntryTile && t.library == PvDoorLibrary.finding)
            t.entryId,
      ];
      expect(linked, ['low_lying_placenta', 'nuchal_cord']);
      for (final id in linked) {
        expect(kAllConditions.any((c) => c.id == id), isFalse,
            reason: '$id now exists as a condition too. Either point the tile '
                'at it, or record in §4a why both answers are needed.');
      }
    });

    test('every condition tile points at a condition that exists', () {
      for (final t in door.allTiles) {
        if (t is! PvDoorEntryTile || t.library != PvDoorLibrary.condition) {
          continue;
        }
        expect(kAllConditions.any((c) => c.id == t.entryId), isTrue,
            reason: '"${t.title}" points at "${t.entryId}".');
      }
    });
  });

  group('the checklist system', () {
    test('ids are unique across every checklist', () {
      final ids = kPvChecklists.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('item ids are unique within a checklist', () {
      // ⚠️ THEY ARE PERSISTED, so a duplicate makes two rows tick together —
      // which looks like a rendering bug and is a data one.
      for (final list in kPvChecklists) {
        final ids = list.items.map((i) => i.id).toList();
        expect(ids.toSet().length, ids.length, reason: '${list.id} repeats an id');
      }
    });

    test('every item is phrased as a question', () {
      for (final list in kPvChecklists) {
        for (final i in list.items) {
          expect(i.text.trim().endsWith('?'), isTrue,
              reason: '${list.id}: "${i.text}" is not a question.');
        }
      }
    });

    test('the scans checklist kept its id and its item ids', () {
      // ⚠️ THE MIGRATION'S ONE HARD REQUIREMENT. `PvChecklistStore` keys the
      // scans list on its original `scan_questions_ticked` preference, so
      // anybody mid-list keeps their ticks. Changing an id here empties a
      // checklist silently, and an emptied checklist looks exactly like one
      // never used.
      expect(kScanQuestionsChecklist.id, 'scan_questions');
      final ids = kScanQuestionsChecklist.items.map((i) => i.id).toSet();
      for (final id in [
        'prep_fast',
        'scan_what_for',
        'rep_when',
        'next_call'
      ]) {
        expect(ids, contains(id));
      }
    });

    test('every checklist a door names actually resolves', () {
      final c = PregnancyController();
      for (final t in kPvDoorPages.expand((d) => d.allTiles)) {
        if (t is! PvDoorChecklistTile) continue;
        expect(pvDoorScreenFor(t.surfaceId, c), isNotNull,
            reason: '"${t.title}" opens nothing.');
      }
    });
  });
}
