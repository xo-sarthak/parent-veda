// =============================================================================
//  Brand Studio — the trust invariants
// -----------------------------------------------------------------------------
//  These are the architecture. docs/BRAND-STUDIO.md §7 describes them in prose;
//  this file is what actually holds the line. If a change here starts failing,
//  the correct response is almost never to edit the test.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_campaigns.dart';
import 'package:parentveda/brand/brand_disclosure.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/launch_hub_screen.dart';
import 'package:parentveda/screens/product_guide/product_guide_data.dart';

const _brandA = Brand(id: 'brand_a', name: 'BrandA', colour: Color(0xFF2E7D6B));

BrandCreative _creative() => const BrandCreative(
      eyebrow: 'New',
      headline: 'A Thing',
      subline: 'It does a thing.',
      story: 'A story about the thing.',
      cta: 'See it',
    );

BrandSchedule _live() => BrandSchedule(start: DateTime(2020), end: DateTime(2030));

BrandCampaign _campaign({
  String id = 'c1',
  BrandSlot slot = BrandSlot.premiere,
  BrandAudience audience = BrandAudience.everyone,
  BrandSchedule? schedule,
  int maxImpressions = 1,
  bool active = true,
}) =>
    BrandCampaign(
      id: id,
      brand: _brandA,
      slot: slot,
      creative: _creative(),
      schedule: schedule ?? _live(),
      audience: audience,
      maxImpressions: maxImpressions,
      active: active,
    );

BrandContext _ctx({
  BrandStage stage = BrandStage.parenting,
  Set<String> signals = const {},
  int? childAgeMonths,
  int? pregnancyWeek,
  DateTime? now,
}) =>
    BrandContext(
      stage: stage,
      now: now ?? DateTime(2026, 7, 15),
      signals: signals,
      childAgeMonths: childAgeMonths,
      pregnancyWeek: pregnancyWeek,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true; // this suite needs the engine live
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
  });

  tearDown(() {
    BrandStudio.instance.allowInTests = false;
    BrandStudio.instance.resetCampaigns();
  });

  // ---- 1 · slot isolation ---------------------------------------------------
  test('a campaign never resolves into a slot it was not declared for', () {
    BrandStudio.instance.setCampaigns([_campaign(slot: BrandSlot.premiere)]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNotNull);
    expect(BrandStudio.instance.resolve(BrandSlot.launchHub, _ctx()), isNull);
  });

  test('the sponsored-notification slot is live and targets correctly', () {
    // Was the last unbuilt slot; now built (BrandNotifications + the demo
    // campaign). Being LIVE does not mean being loose: a pushed notification
    // must still reach only a parent it targets.
    expect(BrandSlot.sponsoredNotification.isLive, isTrue);

    // Targeted at breastfeeding — resolves for a matching parent...
    BrandStudio.instance.setCampaigns([
      _campaign(
        slot: BrandSlot.sponsoredNotification,
        audience: const BrandAudience(anySignal: {'breastfeeding'}),
      ),
    ]);
    expect(
      BrandStudio.instance.resolve(BrandSlot.sponsoredNotification,
          _ctx(signals: {'breastfeeding'})),
      isNotNull,
    );
    // ...and NOT for a parent who never said so.
    expect(
      BrandStudio.instance.resolve(BrandSlot.sponsoredNotification, _ctx()),
      isNull,
      reason: 'a pushed notification to an untargeted parent is exactly the '
          'thing this slot must never do',
    );
  });

  test('the research surfaces are live, and their hard rules still hold', () {
    // Products 4 + 6 were built at the product owner's direction despite
    // contradicting the shipped "never on your research pages" copy. The copy
    // was narrowed to match reality, and each surface carries a visible
    // NeedsAttentionFlag in debug. What must NOT bend is below.
    expect(BrandSlot.compareGuide.isLive, isTrue);
    expect(BrandSlot.productGuideExpert.isLive, isTrue);
    expect(BrandSlot.productGuideResearch.isLive, isTrue);
    // They are presented-by: a brand funds the section, never writes it.
    for (final s in [BrandSlot.compareGuide, BrandSlot.productGuideExpert, BrandSlot.productGuideResearch]) {
      expect(s.archetype, BrandArchetype.presentedBy);
      expect(s.archetype.isPushed, isFalse, reason: 'a research sponsor must never be pushed at anyone');
    }
  });

  test('THE regression: the Premiere must actually be able to show', () {
    // It could not, for days: the only trigger is the pregnancy shell asking
    // for pregnancy-stage campaigns, and the only Premiere targeted parenting.
    // Every invariant passed because they all check that things correctly do
    // NOT show. None checked that anything ever does.
    final premieres = kBrandCampaigns.where((c) => c.slot == BrandSlot.premiere);
    expect(premieres, isNotEmpty);
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    for (final stage in BrandStage.values) {
      final shown = BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(stage: stage));
      expect(shown, isNotNull, reason: 'no Premiere can ever render in the ${stage.name} app');
    }
  });

  test('every live slot has at least one campaign that can actually render', () {
    // The general form of the bug above: a placement that is switched on but
    // unreachable is worse than one that is switched off, because it looks
    // built. Demo mode relaxes targeting, so this asks "could this EVER show".
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    BrandStudio.instance.demoMode = true;
    addTearDown(() => BrandStudio.instance.demoMode = false);

    for (final c in kBrandCampaigns) {
      if (!c.slot.isLive) continue;
      // Ask the way the real surface asks: in the campaign's own stage, with
      // its own placement key.
      final stage = c.audience.stage ?? BrandStage.parenting;
      final got = BrandStudio.instance.resolve(
        c.slot,
        _ctx(stage: stage),
        placementKey: c.placementKey,
      );
      expect(got, isNotNull,
          reason: '${c.id} (${c.slot.name}) is switched on but can never render '
              'anywhere — worse than being switched off, because it looks built');
    }
  });

  test('demo mode relaxes targeting but never the things that protect a parent', () {
    BrandStudio.instance.setCampaigns([
      _campaign(audience: const BrandAudience(anySignal: {'breastfeeding'})),
    ]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);

    BrandStudio.instance.demoMode = true;
    addTearDown(() => BrandStudio.instance.demoMode = false);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNotNull,
        reason: 'demo mode should reveal a targeted campaign');

    // But it must never override the kill switch...
    BrandStudio.instance.enabled = false;
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
    BrandStudio.instance.enabled = true;
    // (The old "nor an unbuilt surface" check retired here — every slot is
    // built now, so there is no unbuilt surface left to demo-reveal.)
  });

  test('every blocked campaign explains itself in a sentence', () {
    // The preview screen renders these verbatim, so an empty or lazy reason is
    // a real defect — it is the only thing standing between "it works" and
    // "I cannot tell whether it works".
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    final ctx = _ctx();
    for (final c in kBrandCampaigns) {
      final why = BrandStudio.instance.blockReason(c, ctx);
      if (why == null) continue;
      expect(why.trim(), isNotEmpty, reason: '${c.id} is blocked with no reason given');
      expect(why.length, greaterThan(12), reason: '${c.id}: "$why" does not explain anything');
    }
  });

  test('a campaign never leaks onto a placement it did not name', () {
    // Buying "tool sponsorship" must not brand every tool in the app.
    BrandStudio.instance.setCampaigns([
      BrandCampaign(
        id: 'tool_sleep',
        brand: _brandA,
        slot: BrandSlot.sponsoredTool,
        creative: _creative(),
        schedule: _live(),
        placementKey: 'sleep_tracker',
      ),
    ]);
    expect(
      BrandStudio.instance.resolve(BrandSlot.sponsoredTool, _ctx(), placementKey: 'sleep_tracker'),
      isNotNull,
    );
    expect(
      BrandStudio.instance.resolve(BrandSlot.sponsoredTool, _ctx(), placementKey: 'growth_journey'),
      isNull,
      reason: 'a campaign named one tool and appeared on another',
    );
    expect(
      BrandStudio.instance.resolve(BrandSlot.sponsoredTool, _ctx()),
      isNull,
      reason: 'an unkeyed request picked up a keyed campaign',
    );
  });

  // ---- 2 · once per campaign, and it persists -------------------------------
  test('Premiere shows once per campaign, not once per launch', () {
    BrandStudio.instance.setCampaigns([_campaign(id: 'p1', maxImpressions: 1)]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNotNull);

    BrandStudioStore.instance.recordImpression('p1');

    // The old promo used an in-memory bool, so this came back on every restart.
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
  });

  test('a dismissed campaign never returns', () {
    BrandStudio.instance.setCampaigns([_campaign(id: 'p1', maxImpressions: 5)]);
    BrandStudioStore.instance.markDismissed('p1');
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
  });

  test('a destination is visited, so it never spends an impression', () {
    BrandStudio.instance.setCampaigns([_campaign(id: 'h1', slot: BrandSlot.launchHub)]);
    for (var i = 0; i < 5; i++) {
      BrandStudioStore.instance.recordImpression('h1');
    }
    expect(BrandStudio.instance.resolve(BrandSlot.launchHub, _ctx()), isNotNull);
  });

  // ---- 3 · targeting narrows ------------------------------------------------
  test('a targeted campaign does not resolve for a parent who lacks the signal', () {
    BrandStudio.instance.setCampaigns([
      _campaign(audience: const BrandAudience(anySignal: {'breastfeeding'})),
    ]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
    expect(
      BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(signals: {'breastfeeding'})),
      isNotNull,
    );
  });

  test('an age-banded campaign does not resolve for an unknown or outside age', () {
    BrandStudio.instance.setCampaigns([
      _campaign(audience: const BrandAudience(childAgeMonthsMin: 4, childAgeMonthsMax: 9)),
    ]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull, reason: 'unknown age must fail closed');
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(childAgeMonths: 2)), isNull);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(childAgeMonths: 6)), isNotNull);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(childAgeMonths: 20)), isNull);
  });

  test('a campaign never crosses the pregnancy / parenting divide', () {
    BrandStudio.instance.setCampaigns([
      _campaign(audience: const BrandAudience(stage: BrandStage.pregnancy)),
    ]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(stage: BrandStage.parenting)), isNull);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(stage: BrandStage.pregnancy)), isNotNull);
  });

  // ---- 4 · personalization improves relevance, never volume ----------------
  //
  // The distinction that makes this tractable: PUSHED content (a takeover, a
  // notification) is delivered to a parent whether they asked or not, so its
  // volume must not grow with what we know about them. PULLED content (the
  // Launch Hub) is a place they chose to open, where more relevant launches is
  // the point. See docs/BRAND-STUDIO.md §5.

  test('a rich profile can never stack up more pushed takeovers than an empty one', () {
    // The real risk, and the one a naive implementation walks into: three
    // differently-targeted Premieres, and the parent who told us most gets
    // interrupted three times while the parent who told us nothing gets once.
    // resolve() returning a single campaign is what structurally prevents it.
    BrandStudio.instance.setCampaigns([
      _campaign(id: 'p_bf', audience: const BrandAudience(anySignal: {'breastfeeding'})),
      _campaign(id: 'p_ecz', audience: const BrandAudience(anySignal: {'eczema'})),
      _campaign(id: 'p_age', audience: const BrandAudience(childAgeMonthsMin: 1, childAgeMonthsMax: 24)),
    ]);

    final full = _ctx(signals: {'breastfeeding', 'eczema'}, childAgeMonths: 6);
    // Matches all three...
    expect(BrandStudio.instance.resolveAll(BrandSlot.premiere, full).length, 3);
    // ...but a takeover slot surfaces exactly one, ever.
    final shown = BrandStudio.instance.resolve(BrandSlot.premiere, full);
    expect(shown, isNotNull);

    BrandStudioStore.instance.recordImpression(shown!.id);
    final next = BrandStudio.instance.resolve(BrandSlot.premiere, full);
    expect(next?.id, isNot(shown.id), reason: 'a spent campaign must not resurface');
  });

  test('a campaign cap belongs to the campaign, never to the profile', () {
    // No audience field can raise maxImpressions — there is no path from
    // knowing more about a family to showing them the same thing more often.
    for (final c in kBrandCampaigns) {
      final rich = _ctx(
        signals: {'breastfeeding', 'eczema', 'sleep', 'mixed', 'expressed'},
        childAgeMonths: 6,
        pregnancyWeek: 10,
        stage: c.audience.stage ?? BrandStage.parenting,
      );
      if (!c.audience.matches(rich)) continue;
      // Spend the cap, then confirm a rich profile buys no extra showings.
      for (var i = 0; i < c.maxImpressions; i++) {
        BrandStudioStore.instance.recordImpression(c.id);
      }
      // Only PUSHED content is capped. A destination the parent opened, or a
      // sponsor line on a tool they chose to use, is attribution rather than an
      // interruption — capping those would make the disclosure vanish mid-use,
      // which is worse for the parent than seeing who funded it.
      if (c.slot.archetype.isPushed) {
        expect(BrandStudio.instance.isEligible(c, rich), isFalse,
            reason: '${c.id} kept showing past its cap for a rich profile');
      }
      BrandStudioStore.instance.resetAll();
    }
  });

  test('personalization can only narrow a fixed catalogue, never invent a campaign', () {
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    final full = _ctx(
      signals: {'breastfeeding', 'eczema', 'sleep', 'mixed', 'expressed'},
      childAgeMonths: 6,
      pregnancyWeek: 10,
    );
    for (final slot in BrandSlot.values) {
      for (final c in BrandStudio.instance.resolveAll(slot, full)) {
        expect(kBrandCampaigns.contains(c), isTrue,
            reason: 'a profile conjured a campaign that was never sold');
      }
    }
  });

  test('the Launch Hub deliberately shows more to a parent who told us more', () {
    // Documenting the ONE place where knowing more surfaces more, and why that
    // is correct: a destination is opened on purpose. A breastfeeding mother
    // should find the nursing launch here. A mother who told us nothing is not
    // shown it — targeting fails closed, so silence costs a parent nothing.
    BrandStudio.instance.setCampaigns(kBrandCampaigns);

    final quiet = _ctx();
    final told = _ctx(signals: {'breastfeeding'}, childAgeMonths: 6);

    final quietHub = BrandStudio.instance.archiveFor(BrandSlot.launchHub, quiet);
    final toldHub = BrandStudio.instance.archiveFor(BrandSlot.launchHub, told);

    expect(toldHub.length, greaterThan(quietHub.length));
    expect(quietHub.any((c) => c.id == 'launch_mamabloom_nursing'), isFalse);
    expect(toldHub.any((c) => c.id == 'launch_mamabloom_nursing'), isTrue);
  });

  test('every audience field only ever narrows', () {
    const unconstrained = BrandAudience.everyone;
    expect(unconstrained.isUnconstrained, isTrue);
    // Anything the unconstrained audience rejects, a constrained one must too.
    const constrained = BrandAudience(anySignal: {'breastfeeding'});
    final ctx = _ctx();
    expect(unconstrained.matches(ctx), isTrue);
    expect(constrained.matches(ctx), isFalse);
  });

  // ---- 5 · kill switch ------------------------------------------------------
  test('the kill switch empties every slot in the app', () {
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    BrandStudio.instance.enabled = false;
    final ctx = _ctx(signals: {'breastfeeding'}, childAgeMonths: 6);
    for (final slot in BrandSlot.values) {
      expect(BrandStudio.instance.resolve(slot, ctx), isNull, reason: 'slot ${slot.name} survived the kill switch');
      expect(BrandStudio.instance.resolveAll(slot, ctx), isEmpty);
      expect(BrandStudio.instance.archiveFor(slot, ctx), isEmpty);
    }
  });

  test('brand surfaces stay out of unrelated widget tests by default', () {
    BrandStudio.instance.allowInTests = false;
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
  });

  // ---- 6 · schedule ---------------------------------------------------------
  test('campaigns outside their window never resolve', () {
    BrandStudio.instance.setCampaigns([
      _campaign(schedule: BrandSchedule(start: DateTime(2026, 8, 1), end: DateTime(2026, 9, 1))),
    ]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(now: DateTime(2026, 7, 15))), isNull,
        reason: 'not started');
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(now: DateTime(2026, 8, 15))), isNotNull);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx(now: DateTime(2026, 9, 2))), isNull,
        reason: 'expired');
  });

  test('an inactive campaign never resolves', () {
    BrandStudio.instance.setCampaigns([_campaign(active: false)]);
    expect(BrandStudio.instance.resolve(BrandSlot.premiere, _ctx()), isNull);
  });

  // ---- 7 · ratings are untouchable -----------------------------------------
  test('ParentVeda ratings are identical with the Brand Studio on, off and live', () {
    // parentScore/parentsPct/expertsPct derive only from `rating` + `reco`,
    // both hand-seeded editorial fields. No sponsor data may ever reach them.
    Map<String, List<int>> snapshot() => {
          for (final g in kProductGuides) g.id: [g.parentScore, g.parentsPct, g.expertsPct],
        };

    BrandStudio.instance.enabled = false;
    final off = snapshot();

    BrandStudio.instance.enabled = true;
    BrandStudio.instance.setCampaigns(kBrandCampaigns);
    final on = snapshot();

    expect(on, equals(off), reason: 'a live campaign moved a ParentVeda rating');

    // And specifically with a campaign live for a brand that has guides.
    final brands = kProductGuides.map((g) => g.brand).toSet();
    expect(brands, isNotEmpty);
    BrandStudio.instance.setCampaigns([
      BrandCampaign(
        id: 'sponsor_test',
        brand: Brand(id: 'x', name: brands.first, colour: const Color(0xFF000000)),
        slot: BrandSlot.premiere,
        creative: _creative(),
        schedule: _live(),
      ),
    ]);
    expect(snapshot(), equals(off), reason: 'sponsoring a brand moved its own product rating');
  });

  // ---- 8 · disclosure is not optional --------------------------------------
  test('every campaign carries a non-empty disclosure it did not write', () {
    for (final c in kBrandCampaigns) {
      expect(c.disclosure.trim(), isNotEmpty, reason: '${c.id} has no disclosure');
      expect(c.disclosure, contains(c.brand.name));
      expect(c.independenceNote, contains('did not write'));
    }
  });

  testWidgets('a launch always renders its disclosure and independence note', (tester) async {
    final launch = kBrandCampaigns.firstWhere((c) => c.slot == BrandSlot.launchHub);
    await tester.pumpWidget(MaterialApp(home: LaunchDetailScreen(campaign: launch)));
    await tester.pump();

    expect(find.text(launch.disclosure.toUpperCase()), findsWidgets);
    expect(find.byType(SponsorDisclosure), findsWidgets);
    expect(find.text(launch.independenceNote), findsOneWidget);
  });

  // ---- 9 · certification is not for sale -----------------------------------
  test('no seeded brand is certified, and campaigns cannot confer certification', () {
    // `certified` lives on Brand, never on BrandCampaign — so there is no field
    // a campaign could set. This test pins that it stays that way.
    for (final b in kBrands) {
      expect(b.certified, isFalse, reason: '${b.name} was certified by seed data, not by evaluation');
    }
  });

  // ---- 10 · the seed catalogue is coherent ---------------------------------
  test('every Premiere links to a launch that actually exists', () {
    for (final c in kBrandCampaigns.where((c) => c.slot == BrandSlot.premiere)) {
      final id = c.linkedCampaignId;
      expect(id, isNotNull, reason: '${c.id} is a takeover with nowhere to land');
      expect(
        kBrandCampaigns.any((o) => o.id == id && o.slot == BrandSlot.launchHub),
        isTrue,
        reason: '${c.id} links to a missing launch',
      );
    }
  });

  test('campaign ids are unique', () {
    final ids = kBrandCampaigns.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
