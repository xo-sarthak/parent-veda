// =============================================================================
//  CommunityScreen — Community · feed (parenting app · S4)
// -----------------------------------------------------------------------------
//  A populated-from-day-one feed: auto-joined + topical rooms as chips, then a
//  mix of a mother's post, a ParentVeda-promoted post, a live expert session,
//  and a labelled sponsored slot. Faithful build of Claude Design S4.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              _pad(Text('Community', style: ppJakarta(24))),
              const SizedBox(height: 4),
              _pad(Text('Your rooms, already full.', style: ppBody(13))),

              // room chips
              const SizedBox(height: 18),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _chip('March 2025 babies', active: true),
                    _chip('Boy moms'),
                    _chip('Delhi NCR'),
                    _chip('Sleep'),
                    _chip('Brain development'),
                    _joinChip(),
                  ],
                ),
              ),

              _pad(_gap(22, 22)),

              // post 1 — mother
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('#Sleep', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text('· Delhi NCR', style: ppBody(11, color: ppMuted)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                    clipBehavior: Clip.antiAlias,
                    child: const PpStriped(height: 40),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: 'Meera', style: TextStyle(color: ppInk, fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' · mom of a 4-month-old'),
                    ]), style: ppBody(13)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text('"Night 6 of the regression. Here\'s what finally worked for us…"',
                    style: ppBody(15, color: ppInk, h: 1.5)),
                const SizedBox(height: 12),
                Row(children: [
                  Text('♥ 128', style: ppBody(12, color: ppCoral)),
                  const SizedBox(width: 18),
                  Text('42 replies', style: ppBody(12, color: ppMuted)),
                ]),
              ])),

              _pad(Padding(padding: const EdgeInsets.only(bottom: 20), child: ppDivider())),

              // post 2 — promoted
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('From ParentVeda', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 10),
                Text('Leap 4 survival kit — 5 things that help', style: ppJakarta(18)),
                const SizedBox(height: 12),
                const PpStriped(height: 130, radius: 16, border: true),
              ])),

              _pad(Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: ppDivider())),

              // post 3 — live
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                      width: 7, height: 7, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  ppEyebrow('Live · Sunday 6pm', spacing: 0.8),
                ]),
                const SizedBox(height: 10),
                Text('Sleep for Indian families, with Dr. Ananya Rao', style: ppJakarta(17)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('Free expert session', style: ppBody(13))),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _soon(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppPurple)),
                      child: Text('Remind me', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                    ),
                  ),
                ]),
              ])),

              _pad(Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: ppDivider())),

              // post 4 — sponsored
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Sponsored', color: ppMuted, spacing: 0.8),
                const SizedBox(height: 10),
                Row(children: [
                  const PpStriped(height: 64, width: 64, radius: 16, border: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Nunu — breathable muslin swaddles', style: ppJakarta(15), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('New from an Indian parent brand.', style: ppBody(12)),
                    ]),
                  ),
                ]),
              ])),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
                ),
              ),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 3)),
      ]),
    );
  }

  Widget _gap(double top, double bottom) => Padding(padding: EdgeInsets.only(top: top, bottom: bottom), child: ppDivider());

  Widget _chip(String label, {bool active = false}) => Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: ppBody(12, color: active ? Colors.white : ppSoft, w: active ? FontWeight.w700 : FontWeight.w600)),
      );

  Widget _joinChip() => Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFC7BBD6), style: BorderStyle.solid),
        ),
        child: Text('+ Join', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
      );
}
