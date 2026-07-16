// =============================================================================
//  BrandStudio — the resolver
// -----------------------------------------------------------------------------
//  THE ONE RULE: brand content enters the UI through this class and nowhere
//  else. No screen imports kBrandCampaigns. No screen builds a sponsored widget
//  on its own. A surface asks for a SLOT and gets a campaign or null.
//
//  That is what makes "we don't sprinkle banners through the app" a property of
//  the system instead of a promise someone has to remember. If you are reaching
//  for the campaign list inside a screen, that is the bug.
//
//  See docs/BRAND-STUDIO.md. Invariants are pinned in test/brand_studio_test.dart.
// =============================================================================

import 'package:flutter/widgets.dart';

import 'brand_campaigns.dart';
import 'brand_models.dart';
import 'brand_store.dart';

/// Compile-time kill switch for the whole ecosystem.
const bool kBrandStudioEnabled = true;

/// True inside `flutter test`. The test binding's runtime type always contains
/// "Test", so brand surfaces stay out of every existing widget test without
/// per-test wiring. Mirrors `pvIsUnderTest` in the video module.
bool get _isUnderTest => WidgetsBinding.instance.runtimeType.toString().contains('Test');

class BrandStudio extends ChangeNotifier {
  BrandStudio._();
  static final BrandStudio instance = BrandStudio._();

  /// Runtime kill switch. Flipping this false empties every slot in the app,
  /// instantly and globally — no redeploy, no per-screen cleanup.
  bool _enabled = kBrandStudioEnabled;

  /// Set true by the Brand Studio's own tests, which need the engine live.
  /// Every other test gets an inert Studio.
  @visibleForTesting
  bool allowInTests = false;

  bool get enabled {
    if (!kBrandStudioEnabled || !_enabled) return false;
    if (_isUnderTest && !allowInTests) return false;
    return true;
  }

  set enabled(bool v) {
    if (_enabled == v) return;
    _enabled = v;
    notifyListeners();
  }

  /// Overridable so tests drive a known catalogue instead of the seed data.
  List<BrandCampaign> _campaigns = kBrandCampaigns;
  List<BrandCampaign> get campaigns => List.unmodifiable(_campaigns);

  @visibleForTesting
  void setCampaigns(List<BrandCampaign> campaigns) {
    _campaigns = campaigns;
    notifyListeners();
  }

  @visibleForTesting
  void resetCampaigns() {
    _campaigns = kBrandCampaigns;
    notifyListeners();
  }

  /// DEMO MODE — relaxes targeting and caps so every placement is visible.
  ///
  /// Exists because this engine's job is to show almost nothing: with
  /// placeholder sponsors and an empty family profile, a correctly-working
  /// Brand Studio is indistinguishable from one that was never built. That is
  /// fine for a parent and useless for anyone trying to evaluate the thing.
  ///
  /// Demo mode does NOT bypass: the kill switch, `active`, `isLive`, or the
  /// rank floor. It only relaxes who a campaign reaches and how often — so it
  /// can never show you something that could not exist for a real parent.
  bool get demoMode => BrandStudioStore.instance.demoMode;
  set demoMode(bool v) => BrandStudioStore.instance.demoMode = v;

  /// Why this campaign will not show — or null when it will.
  ///
  /// The preview screen renders these verbatim. Written as sentences a person
  /// can act on, not error codes.
  String? blockReason(BrandCampaign c, BrandContext ctx) {
    if (!enabled) return 'The Brand Studio is switched off.';
    if (!c.active) return 'The campaign is not active.';
    if (!c.slot.isLive) {
      return 'The ${c.slot.name} surface does not exist yet, so nothing can run there.';
    }
    if (!c.schedule.isLiveAt(ctx.now)) {
      return ctx.now.isBefore(c.schedule.start)
          ? 'Not started — begins ${_d(c.schedule.start)}.'
          : 'Ended ${_d(c.schedule.end)}.';
    }
    if (!demoMode && !c.audience.matches(ctx)) return _audienceReason(c.audience, ctx);

    final store = BrandStudioStore.instance;
    if (!demoMode && store.dismissed(c.id)) return 'You closed this, so it will not come back.';
    if (!demoMode && c.slot.archetype.isPushed && store.impressions(c.id) >= c.maxImpressions) {
      return 'Already shown ${store.impressions(c.id)} of ${c.maxImpressions} times — its cap is spent.';
    }
    return null;
  }

  static String _d(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _audienceReason(BrandAudience a, BrandContext ctx) {
    if (a.stage != null && a.stage != ctx.stage) {
      return 'Targeted at the ${a.stage!.name} app; you are in the ${ctx.stage.name} app.';
    }
    if (a.anySignal.isNotEmpty && !a.anySignal.any(ctx.signals.contains)) {
      return 'Needs one of: ${a.anySignal.join(', ')} — set it in My Family Profile.';
    }
    if (a.childAgeMonthsMin != null || a.childAgeMonthsMax != null) {
      if (ctx.childAgeMonths == null) {
        return "Targeted by the child's age, and no real child is saved yet.";
      }
      return 'For children ${a.childAgeMonthsMin ?? 0}–${a.childAgeMonthsMax ?? 99} months; yours is ${ctx.childAgeMonths}.';
    }
    if (a.pregnancyWeekMin != null || a.pregnancyWeekMax != null) {
      if (ctx.pregnancyWeek == null) return 'Targeted by pregnancy week, which this screen did not pass in.';
      return 'For weeks ${a.pregnancyWeekMin ?? 0}–${a.pregnancyWeekMax ?? 42}; you are at ${ctx.pregnancyWeek}.';
    }
    return 'Does not match this parent.';
  }

  /// Is this campaign allowed to be shown to this parent, right now?
  ///
  /// Every clause here fails CLOSED. When we cannot verify something, the
  /// parent sees nothing — that is always the cheaper mistake.
  bool isEligible(BrandCampaign c, BrandContext ctx) => blockReason(c, ctx) == null;

  /// The Launch Hub campaign a Premiere announces, if it is still available.
  ///
  /// Audience is NOT re-checked here: the parent has already been shown the
  /// Premiere and tapped through deliberately. Dead-ending them on a "nothing
  /// here" screen because the linked launch targets a slightly different
  /// segment would be a bug, not a safeguard.
  BrandCampaign? linkedLaunch(BrandCampaign premiere, BrandContext ctx) {
    final id = premiere.linkedCampaignId;
    if (id == null) return null;
    for (final c in _campaigns) {
      if (c.id == id && c.active) return c;
    }
    return null;
  }

  /// The single entry point. Returns the campaign for [slot], or null.
  ///
  /// Null is the overwhelmingly common answer, and callers must treat it as
  /// completely ordinary — an empty slot is the app working correctly, not a
  /// gap to fill.
  ///
  /// [placementKey] names the instance (which tool, which collection). It is
  /// matched exactly: a campaign that named a placement never appears anywhere
  /// else, and a request for a placement never picks up an unkeyed campaign.
  BrandCampaign? resolve(BrandSlot slot, BrandContext ctx, {String? placementKey}) {
    if (!enabled) return null;
    for (final c in _campaigns) {
      if (c.slot != slot) continue;
      if (c.placementKey != placementKey) continue;
      if (isEligible(c, ctx)) return c;
    }
    return null;
  }

  /// Every eligible campaign for a slot — for the Launch Hub, which lists them.
  List<BrandCampaign> resolveAll(BrandSlot slot, BrandContext ctx, {String? placementKey}) {
    if (!enabled) return const [];
    return _campaigns
        .where((c) => c.slot == slot && c.placementKey == placementKey && isEligible(c, ctx))
        .toList();
  }

  /// Campaigns for the Launch Hub archive: past launches a parent can revisit.
  ///
  /// Deliberately ignores the frequency cap and the schedule — a launch a
  /// parent chooses to look up again is not an impression being spent on them.
  /// Still respects targeting and the kill switch.
  List<BrandCampaign> archiveFor(BrandSlot slot, BrandContext ctx) {
    if (!enabled) return const [];
    return _campaigns
        .where((c) => c.slot == slot && c.active && c.slot.isLive && c.audience.matches(ctx))
        .toList();
  }
}
