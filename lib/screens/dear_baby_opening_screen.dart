// =============================================================================
//  DearBabyOpeningScreen — "open your letters", the day the baby is born
// -----------------------------------------------------------------------------
//  The vault's row has promised it since the start: "Letters that open when
//  your baby is born". This is that moment (STILL-OPEN §83.2). It is shown
//  from the vault while the letters are unlocked but not yet opened
//  (DearBabyVaultStore), and never again once she has opened them.
//
//  From the Mobbin pass (MOBBIN-DISCOVERY §22):
//    * Swiggy's envelope with sheets fanning up out of it: the shape of the
//      moment, adopted.
//    * Tolan's "unlocked" paper card with one ink "Read now" pill and a quiet
//      "Continue" under it: one action, and a way out that is not a button.
//    * The confetti every reward screen reaches for: declined. This is a
//      mother's letters on the day she gave birth, not a level-up. Calm,
//      the house voice.
//
//  ⚠️ RESPONSIVE BY CONSTRUCTION. The seal settles under her finger the
//  instant she presses it (PvPress), the haptic lands on release, and the
//  flap starts in the same frame. The pill under it opens the same way, so
//  there is no dead tap whichever she reaches for. Reduced motion skips
//  straight to the open envelope.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/dear_baby_vault_store.dart';
import '../theme/pv_fonts.dart';
import '../widgets/pv_feedback.dart';
import 'v2/v2_palette.dart';

const Color _paper = Color(0xFFFBF7F0);
const Color _paperDeep = Color(0xFFF3EADC);
const Color _paperLine = Color(0xFFE4D9C8);

class DearBabyOpeningScreen extends StatefulWidget {
  const DearBabyOpeningScreen({
    super.key,
    required this.letters,
    required this.firstWeek,
    required this.lastWeek,
  });

  final int letters;
  final int? firstWeek;
  final int? lastWeek;

  @override
  State<DearBabyOpeningScreen> createState() => _DearBabyOpeningScreenState();
}

class _DearBabyOpeningScreenState extends State<DearBabyOpeningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// Flips on the tap itself, not when the flap finishes: the words and the
  /// button answer her finger while the envelope is still opening.
  bool _isOpen = false;

  void _openEnvelope() {
    if (_isOpen) return;
    pvCommitFeedback();
    setState(() => _isOpen = true);
    if (MediaQuery.of(context).disableAnimations) {
      _open.value = 1;
    } else {
      _open.forward();
    }
  }

  Future<void> _read() async {
    pvCommitFeedback();
    await DearBabyVaultStore.instance.markOpened();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final name = DearBabyVaultStore.instance.childName;
    final n = widget.letters;
    final span = widget.firstWeek == null
        ? ''
        : (widget.firstWeek == widget.lastWeek
            ? ', from week ${widget.firstWeek}'
            : ', week ${widget.firstWeek} to week ${widget.lastWeek}');
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: PvPress(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.line),
                    ),
                    child: Icon(Icons.close_rounded, size: 20, color: p.ink1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              Text('DEAR BABY',
                  style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: p.ink3)),
              const SizedBox(height: 10),
              Text(name == null ? 'Welcome, little one' : 'Welcome, $name',
                  textAlign: TextAlign.center,
                  style: pvDisplayStyle(size: 32, height: 1.1, color: p.ink1)),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isOpen
                      ? 'These were written for you while you were on your way.'
                      : 'Your letters are ready to open. '
                          '${n == 1 ? 'One letter' : '$n letters'}$span.',
                  key: ValueKey(_isOpen),
                  textAlign: TextAlign.center,
                  style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Center(
              child: LayoutBuilder(builder: (context, c) {
                final w = math.min(c.maxWidth - 64, 320.0);
                return AnimatedBuilder(
                  animation: _open,
                  builder: (context, _) => _Envelope(
                    width: w,
                    t: _open.value,
                    letters: n,
                    ink: p.ink1,
                    onSeal: _openEnvelope,
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottom),
            child: Column(children: [
              PvPress(
                child: GestureDetector(
                  key: const ValueKey('dear_baby_open_cta'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _isOpen ? _read : _openEnvelope,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.ink1,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        _isOpen ? 'Read your letters' : 'Open the envelope',
                        key: ValueKey(_isOpen),
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('Later',
                    style: pvManrope(
                        fontSize: 14, fontWeight: FontWeight.w600, color: p.ink2)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The envelope: a body, a flap that folds back, and sheets that rise out of
/// it as it opens. [t] runs 0 (sealed) to 1 (open, sheets up).
class _Envelope extends StatelessWidget {
  const _Envelope({
    required this.width,
    required this.t,
    required this.letters,
    required this.ink,
    required this.onSeal,
  });

  final double width;
  final double t;
  final int letters;
  final Color ink;
  final VoidCallback onSeal;

  @override
  Widget build(BuildContext context) {
    final h = width * 0.66;
    // The flap folds over the first 45%; the sheets rise after it.
    final flap = Curves.easeInOut.transform((t / 0.45).clamp(0.0, 1.0));
    final rise = Curves.easeOutBack.transform(((t - 0.35) / 0.65).clamp(0.0, 1.0));
    final sheets = math.min(3, math.max(1, letters));

    return SizedBox(
      width: width,
      height: h + width * 0.55,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
        // The flap, open: drawn behind the sheets once it has folded past
        // upright.
        if (flap > 0.5)
          Positioned(
            bottom: h - 1,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(math.pi * (1 - flap)),
              child: CustomPaint(
                size: Size(width, h * 0.62),
                painter: _FlapPainter(up: true),
              ),
            ),
          ),
        // The sheets, rising.
        for (var i = 0; i < sheets; i++)
          Positioned(
            // Sealed, the sheets sit wholly inside the body (top at 0.98h).
            bottom: h * 0.08 + rise * (width * (0.34 + 0.09 * (sheets - 1 - i))),
            child: Transform.rotate(
              angle: rise * (i - (sheets - 1) / 2) * 0.09,
              child: Container(
                width: width * 0.8,
                height: h * 0.9,
                padding: EdgeInsets.fromLTRB(width * 0.08, width * 0.07, width * 0.08, 0),
                decoration: BoxDecoration(
                  color: i == sheets - 1 ? Colors.white : _paper,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _paperLine),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05 * rise),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final f in const [0.5, 0.9, 0.8, 0.65])
                    Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      width: width * 0.64 * f,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _paperLine,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        // The body of the envelope, over the bottom of the sheets.
        CustomPaint(size: Size(width, h), painter: _BodyPainter()),
        // The flap, closed or closing: over everything until it passes upright.
        if (flap <= 0.5)
          Positioned(
            bottom: h * 0.38,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(-math.pi * flap),
              child: CustomPaint(
                size: Size(width, h * 0.62),
                painter: _FlapPainter(up: false),
              ),
            ),
          ),
        // The seal: pressed, it settles; it fades as the flap lifts.
        if (flap < 0.25)
          Positioned(
            bottom: h * 0.38 - 30,
            child: Opacity(
              opacity: 1 - flap * 4,
              child: PvPress(
                child: GestureDetector(
                  key: const ValueKey('dear_baby_seal'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onSeal,
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('$letters',
                          style: pvDisplayStyle(size: 20, height: 1, color: Colors.white)),
                      Text(letters == 1 ? 'LETTER' : 'LETTERS',
                          style: pvManrope(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final r = RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(10));
    canvas.drawRRect(r, Paint()..color = _paperDeep);
    // The two side folds meeting under the flap.
    final fold = Paint()
      ..color = _paperLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, s.height), Offset(s.width / 2, s.height * 0.42), fold);
    canvas.drawLine(Offset(s.width, s.height), Offset(s.width / 2, s.height * 0.42), fold);
    canvas.drawRRect(r, fold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The flap: a triangle pointing down when closed, up when folded back.
class _FlapPainter extends CustomPainter {
  _FlapPainter({required this.up});
  final bool up;

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, s.height)
        ..lineTo(s.width / 2, 0)
        ..lineTo(s.width, s.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(s.width, 0)
        ..lineTo(s.width / 2, s.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = up ? _paperDeep : const Color(0xFFEFE4D3));
    canvas.drawPath(
        path,
        Paint()
          ..color = _paperLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _FlapPainter old) => old.up != up;
}
