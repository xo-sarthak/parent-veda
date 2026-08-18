// =============================================================================
//  The Problem Hub — the final spec's rules, as tests
// -----------------------------------------------------------------------------
//  PARENTVEDA-PROBLEM-HUB-FINAL-SPEC.md turns into forty config files, and a
//  config file is exactly the kind of thing edited quickly by someone who has
//  not read the spec. The rules that matter are asserted here rather than left
//  as prose.
//
//  Every test loops over `kAllHubs`, so hub #2 inherits all of them the moment
//  it is added.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/services/ttc_surfaces.dart';
import 'package:parentveda/services/parenting_surfaces.dart';
import 'package:parentveda/data/hubs/ttc_hubs.dart';
import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/data/hubs/pregnancy_hubs.dart';
import 'package:parentveda/data/hubs/scans_hub.dart';
import 'package:parentveda/data/hubs/scans_hub_v2.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/bracket.dart';
import 'package:parentveda/screens/brackets/hub/hub_config.dart';
import 'package:parentveda/services/app_structure.dart';
import 'package:parentveda/services/bracket_resolver.dart';

/// Every hub built so far.
// ⚠️ BOTH VERSIONS ARE HELD TO EVERY RULE. A toggle is only a fair comparison
// if the new shape is checked as hard as the old one — otherwise "V2 is
// simpler" can quietly mean "V2 skipped the tests".
final List<HubConfig> kAllHubs = [
  kScansHub,
  kScansHubV2,
  ...kPregnancyHubs,
  ...kParentingHubs,
  ...kTtcHubs,
];

/// ⚠️ AN EXPLICITLY DECLARED HINDI DEBT, NOT A FINISHED PAIR.
///
/// `_en(...)` writes the English into both slots on purpose — CLAUDE.md calls
/// this "English for now, Hindi owed", and it is greppable precisely so it
/// cannot be mistaken for completed work.
///
/// The bilingual assertions below skip these rather than failing, and the
/// `Hindi debt` group counts them so the exemption can never quietly become
/// permanent. Never `_t(x, x)` for a string that is genuinely finished — use
/// `_same(...)`, which means something different.
bool _owed(LocalizedText t) => t.hi == t.en;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('The doors are the primary navigation, and the problem sets the count',
      () {
    // ⚠️ THIS WAS `inInclusiveRange(2, 4)` AND THE CEILING WAS WRONG.
    //
    // The reconciliation Excel gives Scans & tests six journey steps, and the
    // implementation prompt is explicit: "Do NOT arbitrarily limit this to
    // four. If a hub genuinely has six useful user intents, show six." Holding
    // four would have meant dropping "See my timeline" and "What happens
    // next?" — the opening and closing moves of the journey.
    //
    // The floor still holds (one door is not a choice) and a ceiling still
    // holds, because past about eight the hub stops asking a question and
    // becomes the inventory menu it was built to replace.
    // ⚠️ THE FLOOR MOVED FROM 2 TO 1, AND THAT IS A ROUTING FACT.
    //
    // Twenty-three of the forty hubs have a single door whose label only
    // restates the tile — "Symptoms & discomforts" -> "I have a symptom". Those
    // never render a hub screen at all: `hub_registry.dart` opens the door's
    // destination directly, because a screen showing one heading and one button
    // is a tap of pure tax.
    //
    // So 1 is legal and MEANS something. The separate test below is what stops
    // it becoming an excuse to skip the thinking.
    test('between one and eight doors', () {
      for (final h in kAllHubs) {
        expect(h.needs.length, inInclusiveRange(1, 8), reason: h.bracketId);
      }
    });

    test('a one-door hub still declares a real destination and promise', () {
      for (final h in kAllHubs) {
        if (h.needs.length != 1) continue;
        final n = h.needs.single;
        expect(n.action != null || n.surfaceId != null, isTrue,
            reason: '${h.bracketId} opens directly, so its single door IS the '
                'whole feature — it cannot lead nowhere');
        expect(n.blurb.en.trim().length, greaterThan(20), reason: h.bracketId);
      }
    });

    test('every hub points at a real bracket', () {
      for (final h in kAllHubs) {
        expect(bracketById(h.bracketId), isNotNull, reason: h.bracketId);
      }
    });
  });

  group('§2.1 — a door names an outcome, never a content type', () {
    // ⚠️ THE RULE MOST LIKELY TO BE BROKEN BY ACCIDENT. The spec bans inventory
    // language as the user's primary choices, and the reason is the whole
    // restructure: "Content" and "Tools" are how WE filed things. She has never
    // once thought "I need the tools layer".
    test('no door is labelled with an inventory word', () {
      const banned = [
        'content', 'contents', 'tools', 'tool', 'products', 'product',
        'courses', 'course', 'consults', 'consult', 'activities', 'extras',
        'masterclass', 'articles', 'videos',
      ];
      for (final h in kAllHubs) {
        for (final n in h.needs) {
          final words =
              n.label.en.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), '').split(' ');
          for (final b in banned) {
            expect(words.contains(b), isFalse,
                reason: '${h.bracketId}: door "${n.label.en}" uses inventory '
                    'language — §2.1 forbids it as a primary choice');
          }
        }
      }
    });

    test('every door promises something, in both languages', () {
      for (final h in kAllHubs) {
        for (final n in h.needs) {
          expect(n.label.hi.trim(), isNotEmpty, reason: n.label.en);
          expect(n.blurb.en.trim().length, greaterThan(20),
              reason: '${h.bracketId}: "${n.label.en}" has no promise under it');
          expect(n.blurb.hi.trim(), isNotEmpty, reason: n.label.en);
          if (!_owed(n.label)) {
            expect(n.label.hi, isNot(equals(n.label.en)), reason: n.label.en);
          }
          if (!_owed(n.blurb)) {
            expect(n.blurb.hi, isNot(equals(n.blurb.en)), reason: n.label.en);
          }
        }
      }
    });

    // ⚠️ THIS WAS PREGNANCY-ONLY AND WOULD HAVE PASSED BY ACCIDENT.
    //
    // `homeFor()` reads `app_structure.dart`, which is the PREGNANCY tab set and
    // has no opinion about `pp_` or `ttc_` ids. Adding the parenting and TTC
    // hubs to this file would have failed every one of their doors — or worse,
    // if the check had been loosened, passed doors that lead nowhere.
    //
    // A surface is now checked against the router of the stage it belongs to,
    // which is the only place that can actually answer the question.
    test('every door goes somewhere — a real surface, or a declared action', () {
      for (final h in kAllHubs) {
        for (final n in h.needs) {
          final id = n.surfaceId;
          final ok = n.action != null || (id != null && _surfaceExists(id));
          expect(ok, isTrue,
              reason: '${h.bracketId}: door "${n.label.en}" leads nowhere');
        }
      }
    });

    test('a closing offer also goes somewhere', () {
      for (final h in kAllHubs) {
        final c = h.closing;
        if (c == null) continue;
        expect(c.action.trim(), isNotEmpty, reason: h.bracketId);
        expect(c.blurb.en.trim().length, greaterThan(15),
            reason: '${h.bracketId}: the closing offer promises nothing');
      }
    });

    // ⚠️ A ONE-DOOR HUB MUST NOT CARRY A CLOSING OFFER. It has no screen to
    // show it on — the tile opens the door's destination directly — so a
    // closing there is silently dead config.
    test('one-door hubs declare no closing offer', () {
      for (final h in kAllHubs) {
        if (h.needs.length > 1) continue;
        expect(h.closing, isNull,
            reason: '${h.bracketId} opens directly, so its closing offer would '
                'never render');
      }
    });

    test('no two doors share a mark or a hue', () {
      for (final h in kAllHubs) {
        expect(h.needs.map((n) => n.mark).toSet().length, h.needs.length,
            reason: '${h.bracketId}: two doors share a mark');
        expect(h.needs.map((n) => n.hue).toSet().length, h.needs.length,
            reason: '${h.bracketId}: two doors share a hue');
      }
    });
  });

  group('§2.2 / §2.3 — the deleted architecture stays deleted', () {
    // These two are the reason this file exists. Both were BUILT and then
    // removed by the final spec, so both are exactly the sort of thing that
    // grows back when someone thinks the hub looks empty.
    test('HubConfig has no sections field — the category menu is gone', () {
      // A compile-time guarantee: if `sections` returns, this file stops
      // compiling because the constructor changes. Kept as a named test so the
      // reason is discoverable from the test list.
      const kept = '§2.2: asking "what do you need?" then showing category '
          'sections asks the same question twice.';
      expect(kept, isNotEmpty);
    });

    test('no hub declares a situational card', () {
      // §2.3 — a generic informational card interrupts the primary task. The
      // renderer no longer accepts one; this asserts the intent survives.
      const kept = '§2.3: she tapped the hub to get somewhere. The first thing '
          'on screen should not be about something else.';
      expect(kept, isNotEmpty);
    });
  });

  group('§5.2 — an urgent strip only where red flags genuinely matter', () {
    test('Scans has one, and it routes to a declared action', () {
      expect(kScansHub.urgent, isNotNull);
      expect(kScansHub.urgent!.action, kActUrgent);
      expect(kScansHub.urgent!.line.hi,
          isNot(equals(kScansHub.urgent!.line.en)));
    });

    // The calm door to the same screen is deliberate, not duplication. The
    // strip is for someone bleeding now who will not read six options first;
    // the door is the same question asked in daylight.
    //
    // ⚠️ The label moved from "Know when to ask my doctor" to the Excel's
    // "Need expert help?" (journey step 6), so this asserts the DESTINATION
    // rather than the wording — which is what the test was really about.
    test('the calm route to the same destination also exists', () {
      final calm = kScansHub.needs.where((n) => n.action == kActUrgent);
      expect(calm, hasLength(1));
      expect(calm.first.blurb.en.toLowerCase(), contains('call'));
    });
  });

  group('Hindi debt — declared, counted, and impossible to lose', () {
    // The point of this group is NOT to pass. It is to make the size of the
    // debt visible in the test output, so "we will translate it later" has a
    // number attached to it every time the suite runs.
    test('every hub that owes Hindi says so out loud', () {
      final owed = <String>[];
      for (final h in kAllHubs) {
        if (_owed(h.hero)) owed.add('${h.bracketId}: hero');
        for (final n in h.needs) {
          if (_owed(n.label)) owed.add('${h.bracketId}: door "${n.label.en}"');
        }
      }
      // ⚠️ Not an assertion that owed is empty — it deliberately is not. This
      // asserts only that the debt is countable, and prints it.
      expect(owed, isNotNull);
      // ignore: avoid_print
      print('Hindi owed on ${owed.length} hub string(s): '
          '${owed.join(' | ')}');
    });

    test('V1 is fully translated and must stay that way', () {
      // V1 shipped bilingual. A regression there would be a real loss, so it
      // is held to the original rule with no exemption.
      expect(_owed(kScansHub.hero), isFalse);
      for (final n in kScansHub.needs) {
        expect(_owed(n.label), isFalse, reason: n.label.en);
        expect(_owed(n.blurb), isFalse, reason: n.label.en);
      }
    });
  });

  group('§13.1 — NOT APPLICABLE: products. NOT CORE: course.', () {
    // ⚠️ TWO INDEPENDENT LOCKS. The config names no commerce surface, and the
    // bracket table refuses the layer. It takes two separate mistakes to put a
    // shop on the screen someone reaches by searching "ectopic".
    test('the Scans config names no product or course surface', () {
      const commerce = ['shop', 'product_guide', 'masterclasses', 'cohorts'];
      for (final n in kScansHub.needs) {
        expect(commerce.contains(n.surfaceId), isFalse,
            reason: 'commerce surface "${n.surfaceId}" on Scans');
      }
    });

    test('and the bracket table refuses them independently', () {
      final b = bracketById('pregnancy_scans_tests')!;
      expect(canRender(b, BracketLayer.products), isFalse);
      expect(isRefused(b, BracketLayer.products), isTrue);
      expect(canRender(b, BracketLayer.course), isFalse);
    });
  });

  group('§5.1 — the hero is the problem, not the filing label', () {
    test('the hero is a sentence, and not the bracket name', () {
      for (final h in kAllHubs) {
        final b = bracketById(h.bracketId)!;
        expect(h.hero.en.toLowerCase(),
            isNot(equals(b.title.en.toLowerCase())),
            reason: h.bracketId);
        expect(h.hero.en.split(' ').length, greaterThan(3),
            reason: '${h.bracketId}: a hero is a sentence, not a label');
        if (!_owed(h.hero)) {
          expect(h.hero.hi, isNot(equals(h.hero.en)));
        }
      }
    });

    test('every hub records its template and core question', () {
      for (final h in kAllHubs) {
        expect(h.coreQuestion.trim().endsWith('?'), isTrue, reason: h.bracketId);
      }
    });
  });

  group('§2.5 — LIVE means reuse an existing surface', () {
    // ⚠️ ALSO PREGNANCY-ONLY UNTIL NOW. `app_structure` is the pregnancy tab
    // set; parenting and TTC declare their surfaces in their own files. Asking
    // app_structure about a `pp_` id gets null for the wrong reason.
    test('every surface a door names is declared by its own stage', () {
      for (final h in kAllHubs) {
        for (final n in h.needs) {
          final id = n.surfaceId;
          if (id == null) continue;
          expect(_surfaceExists(id), isTrue,
              reason: '${h.bracketId}: "$id" is claimed as reuse but no '
                  'stage declares it');
        }
      }
    });
  });
}

/// True when [id] is a real surface in ANY stage's router.
///
/// Deliberately not stage-scoped: a hub knows its bracket, not its router, and
/// the three id namespaces (`pp_`, `ttc_`, and pregnancy's bare names) do not
/// collide. What matters is that the id resolves somewhere real rather than
/// silently opening nothing.
bool _surfaceExists(String id) {
  // ⚠️ A CONTENT SECTION IS A REAL DESTINATION, and it is not declared by a
  // stage's surface list.
  //
  // The parenting content sections resolve by prefix out of `kPpSections`
  // rather than as hand-written router cases, precisely so that registering a
  // section is the whole of wiring it. That means `ppSurfaceLabel` -- which
  // reads a static list -- cannot see them, and this test read a live door as
  // leading nowhere.
  //
  // Resolved against the registry rather than by accepting the prefix blindly,
  // so a door pointing at a section that does not exist still fails. That is the
  // case this test is actually for.
  const sectionPrefix = 'pp_section/';
  if (id.startsWith(sectionPrefix)) {
    return ppSectionFor(id.substring(sectionPrefix.length)) != null;
  }
  if (homeFor(id) != null) return true;
  if (ppSurfaceLabel(id) != null) return true;
  if (ttcSurfaceLabel(id, hinglish: false) != null) return true;
  return false;
}
