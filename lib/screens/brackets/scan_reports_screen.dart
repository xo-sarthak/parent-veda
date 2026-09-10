// =============================================================================
//  ScanReportsScreen — "My reports"
// -----------------------------------------------------------------------------
//  Scans & tests V2, door 2.
//
//  ⚠️ THIS IS THE BEST DOOR IN THE HUB AND IT WAS NOT IN V1 AT ALL.
//
//  V1 had six doors and none of them answered "where did I put that report?" —
//  which is the question most likely to make someone open this section twice.
//  The other two doors are read; this one leaves something behind, and what it
//  leaves makes both of the others better: a stored report is what the decoder
//  reads from, and what she carries to the next appointment.
//
//  ⚠️ NO NEW UPLOAD ENGINE — prompt §11. `showAttachmentPicker` already does
//  camera / gallery / PDF and ships today; `uploadAttachments` handles
//  durability. This screen is a list, a picker call and a store.
//
//  ⚠️ THAT SECOND SENTENCE USED TO READ "`uploadAttachments` ALREADY HANDLES
//  DURABILITY" AND IT WAS NOT TRUE. This file imported `pp_attachments.dart`
//  for the picker, so the function was one line away and in scope, and `_add`
//  stored `a.path` — the raw camera path — straight into the store. Nothing
//  was ever uploaded. `scan_reports_store.dart` carried a matching claim at its
//  own head, so two files documented a call that did not exist.
//
//  ⚠️ AND IT WAS INVISIBLE FROM THE APP. Reports listed, opened, and survived a
//  restart, because `shared_preferences` and a local file path are enough for
//  every case except the one that matters: a new phone. The failure had no
//  symptom until the moment there was nothing anyone could do about it.
//
//  The general form, which has now shown up four times in one review: **a
//  comment describing work that has not happened reads as a decision somebody
//  is tracking.** Nobody was tracking any of them.
//
//  KNOWN STYLING DEBT: the picker sheet is styled with `pp_common` (the
//  parenting palette), so it arrives purple inside a V3 screen. Reusing it is
//  still right — a second picker would be exactly the duplication the
//  reconciliation forbids — but it is on the list in
//  docs/SCANS-HUB-RECONCILIATION.md.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scan_reports_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/storage_image.dart';
import '../post_pregnancy/pp_attachments.dart';
import '../v2/v2_palette.dart';
import 'hub/hub_solution_cards.dart';
import 'scan_report_viewer_screen.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The locker, on its own screen.
///
/// ⚠️ THIS IS NOW A WRAPPER, AND THE MOVE WAS ADDITIVE. Everything it used to
/// do lives in [ScanReportsBody]; this keeps the app bar, the ground and the
/// route so nothing that already opens `scans/reports` changed. The body was
/// split out so the Scans door can render the locker IN PLACE on its "My
/// reports" tab — the brief calls that tab a tool screen, and the locker is the
/// tool.
class ScanReportsScreen extends StatelessWidget {
  const ScanReportsScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = S.current;
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(_en('My reports').of(lang),
                style: pvManrope(
                    fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            children: [ScanReportsBody(pregnancy: pregnancy)],
          ),
        );
      },
    );
  }
}

/// The locker itself — the rows, the empty state and the add flow — without a
/// Scaffold or an app bar.
///
/// ⚠️ A COLUMN, NOT A LIST, for the reason [ScanTimelineBody] gives: a
/// scrolling widget inside another scrolling widget is either unbounded or a
/// nested scroll nobody can drive with a thumb. Whoever renders this does the
/// scrolling.
class ScanReportsBody extends StatefulWidget {
  const ScanReportsBody({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  State<ScanReportsBody> createState() => _ScanReportsScreenState();
}

/// What the "Which one is this?" sheet settles: a title, and optionally a scan.
///
/// ⚠️ TWO FACTS, NOT ONE, AND CONFLATING THEM WAS THE DEFECT. The sheet used to
/// return `TestScanInfo?`, so "which scan" and "what to call it" were one
/// answer — and the only way to say "none of these" was null, which stored the
/// literal title "Report". A mother with four unnamed documents got four rows
/// reading "Report" and had to open each to tell them apart.
///
/// A scan id links into the library; a title is what she calls it. Most reports
/// in a pregnancy folder — a thyroid panel, a referral letter, a discharge
/// summary — have the second and not the first.
class _ReportNaming {
  const _ReportNaming(this.title, this.scanId);
  final String title;
  final String? scanId;
}

class _ScanReportsScreenState extends State<ScanReportsBody> {
  @override
  void initState() {
    super.initState();
    ScanReportsStore.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [ScanReportsStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = ScanReportsStore.instance;
        final reports = store.reports;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              if (reports.isEmpty)
                _Empty(p: p, lang: lang)
              else ...[
                Text(
                    _en('Newest first. Everything stays on your phone.')
                        .of(lang),
                    style:
                        pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
                const SizedBox(height: 16),
                for (final r in reports) ...[
                  _ReportRow(
                    report: r,
                    p: p,
                    lang: lang,
                    // ⚠️ THE ROW OPENS THE REPORT. It used to open nothing —
                    // the only control on it was a bin, so the door built to
                    // answer "where did I put that report?" could name the
                    // report and would not show it.
                    onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings:
                            const RouteSettings(name: 'scans/reports/view'),
                        builder: (_) => ScanReportViewerScreen(
                            reportId: r.id, pregnancy: widget.pregnancy),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, r, p, lang),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 22),
              SolutionCard(
                type: SolutionType.tool,
                title: _en('Add a report'),
                value: _en('Take a photo, or add a PDF.'),
                p: p,
                lang: lang,
                onTap: () => _add(context),
              ),
              const SizedBox(height: 20),
              // ⚠️ OFF, KEPT FOR REVERT. It read "Clinics usually keep the
              // original. Keep your own copy, the next doctor will ask."
              // Removed per review: the screen's own empty state already says
              // why keeping reports matters, so this repeated it a second time
              // on the same page.
              //
              // Text(
              //     _en('Clinics usually keep the original. Keep your own '
              //             'copy, the next doctor will ask.')
              //         .of(lang),
              //     style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
          ],
        );
      },
    );
  }

  Future<void> _add(BuildContext context) async {
    // ⚠️ The picker is the app's existing one. Camera, gallery, PDF — all three
    // already work, and all three matter here: a lab may email a PDF, a clinic
    // may hand over paper.
    final picked = await showAttachmentPicker(context);
    if (picked.isEmpty || !context.mounted) return;

    final named = await _askWhichScan(context);
    if (!context.mounted) return;

    // ⚠️ THE LINE THAT WAS MISSING. `uploadAttachments` returns copies pointing
    // at Storage, and keeps the LOCAL path for anything that fails — signed
    // out, offline, upload rejected — so a report is never dropped for want of
    // a network. `ScanReport.needsBackup` reads those paths, which is why the
    // "on this phone only" line is always true rather than a remembered flag.
    //
    // Awaited rather than fired off: a photograph is a few hundred KB, this is
    // the moment she is already waiting, and the alternative is a row that
    // claims to be saved while its bytes are still in flight.
    final stored = await uploadAttachments(picked, 'report');

    final now = DateTime.now();
    await ScanReportsStore.instance.add(ScanReport(
      // The app generates the id, so a later cloud copy shares this identity
      // and syncing is a merge rather than a duplicate.
      id: 'rep_${now.microsecondsSinceEpoch}',
      title: named.title,
      dateIso: now.toIso8601String(),
      // ⚠️ DEFAULTED, NEVER ASKED. Today is right for the common case — a
      // report photographed the day it was handed over — and the editor
      // corrects the case it is wrong. See `ScanReport.reportDateIso`.
      reportDateIso: now.toIso8601String(),
      scanId: named.scanId,
      files: stored
          .map((a) =>
              ReportFile(path: a.path, name: a.name, isPdf: a.isPdf))
          .toList(),
    ));
  }

  /// Ask her to type a name for something the library does not know.
  ///
  /// ⚠️ THE CASE THIS EXISTS FOR IS THE COMMON ONE, NOT THE EDGE ONE. The scan
  /// list covers the imaging the app knows about; a thyroid panel, a referral
  /// letter and a discharge summary are none of those, and they are most of
  /// what accumulates in a pregnancy folder. Skipping the sheet used to store
  /// the literal title "Report" — so a mother with four unnamed documents saw
  /// four rows called "Report" and had to open each one to tell them apart.
  Future<String?> _askName(BuildContext context) async {
    final p = V2PaletteStore.instance.current;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.ground,
        title: Text('What is this report?',
            style: pvFraunces(
                fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          style: pvManrope(fontSize: 14, color: p.ink1),
          decoration: InputDecoration(
            hintText: 'Thyroid panel, referral letter…',
            hintStyle: pvManrope(fontSize: 14, color: p.ink3),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Skip', style: pvManrope(fontSize: 13, color: p.ink3)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: Text('Save',
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ],
      ),
    );
    controller.dispose();
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Optional, and skippable. ⚠️ Naming the scan is a convenience, never a
  /// gate — a report we cannot classify is still a report she needs to keep.
  Future<_ReportNaming> _askWhichScan(BuildContext context) async {
    final p = V2PaletteStore.instance.current;
    final lang = S.current;

    final picked = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
          children: [
            Center(
                child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: p.line,
                        borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text(_en('Which one is this?').of(lang),
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
            const SizedBox(height: 6),
            Text(_en('Optional. Just makes it easier to find.').of(lang),
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
            const SizedBox(height: 16),
            for (final s in kTestsScans.take(12))
              _pickRow(ctx, s.name.of(lang), () => Navigator.pop(ctx, s), p),
            // ⚠️ THE ROW THAT WAS MISSING, AND IT IS NOT THE EDGE CASE. The
            // twelve above are the imaging the app knows about. A thyroid
            // panel, a referral letter and a discharge summary are none of
            // them, and together they are most of what accumulates in a folder.
            _pickRow(ctx, _en('Type a name').of(lang),
                () => Navigator.pop(ctx, _kTypeName), p),
            _pickRow(ctx, _en('Not sure / something else').of(lang),
                () => Navigator.pop(ctx, null), p),
          ],
        ),
      ),
    );

    if (!context.mounted) return const _ReportNaming('Report', null);

    if (picked is TestScanInfo) {
      // ⚠️ `.en`, NOT `.of(lang)`. The title is stored, and a stored value is
      // identity: saving the Hindi label would file the same scan under two
      // different names depending on a setting she can change afterwards. Same
      // rule CLAUDE.md names, in the place it is easiest to get wrong.
      return _ReportNaming(picked.name.en, picked.id);
    }
    if (picked == _kTypeName) {
      final typed = await _askName(context);
      // She opened the box and closed it again. That is "skip", not an error.
      return _ReportNaming(typed ?? 'Report', null);
    }
    return const _ReportNaming('Report', null);
  }

  /// Sentinel for the "Type a name" row. A private const object rather than a
  /// magic string, so nothing can collide with a real value coming back.
  static const Object _kTypeName = Object();

  Widget _pickRow(
          BuildContext ctx, String label, VoidCallback onTap, V2Palette p) =>
      InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
        ),
      );

  Future<void> _confirmDelete(BuildContext context, ScanReport r, V2Palette p,
      AppLanguage lang) async {
    // ⚠️ CONFIRMED, ALWAYS. This may be the only copy of a document that was
    // handed back at the clinic.
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(_en('Remove this report?').of(lang),
            style: pvFraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
        content: Text(
            _en('This might be your only copy.').of(lang),
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_en('Keep it').of(lang),
                  style: pvManrope(
                      fontWeight: FontWeight.w700, color: p.ink2))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_en('Remove').of(lang),
                  style: pvManrope(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB3261E)))),
        ],
      ),
    );
    if (yes == true) await ScanReportsStore.instance.remove(r.id);
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow(
      {required this.report,
      required this.p,
      required this.lang,
      required this.onOpen,
      required this.onDelete});

  final ScanReport report;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE REPORT'S OWN DATE, NOT THE UPLOAD DATE. `reportDateIso` falls back
    // to `dateIso`, so a library recorded before that field existed reads
    // exactly as it did.
    final d = DateTime.tryParse(report.reportDateIso);
    final n = report.files.length;
    final unsafe = report.needsBackup;

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ A THUMBNAIL, BECAUSE A TITLE IS NOT HOW SHE RECOGNISES A
              // REPORT. Several will be called the same thing — "Growth scan"
              // three times across the third trimester — and the picture is
              // what tells them apart at a glance. PDFs get an icon; there is
              // nothing to thumbnail without rendering a page, and rendering
              // nine of them to draw a list would cost more than it returns.
              _Thumb(report: report, p: p),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(
                        '${d == null ? '' : _fmt(d)}'
                        '${d == null ? '' : ' · '}'
                        '$n ${n == 1 ? 'file' : 'files'}',
                        style: pvManrope(fontSize: 12, color: p.ink3)),

                    // ---- backup state ---------------------------------------
                    //
                    // ⚠️ SHOWN ONLY WHEN IT IS NOT SAFE, AND THAT IS THE WHOLE
                    // DESIGN. A "Backed up" tick on every row would put a
                    // status label on every medical document she owns, and turn
                    // a folder into a dashboard she has to audit. Silence means
                    // safe; the line appears exactly when there is something to
                    // know.
                    //
                    // ⚠️ IT NAMES THE FACT, NOT THE FEAR. "Only on this phone"
                    // is what is true. "Not backed up" describes the same state
                    // as a failure, and on a scan report that reads as "you may
                    // have lost this" — which is not what it means, and is a
                    // thing to say to a pregnant woman only when it is true.
                    //
                    // ⚠️ AND IT IS DERIVED FROM THE FILE PATHS. Nothing stores
                    // "backed up" as a flag, so this cannot go stale after she
                    // signs out. See `ScanReport.needsBackup`.
                    if (unsafe) ...[
                      const SizedBox(height: 5),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.phone_iphone_rounded,
                            size: 12, color: p.ink3),
                        const SizedBox(width: 5),
                        Text('Only on this phone',
                            style: pvManrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.ink3)),
                      ]),
                    ],
                  ],
                ),
              ),
              // ⚠️ DELETE STAYS ON THE ROW. It is the one control that already
              // shipped here, and taking it away to "tidy up" would trade a
              // working one-tap action for a longer path to the same place.
              // The viewer offers it too, past the document — see there for
              // why that copy is the safer of the two.
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: 19, color: p.ink3),
                tooltip: 'Remove',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 6),
                child: Icon(Icons.chevron_right_rounded,
                    size: 19, color: p.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

/// The first file, small — or a PDF mark when that is what it is.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.report, required this.p});

  final ScanReport report;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final first = report.files.isEmpty ? null : report.files.first;
    final showImage = first != null && !first.isPdf;

    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: showImage
          ? StorageImage(first.path, fit: BoxFit.cover)
          : Icon(
              first == null
                  ? Icons.description_outlined
                  : Icons.picture_as_pdf_outlined,
              size: 20,
              color: p.ink3),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.p, required this.lang});

  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_en('Nothing here yet').of(lang),
              style: pvFraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: p.ink1)),
          const SizedBox(height: 10),
          Text(
              _en('Add your reports here and they stay in one place. '
                      'A photo is enough.')
                  .of(lang),
              style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        ],
      );
}
