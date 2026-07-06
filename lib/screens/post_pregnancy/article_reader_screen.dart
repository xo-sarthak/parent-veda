// =============================================================================
//  ArticleReaderScreen — Article · reader (parenting · S20)
// -----------------------------------------------------------------------------
//  The reading view: cover, taxonomy tags, byline (reviewed), the article body,
//  an author card, "keep reading" links, and a related-product cross-link.
//  Opens from any "Read" link, AskVeda, or a related rail. Faithful build of
//  Claude Design "post pregnancy - content.dc.html" · S20. The sleep-cycles
//  article carries the full designed body; others show a lighter placeholder.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_articles_data.dart';
import 'pp_common.dart';

class ArticleReaderScreen extends StatelessWidget {
  const ArticleReaderScreen({super.key, this.article});
  final Article? article;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  Widget _div() => _pad(const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      ));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _open(BuildContext context, Article a) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ArticleReaderScreen(article: a)));

  @override
  Widget build(BuildContext context) {
    final a = article ?? kArticles.firstWhere((e) => e.id == 'sleepcycles');
    final related = kArticles.where((x) => x.category == a.category && x.id != a.id).take(2).toList();

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // cover
            SizedBox(
              height: 230,
              child: Stack(children: [
                const PpStriped(height: 230),
                Positioned(
                  top: 14,
                  left: 20,
                  right: 20,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _circleBtn(Icons.arrow_back, () => Navigator.of(context).maybePop()),
                    Row(children: [
                      _circleBtn(Icons.ios_share_rounded, () => _soon(context)),
                      const SizedBox(width: 8),
                      _circleBtn(Icons.favorite_border, () => _soon(context)),
                    ]),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 24),
            // tags
            _pad(Wrap(spacing: 8, runSpacing: 8, children: [
              _tag(a.category, a.categoryColor, a.categoryColor == ppCoral ? ppCoralTint : ppPanel),
              _tag(a.age.replaceAll('mo', 'months'), ppPurple, ppPanel),
            ])),
            const SizedBox(height: 14),
            _pad(Text(a.title, style: ppFraunces(31, h: 1.18))),

            // byline
            const SizedBox(height: 18),
            _pad(Row(children: [
              _avatar(38),
              const SizedBox(width: 11),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.author, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                  Text('${a.authorRole} · ${a.readMin} min read', style: ppBody(12, color: ppMuted)),
                ]),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check, size: 12, color: ppPurple),
                  const SizedBox(width: 4),
                  Text('Reviewed', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            ])),

            _div(),

            // body
            if (a.id == 'sleepcycles') ..._fullBody() else ..._lightBody(a),

            _div(),

            // author card
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _avatar(48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.author, style: ppJakarta(14)),
                  const SizedBox(height: 1),
                  Text('${a.authorRole} · 15 years', style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text("Writes ParentVeda's sleep and development library. Reviewed by our medical panel.",
                      style: ppBody(13, h: 1.55)),
                ]),
              ),
            ])),

            _div(),

            // keep reading
            _pad(Text('Keep reading', style: ppJakarta(16))),
            const SizedBox(height: 14),
            for (int i = 0; i < related.length; i++)
              _pad(_keepRow(context, related[i], top: true, bottom: i == related.length - 1)),

            // related product
            const SizedBox(height: 14),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text('Related', style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('White-noise soothers for lighter sleep', style: ppBody(14, color: ppInk, h: 1.4))),
                  const SizedBox(width: 8),
                  const Text('→', style: TextStyle(color: ppMuted)),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            _pad(Text("Articles are surfaced across ParentVeda — in AskVeda answers and each section's related rail. Every one is reviewed by our medical panel.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  List<Widget> _fullBody() => [
        _pad(Text(
            "If your baby was a champion sleeper and has suddenly started waking every couple of hours — you're not doing anything wrong. Something real has changed inside their brain.",
            style: ppFraunces(18, h: 1.6))),
        _para('Around the four-month mark, a baby\'s sleep matures from the simple newborn pattern into a more adult-like structure. Instead of drifting between just two states, they now move through several distinct cycles a night — and between each one, there\'s a brief moment of near-waking.'),
        _h2("What's actually happening"),
        _para('A newborn falls straight into deep sleep. A four-month-old, like an adult, cycles through lighter and deeper stages roughly every 45 minutes. At the end of each cycle they surface — and if they don\'t yet know how to resettle on their own, they wake fully and call for you.'),
        _callout('This isn\'t a step backwards. It\'s a sign your baby\'s brain is developing exactly on schedule.'),
        _h2('What helps'),
        _para("The goal isn't to force sleep — it's to give your baby the chance to practise resettling:"),
        _bullet('A short, identical wind-down every night.'),
        _bullet('Putting down drowsy but awake, so they learn the last step themselves.'),
        _bullet('A calm, dark, consistent room between cycles.'),
        _para('Most of all — hold your routine and be patient. This phase settles within two to six weeks, and your baby comes out the other side a more capable sleeper.'),
      ];

  List<Widget> _lightBody(Article a) => [
        _pad(Text('A ParentVeda-reviewed read on ${a.category.toLowerCase()} for the ${a.age} stage.',
            style: ppFraunces(18, h: 1.6))),
        const SizedBox(height: 16),
        _pad(Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome_outlined, size: 18, color: ppPurple),
            const SizedBox(width: 11),
            Expanded(
              child: Text('The full article is being written — it lands soon, reviewed by our medical panel.',
                  style: ppBody(13, color: ppInk, h: 1.5)),
            ),
          ]),
        )),
      ];

  Widget _para(String t) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: _pad(Text(t, style: ppBody(15, color: ppInk, h: 1.7))),
      );

  Widget _h2(String t) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 10),
        child: _pad(Text(t, style: ppJakarta(18))),
      );

  Widget _callout(String quote) => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: _pad(Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ppEyebrow('The key idea', color: ppPurple, spacing: 0.8),
            const SizedBox(height: 8),
            Text(quote, style: ppFraunces(17, h: 1.5)),
          ]),
        )),
      );

  Widget _bullet(String t) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(t, style: ppBody(15, color: ppInk, h: 1.6))),
        ])),
      );

  Widget _tag(String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: ppBody(11, color: fg, w: FontWeight.w700)),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: ppInk),
        ),
      );

  Widget _avatar(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
        clipBehavior: Clip.antiAlias,
        child: const PpStriped(height: 60, colorA: ppBorder, colorB: ppStripeB),
      );

  Widget _keepRow(BuildContext context, Article a, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: () => _open(context, a),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            const PpStriped(height: 52, width: 60, radius: 12, border: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${a.category} · ${a.readMin} min', style: ppBody(12, color: ppMuted)),
              ]),
            ),
          ]),
        ),
      );
}
