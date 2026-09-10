// =============================================================================
//  A checklist — tick it, take it in, send it
// -----------------------------------------------------------------------------
//  One screen for every door's "before your appointment" tab. It renders a
//  `PvChecklist` and knows nothing about scans or conditions; what it is about
//  comes from the list's own `subject()`, which reads that area's store.
//
//  ⚠️ GENERALISED FROM `ScanQuestionsScreen` AT THE SECOND CALLER. See the
//  header of `pv_checklist.dart` for why that timing rather than the third.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT NEVER SCORES, RANKS OR CONGRATULATES
//  ---------------------------------------------------------------------------
//
//  No progress bar, no "4 of 18", no streak. A counter on a list of things
//  somebody is nervous enough to write down is a debt statement — the same
//  reason the door playbook forbids "3 of 8" on a health questionnaire, and the
//  reason both briefs' DO NOT lists end with "no streak or gamification".
//
//  The count that IS shown sits on the share button, because that is the one
//  place a number is useful: it says how long the message is about to be.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SHARE IS A TEXT MESSAGE, NOT A DOCUMENT
//  ---------------------------------------------------------------------------
//
//  `Share.share` with plain text through the OS sheet, so it lands in WhatsApp,
//  which is where it will actually go. A PDF would look more finished and would
//  be worse: she wants to paste this into a chat with her husband or her
//  mother, or read it off her own screen in a corridor, and a downloaded file
//  does neither.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/checklists/pv_checklist.dart';
import '../../services/pv_checklist_store.dart';
import '../../services/pv_checklist_subjects.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart';
import '../v2/v2_palette.dart';

class PvChecklistScreen extends StatefulWidget {
  const PvChecklistScreen({
    super.key,
    required this.checklist,
    required this.hue,
  });

  final PvChecklist checklist;

  /// The door's own hue, so a checklist opened from Scans is blue and one
  /// opened from Complications is teal. Passed in rather than stored on the
  /// list: the same checklist could sit on two doors, and it should look like
  /// wherever she came from.
  final double hue;

  @override
  State<PvChecklistScreen> createState() => _PvChecklistScreenState();
}

class _PvChecklistScreenState extends State<PvChecklistScreen> {
  PvChecklist get list => widget.checklist;

  @override
  void initState() {
    super.initState();
    PvChecklistStore.instance.init(list.id);
  }

  Future<void> _share() async {
    final store = PvChecklistStore.instance;

    // ⚠️ TICKED ONLY, AND IN THE PAGE'S ORDER. Sharing the whole list would be
    // sharing a leaflet; sharing in tick order would arrive as whatever
    // sequence she happened to tap. Reading the page's own order back means the
    // message looks like the screen she just filled in.
    final lines = <String>[];
    for (final g in list.groups) {
      final picked =
          g.items.where((q) => store.isTicked(list.id, q.id)).toList();
      if (picked.isEmpty) continue;
      lines.add('');
      lines.add(g.heading);
      for (final q in picked) {
        lines.add('• ${q.text}');
      }
    }
    if (lines.isEmpty) return;

    final subject = list.subject?.call();
    final header = subject == null
        ? list.shareHeader
        : '${list.shareHeader} — $subject';

    await Share.share('$header\n${lines.join('\n')}');
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        // ⚠️ THE SUBJECT'S OWN STORE IS LISTENED TO, NOT JUST THE TICKS.
        // `subject()` reads `ScansStore` or `ConditionsStore`, so a scan marked
        // done or a condition added while this screen is open changes the
        // heading — and without this the title would go stale in place, which
        // is the inline-tool bug one level up.
        animation: Listenable.merge([
          PvChecklistStore.instance,
          V2PaletteStore.instance,
          ...pvChecklistSubjectStores,
        ]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = PvChecklistStore.instance;
          final count = store.count(list.id);
          final subject = list.subject?.call();

          return PvDoorToolScaffold(
            hue: widget.hue,
            eyebrow: list.eyebrow,
            title: subject == null
                ? list.title
                : (list.subjectTitle?.call(subject) ?? list.title),
            intro: subject == null
                ? list.intro
                : (list.subjectIntro?.call(subject) ?? list.intro),
            action: count == 0
                ? null
                : _ShareBar(p: p, count: count, onTap: _share),
            children: [
              for (final g in list.groups) ...[
                pvDoorPad(Text(g.heading,
                    style: pvFraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.4,
                        color: p.ink1))),
                const SizedBox(height: 11),
                for (final q in g.items) ...[
                  pvDoorPad(_ItemRow(
                    item: q,
                    hue: widget.hue,
                    ticked: store.isTicked(list.id, q.id),
                    p: p,
                    onTap: () => store.toggle(list.id, q.id),
                  )),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 20),
              ],

              // ⚠️ THE INVITATION, NOT A BLANK. Nothing ticked means the share
              // bar is not there, and a screen whose only action has silently
              // vanished reads as broken. One line says where it went.
              if (count == 0)
                pvDoorPad(Text(
                    'Tick a few and a share button appears, so you can send '
                    'the list to yourself or to whoever is coming with you.',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.55, color: p.ink3))),
              if (count > 0)
                pvDoorPad(GestureDetector(
                  onTap: () => store.clear(list.id),
                  behavior: HitTestBehavior.opaque,
                  child: Text('Clear all',
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                )),
              const SizedBox(height: 22),
              pvDoorPad(PvDoorDisclaimer(p: p)),
              // Clearance for the pinned share bar, so the last row is
              // reachable rather than sitting under it.
              if (count > 0) const SizedBox(height: 64),
            ],
          );
        },
      );
}

/// One question. A tick, and the words.
///
/// ⚠️ THE WHOLE ROW IS THE TARGET, NOT THE BOX. A 20pt checkbox is under every
/// touch minimum, and a list where the words are inert teaches that the words
/// are not the thing — on a screen whose entire content is sentences.
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.hue,
    required this.ticked,
    required this.p,
    required this.onTap,
  });

  final PvChecklistItem item;
  final double hue;
  final bool ticked;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, p);
    return Semantics(
      checked: ticked,
      button: true,
      label: item.text,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            // ⚠️ A TICKED ROW GOES TINTED, NOT GREYED OUT. Greying says "done
            // with, ignore" — the opposite of what a ticked question means
            // here. It is the one she is definitely asking.
            color: ticked ? tint : p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ticked ? Colors.transparent : p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ticked ? p.ink1 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: ticked ? null : Border.all(color: p.line, width: 1.5),
              ),
              child: ticked
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.text,
                  style: pvManrope(
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: ticked ? FontWeight.w700 : FontWeight.w500,
                      color: p.ink1)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The pinned share bar. Appears once something is ticked.
class _ShareBar extends StatelessWidget {
  const _ShareBar(
      {required this.p, required this.count, required this.onTap});

  final V2Palette p;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(kPvDoorGutter, 12, kPvDoorGutter,
            12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: p.ground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.action,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, size: 17, color: p.onAction),
                const SizedBox(width: 9),
                Text(
                    count == 1
                        ? 'Share 1 question'
                        : 'Share $count questions',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: p.onAction)),
              ],
            ),
          ),
        ),
      );
}
