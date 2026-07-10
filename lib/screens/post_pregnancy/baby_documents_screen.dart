// =============================================================================
//  BabyDocumentsScreen - a calm home for the child's important papers
// -----------------------------------------------------------------------------
//  Birth certificate, Aadhaar, passport, insurance, medical papers - each a
//  title + category + date + optional image/PDF attachments. Add via a simple
//  sheet (title · category chips · attachments), browse as cards, tap to view
//  the attachments as chips, delete when no longer needed. Backed by the
//  in-memory BabyDocumentsStore; image/PDF picking uses the shared picker.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_attachments.dart';
import 'pp_common.dart';
import 'pp_documents_data.dart';

class BabyDocumentsScreen extends StatefulWidget {
  const BabyDocumentsScreen({super.key});

  @override
  State<BabyDocumentsScreen> createState() => _BabyDocumentsScreenState();
}

class _BabyDocumentsScreenState extends State<BabyDocumentsScreen> {
  final _store = BabyDocumentsStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  static String _today() {
    final d = DateTime.now();
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final docs = _store.documents;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Health')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('ParentVeda Health', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Baby documents', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Every important paper for your child, in one calm place - photos or PDFs, never a scramble when you need them.', style: ppBody(14, h: 1.5))),
                const SizedBox(height: 18),
                _pad(_addButton('Add document', _addSheet)),
                const SizedBox(height: 18),
                if (docs.isEmpty)
                  _pad(_empty('No documents saved yet. Add the birth certificate, insurance and more so they are always to hand.'))
                else
                  _pad(Column(children: [for (int i = 0; i < docs.length; i++) _docCard(docs[i], i)])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 8),
            Text(label, style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _empty(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Text(msg, style: ppBody(13.5, color: ppMuted, h: 1.5)),
      );

  Widget _docCard(BabyDocument d, int i) => GestureDetector(
        onTap: () => _viewSheet(d, i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.folder_outlined, size: 18, color: ppPurple)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.title, style: ppJakarta(14.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                    child: Text(d.category, style: ppBody(10.5, color: ppPurple, w: FontWeight.w700)),
                  ),
                  Text(d.date, style: ppBody(11, color: ppMuted)),
                ]),
              ])),
              GestureDetector(
                onTap: () => _confirmDelete('Delete this document?', () => _store.removeDocument(i)),
                behavior: HitTestBehavior.opaque,
                child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
              ),
            ]),
            if (d.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              attachmentSummary(d.attachments),
            ],
          ]),
        ),
      );

  // ---- view a saved document (details + attachment chips) -----------------
  void _viewSheet(BabyDocument d, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Text(d.title, style: ppJakarta(18))),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  _editSheet(d, index);
                },
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_outlined, size: 15, color: ppPurple),
                  const SizedBox(width: 4),
                  Text('Edit', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(d.category, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(d.date, style: ppBody(12, color: ppMuted)),
            ]),
            if (d.notes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(d.notes, style: ppBody(14, color: ppInk, h: 1.5)),
            ],
            const SizedBox(height: 16),
            if (d.attachments.isEmpty)
              Text('No files attached to this document.', style: ppBody(12.5, color: ppMuted))
            else ...[
              Text('Attachments', style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
              const SizedBox(height: 10),
              attachmentChips(d.attachments),
            ],
          ]),
        ),
      ),
    );
  }

  // ---- add / edit ---------------------------------------------------------
  void _addSheet() => _editSheet(null, null);

  void _editSheet(BabyDocument? existing, int? index) {
    final title = TextEditingController(text: existing?.title ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String category = existing?.category ?? kBabyDocCategories.first;
    final List<Attachment> atts = [...?existing?.attachments];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Text(existing == null ? 'Add document' : 'Edit document', style: ppJakarta(18))),
                  if (index != null)
                    GestureDetector(
                      onTap: () {
                        _store.removeDocument(index);
                        Navigator.of(ctx).pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.delete_outline_rounded, size: 22, color: ppCoral),
                    ),
                ]),
                const SizedBox(height: 16),
                _tf(title, 'Document title (e.g. Passport)'),
                _label('Category'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in kBabyDocCategories)
                    GestureDetector(
                      onTap: () => setSheet(() => category = c),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: category == c ? ppPurple : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: category == c ? ppPurple : ppLine),
                        ),
                        child: Text(c, style: ppBody(12, color: category == c ? Colors.white : ppInk, w: FontWeight.w700)),
                      ),
                    ),
                ]),
                const SizedBox(height: 16),
                _tf(notes, 'Notes (optional)', maxLines: 3),
                _attachRow(atts, setSheet),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    if (title.text.trim().isEmpty) return;
                    final d = BabyDocument(
                      id: existing?.id ?? 'doc_${DateTime.now().microsecondsSinceEpoch}',
                      title: title.text.trim(),
                      category: category,
                      date: existing?.date ?? _today(),
                      notes: notes.text.trim(),
                      attachments: List.of(atts),
                    );
                    index == null ? _store.addDocument(d) : _store.updateDocument(index, d);
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Text('Save', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String title, VoidCallback onConfirm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: ppJakarta(16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                    child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onConfirm();
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)),
                    child: Text('Delete', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ---- small form parts ---------------------------------------------------
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
      );

  Widget _tf(TextEditingController c, String label, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label(label),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              maxLines: maxLines,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  Widget _attachRow(List<Attachment> atts, void Function(void Function()) setSheet) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Attachments'),
          GestureDetector(
            onTap: () async {
              final picked = await showAttachmentPicker(context);
              if (picked.isNotEmpty) setSheet(() => atts.addAll(picked));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ppBorder)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.attach_file_rounded, size: 17, color: ppPurple),
                const SizedBox(width: 8),
                Text('Add attachment', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              ]),
            ),
          ),
          if (atts.isNotEmpty) ...[
            const SizedBox(height: 10),
            attachmentChips(atts, onRemove: (i) => setSheet(() => atts.removeAt(i))),
          ],
        ]),
      );
}
