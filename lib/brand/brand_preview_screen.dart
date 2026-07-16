// =============================================================================
//  Brand Studio preview — seeing an engine whose job is to show nothing
// -----------------------------------------------------------------------------
//  The Brand Studio is mostly invisible on purpose: it resolves to null for
//  almost every parent, almost always. That is correct behaviour and it is also
//  indistinguishable, from the outside, from a thing that was never built.
//
//  This page is the answer. Every campaign, whether it will show, and if not,
//  the exact reason in a sentence you can act on. Plus a demo toggle that
//  relaxes targeting so you can walk the app and actually see the placements.
//
//  Debug builds only. This is a workbench, not a feature.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_context.dart';
import 'brand_models.dart';
import 'brand_store.dart';
import 'brand_studio.dart';
import 'needs_attention.dart';

const _bg = Color(0xFFFBF9FE);
const _ink = Color(0xFF2F2C30);
const _soft = Color(0xFF69636C);
const _line = Color(0xFFE4E2E5);
const _purple = Color(0xFF6A30B6);
const _green = Color(0xFF3FA56A);
const _red = Color(0xFFD92D20);

TextStyle _t(double s, {FontWeight w = FontWeight.w400, Color c = _ink, double h = 1.4}) =>
    GoogleFonts.manrope(fontSize: s, fontWeight: w, color: c, height: h);

class BrandPreviewScreen extends StatefulWidget {
  const BrandPreviewScreen({super.key, this.pregnancyWeek});
  final int? pregnancyWeek;

  @override
  State<BrandPreviewScreen> createState() => _BrandPreviewScreenState();
}

class _BrandPreviewScreenState extends State<BrandPreviewScreen> {
  BrandStage _stage = BrandStage.parenting;

  @override
  Widget build(BuildContext context) {
    final studio = BrandStudio.instance;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Brand Studio', style: _t(17, w: FontWeight.w800)),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([studio, BrandStudioStore.instance]),
        builder: (context, _) {
          final ctx = captureBrandContext(stage: _stage, pregnancyWeek: widget.pregnancyWeek);
          final campaigns = studio.campaigns;
          final live = campaigns.where((c) => studio.isEligible(c, ctx)).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
            children: [
              Text(
                'An engine whose job is to show almost nothing. This page is the only way to see it working.',
                style: _t(13, c: _soft, h: 1.55),
              ),
              const SizedBox(height: 18),
              _controls(studio),
              const SizedBox(height: 18),
              _context(ctx, live, campaigns.length),
              const SizedBox(height: 22),
              Text('CAMPAIGNS', style: _t(10, w: FontWeight.w800, c: _soft)),
              const SizedBox(height: 4),
              Text(
                'Tap a slot name to learn what it is. A blocked campaign says exactly why.',
                style: _t(11.5, c: _soft),
              ),
              const SizedBox(height: 12),
              for (final c in campaigns) _campaignCard(c, ctx),
              const SizedBox(height: 24),
              Text('FLAGGED FOR YOU', style: _t(10, w: FontWeight.w800, c: _red)),
              const SizedBox(height: 4),
              Text(
                'Things that got built despite a real argument against them. Each one is a decision waiting on you.',
                style: _t(11.5, c: _soft),
              ),
              const SizedBox(height: 12),
              for (final f in BrandFlag.values) _flagRow(f),
              const SizedBox(height: 24),
              _slotTable(),
            ],
          );
        },
      ),
    );
  }

  // ---- controls -------------------------------------------------------------
  Widget _controls(BrandStudio studio) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _switchRow(
            'Demo mode',
            'Relax targeting and caps so every placement is visible. Never bypasses the kill switch or the rank floor — it cannot show you something a real parent could not see.',
            studio.demoMode,
            (v) => setState(() => studio.demoMode = v),
          ),
          const Divider(height: 26, color: _line),
          _switchRow(
            'Brand Studio enabled',
            'The kill switch. Off empties every slot in the app instantly.',
            studio.enabled,
            (v) => setState(() => studio.enabled = v),
          ),
          const Divider(height: 26, color: _line),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Replay everything', style: _t(14, w: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('Clears impressions and dismissals so a Premiere can be watched again.', style: _t(11.5, c: _soft)),
              ]),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                BrandStudioStore.instance.replayAll();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset — restart the app to see the Premiere'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Text('Reset', style: _t(12.5, w: FontWeight.w800, c: _purple)),
            ),
          ]),
          const Divider(height: 26, color: _line),
          Text('Preview as', style: _t(14, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [
            for (final s in BrandStage.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s.name, style: _t(12, w: FontWeight.w700, c: _stage == s ? Colors.white : _ink)),
                  selected: _stage == s,
                  selectedColor: _purple,
                  onSelected: (_) => setState(() => _stage = s),
                ),
              ),
          ]),
        ]),
      );

  Widget _switchRow(String title, String sub, bool value, ValueChanged<bool> onChanged) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: _t(14, w: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(sub, style: _t(11.5, c: _soft, h: 1.45)),
            ]),
          ),
          const SizedBox(width: 12),
          Switch(value: value, activeThumbColor: _purple, onChanged: onChanged),
        ],
      );

  // ---- who we think you are -------------------------------------------------
  Widget _context(BrandContext ctx, int live, int total) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF3EEF7), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WHAT THE STUDIO KNOWS ABOUT YOU', style: _t(10, w: FontWeight.w800, c: _purple)),
          const SizedBox(height: 10),
          Text(
            'This is everything targeting can see. It is read from your family profile — nothing else.',
            style: _t(11.5, c: _soft, h: 1.45),
          ),
          const SizedBox(height: 12),
          _kv('Stage', ctx.stage.name),
          _kv('Child age', ctx.childAgeMonths == null ? 'unknown (no real child saved)' : '${ctx.childAgeMonths} months'),
          _kv('Pregnancy week', ctx.pregnancyWeek?.toString() ?? 'not passed in on this screen'),
          _kv('Signals', ctx.signals.isEmpty ? 'none — profile is empty' : ctx.signals.join(', ')),
          const SizedBox(height: 8),
          Text('$live of $total campaigns would show right now.', style: _t(12.5, w: FontWeight.w800, c: _purple)),
        ]),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 108, child: Text(k, style: _t(12, c: _soft, w: FontWeight.w700))),
          Expanded(child: Text(v, style: _t(12, w: FontWeight.w600))),
        ]),
      );

  // ---- one campaign ---------------------------------------------------------
  Widget _campaignCard(BrandCampaign c, BrandContext ctx) {
    final why = BrandStudio.instance.blockReason(c, ctx);
    final ok = why == null;
    final store = BrandStudioStore.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ok ? _green.withValues(alpha: 0.45) : _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c.brand.colour, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(c.creative.headline, style: _t(14, w: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: (ok ? _green : _soft).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ok ? 'SHOWING' : 'BLOCKED',
              style: _t(9, w: FontWeight.w800, c: ok ? _green : _soft),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _pill(c.slot.name),
          const SizedBox(width: 6),
          _pill(c.slot.archetype.name),
          if (c.placementKey != null) ...[const SizedBox(width: 6), _pill('→ ${c.placementKey}')],
        ]),
        const SizedBox(height: 10),
        Text(
          ok
              ? _whereToSee(c)
              : why,
          style: _t(12, c: ok ? _green : _soft, h: 1.45, w: FontWeight.w600),
        ),
        if (c.slot.archetype.isPushed) ...[
          const SizedBox(height: 6),
          Text('Shown ${store.impressions(c.id)} of ${c.maxImpressions} times.', style: _t(11, c: _soft)),
        ],
      ]),
    );
  }

  /// Where to physically go in the app to see this. The thing that was missing.
  String _whereToSee(BrandCampaign c) => switch (c.slot) {
        BrandSlot.premiere => 'Open the app fresh (Reset above first) — it fires once on launch.',
        BrandSlot.launchHub => 'Tools → Launches',
        BrandSlot.sponsoredEducation => 'Explore → Learn → the "${c.placementKey}" collection',
        BrandSlot.sponsoredTool => 'Tools → Sleep journey',
        BrandSlot.sponsoredMilestone => 'Tools → Development journey',
        BrandSlot.sponsoredJourney => 'Explore → Guided journeys',
        BrandSlot.communityCampaign => 'Community → scroll the feed',
        BrandSlot.liveSession => 'Pregnancy → Prepare tab',
        BrandSlot.recoFeatured => 'Explore → Recommendations (labelled SPONSORED)',
        BrandSlot.sponsoredCollection => 'Recommendations → Sensory Play collection',
        BrandSlot.productGuideExpert => 'Tools → Product Guide → any guide → Expert videos',
        BrandSlot.productGuideResearch => 'Tools → Product Guide → any guide → Research Corner',
        BrandSlot.compareGuide => 'Tools → Compare products → pick two',
        BrandSlot.nativeDiscovery => 'Anywhere a product is named in an article',
        BrandSlot.productSampling => 'Explore → Recommendations',
        BrandSlot.sponsoredNotification => 'Not built — no notification seam yet.',
      };

  Widget _pill(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF3EEF7), borderRadius: BorderRadius.circular(6)),
        child: Text(s, style: _t(9.5, w: FontWeight.w700, c: _purple)),
      );

  // ---- flags ----------------------------------------------------------------
  Widget _flagRow(BrandFlag f) {
    final info = kBrandFlags[f]!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showBrandFlagSheet(context, f),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _red.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.flag_rounded, size: 14, color: _red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(info.title, style: _t(13, w: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(info.where, style: _t(11, c: _soft)),
            ]),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: _red),
        ]),
      ),
    );
  }

  // ---- the whole placement map ----------------------------------------------
  Widget _slotTable() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EVERY PLACEMENT', style: _t(10, w: FontWeight.w800, c: _soft)),
          const SizedBox(height: 4),
          Text(
            'The complete list. A closed set — a placement cannot exist unless it is here.',
            style: _t(11.5, c: _soft),
          ),
          const SizedBox(height: 12),
          for (final s in BrandSlot.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                Icon(
                  s.isLive ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                  size: 13,
                  color: s.isLive ? _green : _soft,
                ),
                const SizedBox(width: 9),
                Expanded(child: Text(s.name, style: _t(12, w: FontWeight.w600))),
                Text(s.archetype.name, style: _t(10.5, c: _soft)),
              ]),
            ),
        ]),
      );
}

/// Debug-only entry point. Returns an empty widget in release so the workbench
/// can never appear in a parent's app.
Widget brandPreviewEntry(BuildContext context, {int? pregnancyWeek, required Widget Function(VoidCallback) builder}) {
  if (!kDebugMode) return const SizedBox.shrink();
  return builder(() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => BrandPreviewScreen(pregnancyWeek: pregnancyWeek)),
      ));
}
