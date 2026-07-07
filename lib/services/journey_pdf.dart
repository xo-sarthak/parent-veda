// =============================================================================
//  JourneyPdf
// -----------------------------------------------------------------------------
//  Builds the week-40 keepsake: a warm, blush-and-cream multi-page PDF booklet
//  of the mother's journey. A cover page, one page per week that has a memory
//  (journal entry and/or photos), and a closing message - with an elegant serif
//  for the week numbers and gentle botanical accents in the page corners.
//  "A keepsake booklet a mother gives her child years later."
// =============================================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../localization/app_language.dart';

/// A week that has something worth keeping (text and/or photos).
class JourneyWeek {
  JourneyWeek({
    required this.week,
    required this.dateRange,
    required this.text,
    required this.photoPaths,
  });

  final int week;
  final String dateRange;
  final String text;
  final List<String> photoPaths;

  bool get hasContent => text.trim().isNotEmpty || photoPaths.isNotEmpty;
}

class JourneyPdf {
  // Warm keepsake palette (blush / cream / soft rose / sage).
  static const _cream = PdfColor.fromInt(0xFFFFF8F3);
  static const _blush = PdfColor.fromInt(0xFFFBE6DD);
  static const _rose = PdfColor.fromInt(0xFFC97B6B);
  static const _roseDeep = PdfColor.fromInt(0xFF9E5546);
  static const _ink = PdfColor.fromInt(0xFF4A3B36);
  static const _sage = PdfColor.fromInt(0xFFB7C9A8);
  static const _sageDeep = PdfColor.fromInt(0xFF8FA87C);

  /// Builds the booklet bytes from the [weeks] that have content (any order;
  /// sorted ascending here). [completionDate] is a pre-formatted date string.
  static Future<Uint8List> build({
    required AppLanguage lang,
    required List<JourneyWeek> weeks,
    required String completionDate,
  }) async {
    final s = S(lang);
    final doc = pw.Document(
      title: s.bookletCoverTitle,
      author: s.appName,
    );

    final serif = await PdfGoogleFonts.frauncesRegular();
    final serifBold = await PdfGoogleFonts.frauncesSemiBold();
    final bodyFont = await PdfGoogleFonts.nunitoRegular();
    final bodyItalic = await PdfGoogleFonts.nunitoItalic();

    final content = [...weeks.where((w) => w.hasContent)]
      ..sort((a, b) => a.week.compareTo(b.week));

    // ---- Cover ----
    doc.addPage(_decoratedPage(
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('❀', style: pw.TextStyle(font: serif, fontSize: 34, color: _rose)),
            pw.SizedBox(height: 24),
            pw.Text(
              s.bookletCoverTitle,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: serifBold, fontSize: 40, color: _roseDeep),
            ),
            pw.SizedBox(height: 18),
            pw.Container(width: 80, height: 1.5, color: _rose),
            pw.SizedBox(height: 18),
            pw.Text(
              s.bookletCoverSubtitle,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: bodyItalic, fontSize: 15, color: _ink),
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              s.bookletCompletedOn(completionDate),
              style: pw.TextStyle(font: bodyFont, fontSize: 12, color: _rose),
            ),
          ],
        ),
      ),
    ));

    // ---- One page per week with content ----
    for (final w in content) {
      doc.addPage(_decoratedPage(
        build: (context) => _weekPage(
          w: w,
          s: s,
          serif: serif,
          serifBold: serifBold,
          bodyFont: bodyFont,
          bodyItalic: bodyItalic,
        ),
      ));
    }

    // ---- Closing ----
    doc.addPage(_decoratedPage(
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('♥', style: pw.TextStyle(font: serif, fontSize: 30, color: _rose)),
            pw.SizedBox(height: 22),
            pw.Text(
              s.bookletClosingTitle,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: serifBold, fontSize: 28, color: _roseDeep),
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              constraints: const pw.BoxConstraints(maxWidth: 360),
              child: pw.Text(
                s.bookletClosingBody,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: bodyItalic, fontSize: 15, color: _ink, lineSpacing: 5),
              ),
            ),
            pw.SizedBox(height: 36),
            pw.Text('- ${s.appName} -',
                style: pw.TextStyle(font: bodyFont, fontSize: 11, color: _rose)),
          ],
        ),
      ),
    ));

    return doc.save();
  }

  // ---- A single week's page: header, journal body, photos ----
  static pw.Widget _weekPage({
    required JourneyWeek w,
    required S s,
    required pw.Font serif,
    required pw.Font serifBold,
    required pw.Font bodyFont,
    required pw.Font bodyItalic,
  }) {
    final body = w.text.trim().isNotEmpty ? w.text.trim() : s.bookletEmptyEntry;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header - big serif week number + date range.
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              s.weekWord,
              style: pw.TextStyle(font: serif, fontSize: 16, color: _rose),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              '${w.week}',
              style: pw.TextStyle(font: serifBold, fontSize: 46, color: _roseDeep, height: 0.9),
            ),
            pw.Spacer(),
            pw.Text(
              w.dateRange,
              style: pw.TextStyle(font: bodyFont, fontSize: 12, color: _rose),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(width: double.infinity, height: 1, color: _blush),
        pw.SizedBox(height: 20),
        // Journal body.
        pw.Text(
          body,
          style: pw.TextStyle(
            font: w.text.trim().isEmpty ? bodyItalic : bodyFont,
            fontSize: 14,
            color: _ink,
            lineSpacing: 5,
          ),
        ),
        pw.SizedBox(height: 24),
        // Photos: 1 = centered large, 2 = side by side.
        if (w.photoPaths.isNotEmpty)
          pw.Expanded(child: _photos(w.photoPaths)),
      ],
    );
  }

  static pw.Widget _photos(List<String> paths) {
    final images = <pw.ImageProvider>[];
    for (final p in paths.take(2)) {
      try {
        final f = File(p);
        if (f.existsSync()) images.add(pw.MemoryImage(f.readAsBytesSync()));
      } catch (_) {/* skip unreadable */}
    }
    if (images.isEmpty) return pw.SizedBox();
    if (images.length == 1) {
      return pw.Center(child: _framedPhoto(images.first));
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _framedPhoto(images[0])),
        pw.SizedBox(width: 14),
        pw.Expanded(child: _framedPhoto(images[1])),
      ],
    );
  }

  static pw.Widget _framedPhoto(pw.ImageProvider img) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        boxShadow: [
          pw.BoxShadow(color: _blush, blurRadius: 6, offset: PdfPoint(0, 3)),
        ],
      ),
      child: pw.ClipRRect(
        horizontalRadius: 6,
        verticalRadius: 6,
        child: pw.Image(img, fit: pw.BoxFit.cover),
      ),
    );
  }

  // ---- A cream page with botanical corner accents wrapping [build] ----
  static pw.Page _decoratedPage({required pw.WidgetBuilder build}) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Stack(
        children: [
          pw.Positioned.fill(child: pw.Container(color: _cream)),
          // Soft botanical accents, top-left and bottom-right.
          pw.Positioned(
            left: -14,
            top: -14,
            child: pw.CustomPaint(size: const PdfPoint(150, 150), painter: _botanical),
          ),
          pw.Positioned(
            right: -14,
            bottom: -14,
            child: pw.Transform.rotate(
              angle: 3.14159,
              child: pw.CustomPaint(size: const PdfPoint(150, 150), painter: _botanical),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(48, 56, 48, 56),
            child: build(context),
          ),
        ],
      ),
    );
  }

  // Gentle leaves-and-berries sprig drawn in the corner.
  static void _botanical(PdfGraphics canvas, PdfPoint size) {
    final w = size.x;
    // A curving stem.
    canvas
      ..setStrokeColor(_sageDeep)
      ..setLineWidth(1.4)
      ..moveTo(w * 0.12, w * 0.12)
      ..curveTo(w * 0.35, w * 0.22, w * 0.5, w * 0.45, w * 0.62, w * 0.66)
      ..strokePath();
    // Leaves along the stem.
    final leafSpots = [
      [w * 0.26, w * 0.20],
      [w * 0.40, w * 0.34],
      [w * 0.52, w * 0.50],
    ];
    canvas.setFillColor(_sage);
    for (final p in leafSpots) {
      canvas
        ..saveContext()
        ..drawEllipse(p[0], p[1], w * 0.085, w * 0.04)
        ..fillPath()
        ..restoreContext();
    }
    // Blush berries.
    canvas.setFillColor(_blush);
    canvas
      ..drawEllipse(w * 0.16, w * 0.30, w * 0.035, w * 0.035)
      ..fillPath()
      ..drawEllipse(w * 0.30, w * 0.42, w * 0.03, w * 0.03)
      ..fillPath();
  }
}
