// =============================================================================
//  A diet chart as a real PDF — printable, shareable, and correct in Hindi
// -----------------------------------------------------------------------------
//  ⚠️ WHAT THIS REPLACES. The chart screen carried a "Download this chart"
//  button that called `downloadDietChartPlaceholder(id) {}` — an empty function
//  — and then raised a snackbar reading "Download starting shortly. It will
//  also be saved in your account." Nothing downloaded and nothing was saved.
//
//  ⚠️ THE FAILURE WAS THE CONFIRMATION, NOT THE MISSING FILE. A dead button
//  teaches her the app is unfinished and she moves on. A button that says it
//  worked sends her to look for a file that was never created, and quietly
//  devalues every other confirmation the app gives her. Whether to build this
//  or to remove the button was a real choice; what was never defensible was
//  leaving a lie in place.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THIS WAS CHEAP, AND WHY THAT WAS NOT OBVIOUS
//  ---------------------------------------------------------------------------
//  The instinct is that a PDF means a new dependency and a week of layout work.
//  Neither was true here, and finding that out took one look at `pubspec.yaml`:
//
//    · `pdf` and `printing` are ALREADY dependencies — the care poster and the
//      journey booklet both generate PDFs today.
//    · The one genuinely hard part was ALREADY SOLVED. Fraunces, Nunito and
//      Manrope carry no Devanagari glyphs, so a Hindi PDF comes out as blank
//      boxes; `lib/services/pdf_fonts.dart` exists because somebody hit exactly
//      that and fixed it properly.
//
//  The general lesson is worth more than the feature: **before estimating a
//  feature as expensive, check whether the expensive part is already in the
//  repo.** A codebase this size usually has the hard half done somewhere, for a
//  different reason, by someone who is no longer in the conversation.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT REFUSES RATHER THAN SHIPPING BLANK BOXES
//  ---------------------------------------------------------------------------
//  `PdfGoogleFonts` fetches over the network, and on failure the package falls
//  back to Helvetica — which has no Devanagari either. So an offline Hindi
//  export degrades to precisely the bug `pdf_fonts.dart` was written to prevent.
//  `PdfFontSet.load` reports `complete`, and [build] returns null when it is
//  false.
//
//  Returning null rather than throwing is deliberate: the caller has to decide
//  what to tell her, and there is exactly one honest thing to say — "we could
//  not build this offline, try again on a connection". A thrown exception would
//  reach her as a crash dialog, and a silent success would hand her a document
//  full of empty rectangles that she might print and take to a doctor.
// =============================================================================

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/diet_chart_content.dart';
import '../data/nutrition_data.dart';
import '../localization/app_language.dart';
import 'pdf_fonts.dart';

/// Quiet, printable colours. Deliberately NOT the app's lavender: a chart is
/// printed on a home or clinic printer, often in greyscale, and a mid-tone
/// tint that reads as calm on screen reads as muddy grey on paper. Ink on
/// near-white survives both.
const PdfColor _ink = PdfColor.fromInt(0xFF211D26);
const PdfColor _ink2 = PdfColor.fromInt(0xFF4A4351);
const PdfColor _muted = PdfColor.fromInt(0xFF6E6577);
const PdfColor _line = PdfColor.fromInt(0xFFDDD7E2);
const PdfColor _band = PdfColor.fromInt(0xFFF4F1F7);

class DietChartPdf {
  const DietChartPdf._();

  /// Builds the document, or **null** if the fonts for [lang] could not all be
  /// resolved. See the header: null means "do not show her anything", not
  /// "something went slightly wrong".
  static Future<Uint8List?> build({
    required DietChart chart,
    required ChartContent content,
    required AppLanguage lang,
  }) async {
    final fonts = await PdfFontSet.load(lang);
    if (!fonts.complete) return null;

    final serif = fonts.serif;
    final serifBold = fonts.serifBold;
    final body = fonts.body;
    final sansBold = fonts.sansBold;

    String tr(LocalizedText t) => t.of(lang);

    final doc = pw.Document(
      title: tr(chart.title),
      author: 'ParentVeda',
    );

    pw.Widget heading(String s) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 18, bottom: 7),
          child: pw.Text(s,
              style: pw.TextStyle(font: sansBold, fontSize: 11, color: _ink)),
        );

    pw.Widget bullet(String s) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
                width: 3,
                height: 3,
                margin: const pw.EdgeInsets.only(top: 5, right: 7),
                decoration: const pw.BoxDecoration(
                    color: _muted, shape: pw.BoxShape.circle)),
            pw.Expanded(
                child: pw.Text(s,
                    style: pw.TextStyle(
                        font: body, fontSize: 9.5, lineSpacing: 1.6, color: _ink2))),
          ]),
        );

    // ⚠️ A TABLE, NOT A LIST OF PARAGRAPHS. This is the one place the PDF
    // should differ from the screen rather than mirror it. On paper a chart is
    // scanned — she is looking for "what is lunch on day two" while standing in
    // a kitchen — and a two-column row per meal answers that in one glance. The
    // in-app version can afford to read as prose because she is holding it.
    pw.Widget dayTable(ChartDay d) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              color: _band,
              child: pw.Text(tr(d.label),
                  style: pw.TextStyle(
                      font: sansBold, fontSize: 10, color: _ink)),
            ),
            for (final m in d.meals)
              pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(color: _line, width: 0.6))),
                padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 78,
                        child: pw.Text(tr(m.meal),
                            style: pw.TextStyle(
                                font: sansBold, fontSize: 9, color: _muted)),
                      ),
                      pw.Expanded(
                          child: pw.Text(tr(m.items),
                              style: pw.TextStyle(
                                  font: body,
                                  fontSize: 9.5,
                                  lineSpacing: 1.5,
                                  color: _ink))),
                    ]),
              ),
            pw.SizedBox(height: 12),
          ],
        );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 44),
      // ⚠️ THE FOOTER CARRIES THE DISCLAIMER, ON EVERY PAGE. On screen a
      // disclaimer at the foot of a scroll is read once. A printed chart gets
      // stuck to a fridge and its second page is read alone for four months, so
      // the page that survives on its own must carry it too.
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerLeft,
        margin: const pw.EdgeInsets.only(top: 10),
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6))),
        child: pw.Text(
          lang.isHindi
              ? 'ParentVeda · यह एक आम मार्गदर्शन है, इलाज या सलाह नहीं। अपने '
                  'डॉक्टर की बात सबसे ऊपर रखिए। · पेज ${context.pageNumber}/${context.pagesCount}'
              : 'ParentVeda · General guidance, not medical advice. Your '
                  'doctor comes first. · Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: body, fontSize: 7.5, color: _muted),
        ),
      ),
      build: (context) => [
        pw.Text(tr(chart.title),
            style: pw.TextStyle(font: serifBold, fontSize: 20, color: _ink)),
        pw.SizedBox(height: 8),
        pw.Text(tr(content.focus),
            style: pw.TextStyle(
                font: body, fontSize: 10, lineSpacing: 1.7, color: _ink2)),
        pw.SizedBox(height: 16),

        heading(lang.isHindi ? 'तीन दिन, विस्तार से' : 'Three worked days'),
        for (final d in content.days) dayTable(d),

        heading(lang.isHindi ? 'बदल कर क्या ले सकती हैं' : 'Swaps'),
        for (final s in content.swaps) bullet(tr(s)),

        heading(lang.isHindi ? 'किन चीज़ों में कमी रखें' : 'Go easy on'),
        for (final s in content.limits) bullet(tr(s)),

        // Only where a clinician owns the decision — see ChartContent.
        if (content.doctorNote != null) ...[
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(11),
            decoration: pw.BoxDecoration(
                color: _band,
                border: pw.Border.all(color: _line, width: 0.6),
                borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(tr(content.doctorNote!),
                style: pw.TextStyle(
                    font: serif, fontSize: 9.5, lineSpacing: 1.6, color: _ink)),
          ),
        ],
      ],
    ));

    return doc.save();
  }

  /// Hands it to the OS: print, save as PDF, or send to any app that takes one.
  ///
  /// ⚠️ ONE SHEET, THREE ANSWERS — WHICH IS WHY THE BUTTON NO LONGER SAYS
  /// "DOWNLOAD". `Printing.layoutPdf` offers print, save and share together, so
  /// the mother who wants it on her fridge, the one who wants it in her files
  /// and the one who wants it on her mother-in-law's WhatsApp all get what they
  /// came for from the same tap. "Download" named only one of those three, and
  /// on a phone it is the least likely.
  static Future<void> present({
    required DietChart chart,
    required Uint8List bytes,
  }) =>
      Printing.layoutPdf(
        onLayout: (_) async => bytes,
        // Becomes the filename when saved or shared, so it must survive being
        // seen out of context in a Downloads folder six weeks later.
        name: 'ParentVeda-${slugForFilename(chart.id)}',
      );

  /// ⚠️ BUILT FROM `chart.id`, NOT FROM THE TITLE. A title is `LocalizedText`,
  /// so slugging it would produce a Devanagari filename in the Hindi build —
  /// which some file managers and most printers handle badly, and which makes
  /// the same chart arrive under two different names depending on a setting.
  /// The id is the identity; the title is display. Same `.en`-is-identity rule
  /// CLAUDE.md names, reaching a place nobody expects it.
  static String slugForFilename(String chartId) => chartId
      .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '')
      .replaceAll('_', '-');
}
