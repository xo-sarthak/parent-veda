// =============================================================================
//  My Journal V2 - capture flow (add sheet + 4 capture modes)
// -----------------------------------------------------------------------------
//  Two taps to a saved memory: the FAB opens the add sheet, each option opens a
//  focused capture screen with one obvious primary action.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/pv_fonts.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../doors/pv_list_row.dart' show PvListRow, PvRowGroup;
import '../../pregnancy/preg_tool_chrome.dart';
import '../../products/pv_store_chrome.dart' show PvChip, PvCommit, pvStorePalette;
import '../../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../../v2/v2_palette.dart' show V2Palette, v2BlockTint;
import 'jv2_common.dart';
import 'jv2_data.dart';
import 'jv2_store.dart';
import '../../../widgets/pv_feedback.dart' show PvPress;

// =============================================================================
//  THE ONE PARENTVEDA LOOK (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "My journal section when clicked opens up with the old UI,
//  everything purple." The journal list moved onto PregToolScaffold earlier
//  today; everything it opens still wore the old chrome (purple mic disc,
//  purple tab underline, coral/lavender icon wells, Jakarta titles). Each
//  screen below now wears the shell every TTC and pregnancy tool wears, the
//  add sheet is a white sheet of PvListRows with the drawn TTC marks, and the
//  one primary action is an ink PvCommit.
//
//  Mobbin (journal composer): the prompt as a serif heading, a small-caps
//  label over the writing area, a strip of attach controls as plain round
//  outlined buttons, one dark commit - after Stoic
//  (mobbin.com/screens/031adb37-b0a4-4362-a7e6-10c535b883b8) and the
//  small-caps field label of 5 Minute Journal
//  (mobbin.com/screens/0786f4b2-2305-4863-8c88-ad5024887402).
//
//  Only the chrome changed. Every save still goes through `_save` ->
//  PpJournalStore.instance.add with the same kind, title, body and photo.
//  Each old build is kept for revert beside its replacement.
// =============================================================================

/// The journal's field colour: the rose of pregnancy's Keep group (Memories,
/// hue 330), not a lilac, so a memory looks the same in both stages.
const double kPpJournalHue = 330;

/// Small caps over a group or a field: Manrope 11, w800, letterspaced.
Widget _capsLabel(V2Palette p, String text) => Text(text.toUpperCase(),
    style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action));

/// The white card a writing field sits in.
Widget _writingCard(V2Palette p, Widget child, {Key? key}) => Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: child,
    );

/// The drawn mark for each way of adding a memory.
Widget _journalMark(TtcTabMark m, {double size = 40}) =>
    TtcMarkLeading(tab: m, tint: v2BlockTint(kPpJournalHue, pvStorePalette), size: size);

// ---- add-memory bottom sheet (the one look) ----------------------------------
void showAddMemorySheet(BuildContext context) {
  void go(Widget s) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  }

  final p = pvStorePalette;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(999)))),
          const SizedBox(height: 18),
          _capsLabel(p, 'Journal'),
          const SizedBox(height: 6),
          Text("Add to $jvChild's Story",
              style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
          const SizedBox(height: 14),
          PvRowGroup(p: p, children: [
            PvListRow(
              key: const ValueKey('jv_add_guided'),
              p: p,
              leading: _journalMark(TtcTabMark.flagPath),
              title: 'Guided Memory',
              line: 'Capture important milestones',
              onTap: () => go(const GuidedMemoryScreen()),
            ),
            PvListRow(
              key: const ValueKey('jv_add_quick'),
              p: p,
              leading: _journalMark(TtcTabMark.sunrise),
              title: 'Quick Capture',
              line: 'Photo, video or a voice note',
              onTap: () => go(const QuickCaptureScreen()),
            ),
            PvListRow(
              key: const ValueKey('jv_add_story'),
              p: p,
              leading: _journalMark(TtcTabMark.openBook),
              title: 'Write a Story',
              line: 'Write your own story',
              onTap: () => go(const WriteStoryScreen()),
            ),
            PvListRow(
              key: const ValueKey('jv_add_letter'),
              p: p,
              leading: _journalMark(TtcTabMark.heartHand),
              title: "Letter to $jvChild",
              line: 'Write a letter for the future',
              onTap: () => go(const LetterScreen()),
            ),
          ]),
        ]),
      ),
    ),
  );
}

/// Photo, video, voice as round outlined controls (Stoic's attach strip), the
/// picked photo above them. Same behaviour as [_mediaRow]: photo is real,
/// video and voice say honestly that they are coming.
Widget _mediaRowV3(BuildContext context, {String? photo, ValueChanged<String?>? onPhoto}) {
  final p = pvStorePalette;
  Widget item(IconData icon, String label, VoidCallback onTap, {bool on = false}) => Expanded(
        child: Semantics(
          button: true,
          label: on ? 'Photo added' : label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ExcludeSemantics(
                child: Column(children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? p.ink1 : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: on ? p.ink1 : p.line),
                    ),
                    child: Icon(on ? Icons.check_rounded : icon, size: 20, color: on ? Colors.white : p.ink1),
                  ),
                  const SizedBox(height: 6),
                  Text(on ? 'Photo added' : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2)),
                ]),
              ),
            ),
          ),
        ),
      );
  void soon(String label) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label - coming soon'), behavior: SnackBarBehavior.floating),
      );
  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    if (photo != null) ...[
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(photo), height: 140, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(height: 0)),
      ),
      const SizedBox(height: 12),
    ],
    Row(children: [
      item(Icons.photo_camera_outlined, 'Photo', () async {
        if (onPhoto == null) return soon('Photo');
        if (photo != null) return onPhoto(null);
        final picked = await _pickPhoto(context);
        if (picked != null) onPhoto(picked);
      }, on: photo != null),
      item(Icons.videocam_outlined, 'Video', () => soon('Video')),
      item(Icons.mic_none_rounded, 'Voice', () => soon('Voice')),
    ]),
  ]);
}

// ---- add-memory bottom sheet ------------------------------------------------
// Kept for revert (2026-10-07): the purple-welled sheet before the one look.
// ignore: unused_element
void _showAddMemorySheetBeforeShell(BuildContext context) {
  void go(Widget s) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
          const SizedBox(height: 16),
          Text("Add to $jvChild's Story", style: ppFraunces(24, h: 1.1)),
          const SizedBox(height: 16),
          _sheetRow(Icons.auto_awesome_outlined, 'Guided Memory', 'Capture important milestones', () => go(const GuidedMemoryScreen())),
          _sheetRow(Icons.photo_camera_outlined, 'Quick Capture', 'Photo, video or a voice note', () => go(const QuickCaptureScreen())),
          _sheetRow(Icons.edit_outlined, 'Write a Story', 'Write your own story', () => go(const WriteStoryScreen())),
          _sheetRow(Icons.favorite_border, "Letter to $jvChild", 'Write a letter for the future', () => go(const LetterScreen()), last: true),
        ]),
      ),
    ),
  );
}

Widget _sheetRow(IconData icon, String title, String sub, VoidCallback onTap, {bool last = false}) => PvPress(child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: last ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppJakarta(15)),
              const SizedBox(height: 2),
              Text(sub, style: ppBody(12)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    ));

// ---- media row (photo / video / voice) --------------------------------------
//  Photo is real since 2026-10-02 (gallery or camera, kept by PpJournalStore).
//  Video and voice still say so honestly. The old all-"coming soon" row is
//  kept for revert below.
Widget _mediaRow(BuildContext context, {String? photo, ValueChanged<String?>? onPhoto}) {
  Widget item(IconData icon, String label, VoidCallback onTap, {bool on = false}) => Expanded(
        child: PvPress(child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Icon(on ? Icons.check_circle_rounded : icon, size: 22, color: ppPurple),
            const SizedBox(height: 6),
            Text(on ? 'Photo added' : label, style: ppBody(11, color: ppSoft, w: FontWeight.w600)),
          ]),
        )),
      );
  void soon(String label) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label - coming soon'), behavior: SnackBarBehavior.floating),
      );
  return Column(children: [
    if (photo != null) ...[
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(File(photo), height: 120, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(height: 0)),
      ),
      const SizedBox(height: 12),
    ],
    Row(children: [
      item(Icons.photo_camera_outlined, 'Photo', () async {
        if (onPhoto == null) return soon('Photo');
        if (photo != null) return onPhoto(null);
        final picked = await _pickPhoto(context);
        if (picked != null) onPhoto(picked);
      }, on: photo != null),
      item(Icons.videocam_outlined, 'Video', () => soon('Video')),
      item(Icons.mic_none_rounded, 'Voice', () => soon('Voice')),
    ]),
  ]);
}

Future<String?> _pickPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: ppBg,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Ink line icons and Manrope (2026-10-07), the one look.
        ListTile(
            leading: Icon(Icons.photo_library_outlined, color: pvStorePalette.ink1),
            title: Text('Choose from gallery', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: pvStorePalette.ink1)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery)),
        ListTile(
            leading: Icon(Icons.photo_camera_outlined, color: pvStorePalette.ink1),
            title: Text('Take a photo', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: pvStorePalette.ink1)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera)),
      ]),
    ),
  );
  if (source == null) return null;
  try {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 2000, imageQuality: 85);
    return x?.path;
  } catch (_) {
    return null;
  }
}

/* Kept for revert: the row where every item said "coming soon".
Widget _mediaRowOld(BuildContext context) {
  Widget item(IconData icon, String label) => Expanded(
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label - coming soon'), behavior: SnackBarBehavior.floating),
          ),
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Icon(icon, size: 22, color: ppPurple),
            const SizedBox(height: 6),
            Text(label, style: ppBody(11, color: ppSoft, w: FontWeight.w600)),
          ]),
        ),
      );
  return Row(children: [
    item(Icons.photo_camera_outlined, 'Photo'),
    item(Icons.videocam_outlined, 'Video'),
    item(Icons.mic_none_rounded, 'Voice'),
  ]);
}
*/

/// Saves through PpJournalStore, then confirms. Nothing written and no photo
/// means nothing saved, and she is told so rather than thanked.
Future<void> _save(BuildContext context, String what, JvKind kind, {String title = '', String body = '', String? photo}) async {
  final messenger = ScaffoldMessenger.of(context);
  final nav = Navigator.of(context);
  final ok = await PpJournalStore.instance.add(kind: kind, title: title, body: body, pickedPhotoPath: photo);
  messenger.showSnackBar(SnackBar(
    content: Text(ok ? '$what saved to $jvChild\'s journal' : 'Write a few words or add a photo first'),
    behavior: SnackBarBehavior.floating,
  ));
  if (ok) nav.maybePop();
}

/* Kept for revert: the version that thanked her and stored nothing.
void _saved(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what saved to the story'), behavior: SnackBarBehavior.floating));
  Navigator.of(context).maybePop();
}
*/

// ---- Guided Memory ----------------------------------------------------------
class GuidedMemoryScreen extends StatefulWidget {
  const GuidedMemoryScreen({super.key});
  @override
  State<GuidedMemoryScreen> createState() => _GuidedMemoryScreenState();
}

class _GuidedMemoryScreenState extends State<GuidedMemoryScreen> {
  int _tab = 0;
  static const _tabs = ['Suggested', 'Completed', 'All'];

  /// One drawn mark per prompt, by what the first is about. A prompt this
  /// map does not know falls back to the path with a flag: a first.
  static TtcTabMark _markFor(String title) => switch (title) {
        'First Day at School' => TtcTabMark.signpost,
        'First Sleepover' => TtcTabMark.twoFigures,
        'Learned to Ride' => TtcTabMark.windingPath,
        'Favourite Food' => TtcTabMark.bowl,
        'Family Vacation' => TtcTabMark.pin,
        _ => TtcTabMark.flagPath,
      };

  // The one look (2026-10-07): the tool shell, ink chips for the tabs, the
  // prompts as PvListRows with drawn marks. Same prompts, same tap target.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: kPpJournalHue,
      eyebrow: 'Journal',
      mark: IntentMark.bookMark,
      title: 'Guided Memories',
      intro: 'Pick a first and answer one prompt. It goes straight into $jvChild\'s journal.',
      children: [
        pregToolPad(Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < _tabs.length; i++)
            PvChip(label: _tabs[i], selected: i == _tab, onTap: () => setState(() => _tab = i)),
        ])),
        const SizedBox(height: 18),
        pregToolPad(PvRowGroup(p: p, children: [
          for (final g in jvGuided)
            PvListRow(
              key: ValueKey('jv_guided_${g.title}'),
              p: p,
              leading: _journalMark(_markFor(g.title)),
              title: g.title,
              line: '${g.subtitle} · ${g.minutes} min',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuickCaptureScreen(prompt: g.title))),
            ),
        ])),
      ],
    );
  }

  // Kept for revert (2026-10-07): the purple-underlined tabs and coral wells.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(jvTopBar(context, title: 'Guided Memories')),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
              for (var i = 0; i < _tabs.length; i++)
                PvPress(child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 22),
                    child: Column(children: [
                      Text(_tabs[i], style: ppBody(14, color: i == _tab ? ppInk : ppMuted, w: i == _tab ? FontWeight.w700 : FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(height: 2, width: 22, color: i == _tab ? ppPurple : Colors.transparent),
                    ]),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 8),
          for (final g in jvGuided)
            jvPad(PvPress(child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => QuickCaptureScreen(prompt: g.title))),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(13)),
                    child: Icon(g.icon, size: 20, color: ppCoral),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(g.title, style: ppJakarta(15)),
                      const SizedBox(height: 2),
                      Text('${g.subtitle} · ${g.minutes} min', style: ppBody(12)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                ]),
              ),
            ))),
        ],
      ),
    );
  }
}

// ---- Quick Capture ----------------------------------------------------------
class QuickCaptureScreen extends StatefulWidget {
  const QuickCaptureScreen({super.key, this.prompt});
  final String? prompt;

  @override
  State<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends State<QuickCaptureScreen> {
  final _text = TextEditingController();
  String? _photo;

  String? get prompt => widget.prompt;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  // The one look (2026-10-07). The prompt is the serif title (Stoic), the
  // words go in one white card under a small-caps label (5 Minute Journal),
  // photo/video/voice are the round attach strip, Save is the ink commit.
  // The big purple mic is gone from this build: Voice in the strip says the
  // same "coming soon" it did. Same save: kind moment, title = the prompt.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: kPpJournalHue,
      eyebrow: 'A moment',
      title: prompt ?? "What's happening today?",
      children: [
        pregToolPad(_capsLabel(p, 'In your words')),
        const SizedBox(height: 8),
        pregToolPad(_writingCard(
          p,
          key: const ValueKey('jv_quick_field'),
          TextField(
            // autofocus so the cursor is blinking the moment the screen
            // opens: somewhere to type, not something to look at.
            controller: _text,
            autofocus: true,
            minLines: 4,
            maxLines: null,
            style: pvManrope(fontSize: 15, height: 1.6, color: p.ink1),
            cursorColor: p.ink1,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              hintText: 'A line or two is plenty.',
              hintStyle: pvManrope(fontSize: 15, height: 1.6, color: p.ink3),
            ),
          ),
        )),
        const SizedBox(height: 18),
        pregToolPad(_mediaRowV3(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
        const SizedBox(height: 18),
        pregToolPad(PvCommit(
          key: const ValueKey('jv_quick_save'),
          label: 'Save',
          onTap: () => _save(context, 'Memory', JvKind.moment, title: prompt ?? '', body: _text.text, photo: _photo),
        )),
      ],
    );
  }

  // Kept for revert (2026-10-07): the coral-gradient page with the purple mic.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppCoralTint, ppBg]),
            ),
            child: Column(children: [
              Row(children: [
                PvPress(child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(Icons.close_rounded, size: 24, color: ppInk),
                )),
                const Spacer(),
              ]),
              const SizedBox(height: 8),
              TextField(
                // autofocus so the cursor is blinking on the prompt the moment
                // the screen opens. Without it the page reads as something to
                // look at rather than somewhere to type - there was nothing
                // telling you where the words were meant to go.
                controller: _text,
                autofocus: true,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: ppFraunces(22, h: 1.2),
                cursorColor: ppPurple,
                cursorWidth: 2.2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  hintText: prompt ?? "What's happening today?",
                  hintStyle: ppFraunces(22, color: ppMuted, h: 1.2),
                ),
              ),
            ]),
          ),
          const Spacer(),
          PvPress(child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice capture - coming soon'), behavior: SnackBarBehavior.floating),
            ),
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x596A30B6), blurRadius: 30, spreadRadius: -6, offset: Offset(0, 12))],
              ),
              child: const Icon(Icons.mic_none_rounded, size: 34, color: Colors.white),
            ),
          )),
          const SizedBox(height: 14),
          Text('Tap to speak', style: ppBody(13, color: ppMuted)),
          const Spacer(),
          jvPad(_mediaRow(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
          const SizedBox(height: 18),
          jvPad(jvButton('Save', () => _save(context, 'Memory', JvKind.moment, title: prompt ?? '', body: _text.text, photo: _photo))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}

// ---- Write a Story ----------------------------------------------------------
class WriteStoryScreen extends StatefulWidget {
  const WriteStoryScreen({super.key});
  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String? _photo;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  // The one look (2026-10-07): title and story each under a small-caps
  // label in a white card, the attach strip, the ink commit. Same save.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: kPpJournalHue,
      eyebrow: 'A story',
      title: 'Write a Story',
      intro: 'Anything you want to remember about today, in your own words.',
      children: [
        pregToolPad(_capsLabel(p, 'Title')),
        const SizedBox(height: 8),
        pregToolPad(_writingCard(
          p,
          key: const ValueKey('jv_story_title'),
          TextField(
            controller: _title,
            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1),
            cursorColor: p.ink1,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              hintText: 'Add a title',
              hintStyle: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25, color: p.ink3),
            ),
          ),
        )),
        const SizedBox(height: 16),
        pregToolPad(_capsLabel(p, 'The story')),
        const SizedBox(height: 8),
        pregToolPad(_writingCard(
          p,
          key: const ValueKey('jv_story_body'),
          TextField(
            controller: _body,
            minLines: 6,
            maxLines: null,
            style: pvManrope(fontSize: 15, height: 1.7, color: p.ink1),
            cursorColor: p.ink1,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              hintText: 'Today was so special…',
              hintStyle: pvManrope(fontSize: 15, height: 1.7, color: p.ink3),
            ),
          ),
        )),
        const SizedBox(height: 18),
        pregToolPad(_mediaRowV3(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
        const SizedBox(height: 18),
        pregToolPad(PvCommit(
          key: const ValueKey('jv_story_save'),
          label: 'Save Story',
          onTap: () => _save(context, 'Story', JvKind.story, title: _title.text, body: _body.text, photo: _photo),
        )),
      ],
    );
  }

  // Kept for revert (2026-10-07): the bare page with an X and Jakarta inputs.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(children: [
              PvPress(child: GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: const Icon(Icons.close_rounded, size: 24, color: ppInk))),
              const Spacer(),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              children: [
                TextField(
                  controller: _title,
                  style: ppFraunces(28, h: 1.15),
                  decoration: InputDecoration(border: InputBorder.none, filled: false, hintText: 'Add a title', hintStyle: ppFraunces(28, color: ppMuted, h: 1.15)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _body,
                  maxLines: null,
                  style: ppBody(15, color: ppInk, h: 1.7),
                  decoration: InputDecoration(border: InputBorder.none, filled: false, hintText: 'Today was so special…', hintStyle: ppBody(15, color: ppMuted, h: 1.7)),
                ),
              ],
            ),
          ),
          jvPad(_mediaRow(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
          const SizedBox(height: 16),
          jvPad(jvButton('Save Story', () => _save(context, 'Story', JvKind.story, title: _title.text, body: _body.text, photo: _photo))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}

// ---- Letter to Aarav --------------------------------------------------------
class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});
  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final _body = TextEditingController();
  String? _photo;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  // The one look (2026-10-07): the letter is still set in italic serif, as a
  // letter should be, but on a white card with a hairline instead of ivory
  // paper. Same save: kind letter, title "Letter to <name>".
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final letterStyle = pvFraunces(fontSize: 16, height: 1.9, color: p.ink1).copyWith(fontStyle: FontStyle.italic);
    return PregToolScaffold(
      hue: kPpJournalHue,
      eyebrow: 'A letter',
      title: 'Letter to $jvChild',
      intro: 'Write it for the day they are old enough to read it.',
      children: [
        pregToolPad(_capsLabel(p, 'Your letter')),
        const SizedBox(height: 8),
        pregToolPad(_writingCard(
          p,
          key: const ValueKey('jv_letter_body'),
          TextField(
            controller: _body,
            minLines: 10,
            maxLines: null,
            style: letterStyle,
            cursorColor: p.ink1,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              hintText: 'Dear $jvChild,\n\nOne day, when you read this…',
              hintStyle: letterStyle.copyWith(color: p.ink3),
            ),
          ),
        )),
        const SizedBox(height: 18),
        pregToolPad(_mediaRowV3(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
        const SizedBox(height: 18),
        pregToolPad(PvCommit(
          key: const ValueKey('jv_letter_save'),
          label: 'Save Letter',
          onTap: () => _save(context, 'Letter', JvKind.letter, title: 'Letter to $jvChild', body: _body.text, photo: _photo),
        )),
      ],
    );
  }

  // Kept for revert (2026-10-07): the ivory-paper page with an X.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(children: [
              PvPress(child: GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: const Icon(Icons.close_rounded, size: 24, color: ppInk))),
              const Spacer(),
              Text('Letter to $jvChild', style: ppJakarta(14, color: ppSoft)),
              const Spacer(),
              const SizedBox(width: 24),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: jvPaper, borderRadius: BorderRadius.circular(20), border: Border.all(color: jvPaperLine)),
                child: TextField(
                  controller: _body,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: ppFraunces(16, color: ppInk, h: 1.9).copyWith(fontStyle: FontStyle.italic),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: 'Dear $jvChild,\n\nOne day, when you read this…',
                    hintStyle: ppFraunces(16, color: ppMuted, h: 1.9).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ),
          jvPad(_mediaRow(context, photo: _photo, onPhoto: (v) => setState(() => _photo = v))),
          const SizedBox(height: 16),
          jvPad(jvButton('Save Letter', () => _save(context, 'Letter', JvKind.letter, title: 'Letter to $jvChild', body: _body.text, photo: _photo))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}
