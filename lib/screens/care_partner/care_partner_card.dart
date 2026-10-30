// =============================================================================
//  CarePartnerCard — "Invited by Dr Meera Rao"
// -----------------------------------------------------------------------------
//  The one component that renders a Care Partner to a parent. Everywhere the
//  partner appears goes through here, so the tone cannot drift screen by screen.
//
//  It is NOT the sponsorship component and must never be. PresentedBy (in
//  lib/brand/) says a brand paid for something; this says a person she trusts
//  introduced her. The words come from the partner's TrustMessage, which
//  refuses to render "sponsored" whatever the admin panel is set to.
//
//  Quiet on purpose. A doctor's name on a soft card is a reassurance; a doctor's
//  name in a coloured banner is an advertisement, and the whole module fails the
//  moment a parent reads it as one.
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_partner_models.dart';
import '../../services/partner_brand.dart' show careLineDetail, careLineLabel;
import '../post_pregnancy/pp_common.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

enum CarePartnerCardShape {
  /// A single line — for a content page or the home.
  line,

  /// A card with the photo and welcome — for the welcome moment and Care Circle.
  full,

  /// "Your doctor · Dr Meera Rao", the place underneath, under the top row of
  /// the three homes (Partner Editions A1, D3). A hairline box on white, never
  /// a tinted slab: the base UI's rule for a note on the page.
  home,
}

class CarePartnerCard extends StatelessWidget {
  const CarePartnerCard({
    super.key,
    required this.partner,
    this.shape = CarePartnerCardShape.line,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.trailing,
  });

  final CarePartner partner;
  final CarePartnerCardShape shape;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// The home shape only: drawn inside its box after the chevron, where the
  /// slot puts its dismiss so the cross sits in the line, not beside it.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Kept for revert (two shapes, before A1's home line):
    // final body = shape == CarePartnerCardShape.line ? _line() : _full();
    final body = switch (shape) {
      CarePartnerCardShape.line => _line(),
      CarePartnerCardShape.home => _home(),
      CarePartnerCardShape.full => _full(),
    };
    return Padding(
      padding: padding,
      child: onTap == null
          ? body
          : PvPress(enabled: onTap != null, child: GestureDetector(
              onTap: onTap, behavior: HitTestBehavior.opaque, child: body)),
    );
  }

  /// Photo for a person, logo for an organisation, initials when neither has
  /// been uploaded — never a broken image box.
  Widget _avatar(double size) {
    final url = partner.isOrganisation
        ? (partner.logoUrl ?? partner.photoUrl)
        : (partner.photoUrl ?? partner.logoUrl);
    final radius = BorderRadius.circular(partner.isOrganisation ? size * 0.26 : size);
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initials(size, radius),
        ),
      );
    }
    return _initials(size, radius);
  }

  Widget _initials(double size, BorderRadius radius) {
    final letters = partner.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && RegExp('[A-Za-z]').hasMatch(w[0]))
        // "Dr" tells you nothing; the name does.
        .where((w) => w.toLowerCase() != 'dr' && w.toLowerCase() != 'dr.')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: ppPanel, borderRadius: radius),
      child: Text(letters.isEmpty ? '?' : letters,
          style: ppJakarta(size * 0.34, color: ppPurple)),
    );
  }

  /// The home line. 46pt tall at the default text size: a 30pt avatar inside
  /// 8pt of padding, the same rhythm as the lockup pill beside it in the
  /// storyboard. Both lines are single and ellipsised, so a long clinic name
  /// can never push the hero down.
  Widget _home() => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: ppBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppLine),
        ),
        child: Row(children: [
          _avatar(30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${careLineLabel(partner)} · ${partner.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ppJakarta(12.5, color: ppInk)),
                if (careLineDetail(partner).isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(careLineDetail(partner),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ppBody(11.5, color: ppSoft, h: 1.3)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ppSoft),
          ?trailing,
        ]),
      );

  Widget _line() => Row(children: [
        _avatar(28),
        const SizedBox(width: 10),
        Flexible(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              TextSpan(
                  text: '${partner.trust.safePrimary} ',
                  style: ppBody(12, color: ppSoft)),
              TextSpan(text: partner.name, style: ppJakarta(12.5)),
            ]),
          ),
        ),
      ]);

  Widget _full() => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _avatar(46),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner.trust.safePrimary.toUpperCase(),
                        style: ppJakarta(9.5, color: ppSoft)),
                    const SizedBox(height: 3),
                    Text(partner.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ppJakarta(15)),
                    if (partner.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(partner.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ppBody(11.5)),
                    ],
                  ]),
            ),
            if (partner.status == PartnerStatus.active)
              const Icon(Icons.verified_rounded, size: 17, color: ppPurple),
          ]),
          if (partner.trust.shortWelcome.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              decoration: BoxDecoration(
                  color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Text(partner.trust.shortWelcome,
                  style: ppBody(12.5, h: 1.5)),
            ),
          ],
        ]),
      );
}
