// =============================================================================
//  One source, itemised — and the receipt for any line
// -----------------------------------------------------------------------------
//  Tap "Consultations" on the Earnings tab and you land here: the period's
//  total, count and rate at the top, then every line, newest first. Tap a
//  line and the receipt opens as a sheet in the printed-receipt grammar the
//  Turo host receipt uses:
//
//      Parent paid                       ₹800
//      ParentVeda fee (20%)             −₹160
//        Covers the platform, payments, support and the app.
//      YOU EARNED                        ₹640
//
//  The gross is ALWAYS shown (the user's call, 2026-09-18): the cut being
//  visible is the transparency the tab exists for.
//
//  Videos are the one source with a thing to show above the ledger — the
//  films themselves, each a link with its share — because a doctor with no
//  video revenue yet should still see that the flow exists.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../doctor/doctor_ledger.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

class DoctorSourceScreen extends StatefulWidget {
  const DoctorSourceScreen({super.key, required this.source});
  final EarningSource source;

  @override
  State<DoctorSourceScreen> createState() => _DoctorSourceScreenState();
}

class _DoctorSourceScreenState extends State<DoctorSourceScreen> {
  @override
  void initState() {
    super.initState();
    DoctorLedger.instance.loadRows(widget.source);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DoctorLedger.instance,
      builder: (context, _) {
        final l = DoctorLedger.instance;
        final src = widget.source;
        final t = l.summary.forSource(src);
        final rows = l.rowsFor(src);
        final p = dcP;
        return DcScreen(
          title: src.label,
          subtitle: l.period.label,
          onRefresh: () async {
            await l.refreshSummary();
            await l.loadRows(src);
          },
          children: [
            DcStatRow([
              DcStat('Earned', dcRupees(t?.expertPaise ?? 0)),
              DcStat('Items', '${t?.items ?? 0}'),
              DcStat('Your share', l.rateFor(src) > 0 ? dcPercent(l.rateFor(src)) : '—'),
            ]),
            const SizedBox(height: 10),
            // A rate of zero means UNKNOWN (no rule reached the phone yet),
            // and "you keep 0%" is a claim, not an absence. Walked 2026-09-18.
            Text(
              l.rateFor(src) > 0
                  ? (src.hasOwnCodeRate && l.ownCodeRateFor(src) > 0
                      ? 'You keep ${dcPercent(l.rateFor(src))} of a sale ParentVeda brings and '
                          '${dcPercent(l.ownCodeRateFor(src))} of one your own code brings. '
                          'The rest covers the platform, payments, support and the app.'
                      : 'You keep ${dcPercent(l.rateFor(src))} of ${src.gross.toLowerCase()}. '
                          'The rest covers the platform, payments, support and the app.')
                  : 'Your share of ${src.gross.toLowerCase()} is shown here once it is set. '
                      'Every line below carries the rate that applied to it.',
              style: dcMeta(13.5, color: p.ink2),
            ),
            const SizedBox(height: 22),

            if (src == EarningSource.video) ...[
              const DcSectionHead('Your videos'),
              if (l.videos.isEmpty)
                const DcEmpty(
                  'No videos yet',
                  'When ParentVeda films with you, each video is listed here with its link and your share. '
                  'Revenue is added month by month as the channel reports it.',
                  mark: DoctorMark.video,
                )
              else
                DcRowGroup(children: [
                  for (final v in l.videos)
                    DcRow(
                      mark: DoctorMark.video,
                      title: v.title.isEmpty ? v.url : v.title,
                      subtitle: 'Your share ${dcPercent(v.shareBps)} · added ${dcDate(v.addedAt, year: true)}',
                      trailing: Icon(Icons.open_in_new_rounded, size: 20, color: p.ink3),
                      chevron: false,
                      onTap: () => launchUrl(Uri.parse(v.url), mode: LaunchMode.externalApplication),
                    ),
                ]),
              const SizedBox(height: 22),
            ],

            DcSectionHead('Every line', note: rows.isEmpty ? null : '${rows.length}'),
            if (rows.isEmpty)
              DcEmpty(
                'Nothing in ${l.period.label.toLowerCase()}',
                src.emptyLine,
                mark: DoctorMark.earnings,
              )
            else
              DcRowGroup(children: [
                for (final r in rows)
                  DcRow(
                    title: r.headline,
                    subtitle: '${dcDayDate(r.occurredAt)}'
                        '${r.source == EarningSource.consultation ? ' · ${dcTime(r.occurredAt)}' : ''}'
                        '${r.channel == EarningChannel.ownCode ? ' · your code' : ''}'
                        ' · ${r.status.label}',
                    trailingText: dcRupees(r.expertPaise),
                    trailingSub: r.status == EarningStatus.reversed ? 'not counted' : null,
                    titleColor: r.status == EarningStatus.reversed ? p.ink3 : null,
                    onTap: () => showReceipt(context, r),
                  ),
              ]),
          ],
        );
      },
    );
  }
}

/// The receipt for one ledger line. Shared with the payout detail screen.
Future<void> showReceipt(BuildContext context, EarningRow r) {
  final p = dcP;
  final feePct = dcPercent(10000 - r.shareBps);
  return dcSheet(
    context,
    title: r.source.singular,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r.headline, style: dcStrong(16)),
      const SizedBox(height: 3),
      Text(
        '${dcDayDate(r.occurredAt)}'
        '${r.source == EarningSource.consultation ? ' · ${dcTime(r.occurredAt)}' : ''}',
        style: dcMeta(13.5),
      ),
      const SizedBox(height: 16),
      DcCard(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Column(children: [
          DcReceiptLine(r.source.gross, dcRupees(r.grossPaise),
              note: r.channel == EarningChannel.ownCode ? 'Brought by your own code.' : null),
          Divider(height: 1, color: p.line),
          DcReceiptLine(
            'ParentVeda fee ($feePct)',
            '−${dcRupees(r.platformPaise.abs())}',
            muted: true,
            note: 'Covers the platform, payments, support and the app.',
          ),
          Divider(height: 1, color: p.line),
          DcReceiptLine('You earned', dcRupees(r.expertPaise), strong: true),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        DcStatusPill(r.status.label,
            hue: switch (r.status) {
              EarningStatus.paid => 104.0,
              EarningStatus.payable => 42.0,
              EarningStatus.reversed => 344.0,
              EarningStatus.accrued => null,
            }),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            switch (r.status) {
              EarningStatus.accrued => 'Counts once the session has happened.',
              EarningStatus.payable => 'In your next payout.',
              EarningStatus.paid => 'Included in a payout.',
              EarningStatus.reversed => 'Cancelled; not counted.',
            },
            style: dcMeta(13),
          ),
        ),
      ]),
      if (r.note != null && r.note!.isNotEmpty) ...[
        const SizedBox(height: 14),
        DcNotice(r.note!),
      ],
      const SizedBox(height: 14),
      Text('Reference ${r.id}', style: dcMeta(12, color: p.ink3)),
      const SizedBox(height: 4),
    ]),
  );
}
