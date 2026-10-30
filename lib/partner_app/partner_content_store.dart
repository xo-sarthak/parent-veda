// =============================================================================
//  PartnerContentStore — an organisation's exclusive sessions and offers (P4)
// -----------------------------------------------------------------------------
//  ONE server call, partner_exclusive_content() (0142), which takes no
//  parameter and finds the organisation through my_partner_org(), the
//  resolver that opened this app. Employer, school and IVF centre all read the
//  same answer; the server picks the audience column from the kind.
//
//  READ-ONLY (R9). We write an organisation's sessions and offers (SQL now,
//  Directus later): an hour of a clinician talking to a company's employees is
//  clinical content, and the admin's job is to pass it on, not to edit it.
//
//  BOOKED AND REDEEMED ARE BEHAVIOUR. Each arrives as null below the server's
//  min_cohort (zero included, so a blank never means "someone did") and stays
//  null here: the screen says "Fewer than N", never a number.
//
//  NOT CACHED, as CareOrgStore and SponsorAdminStore: a desk task worth a
//  network call, and nothing about other people belongs on a phone's disk.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../services/remote/supabase_repo.dart';

/// One session written for this organisation's people.
@immutable
class ExclusiveProgramme {
  const ExclusiveProgramme({
    required this.id,
    required this.title,
    required this.kind,
    required this.status,
    this.stage,
    this.firstSession,
    this.lastSession,
    this.booked,
  });

  final String id;
  final String title;

  /// masterclass | cohort | course | … (programmes.kind). Identity.
  final String kind;

  /// scheduled | published | completed (0142 sends only these). Identity.
  final String status;
  final String? stage;
  final DateTime? firstSession;
  final DateTime? lastSession;

  /// Null when held back below min_cohort.
  final int? booked;

  /// Where it sits for the admin, from the status and the dates. The server's
  /// workflow states before 'scheduled' never reach here.
  ExclusiveState stateAt(DateTime now) {
    if (status == 'scheduled') return ExclusiveState.comingSoon;
    if (status == 'completed') return ExclusiveState.finished;
    final last = lastSession;
    if (last != null && last.isBefore(now)) return ExclusiveState.finished;
    return ExclusiveState.open;
  }

  static ExclusiveProgramme fromMap(Map m) => ExclusiveProgramme(
    id: (m['id'] ?? '').toString(),
    title: (m['title'] ?? '').toString().trim(),
    kind: (m['kind'] ?? 'masterclass').toString(),
    status: (m['status'] ?? 'published').toString(),
    stage: m['stage']?.toString(),
    firstSession: DateTime.tryParse((m['first_session_utc'] ?? '').toString()),
    lastSession: DateTime.tryParse((m['last_session_utc'] ?? '').toString()),
    booked: (m['booked'] as num?)?.toInt(),
  );
}

enum ExclusiveState { comingSoon, open, finished }

/// One offer (a programme_coupons row) only this organisation's people can use.
@immutable
class ExclusiveOffer {
  const ExclusiveOffer({
    required this.code,
    required this.kind,
    required this.value,
    required this.active,
    this.programmeTitle,
    this.startsAt,
    this.endsAt,
    this.redeemed,
  });

  /// The code itself. Shown: it is the organisation's own, it works only for
  /// its people, and the admin is the one who passes it on.
  final String code;

  /// percent | flat (paise). Identity.
  final String kind;
  final int value;

  /// Live now: switched on, not past its end, not used up (the server's view).
  final bool active;

  /// Null = any programme.
  final String? programmeTitle;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// Null when held back below min_cohort.
  final int? redeemed;

  bool get isPercent => kind == 'percent';

  static ExclusiveOffer fromMap(Map m) => ExclusiveOffer(
    code: (m['code'] ?? '').toString(),
    kind: (m['kind'] ?? 'percent').toString(),
    value: (m['value'] as num?)?.toInt() ?? 0,
    active: m['active'] == true,
    programmeTitle: (m['programme_title'] as String?)?.trim(),
    startsAt: DateTime.tryParse((m['starts_at'] ?? '').toString()),
    endsAt: DateTime.tryParse((m['ends_at'] ?? '').toString()),
    redeemed: (m['redeemed'] as num?)?.toInt(),
  );
}

/// The whole answer of partner_exclusive_content().
@immutable
class PartnerContent {
  const PartnerContent({
    required this.minCohort,
    this.programmes = const [],
    this.offers = const [],
  });

  /// The server's threshold. Every "Fewer than N" uses this.
  final int minCohort;
  final List<ExclusiveProgramme> programmes;
  final List<ExclusiveOffer> offers;

  bool get isEmpty => programmes.isEmpty && offers.isEmpty;

  /// Null when the answer is not this organisation's content (ok:false).
  static PartnerContent? fromMap(Map? m) {
    if (m == null || m['ok'] != true) return null;
    return PartnerContent(
      minCohort: (m['min_cohort'] as num?)?.toInt() ?? 5,
      programmes: [
        for (final p in (m['programmes'] as List? ?? const []).whereType<Map>())
          ExclusiveProgramme.fromMap(p),
      ],
      offers: [
        for (final o in (m['offers'] as List? ?? const []).whereType<Map>())
          ExclusiveOffer.fromMap(o),
      ],
    );
  }
}

class PartnerContentStore extends ChangeNotifier {
  PartnerContentStore._();
  static final PartnerContentStore instance = PartnerContentStore._();

  /// The one server call. A seam so a test can answer for the server without
  /// a mocking framework (CareOrgStore.ask is the same idea).
  @visibleForTesting
  static Future<dynamic> Function() ask = () =>
      SupabaseRepo.rpcJson('partner_exclusive_content');

  PartnerContent? _content;
  bool _loading = false;
  bool _everLoaded = false;
  String? _error;

  PartnerContent? get content => _content;
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
      // ok:false (not live, not an admin) and "not signed in" both land here
      // as null: the tab shows its empty state.
      _content = PartnerContent.fromMap(res is Map ? res : null);
    } catch (e) {
      debugPrint('[partners] partner_exclusive_content failed: $e');
      _error = 'We could not load your sessions just now.';
    }
    _loading = false;
    _everLoaded = true;
    notifyListeners();
  }

  /// Forget the organisation. forgetPartnerOrgOnThisPhone() calls it.
  void clear() {
    _content = null;
    _error = null;
    _loading = false;
    _everLoaded = false;
    notifyListeners();
  }

  @visibleForTesting
  void setForTest({PartnerContent? content, String? error}) {
    _content = content;
    _error = error;
    _loading = false;
    _everLoaded = true;
    notifyListeners();
  }
}
