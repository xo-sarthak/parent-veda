// =============================================================================
//  WonderWeekScreen — Tools · Wonder Week Window (parenting · S22b v2 premium)
// -----------------------------------------------------------------------------
//  A ParentVeda original: which leap the baby is in, how far through the storm,
//  an Indian-context "nazar" reframe, what he's working on, the sunny side,
//  cross-links to ride it out, a leaps timeline, and a sticky share. Faithful
//  build of Claude Design "post pregnancy - content.dc.html" · S22b v2 (premium).
//  Reached from the Tools hub.
// =============================================================================

import 'package:flutter/material.dart';

import 'community_screen.dart';
import 'growth_activity_screen.dart';
import 'pp_common.dart';
import 'remedy_detail_screen.dart';

class WonderWeekScreen extends StatelessWidget {
  const WonderWeekScreen({super.key});

  static const Color _lav = Color(0xFFB79BDD);
  static const Color _gold = Color(0xFFFFE3A0);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // cosmic hero
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                decoration: const BoxDecoration(
                  gradient: RadialGradient(center: Alignment(0.55, -0.7), radius: 1.3, colors: [Color(0xFF5A3E8A), Color(0xFF2A2733)]),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                      ),
                    ),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('LIVE NOW', style: ppBody(10, color: const Color(0xFFC7B2E0), w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
                    ]),
                  ]),
                  const SizedBox(height: 26),
                  Text('AARAV IS IN', style: ppBody(11, color: _lav, w: FontWeight.w700).copyWith(letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('Leap 4', style: ppFraunces(44, color: Colors.white, h: 1.0)),
                  const SizedBox(height: 6),
                  Text('The World of Events', style: ppBody(15, color: const Color(0xFFCFC7DA))),
                  const SizedBox(height: 26),
                  Row(children: [
                    const Icon(Icons.cloud_rounded, size: 17, color: Color(0xFFCFC7DA)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LayoutBuilder(builder: (context, c) {
                        final w = c.maxWidth;
                        const f = 0.62;
                        return SizedBox(
                          height: 16,
                          child: Stack(clipBehavior: Clip.none, children: [
                            Positioned(left: 0, right: 0, top: 4, child: Container(height: 8, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)))),
                            Positioned(left: 0, top: 4, child: Container(width: w * f, height: 8, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7A5B9E), _gold]), borderRadius: BorderRadius.circular(999)))),
                            Positioned(
                              left: w * f - 8,
                              top: 0,
                              child: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.8), blurRadius: 12, spreadRadius: 2)])),
                            ),
                          ]),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.wb_sunny_rounded, size: 17, color: _gold),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Flexible(child: Text('Day 12 · past the worst', style: ppBody(12, color: _gold, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 10),
                    Flexible(child: Text('~1 week to sunny', textAlign: TextAlign.right, style: ppBody(12, color: const Color(0xFF9A93A3)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ]),
              ),

              // nazar quote card (overlaps hero)
              Transform.translate(
                offset: const Offset(0, -14),
                child: _pad(Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0DEE4)),
                      boxShadow: const [BoxShadow(color: Color(0x262F2C30), blurRadius: 32, spreadRadius: -20, offset: Offset(0, 14))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.visibility_outlined, size: 18, color: ppCoral),
                      const SizedBox(width: 8),
                      Text('"NAZAR LAG GAYI?"', style: ppBody(11, color: const Color(0xFFC6295A), w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                    ]),
                    const SizedBox(height: 8),
                    Text("Clingy and crying more? It's not the evil eye — it's Leap 4's fussiness, and it passes. This is growth.",
                        style: ppFraunces(17, h: 1.45)),
                  ]),
                )),
              ),

              // what he's working on
              _pad(Text("What he's working on", style: ppJakarta(17))),
              const SizedBox(height: 12),
              _pad(Column(children: [
                _workRow(Icons.back_hand_outlined, 'Watching hands, reaching with real intent.'),
                const SizedBox(height: 10),
                _workRow(Icons.cyclone_rounded, 'Rolling toward things he wants.'),
                const SizedBox(height: 10),
                _workRow(Icons.link_rounded, 'Grasping that actions flow in sequences.'),
              ])),

              // sunny side
              const SizedBox(height: 20),
              _pad(Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF6E6), Color(0xFFF6EED9)]),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.wb_sunny_rounded, size: 16, color: ppBrown),
                    const SizedBox(width: 8),
                    ppEyebrow('On the sunny side', color: ppBrown, spacing: 0.8),
                  ]),
                  const SizedBox(height: 8),
                  Text('A calmer, more capable baby — steadier reaching, the first real rolls, and longer, settled sleep stretches.',
                      style: ppBody(14, color: ppInk, h: 1.6)),
                ]),
              )),

              // riding out
              const SizedBox(height: 28),
              _pad(Text('Riding out the storm', style: ppJakarta(17))),
              const SizedBox(height: 12),
              _pad(_link(context, 'Play', ppPurple, 'Peekaboo — soothe the clinginess',
                  () => _push(context, const GrowthActivityScreen()), top: true)),
              _pad(_link(context, 'Nuskha', ppBrown, 'Ajwain potli for leap-time sniffles',
                  () => _push(context, const RemedyDetailScreen()), top: true)),
              _pad(_link(context, 'Room', ppPurple, 'Parents in Leap 4 right now',
                  () => _push(context, const CommunityScreen()), top: true, bottom: true)),

              // timeline
              const SizedBox(height: 28),
              _pad(Text('The road so far', style: ppJakarta(17))),
              const SizedBox(height: 12),
              _pad(Row(children: [
                _seg('1–3', 'done', flex: 10, bg: ppPanel, fg: ppPurple),
                const SizedBox(width: 8),
                _seg('Leap 4', 'now', flex: 14, bg: ppPurple, fg: Colors.white, subFg: const Color(0xFFD8C8EA)),
                const SizedBox(width: 8),
                _seg('5', '~6 wks', flex: 10, outline: true),
                const SizedBox(width: 8),
                _seg('6', 'later', flex: 10, outline: true),
              ])),

              const SizedBox(height: 22),
              _pad(Text("Based on the Wonder Weeks framework, tuned for Indian homes. Every baby's timing varies by a week or two.",
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // sticky share
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.3]),
              ),
              child: GestureDetector(
                onTap: () => _soon(context),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.ios_share_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(child: Text("Share “Aarav's in Leap 4”", style: ppBody(14, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _workRow(IconData icon, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, size: 20, color: ppPurple),
          const SizedBox(width: 13),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.45))),
        ]),
      );

  Widget _link(BuildContext context, String tag, Color tagFg, String title, VoidCallback onTap,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: onTap,
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
          Container(
            width: 64,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
            child: Text(tag, style: ppBody(10, color: tagFg, w: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: ppBody(14, color: ppInk, h: 1.4))),
          const SizedBox(width: 8),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }

  Widget _seg(String label, String sub, {required int flex, Color? bg, Color? fg, Color? subFg, bool outline = false}) => Expanded(
        flex: flex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: outline ? Colors.transparent : bg,
            borderRadius: BorderRadius.circular(12),
            border: outline ? Border.all(color: ppLine) : null,
          ),
          child: Column(children: [
            Text(label, style: ppBody(12, color: outline ? ppMuted : (fg ?? ppInk), w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(sub, style: ppBody(9, color: outline ? ppMuted : (subFg ?? ppMuted))),
          ]),
        ),
      );
}
