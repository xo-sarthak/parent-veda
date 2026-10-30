// =============================================================================
//  PartnerOrgSession — which organisation is signed in to ParentVeda Partners
// -----------------------------------------------------------------------------
//  The Partners app (Partner Editions P1) is for organisations with several
//  people: an employer, a school, an IVF centre with several doctors. Like
//  ParentVeda+, the account IS the identity: signing in proves the email, and
//  the server then says which organisation that email runs, through ONE call,
//  my_partner_org() (0136). Nothing on the phone picks or remembers an
//  organisation; a login whose admin row is removed tonight sees nothing
//  tomorrow.
//
//  WHY ONE RESOLVER AND NOT TWO. A sponsor (employer, school) and a care_org
//  (IVF centre) live in different tables. Asking both from here and deciding
//  on the phone would put the "sponsor wins" rule in Dart, where the web portal
//  could never see it. The server decides; this file only reads the answer.
//
//  FOUR OUTCOMES, NOT A BOOL, for the reason DoctorResolve gave first: "the
//  server said no" and "the server did not answer" need different screens. A
//  timeout must read as unreachable, never as signed out. The fourth,
//  [PartnerResolve.suspended], is an organisation that exists but is not live
//  (a paused contract, one not started, one ended): the person IS an admin,
//  and telling them they are not would send them to the wrong person.
//
//  NOT CACHED. Like SponsorAdminStore, nothing here is written to
//  SharedPreferences: an organisation's identity is a desk-task lookup worth a
//  network call, and an offline phone gets the can't-reach screen, which says
//  so honestly, rather than yesterday's organisation.
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';

/// What [PartnerOrgSession.resolveFromServer] found out.
enum PartnerResolve {
  /// A live organisation; the shell opens.
  resolved,

  /// The server answered and this login is not an organisation's admin, or
  /// nobody is signed in. [PartnerOrgSession.refusal] says what it is instead.
  notAnAdmin,

  /// An organisation, but not live: paused, not started yet, or ended.
  /// [PartnerOrgSession.org] is set so the screen can name it.
  suspended,

  /// No answer in time, or the call failed. Identity UNKNOWN, not absent.
  unreachable,
}

/// The two kinds of organisation the app renders differently.
enum PartnerOrgKind { sponsor, careOrg }

/// The organisation, as my_partner_org() returns it.
class PartnerOrg {
  const PartnerOrg({
    required this.kind,
    required this.id,
    required this.name,
    required this.status,
    this.sponsorKind,
    this.partnerType,
    this.logoUrl,
    this.supportContact,
  });

  final PartnerOrgKind kind;
  final String id;
  final String name;

  /// sponsors.status (pending | active | suspended | ended) or
  /// care_partners.status (pending | active | inactive). Identity: compared,
  /// never shown.
  final String status;

  /// sponsors.kind: employer | school | insurer | ... Free text on the
  /// server, so an unknown value reads as an employer here.
  final String? sponsorKind;

  /// care_partners.type for a care_org (ivf_centre, hospital, ...).
  final String? partnerType;
  final String? logoUrl;

  /// Shown to members; for a sponsor, also the admin's way to ParentVeda.
  final String? supportContact;

  bool get isLive => status == 'active';
  bool get isSchool =>
      kind == PartnerOrgKind.sponsor && sponsorKind == 'school';

  /// The people this organisation brings, in its own words: a school has
  /// parents, an employer has employees, an IVF centre has doctors (no family
  /// is ever named to a care_org; P3).
  String get peopleWord => switch (kind) {
    PartnerOrgKind.careOrg => 'doctors',
    PartnerOrgKind.sponsor => isSchool ? 'parents' : 'employees',
  };

  /// Null when the map is not an organisation (ok:false, or malformed).
  static PartnerOrg? fromMap(Map? m) {
    if (m == null || m['ok'] != true) return null;
    final id = (m['id'] ?? '').toString();
    if (id.isEmpty) return null;
    String? opt(Object? v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    return PartnerOrg(
      kind: m['kind'] == 'care_org'
          ? PartnerOrgKind.careOrg
          : PartnerOrgKind.sponsor,
      id: id,
      name: (m['name'] ?? '').toString(),
      status: (m['status'] ?? '').toString(),
      sponsorKind: opt(m['sponsor_kind']),
      partnerType: opt(m['partner_type']),
      logoUrl: opt(m['logo_url']),
      supportContact: opt(m['support_contact']),
    );
  }
}

class PartnerOrgSession extends ChangeNotifier {
  PartnerOrgSession._();
  static final PartnerOrgSession instance = PartnerOrgSession._();

  /// How long to wait before calling the server unreachable. The doctor
  /// app's number (DoctorSession._resolveDeadline), for the same reason.
  static const _deadline = Duration(seconds: 6);

  /// The one server call. A seam so a test can answer for the server without
  /// a mocking framework (the house has none): assign, run, restore.
  @visibleForTesting
  static Future<dynamic> Function() ask = () =>
      SupabaseRepo.rpcJson('my_partner_org');

  /// Whether a session exists. The same kind of seam, for the same test.
  @visibleForTesting
  static bool Function() signedIn = () => SupabaseRepo.isLoggedIn;

  PartnerOrg? _org;
  String? _refusal;

  /// The organisation this login runs, live or not. Null when not an admin.
  PartnerOrg? get org => _org;

  /// True only for a LIVE organisation: what the shell is gated on.
  bool get active => _org?.isLive ?? false;

  /// When [PartnerResolve.notAnAdmin]: the server's word for what this login
  /// is instead (doctor | parent | not_an_admin | not_signed_in).
  String? get refusal => _refusal;

  Future<PartnerResolve> resolveFromServer() async {
    if (!signedIn()) {
      _set(null, 'not_signed_in');
      return PartnerResolve.notAnAdmin;
    }
    final dynamic res;
    try {
      res = await ask().timeout(_deadline);
    } catch (e) {
      // Named, not swallowed: "not an admin" and "could not ask" must never
      // be the same line in a log, any more than on the screen.
      debugPrint('[partners] my_partner_org failed: $e');
      return PartnerResolve.unreachable;
    }
    final map = res is Map ? res : null;
    if (map == null) {
      // An answer we cannot read is not a "no". Treat it like silence.
      debugPrint('[partners] my_partner_org: unexpected answer $res');
      return PartnerResolve.unreachable;
    }
    final org = PartnerOrg.fromMap(map);
    if (org == null) {
      _set(null, (map['code'] ?? 'not_an_admin').toString());
      return PartnerResolve.notAnAdmin;
    }
    _set(org, null);
    return org.isLive ? PartnerResolve.resolved : PartnerResolve.suspended;
  }

  void _set(PartnerOrg? org, String? refusal) {
    _org = org;
    _refusal = refusal;
    notifyListeners();
  }

  /// Forget the organisation. Called by forgetPartnerOrgOnThisPhone().
  void clear() {
    if (_org == null && _refusal == null) return;
    _set(null, null);
  }

  @visibleForTesting
  void setForTest(PartnerOrg? org) => _set(org, null);
}
