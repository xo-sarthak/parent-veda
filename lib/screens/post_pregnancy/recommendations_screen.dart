// =============================================================================
//  RecommendationsScreen — Explore · Recommendations (parenting · S16)
// -----------------------------------------------------------------------------
//  "Chosen for Aarav" — what to read, watch, play & do, tuned to his stage and
//  your city. Books (→ book detail), an honest screen-time note, and nearby
//  places. Reached from the Explore drawer. Faithful build of Claude Design ·
//  S16. Pushed screen (no bottom nav).
// =============================================================================

import 'package:flutter/material.dart';

import 'book_detail_screen.dart';
import 'pp_common.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _red = Color(0xFFC0392B);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openBook(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const BookDetailScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLangToggle(),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Chosen for Aarav'),
              const SizedBox(height: 10),
              Text('What to read, watch,\nplay & do', style: ppFraunces(30, h: 1.15)),
              const SizedBox(height: 12),
              Text(
                  "Never wonder “what's good for this age?” again — every pick is tuned to his stage and your city.",
                  style: ppBody(15)),
            ])),

            // age + city context
            const SizedBox(height: 18),
            _pad(Row(children: [
              Expanded(
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  _ctx(Icons.eco_outlined, '4 months'),
                  _ctx(Icons.place_outlined, 'Delhi NCR'),
                ]),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _soon(context),
                child: Text('Change', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              ),
            ])),

            // category chips
            const SizedBox(height: 18),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _chip(context, 'Books', active: true),
                  _chip(context, 'Shows'),
                  _chip(context, 'Toys'),
                  _chip(context, 'Places'),
                  _chip(context, 'Activities'),
                ],
              ),
            ),

            // Books
            const SizedBox(height: 24),
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Row(children: [
                  const Icon(Icons.menu_book_outlined, size: 18, color: ppPurple),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Books for 4 months', style: ppJakarta(17), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _soon(context), child: ppSeeAll()),
            ])),
            const SizedBox(height: 12),
            _pad(_book(context, "That's Not My Tiger",
                'A touch-and-feel board book — high-contrast pages and textures made for tiny, curious hands.',
                '₹299',
                top: true)),
            _pad(_book(context, 'Black & White Baby Book',
                "Bold high-contrast art that a 4-month-old's developing eyes can actually lock onto.", '₹349')),
            _pad(_book(context, 'Cloth Crinkle Book',
                'Soft, washable and crinkly — sound and texture in one, and safe to chew.', '₹249')),
            _pad(_book(context, 'Peekaboo Baby (Indian faces)',
                'Familiar Indian faces and a mirror page — the first seed of peekaboo and object permanence.',
                '₹399',
                bottom: true)),
            const SizedBox(height: 16),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppPurple)),
                child: Text('Explore more', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
              ),
            )),

            // Shows — honest note
            const SizedBox(height: 28),
            _pad(Row(children: [
              const Icon(Icons.tv_outlined, size: 18, color: ppPurple),
              const SizedBox(width: 8),
              Text('Screen time, honestly', style: ppJakarta(17)),
            ])),
            const SizedBox(height: 12),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'At 4 months, the honest answer is '),
                    TextSpan(text: 'no screens yet', style: TextStyle(color: ppInk, fontWeight: FontWeight.w700)),
                    const TextSpan(
                        text:
                            " — his brain learns from your face, not a screen. We'll surface show picks (with reasons) once he's older."),
                  ]),
                  style: ppBody(14, color: ppInk, h: 1.55),
                ),
                const SizedBox(height: 16),
                _rule(Icons.check_rounded, _green, 'When ready: slow, gentle shows',
                    'Calm pace, real-world scenes, little dialogue.'),
                const SizedBox(height: 12),
                _rule(Icons.close_rounded, _red, 'Avoid: fast, flashy, loud',
                    'Rapid cuts over-stimulate and set a hard-to-undo pace.'),
              ]),
            )),

            // Places
            const SizedBox(height: 28),
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Row(children: [
                  const Icon(Icons.place_outlined, size: 18, color: ppPurple),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Near you, in Delhi', style: ppJakarta(17), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _soon(context), child: ppSeeAll()),
            ])),
            const SizedBox(height: 12),
            _pad(_place(context, 'Lodhi Garden morning walk', 'Stroller-friendly · shaded', '0–1 yr', top: true)),
            _pad(_place(context, 'Baby sensory session, GK-II', 'This Saturday · 11am', '3–6 mo', bottom: true)),

            const SizedBox(height: 22),
            _pad(Text(
                "Every pick is tied to Aarav's age and your city — books & toys via trusted links, places & activities curated by a local editor.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _ctx(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: ppPurple),
          const SizedBox(width: 6),
          Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w700)),
        ]),
      );

  Widget _chip(BuildContext context, String label, {bool active = false}) => GestureDetector(
        onTap: active ? null : () => _soon(context),
        child: Container(
          margin: const EdgeInsets.only(right: 9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? ppPurple : ppBorder),
          ),
          child: Text(label,
              style: ppBody(13, color: active ? Colors.white : ppSoft, w: FontWeight.w700)),
        ),
      );

  Widget _book(BuildContext context, String title, String desc, String price,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openBook(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52,
            height: 68,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 74),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(desc, style: ppBody(12, h: 1.45)),
            ]),
          ),
          const SizedBox(width: 12),
          Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _rule(IconData icon, Color color, String title, String sub) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(sub, style: ppBody(12, h: 1.45)),
            ]),
          ),
        ],
      );

  Widget _place(BuildContext context, String title, String meta, String age,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _soon(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          const PpStriped(height: 52, width: 66, radius: 12, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(15, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(meta, style: ppBody(12)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
            child: Text(age, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
