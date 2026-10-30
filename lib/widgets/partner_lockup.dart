// =============================================================================
//  PartnerStrip — "ParentVeda × Northwind", or "Your doctor · Dr Rao"
// -----------------------------------------------------------------------------
//  Partner Editions A1 (docs/partner-editions/MASTER.md). One widget under the
//  top row of all three homes, so Pregnancy, Trying and Parenting cannot drift
//  apart: a fix here is a fix in every stage. PartnerBrand decides WHO; this
//  only draws.
//
//  ⚠️ NOT PresentedBy. `care_visibility.dart` (its header) and
//  `care_partner_card.dart` both say why: PresentedBy is the sponsorship
//  component, "a brand paid for this". A co-brand edition is the family's own
//  benefit, and a doctor is a person in her care; neither is an advert, and
//  borrowing the advert's component would make both read as one.
//
//  NO PARTNER COLOURS (D1). The pill is white with a hairline, the text is
//  ink. A sponsor's logo is its own picture; without one, the monogram is in
//  ParentVeda's ink, never a brand colour we would have to invent.
//
//  SPACING. The strip owns the gap above it (`padding`, 14 by default) and
//  takes no room at all when there is no partner, so a family without one
//  sees today's home to the pixel. That is why the heroes take it as a nullable
//  slot and never add a SizedBox of their own around it.
// =============================================================================

import 'package:flutter/material.dart';

import '../brand/brand_mark.dart';
import '../brand/brand_models.dart';
import '../care_partner/care_visibility.dart';
import '../screens/care_partner/care_partner_card.dart';
import '../screens/care_partner/care_partner_slot.dart';
import '../screens/enterprise/employer_benefits_screen.dart';
import '../screens/v2/v2_palette.dart';
import '../services/partner_brand.dart';
import '../theme/pv_fonts.dart';
import 'pv_feedback.dart' show PvPress;

/// The ink a monogram takes when a sponsor has no logo: the base UI's ink,
/// the same as the one button style. Never a partner colour (D1).
const Color _kMonogramInk = Color(0xFF2F2C30);

class PartnerStrip extends StatelessWidget {
  const PartnerStrip({
    super.key,
    required this.p,
    this.padding = const EdgeInsets.only(top: 14),
  });

  final V2Palette p;

  /// Applied only when something is drawn.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: PartnerBrand.instance,
    builder: (context, _) {
      final brand = PartnerBrand.instance;
      final lockup = brand.lockup;
      if (lockup != null) {
        return Padding(
          padding: padding,
          child: Center(
            child: PartnerLockup(info: lockup, p: p),
          ),
        );
      }
      if (brand.careLine != null) {
        // Through the slot, not drawn here: whether a care partner shows
        // (status, expiry, her dismissal, an admin's surfaces) is
        // CareVisibility's decision everywhere else, and so it is here.
        return CarePartnerSlot(
          key: const ValueKey('partner_strip_doctor'),
          surface: CareSurface.home,
          shape: CarePartnerCardShape.home,
          padding: padding,
        );
      }
      return const SizedBox.shrink();
    },
  );
}

/// The co-brand pill. Taps through to the benefits page she already has
/// (You › Benefits), so the strip is a way in, never a dead label.
class PartnerLockup extends StatelessWidget {
  const PartnerLockup({super.key, required this.info, required this.p});

  final PartnerLockupInfo info;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final text = pvManrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: p.ink1,
    );
    return Semantics(
      button: true,
      label: 'ParentVeda with ${info.name}. Your benefits',
      excludeSemantics: true,
      child: PvPress(
        child: GestureDetector(
          key: const ValueKey('partner_strip_lockup'),
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'employer'),
              builder: (_) => const EmployerBenefitsScreen(),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
            decoration: BoxDecoration(
              color: p.ground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/brand/pv-mark.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const SizedBox(width: 22, height: 22),
                  ),
                ),
                const SizedBox(width: 7),
                Text('ParentVeda', style: text),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    '×',
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink3,
                    ),
                  ),
                ),
                _PartnerMark(info: info, size: 22),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    info.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The sponsor's logo when it uploaded one, else its monogram in ink. A logo
/// that fails to load falls back the same way: never a broken image box.
class _PartnerMark extends StatelessWidget {
  const _PartnerMark({required this.info, required this.size});

  final PartnerLockupInfo info;
  final double size;

  @override
  Widget build(BuildContext context) {
    final monogram = BrandMark(
      brand: Brand(id: 'partner', name: info.name, colour: _kMonogramInk),
      size: size,
    );
    final url = info.logoUrl;
    if (url == null) return monogram;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => monogram,
      ),
    );
  }
}
