// =============================================================================
//  Launch promo pop-up — a large, sponsored brand carousel shown on app open
// -----------------------------------------------------------------------------
//  A big, clearly-visible modal (not a small toast): a swipeable carousel of
//  brand creatives with page dots and a close (X), dimming the app behind it.
//  Content comes from data/promo_data.dart. Shown once per app launch via
//  showLaunchPromo(), which MainScaffold calls after its first frame.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/promo_data.dart';

/// Guards so the pop-up appears only once per app process (an "on open" promo,
/// not on every rebuild / tab change). Set false in tests to suppress it.
bool kLaunchPromoEnabled = true;
bool _launchPromoShown = false;

/// Shows the launch promo carousel once. Safe to call repeatedly — it no-ops
/// after the first show, if disabled, or if there are no slides.
Future<void> showLaunchPromo(BuildContext context) async {
  if (!kLaunchPromoEnabled || _launchPromoShown || kLaunchPromos.isEmpty) return;
  _launchPromoShown = true;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _LaunchPromoDialog(slides: kLaunchPromos),
  );
}

class _LaunchPromoDialog extends StatefulWidget {
  const _LaunchPromoDialog({required this.slides});
  final List<PromoSlide> slides;

  @override
  State<_LaunchPromoDialog> createState() => _LaunchPromoDialogState();
}

class _LaunchPromoDialogState extends State<_LaunchPromoDialog> {
  final PageController _pager = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _act(PromoSlide s) async {
    Navigator.of(context).maybePop();
    final url = s.url;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Big and clearly visible: nearly the full width, most of the height.
    final w = media.size.width - 40;
    final h = media.size.height * 0.74;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      elevation: 0,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            // creative carousel
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: PageView.builder(
                controller: _pager,
                itemCount: widget.slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _Slide(slide: widget.slides[i], onCta: () => _act(widget.slides[i])),
              ),
            ),

            // close (X)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))],
                  ),
                  child: const Icon(Icons.close_rounded, size: 19, color: Color(0xFF33383D)),
                ),
              ),
            ),

            // page dots
            if (widget.slides.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < widget.slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page ? Colors.white : Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.onCta});
  final PromoSlide slide;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    // A real brand image, if supplied, fills the whole creative.
    if (slide.imageAsset != null) {
      return GestureDetector(
        onTap: onCta,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(slide.imageAsset!, fit: BoxFit.cover),
            Positioned(left: 14, top: 14, child: _tag()),
            Positioned(left: 20, right: 20, bottom: 40, child: _ctaButton()),
          ],
        ),
      );
    }

    // Placeholder creative: coloured header scoop + offer pills + CTA.
    return Container(
      color: slide.body,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header panel with the big headline
          Container(
            height: 210,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: BoxDecoration(
              color: slide.header,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tag(),
                const Spacer(),
                Text(
                  slide.headline,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: slide.ink,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // offers + subline + CTA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final o in slide.offers) ...[
                    _offerPill(o),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    slide.subline,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: slide.ink.withValues(alpha: 0.72),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: slide.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(slide.icon, size: 22, color: slide.accent),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        slide.brand,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: slide.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ctaButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'SPONSORED · ${slide.brand.toUpperCase()}',
          style: GoogleFonts.manrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: slide.ink.withValues(alpha: 0.7),
          ),
        ),
      );

  Widget _offerPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: slide.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: slide.accent.withValues(alpha: 0.28)),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: slide.ink,
          ),
        ),
      );

  Widget _ctaButton() => GestureDetector(
        onTap: onCta,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: slide.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: slide.accent.withValues(alpha: 0.4), blurRadius: 22, spreadRadius: -8, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.cta,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      );
}
