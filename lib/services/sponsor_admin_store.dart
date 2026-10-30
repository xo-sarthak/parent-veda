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

/// One person on the programme's list, and whether they have activated.
/// Note what is not here: no user id, no pregnancy, no child, no usage. The
/// server does not return those fields, so this class could not carry them
/// even if a screen asked.
///
/// [fullName] is the one exception worth explaining, and it is not one: HR
/// SENT US THESE NAMES on their own staff list (0061). Returning them hands
/// the organisation its data back, not ours. Null for someone who activated
/// by email domain and was never on a list.
@immutable
class SponsorMemberRow {
  const SponsorMemberRow({
    required this.workEmail,
    required this.status,
    this.fullName,
    this.activatedAt,
    this.removedAt,
  });

  final String workEmail;
  final String? fullName;

  /// active | not_activated | removed (sponsor_roster, 0061). Identity:
  /// compared, never shown.
  ///
  /// ⚠️ THREE values, not two. This class was written against 0060's roster,
  /// which returned members only, so "not active" meant "removed". 0061 added
  /// the people on the list who have not started yet, and every screen that
  /// still split the list on [isActive] showed them as Removed, with a "—"
  /// for a date: the follow-up list HR opens the screen for, labelled as the
  /// leavers. Split on the three getters below, never on `!isActive`.
  final String status;
  final DateTime? activatedAt;
  final DateTime? removedAt;

  bool get isActive => status == 'active';
  bool get isNotActivated => status == 'not_activated';
  bool get isRemoved => status == 'removed';

  /// The name HR gave us, or the email when there is none.
  String get displayName {
    final n = fullName?.trim();
    return n == null || n.isEmpty ? workEmail : n;
  }

  static SponsorMemberRow fromMap(Map<String, dynamic> m) {
    final name = m['full_name']?.toString().trim();
    return SponsorMemberRow(
      workEmail: (m['work_email'] ?? '').toString(),
      fullName: name == null || name.isEmpty ? null : name,
      // An unknown status reads as not started: it is the one that claims
      // nothing (neither "using it" nor "taken off").
      status: switch (m['status']) {
        'active' => 'active',
        'removed' => 'removed',
        _ => 'not_activated',
      },
      activatedAt: m['activated_at'] == null
          ? null
          : DateTime.tryParse(m['activated_at'].toString()),
      removedAt: m['removed_at'] == null
          ? null
          : DateTime.tryParse(m['removed_at'].toString()),
    );
  }
}

/// One month of engagement (sponsor_engagement, 0065). Every figure is null
/// when that month's cohort of people who opened the app was below the
/// threshold: the headcount itself is behavioural ("2 people opened it in
/// July"), so it is withheld with the rest. Null is "withheld", never 0.
@immutable
class SponsorEngagementPoint {
  const SponsorEngagementPoint({
    required this.month,
    this.activePeople,
    this.sessions,
    this.avgSessionMin,
  });

  final DateTime month;
  final int? activePeople;
  final int? sessions;
  final double? avgSessionMin;

  bool get withheld => activePeople == null;

  static SponsorEngagementPoint? fromMap(Map<String, dynamic> m) {
    final d = DateTime.tryParse((m['month'] ?? '').toString());
    if (d == null) return null;
    num? n(Object? v) =>
        v == null ? null : (v is num ? v : num.tryParse(v.toString()));
    return SponsorEngagementPoint(
      month: d,
      activePeople: n(m['active_people'])?.toInt(),
      sessions: n(m['sessions'])?.toInt(),
      avgSessionMin: n(m['avg_session_min'])?.toDouble(),
    );
  }
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
    required this.eligibleListed,
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

  /// How many people the organisation actually named on the list they sent
  /// us. 0 when they never sent one and eligibility is by email domain.
  ///
  /// The better denominator when it exists: seats are what a company BOUGHT,
  /// the roster is who they TOLD US ABOUT, and those are not always the same
  /// number. "14 of 40 people" is a sentence HR can act on.
  final int eligibleListed;

  /// What "activation rate" is a percentage OF — so the screen can label it
  /// honestly rather than leaving HR to guess.
  bool get denominatorIsRoster => eligibleListed > 0;
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
      eligibleListed: _i(m['eligible_listed']) ?? 0,
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

/// One month of history. Behavioural fields are null when THAT MONTH's cohort
/// was too small — a stricter test than the dashboard's, because a programme of
/// 40 can still have a month with three people in it.
@immutable
class SponsorTrendPoint {
  const SponsorTrendPoint({
    required this.month,
    required this.activatedInMonth,
    required this.activatedCumulative,
    this.consultationsBooked,
  });

  final DateTime month;
  final int activatedInMonth;
  final int activatedCumulative;
  final int? consultationsBooked;

  static SponsorTrendPoint? fromMap(Map<String, dynamic> m) {
    final d = DateTime.tryParse((m['month'] ?? '').toString());
    if (d == null) return null;
    int? i(Object? v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
    return SponsorTrendPoint(
      month: d,
      activatedInMonth: i(m['activated_in_month']) ?? 0,
      activatedCumulative: i(m['activated_cumulative']) ?? 0,
      consultationsBooked: i(m['consultations_booked']),
    );
  }
}

class SponsorAdminStore extends ChangeNotifier {
  SponsorAdminStore._();
  static final SponsorAdminStore instance = SponsorAdminStore._();

  SponsorDashboard? _dashboard;
  List<SponsorTrendPoint> _trend = const [];
  List<SponsorMemberRow> _roster = const [];
  List<SponsorEngagementPoint> _engagement = const [];
  bool _loading = false;
  bool _everLoaded = false;
  String? _error;

  SponsorDashboard? get dashboard => _dashboard;

  /// Oldest month first. Empty until the first refresh, or when not an admin.
  List<SponsorTrendPoint> get trend => List.unmodifiable(_trend);

  /// The change in take-up against the same figure three months ago — the one
  /// number that turns a snapshot into an argument.
  ///
  /// Null when there is not enough history to say, rather than 0: "no change"
  /// and "we have only been running a month" are different facts, and only one
  /// of them is worth putting on a slide.
  int? get activationChange3m {
    if (_trend.length < 4) return null;
    final now = _trend.last.activatedCumulative;
    final then = _trend[_trend.length - 4].activatedCumulative;
    return now - then;
  }

  List<SponsorMemberRow> get roster => List.unmodifiable(_roster);

  /// Oldest month first, six months. Empty until the first refresh.
  List<SponsorEngagementPoint> get engagement =>
      List.unmodifiable(_engagement);

  /// This calendar month's engagement, or null when it has not loaded. A
  /// loaded month can still be [SponsorEngagementPoint.withheld].
  SponsorEngagementPoint? get thisMonth {
    if (_engagement.isEmpty) return null;
    final now = DateTime.now();
    final last = _engagement.last;
    return last.month.year == now.year && last.month.month == now.month
        ? last
        : null;
  }
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

        // History is a separate call and deliberately not fatal: it is the
        // nice-to-have on this screen, and a sponsor whose trend query fails
        // should still see their take-up rather than an error page.
        try {
          final t = await client.rpc('sponsor_trend', params: {'p_months': 12});
          _trend = ((t as List?) ?? const [])
              .map((e) =>
                  SponsorTrendPoint.fromMap((e as Map).cast<String, dynamic>()))
              .whereType<SponsorTrendPoint>()
              .toList();
        } catch (_) {
          _trend = const [];
        }

        // Engagement (0065), same reasoning: not fatal. Six months, which is
        // what the Partners app shows; the server caps it at 24.
        try {
          final e = await client.rpc(
            'sponsor_engagement',
            params: {'p_months': 6},
          );
          _engagement = ((e as List?) ?? const [])
              .map((x) => SponsorEngagementPoint.fromMap(
                  (x as Map).cast<String, dynamic>()))
              .whereType<SponsorEngagementPoint>()
              .toList();
        } catch (_) {
          _engagement = const [];
        }
      } else {
        _roster = const [];
        _trend = const [];
        _engagement = const [];
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

  /// Forget the programme: the dashboard, the roster of names, the trend.
  /// The Partners app's sign-out (forgetPartnerOrgOnThisPhone) calls it, so
  /// the next organisation to sign in on a shared desk phone never sees the
  /// last one's staff list. Nothing is on disk to clear; it never was.
  void clear() {
    _dashboard = null;
    _roster = const [];
    _trend = const [];
    _engagement = const [];
    _error = null;
    _loading = false;
    _everLoaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void setForTest({
    SponsorDashboard? dashboard,
    List<SponsorMemberRow>? roster,
    List<SponsorTrendPoint>? trend,
    List<SponsorEngagementPoint>? engagement,
    String? error,
  }) {
    _dashboard = dashboard;
    _roster = roster ?? const [];
    _trend = trend ?? const [];
    _engagement = engagement ?? const [];
    _error = error;
    _everLoaded = true;
    _loading = false;
    notifyListeners();
  }
}
