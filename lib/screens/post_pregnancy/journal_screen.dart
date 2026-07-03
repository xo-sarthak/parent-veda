// =============================================================================
//  MyChildJournalScreen — Journal · private space (parenting app · S9)
// -----------------------------------------------------------------------------
//  The child's private, auto-transcribing journal: quick-capture, then a
//  reverse-chronological feed of voice / photo / note moments (with a milestone
//  auto-detected). Faithful build of Claude Design S9. Reached from Home →
//  Capture today → Journal.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class MyChildJournalScreen extends StatelessWidget {
  const MyChildJournalScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  // Waveform bar heights (0–1) and whether "played" (purple) vs upcoming (lavender).
  static const List<double> _wave = [.40, .70, 1, .55, .85, .35, .65, .90, .45, .75, .30, .60, .50, .80];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Aarav')),

            const SizedBox(height: 22),
            _pad(Text("Aarav's journal", style: ppFraunces(30, h: 1.15))),
            const SizedBox(height: 4),
            _pad(Text('Just for you. 34 moments saved.', style: ppBody(13))),

            const SizedBox(height: 20),
            _pad(Row(children: [
              _quick(context, Icons.mic_none_rounded, 'Record', filled: true),
              const SizedBox(width: 10),
              _quick(context, Icons.photo_camera_outlined, 'Photo'),
              const SizedBox(width: 10),
              _quick(context, Icons.edit_outlined, 'Note'),
            ])),

            const SizedBox(height: 26),
            _pad(ppEyebrow('Today · Tue 8 July', color: ppMuted, spacing: 1.0)),
            const SizedBox(height: 14),

            // voice entry
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _wave.length; i++) ...[
                            Container(
                              width: 3,
                              height: 30 * _wave[i],
                              decoration: BoxDecoration(
                                  color: i < 5 ? ppPurple : const Color(0xFFC7B2E0),
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('0:24', style: ppBody(12, color: ppSoft, w: FontWeight.w600)),
                ]),
                const SizedBox(height: 14),
                Text(
                    '"He rolled halfway across the mat and looked so proud of himself. I actually gasped out loud — his little face just lit up."',
                    style: ppBody(14, color: ppInk, h: 1.6)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_outlined, size: 12, color: ppBrown),
                    const SizedBox(width: 5),
                    Flexible(child: Text('Auto-transcribed · हिं → EN', style: ppBody(11, color: ppBrown, w: FontWeight.w700))),
                  ]),
                ),
              ]),
            )),

            // milestone
            const SizedBox(height: 14),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8C8EA)),
              ),
              child: Row(children: [
                const Icon(Icons.flag_rounded, size: 20, color: ppCoral),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('First half-roll', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text("Milestone added to Aarav's timeline.", style: ppBody(12)),
                  ]),
                ),
              ]),
            )),

            const SizedBox(height: 26),
            _pad(ppEyebrow('Yesterday · Mon 7 July', color: ppMuted, spacing: 1.0)),
            const SizedBox(height: 14),
            _pad(ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFECE5F2)), borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const PpStriped(height: 180),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text("Morning light, milk drunk, world's okay.", style: ppBody(14, color: ppInk, h: 1.55)),
                  ),
                ]),
              ),
            )),

            const SizedBox(height: 26),
            _pad(ppEyebrow('Sun 6 July', color: ppMuted, spacing: 1.0)),
            const SizedBox(height: 14),
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white, border: Border.all(color: const Color(0xFFECE5F2)), borderRadius: BorderRadius.circular(20)),
              child: Text(
                  "Third night waking again at 2am. Reminding myself: it's the leap, not us. Writing it down so future-me remembers we got through it.",
                  style: ppBody(14, color: ppInk, h: 1.6)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, {bool filled = false}) => Expanded(
        child: GestureDetector(
          onTap: () => _soon(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: filled ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: filled ? null : Border.all(color: ppLine),
            ),
            child: Column(children: [
              Icon(icon, size: 20, color: filled ? Colors.white : ppPurple),
              const SizedBox(height: 7),
              Text(label, style: ppBody(12, color: filled ? Colors.white : ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
      );
}
