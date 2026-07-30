// =============================================================================
//  CarePosterPdf — the poster a partner actually prints
// -----------------------------------------------------------------------------
//  The PNG export next to this is for a phone screen and a WhatsApp send. This
//  is for paper, and the difference is not resolution — it is that the QR is
//  VECTOR.
//
//  A 1080px PNG upscaled to A4 gives a QR whose modules have soft edges. Some
//  scanners cope; a phone camera in a dim waiting room, at an angle, on a
//  poster behind glass, often does not. A vector QR is mathematically exact at
//  any size, which is the whole reason to bother with a PDF at all.
//
//  Two pages, deliberately:
//
//    A4      one poster for the waiting-room wall.
//    A5 x2   two per sheet, to cut in half — a reception desk, a consulting
//            room, a prescription-pad cover. A clinic wants several copies and
//            will not pay for four separate prints.
//
//  Same content rules as the screen poster (care_qr_poster.dart), for the same
//  reason: A PATIENT READS THIS. No money, the partner's name largest after the
//  QR, the code printed for anyone who cannot scan, ours a small mark at the
//  foot.
//
//  Follows the house pattern in journey_pdf.dart — pdf + printing, both already
//  in pubspec, fonts via PdfGoogleFonts so nothing has to be bundled.
// =============================================================================

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'care_partner_models.dart';

class CarePosterPdf {
  CarePosterPdf._();

  // The app palette, as print colours.
  static const _ink = PdfColor.fromInt(0xFF2D144C);
  static const _soft = PdfColor.fromInt(0xFF69636C);
  static const _purple = PdfColor.fromInt(0xFF6A30B6);
  static const _panel = PdfColor.fromInt(0xFFF3EEF7);
  static const _border = PdfColor.fromInt(0xFFE7DFEE);
  static const _muted = PdfColor.fromInt(0xFFA99CBB);

  /// Build the print pack: an A4 poster, then an A5-pair sheet.
  static Future<Uint8List> build({
    required CarePartner partner,
    required String link,
    required String token,
  }) async {
    // PdfGoogleFonts FETCHES over the network and falls back to Helvetica when
    // it cannot. Helvetica has no Unicode support, so a partner name carrying
    // any non-ASCII character — an accent, a Devanagari word in an
    // organisation's name — would come out broken ON PAPER, silently.
    //
    // So each load is guarded, and Helvetica is only ever reached deliberately.
    // OPEN POINT for launch: bundling the two TTFs would remove the network
    // dependency entirely and guarantee the brand on a printed sheet. Recorded
    // in docs/STILL-OPEN.md.
    final serif = await _font(PdfGoogleFonts.frauncesSemiBold);
    final sans = await _font(PdfGoogleFonts.manropeRegular);
    final sansBold = await _font(PdfGoogleFonts.manropeExtraBold);

    final doc = pw.Document(
      // A fallback chain, so a glyph the display font lacks still prints
      // instead of becoming a blank box.
      theme: pw.ThemeData.withFont(
        base: sans,
        bold: sansBold,
        fontFallback: [sans, sansBold, serif],
      ),
      title: 'ParentVeda — ${partner.name}',
      author: 'ParentVeda',
      // What it is, not who it is for: PDF metadata travels with the file and a
      // print shop can see it.
      subject: 'Referral poster',
    );

    // ---- page 1: A4, one poster ------------------------------------------
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => _poster(
        partner: partner,
        link: link,
        token: token,
        serif: serif,
        sans: sans,
        sansBold: sansBold,
        qrSize: 210,
        nameSize: 30,
        scale: 1.0,
      ),
    ));

    // ---- page 2: A4 holding two A5 posters, to cut ------------------------
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(children: [
        pw.Expanded(
          child: _poster(
            partner: partner,
            link: link,
            token: token,
            serif: serif,
            sans: sans,
            sansBold: sansBold,
            qrSize: 132,
            nameSize: 21,
            scale: 0.72,
          ),
        ),
        // The cut line. Dashed, so it reads as an instruction rather than a
        // border somebody tries to trim to.
        pw.Container(
          height: 1,
          child: pw.Row(
            children: List.generate(
              90,
              (i) => pw.Expanded(
                child: pw.Container(
                  height: 0.7,
                  color: i.isEven ? _border : PdfColors.white,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: _poster(
            partner: partner,
            link: link,
            token: token,
            serif: serif,
            sans: sans,
            sansBold: sansBold,
            qrSize: 132,
            nameSize: 21,
            scale: 0.72,
          ),
        ),
      ]),
    ));

    return doc.save();
  }

  /// Load a font, or fall back rather than throw. A poster that fails to build
  /// is worse than one set in Helvetica.
  static Future<pw.Font> _font(Future<pw.Font> Function() load) async {
    try {
      return await load();
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  static pw.Widget _poster({
    required CarePartner partner,
    required String link,
    required String token,
    required pw.Font serif,
    required pw.Font sans,
    required pw.Font sansBold,
    required double qrSize,
    required double nameSize,
    required double scale,
  }) {
    final pad = 34.0 * scale;
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      color: PdfColors.white,
      padding: pw.EdgeInsets.all(pad),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            partner.trust.safePrimary.toUpperCase(),
            style: pw.TextStyle(
                font: sansBold, fontSize: 10 * scale, color: _soft,
                letterSpacing: 2.6),
          ),
          pw.SizedBox(height: 8 * scale),
          pw.Text(
            partner.name,
            textAlign: pw.TextAlign.center,
            maxLines: 2,
            style: pw.TextStyle(font: serif, fontSize: nameSize, color: _ink),
          ),
          if (partner.subtitle.isNotEmpty) ...[
            pw.SizedBox(height: 6 * scale),
            pw.Text(
              partner.subtitle,
              textAlign: pw.TextAlign.center,
              maxLines: 2,
              style: pw.TextStyle(
                  font: sans, fontSize: 11.5 * scale, color: _soft),
            ),
          ],
          pw.SizedBox(height: 26 * scale),

          // The QR, drawn as vector paths. This is the point of the PDF.
          pw.Container(
            padding: pw.EdgeInsets.all(14 * scale),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _border, width: 0.8),
              borderRadius: pw.BorderRadius.circular(16 * scale),
            ),
            child: pw.BarcodeWidget(
              data: link,
              barcode: Barcode.qrCode(
                // Medium: survives a scuffed, sun-faded poster without making
                // the pattern so dense a camera struggles across a desk.
                errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
              ),
              width: qrSize,
              height: qrSize,
              drawText: false,
              color: PdfColors.black,
            ),
          ),

          pw.SizedBox(height: 20 * scale),
          pw.Text('Scan to join ParentVeda',
              style: pw.TextStyle(
                  font: sansBold, fontSize: 15 * scale, color: _ink)),
          pw.SizedBox(height: 6 * scale),
          pw.Text(
            'Week-by-week guidance for pregnancy and the early years.',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                font: sans, fontSize: 11 * scale, color: _soft),
          ),

          pw.SizedBox(height: 18 * scale),
          // The fallback has to be ON THE PAPER: a cracked camera, an older
          // patient, bad light — and on iOS manual entry is the only mechanism
          // there is, because Apple has no install referrer.
          pw.Container(
            padding: pw.EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 8 * scale),
            decoration: pw.BoxDecoration(
              color: _panel,
              borderRadius: pw.BorderRadius.circular(9 * scale),
            ),
            child: pw.Text(
              'Or enter code  $token',
              style: pw.TextStyle(
                  font: sansBold, fontSize: 12 * scale, color: _purple),
            ),
          ),

          pw.Spacer(),
          pw.Text('ParentVeda',
              style: pw.TextStyle(
                  font: sansBold,
                  fontSize: 10 * scale,
                  color: _muted,
                  letterSpacing: 0.6)),
        ],
      ),
    );
  }

  /// Hand it to the OS: the print dialog, save as PDF, or any app that takes
  /// one. `printing` gives all three from a single sheet, so a partner with a
  /// clinic printer never has to leave the app.
  static Future<void> present({
    required CarePartner partner,
    required Uint8List bytes,
  }) =>
      Printing.layoutPdf(
        onLayout: (_) async => bytes,
        // Becomes the filename when saved or shared.
        name: 'ParentVeda-${_slug(partner.name)}-poster',
      );

  static Future<void> share({
    required CarePartner partner,
    required Uint8List bytes,
  }) =>
      Printing.sharePdf(
        bytes: bytes,
        filename: 'ParentVeda-${_slug(partner.name)}-poster.pdf',
      );

  @visibleForTesting
  static String debugSlug(String s) => _slug(s);

  static String _slug(String s) => s
      .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
}
