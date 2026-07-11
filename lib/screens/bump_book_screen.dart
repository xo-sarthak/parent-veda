// =============================================================================
//  BumpBookScreen - "My Bump Journey Book"
// -----------------------------------------------------------------------------
//  An animated FLIPBOOK keepsake of the mother's weekly bump photos, ordered by
//  week. A warm, editorial, cream-paper feel: a cover page, one page per week
//  (week label, photo, caption + a gentle date/trimester note), and a closing
//  page - turned with a tasteful page-flip transition. Three ways to keep it:
//    * View in app  - the flipbook itself (the default view).
//    * Download     - a multi-page PDF that mirrors the on-screen keepsake.
//    * Order print  - a "coming soon" hardcover placeholder (no real commerce).
//
//  NOTE: BumpPhoto has no dedicated "notes" field - the model carries only a
//  `caption`. The "notes" line on each page/PDF is the derived date + trimester
//  meta (the only other per-photo context we have). Reuses the PDF/preview/share
//  pattern from services/journey_pdf.dart + screens/journey_booklet_screen.dart.
// =============================================================================

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_language.dart';
import '../models/bump_photo.dart';
import '../services/bump_store.dart';
import '../services/remote/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/storage_image.dart';

class BumpBookScreen extends StatefulWidget {
  const BumpBookScreen({super.key, required this.lang});
  final AppLanguage lang;

  @override
  State<BumpBookScreen> createState() => _BumpBookScreenState();
}

class _BumpBookScreenState extends State<BumpBookScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _busy = false;

  // Warm paper palette (kept in-file so the keepsake reads independently).
  static const Color _paper = Color(0xFFFBF4EA);
  static const Color _paperDeep = Color(0xFFF3E7D5);
  static const Color _ink = Color(0xFF4A3B36);
  static const Color _accent = Color(0xFFC97B6B);
  static const Color _accentDeep = Color(0xFF9E5546);

  bool get _en => widget.lang.isEnglish;
  String _t(String en, String hi) => _en ? en : hi;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final p = _controller.page?.round() ?? 0;
      if (p != _page && mounted) setState(() => _page = p);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BumpStore.instance,
      builder: (context, _) {
        final photos = BumpStore.instance.photos; // sorted by week, then date
        return Scaffold(
          backgroundColor: _paper,
          appBar: AppBar(
            backgroundColor: _paper,
            surfaceTintColor: _paper,
            elevation: 0,
            iconTheme: const IconThemeData(color: _accentDeep),
            title: Text(
              _t('My Bump Journey Book', 'Meri Bump Journey Book'),
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, color: _accentDeep, fontSize: 17),
            ),
            actions: photos.isEmpty
                ? null
                : [
                    IconButton(
                      tooltip: _t('Download', 'Download'),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _accentDeep),
                            )
                          : const Icon(Icons.download_rounded),
                      onPressed: _busy ? null : () => _download(photos),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded),
                      onSelected: (v) {
                        if (v == 'download') _download(photos);
                        if (v == 'print') _orderPrint();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'download',
                          child: Row(children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                size: 18, color: _accentDeep),
                            const SizedBox(width: 10),
                            Text(_t('Download PDF', 'PDF Download')),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'print',
                          child: Row(children: [
                            const Icon(Icons.menu_book_rounded,
                                size: 18, color: _accentDeep),
                            const SizedBox(width: 10),
                            Text(_t('Order printed copy', 'Print copy order')),
                          ]),
                        ),
                      ],
                    ),
                  ],
          ),
          body: photos.isEmpty ? _empty() : _flipbook(photos),
        );
      },
    );
  }

  // --- flipbook --------------------------------------------------------------
  Widget _flipbook(List<BumpPhoto> photos) {
    // Cover + one page per photo + closing.
    final total = photos.length + 2;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: total,
            itemBuilder: (context, index) {
              final Widget page;
              if (index == 0) {
                page = _coverPage(photos);
              } else if (index == total - 1) {
                page = _closingPage(photos);
              } else {
                page = _photoPage(photos[index - 1], index, photos.length);
              }
              return _flipWrap(index, page);
            },
          ),
        ),
        _indicator(total),
        const SizedBox(height: 8),
        _bottomBar(photos),
      ],
    );
  }

  // A tasteful 3D page-flip: hinge on the trailing edge, rotate + scale + fade
  // driven by the PageController's fractional offset. No external package.
  Widget _flipWrap(int index, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        double value = 0;
        if (_controller.hasClients && _controller.position.haveDimensions) {
          value = (_controller.page ?? _controller.initialPage.toDouble()) -
              index;
        }
        final t = value.clamp(-1.0, 1.0);
        final rotate = -t * (math.pi / 2.2);
        final scale = 1 - (t.abs() * 0.14);
        final opacity = (1 - t.abs() * 0.55).clamp(0.0, 1.0);
        return Transform(
          alignment: t <= 0 ? Alignment.centerRight : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(rotate),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }

  // A single cream "leaf" of the book (shared frame for every page).
  Widget _leaf({required Widget child}) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _paperDeep, width: 1.4),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x142D144C),
                  blurRadius: 18,
                  offset: Offset(0, 6)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );

  Widget _coverPage(List<BumpPhoto> photos) {
    final s = S(widget.lang);
    return _leaf(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_paper, _paperDeep],
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa_rounded, size: 34, color: _accent),
              const SizedBox(height: 22),
              Text(
                _t('My Bump\nJourney', 'Meri Bump\nJourney'),
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                    fontSize: 40,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    color: _accentDeep),
              ),
              const SizedBox(height: 18),
              Container(width: 70, height: 1.6, color: _accent),
              const SizedBox(height: 18),
              Text(
                _t('A keepsake of every week we grew together.',
                    'Har hafte ki ek pyaari yaad.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: _ink),
              ),
              const SizedBox(height: 30),
              Text(
                _t('${photos.length} weeks captured', '${photos.length} hafte'),
                style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: _accent),
              ),
              const SizedBox(height: 6),
              Text(
                '${s.jrWeekLabel(photos.first.weekNumber)} - ${s.jrWeekLabel(photos.last.weekNumber)}',
                style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.neutral500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPage(BumpPhoto b, int index, int totalPhotos) {
    final s = S(widget.lang);
    final note = '${s.trimesterName(b.weekNumber)} - ${s.formatShortDate(b.date)}';
    return _leaf(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo fills the top.
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: StorageImage(b.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.jrWeekLabel(b.weekNumber),
                  style: GoogleFonts.fraunces(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: _accentDeep),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: _accent),
                ),
                if (b.caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    b.caption.trim(),
                    style: GoogleFonts.fraunces(
                        fontSize: 15.5,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                        color: _ink),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  '$index / $totalPhotos',
                  style: GoogleFonts.manrope(
                      fontSize: 11, color: AppTheme.neutral400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _closingPage(List<BumpPhoto> photos) {
    return _leaf(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_paperDeep, _paper],
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_rounded, size: 30, color: _accent),
              const SizedBox(height: 20),
              Text(
                _t('The waiting was\nthe sweetest part.',
                    'Intezaar bhi\nkitna pyaara tha.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                    color: _accentDeep),
              ),
              const SizedBox(height: 18),
              Container(width: 60, height: 1.4, color: _accent),
              const SizedBox(height: 18),
              Text(
                _t('Keep this book, share it, or hold it in print one day.',
                    'Is book ko sambhaal ke rakhiye.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.5, color: _ink),
              ),
              const SizedBox(height: 28),
              Text('- ${s.appName} -',
                  style: GoogleFonts.manrope(
                      fontSize: 11, color: _accent)),
            ],
          ),
        ),
      ),
    );
  }

  S get s => S(widget.lang);

  Widget _indicator(int total) {
    // Dots when there are few pages; a compact "n / total" pill otherwise.
    if (total > 12) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _paperDeep)),
        child: Text('${_page + 1} / $total',
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentDeep)),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _page ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == _page ? _accent : _paperDeep,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }

  Widget _bottomBar(List<BumpPhoto> photos) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _download(photos),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accentDeep,
                  side: const BorderSide(color: _accent),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(_t('Download', 'Download'),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _orderPrint,
                style: FilledButton.styleFrom(
                  backgroundColor: _accentDeep,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(_t('Order print', 'Print order'),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );

  // --- empty -----------------------------------------------------------------
  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _paperDeep, shape: BoxShape.circle),
                child: const Icon(Icons.auto_stories_rounded,
                    size: 42, color: _accent),
              ),
              const SizedBox(height: 20),
              Text(
                _t('Your book is waiting', 'Aapki book taiyaar hai'),
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                    fontSize: 23, fontWeight: FontWeight.w500, color: _accentDeep),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                    'Add a few bump photos to your journey first, and they will bloom into a keepsake book here.',
                    'Pehle apni journey mein kuch bump photos add karein - yehi book ban jayengi.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 14, height: 1.5, color: AppTheme.neutral600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _accentDeep),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                label: Text(_t('Add bump photos', 'Bump photos add karein')),
              ),
            ],
          ),
        ),
      );

  // --- Download (multi-page PDF) ---------------------------------------------
  Future<void> _download(List<BumpPhoto> photos) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      // Resolve each stored reference (local path OR cloud object) to bytes.
      final resolved = <_BookPageData>[];
      for (final b in photos) {
        Uint8List? bytes;
        try {
          final f = await StorageService.resolve(b.imageUrl);
          if (f != null && f.existsSync()) bytes = await f.readAsBytes();
        } catch (_) {/* skip unreadable image */}
        resolved.add(_BookPageData(
          week: b.weekNumber,
          caption: b.caption.trim(),
          note: '${s.trimesterName(b.weekNumber)} - ${s.formatShortDate(b.date)}',
          imageBytes: bytes,
        ));
      }
      final pdfBytes = await _buildPdf(resolved);
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/parentveda_bump_book_$stamp.pdf');
      await file.writeAsBytes(pdfBytes);
      if (!mounted) return;
      navigator.push(MaterialPageRoute(
        builder: (_) =>
            _BumpBookPreviewScreen(bytes: pdfBytes, filePath: file.path, lang: widget.lang),
      ));
    } catch (_) {
      messenger.showSnackBar(SnackBar(
          content: Text(_t('Could not build the book. Please try again.',
              'Book nahi ban payi. Dobara try karein.'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _buildPdf(List<_BookPageData> pages) async {
    const cream = PdfColor.fromInt(0xFFFFF8F3);
    const paperDeep = PdfColor.fromInt(0xFFF3E7D5);
    const rose = PdfColor.fromInt(0xFFC97B6B);
    const roseDeep = PdfColor.fromInt(0xFF9E5546);
    const ink = PdfColor.fromInt(0xFF4A3B36);

    final serif = await PdfGoogleFonts.frauncesRegular();
    final serifBold = await PdfGoogleFonts.frauncesSemiBold();
    final body = await PdfGoogleFonts.nunitoRegular();
    final bodyItalic = await PdfGoogleFonts.nunitoItalic();

    final doc = pw.Document(
        title: _t('My Bump Journey', 'Meri Bump Journey'), author: s.appName);

    pw.Page decorated(pw.WidgetBuilder build) => pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.Stack(children: [
            pw.Positioned.fill(child: pw.Container(color: cream)),
            pw.Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: pw.Container(height: 10, color: paperDeep),
            ),
            pw.Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: pw.Container(height: 10, color: paperDeep),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(46, 54, 46, 54),
              child: build(context),
            ),
          ]),
        );

    // Cover.
    doc.addPage(decorated((context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('*',
                  style: pw.TextStyle(font: serif, fontSize: 30, color: rose)),
              pw.SizedBox(height: 22),
              pw.Text(_t('My Bump Journey', 'Meri Bump Journey'),
                  textAlign: pw.TextAlign.center,
                  style:
                      pw.TextStyle(font: serifBold, fontSize: 40, color: roseDeep)),
              pw.SizedBox(height: 18),
              pw.Container(width: 80, height: 1.5, color: rose),
              pw.SizedBox(height: 18),
              pw.Text(
                  _t('A keepsake of every week we grew together.',
                      'Har hafte ki ek pyaari yaad.'),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: bodyItalic, fontSize: 15, color: ink)),
              pw.SizedBox(height: 40),
              pw.Text(_t('${pages.length} weeks captured', '${pages.length} hafte'),
                  style: pw.TextStyle(font: body, fontSize: 12, color: rose)),
            ],
          ),
        )));

    // One page per week.
    for (final pgi in pages) {
      doc.addPage(decorated((context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text(_t('Week', 'Hafta'),
                    style: pw.TextStyle(font: serif, fontSize: 16, color: rose)),
                pw.SizedBox(width: 8),
                pw.Text('${pgi.week}',
                    style: pw.TextStyle(
                        font: serifBold, fontSize: 46, color: roseDeep, height: 0.9)),
                pw.Spacer(),
                pw.Text(pgi.note,
                    style: pw.TextStyle(font: body, fontSize: 12, color: rose)),
              ]),
              pw.SizedBox(height: 10),
              pw.Container(width: double.infinity, height: 1, color: paperDeep),
              pw.SizedBox(height: 18),
              if (pgi.imageBytes != null)
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(10),
                        boxShadow: [
                          pw.BoxShadow(
                              color: paperDeep,
                              blurRadius: 6,
                              offset: PdfPoint(0, 3)),
                        ],
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 6,
                        verticalRadius: 6,
                        child: pw.Image(pw.MemoryImage(pgi.imageBytes!),
                            fit: pw.BoxFit.cover),
                      ),
                    ),
                  ),
                )
              else
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(_t('(photo unavailable)', '(photo nahi mili)'),
                        style: pw.TextStyle(
                            font: bodyItalic, fontSize: 12, color: rose)),
                  ),
                ),
              if (pgi.caption.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(pgi.caption,
                    style: pw.TextStyle(
                        font: bodyItalic, fontSize: 14, color: ink, lineSpacing: 4)),
              ],
            ],
          )));
    }

    // Closing.
    doc.addPage(decorated((context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('<3',
                  style: pw.TextStyle(font: serif, fontSize: 24, color: rose)),
              pw.SizedBox(height: 20),
              pw.Text(_t('The waiting was the sweetest part.',
                  'Intezaar bhi kitna pyaara tha.'),
                  textAlign: pw.TextAlign.center,
                  style:
                      pw.TextStyle(font: serifBold, fontSize: 26, color: roseDeep)),
              pw.SizedBox(height: 18),
              pw.Container(width: 60, height: 1.4, color: rose),
              pw.SizedBox(height: 18),
              pw.Text('- ${s.appName} -',
                  style: pw.TextStyle(font: body, fontSize: 11, color: rose)),
            ],
          ),
        )));

    return doc.save();
  }

  // --- Order printed copy (placeholder) --------------------------------------
  void _orderPrint() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _paperDeep,
                        borderRadius: BorderRadius.circular(99))),
              ),
              const SizedBox(height: 20),
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _paperDeep, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.menu_book_rounded,
                    size: 26, color: _accentDeep),
              ),
              const SizedBox(height: 16),
              Text(
                _t('A printed hardcover, coming soon',
                    'Printed hardcover, jald aa rahi hai'),
                style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _accentDeep),
              ),
              const SizedBox(height: 10),
              Text(
                _t(
                    'We are crafting a beautiful lay-flat hardcover of your Bump Journey Book - printed on thick matte paper and delivered to your door. It is not quite ready yet, but we will let you know the moment it is.',
                    'Hum aapki Bump Journey Book ki ek sundar hardcover taiyaar kar rahe hain - motay matte paper par, aapke ghar tak. Abhi taiyaar nahi, par ready hote hi aapko bata denge.'),
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.55, color: _ink),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Intentionally disabled - no real commerce yet.
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_t(
                            'We will notify you when printed copies are ready.',
                            'Print copy ready hote hi hum aapko notify karenge.'))));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentDeep,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: Text(_t('Notify me', 'Mujhe notify karein'),
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _t('Ordering opens later - no charge today.',
                      'Ordering baad mein - abhi koi charge nahi.'),
                  style: GoogleFonts.manrope(
                      fontSize: 11.5, color: AppTheme.neutral500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// One week's data flattened for the PDF (image resolved to bytes off-screen).
class _BookPageData {
  _BookPageData({
    required this.week,
    required this.caption,
    required this.note,
    required this.imageBytes,
  });
  final int week;
  final String caption;
  final String note;
  final Uint8List? imageBytes;
}

// ---------------------------------------------------------------------------
//  In-app PDF preview + share (mirrors JourneyBookletScreen's preview).
// ---------------------------------------------------------------------------
class _BumpBookPreviewScreen extends StatelessWidget {
  const _BumpBookPreviewScreen({
    required this.bytes,
    required this.filePath,
    required this.lang,
  });
  final Uint8List bytes;
  final String filePath;
  final AppLanguage lang;

  Future<void> _share(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        text: lang.isEnglish
            ? 'My Bump Journey keepsake book'
            : 'Meri Bump Journey book',
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(
          content: Text(lang.isEnglish ? 'Could not share.' : 'Share nahi hua.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'My Bump Journey Book' : 'Bump Journey Book',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: lang.isEnglish ? 'Share' : 'Share',
            onPressed: () => _share(context),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => bytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: filePath.split('/').last,
      ),
    );
  }
}
