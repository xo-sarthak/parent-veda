// =============================================================================
//  The eleven parenting sections — the house rules, as tests
// -----------------------------------------------------------------------------
//  ⚠️ THESE TESTS EXIST BECAUSE ELEVEN SECTIONS WERE BUILT IN PARALLEL, and the
//  failures that produces are not the failures a single author produces.
//
//  A lone author drifts slowly. Eleven authors working from one spec template
//  drift instantly and invisibly: one writes em dashes, one forgets a band tag,
//  one leaves an area with no pages, one names an area "Behaviour articles"
//  instead of asking a question. Every one of those compiles, renders, and looks
//  fine on the screen the author was looking at.
//
//  So the shared rules are asserted over DATA, across every section at once. That
//  is the payoff of the block model in `pp_content.dart`: "no page is one
//  undifferentiated paragraph" is a property you can check, not a reading you
//  have to do eleven times.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_screen.dart';

/// Every page in every section, tagged with its section, so a failure message can
/// say which file to open.
Iterable<(PpSection, PpArea, PpPage)> _allPages() sync* {
  for (final s in kPpSections) {
    for (final a in s.areas) {
      for (final p in a.pages) {
        yield (s, a, p);
      }
    }
  }
}

/// Every user-visible string in a block. Kept in one place because a rule
/// checked on titles but not on card lines is a rule with a hole in it.
Iterable<String> strings(PpBlock b) {
  if (b is PpIntro) return [b.text];
  if (b is PpArticle) return [?b.heading, ...b.paragraphs];
  if (b is PpSteps) {
    return [
      ?b.heading,
      for (final s in b.steps) ...[s.title, ?s.detail],
    ];
  }
  if (b is PpCards) {
    return [
      ?b.heading,
      for (final c in b.cards) ...[c.title, c.line],
    ];
  }
  if (b is PpTable) {
    return [?b.heading, ...b.columns, for (final r in b.rows) ...r];
  }
  if (b is PpChartCard) {
    return [
      b.title,
      ?b.subtitle,
      ?b.note,
      for (final (l, v) in b.rows) ...[l, v],
    ];
  }
  if (b is PpCallout) return [?b.title, b.text];
  if (b is PpScript) {
    return [
      ?b.heading,
      for (final l in b.lines) ...[l.say, ?l.notThis, ?l.why],
    ];
  }
  if (b is PpWhenLine) return [b.text];
  if (b is PpIndiaNote) return [b.text];
  if (b is PpVideoSlot) return [b.title, ?b.subtitle];
  if (b is PpAudioSlot) return [b.title];
  if (b is PpLink) return [b.label, ?b.blurb];
  if (b is PpConsult) return [b.title, b.whoFor];
  return const [];
}

void main() {
  group('every section is reachable and matched to a real door', () {
    // ⚠️ THE WIRING GATE. Correct-but-unreachable content is this repo's
    // repeated failure, and eleven parallel builds is the ideal condition for it.
    test('every registered section is registered once', () {
      // ⚠️ NOT A FIXED COUNT. It was `expect(kPpSections.length, 10)`, written
      // when eleven sections were expected to land together. Five landed; five
      // are owed and named in `kPpSectionsOwed`. A hardcoded total would now
      // fail for a reason that has nothing to do with correctness, and worse, it
      // would go green again the moment someone registered a stub -- rewarding
      // exactly the filler the specs forbid.
      //
      // What actually matters is that the accounting is complete, and that is
      // asserted by "every bracket has a section, or is named as owed, or is
      // named as deliberately sectionless" below.
      expect(kPpSections, isNotEmpty);
      final ids = [for (final s in kPpSections) s.id];
      expect(ids.toSet().length, ids.length);
      expect(kPpSectionlessBrackets, contains('parenting_buying'),
          reason: 'What to Buy is the commerce IA, not a content section');
    });

    test('an owed section is not also a registered one', () {
      for (final id in kPpSectionsOwed) {
        expect(ppSectionFor(id), isNull,
            reason: '"$id" is registered but still listed as owed');
      }
    });

    test('every section id is a real parenting bracket', () {
      final brackets = {for (final h in kParentingHubs) h.bracketId};
      for (final s in kPpSections) {
        expect(brackets, contains(s.id),
            reason: '"${s.id}" is not a bracket in parenting_hubs.dart, so no '
                'door can ever open it');
      }
    });

    test('and no two sections claim the same bracket', () {
      final ids = [for (final s in kPpSections) s.id];
      expect(ids.toSet().length, ids.length, reason: 'duplicate bracket id');
    });

    test('every parenting bracket has a section or is named as sectionless', () {
      // The four-state distinction the bracket model exists to preserve:
      // "deliberately elsewhere" must not be indistinguishable from "forgotten".
      for (final h in kParentingHubs) {
        final has = ppSectionFor(h.bracketId) != null;
        final excused = kPpSectionlessBrackets.contains(h.bracketId) ||
            kPpSectionsOwed.contains(h.bracketId);
        expect(has || excused, isTrue,
            reason: 'bracket "${h.bracketId}" has no section and is named '
                'neither as owed nor as deliberately sectionless — is it '
                'forgotten or deliberate?');
      }
    });
  });

  group('no section has a hole in it', () {
    test('every area has pages or is a tool', () {
      for (final s in kPpSections) {
        for (final a in s.areas) {
          expect(a.pages.isNotEmpty || a.toolSurfaceId != null, isTrue,
              reason: '${s.id} / ${a.id} has no pages and is not a tool, so '
                  'tapping it does nothing');
        }
      }
    });

    test('every page has blocks', () {
      for (final (s, a, p) in _allPages()) {
        expect(p.blocks, isNotEmpty,
            reason: '${s.id} / ${a.id} / ${p.id} renders an empty screen');
      }
    });

    test('every section has areas and an intro', () {
      for (final s in kPpSections) {
        expect(s.areas, isNotEmpty, reason: '${s.id} has no areas');
        expect(s.intro.trim(), isNotEmpty, reason: '${s.id} has no intro line');
        expect(s.title.trim(), isNotEmpty);
      }
    });

    test('page and area ids are unique within their section', () {
      for (final s in kPpSections) {
        final areaIds = [for (final a in s.areas) a.id];
        expect(areaIds.toSet().length, areaIds.length,
            reason: '${s.id} has duplicate area ids');
        final pageIds = [for (final p in s.allPages) p.id];
        expect(pageIds.toSet().length, pageIds.length,
            reason: '${s.id} has duplicate page ids, so pageById is ambiguous');
      }
    });
  });

  group('the copy rules every spec shares', () {
    // ⚠️ "No em dashes anywhere in UI copy" appears in every one of the eleven
    // specs. It is the single easiest rule to break by habit and the single
    // easiest to check, which is exactly why it is here rather than in a review
    // checklist.
    test('no em dashes anywhere', () {
      final bad = <String>[];
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          for (final str in strings(b)) {
            if (str.contains('—')) {
              bad.add('${s.id}/${p.id}: ${str.substring(0, str.length.clamp(0, 70))}');
            }
          }
        }
      }
      expect(bad, isEmpty, reason: 'em dashes found:\n${bad.join('\n')}');
      for (final s in kPpSections) {
        expect(s.intro.contains('—'), isFalse, reason: '${s.id} intro');
      }
    });

    test('no lorem, no TODO, no placeholder prose', () {
      const banned = ['lorem', 'ipsum', 'todo:', 'tbd', 'xxx', 'placeholder text'];
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          for (final str in strings(b)) {
            final low = str.toLowerCase();
            for (final w in banned) {
              expect(low.contains(w), isFalse,
                  reason: '${s.id}/${p.id} contains "$w": $str');
            }
          }
        }
      }
    });

    // ⚠️ THE RULE THE BLOCK MODEL WAS BUILT TO MAKE CHECKABLE: "do not render any
    // page as one long undifferentiated paragraph". A paragraph past this length
    // is a wall of text whatever the block type says.
    test('no paragraph is a wall of text', () {
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          if (b is PpArticle) {
            for (final para in b.paragraphs) {
              expect(para.length, lessThan(900),
                  reason: '${s.id}/${p.id} has a ${para.length}-char paragraph; '
                      'split it');
            }
          }
        }
      }
    });

    test('every page opens with an intro', () {
      // The page template every spec specifies starts with "a short warm intro
      // (2 to 3 lines)". A page that opens straight into steps has skipped the
      // part that tells her whether she is in the right place.
      for (final (s, _, p) in _allPages()) {
        expect(p.blocks.first, isA<PpIntro>(),
            reason: '${s.id}/${p.id} does not open with a PpIntro');
      }
    });

    test('an area title reads as a question or an action, not a mechanism', () {
      // From the First 40 Days spec, applied to all of them: "Never ship an
      // engineer label like 'activities', 'tracker' or 'module' as a user-facing
      // name." Checked on area titles because those are the labels a parent
      // actually scans.
      const mechanismWords = [
        'module',
        'tracker',
        'content',
        'articles',
        'section',
        'data',
        'engine',
        'library',
      ];
      final bad = <String>[];
      for (final s in kPpSections) {
        for (final a in s.areas) {
          final low = a.title.toLowerCase();
          for (final w in mechanismWords) {
            if (low.contains(w)) bad.add('${s.id}/${a.id}: "${a.title}" ($w)');
          }
        }
      }
      expect(bad, isEmpty,
          reason: 'area titles naming our mechanism rather than her question:\n'
              '${bad.join('\n')}');
    });
  });

  group('the safety rules', () {
    // ⚠️ A DOCTOR CALLOUT IS NOT DECORATION. Where a spec asks for one it is
    // because the page covers something that can be serious, and "visible and not
    // buried" was stated explicitly. This asserts the app has a real number of
    // them rather than one token callout per section.
    test('doctor callouts exist across the sections', () {
      var total = 0;
      for (final (_, _, p) in _allPages()) {
        total += p.blocks
            .whereType<PpCallout>()
            .where((c) => c.kind == PpCalloutKind.doctor)
            .length;
      }
      expect(total, greaterThan(20),
          reason: 'only $total doctor callouts across ten sections — the '
              'clinical routing is thinner than the specs require');
    });

    test('a page that raises a clinical worry names someone to go to', () {
      // The specs are anti-anxiety before they are anything else. A page that
      // names a symptom and stops has raised the fear and given her nowhere to
      // put it.
      //
      // ⚠️ CHECKED PER PAGE, NOT PER CALLOUT, AND THAT IS A CORRECTION.
      //
      // This asserted it of every individual callout and failed on a page that
      // was actually right: `dev_speech_flags` lists six age-banded callouts
      // under a heading that already routes to a paediatrician. Forcing each of
      // the six to repeat "see your paediatrician" would have made the copy
      // worse in order to satisfy the test, which is the wrong way round.
      //
      // The guarantee that matters is that she is never left holding a worry
      // with nowhere to take it, and that is a property of the PAGE. A callout
      // is not read alone; a page is.
      const routes = [
        'doctor',
        'paediatrician',
        'pediatrician',
        'hospital',
        'clinic',
        'physio',
        'nurse',
        'emergency',
        'therapist',
        'call',
      ];
      for (final (s, _, p) in _allPages()) {
        final hasDoctorCallout = p.blocks
            .whereType<PpCallout>()
            .any((c) => c.kind == PpCalloutKind.doctor);
        if (!hasDoctorCallout) continue;
        final all =
            [for (final b in p.blocks) ...strings(b)].join(' ').toLowerCase();
        expect(routes.any(all.contains), isTrue,
            reason: '${s.id}/${p.id} raises a clinical worry and names nobody '
                'to take it to');
      }
    });

    // ⚠️ NO GAMIFICATION appears in every spec, and the specific words are the
    // ones that creep in: streak, score, badge, points.
    test('nothing in the copy offers a streak, a score or a badge', () {
      // ⚠️ THE BAN IS ON THE PRACTICE, NOT THE WORD, AND THE FIRST VERSION OF
      // THIS TEST GOT THAT WRONG.
      //
      // It banned the substring "streak" and duly failed on
      // `parenting_first_40/f40_light_check`, whose copy reads "There is no
      // score here, no streak, and nothing that..." -- a page promising the
      // exact opposite of gamification, failing the anti-gamification test.
      //
      // A word-level ban cannot tell a promise from a threat. So a negated
      // mention passes and only an unnegated one fails. The general lesson is
      // worth keeping: a test that bans vocabulary punishes the copy that talks
      // about the thing most explicitly, which is usually the best copy.
      //
      // It also now reads EVERY string rather than only intros and callouts,
      // which is the hole the first version had in the other direction.
      // 'you missed' was here and caught `parenting_potty/reading_signals`:
      // "Notice what you missed, later" -- a line about a missed su-su cue,
      // not a scolding. The gamifying phrase is 'you missed a day'; the two
      // words alone are ordinary English.
      // ⚠️ PHRASES, NOT WORDS. Plain 'streak' also matched a You, Maa line
      // about "a lot of fresh blood rather than streaks", which is a clinical
      // description and the opposite of a game mechanic. Every entry here is a
      // phrase that can only mean gamification.
      const banned = [
        'day streak',
        'keep your streak',
        'streak of days',
        'badge',
        'leaderboard',
        'you missed a day',
        'points for',
      ];
      const negations = ['no ', 'not ', 'never ', 'without ', 'nothing '];
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          for (final raw in strings(b)) {
            final low = raw.toLowerCase();
            for (final w in banned) {
              var from = 0;
              while (true) {
                final at = low.indexOf(w, from);
                if (at == -1) break;
                final start = at < 24 ? 0 : at - 24;
                final negated = negations.any(low.substring(start, at).contains);
                expect(negated, isTrue,
                    reason: '${s.id}/${p.id} offers "$w": $raw');
                from = at + w.length;
              }
            }
          }
        }
      }
    });
  });

  group('age banding narrows what leads, never what exists', () {
    test('every band tag on a page is a real band in its section', () {
      // A typo'd band id silently hides a page from every band — it renders
      // nowhere and nothing fails. This is the only way to catch it.
      for (final s in kPpSections) {
        final set = s.bandSet;
        if (set == null) continue;
        final known = {for (final b in set.bands) b.id};
        for (final a in s.areas) {
          for (final tag in a.bands) {
            expect(known, contains(tag),
                reason: '${s.id}/${a.id} is tagged to band "$tag", which does '
                    'not exist — the area renders in no band at all');
          }
          for (final p in a.pages) {
            for (final tag in p.bands) {
              expect(known, contains(tag),
                  reason: '${s.id}/${a.id}/${p.id} is tagged to unknown band '
                      '"$tag"');
            }
          }
        }
      }
    });

    test('every band of every section shows at least one area', () {
      // The failure every spec independently described: "a parent of a
      // 3-month-old never sees an empty tantrum library". An empty band is that
      // failure, and it is invisible unless you open the app as that parent.
      for (final s in kPpSections) {
        final set = s.bandSet;
        if (set == null) continue;
        for (final band in set.bands) {
          final areas = s.areas.where((a) => a.inBand(band.id)).toList();
          expect(areas, isNotEmpty,
              reason: '${s.id} band "${band.id}" (${band.label}) has no areas');
          final pages = areas.expand((a) => a.pagesFor(band.id)).toList();
          final tools = areas.where((a) => a.toolSurfaceId != null).length;
          expect(pages.isNotEmpty || tools > 0, isTrue,
              reason: '${s.id} band "${band.id}" has areas but nothing in them');
        }
      }
    });

    test('bands do not overlap and leave no gap', () {
      for (final s in kPpSections) {
        final set = s.bandSet;
        if (set == null) continue;
        final bands = set.bands;
        for (var i = 0; i < bands.length - 1; i++) {
          expect(bands[i].toMonths, bands[i + 1].fromMonths,
              reason: '${s.id}: "${bands[i].id}" ends at ${bands[i].toMonths} '
                  'and "${bands[i + 1].id}" starts at '
                  '${bands[i + 1].fromMonths} — a child falls in two bands or '
                  'in none');
        }
        expect(bands.first.fromMonths, 0,
            reason: '${s.id} first band does not start at birth');
      }
    });
  });

  group('slots and links are declared honestly', () {
    test('every video and audio slot has a slot id', () {
      // The slot id is the wiring, declared at the moment the placeholder is
      // created rather than worked out again when the file arrives.
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          if (b is PpVideoSlot) {
            expect(b.slotId.trim(), isNotEmpty,
                reason: '${s.id}/${p.id} video "${b.title}" has no slot id');
          }
          if (b is PpAudioSlot) {
            expect(b.slotId.trim(), isNotEmpty,
                reason: '${s.id}/${p.id} audio "${b.title}" has no slot id');
          }
        }
      }
    });

    test('one slot id always means one video, wherever it appears', () {
      // ⚠️ THIS ASSERTED GLOBAL UNIQUENESS AND THAT WAS THE WRONG RULE.
      //
      // It failed on `feeding/latch_demo`, used by both the First 40 Days latch
      // page and the Feeding latch page. Those are two placements of ONE video,
      // which is correct and desirable: a slot id is a FILE's identity, not a
      // position on a page, and the same explainer genuinely belongs in both
      // places. Forcing unique ids there would have meant either shooting the
      // video twice or arbitrarily deleting it from one of the two pages that
      // needs it.
      //
      // The real bug the rule was reaching for is two DIFFERENT videos sharing
      // an id, because then one file lands and the other silently never does.
      // So the check is now consistency of title, not uniqueness of id.
      final titles = <String, String>{};
      final where = <String, String>{};
      for (final (s, _, p) in _allPages()) {
        for (final b in p.blocks) {
          final (id, title) = switch (b) {
            PpVideoSlot v => (v.slotId, v.title),
            PpAudioSlot a => (a.slotId, a.title),
            _ => (null, null),
          };
          if (id == null || title == null) continue;
          final seen = titles[id];
          if (seen == null) {
            titles[id] = title;
            where[id] = '${s.id}/${p.id}';
            continue;
          }
          expect(title, seen,
              reason: 'slot "$id" is two different things: "$seen" in '
                  '${where[id]} and "$title" in ${s.id}/${p.id}');
        }
      }
    });

    test('every pageId link points at a page in its own section', () {
      // ⚠️ A `pageId` LINK IS RESOLVED AGAINST ITS OWN SECTION AT RENDER TIME, so
      // a typo'd or cross-section id silently does nothing when tapped. That is
      // the failure this catches, and it is the one that cannot be seen by
      // reading the file: the id looks fine, the row renders fine, and only the
      // tap is wrong.
      for (final s in kPpSections) {
        final ids = {for (final p in s.allPages) p.id};
        for (final p in s.allPages) {
          for (final b in p.blocks.whereType<PpLink>()) {
            final target = b.pageId;
            if (target == null) continue;
            expect(ids, contains(target),
                reason: '${s.id}/${p.id} links to page "$target", which is not '
                    'in this section');
          }
        }
      }
    });

    test('every consult block names who it is for', () {
      // Required by every spec that surfaces the paid layer, because the
      // alternative sells to the parent whose problem the page above just solved.
      for (final (s, _, p) in _allPages()) {
        for (final c in p.blocks.whereType<PpConsult>()) {
          expect(c.whoFor.trim().length, greaterThan(20),
              reason: '${s.id}/${p.id} consult has no real "who this is for" '
                  'line');
          expect(c.surfaceId.trim(), isNotEmpty);
        }
      }
    });
  });
}
