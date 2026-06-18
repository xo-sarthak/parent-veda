// =============================================================================
//  CardShell
// -----------------------------------------------------------------------------
//  Shared visual scaffold for every card in the weekly stack. Keeps the calm
//  "nursery, not toy store" aesthetic consistent: soft surface, generous
//  rounding, a whisper of shadow, an eyebrow + title header with a tinted icon
//  chip, and comfortable scrollable content so nothing ever overflows.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Provides per-week chrome (currently just the gradient-card trial flag) to
/// every [CardShell] below it without threading a param through each card.
class CardChrome extends InheritedWidget {
  const CardChrome({super.key, required this.gradient, required super.child});

  final bool gradient;

  static bool gradientOf(BuildContext context) {
    final c = context.dependOnInheritedWidgetOfExactType<CardChrome>();
    return c?.gradient ?? false;
  }

  @override
  bool updateShouldNotify(CardChrome oldWidget) => gradient != oldWidget.gradient;
}

class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.footer,
    this.trailing,
  });

  /// Small uppercase-ish label above the title (e.g. "Baby's whisper").
  final String eyebrow;

  /// Card title (e.g. "How big am I?").
  final String title;

  final IconData icon;

  /// Accent colour for the icon chip + eyebrow.
  final Color accent;

  /// Main scrollable content of the card.
  final Widget child;

  /// Optional pinned footer (e.g. a CTA) that stays below the scroll area.
  final Widget? footer;

  /// Optional trailing widget in the header (e.g. a speaker button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final gradient = CardChrome.gradientOf(context);
    return Container(
      decoration: BoxDecoration(
        color: gradient ? null : AppTheme.surface,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // A soft, smooth three-stop blush: clean white at the top easing
                // into a warm peach-rose glow at the foot of the card.
                colors: [Colors.white, AppTheme.primary50, AppTheme.secondary50],
                stops: [0.0, 0.55, 1.0],
              )
            : null,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          // One soft, lavender-tinted shadow — never harsh.
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The header scrolls *with* the content (it is no longer pinned), and
            // a soft fade at the top/bottom edges means nothing looks hard-cut.
            Expanded(
              child: _FadeScroll(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _Header(
                        eyebrow: eyebrow,
                        title: title,
                        icon: icon,
                        accent: accent,
                        trailing: trailing),
                    const SizedBox(height: 20),
                    child,
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 14),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Wraps a scroll view in a gentle top/bottom alpha fade so scrolled content
/// dissolves softly at the card edges instead of being sharply clipped.
class _FadeScroll extends StatelessWidget {
  const _FadeScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final topStop = (14 / h).clamp(0.0, 0.45);
        final bottomStop = 1 - (22 / h).clamp(0.0, 0.45);
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, topStop, bottomStop, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.accent,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: accent,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(title, style: text.headlineSmall),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// A soft tinted "pill" used for small labels inside cards.
class SoftPill extends StatelessWidget {
  const SoftPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 14 : 10, 8, 14, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
