// =============================================================================
//  The Labour prep door: tools first, safety in her voice
// -----------------------------------------------------------------------------
//  The reachability gates live in `pv_door_scans_test.dart`, which walks
//  `kPvDoorPages`; this door inherited them on registration.
//
//  What is here is the three things this brief adds that no other has:
//
//    · **The voice rule.** It names two lines and gives their replacements, and
//      it is entirely a property of strings — nothing about a legal-notice
//      disclaimer fails to compile.
//    · **Tools-first ordering.** The default tab is a timer because near the
//      due date somebody opens a tool, not a read.
//    · **What is owed.** This area promises more than it has written. The
//      coming-soon cards are the honest treatment, and a card that quietly
//      became tappable without content behind it would be the failure.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  late PvDoorPage door;
  setUp(() => door = pvDoorPageFor('pregnancy_labour')!);

  group('tools first', () {
    test('seven sub-tabs, the timer first', () {
      // ⚠️ THE ORDERING IS THE BRIEF'S ARGUMENT, NOT A PREFERENCE: "near the
      // due date people open a tool, not a read."
      //
      // Seven since 2026-09-29: the pregnancy gap analysis asked for "Signs
      // and stages" (P1, beside the timer) and "Feeding and first days" (P2).
      // The timer is still first.
      expect(door.groups.length, 7);
      expect(door.groups.first.id, kLabourTabTimer);
      expect(door.groups.map((g) => g.label), [
        'Contraction timer',
        'Signs and stages',
        'Hospital bag',
        'Understand the birth',
        'Feeding and first days',
        'For your partner',
        'Talk and learn',
      ]);
    });

    test('sub-tabs 1 and 2 are not rails', () {
      // The brief's DO NOT list says so by name.
      for (final id in [kLabourTabTimer, kLabourTabBag]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.stack);
      }
    });

    test('every other sub-tab is a rail', () {
      for (final id in [
        kLabourTabSigns,
        kLabourTabBirth,
        kLabourTabFeeding,
        kLabourTabPartner,
        kLabourTabTalk,
      ]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.layout, PvDoorLayout.rails);
      }
    });

    test('the timer is the first card on the first tab', () {
      // ⚠️ ONE TAP FROM OPENING THE DOOR, WHICH IS THE POINT OF THE ORDER. If
      // anything is ever added above it, somebody in early labour scrolls.
      final first = door.sectionsOf(kLabourTabTimer).first.tiles.first;
      expect(first, isA<PvDoorToolTile>());
      expect((first as PvDoorToolTile).surfaceId, kLabourSurfaceTimer);
    });

    test('neither tool is embedded, and that is deliberate', () {
      // ⚠️ THE ONE DELIBERATE DEVIATION FROM THIS ENGINE'S OWN RULE. Every
      // other tool tab renders its tool in place; these two do not, because a
      // live timer with save-on-pop and a packer with a pinned alert bar both
      // lose real behaviour inside somebody else's scroll. The reasoning is in
      // `pv_door_labour.dart`; this holds the decision so it is not "tidied"
      // back by someone reading only the rule.
      for (final id in [kLabourTabTimer, kLabourTabBag]) {
        final g = door.groups.firstWhere((g) => g.id == id);
        expect(g.inlineSurfaceId, isNull,
            reason: '${g.label} embeds a tool that owns its screen — see the '
                'note in pv_door_labour.dart before changing this.');
      }
    });
  });

  group('the voice rule', () {
    test('the timer disclaimer speaks to her, in both languages', () {
      // ⚠️ THE BRIEF NAMES THIS LINE AND GIVES THE REPLACEMENT. Both sides
      // moved together: a rewritten English beside a stale Hindi would leave
      // the Hindi build carrying the legal framing on a safety notice.
      final en = S(AppLanguage.english);
      final hi = S(AppLanguage.hinglish);

      expect(en.ctDisclaimerTitle,
          "We can't tell you if it's labour, but your doctor can");
      expect(en.ctDisclaimerTitle.toLowerCase(),
          isNot(contains('not a diagnosis')));

      // The corporate opening is gone from both, and the safety is not.
      expect(en.ctDisclaimerBody, isNot(contains('is not a medical')));
      expect(hi.ctDisclaimerBody, isNot(contains('डायग्नोस्टिक सेवा')));
      expect(en.ctDisclaimerBody, contains('Only your doctor or midwife can'));
      expect(en.ctDisclaimerBody,
          contains('even if the pattern here looks calm'));

      // And the Hindi is Devanagari, not Latin-script Hindi.
      expect(hi.ctDisclaimerTitle, isNot(equals(en.ctDisclaimerTitle)));
      expect(RegExp(r'[ऀ-ॿ]').hasMatch(hi.ctDisclaimerTitle), isTrue,
          reason: 'the Hindi title must be Devanagari');
    });

    test('both safety notes are on the door, and they differ', () {
      // The brief gives two different lines — one about what a timer cannot
      // tell her, one about calling anyway. Using one for both would drop half
      // of what it asked for.
      final timer =
          door.groups.firstWhere((g) => g.id == kLabourTabTimer).note;
      final talk = door.groups.firstWhere((g) => g.id == kLabourTabTalk).note;
      expect(timer, isNotNull);
      expect(talk, isNotNull);
      expect(timer, isNot(equals(talk)));
      expect(timer!, contains("can't tell you if it's labour"));
      expect(talk!, contains('even if this screen looks calm'));
    });

    test('they are notes, not red flags', () {
      // A safety caution is not an emergency. The flag treatment is coral and
      // urgent; spending it here would spend an alarm on a standing note.
      for (final g in door.groups) {
        expect(g.pinnedRedFlag, isNull);
      }
    });

    test('nothing on this door reads like a notice', () {
      const corporate = [
        'parentveda is not',
        'not a medical or diagnostic',
        'terms and conditions',
        'shall not be liable',
        'for informational purposes',
      ];
      final strings = <String>[
        door.heroTitle,
        door.heroBlurb,
        ?door.closingLine,
        for (final g in door.groups) ...[g.label, ?g.note],
        for (final s in door.sections) s.heading,
        for (final t in door.allTiles) ...[t.title, t.blurb],
      ];
      for (final s in strings) {
        for (final phrase in corporate) {
          expect(s.toLowerCase(), isNot(contains(phrase)),
              reason: '"$s" reads like a notice.');
        }
      }
    });

    test('no bare jargon in a heading or a card we wrote', () {
      // "C-section" is kept — the brief says so, people know it. "Braxton
      // Hicks" is not: the brief allows it ONLY as a linked page title in
      // Complications, never as a label we write.
      final ours = <String>[
        for (final g in door.groups) g.label,
        for (final s in door.sections) s.heading,
        for (final t in door.allTiles) ...[t.title, t.blurb],
      ];
      for (final s in ours) {
        expect(s.toLowerCase(), isNot(contains('braxton')),
            reason: '"$s" names Braxton Hicks as a label we wrote.');
      }
    });
  });

  group('what is owed is owed honestly', () {
    test('every coming-soon card opens nothing', () {
      for (final t in door.allTiles) {
        if (!t.comingSoon) continue;
        expect(t, isNot(isA<PvDoorToolTile>()),
            reason: '"${t.title}" says coming soon and is a tool.');
        if (t is PvDoorReadTile) expect(t.surfaceId, isNull);
      }
    });

    test('the videos are marked, not faked', () {
      // The four owed reads were written on 2026-09-29 and now open real
      // reads; the two films are still owed and still say so.
      final soon = [for (final t in door.allTiles) if (t.comingSoon) t.title];
      expect(soon, containsAll(<String>[
        'The contraction timer, in two minutes',
        'Labour, start to finish',
      ]));
    });

    test('the four reads that were owed are written, and open', () {
      for (final title in [
        'If it becomes a C-section',
        'The first hour after birth',
        'What your partner should do',
        'What labour is like, and your options',
      ]) {
        final t = door.allTiles.firstWhere((t) => t.title == title);
        expect(t, isA<PvDoorGuideTile>(), reason: title);
        expect(t.comingSoon, isFalse, reason: title);
        expect(pregnancyReadById((t as PvDoorGuideTile).readId), isNotNull,
            reason: title);
      }
    });

    test('the birth-plan card is present, and it is a tool', () {
      // ⚠️ THIS TEST USED TO ASSERT THE OPPOSITE. The brief asked for the card
      // and `pregnancy_journeys` had removed the step because the tool did not
      // exist, so the door omitted it and recorded the conflict (STILL-OPEN
      // §37.3). On 2026-09-11 the user decided: build it. The tool now exists
      // and the card is a TOOL, not a guide — she needs somewhere to write it
      // down, not another thing to read. `birth_plan_test.dart` holds the tool.
      final tile =
          door.allTiles.firstWhere((t) => t.title == 'Your birth plan');
      expect(tile, isA<PvDoorToolTile>());
      expect(tile.comingSoon, isFalse);
    });

    test("the door's own reads, and every guide opens one that exists", () {
      // Was "only one read is new": true until 2026-09-29, when the gap
      // analysis asked for the birth itself to be written.
      final reads = {
        for (final r in kPregnancyReads)
          if (r.id.startsWith('preg_labour_')) r.id,
      };
      expect(reads, {
        'preg_labour_read_pain_relief',
        'preg_labour_read_c_section',
        'preg_labour_read_first_hour',
        'preg_labour_read_options',
        'preg_labour_read_partner',
        'preg_labour_read_signs_near',
        'preg_labour_read_waters',
        'preg_labour_read_when_to_go',
        'preg_labour_read_preterm',
        'preg_labour_read_stages',
        'preg_labour_read_pushing_placenta',
        'preg_labour_read_induction',
        'preg_labour_read_past_due',
        'preg_labour_read_vbac',
        'preg_labour_read_tears',
        'preg_labour_read_bf_start',
        'preg_labour_read_colostrum',
        'preg_labour_read_golden_hour_feed',
        'preg_labour_read_feeding_help',
        'preg_labour_read_first_40',
      });

      for (final t in door.allTiles) {
        if (t is! PvDoorGuideTile) continue;
        expect(pregnancyReadById(t.readId), isNotNull, reason: t.title);
      }
    });

    test('every read written for this door is on it', () {
      // The wiring gate: a read nobody can reach is the failure this repo
      // has hit before.
      final onDoor = {
        for (final t in door.allTiles)
          if (t is PvDoorGuideTile) t.readId,
      };
      for (final r in kPregnancyReads) {
        if (!r.id.startsWith('preg_labour_')) continue;
        expect(onDoor, contains(r.id), reason: '${r.id} is on no tile.');
      }
    });

    test('the timings guide lands on a heading that exists', () {
      final t = door.allTiles.firstWhere((t) => t.title == 'What the timings mean')
          as PvDoorGuideTile;
      final r = pregnancyReadById(t.readId)!;
      expect(r.toc.map((h) => h.en), contains(t.atHeading));
    });

    test('the timer sits beside the signs', () {
      // The brief: "with our contraction timer beside it".
      final tools = [
        for (final s in door.sectionsOf(kLabourTabSigns))
          for (final t in s.tiles)
            if (t is PvDoorToolTile) t.surfaceId,
      ];
      expect(tools, contains(kLabourSurfaceTimer));
    });
  });

  group('single source, three times', () {
    test('the practice-contractions page is linked, not restated', () {
      final tile = door.allTiles.firstWhere(
          (t) => t is PvDoorEntryTile && t.library == PvDoorLibrary.finding);
      expect((tile as PvDoorEntryTile).entryId, 'braxton_hicks');
      expect(pvDoorEntryResolves(tile.library, tile.entryId), isTrue);
    });

    test('the partner class opens the course, not a second video', () {
      final tile = door.allTiles
          .firstWhere((t) => t.title == 'Your partner as birth support');
      expect((tile as PvDoorToolTile).surfaceId, kLabourSurfaceCourse);
    });

    test('the partner packing list opens the bag, not a second list', () {
      final tile = door.allTiles.firstWhere(
          (t) => t.title == 'What to pack for whoever comes with you');
      expect((tile as PvDoorToolTile).surfaceId, kLabourSurfaceBag);
    });

    test('all six classes exist behind the course card', () {
      // ⚠️ THE CARD PROMISES SIX AND THE PRICE. Both are read off
      // `kBirthingClasses` and `prepare_data.dart` rather than retyped, so this
      // asserts the promise still matches the data.
      expect(kBirthingClasses.length, 6);
      expect(kBirthingClasses.first.free, isTrue,
          reason: 'the card says the first class is free.');
      final titles = kBirthingClasses.map((c) => c.title.en).toList();
      expect(titles[4], contains('partner'));
      expect(titles[5].toLowerCase(), contains('golden hour'));
    });

    test('the course card names the price on its face', () {
      // This app's rule: a tile that costs money is legible as such BEFORE she
      // taps. A shop tile that looks like an article is a dark pattern whether
      // or not anyone meant it that way.
      final tile =
          door.allTiles.firstWhere((t) => t.title == 'Complete Birthing Course');
      expect(tile.blurb, contains('₹1,499'));
    });
  });

  group('every surface builds', () {
    test('each one a tile names', () {
      final c = PregnancyController();
      for (final t in door.allTiles) {
        final id = switch (t) {
          PvDoorToolTile(:final surfaceId) => surfaceId,
          PvDoorTalkTile(:final surfaceId) => surfaceId,
          PvDoorChecklistTile(:final surfaceId) => surfaceId,
          _ => null,
        };
        if (id == null) continue;
        expect(pvDoorScreenFor(id, c), isNotNull,
            reason: '"${t.title}" opens nothing.');
      }
    });
  });
}
