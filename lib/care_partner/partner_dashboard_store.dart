// =============================================================================
//  PartnerDashboardStore — the numbers behind the Partner Journey Dashboard
// -----------------------------------------------------------------------------
//  Feeds the doctor-side impact screen. Everything here is a TOTAL, because the
//  two server functions it calls (partner_impact and partner_earnings, both in
//  0037) return only counts and sums. There is deliberately no method on this
//  store that could return a family, a name or a row — the privacy boundary is
//  enforced in SQL, and this file simply has nothing to enforce it against.
//
//  It caches nothing to disk. Impact numbers that are a week stale would be
//  worse than a spinner: a doctor checking "did the family I referred yesterday
//  arrive?" needs today's answer, and an offline doctor is looking at a screen
//  whose whole point is server-side aggregation anyway.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';
import 'care_partner_models.dart';
import 'care_partner_store.dart';

/// The impact totals. Every field is a count of families or of events across
/// them — never anything identifying.
@immutable
class PartnerImpact {
  const PartnerImpact({
    this.familiesReferred = 0,
    this.activeThisMonth = 0,
    this.pregnanciesSupported = 0,
    this.childrenAdded = 0,
    this.consultationsDone = 0,
    this.vaccinationsCompleted = 0,
    this.contentConsumed = 0,
  });

  final int familiesReferred;
  final int activeThisMonth;
  final int pregnanciesSupported;
  final int childrenAdded;
  final int consultationsDone;
  final int vaccinationsCompleted;
  final int contentConsumed;

  bool get isEmpty => familiesReferred == 0 && childrenAdded == 0;

  static int _n(Object? v) => (v as num?)?.toInt() ?? 0;

  static PartnerImpact fromMap(Map d) => PartnerImpact(
        familiesReferred: _n(d['families_referred']),
        activeThisMonth: _n(d['active_this_month']),
        pregnanciesSupported: _n(d['pregnancies_supported']),
        childrenAdded: _n(d['children_added']),
        consultationsDone: _n(d['consultations_done']),
        vaccinationsCompleted: _n(d['vaccinations_completed']),
        contentConsumed: _n(d['content_consumed']),
      );
}

/// One row of "where the money came from" — a source and a status, with a count
/// and a total. Never a booking, never a parent.
@immutable
class PartnerEarningRow {
  const PartnerEarningRow({
    required this.source,
    required this.status,
    required this.entries,
    required this.partnerMinor,
  });

  final String source; // 'consultation' | 'class' | 'referral' | ...
  final String status; // 'pending' | 'approved' | 'paid' | 'reversed'
  final int entries;
  final int partnerMinor;

  String get sourceLabel => switch (source) {
        'consultation' => 'Consultations',
        'class' => 'Classes & cohorts',
        'referral' => 'Family referrals',
        'subscription' => 'Subscriptions',
        _ => source.isEmpty
            ? 'Other'
            : source[0].toUpperCase() + source.substring(1),
      };

  String get statusLabel => switch (status) {
        'pending' => 'pending',
        'approved' => 'approved',
        'paid' => 'paid out',
        'reversed' => 'reversed',
        _ => status,
      };

  /// Rupees, from paise. Whole rupees — a doctor reading a dashboard does not
  /// need two decimal places, and the ledger keeps the exact minor units.
  String get amountLabel => '₹${(partnerMinor / 100).round()}';

  static PartnerEarningRow fromMap(Map d) => PartnerEarningRow(
        source: (d['source'] ?? '').toString(),
        status: (d['status'] ?? '').toString(),
        entries: (d['entries'] as num?)?.toInt() ?? 0,
        partnerMinor: (d['partner_minor'] as num?)?.toInt() ?? 0,
      );
}

/// The conversion funnel (0039). Counts only, and narrower than it looks:
/// scans are counted for families who eventually signed up, because an
/// anonymous scan that never became anybody is deliberately not recorded
/// anywhere — doing so would mean tracking someone who has agreed to nothing.
@immutable
class PartnerFunnel {
  const PartnerFunnel({
    this.scanned = 0,
    this.installed = 0,
    this.signedUp = 0,
    this.activated = 0,
  });

  final int scanned;
  final int installed;
  final int signedUp;
  final int activated;

  static PartnerFunnel fromMap(Map d) => PartnerFunnel(
        scanned: (d['scanned'] as num?)?.toInt() ?? 0,
        installed: (d['installed'] as num?)?.toInt() ?? 0,
        signedUp: (d['signed_up'] as num?)?.toInt() ?? 0,
        activated: (d['activated'] as num?)?.toInt() ?? 0,
      );

  /// Of the families who signed up, how many told us something real about
  /// themselves. The only ratio here worth showing a doctor.
  int get activationPct =>
      signedUp == 0 ? 0 : ((activated / signedUp) * 100).round();
}

class PartnerDashboardStore extends ChangeNotifier {
  PartnerDashboardStore._();
  static final PartnerDashboardStore instance = PartnerDashboardStore._();

  CarePartner? _partner;
  PartnerImpact? _impact;
  PartnerFunnel? _funnel;
  String? _token;
  List<PartnerEarningRow> _earnings = const [];
  bool _loading = false;
  String? _loadedFor;

  CarePartner? get partner => _partner;
  PartnerImpact? get impact => _impact;
  PartnerFunnel? get funnel => _funnel;

  /// The partner's referral token, READ FROM THE SERVER — never computed.
  ///
  /// Null means no active partner_referrals row exists, and the kit must say
  /// "not set up yet" rather than print something. A derived token used to be
  /// rendered here; it produced a well-formed QR that resolved to nothing,
  /// which is invisible on a poster and permanent once printed.
  String? get token => _token;
  List<PartnerEarningRow> get earnings => _earnings;
  bool get isLoading => _loading;

  /// True once we know this doctor is not a Care Partner at all — the screen
  /// then invites them to become one instead of showing seven zeroes.
  bool get isNotAPartner => _loadedFor != null && !_loading && _partner == null;

  int get totalEarnedMinor =>
      _earnings.fold(0, (a, r) => a + r.partnerMinor);

  /// Load everything for the doctor currently in session.
  ///
  /// [expertId] is the kExperts id from DoctorSession. The care_partners row is
  /// found through its expert_id column — the same person, two roles: someone
  /// who consults inside the app AND brings families to it.
  Future<void> load(String? expertId, {bool force = false}) async {
    if (expertId == null || expertId.isEmpty) return;
    if (_loading) return;
    if (_loadedFor == expertId && !force) return;

    _loading = true;
    notifyListeners();
    try {
      if (SupabaseRepo.isLoggedIn) {
        final rows = await SupabaseRepo.selectAll('care_partners');
        final row = rows
            .whereType<Map>()
            .where((r) => '${r['expert_id']}' == expertId)
            .firstOrNull;
        _partner = row == null ? null : CarePartnerStore.partnerFromRow(row);

        final id = _partner?.id;
        if (id != null) {
          final impact = await SupabaseRepo.callFunction(
              'partner_impact', {'p_partner_id': id});
          final first = impact.whereType<Map>().firstOrNull;
          _impact = first == null
              ? const PartnerImpact()
              : PartnerImpact.fromMap(first);

          // The token comes from the table the website resolves against, so
          // there is exactly one source of truth for what a poster carries.
          final refs = await SupabaseRepo.selectAll('partner_referrals');
          final mine = refs
              .whereType<Map>()
              .where((r) =>
                  '${r['partner_id']}' == id && (r['active'] as bool? ?? true))
              .toList()
            // Newest first: rotating a partner issues a new row, and the most
            // recent one is the one now printed.
            ..sort((a, b) =>
                '${b['created_at']}'.compareTo('${a['created_at']}'));
          _token = mine.isEmpty ? null : '${mine.first['token']}';

          final funnel = await SupabaseRepo.callFunction(
              'partner_funnel', {'p_partner_id': id});
          final f = funnel.whereType<Map>().firstOrNull;
          _funnel = f == null ? const PartnerFunnel() : PartnerFunnel.fromMap(f);

          final earn = await SupabaseRepo.callFunction(
              'partner_earnings', {'p_partner_id': id});
          _earnings = earn
              .whereType<Map>()
              .map(PartnerEarningRow.fromMap)
              .toList()
            // Biggest contribution first — that is the question being asked.
            ..sort((a, b) => b.partnerMinor.compareTo(a.partnerMinor));
        }
      }
      _loadedFor = expertId;
    } catch (_) {
      // A failed load leaves the previous numbers on screen rather than
      // replacing real figures with zeroes, which would read as "you lost
      // everything" instead of "we could not reach the server".
      _loadedFor = expertId;
    }
    _loading = false;
    notifyListeners();
  }

  @visibleForTesting
  void debugSeed({
    CarePartner? partner,
    PartnerImpact? impact,
    PartnerFunnel? funnel,
    String? token,
    List<PartnerEarningRow>? earnings,
  }) {
    _partner = partner;
    _impact = impact;
    _funnel = funnel;
    _token = token;
    _earnings = earnings ?? const [];
    _loadedFor = partner?.expertId ?? 'debug';
    _loading = false;
    notifyListeners();
  }

  void reset() {
    _partner = null;
    _impact = null;
    _funnel = null;
    _token = null;
    _earnings = const [];
    _loadedFor = null;
    _loading = false;
    notifyListeners();
  }
}
