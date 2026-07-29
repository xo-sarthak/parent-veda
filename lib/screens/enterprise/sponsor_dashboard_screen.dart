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
//  ⚠️ NOT HERE, AND CANNOT BE: average time in the app. It needs a per-user
//  usage event stream this product deliberately does not build — profile_events
//  is anonymous by construction. Telling a sponsor plainly that we do not
//  measure it is better than building the thing we promise not to.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/sponsor_admin_store.dart';
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
                      'Programme load nahi ho paya.')
                  : _p('You do not administer a programme.',
                      'Aap kisi programme ke admin nahi ho.'),
              sub: store.error != null
                  ? _p('Pull down to try again.',
                      'Neeche kheench kar dobara try karo.')
                  : _p(
                      'If you handle this benefit for your organisation, ask us '
                          'to give your account access.',
                      'Agar aap apne organisation ke liye yeh benefit dekhte '
                          'ho, humse apne account ko access dilwa lijiye.'),
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
                  '${_date(d.renewalAt!)} ko renew')
              : _p('No renewal date on file', 'Renewal date file mein nahi hai'),
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
                  _stat(_p('On your list', 'Aapki list mein'),
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
                          'Aapki list ke ${d.eligibleListed - d.activated} log '
                              'abhi tak activate nahi hue')
                      : _p('${d.seatsLeft ?? 0} seats left',
                          '${d.seatsLeft ?? 0} seats bachi hain'),
                  style: t.labelSmall?.copyWith(color: AppTheme.neutral600),
                ),
              ],
              if (d.activatedLast30d > 0) ...[
                const SizedBox(height: 10),
                Text(
                  _p('${d.activatedLast30d} joined in the last 30 days',
                      'Pichhle 30 din mein ${d.activatedLast30d} log jude'),
                  style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
                ),
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
                      'Yeh dashboard kya nahi dikha sakta'),
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
                    'Kisi ek insaan ke baare mein kuch nahi. Kisne book kiya, '
                        'kya padha, kya poocha, kitna time app mein bitaya — '
                        'aakhri wala hum kisi ke liye measure hi nahi karte. '
                        'Take-up aur totals hi poori picture hain, aur isi wajah '
                        'se log activate karte hain.'),
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
                    ? _p('Hide removed', 'Removed chhupao')
                    : _p('Show removed (${removed.length})',
                        'Removed dekho (${removed.length})'),
                style: t.bodySmall?.copyWith(color: AppTheme.primary600),
              ),
            ),
        ]),
        const SizedBox(height: 4),
        Text(
          _p('Eligibility only. Activation is all we record about a person '
              'here.',
              'Sirf eligibility. Kisi bhi insaan ke baare mein bas activation '
                  'record hota hai.'),
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
                    'Abhi kisi ne activate nahi kiya.'),
                    style:
                        t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _p(
                      'Employees activate inside the app with their work email. '
                          'Sharing that one line is usually all it takes.',
                      'Employees app ke andar apni work email se activate karte '
                          'hain. Bas yeh ek line share kar dijiye.'),
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
              '$min log activate karenge tab tak rok rakha hai'),
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            _p(
                'In a small group, "two consultations this month" is close '
                    'enough to a name. We would rather show you nothing than '
                    'show you someone.',
                'Chhote group mein "is mahine do consultations" lagbhag ek naam '
                    'hi hai. Aapko kuch na dikhana behtar hai, kisi ko dikhane '
                    'se.'),
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
                          '${_date(r.activatedAt)} ko activated')
                      : _p('Removed ${_date(r.removedAt)}',
                          '${_date(r.removedAt)} ko removed'),
                  style: t.labelSmall?.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
          ),
          if (r.isActive)
            IconButton(
              tooltip: _p('Remove', 'Remove karo'),
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
        title: Text(_p('Remove ${r.workEmail}?', '${r.workEmail} hatayein?')),
        content: Text(
          // Say exactly what is lost and what is not. Someone who bought
          // Premium themselves keeps it — that is what `source` on the
          // entitlement was for, and HR should not fear taking it away.
          _p(
              'Their seat is freed and the plan your organisation provides is '
                  'withdrawn. Anything they bought themselves is untouched, and '
                  'their journal, photos and records stay theirs.',
              'Unki seat free ho jayegi aur organisation ka diya plan hat '
                  'jayega. Jo unhone khud kharida hai woh waise hi rahega, aur '
                  'unka journal, photos aur records unke hi rahenge.'),
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
          ? _p('${r.workEmail} removed.', '${r.workEmail} hata diya.')
          : (res['message'] ?? _p('That did not work.', 'Yeh nahi hua.'))
              .toString()),
    ));
  }

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
