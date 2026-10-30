// =============================================================================
//  PartnerReport — the monthly summary an admin forwards (P2)
// -----------------------------------------------------------------------------
//  Mirrors the web portal's report page (C:\parentveda-web\src\app\portal\
//  report\page.tsx): a headline sentence, four figures, consultations or why
//  they are withheld, month by month, and what the report does not contain.
//
//  ONE MODEL, TWO RENDERERS. The Report screen and the shared PDF both read
//  this class, and neither computes anything of its own. The portal avoided a
//  second layout by printing the page; a phone has no print-to-PDF a desk user
//  would reach for, so the app does draw a second layout, and the cost of that
//  is two places that could disagree about a number. Putting every figure and
//  sentence here first means they can only disagree about typography.
//
//  Nothing here is aggregation. The server returned totals (sponsor_dashboard,
//  sponsor_trend); this file only phrases them and does the two pieces of
//  arithmetic the portal does too (not started yet, change over three months).
// =============================================================================

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../services/sponsor_admin_store.dart';

const _mo = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _date(DateTime d) {
  final l = d.toLocal();
  return '${l.day} ${_mo[l.month - 1]} ${l.year}';
}

String _month(DateTime d) => '${_mo[d.month - 1]} ${d.year}';

class PartnerReportFigure {
  const PartnerReportFigure(this.label, this.value);
  final String label;
  final String value;
}

class PartnerReportMonth {
  const PartnerReportMonth(this.month, this.joined, this.total, this.consults);
  final String month;
  final String joined;
  final String total;

  /// "—" when that month was withheld, never "0".
  final String consults;
}

class PartnerReport {
  const PartnerReport({
    required this.orgName,
    required this.generated,
    required this.renewal,
    required this.headline,
    required this.change,
    required this.figures,
    required this.consultsWithheld,
    required this.consults,
    required this.months,
    required this.limits,
    required this.promise,
  });

  final String orgName;
  final String generated;
  final String? renewal;
  final String headline;
  final String? change;
  final List<PartnerReportFigure> figures;

  /// Set when consultations are withheld: the sentence that says why.
  final String? consultsWithheld;
  final List<PartnerReportFigure> consults;
  final List<PartnerReportMonth> months;
  final List<String> limits;
  final String promise;

  /// [peopleWord] is the organisation's word for its members: employees, or
  /// parents for a school (PartnerOrg.peopleWord).
  factory PartnerReport.from(
    SponsorDashboard d,
    List<SponsorTrendPoint> trend, {
    required String peopleWord,
    DateTime? now,
  }) {
    // The server's denominator, never one of our own: the list when there is
    // one, otherwise the seats (null when unlimited).
    final int? den = d.denominatorIsRoster
        ? d.eligibleListed
        : d.seatsPurchased;
    final notYet = den == null ? null : math.max(den - d.activated, 0);
    final change3m = trend.length >= 4
        ? trend.last.activatedCumulative -
              trend[trend.length - 4].activatedCumulative
        : null;

    final headline = den == null
        ? '${d.activated} $peopleWord are using ParentVeda.'
        : '${d.activated} of $den $peopleWord are using ParentVeda'
              '${d.activationRate == null ? '' : ', ${d.activationRate}%'}.';

    final min = d.minCohort;
    return PartnerReport(
      orgName: d.sponsorName,
      generated: 'Generated ${_date(now ?? DateTime.now())}',
      renewal: d.renewalAt == null ? null : 'Renews ${_date(d.renewalAt!)}',
      headline: headline,
      change: change3m == null
          ? null
          : change3m > 0
          ? 'Up $change3m since three months ago.'
          : change3m == 0
          ? 'Level with three months ago.'
          : 'Down ${-change3m} since three months ago.',
      figures: [
        PartnerReportFigure('Activated', '${d.activated}'),
        d.denominatorIsRoster
            ? PartnerReportFigure('On your list', '${d.eligibleListed}')
            : PartnerReportFigure(
                'Seats purchased',
                d.seatsPurchased?.toString() ?? 'Unlimited',
              ),
        PartnerReportFigure('Joined last 30 days', '${d.activatedLast30d}'),
        PartnerReportFigure('Not started yet', notYet?.toString() ?? '—'),
      ],
      consultsWithheld: d.suppressed
          ? 'Withheld. Behavioural figures are only reported once $min people '
                'have activated. Below that, a total is close enough to naming '
                'someone. This is a deliberate limit, not missing data.'
          : null,
      consults: d.suppressed
          ? const []
          : [
              PartnerReportFigure('Booked', '${d.consultationsBooked ?? 0}'),
              PartnerReportFigure(
                'Attended',
                '${d.consultationsCompleted ?? 0}',
              ),
              PartnerReportFigure(
                'Upcoming',
                '${d.consultationsUpcoming ?? 0}',
              ),
            ],
      months: [
        for (final p in trend)
          PartnerReportMonth(
            _month(p.month),
            '${p.activatedInMonth}',
            '${p.activatedCumulative}',
            p.consultationsBooked?.toString() ?? '—',
          ),
      ],
      limits: [
        'Nothing about any individual: not who booked a consultation, what '
            'they read, what they asked, or when they last opened the app.',
        'No breakdown by section. Which parts of ParentVeda your $peopleWord '
            'use most is not reported, because in a small group it narrows '
            'down who is concerned about what.',
        'Totals are withheld entirely below $min people, for the same reason.',
      ],
      promise:
          'Your $peopleWord activated this benefit on the understanding that '
          'their pregnancy, their child and their questions stay private. That '
          'promise is enforced in our database, not by policy: the figures '
          'above are the only shape in which this data can be returned.',
    );
  }

  /// A file name that sorts by month in a folder of them.
  String get fileName {
    final safe = orgName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final n = DateTime.now();
    return 'ParentVeda-report-$safe-${n.year}-${n.month.toString().padLeft(2, '0')}.pdf';
  }
}

// ---- the PDF ----------------------------------------------------------------
//
// The built-in Helvetica, deliberately: no font is fetched, so the report
// builds offline and in a test. Helvetica covers Latin-1 and little else, so
// [_pdfSafe] swaps the few typographic marks this file writes (the dash) and
// any character it cannot draw for a plain one, rather than letting a
// partner's name with an unusual letter throw. The screen shows the real name.

const _ink = PdfColor.fromInt(0xFF211D26);
const _muted = PdfColor.fromInt(0xFF6E6577);
const _line = PdfColor.fromInt(0xFFDDD7E2);

String _pdfSafe(String s) => s
    .replaceAll('—', '-')
    .replaceAll('–', '-')
    .replaceAll('’', "'")
    .replaceAllMapped(RegExp(r'[^\x20-\x7E\xA0-\xFF]'), (_) => '?');

Future<Uint8List> buildPartnerReportPdf(PartnerReport r) async {
  final doc = pw.Document(
    title: _pdfSafe('${r.orgName} programme report'),
    author: 'ParentVeda',
  );
  pw.Widget t(String s, {double size = 10, bool bold = false, PdfColor? c}) =>
      pw.Text(
        _pdfSafe(s),
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: c ?? _ink,
          lineSpacing: 2,
        ),
      );
  pw.Widget figures(List<PartnerReportFigure> fs) => pw.Row(
    children: [
      for (final f in fs)
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              t(f.value, size: 20, bold: true),
              pw.SizedBox(height: 2),
              t(f.label, size: 9, c: _muted),
            ],
          ),
        ),
    ],
  );
  pw.Widget head(String s) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 22, bottom: 8),
    child: t(s.toUpperCase(), size: 9, bold: true, c: _muted),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 48, 48, 48),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: t(
          'ParentVeda Partners - page ${ctx.pageNumber} of ${ctx.pagesCount}',
          size: 8,
          c: _muted,
        ),
      ),
      build: (_) => [
        t('PARENTVEDA - PROGRAMME REPORT', size: 9, bold: true, c: _muted),
        pw.SizedBox(height: 6),
        t(r.orgName, size: 24, bold: true),
        pw.SizedBox(height: 4),
        t([r.generated, ?r.renewal].join(' - '), size: 10, c: _muted),
        pw.Divider(color: _line, height: 28),
        t(r.headline, size: 16, bold: true),
        if (r.change != null) ...[pw.SizedBox(height: 4), t(r.change!)],
        pw.SizedBox(height: 18),
        figures(r.figures),
        head('Consultations'),
        if (r.consultsWithheld != null)
          t(r.consultsWithheld!, c: _muted)
        else
          figures(r.consults),
        if (r.months.isNotEmpty) ...[
          head('Month by month'),
          pw.TableHelper.fromTextArray(
            headers: const ['Month', 'Joined', 'Total using', 'Consultations'],
            data: [
              for (final m in r.months)
                [m.month, m.joined, m.total, _pdfSafe(m.consults)],
            ],
            border: null,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _muted,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10, color: _ink),
            headerDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _line)),
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: _line, width: 0.5),
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
        head('What this report does not contain'),
        for (final l in r.limits)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: t('-  $l'),
          ),
        pw.SizedBox(height: 10),
        t(r.promise, size: 9, c: _muted),
      ],
    ),
  );
  return doc.save();
}
