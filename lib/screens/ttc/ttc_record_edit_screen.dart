// =============================================================================
//  Records and reports: add a result, or change one (one page, one flow)
// -----------------------------------------------------------------------------
//  Rebuilt 2026-09-27 (the tool rebuild) after the user walked build 13:
//
//    "When you click on Add at the top right you can see the old UI hint
//     collapsing with ours. Two screens open to add."
//
//  ⚠️ THE MECHANISM, because it is a general trap and not a local slip. Add
//  opened a bottom sheet (`_AddSheet`), and that sheet's `initState` opened a
//  SECOND bottom sheet on its first frame: `showTtcAttachmentPicker`, the old
//  V1 chooser (lilac ground, purple icons). Two modal routes stacked, the old
//  one on top, the new one visible behind it. Nothing was wrong with either
//  sheet on its own; the defect was one route pushing another as a side effect
//  of being built. So the fix is structural, not cosmetic: adding is now ONE
//  page in the tool shell, and the three ways to bring in the report (camera,
//  photos, a PDF) are rows ON that page. The camera is the phone's own screen,
//  which is not a second sheet of ours.
//
//  And the same page changes a saved result. "The last report added … I
//  cannot delete it" was the second defect: a saved result could be opened
//  and looked at, and that was all. Now every result opens here with its
//  fields filled, and removing it is on the page, behind a confirm, with an
//  Undo afterwards.
//
//  Shape from Mobbin (2026-09-27):
//   · Crouton "Add Recipe", the photo block at the top of a full-page form,
//     "Add Photo" inside it, fields below:
//     https://mobbin.com/screens/6184144c-5b37-442c-bd61-86f31b9d3490
//   · Zocdoc "Upload your insurance", take a photo or upload, both visible,
//     nothing hidden behind a chooser:
//     https://mobbin.com/screens/bf062ed4-eadf-402b-956a-56d8d5471ec4
//   · Claude "Add to Chat", camera and files as rows on the same surface:
//     https://mobbin.com/screens/b5f09526-d0a5-41ba-b25b-e385ff3bbe08
//   · AllTrails "Edit list", the edit form carries its own delete, confirmed:
//     https://mobbin.com/flows/e29d9d73-8e16-404c-9b41-6898dba510f0
//   · Toggl Track "Deleting a time entry", the undo after a delete:
//     https://mobbin.com/flows/6cefa024-2a63-4449-94dd-127c00f20495
//
//  ⚠️ STILL NOTHING HERE INTERPRETS A VALUE. It files what the report says.
//  See the head of `ttc_records_v2.dart`.
// =============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/remote/storage_service.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_tests_data.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_records_v2.dart'
    show kTtcRecordsHue, ttcRecordDate, TtcRecordsAction, ttcRecordFileName;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_confirm.dart';

/// Opens the one add-or-change page.
///
/// [record] changes a saved result. Without it, a new one: [testId] starts it
/// on a library test (the test library's "Add my result", the coverage list's
/// "Add"), [like] starts it as another reading of the same test (same name,
/// same person), and [camera] opens the phone's camera straight away, for
/// "Photograph a report" when the sheet is already in her hand.
///
/// Returns true when the result was removed, so a detail screen underneath
/// can close itself rather than show an empty page.
Future<bool> openTtcRecordEdit(
  BuildContext context, {
  TtcRecord? record,
  String? testId,
  TtcRecord? like,
  bool camera = false,
}) async {
  final removed = await Navigator.of(context).push<bool>(MaterialPageRoute(
    settings: RouteSettings(
        name: record == null ? 'ttc/record_add' : 'ttc/record_edit'),
    builder: (_) => TtcRecordEditScreen(
      record: record,
      testId: testId,
      like: like,
      camera: camera,
    ),
  ));
  return removed == true;
}

/// Removes one result after asking, then offers Undo. Shared by this page and
/// the result's own page, so both say the same words.
Future<bool> ttcRemoveRecord(BuildContext context, TtcRecord r) async {
  final ok = await ttcConfirmRemove(
    context,
    title: 'Remove ${r.label}, ${ttcRecordDate(r.takenOn)}?',
    body: r.attachments.isEmpty
        ? 'It comes off your records, on this phone and on your account.'
        : 'It comes off your records, with its '
            '${r.attachments.length == 1 ? 'photo' : 'photos'}. A photo you '
            'chose from your gallery stays in your gallery.',
  );
  if (!ok || !context.mounted) return false;
  TtcRecordsStore.instance.remove(r.id);
  HapticFeedback.selectionClick();
  pvSnack(context, 'Result removed.',
      action: 'Undo',
      onAction: () => TtcRecordsStore.instance.restore([r]),
      lift: 24);
  return true;
}

class TtcRecordEditScreen extends StatefulWidget {
  const TtcRecordEditScreen({
    super.key,
    this.record,
    this.testId,
    this.like,
    this.camera = false,
  });

  final TtcRecord? record;
  final String? testId;
  final TtcRecord? like;
  final bool camera;

  @override
  State<TtcRecordEditScreen> createState() => _TtcRecordEditScreenState();
}

class _TtcRecordEditScreenState extends State<TtcRecordEditScreen> {
  late final TtcRecord? _r = widget.record;
  bool get _editing => _r != null;

  late final _label = TextEditingController(
      text: _r?.label ?? widget.like?.label ?? '');
  late final _value = TextEditingController(text: _r?.value ?? '');
  late final _unit =
      TextEditingController(text: _r?.unit ?? widget.like?.unit ?? '');
  late final _note = TextEditingController(text: _r?.note ?? '');

  late List<String> _shots = [...?_r?.attachments];
  late DateTime _taken = _r?.takenOn ?? DateTime.now();

  /// Whose, once she has said. Null means "use the best guess" ([_whose]).
  late bool? _partner = _r?.forPartner ?? widget.like?.forPartner;
  bool _busy = false;

  /// The library test she picked from the suggestions, or arrived with.
  String? _pickedTestId;

  @override
  void initState() {
    super.initState();
    final preset = widget.testId == null ? null : ttcTestById(widget.testId!);
    if (preset != null) {
      _label.text = preset.name;
      _pickedTestId = preset.id;
    } else {
      _pickedTestId = _r?.testId ?? widget.like?.testId;
    }
    // ⚠️ THE FORM FOLLOWS THE TYPING. The Save button, the suggestions and
    // whose it is all read the test name, so the page redraws as she types.
    _label.addListener(_onLabel);
    if (widget.camera) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _bring(_Source.camera));
    }
  }

  void _onLabel() {
    final picked = _pickedTestId == null ? null : ttcTestById(_pickedTestId!);
    // Editing the name away from the picked test un-picks it.
    if (picked != null &&
        picked.name.toLowerCase() != _label.text.trim().toLowerCase()) {
      _pickedTestId = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _label.removeListener(_onLabel);
    _label.dispose();
    _value.dispose();
    _unit.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Library tests whose name holds what she has typed, so "amh" offers
  /// "AMH" and a repeat files under the same group as the first reading.
  List<TtcTest> get _suggestions {
    final q = _label.text.trim().toLowerCase();
    if (q.isEmpty || _pickedTestId != null) return const [];
    return ttcTests
        .where((t) =>
            t.name.toLowerCase().contains(q) && t.name.toLowerCase() != q)
        .take(4)
        .toList();
  }

  /// ⚠️ THE TEST DECIDES WHOSE IT IS, WHERE THE TEST CAN. A semen analysis is
  /// never hers. Everything else follows what she filed last. The switch
  /// shows this guess already chosen, so it costs no tap when it is right.
  bool get _whose {
    if (_partner != null) return _partner!;
    final picked = _pickedTestId == null ? null : ttcTestById(_pickedTestId!);
    if (picked != null) return picked.forHim;
    final label = _label.text.trim().toLowerCase();
    final test = ttcTests.where((t) => t.name.toLowerCase().startsWith(label));
    if (label.isNotEmpty && test.isNotEmpty) return test.first.forHim;
    final last = TtcRecordsStore.instance.records;
    return last.isEmpty ? false : last.first.forPartner;
  }

  bool get _canSave => _shots.isNotEmpty || _label.text.trim().isNotEmpty;

  // ---- bringing in the report ----------------------------------------------

  /// Camera, photos or a PDF. Every picker failure is an empty answer, not an
  /// error: a denied permission is a normal outcome on a phone.
  Future<void> _bring(_Source source) async {
    List<String> picked = const [];
    try {
      switch (source) {
        case _Source.camera:
          final x = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 70);
          picked = x == null ? const [] : [x.path];
        case _Source.photos:
          final xs = await ImagePicker().pickMultiImage(imageQuality: 70);
          picked = [for (final x in xs) x.path];
        case _Source.pdf:
          final r = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              allowMultiple: true);
          picked = r == null
              ? const []
              : [
                  for (final f in r.files)
                    if (f.path != null) f.path!,
                ];
      }
    } catch (_) {
      picked = const [];
    }
    if (picked.isEmpty || !mounted) return;
    setState(() => _busy = true);
    final refs = <String>[];
    for (final p in picked) {
      refs.add(await StorageService.upload(p, 'ttc_record'));
    }
    if (!mounted) return;
    setState(() {
      _shots = [..._shots, ...refs];
      _busy = false;
    });
  }

  // ---- saving and removing ---------------------------------------------------

  void _save() {
    final label = _label.text.trim();
    final match = label.isEmpty
        ? const <TtcTest>[]
        : ttcTests
            .where((t) => t.name.toLowerCase().startsWith(label.toLowerCase()))
            .toList();
    final testId =
        _pickedTestId ?? (match.isEmpty ? null : match.first.id);
    final note = _note.text.trim();
    final store = TtcRecordsStore.instance;

    final r = _r;
    if (r == null) {
      final rec = store.add(
        label: label.isEmpty ? 'Report' : label,
        takenOn: _taken,
        testId: testId,
        value: _value.text.trim(),
        unit: _unit.text.trim(),
        note: note.isEmpty ? null : note,
        forPartner: _whose,
      );
      if (_shots.isNotEmpty) store.replace(rec.copyWith(attachments: _shots));
      pvSnack(context, 'Saved to your reports.',
          icon: Icons.check_rounded, lift: 24);
    } else {
      store.replace(r.copyWith(
        label: label.isEmpty ? r.label : label,
        takenOn: _taken,
        testId: testId,
        clearTestId: testId == null,
        value: _value.text.trim(),
        unit: _unit.text.trim(),
        // A cleared note stays cleared: '' is an empty note, not "no change".
        note: note,
        forPartner: _whose,
        attachments: _shots,
      ));
      pvSnack(context, 'Changes saved.', icon: Icons.check_rounded, lift: 24);
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).maybePop(false);
  }

  Future<void> _remove() async {
    final nav = Navigator.of(context);
    final gone = await ttcRemoveRecord(context, _r!);
    if (gone) nav.pop(true);
  }

  // ---- the page ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return TtcToolScaffold(
      hue: kTtcRecordsHue,
      variant: 1,
      eyebrow: 'Records and reports',
      title: _editing ? 'Change this result' : 'Add a result',
      intro: _editing
          ? 'Fix anything that was filed wrong, then save.'
          : 'A photo of the report or the name of the test is enough to '
              'save. The rest can wait.',
      children: [
        ttcToolPad(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),

            // 1. Whose. Asked first because it changes where the row lands.
            TtcRecordBlock(
              title: 'Whose result is this?',
              child: TtcToolOptions(
                hue: kTtcRecordsHue,
                p: V2PaletteStore.instance.current,
                items: [
                  TtcToolOption(
                      label: 'Yours',
                      on: !_whose,
                      onTap: () => setState(() => _partner = false)),
                  TtcToolOption(
                      label: "Your partner's",
                      on: _whose,
                      onTap: () => setState(() => _partner = true)),
                ],
              ),
            ),

            // 2. The report itself.
            TtcRecordBlock(
              title: 'The report',
              note: _shots.isEmpty
                  ? 'A photo is the quickest way. You can type the number '
                      'later, sitting down.'
                  : 'Add another page if the report has more than one.',
              child: Column(children: [
                for (var i = 0; i < _shots.length; i++)
                  _AttachedRow(
                    key: ValueKey('ttc_rec_shot_$i'),
                    ref: _shots[i],
                    n: i + 1,
                    onRemove: () => setState(() =>
                        _shots = [..._shots]..removeAt(i)),
                  ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else ...[
                  _SourceRow(
                    key: const ValueKey('ttc_rec_camera'),
                    icon: Icons.photo_camera_outlined,
                    label: _shots.isEmpty ? 'Take a photo' : 'Take another photo',
                    onTap: () => _bring(_Source.camera),
                  ),
                  _SourceRow(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from your photos',
                    onTap: () => _bring(_Source.photos),
                  ),
                  _SourceRow(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Choose a PDF',
                    last: true,
                    onTap: () => _bring(_Source.pdf),
                  ),
                ],
              ]),
            ),

            // 3. The name, the thing that groups repeats together.
            TtcRecordBlock(
              title: 'What test was it?',
              note: 'Pick a name from the list if it shows, so a second '
                  'reading sits next to the first.',
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TtcRecordField(
                        controller: _label,
                        hint: 'For example AMH or Thyroid',
                        fieldKey: const ValueKey('ttc_rec_label')),
                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in _suggestions)
                          TtcToolPill(
                            key: ValueKey('ttc_rec_suggest_${s.id}'),
                            label: s.name,
                            on: false,
                            hue: kTtcRecordsHue,
                            onTap: () {
                              _pickedTestId = s.id;
                              _label.text = s.name;
                              _label.selection = TextSelection.collapsed(
                                  offset: s.name.length);
                            },
                          ),
                      ]),
                    ],
                  ]),
            ),

            // 4. What it says.
            TtcRecordBlock(
              title: 'What does the report say?',
              note: 'Copy it exactly as printed. Words are fine too, like '
                  '"both tubes open".',
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  flex: 3,
                  child: TtcRecordField(
                      controller: _value,
                      hint: 'Result',
                      fieldKey: const ValueKey('ttc_rec_value')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TtcRecordField(
                      controller: _unit,
                      hint: 'Unit',
                      fieldKey: const ValueKey('ttc_rec_unit')),
                ),
              ]),
            ),

            // 5. When.
            TtcRecordBlock(
              title: 'Date on the report',
              child: TtcRecordDateField(
                  taken: _taken, onPick: (d) => setState(() => _taken = d)),
            ),

            // 6. A doctor's words, if any.
            TtcRecordBlock(
              title: 'Anything written on it',
              note: 'Optional. A line from the doctor, word for word.',
              child: TtcRecordField(
                  controller: _note,
                  hint: 'For example "Repeat in 3 months"',
                  lines: 3,
                  fieldKey: const ValueKey('ttc_rec_note')),
            ),

            const SizedBox(height: 6),
            // ⚠️ AN HONEST DISABLED STATE. A live-looking button that
            // swallowed the tap was the first tools-pass fix here; the reason
            // stays right under it.
            TtcRecordsAction(
                key: const ValueKey('ttc_rec_save'),
                label: _editing ? 'Save changes' : 'Save this result',
                enabled: _canSave,
                onTap: _save),
            if (!_canSave)
              const TtcFormHint(text: 'Add a photo or the test name to save.'),
            if (_editing) ...[
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  key: const ValueKey('ttc_rec_remove'),
                  onPressed: _remove,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 17, color: Color(0xFFB42318)),
                  label: Text('Remove this result',
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB42318))),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Center(
              child: Text('This is a record, not a judgement.',
                  style: ttcBody(12, color: ttcMuted)),
            ),
            const SizedBox(height: 26),
          ],
        )),
      ],
    );
  }
}

enum _Source { camera, photos, pdf }

/// One labelled part of the form: white, a hairline, the question on top.
/// The tool shell's question card without the number, because this is a form
/// she fills in any order, not a quiz she walks through.
class TtcRecordBlock extends StatelessWidget {
  const TtcRecordBlock({
    super.key,
    required this.title,
    required this.child,
    this.note,
  });

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: pvJakarta(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                height: 1.32,
                color: p.ink1)),
        if (note != null) ...[
          const SizedBox(height: 5),
          Text(note!,
              style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        ],
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

/// A text box in the tool's clothes: white, a hairline, ink when it holds
/// something. The same field the semen reader uses.
class TtcRecordField extends StatefulWidget {
  const TtcRecordField({
    super.key,
    required this.controller,
    this.hint,
    this.lines = 1,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String? hint;
  final int lines;
  final Key? fieldKey;

  @override
  State<TtcRecordField> createState() => _TtcRecordFieldState();
}

class _TtcRecordFieldState extends State<TtcRecordField> {
  @override
  Widget build(BuildContext context) {
    final has = widget.controller.text.trim().isNotEmpty;
    OutlineInputBorder edge(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.5),
        );
    return TextField(
      key: widget.fieldKey,
      controller: widget.controller,
      minLines: widget.lines,
      maxLines: widget.lines,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) => setState(() {}),
      style: ttcBody(14.5, color: ttcTitleInk, w: FontWeight.w700),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: widget.hint,
        hintStyle: ttcBody(14, color: ttcMuted, w: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: edge(has ? ttcTitleInk : ttcLine),
        focusedBorder: edge(ttcTitleInk),
        border: edge(ttcLine),
      ),
    );
  }
}

/// The date row. Past dates only: a report cannot have been printed tomorrow,
/// and a future date would sort to the top and become "latest" for ever.
class TtcRecordDateField extends StatelessWidget {
  const TtcRecordDateField({
    super.key,
    required this.taken,
    required this.onPick,
    this.fieldKey,
  });

  final DateTime taken;
  final ValueChanged<DateTime> onPick;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = taken.year == now.year &&
        taken.month == now.month &&
        taken.day == now.day;
    return InkWell(
      key: fieldKey,
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          helpText: 'Date on the report',
          initialDate: taken.isAfter(now) ? now : taken,
          firstDate: DateTime(2015),
          lastDate: now,
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ttcTitleInk, width: 1.5),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: ttcTitleInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                today
                    ? 'Today, ${ttcRecordDate(taken)}'
                    : ttcRecordDate(taken),
                style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
          ),
          Text('Change',
              style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w800)),
        ]),
      ),
    );
  }
}

/// One way to bring the report in: a row, not a second sheet.
class _SourceRow extends StatelessWidget {
  const _SourceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ttcLine, width: 1.5),
            ),
            child: Row(children: [
              Icon(icon, size: 19, color: ttcTitleInk),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 19, color: ttcMuted),
            ]),
          ),
        ),
      );
}

/// A page already attached, with a way to take it off this result.
///
/// Taking it off edits the LIST, never the file: detaching a scan from a
/// record is not a request to delete the scan (the rule from
/// `ttc_attachments.dart`). And it only lands on Save.
class _AttachedRow extends StatelessWidget {
  const _AttachedRow({
    super.key,
    required this.ref,
    required this.n,
    required this.onRemove,
  });

  final String ref;
  final int n;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final pdf = ref.toLowerCase().endsWith('.pdf');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: ttcPanel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(pdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            size: 18, color: ttcTitleInk),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pdf ? 'PDF, page $n' : 'Photo, page $n',
                style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w800)),
            Text(ttcRecordFileName(ref),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(11.5, color: ttcMuted)),
          ]),
        ),
        IconButton(
          tooltip: 'Take this page off',
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, size: 18, color: ttcSoft),
        ),
      ]),
    );
  }
}
