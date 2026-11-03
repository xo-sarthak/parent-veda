// =============================================================================
//  Brand page — one partner's own page (Pee Safe demo, item 4)
// -----------------------------------------------------------------------------
//  Generic per [Brand]. Reached from a launch (LaunchDetailScreen's brand-name
//  link), never pushed at anyone, so like the Launch Hub it spends no
//  impression.
//
//  Layout follows the Mobbin brand-page pattern (docs/PEE-SAFE-DEMO.md):
//  hero with a round logo overlapping its edge -> name + "ParentVeda partner"
//  -> one full-width store button -> story broken by a photo -> film slot ->
//  where it's used -> products -> reading shelf.
//
//  Where the content comes from, and why:
//    · Story, image and film come from the brand's LAUNCH ([BrandCreative]).
//      One creative, two surfaces: the page never carries copy of its own that
//      could drift from what the launch says.
//    · Products come from [brandPageCatalogueFor], a per-brand adapter. The
//      page knows nothing about Pee Safe; only the adapter does. A brand with
//      no catalogue gets the invitation, not a missing section.
//    · The reading shelf is the launch's resources that point at a real read
//      (`readId`), opened in PvReaderScreen (item 5). A brand with none
//      renders an invitation, because a feature is never hidden.
//
//  Colour: this is the brand's OWN surface, so its colour (Pee Safe's lime) is
//  allowed here — and only here. Text on that colour is chosen by brightness,
//  because lime with white text is unreadable.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'brand_disclosure.dart';
import 'brand_mark.dart';
import 'brand_models.dart';
import 'brand_studio.dart';
import 'outbound.dart';
import 'pee_safe/pee_safe_brand.dart';
import 'pee_safe/pee_safe_products.dart';
import 'pee_safe/pee_safe_recovery_kit_screen.dart';
import 'pee_safe/pee_safe_reads.dart';
import '../localization/app_language.dart';
import '../theme/pv_fonts.dart';
import '../widgets/pv_feedback.dart' show PvPress;
import '../widgets/pv_toast.dart';

/// The route name other code detects this page by.
const String kBrandPageRoute = 'brand_page';

const _soft = Color(0xFF69636C);
const _line = Color(0xFFE4E2E5);

// =============================================================================
//  The catalogue adapter — the only brand-specific part
// =============================================================================

/// One product on a brand page. [open] leaves through openOutbound, attributed
/// to the launch the parent came from.
@immutable
class BrandPageProduct {
  const BrandPageProduct({
    required this.id,
    required this.name,
    required this.line,
    required this.image,
    required this.open,
  });

  final String id;
  final String name;
  final String line;
  final String image;
  final Future<bool> Function({BrandCampaign? campaign}) open;
}

/// A moment a brand's products are used in ("After birth", "Travel").
@immutable
class BrandPageMoment {
  const BrandPageMoment({required this.label, required this.icon, required this.products});
  final String label;
  final IconData icon;
  final List<BrandPageProduct> products;
}

@immutable
class BrandPageCatalogue {
  const BrandPageCatalogue({required this.all, required this.moments});
  final List<BrandPageProduct> all;
  final List<BrandPageMoment> moments;
}

/// The products for [brand]'s page, or null when the brand has none here.
BrandPageCatalogue? brandPageCatalogueFor(Brand brand) {
  if (brand.id == kPeeSafe.id && kPeeSafeDemo) return _peeSafeCatalogue();
  return null;
}

BrandPageProduct _fromPeeSafe(PeeSafeProduct p) => BrandPageProduct(
      id: p.id,
      name: p.name,
      line: p.line,
      image: p.image,
      open: p.open,
    );

BrandPageCatalogue _peeSafeCatalogue() {
  // Ordered by the parent's journey, not the enum: relevance, not stage (P3),
  // but a reader still reads top to bottom.
  const order = <(PeeSafeMoment, String, IconData)>[
    (PeeSafeMoment.tryingToConceive, 'Trying to conceive', Icons.spa_outlined),
    (PeeSafeMoment.pregnancy, 'Pregnancy', Icons.pregnant_woman_outlined),
    (PeeSafeMoment.hospitalBag, 'Hospital bag', Icons.luggage_outlined),
    (PeeSafeMoment.postpartum, 'After birth', Icons.healing_outlined),
    (PeeSafeMoment.periodsReturn, 'When periods return', Icons.event_repeat_outlined),
    (PeeSafeMoment.travel, 'Travel', Icons.flight_takeoff_outlined),
    (PeeSafeMoment.outingsWithChild, 'Out with your child', Icons.stroller_outlined),
  ];
  return BrandPageCatalogue(
    all: [for (final p in kPeeSafeProducts) _fromPeeSafe(p)],
    moments: [
      for (final (m, label, icon) in order)
        if (peeSafeFor(m).isNotEmpty)
          BrandPageMoment(label: label, icon: icon, products: [for (final p in peeSafeFor(m)) _fromPeeSafe(p)]),
    ],
  );
}

/// The brand's launch in the Launch Hub, which supplies the page's story.
BrandCampaign? brandLaunchFor(Brand brand) {
  for (final c in BrandStudio.instance.campaigns) {
    if (c.brand.id == brand.id && c.slot == BrandSlot.launchHub && c.active) return c;
  }
  return null;
}

/// Splits prose so a photo can sit in the middle: on a blank line when there
/// is one, else at the sentence nearest the middle. A single sentence stays
/// whole (second half empty).
(String, String) splitStory(String story) {
  final s = story.trim();
  final paras = s.split(RegExp(r'\n\s*\n'));
  if (paras.length > 1) {
    final mid = (paras.length / 2).ceil();
    return (paras.take(mid).join('\n\n'), paras.skip(mid).join('\n\n'));
  }
  final sentences = s.split(RegExp(r'(?<=[.!?])\s+'));
  if (sentences.length < 2) return (s, '');
  final mid = (sentences.length / 2).ceil();
  return (sentences.take(mid).join(' '), sentences.skip(mid).join(' '));
}

// =============================================================================
//  The page
// =============================================================================
class BrandPageScreen extends StatefulWidget {
  const BrandPageScreen({super.key, required this.brand, this.launch});

  final Brand brand;

  /// The launch the parent came from. Null looks the brand's launch up.
  final BrandCampaign? launch;

  /// The one way to open this page, so the route name is never forgotten.
  static Route<void> route(Brand brand, {BrandCampaign? launch}) => MaterialPageRoute(
        settings: const RouteSettings(name: kBrandPageRoute),
        builder: (_) => BrandPageScreen(brand: brand, launch: launch),
      );

  @override
  State<BrandPageScreen> createState() => _BrandPageScreenState();
}

class _BrandPageScreenState extends State<BrandPageScreen> {
  int? _moment; // index into catalogue.moments; null = all products

  Brand get b => widget.brand;
  late final BrandCampaign? _launch = widget.launch ?? brandLaunchFor(widget.brand);
  late final BrandPageCatalogue? _catalogue = brandPageCatalogueFor(widget.brand);

  // Pee Safe has its own wash and ink; any other brand gets a tint of its own.
  Color get _wash => b.id == kPeeSafe.id ? kPeeSafeWash : Color.lerp(b.colour, Colors.white, 0.92)!;
  Color get _ink => b.id == kPeeSafe.id ? kPeeSafeInk : const Color(0xFF2F2C30);
  Color get _onBrand =>
      ThemeData.estimateBrightnessForColor(b.colour) == Brightness.light ? _ink : Colors.white;

  /// A photo for the story and the film fallback: the launch's own image, else
  /// the first product's.
  String? get _photo {
    final a = _launch?.creative.imageAsset;
    if (a != null && a.isNotEmpty) return a;
    final all = _catalogue?.all ?? const [];
    return all.isEmpty ? null : all.first.image;
  }

  String? get _secondPhoto {
    final all = _catalogue?.all ?? const [];
    return all.length > 2 ? all[2].image : _photo;
  }

  TextStyle _body(double size, {Color? color, double h = 1.6, FontWeight w = FontWeight.w400}) =>
      pvManrope(fontSize: size, height: h, color: color ?? _soft, fontWeight: w);

  TextStyle _eyebrow() => pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: _soft);

  @override
  Widget build(BuildContext context) {
    final cr = _launch?.creative;
    final (storyA, storyB) = splitStory(cr?.story ?? '');
    return Scaffold(
      backgroundColor: _wash,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _hero(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.name,
                  style: pvFraunces(fontSize: 30, height: 1.1, fontWeight: FontWeight.w600, color: _ink, letterSpacing: -0.6)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.handshake_outlined, size: 15, color: _ink),
                const SizedBox(width: 6),
                Text('ParentVeda partner', style: _body(13, color: _ink, w: FontWeight.w700)),
              ]),
              if (_launch != null) ...[
                const SizedBox(height: 12),
                IndependenceNote(campaign: _launch),
              ],
              const SizedBox(height: 18),
              _storeButton(context),
              if (storyA.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('THE STORY', style: _eyebrow()),
                const SizedBox(height: 10),
                Text(storyA, style: _body(15, color: _ink, h: 1.65)),
                if (_photo != null) ...[
                  const SizedBox(height: 18),
                  _image(_photo!, height: 200),
                ],
                if (storyB.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(storyB, style: _body(15, color: _ink, h: 1.65)),
                ],
              ],
              const SizedBox(height: 28),
              _BrandFilmSlot(videoRef: cr?.videoRef, fallbackImage: _secondPhoto, ink: _ink, brand: b),
              const SizedBox(height: 32),
              ..._products(context),
              const SizedBox(height: 32),
              _shelf(context),
              // Item 6: the brand's tool. Pee Safe only for now; a generic
              // brand has no tool, so nothing renders rather than a stub.
              if (b.id == kPeeSafe.id && kPeeSafeDemo) ...[
                const SizedBox(height: 32),
                _tool(context),
              ],
              const SizedBox(height: 28),
              Text(
                'Prices and stock are shown on ${b.name}\'s store. ParentVeda\'s own guides do not change because a brand is a partner.',
                style: _body(11.5),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ---- hero: brand-coloured band, round logo overlapping its bottom edge ----
  Widget _hero(BuildContext context) {
    const bandH = 190.0, logo = 92.0;
    return SizedBox(
      height: bandH + logo / 2,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          height: bandH,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [b.colour, Color.lerp(b.colour, _wash, 0.55)!],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: _onBrand),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _disclosure(),
            ]),
          ),
        ),
        Positioned(
          left: 20,
          top: bandH - logo / 2,
          child: Container(
            width: logo,
            height: logo,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _wash, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: ClipOval(child: _logo(logo - 32)),
          ),
        ),
      ]),
    );
  }

  Widget _logo(double size) {
    final a = b.logoAsset;
    if (a == null || a.isEmpty) return BrandMark(brand: b, size: size);
    return Image.asset(a, width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (_, _, _) => BrandMark(brand: b, size: size));
  }

  /// "Presented by `brand`". The launch's own disclosure when there is one,
  /// so the wording stays centralised in BrandCampaign.
  Widget _disclosure() {
    final l = _launch;
    if (l != null) {
      return SponsorDisclosure(campaign: l, color: _onBrand, background: _onBrand.withValues(alpha: 0.14));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _onBrand.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Text('Presented by ${b.name}'.toUpperCase(),
          style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: _onBrand)),
    );
  }

  Widget _storeButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: b.colour,
            foregroundColor: _onBrand,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            final url = b.landingUrl;
            if (url == null || url.isEmpty) {
              pvToast(context, S.now.uiBrandLinkComingSoon);
              return;
            }
            await openOutbound(url, campaign: _launch);
          },
          icon: const Icon(Icons.open_in_new_rounded, size: 17),
          label: Text('Visit ${b.name} store', style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800)),
        ),
      );

  Widget _image(String asset, {required double height}) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.white,
          child: Image.asset(asset, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(Icons.image_outlined, color: _soft.withValues(alpha: 0.5))),
        ),
      );

  // ---- where it's used, then the grid ---------------------------------------
  List<Widget> _products(BuildContext context) {
    final cat = _catalogue;
    if (cat == null || cat.all.isEmpty) {
      return [
        Text('WHERE IT\'S USED', style: _eyebrow()),
        const SizedBox(height: 10),
        _invitation(Icons.storefront_outlined, "${b.name}'s range",
            'Picks from ${b.name} appear here, grouped by when parents reach for them, once the brand lists them with ParentVeda.'),
        // No "coming soon" (2026-11-03, the user). Kept for revert:
        // _invitation(Icons.inventory_2_outlined, 'Products coming soon',
        //             '${b.name}\'s range will be listed here, grouped by when parents reach for it.'),
      ];
    }
    final m = _moment;
    final shown = m == null ? cat.all : cat.moments[m].products;
    return [
      Text('WHERE IT\'S USED', style: _eyebrow()),
      const SizedBox(height: 4),
      Text('Tap a moment to see what fits it.', style: _body(12.5)),
      const SizedBox(height: 12),
      SizedBox(
        height: 104,
        // Eight tiles at most: a plain Row builds them all, which a lazy list
        // would not, and the cost is nothing at this size.
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _momentTile(Icons.apps_rounded, 'Everything', cat.all.length, m == null, () => setState(() => _moment = null)),
            for (var i = 0; i < cat.moments.length; i++) ...[
              const SizedBox(width: 10),
              _momentTile(cat.moments[i].icon, cat.moments[i].label, cat.moments[i].products.length, m == i,
                  () => setState(() => _moment = i)),
            ],
          ]),
        ),
      ),
      const SizedBox(height: 18),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: shown.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.56,
        ),
        itemBuilder: (_, i) => _productCard(shown[i]),
      ),
    ];
  }

  Widget _momentTile(IconData icon, String label, int count, bool selected, VoidCallback onTap) => PvPress(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? b.colour : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? b.colour : _line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 19, color: _ink),
              const SizedBox(height: 8),
              // Flexible, not fixed: a long label or a large text scale must
              // shrink the label, never overflow the tile.
              Flexible(
                child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: pvJakarta(fontSize: 12.5, height: 1.2, fontWeight: FontWeight.w700, color: _ink)),
              ),
              Text('$count ${count == 1 ? 'product' : 'products'}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: _body(11, h: 1.3, color: _ink.withValues(alpha: 0.7))),
            ]),
          ),
        ),
      );

  Widget _productCard(BrandPageProduct p) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(p.image, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(Icons.image_outlined, color: _soft.withValues(alpha: 0.5))),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: pvJakarta(fontSize: 13, height: 1.25, fontWeight: FontWeight.w700, color: _ink)),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(p.line, maxLines: 3, overflow: TextOverflow.ellipsis, style: _body(11.5, h: 1.4)),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: BorderSide(color: b.colour, width: 1.6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 34),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => p.open(campaign: _launch),
                    child: Text('Buy', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      );

  // ---- reading shelf ---------------------------------------------------------
  Widget _shelf(BuildContext context) {
    final reads = [
      for (final r in _launch?.creative.resources ?? const <BrandResource>[])
        if (r.readId != null && r.readId!.isNotEmpty) r,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('READ WITH ${b.name.toUpperCase()}', style: _eyebrow()),
      const SizedBox(height: 4),
      Text('Written by ParentVeda. ${b.name} funds it and does not write it.', style: _body(12.5)),
      const SizedBox(height: 12),
      if (reads.isEmpty)
        _invitation(Icons.menu_book_outlined, 'Guides are on their way',
            'Short reads on discharge in pregnancy, bleeding after birth and gentle care afterwards will sit here.')
      else
        for (final r in reads)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PvPress(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Item 5: opens the read in PvReaderScreen. Kept for revert:
                // onTap: () => pvToast(context, S.now.comingSoonLabel(r.label)),
                onTap: () {
                  if (!openPeeSafeRead(context, r.readId!)) {
                    pvToast(context, S.now.comingSoonLabel(r.label));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line),
                  ),
                  child: Row(children: [
                    Icon(Icons.menu_book_outlined, size: 17, color: _ink),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.label, style: pvJakarta(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 2),
                        Text(r.blurb, style: _body(12)),
                      ]),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 15, color: _soft),
                  ]),
                ),
              ),
            ),
          ),
    ]);
  }

  // ---- tool (item 6) ----------------------------------------------------------
  Widget _tool(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('A TOOL WITH ${b.name.toUpperCase()}', style: _eyebrow()),
        const SizedBox(height: 4),
        Text('Built by ParentVeda. ${b.name} funds it and does not write it.', style: _body(12.5)),
        const SizedBox(height: 12),
        PvPress(
          child: GestureDetector(
            key: const ValueKey('brand_page_kit'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(PeeSafeRecoveryKitScreen.route()),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _line),
              ),
              child: Row(children: [
                Icon(Icons.checklist_rounded, size: 18, color: _ink),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Postpartum recovery kit',
                        style: pvJakarta(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink)),
                    const SizedBox(height: 2),
                    Text('A checklist of what to have ready for the weeks after birth.', style: _body(12)),
                  ]),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 15, color: _soft),
              ]),
            ),
          ),
        ),
      ]);

  Widget _invitation(IconData icon, String title, String body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(children: [
          Icon(icon, size: 21, color: _soft),
          const SizedBox(height: 10),
          Text(title, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: _ink)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: _body(12.5)),
        ]),
      );
}

// =============================================================================
//  Film slot — plays videoRef when set, else a still. Never a broken player.
// =============================================================================
class _BrandFilmSlot extends StatefulWidget {
  const _BrandFilmSlot({required this.videoRef, required this.fallbackImage, required this.ink, required this.brand});
  final String? videoRef;
  final String? fallbackImage;
  final Color ink;
  final Brand brand;

  @override
  State<_BrandFilmSlot> createState() => _BrandFilmSlotState();
}

class _BrandFilmSlotState extends State<_BrandFilmSlot> {
  VideoPlayerController? _video;
  bool _ready = false;
  bool _muted = false;

  /// True when the brand has a film at all. A film that failed to load still
  /// falls back to the still, but must not then claim "Film coming soon".
  bool get _hasRef => (widget.videoRef ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    final ref = widget.videoRef;
    if (ref == null || ref.isEmpty) return;
    // Same asset-or-network rule as the Premiere. A failed load stays on the
    // still: the film is a nice-to-have, the page is not allowed to break.
    final v = ref.startsWith('assets/') ? VideoPlayerController.asset(ref) : VideoPlayerController.networkUrl(Uri.parse(ref));
    _video = v;
    v.initialize().timeout(const Duration(seconds: 6)).then((_) {
      if (!mounted) return;
      v.setLooping(true);
      setState(() => _ready = true);
    }).catchError((Object _) {
      // Kept for revert: .catchError((_) {}) — it left a dead controller alive.
      if (!mounted) return;
      setState(() => _video = null);
      v.dispose();
    });
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _video?.setVolume(_muted ? 0 : 1);
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _video;
    final playing = v != null && _ready;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('THE FILM',
          style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: _soft)),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(fit: StackFit.expand, children: [
            if (playing)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(width: v.value.size.width, height: v.value.size.height, child: VideoPlayer(v)),
              )
            else if (widget.fallbackImage != null)
              Image.asset(widget.fallbackImage!, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(color: widget.brand.colour.withValues(alpha: 0.3)))
            else
              ColoredBox(color: widget.brand.colour.withValues(alpha: 0.3)),
            if (playing)
              Center(
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.35)),
                  icon: Icon(v.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () => setState(() => v.value.isPlaying ? v.pause() : v.play()),
                ),
              ),
            if (playing)
              Positioned(
                left: 8,
                bottom: 8,
                child: IconButton.filled(
                  key: const ValueKey('brand_film_mute'),
                  tooltip: _muted ? 'Unmute' : 'Mute',
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.35)),
                  icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white, size: 20),
                  onPressed: _toggleMute,
                ),
              )
            else if (!_hasRef)
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
                  // Kept for revert: 'Film coming soon' (2026-11-03: no "coming soon").
                  child: Text('The ${widget.brand.name} story', style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: widget.ink)),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }
}
