// =============================================================================
//  Programme — what HR sees.
// -----------------------------------------------------------------------------
//  Reached from Employer Benefits, and only by someone holding the
//  `sponsor_admin` capability. That is the entitlement architecture doing its
//  job: HR is a user with a capability, not a separate system. No second auth,
//  no middleware, no third codebase — an extra row on the same screen for the
//  two people at the company who administer the programme.
//
//  THIS SCREEN IS A RENDERER, ON PURPOSE. Every number arrives already
//  aggregated from sponsor_dashboard() (0060). None of it is computed here, and
//  the rows behind the numbers never leave the database — which is the
//  difference between a privacy promise and a privacy policy. It is also why a
//  web portal later is a front-end job: the product is the views.
//
//  THE ROSTER IS ELIGIBILITY ONLY. Work email, status, activation date. No
//  name, no user id, no usage, no last-seen. This is the screen where the
//  promise made to the employee is kept or broken, and the aggregate above it
//  can be rich precisely because this stays thin.
//
//  SUPPRESSION IS SHOWN, NOT HIDDEN. Below the configured cohort the server
//  returns null and the UI says why. Rendering null as "0" would turn a policy
//  into a false claim about a company — and a sponsor who reads "0
//  consultations" concludes the benefit is failing, which is the opposite of
//  what the data says.
//
//  TREND, NOT JUST A SNAPSHOT. `sponsor_trend()` (0063) derives monthly history
//  from `activated_at` and `booking_bookings.created_at` — no snapshot table,
//  because both facts already carry the moment they happened and a second copy
//  can drift from the first. Cumulative rather than per-month: per-month
//  activations collapse the instant onboarding finishes, which reads as failure
//  when it is success.
//
//  ⚠️ ENGAGEMENT IS MEASURED NOW, and this comment used to say it never would
//  be. `usage_events` (0065) records session shape per user, and
//  `sponsor_engagement()` exposes monthly totals with the same suppression.
//  The earlier position — do not measure, because the rows are a liability —
//  was wrong: there is no technical reason a per-user measurement cannot be
//  exposed only as an aggregate, which is what this file has always done for
//  consultations. What DOES still hold is that no per-surface breakdown is
//  offered to a sponsor: "your people spend their time in Health" narrows down
//  who is worried about what in a small team. That question is answered for
//  ParentVeda from the raw table, never for the employer.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/sponsor_admin_store.dart';
import '../../services/usage_events.dart';
import '../../theme/app_theme.dart';
import 'enterprise_common.dart';

class SponsorDashboardScreen extends StatefulWidget {
  const SponsorDashboardScreen({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  State<SponsorDashboardScreen> createState() => _SponsorDashboardScreenState();
}

class _SponsorDashboardScreenState extends State<SponsorDashboardScreen> {
  bool _showRemoved = false;

  @override
  void initState() {
    super.initState();
    SponsorAdminStore.instance.refresh();
    UsageEvents.instance.screen(UsageSurface.sponsorProgramme);
  }

  String _p(String en, String hi) => ep(widget.lang, en, hi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(_p('Programme', 'Programme')),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: SponsorAdminStore.instance,
          builder: (context, _) => RefreshIndicator(
            onRefresh: SponsorAdminStore.instance.refresh,
            child: _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final store = SponsorAdminStore.instance;
    final d = store.dashboard;

    if (d == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
        children: [
          if (store.loading && !store.everLoaded)
            const Center(child: CircularProgressIndicator())
          else
            EnterpriseHeading(
              store.error != null
                  ? _p('We could not load your programme.',
                      'आपका प्रोग्राम लोड नहीं हो पाया।')
                  : _p('You do not administer a programme.',
                      'किसी प्रोग्राम की देखरेख का ज़िम्मा आपके पास नहीं है।'),
              sub: store.error != null
                  ? _p('Pull down to try again.',
                      'नीचे खींचकर फिर कोशिश कीजिए।')
                  : _p(
                      'If you handle this benefit for your organisation, ask us '
                          'to give your account access.',
                      'अगर आपकी कंपनी में इस सुविधा का ज़िम्मा आपके पास है, तो हमसे कहिए कि आपके अकाउंट को इसकी पहुँच दी जाए।'),
            ),
        ],
      );
    }

    final active = store.roster.where((r) => r.isActive).toList();
    final removed = store.roster.where((r) => !r.isActive).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(d.sponsorName,
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          d.renewalAt != null
              ? _p('Renews ${_date(d.renewalAt!)}',
                  '${_date(d.renewalAt!)} को नवीनीकरण')
              : _p('No renewal date on file', 'नवीनीकरण की कोई तारीख़ दर्ज नहीं है'),
          style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
        ),
        const SizedBox(height: 18),

        // ---- take-up: the number HR is judged on ---------------------------
        EnterpriseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_p('Take-up', 'Take-up'),
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              // THE DENOMINATOR IS LABELLED, not left to be guessed. When a
              // company sent us a staff list, take-up is out of the people
              // they named; when they did not, it is out of the seats they
              // bought. Those are different numbers and an unlabelled
              // percentage silently means whichever one HR assumed.
              Row(children: [
                _stat(_p('Activated', 'Activated'), '${d.activated}'),
                if (d.denominatorIsRoster)
                  _stat(_p('On your list', 'आपकी सूची में'),
                      '${d.eligibleListed}')
                else
                  _stat(
                    _p('Seats', 'Seats'),
                    d.seatsPurchased == null
                        ? _p('Unlimited', 'Unlimited')
                        : '${d.seatsPurchased}',
                  ),
                _stat(
                  _p('Take-up', 'Take-up'),
                  d.activationRate == null ? '—' : '${d.activationRate}%',
                ),
              ]),
              if (_denominator(d) != null) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (d.activated / _denominator(d)!).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary500),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.denominatorIsRoster
                      ? _p(
                          '${d.eligibleListed - d.activated} of the people you '
                              'listed have not activated yet',
                          'आपकी सूची में से ${d.eligibleListed - d.activated} लोगों ने अभी तक चालू नहीं किया')
                      : _p('${d.seatsLeft ?? 0} seats left',
                          '${d.seatsLeft ?? 0} सीट बाक़ी हैं'),
                  style: t.labelSmall?.copyWith(color: AppTheme.neutral600),
                ),
              ],
              if (d.activatedLast30d > 0) ...[
                const SizedBox(height: 10),
                Text(
                  _p('${d.activatedLast30d} joined in the last 30 days',
                      'पिछले 30 दिनों में ${d.activatedLast30d} लोग जुड़े'),
                  style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
                ),
              ],
              // TREND. "35%" is a number; "35%, up 6 since April" is the
              // sentence HR repeats upward. Rendered only when there is
              // enough history to mean something — three months of nothing
              // dressed as a chart is worse than no chart.
              if (store.trend.length >= 4) ...[
                const SizedBox(height: 16),
                _TrendStrip(points: store.trend, label: _trendLabel(store)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---- usage, or the honest absence of it ----------------------------
        EnterpriseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_p('Consultations', 'Consultations'),
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              if (d.suppressed)
                _suppressedNote(d.minCohort)
              else
                Row(children: [
                  _stat(_p('Booked', 'Booked'), '${d.consultationsBooked ?? 0}'),
                  _stat(_p('Attended', 'Attended'),
                      '${d.consultationsCompleted ?? 0}'),
                  _stat(_p('Upcoming', 'Upcoming'),
                      '${d.consultationsUpcoming ?? 0}'),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---- what we do not measure, said out loud -------------------------
        EnterpriseCard(
          color: AppTheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 17, color: AppTheme.primary600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_p('What this dashboard cannot show',
                      'यह डैशबोर्ड क्या नहीं दिखा सकता'),
                      style:
                          t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 9),
              Text(
                _p(
                    'Nothing about an individual. Not who booked, not what they '
                        'read, not what they asked, not how long they spent in '
                        'the app — we do not measure that last one at all, for '
                        'anyone. Take-up and totals are the whole picture, and '
                        'that is what makes people willing to activate.',
                    'किसी एक व्यक्ति के बारे में कुछ नहीं। किसने बुक किया, किसने क्या पढ़ा, किसने क्या पूछा, किसने ऐप में कितना समय बिताया — आख़िरी वाली बात तो हम किसी के लिए भी नापते ही नहीं। कितने लोगों ने लिया और कुल जोड़ — बस यही पूरी तस्वीर है, और इसी वजह से लोग इसे चालू करने को तैयार होते हैं।'),
                style: t.bodySmall
                    ?.copyWith(color: AppTheme.neutral600, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ---- the roster ----------------------------------------------------
        Row(children: [
          Expanded(
            child: Text(_p('Employees', 'Employees'),
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          if (removed.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _showRemoved = !_showRemoved),
              child: Text(
                _showRemoved
                    ? _p('Hide removed', 'हटाए गए छिपाइए')
                    : _p('Show removed (${removed.length})',
                        'हटाए गए दिखाइए (${removed.length})'),
                style: t.bodySmall?.copyWith(color: AppTheme.primary600),
              ),
            ),
        ]),
        const SizedBox(height: 4),
        Text(
          _p('Eligibility only. Activation is all we record about a person '
              'here.',
              'सिर्फ़ पात्रता। यहाँ किसी व्यक्ति के बारे में हम बस इतना दर्ज करते हैं कि उसने चालू किया या नहीं।'),
          style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
        ),
        const SizedBox(height: 12),

        if (active.isEmpty && !_showRemoved)
          // Never a blank space — the empty state is the feature's
          // advertisement (CLAUDE.md), and here it is also the next action.
          EnterpriseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p('Nobody has activated yet.',
                    'अभी तक किसी ने चालू नहीं किया।'),
                    style:
                        t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _p(
                      'Employees activate inside the app with their work email. '
                          'Sharing that one line is usually all it takes.',
                      'कर्मचारी ऐप के अंदर अपने ऑफ़िस वाले ईमेल से इसे चालू करते हैं। आम तौर पर बस इतनी सी बात बता देना काफ़ी होता है।'),
                  style: t.bodySmall
                      ?.copyWith(color: AppTheme.neutral600, height: 1.45),
                ),
              ],
            ),
          )
        else
          for (final r in [...active, if (_showRemoved) ...removed])
            _rosterRow(r),
      ],
    );
  }

  String _trendLabel(SponsorAdminStore store) {
    final change = store.activationChange3m;
    if (change == null) {
      return _p('Take-up so far', 'अब तक कितने लोगों ने लिया');
    }
    if (change > 0) {
      return _p('Up $change since three months ago',
          'तीन महीने पहले से $change ज़्यादा');
    }
    if (change == 0) {
      return _p('Level with three months ago',
          'तीन महीने पहले जितना ही');
    }
    // Shown as plainly as growth is. A dashboard that only narrates good news
    // is one nobody trusts the good news on either.
    return _p('Down ${-change} since three months ago',
        'तीन महीने पहले से ${-change} कम');
  }

  /// What the progress bar fills toward, or null when there is nothing to
  /// fill toward (no list, unlimited seats). Mirrors the server's choice in
  /// `sponsor_dashboard()` rather than making its own — two places deciding
  /// one denominator is two places to disagree about what a percentage means.
  static int? _denominator(SponsorDashboard d) {
    if (d.denominatorIsRoster) return d.eligibleListed;
    final seats = d.seatsPurchased;
    return (seats == null || seats == 0) ? null : seats;
  }

  Widget _suppressedNote(int min) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_p('Held back until $min people have activated',
              '$min लोगों के चालू करने तक यह नहीं दिखाया जाएगा'),
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            _p(
                'In a small group, "two consultations this month" is close '
                    'enough to a name. We would rather show you nothing than '
                    'show you someone.',
                'छोटे समूह में — इस महीने दो कंसल्टेशन — यह कहना क़रीब-क़रीब नाम बता देने जैसा है। किसी एक इंसान को दिखा देने से बेहतर है कि हम आपको कुछ न दिखाएँ।'),
            style:
                t.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800, color: AppTheme.primary600)),
          const SizedBox(height: 2),
          Text(label,
              style: t.labelSmall?.copyWith(color: AppTheme.neutral600)),
        ],
      ),
    );
  }

  Widget _rosterRow(SponsorMemberRow r) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: EnterpriseCard(
        padding: const EdgeInsets.fromLTRB(15, 13, 9, 13),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.workEmail,
                    style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: r.isActive
                            ? AppTheme.neutral900
                            : AppTheme.neutral400)),
                const SizedBox(height: 3),
                Text(
                  r.isActive
                      ? _p('Activated ${_date(r.activatedAt)}',
                          '${_date(r.activatedAt)} को चालू हुआ')
                      : _p('Removed ${_date(r.removedAt)}',
                          '${_date(r.removedAt)} को हटाया गया'),
                  style: t.labelSmall?.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
          ),
          if (r.isActive)
            IconButton(
              tooltip: _p('Remove', 'हटाइए'),
              icon: const Icon(Icons.person_remove_outlined,
                  size: 19, color: AppTheme.neutral400),
              onPressed: () => _confirmRemove(r),
            ),
        ]),
      ),
    );
  }

  Future<void> _confirmRemove(SponsorMemberRow r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_p('Remove ${r.workEmail}?', '${r.workEmail} को हटाएँ?')),
        content: Text(
          // Say exactly what is lost and what is not. Someone who bought
          // Premium themselves keeps it — that is what `source` on the
          // entitlement was for, and HR should not fear taking it away.
          _p(
              'Their seat is freed and the plan your organisation provides is '
                  'withdrawn. Anything they bought themselves is untouched, and '
                  'their journal, photos and records stay theirs.',
              'उनकी सीट ख़ाली हो जाएगी और आपकी कंपनी का दिया प्लान हट जाएगा। जो उन्होंने ख़ुद ख़रीदा है उसे कुछ नहीं होगा, और उनका जर्नल, तस्वीरें और रिकॉर्ड उनके ही रहेंगे।'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_p('Cancel', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_p('Remove', 'Remove'),
                style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final res = await SponsorAdminStore.instance.removeMember(r.workEmail);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['ok'] == true
          ? _p('${r.workEmail} removed.', '${r.workEmail} हटा दिया गया।')
          : (res['message'] ?? _p('That did not work.', 'यह नहीं हो पाया।'))
              .toString()),
    ));
  }

  static String monthInitial(DateTime d) =>
      const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
          [d.month - 1];

  static String _date(DateTime? d) {
    if (d == null) return '—';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final l = d.toLocal();
    return '${l.day} ${m[l.month - 1]} ${l.year}';
  }
}

/// A twelve-month bar of cumulative take-up.
///
/// CUMULATIVE, NOT PER-MONTH, and the choice matters. Per-month activations
/// look like a collapse the moment a company finishes onboarding — a big first
/// bar and eleven small ones — which reads as the product failing when it is
/// the product having succeeded. Cumulative only ever goes up or flattens, and
/// flattening is the honest signal that take-up has stalled.
///
/// No axes, no gridlines, no numbers on the bars. This is a sparkline whose job
/// is to answer "is the line going up" in one glance; the exact figures are
/// already above it, and repeating them here would just be two places to
/// disagree.
class _TrendStrip extends StatelessWidget {
  const _TrendStrip({required this.points, required this.label});

  final List<SponsorTrendPoint> points;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final peak = points
        .map((p) => p.activatedCumulative)
        .fold<int>(1, (a, b) => b > a ? b : a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: t.labelSmall?.copyWith(
                color: AppTheme.neutral600, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // A floor of 3px so a zero month is still a visible
                          // tick. An invisible bar reads as missing data; a
                          // short one reads as nothing happened, which is what
                          // is true.
                          height: (p.activatedCumulative / peak * 34)
                              .clamp(3.0, 34.0),
                          decoration: BoxDecoration(
                            color: p == points.last
                                ? AppTheme.primary600
                                : AppTheme.primary200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _SponsorDashboardScreenState.monthInitial(p.month),
                          style: t.labelSmall?.copyWith(
                              fontSize: 9, color: AppTheme.neutral400),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
