// =============================================================================
//  Her records, as one sheet somebody else can read
// -----------------------------------------------------------------------------
//  The in-app appointment sheet is a phone you hand across a desk. This is the
//  version that survives being handed to somebody who then keeps it — a second
//  opinion, a new clinic, a partner's insurer, a folder at home.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE PDF IS THE WHOLE FOLDER. THE SHEET IS THE SIX MOST RECENT.
//  ---------------------------------------------------------------------------
//
//  That difference is the only real design decision in this file, and it goes
//  the way it does because of who reads each one.
//
//  The sheet is read over her shoulder in ninety seconds, so six is generous.
//  The PDF is read by a clinician who has never met her, alone, at a desk —
//  and a medical summary that silently stops at six is the kind of omission
//  that changes a decision without anybody knowing it happened. Paper has room.
//  Every reading of every test goes in, oldest under newest.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE PHOTOS TRAVEL WITH IT, OR THE HANDOVER IS HALF A HANDOVER
//  ---------------------------------------------------------------------------
//
//  A summary that says "photo saved" and does not carry the photo is worse than
//  one that never mentioned it: the reader now knows a document exists and
//  cannot see it. So every image attachment becomes a page of its own, captioned
//  with the test and the date.
//
//  A PDF attachment cannot be embedded as an image and is NOT silently dropped
//  — it is named on the summary as a file that exists and did not travel. An
//  absence you can see is a different thing from an absence you cannot.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND IT STILL DOES NOT INTERPRET ANYTHING
//  ---------------------------------------------------------------------------
//
//  Same rule as the screen, and it matters more here, because paper carries
//  authority a screen does not. No ranges, no flags, no "high", no shading. A
//  prior reading is quoted beside the current one because that is arithmetic on
//  her own two numbers; nothing else is added. The footer says so on every page
//  — a printed page gets separated from its stack and read alone.
// =============================================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../localization/app_language.dart';
import '../ttc/ttc_records_grouping.dart';
import 'pdf_fonts.dart';
import 'remote/storage_service.dart';

const PdfColor _ink = PdfColor.fromInt(0xFF211D26);
const PdfColor _ink2 = PdfColor.fromInt(0xFF4A4351);
const PdfColor _muted = PdfColor.fromInt(0xFF6E6577);
const PdfColor _line = PdfColor.fromInt(0xFFDDD7E2);
const PdfColor _band = PdfColor.fromInt(0xFFF1F4F6);

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// One resolved image attachment, with enough context to caption its page.
class _Shot {
  const _Shot({required this.bytes, required this.caption});
  final Uint8List bytes;
  final String caption;
}

class TtcRecordsPdf {
  /// Null when the fonts could not be loaded.
  ///
  /// ⚠️ REFUSING IS THE CORRECT FAILURE HERE, and it is the house rule from
  /// `pdf_fonts.dart` rather than a new one. `PdfGoogleFonts` fetches over the
  /// network and falls back to Helvetica, which has no Devanagari — so an
  /// offline Hindi export would hand somebody a medical summary printed as
  /// empty boxes. A file that never existed is recoverable; one that was
  /// printed, filed and read is not.
  static Future<Uint8List?> build({
    required AppLanguage lang,
    String? forAppointment,
  }) async {
    final fonts = await PdfFontSet.load(lang);
    if (!fonts.complete) return null;

    final serif = fonts.serif;
    final body = fonts.body;
    final sansBold = fonts.sansBold;

    final groups = ttcGroupedRecords();
    final coverage = ttcRecordCoverage();
    final shots = await _resolveShots(groups);
    final unshown = _unshown(groups);

    final doc = pw.Document(title: 'ParentVeda records', author: 'ParentVeda');

    pw.Widget label(String s) => pw.Text(s.toUpperCase(),
        style: pw.TextStyle(font: sansBold, fontSize: 8, color: _muted));

    // One test, and every reading of it. The newest carries the row; the older
    // ones sit under it in a smaller size, in date order, so the direction is
    // read down the block without anything being said about it.
    pw.Widget block(TtcRecordGroup g) {
      final latest = g.latest;
      final value = ttcRecordValue(latest);
      return pw.Container(
        decoration: const pw.BoxDecoration(
            border:
                pw.Border(bottom: pw.BorderSide(color: _line, width: 0.6))),
        padding: const pw.EdgeInsets.symmetric(vertical: 9),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(g.label,
                          style: pw.TextStyle(
                              font: sansBold, fontSize: 10.5, color: _ink)),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                          value.isEmpty ? 'not typed' : value,
                          style: pw.TextStyle(
                              font: sansBold,
                              fontSize: 10.5,
                              color: value.isEmpty ? _muted : _ink)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(_date(latest.takenOn),
                          style: pw.TextStyle(
                              font: body, fontSize: 9.5, color: _ink2)),
                    ),
                    pw.SizedBox(
                      width: 52,
                      child: pw.Text(g.forPartner ? 'Partner' : 'Her',
                          style: pw.TextStyle(
                              font: body, fontSize: 9.5, color: _muted)),
                    ),
                  ]),
              // Earlier readings. Not a trend line, not a verdict — the same
              // rows she filed, in the order she filed them.
              if (g.repeated)
                for (final r in g.readings.skip(1))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4, left: 10),
                    child: pw.Text(
                        '${_date(r.takenOn)}   '
                        '${ttcRecordValue(r).isEmpty ? 'not typed' : ttcRecordValue(r)}',
                        style: pw.TextStyle(
                            font: body, fontSize: 9, color: _muted)),
                  ),
              if (latest.note != null && latest.note!.trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 5),
                  child: pw.Text(latest.note!.trim(),
                      style: pw.TextStyle(
                          font: body,
                          fontSize: 9.5,
                          lineSpacing: 1.5,
                          color: _ink2)),
                ),
            ]),
      );
    }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(42, 42, 42, 46),
      // ⚠️ THE DISCLAIMER IS ON EVERY PAGE, not once at the end. Printed pages
      // get separated from their stack, and page three read on its own must
      // still say what this document is and is not.
      footer: (context) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 10),
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6))),
        child: pw.Row(children: [
          pw.Expanded(
            child: pw.Text(
                'Saved by ParentVeda exactly as the reports were written. '
                'Nothing here is interpreted, ranked or flagged.',
                style: pw.TextStyle(font: body, fontSize: 7.5, color: _muted)),
          ),
          pw.Text('${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(font: body, fontSize: 7.5, color: _muted)),
        ]),
      ),
      build: (context) => [
        label(forAppointment == null ? 'Test results' : 'For $forAppointment'),
        pw.SizedBox(height: 6),
        pw.Text('Everything on file, in date order.',
            style: pw.TextStyle(font: serif, fontSize: 19, color: _ink)),
        pw.SizedBox(height: 5),
        pw.Text(
            '${groups.fold<int>(0, (n, g) => n + g.count)} results across '
            '${groups.length} ${groups.length == 1 ? 'test' : 'tests'}. '
            'Prepared ${_date(DateTime.now())}.',
            style: pw.TextStyle(font: body, fontSize: 9.5, color: _ink2)),
        pw.SizedBox(height: 18),

        pw.Container(
          color: _band,
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: pw.Row(children: [
            pw.Expanded(flex: 5, child: label('Test')),
            pw.Expanded(flex: 4, child: label('Result as printed')),
            pw.Expanded(flex: 3, child: label('Date')),
            pw.SizedBox(width: 52, child: label('Whose')),
          ]),
        ),
        for (final g in groups) block(g),

        if (coverage.notAdded.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          label('Not in this document'),
          pw.SizedBox(height: 5),
          // ⚠️ "NOT SAVED HERE", NOT "MISSING". Same line the screen holds, and
          // it matters more on paper: a clinician reading "missing" would be
          // reading a judgement about another clinician's workup, which this
          // app has no standing to make.
          pw.Text(
              '${coverage.notAdded.map((t) => t.name).join(', ')} '
              '${coverage.notAdded.length == 1 ? 'is' : 'are'} not saved in '
              'ParentVeda. That is a fact about this folder, not about which '
              'tests were done or should be.',
              style: pw.TextStyle(
                  font: body, fontSize: 9.5, lineSpacing: 1.5, color: _ink2)),
        ],

        if (unshown.isNotEmpty) ...[
          pw.SizedBox(height: 14),
          label('Files that could not travel'),
          pw.SizedBox(height: 5),
          pw.Text(
              '${unshown.join(', ')}. '
              'Saved in the app and not reproducible in this document.',
              style: pw.TextStyle(
                  font: body, fontSize: 9.5, lineSpacing: 1.5, color: _ink2)),
        ],
      ],
    ));

    // One page per photograph, captioned. Full-bleed-ish and unannotated: the
    // reader is looking at the lab's own sheet, not at our reading of it.
    for (final s in shots) {
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(30, 30, 30, 30),
        build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(s.caption,
                  style: pw.TextStyle(font: sansBold, fontSize: 10, color: _ink)),
              pw.SizedBox(height: 10),
              pw.Expanded(
                child: pw.Center(
                    child: pw.Image(pw.MemoryImage(s.bytes),
                        fit: pw.BoxFit.contain)),
              ),
            ]),
      ));
    }

    return doc.save();
  }

  /// Print, save or send — one sheet, three answers.
  ///
  /// The same call the diet chart uses. `Printing.layoutPdf` puts print, save
  /// and share behind one tap, which is why the button does not say "Download":
  /// on a phone, downloading is the least likely of the three.
  static Future<void> present(Uint8List bytes) => Printing.layoutPdf(
        onLayout: (_) async => bytes,
        // Dated, because this file is generated repeatedly and two of them in a
        // Downloads folder must be tellable apart.
        name: 'ParentVeda-records-'
            '${DateTime.now().toIso8601String().substring(0, 10)}',
      );

  /// Attachments that are images, resolved to bytes.
  ///
  /// ⚠️ A FAILED RESOLVE IS SKIPPED, NOT FATAL. A ref can point at a cloud file
  /// on a phone that is offline. Losing the whole document because one photo
  /// would not download is the wrong trade — the summary is the part somebody
  /// is waiting on.
  static Future<List<_Shot>> _resolveShots(List<TtcRecordGroup> groups) async {
    final out = <_Shot>[];
    for (final g in groups) {
      for (final r in g.readings) {
        for (final ref in r.attachments) {
          if (!_isImage(ref)) continue;
          File? f;
          try {
            f = await StorageService.resolve(ref);
          } catch (_) {
            f = null;
          }
          if (f == null) continue;
          try {
            out.add(_Shot(
              bytes: await f.readAsBytes(),
              caption: '${g.label} — ${_date(r.takenOn)}',
            ));
          } catch (_) {
            // Unreadable on disk. Same call as above.
          }
        }
      }
    }
    return out;
  }

  /// The attachments a PDF cannot hold, named so their absence is visible.
  static List<String> _unshown(List<TtcRecordGroup> groups) {
    final out = <String>[];
    for (final g in groups) {
      for (final r in g.readings) {
        for (final ref in r.attachments) {
          if (!_isImage(ref)) out.add('${g.label} (${_date(r.takenOn)})');
        }
      }
    }
    return out;
  }

  /// ⚠️ EXTENSION, NOT CONTENT SNIFFING, AND THAT IS A REAL LIMIT. A ref with
  /// no extension reads as a non-image and gets named in "could not travel"
  /// rather than silently dropped. Guessing wrong toward naming it is the safe
  /// direction: the reader is told something exists, which is recoverable.
  static bool _isImage(String ref) {
    final r = ref.toLowerCase();
    return r.endsWith('.jpg') ||
        r.endsWith('.jpeg') ||
        r.endsWith('.png') ||
        r.endsWith('.webp');
  }
}
