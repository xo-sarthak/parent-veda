// =============================================================================
//  PartnerExclusiveRail — "Only for Northwind Systems families" on every home
// -----------------------------------------------------------------------------
//  Partner Editions A2 (docs/partner-editions/MASTER.md, D1 and D3; storyboard
//  row 2). The first thing on each home's white sheet, for a family whose
//  employer, school, doctor or clinic has sessions only its families can see.
//  Everyone else's sheet is unchanged: with nothing to show this is a
//  zero-size box, so no gap opens where it would have been.
//
//  WHO DECIDES WHAT. The database decides who may SEE a programme (0142's
//  `_audience_ok`, behind the `programmes_published` view), so a session can
//  never leak to another company's families from here. This file only reads
//  WHOSE each row is (`audience_sponsor_id` / `audience_partner_id`) to name
//  the partner, and it names them through PartnerBrand, the one resolver the
//  strip above already uses, so the strip and the rail cannot disagree.
//
//  ONE RAIL, ONE PARTNER. A sponsor's rail wins, the rule PartnerBrand keeps
//  for the strip. A doctor's sessions still sit in Learn, where every
//  programme is; they lead here only when there is no sponsor rail.
//
//  WHAT GOES IN IT (the user, 2026-10-31): the partner's live and recorded
//  programmes, plus, for a sponsor that includes consultations, one card
//  saying how many are left.
//  Kept for revert (A2): "The storyboard's offer card is owed: nothing on
//  the phone reads audience coupons yet (STILL-OPEN §5.1g)."
//  A3 (2026-10-31): the offer card is here, read through 0148's
//  `my_partner_offers()` (PartnerOfferStore). Its words are true today:
//  "15% off …" and "Until 30 Nov", never the storyboard's "Auto-applied",
//  because checkout does not take offers yet (auto-apply is A4). An offer
//  alone is enough for a rail.
//  A4 (2026-10-31): checkout now takes the offer off on the server (0149
//  `_offers_for`, the same rule `my_offer_quote` and `open_payment_order`
//  use), so the card says "Auto-applied", as the storyboard drew it.
//
//  NO PARTNER COLOURS (D1). The storyboard drew these cards in the partner's
//  tint; D1 overrules it, so they are ParentVeda's grey panel with ink text.
//  A doctor is named in words, never drawn as a logo (D3).
//
//  SPACING IS THE HOME'S. Each home passes its own section head and its own
//  gaps, because the three sheets do not share one rhythm (Pregnancy pads its
//  head 22/12, Trying 26 then 14, Parenting 22 then 12). The rail matches each
//  sheet instead of imposing a fourth.
// =============================================================================

import 'package:flutter/material.dart';

import '../care_partner/care_partner_models.dart';
import '../care_partner/care_partner_store.dart';
import '../screens/enterprise/employer_benefits_screen.dart';
import '../screens/post_pregnancy/learning_detail_screen.dart';
import '../screens/post_pregnancy/pp_learning_data.dart';
import '../screens/v2/v2_palette.dart';
import '../services/credits_store.dart';
import '../services/entitlement_store.dart';
import '../services/partner_brand.dart';
import '../services/partner_offer_store.dart';
import '../services/programme_store.dart';
import '../services/sponsor_benefits.dart';
import '../theme/pv_fonts.dart';
import 'pv_feedback.dart' show PvPress;

/// What one home's rail draws: the words, and the cards under them.
@immutable
class PartnerRail {
  const PartnerRail({
    required this.eyebrow,
    required this.title,
    required this.chip,
    required this.programmes,
    this.consultsLeft,
    this.offers = const [],
  });

  final String eyebrow;
  final String title;

  /// The small pill on each programme card ("Northwind Systems only").
  final String chip;
  final List<LearningProgram> programmes;

  /// Consultations still to book under the sponsor's plan, or null when the
  /// plan includes none (no consult card).
  final int? consultsLeft;

  /// The partner's offers (A3), drawn first: an offer is the one card here
  /// with an end date.
  final List<PartnerOffer> offers;

  // Kept for revert (A2): programmes.isEmpty && consultsLeft == null;
  bool get isEmpty =>
      programmes.isEmpty && consultsLeft == null && offers.isEmpty;
}

/// The rail for this family, or null when there is nothing only for them.
/// Pure, so the rule is testable without pumping a home.
PartnerRail? partnerRailFor({
  required PartnerLockupInfo? sponsor,
  required CarePartner? care,
  required List<LearningProgram> programmes,
  int? consultsLeft,
  List<PartnerOffer> offers = const [],
}) {
  bool live(LearningProgram p) => p.status != LearningStatus.completed;

  if (sponsor != null && sponsor.id != null) {
    final mine = [
      for (final p in programmes)
        if (p.audienceSponsorId == sponsor.id && live(p)) p,
    ];
    final school = sponsor.kind == 'school';
    // Pee Safe demo (item 9): a store-QR family. A brand, so the disclosure
    // is the eyebrow ("Presented by"), not "Only for".
    final store = sponsor.kind == 'store';
    final rail = PartnerRail(
      eyebrow: store
          ? 'Presented by ${sponsor.name}'
          : school
          ? 'Only for ${sponsor.name} parents'
          : 'Only for ${sponsor.name} families',
      title: store
          ? 'For ${sponsor.name} store families'
          : school
          ? 'From your school'
          : 'Included with your benefit',
      chip: '${sponsor.name} only',
      programmes: mine,
      consultsLeft: consultsLeft,
      offers: [
        for (final o in offers)
          if (o.isSponsor && o.audienceId == sponsor.id) o,
      ],
    );
    if (!rail.isEmpty) return rail;
  }

  if (care != null) {
    final mine = [
      for (final p in programmes)
        if (p.audiencePartnerId == care.id && live(p)) p,
    ];
    final theirs = [
      for (final o in offers)
        if (!o.isSponsor && o.audienceId == care.id) o,
    ];
    // Kept for revert (A2): if (mine.isEmpty) return null;
    if (mine.isEmpty && theirs.isEmpty) return null;
    final name = care.name.trim();
    final person = !care.isOrganisation;
    return PartnerRail(
      eyebrow: 'From $name',
      title: person ? "For $name's patients" : 'For $name patients',
      chip: person ? "$name's patients" : '$name patients',
      programmes: mine,
      offers: theirs,
    );
  }
  return null;
}

/// The line under a programme's title: when it happens, or how long it is.
String partnerRailMeta(LearningProgram p) {
  if (p.isLive) {
    final when = p.startLabel;
    return (when == null || when.isEmpty) ? 'Live' : 'Live · $when';
  }
  return p.durationLabel.isEmpty ? 'Recorded' : 'Recorded · ${p.durationLabel}';
}

class PartnerExclusiveRail extends StatelessWidget {
  const PartnerExclusiveRail({
    super.key,
    required this.p,
    required this.head,
    this.top = 0,
    this.headGap = 0,
    this.bottom = 0,
  });

  final V2Palette p;

  /// The home's own section head, given the rail's eyebrow and title.
  final Widget Function(String eyebrow, String title) head;

  /// Gaps, drawn only when the rail is: above the head, between the head and
  /// the cards, and under the cards.
  final double top;
  final double headGap;
  final double bottom;

  static const double cardWidth = 150;
  static const double cardMinHeight = 118;

  @override
  Widget build(BuildContext context) {
    // Loaded at launch (main.dart:449); a no-op then, a safety net in tests.
    ProgrammeStore.instance.ensureLoaded();
    PartnerOfferStore.instance.ensureLoaded();
    return ListenableBuilder(
      listenable: Listenable.merge([
        PartnerBrand.instance,
        ProgrammeStore.instance,
        CreditsStore.instance,
        PartnerOfferStore.instance,
      ]),
      builder: (context, _) {
        final ent = EntitlementStore.instance;
        final rail = partnerRailFor(
          sponsor: PartnerBrand.instance.lockup,
          care: CarePartnerStore.instance.partner,
          programmes: ProgrammeStore.instance.all,
          consultsLeft: ent.can(Caps.consultationCredit)
              ? CreditsStore.instance.available
              : null,
          offers: PartnerOfferStore.instance.all,
        );
        if (rail == null) return const SizedBox.shrink();
        return Padding(
          key: const ValueKey('partner_exclusive_rail'),
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              head(rail.eyebrow, rail.title),
              SizedBox(height: headGap),
              _cards(context, rail),
            ],
          ),
        );
      },
    );
  }

  Widget _cards(BuildContext context, PartnerRail rail) {
    // The card widens with large text (to 1.3x), so a title wraps into
    // lines rather than into a sliver of a column. Names are never cut off.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    final width = cardWidth * scale;
    void openBenefits() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'employer'),
        builder: (_) => const EmployerBenefitsScreen(),
      ),
    );
    final cards = <Widget>[
      // A3: the partner's offers. Benefits says the rest.
      // A4: true now: checkout applies the best offer on the server.
      for (final o in rail.offers)
        _Card(
          key: ValueKey('partner_rail_offer_${o.code}'),
          p: p,
          width: width,
          chip: 'Offer',
          title: o.headline,
          // Kept for revert (A3): meta: o.until,
          meta: 'Auto-applied · ${o.until}',
          onTap: openBenefits,
        ),
      if (rail.consultsLeft case final left?)
        _Card(
          key: const ValueKey('partner_rail_consult'),
          p: p,
          width: width,
          chip: '$left of ${SponsorBenefits.consultationsPerActivation} left',
          title: 'Book a consult',
          meta: left > 0 ? 'Included · no charge' : 'All used for now',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'employer'),
              builder: (_) => const EmployerBenefitsScreen(),
            ),
          ),
        ),
      for (final pr in rail.programmes)
        _Card(
          key: ValueKey('partner_rail_${pr.id}'),
          p: p,
          width: width,
          chip: rail.chip,
          title: pr.title,
          meta: partnerRailMeta(pr),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LearningDetailScreen(program: pr),
            ),
          ),
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // 18, the gutter every home's rails use (PvInsightRail).
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              cards[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.p,
    required this.width,
    required this.chip,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final V2Palette p;
  final double width;
  final String chip;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title. $meta. $chip',
    excludeSemantics: true,
    child: PvPress(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: width,
          constraints: const BoxConstraints(
            minHeight: PartnerExclusiveRail.cardMinHeight,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ParentVeda's grey panel, never the partner's tint (D1).
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.ground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  chip,
                  style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: p.ink2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: pvFraunces(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.2,
                  color: p.ink1,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 8),
              Text(
                meta,
                style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: p.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
