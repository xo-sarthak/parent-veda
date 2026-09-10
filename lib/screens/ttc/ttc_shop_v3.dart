// =============================================================================
//  The TTC product flow — categories → shelf → product
// -----------------------------------------------------------------------------
//  Built 2026-09-03 from the "ParentVeda Product Flow" design project. Three
//  screens, one set of components, wired ONLY into the V3 doors for now.
//
//  **Where to look:** any V3 door → a product tile → the shelf → a product.
//  Also TTC → Tools → Products.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE OLD PRODUCT SCREENS ARE NOT TOUCHED, AND THAT WAS THE INSTRUCTION
//  ---------------------------------------------------------------------------
//
//  The design brief says three screens replace nine across pregnancy, parenting
//  and TTC. That is not what this file does. It builds the three for TTC only;
//  `products_screen.dart`, the five parenting product surfaces and the Guide
//  hub are all untouched and still live. Asked for directly: *"apply this
//  screen or wire the screen only for the trying-to-conceive V3 ones. Don't
//  mess around the old random product screens."*
//
//  `ttc_products_screen.dart` — the flat research page this replaces for V3 —
//  also stays on disk and stays routed at `ttc_products`, because Ask Veda deep
//  links point at it (`ttcprod_folic` → that screen's `focusId`). Two surfaces
//  over one catalogue is the drift risk, and it is survivable here precisely
//  because both read `ttcProducts` and neither holds any copy of its own.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THE DESIGN ASKS FOR THAT THIS DATA CANNOT HONESTLY FILL
//  ---------------------------------------------------------------------------
//
//  The parenting design is drawn against `PpProduct` + `ProductGuide`, which
//  carry ratings, review counts, retailer, photos, ingredients, studies and a
//  `pvScore`. `TtcProduct` carries none of those. So four blocks are rendered
//  as the design's OWN honest-empty states rather than filled with invention:
//
//    * **Ratings from parents** — no review corpus exists. The block says what
//      it will hold.
//    * **The research** — the reads carry the evidence; per-product study cards
//      would mean writing citations we have not read.
//    * **Photography** — the hatch block, at the real 230pt geometry, so
//      nothing shifts when photographs land.
//    * **`pvScore /100`** — replaced by `TtcEvidence`, and the reasoning is on
//      that enum. Inventing a score would be the most authoritative-looking
//      falsehood on the page.
//
//  ⚠️ AND THERE IS NO BUY BUTTON. The design's sticky bar and affiliate
//  interstitial are the sharpest things in it, and both require a retailer this
//  catalogue does not have — no URL, no seller, no affiliate relationship. A
//  Buy button that opens nothing is worse than no Buy button, and building the
//  interstitial now would be building a screen nothing can reach. The sticky
//  bar carries price and Compare instead. Recorded in `docs/STILL-OPEN.md`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND THE ONE THING THAT MAKES THIS NOT A SHOP
//  ---------------------------------------------------------------------------
//
//  The recommendation band is on the CARD, on the shelf, before anything is
//  tapped — including `Generally not needed`. A marketplace ranks and has no
//  vocabulary for "do not buy this", because that sentence costs it money. That
//  band is the whole reason a trust-first page is allowed to look like a shop
//  at all, and it must never move below a fold.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_products_data.dart';
import 'ttc_common.dart';
import 'ttc_records_v2.dart' show TtcRecordsAction;
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// ⚠️ 320, WHICH IS THE DESIGN'S OWN HERO HUE — put back 2026-09-03.
///
/// I shipped 286 on the reasoning that it was closer to the stage's existing
/// violet family. Nobody asked for that. The design project's hero field is
/// `accentHue: 320` on all three screens, and changing it is the difference
/// between a rose-pink header and a dull violet one — reported as *"the one on
/// the phone looks so dull and the one that I gave you looks so bright"*.
///
/// The instruction was to change the words, not the design.
const double kTtcShopHue = 320;

/// The categories screen's own hue — 273 in the design, not 320.
///
/// ⚠️ THE DESIGN USES TWO. `PVCategories` is `accentHue: 273` (violet) and the
/// shelf and product pages are 320 (rose). Using one for all three flattened
/// the flow: every screen looked like the screen before it, and the violet
/// landing that separates "what am I shopping for" from "here is the shelf"
/// was gone.
const double kTtcShopEntryHue = 273;

/// ⚠️ BRIGHTER THAN THE STAGE DEFAULT, DELIBERATELY. `v3FieldChroma` targets
/// C* 26 so that every door feels equally strong beside its neighbours. A shop
/// is not a neighbour of those doors — it is the one surface here allowed to
/// look inviting — and at the default it read as washed out next to the design.
const double kTtcShopChroma = 44;

/// The design system's `action` violet — spent on section eyebrows and links
/// and nowhere else. Never a fill, never a chevron, never a background.
const Color kTtcActionInk = Color(0xFF6A30B6);

// =============================================================================
//  The compare tray
// -----------------------------------------------------------------------------
//  ⚠️ COMPARE WAS A BUTTON THAT DID NOTHING, AND THAT IS WORSE THAN NO BUTTON.
//
//  The shelf held its two ticks in screen state, so leaving the shelf lost them
//  — and the product page's Compare pill was wired to `() {}` because there was
//  nowhere to put a selection that outlived the screen. Reported plainly:
//  "Compare button is not working."
//
//  A tray has to outlive both screens, because the actual journey is: tick one
//  on the shelf, open it, read it, go back, tick another. So it is a singleton
//  `ChangeNotifier` like every other store in this app, and both screens listen.
//
//  ⚠️ TWO AT A TIME, ENFORCED IN THE STORE RATHER THAN IN A SCREEN. The design
//  says so and the parenting compare store already does: "a third would be a
//  table nobody reads at 11pm". Adding a third drops the oldest, so the tick
//  she just made always takes effect — a cap that silently refuses her tap
//  reads as a broken button.
//
//  ⚠️ AND IT IS NOT PERSISTED. What she was torn between on Tuesday is not a
//  preference, and restoring it a week later would put two products in a tray
//  she has no memory of choosing.
// =============================================================================

class TtcCompareTray extends ChangeNotifier {
  TtcCompareTray._();
  static final TtcCompareTray instance = TtcCompareTray._();

  static const int max = 2;

  final List<String> _ids = [];
  List<String> get ids => List.unmodifiable(_ids);

  bool has(String id) => _ids.contains(id);
  bool get isFull => _ids.length >= max;

  List<TtcProduct> get products =>
      _ids.map(ttcProductById).whereType<TtcProduct>().toList();

  void toggle(String id) {
    if (_ids.remove(id)) {
      notifyListeners();
      return;
    }
    _ids.add(id);
    while (_ids.length > max) {
      _ids.removeAt(0);
    }
    notifyListeners();
  }

  void clear() {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
  }
}

// =============================================================================
//  Shared vocabulary
// =============================================================================

/// The band's colour, and it is spent by MEANING rather than by decoration.
///
/// ⚠️ NO RED, ANYWHERE, INCLUDING ON `skip`. Red means danger in this app and
/// "generally not needed" is not a danger — it is a saving. `skip` renders as
/// an outlined dot in plain ink, which reads as "noted" rather than "warning",
/// and is the one band drawn hollow so it is distinguishable without colour.
Color ttcBandColour(TtcRecoBand band) => switch (band) {
      TtcRecoBand.strong => const Color(0xFF2E6B4F),
      TtcRecoBand.buy => const Color(0xFF2E6B4F),
      TtcRecoBand.consider => const Color(0xFF8A6A1F),
      TtcRecoBand.situational => ttcMuted,
      TtcRecoBand.skip => ttcTitleInk,
    };

bool ttcBandFilled(TtcRecoBand band) => band != TtcRecoBand.skip;

/// ⚠️ THE STAR HAS ITS OWN COLOUR, AND IT IS THE ONLY PLACE A RATING GETS ONE.
///
/// A grey star beside grey text is invisible until you meet a product with no
/// rating and notice the difference — reported exactly that way. Amber is what
/// every shelf on earth uses for this and the recognition is worth more than
/// the novelty of not using it.
///
/// It is NOT the same amber as the `consider` band. That one means "worth
/// considering" and carries a judgement; this one is furniture on a number
/// somebody else supplied.
const Color kTtcStarInk = Color(0xFFE0A11A);

/// The dot + label pair, at one of two sizes.
class TtcBandMark extends StatelessWidget {
  const TtcBandMark({super.key, required this.band, this.small = false});

  final TtcRecoBand band;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = ttcBandColour(band);
    final filled = ttcBandFilled(band);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: small ? 8 : 10,
        height: small ? 8 : 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? c : Colors.transparent,
          border: filled ? null : Border.all(color: c, width: 1.6),
        ),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: Text(band.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
                fontSize: small ? 9.5 : 11,
                fontWeight: FontWeight.w800,
                letterSpacing: small ? 1.1 : 1.2,
                color: c)),
      ),
    ]);
  }
}

/// The honest hatch, at whatever height the caller needs.
///
/// ⚠️ NOT A GREY BOX AND NOT A BROKEN IMAGE ICON. It occupies the real
/// geometry a photograph will occupy, so the page does not reflow on the day
/// the pictures land — the same rule `pv_placeholders.dart` already holds for
/// films.
class TtcPhotoPending extends StatelessWidget {
  const TtcPhotoPending({super.key, required this.height, this.label = true});

  final double height;
  final bool label;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ttcPanel,
          borderRadius: BorderRadius.circular(height > 120 ? 22 : 14),
          border: Border.all(color: ttcBorder),
        ),
        child: CustomPaint(
          painter: _HatchPainter(),
          child: !label
              ? null
              : Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('No photo yet',
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: ttcSoft)),
                  ),
                ),
        ),
      );
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ttcMuted.withValues(alpha: 0.16)
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
//  SCREEN 1 — what are we shopping for?
// =============================================================================

void openTtcShop(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/shop'),
      builder: (_) => const TtcShopScreen(),
    ));

class TtcShopScreen extends StatefulWidget {
  const TtcShopScreen({super.key});

  @override
  State<TtcShopScreen> createState() => _TtcShopScreenState();
}

class _TtcShopScreenState extends State<TtcShopScreen> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  bool get _searching => _query.trim().isNotEmpty;

  /// One hue per category, from the app's own wheel. Fixed saturation and
  /// lightness; only the hue varies, which is what stops five tinted rows
  /// looking like five different design systems.
  static const _hues = <String, double>{
    'supplements': 104,
    'kits': 206,
    'tests': 344,
    'wellness': 160,
    'books': 42,
  };

  static const _promise = <String, String>{
    'supplements': 'What has evidence, what does not, and what to skip.',
    'kits': 'Useful for a cycle or two. Less so every month after.',
    'tests': 'They all work. The trap is testing too early.',
    'wellness': 'The few things worth buying, and the many that are not.',
    'books': 'For the waiting, which is the part nobody prepares you for.',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([TtcLang.instance, TtcCompareTray.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final hits = _searching ? ttcSearchProducts(_query) : const <TtcProduct>[];

        return TtcToolScaffold(
          hue: kTtcShopEntryHue,
          chroma: kTtcShopChroma,
          eyebrow: 'Products',
          title: 'What are you\nlooking for?',
          // ⚠️ THE PROMISE IS MADE BEFORE THE FIRST ROW, not at the bottom in
          // small print. Everything under this line is chosen to be defensible
          // rather than to be bought.
          intro: 'Ten things people buy while trying, and an honest line on '
              'each. Several of them are here to talk you out of the '
              'purchase.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ⚠️ THE SEARCH BAR THE DESIGN OPENS WITH, AND IT WAS MISSING.
                // Reported as "there is no search bar, I cannot search at all,
                // no matter which page I am on".
                //
                // It searches names, brands and categories at once, because
                // somebody typing "folic" and somebody typing "Folvite" are
                // asking the same question, and a search that only matches the
                // product name would answer one of them.
                _SearchBar(
                  controller: _q,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() {
                    _q.clear();
                    _query = '';
                  }),
                ),
                const SizedBox(height: 20),

                if (_searching) ...[
                  Text(
                      hits.isEmpty
                          ? 'Nothing here matches "${_query.trim()}".'
                          : '${hits.length} '
                              '${hits.length == 1 ? 'result' : 'results'}',
                      style: ttcBody(12.5, color: ttcMuted)),
                  const SizedBox(height: 12),
                  if (hits.isEmpty)
                    TtcCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ten things, five shelves.',
                                style: ttcJakarta(15)),
                            const SizedBox(height: 7),
                            Text(
                                'This is a short, deliberately short list — not '
                                'a catalogue. If what you are looking for is '
                                'not here, it is usually because there is '
                                'nothing worth saying about it yet.',
                                style: ttcBody(13, h: 1.5)),
                            const SizedBox(height: 14),
                            TtcRecordsAction(
                                label: 'Show me everything',
                                onTap: () => setState(() {
                                      _q.clear();
                                      _query = '';
                                    })),
                          ]),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.46,
                      children: [
                        for (final p in hits)
                          TtcProductCard(product: p, hi: hi),
                      ],
                    ),
                ] else ...[
                  // ⚠️ HIS SHELF IS A STRIP, NOT A TAB — and the parenting
                  // design put a child's age here. There is no child. What
                  // there is, and what this stage exists to correct, is that
                  // half of this is his and almost nothing sold for fertility
                  // says so.
                  _PartnerStrip(hi: hi),
                  const SizedBox(height: 20),

                  for (final (id, en, hiName) in ttcProductCategories) ...[
                    _CategoryRow(
                      id: id,
                      label: hi ? hiName : en,
                      promise: _promise[id] ?? '',
                      hue: _hues[id] ?? kTtcShopHue,
                      count: ttcProductsIn(id).length,
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 20),
                  // ⚠️ THE DESIGN'S COMPARE ROW, AND IT WAS MISSING TOO —
                  // "where will I compare two products then?". A row rather
                  // than a hero card, because comparing is a step inside
                  // researching and not a tool you go and find.
                  _CompareEntry(),
                ],

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                        'Nothing here is sold by ParentVeda and nothing is '
                        'sponsored. Prices are indicative Indian ranges and '
                        'will drift.',
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.id,
    required this.label,
    required this.promise,
    required this.hue,
    required this.count,
  });

  final String id;
  final String label;
  final String promise;
  final double hue;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tint = HSLColor.fromAHSL(1, hue, 0.32, 0.91).toColor();
    final deep = HSLColor.fromAHSL(1, hue, 0.34, 0.34).toColor();
    final names = ttcProductsIn(id)
        .map((p) => p.name(TtcS.current().hinglish))
        .take(3)
        .join(' · ');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'ttc/shop/$id'),
        builder: (_) => TtcShelfScreen(category: id),
      )),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The drawn mark — one filled shape in the row's own hue, detail
          // knocked out in white. Not a stock icon set, and never a photo.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: deep, borderRadius: BorderRadius.circular(13)),
            child: Icon(_markFor(id), size: 21, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: ttcFraunces(16.5,
                          w: FontWeight.w600, color: ttcTitleInk)),
                  const SizedBox(height: 4),
                  Text(promise,
                      style: ttcBody(12.5, color: deep, h: 1.4)),
                  const SizedBox(height: 6),
                  Text('$count · $names',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(11.5, color: deep.withValues(alpha: 0.7))),
                ]),
          ),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.chevron_right_rounded, size: 17, color: deep),
          ),
        ]),
      ),
    );
  }

  static IconData _markFor(String id) => switch (id) {
        'supplements' => Icons.medication_outlined,
        'kits' => Icons.science_outlined,
        'tests' => Icons.check_circle_outline_rounded,
        'wellness' => Icons.spa_outlined,
        'books' => Icons.menu_book_outlined,
        _ => Icons.shopping_bag_outlined,
      };
}

/// His half, shown rather than filed under a tab.
class _PartnerStrip extends StatelessWidget {
  const _PartnerStrip({required this.hi});
  final bool hi;

  @override
  Widget build(BuildContext context) {
    final his = ttcProducts.where((p) => p.forPartner).toList();
    if (his.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('FOR HIM',
          style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: kTtcActionInk)),
      const SizedBox(height: 10),
      // ⚠️ THE SAME CARD AS EVERY OTHER PRODUCT — CHANGED 2026-09-04.
      //
      // This was a thin row: name, band, one line. Reported directly, and the
      // point is not consistency for its own sake — his half of the shelf
      // rendered as a lesser kind of object than hers, on the one door in this
      // stage whose argument is that his half counts equally.
      SizedBox(
        height: TtcProductCard.railHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: his.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) =>
              TtcProductCard(product: his[i], hi: hi, width: 168),
        ),
      ),
    ]);
  }
}

/// ⚠️ KEPT FOR REVERT, NOT RENDERED. The thin row that used to stand in for a
/// product on the For-him strip and in search results. Replaced by
/// `TtcProductCard` because a product shown as a row is a different kind of
/// object from a product shown as a card, and his half of the shelf was the
/// one wearing the lesser shape.
// ignore: unused_element
class _ProductRowCompact extends StatelessWidget {
  const _ProductRowCompact({required this.product, required this.hi});
  final TtcProduct product;
  final bool hi;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        onTap: () => openTtcProductPage(context, product.id),
        child: TtcCard(
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name(hi), style: ttcJakarta(14.5)),
                    const SizedBox(height: 6),
                    TtcBandMark(band: product.band, small: true),
                    const SizedBox(height: 6),
                    Text(product.verdict.isEmpty
                        ? product.why(hi)
                        : product.verdict,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                  ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
          ]),
        ),
      );
}

// =============================================================================
//  SCREEN 2 — the shelf
// =============================================================================

class TtcShelfScreen extends StatefulWidget {
  const TtcShelfScreen({super.key, required this.category});
  final String category;

  @override
  State<TtcShelfScreen> createState() => _TtcShelfScreenState();
}

class _TtcShelfScreenState extends State<TtcShelfScreen> {
  /// ⚠️ THE SHARED TRAY, NOT A LIST ON THIS SCREEN. It used to be screen
  /// state, which meant opening a product and coming back lost the tick — and
  /// that is the actual journey: tick one, read it, go back, tick another.
  /// See `TtcCompareTray`.

  /// ⚠️ FOUR FILTERS, NOT TWO — 2026-09-04. "Everything / Worth buying" was
  /// the only pair this catalogue could support at ten items, and it was
  /// reported as too few. These four are each a question somebody actually
  /// arrives with, and every one of them is a field that exists rather than a
  /// facet invented to fill a row:
  ///
  ///   * Everything      — the default, always. A shelf that opens filtered
  ///                       has quietly become a shop.
  ///   * Worth buying    — band strong / buy / consider.
  ///   * Strong evidence — the question this stage is actually about.
  ///   * For him         — the one thing this catalogue knows about a reader.
  ///
  /// ⚠️ AND THERE IS NO PRICE FILTER. Four price bands over ten items is
  /// furniture: two of the bands would be empty and one would hold everything.
  /// ⚠️ THREE DIMENSIONS, EACH A FIELD THAT EXISTS. Band, evidence and whose
  /// it is — not facets invented to make the sheet look full. There is still no
  /// price filter, and there should not be: four price bands over ten items
  /// leaves two empty and one holding everything.
  Set<TtcRecoBand> _bands = {};
  Set<TtcEvidence> _evidence = {};

  /// null = everyone, true = his, false = hers.
  bool? _whose;

  TtcShelfSort _sort = TtcShelfSort.recommended;

  int get _activeCount =>
      _bands.length + _evidence.length + (_whose == null ? 0 : 1);

  String get _sortLabel => switch (_sort) {
        TtcShelfSort.recommended => 'How strongly we recommend it',
        TtcShelfSort.priceLow => 'Price, low to high',
        TtcShelfSort.priceHigh => 'Price, high to low',
        TtcShelfSort.evidence => 'Strength of evidence',
      };

  List<(String, VoidCallback)> get _activeChips => [
        for (final b in _bands)
          (b.label, () => setState(() => _bands.remove(b))),
        for (final e in _evidence)
          ('${e.label} evidence', () => setState(() => _evidence.remove(e))),
        if (_whose != null)
          (_whose! ? 'For him' : 'For her', () => setState(() => _whose = null)),
      ];

  /// Searching within the shelf.
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, TtcCompareTray.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final tray = TtcCompareTray.instance;

        final label = ttcProductCategories
            .where((c) => c.$1 == widget.category)
            .map((c) => hi ? c.$3 : c.$2)
            .firstOrNull ??
            'Products';

        var items = ttcProductsIn(widget.category);
        if (_bands.isNotEmpty) {
          items = items.where((p) => _bands.contains(p.band)).toList();
        }
        if (_evidence.isNotEmpty) {
          items = items.where((p) => _evidence.contains(p.evidence)).toList();
        }
        if (_whose != null) {
          items = items.where((p) => p.forPartner == _whose).toList();
        }
        if (_query.trim().isNotEmpty) {
          final hits = ttcSearchProducts(_query).map((p) => p.id).toSet();
          items = items.where((p) => hits.contains(p.id)).toList();
        }
        // ⚠️ THE ORDER IS STATED, NOT HIDDEN. The count line below names
        // whichever sort is on. A shelf whose order is unexplained is a shelf
        // that could be sponsored and nobody could tell.
        items = ttcSortShelf(items, _sort);

        return Stack(children: [
          TtcToolScaffold(
            hue: kTtcShopHue,
            chroma: kTtcShopChroma,
            variant: 2,
            eyebrow: 'Products',
            title: label,
            intro: _guidanceFor(widget.category),
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  _SearchBar(
                    controller: _q,
                    onChanged: (v) => setState(() => _query = v),
                    onClear: () => setState(() {
                      _q.clear();
                      _query = '';
                    }),
                  ),
                  const SizedBox(height: 14),
                  // ⚠️ A FILTERS BUTTON THAT OPENS A SHEET, WHICH IS WHAT THE
                  // DESIGN SPECIFIES — CORRECTED 2026-09-04.
                  //
                  // I shipped a row of chips instead, then "fixed" it by adding
                  // two more chips. Reported bluntly: *"I don't need you to
                  // just add more buttons for filter. There should be a
                  // dedicated filter button. You have seen that Claude Design."*
                  //
                  // The design is right and the reason is not taste. A chip row
                  // shows every filter at once and can only ever hold one
                  // dimension — you cannot say "strong evidence AND for him" —
                  // and it eats a line of the shelf permanently. A button plus
                  // a sheet is the marketplace convention every reader already
                  // knows, holds as many dimensions as the data has, and gives
                  // the shelf its line back.
                  Row(children: [
                    _FiltersButton(
                      count: _activeCount,
                      onTap: () async {
                        final next = await showTtcShelfFilters(
                            context, _bands, _evidence, _whose);
                        if (next == null) return;
                        setState(() {
                          _bands = next.bands;
                          _evidence = next.evidence;
                          _whose = next.whose;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SortButton(
                        label: _sortLabel,
                        onTap: () async {
                          final next = await showTtcShelfSort(context, _sort);
                          if (next != null) setState(() => _sort = next);
                        },
                      ),
                    ),
                  ]),
                  if (_activeCount > 0) ...[
                    const SizedBox(height: 12),
                    // Active filters as removable chips, beneath the bar —
                    // the design's own arrangement, and the only way somebody
                    // can see what is narrowing a short shelf.
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final chip in _activeChips)
                        _ActiveChip(label: chip.$1, onRemove: chip.$2),
                    ]),
                  ],
                  const SizedBox(height: 14),

                  Text(
                      '${items.length} '
                      '${items.length == 1 ? 'item' : 'items'} · ordered by '
                      '${_sortLabel.toLowerCase()}',
                      style: ttcBody(12, color: ttcMuted, h: 1.45)),
                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    TtcCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _query.trim().isEmpty
                                    ? 'Nothing on this shelf matches that.'
                                    : 'Nothing here matches '
                                        '"${_query.trim()}".',
                                style: ttcJakarta(15)),
                            const SizedBox(height: 7),
                            Text(
                                'Either the filter is narrower than the shelf, '
                                'or everything here is something we would only '
                                'suggest in a narrow case. Both are answers '
                                'rather than empty screens.',
                                style: ttcBody(13, h: 1.5)),
                            const SizedBox(height: 14),
                            TtcRecordsAction(
                                label: 'Show me all of them anyway',
                                onTap: () => setState(() {
                                      _bands = {};
                                      _evidence = {};
                                      _whose = null;
                                      _q.clear();
                                      _query = '';
                                    })),
                          ]),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.46,
                      children: [
                        for (final p in items)
                          TtcProductCard(product: p, hi: hi),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _RowLink(
                    label: 'The other shelves',
                    sub: 'Supplements, kits, tests, wellness and books — and '
                        'what we would not buy.',
                    onTap: () => openTtcShop(context),
                  ),
                  SizedBox(height: tray.ids.length == 2 ? 110 : 26),
                ],
              )),
            ],
          ),
          // ⚠️ THE YELLOW UNDERLINES WERE NEVER AN OVERFLOW. I said "overflow
          // hatching" twice and fixed two real but unrelated overflows; the
          // lines in the screenshots are Flutter's MISSING-MATERIAL marker —
          // the dashed amber underline it draws on any `Text` with no
          // `Material` ancestor.
          //
          // This bar and the compare pill sit in a `Stack` as SIBLINGS of the
          // `Scaffold`, not inside it, so nothing above them provides one.
          // Wrapping in a transparent `Material` is the whole fix, and it is
          // also what gives them ink splashes.
          //
          // Worth remembering as a rule: amber underlines under every string
          // in one region means no Material there. Yellow-and-black diagonal
          // hatching along one edge means overflow. They look similar in a
          // screenshot and have nothing to do with each other.
          if (tray.ids.length == 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                type: MaterialType.transparency,
                child: _CompareBar(
                  ids: tray.ids,
                  hi: hi,
                  onClear: tray.clear,
                ),
              ),
            ),
        ]);
      },
    );
  }

  /// The shelf's own guidance, above the products. It is allowed to tell her
  /// to buy nothing.
  static String _guidanceFor(String category) => switch (category) {
        'supplements' =>
          'One of these has settled evidence behind it. Most of the rest are '
              'sold on hope, and one is here so you can stop feeling guilty '
              'about not buying it.',
        'kits' =>
          'Useful while you learn your own pattern, and much less useful after '
              'that. If testing daily is making the month heavier, stopping is '
              'a good decision.',
        'tests' =>
          'They all work, and the cheap ones work as well as the expensive '
              'ones. Almost every disappointment here is a test taken too '
              'early.',
        'wellness' =>
          'A short shelf on purpose. Most of what is sold under this word for '
              'fertility has nothing behind it.',
        'books' =>
          'For the waiting rather than the trying. Avoid anything promising a '
              'method or a number of days.',
        _ => 'What is worth buying, and what is not.',
      };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: on ? ttcTitleInk : ttcBorder, width: on ? 1.3 : 1.2),
          ),
          child: Text(label,
              style: ttcBody(12.5,
                  color: on ? ttcTitleInk : ttcSoft,
                  w: on ? FontWeight.w800 : FontWeight.w600)),
        ),
      );
}

String _shelfThousands(int n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

/// ⚠️ ONE PRODUCT CARD, USED EVERYWHERE A PRODUCT APPEARS — 2026-09-04.
///
/// There were three shapes doing this job: the shelf grid card, a stripped
/// "compact row" for the For-him strip and the search results, and a smaller
/// still one on the Also-on-this-shelf rail. Reported directly: *"see the way
/// you are representing products initially — the card of the product image,
/// name, brand, price, all that. Don't change that. Use the same thing."*
///
/// He is right, and the reason is not consistency for its own sake. A product
/// shown as a row with a name and a band is a DIFFERENT KIND OF OBJECT from a
/// product shown as a card with a price and a rating — and zinc appearing as
/// the thin version made his half of the shelf look like an afterthought,
/// which is the exact thing this stage exists to correct.
///
/// So: one card, one width, four placements.
///
/// ⚠️ AND COMPARE IS A LABELLED CONTROL INSIDE THE CARD, NOT A TICK IN THE
/// CORNER. The tick was ambiguous — *"am I adding it to my cart? am I comparing
/// it?"* — and a control whose meaning has to be guessed is a control nobody
/// uses. It sits under the band, says the word, and changes to "Comparing" when
/// it is on.
class TtcProductCard extends StatelessWidget {
  const TtcProductCard({
    super.key,
    required this.product,
    required this.hi,
    this.width,
  });

  final TtcProduct product;
  final bool hi;

  /// Null inside a grid; a fixed width on a horizontal rail.
  final double? width;

  /// What a horizontal rail of these needs.
  ///
  /// ⚠️ MEASURED AGAINST THE WORST CARD, NOT THE AVERAGE ONE. 310 fitted most
  /// of them and overflowed by 28 on the two whose name wraps to two lines AND
  /// which carry a badge — `A "fertility blend" multivitamin` is the tallest
  /// card in the catalogue. A rail height set from a typical card is a rail
  /// that draws stripes on the atypical one.
  static const double railHeight = 356;

  @override
  Widget build(BuildContext context) {
    final tray = TtcCompareTray.instance;
    final on = tray.has(product.id);

    final card = Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcBorder),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TtcProductMark(hue: product.hue, height: 104),

            // ⚠️ ONE BADGE AT MOST, and only where it is earned.
            if (product.badge.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: ttcPanel,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(product.badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: ttcSoft)),
              ),
            ],

            const SizedBox(height: 10),
            Text(product.name(hi),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(12.5,
                    color: ttcTitleInk, w: FontWeight.w700, h: 1.3)),
            if (product.brand.isNotEmpty)
              Text(product.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(11, color: ttcMuted)),

            // ⚠️ NO `Expanded` HERE ANY MORE — this was the "lot of empty
            // space between the brand name and the price". The card sat in a
            // grid cell taller than its content and an `Expanded` around the
            // name stretched to fill it, pushing the price to the floor. The
            // card now sizes to its content and the grid's aspect ratio is
            // tuned to match.
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(product.price,
                      style: ttcFraunces(16.5,
                          w: FontWeight.w600, color: ttcTitleInk)),
                  if (product.size.isNotEmpty)
                    Flexible(
                      child: Text(' ${product.size}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ttcBody(11, color: ttcMuted)),
                    ),
                ]),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.star_rounded, size: 13, color: kTtcStarInk),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                    '${product.rating.toStringAsFixed(1)} · '
                    '${_shelfThousands(product.reviews)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(11, color: ttcSoft, w: FontWeight.w600)),
              ),
            ]),

            const SizedBox(height: 8),
            TtcBandMark(band: product.band, small: true),

            const SizedBox(height: 10),
            _CompareToggle(
              on: on,
              onTap: () {
                tray.toggle(product.id);
                final picked = tray.products;
                if (picked.length == 2) {
                  showTtcCompare(context, picked);
                }
              },
            ),
          ]),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openTtcProductPage(context, product.id),
      child: card,
    );
  }
}

/// The in-card compare control. Says the word, and says it differently when on.
class _CompareToggle extends StatelessWidget {
  const _CompareToggle({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 32,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? ttcTitleInk : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? ttcTitleInk : ttcBorder),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(on ? Icons.check_rounded : Icons.compare_arrows_rounded,
                size: 14, color: on ? Colors.white : ttcSoft),
            const SizedBox(width: 5),
            Flexible(
              child: Text(on ? 'Comparing' : 'Compare',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(11.5,
                      color: on ? Colors.white : ttcSoft,
                      w: FontWeight.w800)),
            ),
          ]),
        ),
      );
}

class _CompareBar extends StatelessWidget {
  const _CompareBar(
      {required this.ids, required this.hi, required this.onClear});

  final List<String> ids;
  final bool hi;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final picked = ids.map(ttcProductById).whereType<TtcProduct>().toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ttcBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: Text(picked.map((p) => p.name(hi)).join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showTtcCompare(context, picked),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ttcTitleInk,
                    borderRadius: BorderRadius.circular(999)),
                child: Text('Compare',
                    style: ttcBody(12.5,
                        color: Colors.white, w: FontWeight.w800)),
              ),
            ),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            Expanded(
              child: Text(
                  'Two at a time. A third would be a table nobody reads.',
                  style: ttcBody(11, color: ttcMuted)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Text('Clear',
                  style: ttcBody(11.5, color: ttcSoft, w: FontWeight.w800)),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Open the comparison.
///
/// ⚠️ IT IS A SCREEN NOW, NOT A BOTTOM SHEET — 2026-09-04.
///
/// I built a sheet. Reported: *"for compare see in app we have a whole compare
/// screen already present, lol we have a separate tool meaning use tht screen
/// for it"* — and that is right on both counts. Comparing is a task somebody
/// sits with: they scroll a table, take one out, put another in, and come back
/// to it. A sheet is the wrong container for that. It caps at 88% of the
/// screen, it dismisses on a downward drag — which is also the gesture for
/// scrolling a table — and it cannot hold a sticky buy bar without fighting
/// its own scroll.
///
/// So this is `ProductsCompareScreen`'s anatomy, which is the screen that was
/// being pointed at: the three states (nothing picked, one picked, two picked),
/// overview cards you can manage in place, one column-divided table, and a buy
/// bar per product.
///
/// ⚠️ WHY NOT LITERALLY PUSH THAT WIDGET. I looked, and it will not go. Three
/// hard blocks, none of them cosmetic:
///
///   1. It is typed on `PpProduct` and reads `PpCompareStore`. Both are the
///      parenting catalogue. Converting a `TtcProduct` across drops `band` and
///      `evidence` — the two facts this whole shelf is built to show — and
///      putting TTC items in `PpCompareStore` would make them appear on the
///      parenting product cards, which read the same store.
///   2. Its empty state calls `openPpTab(context, 4)`. Tapped from a TTC door,
///      that lands her in the parenting Products tab. Not a style problem.
///   3. It is painted in `ppPurple` on `ppBg` in `ppFraunces`.
///
/// The honest alternative is to lift the layout into one widget both stages
/// pass their own products to. That is worth doing and it edits shipped
/// parenting code, so it is written down in `docs/STILL-OPEN.md` §24 rather
/// than done quietly in a bug-fix pass.
Future<void> showTtcCompare(BuildContext context, List<TtcProduct> pair) {
  if (pair.isEmpty) return Future<void>.value();
  return Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'ttc/shop/compare'),
    builder: (_) => const TtcCompareScreen(),
  ));
}

/// Side by side, for two.
///
/// ⚠️ IT HOLDS NO PRODUCTS OF ITS OWN. Like the parenting one, it is a view of
/// the tray — add, remove or clear from anywhere and this rebuilds. That is the
/// reason it can be opened from four places (a shelf bar, a product pill, the
/// For-him rail, the shop entry) without any of them passing state.
class TtcCompareScreen extends StatelessWidget {
  const TtcCompareScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcCompareTray.instance,
        builder: (context, _) {
          final picked = TtcCompareTray.instance.products;
          if (picked.isEmpty) return const _CompareEmpty();
          if (picked.length == 1) return _CompareOne(product: picked.first);
          return _CompareBoth(pair: picked);
        },
      );
}

// ---- chrome shared by the three states -------------------------------------

Widget _comparePad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

Widget _compareBack(BuildContext context, String eyebrow,
        {bool showClear = false}) =>
    _comparePad(Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration:
              const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, size: 16, color: ttcTitleInk),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: ttcMuted)),
      ),
      if (showClear)
        GestureDetector(
          onTap: TtcCompareTray.instance.clear,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text('Clear',
                style:
                    ttcBody(12.5, color: kTtcActionInk, w: FontWeight.w700)),
          ),
        ),
    ]));

// =============================================================================
//  0 picked
// =============================================================================

class _CompareEmpty extends StatelessWidget {
  const _CompareEmpty();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ttcBg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _compareBack(context, 'Compare'),
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: ttcPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.compare_arrows_rounded,
                      size: 40, color: kTtcActionInk),
                ),
              ),
              const SizedBox(height: 26),
              _comparePad(Text('Nothing picked yet.',
                  textAlign: TextAlign.center,
                  style: ttcFraunces(25, h: 1.15, color: ttcTitleInk))),
              const SizedBox(height: 12),
              _comparePad(Text(
                  'Tap Compare on any two products on a shelf and they will '
                  'come here, side by side.',
                  textAlign: TextAlign.center,
                  style: ttcBody(14, color: ttcSoft, h: 1.6))),
              const SizedBox(height: 26),
              _comparePad(GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: kTtcActionInk,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text('Back to the shelf',
                      style: ttcBody(14.5,
                          color: Colors.white, w: FontWeight.w700)),
                ),
              )),
            ],
          ),
        ),
      );
}

// =============================================================================
//  1 picked — the product, and what it could sensibly be held against
// =============================================================================

class _CompareOne extends StatelessWidget {
  const _CompareOne({required this.product});
  final TtcProduct product;

  @override
  Widget build(BuildContext context) {
    final hi = TtcS.current().hinglish;

    // ⚠️ SUGGESTIONS COME FROM THE SAME SHELF, AND THAT IS A RULE NOT A
    // CONVENIENCE. Comparing a folic acid against an ovulation strip produces a
    // table of "not applicable" and teaches nothing. Same category or nothing.
    final others = ttcProductsIn(product.category)
        .where((p) => p.id != product.id)
        .toList();

    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _compareBack(context, 'Compare · ${product.category}',
                showClear: true),
            const SizedBox(height: 20),
            _comparePad(Text('One picked. Pick one more.',
                style: ttcFraunces(28, h: 1.14, color: ttcTitleInk))),
            const SizedBox(height: 20),
            _comparePad(_CompareOverview(product: product)),
            if (others.isNotEmpty) ...[
              const SizedBox(height: 26),
              _comparePad(Text('ALSO ON THIS SHELF',
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: ttcMuted))),
              const SizedBox(height: 12),
              for (final o in others) ...[
                _comparePad(_CompareSuggestion(product: o, hi: hi)),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CompareSuggestion extends StatelessWidget {
  const _CompareSuggestion({required this.product, required this.hi});
  final TtcProduct product;
  final bool hi;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => TtcCompareTray.instance.toggle(product.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ttcBorder),
          ),
          child: Row(children: [
            // ⚠️ A WIDTH, BECAUSE `TtcProductMark` ASKS FOR `double.infinity`.
            // That is right inside a card, where the column bounds it, and it
            // throws `BoxConstraints forces an infinite width` inside a `Row`,
            // which is unbounded horizontally. The mark is not wrong — a widget
            // that fills its parent is the normal shape — the caller has to
            // supply the bound. Caught by the compare test, not by reading it.
            SizedBox(
              width: 54,
              child: TtcProductMark(hue: product.hue, height: 54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name(hi),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ttcBody(13.5,
                            color: ttcTitleInk, w: FontWeight.w700, h: 1.25)),
                    const SizedBox(height: 6),
                    TtcBandMark(band: product.band, small: true),
                  ]),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: kTtcActionInk,
                  borderRadius: BorderRadius.circular(999)),
              child: Text('Add',
                  style: ttcBody(12,
                      color: Colors.white, w: FontWeight.w800)),
            ),
          ]),
        ),
      );
}

// =============================================================================
//  2 picked — the comparison proper
// =============================================================================

class _CompareBoth extends StatelessWidget {
  const _CompareBoth({required this.pair});
  final List<TtcProduct> pair;

  @override
  Widget build(BuildContext context) {
    final hi = TtcS.current().hinglish;

    // ⚠️ THE UNION OF THE TWO SPEC LISTS, NOT THE INTERSECTION. If one product
    // states its dose and the other does not, the row still appears with a dash
    // against the silent one — because "it does not say" is itself the answer
    // somebody is comparing on, and an intersection would hide exactly the
    // difference she came to find.
    final keys = <String>[];
    for (final p in pair) {
      for (final (k, _) in p.specs) {
        if (!keys.contains(k)) keys.add(k);
      }
    }
    String specOf(TtcProduct p, String k) => p.specs
        .where((s) => s.$1 == k)
        .map((s) => s.$2)
        .firstOrNull ??
        '—';

    final sameShelf = pair.every((p) => p.category == pair.first.category);

    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 112),
            children: [
              _compareBack(
                  context,
                  'Compare · ${sameShelf ? pair.first.category : 'two products'}',
                  showClear: true),
              const SizedBox(height: 20),
              _comparePad(Text('Side by side.',
                  style: ttcFraunces(30, h: 1.14, color: ttcTitleInk))),

              // ⚠️ THE FRAMING COMES BEFORE THE TABLE, DELIBERATELY. A
              // comparison table is persuasive furniture: two columns of ticks
              // imply that the winner is whichever has more of them. Saying
              // which column matters, before she reads any of them, is the one
              // thing that stops this page from becoming an advert with a grid
              // in it.
              const SizedBox(height: 16),
              _comparePad(Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ttcPanel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: kTtcActionInk),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Before you read it: the evidence row matters more '
                            'than the price row, and neither of these is a '
                            'treatment.',
                            style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
                      ),
                    ]),
              )),

              // overview cards, each removable in place
              const SizedBox(height: 20),
              _comparePad(Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < pair.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                          child: _CompareOverview(
                              product: pair[i], manage: true)),
                    ],
                  ])),

              // ---- one column-divided table ------------------------------
              const SizedBox(height: 20),
              _comparePad(Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ttcBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  _CompareTRow(
                    cells: [
                      for (final p in pair)
                        Text(p.name(hi),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ttcBody(13,
                                color: ttcTitleInk,
                                w: FontWeight.w800,
                                h: 1.25)),
                    ],
                    header: true,
                  ),
                  _CompareTRow(
                    label: 'How strongly we recommend it',
                    cells: [
                      for (final p in pair)
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TtcBandMark(band: p.band, small: true)),
                    ],
                  ),
                  _CompareTRow(
                    label: 'Evidence',
                    cells: [
                      for (final p in pair)
                        _CompareValue(p.evidence.label),
                    ],
                  ),
                  _CompareTRow(
                    label: 'Price',
                    cells: [for (final p in pair) _CompareValue(p.priceEn)],
                  ),
                  _CompareTRow(
                    label: 'Whose',
                    cells: [
                      for (final p in pair)
                        _CompareValue(p.forPartner ? 'His' : 'Hers'),
                    ],
                  ),
                  for (final k in keys)
                    _CompareTRow(
                      label: k,
                      cells: [
                        for (final p in pair) _CompareValue(specOf(p, k)),
                      ],
                    ),
                  _CompareTRow(
                    label: "What's good",
                    cells: [for (final p in pair) _CompareList(p.goods)],
                  ),
                  _CompareTRow(
                    label: 'Worth knowing',
                    cells: [for (final p in pair) _CompareList(p.watchOuts)],
                  ),
                  _CompareTRow(
                    label: 'Our take',
                    cells: [
                      for (final p in pair)
                        Text(
                            p.verdict.isEmpty ? p.why(hi) : p.verdict,
                            style: ttcBody(12, color: ttcInk, h: 1.5)),
                    ],
                    last: true,
                  ),
                ]),
              )),

              const SizedBox(height: 20),
              _comparePad(Text(
                  'Our take is written the same way whether or not anyone pays '
                  'us. Where the honest answer is "neither", the page says so.',
                  textAlign: TextAlign.center,
                  style: ttcBody(12, color: ttcMuted, h: 1.55))),
            ],
          ),

          // ⚠️ A BUY BAR PER PRODUCT. The comparison ends in a decision, and
          // a decision needs somewhere to land — a table you have to navigate
          // back out of to act on is a table people re-read instead of using.
          //
          // Transparent `Material` because this sits in a `Stack` beside the
          // `Scaffold`, not inside it — same missing-Material rule as the
          // shelf's compare bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: ttcBorder)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(children: [
                    for (var i = 0; i < pair.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              showTtcBuyInterstitial(context, pair[i]),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: i == 0
                                    ? kTtcActionInk
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: kTtcActionInk,
                                    width: i == 0 ? 1 : 1.3)),
                            child: Text('Buy ${_buyLabel(pair[i], hi)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ttcBody(13,
                                    color: i == 0
                                        ? Colors.white
                                        : kTtcActionInk,
                                    w: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---- the pieces ------------------------------------------------------------

/// One product's card at the top of the comparison.
class _CompareOverview extends StatelessWidget {
  const _CompareOverview({required this.product, this.manage = false});
  final TtcProduct product;
  final bool manage;

  @override
  Widget build(BuildContext context) {
    final hi = TtcS.current().hinglish;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcBorder),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(children: [
              TtcProductMark(hue: product.hue, height: 92),
              if (manage)
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () =>
                        TtcCompareTray.instance.toggle(product.id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: ttcBorder),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: ttcSoft),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 10),
            if (product.brand.isNotEmpty) ...[
              Text(product.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: ttcMuted)),
              const SizedBox(height: 4),
            ],
            Text(product.name(hi),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(13.5,
                    color: ttcTitleInk, w: FontWeight.w700, h: 1.25)),
            const SizedBox(height: 8),
            TtcBandMark(band: product.band, small: true),
            const SizedBox(height: 8),
            Text(product.priceEn,
                style: ttcBody(13, color: ttcInk, w: FontWeight.w800)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => openTtcProductPage(context, product.id),
              behavior: HitTestBehavior.opaque,
              child: Text('See the full page',
                  style: ttcBody(11.5,
                      color: kTtcActionInk, w: FontWeight.w700)),
            ),
          ]),
    );
  }
}

/// One row of the comparison table: an optional label, then one cell per
/// product, divided by a vertical rule.
class _CompareTRow extends StatelessWidget {
  const _CompareTRow(
      {required this.cells,
      this.label,
      this.header = false,
      this.last = false});

  final List<Widget> cells;
  final String? label;
  final bool header;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: header ? ttcPanel : Colors.white,
          border: last
              ? null
              : Border(bottom: BorderSide(color: ttcBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(label!.toUpperCase(),
                    style: pvManrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: ttcMuted)),
                const SizedBox(height: 8),
              ],
              IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cells.length; i++) ...[
                        if (i > 0)
                          Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              color: ttcBorder),
                        Expanded(child: cells[i]),
                      ],
                    ]),
              ),
            ]),
      );
}

class _CompareValue extends StatelessWidget {
  const _CompareValue(this.value);
  final String value;

  @override
  Widget build(BuildContext context) => Text(value,
      style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700, h: 1.4));
}

class _CompareList extends StatelessWidget {
  const _CompareList(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('—', style: ttcBody(12.5, color: ttcMuted));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                              color: ttcMuted, shape: BoxShape.circle)),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                        child: Text(s,
                            style: ttcBody(12, color: ttcInk, h: 1.45))),
                  ]),
            ),
        ]);
  }
}

/// ⚠️ TWO BUTTONS BOTH READING "BUY" WOULD BE A COIN TOSS. The bar sits under
/// a table of two columns, and by the time somebody reaches it they have
/// stopped tracking which column was on the left. So each button names its
/// product — the brand where there is one, because that is the shortest thing a
/// person recognises, and the opening words of the name where there is not.
String _buyLabel(TtcProduct p, bool hi) {
  if (p.brand.isNotEmpty) return p.brand;
  final words = p.name(hi).split(' ');
  return words.length <= 2 ? p.name(hi) : words.take(2).join(' ');
}

// Kept for revert: the stacked label-over-value cell the compare BOTTOM SHEET
// used. Superseded by `_CompareValue` inside `_CompareTRow`, where the label is
// stated once for the row instead of repeated in every column — which is the
// difference between a table and two lists printed next to each other.
//
// class _CompareRow extends StatelessWidget {
//   const _CompareRow({required this.label, required this.value});
//   final String label;
//   final String value;
//
//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.only(bottom: 6),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label.toUpperCase(),
//               style: pvManrope(
//                   fontSize: 9.5,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 1,
//                   color: ttcMuted)),
//           const SizedBox(height: 2),
//           Text(value,
//               style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700)),
//         ]),
//       );
// }

// =============================================================================
//  SCREEN 3 — the product page
// =============================================================================

/// Lookup by id. Null is a real answer — an unknown id opens nothing rather
/// than opening the wrong product.
TtcProduct? ttcProductById(String id) =>
    ttcProducts.where((p) => p.id == id).firstOrNull;

void openTtcProductPage(BuildContext context, String id) {
  if (ttcProductById(id) == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'ttc/shop/product/$id'),
    builder: (_) => TtcProductPage(productId: id),
  ));
}

class TtcProductPage extends StatefulWidget {
  const TtcProductPage({super.key, required this.productId});

  final String productId;

  @override
  State<TtcProductPage> createState() => _TtcProductPageState();
}

class _TtcProductPageState extends State<TtcProductPage> {
  final _scroll = ScrollController();
  bool _sticky = false;
  String? _vote;

  @override
  void initState() {
    super.initState();
    // The design's sticky bar "appears on scroll". 320 is roughly the point
    // the in-page price and buttons have left the screen — below that the bar
    // would duplicate controls the reader can already see.
    _scroll.addListener(() {
      final on = _scroll.offset > 320;
      if (on != _sticky) setState(() => _sticky = on);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = ttcProductById(widget.productId);
        if (p == null) return const _GoneProduct();

        final category = ttcProductCategories
                .where((c) => c.$1 == p.category)
                .map((c) => hi ? c.$3 : c.$2)
                .firstOrNull ??
            'Products';

        return Stack(children: [
          TtcToolScaffold(
            hue: kTtcShopHue,
            chroma: kTtcShopChroma,
            variant: 3,
            scrollController: _scroll,
            eyebrow: category,
            title: p.name(hi),
            intro: p.brand.isEmpty ? p.priceEn : '${p.brand} · ${p.size}',
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ⚠️ A SWIPEABLE GALLERY, AND THE APOLOGY IS GONE — 2026-09-04.
                  //
                  // This was a single drawing plus a thumbnail rail carrying
                  // the line "one drawing, not a photograph — we photograph
                  // products ourselves and this one is in the queue". Two
                  // problems with that, and the second is the real one:
                  //
                  //   1. A rail of one thumbnail is not a rail. It read as an
                  //      empty region between the picture and the brand name.
                  //   2. It apologised. A page that opens by explaining what it
                  //      does not have yet has spent its first impression on a
                  //      shortcoming nobody asked about.
                  //
                  // It is a `PageView` with dots now, holding the drawing
                  // today and photographs when they land — and with one item it
                  // simply shows that item, with no dots and nothing to swipe.
                  _ProductGallery(hue: p.hue, photos: p.photos),

                  // 2 ---- brand, then name ----------------------------------
                  const SizedBox(height: 20),
                  if (p.brand.isNotEmpty)
                    Text(p.brand.toUpperCase(),
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: ttcMuted)),
                  const SizedBox(height: 4),
                  Text(p.name(hi),
                      style: ttcFraunces(27,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.15)),

                  // 3 ---- the band ------------------------------------------
                  const SizedBox(height: 12),
                  TtcBandMark(band: p.band),

                  // 4 ---- the verdict ---------------------------------------
                  const SizedBox(height: 8),
                  if (p.verdict.isNotEmpty)
                    Text(p.verdict,
                        style: ttcBody(14, color: ttcTitleInk, h: 1.55)),

                  // 5 ---- the score card ------------------------------------
                  const SizedBox(height: 20),
                  _ScoreCard(
                    product: p,
                    vote: _vote,
                    // ⚠️ IT SAYS SOMETHING BACK. Yes and No used to set a
                    // variable and change a border, which from the outside is
                    // a button that did nothing. A vote nobody acknowledges is
                    // a vote nobody makes twice.
                    onVote: (v) {
                      setState(() => _vote = v);
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(SnackBar(
                          content: Text(
                              v == 'up'
                                  ? 'Good — thank you. That helps us know '
                                      'which pages are worth writing.'
                                  : 'Noted, and thank you for saying so. '
                                      'Pages people mark this way get rewritten '
                                      'before new ones get written.',
                              style: ttcBody(13, color: Colors.white, h: 1.4)),
                        ));
                    },
                  ),

                  // 6 ---- best-for chips ------------------------------------
                  const SizedBox(height: 20),
                  ttcShopEyebrow('Best for'),
                  const SizedBox(height: 12),
                  _BestForChips(chips: p.bestFor),
                  const SizedBox(height: 8),
                  Text(
                      'Ticked chips are the ones this actually applies to — '
                      'the rest are true of the product but may not be true '
                      'of you.',
                      style: ttcBody(13, color: ttcMuted, h: 1.5)),

                  // 7 ---- price, Compare, Buy -------------------------------
                  const SizedBox(height: 20),
                  _PriceRow(product: p, onBuy: () => _openBuy(p)),
                ],
              )),

              // 8 ---- before you buy --------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('Before you buy'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ttcBorder),
                    ),
                    child: Text(p.why(hi),
                        style: ttcBody(14, color: ttcTitleInk, h: 1.6)),
                  ),
                ],
              )),

              // 9 ---- an honest look --------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('An honest look'),
                  const SizedBox(height: 12),
                  if (p.goods.isNotEmpty) ...[
                    _HonestBlock(
                      label: "What's good",
                      tint: const Color(0xFFE4F0EA),
                      ink: const Color(0xFF2E6B4F),
                      lines: p.goods,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _HonestBlock(
                    label: 'Worth considering',
                    tint: const Color(0xFFF2ECDF),
                    ink: const Color(0xFF8A6A1F),
                    lines: p.watchOuts.isEmpty ? [p.watchOut(hi)] : p.watchOuts,
                  ),
                ],
              )),

              // 10 ---- the divider ----------------------------------------
              const SizedBox(height: 40),
              ttcToolPad(const _ExploreDivider()),
              const SizedBox(height: 28),

              // 11 ---- what to look for -----------------------------------
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('What to look for'),
                  const SizedBox(height: 12),
                  TtcCard(
                      child: Text(p.lookFor(hi), style: ttcBody(14, h: 1.6))),
                ],
              )),

              // 12 ---- from people trying ---------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('From people trying'),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(p.rating.toStringAsFixed(1),
                            style: ttcFraunces(22,
                                w: FontWeight.w600, color: ttcTitleInk)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              'average · ${p.voices.length} from people here · '
                              '${_thousands(p.reviews)} on retailer sites',
                              style: ttcBody(13, color: ttcMuted)),
                        ),
                      ]),
                  const SizedBox(height: 12),
                  for (final v in p.voices) ...[
                    _VoiceCard(voice: v),
                    const SizedBox(height: 12),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showTtcAllRatings(context, p),
                    child: Text('See all ${p.voices.length} ratings →',
                        style: ttcBody(12.5,
                            color: kTtcActionInk, w: FontWeight.w800)),
                  ),
                ],
              )),

              // 13 ---- what's inside --------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow("What's inside"),
                  const SizedBox(height: 12),
                  for (final i in p.inside) ...[
                    _InsideCard(item: i),
                    const SizedBox(height: 12),
                  ],
                ],
              )),

              // 14 ---- the research ---------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('The research, in plain language'),
                  const SizedBox(height: 12),
                  for (final st in p.studies) ...[
                    _StudyCard(study: st),
                    const SizedBox(height: 12),
                  ],
                ],
              )),

              // 15 ---- the details ----------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ttcShopEyebrow('The details'),
                  const SizedBox(height: 12),
                  // ⚠️ ONE TABLE, NOT A STACK OF SEPARATE WELLS. Each row used
                  // to be its own tinted block with its own rounded corners,
                  // which is six objects where there is one fact sheet — and
                  // six sets of corners is what made it read as untidy even
                  // after the alignment was fixed.
                  //
                  // One bordered card, hairlines between rows, a fixed label
                  // column. That is what a spec sheet looks like on paper and
                  // there is no reason for it to look like anything else here.
                  _SpecTable(rows: [
                    ('Evidence', p.evidence.label),
                    ('Whose', p.forPartner ? 'His' : 'Hers'),
                    ('Typical range', p.priceEn),
                    ...p.specs,
                  ]),
                ],
              )),

              // 16 ---- read next ------------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(ttcShopEyebrow('Also on this shelf')),
              const SizedBox(height: 12),
              _ReadNextRail(category: p.category, currentId: p.id),

              // 17 ---- Ask Veda -------------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(_AskVedaRow(name: p.name(hi))),

              // 18 ---- the disclaimer -------------------------------------
              const SizedBox(height: 28),
              ttcToolPad(Text(
                  'ParentVeda does not sell this. Prices and brands are '
                  'examples of what an Indian chemist stocks, not '
                  'recommendations of one brand over another. General '
                  'information, not medical advice — if you are unsure whether '
                  'something applies to you, ask your doctor.',
                  textAlign: TextAlign.center,
                  style: ttcBody(11.5, color: ttcMuted, h: 1.6))),
              const SizedBox(height: 40),
            ],
          ),

          // ---- the sticky bar, on scroll --------------------------------
          if (_sticky)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                type: MaterialType.transparency,
                child: _StickyBar(product: p, onBuy: () => _openBuy(p)),
              ),
            ),

          // ⚠️ ABOVE THE STICKY BAR WHEN BOTH ARE UP. Compare floats bottom
          // right; the buy bar takes the full width beneath it, so the pill
          // lifts rather than sitting on top of the price.
          Positioned(
            right: 18,
            bottom: _sticky ? 92 : 22,
            // Same missing-Material problem as the compare bar — see the note
            // on the shelf.
            child: Material(
              type: MaterialType.transparency,
              child: _CompareFab(product: p),
            ),
          ),
        ]);
      },
    );
  }

  void _openBuy(TtcProduct p) => showTtcBuyInterstitial(context, p);

  // ignore: unused_element
  void _compare(TtcProduct p) {
    final tray = TtcCompareTray.instance;
    if (!tray.has(p.id)) tray.toggle(p.id);
    final picked = tray.products;
    if (picked.length < 2) {
      // ⚠️ IT SAYS WHAT HAPPENED. A tick with no visible effect is the same
      // dead button by another route.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to compare. Tick one more on any shelf.',
            style: ttcBody(13, color: Colors.white)),
      ));
      setState(() {});
      return;
    }
    showTtcCompare(context, picked);
  }
}

String _thousands(int n) {
  final s = n.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

/// The design's three 54pt thumbnails. The first is selected.
///
/// ⚠️ THE DESIGN SHOWS THIS RAIL "ONLY WHEN MORE THAN ONE SHOT EXISTS". There
/// is one drawing per product, so the rail is a single square — which is what
/// the rule actually asks for, rather than three identical thumbnails of the
/// same picture.
/// ⚠️ KEPT FOR REVERT, NOT RENDERED. The single-thumbnail rail with the
/// "we photograph products ourselves" line, replaced by `_ProductGallery`.
// ignore: unused_element
class _ThumbRail extends StatelessWidget {
  const _ThumbRail({required this.hue});
  final double hue;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: HSLColor.fromAHSL(1, hue, 0.32, 0.91).toColor(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ttcTitleInk, width: 1.4),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 28,
              child: CustomPaint(painter: _MarkPainter(hue)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
              'One drawing, not a photograph. We photograph products '
              'ourselves and this one is in the queue.',
              style: ttcBody(11.5, color: ttcMuted, h: 1.45)),
        ),
      ]);
}

/// The design's score card, transcribed.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard(
      {required this.product, required this.vote, required this.onVote});

  final TtcProduct product;
  final String? vote;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _factLabel('ParentVeda score'),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${product.pvScore}',
                        style: ttcFraunces(42,
                            w: FontWeight.w600, color: ttcTitleInk, h: 1.05)),
                    const SizedBox(width: 2),
                    Text('/100', style: ttcBody(13, color: ttcMuted)),
                  ]),
            ]),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _factLabel('People would recommend'),
                    Text('${product.parentsPct}%',
                        style: ttcFraunces(16.5,
                            w: FontWeight.w600, color: ttcTitleInk)),
                    const SizedBox(height: 12),
                    _factLabel('Experts say buy'),
                    Text('${product.expertsPct}%',
                        style: ttcFraunces(16.5,
                            w: FontWeight.w600, color: ttcTitleInk)),
                  ]),
            ),
          ]),
          const SizedBox(height: 20),
          ttcDivider(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Text('Was this page useful?',
                  style: ttcBody(13, color: ttcMuted)),
            ),
            _VoteButton(
                label: 'Yes', on: vote == 'up', onTap: () => onVote('up')),
            const SizedBox(width: 8),
            _VoteButton(
                label: 'No', on: vote == 'down', onTap: () => onVote('down')),
          ]),
        ]),
      );

  static Widget _factLabel(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(s.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
      );
}

class _VoteButton extends StatelessWidget {
  const _VoteButton(
      {required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: on ? ttcTitleInk : ttcBorder, width: 1.2),
          ),
          child: Text(label,
              style: ttcBody(12.5,
                  color: on ? ttcTitleInk : ttcMuted, w: FontWeight.w800)),
        ),
      );
}

class _BestForChips extends StatelessWidget {
  const _BestForChips({required this.chips});
  final List<(String, bool)> chips;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in chips)
            Container(
              height: 32,
              constraints: const BoxConstraints(maxWidth: 320),
              padding: EdgeInsets.only(left: c.$2 ? 11 : 14, right: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.$2
                    ? HSLColor.fromAHSL(1, kTtcShopHue, 0.32, 0.91).toColor()
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: c.$2 ? null : Border.all(color: ttcBorder),
              ),
              // ⚠️ THIS IS THE ROW THAT DREW THE YELLOW STRIPES, and it took a
              // probe to find rather than a guess. A `Wrap` moves a chip to the
              // next line when it does not fit — but a SINGLE chip wider than
              // the whole line has nowhere to go, and "Only if a test showed
              // low" with a tick and 28pt of padding is 8.8 points over 354.
              //
              // Only two products carried a label that long, which is why it
              // looked intermittent. `Flexible` inside, a max width outside.
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (c.$2) ...[
                  Icon(Icons.check_rounded, size: 13, color: ttcTitleInk),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(c.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(12.5,
                          color: c.$2 ? ttcTitleInk : ttcSoft,
                          w: FontWeight.w600)),
                ),
              ]),
            ),
        ],
      );
}

/// Price on the left, Compare outlined, Buy filled in ink — never violet.
class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.onBuy});
  final TtcProduct product;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    // ⚠️ IT OVERFLOWED, AND THE STRIPES WERE VISIBLE ON A REAL PHONE.
    //
    // "₹1,499 · 60 tablets" plus a 44pt Compare pill plus a 44pt Buy pill does
    // not fit 354 points, so Flutter drew its yellow-and-black overflow
    // hatching under both ends of the row. Reported exactly that way: "Buy now
    // at the bottom right, it's having yellow lines below it".
    //
    // The row is now two lines rather than one squeezed line. The price keeps
    // its own line and the buttons get a full-width row underneath, which is
    // also the only arrangement where both pills keep the 44pt target the
    // design specifies.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PRICE',
          style: pvManrope(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: ttcMuted)),
      const SizedBox(height: 3),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(product.price,
                style:
                    ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)),
            if (product.size.isNotEmpty)
              Flexible(
                child: Text(' · ${product.size}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(12.5, color: ttcMuted)),
              ),
          ]),
      const SizedBox(height: 14),
      // ⚠️ ONE BUTTON HERE, AND COMPARE MOVED TO A FLOATING PILL. Asked for
      // directly. It is also the better arrangement: two equal pills side by
      // side made Buy and Compare look like alternatives, when one is the
      // commit action and the other is a thing you do to several products over
      // several screens. A floating control is the right shape for something
      // that follows you around; a pill in a row is not.
      SizedBox(
        width: double.infinity,
        child: _FilledPill(label: 'Buy now', onTap: onBuy),
      ),
    ]);
  }
}

class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcBorder, width: 1.2),
          ),
          child: Text(label,
              style:
                  ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700)),
        ),
      );
}

/// ⚠️ THE ONE FILLED PILL IN THE FLOW, AND IT IS `ink1`, NOT VIOLET. The
/// design system's rule, stated twice in the brief: exactly one filled pill per
/// flow, for a genuine commit action, in ink.
class _FilledPill extends StatelessWidget {
  const _FilledPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: ttcTitleInk, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: ttcBody(12.5, color: Colors.white, w: FontWeight.w700)),
        ),
      );
}

class _VoiceCard extends StatelessWidget {
  const _VoiceCard({required this.voice});
  final (String, int, String, String) voice;

  @override
  Widget build(BuildContext context) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(voice.$1,
                style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700)),
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < 5; i++)
                Icon(
                    i < voice.$2
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 13,
                    color: i < voice.$2 ? kTtcStarInk : ttcBorder),
            ]),
          ]),
          const SizedBox(height: 4),
          Text(voice.$3.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 8),
          Text(voice.$4, style: ttcBody(13, color: ttcTitleInk, h: 1.55)),
        ]),
      );
}

String ttcStars(int n) => '${'★' * n}${'☆' * (5 - n)}';

class _InsideCard extends StatelessWidget {
  const _InsideCard({required this.item});
  final (String, String, String, String) item;

  @override
  Widget build(BuildContext context) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(item.$1,
                    style: ttcFraunces(16.5,
                        w: FontWeight.w600, color: ttcTitleInk)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(item.$2,
                      style: ttcBody(11.5, color: ttcMuted)),
                ),
              ]),
          const SizedBox(height: 8),
          Text(item.$3, style: ttcBody(13, h: 1.55)),
          if (item.$4.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(14)),
              child: Text(item.$4,
                  style: ttcBody(13, color: ttcTitleInk, h: 1.5)),
            ),
          ],
        ]),
      );
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({required this.study});
  final (String, String, String, String, bool) study;

  @override
  Widget build(BuildContext context) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ⚠️ A MAKER'S OWN TRIAL IS LABELLED AS ONE. The design's rule, and
          // the honest half of carrying research at all.
          if (study.$5) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(999)),
              child: Text("MAKER'S OWN TRIAL",
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: ttcMuted)),
            ),
            const SizedBox(height: 8),
          ],
          Text(study.$1,
              style: ttcFraunces(16.5,
                  w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
          const SizedBox(height: 8),
          Text(study.$2, style: ttcBody(13, h: 1.55)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.circular(14)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHAT THIS MEANS FOR YOU',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 4),
                  Text(study.$3,
                      style: ttcBody(13, color: ttcTitleInk, h: 1.55)),
                ]),
          ),
          const SizedBox(height: 12),
          Text(study.$4, style: ttcBody(11.5, color: ttcMuted, h: 1.45)),
        ]),
      );
}

/// Three, horizontal. Never an infinite tail.
///
/// ⚠️ "ALSO ON THIS SHELF", NOT "READ NEXT". The design's parenting page calls
/// this rail "Related guides" and it opens guides; ours opens PRODUCTS, and
/// "Read next" over three things to buy is the chip-lies problem in a heading.
/// Three, horizontal. Never an infinite tail.
///
/// ⚠️ "ALSO ON THIS SHELF", NOT "READ NEXT", AND THE SAME CARD AS THE SHELF.
/// It opens products, so calling it "Read next" was a heading that lied — and
/// it drew its own smaller card, so the same product looked like two different
/// things depending on which screen you met it on.
class _ReadNextRail extends StatelessWidget {
  const _ReadNextRail({required this.category, required this.currentId});
  final String category;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final others = ttcProductsIn(category)
        .where((p) => p.id != currentId)
        .take(3)
        .toList();
    if (others.isEmpty) return const SizedBox.shrink();
    final hi = TtcS.current().hinglish;

    return SizedBox(
      height: TtcProductCard.railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: others.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            TtcProductCard(product: others[i], hi: hi, width: 168),
      ),
    );
  }
}

class _AskVedaRow extends StatelessWidget {
  const _AskVedaRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ttcBorder),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Still deciding?', style: ttcJakarta(14.5)),
                  const SizedBox(height: 4),
                  Text('Ask Veda about $name.',
                      style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, size: 20, color: kTtcActionInk),
        ]),
      );
}

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.product, required this.onBuy});
  final TtcProduct product;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: ttcBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⚠️ `Flexible` INSIDE THE `Expanded`, and the brand and
                    // size on one ellipsised line. "Various · 60 tablets" in
                    // 9.5pt caps plus a 44pt pill was over 354 and drew the
                    // same overflow hatching as the row above.
                    Text(
                        '${product.brand.isEmpty ? '' : '${product.brand} · '}'
                                '${product.size}'
                            .toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: ttcMuted)),
                    const SizedBox(height: 2),
                    Text(product.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ttcFraunces(18,
                            w: FontWeight.w600, color: ttcTitleInk)),
                  ]),
            ),
            const SizedBox(width: 10),
            _FilledPill(label: 'Buy now', onTap: onBuy),
          ]),
        ),
      );
}

/// ⚠️ KEPT FOR REVERT, NOT RENDERED. This was the page's hero card while the
/// score was unavailable — a big EVIDENCE word where the design puts `88/100`.
/// The design's own card is now built and the score is seeded, so this is
/// unused; it is left here because "we cannot honestly print a number" may
/// become true again the day somebody asks where the number came from.
// ignore: unused_element
class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.product});
  final TtcProduct product;

  @override
  Widget build(BuildContext context) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EVIDENCE',
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: ttcMuted)),
              const SizedBox(height: 3),
              Text(product.evidence.label,
                  style: ttcFraunces(34,
                      w: FontWeight.w600, color: ttcTitleInk, h: 1.05)),
            ]),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('PRICE',
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: ttcMuted)),
              const SizedBox(height: 4),
              Text(product.priceEn,
                  style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w800)),
            ]),
          ]),
          const SizedBox(height: 12),
          ttcDivider(),
          const SizedBox(height: 12),
          Text(product.evidence.meaning, style: ttcBody(13, h: 1.55)),
        ]),
      );
}

/// The design's "best for" chips.
///
/// ⚠️ THE PARENTING VERSION MATCHES CHIPS AGAINST A CHILD — eczema-prone, 7
/// months, winter in Pune. There is no child here, and the honest equivalent of
/// "something we already know about you" in this stage is whose half it is.
/// Everything else is a plain fact about the product, unticked.
/// ⚠️ KEPT FOR REVERT, NOT RENDERED. The stand-in for the design's "best for"
/// chips while no product carried any — it derived them from the category. The
/// real chips are seeded per product now (`bestFor`), so this is unused.
// ignore: unused_element
class _WhoseChips extends StatelessWidget {
  const _WhoseChips({required this.product, required this.hi});
  final TtcProduct product;
  final bool hi;

  @override
  Widget build(BuildContext context) {
    final chips = <(String, bool)>[
      (product.forPartner ? 'For him' : 'For her', true),
      if (product.evidence == TtcEvidence.strong) ('Well evidenced', true),
      if (product.id == 'myo_inositol') ('PCOS only', true),
      if (product.category == 'supplements') ('Taken daily', false),
      if (product.category == 'kits') ('Used through the cycle', false),
      if (product.category == 'tests') ('One-off', false),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in chips)
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: chip.$2 ? ttcPanel : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: chip.$2 ? null : Border.all(color: ttcBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (chip.$2) ...[
                Icon(Icons.check_rounded, size: 13, color: ttcTitleInk),
                const SizedBox(width: 5),
              ],
              Text(chip.$1,
                  style: ttcBody(12.5,
                      color: chip.$2 ? ttcTitleInk : ttcSoft,
                      w: FontWeight.w600)),
            ]),
          ),
      ],
    );
  }
}

class _HonestBlock extends StatelessWidget {
  const _HonestBlock({
    required this.label,
    required this.tint,
    required this.ink,
    required this.lines,
  });

  final String label;
  final Color tint;
  final Color ink;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration:
            BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ink)),
          const SizedBox(height: 11),
          for (final line in lines) ...[
            Text(line, style: ttcBody(13, color: ttcTitleInk, h: 1.55)),
            if (line != lines.last) const SizedBox(height: 9),
          ],
        ]),
      );
}

/// "Everything below is optional." A hairline with a label set into it.
class _ExploreDivider extends StatelessWidget {
  const _ExploreDivider();

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Container(height: 1, color: ttcBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('EXPLORE MORE, IF YOU WANT TO',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
        ),
        Expanded(child: Container(height: 1, color: ttcBorder)),
      ]);
}

/// The details, as one table.
class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ttcBorder),
        ),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Container(height: 1, color: ttcBorder),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(rows[i].$1,
                          style: ttcBody(12.5, color: ttcMuted, h: 1.4)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(rows[i].$2,
                          style: ttcBody(12.5,
                              color: ttcTitleInk,
                              w: FontWeight.w700,
                              h: 1.4)),
                    ),
                  ]),
            ),
          ],
        ]),
      );
}

/// ⚠️ KEPT FOR REVERT, NOT RENDERED. One row per tinted well, replaced by
/// `_SpecTable`.
// ignore: unused_element
class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(14)),
        // ⚠️ THE LABEL COLUMN IS FIXED, NOT `Expanded` — FIXED 2026-09-04.
        //
        // Both sides were flexible, so each row divided the width by its own
        // content: "Evidence / Strong" put the value near the middle and "When
        // to start / A month before, ideally three" pushed it hard right. Four
        // rows, four different value positions, and the column read as
        // untidy rather than as a table.
        //
        // A fixed label column means every value starts in the same place,
        // which is the entire point of a spec sheet.
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 118,
            child: Text(label, style: ttcBody(13, color: ttcSoft, h: 1.4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: ttcBody(12.5,
                    color: ttcTitleInk, w: FontWeight.w700, h: 1.4)),
          ),
        ]),
      );
}

/// A block that states what it will hold. Never tappable.
/// ⚠️ KEPT FOR REVERT, NOT RENDERED. The honest-empty block that stood where
/// reviews and research now sit. Unused since both are seeded — and worth
/// keeping, because it is the correct thing to render the day somebody strips
/// the seed data out rather than replacing it.
// ignore: unused_element
class _Pending extends StatelessWidget {
  const _Pending({required this.label, required this.body});
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ttcBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 6),
          Text(body, style: ttcBody(13, color: ttcSoft, h: 1.55)),
        ]),
      );
}

class _GoneProduct extends StatelessWidget {
  const _GoneProduct();

  @override
  Widget build(BuildContext context) => TtcToolScaffold(
        hue: kTtcShopHue,
        eyebrow: 'Products',
        title: 'That one is gone.',
        intro: 'It is no longer in the library.',
        children: [
          ttcToolPad(TtcRecordsAction(
            label: 'Back to products',
            onTap: () => Navigator.of(context).maybePop(),
          )),
        ],
      );
}


/// A plain row that opens somewhere. Chevron in `ink3`, never in the accent.
class _RowLink extends StatelessWidget {
  const _RowLink({required this.label, required this.sub, required this.onTap});

  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ttcBorder),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: ttcJakarta(14.5)),
                    const SizedBox(height: 4),
                    Text(sub, style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                  ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
          ]),
        ),
      );
}

// =============================================================================
//  The drawn product, transcribed from the design's own SVG
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE I SHIPPED THE HATCH EVERYWHERE AND IT WAS WRONG.
//
//  The design has TWO photo states and uses both: a drawn bottle in the
//  product's hue for the normal case, and a hatched "No photo yet" block for
//  the genuine no-photograph case. I rendered the hatch in both, which made
//  every card a grey placeholder — reported as *"the one on the phone looks so
//  dull and the one that I gave you looks so bright and vibrant"*, which is
//  exactly what it was.
//
//  The illustration is not decoration and it is not a stand-in for a
//  photograph. It is a drawn mark, the same device the category rows use, and
//  the design ships it as the normal state precisely because a catalogue with
//  no photography still has to look like a catalogue.
//
//  ⚠️ THE GEOMETRY IS THE DESIGN'S, NOT APPROXIMATED. Rect positions, radii and
//  the three lightness steps (78% cap / 86% body / white label) are transcribed
//  from `PVProduct.dc.html` and `PVShelf.dc.html`. The shelf's mark is a
//  different, simpler drawing at a different lightness (62% cap / 78% body) —
//  two drawings, because a 52pt mark and a 150pt one are not the same picture
//  scaled.
// =============================================================================

/// The bottle, at hero size. Transcribed from `PVProduct.dc.html`.
class TtcProductArt extends StatelessWidget {
  const TtcProductArt({super.key, required this.hue, this.height = 230});

  final double hue;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ttcBorder),
        ),
        // ⚠️ THE PAINTER FILLS AND CENTRES ITSELF NOW. It used to sit in a
        // fixed 150×196 box inside a `Center`, which looked right at hero size
        // and clipped at every other size.
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomPaint(
              size: Size.infinite, painter: _BottlePainter(hue)),
        ),
      );
}

class _BottlePainter extends CustomPainter {
  const _BottlePainter(this.hue);
  final double hue;

  Color _at(double sat, double light) =>
      HSLColor.fromAHSL(1, hue, sat, light).toColor();

  /// The drawing's own coordinate space, from the design's `viewBox`.
  static const Size _art = Size(150, 196);

  @override
  void paint(Canvas canvas, Size size) {
    // ⚠️ SCALED TO THE BOX, NOT DRAWN AT FIXED COORDINATES — FIXED 2026-09-04.
    //
    // Both painters transcribed the design's SVG rect coordinates literally,
    // which is correct for an SVG (it has a viewBox and scales itself) and
    // wrong for a `CustomPainter` (it does not). Put in a 40pt thumbnail, a
    // drawing laid out at 150×196 spilled straight out of the card.
    //
    // Reported as "the SVG art is coming out of the situation", and it was
    // visible in three places at once: the thumbnail rail, the read-next cards
    // and the shelf marks.
    final k = (size.width / _art.width).clamp(0.0, size.height / _art.height);
    canvas.translate((size.width - _art.width * k) / 2,
        (size.height - _art.height * k) / 2);
    canvas.scale(k);

    void rect(double x, double y, double w, double h, double r, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
        Paint()..color = c,
      );
    }

    // cap · body · label · two label lines — the design's five rects.
    rect(52, 4, 46, 24, 7, _at(0.32, 0.78));
    rect(30, 26, 90, 166, 22, _at(0.32, 0.86));
    rect(44, 74, 62, 58, 10, Colors.white);
    rect(52, 88, 46, 6, 3, _at(0.24, 0.82));
    rect(52, 102, 30, 6, 3, _at(0.24, 0.88));
  }

  @override
  bool shouldRepaint(covariant _BottlePainter old) => old.hue != hue;
}

/// The same object at card size, in its own tinted well.
/// Transcribed from `PVShelf.dc.html`.
class TtcProductMark extends StatelessWidget {
  const TtcProductMark({super.key, required this.hue, this.height = 104});

  final double hue;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          // The well is the hue at 91% lightness — the card's own colour, and
          // the reason a grid of these looks like a shelf rather than a form.
          color: HSLColor.fromAHSL(1, hue, 0.32, 0.91).toColor(),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child:
              CustomPaint(size: Size.infinite, painter: _MarkPainter(hue)),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.hue);
  final double hue;

  Color _at(double sat, double light) =>
      HSLColor.fromAHSL(1, hue, sat, light).toColor();

  /// The design's `viewBox` for the small mark.
  static const Size _art = Size(52, 72);

  @override
  void paint(Canvas canvas, Size size) {
    // Same scaling as `_BottlePainter` — see the note there.
    final k = (size.width / _art.width).clamp(0.0, size.height / _art.height);
    canvas.translate((size.width - _art.width * k) / 2,
        (size.height - _art.height * k) / 2);
    canvas.scale(k);

    void rect(double x, double y, double w, double h, double r, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
        Paint()..color = c,
      );
    }

    rect(18, 0, 16, 10, 3, _at(0.34, 0.62));
    rect(8, 9, 36, 63, 10, _at(0.32, 0.78));
    rect(15, 28, 22, 20, 4, Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.hue != hue;
}

// =============================================================================
//  The section eyebrow, and the two overlays
// =============================================================================

/// ⚠️ THE SIGNATURE OF THE WHOLE DESIGN SYSTEM, AND IT MUST NEVER BE GREY.
/// Manrope 11 / 800, +1.4 tracking, in `action` violet — spent on eyebrows and
/// links and nowhere else. Never a fill, never a chevron, never a background.
Widget ttcShopEyebrow(String s) => Text(s.toUpperCase(),
    style: pvManrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: kTtcActionInk));

/// The affiliate interstitial.
///
/// ⚠️ THE THIRD SENTENCE IS THE WHOLE REASON THIS PAGE MAY CARRY A BUY BUTTON.
/// The design brief says so in as many words: *"that last sentence is the whole
/// reason a trust-first page is allowed to carry a Buy button at all."*
///
/// So it says three things, in this order: you are leaving, we may earn a
/// commission at no extra cost to you, and **it never changes what we
/// recommend, how we rate a product, or the order of this shelf.** Removing the
/// third one turns this sheet from a disclosure into a formality.
///
/// ⚠️ AND IT IS NOT AN AFFILIATE LINK YET. There is no affiliate relationship
/// in this stage; the URLs are plain retailer searches and ParentVeda earns
/// nothing from them. The sheet says that rather than claiming a commission we
/// do not take — see the copy below, and `docs/STILL-OPEN.md` §24.3 for what
/// changes on the day it becomes one.
Future<void> showTtcBuyInterstitial(BuildContext context, TtcProduct p) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuySheet(product: p),
    );

class _BuySheet extends StatelessWidget {
  const _BuySheet({required this.product});
  final TtcProduct product;

  @override
  Widget build(BuildContext context) {
    final hi = TtcS.current().hinglish;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ttcShopEyebrow('Before you go'),
                const SizedBox(height: 12),
                Text('You are leaving for ${product.retailer}',
                    style: ttcFraunces(22,
                        w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                const SizedBox(height: 12),
                Text(
                    'This opens a search on ${product.retailer}. ParentVeda '
                    'earns nothing from it — there is no affiliate '
                    'arrangement in this stage.',
                    style: ttcBody(13, color: ttcSoft, h: 1.55)),
                const SizedBox(height: 8),
                Text(
                    'If that ever changes, we will say so here. It would '
                    'still never change what we recommend, how we rate a '
                    'product, or the order of a shelf.',
                    style: ttcBody(13, color: ttcTitleInk, h: 1.55)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                          '${product.name(hi)}'
                          '${product.size.isEmpty ? '' : ', ${product.size}'}',
                          style: ttcBody(13, color: ttcSoft, h: 1.4)),
                    ),
                    const SizedBox(width: 10),
                    Text(product.priceEn,
                        style: ttcBody(12.5,
                            color: ttcTitleInk, w: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _FilledPill(
                    label: 'Continue to ${product.retailer}',
                    onTap: () => _open(context, product.retailerUrl),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _OutlinedPill(
                    label: 'Stay on this page',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  /// ⚠️ FIRE-AND-FORGET, AND IT CLOSES THE SHEET FIRST. If the launch fails —
  /// no browser, no network — she is left on the product page rather than on a
  /// sheet with a dead button, which is the failure the rest of this stage
  /// handles the same way.
  Future<void> _open(BuildContext context, String url) async {
    Navigator.of(context).maybePop();
    if (url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nothing to recover: the sheet is already closed.
    }
  }
}

/// Every rating, with the distribution and the design's filters.
Future<void> showTtcAllRatings(BuildContext context, TtcProduct p) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingsSheet(product: p),
    );

class _RatingsSheet extends StatefulWidget {
  const _RatingsSheet({required this.product});
  final TtcProduct product;

  @override
  State<_RatingsSheet> createState() => _RatingsSheetState();
}

class _RatingsSheetState extends State<_RatingsSheet> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final all = widget.product.voices;
    final shown = switch (_filter) {
      'Praise' => all.where((v) => v.$2 >= 4).toList(),
      'Concerns' => all.where((v) => v.$2 <= 3).toList(),
      '5 star' => all.where((v) => v.$2 == 5).toList(),
      '4 star' => all.where((v) => v.$2 == 4).toList(),
      '3 star' => all.where((v) => v.$2 == 3).toList(),
      _ => all,
    };

    // The distribution, counted from the voices themselves rather than stored
    // — one source, and it can never disagree with the list below it.
    final counts = <int, int>{for (var s = 1; s <= 5; s++) s: 0};
    for (final v in all) {
      counts[v.$2] = (counts[v.$2] ?? 0) + 1;
    }
    final max = counts.values.fold<int>(0, (a, b) => a > b ? a : b);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcBorder,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ALL RATINGS',
                            style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: ttcMuted)),
                        Row(crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(widget.product.rating.toStringAsFixed(1),
                                  style: ttcFraunces(27,
                                      w: FontWeight.w600,
                                      color: ttcTitleInk)),
                              const SizedBox(width: 5),
                              Icon(Icons.star_rounded,
                                  size: 19, color: kTtcStarInk),
                            ]),
                      ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        '${all.length} from people trying, here',
                        style: ttcBody(13, color: ttcMuted, h: 1.4)),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ttcBorder),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 17, color: ttcMuted),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                for (var star = 5; star >= 1; star--) ...[
                  Row(children: [
                    SizedBox(
                      width: 26,
                      child: Text('$star★',
                          style: ttcBody(11.5, color: ttcMuted)),
                    ),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                            color: ttcPanel,
                            borderRadius: BorderRadius.circular(999)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              max == 0 ? 0 : (counts[star] ?? 0) / max,
                          child: Container(
                            decoration: BoxDecoration(
                                color: ttcMuted,
                                borderRadius: BorderRadius.circular(999)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 22,
                      child: Text('${counts[star]}',
                          textAlign: TextAlign.right,
                          style: ttcBody(11.5, color: ttcMuted)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final f in const [
                      'All',
                      'Praise',
                      'Concerns',
                      '5 star',
                      '4 star',
                      '3 star',
                    ]) ...[
                      _FilterChip(
                        label: f,
                        on: _filter == f,
                        onTap: () => setState(() => _filter = f),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ]),
                ),
              ]),
        ),
        Expanded(
          child: Container(
            color: ttcBg,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                if (shown.isEmpty)
                  Text('Nothing under "$_filter".',
                      style: ttcBody(13, color: ttcMuted))
                else
                  for (final v in shown) ...[
                    _VoiceCard(voice: v),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
//  Search, and the compare entry
// =============================================================================

/// ⚠️ NAME, BRAND AND CATEGORY AT ONCE. Somebody typing "folic" and somebody
/// typing "Folvite" are asking the same question, and a search that matched
/// only the product name would answer one of them. Category is in there because
/// "supplements" is a perfectly reasonable thing to type into a search box.
List<TtcProduct> ttcSearchProducts(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return ttcProducts.where((p) {
    final hay = [
      p.nameEn,
      p.nameHi,
      p.brand,
      p.category,
      p.verdict,
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }).toList()
    ..sort((a, b) => a.band.rank.compareTo(b.band.rank));
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ttcBorder, width: 1.2),
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 18, color: ttcMuted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: ttcBody(13.5, color: ttcTitleInk),
              // ⚠️ `border: InputBorder.none` WAS NOT ENOUGH, AND THAT IS WHY
              // IT STAYED PURPLE.
              //
              // The app's global `InputDecorationTheme` sets `filled: true`
              // with `scheme.surfaceContainer` and its own focused border. A
              // `TextField` inherits all of that, and `border:` only replaces
              // the FALLBACK — `enabledBorder` and `focusedBorder` still come
              // from the theme, which is where the purple ring came from, and
              // `filled` was never touched, which is where the lilac panel
              // inside a white bar came from.
              //
              // So every one of them is turned off explicitly. The white comes
              // from the container around it and nothing paints over it.
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search folic acid, strips, a brand',
                hintStyle: ttcBody(13.5, color: ttcMuted),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded, size: 17, color: ttcMuted),
              ),
            ),
        ]),
      );
}

/// The design's compare row: a row, not a hero card.
class _CompareEntry extends StatelessWidget {
  const _CompareEntry();

  @override
  Widget build(BuildContext context) {
    final tray = TtcCompareTray.instance;
    final picked = tray.products;
    final hi = TtcS.current().hinglish;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // ⚠️ IT OPENS AT ANY COUNT NOW. This was `picked.length < 2 ? null :`
      // — a row that looked tappable and was not, which is exactly the
      // *"compare button is not working"* report. It was defensible while
      // compare was a sheet that could only render a pair; the screen has a
      // nothing-picked state and a one-picked state that offers the second
      // product, so there is no count at which opening it is useless.
      onTap: () => showTtcCompare(context, picked),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ttcBorder),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compare two you are torn between',
                      style: ttcJakarta(14.5)),
                  const SizedBox(height: 4),
                  // ⚠️ IT STATES THE MECHANISM WHEN THE TRAY IS EMPTY. "Nothing
                  // saved yet" alone leaves her to work out how anything gets
                  // saved; the design's own copy names the tick, and so does
                  // this.
                  Text(
                      picked.isEmpty
                          ? 'Nothing picked yet — tick two on any shelf.'
                          : picked.length == 1
                              ? '${picked.first.name(hi)}. Tick one more.'
                              : picked.map((p) => p.name(hi)).join('  ·  '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded,
              size: 20, color: picked.length < 2 ? ttcBorder : ttcMuted),
        ]),
      ),
    );
  }
}

// =============================================================================
//  The filter sheet, the sort sheet, and their controls
// -----------------------------------------------------------------------------
//  ⚠️ THE DESIGN'S ARRANGEMENT, NOT A ROW OF CHIPS. A "Filters" button with a
//  count badge, a sort control beside it, a full sheet behind it, and the
//  active filters as removable chips underneath.
//
//  I shipped chips, then "fixed" it by adding two more chips. The design has a
//  button and a sheet, and the difference is not taste: a chip row shows every
//  filter at once, can only ever hold ONE dimension — you cannot say "strong
//  evidence AND for him" — and eats a line of the shelf permanently. A button
//  plus a sheet is the convention every reader already knows, holds as many
//  dimensions as the data has, and gives the shelf its line back.
// =============================================================================

enum TtcShelfSort { recommended, priceLow, priceHigh, evidence }

/// ⚠️ PRICE SORTS PARSE THE NUMBER OUT OF "₹1,299". The shelf's `price` is a
/// display string on purpose — currency symbol and thousands separators, the
/// way she will see it on a box. Sorting needs a number, and deriving it here
/// keeps that display string as the single source rather than adding a second,
/// silently-diverging numeric field.
double _priceValue(TtcProduct p) =>
    double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

List<TtcProduct> ttcSortShelf(List<TtcProduct> items, TtcShelfSort sort) {
  final out = [...items];
  switch (sort) {
    case TtcShelfSort.recommended:
      out.sort((a, b) => a.band.rank.compareTo(b.band.rank));
    case TtcShelfSort.priceLow:
      out.sort((a, b) => _priceValue(a).compareTo(_priceValue(b)));
    case TtcShelfSort.priceHigh:
      out.sort((a, b) => _priceValue(b).compareTo(_priceValue(a)));
    case TtcShelfSort.evidence:
      out.sort((a, b) => a.evidence.index.compareTo(b.evidence.index));
  }
  return out;
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcBorder, width: 1.2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tune_rounded, size: 16, color: ttcTitleInk),
            const SizedBox(width: 8),
            Text('Filters',
                style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w700)),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: ttcTitleInk,
                    borderRadius: BorderRadius.circular(999)),
                child: Text('$count',
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ],
          ]),
        ),
      );
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcBorder, width: 1.2),
          ),
          child: Row(children: [
            Expanded(
              child: Text('Sort: $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w600)),
            ),
            Icon(Icons.expand_more_rounded, size: 17, color: ttcMuted),
          ]),
        ),
      );
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onRemove,
        child: Container(
          height: 32,
          padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(Icons.close_rounded, size: 14, color: ttcMuted),
          ]),
        ),
      );
}

/// What the sheet hands back.
class TtcShelfFilters {
  const TtcShelfFilters(this.bands, this.evidence, this.whose);
  final Set<TtcRecoBand> bands;
  final Set<TtcEvidence> evidence;
  final bool? whose;
}

Future<TtcShelfFilters?> showTtcShelfFilters(
  BuildContext context,
  Set<TtcRecoBand> bands,
  Set<TtcEvidence> evidence,
  bool? whose,
) =>
    showModalBottomSheet<TtcShelfFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _FilterSheet(bands: {...bands}, evidence: {...evidence}, whose: whose),
    );

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.bands,
    required this.evidence,
    required this.whose,
  });

  final Set<TtcRecoBand> bands;
  final Set<TtcEvidence> evidence;
  final bool? whose;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<TtcRecoBand> _bands = widget.bands;
  late Set<TtcEvidence> _evidence = widget.evidence;
  late bool? _whose = widget.whose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcBorder,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: Text('Filters',
                        style: ttcFraunces(22,
                            w: FontWeight.w600, color: ttcTitleInk)),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ttcBorder)),
                      child:
                          Icon(Icons.close_rounded, size: 17, color: ttcMuted),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                ttcShopEyebrow('How strongly we recommend it'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final b in TtcRecoBand.values)
                    _SheetChip(
                      label: b.label,
                      on: _bands.contains(b),
                      onTap: () => setState(() => _bands.contains(b)
                          ? _bands.remove(b)
                          : _bands.add(b)),
                    ),
                ]),
                const SizedBox(height: 20),
                ttcShopEyebrow('Strength of the evidence'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in TtcEvidence.values)
                    _SheetChip(
                      label: e.label,
                      on: _evidence.contains(e),
                      onTap: () => setState(() => _evidence.contains(e)
                          ? _evidence.remove(e)
                          : _evidence.add(e)),
                    ),
                ]),
                const SizedBox(height: 20),
                ttcShopEyebrow('Whose it is'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final w in const [
                    (null, 'Everyone'),
                    (false, 'For her'),
                    (true, 'For him'),
                  ])
                    _SheetChip(
                      label: w.$2,
                      on: _whose == w.$1,
                      onTap: () => setState(() => _whose = w.$1),
                    ),
                ]),
                const SizedBox(height: 24),
                Row(children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _bands = {};
                      _evidence = {};
                      _whose = null;
                    }),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ttcBorder, width: 1.2),
                      ),
                      child: Text('Clear all',
                          style: ttcBody(12.5,
                              color: ttcSoft, w: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context)
                          .pop(TtcShelfFilters(_bands, _evidence, _whose)),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: ttcTitleInk,
                            borderRadius: BorderRadius.circular(999)),
                        child: Text('Show them',
                            style: ttcBody(12.5,
                                color: Colors.white, w: FontWeight.w800)),
                      ),
                    ),
                  ),
                ]),
              ]),
        ),
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip(
      {required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? ttcPanel : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: on ? ttcTitleInk : ttcBorder, width: 1.2),
          ),
          child: Text(label,
              style: ttcBody(12.5,
                  color: on ? ttcTitleInk : ttcSoft,
                  w: on ? FontWeight.w800 : FontWeight.w600)),
        ),
      );
}

Future<TtcShelfSort?> showTtcShelfSort(
        BuildContext context, TtcShelfSort current) =>
    showModalBottomSheet<TtcShelfSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcBorder,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ttcShopEyebrow('Order the shelf by'),
                ),
                const SizedBox(height: 8),
                for (final o in const [
                  (TtcShelfSort.recommended, 'How strongly we recommend it'),
                  (TtcShelfSort.evidence, 'Strength of evidence'),
                  (TtcShelfSort.priceLow, 'Price, low to high'),
                  (TtcShelfSort.priceHigh, 'Price, high to low'),
                ])
                  ListTile(
                    title: Text(o.$2,
                        style: ttcBody(14,
                            color: ttcTitleInk,
                            w: o.$1 == current
                                ? FontWeight.w800
                                : FontWeight.w600)),
                    trailing: o.$1 == current
                        ? Icon(Icons.check_rounded,
                            size: 19, color: ttcTitleInk)
                        : null,
                    onTap: () => Navigator.of(context).pop(o.$1),
                  ),
                const SizedBox(height: 12),
              ]),
        ),
      ),
    );

// =============================================================================
//  The product gallery, and the floating compare pill
// =============================================================================

/// A swipeable gallery. Today it holds one drawing; tomorrow, photographs.
///
/// ⚠️ IT DOES NOT APOLOGISE FOR HAVING ONE IMAGE. The thumbnail rail this
/// replaces carried the line "one drawing, not a photograph — we photograph
/// products ourselves and this one is in the queue". True, and it spent the
/// page's first impression on a shortcoming nobody had asked about.
///
/// ⚠️ AND WITH ONE ITEM IT IS NOT A CAROUSEL. No dots, no swipe hint, no
/// stray affordance for a gesture that does nothing — a page indicator showing
/// a single dot is furniture that says "there is more" when there is not.
class _ProductGallery extends StatefulWidget {
  const _ProductGallery({required this.hue, required this.photos});

  final double hue;

  /// Photograph URLs, when they exist. Empty means the drawing alone — which
  /// is every product today, and none of them once photographs land.
  final List<String> photos;

  @override
  State<_ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<_ProductGallery> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The drawing is always the first frame — it is the one thing that exists
    // for every product, and a gallery whose first frame can fail to load is a
    // page that sometimes opens broken.
    final pages = <Widget>[
      TtcProductArt(hue: widget.hue),
      for (final url in widget.photos)
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(url,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => TtcProductArt(hue: widget.hue)),
        ),
    ];

    return Column(children: [
      SizedBox(
        height: 230,
        child: PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _page = i),
          children: pages,
        ),
      ),
      if (pages.length > 1) ...[
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < pages.length; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: i == _page ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _page ? ttcTitleInk : ttcBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (i < pages.length - 1) const SizedBox(width: 6),
          ],
        ]),
      ],
    ]);
  }
}

/// Compare, as a floating pill.
///
/// ⚠️ IT FOLLOWS HER, WHICH IS WHY IT FLOATS. Comparing happens across several
/// products and several screens — tick one here, open another there — so the
/// control belongs somewhere persistent rather than in a row of two buttons
/// where it looked like an alternative to Buy.
///
/// ⚠️ AND IT SHOWS THE COUNT. "Compare" alone gives no clue whether the tap
/// registered; "Compare · 1" and then "Compare · 2" is the whole feedback loop,
/// and at two it opens the comparison rather than waiting to be asked again.
class _CompareFab extends StatelessWidget {
  const _CompareFab({required this.product});
  final TtcProduct product;

  @override
  Widget build(BuildContext context) {
    final tray = TtcCompareTray.instance;
    final n = tray.ids.length;
    final on = tray.has(product.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!on) tray.toggle(product.id);
        // Ticking the first product used to do nothing visible beyond the
        // pill's own count. It now opens the comparison, which at one product
        // is a page saying "pick one more" and listing what is on this shelf —
        // a far better answer than silence.
        showTtcCompare(context, tray.products);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ttcTitleInk, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD0C8DC).withValues(alpha: 0.7),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(on ? Icons.check_rounded : Icons.compare_arrows_rounded,
              size: 17, color: ttcTitleInk),
          const SizedBox(width: 8),
          Text(
              n == 0
                  ? 'Compare'
                  : n == 1
                      ? (on ? 'Pick one more' : 'Compare · 1')
                      : 'Compare · 2',
              style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800)),
        ]),
      ),
    );
  }
}
