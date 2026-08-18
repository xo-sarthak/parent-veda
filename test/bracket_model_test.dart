// =============================================================================
//  The bracket model's four guarantees
// -----------------------------------------------------------------------------
//  These are the gate described in docs/BRACKET-AUDIT.md, expressed as tests.
//  Each one exists because of a specific way this could fail silently.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/brackets/parenting_brackets.dart';
import 'package:parentveda/data/brackets/pregnancy_brackets.dart';
import 'package:parentveda/data/brackets/skilling_brackets.dart';
import 'package:parentveda/data/brackets/ttc_brackets.dart';
import 'package:parentveda/screens/v2/v3_skill_art.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/services/app_structure.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/services/parenting_surfaces.dart';
import 'package:parentveda/services/ttc_surfaces.dart';
import 'package:parentveda/services/life_stage_store.dart';

void main() {
  group('the table is complete', () {
    // WHY: a bracket that omits a layer inherits whatever the reader assumes,
    // and the assumption people make is that it ships. Sixty-nine cells declared
    // and one forgotten is indistinguishable from sixty-nine declared and one
    // deliberately live — unless this test exists.
    test('every bracket declares all seven layers, with no defaulting', () {
      for (final b in kAllBrackets) {
        for (final l in BracketLayer.values) {
          expect(b.layers.containsKey(l), isTrue,
              reason: '${b.id} does not declare ${l.name} — '
                  'an undeclared layer is an accident waiting to be read as live');
        }
      }
    });

    test('ten brackets, seventy cells', () {
      expect(kPregnancyBrackets.length, 10);
      expect(
          kPregnancyBrackets.fold<int>(0, (n, b) => n + b.layers.length), 70);
    });

    test('every bracket carries a label, a title, a blurb and a theme', () {
      for (final b in kAllBrackets) {
        expect(b.label.en.trim(), isNotEmpty, reason: b.id);
        expect(b.title.en.trim(), isNotEmpty, reason: b.id);
        expect(b.blurb.en.trim(), isNotEmpty, reason: b.id);
        expect(b.theme.trim(), isNotEmpty, reason: b.id);
      }
    });

    // WHY: the app has two languages and this is its primary navigation. A
    // bracket shipped English-only would leave the Hindi build with untranslated
    // doors — and unlike a missing article, there is no way for her to route
    // around it.
    // ⚠️ THE ALLOWLIST IS THE POINT, NOT AN EXEMPTION.
    //
    // CLAUDE.md forbids `_t(x, x)` because an identical pair reads as finished
    // work to anything counting pairs — that is how `can_i_data` was once
    // reported done with 302 strings still in English. The convention for
    // genuinely-identical strings is `_same(...)`, a marker that says "identical
    // BY NATURE" out loud.
    //
    // `LocalizedText` has no `same` constructor, so the marker lives here
    // instead: three strings, named, each with the reason it cannot differ.
    // Adding a fourth should require a sentence, which is exactly the friction
    // this list exists to create.
    //
    // All three are TTC, and all three are Hinglish rather than Devanagari —
    // which is why they stay Latin. In Hinglish a clinical acronym and a term
    // she reads on a clinic form are written the same way in both languages;
    // there is no second spelling to give them.
    const identicalByNature = <String>{
      'PCOS', // an acronym; there is no other way to write it
      'Fertile window', // what the clinic itself says, in both languages
      'Male fertility', // ditto — a Hinglish speaker does not say a translation
    };

    test('every user-visible string has Hindi', () {
      for (final b in kAllBrackets) {
        for (final pair in [b.label, b.title, b.blurb]) {
          expect(pair.hi.trim(), isNotEmpty,
              reason: '${b.id}: "${pair.en}" has no Hindi');
          if (identicalByNature.contains(pair.en)) continue;
          expect(pair.hi, isNot(equals(pair.en)),
              reason: '${b.id}: "${pair.en}" is identical in both languages — '
                  'if that is genuinely correct it needs saying explicitly, '
                  'because an identical pair reads as finished work to every '
                  'audit that counts pairs');
        }
      }
    });
  });

  group('ids are stage-scoped, themes are not', () {
    // WHY: prenatal anxiety and postpartum depression are different subjects.
    // A shared id would carry a saved item across a stage transition into a
    // bracket whose material does not match it.
    test('every id is prefixed with its stage', () {
      for (final b in kPregnancyBrackets) {
        expect(b.id.startsWith('pregnancy_'), isTrue,
            reason: '${b.id} is not stage-scoped');
        expect(b.stage, LifeStage.pregnancy);
      }
    });

    test('ids are unique across every stage', () {
      final ids = kAllBrackets.map((b) => b.id).toSet();
      expect(ids.length, kAllBrackets.length);
    });

    test('parenting ids are stage-scoped too', () {
      for (final b in kParentingBrackets) {
        expect(b.id.startsWith('parenting_'), isTrue, reason: b.id);
        expect(b.stage, LifeStage.parenting);
      }
    });
  });

  group('live means live', () {
    // WHY: this is the gate the whole audit exists for. A `live` layer with
    // nothing behind it is worse than an absent one — it promises a section and
    // opens to nothing, which is the "correct but unreachable" failure this repo
    // has already hit and written a wiring gate for.
    test('every live layer names at least one surface', () {
      for (final b in kAllBrackets) {
        for (final l in b.liveLayers) {
          expect(b.layer(l).surfaceIds, isNotEmpty,
              reason: '${b.id} → ${l.name} claims to be live and points nowhere');
        }
      }
    });

    // ⚠️ EACH STAGE IS CHECKED AGAINST ITS OWN SURFACE LIST.
    //
    // The first version asked homeFor() for every bracket in the app, and the
    // moment parenting arrived it failed on all eleven — correctly, and for the
    // wrong reason. app_structure is pregnancy-shaped: its homes are today ·
    // prepare · tools · calendar · community, which is the pregnancy tab set.
    // Parenting's tabs are My Child · Brain · Tools · Community · Products.
    // Asking "which pregnancy tab owns this parenting screen" has no answer,
    // and null is indistinguishable from "this door opens nothing".
    //
    // The question that survives both stages is "does this open something".
    test('every pregnancy surface is declared in app_structure', () {
      for (final b in kPregnancyBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(homeFor(id), isNotNull,
              reason: '${b.id} points at "$id", which app_structure does not '
                  'declare — that door opens nothing');
        }
      }
    });

    test('every parenting surface is declared in parenting_surfaces', () {
      for (final b in kParentingBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(id.startsWith('pp_'), isTrue,
              reason: '${b.id} points at "$id" — parenting ids are pp_-prefixed '
                  'so they can never be mistaken for a pregnancy surface');
          expect(ppSurfaceLabel(id), isNotNull,
              reason: '${b.id} points at "$id", which parenting_surfaces does '
                  'not declare');
        }
      }
    });

    test('every TTC surface is declared in ttc_surfaces', () {
      for (final b in kTtcBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(id.startsWith('ttc_'), isTrue,
              reason: '${b.id} points at "$id" — TTC ids are ttc_-prefixed');
          expect(ttcSurfaceLabel(id, hinglish: false), isNotNull,
              reason: '${b.id} points at "$id", which ttc_surfaces does not '
                  'declare');
          // Both languages, because the stage runs in both and a row with a
          // label in one and nothing in the other is a hole only Hinglish users
          // would ever see.
          expect(ttcSurfaceLabel(id, hinglish: true), isNotNull,
              reason: '${b.id} → "$id" has no Hinglish label');
        }
      }
    });

    // ⚠️ THE WIRING GATE, FOR REAL. A declared label proves the surface is
    // KNOWN; only the router proves it OPENS. Pregnancy and parenting each have
    // one hub id that deliberately resolves to no single screen, so this is
    // asserted per-stage rather than globally — and for TTC every live surface
    // must open, because every one of them names a screen that already ships.
    test('every live TTC surface opens a real screen', () {
      for (final b in kTtcBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(ttcScreenForSurface(id), isNotNull,
              reason: '${b.id} → "$id" is declared and labelled but the router '
                  'opens nothing — the correct-but-unreachable failure this '
                  'repo has already shipped once');
        }
      }
    });

    test('no stage points at another stage surface', () {
      for (final b in kPregnancyBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(id.startsWith('pp_'), isFalse, reason: '${b.id} -> $id');
          expect(id.startsWith('ttc_'), isFalse, reason: '${b.id} -> $id');
        }
      }
      for (final b in kParentingBrackets) {
        for (final id in liveSurfaceIds(b)) {
          expect(id.startsWith('ttc_'), isFalse, reason: '${b.id} -> $id');
        }
      }
    });

    test('TTC ids are stage-scoped', () {
      for (final b in kTtcBrackets) {
        expect(b.id.startsWith('ttc_'), isTrue, reason: b.id);
        expect(b.stage, LifeStage.tryingToConceive);
      }
    });

    // ⚠️ SEVEN DOORS, NOT TEN OR ELEVEN. The workbook's PRECONCEPTION block has
    // exactly seven rows; a stage that grew an eighth door without the workbook
    // growing a row would mean someone invented a problem bracket, which is the
    // one thing the whole Level Map exists to stop.
    test('seven TTC brackets, forty-nine cells', () {
      expect(kTtcBrackets.length, 7);
      expect(kTtcBrackets.fold<int>(0, (n, b) => n + b.layers.length), 49);
    });

    // ⚠️ THE FINDING, PINNED. TTC's paid layers are the strongest in the
    // product — thirteen real offerings against five mock specialists
    // everywhere else. If a refactor ever quietly demotes these, the stage
    // silently loses the thing that makes it different.
    test('TTC consult resolves on every bracket that wants one', () {
      final consulting = kTtcBrackets
          .where((b) => b.layer(BracketLayer.consult).isLive)
          .map((b) => b.id)
          .toSet();
      expect(consulting, containsAll(<String>[
        'ttc_conceiving',
        'ttc_pcos',
        'ttc_infertility',
        'ttc_preconception_health',
        'ttc_male_fertility',
        'ttc_after_loss',
      ]));
    });

    // ⚠️ THE MOST IMPORTANT SINGLE ASSERTION IN THIS FILE.
    //
    // A woman who has just lost a pregnancy must not be shown a shop, a
    // checklist, a habit tracker or a course. The workbook refused five of
    // seven layers on this bracket and every refusal is right. This is the cell
    // most likely to be softened later by a well-meaning "the screen looks
    // empty" fix.
    test('after a loss, nothing is sold and nothing is tracked', () {
      final b = bracketById('ttc_after_loss')!;
      for (final l in [
        BracketLayer.products,
        BracketLayer.tools,
        BracketLayer.activities,
      ]) {
        expect(isRefused(b, l), isTrue,
            reason: 'ttc_after_loss → ${l.name} must be notApplicable');
        expect(canRender(b, l), isFalse);
      }
      // What she IS shown: a person, and other people.
      expect(canRender(b, BracketLayer.consult), isTrue);
      expect(canRender(b, BracketLayer.extras), isTrue);
    });

    // =========================================================================
    //  SKILLING — the stage that is declared and entirely unbuilt
    // =========================================================================

    // ⚠️ THE LOAD-BEARING ONE. Skilling exists as a PLAN: eighty-four cells,
    // zero resolvers. The moment one of them is flipped to `live` without a
    // real screen behind it, a door starts promising a section that opens to
    // nothing — the correct-but-unreachable failure this repo has already
    // shipped once.
    //
    // When skilling genuinely starts shipping, this test does not get deleted:
    // it gets replaced with the per-surface router assertion the other three
    // stages have. Deleting it would remove the only thing standing between a
    // spreadsheet and a promise.
    test('no skilling layer claims to be live', () {
      for (final b in kSkillingBrackets) {
        expect(b.liveLayers, isEmpty,
            reason: '${b.id} claims a live layer, but nothing is built for '
                'skilling — name the file first, then flip the state');
      }
    });

    test('twelve skilling brackets, eighty-four cells', () {
      expect(kSkillingBrackets.length, 12);
      expect(kSkillingBrackets.fold<int>(0, (n, b) => n + b.layers.length), 84);
    });

    test('skilling ids are stage-scoped', () {
      for (final b in kSkillingBrackets) {
        expect(b.id.startsWith('skilling_'), isTrue, reason: b.id);
        expect(b.stage, LifeStage.skilling);
      }
    });

    // Every skilling cell is `notReady` — real, named, not built. NOT
    // `notApplicable`: the workbook refuses nothing in this stage, and marking
    // an unbuilt thing as permanently refused would quietly delete a plan.
    test('every skilling cell is notReady, never refused', () {
      for (final b in kSkillingBrackets) {
        for (final l in BracketLayer.values) {
          expect(b.layer(l).state, LayerState.notReady,
              reason: '${b.id} → ${l.name}');
        }
      }
    });

    // ⚠️ THE PREVIEW SHOWS THESE STRINGS TO A HUMAN. `_PlanSheet` renders the
    // raw `reason` under each layer heading, which makes it the one place in
    // the app where a workbook cell is read verbatim by a person — so an empty
    // one is a blank row in the only screen this stage has.
    test('every skilling cell carries the workbook text the preview renders',
        () {
      for (final b in kSkillingBrackets) {
        for (final l in BracketLayer.values) {
          expect(b.layer(l).reason.trim().length, greaterThan(3),
              reason: '${b.id} → ${l.name} would render a blank row in the '
                  'skilling preview');
        }
      }
    });

    // Every door in the preview must have a mark. A tile with no art is the
    // only visual defect this screen can have that a layout check would miss.
    test('every skilling bracket has a drawn mark', () {
      for (final b in kSkillingBrackets) {
        expect(skillMarkFor(b.id), isNotNull, reason: '${b.id} has no mark');
      }
      // And no two brackets share one — twelve doors, twelve shapes.
      final marks = kSkillingBrackets.map((b) => skillMarkFor(b.id)).toSet();
      expect(marks.length, kSkillingBrackets.length);
    });

    // Same rule, the other clinical bracket. Selling anything on the IVF
    // explainer would be the worst placement in the product.
    test('the IVF explainer sells nothing', () {
      final b = bracketById('ttc_infertility')!;
      expect(isRefused(b, BracketLayer.products), isTrue);
      expect(canRender(b, BracketLayer.products), isFalse);
    });
  });

  group('not-applicable means nothing, ever', () {
    // WHY: this is the one place CLAUDE.md's "a feature is never hidden; empty
    // sections render an invitation" is deliberately suspended. The first person
    // to see a two-section bracket will want to fill it, and an invitation under
    // Infertility → Products is a shopping prompt beside a clinical grief.
    test('every non-live layer renders nothing', () {
      for (final b in kAllBrackets) {
        for (final l in BracketLayer.values) {
          final spec = b.layer(l);
          if (spec.state == LayerState.live) continue;
          expect(spec.rendersNothing, isTrue,
              reason: '${b.id} → ${l.name} is ${spec.state.name} but claims to '
                  'render something');
          expect(canRender(b, l), isFalse, reason: '${b.id} → ${l.name}');
        }
      }
    });

    test('every non-live layer records the workbook reason', () {
      for (final b in kAllBrackets) {
        for (final l in BracketLayer.values) {
          final spec = b.layer(l);
          if (spec.state == LayerState.live) continue;
          expect(spec.reason.trim(), isNotEmpty,
              reason: '${b.id} → ${l.name} is ${spec.state.name} with no reason '
                  '— the next reader cannot tell "never" from "not yet"');
        }
      }
    });

    // The named case, spelled out, because a general rule is easy to weaken and
    // a named example is not. These four cells carry "Not a fit" in the workbook
    // with NO red fill — reading colour alone would have shipped commerce here.
    test('the four uncoloured refusals are honoured', () {
      void refuses(String id, BracketLayer layer) {
        final b = bracketById(id)!;
        expect(isRefused(b, layer), isTrue,
            reason: '$id → ${layer.name} must be notApplicable');
        expect(canRender(b, layer), isFalse);
      }

      refuses('pregnancy_scans_tests', BracketLayer.products);
      refuses('pregnancy_is_it_safe', BracketLayer.products);
      refuses('pregnancy_is_it_safe', BracketLayer.course);
      // Scans → Course is notCore rather than notApplicable: it exists, as a
      // module of childbirth prep. Different reason, same silence.
      expect(
          bracketById('pregnancy_scans_tests')!
              .layer(BracketLayer.course)
              .state,
          LayerState.notCore);
    });
  });

  group('the audit is reflected', () {
    test('thirty-four live cells across the stage', () {
      final live = kPregnancyBrackets.fold<int>(
          0, (n, b) => n + b.liveLayers.length);
      // The audit's original figure was 30 of 60. Two things moved it:
      //   +3  Extras became a real seventh layer, and three of its entries
      //       already exist — the report explainer, the urgent-symptom set and
      //       the safe/not-safe database.
      //   +1  Complications → Tools was upgraded from notReady. The workbook
      //       asks for "kick counter, sugar & BP log"; the kick counter exists
      //       and reduced movement is this bracket's own red flag, so the layer
      //       resolves. The missing logs are a listed gap, not an absent layer.
      // ⚠️ If this number changes, docs/BRACKET-AUDIT.md changes with it. They
      // are one claim in two places, and a doc that drifts from its test is
      // worse than no doc.
      expect(live, 34,
          reason: 'live-cell count drifted from the audit; update both');
    });

    test('Labour prep is the only bracket with no refused layer', () {
      final fullyServed = kPregnancyBrackets
          .where((b) => BracketLayer.values
              .every((l) => b.layer(l).state != LayerState.notApplicable))
          .map((b) => b.id)
          .toList();
      expect(fullyServed, contains('pregnancy_labour'));
    });
  });
}
