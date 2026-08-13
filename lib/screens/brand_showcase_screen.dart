// =============================================================================
//  Brand Showcase — the Brand Studio, walkable end to end
// -----------------------------------------------------------------------------
//  The problem this solves: the Brand Studio was fully built and completely
//  invisible. Its placements are - correctly - quiet, contextual and rare, so
//  someone handed the app could not tell the feature existed. A monetization
//  architecture nobody can see is indistinguishable from one nobody built.
//
//  This is the guided tour. All 15 brand products in one list: what each one
//  is, where it lives, whether it is live, and a "Show me" that switches demo
//  mode on and takes you straight to the real placement in the real app. Not a
//  mock, not a description - the actual surface, in context.
//
//  Distinct from BrandPreviewScreen, which stays: that is a DIAGNOSTIC (which
//  campaigns resolve, and the exact reason when they do not). This one is for
//  showing the feature to a person.
// =============================================================================

import 'package:flutter/material.dart';

import '../brand/brand_campaigns.dart';
import '../brand/brand_mark.dart';
import '../brand/brand_models.dart';
import '../brand/brand_store.dart';
import '../brand/brand_studio.dart';
import '../brand/launch_hub_screen.dart';
import '../brand/premiere_screen.dart';
import 'post_pregnancy/journeys_screen.dart';
import 'post_pregnancy/products_compare_screen.dart';
import 'post_pregnancy/reading_home_screen.dart';
import 'post_pregnancy/recommendations_screen.dart';
import 'post_pregnancy/sleep_journey_screen.dart';
import 'prepare/prepare_hub_screen.dart';
import '../theme/pv_fonts.dart';
import '../localization/app_language.dart';

const _bg = Color(0xFFFBF9FE);
const _ink = Color(0xFF2F2C30);
const _soft = Color(0xFF69636C);
const _line = Color(0xFFE7E3EE);
const _purple = Color(0xFF6A30B6);

/// One row of the tour.
class _Product {
  const _Product(this.number, this.slot, this.title, this.what, this.where,
      {this.stars = 0, this.built = true, this.note});
  final int number;
  final BrandSlot? slot;
  final String title;
  final String what;
  final String where;
  final int stars;
  final bool built;
  final String? note;
}

const List<_Product> _products = [
  _Product(1, BrandSlot.premiere, 'ParentVeda Premiere',
      'A full-screen launch film on app open. 3-6 times a year, once per campaign, always skippable. The only interruption the Studio permits.',
      'Fires on app open, both apps', stars: 5),
  _Product(2, BrandSlot.launchHub, 'Exclusive Launch Hub',
      'A launch\'s permanent home - story, expert introduction, highlights, resources. An Apple Event, not a catalogue.',
      'Tools → Launches', stars: 5),
  _Product(3, BrandSlot.sponsoredEducation, 'Sponsored Educational Experiences',
      'A brand pays for a ParentVeda collection to exist. It never touches what the collection says.',
      'Explore → READ → a collection', stars: 5),
  _Product(4, BrandSlot.productGuideExpert, 'Product Guide Sponsorship',
      'Expert videos and the research corner inside a Product Guide can be sponsored. Ratings are untouchable.',
      'Tools → Product Guide → any guide'),
  _Product(5, BrandSlot.recoFeatured, 'Recommendation Sponsorship',
      'A featured pick inside the recommendation engine. Money buys the right to be CONSIDERED - never a rank bonus.',
      'Explore → Recommendations', stars: 5),
  _Product(6, BrandSlot.compareGuide, 'Compare Tool Sponsorship',
      'Buying guides and comparison notes may be sponsored. The comparison data itself never moves.',
      'Explore → Products → Compare'),
  _Product(7, BrandSlot.sponsoredJourney, 'Sponsored Parenting Journeys',
      'A multi-day guided journey a brand supports. The journey stays ParentVeda\'s content.',
      'Explore → Guided journeys'),
  _Product(8, BrandSlot.sponsoredTool, 'Tool Sponsorship',
      'A quiet supported-by line on a tool a parent chose to open. Never dominates the screen.',
      'Tools → Sleep journey'),
  _Product(9, BrandSlot.sponsoredCollection, 'Product Collections',
      'Curated collections a brand sponsors. ParentVeda still decides what is in them.',
      'Recommendations → a collection'),
  _Product(10, BrandSlot.liveSession, 'Live Expert Sessions',
      'Webinars, AMAs and expert talks a brand supports. The doctor stays independent.',
      'Pregnancy → Prepare', stars: 5),
  _Product(11, BrandSlot.communityCampaign, 'Community Campaigns',
      'A sponsored challenge in the community feed. Participation stays the focus.',
      'Community → the feed'),
  _Product(12, BrandSlot.productSampling, 'Product Sampling',
      'Free samples and trial packs: eligibility, registration, then feedback.',
      'Explore → Recommendations', 
      note: 'Eligibility, registration and feedback are live. Real fulfilment (who actually posts the parcel) is an ops question, not an app one.'),
  _Product(13, BrandSlot.sponsoredMilestone, 'Milestone Sponsorship',
      'A brand supports the content around a milestone (6 months, 1 year). The milestone content stays editorial.',
      'My Child → a milestone journey'),
  _Product(14, BrandSlot.nativeDiscovery, 'Native Discovery',
      'A product named naturally inside content links to its Product Guide. Never an advertisement.',
      'Recipes, Ready for Birth, product cards',
      note: 'Live in recipes and the hospital bag. Still to reach: articles, FAQs, Ask Veda answers.'),
  _Product(15, BrandSlot.sponsoredNotification, 'Notification Sponsorship',
      'Very limited, only relevant. Every Brand Studio guard applies, plus a global frequency gap.',
      'Sent from the parenting home'),
  _Product(16, null, 'ParentVeda Certified',
      'Independent evaluation with a published methodology. Deliberately lives on the BRAND, not the campaign, so buying a campaign can never confer it.',
      'Architecture only', stars: 5, built: false,
      note: 'By design: certification is never for sale, so there is nothing to switch on.'),
];

class BrandShowcaseScreen extends StatefulWidget {
  const BrandShowcaseScreen({super.key, this.pregnancyWeek});
  final int? pregnancyWeek;

  @override
  State<BrandShowcaseScreen> createState() => _BrandShowcaseScreenState();
}

class _BrandShowcaseScreenState extends State<BrandShowcaseScreen> {
  @override
  void initState() {
    super.initState();
    // The tour is useless if targeting hides everything, so demo mode goes on
    // the moment you open it. It relaxes AUDIENCE and frequency caps only - it
    // never bypasses the kill switch, the schedule, or the rank floor.
    BrandStudio.instance.demoMode = true;
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _showMe(_Product p) async {
    switch (p.slot) {
      case BrandSlot.premiere:
        // Replay so it can be watched on demand - it is capped at once ever.
        BrandStudioStore.instance.replayAll();
        await showPremiereIfAny(context, stage: BrandStage.parenting);
      case BrandSlot.launchHub:
        _push(LaunchHubScreen(
            stage: BrandStage.parenting, pregnancyWeek: widget.pregnancyWeek));
      case BrandSlot.sponsoredEducation:
        _push(const ReadingHomeScreen());
      case BrandSlot.sponsoredJourney:
        _push(const JourneysScreen());
      case BrandSlot.sponsoredTool:
        _push(const SleepJourneyScreen());
      case BrandSlot.recoFeatured:
      case BrandSlot.sponsoredCollection:
      case BrandSlot.productSampling:
        _push(const RecommendationsScreen());
      case BrandSlot.compareGuide:
        _push(const ProductsCompareScreen());
      case BrandSlot.liveSession:
        // A debug/showcase surface with no PregnancyController in scope.
        // S.current is main.dart's mirror of the controller's language and is
        // read here at TAP time, not inside a build - so the pushed hub gets
        // the right language and still repaints from its own `lang` field.
        _push(PrepareHubScreen(lang: S.current));
      default:
        _toast('Walk to: ${p.where}');
    }
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final live = BrandStudio.instance.demoMode;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(S.now.uiBrandStudio,
            style: pvFraunces(
                fontSize: 21, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          Text(
            S.now.uiFifteenPremiumBrandProducts,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: _soft),
          ),
          const SizedBox(height: 14),
          _demoBanner(live),
          const SizedBox(height: 16),
          _partners(),
          const SizedBox(height: 18),
          for (final p in _products) _row(p),
          const SizedBox(height: 10),
          Text(
            'Demo mode relaxes audience targeting and frequency caps so the tour '
            'shows something. It never bypasses the kill switch, a campaign\'s '
            'schedule, or the recommendation rank floor - a sponsored product '
            'still cannot outrank a better one.',
            style: pvManrope(fontSize: 11.5, height: 1.5, color: _soft),
          ),
        ],
      ),
    );
  }

  Widget _demoBanner(bool on) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _purple.withValues(alpha: 0.18)),
        ),
        child: Row(children: [
          const Icon(Icons.visibility_outlined, size: 18, color: _purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              on
                  ? 'Demo mode is ON, so placements show for this device.'
                  : 'Demo mode is off - most placements will resolve to nothing.',
              style: pvManrope(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
          Switch(
            value: on,
            activeTrackColor: _purple,
            activeThumbColor: Colors.white,
            onChanged: (v) => setState(() => BrandStudio.instance.demoMode = v),
          ),
        ]),
      );

  Widget _partners() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(S.now.uiDemoPartners,
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _soft)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final b in kBrands) BrandLockup(brand: b, markSize: 26)],
        ),
        const SizedBox(height: 8),
        Text(S.now.uiNotRealPartnershipsPlaceholders,
            style: pvManrope(fontSize: 11, color: _soft)),
      ]);

  Widget _row(_Product p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.built ? _purple.withValues(alpha: 0.10) : const Color(0xFFF0EEF3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${p.number}',
                  style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: p.built ? _purple : _soft)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(p.title,
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                  ),
                  if (p.stars == 5) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE0A93B)),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(p.what,
                    style: pvManrope(
                        fontSize: 12.5, height: 1.45, color: _soft)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.place_outlined, size: 13, color: _soft),
            const SizedBox(width: 5),
            Expanded(
              child: Text(p.where,
                  style: pvManrope(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: _soft)),
            ),
            if (p.built)
              GestureDetector(
                onTap: () => _showMe(p),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color: _purple, borderRadius: BorderRadius.circular(9)),
                  child: Text(S.now.uiShowMe,
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0EEF3),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(S.now.uiNotBuilt,
                    style: pvManrope(
                        fontSize: 10.5, fontWeight: FontWeight.w800, color: _soft)),
              ),
          ]),
          if (p.note != null) ...[
            const SizedBox(height: 8),
            Text(p.note!,
                style: pvManrope(
                    fontSize: 11.5, height: 1.45, color: const Color(0xFF9A7B2E))),
          ],
        ]),
      );
}
