// =============================================================================
//  SnapshotExpandedScreen — Snapshot of Today · expanded (parenting · S6)
// -----------------------------------------------------------------------------
//  The full "where he is right now": intro video, the four developmental windows
//  (motor/cognitive/social/language), what's-next, and the child's details.
//  Faithful build of Claude Design S6. Reached from Home → Snapshot "See all".
//  Pushed screen (no bottom nav).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class SnapshotExpandedScreen extends StatelessWidget {
  const SnapshotExpandedScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
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
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_back, size: 20, color: ppSoft),
                const SizedBox(width: 12),
                Flexible(child: Text('Aarav · Snapshot of Today', style: ppBody(14, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            )),

            // video hero
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(children: [
                  const PpStriped(height: 210, radius: 22, border: true),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 5, height: 5, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('2 min', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const Positioned.fill(child: Center(child: _Play(56))),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x802F2C30)]),
                      ),
                      child: Text('Aarav this month — a guide to Leap 4', style: ppBody(13, color: Colors.white, w: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            _pad(Text('Where Aarav is right now', style: ppFraunces(30, h: 1.15))),
            const SizedBox(height: 10),
            _pad(Text(
                'Four windows into a 4-month-old, mid-Leap 4. Every baby moves at his own pace — these are what to look for, not a scorecard.',
                style: ppBody(14, h: 1.6))),

            const SizedBox(height: 24),
            _pad(_window('Motor',
                'His hands have found each other — he clasps them at his chest, swipes at dangling toys, and pushes up on the floor. A first roll from tummy to back could arrive any day.',
                first: true)),
            _pad(_window('Cognitive',
                "He's piecing together that one thing leads to another — following your hand all the way to the toy it reaches for. Cause, meet effect. This is the heart of Leap 4.")),
            _pad(_window('Social',
                'Your face is the best thing in his world. He beams at you across a room, and has just discovered that a laugh earns a laugh back.')),
            _pad(_window('Language',
                "Coos are stretching into 'aah-goo', raspberries and squeals — he's rehearsing the music of conversation long before the words arrive.")),

            const SizedBox(height: 24),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('What to expect next', color: ppBrown, spacing: 0.8),
                const SizedBox(height: 8),
                Text(
                    'A confident roll, reaching with one hand, and grabbing everything — including your hair and your plate. Solids open up around 6 months.',
                    style: ppBody(14, color: ppInk, h: 1.55)),
              ]),
            )),

            _pad(const Padding(padding: EdgeInsets.symmetric(vertical: 26), child: SizedBox(height: 1, child: ColoredBox(color: ppLine)))),

            // details
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Aarav's details", style: ppJakarta(18)),
              GestureDetector(onTap: () => _soon(context), child: Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700))),
            ])),
            const SizedBox(height: 16),
            _pad(Row(children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                  clipBehavior: Clip.antiAlias,
                  child: const PpStriped(height: 70),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, shape: BoxShape.circle, border: Border.all(color: ppBg, width: 2)),
                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ),
              ]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Aarav', style: ppJakarta(20)),
                  const SizedBox(height: 2),
                  Text('Born 8 Mar 2026 · Boy · Delhi NCR', style: ppBody(13)),
                ]),
              ),
            ])),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Expanded(child: _stat('Weight', '6.4', 'kg', '50th centile')),
              const SizedBox(width: 12),
              Expanded(child: _stat('Height', '63', 'cm', '48th centile')),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _window(String label, String text, {bool first = false}) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: first ? ppPurple : ppLine, width: first ? 2 : 1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow(label, color: ppPurple, spacing: 1.0),
          const SizedBox(height: 8),
          Text(text, style: ppBody(14, color: ppInk, h: 1.6)),
        ]),
      );

  Widget _stat(String label, String value, String unit, String centile) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow(label, color: ppSoft, spacing: 0.4),
          const SizedBox(height: 6),
          Text.rich(TextSpan(children: [
            TextSpan(text: value, style: ppJakarta(24)),
            TextSpan(text: ' $unit', style: ppBody(14, color: ppSoft, w: FontWeight.w600)),
          ])),
          const SizedBox(height: 2),
          Text(centile, style: ppBody(12, color: ppMuted)),
        ]),
      );
}

class _Play extends StatelessWidget {
  const _Play(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
      );
}
