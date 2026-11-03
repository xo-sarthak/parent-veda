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
//
//  A3 (2026-10-31, the user revised A2's "a doctor family's You is
//  unchanged"): two more pieces, below.
//
//  PartnerCareBenefitCard: a doctor's or clinic's benefit, storyboard row 3's
//  doctor variant. WORDS ONLY: no logo, no monogram, no meter (D3). Shown only
//  with a real benefit (an offer, or a session only their patients see),
//  otherwise it takes no room; and only without a sponsor, whose card keeps
//  the slot under the hero (one partner, as for the strip). The benefit is
//  the rail's own rule (`partnerRailFor` with no sponsor), so the card and
//  the doctor's rail on the homes cannot disagree about what she has.
//
//  PartnerBenefitsRow: "Your benefits", ALWAYS shown (a feature is never
//  hidden), last in Your things. Parenting had no way in to Benefits for a
//  parent with no sponsor: its More sheet has no Benefits row, and the old
//  "Employer benefits" row in `_supportRows` sits in a list the live Settings
//  never draws. Its line says what is behind it: the sponsor, the doctor, or
//  the question "Does your employer offer ParentVeda?".
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/enterprise/employer_benefits_screen.dart';
import '../screens/products/pv_store_chrome.dart' show kPvLine, pvStorePalette;
import '../care_partner/care_partner_store.dart';
import '../screens/profile/pv_you_chrome.dart'
    show PvProfileRow, kPvProfileGroupGap, kPvProfileGutter;
import '../screens/ttc/doors/ttc_tab_art.dart';
import '../services/credits_store.dart';
import '../services/entitlement_store.dart';
import '../services/partner_brand.dart';
import '../services/partner_offer_store.dart';
import '../services/programme_store.dart';
import '../services/sponsor_benefits.dart';
import '../theme/pv_fonts.dart';
import 'partner_exclusive_rail.dart' show PartnerRail, partnerRailFor;
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
      PartnerOfferStore.instance,
    ]),
    builder: (context, _) {
      final info = PartnerBrand.instance.lockup;
      if (info == null) return const SizedBox.shrink();
      final ent = EntitlementStore.instance;
      final credits = CreditsStore.instance;
      final consults = ent.can(Caps.consultationCredit);
      const per = SponsorBenefits.consultationsPerActivation;
      final left = credits.available.clamp(0, per);
      // Pee Safe demo (item 9): a store-QR family holds an offer, not a
      // benefit plan, so the card names the offer and discloses the brand.
      final store = info.kind == 'store';
      final copy = store
          ? storeBenefitCopy(
              name: info.name,
              offers: PartnerOfferStore.instance.forSponsor(info.id),
            )
          : partnerBenefitCopy(
              consults: consults,
              left: left,
              per: per,
              validUntil: credits.expiringNext,
              masterclasses: ent.can(Caps.masterclassAccess),
            );
      final eyebrow = store
          ? 'Presented by ${info.name}'
          : 'Your ${info.name} benefit';
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
          label: '$eyebrow. ${copy.$1}. ${copy.$2}',
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
                      // Kept for revert (item 9):
                      //   'Your ${info.name} benefit'.toUpperCase(),
                      eyebrow.toUpperCase(),
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
                    if (consults && !store) ...[
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

/// The benefit card's two lines for a store-QR family (Pee Safe demo, item
/// 9): the first offer, or an invitation when none is held. Pure.
(String, String) storeBenefitCopy({
  required String name,
  required List<PartnerOffer> offers,
}) => offers.isEmpty
    ? ('See what is included', 'From the $name store. Your health details stay private.')
    : (
        offers.first.headline,
        'From the $name store. Your health details stay private.',
      );

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

/// The doctor's or clinic's benefit for this family, or null: the rail's rule
/// with the sponsor left out. Null too when a sponsor holds the slot.
PartnerRail? careBenefitNow() {
  if (PartnerBrand.instance.lockup != null) return null;
  return partnerRailFor(
    sponsor: null,
    care: CarePartnerStore.instance.partner,
    programmes: ProgrammeStore.instance.all,
    offers: PartnerOfferStore.instance.all,
  );
}

/// The card's two lines for a doctor or clinic. Pure, so the wording is
/// testable without a widget.
(String, String) careBenefitCopy({
  required PartnerRail rail,
  required bool person,
}) {
  final n = rail.programmes.length;
  final sessions = n == 1 ? '1 session' : '$n sessions';
  final headline = rail.offers.isNotEmpty
      ? rail.offers.first.headline
      : '$sessions only ${rail.chip} see';
  final things = [
    if (n > 0) 'sessions',
    if (rail.offers.isNotEmpty) rail.offers.length == 1 ? 'offer' : 'offers',
  ].join(' and ');
  final whose = person ? "Your doctor's" : "Your clinic's";
  final verb = (n > 0 || rail.offers.length > 1) ? 'live' : 'lives';
  return (
    headline,
    '$whose $things $verb here. Your health details stay private.',
  );
}

/// "From Dr Meera Rao", what she gets, and the privacy line. Words only (D3).
class PartnerCareBenefitCard extends StatelessWidget {
  const PartnerCareBenefitCard({super.key});

  @override
  Widget build(BuildContext context) {
    PartnerOfferStore.instance.ensureLoaded();
    return ListenableBuilder(
      listenable: Listenable.merge([
        PartnerBrand.instance,
        ProgrammeStore.instance,
        PartnerOfferStore.instance,
      ]),
      builder: (context, _) {
        final rail = careBenefitNow();
        final care = CarePartnerStore.instance.partner;
        if (rail == null || care == null) return const SizedBox.shrink();
        final copy = careBenefitCopy(rail: rail, person: !care.isOrganisation);
        final p = pvStorePalette;
        return Padding(
          key: const ValueKey('partner_care_benefit_card'),
          padding: const EdgeInsets.fromLTRB(
            kPvProfileGutter,
            kPvProfileGroupGap,
            kPvProfileGutter,
            0,
          ),
          child: Semantics(
            button: true,
            label: '${rail.eyebrow}. ${copy.$1}. ${copy.$2}',
            excludeSemantics: true,
            child: PvPress(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openBenefits(context),
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
                        rail.eyebrow.toUpperCase(),
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
}

/// "Your benefits", the always-shown row on You. Its line names what is
/// behind it.
class PartnerBenefitsRow extends StatelessWidget {
  const PartnerBenefitsRow({super.key, required this.tint});

  /// The profile's mark tint.
  final Color tint;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      PartnerBrand.instance,
      ProgrammeStore.instance,
      PartnerOfferStore.instance,
    ]),
    builder: (context, _) {
      final sponsor = PartnerBrand.instance.lockup;
      final care = careBenefitNow() == null
          ? null
          : CarePartnerStore.instance.partner;
      return PvProfileRow(
        key: const ValueKey('pv_profile_benefits'),
        mark: TtcTabArt(mark: TtcTabMark.wallet, tint: tint),
        title: 'Your benefits',
        // Pee Safe demo (item 9): a store-QR brand is disclosed, not "From".
        subtitle: sponsor != null && sponsor.kind == 'store'
            ? 'Presented by ${sponsor.name}'
            : sponsor != null
            ? 'From ${sponsor.name}'
            : care != null
            ? 'From ${care.name.trim()}'
            : 'Does your employer offer ParentVeda?',
        onTap: () => _openBenefits(context),
      );
    },
  );
}

void _openBenefits(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'employer'),
    builder: (_) => const EmployerBenefitsScreen(),
  ),
);
