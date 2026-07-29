// =============================================================================
//  SponsorAdminStore — the HR half. Numbers, never people.
// -----------------------------------------------------------------------------
//  Reads sponsor_dashboard() and sponsor_roster() (migration 0060). Both are
//  security-definer functions that resolve the company from auth.uid(), so
//  there is no sponsor id anywhere in this file — nothing for a modified client
//  to change, and no shape of these calls that answers about another customer.
//
//  WHY THE AGGREGATION IS NOT DONE HERE. Every number could be computed in Dart
//  from rows, and that would be the version that leaks: to compute "how many
//  consultations" the client would first have to HOLD the consultations. The
//  database returns a count and never the rows behind it, so the privacy
//  promise survives a curious engineer, a debug build and a proxy.
//
//  It is also why a web portal later is a front-end job rather than a rebuild —
//  the product is the views, and this class is a thin reader over them.
//
//  SUPPRESSION. Below the configured cohort the server returns null for
//  behavioural figures and sets `suppressed`. Null is not zero, and the UI must
//  not render it as one: "0 consultations" is a claim about a company, while
//  "withheld" is a statement about a policy. Only one of those is true.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// One employee's ELIGIBILITY. Note what is not here: no user id, no name, no
/// pregnancy, no child, no usage. The server does not return those fields, so
/// this class could not carry them even if a screen asked.
@immutable
class SponsorMemberRow {
  const SponsorMemberRow({
    required this.workEmail,
    required this.status,
    this.activatedAt,
    this.removedAt,
  });

  final String workEmail;
  final String status; // active | removed
  final DateTime? activatedAt;
  final DateTime? removedAt;

  bool get isActive => status == 'active';

  static SponsorMemberRow fromMap(Map<String, dynamic> m) => SponsorMemberRow(
        workEmail: (m['work_email'] ?? '').toString(),
        status: (m['status'] ?? 'active').toString(),
        activatedAt: m['activated_at'] == null
            ? null
            : DateTime.tryParse(m['activated_at'].toString()),
        removedAt: m['removed_at'] == null
            ? null
            : DateTime.tryParse(m['removed_at'].toString()),
      );
}

/// The dashboard, as the server computed it.
@immutable
class SponsorDashboard {
  const SponsorDashboard({
    required this.sponsorId,
    required this.sponsorName,
    required this.kind,
    required this.activated,
    required this.removed,
    required this.activatedLast30d,
    required this.suppressed,
    required this.minCohort,
    this.seatsPurchased,
    this.seatsLeft,
    this.activationRate,
    this.renewalAt,
    this.consultationsBooked,
    this.consultationsCompleted,
    this.consultationsUpcoming,
  });

  final String sponsorId;
  final String sponsorName;
  final String kind;

  // Commercial facts about a contract the sponsor signed. Never withheld —
  // refusing to tell a customer how many of their own seats are used would be
  // absurd, and none of it is behaviour.
  final int? seatsPurchased; // null = unlimited
  final int activated;
  final int removed;
  final int activatedLast30d;
  final int? seatsLeft;
  final int? activationRate; // percent, null when seats are unlimited
  final DateTime? renewalAt;

  // Behaviour. Null when the cohort is too small to be anonymous.
  final bool suppressed;
  final int minCohort;
  final int? consultationsBooked;
  final int? consultationsCompleted;
  final int? consultationsUpcoming;

  static int? _i(Object? v) =>
      v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

  static SponsorDashboard? fromMap(Map<String, dynamic>? m) {
    if (m == null || m['ok'] != true) return null;
    return SponsorDashboard(
      sponsorId: (m['sponsor_id'] ?? '').toString(),
      sponsorName: (m['sponsor_name'] ?? '').toString(),
      kind: (m['kind'] ?? 'employer').toString(),
      seatsPurchased: _i(m['seats_purchased']),
      activated: _i(m['activated']) ?? 0,
      removed: _i(m['removed']) ?? 0,
      activatedLast30d: _i(m['activated_last_30d']) ?? 0,
      seatsLeft: _i(m['seats_left']),
      activationRate: _i(m['activation_rate']),
      renewalAt: m['renewal_at'] == null
          ? null
          : DateTime.tryParse(m['renewal_at'].toString()),
      suppressed: m['suppressed'] == true,
      minCohort: _i(m['min_cohort']) ?? 5,
      consultationsBooked: _i(m['consultations_booked']),
      consultationsCompleted: _i(m['consultations_completed']),
      consultationsUpcoming: _i(m['consultations_upcoming']),
    );
  }
}

class SponsorAdminStore extends ChangeNotifier {
  SponsorAdminStore._();
  static final SponsorAdminStore instance = SponsorAdminStore._();

  SponsorDashboard? _dashboard;
  List<SponsorMemberRow> _roster = const [];
  bool _loading = false;
  bool _everLoaded = false;
  String? _error;

  SponsorDashboard? get dashboard => _dashboard;
  List<SponsorMemberRow> get roster => List.unmodifiable(_roster);
  bool get loading => _loading;
  bool get everLoaded => _everLoaded;
  String? get error => _error;

  /// True once the server has confirmed this user administers a programme.
  bool get isAdmin => _dashboard != null;

  /// NOT cached to SharedPreferences, unlike every other store here.
  ///
  /// The local-first rule exists so a parent on a train still sees her own
  /// journey. It does not apply to a table about other people's take-up: this
  /// is a desk task, it is worth a network call, and writing a roster of
  /// employees to disk on a phone would put the most sensitive rows in the
  /// least protected place. Local-first is a default, not a reflex.
  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      // Uninitialised backend behaves exactly like being logged out.
      _loading = false;
      _everLoaded = true;
      notifyListeners();
      return;
    }

    try {
      final d = await client.rpc('sponsor_dashboard');
      _dashboard = SponsorDashboard.fromMap((d as Map?)?.cast<String, dynamic>());

      if (_dashboard != null) {
        final rows = await client.rpc('sponsor_roster');
        _roster = ((rows as List?) ?? const [])
            .map((e) => SponsorMemberRow.fromMap(
                (e as Map).cast<String, dynamic>()))
            .toList();
      } else {
        _roster = const [];
      }
    } catch (e) {
      _error = 'We could not load your programme just now.';
    }

    _loading = false;
    _everLoaded = true;
    notifyListeners();
  }

  /// Remove a leaver. The server takes only the work email and resolves the
  /// company from the session, so an admin cannot type their way into another
  /// customer's roster.
  Future<Map<String, dynamic>> removeMember(String workEmail) async {
    try {
      final res = await Supabase.instance.client
          .rpc('sponsor_remove_member', params: {'p_work_email': workEmail});
      final map = (res as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{'ok': false, 'code': 'unexpected_response'};
      if (map['ok'] == true) await refresh();
      return map;
    } catch (_) {
      return {
        'ok': false,
        'code': 'network_error',
        'message': 'We could not reach ParentVeda. Check your connection.',
      };
    }
  }

  @visibleForTesting
  void setForTest({SponsorDashboard? dashboard, List<SponsorMemberRow>? roster}) {
    _dashboard = dashboard;
    _roster = roster ?? const [];
    _everLoaded = true;
    _loading = false;
    notifyListeners();
  }
}
