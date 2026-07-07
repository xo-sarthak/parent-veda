// =============================================================================
//  DevelopmentMapScreen - the birth-to-five journey, as one map (signature)
// -----------------------------------------------------------------------------
//  A single, beautiful roadmap of the whole early journey - age bands from birth
//  to five, each with its headline skills. "You are here" marks the current
//  stage; the past is celebrated, the future is something to look forward to. Tap
//  any band to see what it holds. No timelines-as-deadlines, no comparison.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class DevelopmentMapScreen extends StatelessWidget {
  const DevelopmentMapScreen({super.key});

  // (range, headline, description, skills)
  static const List<(String, String, String, List<String>)> _bands = [
    ('0–3 months', 'Settling in', 'Learning to focus, hold his head steady, and share that very first smile.', ['Head control', 'First social smile', 'Focusing on faces', 'Cooing']),
    ('3–6 months', 'The world opens up', 'Cause and effect, reaching, rolling, and the music of babble.', ['Rolling', 'Reaching & grasping', 'Cause & effect', 'Musical babble']),
    ('6–9 months', 'On the move', 'Sitting steady, first foods, and the magic of “where did it go?”.', ['Sitting', 'Object permanence', 'First foods', 'Hand-to-hand']),
    ('9–12 months', 'Cruising & first words', 'Pulling up, the tiny pincer grasp, and a meaningful “mama”.', ['Pulling up', 'Pincer grasp', 'First words', 'Waving']),
    ('1–2 years', 'Little explorer', 'First steps bloom into running; words into little phrases.', ['Walking', 'Words bloom', 'Big feelings', 'Pretend begins']),
    ('2–3 years', 'Me do it', 'Sentences, pretend play, and a fierce new independence.', ['Short sentences', 'Pretend play', 'Independence', 'Sharing (in time)']),
    ('3–4 years', 'Endless why', 'Imagination soars, friendships form, self-care grows.', ['Storytelling', 'Friendships', 'Dressing', 'Endless questions']),
    ('4–5 years', 'Ready for the world', 'Rich stories, real conversations, and school-ready skills.', ['Complex talk', 'Cooperative play', 'Early letters', 'Self-reliance']),
  ];

  static const int _current = 1; // Aarav ~4 months → the 3–6 band

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Development')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('The Development Map', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Birth to five', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('The whole early journey, as one gentle map. Ages are guides, not deadlines - every child walks it at their own pace.', style: ppBody(14, h: 1.5))),
            const SizedBox(height: 22),
            _pad(Column(children: [
              for (int i = 0; i < _bands.length; i++) _band(context, i, first: i == 0, last: i == _bands.length - 1),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _band(BuildContext context, int i, {bool first = false, bool last = false}) {
    final b = _bands[i];
    final isCurrent = i == _current;
    final isPast = i < _current;
    final accent = isCurrent ? ppCoral : ppPurple;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 34,
          child: Column(children: [
            SizedBox(height: 4, child: first ? null : Container(width: 2, color: ppBorder)),
            _node(isCurrent, isPast),
            if (!last) Expanded(child: Container(width: 2, color: ppBorder)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => _sheet(context, i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrent ? ppCoral.withValues(alpha: 0.07) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isCurrent ? ppCoral.withValues(alpha: 0.45) : ppHair),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(b.$1.toUpperCase(), style: ppBody(9.5, color: isPast ? ppMuted : accent, w: FontWeight.w800).copyWith(letterSpacing: 0.5)),
                  const Spacer(),
                  if (isCurrent)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)), child: Text('YOU ARE HERE', style: ppBody(8.5, color: Colors.white, w: FontWeight.w800).copyWith(letterSpacing: 0.5))),
                ]),
                const SizedBox(height: 6),
                Text(b.$2, style: ppFraunces(18, h: 1.15, color: isPast ? ppSoft : ppInk)),
                const SizedBox(height: 6),
                Text(b.$3, style: ppBody(13, color: isPast ? ppMuted : ppSoft, h: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(spacing: 7, runSpacing: 7, children: [
                  for (final s in b.$4.take(3))
                    Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)), child: Text(s, style: ppBody(10.5, color: ppSoft, w: FontWeight.w600))),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _node(bool isCurrent, bool isPast) {
    if (isCurrent) {
      return Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: ppCoralTint, border: Border.all(color: ppCoral, width: 2)), child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)));
    }
    if (isPast) {
      return Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 14, color: Colors.white));
    }
    return Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFCFC5DB), width: 1.5)));
  }

  void _sheet(BuildContext context, int i) {
    final b = _bands[i];
    final isCurrent = i == _current;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Row(children: [
              ppEyebrow(b.$1, color: isCurrent ? ppCoral : ppPurple, spacing: 0.8),
              if (isCurrent) ...[const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)), child: Text('YOU ARE HERE', style: ppBody(8.5, color: Colors.white, w: FontWeight.w800).copyWith(letterSpacing: 0.5)))],
            ]),
            const SizedBox(height: 10),
            Text(b.$2, style: ppFraunces(24, h: 1.12)),
            const SizedBox(height: 10),
            Text(b.$3, style: ppBody(14.5, color: ppInk, h: 1.6)),
            const SizedBox(height: 18),
            Text('What tends to blossom', style: ppJakarta(15)),
            const SizedBox(height: 12),
            for (final s in b.$4)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.auto_awesome_outlined, size: 15, color: isCurrent ? ppCoral : ppPurple),
                  const SizedBox(width: 11),
                  Expanded(child: Text(s, style: ppBody(14, color: ppInk, h: 1.4))),
                ]),
              ),
            const SizedBox(height: 12),
            Text('Many children grow into these across this window - some sooner, some later, and all of it normal.', style: ppBody(11.5, color: ppMuted, h: 1.5)),
          ]),
        ),
      ),
    );
  }
}
