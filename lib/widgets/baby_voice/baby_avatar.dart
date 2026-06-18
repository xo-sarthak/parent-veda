// =============================================================================
//  BabyAvatar
// -----------------------------------------------------------------------------
//  A soft, cute cartoon baby face (CustomPainter) that blinks every few seconds
//  and gives a gentle bounce while the baby voice is speaking. Uses the app's
//  primary/secondary palette only.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/baby_voice_service.dart';
import '../../theme/app_theme.dart';

class BabyAvatar extends StatefulWidget {
  const BabyAvatar({
    super.key,
    required this.week,
    required this.listenKey,
    this.size = 120,
  });

  final int week;
  final String listenKey;
  final double size;

  @override
  State<BabyAvatar> createState() => _BabyAvatarState();
}

class _BabyAvatarState extends State<BabyAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _bounce;
  final BabyVoiceService _svc = BabyVoiceService.instance;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3600))
      ..repeat();
    _bounce = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _svc.addListener(_onVoice);
  }

  void _onVoice() {
    final playing = _svc.isPlaying(widget.listenKey);
    if (playing && !_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    } else if (!playing && _bounce.isAnimating) {
      _bounce.stop();
      _bounce.value = 0;
    }
  }

  @override
  void dispose() {
    _svc.removeListener(_onVoice);
    _blink.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blink, _bounce]),
      builder: (context, _) {
        // Blink: eyes closed only briefly near the end of each cycle.
        final t = _blink.value;
        final blink = t > 0.93 ? ((t - 0.93) / 0.07) : 0.0;
        final eyeOpen = 1.0 - (blink < 0.5 ? blink * 2 : (1 - blink) * 2);
        final scale = 1.0 + 0.05 * Curves.easeInOut.transform(_bounce.value);
        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _BabyFacePainter(eyeOpen: eyeOpen.clamp(0.0, 1.0)),
          ),
        );
      },
    );
  }
}

class _BabyFacePainter extends CustomPainter {
  _BabyFacePainter({required this.eyeOpen});

  /// 1 = fully open, 0 = closed.
  final double eyeOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);
    final r = w * 0.40;

    // Soft outer halo
    canvas.drawCircle(
      c,
      r * 1.18,
      Paint()..color = AppTheme.primary100.withValues(alpha: 0.5),
    );

    // Head
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFE3D3)); // soft peach
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppTheme.secondary200.withValues(alpha: 0.6),
    );

    // Little hair curl on top
    final hairPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.tertiary400;
    final hairPath = Path()
      ..moveTo(c.dx, c.dy - r * 0.96)
      ..relativeCubicTo(w * 0.06, -w * 0.05, w * 0.12, w * 0.02, w * 0.04, w * 0.07);
    canvas.drawPath(hairPath, hairPaint);

    // Cheeks
    final cheek = Paint()..color = AppTheme.secondary200.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(c.dx - r * 0.55, c.dy + r * 0.18), r * 0.16, cheek);
    canvas.drawCircle(Offset(c.dx + r * 0.55, c.dy + r * 0.18), r * 0.16, cheek);

    // Eyes
    final eyePaint = Paint()..color = AppTheme.neutral900;
    final eyeY = c.dy - r * 0.10;
    final eyeDx = r * 0.34;
    final eyeRx = r * 0.11;
    final eyeRy = r * 0.16 * eyeOpen;
    for (final sign in [-1.0, 1.0]) {
      final eyeCenter = Offset(c.dx + sign * eyeDx, eyeY);
      if (eyeOpen < 0.15) {
        // closed — a gentle curved lash line
        final p = Path()
          ..moveTo(eyeCenter.dx - eyeRx, eyeCenter.dy)
          ..quadraticBezierTo(
              eyeCenter.dx, eyeCenter.dy + r * 0.06, eyeCenter.dx + eyeRx, eyeCenter.dy);
        canvas.drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.02
            ..strokeCap = StrokeCap.round
            ..color = AppTheme.neutral900,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: eyeRx * 2, height: eyeRy * 2),
          eyePaint,
        );
        // sparkle
        canvas.drawCircle(
          Offset(eyeCenter.dx + eyeRx * 0.3, eyeCenter.dy - eyeRy * 0.4),
          eyeRx * 0.35,
          Paint()..color = Colors.white,
        );
      }
    }

    // Smile
    final smile = Path()
      ..moveTo(c.dx - r * 0.28, c.dy + r * 0.42)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.66, c.dx + r * 0.28, c.dy + r * 0.42);
    canvas.drawPath(
      smile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.secondary600,
    );
  }

  @override
  bool shouldRepaint(_BabyFacePainter old) => old.eyeOpen != eyeOpen;
}
