// =============================================================================
//  PartnerDashboardStore — the numbers behind the Partner Journey Dashboard
// -----------------------------------------------------------------------------
//  Feeds the doctor-side impact screen, the referral kit and Home's "Families
//  you brought". Everything here is a TOTAL, because every server function it
//  calls (partner_impact, partner_funnel, partner_earnings, and since 0133
//  my_doctor_referrals) returns only counts and sums. There is deliberately no method on this
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
///
/// TWO KINDS (R3, 0141). [familiesReferred] and [activeThisMonth] are referral
/// facts and always arrive. The five behaviour figures are NULL while the
/// partner has fewer than [minCohort] families: with two families,
/// "pregnancies supported: 1" says which patient conceived. Null is "held
/// back", never zero; the screen shows a dash and says why.
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
    this.suppressed = false,
    this.minCohort = 5,
  });

  final int familiesReferred;
  final int activeThisMonth;
  final int? pregnanciesSupported;
  final int? childrenAdded;
  final int? consultationsDone;
  final int? vaccinationsCompleted;
  final int? contentConsumed;

  /// The server held the behaviour figures back (0141).
  final bool suppressed;

  /// The server's threshold, for "shown once N families join".
  final int minCohort;

  bool get isEmpty => familiesReferred == 0 && (childrenAdded ?? 0) == 0;

  static int _n(Object? v) => (v as num?)?.toInt() ?? 0;

  static PartnerImpact fromMap(Map d) {
    final held = d['suppressed'] == true;
    // Null ONLY when the server says it held the figures back, and then even
    // if a figure came with it. A missing column (a server before 0141)
    // still reads as 0, as it always did.
    int? b(Object? v) => held ? null : _n(v);
    return PartnerImpact(
      familiesReferred: _n(d['families_referred']),
      activeThisMonth: _n(d['active_this_month']),
      pregnanciesSupported: b(d['pregnancies_supported']),
      childrenAdded: b(d['children_added']),
      consultationsDone: b(d['consultations_done']),
      vaccinationsCompleted: b(d['vaccinations_completed']),
      contentConsumed: b(d['content_consumed']),
      suppressed: held,
      minCohort: (d['min_cohort'] as num?)?.toInt() ?? 5,
    );
  }
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

  /// Behaviour: null while the partner has fewer families than the server's
  /// threshold (0141), shown as a dash, never a 0.
  final int? activated;

  static PartnerFunnel fromMap(Map d) => PartnerFunnel(
        scanned: (d['scanned'] as num?)?.toInt() ?? 0,
        installed: (d['installed'] as num?)?.toInt() ?? 0,
        signedUp: (d['signed_up'] as num?)?.toInt() ?? 0,
        activated: (d['activated'] as num?)?.toInt(),
      );

  /// Of the families who signed up, how many told us something real about
  /// themselves. The only ratio here worth showing a doctor. Null while
  /// [activated] is held back.
  int? get activationPct {
    final a = activated;
    if (a == null) return null;
    return signedUp == 0 ? 0 : ((a / signedUp) * 100).round();
  }
}

/// "Families you brought" — the signed-in DOCTOR's own slice (0133,
/// my_doctor_referrals). Not the partner's totals: a doctor inside a clinic
/// sees the families from her own code, never the whole clinic's (R4). For a
/// solo doctor the two are the same families, so the numbers agree with
/// [PartnerFunnel.signedUp] and [PartnerImpact.activeThisMonth].
@immutable
class DoctorReferrals {
  const DoctorReferrals({
    this.scanned = 0,
    this.installed = 0,
    this.signedUp = 0,
    this.active30d = 0,
    this.bookedMe = 0,
  });

  final int scanned;
  final int installed;

  /// "Joined" on Home: families who reached an account through her.
  final int signedUp;
  final int active30d;

  /// Of those, how many went on to book HER.
  final int bookedMe;

  bool get isEmpty => signedUp == 0;

  static int _n(Object? v) => (v as num?)?.toInt() ?? 0;

  static DoctorReferrals fromMap(Map d) => DoctorReferrals(
        scanned: _n(d['scanned']),
        installed: _n(d['installed']),
        signedUp: _n(d['signed_up']),
        active30d: _n(d['active_30d']),
        bookedMe: _n(d['booked_me']),
      );
}

class PartnerDashboardStore extends ChangeNotifier {
  PartnerDashboardStore._();
  static final PartnerDashboardStore instance = PartnerDashboardStore._();

  CarePartner? _partner;
  PartnerImpact? _impact;
  PartnerFunnel? _funnel;
  String? _token;
  DoctorReferrals? _referrals;
  List<PartnerEarningRow> _earnings = const [];
  bool _loading = false;
  bool _failed = false;
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

  /// The doctor's own "families you brought" — null until the first answer.
  DoctorReferrals? get referrals => _referrals;
  bool get isLoading => _loading;

  /// The LAST load did not reach the server. Kept apart from "no partner":
  /// "we could not ask" and "you are not set up" need different words, and
  /// the old store collapsed both into the second (DOCTOR-APP.md D2 item 5).
  /// Whatever was on screen before stays there — see the catch in [load].
  bool get loadFailed => _failed;

  /// True once we know this doctor is not a Care Partner at all — the screen
  /// then invites them to become one instead of showing seven zeroes. Never
  /// true after a failed load: not knowing is not the same as "no".
  bool get isNotAPartner =>
      _loadedFor != null && !_loading && !_failed && _partner == null;

  int get totalEarnedMinor =>
      _earnings.fold(0, (a, r) => a + r.partnerMinor);

  /// Load everything for the partner currently signed in.
  ///
  /// [sessionKey] only de-duplicates repeat loads — it is NOT how the partner
  /// is identified. The server answers that, via my_care_partner(). A doctor in
  /// solo practice and a hospital are the same shape here: one care_partners
  /// row, one account, and `expert_id` present only if they also consult.
  Future<void> load(String? sessionKey, {bool force = false}) async {
    if (sessionKey == null || sessionKey.isEmpty) return;
    if (_loading) return;
    if (_loadedFor == sessionKey && !force) return;

    _loading = true;
    notifyListeners();
    try {
      if (SupabaseRepo.isLoggedIn) {
        // ASK THE SERVER WHO WE ARE, rather than matching expert_id here.
        //
        // Matching on expert_id could only ever find a partner that is also a
        // consulting expert, so a hospital, IVF centre or lab — every partner
        // whose expert_id is null by design — resolved to nothing and its
        // dashboard read "not set up yet" permanently. my_care_partner()
        // (0068) resolves either route: a direct partner login, or the expert
        // account of a partner that has one.
        final mine = await SupabaseRepo.callFunction('my_care_partner');
        final row = mine.whereType<Map>().firstOrNull;
        _partner = row == null ? null : CarePartnerStore.partnerFromRow(row);

        // ONE source of truth for what a poster carries, and the server owns
        // it. This used to sort partner_referrals client-side and take the
        // newest active row — which breaks the moment a token is rotated,
        // because a retired token keeps `active` true through its grace
        // window (0069) and would have won that sort. A partner would then
        // be shown, and print, a code that is on its way out.
        //
        // Asked OUTSIDE the partner check since 0133: the answer is the
        // caller's OWN code, and a doctor inside a clinic has one (minted
        // with her expert_id) while my_care_partner() rightly says she owns
        // no partner. Gating it on the partner hid her code from her.
        final tok = await SupabaseRepo.callFunction('my_partner_token');
        final live =
            tok.isEmpty || tok.first == null ? null : '${tok.first}'.trim();
        _token = (live == null || live.isEmpty) ? null : live;

        // Her own slice, outside the check for the same reason. An
        // organisation login gets a row of zeros, which Home never shows.
        final slice = await SupabaseRepo.callFunction('my_doctor_referrals');
        final m = slice.whereType<Map>().firstOrNull;
        _referrals =
            m == null ? const DoctorReferrals() : DoctorReferrals.fromMap(m);

        final id = _partner?.id;
        if (id != null) {
          final impact = await SupabaseRepo.callFunction(
              'partner_impact', {'p_partner_id': id});
          final first = impact.whereType<Map>().firstOrNull;
          _impact = first == null
              ? const PartnerImpact()
              : PartnerImpact.fromMap(first);

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
      } else {
        // Signed out, or a backend that never started — which must behave
        // exactly like signed out. There is nothing to wait for, so Home's
        // card gets an answer (none yet) rather than a bar that never ends.
        _referrals ??= const DoctorReferrals();
      }
      _loadedFor = sessionKey;
      _failed = false;
    } catch (_) {
      // A failed load leaves the previous numbers on screen rather than
      // replacing real figures with zeroes, which would read as "you lost
      // everything" instead of "we could not reach the server". The flag is
      // what lets a screen say the second thing out loud.
      _loadedFor = sessionKey;
      _failed = true;
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
    DoctorReferrals? referrals,
    List<PartnerEarningRow>? earnings,
    bool failed = false,
    String? sessionKey,
  }) {
    _partner = partner;
    _impact = impact;
    _funnel = funnel;
    _token = token;
    _referrals = referrals;
    _earnings = earnings ?? const [];
    _failed = failed;
    // An organisation has no expertId, so key the debug seed off the
    // partner id — otherwise seeding an org left _loadedFor null and the
    // next load() would overwrite the seed.
    _loadedFor = sessionKey ?? partner?.id ?? 'debug';
    _loading = false;
    notifyListeners();
  }

  void reset() {
    _partner = null;
    _impact = null;
    _funnel = null;
    _token = null;
    _referrals = null;
    _earnings = const [];
    _loadedFor = null;
    _loading = false;
    _failed = false;
    notifyListeners();
  }
}
