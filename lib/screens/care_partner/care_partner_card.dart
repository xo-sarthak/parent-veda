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
import '../post_pregnancy/pp_common.dart';

enum CarePartnerCardShape {
  /// A single line — for a content page or the home.
  line,

  /// A card with the photo and welcome — for the welcome moment and Care Circle.
  full,
}

class CarePartnerCard extends StatelessWidget {
  const CarePartnerCard({
    super.key,
    required this.partner,
    this.shape = CarePartnerCardShape.line,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  final CarePartner partner;
  final CarePartnerCardShape shape;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final body = shape == CarePartnerCardShape.line ? _line() : _full();
    return Padding(
      padding: padding,
      child: onTap == null
          ? body
          : GestureDetector(
              onTap: onTap, behavior: HitTestBehavior.opaque, child: body),
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
