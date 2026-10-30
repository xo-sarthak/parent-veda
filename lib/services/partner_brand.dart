// =============================================================================
//  PartnerBrand — which partner, if any, a family's homes should name
// -----------------------------------------------------------------------------
//  Partner Editions A1 (docs/partner-editions/MASTER.md, decisions D1 and D3).
//  The app already knows two kinds of partner, held by two stores that never
//  had a reason to talk to each other:
//
//    · a SPONSOR (employer or school) pays for her benefit. EntitlementStore
//      holds it, and only after she activates with a work-email code.
//    · a CARE PARTNER (a doctor, an IVF centre, a lactation consultant)
//      introduced her. CarePartnerStore holds it, from a QR or a link.
//
//  This is the one place that turns those two into one answer for the homes,
//  so the three stages cannot drift into three different rules.
//
//  THE RULE, AND WHY IT IS NOT SYMMETRIC (D3). A sponsor gets a LOCKUP,
//  "ParentVeda × Northwind": a contract, a benefit she holds, the same shape a
//  co-branded edition takes anywhere. A care partner gets a LINE, "Your doctor
//  · Dr Meera Rao": a clinician is a person in her care, not a brand on her
//  app, and drawing a doctor as a logo would make the relationship read as an
//  advert. When both exist the sponsor's lockup takes the strip; the doctor
//  stays in the Care Circle and on the topic pages, where she already is.
//
//  WHAT IT DOES NOT DO. No colours (D1: a partner colours nothing), no
//  navigation, and no visibility rules for the doctor line: those stay in
//  CareVisibility, where every other placement of a care partner is decided.
//  This class says WHO; CarePartnerSlot still says WHETHER, today.
//
//  The trade-off of a derived singleton over a widget that reads both stores:
//  one more class to know about, but the decision is testable without pumping
//  a home, and A2's rail and You chip read the same answer.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../care_partner/care_partner_models.dart';
import '../care_partner/care_partner_store.dart';
import 'entitlement_store.dart';

/// What the lockup needs to draw: a name and, when the sponsor uploaded one, a
/// logo. Kept apart from [SponsorInfo] so the widget does not depend on the
/// entitlement plumbing.
@immutable
class PartnerLockupInfo {
  const PartnerLockupInfo({
    required this.name,
    this.logoUrl,
    this.kind = 'employer',
  });

  final String name;
  final String? logoUrl;

  /// 'employer' | 'school' | … as `my_sponsor()` returns it.
  final String kind;
}

class PartnerBrand extends ChangeNotifier {
  PartnerBrand._() {
    // Both stores outlive every screen, so the listeners are never removed.
    EntitlementStore.instance.addListener(notifyListeners);
    CarePartnerStore.instance.addListener(notifyListeners);
  }
  static final PartnerBrand instance = PartnerBrand._();

  /// The co-brand lockup, or null. Only a sponsor owns one (D1, D3).
  PartnerLockupInfo? get lockup {
    final s = EntitlementStore.instance.sponsor;
    if (s == null || s.name.trim().isEmpty) return null;
    final logo = s.logoUrl?.trim();
    return PartnerLockupInfo(
      name: s.name.trim(),
      logoUrl: (logo == null || logo.isEmpty) ? null : logo,
      kind: s.kind,
    );
  }

  /// The care partner whose "Your doctor" line may sit on the homes, or null.
  /// Null whenever a lockup exists: one strip, one partner.
  CarePartner? get careLine =>
      lockup != null ? null : CarePartnerStore.instance.partner;

  /// True when the homes have anything to draw at all.
  bool get hasAny => lockup != null || careLine != null;
}

/// "Your doctor", "Your clinic"… — how a family names the partner who looks
/// after her. A person by their role, an organisation by the place.
String careLineLabel(CarePartner partner) => switch (partner.type) {
  CarePartnerType.doctor => 'Your doctor',
  CarePartnerType.ivfCentre || CarePartnerType.clinic => 'Your clinic',
  CarePartnerType.hospital => 'Your hospital',
  CarePartnerType.diagnosticLab => 'Your lab',
  CarePartnerType.nutritionist => 'Your nutritionist',
  CarePartnerType.lactationConsultant => 'Your lactation consultant',
  CarePartnerType.psychologist => 'Your psychologist',
  CarePartnerType.physiotherapist => 'Your physiotherapist',
  _ => 'Your care partner',
};

/// The quieter second line under the name: where a person works, or the city
/// an organisation is in. Empty when we hold neither.
String careLineDetail(CarePartner partner) {
  if (!partner.isOrganisation && partner.organisation.trim().isNotEmpty) {
    return partner.organisation.trim();
  }
  return partner.city.trim();
}
