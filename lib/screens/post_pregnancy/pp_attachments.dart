// =============================================================================
//  pp_attachments - shared image/PDF attachment picker + display
// -----------------------------------------------------------------------------
//  One place for "attach a photo or a PDF" across the parenting app: health
//  reports, prescriptions, and baby documents. Photos come from image_picker
//  (camera or gallery, multi-select); PDFs from file_picker. Attachments are
//  local file paths only (no upload/backend yet). Keep it small and reusable.
// =============================================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'pp_common.dart';

enum AttachKind { image, pdf }

class Attachment {
  const Attachment(this.kind, this.path, this.name);
  final AttachKind kind;
  final String path;
  final String name;

  bool get isPdf => kind == AttachKind.pdf;
}

/// Opens a small sheet (Take photo · Choose photos · Attach PDF) and returns the
/// picked attachments (empty if cancelled or on any picker error).
Future<List<Attachment>> showAttachmentPicker(BuildContext context, {bool allowPdf = true}) async {
  final res = await showModalBottomSheet<List<Attachment>>(
    context: context,
    backgroundColor: ppBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
          const SizedBox(height: 14),
          Text('Add an attachment', style: ppJakarta(17)),
          const SizedBox(height: 14),
          _row(ctx, Icons.photo_camera_outlined, 'Take a photo', () => _camera(ctx)),
          _row(ctx, Icons.photo_library_outlined, 'Choose photos', () => _gallery(ctx)),
          if (allowPdf) _row(ctx, Icons.picture_as_pdf_outlined, 'Attach a PDF', () => _pdf(ctx)),
        ]),
      ),
    ),
  );
  return res ?? const [];
}

Widget _row(BuildContext ctx, IconData icon, String label, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Row(children: [
          Icon(icon, size: 20, color: ppPurple),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );

Future<void> _camera(BuildContext ctx) async {
  try {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(x == null ? const <Attachment>[] : [Attachment(AttachKind.image, x.path, x.name)]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <Attachment>[]);
  }
}

Future<void> _gallery(BuildContext ctx) async {
  try {
    final xs = await ImagePicker().pickMultiImage(imageQuality: 70);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop([for (final x in xs) Attachment(AttachKind.image, x.path, x.name)]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <Attachment>[]);
  }
}

Future<void> _pdf(BuildContext ctx) async {
  try {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(r == null ? const <Attachment>[] : [for (final f in r.files) if (f.path != null) Attachment(AttachKind.pdf, f.path!, f.name)]);
  } catch (_) {
    if (ctx.mounted) Navigator.of(ctx).pop(const <Attachment>[]);
  }
}

/// A row of attachment chips (icon + name), with an optional remove tap.
Widget attachmentChips(List<Attachment> items, {void Function(int index)? onRemove}) {
  if (items.isEmpty) return const SizedBox.shrink();
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var i = 0; i < items.length; i++)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: ppHair)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(items[i].isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(items[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(12, color: ppInk, w: FontWeight.w600)),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => onRemove(i),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.close_rounded, size: 14, color: ppMuted),
              ),
            ],
          ]),
        ),
    ],
  );
}

/// A compact "N files attached" summary line for cards/timelines.
Widget attachmentSummary(List<Attachment> items) {
  if (items.isEmpty) return const SizedBox.shrink();
  final imgs = items.where((a) => !a.isPdf).length;
  final pdfs = items.where((a) => a.isPdf).length;
  final parts = <String>[];
  if (imgs > 0) parts.add('$imgs ${imgs == 1 ? 'image' : 'images'}');
  if (pdfs > 0) parts.add('$pdfs PDF');
  return Row(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.attach_file_rounded, size: 13, color: ppMuted),
    const SizedBox(width: 5),
    Text(parts.join(' · '), style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
  ]);
}
