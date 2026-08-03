// =============================================================================
//  The parenting review — two passes, one set of tests.
// -----------------------------------------------------------------------------
//  Two review documents, written weeks apart, and the second overrides the
//  first where they disagree. The clearest example: pass 1 asked for "Today's
//  parenting tip" to open a proper page when expanded; pass 2 asked for the
//  section to be removed altogether. The second wins.
//
//  These tests hold the OUTCOMES, and — just as importantly — that nothing was
//  deleted to get there. Every removal in both passes is a commented-out call
//  site with the screen still on disk, so each one is asserted twice: the thing
//  is gone from where it was, and the code that made it is still there.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/daily_tip_popup.dart';
import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';

String _read(String p) => File(p).readAsStringSync();

/// Strip comment lines before asserting something is ABSENT — every removal
/// here is a comment, so a naive search finds the thing it is checking is gone.
String _code(String src) => src
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  dailyPopupAndSaved();
  productTemplateAcrossApps();
  final drawerRaw = _read('lib/screens/post_pregnancy/explore_drawer.dart');
  final drawer = _code(drawerRaw);
  final navRaw = _read('lib/screens/post_pregnancy/pp_common.dart');
  final nav = _code(navRaw);
  final toolsRaw = _read('lib/screens/post_pregnancy/tools_hub_screen.dart');
  final tools = _code(toolsRaw);
  final childRaw = _read('lib/screens/post_pregnancy/my_child_screen.dart');
  final child = _code(childRaw);
  final guide =
      _code(_read('lib/screens/product_guide/product_guide_hub_screen.dart'));
  final product =
      _code(_read('lib/screens/post_pregnancy/product_detail_screen.dart'));

  // ==========================================================================
  //  Navigation
  // ==========================================================================
  group('bottom nav — Brain replaces Ask Veda', () {
    test('tab 1 opens Brain Development', () {
      expect(nav.contains('const GrowHomeScreen()'), isTrue);
      expect(nav.contains("(Icons.emoji_objects_rounded, 'Brain')"), isTrue);
    });

    test('Ask Veda is out of the tabs but not out of the app', () {
      expect(nav.contains("'AskVeda')"), isFalse,
          reason: 'the AskVeda tab should be gone from the pill');
      // Still reachable — the review moved the tab, it did not delete a feature.
      expect(navRaw.contains('AskVedaScreen'), isTrue);
      expect(child.contains('Ask Veda anything else'), isTrue,
          reason: 'the My Child door into Ask Veda must survive');
    });

    test('the old tab is commented, not deleted', () {
      expect(navRaw.contains("//   nav.push(MaterialPageRoute<void>(builder: (_) => const AskVedaScreen()));"),
          isTrue);
      expect(navRaw.contains("//   (Icons.auto_awesome_rounded, 'AskVeda'),"),
          isTrue);
    });
  });

  group('Explore', () {
    test('My Child, Guided journeys, His journey and Skill Development are '
        'all out of the menu', () {
      for (final row in [
        "'My Child'",
        "'Guided journeys'",
        "'His journey'",
        "'Skill Development'",
      ]) {
        expect(drawer.contains(row), isFalse, reason: '$row still in Explore');
      }
    });

    test('and every one of them is commented in place', () {
      for (final row in [
        "// _section(context, Icons.child_care_outlined, 'My Child',",
        "// _section(context, Icons.route_rounded, 'Guided journeys',",
        "// _section(context, Icons.timeline_rounded, 'His journey',",
        "// _section(context, Icons.emoji_objects_outlined, 'Skill Development',",
      ]) {
        expect(drawerRaw.contains(row), isTrue, reason: 'missing revert: $row');
      }
    });

    test('their screens are all still on disk', () {
      // "Remove from the menu, not the feature" was explicit for His journey,
      // and is true of the rest too.
      for (final f in [
        'my_child_screen.dart',
        'journeys_screen.dart',
        'phase_map_screen.dart',
        'development_home_screen.dart',
        'grow_home_screen.dart',
      ]) {
        expect(File('lib/screens/post_pregnancy/$f').existsSync(), isTrue,
            reason: '$f was deleted; it should only have lost a door');
      }
    });

    test('My Family Profile is renamed', () {
      expect(drawer.contains("'Personalize ParentVeda experience'"), isTrue);
      expect(drawer.contains("'My Family Profile'"), isFalse);
      expect(drawerRaw.contains("// _section(context, Icons.tune_rounded, 'My Family Profile',"),
          isTrue);
    });

    test('Launches and Brand Studio moved in', () {
      for (final row in ["'Launches'", "'Brand Studio'", "'Brand Studio (debug)'"]) {
        expect(drawer.contains(row), isTrue, reason: '$row missing from Explore');
      }
    });

    test('Due date and Track ovulation are two separate features', () {
      expect(drawer.contains("'Due date'"), isTrue);
      expect(drawer.contains("'Track ovulation'"), isTrue);
      expect(drawer.contains('NextBabyIntent.dueDate'), isTrue);
      expect(drawer.contains('NextBabyIntent.ovulation'), isTrue);
    });
  });

  group('Tools lost what moved', () {
    test('Launches, Brand Studio, Compare, Development journey and Due date '
        'are gone from Tools', () {
      for (final row in [
        "'Launches'",
        "'Brand Studio'",
        "'Compare products'",
        "'Development journey'",
        "'Due date & ovulation'",
      ]) {
        expect(tools.contains(row), isFalse, reason: '$row still in Tools');
      }
    });

    test('every one is commented in place', () {
      for (final row in [
        "// _tracker(context, Icons.auto_awesome_outlined,",
        "// _tracker(context, Icons.workspace_premium_outlined,",
        "// _tracker(context, Icons.compare_arrows_rounded,",
        "// _tracker(context, Icons.checklist_rounded,",
        "// _tracker(context, Icons.calendar_month_outlined,",
      ]) {
        expect(toolsRaw.contains(row), isTrue, reason: 'missing revert: $row');
      }
    });

    test('the phase explanation was already gone before this review', () {
      // Pass 2 asked to remove it; the 17-18 July review had already done so.
      // Asserted rather than assumed, so nobody re-adds it thinking it is due.
      expect(tools.contains("'His Leap Window'"), isFalse);
      expect(toolsRaw.contains('"His Leap Window" REMOVED from Tools'), isTrue);
    });

    test('Compare now lives in the Product Guide', () {
      expect(guide.contains('ProductsCompareScreen()'), isTrue);
      expect(guide.contains("'Compare products'"), isTrue);
    });
  });

  // ==========================================================================
  //  My Child
  // ==========================================================================
  group('My Child page', () {
    test("Today's tip and Coming up are off the page", () {
      expect(child.contains('_dailyTip(),'), isFalse);
      expect(child.contains('_milestones(),'), isFalse);
    });

    test('both builders survive, so the call sites can come back', () {
      expect(childRaw.contains('// _dailyTip(),'), isTrue);
      expect(childRaw.contains('// _milestones(),'), isTrue);
      expect(childRaw.contains('Widget _dailyTip()'), isTrue);
      expect(childRaw.contains('Widget _milestones()'), isTrue);
    });

    test('Picks became Products', () {
      expect(child.contains("title: 'Products for this phase',"), isTrue);
      expect(child.contains("title: 'Picks for this phase',"), isFalse);
      expect(childRaw.contains("//   title: 'Picks for this phase',"), isTrue);
    });

    test('the Watch button is off the phase video card', () {
      // The card itself still opens the player — that is why the button was
      // redundant rather than load-bearing.
      expect(child.contains("label: Text('Watch'"), isFalse);
      expect(childRaw.contains("//     label: Text('Watch'"), isTrue);
      expect(child.contains('onTap: open,'), isTrue,
          reason: 'the card must still open the video');
    });

    test('the phase timeline weights near-term stops differently', () {
      // Was one identical tick per phase, twenty of them.
      expect(child.contains('if (i != idx)'), isTrue);
      expect(child.contains('i < idx'), isTrue,
          reason: 'passed stops should be drawn differently from coming ones');
    });
  });

  // ==========================================================================
  //  The landing pop-up
  // ==========================================================================
  group('daily tip pop-up', () {
    test('every tip has a mechanism and a source', () {
      // "actionable tip with a scientific reason (referring to a study)".
      for (final t in kDailyTips) {
        expect(t.why.trim(), isNotEmpty, reason: '${t.title}: no why');
        expect(t.source.trim(), isNotEmpty, reason: '${t.title}: no source');
      }
    });

    test('no source pretends to be a precise citation', () {
      // Naming a real body of work is honest; inventing "Smith et al., 2019,
      // Pediatrics" is the one error a reader cannot catch. So: no bare years,
      // no fabricated journal references.
      final year = RegExp(r'\b(19|20)\d{2}\b');
      for (final t in kDailyTips) {
        expect(year.hasMatch(t.source), isFalse,
            reason: '${t.title} cites a year: "${t.source}"');
        expect(t.source.contains('et al'), isFalse, reason: t.title);
        expect(t.source.contains('doi'), isFalse, reason: t.title);
      }
    });

    test('today is stable and the id follows it', () {
      final a = dailyTip();
      expect(dailyTip().title, a.title);
      expect(dailyTipId().startsWith('tip_'), isTrue);
    });

    test('the share text carries the source and the disclaimer', () {
      final s = dailyTipShareText(kDailyTips.first);
      expect(s.contains(kDailyTips.first.title), isTrue);
      expect(s.contains('Based on:'), isTrue,
          reason: 'a tip forwarded with no provenance is the thing this app '
              'exists to be an alternative to');
      expect(s.contains('not advice about one child'), isTrue);
    });

    test('it is fired from the My Child home and the store is booted', () {
      expect(child.contains('maybeShowDailyTip(context)'), isTrue);
      expect(_code(_read('lib/main.dart')).contains('DailyTipStore.instance.init()'),
          isTrue);
    });

    test('once a day is the INTENDED behaviour, even while overridden', () {
      final popup = _code(_read('lib/screens/post_pregnancy/daily_tip_popup.dart'));
      // The date-keyed check must survive the testing override, or turning the
      // flag off at launch would leave nothing behind it.
      expect(popup.contains('bool get shownToday'), isTrue);
      expect(popup.contains('store.shownToday'), isTrue);
      // Was: no always-show flag at all. The review asked for the pop-up on
      // every open while it is being looked at, so there is one now — named to
      // match kPremiereAlwaysShow, and asserted to be launch-blocking in
      // "every open while testing, behind a named flag" above.
    });
  });

  // ==========================================================================
  //  Milestone pages
  // ==========================================================================
  group('milestone pages', () {
    test('every area carries the name a parent actually tapped', () {
      for (final a in kDevAreas) {
        expect(a.shortName.trim(), isNotEmpty, reason: '${a.id} has no shortName');
        expect(a.label, a.shortName);
      }
    });

    test('the four My Child rows map to those names', () {
      // The complaint was tapping "Brain" and landing on "Thinking & Problem
      // Solving".
      expect(devAreaById('cognitive').label, 'Brain');
      expect(devAreaById('gross_motor').label, 'Physical');
      expect(devAreaById('language').label, 'Language');
      expect(devAreaById('emotional').label, 'Emotional');
    });

    test('the page titles use it', () {
      final area =
          _code(_read('lib/screens/post_pregnancy/development_area_screen.dart'));
      expect(area.contains('ppBack(context, area.label)'), isTrue);
      expect(area.contains('Text(area.label, style: ppFraunces(24'), isTrue);
      expect(area.contains(r"'${area.label} skills timeline'"), isTrue);
    });

    test('all five sections are present, after the skills timeline', () {
      final area =
          _code(_read('lib/screens/post_pregnancy/development_area_screen.dart'));
      final timeline = area.indexOf('skills timeline');
      expect(timeline, greaterThan(-1));
      for (final section in [
        'Ways to help it along',
        'Try together',
        "'Watch'",
        "'Learn'",
        'Explore products',
      ]) {
        final at = area.indexOf(section);
        expect(at, greaterThan(-1), reason: '$section missing');
        expect(at, greaterThan(timeline),
            reason: '$section should sit after the skills timeline');
      }
    });

    test('every area has help bullets to show', () {
      for (final a in kDevAreas) {
        final stage = a.journey.firstWhere((s) => s.status == 'current',
            orElse: () => a.journey.first);
        expect(helpBulletsFor(a, stage), isNotEmpty, reason: a.id);
      }
    });
  });

  // ==========================================================================
  //  Tests & Scans
  // ==========================================================================
  group('tests & scans', () {
    final screen =
        _code(_read('lib/screens/tools/tests_scans_reports_screen.dart'));

    test('the parameters section is renamed', () {
      expect(screen.contains("'Understanding your report parameters'"), isTrue);
      expect(screen.contains("title: 'Understanding Your Report',"), isFalse);
    });

    test('the closing interpretation section exists', () {
      expect(screen.contains("'How do I interpret the test results?'"), isTrue);
    });

    test('every test with parameters also explains how to read the whole '
        'report', () {
      for (final t in kTestsScans.where((t) => t.parameters.isNotEmpty)) {
        expect(t.interpretation.trim(), isNotEmpty,
            reason: '${t.name} explains each parameter and never the report');
        expect(t.interpretPointers, isNotEmpty, reason: t.name);
      }
    });

    test('no interpretation states a diagnosis', () {
      // It may say what a finding CAN point at. It may never say what it does
      // mean for this person — the app explains a report, it never reads one.
      for (final t in kTestsScans) {
        if (t.interpretation.isEmpty) continue;
        // Negations are stripped first. "is not a diagnosis of anything" is
        // exactly the sentence this rule WANTS, and a bare substring search
        // fails it — which is how a well-written line ends up looking like the
        // violation it is guarding against.
        final all =
            '${t.interpretation} ${t.interpretPointers.join(' ')}'
                .toLowerCase()
                .replaceAll('not a diagnosis', '')
                .replaceAll('not the same as diagnosing', '')
                .replaceAll('never a diagnosis', '')
                // "a diagnostic test" is the correct next step to name, and
                // naming it is the opposite of diagnosing.
                .replaceAll('diagnostic', '')
                // "tell your doctor if you have taken any" is a conditional
                // about the parent, not a statement about their body. The
                // rule is about ASSERTING a finding, so the conditional form
                // is stripped rather than the guard being loosened.
                .replaceAll('if you have', '');
        for (final banned in [
          'you have ',
          'your baby has ',
          'this means you',
          'diagnos',
        ]) {
          expect(all.contains(banned), isFalse,
              reason: '${t.name} says "$banned"');
        }
      }
    });

    test('every interpretation ends up at a clinician', () {
      for (final t in kTestsScans) {
        if (t.interpretation.isEmpty) continue;
        final all =
            '${t.interpretation} ${t.interpretPointers.join(' ')}'.toLowerCase();
        expect(
            all.contains('doctor') ||
                all.contains('paediatrician') ||
                all.contains('team') ||
                all.contains('vaccinator'),
            isTrue,
            reason: '${t.name} never routes anywhere');
      }
    });
  });

  // ==========================================================================
  //  Vaccination template
  // ==========================================================================
  group('vaccination — one template', () {
    test('every vaccine has common questions', () {
      // The reported bug: MMR had them, BCG did not.
      for (final v in kVaccines) {
        expect(v.faqs, isNotEmpty, reason: '${v.name} has no common questions');
      }
    });

    test('myth vs fact stays optional', () {
      // "…can appear optionally in vaccines where it makes sense." Inventing a
      // myth to fill a template teaches a parent a wrong idea in order to
      // correct it, so not every vaccine should have one.
      final withMyths = kVaccines.where((v) => v.myths.isNotEmpty).length;
      expect(withMyths, greaterThan(0));
      expect(withMyths, lessThan(kVaccines.length),
          reason: 'if every vaccine has one, some were invented to fill a slot');
    });

    test('BCG specifically now matches the MMR template', () {
      final bcg = kVaccines.firstWhere((v) => v.name == 'BCG');
      final mmr = kVaccines.firstWhere((v) => v.name.startsWith('Measles'));
      expect(bcg.faqs, isNotEmpty);
      expect(mmr.faqs, isNotEmpty);
    });

    test('no question or answer is empty', () {
      for (final v in kVaccines) {
        for (final (q, a) in v.faqs) {
          expect(q.trim(), isNotEmpty, reason: v.name);
          expect(a.trim(), isNotEmpty, reason: '${v.name}: $q');
        }
        for (final (m, f) in v.myths) {
          expect(m.trim(), isNotEmpty, reason: v.name);
          expect(f.trim(), isNotEmpty, reason: '${v.name}: $m');
        }
      }
    });
  });

  // ==========================================================================
  //  Product template
  // ==========================================================================
  group('product detail — one template', () {
    test('At a glance is no longer behind the soother branch', () {
      // The actual bug: `if (_isSoother) ... else ...`, so a soother got
      // "What's inside" and a rash cream got "At a glance", never both.
      final glance = product.indexOf("ppEyebrow('At a glance'");
      final inside = product.indexOf('What\'s inside & how it works');
      expect(glance, greaterThan(-1));
      expect(inside, greaterThan(-1));
      expect(glance, lessThan(inside),
          reason: 'the review put At a glance first');
    });

    test('both sections render for every product', () {
      // Two occurrences of the "what's inside" heading — the soother's rich
      // one and the generic one — and one unconditional "at a glance".
      expect("What's inside & how it works".allMatches(product).length,
          greaterThanOrEqualTo(2));
    });

    test("the take is renamed to ParentVeda's", () {
      expect(product.contains('"ParentVeda\'s take"'), isTrue);
      expect(product.contains("'The ParentVeda take'"), isFalse);
    });

    test('how-we-review is an expandable, not a section', () {
      expect(product.contains('_HowWeReview('), isTrue);
      expect(product.contains('Icons.info_outline_rounded'), isTrue);
      expect(product.contains("_pad(Text('How ParentVeda reviews this', style: ppJakarta(16)))"),
          isFalse);
    });

    test('the sections appear in the order the review specified', () {
      final order = [
        "ppEyebrow('At a glance'",
        "What's inside & how it works",
        '"ParentVeda\'s take"',
        "'Read the research'",
        "'From verified parents'",
        "'Compare with alternatives'",
      ];
      var last = -1;
      for (final s in order) {
        final at = product.indexOf(s);
        expect(at, greaterThan(-1), reason: '$s missing');
        expect(at, greaterThan(last), reason: '$s is out of order');
        last = at;
      }
    });
  });

  // ==========================================================================
  //  Child profile
  // ==========================================================================
  group('birth weight and another child', () {
    test('birth weight is its own field, not the current weight', () {
      final c = Child(
        id: 'x',
        name: 'A',
        isBoy: true,
        dob: DateTime(2026),
        weightKg: 6.2,
        heightCm: 62,
        headCm: 40,
        birthWeightKg: 3.1,
      );
      expect(c.birthWeightKg, 3.1);
      expect(c.weightKg, 6.2,
          reason: 'conflating them would rewrite history on every update');
    });

    test('it survives a round trip', () {
      final c = Child(
        id: 'x',
        name: 'A',
        isBoy: true,
        dob: DateTime(2026, 3, 4),
        weightKg: 6.2,
        heightCm: 62,
        headCm: 40,
        birthWeightKg: 3.1,
      );
      expect(Child.fromJson(c.toJson()).birthWeightKg, 3.1);
    });

    test('an unrecorded birth weight is 0, not a guess', () {
      expect(
          Child.fromJson(const {'id': 'x', 'name': 'A'}).birthWeightKg, 0);
      // …and a row from a database that has no such column yet must not throw.
      expect(Child.fromRow(const {'id': 'x', 'name': 'A'}).birthWeightKg, 0);
    });

    test('the add-child form asks for all three, optionally', () {
      final sheet =
          _code(_read('lib/screens/post_pregnancy/multichild_sheet.dart'));
      expect(sheet.contains("'Birth weight'"), isTrue);
      expect(sheet.contains("'Weight now'"), isTrue);
      expect(sheet.contains("'Height now'"), isTrue);
      expect(sheet.contains("Text('Optional'"), isTrue);
      // Name + dob stay the only requirements.
      expect(sheet.contains('if (nameCtl.text.trim().isEmpty || dob == null) return;'),
          isTrue);
    });

    test('the growth hero shows it as a fact, never as an adjusted expectation',
        () {
      expect(child.contains('Born at '), isTrue);
      // The "~" expected figures must still come from the population table.
      expect(child.contains('e.weightKg.toStringAsFixed(1)'), isTrue);
      expect(child.contains('birthWeightKg) * '), isFalse,
          reason: 'adjusting the expected curve by birth weight is a clinical '
              'calculation about one child — see CLAUDE.md');
    });
  });

  // ==========================================================================
  //  The stage doors
  // ==========================================================================
  group('due date / ovulation ask before they move anyone', () {
    final next = _code(_read('lib/screens/post_pregnancy/next_baby_screens.dart'));

    test('each asks its question', () {
      expect(next.contains('Are you pregnant?'), isTrue);
      expect(next.contains('Are you trying to conceive?'), isTrue);
    });

    test('nothing is set merely by looking', () {
      expect(next.contains('Nothing changes just because you looked'), isTrue);
    });

    test('a "not right now" answer is a real option, not a dismissal', () {
      expect(next.contains("'Not right now'"), isTrue);
    });

    test('the stage switch is honest about not being built', () {
      // Pushing a pregnancy home over a toddler's data would be worse than
      // saying so.
      expect(next.contains('coming very') || next.contains('coming soon'), isTrue);
      expect(next.contains('Your parenting side stays exactly'), isTrue);
    });
  });
}

// =============================================================================
//  The other half of the product point: pregnancy AND parenting.
// -----------------------------------------------------------------------------
//  "Currently some diff is there in the format and template across pregnancy
//  and parenting and within parenting as well."
//
//  Within-parenting was one `if (_isSoother)` branch, covered above. This is
//  the across half — the two pages are deliberately NOT the same code (the
//  pregnancy one is bilingual and carries affiliate rules, a cart, a checklist
//  and a week timeline that only means anything before birth), so what is
//  aligned is what a parent actually experiences as "a different template":
//  the section names and their order.
// =============================================================================

void productTemplateAcrossApps() {
  final preg = _code(_read('lib/screens/products_screen.dart'));
  final strings = _read('lib/localization/app_language.dart');

  group('product template across both apps', () {
    test('the shared section names exist in both languages', () {
      for (final getter in [
        'prAtAGlance',
        'prWhatsInside',
        'prPvTake',
        'prVerifiedParents',
        'prCompareAlternatives',
        'prHowWeReview',
      ]) {
        expect(strings.contains('String get $getter'), isTrue,
            reason: '$getter missing');
      }
      // Hindi, not English twice — this screen is bilingual and a section
      // heading that stays English is the tell.
      //
      // This asserts the second argument is *in Devanagari* rather than
      // pinning the exact words. Pinning the copy made this test fail the day
      // the house style moved off Hinglish, which told us nothing about the
      // thing it exists to protect: that the heading was translated at all.
      final devanagari = RegExp(r'[ऀ-ॿ]');
      for (final en in [
        "_p('At a glance',",
        '_p("ParentVeda\'s take",',
        "_p('From verified parents',",
      ]) {
        final at = strings.indexOf(en);
        expect(at, isNot(-1), reason: '$en no longer passed to _p');
        final call = strings.substring(at, strings.indexOf(')', at));
        expect(devanagari.hasMatch(call), isTrue,
            reason: 'the Hindi side of $en is not in Devanagari');
      }
    });

    test('the pregnancy page uses them', () {
      for (final g in [
        's.prAtAGlance',
        's.prPvTake',
        's.prVerifiedParents',
        's.prCompareAlternatives',
        's.prHowWeReview',
      ]) {
        expect(preg.contains(g), isTrue, reason: '$g never rendered');
      }
    });

    test('the old headings are commented, not deleted', () {
      final raw = _read('lib/screens/products_screen.dart');
      for (final old in [
        'Text(s.prVerdict, ...)',
        'Text(s.prWhy, ...)',
        's.prReviewSummary',
        's.prRelated',
      ]) {
        expect(raw.contains(old), isTrue, reason: 'missing revert note: $old');
      }
    });

    test('both apps disclose how a product is reviewed', () {
      expect(preg.contains('_HowWeReviewPreg('), isTrue);
      expect(
          _code(_read('lib/screens/post_pregnancy/product_detail_screen.dart'))
              .contains('_HowWeReview('),
          isTrue);
    });

    test('the shared sections run in the same order in both', () {
      // Only the sections the pregnancy DETAIL page actually renders. The
      // first attempt at this test included prWhatsInside and caught a real
      // mistake: that heading belongs to _GuidanceCard, which is on the
      // CATEGORY screen, so renaming it aligned nothing.
      final order = [
        'prAtAGlance',
        'prPvTake',
        'prVerifiedParents',
        'prHowWeReview',
        'prCompareAlternatives',
      ];
      var last = -1;
      for (final g in order) {
        final at = preg.indexOf('s.$g');
        expect(at, greaterThan(last), reason: '$g is out of order');
        last = at;
      }
    });

    test('the week timeline survives — a stage-specific section is allowed', () {
      // Consistency is about the SHARED sections. A pregnancy page losing its
      // week timeline to match a parenting page would be consistency bought by
      // deleting something useful.
      expect(preg.contains('_WeekTimeline('), isTrue);
    });
  });
}

// =============================================================================
//  The daily pop-up: tip OR video, every open, after the brand ad.
// -----------------------------------------------------------------------------
//  The follow-up ask, in four parts:
//
//    * the pop-up shuffles daily between something to read and something to
//      watch, and both can be saved;
//    * the video plays in place;
//    * it fires AFTER the brand takeover, not racing it;
//    * and the parenting side gains the saved-collections button the pregnancy
//      side has had all along.
// =============================================================================

void dailyPopupAndSaved() {
  final popup = _code(_read('lib/screens/post_pregnancy/daily_tip_popup.dart'));
  final popupRaw = _read('lib/screens/post_pregnancy/daily_tip_popup.dart');
  final hub = _code(_read('lib/screens/post_pregnancy/pp_saved_hub_screen.dart'));
  final child = _code(_read('lib/screens/post_pregnancy/my_child_screen.dart'));

  group('the pop-up alternates', () {
    test('even days read, odd days watch, and it never changes on a reopen', () {
      final even = dailyPopupKind(DateTime(2026, 1, 1).add(const Duration(days: 2)));
      final odd = dailyPopupKind(DateTime(2026, 1, 1).add(const Duration(days: 3)));
      expect(even, isNot(odd));
      // Deterministic: the same day must give the same answer every time, or a
      // parent who closes and reopens gets a different card.
      for (var i = 0; i < 5; i++) {
        expect(dailyPopupKind(DateTime(2026, 4, 7)), dailyPopupKind(DateTime(2026, 4, 7)));
      }
    });

    test('both kinds come round within a week', () {
      final kinds = <DailyPopupKind>{};
      for (var i = 0; i < 7; i++) {
        kinds.add(dailyPopupKind(DateTime(2026, 5, 1).add(Duration(days: i))));
      }
      expect(kinds.length, 2);
    });

    test('a watch-day offers a SHORT video, not a masterclass', () {
      // A pop-up is a thirty-second moment; a twelve-minute video in it is
      // something nobody is about to start.
      for (var i = 0; i < 14; i++) {
        final v = dailyPopupVideo(DateTime(2026, 6, 1).add(Duration(days: i)));
        expect(v.quick, isTrue, reason: '"${v.title}" is not a short');
      }
    });

    test('it does not repeat inside a fortnight', () {
      final seen = <String>{};
      for (var i = 0; i < 12; i++) {
        final v = dailyPopupVideo(DateTime(2026, 6, 1).add(Duration(days: i)));
        expect(seen.add(v.id), isTrue, reason: '"${v.title}" came round again');
      }
    });

    test('the video plays in place and can be saved', () {
      expect(popup.contains("'Watch now'"), isTrue);
      expect(popup.contains('WatchPlayerScreen(video: v)'), isTrue);
      // Saved into the WATCH store, so one saved video is one saved video
      // wherever it was saved from.
      expect(popup.contains('WatchStore.instance.toggleSave(video.id)'), isTrue);
    });

    test('a tip can still be saved and shared', () {
      expect(popup.contains('DailyTipStore.instance.toggleSaved(id)'), isTrue);
      expect(popup.contains('Share.share(dailyTipShareText(tip))'), isTrue);
    });
  });

  group('timing', () {
    test('it fires after the brand takeover, awaited', () {
      // showPremiereIfAny returns a Future that completes when its route pops.
      // Without the await both sheets land in the same frame, stacked.
      final at = child.indexOf('await showPremiereIfAny(');
      final then = child.indexOf('await maybeShowDailyTip(');
      expect(at, greaterThan(-1), reason: 'the brand ad must be awaited');
      expect(then, greaterThan(at), reason: 'the tip must come second');
    });

    test('every open while testing, behind a named flag', () {
      expect(popup.contains('bool kDailyPopupAlwaysShow = true'), isTrue);
      expect(popup.contains('if (!kDailyPopupAlwaysShow && store.shownToday) return;'),
          isTrue);
      // Named to match the other testing override so both turn up in one search.
      expect(
          _code(_read('lib/brand/premiere_screen.dart'))
              .contains('kPremiereAlwaysShow'),
          isTrue);
    });

    test('the flag is loudly marked as launch-blocking', () {
      expect(popupRaw.contains('MUST BE false BEFORE LAUNCH'), isTrue);
    });

    test('it still never fires before the store has loaded', () {
      // The bug found earlier: showing before the cache load finishes would
      // re-show something already dismissed.
      expect(popup.contains('if (!store.isReady) return;'), isTrue);
    });
  });

  group('saved collections on the parenting side', () {
    test('the bookmark sits in the My Child header, like pregnancy', () {
      expect(child.contains('Icons.bookmark_border_rounded'), isTrue);
      expect(child.contains('const PpSavedHubScreen()'), isTrue);
      // Same icon as the pregnancy home, so the two apps read as one product.
      expect(_code(_read('lib/screens/home_screen_b.dart'))
              .contains('Icons.bookmark_border_rounded'),
          isTrue);
    });

    test('it owns no state — it reads the stores that already hold it', () {
      for (final store in [
        'WatchStore.instance',
        'ReadingStore.instance',
        'DailyTipStore.instance',
      ]) {
        expect(hub.contains(store), isTrue, reason: '$store not read');
      }
      // No save state of its own would mean three lists that drift.
      expect(hub.contains('class PpSavedHubStore'), isFalse);
    });

    test('all three groups render even when empty', () {
      // A feature is never hidden for being empty — a parent who has only ever
      // saved videos should still learn reads and tips are savable.
      expect(hub.contains("'Videos'"), isTrue);
      expect(hub.contains("'Reads'"), isTrue);
      expect(hub.contains("'Daily tips'"), isTrue);
      expect(hub.contains('Nothing here yet.'), isTrue);
      expect(hub.contains('count == 0'), isTrue);
    });

    test('anything saved can be unsaved from the list it is in', () {
      expect(hub.contains('onUnsave:'), isTrue);
    });
  });
}
