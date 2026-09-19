// =============================================================================
//  Is it safe? — the three beats of a scan: looking, locked, found
// -----------------------------------------------------------------------------
//  2026-09-20, after the user's first real scans on the phone: "add effects
//  so the user gets to know that success took place — like UPI apps do with
//  effects and motion." Mobbin (MOBBIN-DISCOVERY §11): Opera sweeps a line
//  while it looks; WhatsApp locks a green ring around the code the instant
//  it reads it, then draws a tick; Luma slides the result up under a
//  "checked in" pill. Three beats, each with its own motion and haptic:
//
//    LOOKING   a sweep line across the finder (barcode) or across her photo
//              (identify) — the app is working, not stuck
//    LOCKED    the corners snap into a full ring and go green; a heavy
//              haptic — the phone SAW it, before the network answers
//    FOUND     a tick draws itself inside a ring; the row scales in — the
//              answer is here
//
//  All ink except the lock ring, which is the safe green for a second; the
//  verdict's colour stays on the dot, as everywhere.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../v2/v2_palette.dart';

const Color kCanILockGreen = Color(0xFF2E9E5B);

/// A thin line that sweeps top to bottom, forever, inside its parent.
class CanISweep extends StatefulWidget {
  const CanISweep({super.key, this.color = Colors.white, this.running = true});
  final Color color;
  final bool running;

  @override
  State<CanISweep> createState() => _CanISweepState();
}

class _CanISweepState extends State<CanISweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void didUpdateWidget(CanISweep old) {
    super.didUpdateWidget(old);
    if (!widget.running && _c.isAnimating) _c.stop();
    if (widget.running && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _SweepPainter(_c.value, widget.color, widget.running)),
      );
}

class _SweepPainter extends CustomPainter {
  _SweepPainter(this.t, this.color, this.on);
  final double t;
  final Color color;
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    if (!on) return;
    // Ease in and out so the line lingers at neither edge.
    final y = size.height * (0.5 - 0.5 * math.cos(t * math.pi * 2)) * 0.92 + size.height * 0.04;
    final paint = Paint()
      ..shader = LinearGradient(colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)])
          .createShader(Rect.fromLTWH(0, y - 1, size.width, 2))
      ..strokeWidth = 2;
    canvas.drawLine(Offset(size.width * 0.06, y), Offset(size.width * 0.94, y), paint);
    final glow = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.06, y - 8, size.width * 0.88, 16), glow);
  }

  @override
  bool shouldRepaint(covariant _SweepPainter old) => old.t != t || old.on != on;
}

/// The finder: four corners while looking; on lock the corners grow into a
/// full rounded ring and turn green (WhatsApp's lock-on).
class CanIFinder extends StatelessWidget {
  const CanIFinder({super.key, required this.locked});
  final bool locked;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: locked ? 1 : 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => CustomPaint(painter: _FinderPainter(v)),
      );
}

class _FinderPainter extends CustomPainter {
  _FinderPainter(this.v);
  final double v; // 0 = corners, 1 = full green ring

  @override
  void paint(Canvas canvas, Size size) {
    final color = Color.lerp(Colors.white, kCanILockGreen, v)!;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // Each corner's arm grows from 26 to half the side, meeting its neighbour.
    final lx = 26 + (w / 2 - 26) * v;
    final ly = 26 + (h / 2 - 26) * v;
    for (final (x, y, dx, dy) in [(0.0, 0.0, 1.0, 1.0), (w, 0.0, -1.0, 1.0), (0.0, h, 1.0, -1.0), (w, h, -1.0, -1.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * lx, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * ly), paint);
    }
    if (v > 0) {
      // A soft green wash inside the ring as it locks.
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(6)),
        Paint()..color = kCanILockGreen.withValues(alpha: 0.12 * v),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FinderPainter old) => old.v != v;
}

/// A tick that draws itself inside a ring, once.
class CanITick extends StatefulWidget {
  const CanITick({super.key, this.size = 56, this.color});
  final double size;
  final Color? color;

  @override
  State<CanITick> createState() => _CanITickState();
}

class _CanITickState extends State<CanITick> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 620))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _TickPainter(_c.value, widget.color ?? p.ink1)),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    // The ring sweeps round in the first 60%.
    final ring = Curves.easeOutCubic.transform((t / 0.6).clamp(0, 1));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * ring,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // The tick draws in the last 50%, two strokes.
    final tick = Curves.easeOutCubic.transform(((t - 0.5) / 0.5).clamp(0, 1));
    if (tick <= 0) return;
    final a = Offset(size.width * 0.30, size.height * 0.52);
    final b = Offset(size.width * 0.45, size.height * 0.67);
    final d = Offset(size.width * 0.71, size.height * 0.37);
    final path = Path()..moveTo(a.dx, a.dy);
    final first = (tick / 0.4).clamp(0.0, 1.0);
    path.lineTo(a.dx + (b.dx - a.dx) * first, a.dy + (b.dy - a.dy) * first);
    if (tick > 0.4) {
      final second = ((tick - 0.4) / 0.6).clamp(0.0, 1.0);
      path.lineTo(b.dx + (d.dx - b.dx) * second, b.dy + (d.dy - b.dy) * second);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) => old.t != t;
}

/// Scales and fades a child in, once — the found row arriving.
class CanIArrive extends StatelessWidget {
  const CanIArrive({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420) + delay,
        curve: Interval(delay.inMilliseconds / (420 + delay.inMilliseconds), 1, curve: Curves.easeOutBack),
        builder: (_, v, child) => Opacity(
          opacity: v.clamp(0, 1),
          child: Transform.scale(scale: 0.92 + 0.08 * v, child: child),
        ),
        child: child,
      );
}

/// The two haptics: the phone saw it; the answer is here.
Future<void> canILockHaptic() => HapticFeedback.heavyImpact();
Future<void> canIFoundHaptic() async {
  await HapticFeedback.mediumImpact();
  await Future<void>.delayed(const Duration(milliseconds: 90));
  await HapticFeedback.lightImpact();
}
