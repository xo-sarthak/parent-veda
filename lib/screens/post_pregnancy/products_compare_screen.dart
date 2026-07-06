// =============================================================================
//  ProductsCompareScreen — Products · compare (parenting · S3·compare v2 premium)
// -----------------------------------------------------------------------------
//  Compare as a first-class tool, fully DYNAMIC and fully DIFFERENTIATED: it
//  reads the two products picked in the Products flow (PpCompareStore) — or a
//  sensible default pair when opened cold from the Tools hub — and renders every
//  section per-product. Ratings sit up top in each overview; the spec sheet is
//  built from each product's own specs; and "The ParentVeda take" is one card
//  PER product with that product's own what's-right / worth-knowing. No generic
//  shared copy anywhere. Reached from the Products flow and the Tools hub.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_products_data.dart';

class ProductsCompareScreen extends StatelessWidget {
  const ProductsCompareScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _amberBg = Color(0xFFFFF6EE);
  static const Color _greenBg = Color(0xFFEAF4EE);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening the store soon'), behavior: SnackBarBehavior.floating),
      );

  // The pair to compare: the live selection when two are picked, else a default.
  List<PpProduct> _pair() {
    final sel = PpCompareStore.instance.selected;
    if (sel.length == 2) return sel;
    return [productById('dozy'), productById('lull')];
  }

  String _summaryOf(PpProduct p) => p.summary.isNotEmpty ? p.summary : '${p.brand} · ${p.sub}';

  // Each product's spec sheet — its own `specs`, else derived from its fields —
  // with the rating appended as its own row (like Warranty), up front in the table.
  Map<String, String> _specsOf(PpProduct p) {
    final m = <String, String>{};
    if (p.specs.isNotEmpty) {
      m.addAll(p.specs);
    } else {
      if (p.sound != null) m['Sound'] = p.sound!;
      if (p.autoOff != null) m['Auto-off timer'] = p.autoOff! ? 'Yes' : 'No';
      if (p.volumeLock != null) m['Volume lock'] = p.volumeLock! ? 'Yes' : 'No';
      if (p.power != null) m['Power'] = p.power!;
      m['Price'] = p.priceLabel;
      m['Sold via'] = p.retailer;
    }
    m['Rating'] = '★ ${p.rating.toStringAsFixed(1)} · ${p.reviews} reviews';
    return m;
  }

  List<String> _prosOf(PpProduct p) {
    if (p.pros.isNotEmpty) return p.pros;
    final l = <String>[];
    if (p.rating >= 4.6) l.add('Highly rated — ${p.ratingLabel} from ${p.reviews} reviews');
    if (p.parentVeda) l.add('Made by ParentVeda');
    if (p.verified) l.add('ParentVeda-verified purchase reviews');
    if (p.bestseller) l.add('A bestseller in its category');
    if (l.isEmpty) l.add('${p.ratingLabel} from ${p.reviews} reviews');
    return l;
  }

  List<String> _consOf(PpProduct p) {
    if (p.cons.isNotEmpty) return p.cons;
    final l = <String>[];
    if (p.price >= 2000) l.add('A premium price point');
    if (p.reviews < 60) l.add('Fewer reviews so far — newer to the shelf');
    if (!p.verified && !p.parentVeda) l.add('Not yet ParentVeda-verified');
    if (l.isEmpty) l.add('Nothing major flagged by parents yet');
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final pair = _pair();
    final a = pair[0], b = pair[1];
    final usingDefault = PpCompareStore.instance.selected.length != 2;

    final sa = _specsOf(a), sb = _specsOf(b);
    final specKeys = <String>[...sa.keys, for (final k in sb.keys) if (!sa.containsKey(k)) k];

    final titleA = a.brand == b.brand ? a.name : a.brand;
    final titleB = a.brand == b.brand ? b.name : b.brand;
    final eyebrow = a.sub == b.sub ? 'Compare · ${a.sub}' : 'Compare · ${a.category}';

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 108),
            children: [
              _pad(Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(child: ppEyebrow(eyebrow, color: ppMuted, spacing: 1.2)),
              ])),

              const SizedBox(height: 20),
              _pad(Text.rich(TextSpan(children: [
                TextSpan(text: '$titleA '),
                TextSpan(text: 'vs $titleB.', style: ppFraunces(31, color: ppPurple, h: 1.12).copyWith(fontStyle: FontStyle.italic)),
              ]), style: ppFraunces(31, h: 1.12))),
              if (usingDefault) ...[
                const SizedBox(height: 10),
                _pad(Text('A sample pair — tick two products in Products to compare your own.',
                    style: ppBody(12, color: ppMuted, h: 1.5))),
              ],

              // overview cards — rating sits up top in each
              const SizedBox(height: 22),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _overview(a)),
                const SizedBox(width: 12),
                Expanded(child: _overview(b)),
              ])),

              // spec sheet (per-product columns)
              const SizedBox(height: 22),
              _pad(Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  for (var i = 0; i < specKeys.length; i++)
                    _specRow(specKeys[i], sa[specKeys[i]] ?? '—', sb[specKeys[i]] ?? '—', last: i == specKeys.length - 1),
                ]),
              )),

              // the take — one card PER product
              const SizedBox(height: 28),
              _pad(Text('The ParentVeda take', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('For each pick, honestly — what works, and what to know.', style: ppBody(12))),
              const SizedBox(height: 14),
              _pad(_takeCard(a)),
              const SizedBox(height: 12),
              _pad(_takeCard(b)),

              // community — segregated from the comparison (generalized, but kept)
              _pad(ppSectionDivider()),
              _pad(Text('What parents say', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('Named, verified-mother reviews — the same trust system as every Product page.', style: ppBody(12))),
              const SizedBox(height: 14),
              _pad(Row(children: [
                Expanded(child: _communityStat(a)),
                const SizedBox(width: 12),
                Expanded(child: _communityStat(b)),
              ])),
              const SizedBox(height: 14),
              _pad(_lovedNoted(a, b)),

              const SizedBox(height: 22),
              _pad(Text("ParentVeda's take is evidence-based, neutral and never promotional.",
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // sticky dual buy (dynamic)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.26]),
              ),
              child: Row(children: [
                Expanded(child: _buyBtn(context, 'Buy ${a.brand} · ${a.priceLabel}', primary: true)),
                const SizedBox(width: 12),
                Expanded(child: _buyBtn(context, 'Buy ${b.brand} · ${b.priceLabel}', primary: false)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ---- overview (rating prominent, up top) -------------------------------
  Widget _overview(PpProduct p) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PpStriped(height: 80, radius: 12),
          const SizedBox(height: 10),
          Text(p.brand, style: ppBody(11, color: ppMuted)),
          const SizedBox(height: 2),
          Text(p.name, style: ppJakarta(14).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          // rating first — it matters most
          Row(children: [
            const Icon(Icons.star_rounded, size: 15, color: ppCoral),
            const SizedBox(width: 3),
            Text(p.rating.toStringAsFixed(1), style: ppBody(14, color: ppInk, w: FontWeight.w800)),
            const SizedBox(width: 5),
            Flexible(child: Text('${p.reviews} reviews', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text(p.priceLabel, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_summaryOf(p), style: ppBody(12, h: 1.45)),
        ]),
      );

  // ---- spec sheet --------------------------------------------------------
  Widget _specRow(String label, String a, String b, {bool last = false}) {
    final free = label.toLowerCase().startsWith('free');
    final rating = label == 'Rating';
    Widget val(String t) => Text(t,
        style: ppBody(13, color: rating ? ppCoral : (free ? _green : ppInk), w: (rating || free) ? FontWeight.w700 : FontWeight.w400, h: 1.4));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : const Color(0xFFF3EEF7)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(label, color: ppMuted, spacing: 0.6),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: val(a)),
          const SizedBox(width: 12),
          Expanded(child: val(b)),
        ]),
      ]),
    );
  }

  // ---- per-product take --------------------------------------------------
  Widget _takeCard(PpProduct p) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: ppJakarta(15).copyWith(height: 1.2)),
          const SizedBox(height: 14),
          _takeBlock("What's right", _green, _greenBg, Icons.check_rounded, _prosOf(p)),
          const SizedBox(height: 10),
          _takeBlock('Worth knowing', ppBrown, _amberBg, Icons.info_outline, _consOf(p)),
        ]),
      );

  Widget _takeBlock(String title, Color fg, Color bg, IconData icon, List<String> items) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: ppBody(10, color: fg, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 9),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 9),
                Expanded(child: Text(items[i], style: ppBody(13, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );

  // ---- community (segregated section) ------------------------------------
  Widget _communityStat(PpProduct p) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Column(children: [
          Text(p.brand, style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star_rounded, size: 16, color: ppCoral),
            const SizedBox(width: 3),
            Text(p.rating.toStringAsFixed(1), style: ppJakarta(20)),
          ]),
          const SizedBox(height: 2),
          Text('${p.reviews} parents', style: ppBody(11, color: ppMuted)),
        ]),
      );

  Widget _lovedNoted(PpProduct a, PpProduct b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PARENTS LOVED', style: ppBody(10, color: _green, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 9),
          _cLine(Icons.check_rounded, _green, a.brand, _prosOf(a).first),
          _cLine(Icons.check_rounded, _green, b.brand, _prosOf(b).first),
          const SizedBox(height: 14),
          Text('PARENTS ALSO NOTED', style: ppBody(10, color: ppBrown, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 9),
          _cLine(Icons.info_outline, ppBrown, a.brand, _consOf(a).first),
          _cLine(Icons.info_outline, ppBrown, b.brand, _consOf(b).first),
        ]),
      );

  Widget _cLine(IconData icon, Color color, String brand, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$brand — ', style: ppBody(13, color: ppInk, w: FontWeight.w700, h: 1.5)),
              TextSpan(text: text, style: ppBody(13, color: ppInk, h: 1.5)),
            ])),
          ),
        ]),
      );

  Widget _buyBtn(BuildContext context, String label, {required bool primary}) => GestureDetector(
        onTap: () => _soon(context),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: primary ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: primary ? null : Border.all(color: ppLine),
          ),
          child: Text(label, style: ppBody(14, color: primary ? Colors.white : ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}
