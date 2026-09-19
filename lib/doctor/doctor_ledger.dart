// =============================================================================
//  DoctorLedger — what a doctor has earned, as the SERVER says it
// -----------------------------------------------------------------------------
//  Replaces DoctorEarnings (doctor_earnings.dart, kept for revert), which
//  multiplied bookings by a catalogue price and a Dart constant. Nothing here
//  computes money. The database writes one row per event with the rate frozen
//  in (0084: expert_earnings), groups them into payouts, and answers four
//  questions through SECURITY DEFINER readers gated on my_expert_ids():
//
//     my_earnings_summary(from, to)   what we owe, when, the period by source
//     my_earnings(from, to, source)   the itemised list, counterparty joined
//     my_payouts() / my_payout_items  what was paid, and what each one held
//     my_videos() / my_share_rates()  the films, and today's rates
//
//  LOCAL-FIRST, as everywhere: the last answer for each question is cached
//  in shared_preferences under the expert id, so the Earnings tab opens with
//  numbers and refreshes underneath. A cloud failure keeps the cache; it is
//  never a crash. An uninitialised backend behaves exactly like logged out.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/remote/supabase_repo.dart';

/// The ways a doctor makes money here — the Commercial Terms workbook's
/// rows (0085), in the workbook's order: consultations, live courses,
/// recorded courses, content, products, then referrals. The order is the
/// screen's order.
enum EarningSource { consultation, masterclass, cohort, course, video, article, affiliate, sponsorship, product, referral, other }

/// Which channel brought a sale. A recorded course pays 30% through ours
/// and 55% through the doctor's own code (0085).
enum EarningChannel { platform, ownCode }

extension EarningChannelX on EarningChannel {
  String get wire => this == EarningChannel.ownCode ? 'own_code' : 'platform';
  static EarningChannel parse(String? s) => s == 'own_code' ? EarningChannel.ownCode : EarningChannel.platform;
}

extension EarningSourceX on EarningSource {
  String get label => switch (this) {
        EarningSource.consultation => 'Consultations',
        EarningSource.masterclass => 'Masterclasses',
        EarningSource.cohort => 'Cohorts',
        EarningSource.course => 'Recorded courses',
        EarningSource.video => 'Videos',
        EarningSource.article => 'Articles',
        EarningSource.affiliate => 'Affiliate income',
        EarningSource.sponsorship => 'Brand sponsorship',
        EarningSource.product => 'Products',
        EarningSource.referral => 'Referrals',
        EarningSource.other => 'Other',
      };

  String get singular => switch (this) {
        EarningSource.consultation => 'Consultation',
        EarningSource.masterclass => 'Masterclass',
        EarningSource.cohort => 'Cohort',
        EarningSource.course => 'Recorded course',
        EarningSource.video => 'Video',
        EarningSource.article => 'Article',
        EarningSource.affiliate => 'Affiliate',
        EarningSource.sponsorship => 'Sponsorship',
        EarningSource.product => 'Product',
        EarningSource.referral => 'Referral',
        EarningSource.other => 'Other',
      };

  /// What the parent's side of the receipt is called.
  String get gross => switch (this) {
        EarningSource.consultation => 'Parent paid',
        EarningSource.masterclass => 'Seats sold',
        EarningSource.cohort => 'Seats sold',
        EarningSource.course => 'Course sales',
        EarningSource.video => 'Ad revenue',
        EarningSource.article => 'Ad revenue',
        EarningSource.affiliate => 'Affiliate income',
        EarningSource.sponsorship => 'Sponsorship value',
        EarningSource.product => 'Product sales',
        EarningSource.referral => 'Referral value',
        EarningSource.other => 'Amount',
      };

  /// The empty row's invitation. A feature is never hidden.
  String get emptyLine => switch (this) {
        EarningSource.consultation => 'Nothing yet. Your first consultation appears here.',
        EarningSource.masterclass => 'Nothing yet. Host a masterclass and each seat shows here.',
        EarningSource.cohort => 'Nothing yet. A cohort you lead shows here, seat by seat.',
        EarningSource.course => 'Nothing yet. Sales of a recorded course show here.',
        EarningSource.video => 'No videos yet. Each film made with you appears here with its share.',
        EarningSource.article => 'Nothing yet. Ad revenue on articles validated under your name.',
        EarningSource.affiliate => 'Nothing yet. Affiliate income earned on your content.',
        EarningSource.sponsorship => 'Nothing yet. Brand work where you are the named face.',
        EarningSource.product => 'Nothing yet. Products you endorse or co-develop.',
        EarningSource.referral => 'Nothing yet. Families you refer earn here once a rate is agreed.',
        EarningSource.other => 'Nothing else yet.',
      };

  /// Sources with a second rate through the doctor's own code (0085).
  bool get hasOwnCodeRate => this == EarningSource.course;

  static EarningSource parse(String? s) =>
      EarningSource.values.firstWhere((e) => e.name == s, orElse: () => EarningSource.other);
}

enum EarningStatus { accrued, payable, paid, reversed }

extension EarningStatusX on EarningStatus {
  String get label => switch (this) {
        EarningStatus.accrued => 'Upcoming',
        EarningStatus.payable => 'To be paid',
        EarningStatus.paid => 'Paid',
        EarningStatus.reversed => 'Cancelled',
      };
  static EarningStatus parse(String? s) =>
      EarningStatus.values.firstWhere((e) => e.name == s, orElse: () => EarningStatus.accrued);
}

/// The period selector. `from`/`to` are half-open, local midnight.
enum LedgerPeriod { thisMonth, lastMonth, thisYear, allTime }

extension LedgerPeriodX on LedgerPeriod {
  String get label => switch (this) {
        LedgerPeriod.thisMonth => 'This month',
        LedgerPeriod.lastMonth => 'Last month',
        LedgerPeriod.thisYear => 'This year',
        LedgerPeriod.allTime => 'All time',
      };

  (DateTime, DateTime) range([DateTime? now]) {
    final n = now ?? DateTime.now();
    switch (this) {
      case LedgerPeriod.thisMonth:
        return (DateTime(n.year, n.month), DateTime(n.year, n.month + 1));
      case LedgerPeriod.lastMonth:
        return (DateTime(n.year, n.month - 1), DateTime(n.year, n.month));
      case LedgerPeriod.thisYear:
        return (DateTime(n.year), DateTime(n.year + 1));
      case LedgerPeriod.allTime:
        return (DateTime(2020), DateTime(n.year + 2));
    }
  }
}

class SourceTotal {
  const SourceTotal({required this.source, required this.expertPaise, required this.grossPaise, required this.items, required this.shareBps});
  final EarningSource source;
  final int expertPaise;
  final int grossPaise;
  final int items;
  final int shareBps;

  factory SourceTotal.fromJson(Map j) => SourceTotal(
        source: EarningSourceX.parse(j['source'] as String?),
        expertPaise: (j['expert_paise'] as num?)?.toInt() ?? 0,
        grossPaise: (j['gross_paise'] as num?)?.toInt() ?? 0,
        items: (j['items'] as num?)?.toInt() ?? 0,
        shareBps: (j['share_bps'] as num?)?.toInt() ?? 0,
      );
}

class LedgerSummary {
  const LedgerSummary({
    required this.owedPaise,
    required this.accruedPaise,
    required this.paidPaise,
    required this.lifetimePaise,
    required this.periodPaise,
    required this.periodUpcomingPaise,
    required this.nextPayout,
    required this.bySource,
  });

  /// "We owe you" — payable, not yet in a payout.
  final int owedPaise;
  /// Booked but not yet delivered.
  final int accruedPaise;
  final int paidPaise;
  final int lifetimePaise;
  final int periodPaise;
  final int periodUpcomingPaise;
  final DateTime? nextPayout;
  final List<SourceTotal> bySource;

  static const empty = LedgerSummary(
      owedPaise: 0, accruedPaise: 0, paidPaise: 0, lifetimePaise: 0,
      periodPaise: 0, periodUpcomingPaise: 0, nextPayout: null, bySource: []);

  factory LedgerSummary.fromJson(Map j) => LedgerSummary(
        owedPaise: (j['owed_paise'] as num?)?.toInt() ?? 0,
        accruedPaise: (j['accrued_paise'] as num?)?.toInt() ?? 0,
        paidPaise: (j['paid_paise'] as num?)?.toInt() ?? 0,
        lifetimePaise: (j['lifetime_paise'] as num?)?.toInt() ?? 0,
        periodPaise: (j['period_paise'] as num?)?.toInt() ?? 0,
        periodUpcomingPaise: (j['period_upcoming'] as num?)?.toInt() ?? 0,
        nextPayout: DateTime.tryParse((j['next_payout'] ?? '').toString()),
        bySource: ((j['by_source'] as List?) ?? const [])
            .whereType<Map>()
            .map(SourceTotal.fromJson)
            .toList(growable: false),
      );

  SourceTotal? forSource(EarningSource s) {
    for (final t in bySource) {
      if (t.source == s) return t;
    }
    return null;
  }
}

class EarningRow {
  const EarningRow({
    required this.id,
    required this.source,
    required this.refKind,
    required this.refId,
    required this.title,
    required this.counterparty,
    required this.occurredAt,
    required this.grossPaise,
    required this.shareBps,
    required this.expertPaise,
    required this.platformPaise,
    required this.status,
    required this.payoutId,
    required this.reversalOf,
    required this.note,
    this.channel = EarningChannel.platform,
  });
  final String id;
  final EarningSource source;
  final EarningChannel channel;
  final String refKind;
  final String? refId;
  final String title;
  final String? counterparty;
  final DateTime occurredAt;
  final int grossPaise;
  final int shareBps;
  final int expertPaise;
  final int platformPaise;
  final EarningStatus status;
  final String? payoutId;
  final String? reversalOf;
  final String? note;

  bool get isReversal => reversalOf != null;

  /// The line a list shows: the parent for a consult, the title otherwise.
  String get headline => (counterparty != null && counterparty!.trim().isNotEmpty)
      ? counterparty!
      : title;

  factory EarningRow.fromJson(Map j) => EarningRow(
        id: (j['id'] ?? '').toString(),
        source: EarningSourceX.parse(j['source'] as String?),
        refKind: (j['ref_kind'] ?? 'manual').toString(),
        refId: j['ref_id'] as String?,
        title: (j['title'] ?? '').toString(),
        counterparty: j['counterparty'] as String?,
        occurredAt: DateTime.tryParse((j['occurred_at'] ?? '').toString())?.toLocal() ?? DateTime.now(),
        grossPaise: (j['gross_paise'] as num?)?.toInt() ?? 0,
        shareBps: (j['share_bps'] as num?)?.toInt() ?? 0,
        expertPaise: (j['expert_paise'] as num?)?.toInt() ?? 0,
        platformPaise: (j['platform_paise'] as num?)?.toInt() ?? 0,
        status: EarningStatusX.parse(j['status'] as String?),
        payoutId: j['payout_id'] as String?,
        reversalOf: j['reversal_of'] as String?,
        note: j['note'] as String?,
        channel: EarningChannelX.parse(j['channel'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'source': source.name, 'ref_kind': refKind, 'ref_id': refId,
        'title': title, 'counterparty': counterparty,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'gross_paise': grossPaise, 'share_bps': shareBps,
        'expert_paise': expertPaise, 'platform_paise': platformPaise,
        'status': status.name, 'payout_id': payoutId, 'reversal_of': reversalOf,
        'note': note, 'channel': channel.wire,
      };
}

class Payout {
  const Payout({
    required this.id,
    required this.periodFrom,
    required this.periodTo,
    required this.amountPaise,
    required this.status,
    required this.method,
    required this.reference,
    required this.bankLast4,
    required this.paidAt,
    required this.note,
  });
  final String id;
  final DateTime periodFrom;
  final DateTime periodTo;
  final int amountPaise;
  final String status; // scheduled | processing | paid | failed
  final String method; // manual_neft | razorpay_route
  final String? reference;
  final String? bankLast4;
  final DateTime? paidAt;
  final String? note;

  String get statusLabel => switch (status) {
        'paid' => 'Paid',
        'processing' => 'On its way',
        'scheduled' => 'Scheduled',
        'failed' => 'Failed',
        _ => status,
      };

  String get methodLabel => method == 'razorpay_route' ? 'Razorpay' : 'Bank transfer';

  factory Payout.fromJson(Map j) => Payout(
        id: (j['id'] ?? '').toString(),
        periodFrom: DateTime.tryParse((j['period_from'] ?? '').toString()) ?? DateTime.now(),
        periodTo: DateTime.tryParse((j['period_to'] ?? '').toString()) ?? DateTime.now(),
        amountPaise: (j['amount_paise'] as num?)?.toInt() ?? 0,
        status: (j['status'] ?? 'paid').toString(),
        method: (j['method'] ?? 'manual_neft').toString(),
        reference: j['reference'] as String?,
        bankLast4: j['bank_last4'] as String?,
        paidAt: DateTime.tryParse((j['paid_at'] ?? '').toString())?.toLocal(),
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'period_from': periodFrom.toIso8601String(),
        'period_to': periodTo.toIso8601String(),
        'amount_paise': amountPaise, 'status': status, 'method': method,
        'reference': reference, 'bank_last4': bankLast4,
        'paid_at': paidAt?.toUtc().toIso8601String(), 'note': note,
      };
}

class ExpertVideo {
  const ExpertVideo({required this.id, required this.url, required this.title, required this.shareBps, required this.addedAt});
  final String id;
  final String url;
  final String title;
  final int shareBps;
  final DateTime addedAt;

  factory ExpertVideo.fromJson(Map j) => ExpertVideo(
        id: (j['id'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        shareBps: (j['share_bps'] as num?)?.toInt() ?? 0,
        addedAt: DateTime.tryParse((j['added_at'] ?? '').toString())?.toLocal() ?? DateTime.now(),
      );
  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'title': title, 'share_bps': shareBps, 'added_at': addedAt.toUtc().toIso8601String()};
}

/// Where the money goes. Own-row, private; status is the server's.
class PayoutAccount {
  const PayoutAccount({
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    this.pan,
    this.upiId,
    this.status = 'pending',
    this.reason,
  });
  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String? pan;
  final String? upiId;
  final String status; // pending | verified | rejected
  final String? reason;

  String get last4 => accountNumber.length >= 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber;
  String get masked => '•••• $last4';
  bool get verified => status == 'verified';

  factory PayoutAccount.fromJson(Map j) => PayoutAccount(
        accountName: (j['account_name'] ?? '').toString(),
        accountNumber: (j['account_number'] ?? '').toString(),
        ifsc: (j['ifsc'] ?? '').toString(),
        pan: j['pan'] as String?,
        upiId: j['upi_id'] as String?,
        status: (j['status'] ?? 'pending').toString(),
        reason: j['reason'] as String?,
      );
  Map<String, dynamic> toJson() => {
        'account_name': accountName, 'account_number': accountNumber, 'ifsc': ifsc,
        'pan': pan, 'upi_id': upiId, 'status': status, 'reason': reason,
      };
}

class DoctorLedger extends ChangeNotifier {
  DoctorLedger._();
  static final DoctorLedger instance = DoctorLedger._();

  String? _expertId;
  bool _loaded = false;

  LedgerPeriod _period = LedgerPeriod.thisMonth;
  LedgerPeriod get period => _period;

  LedgerSummary _summary = LedgerSummary.empty;
  LedgerSummary get summary => _summary;

  final Map<String, List<EarningRow>> _rows = {}; // key: period|source
  List<Payout> _payouts = const [];
  List<Payout> get payouts => _payouts;
  final Map<String, List<EarningRow>> _payoutItems = {};
  List<ExpertVideo> _videos = const [];
  List<ExpertVideo> get videos => _videos;
  /// Today's rates by source, for the platform channel; [_ownCodeRates] for
  /// the doctor's own code (0085). Both from my_share_rates().
  Map<EarningSource, int> _rates = const {};
  Map<EarningSource, int> _ownCodeRates = const {};
  Map<EarningSource, int> get rates => _rates;
  PayoutAccount? _account;
  PayoutAccount? get account => _account;
  bool _accountKnown = false;
  /// False until the server has answered once; the attention card must not
  /// nag "add a bank account" on a cache miss.
  bool get accountKnown => _accountKnown;

  bool _busy = false;
  bool get busy => _busy;

  String _key(String s) => 'doctor_ledger_${_expertId ?? 'none'}_$s';

  /// Bind to an expert. Loads the cache immediately, then refreshes.
  Future<void> bind(String? expertId) async {
    if (expertId == _expertId && _loaded) return;
    _expertId = expertId;
    _loaded = true;
    await _loadCache();
    notifyListeners();
    await refresh();
  }

  Future<void> _loadCache() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(_key('summary_${_period.name}'));
      if (s != null) _summary = LedgerSummary.fromJson(jsonDecode(s) as Map);
      final p = sp.getString(_key('payouts'));
      if (p != null) {
        _payouts = (jsonDecode(p) as List).whereType<Map>().map(Payout.fromJson).toList(growable: false);
      }
      final v = sp.getString(_key('videos'));
      if (v != null) {
        _videos = (jsonDecode(v) as List).whereType<Map>().map(ExpertVideo.fromJson).toList(growable: false);
      }
      final r = sp.getString(_key('rates'));
      if (r != null) {
        final m = jsonDecode(r) as Map;
        _rates = {for (final e in m.entries) EarningSourceX.parse(e.key as String): (e.value as num).toInt()};
      }
      final oc = sp.getString(_key('rates_own_code'));
      if (oc != null) {
        final m = jsonDecode(oc) as Map;
        _ownCodeRates = {for (final e in m.entries) EarningSourceX.parse(e.key as String): (e.value as num).toInt()};
      }
      final a = sp.getString(_key('account'));
      if (a != null) _account = PayoutAccount.fromJson(jsonDecode(a) as Map);
    } catch (_) {/* a bad cache is an empty cache */}
  }

  Future<void> _put(String k, Object v) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key(k), jsonEncode(v));
    } catch (_) {}
  }

  Future<void> setPeriod(LedgerPeriod p) async {
    if (p == _period) return;
    _period = p;
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString(_key('summary_${p.name}'));
      _summary = s == null ? LedgerSummary.empty : LedgerSummary.fromJson(jsonDecode(s) as Map);
    } catch (_) {}
    notifyListeners();
    await refreshSummary();
  }

  /// Everything the Earnings tab shows, in one pass. Failures keep the cache.
  Future<void> refresh() async {
    if (!SupabaseRepo.isLoggedIn || _expertId == null) return;
    _busy = true;
    notifyListeners();
    await Future.wait([
      refreshSummary(),
      _refreshPayouts(),
      _refreshVideos(),
      _refreshRates(),
      refreshAccount(),
    ]);
    _busy = false;
    notifyListeners();
  }

  Future<void> refreshSummary() async {
    if (!SupabaseRepo.isLoggedIn) return;
    final (from, to) = _period.range();
    try {
      final res = await SupabaseRepo.callFunction('my_earnings_summary', {
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
      });
      final j = res.isEmpty ? null : res.first;
      if (j is Map) {
        _summary = LedgerSummary.fromJson(j);
        await _put('summary_${_period.name}', j);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ledger] summary failed: $e');
    }
  }

  /// The itemised rows for the current period and one source (null = all).
  List<EarningRow> rowsFor(EarningSource? source) =>
      _rows['${_period.name}|${source?.name ?? 'all'}'] ?? const [];

  Future<void> loadRows(EarningSource? source) async {
    if (!SupabaseRepo.isLoggedIn) return;
    final (from, to) = _period.range();
    final key = '${_period.name}|${source?.name ?? 'all'}';
    try {
      final res = await SupabaseRepo.callFunction('my_earnings', {
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
        'p_source': source?.name,
      });
      _rows[key] = res.whereType<Map>().map(EarningRow.fromJson).toList(growable: false);
      notifyListeners();
    } catch (e) {
      debugPrint('[ledger] rows failed: $e');
    }
  }

  Future<void> _refreshPayouts() async {
    try {
      final res = await SupabaseRepo.callFunction('my_payouts');
      _payouts = res.whereType<Map>().map(Payout.fromJson).toList(growable: false);
      await _put('payouts', _payouts.map((p) => p.toJson()).toList());
    } catch (e) {
      debugPrint('[ledger] payouts failed: $e');
    }
  }

  List<EarningRow> payoutItems(String payoutId) => _payoutItems[payoutId] ?? const [];

  Future<void> loadPayoutItems(String payoutId) async {
    if (!SupabaseRepo.isLoggedIn) return;
    try {
      final res = await SupabaseRepo.callFunction('my_payout_items', {'p_payout_id': payoutId});
      _payoutItems[payoutId] = res.whereType<Map>().map(EarningRow.fromJson).toList(growable: false);
      notifyListeners();
    } catch (e) {
      debugPrint('[ledger] payout items failed: $e');
    }
  }

  Future<void> _refreshVideos() async {
    try {
      final res = await SupabaseRepo.callFunction('my_videos');
      _videos = res.whereType<Map>().map(ExpertVideo.fromJson).toList(growable: false);
      await _put('videos', _videos.map((v) => v.toJson()).toList());
    } catch (e) {
      debugPrint('[ledger] videos failed: $e');
    }
  }

  Future<void> _refreshRates() async {
    try {
      final res = await SupabaseRepo.callFunction('my_share_rates');
      final m = <EarningSource, int>{};
      final oc = <EarningSource, int>{};
      for (final r in res.whereType<Map>()) {
        final src = EarningSourceX.parse(r['source'] as String?);
        final bps = (r['share_bps'] as num?)?.toInt() ?? 0;
        // 0084's my_share_rates had no channel column; treat its rows as
        // platform so the app works against either migration level.
        if (EarningChannelX.parse(r['channel'] as String?) == EarningChannel.ownCode) {
          oc[src] = bps;
        } else {
          m[src] = bps;
        }
      }
      if (m.isNotEmpty) {
        _rates = m;
        _ownCodeRates = oc;
        await _put('rates', {for (final e in m.entries) e.key.name: e.value});
        await _put('rates_own_code', {for (final e in oc.entries) e.key.name: e.value});
      }
    } catch (e) {
      debugPrint('[ledger] rates failed: $e');
    }
  }

  /// Today's rate for a source: the period's frozen rate if it earned, else
  /// the rule in force. So an empty row can still say "80% of what parents pay".
  int rateFor(EarningSource s) => _summary.forSource(s)?.shareBps ?? _rates[s] ?? 0;

  /// The rate through the doctor's own code, where one exists (0085).
  int ownCodeRateFor(EarningSource s) => _ownCodeRates[s] ?? 0;

  Future<void> refreshAccount() async {
    if (!SupabaseRepo.isLoggedIn || _expertId == null) return;
    // selectAll() swallows every failure as an empty list — right for a
    // catalogue, wrong here: a missing table (0084 not yet run) or a dead
    // network would read as "no account" and the Home would nag a doctor to
    // add one they have. Only a real answer, empty or not, is knowledge.
    final rows = await SupabaseRepo.selectAllOrNull('expert_payout_accounts');
    if (rows == null) {
      debugPrint('[ledger] account read failed; keeping the cache');
      return;
    }
    final mine = rows.where((r) => r['expert_id'] == _expertId).toList();
    _account = mine.isEmpty ? null : PayoutAccount.fromJson(mine.first);
    _accountKnown = true;
    if (_account != null) await _put('account', _account!.toJson());
    notifyListeners();
  }

  /// The doctor submits or re-submits their account. The server forces
  /// status back to 'pending' (the with-check), so the local copy says the
  /// same. Returns false when the server refused or was unreachable — the
  /// form must say so rather than pretend.
  Future<bool> savePayoutAccount(PayoutAccount a) async {
    if (!SupabaseRepo.isLoggedIn || _expertId == null) return false;
    final row = {
      'expert_id': _expertId,
      'account_name': a.accountName.trim(),
      'account_number': a.accountNumber.trim(),
      'ifsc': a.ifsc.trim().toUpperCase(),
      'pan': (a.pan ?? '').trim().isEmpty ? null : a.pan!.trim().toUpperCase(),
      'upi_id': (a.upiId ?? '').trim().isEmpty ? null : a.upiId!.trim(),
      'status': 'pending',
      'reason': null,
      'submitted_at': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      final ok = await SupabaseRepo.upsertRowConfirmed(
          'expert_payout_accounts', row, onConflict: 'expert_id');
      if (!ok) return false;
      _account = PayoutAccount(
        accountName: a.accountName.trim(),
        accountNumber: a.accountNumber.trim(),
        ifsc: a.ifsc.trim().toUpperCase(),
        pan: row['pan'],
        upiId: row['upi_id'],
      );
      _accountKnown = true;
      await _put('account', _account!.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ledger] save account failed: $e');
      return false;
    }
  }

  /// Sign-out: forget who we were, keep nothing in memory.
  void clear() {
    _expertId = null;
    _loaded = false;
    _summary = LedgerSummary.empty;
    _rows.clear();
    _payouts = const [];
    _payoutItems.clear();
    _videos = const [];
    _rates = const {};
    _ownCodeRates = const {};
    _account = null;
    _accountKnown = false;
    notifyListeners();
  }
}
