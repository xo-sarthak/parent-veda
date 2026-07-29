// =============================================================================
//  TTC attachments - the actual document
// -----------------------------------------------------------------------------
//  A-49. Fertility results in India arrive on paper and as PDFs. Without a way
//  to hold the document, Health Records could only ever hold a number she
//  retyped, while the thing her clinic actually handed her stayed in her
//  gallery or her email - which is where she would go looking for it. So the
//  folder was not really the folder.
//
//  ---------------------------------------------------------------------------
//  Local-first, with the backend switched off
//
//  `StorageService.upload()` returns the ORIGINAL LOCAL PATH when signed out,
//  when the file is missing, or when the upload fails, and `resolve()` accepts
//  either a local path or a storage object path. That is not a fallback bolted
//  on - it is the design, and it means this screen behaves identically with no
//  backend at all and starts syncing the files the day one exists.
//
//  The LIST of refs is a different matter: it lives on `TtcRecord`, which is
//  cached locally but whose cloud row is hand-written column by column in
//  `pushToCloud`. No column, no travel. Stated plainly rather than discovered
//  later, because a silent half-sync is the failure this codebase keeps having.
//
//  ---------------------------------------------------------------------------
//  Why this is not an import from the parenting stage
//
//  `pp_attachments.dart` does the same job, and the stages are deliberately
//  code-isolated - it is pp-palette from top to bottom, and importing it here
//  would put parenting colours inside TTC and couple two stages that are meant
//  to agree only on values.
//
//  What IS shared is the layer underneath: the same `image_picker`, the same
//  `file_picker`, the same `StorageService`. Sharing infrastructure and
//  duplicating presentation is the split this repo has chosen everywhere else.
// =============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/remote/storage_service.dart';
import '../../ttc/ttc_records_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcAttachments extends StatelessWidget {
  const TtcAttachments({super.key, required this.record, required this.t});

  final TtcRecord record;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final files = record.attachments;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (files.isNotEmpty) ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < files.length; i++)
            _Chip(ref: files[i], onRemove: () => _remove(i)),
        ]),
        const SizedBox(height: 10),
      ],
      GestureDetector(
        onTap: () => _add(context),
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.attach_file_rounded, size: 15, color: ttcPurple),
          const SizedBox(width: 6),
          Text(files.isEmpty ? t.recordsAttach : t.recordsAttachMore,
              style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w700)),
        ]),
      ),
    ]);
  }

  void _remove(int i) {
    final next = [...record.attachments]..removeAt(i);
    // The FILE is left alone. Detaching a scan from a record is not a request
    // to delete the scan, and guessing otherwise is unrecoverable.
    TtcRecordsStore.instance.replace(record.copyWith(attachments: next));
  }

  Future<void> _add(BuildContext context) async {
    final picked = await showTtcAttachmentPicker(context, t);
    if (picked.isEmpty) return;
    final refs = <String>[];
    for (final p in picked) {
      refs.add(await StorageService.upload(p, 'ttc_record'));
    }
    TtcRecordsStore.instance.replace(
        record.copyWith(attachments: [...record.attachments, ...refs]));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.ref, required this.onRemove});

  final String ref;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isPdf = ref.toLowerCase().endsWith('.pdf');
    final name = ref.split(RegExp('[/\\\\]')).last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            size: 15, color: ttcPurple),
        const SizedBox(width: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(11.5, color: ttcTitleInk, w: FontWeight.w600)),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRemove,
          behavior: HitTestBehavior.opaque,
          child: const Icon(Icons.close_rounded, size: 14, color: ttcMuted),
        ),
      ]),
    );
  }
}

/// Camera · gallery · PDF, in TTC's palette. Returns local file paths.
Future<List<String>> showTtcAttachmentPicker(
    BuildContext context, TtcS t) async {
  final res = await showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: ttcBg,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcLine,
                        borderRadius: BorderRadius.circular(999))),
              ),
              const SizedBox(height: 16),
              Text(t.recordsAttach, style: ttcJakarta(17)),
              const SizedBox(height: 14),
              _pickRow(ctx, Icons.photo_camera_outlined, t.recordsAttachCamera,
                  _camera),
              _pickRow(ctx, Icons.photo_library_outlined,
                  t.recordsAttachGallery, _gallery),
              _pickRow(
                  ctx, Icons.picture_as_pdf_outlined, t.recordsAttachPdf, _pdf),
            ]),
      ),
    ),
  );
  return res ?? const [];
}

Widget _pickRow(BuildContext ctx, IconData icon, String label,
        Future<void> Function(BuildContext) onTap) =>
    GestureDetector(
      onTap: () => onTap(ctx),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ttcBorder)),
        child: Row(children: [
          Icon(icon, size: 20, color: ttcPurple),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: ttcBody(14, color: ttcInk, w: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );

// Every picker failure pops an empty list rather than throwing. A denied
// permission is a normal outcome on a phone, not an error worth a dialog.

Future<void> _camera(BuildContext ctx) async {
  try {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(x == null ? const <String>[] : [x.path]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <String>[]);
  }
}

Future<void> _gallery(BuildContext ctx) async {
  try {
    final xs = await ImagePicker().pickMultiImage(imageQuality: 70);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop([for (final x in xs) x.path]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <String>[]);
  }
}

Future<void> _pdf(BuildContext ctx) async {
  try {
    final r = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(r == null
        ? const <String>[]
        : [
            for (final f in r.files)
              if (f.path != null) f.path!,
          ]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <String>[]);
  }
}
