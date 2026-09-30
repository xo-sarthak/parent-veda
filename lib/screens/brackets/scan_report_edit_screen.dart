// =============================================================================
//  ScanReportEditScreen — renaming a report, both ways
// -----------------------------------------------------------------------------
//  ⚠️ THE PROBLEM THIS FIXES IS A ROOM FULL OF FILES ALL CALLED "Report".
//
//  Adding a report asks "Which one is this?" and the sheet is skippable, which
//  is right — a document she cannot classify is still a document she needs to
//  keep, and a mandatory dropdown would mean the app refuses paperwork it does
//  not recognise. But skipping stored the literal title `'Report'`, and nothing
//  could ever change it. Skip twice and "My reports" is two identical rows.
//
//  So the skip stays skippable and this screen is where it gets fixed later.
//
//  ---------------------------------------------------------------------------
//  ⚠️ TITLE AND SCAN LINK ARE TWO DIFFERENT FACTS, AND THIS SCREEN KEEPS THEM
//  APART
//  ---------------------------------------------------------------------------
//  `title` is what she CALLS it. `scanId` is what it IS.
//
//  They start life equal, because picking "Dating scan" from the list sets
//  both — but the moment she renames it to "Dating scan — Apollo, Dr Rao" they
//  diverge, and the link is the half that must survive. `scanId` is what
//  `forScan()` reads, so it is what lets a report surface on the scan's own
//  page later. A rename that quietly dropped it would break a connection she
//  cannot see and would never think to restore.
//
//  Hence the two controls below and the rule between them:
//
//    · choosing from the list  -> sets the link AND overwrites the name
//    · typing a name           -> sets the name ONLY, link untouched
//    · "Not a scan on this list" -> clears the link, keeps whatever she typed
//
//  ⚠️ ENGLISH ONLY FOR NOW, matching the rest of this door.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scan_reports_store.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart' show PvDoorToolScaffold;
import '../post_pregnancy/pp_attachments.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class ScanReportEditScreen extends StatefulWidget {
  const ScanReportEditScreen(
      {super.key, required this.reportId, required this.pregnancy});

  final String reportId;
  final PregnancyController pregnancy;

  @override
  State<ScanReportEditScreen> createState() => _ScanReportEditScreenState();
}

class _ScanReportEditScreenState extends State<ScanReportEditScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;

  /// The report's own date. Seeded from the stored value, which falls back
  /// to the day she added it.
  DateTime? _reportDate;

  /// The linked scan, held separately from the text so choosing from the list
  /// and typing a name stay independent — see the header.
  String? _scanId;

  /// Whether anything has actually changed. Drives the Save button's enabled
  /// state, so "Save" is never offered for a no-op.
  bool _dirty = false;

  ScanReport? get _report {
    for (final r in ScanReportsStore.instance.reports) {
      if (r.id == widget.reportId) return r;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final r = _report;
    _title = TextEditingController(text: r?.title ?? '')
      ..addListener(_markDirty);
    _note = TextEditingController(text: r?.note ?? '')..addListener(_markDirty);
    _reportDate =
        r == null ? null : DateTime.tryParse(r.reportDateIso);
    _scanId = r?.scanId;
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lang = S.current;
    final scan = _scanId == null ? null : _scanById(_scanId!);

    // The door tool header (2026-09-19) — was an AppBar in Manrope.
    return PvDoorToolScaffold(
      hue: 206,
      eyebrow: 'My reports',
      title: _en('Edit report').of(lang),
      intro: _en('The name, the scan it came from, the date, a note.').of(lang),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ---- 1 · The name, typed --------------------------------------
          //
          // ⚠️ THE TEXT FIELD IS FIRST, AND THE LIST IS UNDER IT.
          //
          // The add flow leads with the list, which is right at that moment —
          // she has just photographed something and the fastest correct answer
          // is usually one of nine names. By the time she is EDITING, the
          // reason she is here is most often that none of those nine fitted.
          // Putting the list first again would show her the same nine that
          // already failed her, above the box she actually came for.
          _Label(_en('What do you want to call it?').of(lang), p),
          const SizedBox(height: 8),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(fontSize: 15, color: p.ink1),
            decoration: InputDecoration(
              hintText: 'For example, Anomaly scan, Apollo',
              hintStyle: pvManrope(fontSize: 14.5, color: p.ink3),
              filled: true,
              fillColor: p.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.ink1, width: 1.4), // was p.ink1
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- 2 · Or picked from the library ---------------------------
          _Label(_en('Or pick the scan it came from').of(lang), p),
          const SizedBox(height: 4),
          Text(
              _en('Choosing one renames the report and links it, so it shows '
                      'up on that scan\'s page too.')
                  .of(lang),
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in kTestsScans)
                _Chip(
                  label: s.name.of(lang),
                  selected: s.id == _scanId,
                  p: p,
                  onTap: () => setState(() {
                    _scanId = s.id;
                    // ⚠️ THE NAME FOLLOWS THE PICK. She chose a scan in order
                    // to name the thing; leaving her old title in place would
                    // make the tap look like it did nothing. Typing afterwards
                    // still wins — the link survives a rename, the rename does
                    // not survive a re-pick, and that ordering matches which
                    // of the two she touched last.
                    _title.text = s.name.en;
                    _dirty = true;
                  }),
                ),
              // ⚠️ THE WAY OUT OF A LINK, and it must exist. Without it a
              // report linked to the wrong scan is linked to it permanently —
              // she can rename it, and it still surfaces on a page it has
              // nothing to do with.
              _Chip(
                label: _en('Not a scan on this list').of(lang),
                selected: _scanId == null,
                p: p,
                onTap: () => setState(() {
                  _scanId = null;
                  _dirty = true;
                }),
              ),
            ],
          ),
          if (scan != null) ...[
            const SizedBox(height: 14),
            Text(
                _en('Linked to ${scan.name.en}. Renaming it above keeps the '
                        'link.')
                    .of(lang),
                style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
          ],
          const SizedBox(height: 24),

          // ---- 3 · The date on the paper -----------------------------------
          //
          // ⚠️ THE APP STORES TWO DATES AND SHOWS ONE. `dateIso` is when she
          // added it — an audit fact she has no reason to see. This is the date
          // printed on the report, and it is what the list sorts on.
          //
          // ⚠️ WHY IT IS EDITED HERE AND NOT ASKED AT CAPTURE. Adding a report
          // is two taps, and a date question in that flow would be a third —
          // paid by every mother, to fix a case that only arises when she is
          // photographing something old. "Derive, never ask": it defaults to
          // today, which is right the overwhelming majority of the time, and
          // this is where the rest gets corrected.
          //
          // Sorting on this is the entire point of the field. Photographing a
          // stack of old reports used to file all of them under today, in the
          // order she happened to pick them up.
          _Label(_en('Date on the report').of(lang), p),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _reportDate ?? now,
                // ⚠️ NO FUTURE DATES. A report cannot be from next week, and
                // the mis-tap this prevents is the one that would sort a row to
                // the top of her list and keep it there.
                firstDate: DateTime(now.year - 3),
                lastDate: now,
              );
              if (picked == null) return;
              setState(() {
                _reportDate = picked;
                _dirty = true;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Row(children: [
                Icon(Icons.event_outlined, size: 18, color: p.ink3),
                const SizedBox(width: 10),
                Text(
                    _reportDate == null
                        ? 'Pick a date'
                        : _fmtEditDate(_reportDate!),
                    style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // ---- 4 · A note, because paper does not hold one ----------------
          //
          // The field already existed on the model and nothing ever wrote to
          // it. It is the natural place for "Dr Rao said recheck in 4 weeks" —
          // the sentence said aloud in the room that appears nowhere on the
          // printout, and the one thing she will want at the next appointment.
          _Label(_en('Anything to remember about it?').of(lang), p),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1),
            decoration: InputDecoration(
              hintText: 'Optional. What the doctor said, what to ask next '
                  'time…',
              hintStyle: pvManrope(fontSize: 14, color: p.ink3),
              filled: true,
              fillColor: p.surface,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.ink1, width: 1.4), // was p.ink1
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ---- more files ----------------------------------------------
          // The one edit the screen could not do (the user's review,
          // 2026-09-19): the second page of a report, photographed later.
          Text('Files  ·  ${_report?.files.length ?? 0}',
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _addFiles,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add more files'),
          ),
          const SizedBox(height: 28),

          FilledButton(
            onPressed: _dirty ? _save : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: Text(_en('Save').of(lang)),
          ),
          ]),
        ),
      ],
    );
  }

  /// Photograph or attach more pages; they are stored the way the add
  /// stores them and appended, saved at once (no Save needed for a file).
  Future<void> _addFiles() async {
    final r = _report;
    if (r == null) return;
    final picked = await showAttachmentPicker(context);
    if (picked.isEmpty || !mounted) return;
    final stored = await uploadAttachments(picked, 'report');
    await ScanReportsStore.instance.update(r.copyWith(files: [
      ...r.files,
      for (final a in stored) ReportFile(path: a.path, name: a.name, isPdf: a.isPdf),
    ]));
    pvCommitFeedback();
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final r = _report;
    if (r == null) return;

    // ⚠️ AN EMPTY TITLE FALLS BACK RATHER THAN SAVING BLANK. She can clear the
    // box — a row with no name at all is worse than the generic one, because
    // the list then has a card that names nothing.
    final typed = _title.text.trim();
    final title = typed.isEmpty
        ? (_scanId == null
            ? 'Report'
            : (_scanById(_scanId!)?.name.en ?? 'Report'))
        : typed;

    await ScanReportsStore.instance.update(r.copyWith(
      title: title,
      note: _note.text.trim(),
      reportDateIso: _reportDate?.toIso8601String(),
      scanId: _scanId,
      clearScanId: _scanId == null,
    ));
    if (mounted) Navigator.of(context).pop();
  }
}

/// ⚠️ MONTH NAMES RATHER THAN 03/04/2026. India writes day-first and much of
/// the world writes month-first, and a report date read the wrong way round is
/// wrong by up to eleven months on a document a doctor may look at.
String _fmtEditDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

TestScanInfo? _scanById(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: p.ink1));
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label,
      required this.selected,
      required this.p,
      required this.onTap});

  final String label;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? p.ink1 : p.surface, // was p.ink1
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.ink1 : p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? p.onAction : p.ink2)),
        ),
      );
}
