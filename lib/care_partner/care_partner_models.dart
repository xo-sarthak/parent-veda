// =============================================================================
//  Care Partner — the domain
// -----------------------------------------------------------------------------
//  ParentVeda acquires parents through trusted healthcare professionals. A Care
//  Partner is whoever sent a parent here: a paediatrician, a hospital, an IVF
//  centre, a lactation consultant, later an employer or an insurer.
//
//  THREE RULES THAT SHAPE EVERY DECISION BELOW.
//
//  1. PARENTVEDA OWNS THE PARENT RELATIONSHIP. A partner is credited, thanked
//     and paid; they never own the family. Nothing here lets a partner reach
//     into an individual parent's record.
//
//  2. A PARENT MUST NEVER FEEL THEY ARE IN AN AFFILIATE APP. There is no
//     "Sponsored by" anywhere in this module - the vocabulary is "invited by",
//     "your care partner", "connected through". Trust language is CONFIG
//     (TrustMessage below), so it is tuned without a release.
//
//  3. TYPES ARE DATA, NOT CODE. `CarePartnerType` is a string with well-known
//     values rather than an enum, because the spec is explicit that new partner
//     types must be addable from the admin panel without an app release. An
//     enum would make every new type a build.
//
//  DELIBERATELY SEPARATE from the parent-to-parent referral in lib/referral/.
//  That is a joining bonus between two mothers; this is a commercial
//  relationship with a professional, with commission, verification and a
//  permanent attribution. Shared ideas, different products - the user was
//  explicit that they stay apart.
// =============================================================================

import 'package:flutter/foundation.dart';

/// Well-known partner types. NOT an enum: the admin panel must be able to add
/// `corporate_wellness` or `milk_bank` without shipping an app update, so this
/// is a string with constants for the ones we know today.
class CarePartnerType {
  CarePartnerType._();

  static const String doctor = 'doctor';
  static const String hospital = 'hospital';
  static const String clinic = 'clinic';
  static const String diagnosticLab = 'diagnostic_lab';
  static const String ivfCentre = 'ivf_centre';
  static const String nutritionist = 'nutritionist';
  static const String lactationConsultant = 'lactation_consultant';
  static const String psychologist = 'psychologist';
  static const String physiotherapist = 'physiotherapist';
  static const String corporate = 'corporate';
  static const String insurance = 'insurance';

  static const List<String> known = [
    doctor, hospital, clinic, diagnosticLab, ivfCentre, nutritionist,
    lactationConsultant, psychologist, physiotherapist, corporate, insurance,
  ];

  /// Human label. Falls back to a de-slugged version of an unknown type, so a
  /// type added in the admin panel renders sensibly before anyone teaches the
  /// app about it.
  static String label(String type) => switch (type) {
        doctor => 'Doctor',
        hospital => 'Hospital',
        clinic => 'Clinic',
        diagnosticLab => 'Diagnostic Lab',
        ivfCentre => 'IVF Centre',
        nutritionist => 'Nutritionist',
        lactationConsultant => 'Lactation Consultant',
        psychologist => 'Psychologist',
        physiotherapist => 'Physiotherapist',
        corporate => 'Corporate Partner',
        insurance => 'Insurance Partner',
        _ => type
            .split(RegExp('[_-]'))
            .where((w) => w.isNotEmpty)
            .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' '),
      };

  /// Whether this type is an organisation rather than a person. Changes the
  /// language ("your hospital" vs "your doctor") and whether a photo or a logo
  /// is the right image.
  static bool isOrganisation(String type) => const {
        hospital, clinic, diagnosticLab, ivfCentre, corporate, insurance,
      }.contains(type);
}

/// Where a referral physically came from. Every channel resolves through the
/// SAME engine - the spec is emphatic that a QR code is one acquisition
/// channel, not the feature.
enum ReferralChannel {
  qr,
  link,
  whatsapp,
  sms,
  email,
  nfc,
  poster,
  prescription,
  report,
  website,
  manual,
}

extension ReferralChannelX on ReferralChannel {
  String get label => switch (this) {
        ReferralChannel.qr => 'QR code',
        ReferralChannel.link => 'Referral link',
        ReferralChannel.whatsapp => 'WhatsApp',
        ReferralChannel.sms => 'SMS',
        ReferralChannel.email => 'Email',
        ReferralChannel.nfc => 'NFC card',
        ReferralChannel.poster => 'Poster',
        ReferralChannel.prescription => 'Prescription',
        ReferralChannel.report => 'Report',
        ReferralChannel.website => 'Website',
        ReferralChannel.manual => 'Entered by hand',
      };

  static ReferralChannel parse(String? s) => ReferralChannel.values.firstWhere(
        (c) => c.name == s,
        orElse: () => ReferralChannel.link,
      );
}

/// Whether a partner may currently acquire parents at all.
enum PartnerStatus {
  /// Created but not yet checked by a human. Cannot acquire.
  pending,

  /// Verified by ParentVeda. The only status that may acquire.
  active,

  /// Switched off. Existing attribution and ledger history SURVIVE - a partner
  /// going inactive must never orphan the families they already brought.
  inactive,

  /// Refused. Terminal.
  rejected,
}

extension PartnerStatusX on PartnerStatus {
  bool get canAcquire => this == PartnerStatus.active;
  String get label => switch (this) {
        PartnerStatus.pending => 'Awaiting verification',
        PartnerStatus.active => 'Verified',
        PartnerStatus.inactive => 'Not active',
        PartnerStatus.rejected => 'Not approved',
      };
}

/// The words a parent sees. Configurable per partner, because "invited by Dr
/// Rao" and "your hospital" want different tones - and because the one thing
/// this module must never say is "sponsored".
@immutable
class TrustMessage {
  const TrustMessage({
    this.primary = 'Invited by',
    this.secondary = 'Your care partner',
    this.shortWelcome = '',
    this.longWelcome = '',
  });

  /// e.g. "Invited by", "Connected through", "Recommended by".
  final String primary;

  /// e.g. "Your care partner", "Your trusted healthcare partner".
  final String secondary;

  /// One line, shown on a card.
  final String shortWelcome;

  /// A paragraph, shown once on the welcome screen.
  final String longWelcome;

  /// Words this module refuses to render, whatever the admin panel says.
  /// A partner relationship is not an advertisement, and a misconfigured row
  /// must not be able to turn it into one.
  static const List<String> banned = [
    'sponsored', 'advertisement', 'advert', 'promotion', 'promoted', 'ad by',
  ];

  static bool isAllowed(String text) {
    final t = text.toLowerCase();
    return !banned.any(t.contains);
  }

  /// The primary label, with a banned word swapped for the safe default rather
  /// than shown. Failing closed matters more than honouring bad config.
  String get safePrimary => isAllowed(primary) ? primary : 'Invited by';
  String get safeSecondary =>
      isAllowed(secondary) ? secondary : 'Your care partner';

  Map<String, Object?> toMap() => {
        'primary': primary,
        'secondary': secondary,
        'shortWelcome': shortWelcome,
        'longWelcome': longWelcome,
      };

  static TrustMessage fromMap(Map d) => TrustMessage(
        primary: (d['primary'] ?? 'Invited by').toString(),
        secondary: (d['secondary'] ?? 'Your care partner').toString(),
        shortWelcome: (d['shortWelcome'] ?? '').toString(),
        longWelcome: (d['longWelcome'] ?? '').toString(),
      );
}

/// A referral source: whoever sent this parent to ParentVeda.
@immutable
class CarePartner {
  const CarePartner({
    required this.id,
    required this.name,
    required this.type,
    this.status = PartnerStatus.pending,
    this.speciality = '',
    this.organisation = '',
    this.department = '',
    this.logoUrl,
    this.photoUrl,
    this.city = '',
    this.trust = const TrustMessage(),
    this.expertId,
    this.verifiedAt,
  });

  final String id;
  final String name;

  /// One of [CarePartnerType.known], or a new type from the admin panel.
  final String type;
  final PartnerStatus status;

  final String speciality;

  /// The hospital a doctor belongs to, if any. Lets a Care Circle show both
  /// "Dr Rao" and "Fortis" without inventing a second relationship.
  final String organisation;
  final String department;

  final String? logoUrl;
  final String? photoUrl;
  final String city;

  final TrustMessage trust;

  /// Links this partner to an in-app expert account, when the same person also
  /// TAKES consultations. Null for a doctor who only refers.
  ///
  /// This is why partners and experts are separate records that point at each
  /// other rather than one table: a referring paediatrician may never open the
  /// app, and a consulting expert may refer nobody. The doctor app then shows
  /// each of them only what they actually do.
  final String? expertId;

  final DateTime? verifiedAt;

  bool get isOrganisation => CarePartnerType.isOrganisation(type);
  bool get canAcquire => status.canAcquire;

  /// True when this partner also works inside the app (consults, classes), so
  /// the doctor side can show them earnings and appointments as well as impact.
  bool get hasExpertAccount => (expertId ?? '').isNotEmpty;

  String get typeLabel => CarePartnerType.label(type);

  /// "Dr Meera Rao · Paediatrician, Fortis" — whichever parts exist.
  String get subtitle => [
        if (speciality.isNotEmpty) speciality,
        if (organisation.isNotEmpty) organisation,
        if (department.isNotEmpty) department,
      ].join(' · ');

  CarePartner copyWith({
    String? name,
    String? type,
    PartnerStatus? status,
    String? speciality,
    String? organisation,
    String? department,
    String? logoUrl,
    String? photoUrl,
    String? city,
    TrustMessage? trust,
    String? expertId,
    DateTime? verifiedAt,
  }) =>
      CarePartner(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        status: status ?? this.status,
        speciality: speciality ?? this.speciality,
        organisation: organisation ?? this.organisation,
        department: department ?? this.department,
        logoUrl: logoUrl ?? this.logoUrl,
        photoUrl: photoUrl ?? this.photoUrl,
        city: city ?? this.city,
        trust: trust ?? this.trust,
        expertId: expertId ?? this.expertId,
        verifiedAt: verifiedAt ?? this.verifiedAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'status': status.name,
        'speciality': speciality,
        'organisation': organisation,
        'department': department,
        'logoUrl': logoUrl,
        'photoUrl': photoUrl,
        'city': city,
        'trust': trust.toMap(),
        'expertId': expertId,
        'verifiedAt': verifiedAt?.toIso8601String(),
      };

  static CarePartner fromMap(Map d) => CarePartner(
        id: (d['id'] ?? '').toString(),
        name: (d['name'] ?? '').toString(),
        type: (d['type'] ?? CarePartnerType.doctor).toString(),
        status: PartnerStatus.values.firstWhere(
            (s) => s.name == d['status'],
            orElse: () => PartnerStatus.pending),
        speciality: (d['speciality'] ?? '').toString(),
        organisation: (d['organisation'] ?? '').toString(),
        department: (d['department'] ?? '').toString(),
        logoUrl: d['logoUrl']?.toString(),
        photoUrl: d['photoUrl']?.toString(),
        city: (d['city'] ?? '').toString(),
        trust: d['trust'] is Map
            ? TrustMessage.fromMap(d['trust'] as Map)
            : const TrustMessage(),
        expertId: d['expertId']?.toString(),
        verifiedAt: d['verifiedAt'] == null
            ? null
            : DateTime.tryParse(d['verifiedAt'].toString()),
      );
}

/// The permanent record that a parent came from a partner.
///
/// The spec's hardest requirement: attribution must survive reinstall, device
/// change, login change and every future upgrade, and must NEVER be lost. So
/// this is written once on the server and never rewritten - later events append
/// to the timeline instead of mutating this row.
@immutable
class Attribution {
  const Attribution({
    required this.partnerId,
    required this.token,
    required this.channel,
    this.campaignId,
    this.scannedAt,
    this.installedAt,
    this.signedUpAt,
    this.linkedAt,
  });

  final String partnerId;

  /// The referral token that carried it — the thing printed on the QR.
  final String token;
  final ReferralChannel channel;
  final String? campaignId;

  /// The funnel, in order. Each may be null when that step was skipped (a
  /// parent who typed a code never "scanned").
  final DateTime? scannedAt;
  final DateTime? installedAt;
  final DateTime? signedUpAt;

  /// When the parent was permanently bound to this partner. Once set, this
  /// attribution is settled.
  final DateTime? linkedAt;

  bool get isLinked => linkedAt != null;

  Map<String, Object?> toMap() => {
        'partnerId': partnerId,
        'token': token,
        'channel': channel.name,
        'campaignId': campaignId,
        'scannedAt': scannedAt?.toIso8601String(),
        'installedAt': installedAt?.toIso8601String(),
        'signedUpAt': signedUpAt?.toIso8601String(),
        'linkedAt': linkedAt?.toIso8601String(),
      };

  static Attribution fromMap(Map d) => Attribution(
        partnerId: (d['partnerId'] ?? d['partner_id'] ?? '').toString(),
        token: (d['token'] ?? '').toString(),
        channel: ReferralChannelX.parse(d['channel']?.toString()),
        campaignId: (d['campaignId'] ?? d['campaign_id'])?.toString(),
        scannedAt: _date(d['scannedAt'] ?? d['scanned_at']),
        installedAt: _date(d['installedAt'] ?? d['installed_at']),
        signedUpAt: _date(d['signedUpAt'] ?? d['signed_up_at']),
        linkedAt: _date(d['linkedAt'] ?? d['linked_at']),
      );

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}
