// =============================================================================
//  Fonts for generated PDFs, chosen by language
// -----------------------------------------------------------------------------
//  Fraunces, Nunito and Manrope carry NO Devanagari glyphs. That was harmless
//  while the exports were English or Latin-script Hinglish, and stopped being
//  harmless the moment the content became Devanagari: the same string that
//  renders correctly on screen comes out of the PDF as blank boxes.
//
//  This is a nastier failure than the on-screen equivalent. A screen can be
//  glanced at and fixed; a keepsake book is generated once, saved, printed, and
//  sent to family. Nobody re-reads the PDF pipeline afterwards.
//
//  WHY MUKTA AND NOT A SERIF. The `printing` package ships notoSansDevanagari
//  and Mukta, and no Devanagari SERIF at all. So the serif/sans distinction the
//  English layouts lean on cannot survive in Hindi, and pretending otherwise by
//  mixing a Latin serif with a Devanagari sans would give the two languages
//  visibly different books. Mukta is also what lib/theme/pv_fonts.dart already
//  picked for Devanagari on screen, so the PDF matches the app rather than
//  inventing a third look.
//
//  ⚠️ PdfGoogleFonts FETCHES OVER THE NETWORK. On failure the package falls back
//  to Helvetica, which has no Devanagari either — so an offline Hindi export
//  degrades to exactly the bug this file exists to fix. [PdfFontSet.load]
//  reports whether every font resolved so a caller can refuse rather than hand
//  the mother a book full of empty boxes.
// =============================================================================

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../localization/app_language.dart';

class PdfFontSet {
  const PdfFontSet({
    required this.serif,
    required this.serifBold,
    required this.body,
    required this.bodyItalic,
    required this.sans,
    required this.sansBold,
    required this.complete,
  });

  final pw.Font serif;
  final pw.Font serifBold;
  final pw.Font body;

  /// Devanagari has no true italic. In Hindi this is the regular weight, so a
  /// layout that leans on italic for emphasis loses that emphasis rather than
  /// getting a mechanically slanted face, which is what a synthetic oblique
  /// would do to the shirorekha.
  final pw.Font bodyItalic;

  final pw.Font sans;
  final pw.Font sansBold;

  /// False when any font had to fall back — see the network note above.
  final bool complete;

  static Future<PdfFontSet> load(AppLanguage lang) async {
    var ok = true;
    Future<pw.Font> f(Future<pw.Font> Function() get,
        Future<pw.Font> Function() fallback) async {
      try {
        return await get();
      } catch (_) {
        ok = false;
        return await fallback();
      }
    }

    if (lang.isHindi) {
      final regular = await f(PdfGoogleFonts.muktaRegular,
          PdfGoogleFonts.notoSansDevanagariRegular);
      final medium = await f(PdfGoogleFonts.muktaMedium,
          PdfGoogleFonts.notoSansDevanagariMedium);
      final bold = await f(
          PdfGoogleFonts.muktaBold, PdfGoogleFonts.notoSansDevanagariBold);
      return PdfFontSet(
        serif: medium,
        serifBold: bold,
        body: regular,
        bodyItalic: regular,
        sans: regular,
        sansBold: bold,
        complete: ok,
      );
    }

    // Helvetica is BUILT IN to the pdf package (no network, no Unicode). It is
    // an acceptable last resort for English and never reached for Hindi, where
    // the fallback above is another Devanagari face instead.
    Future<pw.Font> helv() async => pw.Font.helvetica();
    Future<pw.Font> helvBold() async => pw.Font.helveticaBold();
    Future<pw.Font> helvOblique() async => pw.Font.helveticaOblique();

    return PdfFontSet(
      serif: await f(PdfGoogleFonts.frauncesRegular, helv),
      serifBold: await f(PdfGoogleFonts.frauncesSemiBold, helvBold),
      body: await f(PdfGoogleFonts.nunitoRegular, helv),
      bodyItalic: await f(PdfGoogleFonts.nunitoItalic, helvOblique),
      sans: await f(PdfGoogleFonts.manropeRegular, helv),
      sansBold: await f(PdfGoogleFonts.manropeExtraBold, helvBold),
      complete: ok,
    );
  }
}
