// =============================================================================
//  Exclusive Launch Hub — Brand Product 2 (archetype: destination)
// -----------------------------------------------------------------------------
//  Not a shopping catalogue. Closer to an Apple event page: a launch gets a
//  story, an expert introduction, honest highlights and real educational
//  resources, and it stays here for parents to revisit long after the Premiere
//  has gone.
//
//  Because a destination is VISITED rather than shown at anyone, it does not
//  spend an impression (see BrandStudio.isEligible). Nothing here is pushed.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_analytics.dart';
import 'brand_context.dart';
import 'brand_disclosure.dart';
import 'brand_models.dart';
import 'brand_studio.dart';
import 'outbound.dart';

const _bg = Color(0xFFFBF9FE);
const _ink = Color(0xFF2F2C30);
const _soft = Color(0xFF69636C);
const _line = Color(0xFFE4E2E5);
const _titleInk = Color(0xFF2D144C);

TextStyle _serif(double size, {FontWeight w = FontWeight.w600, Color color = _titleInk}) =>
    GoogleFonts.fraunces(fontSize: size, height: 1.12, fontWeight: w, color: color, letterSpacing: -0.4);

TextStyle _body(double size, {Color color = _soft, double h = 1.6, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.manrope(fontSize: size, height: h, color: color, fontWeight: w);

TextStyle _eyebrow({Color color = _soft}) =>
    GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: color);

// =============================================================================
//  The hub — every launch available to this parent
// =============================================================================
class LaunchHubScreen extends StatelessWidget {
  const LaunchHubScreen({super.key, required this.stage, this.pregnancyWeek});

  final BrandStage stage;
  final int? pregnancyWeek;

  @override
  Widget build(BuildContext context) {
    final ctx = captureBrandContext(stage: stage, pregnancyWeek: pregnancyWeek);
    // archiveFor, not resolveAll: a launch a parent looks up again is not an
    // impression being spent on them, and an ended launch stays readable.
    final launches = BrandStudio.instance.archiveFor(BrandSlot.launchHub, ctx);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          Text('LAUNCHES', style: _eyebrow()),
          const SizedBox(height: 10),
          Text('New, and worth knowing about', style: _serif(30)),
          const SizedBox(height: 10),
          Text(
            'Products we think are genuinely new, introduced by the people who made them and read honestly by a ParentVeda expert. Brands pay to launch here. They do not pay for what the expert says.',
            style: _body(14),
          ),
          const SizedBox(height: 24),
          if (launches.isEmpty)
            _empty()
          else
            for (final c in launches) _LaunchCard(campaign: c),
        ],
      ),
    );
  }

  Widget _empty() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEF7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          const Icon(Icons.auto_awesome_outlined, color: _soft, size: 22),
          const SizedBox(height: 12),
          Text('No launches right now', style: _serif(18, color: _ink)),
          const SizedBox(height: 6),
          Text(
            'We only run these a few times a year. An empty page here means nothing new is worth your attention yet.',
            textAlign: TextAlign.center,
            style: _body(13),
          ),
        ]),
      );
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({required this.campaign});
  final BrandCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          BrandAnalytics.instance.event(c, BrandEvent.hubOpened);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => LaunchDetailScreen(campaign: c)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 96,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(c.brand.colour, Colors.black, 0.24)!,
                    Color.lerp(c.brand.colour, const Color(0xFF14101A), 0.6)!,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: SponsorDisclosure(
                  campaign: c,
                  color: Colors.white,
                  background: Colors.white.withValues(alpha: 0.16),
                  compact: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.creative.headline, style: _serif(21, color: _ink)),
                const SizedBox(height: 6),
                Text(c.creative.subline, style: _body(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Read the launch', style: _body(12.5, color: c.brand.colour, w: FontWeight.w800)),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: c.brand.colour),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  One launch — hero, story, expert, highlights, resources
// =============================================================================
class LaunchDetailScreen extends StatelessWidget {
  const LaunchDetailScreen({super.key, required this.campaign});
  final BrandCampaign campaign;

  BrandCampaign get c => campaign;

  @override
  Widget build(BuildContext context) {
    final cr = c.creative;
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: Color.lerp(c.brand.colour, Colors.black, 0.34),
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(background: _hero()),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 44),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // The promise, stated before anything the brand wrote.
              IndependenceNote(campaign: c),
              const SizedBox(height: 18),
              Text(cr.story, style: _body(15, color: _ink, h: 1.65)),
              if (cr.expertHook.isNotEmpty) ...[
                const SizedBox(height: 24),
                _expert(),
              ],
              if (cr.highlights.isNotEmpty) ...[
                const SizedBox(height: 26),
                Text('WHAT IT ACTUALLY IS', style: _eyebrow()),
                const SizedBox(height: 12),
                for (final h in cr.highlights) _highlight(h),
              ],
              if (cr.resources.isNotEmpty) ...[
                const SizedBox(height: 26),
                Text('LEARN THIS PROPERLY', style: _eyebrow()),
                const SizedBox(height: 6),
                Text('ParentVeda\'s own guides on the subject. Free, and not about this product.', style: _body(12.5)),
                const SizedBox(height: 12),
                for (final r in cr.resources) _resource(context, r),
              ],
              const SizedBox(height: 26),
              _cta(context),
              const SizedBox(height: 14),
              Text(
                'A launch is not an endorsement. Nothing here changes a product\'s ParentVeda rating, and no brand can buy one.',
                style: _body(11.5),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _hero() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(c.brand.colour, Colors.black, 0.30)!,
              Color.lerp(c.brand.colour, const Color(0xFF14101A), 0.7)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SponsorDisclosure(
                campaign: c,
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.16),
              ),
              const SizedBox(height: 12),
              Text(
                c.creative.headline,
                style: GoogleFonts.fraunces(
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                c.creative.subline,
                style: GoogleFonts.manrope(fontSize: 14, height: 1.5, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ]),
          ),
        ),
      );

  /// The expert speaks for ParentVeda, not for the brand — so their note is
  /// allowed to undercut the launch, and here it does.
  Widget _expert() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF3EEF7), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.verified_outlined, size: 15, color: Color(0xFF6A30B6)),
            const SizedBox(width: 7),
            Text('PARENTVEDA\'S EXPERT', style: _eyebrow(color: const Color(0xFF6A30B6))),
          ]),
          const SizedBox(height: 11),
          Text('"${c.creative.expertHook}"', style: GoogleFonts.fraunces(fontSize: 15, height: 1.55, color: _ink)),
          const SizedBox(height: 10),
          Text(c.creative.expertName, style: _body(12.5, color: _ink, w: FontWeight.w800)),
          Text(c.creative.expertRole, style: _body(11.5)),
        ]),
      );

  Widget _highlight(BrandHighlight h) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.brand.colour.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(h.icon, size: 17, color: c.brand.colour),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 3),
              Text(h.body, style: _body(13)),
            ]),
          ),
        ]),
      );

  Widget _resource(BuildContext context, BrandResource r) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            BrandAnalytics.instance.event(c, BrandEvent.resourceOpened, meta: {'resource': r.label});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${r.label} — coming soon'), behavior: SnackBarBehavior.floating),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            child: Row(children: [
              const Icon(Icons.menu_book_outlined, size: 17, color: Color(0xFF6A30B6)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.label, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 2),
                  Text(r.blurb, style: _body(12)),
                ]),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 15, color: _soft),
            ]),
          ),
        ),
      );

  Widget _cta(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: c.brand.colour,
            side: BorderSide(color: c.brand.colour.withValues(alpha: 0.5), width: 1.4),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            BrandAnalytics.instance.event(c, BrandEvent.ctaTapped);
            final url = c.brand.landingUrl;
            if (url == null || url.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Brand link coming soon'), behavior: SnackBarBehavior.floating),
              );
              return;
            }
            await openOutbound(url, campaign: c);
          },
          child: Text(
            'Visit ${c.brand.name}',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      );
}
