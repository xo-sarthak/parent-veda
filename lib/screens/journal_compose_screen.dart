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
import '../services/place_service.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import '../widgets/mic_dictation_button.dart';
import 'pregnancy/preg_chrome.dart' show PregNote, pregGroupLabelStyle;
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine;

/// ⚠️ THREE, AND THE CAP IS DELIBERATE RATHER THAN ARBITRARY. Review set it,
/// and it holds up: a journal entry with twelve photos is an album, and the
/// timeline renders these as a carousel that stops being scannable past about
/// three. It also keeps a single entry small enough to sync.
const int kJournalMaxPhotos = 3;

// =============================================================================
//  ⚠️ ON THE V3 DESIGN SYSTEM, NOT `AppTheme`.
// -----------------------------------------------------------------------------
//  This screen first shipped on `AppTheme` because `journal_screen.dart` beside
//  it uses `AppTheme`, and matching a neighbour is usually the right instinct.
//  It was the wrong one here: `AppTheme` is one of the three older token
//  systems that still ship the pre-2026-08-16 lilac, so a brand-new screen was
//  being born into the migration backlog.
//
//  Values rather than a live palette reference, for the same reason the Garbh
//  section carries them - see the note at the top of `garbh_screen.dart`.
// =============================================================================
const _ground = Color(0xFFFFFFFF); // V3 ground — white since 2026-09-17; was 0xFFF5F3F6
const _surface = Color(0xFFFFFFFF); // V3 surface
const _surfaceAlt = Color(0xFFEDECEE); // V3 surfaceAlt
// The page hairline, shared (2026-09-30). Kept for revert: Color(0x14000000).
const _line = kPvLine; // V3 line
const _ink1 = Color(0xFF201C24); // V3 ink1
const _ink2 = Color(0xFF2F2C30); // V3 ink2
// ⚠️ A GREY AGAIN, AND A NEUTRAL ONE (2026-09-30). The violet sweep set this
// to the ink, which made every hint, the disabled Save and the stamp's glyphs
// exactly as dark as the words she types: an empty field read as filled and a
// Save she could not press looked pressable. The V3 grey (0xFF6F6878) has a
// violet cast, so this is a neutral grey at the same weight (5.3:1 on white).
// Kept for revert: Color(0xFF2F2C30).
const _ink3 = Color(0xFF726C75); // a neutral ink3
const _action = kPvInk; // the one ink

Future<void> openJournalCompose(
  BuildContext context,
  PregnancyController p, {
  JournalEntry? edit,
  Future<void> Function(JournalEntry entry)? onAdd,
  String? prompt,
}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'journal/compose'),
      builder: (_) => JournalComposeScreen(
          pregnancy: p, edit: edit, onAdd: onAdd, prompt: prompt),
    ));

class JournalComposeScreen extends StatefulWidget {
  const JournalComposeScreen({
    super.key,
    required this.pregnancy,
    this.edit,
    this.onAdd,
    this.prompt,
  });

  final PregnancyController pregnancy;
  final JournalEntry? edit;

  /// The question she chose to answer (My Journal's "this week's question"),
  /// placed as the entry's name so the answer keeps what it answers. Ignored
  /// on an edit.
  final String? prompt;

  /// The father's journal passes its own store hook, exactly as the old sheet
  /// allowed. One composer, two journals.
  final Future<void> Function(JournalEntry entry)? onAdd;

  @override
  State<JournalComposeScreen> createState() => _JournalComposeScreenState();
}

class _JournalComposeScreenState extends State<JournalComposeScreen> {
  /// Typed by her, or filled by the location button and then editable.
  ///
  /// ⚠️ ONE FIELD FOR BOTH SOURCES, AND THAT IS THE DESIGN. There is no
  /// path where the app stamps a place on an entry without it passing
  /// through a box she can see and change first.
  late final TextEditingController _place =
      // An edit re-opens with whatever place it already had, so saving
      // without touching the field cannot quietly drop it.
      TextEditingController(text: widget.edit?.place ?? '');
  bool _locating = false;

  late final TextEditingController _heading =
      TextEditingController(text: widget.edit?.title ?? widget.prompt ?? '');
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
    _place.dispose();
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
              color: _surface,
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
        place: _placeOrNull,
        // Emptying the box removes the place. See `clearPlace` on the model
        // for why this flag has to exist at all.
        clearPlace: _placeOrNull == null,
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
        place: _placeOrNull,
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

  /// Empty means "no place", not an empty string on the entry.
  ///
  /// ⚠️ THE DIFFERENCE IS VISIBLE TO HER. `JournalEntry.place` renders nothing
  /// when null; an empty string would render a stray separator dot under the
  /// date — a mark she cannot explain, on something she is keeping.
  String? get _placeOrNull {
    final t = _place.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _fillPlace() async {
    if (_locating) return;
    setState(() => _locating = true);
    final res = await PlaceService.current();
    if (!mounted) return;
    setState(() => _locating = false);

    if (res.ok) {
      // ⚠️ IT FILLS THE BOX; IT DOES NOT SAVE. She reads what it wrote and can
      // replace "Sector 62, Noida" with "Maa's house" before this ever reaches
      // an entry.
      _place.text = res.label!;
      return;
    }

    // ⚠️ THREE FAILURES, THREE SENTENCES. Telling a woman to enable a setting
    // that is already enabled is its own small insult, and "something went
    // wrong" tells her nothing she can act on.
    final msg = switch (res.failure) {
      PlaceFailure.denied =>
        'No problem — you can type the place instead.',
      PlaceFailure.serviceOff =>
        'Location is switched off on this phone. You can type the place instead.',
      _ => 'Could not find the place just now. You can type it instead.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.pregnancy.language);

    return Scaffold(
      backgroundColor: _ground,
      // The writer's bar, as every stage's writer has it: the page named in the
      // sans at 17, Save in the ink. Kept for revert: pvJakarta for the title.
      appBar: AppBar(
        backgroundColor: _ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _ink1,
        elevation: 0,
        title: Text(widget.edit == null ? 'Add a memory' : 'Edit memory',
            style: pvManrope(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _ink1)),
        actions: [
          TextButton(
            onPressed: _canSave && !_saving ? _save : null,
            child: Text('Save',
                style: pvManrope(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: _canSave
                        ? _action
                        : _ink3)),
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
            // Wraps: this week's question arrives here as the name, and one
            // line cut it off mid-sentence (the phone, 2026-09-23).
            minLines: 1,
            maxLines: 3,
            style: pvJakarta(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _ink1),
            decoration: InputDecoration(
              hintText: 'Give it a name (optional)',
              hintStyle: pvJakarta(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _ink3),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(height: 22, thickness: 1, color: _line),

          // ---- body, with dictation ------------------------------------
          TextField(
            controller: _body,
            onChanged: (_) => setState(() {}),
            minLines: 5,
            maxLines: 14,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(
                fontSize: 15, height: 1.6, color: _ink2),
            decoration: InputDecoration(
              hintText:
                  'Write it, or tap the mic and just say it. You can also '
                  'skip this and only add photos.',
              hintStyle: pvManrope(
                  fontSize: 14.5, height: 1.5, color: _ink3),
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
            // A group label inside the form: the one small grey caps label.
            // Kept for revert: pvManrope 10 / w800 / 1.1, _ink3.
            Text('PHOTOS', style: pregGroupLabelStyle()),
            const SizedBox(width: 8),
            Text('${_photos.length} of $kJournalMaxPhotos',
                style: pvManrope(fontSize: 11, color: _ink3)),
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
          _PlaceField(
            controller: _place,
            busy: _locating,
            onUseLocation: _fillPlace,
          ),
          const SizedBox(height: 14),
          _MetaPreview(stamp: _stamp, place: _placeOrNull),

          // A quiet note on the page, the stage's one shape for a line like
          // this. Kept for revert: a bare Text, pvManrope 12.5, _ink3.
          if (!_canSave) ...[
            const SizedBox(height: 18),
            const PregNote(
                'Write something, or add a photo. Either one is enough to '
                'save.'),
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
  // A white card with the page hairline. Without the hairline it was a white
  // box on a white page, so the stamp floated with no edge.
  // Kept for revert: no border.
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
        ),
        child: Row(children: [
          Icon(Icons.schedule_rounded, size: 15, color: _ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
                // ⚠️ A NULL PLACE RENDERS NOTHING, never "Location
                // unavailable". That would be an error message about a
                // feature she never asked for.
                place == null ? _fmt(stamp) : '${_fmt(stamp)}  ·  $place',
                style:
                    pvManrope(fontSize: 12, color: _ink2)),
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
                    color: _surfaceAlt,
                    child: Icon(Icons.broken_image_outlined,
                        color: _ink3),
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
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Icon(Icons.add_rounded, color: _ink3),
        ),
      );
}

/// Where this happened — typed, or filled from the phone and then edited.
///
/// ⚠️ THE TEXT FIELD IS THE FEATURE; THE BUTTON IS A CONVENIENCE ON TOP. A
/// journal is not a check-in. What belongs under an entry is "Maa's house" or
/// "Apollo, 3rd floor" — words she chose — and a reverse-geocoded "Sector 62,
/// Noida" is accurate while saying almost nothing she would want to read in ten
/// years. So location fills the box and she keeps the last word.
///
/// ⚠️ AND NOTHING IS EVER STAMPED WITHOUT PASSING THROUGH THIS BOX. There is no
/// path in the app where a place reaches a saved entry without appearing here
/// first, where she can see it and change it. That is the whole privacy design,
/// and it is a property of the wiring rather than a promise in a policy.
class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.controller,
    required this.busy,
    required this.onUseLocation,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.place_outlined, size: 15, color: _ink3),
            const SizedBox(width: 8),
            // ⚠️ FLEXIBLE, AND THE LABEL IS WHAT YIELDS. This row overflowed by
            // 54px at 384 wide - a caught-in-test version of the narrow-phone
            // bug. The button carries an action and must never truncate; the
            // label is a question she can still read at half length.
            Flexible(
              child: Text('Where was this?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _ink2)),
            ),
            const SizedBox(width: 8),
            // ⚠️ NOT A TOGGLE, AND NOT ON BY DEFAULT. A one-shot button means
            // the permission prompt appears at the moment she asked for it,
            // which is the only moment it makes sense — and it means location
            // is never read for an entry she did not ask to label.
            TextButton.icon(
              onPressed: busy ? null : onUseLocation,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: busy
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.my_location_rounded, size: 14, color: _ink2),
              label: Text(busy ? 'Finding…' : 'Use location',
                  style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _ink2)),
            ),
          ]),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(fontSize: 14, color: _ink1),
            decoration: InputDecoration(
              // The hint is doing real work: it tells her the field wants a
              // name she would use, not an address.
              hintText: "Maa's house, the terrace, Apollo…",
              hintStyle: pvManrope(fontSize: 13.5, color: _ink3),
              filled: true,
              fillColor: _surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                // The one ink (kept for revert: _ink3, 1.4).
                borderSide: const BorderSide(color: kPvInk, width: 1.4),
              ),
            ),
          ),
        ],
      );
}
