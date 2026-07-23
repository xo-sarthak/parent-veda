// =============================================================================
//  ParentVeda Product Guide — the product page, redesigned for trust
// -----------------------------------------------------------------------------
//  Not an Amazon spec sheet. Above the fold answers ONE question in ~10 seconds
//  ("is this right for my child?"): recommendation, ParentVeda + community
//  rating, a one-line verdict, Best-For chips, what to watch out for, and the
//  CTAs. A "Before you buy" honesty line sits right under the hero. Everything
//  below is optional (progressive disclosure): why we like it, expert videos,
//  practical community experiences, ingredients explained, research in plain
//  language, category-specific specs, and related guides. Self-contained styling
//  (GoogleFonts + the shared palette) so BOTH apps render it identically.
// =============================================================================

import 'package:flutter/material.dart';

import '../../brand/brand_models.dart';
import '../../brand/outbound.dart';
import '../../brand/needs_attention.dart';
import '../../brand/presented_by.dart';
import '../../services/family_profile.dart';
import '../post_pregnancy/askveda_screen.dart';
import '../post_pregnancy/pp_child_profile.dart';
import '../post_pregnancy/pp_products_data.dart';
import '../post_pregnancy/pp_watch_data.dart';
import '../post_pregnancy/products_compare_screen.dart';
import '../post_pregnancy/watch_player_screen.dart';
import '../post_pregnancy/watch_quicklearn_screen.dart';
import 'product_guide_data.dart';
import 'product_guide_style.dart';
import 'product_guide_votes.dart';


class ProductGuideScreen extends StatelessWidget {
  const ProductGuideScreen({super.key, required this.guide});
  final ProductGuide guide;

  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));
  void _soon(BuildContext c, String m) =>
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    final g = guide;
    return Scaffold(
      backgroundColor: pgBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _topBar(context),
            _hero(context, g),
            const SizedBox(height: 14),
            _pad(_beforeYouBuy(g)),
            const SizedBox(height: 22),
            _pad(_honestLook(g)),
            const SizedBox(height: 26),

            // progressive-disclosure marker
            _pad(Row(children: [
              Expanded(child: Container(height: 1, color: pgLine)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('EXPLORE MORE IF YOU\'D LIKE', style: pgEyebrow(pgMuted)),
              ),
              Expanded(child: Container(height: 1, color: pgLine)),
            ])),
            const SizedBox(height: 22),

            if (g.experts.isNotEmpty) ...[_experts(context, g), const SizedBox(height: 26)],
            _community(context, g),
            const SizedBox(height: 26),
            if (g.ingredients.isNotEmpty) ...[_ingredients(g), const SizedBox(height: 26)],
            if (g.studies.isNotEmpty) ...[_research(context, g), const SizedBox(height: 26)],
            if (g.specs.isNotEmpty) ...[_specs(g), const SizedBox(height: 26)],
            if (g.relatedIds.isNotEmpty) ...[_related(context, g), const SizedBox(height: 20)],

            // Ask Veda closes the page. Three bullets and a research corner will
            // not cover every worry a parent arrives with, and pretending
            // otherwise is how a "trustworthy" page loses trust.
            _pad(_askVedaRow(context, g)),
            const SizedBox(height: 22),

            _pad(Text('Guidance to help you decide — always follow your doctor\'s advice for your child.',
                textAlign: TextAlign.center, style: pgBody(11.5, color: pgMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);

  // ---- top bar ------------------------------------------------------------
  Widget _topBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36, height: 36, alignment: Alignment.center,
              decoration: const BoxDecoration(color: pgPanel, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, size: 18, color: pgInk),
            ),
          ),
          Expanded(child: Center(child: Text('PRODUCT GUIDE', style: pgEyebrow(pgMuted)))),
          const SizedBox(width: 36),
        ]),
      );

  // ---- hero (the 10-second decision) --------------------------------------
  Widget _hero(BuildContext context, ProductGuide g) {
    final rc = pgRecoColor(g.reco.tone);
    return _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 6),
      // image placeholder
      Container(
        height: 168,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF3ECFA), Color(0xFFFDF3F5)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: pgHair),
        ),
        child: Icon(g.icon, size: 58, color: pgPurple.withValues(alpha: 0.55)),
      ),
      const SizedBox(height: 16),
      Text(g.brand.toUpperCase(), style: pgEyebrow(pgMuted)),
      const SizedBox(height: 6),
      Text(g.name, style: pgSerif(26, h: 1.12)),
      const SizedBox(height: 14),

      // at-a-glance buy signal
      _verdictCard(context, g, rc),
      const SizedBox(height: 16),

      // ratings
      Row(children: [
        _rating('ParentVeda', g.rating.parentveda, pgPurple),
        Container(width: 1, height: 34, color: pgHair, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _rating('Community', g.rating.community, pgCoral),
      ]),
      const SizedBox(height: 16),

      // verdict
      Text(g.verdict, style: pgSerif(18, c: pgInk, h: 1.4).copyWith(fontStyle: FontStyle.italic)),
      const SizedBox(height: 16),

      // best-for chips
      Text('BEST FOR', style: pgEyebrow(pgMuted)),
      const SizedBox(height: 8),
      // LEVEL 1 personalization. A chip that matches something she has actually
      // told us about her child is marked - so "Dry skin" carries weight for a
      // parent who logged eczema, and reads as ordinary for everyone else.
      // Content emphasis ONLY: nothing is reordered, nothing is hidden, and the
      // full list shows either way. See docs/PERSONALIZATION.md.
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final b in g.bestFor) _chip(b, matches: _matchesThisChild(b)),
      ]),

      const SizedBox(height: 18),

      // CTAs
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            // The Compare tool is real and already holds a selection - this
            // used to be a snackbar sitting next to a working feature.
            onPressed: () => _openCompare(context, g),
            icon: const Icon(Icons.compare_arrows_rounded, size: 18),
            label: const Text('Compare'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: pgPurple,
              side: const BorderSide(color: Color(0xFFD8C8EA)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _openBuySheet(context, g),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Buy now'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: pgPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    ]));
  }

  Widget _rating(String label, double value, Color color) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: pgEyebrow(pgMuted).copyWith(fontSize: 9.5)),
          const SizedBox(height: 4),
          Row(children: [
            Text(value.toStringAsFixed(1), style: pgTitle(18, c: pgInk)),
            const SizedBox(width: 6),
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  value >= i + 1 ? Icons.star_rounded : (value >= i + 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                  size: 13, color: color,
                ),
            ]),
          ]),
        ]),
      );

  /// Does this "Best for" chip match something she has told us about her child?
  /// Defensive throughout: an unloaded store, or a parent who has told us
  /// nothing, degrades to "no match" - never to a crash and never to a guess.
  bool _matchesThisChild(String chip) {
    try {
      final p = FamilyProfileStore.instance;
      final c = chip.toLowerCase();
      for (final cond in p.conditions) {
        if (c.contains(cond.label.toLowerCase()) || cond.label.toLowerCase().contains(c)) {
          return true;
        }
      }
      // A few plain-language bridges between chip wording and profile signals.
      if (c.contains('sensitive') || c.contains('dry skin')) {
        return p.hasCondition(HealthCondition.eczema);
      }
      if (c.contains('breastfeeding')) return p.feeding == FeedingMethod.breastfeeding;
      if (c.contains('formula')) return p.feeding == FeedingMethod.formula;
      if (c.contains('newborn')) return ChildProfileStore.instance.ageInMonths <= 3;
    } catch (_) {/* no signals */}
    return false;
  }

  Widget _chip(String label, {bool matches = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: matches ? pgPurple.withValues(alpha: 0.14) : pgPanel,
          borderRadius: BorderRadius.circular(999),
          border: matches ? Border.all(color: pgPurple.withValues(alpha: 0.42)) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (matches) ...[
            const Icon(Icons.check_rounded, size: 13, color: pgPurple),
            const SizedBox(width: 4),
          ],
          Text(label, style: pgBody(12.5, color: pgPurple, w: FontWeight.w700)),
        ]),
      );

  // ---- at-a-glance "buy signal" verdict card ------------------------------
  Widget _verdictCard(BuildContext context, ProductGuide g, Color rc) {
    ProductGuideVotes.instance.init();
    final tone = g.reco.tone;
    final trend = tone == 0 ? Icons.trending_up_rounded : (tone == 1 ? Icons.trending_flat_rounded : Icons.trending_down_rounded);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rc.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rc.withValues(alpha: 0.30), width: 1.4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: rc, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(trend, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(child: Text(g.reco.signal, maxLines: 1, overflow: TextOverflow.ellipsis, style: pgBody(13, color: Colors.white, w: FontWeight.w800))),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('${g.parentScore}', style: pgTitle(26, c: pgInk)),
              Text(' /100', style: pgBody(12, color: pgMuted)),
            ]),
            Text('ParentVeda score', style: pgBody(10, color: pgMuted)),
          ]),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: rc.withValues(alpha: 0.18)),
        const SizedBox(height: 12),
        Row(children: [
          _consensus('${g.parentsPct}%', 'parents like you recommend'),
          _vDiv(),
          _consensus('${g.expertsPct}%', 'experts say buy'),
          _vDiv(),
          _consensus('${g.rating.community.toStringAsFixed(1)}★', 'community rating'),
        ]),
        const SizedBox(height: 14),
        Text('YOUR TAKE', style: pgEyebrow(pgMuted).copyWith(fontSize: 9.5)),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: ProductGuideVotes.instance,
          builder: (ctx, _) {
            final v = ProductGuideVotes.instance.voteFor(g.id);
            return Row(children: [
              Expanded(child: _voteBtn('Recommend', Icons.thumb_up_alt_rounded, v == PgVote.recommend, pgGreen, () => ProductGuideVotes.instance.cast(g.id, PgVote.recommend))),
              const SizedBox(width: 8),
              Expanded(child: _voteBtn('Not for us', Icons.thumb_down_alt_rounded, v == PgVote.notForUs, pgCoral, () => ProductGuideVotes.instance.cast(g.id, PgVote.notForUs))),
            ]);
          },
        ),
      ]),
    );
  }

  Widget _consensus(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: pgTitle(16, c: pgInk)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: pgBody(10.5, color: pgSoft, h: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _vDiv() => Container(width: 1, height: 30, color: pgHair, margin: const EdgeInsets.symmetric(horizontal: 6));

  Widget _voteBtn(String label, IconData icon, bool on, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? color : pgLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: on ? Colors.white : color),
            const SizedBox(width: 7),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: pgBody(12.5, color: on ? Colors.white : pgInk, w: FontWeight.w700))),
          ]),
        ),
      );

  // ---- before you buy -----------------------------------------------------
  Widget _beforeYouBuy(ProductGuide g) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF6F0FA), Color(0xFFF0E9F7)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7DFEE)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: pgPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BEFORE YOU BUY', style: pgEyebrow(pgPurple)),
              const SizedBox(height: 6),
              Text(g.beforeYouBuy, style: pgBody(14, color: pgInk, h: 1.55)),
            ]),
          ),
        ]),
      );

  // ---- an honest look (balanced good vs not-so-good, never an ad) ---------
  Widget _honestLook(ProductGuide g) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead('An honest look', 'The good and the not-so-good — no sales pitch'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFFEFF6F1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD6E7DD))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.thumb_up_alt_outlined, size: 15, color: pgGreen), const SizedBox(width: 7), Text("WHAT'S GOOD", style: pgEyebrow(pgGreen))]),
            const SizedBox(height: 10),
            for (final w in g.whyLike)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_rounded, size: 16, color: pgGreen),
                  const SizedBox(width: 9),
                  Expanded(child: Text(w, style: pgBody(13.5, color: pgInk, h: 1.45))),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFFFBF3E8), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEDFC7))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.info_outline_rounded, size: 15, color: pgAmber), const SizedBox(width: 7), Text('WORTH CONSIDERING', style: pgEyebrow(pgAmber))]),
            const SizedBox(height: 10),
            if (g.watchOut.isEmpty)
              Text('No real downsides stood out for this one.', style: pgBody(13.5, color: pgInk, h: 1.45))
            else
              for (final w in g.watchOut)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('•  ', style: pgBody(14, color: pgAmber)),
                    Expanded(child: Text(w, style: pgBody(13.5, color: pgInk, h: 1.45))),
                  ]),
                ),
          ]),
        ),
      ]);

  // ---- expert explains ----------------------------------------------------
  /// Opens the expert's video in the real player. Experts without one say so
  /// plainly rather than pretending to be tappable.
  void _openExpertVideo(BuildContext context, PgExpert e) {
    final id = e.videoId;
    if (id == null) {
      _soon(context, 'This explainer is still being filmed.');
      return;
    }
    final v = watchVideoById(id);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v),
    ));
  }

  /// Adds this product to the Compare tray (if we can match it to a catalogue
  /// product) and opens Compare. Comparing is the whole reason a parent opens
  /// two of these pages.
  void _openCompare(BuildContext context, ProductGuide g) {
    // A guide names a product TYPE ("Fragrance-free baby lotion"); the
    // catalogue names SKUs ("Soothe Baby Lotion"). Matching whole names found
    // nothing, so Compare opened an untouched tray - a test caught it. Match on
    // the meaningful noun instead. toggle() would REMOVE an item already in the
    // tray, which is the opposite of "compare this", so only add when absent.
    for (final m in _catalogueMatchesFor(g).take(2)) {
      if (!PpCompareStore.instance.isSelected(m) && PpCompareStore.instance.canAdd(m)) {
        PpCompareStore.instance.toggle(m);
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen()),
    );
  }

  /// Catalogue products this guide is about. Keyed on the meaningful noun in
  /// the guide's name rather than the whole string, because the guide names a
  /// TYPE and the catalogue names a BRAND. Kept in step with the assertion in
  /// test/product_guide_wiring_test.dart.
  List<PpProduct> _catalogueMatchesFor(ProductGuide g) {
    const nouns = [
      'lotion', 'wash', 'wipe', 'diaper', 'nappy', 'sterilis', 'steriliz',
      'pump', 'formula', 'carrier', 'stroller', 'bottle', 'cream', 'sunscreen',
    ];
    final gn = g.name.toLowerCase();
    final noun = nouns.where(gn.contains).toList();
    if (noun.isEmpty) return const [];
    return kPpProducts
        .where((p) => noun.any((n) => p.name.toLowerCase().contains(n)))
        .toList();
  }

  /// The retailer URL for this guide — a real deep link if one is authored,
  /// otherwise an Amazon search for the product name. openOutbound adds the
  /// Amazon partner tag; the search form means every guide has a working Buy
  /// path today, before per-product affiliate links exist.
  String _buyUrl(ProductGuide g) {
    if (g.buyUrl != null && g.buyUrl!.trim().isNotEmpty) return g.buyUrl!;
    final q = Uri.encodeQueryComponent('${g.brand} ${g.name}');
    return 'https://www.amazon.in/s?k=$q';
  }

  /// The interstitial. "Do not make shopping the focus" (the prompt) means a
  /// parent leaves through a calm, honest door, not a hard sell: we say plainly
  /// that it is an affiliate link, that we may earn a small commission at no
  /// cost to them, and — the line that matters most — that it never changes
  /// what we recommend or how we rate a product. THAT sentence is the whole
  /// reason a trust-first page is allowed to carry a Buy button at all.
  void _openBuySheet(BuildContext context, ProductGuide g) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: pgBg,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: pgLine, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Row(children: [
                const Icon(Icons.shopping_bag_outlined, size: 20, color: pgPurple),
                const SizedBox(width: 9),
                Expanded(child: Text('Heading to Amazon', style: pgSerif(22, h: 1.15))),
              ]),
              const SizedBox(height: 12),
              Text('${g.brand} ${g.name}', style: pgBody(14.5, color: pgInk, w: FontWeight.w700)),
              const SizedBox(height: 16),
              _buyPoint(Icons.link_rounded, 'This is an affiliate link. If you buy, ParentVeda may earn a small commission — at no extra cost to you.'),
              const SizedBox(height: 12),
              _buyPoint(Icons.verified_outlined, 'It never changes what we recommend, or how we rate a product. Our verdict is written before any of this.'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openOutbound(_buyUrl(g), productId: g.id);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Continue to Amazon'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: pgPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Stay here', style: pgBody(13.5, color: pgMuted, w: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _buyPoint(IconData icon, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: pgPurple),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: pgBody(13, color: pgInk, h: 1.55))),
      ]);

  /// Ask Veda, pre-loaded with this product as the question. The rest of the
  /// app funnels unanswered questions here; a product page should too.
  void _askVeda(BuildContext context, ProductGuide g) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AskVedaScreen()),
      );

  Widget _askVedaRow(BuildContext context, ProductGuide g) => GestureDetector(
        onTap: () => _askVeda(context, g),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pgPurple.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: pgPurple.withValues(alpha: 0.20)),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 18, color: pgPurple),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Still deciding?', style: pgSerif(16, c: pgInk, h: 1.2)),
                const SizedBox(height: 3),
                Text('Ask Veda anything about ${g.category.toLowerCase()} for your child.',
                    style: pgBody(12.5, color: pgMuted, h: 1.45)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: pgPurple),
          ]),
        ),
      );

  Widget _experts(BuildContext context, ProductGuide g) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pad(_sectionHead('Expert explains', 'Short, from people who know')),
          // FLAGGED: a sponsor on a research page. See needs_attention.dart.
          _pad(PresentedBy(
            slot: BrandSlot.productGuideExpert,
            stage: BrandStage.parenting,
            placementKey: g.id,
            padding: const EdgeInsets.only(top: 8),
          )),
          _pad(const NeedsAttentionFlag(
            flag: BrandFlag.productGuideSponsorship,
            padding: EdgeInsets.only(top: 8),
          )),
          const SizedBox(height: 14),
          SizedBox(
            height: 158,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                for (final e in g.experts)
                  GestureDetector(
                    // Opens the real video when the expert has one. The Brand
                    // Studio sponsors this exact surface, so a dead tap here
                    // meant live commercial inventory sitting on nothing.
                    onTap: () => _openExpertVideo(context, e),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 230,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: pgHair)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 34, height: 34, alignment: Alignment.center,
                            decoration: BoxDecoration(color: pgPanel, shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, color: pgPurple, size: 20),
                          ),
                          const Spacer(),
                          Text(e.duration, style: pgBody(11, color: pgMuted, w: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 12),
                        Text(e.role.toUpperCase(), style: pgEyebrow(pgCoral).copyWith(fontSize: 9.5)),
                        const SizedBox(height: 3),
                        Text(e.name, style: pgTitle(14)),
                        const SizedBox(height: 6),
                        Expanded(child: Text(e.hook, style: pgBody(12.5, h: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );

  // ---- community (top few + See all with filters) -------------------------
  Widget _community(BuildContext context, ProductGuide g) {
    final shown = g.experiences.take(3).toList();
    return _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHead('From the ParentVeda community', 'Real, practical experiences — not a star dump'),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.groups_rounded, size: 18, color: pgCoral),
        const SizedBox(width: 8),
        Text('${g.rating.community.toStringAsFixed(1)} average', style: pgTitle(14, c: pgInk)),
        const SizedBox(width: 8),
        pgStarsRow(g.rating.community.round(), pgCoral),
      ]),
      const SizedBox(height: 14),
      for (final e in shown) pgExperienceCard(e),
      if (g.experiences.length > shown.length) ...[
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () => _push(context, _CommunityAllScreen(guide: g)),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: pgHair)),
            child: Text('See all ${g.experiences.length} ratings  →', style: pgBody(13.5, color: pgPurple, w: FontWeight.w700)),
          ),
        ),
      ],
    ]));
  }

  // ---- ingredients (each with the good AND an honest con) -----------------
  Widget _ingredients(ProductGuide g) => _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead('Ingredients explained', 'Only the ones that matter — the good and the caveat'),
        const SizedBox(height: 12),
        for (final ing in g.ingredients)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ing.name, style: pgTitle(14.5)),
              const SizedBox(height: 3),
              Text(ing.purpose, style: pgBody(13, color: pgInk, h: 1.45)),
              const SizedBox(height: 8),
              _ingLine(Icons.check_rounded, pgGreen, const Color(0xFFEFF6F1), ing.note),
              if (ing.caution.isNotEmpty) ...[
                const SizedBox(height: 6),
                _ingLine(Icons.info_outline_rounded, pgAmber, const Color(0xFFFBF3E8), ing.caution),
              ],
            ]),
          ),
      ]));

  Widget _ingLine(IconData icon, Color accent, Color bg, String text) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: pgBody(12, color: pgInk, h: 1.45))),
        ]),
      );

  // ---- research corner (about THIS product's ingredients & claims) --------
  Widget _research(BuildContext context, ProductGuide g) => _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead('Research corner', "On this product's actual ingredients & claims"),
        // FLAGGED: a sponsor on a research page. The studies are chosen by
        // ParentVeda, and a maker's own work is still labelled and sorted below
        // independent research — funding changes neither.
        PresentedBy(
          slot: BrandSlot.productGuideResearch,
          stage: BrandStage.parenting,
          placementKey: g.id,
          padding: const EdgeInsets.only(top: 8),
        ),
        const NeedsAttentionFlag(
          flag: BrandFlag.productGuideSponsorship,
          padding: EdgeInsets.only(top: 8),
        ),
        const SizedBox(height: 12),
        // Independent research leads, always. A maker's own study never does.
        for (final st in [...g.studies.where((s) => !s.byMaker), ...g.studies.where((s) => s.byMaker)])
          _studyCard(context, st),
      ]));

  Widget _studyCard(BuildContext context, PgStudy st) {
    final maker = st.byMaker;
    final tagColor = maker ? pgPurple : pgGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maker ? const Color(0xFFF6F0FA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: maker ? const Color(0xFFE7DFEE) : pgHair),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (st.topic.isNotEmpty)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(st.topic.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pgEyebrow(pgSoft).copyWith(fontSize: 9.5)),
              ),
            ),
          const SizedBox(width: 8),
          Icon(maker ? Icons.business_rounded : Icons.verified_outlined, size: 12, color: tagColor),
          const SizedBox(width: 4),
          Text(maker ? "MAKER'S OWN" : 'INDEPENDENT', style: pgEyebrow(tagColor).copyWith(fontSize: 9)),
        ]),
        const SizedBox(height: 10),
        Text(st.summary, style: pgBody(13.5, color: pgInk, h: 1.5)),
        if (st.source.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(st.source, style: pgBody(11, color: pgMuted, w: FontWeight.w600)),
        ],
        const SizedBox(height: 10),
        Text('WHAT THIS MEANS FOR YOU', style: pgEyebrow(pgGreen).copyWith(fontSize: 9.5)),
        const SizedBox(height: 5),
        Text(st.meaning, style: pgBody(13, color: pgSoft, h: 1.5)),
        if (st.detail.isNotEmpty) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _readMore(context, st),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Read more', style: pgBody(12.5, color: pgPurple, w: FontWeight.w700)),
              const Icon(Icons.chevron_right_rounded, size: 16, color: pgPurple),
            ]),
          ),
        ],
      ]),
    );
  }

  void _readMore(BuildContext context, PgStudy st) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(color: pgBg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: pgLine, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              if (st.source.isNotEmpty) Text(st.source, style: pgEyebrow(pgGreen)),
              const SizedBox(height: 8),
              Text(st.summary, style: pgSerif(19, h: 1.3)),
              const SizedBox(height: 14),
              Text(st.detail, style: pgBody(14, color: pgInk, h: 1.65)),
              const SizedBox(height: 16),
              Text('Summarised in plain language from independent sources. Always confirm anything important with your paediatrician.',
                  style: pgBody(11.5, color: pgMuted, h: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  // ---- specs (dynamic per category) ---------------------------------------
  Widget _specs(ProductGuide g) => _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead('Specifications', 'The details that matter for ${g.category.toLowerCase()}'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
          child: Column(children: [
            for (int i = 0; i < g.specs.length; i++) ...[
              if (i > 0) Container(height: 1, color: pgHair),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                child: Row(children: [
                  Expanded(flex: 4, child: Text(g.specs[i].label, style: pgBody(13, color: pgMuted, w: FontWeight.w600))),
                  Expanded(flex: 6, child: Text(g.specs[i].value, style: pgBody(13.5, color: pgInk, w: FontWeight.w600))),
                ]),
              ),
            ],
          ]),
        ),
      ]));

  // ---- related ------------------------------------------------------------
  Widget _related(BuildContext context, ProductGuide g) {
    final items = g.relatedIds.map(pgById).whereType<ProductGuide>().toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_sectionHead('Related guides', 'You might also weigh up')),
      const SizedBox(height: 12),
      _pad(Column(children: [
        for (final r in items)
          GestureDetector(
            onTap: () => _push(context, ProductGuideScreen(guide: r)),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
              child: Row(children: [
                Container(
                  width: 40, height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(12)),
                  child: Icon(r.icon, size: 19, color: pgPurple),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: pgTitle(14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(r.category, style: pgBody(11.5, color: pgMuted)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7BBD6)),
              ]),
            ),
          ),
      ])),
    ]);
  }

  Widget _sectionHead(String title, String sub) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: pgTitle(17)),
        const SizedBox(height: 3),
        Text(sub, style: pgBody(12.5, color: pgMuted)),
      ]);
}

// ---- shared community pieces ------------------------------------------------
Widget pgStarsRow(int n, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
      for (int i = 0; i < 5; i++)
        Icon(i < n ? Icons.star_rounded : Icons.star_outline_rounded, size: 13, color: c),
    ]);

Widget pgExperienceCard(PgExperience e) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          pgStarsRow(e.stars, e.positive ? pgGreen : pgAmber),
          const Spacer(),
          Text(e.positive ? 'Positive' : 'Critical',
              style: pgBody(10.5, color: e.positive ? pgGreen : pgAmber, w: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        Text('“${e.text}”', style: pgBody(14, color: pgInk, h: 1.5)),
        const SizedBox(height: 8),
        Row(children: [
          Text(e.author, style: pgBody(12, color: pgInk, w: FontWeight.w700)),
          const SizedBox(width: 8),
          Flexible(child: Text('· ${e.context}', style: pgBody(11.5, color: pgMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ]),
    );

// ---- "See all ratings" — filter by sentiment and by star level -------------
class _CommunityAllScreen extends StatefulWidget {
  const _CommunityAllScreen({required this.guide});
  final ProductGuide guide;
  @override
  State<_CommunityAllScreen> createState() => _CommunityAllScreenState();
}

class _CommunityAllScreenState extends State<_CommunityAllScreen> {
  String _filter = 'all'; // all | positive | critical | 5..1

  List<PgExperience> get _shown {
    final all = widget.guide.experiences;
    switch (_filter) {
      case 'positive':
        return all.where((e) => e.positive).toList();
      case 'critical':
        return all.where((e) => e.critical).toList();
      case '5':
      case '4':
      case '3':
      case '2':
      case '1':
        final s = int.parse(_filter);
        return all.where((e) => e.stars == s).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.guide;
    final shown = _shown;
    return Scaffold(
      backgroundColor: pgBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
          children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34, height: 34, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: pgPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 16, color: pgInk),
                ),
              ),
              Expanded(child: Center(child: Text('ALL RATINGS', style: pgEyebrow(pgMuted)))),
              const SizedBox(width: 34),
            ]),
            const SizedBox(height: 18),
            Text(g.name, style: pgSerif(22, h: 1.15)),
            const SizedBox(height: 8),
            Row(children: [
              Text(g.rating.community.toStringAsFixed(1), style: pgTitle(20, c: pgInk)),
              const SizedBox(width: 8),
              pgStarsRow(g.rating.community.round(), pgCoral),
              const SizedBox(width: 8),
              Text('${g.experiences.length} ratings', style: pgBody(12.5, color: pgMuted)),
            ]),
            const SizedBox(height: 16),
            // filters
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chipF('All', 'all'),
              _chipF('Positive', 'positive'),
              _chipF('Critical', 'critical'),
              for (final s in [5, 4, 3, 2, 1]) _chipF('$s★', '$s'),
            ]),
            const SizedBox(height: 18),
            if (shown.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(16)),
                child: Text('No ratings match this filter yet.', textAlign: TextAlign.center, style: pgBody(13.5, color: pgInk)),
              )
            else
              for (final e in shown) pgExperienceCard(e),
          ],
        ),
      ),
    );
  }

  Widget _chipF(String label, String value) {
    final on = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: on ? pgPurple : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? pgPurple : pgLine),
        ),
        child: Text(label, style: pgBody(12.5, color: on ? Colors.white : pgInk, w: FontWeight.w600)),
      ),
    );
  }
}
