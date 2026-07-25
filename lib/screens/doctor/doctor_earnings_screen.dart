// =============================================================================
//  DoctorEarningsScreen — the doctor's money view
// -----------------------------------------------------------------------------
//  Real numbers from real bookings: what they've earned, this month, what's
//  still coming, and a per-session breakdown. Plus a payout section — where a
//  doctor would link the account their earnings are paid into (Razorpay Route).
//  The reporting is live; the actual transfer is the next step (needs a KYC'd
//  linked account per doctor).
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_earnings.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';

class DoctorEarningsScreen extends StatelessWidget {
  const DoctorEarningsScreen({super.key});

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  String _rs(int minor) {
    final r = (minor / 100).round();
    // Simple Indian-ish grouping.
    final s = r.toString();
    if (s.length <= 3) return '₹$s';
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    return '₹$head,$tail';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([DoctorSession.instance, DoctorRoster.instance]),
      builder: (context, _) {
        final id = DoctorSession.instance.expertId ?? '';
        final s = DoctorEarnings.summary(id);
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 40),
          children: [
            _pad(Text('Earnings', style: ppFraunces(28, h: 1.1))),
            const SizedBox(height: 16),

            // Hero: pending payout.
            _pad(Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ppPurple, Color(0xFF502489)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: ppCardShadow,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AVAILABLE TO PAY OUT',
                    style: ppBody(10.5, color: const Color(0xB3FFFFFF),
                            w: FontWeight.w800)
                        .copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(_rs(s.pendingMinor),
                    style: ppFraunces(36, color: Colors.white, h: 1)),
                const SizedBox(height: 4),
                Text('Your ${(kDoctorSharePct * 100).round()}% share of completed sessions.',
                    style: ppBody(12, color: const Color(0xCCFFFFFF))),
              ]),
            )),
            const SizedBox(height: 12),

            _pad(Row(children: [
              Expanded(child: _stat('This month', _rs(s.thisMonthMinor))),
              const SizedBox(width: 12),
              Expanded(child: _stat('Upcoming', _rs(s.upcomingMinor))),
            ])),
            const SizedBox(height: 22),

            _pad(_payoutCard(context)),
            const SizedBox(height: 24),

            _pad(Text('SESSIONS',
                style: ppBody(11, color: ppMuted, w: FontWeight.w800)
                    .copyWith(letterSpacing: 1.0))),
            const SizedBox(height: 10),
            if (s.items.isEmpty)
              _pad(Text('No paid sessions yet.',
                  style: ppBody(13, color: ppSoft)))
            else
              for (final e in s.items) _pad(_earningRow(e)),
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppHair),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppJakarta(18, color: ppTitleInk)),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11.5, color: ppMuted)),
        ]),
      );

  Widget _payoutCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppPurple.withValues(alpha: 0.16)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_balance_outlined, size: 20, color: ppPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Payout account',
                  style: ppJakarta(15, color: ppTitleInk)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(999)),
              child: Text('Not set up',
                  style: ppBody(10.5, color: ppCoral, w: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
              'Link your bank account to receive payouts. Earnings are split to '
              'you automatically at checkout via Razorpay once it is set up.',
              style: ppBody(12.5, color: ppSoft, h: 1.5)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(const SnackBar(
                  content: Text(
                      'Bank/KYC onboarding comes with the payout release.'))),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ppPurple, borderRadius: BorderRadius.circular(12)),
              child: Text('Set up payouts',
                  style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        ]),
      );

  Widget _earningRow(ConsultEarning e) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppHair),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.booking.title,
                  style: ppBody(13.5, color: ppInk, w: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                  '${_dateLabel(e.booking.startsUtc)} · ${e.isPast ? "earned" : "upcoming"}',
                  style: ppBody(11.5, color: ppMuted)),
            ]),
          ),
          Text(_rs(e.doctorMinor),
              style: ppJakarta(14,
                  color: e.isPast ? ppPurple : ppMuted)),
        ]),
      );

  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _dateLabel(DateTime utc) {
    final d = utc.toLocal();
    return '${d.day} ${_mo[d.month - 1]}';
  }
}
