// =============================================================================
//  ScanReportViewerScreen — actually looking at the report she saved
// -----------------------------------------------------------------------------
//  ⚠️ THIS SCREEN IS THE HALF OF "MY REPORTS" THAT WAS NEVER BUILT.
//
//  The list could store a report and delete a report. It could not SHOW one.
//  A row rendered its title, its date and a file count, and the only control on
//  it was a bin — so the single most likely reason to open the door ("where did
//  I put that report?") ended at a row that named the thing and would not open
//  it.
//
//  The shape of that bug is worth naming because it recurs: the feature was
//  built along the axis of the DATA (add, persist, remove) rather than the axis
//  of the QUESTION she arrived with (show me). Everything in the store was
//  correct. Nothing read it back.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TWO FILE KINDS, TWO VIEWERS, AND NEITHER IS NEW CODE
//  ---------------------------------------------------------------------------
//  A report is a photograph or a PDF, because the picker offers camera, gallery
//  and PDF and a mother uses all three — a clinic hands over paper, a lab
//  emails a file.
//
//    · images -> `StorageImage` inside an `InteractiveViewer`, the same pair
//      `photo_viewer_screen.dart` already uses. `StorageImage` matters
//      specifically here: it resolves BOTH a local path and a Supabase Storage
//      reference, so a report still opens after it has been uploaded and the
//      local file has gone.
//    · PDFs   -> `PdfPreview`, the house pattern from `bump_book_screen.dart`.
//
//  Neither is a new engine. Prompt §11, and the same reasoning the reports
//  screen used when it reached for the existing attachment picker.
//
//  ⚠️ ENGLISH ONLY FOR NOW — every string is `_en(...)`, matching the rest of
//  this door. `grep -c '_en('` is the size of the Hindi backlog.
// =============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/storage_service.dart';
import '../../services/scan_reports_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/storage_image.dart';
import '../v2/v2_palette.dart';
import 'scan_report_edit_screen.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class ScanReportViewerScreen extends StatelessWidget {
  const ScanReportViewerScreen(
      {super.key, required this.reportId, required this.pregnancy});

  /// ⚠️ THE ID, NOT THE REPORT.
  ///
  /// This screen has an Edit button that changes the very object it is
  /// rendering. Holding a `ScanReport` value would mean the screen kept showing
  /// the pre-edit copy after the editor returned — the title in the app bar
  /// would still be the old one, and she would have to back out and re-enter to
  /// see her own change. Holding the id and re-reading the store on every build
  /// makes that impossible by construction.
  final String reportId;

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ScanReportsStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final lang = S.current;
          final r = _find();

          // ⚠️ DELETING FROM INSIDE THE VIEWER POPS RATHER THAN RENDERING
          // NOTHING. The store notifies before this route is popped, so for one
          // frame the screen is asked to draw a report that no longer exists.
          // An empty scaffold is the honest thing to show in that frame.
          if (r == null) return Scaffold(backgroundColor: p.ground);

          final d = DateTime.tryParse(r.dateIso);
          final scan = r.scanId == null ? null : _scanById(r.scanId!);

          return Scaffold(
            backgroundColor: p.ground,
            appBar: AppBar(
              backgroundColor: p.ground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              foregroundColor: p.ink1,
              title: Text(r.title,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
              actions: [
                IconButton(
                  tooltip: 'Edit',
                  icon: Icon(Icons.edit_outlined, size: 20, color: p.ink2),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      settings:
                          const RouteSettings(name: 'scans/reports/edit'),
                      builder: (_) => ScanReportEditScreen(
                          reportId: r.id, pregnancy: pregnancy),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
              children: [
                // ---- What this is, and when -------------------------------
                Text(
                    [
                      if (d != null) _fmt(d),
                      '${r.files.length} '
                          '${r.files.length == 1 ? 'file' : 'files'}',
                    ].join('  ·  '),
                    style: pvManrope(fontSize: 12.5, color: p.ink3)),
                if (scan != null) ...[
                  const SizedBox(height: 12),
                  _ScanChip(label: scan.name.of(lang), p: p),
                ],
                if (r.note.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(r.note,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.55, color: p.ink2)),
                  ),
                ],
                const SizedBox(height: 20),

                // ---- The files themselves ----------------------------------
                //
                // ⚠️ THE PAGE OPENS ON THE DOCUMENT, NOT ON A LIST OF LINKS.
                // A single-file report — which is most of them — should be
                // readable the moment the screen appears, with no second tap.
                // So each file renders its own preview at a usable size and
                // tapping only ever means "bigger".
                if (r.files.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                        _en('This report has no files attached.').of(lang),
                        style: pvManrope(
                            fontSize: 13.5, height: 1.5, color: p.ink2)),
                  )
                else
                  for (int i = 0; i < r.files.length; i++) ...[
                    _FileCard(
                      file: r.files[i],
                      index: i,
                      total: r.files.length,
                      p: p,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings: const RouteSettings(
                              name: 'scans/reports/file'),
                          builder: (_) => _FullFileScreen(
                              file: r.files[i], title: r.title),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                const SizedBox(height: 14),
                // ⚠️ DELETE LIVES DOWN HERE, PAST THE DOCUMENT. On the list it
                // sat beside a row, which meant a report could be destroyed
                // without ever being looked at. Here she has necessarily
                // scrolled past the thing itself first — and the confirm
                // dialog's warning ("this might be your only copy") is a claim
                // she can now check rather than take on trust.
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, r, p, lang),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFB3261E)),
                  label: Text(_en('Remove this report').of(lang),
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB3261E))),
                ),
              ],
            ),
          );
        },
      );

  ScanReport? _find() {
    for (final r in ScanReportsStore.instance.reports) {
      if (r.id == reportId) return r;
    }
    return null;
  }

  Future<void> _confirmDelete(BuildContext context, ScanReport r, V2Palette p,
      AppLanguage lang) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(_en('Remove this report?').of(lang),
            style: pvFraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
        content: Text(_en('This might be your only copy.').of(lang),
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_en('Keep it').of(lang),
                  style:
                      pvManrope(fontWeight: FontWeight.w700, color: p.ink2))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_en('Remove').of(lang),
                  style: pvManrope(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB3261E)))),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    await ScanReportsStore.instance.remove(r.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

TestScanInfo? _scanById(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

/// The scan this report belongs to, when she has said.
class _ScanChip extends StatelessWidget {
  const _ScanChip({required this.label, required this.p});

  final String label;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: p.action.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: p.action)),
        ),
      );
}

// -----------------------------------------------------------------------------
//  One file, previewed in place
// -----------------------------------------------------------------------------

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.file,
    required this.index,
    required this.total,
    required this.p,
    required this.onOpen,
  });

  final ReportFile file;
  final int index;
  final int total;
  final V2Palette p;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 1) ...[
            Text('${index + 1} of $total  ·  ${file.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: p.ink3)),
            const SizedBox(height: 7),
          ],
          Material(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onOpen,
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: file.isPdf
                    // ⚠️ A PDF IS NOT RENDERED INLINE, AND THAT IS DELIBERATE.
                    // `PdfPreview` brings its own scroll view and toolbar;
                    // nesting one inside this page's ListView gives two
                    // competing scrollers on the same gesture. So the card is a
                    // cover that opens the real viewer.
                    ? _PdfCover(name: file.name, p: p)
                    : StorageImage(file.path, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      );
}

class _PdfCover extends StatelessWidget {
  const _PdfCover({required this.name, required this.p});

  final String name;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 40, color: p.ink3),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink2)),
            ),
            const SizedBox(height: 6),
            Text('Tap to open',
                style: pvManrope(fontSize: 12, color: p.ink3)),
          ],
        ),
      );
}

// -----------------------------------------------------------------------------
//  Full screen — the actual document
// -----------------------------------------------------------------------------

class _FullFileScreen extends StatelessWidget {
  const _FullFileScreen({required this.file, required this.title});

  final ReportFile file;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (file.isPdf) return _PdfScreen(file: file, title: title);

    // Black ground and a zoomable image, exactly as PhotoViewerScreen does it.
    // A report photographed in clinic light is often only readable zoomed, so
    // `maxScale` is higher here than on a memory photo: she is reading 8pt
    // print off a phone camera shot, not admiring a bump picture.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(title,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 8,
          child: StorageImage(file.path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// A stored PDF, resolved to a local file and handed to the house viewer.
class _PdfScreen extends StatefulWidget {
  const _PdfScreen({required this.file, required this.title});

  final ReportFile file;
  final String title;

  @override
  State<_PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<_PdfScreen> {
  // ⚠️ RESOLVED THROUGH `StorageService`, NOT READ STRAIGHT OFF `path`.
  //
  // A report that has been uploaded holds a Storage reference rather than a
  // local file path, and `File(ref).readAsBytes()` on one of those throws a
  // file-not-found she would read as "my report is gone". `resolve` handles
  // both shapes and downloads-and-caches when it has to — the same call
  // `StorageImage` makes for the image case.
  late final Future<Uint8List?> _bytes = _load();

  Future<Uint8List?> _load() async {
    try {
      final f = await StorageService.resolve(widget.file.path);
      if (f == null) return null;
      return await f.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text(widget.title,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
                fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: FutureBuilder<Uint8List?>(
        future: _bytes,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final b = snap.data;
          if (b == null) {
            // ⚠️ A MISSING FILE IS EXPLAINED, NOT CRASHED THROUGH. The most
            // likely cause is a phone-storage clean-up that took the original,
            // and she deserves to be told that rather than shown a spinner
            // that never ends.
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                  'This file could not be opened. It may have been moved or '
                  'removed from your phone.',
                  style: pvManrope(
                      fontSize: 14, height: 1.55, color: p.ink2)),
            );
          }
          return PdfPreview(
            build: (format) => b,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: widget.file.name,
          );
        },
      ),
    );
  }
}
