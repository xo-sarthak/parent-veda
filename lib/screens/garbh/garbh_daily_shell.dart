// =============================================================================
//  The one shell for Garbh Sanskar's four daily screens (2026-10-02)
// -----------------------------------------------------------------------------
//  The user: "for each screen of all 4 pillars, updated UI, use Mobbin well."
//  Shravan, Samvad, Buddhi and Kriya each had their own chrome: a cream page, an
//  app bar, an emoji in a square, a tinted "why" box, a "mark complete" line
//  restated four ways. This is one shell: the door's tinted field, the round
//  back, the pillar's drawn mark, the pillar's name and plain subtitle as the
//  eyebrow, today's item as the serif title and ONE line of what it is.
//
//  The shapes under it come from Mobbin: Oura's and Noom's audio sessions
//  (a title, a line, one big control), Givingli's "Tap to Record", LinkedIn's and
//  Quizlet's daily game card, Life Reset's "how the exercise works".
//
//  ⚠️ COMPLETION IS UNCHANGED, AND SO IS ITS RULE. A practice completes because it
//  was DONE (the track ends, the puzzle is solved, the timer runs out, the voice
//  is saved), never because she claimed it. `GarbhDoneLine` is a status and a
//  quiet "Skip today" for the day she cannot, exactly what `_PracticeFoot` was;
//  the spec forbids a streak and there is none. `GarbhStore` is untouched.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/garbh_rebuild_data.dart' show GarbhJournalStore;
import '../../services/garbh_store.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart' show PvDoorToolScaffold, pvDoorPad;
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../pregnancy/preg_tool_parts.dart' show PregFoldRow;
import 'garbh_marks.dart';

/// The pillars' plain names and subtitles, as the daily rows already say them.
const Map<String, (String name, String tag)> kGarbhPillarWords = {
  'shravan': ('Shravan', 'Listening'),
  'samvad': ('Samvad', 'Talking to your baby'),
  'buddhi': ('Buddhi', 'Just for you'),
  'kriya': ('Kriya', 'Breath and grounding'),
};

class GarbhDailyShell extends StatelessWidget {
  const GarbhDailyShell({
    super.key,
    required this.pillarId,
    required this.title,
    required this.intro,
    required this.children,
  });

  final String pillarId;

  /// Today's item, in the serif.
  final String title;

  /// One line: what it is and for whom.
  final String intro;

  /// Content on the white sheet, each already padded by the caller where it needs
  /// to be edge to edge; wrap in [pvDoorPad] for the page gutter.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final words = kGarbhPillarWords[pillarId] ?? (pillarId, '');
    return PvDoorToolScaffold(
      hue: kGarbhHue,
      eyebrow: '${words.$1} · ${words.$2}',
      title: title,
      intro: intro,
      mark: garbhPillarMark(pillarId, size: 56),
      children: [
        ...children,
        const SizedBox(height: 28),
      ],
    );
  }
}

/// What this practice has done today, as a status: done (stated, nothing left to
/// press), or the quiet line and a "Skip today" for a day she cannot.
class GarbhDoneLine extends StatelessWidget {
  const GarbhDoneLine({super.key, required this.pillarId, this.finishLine});
  final String pillarId;

  /// What finishes it, in words ("This finishes when the track ends.").
  final String? finishLine;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return pvDoorPad(AnimatedBuilder(
      animation: GarbhStore.instance,
      builder: (context, _) {
        final done = GarbhStore.instance.isDone(pillarId);
        if (done) {
          return Row(key: ValueKey('garbh_done_$pillarId'), children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('Done for today',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: p.ink1)),
          ]);
        }
        return Row(key: ValueKey('garbh_notdone_$pillarId'), children: [
          Expanded(
            child: Text(finishLine ?? "This finishes on its own when you're done.",
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink3)),
          ),
          TextButton(
            key: ValueKey('garbh_skip_$pillarId'),
            onPressed: () => GarbhStore.instance.markDone(pillarId),
            style: TextButton.styleFrom(
                foregroundColor: p.ink2, minimumSize: const Size(48, 44)),
            child: Text('Skip today',
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
        ]);
      },
    ));
  }
}

/// A line that opens a quiet row onward: "See all ragas", "See all practices".
class GarbhOnwardRow extends StatelessWidget {
  const GarbhOnwardRow({super.key, required this.pillarId, required this.label, required this.onTap});
  final String pillarId;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return pvDoorPad(Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: kPvLine)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('garbh_onward_$pillarId'),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          child: Row(children: [
            garbhPillarMark(pillarId, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
            Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
          ]),
        ),
      ),
    ));
  }
}

/// A "why" or a safety line, ALWAYS ON THE PAGE: a small label over the words, in
/// a white card with the hairline (no tinted box behind text).
///
/// ⚠️ NOT A FOLD, ON PURPOSE. The rebuild's brief makes "why today, and not any
/// other day" the question this section exists to answer, and a safety note is
/// read before she starts; a line she has to open is a line she will not read. So
/// the long, optional words fold (`garbhFold`) and these do not.
Widget garbhNote(String pillarId, String label, String body) => pvDoorPad(Container(
      key: ValueKey('garbh_note_${pillarId}_${label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPvLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: pvStorePalette.ink3)),
        const SizedBox(height: 7),
        Text(body,
            style: pvManrope(fontSize: 14, height: 1.55, color: pvStorePalette.ink1)),
      ]),
    ));

/// A folded line: the title is always on the page, its words open on a tap.
Widget garbhFold(String pillarId, String fold, IconData icon, String title, Widget body) =>
    pvDoorPad(PregFoldRow(
      keyPrefix: 'garbh_fold_$pillarId',
      fold: fold,
      icon: icon,
      title: title,
      body: body,
    ));

/// "Add to my daily": her pin on a track, the same pin the browse list sets
/// (`GarbhJournalStore.togglePinned`, ids like `shravan_<audio id>`).
///
/// ⚠️ ADDED 2026-10-02 (Garbh Sanskar gap 6). The pin existed only on the old
/// browse list, and nothing showed what she had pinned, so it changed an icon and
/// nothing else. It now sits on today's raga and on every track's own page, and
/// what she pins is listed on Shravan's daily screen ("Your daily").
class GarbhPinChip extends StatelessWidget {
  const GarbhPinChip({super.key, required this.pinId});
  final String pinId;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final store = GarbhJournalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final on = store.isPinned(pinId);
        return Semantics(
          button: true,
          toggled: on,
          label: on ? 'In your daily. Tap to remove.' : 'Add to your daily',
          excludeSemantics: true,
          child: Material(
            color: on ? kPvInk : Colors.white,
            shape: StadiumBorder(side: BorderSide(color: on ? kPvInk : kPvLine, width: 1.3)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('garbh_pin_$pinId'),
              onTap: () => store.togglePinned(pinId),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(on ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 17, color: on ? Colors.white : p.ink1),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(on ? 'In your daily' : 'Add to my daily',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: on ? Colors.white : p.ink1)),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}
