// =============================================================================
//  The monthly report, on screen, with a Share button (P2)
// -----------------------------------------------------------------------------
//  Opened from Overview's "Monthly report" row. Renders a [PartnerReport] and
//  shares the same report as a PDF through the OS share sheet (no print
//  dialog): HR sends numbers upward far more often than it browses them, and
//  what leaves the building should be the same shape every month.
//
//  Reads SponsorAdminStore as Overview left it; the report is a view of the
//  numbers already on screen, never a second fetch that could disagree.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../partner_app/partner_org_session.dart';
import '../../partner_app/partner_report.dart';
import '../../services/sponsor_admin_store.dart';
import '../doctor/doctor_chrome.dart';

class PartnerReportScreen extends StatefulWidget {
  const PartnerReportScreen({super.key, required this.org});
  final PartnerOrg org;

  static const routeName = 'partner/report';

  static Route<void> route(PartnerOrg org) => MaterialPageRoute(
    settings: const RouteSettings(name: PartnerReportScreen.routeName),
    builder: (_) => PartnerReportScreen(org: org),
  );

  @override
  State<PartnerReportScreen> createState() => _PartnerReportScreenState();
}

class _PartnerReportScreenState extends State<PartnerReportScreen> {
  bool _sharing = false;

  Future<void> _share(PartnerReport r) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await buildPartnerReportPdf(r);
      await Share.shareXFiles([
        XFile.fromData(bytes, name: r.fileName, mimeType: 'application/pdf'),
      ], subject: '${r.orgName} · ParentVeda programme report');
    } catch (_) {
      if (mounted) {
        dcToast(context, 'We could not make the PDF just now. Try again.');
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: SponsorAdminStore.instance,
    builder: (context, _) {
      final store = SponsorAdminStore.instance;
      final d = store.dashboard;
      if (d == null) {
        return const DcScreen(
          title: 'Monthly report',
          children: [
            DcEmpty(
              'Your report appears here',
              'Once your programme has loaded, this page summarises it in '
                  'one shareable page.',
              icon: Icons.description_outlined,
            ),
          ],
        );
      }
      final r = PartnerReport.from(
        d,
        store.trend,
        peopleWord: widget.org.peopleWord,
      );
      final p = dcP;
      return DcScreen(
        title: 'Monthly report',
        subtitle: [r.generated, ?r.renewal].join(' · '),
        bottom: ObPrimary(
          p: p,
          label: _sharing ? 'Preparing PDF…' : 'Share as PDF',
          leading: const Icon(Icons.ios_share_rounded, size: 18),
          onTap: _sharing ? null : () => _share(r),
        ),
        children: [
          Text(r.orgName, style: dcStrong(15, color: p.ink2)),
          const SizedBox(height: 6),
          Text(r.headline, style: dcTitle(22, h: 1.25)),
          if (r.change != null) ...[
            const SizedBox(height: 6),
            Text(r.change!, style: dcMeta(14)),
          ],
          const SizedBox(height: 18),
          DcStatRow([
            for (final f in r.figures.take(2)) DcStat(f.label, f.value),
          ]),
          DcStatRow([
            for (final f in r.figures.skip(2)) DcStat(f.label, f.value),
          ]),
          const SizedBox(height: 10),
          const DcSectionHead('Consultations'),
          if (r.consultsWithheld != null)
            DcNotice(r.consultsWithheld!)
          else
            DcStatRow([for (final f in r.consults) DcStat(f.label, f.value)]),
          if (r.months.isNotEmpty) ...[
            const SizedBox(height: 10),
            const DcSectionHead('Month by month'),
            _MonthTable(r.months),
          ],
          const SizedBox(height: 10),
          const DcSectionHead('What this report does not contain'),
          for (final l in r.limits)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DcNotice(l),
            ),
          const SizedBox(height: 6),
          Text(r.promise, style: dcMeta(13)),
        ],
      );
    },
  );
}

/// A table, not a chart: a reader checks a figure in a report rather than
/// glancing at a shape (the portal's reasoning, kept).
class _MonthTable extends StatelessWidget {
  const _MonthTable(this.months);
  final List<PartnerReportMonth> months;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    Widget cell(String s, {bool head = false, bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        s,
        style: head
            ? dcEyebrow()
            : strong
            ? dcStrong(14)
            : dcBody(14),
      ),
    );
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.3)},
      border: TableBorder(horizontalInside: BorderSide(color: p.line)),
      children: [
        TableRow(
          children: [
            cell('MONTH', head: true),
            cell('JOINED', head: true),
            cell('TOTAL', head: true),
            cell('CONSULTS', head: true),
          ],
        ),
        for (final m in months)
          TableRow(
            children: [
              cell(m.month),
              cell(m.joined),
              cell(m.total, strong: true),
              cell(m.consults),
            ],
          ),
      ],
    );
  }
}
