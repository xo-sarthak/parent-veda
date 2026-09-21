// =============================================================================
//  Payouts — every transfer, and what each one covered
// -----------------------------------------------------------------------------
//  DoorDash's payout history: a plain dated list. Tap one and the detail
//  screen says the amount, when, how (bank transfer / Razorpay), the
//  reference the bank gave (UTR), the last four digits it went to, and
//  every ledger line it settled — so "was I paid for the 14th?" is answered
//  by reading, not by asking.
//
//  Payouts are manual first (an admin records the NEFT with its UTR through
//  record_expert_payout(), 0084). The screen does not know or care; when
//  Razorpay Route lands, `method` changes and nothing here does.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_ledger.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';
import 'doctor_source_screen.dart' show showReceipt;

class DoctorPayoutsScreen extends StatelessWidget {
  const DoctorPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DoctorLedger.instance,
      builder: (context, _) {
        final l = DoctorLedger.instance;
        final byMonth = <String, List<Payout>>{};
        for (final po in l.payouts) {
          final d = po.paidAt ?? po.periodTo;
          byMonth.putIfAbsent(dcMonth(d), () => []).add(po);
        }
        return DcScreen(
          title: 'Payouts',
          subtitle: 'Paid so far ${dcRupees(l.summary.paidPaise)}',
          onRefresh: l.refresh,
          children: [
            if (l.payouts.isEmpty)
              const DcEmpty(
                'No payouts yet',
                'Payable earnings are transferred on the 7th of each month. Each transfer appears here with its reference number.',
                mark: DoctorMark.earnings,
              )
            else
              for (final e in byMonth.entries) ...[
                DcSectionHead(e.key),
                DcRowGroup(children: [
                  for (final po in e.value)
                    DcRow(
                      mark: DoctorMark.earnings,
                      title: dcRupees(po.amountPaise),
                      subtitle: '${po.statusLabel}${po.paidAt != null ? ' · ${dcDate(po.paidAt!)}' : ''} · ${po.methodLabel}'
                          '${po.bankLast4 != null ? ' · •••• ${po.bankLast4}' : ''}',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor/payout'),
                          builder: (_) => DoctorPayoutScreen(payout: po))),
                    ),
                ]),
                const SizedBox(height: 16),
              ],
          ],
        );
      },
    );
  }
}

class DoctorPayoutScreen extends StatefulWidget {
  const DoctorPayoutScreen({super.key, required this.payout});
  final Payout payout;

  @override
  State<DoctorPayoutScreen> createState() => _DoctorPayoutScreenState();
}

class _DoctorPayoutScreenState extends State<DoctorPayoutScreen> {
  @override
  void initState() {
    super.initState();
    DoctorLedger.instance.loadPayoutItems(widget.payout.id);
  }

  @override
  Widget build(BuildContext context) {
    final po = widget.payout;
    return ListenableBuilder(
      listenable: DoctorLedger.instance,
      builder: (context, _) {
        final items = DoctorLedger.instance.payoutItems(po.id);
        final p = dcP;
        final bySource = <EarningSource, int>{};
        for (final r in items) {
          bySource[r.source] = (bySource[r.source] ?? 0) + r.expertPaise;
        }
        return DcScreen(
          title: dcRupees(po.amountPaise),
          subtitle: '${po.statusLabel}${po.paidAt != null ? ' on ${dcDate(po.paidAt!, year: true)}' : ''}',
          children: [
            DcCard(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Column(children: [
                _line(p, 'Period', '${dcDate(po.periodFrom)} – ${dcDate(po.periodTo, year: true)}'),
                Divider(height: 1, color: p.line),
                _line(p, 'How', po.methodLabel),
                Divider(height: 1, color: p.line),
                _line(p, 'Reference', po.reference ?? '—', mono: true),
                if (po.bankLast4 != null) ...[
                  Divider(height: 1, color: p.line),
                  _line(p, 'Sent to', 'Account ending ${po.bankLast4}'),
                ],
              ]),
            ),
            if (po.note != null && po.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              DcNotice(po.note!),
            ],
            const SizedBox(height: 22),

            if (bySource.isNotEmpty) ...[
              const DcSectionHead('Made up of'),
              DcRowGroup(children: [
                for (final e in bySource.entries)
                  DcRow(title: e.key.label, trailingText: dcRupees(e.value), chevron: false),
              ]),
              const SizedBox(height: 22),
            ],

            DcSectionHead('Every line', note: items.isEmpty ? null : '${items.length}'),
            if (items.isEmpty)
              const DcEmpty('Loading the lines…', 'Each session this payout covered is listed here.', mark: DoctorMark.earnings)
            else
              DcRowGroup(children: [
                for (final r in items)
                  DcRow(
                    title: r.headline,
                    subtitle: '${r.source.singular} · ${dcDayDate(r.occurredAt)}',
                    trailingText: dcRupees(r.expertPaise),
                    onTap: () => showReceipt(context, r),
                  ),
              ]),
            const SizedBox(height: 16),
            Text('Payout ${po.id}', style: dcMeta(12, color: p.ink3)),
          ],
        );
      },
    );
  }

  Widget _line(dynamic p, String k, String v, {bool mono = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(children: [
          Text(k, style: dcMeta(14)),
          const Spacer(),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: dcStrong(14.5).copyWith(fontFeatures: mono ? const [FontFeature.tabularFigures()] : null)),
          ),
        ]),
      );
}
