// =============================================================================
//  My Journal V2 — capture flow (add sheet + 4 capture modes)
// -----------------------------------------------------------------------------
//  Two taps to a saved memory: the FAB opens the add sheet, each option opens a
//  focused capture screen with one obvious primary action.
// =============================================================================

import 'package:flutter/material.dart';

import 'jv2_common.dart';
import 'jv2_data.dart';

// ---- add-memory bottom sheet ------------------------------------------------
void showAddMemorySheet(BuildContext context) {
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

Widget _sheetRow(IconData icon, String title, String sub, VoidCallback onTap, {bool last = false}) => GestureDetector(
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
    );

// ---- media row (photo / video / voice) --------------------------------------
Widget _mediaRow(BuildContext context) {
  Widget item(IconData icon, String label) => Expanded(
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label — coming soon'), behavior: SnackBarBehavior.floating),
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

void _saved(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what saved to the story'), behavior: SnackBarBehavior.floating));
  Navigator.of(context).maybePop();
}

// ---- Guided Memory ----------------------------------------------------------
class GuidedMemoryScreen extends StatefulWidget {
  const GuidedMemoryScreen({super.key});
  @override
  State<GuidedMemoryScreen> createState() => _GuidedMemoryScreenState();
}

class _GuidedMemoryScreenState extends State<GuidedMemoryScreen> {
  int _tab = 0;
  static const _tabs = ['Suggested', 'Completed', 'All'];

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
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
                ),
            ]),
          ),
          const SizedBox(height: 8),
          for (final g in jvGuided)
            jvPad(GestureDetector(
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
            )),
        ],
      ),
    );
  }
}

// ---- Quick Capture ----------------------------------------------------------
class QuickCaptureScreen extends StatelessWidget {
  const QuickCaptureScreen({super.key, this.prompt});
  final String? prompt;

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(Icons.close_rounded, size: 24, color: ppInk),
                ),
                const Spacer(),
              ]),
              const SizedBox(height: 8),
              TextField(
                maxLines: 2,
                textAlign: TextAlign.center,
                style: ppFraunces(22, h: 1.2),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: prompt ?? "What's happening today?",
                  hintStyle: ppFraunces(22, color: ppMuted, h: 1.2),
                ),
              ),
            ]),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice capture — coming soon'), behavior: SnackBarBehavior.floating),
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
          ),
          const SizedBox(height: 14),
          Text('Tap to speak', style: ppBody(13, color: ppMuted)),
          const Spacer(),
          jvPad(_mediaRow(context)),
          const SizedBox(height: 18),
          jvPad(jvButton('Save', () => _saved(context, 'Memory'))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}

// ---- Write a Story ----------------------------------------------------------
class WriteStoryScreen extends StatelessWidget {
  const WriteStoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: const Icon(Icons.close_rounded, size: 24, color: ppInk)),
              const Spacer(),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              children: [
                TextField(
                  style: ppFraunces(28, h: 1.15),
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Add a title', hintStyle: ppFraunces(28, color: ppMuted, h: 1.15)),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: null,
                  style: ppBody(15, color: ppInk, h: 1.7),
                  decoration: InputDecoration(border: InputBorder.none, hintText: 'Today was so special…', hintStyle: ppBody(15, color: ppMuted, h: 1.7)),
                ),
              ],
            ),
          ),
          jvPad(_mediaRow(context)),
          const SizedBox(height: 16),
          jvPad(jvButton('Save Story', () => _saved(context, 'Story'))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}

// ---- Letter to Aarav --------------------------------------------------------
class LetterScreen extends StatelessWidget {
  const LetterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: const Icon(Icons.close_rounded, size: 24, color: ppInk)),
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
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: ppFraunces(16, color: ppInk, h: 1.9).copyWith(fontStyle: FontStyle.italic),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Dear $jvChild,\n\nOne day, when you read this…',
                    hintStyle: ppFraunces(16, color: ppMuted, h: 1.9).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ),
          jvPad(_mediaRow(context)),
          const SizedBox(height: 16),
          jvPad(jvButton('Save Letter', () => _saved(context, 'Letter'))),
          const SizedBox(height: 18),
        ]),
      ),
    );
  }
}
