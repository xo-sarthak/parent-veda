// =============================================================================
//  CareOrgStore — an IVF centre's numbers in ParentVeda Partners (P3)
// -----------------------------------------------------------------------------
//  ONE server call, care_org_dashboard() (0139), which takes no parameter and
//  finds the centre through my_partner_org() itself, the same resolver that
//  opened this app. So the name on the header and the numbers under it can
//  never belong to two different partners.
//
//  WHY NOT PartnerDashboardStore. That store feeds ParentVeda+ and resolves
//  its partner through my_care_partner(), which since 0132 prefers the
//  person's OWN practice (Route B). A centre manager who is also a doctor
//  with her own practice would have seen the centre's name above her solo
//  practice's numbers. Different question, different store.
//
//  A RENDERER'S STORE. Nothing is counted here. Behaviour arrives as null when
//  the server held it back (below its min_cohort), and stays null: a "—" on
//  the screen, never a 0. No family is ever in the answer.
//
//  NOT CACHED, as SponsorAdminStore: a desk task worth a network call, and
//  numbers about other people's families do not belong on a phone's disk.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../care_partner/partner_dashboard_store.dart' show PartnerEarningRow;
import '../services/remote/supabase_repo.dart';

/// One row of the per-doctor table. A doctor's name (the centre's own staff),
/// a count and a day. Never a family.
@immutable
class CareOrgDoctorRow {
  const CareOrgDoctorRow({
    required this.who,
    required this.name,
    required this.families,
    this.latestOn,
  });

  /// doctor | former | centre (0139). Identity: switched on, never shown.
  final String who;
  final String name;
  final int families;

  /// The day the latest family joined through this code. A day on purpose.
  final DateTime? latestOn;

  bool get isCentre => who == 'centre';
  bool get isFormer => who == 'former';

  static CareOrgDoctorRow fromMap(Map d) => CareOrgDoctorRow(
    who: (d['who'] ?? 'doctor').toString(),
    name: (d['name'] ?? '').toString().trim(),
    families: (d['families'] as num?)?.toInt() ?? 0,
    latestOn: DateTime.tryParse((d['latest_on'] ?? '').toString()),
  );
}

/// The whole answer of care_org_dashboard().
@immutable
class CareOrgDashboard {
  const CareOrgDashboard({
    required this.minCohort,
    required this.suppressed,
    this.families = 0,
    this.scanned = 0,
    this.installed = 0,
    this.signedUp = 0,
    this.active30d = 0,
    this.activated,
    this.pregnancies,
    this.children,
    this.consultations,
    this.vaccinations,
    this.contentRead,
    this.earnings = const [],
    this.doctors = const [],
  });

  /// The server's threshold. Every "shown once…" sentence uses this.
  final int minCohort;
  final bool suppressed;

  // Referral facts: never held back (R3).
  final int families;
  final int scanned;
  final int installed;
  final int signedUp;
  final int active30d;

  // Behaviour: null when held back.
  final int? activated;
  final int? pregnancies;
  final int? children;
  final int? consultations;
  final int? vaccinations;
  final int? contentRead;

  final List<PartnerEarningRow> earnings;
  final List<CareOrgDoctorRow> doctors;

  int get totalEarnedMinor => earnings.fold(0, (a, r) => a + r.partnerMinor);

  /// The centre's listed doctors, without the centre's own code or leavers.
  int get listedDoctors => doctors.where((d) => d.who == 'doctor').length;

  static int _n(Object? v) => (v as num?)?.toInt() ?? 0;
  static int? _opt(Object? v) => (v as num?)?.toInt();

  /// Null when the answer is not a centre's dashboard (ok:false or malformed).
  static CareOrgDashboard? fromMap(Map? m) {
    if (m == null || m['ok'] != true) return null;
    final suppressed = m['suppressed'] == true;
    // Belt and braces: if the server ever says "held back" and still sends a
    // figure, the screen does not show it.
    int? b(Object? v) => suppressed ? null : _opt(v);
    return CareOrgDashboard(
      minCohort: _opt(m['min_cohort']) ?? 5,
      suppressed: suppressed,
      families: _n(m['families']),
      scanned: _n(m['scanned']),
      installed: _n(m['installed']),
      signedUp: _n(m['signed_up']),
      active30d: _n(m['active_30d']),
      activated: b(m['activated']),
      pregnancies: b(m['pregnancies']),
      children: b(m['children']),
      consultations: b(m['consultations']),
      vaccinations: b(m['vaccinations']),
      contentRead: b(m['content_read']),
      earnings: [
        for (final e in (m['earnings'] as List? ?? const []).whereType<Map>())
          PartnerEarningRow.fromMap(e),
      ],
      doctors: [
        for (final d in (m['doctors'] as List? ?? const []).whereType<Map>())
          CareOrgDoctorRow.fromMap(d),
      ],
    );
  }
}

class CareOrgStore extends ChangeNotifier {
  CareOrgStore._();
  static final CareOrgStore instance = CareOrgStore._();

  /// The one server call. A seam so a test can answer for the server without
  /// a mocking framework (PartnerOrgSession.ask is the same idea). Returns
  /// null when nobody is signed in or the backend never started, which must
  /// behave exactly like being logged out.
  @visibleForTesting
  static Future<dynamic> Function() ask = () =>
      SupabaseRepo.rpcJson('care_org_dashboard');

  CareOrgDashboard? _dashboard;
  bool _loading = false;
  bool _everLoaded = false;
  String? _error;

  CareOrgDashboard? get dashboard => _dashboard;
  bool get loading => _loading;
  bool get everLoaded => _everLoaded;

  /// The last load did not reach the server. Whatever was on screen stays.
  String? get error => _error;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ask();
      // ok:false (not a centre, not live) and "not signed in" both land
      // here as null: the tab shows its empty state, which is true.
      _dashboard = CareOrgDashboard.fromMap(res is Map ? res : null);
    } catch (e) {
      debugPrint('[partners] care_org_dashboard failed: $e');
      _error = 'We could not load your numbers just now.';
    }
    _loading = false;
    _everLoaded = true;
    notifyListeners();
  }

  /// Forget the centre. forgetPartnerOrgOnThisPhone() calls it.
  void clear() {
    _dashboard = null;
    _error = null;
    _loading = false;
    _everLoaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void setForTest({CareOrgDashboard? dashboard, String? error}) {
    _dashboard = dashboard;
    _error = error;
    _loading = false;
    _everLoaded = true;
    notifyListeners();
  }
}
