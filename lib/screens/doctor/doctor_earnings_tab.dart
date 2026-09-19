// =============================================================================
//  Earnings — the doctor's admin panel
// -----------------------------------------------------------------------------
//  The user's brief (2026-09-18): a doctor must be able to see, transparently
//  and itemised, what they earned from what, at what cut, from the start until
//  now, and when it will be paid — so that payouts are easy and nobody has to
//  ask. The tab therefore reads top to bottom in the order a person asks:
//
//     We owe you ₹X · next payout <date>        (Turo's copy; the plainest)
//     [attention: add your bank account]        (Airbnb's blocker card)
//     period · earned / upcoming / paid so far   (Cash App's key stats)
//     BY SOURCE — one row per way of earning     (Turo's legend)
//         Consultations   ₹…   12 · 80% of what parents paid  →
//         Masterclasses   ₹…   …                              →
//         … every source renders, empty ones with their invitation
//     PAYOUTS — the last few, → all               (DoorDash's list)
//     STATEMENT — share this period as CSV        (Airtasker)
//
//  Every number is the server's (DoctorLedger). Nothing on this screen does
//  arithmetic beyond formatting. Mobbin audit #8, docs/DOCTOR-APP-AUDIT.md.
//
//  Replaces DoctorEarningsScreen + DoctorImpactTab as the fourth tab (the
//  user's call, 2026-09-18: Earnings is the tab; the families count lives
//  inside the Referrals row). Both old files are kept for revert.
// =============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_session.dart';
import 'doctor_chrome.dart';
import 'doctor_impact_screen.dart';
import 'doctor_payout_account_screen.dart';
import 'doctor_payouts_screen.dart';
import 'doctor_source_screen.dart';

class DoctorEarningsTab extends StatefulWidget {
  const DoctorEarningsTab({super.key});

  @override
  State<DoctorEarningsTab> createState() => _DoctorEarningsTabState();
}

class _DoctorEarningsTabState extends State<DoctorEarningsTab> {
  @override
  void initState() {
    super.initState();
    DoctorLedger.instance.bind(DoctorSession.instance.expertId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DoctorLedger.instance,
      builder: (context, _) {
        final l = DoctorLedger.instance;
        final s = l.summary;
        final p = dcP;
        return DcTab(
          title: 'Earnings',
          onRefresh: l.refresh,
          children: [
            // ---- we owe you ----------------------------------------------
            DcCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WE OWE YOU', style: dcEyebrow()),
                const SizedBox(height: 8),
                Text(dcRupees(s.owedPaise), style: dcNum(40)),
                const SizedBox(height: 8),
                Text(
                  s.nextPayout == null
                      ? 'Paid by bank transfer on the 7th of each month.'
                      : 'Next payout ${dcDate(s.nextPayout!, year: true)} · by bank transfer',
                  style: dcMeta(14),
                ),
                if (s.accruedPaise > 0) ...[
                  const SizedBox(height: 4),
                  Text('${dcRupees(s.accruedPaise)} more once booked sessions happen.',
                      style: dcMeta(13, color: p.ink3)),
                ],
              ]),
            ),
            const SizedBox(height: 12),

            // ---- the blocker, if any --------------------------------------
            if (l.accountKnown && l.account == null)
              DcAttention(
                icon: Icons.account_balance_outlined,
                title: 'Add your bank account',
                body: 'Required to get paid. Takes a minute; we verify it before the first transfer.',
                action: 'Add account',
                onTap: () => _openAccount(context),
              )
            else if (l.account != null && l.account!.status == 'rejected')
              DcAttention(
                icon: Icons.account_balance_outlined,
                urgent: true,
                title: 'We could not verify your bank account',
                body: l.account!.reason ?? 'Please check the details and submit again.',
                action: 'Fix account',
                onTap: () => _openAccount(context),
              )
            else if (l.account != null)
              DcRowGroup(children: [
                DcRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Payout account ${l.account!.masked}',
                  subtitle: l.account!.verified
                      ? 'Verified · ${l.account!.ifsc}'
                      : 'Being verified · ${l.account!.ifsc}',
                  onTap: () => _openAccount(context),
                ),
              ]),
            const SizedBox(height: 22),

            // ---- period ---------------------------------------------------
            DcSegments(
              labels: LedgerPeriod.values.map((e) => e.label).toList(),
              index: l.period.index,
              onChanged: (i) => l.setPeriod(LedgerPeriod.values[i]),
            ),
            const SizedBox(height: 12),
            DcStatRow([
              DcStat('Earned', dcRupees(s.periodPaise)),
              DcStat('Upcoming', dcRupees(s.periodUpcomingPaise)),
              DcStat('Paid so far', dcRupees(s.paidPaise)),
            ]),
            const SizedBox(height: 22),

            // ---- by source ------------------------------------------------
            const DcSectionHead('By source', title: 'Where it came from'),
            DcRowGroup(children: [
              // The workbook's order (0085): consultations · live courses ·
              // recorded courses · content · products. Every row renders,
              // earned or not — the empty ones are the advertisement.
              for (final src in const [
                EarningSource.consultation,
                EarningSource.masterclass,
                EarningSource.cohort,
                EarningSource.course,
                EarningSource.video,
                EarningSource.article,
                EarningSource.affiliate,
                EarningSource.sponsorship,
                EarningSource.product,
              ])
                _sourceRow(context, l, src),
              // Referrals: the families count, aggregate only, and the
              // commission ledger — the whole Impact screen, one row in.
              DcRow(
                title: 'Referrals',
                subtitle: (s.forSource(EarningSource.referral)?.expertPaise ?? 0) > 0
                    ? '${s.forSource(EarningSource.referral)!.items} this period'
                    : 'Families you brought to ParentVeda, and what that earns.',
                trailingText: dcRupees(s.forSource(EarningSource.referral)?.expertPaise ?? 0),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'doctor/impact'),
                    builder: (_) => const DoctorImpactScreen())),
              ),
            ]),
            const SizedBox(height: 22),

            // ---- payouts --------------------------------------------------
            DcSectionHead('Payouts',
                title: 'What has been paid',
                note: l.payouts.length > 3 ? 'See all' : null,
                onNote: l.payouts.length > 3 ? () => _openPayouts(context) : null),
            if (l.payouts.isEmpty)
              const DcEmpty(
                'No payouts yet',
                'Each bank transfer appears here with its reference number and the sessions it covered.',
                icon: Icons.receipt_long_outlined,
              )
            else
              DcRowGroup(children: [
                for (final po in l.payouts.take(3))
                  DcRow(
                    icon: Icons.receipt_long_outlined,
                    title: dcRupees(po.amountPaise),
                    subtitle: '${po.statusLabel}${po.paidAt != null ? ' · ${dcDate(po.paidAt!, year: true)}' : ''} · ${po.methodLabel}',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        settings: const RouteSettings(name: 'doctor/payout'),
                        builder: (_) => DoctorPayoutScreen(payout: po))),
                  ),
              ]),
            const SizedBox(height: 22),

            // ---- statement ------------------------------------------------
            const DcSectionHead('Statement'),
            DcRowGroup(children: [
              DcRow(
                icon: Icons.ios_share_rounded,
                title: 'Share ${l.period.label.toLowerCase()} as a statement',
                subtitle: 'A CSV your accountant can open. Every line, with the rate that applied.',
                onTap: () => _shareStatement(context, l),
              ),
            ]),
            const SizedBox(height: 16),
            Text(
              'Rates shown are the ones that applied when each session happened. '
              'Questions about a line? Write to partners@parentveda.com with its reference.',
              style: dcMeta(12.5, color: p.ink3),
            ),
          ],
        );
      },
    );
  }

  Widget _sourceRow(BuildContext context, DoctorLedger l, EarningSource src) {
    final t = l.summary.forSource(src);
    final rate = l.rateFor(src);
    final own = l.ownCodeRateFor(src);
    final has = t != null && t.items > 0;
    // "30% through ParentVeda, 55% through your own code" where both exist.
    final rateLine = rate <= 0
        ? null
        : (src.hasOwnCodeRate && own > 0
            ? '${dcPercent(rate)} through ParentVeda, ${dcPercent(own)} through your own code'
            : '${dcPercent(rate)} of ${src.gross.toLowerCase()}');
    final sub = has
        ? '${t.items} ${t.items == 1 ? 'item' : 'items'} · ${rateLine ?? src.gross.toLowerCase()}'
        : (rateLine != null ? '${src.emptyLine} You keep $rateLine.' : src.emptyLine);
    return DcRow(
      title: src.label,
      subtitle: sub,
      trailingText: dcRupees(t?.expertPaise ?? 0),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: 'doctor/earnings/${src.name}'),
          builder: (_) => DoctorSourceScreen(source: src))),
    );
  }

  void _openAccount(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/payout-account'),
      builder: (_) => const DoctorPayoutAccountScreen()));

  void _openPayouts(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/payouts'),
      builder: (_) => const DoctorPayoutsScreen()));

  /// The statement is the itemised list for the period, as CSV. Built here
  /// from the same rows the source screens show, so the file and the screen
  /// cannot disagree.
  Future<void> _shareStatement(BuildContext context, DoctorLedger l) async {
    await l.loadRows(null);
    final rows = l.rowsFor(null);
    if (rows.isEmpty) {
      if (context.mounted) dcToast(context, 'Nothing in ${l.period.label.toLowerCase()} yet.');
      return;
    }
    String q(String? v) => '"${(v ?? '').replaceAll('"', '""')}"';
    final b = StringBuffer()
      ..writeln('date,source,item,counterparty,gross_inr,share_pct,earned_inr,platform_inr,status,reference,note');
    for (final r in rows) {
      b.writeln([
        dcDate(r.occurredAt, year: true),
        r.source.singular,
        q(r.title),
        q(r.counterparty),
        (r.grossPaise / 100).toStringAsFixed(2),
        (r.shareBps / 100).toStringAsFixed(2),
        (r.expertPaise / 100).toStringAsFixed(2),
        (r.platformPaise / 100).toStringAsFixed(2),
        r.status.label,
        q(r.id),
        q(r.note),
      ].join(','));
    }
    final name = 'ParentVeda-statement-${l.period.name}.csv';
    await Share.shareXFiles(
      [XFile.fromData(Uint8List.fromList(b.toString().codeUnits), name: name, mimeType: 'text/csv')],
      subject: 'ParentVeda+ statement · ${l.period.label}',
    );
  }
}
