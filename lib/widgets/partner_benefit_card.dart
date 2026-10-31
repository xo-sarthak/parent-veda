// =============================================================================
//  PartnerYouChip + PartnerBenefitCard — the sponsor on her You page
// -----------------------------------------------------------------------------
//  Partner Editions A2 (MASTER D1; storyboard row 3, "You: the benefit, with a
//  logo and what is left").
//
//  ⚠️ THE OLD CHIP WAS UNREACHABLE. `pv_you_screen.dart` passes
//  `chip: sponsor?.name` to `PvIdentityCard` in three places, but all three
//  stages draw the short profile's `PvProfileHero` since 2026-10-07, which had
//  no chip at all. So before A2 a sponsored parent's You page never named her
//  employer. Those three lines are left as they were (the older layouts are
//  kept for revert); the chip now rides in the hero's `partner` slot.
//
//  THE CHIP: the sponsor's logo, or its monogram in ink when it has none
//  (PartnerMark, the lockup's own), and its name. No partner colours.
//
//  THE CARD: what she has left to use, so the benefit keeps getting used
//  (the storyboard's reason). The numbers are the server's: CreditsStore
//  reads the ledger (0066), the same figure Benefits shows and the one that
//  will still be true when she presses Book. White with a hairline, like
//  every group on this page (D1 overrules the storyboard's partner tint).
//  Taps through to Benefits, route `employer`, the same door as the strip.
//
//  A sponsor only. A doctor is a line on the homes and in the Care Circle,
//  never a brand on her profile (D3).
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/enterprise/employer_benefits_screen.dart';
import '../screens/products/pv_store_chrome.dart' show kPvLine, pvStorePalette;
import '../screens/profile/pv_you_chrome.dart'
    show kPvProfileGroupGap, kPvProfileGutter;
import '../services/credits_store.dart';
import '../services/entitlement_store.dart';
import '../services/partner_brand.dart';
import '../services/sponsor_benefits.dart';
import '../theme/pv_fonts.dart';
import 'partner_lockup.dart' show PartnerMark;
import 'pv_feedback.dart' show PvPress;

/// The sponsor's mark and name, centred under her status line. Nothing
/// without a sponsor.
class PartnerYouChip extends StatelessWidget {
  const PartnerYouChip({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: PartnerBrand.instance,
    builder: (context, _) {
      final info = PartnerBrand.instance.lockup;
      if (info == null) return const SizedBox.shrink();
      final p = pvStorePalette;
      return Padding(
        key: const ValueKey('partner_you_chip'),
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 4, 11, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kPvLine),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PartnerMark(info: info, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  info.name,
                  textAlign: TextAlign.center,
                  style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// "1 of 2 consults left", a meter, and what else is included.
class PartnerBenefitCard extends StatelessWidget {
  const PartnerBenefitCard({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      PartnerBrand.instance,
      CreditsStore.instance,
    ]),
    builder: (context, _) {
      final info = PartnerBrand.instance.lockup;
      if (info == null) return const SizedBox.shrink();
      final ent = EntitlementStore.instance;
      final credits = CreditsStore.instance;
      final consults = ent.can(Caps.consultationCredit);
      const per = SponsorBenefits.consultationsPerActivation;
      final left = credits.available.clamp(0, per);
      final copy = partnerBenefitCopy(
        consults: consults,
        left: left,
        per: per,
        validUntil: credits.expiringNext,
        masterclasses: ent.can(Caps.masterclassAccess),
      );
      final p = pvStorePalette;
      return Padding(
        key: const ValueKey('partner_benefit_card'),
        padding: const EdgeInsets.fromLTRB(
          kPvProfileGutter,
          kPvProfileGroupGap,
          kPvProfileGutter,
          0,
        ),
        child: Semantics(
          button: true,
          label: 'Your ${info.name} benefit. ${copy.$1}. ${copy.$2}',
          excludeSemantics: true,
          child: PvPress(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'employer'),
                  builder: (_) => const EmployerBenefitsScreen(),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kPvLine),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your ${info.name} benefit'.toUpperCase(),
                      style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: p.ink2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.$1,
                      style: pvFraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy.$2,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.45,
                        color: p.ink2,
                      ),
                    ),
                    if (consults) ...[
                      const SizedBox(height: 12),
                      _Meter(
                        fraction: left / per,
                        track: p.surfaceAlt,
                        fill: p.ink1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The card's two lines: the headline and the note under it. Pure, so the
/// wording is testable without a widget.
(String, String) partnerBenefitCopy({
  required bool consults,
  required int left,
  required int per,
  DateTime? validUntil,
  bool masterclasses = false,
}) {
  final also = masterclasses ? 'Masterclasses are included.' : '';
  if (!consults) {
    return (
      'See what is included',
      also.isEmpty ? 'Your benefits, in one place.' : also,
    );
  }
  // "1 of 2 consults left": the count is of the two, so plural either way.
  final headline = '$left of $per consults left';
  final when = (validUntil != null && left > 0)
      ? 'Valid until ${_date(validUntil)}.'
      : (left == 0 ? 'They renew when your company renews.' : '');
  final note = [when, also].where((s) => s.isNotEmpty).join(' ');
  return (
    headline,
    note.isEmpty ? 'Book with any ParentVeda doctor or counsellor.' : note,
  );
}

String _date(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) => ClipRRect(
    key: const ValueKey('partner_benefit_meter'),
    borderRadius: BorderRadius.circular(9),
    child: SizedBox(
      height: 6,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: track),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: ColoredBox(color: fill),
          ),
        ],
      ),
    ),
  );
}
