// =============================================================================
//  LetterBookPdf — the Dear Baby letters as a book, made at birth
// -----------------------------------------------------------------------------
//  The vault's keepsake PDF (STILL-OPEN §83.2, REMAINING-CHANGES 8 + 12). It
//  is offered only once the letters have opened at birth (DearBabyVaultStore),
//  so it is a book given to the child, not a draft.
//
//  The same build as `JourneyPdf` (pdf + printing, `PdfFontSet`, an in-app
//  preview, the share sheet), in the vault's own look rather than the journey
//  booklet's blush: the letter paper, the one ink, a week seal, the date in
//  italic serif. A page per letter, the trimester named above the first
//  letter of each, a cover and a closing page.
//
//  ⚠️ MULTIPAGE, NOT PAGE. A spoken letter is a transcription and can run
//  long; a fixed `pw.Page` throws on overflow. Each letter starts a new page
//  (`pw.NewPage`) and a long one simply continues on the next.
//
//  ⚠️ THE FONT FOLLOWS THE WORDS, NOT ONLY THE APP LANGUAGE. A mother on the
//  English app may still write to her baby in Devanagari; English fonts would
//  print that as empty boxes. Any Devanagari in any letter loads the Hindi
//  set, which carries Latin as well.
// =============================================================================

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../localization/app_language.dart';
import 'daily_store.dart';
import 'pdf_fonts.dart';

/// One letter as it will be printed.
class LetterBookItem {
  const LetterBookItem({
    required this.entry,
    required this.fruit,
    required this.trimesterLabel,
  });
  final TalkEntry entry;
  final String? fruit;

  /// Set on the first letter of a trimester, null on the rest.
  final String? trimesterLabel;
}

class LetterBookPdf {
  LetterBookPdf._();

  static const _paper = PdfColor.fromInt(0xFFFBF7F0);
  static const _line = PdfColor.fromInt(0xFFE4D9C8);
  static const _ink = PdfColor.fromInt(0xFF2F2C30);
  static const _ink2 = PdfColor.fromInt(0xFF5E5860);
  static const _ink3 = PdfColor.fromInt(0xFF8C8590);

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  static int _trimester(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);
  static const _trimesterNames = {
    1: 'First trimester',
    2: 'Second trimester',
    3: 'Third trimester',
  };

  /// The page plan: oldest first, the trimester named on its first letter.
  /// Pure, so a test can hold the order without building a PDF.
  static List<LetterBookItem> plan(
    List<TalkEntry> entries, {
    String? Function(int week)? fruitOf,
  }) {
    final sorted = [...entries.where((e) => e.text.trim().isNotEmpty)]
      ..sort((a, b) {
        final d = a.dateIso.compareTo(b.dateIso);
        return d != 0 ? d : a.week.compareTo(b.week);
      });
    int? t;
    return [
      for (final e in sorted)
        LetterBookItem(
          entry: e,
          fruit: e.week > 0 ? fruitOf?.call(e.week) : null,
          trimesterLabel: () {
            if (e.week <= 0) return null;
            final now = _trimester(e.week);
            if (now == t) return null;
            t = now;
            return _trimesterNames[now];
          }(),
        ),
    ];
  }

  static final _devanagari = RegExp(r'[ऀ-ॿ]');

  static Future<Uint8List> build({
    required List<LetterBookItem> items,
    required AppLanguage lang,
    String? childName,
    DateTime? bornOn,
  }) async {
    final hindiWords = items.any((i) => _devanagari.hasMatch(i.entry.text));
    final fonts = await PdfFontSet.load(
        hindiWords ? AppLanguage.hinglish : lang);
    final to = childName ?? 'our baby';

    final theme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(64, 72, 64, 64),
      buildBackground: (_) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: _paper),
      ),
    );

    final weeks = [for (final i in items) if (i.entry.week > 0) i.entry.week];
    final span = weeks.isEmpty
        ? null
        : (weeks.first == weeks.last
            ? 'Written in week ${weeks.first}'
            : 'Written from week ${weeks.reduce((a, b) => a < b ? a : b)} '
                'to week ${weeks.reduce((a, b) => a > b ? a : b)}');

    final doc = pw.Document(title: 'Letters to $to', author: 'ParentVeda');

    // ---- Cover ----
    doc.addPage(pw.Page(
      pageTheme: theme,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('DEAR BABY',
              style: pw.TextStyle(
                  font: fonts.sansBold, fontSize: 10, letterSpacing: 2, color: _ink3)),
          pw.SizedBox(height: 16),
          pw.Text('Letters to\n$to',
              style: pw.TextStyle(
                  font: fonts.serifBold, fontSize: 44, lineSpacing: 2, color: _ink)),
          pw.SizedBox(height: 22),
          pw.Container(width: 56, height: 1.2, color: _ink),
          pw.SizedBox(height: 22),
          pw.Text(
            '${items.length == 1 ? 'One letter' : '${items.length} letters'}'
            '${span == null ? '' : '. $span'}.',
            style: pw.TextStyle(font: fonts.body, fontSize: 13, color: _ink2),
          ),
          if (bornOn != null) ...[
            pw.SizedBox(height: 6),
            pw.Text('Opened the day you were born, ${_date(bornOn)}.',
                style: pw.TextStyle(font: fonts.bodyItalic, fontSize: 13, color: _ink2)),
          ],
        ],
      ),
    ));

    // ---- The letters: each on its own page, a long one runs on ----
    doc.addPage(pw.MultiPage(
      pageTheme: theme,
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${ctx.pageNumber}',
            style: pw.TextStyle(font: fonts.body, fontSize: 9, color: _ink3)),
      ),
      build: (_) => [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) pw.NewPage(),
          ..._letter(items[i], fonts),
        ],
      ],
    ));

    // ---- Closing ----
    doc.addPage(pw.Page(
      pageTheme: theme,
      build: (_) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(width: 56, height: 1.2, color: _ink),
            pw.SizedBox(height: 22),
            pw.Text('Every word here was written\nwhile you were on your way.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    font: fonts.serif, fontSize: 20, lineSpacing: 6, color: _ink)),
            pw.SizedBox(height: 30),
            pw.Text('ParentVeda',
                style: pw.TextStyle(
                    font: fonts.sansBold, fontSize: 9, letterSpacing: 2, color: _ink3)),
          ],
        ),
      ),
    ));

    return doc.save();
  }

  static List<pw.Widget> _letter(LetterBookItem item, PdfFontSet fonts) {
    final e = item.entry;
    final date = DateTime.tryParse(e.dateIso);
    return [
      if (item.trimesterLabel != null) ...[
        pw.Text(item.trimesterLabel!.toUpperCase(),
            style: pw.TextStyle(
                font: fonts.sansBold, fontSize: 9, letterSpacing: 1.8, color: _ink3)),
        pw.SizedBox(height: 18),
      ],
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        if (e.week > 0) ...[
          // The seal: the week, stamped.
          pw.Container(
            width: 52,
            height: 52,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: _ink, width: 1.1),
            ),
            child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
              pw.Text('WEEK',
                  style: pw.TextStyle(
                      font: fonts.sansBold, fontSize: 6.5, letterSpacing: 0.8, color: _ink2)),
              pw.Text('${e.week}',
                  style: pw.TextStyle(font: fonts.serifBold, fontSize: 18, color: _ink)),
            ]),
          ),
          pw.SizedBox(width: 14),
        ],
        pw.Expanded(
          child: pw.Text(date == null ? e.dateIso : _date(date),
              style: pw.TextStyle(font: fonts.bodyItalic, fontSize: 14, color: _ink2)),
        ),
        pw.Text(e.spoken ? 'Spoken' : 'Written',
            style: pw.TextStyle(font: fonts.body, fontSize: 10, color: _ink3)),
      ]),
      pw.SizedBox(height: 22),
      if (e.prompt.trim().isNotEmpty) ...[
        pw.Text(e.prompt.trim(),
            style: pw.TextStyle(font: fonts.sansBold, fontSize: 10.5, color: _ink3)),
        pw.SizedBox(height: 10),
      ],
      pw.Paragraph(
        text: e.text.trim(),
        style: pw.TextStyle(font: fonts.serif, fontSize: 16, lineSpacing: 7, color: _ink),
      ),
      if (item.fruit != null && item.fruit!.trim().isNotEmpty) ...[
        pw.SizedBox(height: 14),
        pw.Container(height: 0.8, color: _line),
        pw.SizedBox(height: 10),
        pw.Text('You that week: the size of ${item.fruit!.trim().toLowerCase()}',
            style: pw.TextStyle(font: fonts.body, fontSize: 11, color: _ink2)),
      ],
    ];
  }
}
