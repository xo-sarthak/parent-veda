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
import '../../widgets/pv_feedback.dart';
import '../../widgets/storage_image.dart';
import '../post_pregnancy/pp_attachments.dart';
import '../v2/v2_palette.dart';
import '../doors/pv_door_chrome.dart' show PvDoorRailCard, PvDoorSingleRail, PvDoorToolScaffold, PvDoorDisclaimer;
import 'hub/hub_solution_cards.dart' show SolutionMeta, SolutionType;
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
              // ⚠️ THE ADD IS FIRST, NOT LAST — 2026-09-19, the user's
              // review: with reports stacking up, the add row sank under
              // them and she scrolled to the bottom to add. Fi and
              // Superpower put the add above the list (an "Upload" pill,
              // an "+ Add" pill by the heading). The row sits above the
              // list, the empty state below it says why.
              _AddRow(p: p, lang: lang, onTap: () => _add(context)),
              const SizedBox(height: 10),
              // ⚠️ THE LOCKER IS AN ENTRY — option A, the user's call
              // 2026-09-19. Every records app on Mobbin (Superpower, Fi,
              // Apple Health, Claude's "1 file" pill) gives the list its own
              // screen; none puts records on a page about something else.
              // So the tab holds two rows — add, and "Your reports · N" with
              // the last-added line under it — and the two articles beneath
              // stay in view whether she has none or forty. The list, the
              // search, the scan pills and the month groups are one tap in
              // (`ScanReportsAllScreen`). The newest-five list is kept for
              // revert in `_grouped`.
              _YourReportsRow(
                reports: reports,
                p: p,
                lang: lang,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    settings: const RouteSettings(name: 'scans/reports/all'),
                    builder: (_) => ScanReportsAllScreen(pregnancy: widget.pregnancy),
                  ),
                ),
              ),
              // The door adds its own 26 before the next heading; nothing here.
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

  void _openReport(BuildContext context, ScanReport r) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'scans/reports/view'),
        builder: (_) =>
            ScanReportViewerScreen(reportId: r.id, pregnancy: widget.pregnancy),
      ));

  /// Rows under month headings ("September 2026"), newest first. Kept for
  /// revert of the newest-five tab (option C).
  // ignore: unused_element
  List<Widget> _grouped(List<ScanReport> rs, V2Palette p, AppLanguage lang,
      {required void Function(ScanReport) onOpen}) {
    final out = <Widget>[];
    String? month;
    for (final r in rs) {
      final d = DateTime.tryParse(r.reportDateIso) ?? DateTime.now();
      final m = '${_kMonthsLong[d.month - 1]} ${d.year}';
      if (m != month) {
        month = m;
        out.add(Padding(
          padding: EdgeInsets.only(top: out.isEmpty ? 4 : 18, bottom: 4),
          child: Text(m.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3)),
        ));
      }
      out.add(_ReportRow(
        report: r,
        p: p,
        lang: lang,
        onOpen: () => onOpen(r),
        onDelete: () {},
      ));
    }
    return out;
  }

  Future<void> _add(BuildContext context) => addReport(context, widget.pregnancy);

  /// The add flow, shared with `ScanReportsAllScreen`: picker → "Which one
  /// is this?" → upload → store → a toast.
  static Future<void> addReport(BuildContext context, PregnancyController pregnancy) async {
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
    // The add answers (Fi's "Uploads completed", DESIGN-SYSTEM §4.0c): a
    // hum and one floating line naming what landed.
    pvCommitFeedback();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added · ${named.title}'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  /// Ask her to type a name for something the library does not know.
  ///
  /// ⚠️ THE CASE THIS EXISTS FOR IS THE COMMON ONE, NOT THE EDGE ONE. The scan
  /// list covers the imaging the app knows about; a thyroid panel, a referral
  /// letter and a discharge summary are none of those, and they are most of
  /// what accumulates in a pregnancy folder. Skipping the sheet used to store
  /// the literal title "Report" — so a mother with four unnamed documents saw
  /// four rows called "Report" and had to open each one to tell them apart.
  static Future<String?> _askName(BuildContext context) async {
    final p = V2PaletteStore.instance.current;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.ground,
        title: Text("What's this report?",
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
    // ⚠️ NOT DISPOSED THE MOMENT THE ROUTE CLOSES (2026-10-02, the red screen '_dependents.isEmpty'): the TextField is still on screen for the exit animation and still listening. Same fix as the add-child sheet.
    Future<void>.delayed(const Duration(milliseconds: 600), controller.dispose);
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Optional, and skippable. ⚠️ Naming the scan is a convenience, never a
  /// gate — a report we cannot classify is still a report she needs to keep.
  /// "Report · 19 Sep" — the name a skipped sheet gives, so two unnamed
  /// reports are not both "Report" (the user, 2026-09-19).
  static String _dayName() {
    final d = DateTime.now();
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Report · ${d.day} ${m[d.month - 1]}';
  }

  static Future<_ReportNaming> _askWhichScan(BuildContext context) async {
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
            Text(_en('Optional. It makes it easier to find.').of(lang),
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

    if (!context.mounted) return _ReportNaming(_dayName(), null);

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
      return _ReportNaming(typed ?? _dayName(), null);
    }
    return _ReportNaming(_dayName(), null);
  }

  /// Sentinel for the "Type a name" row. A private const object rather than a
  /// magic string, so nothing can collide with a real value coming back.
  static const Object _kTypeName = Object();

  static Widget _pickRow(
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
          // The compact row (2026-09-19): a hairline under, no card — the
          // same object as the article rows beneath it. Was a bordered
          // card, radius 18.
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.line)),
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
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: p.ink1)),
                    const SizedBox(height: 3),
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
              // The trash left the row (2026-09-19, the user's review of the
              // locker; Fi and Superpower keep delete off the list). Remove
              // lives in the viewer, past the document, where the warning
              // "this might be your only copy" can be checked. Kept for
              // revert:
              //   IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline))
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
        color: Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface), // was surfaceAlt
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

/// The add action as a full-width hairline box: a plus in a neutral well,
/// "Add a report", "A photo of the paper, or the PDF".
class _AddRow extends StatelessWidget {
  const _AddRow({required this.p, required this.lang, required this.onTap});

  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final well = Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface);
    return PvPress(
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: p.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: well, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.add_rounded, size: 22, color: p.ink1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_en('Add a report').of(lang),
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                      const SizedBox(height: 2),
                      Text(_en('A photo of the paper, or the PDF').of(lang),
                          style: pvManrope(fontSize: 12.5, color: p.ink2)),
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      ),
    );
  }
}

const List<String> _kMonthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "All reports · 12 ›" — the row that opened the full locker under the
/// newest five. Kept for revert.
// ignore: unused_element
class _AllRow extends StatelessWidget {
  const _AllRow(
      {required this.count, required this.p, required this.lang, required this.onTap});

  final int count;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Expanded(
                child: Text('All reports  ·  $count',
                    style: pvManrope(
                        fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      );
}

// =============================================================================
//  ScanReportsAllScreen — every report, searchable, filtered by scan
// -----------------------------------------------------------------------------
//  Superpower's Health Records (Mobbin): a search field, a filter, rows
//  under date headings. Here: the tool header, a field, scan pills, then
//  the rows grouped by month. The add lives here too.
// =============================================================================

class ScanReportsAllScreen extends StatefulWidget {
  const ScanReportsAllScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<ScanReportsAllScreen> createState() => _ScanReportsAllScreenState();
}

class _ScanReportsAllScreenState extends State<ScanReportsAllScreen> {
  final _q = TextEditingController();
  String? _scan;

  @override
  void initState() {
    super.initState();
    _q.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation:
            Listenable.merge([ScanReportsStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final lang = S.current;
          final all = ScanReportsStore.instance.reports;
          final q = _q.text.trim().toLowerCase();
          final shown = [
            for (final r in all)
              if ((_scan == null || r.scanId == _scan) &&
                  (q.isEmpty ||
                      r.title.toLowerCase().contains(q) ||
                      r.note.toLowerCase().contains(q)))
                r
          ];
          final scans = {for (final r in all) if (r.scanId != null) r.scanId!};

          Widget pill(String label, bool on, VoidCallback onTap) => PvPress(
                child: Material(
                  color: on ? p.ink1 : p.surface,
                  shape: StadiumBorder(side: BorderSide(color: on ? p.ink1 : p.line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: on ? null : () {
                      pvCommitFeedback();
                      onTap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(label,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: on ? Colors.white : p.ink1)),
                    ),
                  ),
                ),
              );

          return PvDoorToolScaffold(
            hue: 206,
            eyebrow: 'Scans & tests',
            title: 'All reports',
            intro: '${all.length} ${all.length == 1 ? 'report' : 'reports'}. '
                "Everything stays on your phone, and in your account when you're signed in.",
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(
                    controller: _q,
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
                    decoration: InputDecoration(
                      hintText: 'Search a report or a note',
                      hintStyle: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, color: p.ink3),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      prefixIcon: Icon(Icons.search_rounded, size: 21, color: p.ink3),
                      filled: true,
                      fillColor: p.surface,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: p.line)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: p.ink1, width: 1.2)),
                    ),
                  ),
                  if (scans.length > 1) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(children: [
                        pill('All', _scan == null, () => setState(() => _scan = null)),
                        for (final id in scans)
                          if (_scanById(id) case final sc?) ...[
                            const SizedBox(width: 8),
                            pill(sc.name.of(lang), _scan == id, () => setState(() => _scan = id)),
                          ],
                      ]),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _AddRow(p: p, lang: lang, onTap: () => _addHere(context)),
                  const SizedBox(height: 14),
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(all.isEmpty ? 'Nothing here yet. A photo is enough.' : 'Nothing matches.',
                          style: pvManrope(fontSize: 14, color: p.ink2)),
                    )
                  else
                    for (final w in _groupedStatic(shown, p, lang,
                        onOpen: (r) => Navigator.of(context).push(MaterialPageRoute<void>(
                              settings: const RouteSettings(name: 'scans/reports/view'),
                              builder: (_) => ScanReportViewerScreen(
                                  reportId: r.id, pregnancy: widget.pregnancy),
                            ))))
                      w,
                  const SizedBox(height: 22),
                  PvDoorDisclaimer(p: p),
                  const SizedBox(height: 24), // the FAB is off (2026-09-19); was 88
                ]),
              ),
            ],
          );
        },
      );

  /// The same add as the tab's — picker, "Which one is this?", store.
  Future<void> _addHere(BuildContext context) =>
      _ScanReportsScreenState.addReport(context, widget.pregnancy);

  static List<Widget> _groupedStatic(
      List<ScanReport> rs, V2Palette p, AppLanguage lang,
      {required void Function(ScanReport) onOpen}) {
    final out = <Widget>[];
    String? month;
    for (final r in rs) {
      final d = DateTime.tryParse(r.reportDateIso) ?? DateTime.now();
      final m = '${_kMonthsLong[d.month - 1]} ${d.year}';
      if (m != month) {
        month = m;
        out.add(Padding(
          padding: EdgeInsets.only(top: out.isEmpty ? 4 : 18, bottom: 4),
          child: Text(m.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3)),
        ));
      }
      out.add(_ReportRow(report: r, p: p, lang: lang, onOpen: () => onOpen(r), onDelete: () {}));
    }
    return out;
  }
}

TestScanInfo? _scanById(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

/// "Your reports · N ›" with the last-added line — the entry to the locker.
/// With none: "Nothing here yet · a photo is enough", still tappable (the
/// screen inside has the add too), so the row is never a dead end.
class _YourReportsRow extends StatelessWidget {
  const _YourReportsRow(
      {required this.reports, required this.p, required this.lang, required this.onTap});

  final List<ScanReport> reports;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final well = Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface);
    final n = reports.length;
    final latest = reports.isEmpty ? null : reports.first;
    final d = latest == null ? null : DateTime.tryParse(latest.reportDateIso);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final sub = latest == null
        ? _en('Nothing here yet. A photo is enough.').of(lang)
        : 'Last added  ·  ${latest.title}${d == null ? '' : '  ·  ${d.day} ${m[d.month - 1]}'}';
    return PvPress(
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: well, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.folder_open_rounded, size: 21, color: p.ink1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n == 0 ? 'Your reports' : 'Your reports  ·  $n',
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, color: p.ink2)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      ),
    );
  }
}
