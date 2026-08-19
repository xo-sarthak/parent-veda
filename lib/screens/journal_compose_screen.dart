// =============================================================================
//  Add a memory - the full-page composer
// -----------------------------------------------------------------------------
//  ⚠️ A PAGE, NOT A BOTTOM SHEET, AND THE CHANGE IS NOT COSMETIC.
//
//  "Write a memory" opened a sheet with one text field. A sheet is right for a
//  single quick input and wrong for everything this is meant to hold: a
//  heading, a body, up to three photos, and a preview of how the entry will
//  read afterwards. On a phone with the keyboard up, a sheet leaves roughly
//  half a screen, so the photos would sit under the fold of a surface that is
//  already scrolling inside a scroll.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EITHER HALF IS ENOUGH. TEXT OR PHOTOS. NOT BOTH REQUIRED.
//  ---------------------------------------------------------------------------
//  Review: "user either wrote a note and attached pics to it, or just added
//  pics". That single rule is what let two separate quick actions collapse into
//  one - "Write a memory" and "Add a photo" were the same entry seen from two
//  ends, and having both meant a mother who started with a photo could not add
//  a sentence, and one who started writing could not attach a picture.
//
//  So the Save button unlocks on text OR photos, and the empty state says so.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE META LINE IS BELOW THE CONTENT, NOT ABOVE IT
//  ---------------------------------------------------------------------------
//  Date, time and place render under the entry the way they do under a social
//  post, which is the shape review asked for and also the right one: the
//  photograph is the thing, and the stamp is a caption on it. Putting a
//  timestamp above a memory makes the page read as a log.
//
//  ⚠️ PLACE MAY BE NULL FOREVER, AND THAT IS HANDLED RATHER THAN HIDDEN. This
//  app has no geolocation package, so nothing can currently capture a
//  location - see `JournalEntry.place` for why the field exists anyway. A null
//  place renders nothing at all; it never renders "Location unavailable",
//  which would be an error message about a feature she never asked for.
//
//  ⚠️ DICTATION IS REUSED, NOT REBUILT. `MicDictateButton` already does
//  speech-to-text everywhere else in the journal.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_language.dart';
import '../models/journal_entry.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../theme/pv_fonts.dart';
import '../widgets/mic_dictation_button.dart';

/// ⚠️ THREE, AND THE CAP IS DELIBERATE RATHER THAN ARBITRARY. Review set it,
/// and it holds up: a journal entry with twelve photos is an album, and the
/// timeline renders these as a carousel that stops being scannable past about
/// three. It also keeps a single entry small enough to sync.
const int kJournalMaxPhotos = 3;

Future<void> openJournalCompose(
  BuildContext context,
  PregnancyController p, {
  JournalEntry? edit,
  Future<void> Function(JournalEntry entry)? onAdd,
}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'journal/compose'),
      builder: (_) =>
          JournalComposeScreen(pregnancy: p, edit: edit, onAdd: onAdd),
    ));

class JournalComposeScreen extends StatefulWidget {
  const JournalComposeScreen({
    super.key,
    required this.pregnancy,
    this.edit,
    this.onAdd,
  });

  final PregnancyController pregnancy;
  final JournalEntry? edit;

  /// The father's journal passes its own store hook, exactly as the old sheet
  /// allowed. One composer, two journals.
  final Future<void> Function(JournalEntry entry)? onAdd;

  @override
  State<JournalComposeScreen> createState() => _JournalComposeScreenState();
}

class _JournalComposeScreenState extends State<JournalComposeScreen> {
  late final TextEditingController _heading =
      TextEditingController(text: widget.edit?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.edit?.description ?? '');

  late List<String> _photos = [...(widget.edit?.images ?? const <String>[])];
  bool _saving = false;

  /// ⚠️ CAPTURED ONCE, AT OPEN, NOT READ AT SAVE. If it were read at save the
  /// stamp would be the moment she finished typing, which for a memory written
  /// over ten minutes is the wrong minute - and for an entry left open on a
  /// backgrounded phone could be hours out.
  late final DateTime _stamp = widget.edit?.date ?? DateTime.now();

  @override
  void dispose() {
    _heading.dispose();
    _body.dispose();
    super.dispose();
  }

  /// ⚠️ EITHER HALF. This getter is the rule the whole screen exists to
  /// express, so it is one line and it is read by the button, the hint and the
  /// preview rather than being re-derived at each.
  bool get _canSave =>
      _heading.text.trim().isNotEmpty ||
      _body.text.trim().isNotEmpty ||
      _photos.isNotEmpty;

  Future<void> _addPhoto() async {
    if (_photos.length >= kJournalMaxPhotos) return;
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ]),
        ),
      ),
    );
    if (src == null) return;

    final picked = await ImagePicker().pickImage(source: src, imageQuality: 85);
    if (picked == null) return;
    // Copied into the app's own directory: a gallery path can be revoked or
    // cleaned up by the OS, and a journal that loses its photos is not a
    // journal.
    final saved = await JournalStore.saveImage(picked.path);
    if (!mounted) return;
    setState(() => _photos = [..._photos, saved]);
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final heading = _heading.text.trim();
    final body = _body.text.trim();

    // ⚠️ A PHOTO-ONLY ENTRY STILL NEEDS A TITLE, because the timeline renders
    // one. Rather than showing an empty row, an untitled entry is named for
    // what it is - which is also what she would have called it.
    final title = heading.isNotEmpty
        ? heading
        : (body.isNotEmpty
            ? body
            : (_photos.length == 1 ? 'A photo' : '${_photos.length} photos'));

    final store = JournalStore.instance;
    final edit = widget.edit;

    if (edit != null) {
      await store.updateEntry(edit.copyWith(
        title: title,
        description: heading.isNotEmpty ? body : '',
        imageUrls: _photos,
      ));
    } else {
      final entry = JournalEntry(
        id: 'j_${DateTime.now().microsecondsSinceEpoch}',
        type: JournalEntryType.memory,
        title: title,
        // Only carry the body separately when there is a heading above it;
        // otherwise the body IS the title and duplicating it would render the
        // same sentence twice on the card.
        description: heading.isNotEmpty ? body : '',
        date: _stamp,
        weekNumber: widget.pregnancy.currentWeek,
        imageUrls: _photos,
      );
      if (widget.onAdd != null) {
        await widget.onAdd!(entry);
      } else {
        await store.addEntry(entry);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.pregnancy.language);

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.edit == null ? 'Add a memory' : 'Edit memory',
            style: pvJakarta(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900)),
        actions: [
          TextButton(
            onPressed: _canSave && !_saving ? _save : null,
            child: Text('Save',
                style: pvJakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _canSave
                        ? AppTheme.primary600
                        : AppTheme.neutral500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          // ---- heading --------------------------------------------------
          TextField(
            controller: _heading,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
            style: pvJakarta(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900),
            decoration: InputDecoration(
              hintText: 'Give it a name (optional)',
              hintStyle: pvJakarta(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(height: 22),

          // ---- body, with dictation ------------------------------------
          TextField(
            controller: _body,
            onChanged: (_) => setState(() {}),
            minLines: 5,
            maxLines: 14,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(
                fontSize: 15, height: 1.6, color: AppTheme.neutral800),
            decoration: InputDecoration(
              hintText:
                  'Write it, or tap the mic and just say it. You can also '
                  'skip this and only add photos.',
              hintStyle: pvManrope(
                  fontSize: 14.5, height: 1.5, color: AppTheme.neutral500),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              // ⚠️ REUSED, NOT REBUILT. Speech-to-text already exists and is
              // already used by the journal's other compose surfaces.
              suffixIcon: MicDictateButton(controller: _body, s: s),
            ),
          ),
          const SizedBox(height: 20),

          // ---- photos ---------------------------------------------------
          Row(children: [
            Text('PHOTOS',
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppTheme.neutral500)),
            const SizedBox(width: 8),
            Text('${_photos.length} of $kJournalMaxPhotos',
                style: pvManrope(fontSize: 11, color: AppTheme.neutral400)),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _photos.length; i++)
                _Thumb(
                  path: _photos[i],
                  onRemove: () =>
                      setState(() => _photos = [..._photos]..removeAt(i)),
                ),
              if (_photos.length < kJournalMaxPhotos)
                _AddTile(onTap: _addPhoto),
            ],
          ),

          const SizedBox(height: 26),
          // ---- how it will read afterwards ------------------------------
          //
          // ⚠️ THE STAMP IS SHOWN WHILE SHE WRITES, NOT ONLY AFTER SAVING.
          // She is choosing what to keep; seeing that the date, time and place
          // travel with it is part of that decision, and it is also the only
          // honest way to show that place is currently blank.
          _MetaPreview(stamp: _stamp, place: widget.edit?.place),

          if (!_canSave) ...[
            const SizedBox(height: 18),
            Text(
                'Write something, or add a photo. Either one is enough to '
                'save.',
                style: pvManrope(
                    fontSize: 12.5, height: 1.5, color: AppTheme.neutral500)),
          ],
        ],
      ),
    );
  }
}

/// The date / time / place line, in the shape it takes under a post.
class _MetaPreview extends StatelessWidget {
  const _MetaPreview({required this.stamp, this.place});
  final DateTime stamp;
  final String? place;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _fmt(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'am' : 'pm';
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}  ·  $h12:$m $ampm';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(Icons.schedule_rounded, size: 15, color: AppTheme.neutral500),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
                // ⚠️ A NULL PLACE RENDERS NOTHING, never "Location
                // unavailable". That would be an error message about a
                // feature she never asked for.
                place == null ? _fmt(stamp) : '${_fmt(stamp)}  ·  $place',
                style:
                    pvManrope(fontSize: 12, color: AppTheme.neutral600)),
          ),
        ]),
      );
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(File(path),
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                    width: 96,
                    height: 96,
                    color: AppTheme.neutral200,
                    child: Icon(Icons.broken_image_outlined,
                        color: AppTheme.neutral500),
                  )),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ]);
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Icon(Icons.add_rounded, color: AppTheme.neutral500),
        ),
      );
}
