// =============================================================================
//  TTC - the daily ritual
// -----------------------------------------------------------------------------
//  Pregnancy has Garbh Sanskar. TTC has this: five parts, five minutes.
//
//      "Today's Reflection · Today's Breath · Today's Conversation ·
//       Today's Gratitude · Today's Action. Five minutes. Exactly like Garbh
//       Sanskar. Different purpose."                     - TTC master, §2.4
//
//  Garbh Sanskar splits into a DAILY face (one item per pillar, with
//  completion) and a LIBRARY face. This is the daily face; the library arrives
//  with the Tools hub. The content is chapter-aware, because a gratitude prompt
//  during the waiting days should not sound like one during the fertile window.
//
//  There is no timer, no audio requirement, no score, and no way to fail. The
//  tick exists so the couple can see they did it, not so the app can grade it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_daily_data.dart';
// Kept for revert (2026-09-28, journal out of TTC):
// import '../../ttc/ttc_journal_store.dart' show TtcEntryKind;
import '../../ttc/ttc_ritual_store.dart';
import '../../ttc/ttc_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
// Kept for revert (2026-09-28, journal out of TTC):
// import 'ttc_journal_screen.dart' show writeTtcEntry;
import 'ttc_practice_card_parts.dart';
import '../../ttc/ttc_mind_today.dart'
    show ttcSanskarItems, ttcSanskarBreathPractice;
import 'ttc_practice_player.dart' show TtcPracticeSession;
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// Sand, the hue the Mind and body hub gives this ritual ("Do today's
/// practice"), so the tile she tapped and the page she lands on match.
const double kTtcRitualHue = 42;

// =============================================================================
//  The ritual, rebuilt in the tool shell (2026-09-27, tools rebuild)
// -----------------------------------------------------------------------------
//  The user on the phone: "old tools in new clothes". The morning pass took
//  the 0/5 off and opened one part at a time, but the page still wore the V1
//  look (a purple gradient header, `TtcCard`s, purple buttons), and every
//  part was words to read with nothing to DO beyond ticking. Now:
//
//   · the tool shell every rebuilt TTC tool wears (field, hero, white sheet),
//     so it sits beside Mind and body Today as one family;
//   · rows with a hairline, not boxed purple cards (Superpower's "Today's
//     actions", https://mobbin.com/screens/92693ca8-42cd-48d1-b1e5-a1a35ac02a55);
//   · the breath part carries a one-minute timer she can follow with her
//     eyes on the ring, and finishing it ticks the part, with an undo;
//   · reflection, conversation and gratitude each offer "Write about it in
//     our journal", opening the journal's writer with the prompt carried in
//     (5 Minute Journal and Stardust let the answer be written where the
//     prompt is, https://mobbin.com/screens/999c811f-e1cd-4eff-9b18-c129a7b7a2fe).
//
//  WHAT DID NOT CHANGE: the store, its keys, what counts as done, and the
//  words of every part. The page as it was this morning is kept below as
//  `TtcRitualScreenClassic`; nothing pushes it.
// =============================================================================
class TtcRitualScreen extends StatefulWidget {
  const TtcRitualScreen(
      {super.key, required this.chapter, this.focus, this.clinicOwned});

  final TtcChapter chapter;

  /// Which part was tapped to get here - opened on arrival.
  final TtcRitualPart? focus;

  /// Whether a clinic owns her timing this cycle (a treatment round). Null
  /// reads it from `TtcStore` (2026-09-28), so no call site has to pass it;
  /// a test passes it.
  final bool? clinicOwned;

  @override
  State<TtcRitualScreen> createState() => _TtcRitualScreenState();
}

class _TtcRitualScreenState extends State<TtcRitualScreen> {
  /// The one open part. Starts on the part she tapped to get here, else on
  /// the first part not done yet, so the page opens on something to do.
  TtcRitualPart? _open;
  bool _openSet = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcRitualStore.instance,
        TtcLang.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final pal = V2PaletteStore.instance.current;
        final store = TtcRitualStore.instance;
        final chapter = widget.chapter;
        // One picker (launch sanity MB18, 2026-09-28): the breath part is
        // Mind & body › Today's breath, the same list the home's Sanskar
        // draws. Kept for revert:
        //   final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];
        final items = ttcSanskarItems(chapter);
        if (!_openSet) {
          _openSet = true;
          _open = widget.focus ??
              items
                  .where((i) => !store.isDone(i.part))
                  .map((i) => i.part)
                  .firstOrNull;
        }
        final doneParts = [
          for (final i in items)
            if (store.isDone(i.part)) i.part.title(hi),
        ];

        return TtcToolScaffold(
          hue: kTtcRitualHue,
          // The tile's name is the eyebrow; the title says what the page is.
          // ⚠️ ONE NAME (launch sanity H15, 2026-09-28): the home's band is
          // "Daily Preconception Sanskar" and this page said "Your daily
          // ritual". The home's own words, the same getter. Kept for revert:
          //   eyebrow: t.ritualTitle,
          eyebrow: t.sanskarTitle,
          title: 'Five small things for today',
          // ⚠️ ONE INTRO, UNDER THE TITLE, AS ONE SENTENCE BLOCK (the user on
          // build 17, 2026-09-28: "the positioning and the font, it's not
          // placed well"). The page had two intros: this hero line, and a
          // second 13pt grey line ("Picked for your fertile days.") on the
          // sheet's very first pixel, with "Tap a part to open its practice."
          // in a third, paler style under it. Now why these five and how
          // long they take are one Manrope paragraph in the hero's intro
          // slot, set by the tool chrome at the stage's body size, left on
          // the title's gutter. Headspace's page is a title, one paragraph,
          // then the list (https://mobbin.com/screens/f2297328-ef5d-42b9-96ba-e851f428f5e4).
          // Kept for revert:
          //   intro: "Each one takes about a minute. Do any one and that's "
          //       'enough for today.',
          intro: ttcRitualIntro(chapter,
              clinicOwned: widget.clinicOwned ?? _clinicOwnedNow()),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clear of the sheet's rounded top: the 22 every rebuilt tool
                // starts its sheet with (the practice page's MB10 fix).
                const SizedBox(height: 22),
                // ⚠️ NO CHAPTER NAME ON ITS OWN (the user, 2026-09-27:
                // "Trying Together... that word is not making any sense").
                // One sentence, not two fragments (H15, 2026-09-28): "Picked
                // for this part of your month. Your fertile days: the best
                // time to try this month." Kept for revert:
                //   'Picked for this part of your month. '
                //   '${ttcChapterPlainPart(chapter)}',
                // Kept for revert (2026-09-28): the chapter line on the sheet,
                // now the first sentence of the hero's intro.
                //   Text(_pickedFor(chapter),
                //       style: pvManrope(
                //           fontSize: 13, height: 1.5, color: pal.ink2)),
                //   const SizedBox(height: 12),
                if (doneParts.isNotEmpty) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(Icons.check_circle_rounded,
                          size: 16, color: pal.ink1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Done today: ${doneParts.join(', ')}',
                          style: pvManrope(
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                              color: pal.ink1)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],
                // ⚠️ NO "TAP" HINT (2026-09-28). Each part is a tinted card
                // with a chevron, which already says it opens; a line telling
                // her to tap was a fragment on its own line in a third style.
                // Kept for revert:
                //   else
                //     // Kept for revert (2026-09-28): 'Tap a part to open it.'
                //     Text('Tap a part to open its practice.',
                //         style: pvManrope(fontSize: 13, color: pal.ink3)),
                //   const SizedBox(height: 16),
                for (final item in items) ...[
                  _RitualRow(
                    item: item,
                    t: t,
                    pal: pal,
                    done: store.isDone(item.part),
                    expanded: _open == item.part,
                    onHeaderTap: () => setState(() =>
                        _open = _open == item.part ? null : item.part),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
            )),
          ],
        );
      },
    );
  }
}

/// Whether a clinic owns her timing today. Never throws: a store that cannot
/// answer is treated as her own cycle.
bool _clinicOwnedNow() {
  try {
    return TtcStore.instance.today.clinicInvolved;
  } catch (_) {
    return false;
  }
}

/// The ritual page's intro: why these five, then how long they take, as one
/// paragraph under the title (2026-09-28).
///
/// ⚠️ NO FERTILE DAYS ON A CLINIC'S CYCLE. On a treatment round the clinic
/// owns the timing (`TimingOwnership`), and "picked for your fertile days"
/// is our prediction on a screen that should be deferring to them. The chapter
/// still turns underneath, so the words name the round instead.
String ttcRitualIntro(TtcChapter c, {bool clinicOwned = false}) =>
    '${clinicOwned ? _pickedForRound(c) : _pickedFor(c)} Each part takes '
    'about a minute, and doing any one part is enough for today.';

String _pickedForRound(TtcChapter c) => switch (c) {
      TtcChapter.preparingTogether => 'Picked for the months of getting ready.',
      TtcChapter.knowingYourRhythm ||
      TtcChapter.tryingTogether =>
        'Picked for this stage of your treatment round.',
      TtcChapter.theWaitingDays => "Picked for the wait before your clinic's "
          'test.',
      TtcChapter.aNewBeginning => 'Picked for after a positive test.',
    };

/// Why these five, in one sentence, by where she is in her month (H15).
String _pickedFor(TtcChapter c) => switch (c) {
      TtcChapter.preparingTogether => 'Picked for the months of getting ready.',
      TtcChapter.knowingYourRhythm =>
        'Picked for the days before your fertile days.',
      TtcChapter.tryingTogether => 'Picked for your fertile days.',
      TtcChapter.theWaitingDays =>
        'Picked for the wait after your fertile days.',
      TtcChapter.aNewBeginning => 'Picked for after a positive test.',
    };

/// One part: a row with a hairline that opens in place.
class _RitualRow extends StatelessWidget {
  const _RitualRow({
    required this.item,
    required this.t,
    required this.pal,
    required this.done,
    required this.expanded,
    required this.onHeaderTap,
  });

  final TtcRitualItem item;
  final TtcS t;
  final V2Palette pal;
  final bool done;
  final bool expanded;
  final VoidCallback onHeaderTap;

  // Kept for revert (2026-09-28, journal out of TTC): which journal kind an
  // answer to this part was saved as. The journal left the stage, so the
  // ritual no longer offers to write into it.
  // /// Which journal kind an answer to this part is saved as, or null where
  // /// there is nothing to write (the breath and the action).
  // TtcEntryKind? get _journalKind => switch (item.part) {
  //       TtcRitualPart.reflection => TtcEntryKind.feeling,
  //       TtcRitualPart.gratitude => TtcEntryKind.feeling,
  //       TtcRitualPart.conversation => TtcEntryKind.memory,
  //       TtcRitualPart.breath => null,
  //       TtcRitualPart.action => null,
  //     };

  void _finishBreath(BuildContext context) {
    final store = TtcRitualStore.instance;
    if (store.isDone(item.part)) return;
    store.toggle(item.part);
    pvSnack(context, 'Breath marked done for today.',
        icon: Icons.check_rounded,
        action: 'Undo',
        onAction: () {
          if (store.isDone(item.part)) store.toggle(item.part);
        },
        lift: 24);
  }

  // ⚠️ THE PRACTICE CARD FAMILY (2026-09-28). The user: "do this Headspace
  // thing for ALL cards like this ... especially Preconception Sanskar". The
  // row this replaces drew in four type styles (a Jakarta title, a Manrope
  // reason, a Fraunces thought, a bold text-button), a circled icon, a hairline
  // divider, a help line over the timer and "Tap again to undo." under the
  // button. Now each part is the card she tapped on the home, in the same
  // tint (`ttcRitualPartHue`): the title with a chevron and, once done, a
  // "Done today" chip; today's words as the body (two lines closed, whole when
  // open, the same words the home card shows, so opening it reveals rather
  // than replaces); and the actions as one ink pill with a quieter white pill
  // beside it. Headspace's session card with its one action
  // (https://mobbin.com/screens/d05b1798-9389-4073-999b-693b84cca19e), Calm's
  // gratitude check-in, prompt as the card's words
  // (https://mobbin.com/screens/5685de5b-2537-43d8-80e9-f748a4d0ac2f).
  // The old row is `_buildClassic` below, kept for revert.
  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final tint = v2BlockTint(ttcRitualPartHue(item.part), pal);
    // Kept for revert (2026-09-28, journal out of TTC):
    //   final kind = _journalKind;
    return Container(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(kTtcCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(
            button: true,
            expanded: expanded,
            child: InkWell(
              onTap: onHeaderTap,
              child: Padding(
                // The foot comes from the open part, or the card's own 18.
                padding: EdgeInsets.fromLTRB(kTtcCardPad.left, kTtcCardPad.top,
                    kTtcCardPad.right, expanded ? 0 : kTtcCardPad.bottom),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(item.part.title(hi),
                                  style: ttcCardTitle(pal)),
                            ),
                            if (done) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: TtcCardChip.done(
                                    t.sanskarDoneToday, tint),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: pal.ink2),
                          ]),
                      const SizedBox(height: 6),
                      // Kept for revert (2026-09-28): item.part.why(hi) as the
                      // line under the title, and the words in Fraunces 18
                      // only once open.
                      Text(item.text(hi),
                          maxLines: expanded ? null : 2,
                          overflow: expanded ? null : TextOverflow.ellipsis,
                          style: ttcCardBody(pal)),
                    ]),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(kTtcCardPad.left, 0,
                  kTtcCardPad.right, kTtcCardPad.bottom),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- the breath: a minute she can follow on the ring ----
                    // Kept for revert (2026-09-28): the line over the timer,
                    // 'Use this one-minute timer if it helps.' The ring and
                    // its Start say what it is.
                    // ⚠️ TODAY'S BREATH PRACTICE ITSELF (MB18, 2026-09-28):
                    // the part's words are now Mind & body › Today's breath,
                    // so its ring is that practice's ring (in and out, a
                    // box, a count) rather than a plain minute. Finishing it
                    // still ticks this part, with an undo. Kept for revert:
                    //   TtcPracticeSession.sit(seconds: 60,
                    //       onFinished: () => _finishBreath(context)),
                    if (item.part == TtcRitualPart.breath) ...[
                      const SizedBox(height: 14),
                      TtcPracticeSession(
                        practice: ttcSanskarBreathPractice(),
                        onFinished: () => _finishBreath(context),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // One ink pill; the journal is the quieter second choice.
                    // Kept for revert (2026-09-28): the full-width 48pt toggle
                    // reading t.ritualDone when done, with 'Tap again to
                    // undo.' under it. "Mark not done" says it on the button
                    // (not "Undo": the breath timer's snackbar offers one, and
                    // two Undos on one screen is one too many).
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      if (done)
                        TtcQuietPill(
                            label: 'Mark not done',
                            icon: Icons.undo_rounded,
                            onTap: () =>
                                TtcRitualStore.instance.toggle(item.part))
                      else
                        TtcInkPill(
                            label: t.ritualMarkDone,
                            icon: Icons.check_rounded,
                            onTap: () =>
                                TtcRitualStore.instance.toggle(item.part)),
                      // The breath's steps, on the practice's own page.
                      if (item.part == TtcRitualPart.breath)
                        TtcQuietPill(
                          // Kept for revert (2026-09-28): 'See the steps'.
                          label: 'See the breathing steps',
                          icon: Icons.format_list_numbered_rounded,
                          onTap: () => openTtcSurface(context,
                              'ttc_practice/${ttcSanskarBreathPractice().id}'),
                        ),
                      // Kept for revert (2026-09-28, journal out of TTC):
                      //   if (kind != null)
                      //     TtcQuietPill(
                      //       label: 'Write about it in our journal',
                      //       icon: Icons.edit_outlined,
                      //       onTap: () => writeTtcEntry(context,
                      //           kind: kind, prompt: item.text(hi)),
                      //     ),
                    ]),
                  ]),
            ),
        ]),
      ),
    );
  }

  // Kept for revert (2026-09-28): the bordered row with the circled icon.
  // Nothing calls it.
  // ignore: unused_element
  Widget _buildClassic(BuildContext context) {
    final hi = t.hinglish;
    final tint = v2BlockTint(kTtcRitualHue, pal);
    // Kept for revert (2026-09-28, journal out of TTC):
    //   final kind = _journalKind;
    return Container(
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: expanded ? pal.ink3 : pal.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: tint, shape: BoxShape.circle),
                  child: Icon(_icon(item.part), size: 19, color: pal.ink1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.part.title(hi),
                            style: pvJakarta(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: pal.ink1)),
                        const SizedBox(height: 2),
                        Text(item.part.why(hi),
                            style: pvManrope(
                                fontSize: 12.5, height: 1.4, color: pal.ink2)),
                      ]),
                ),
                const SizedBox(width: 8),
                if (done)
                  Icon(Icons.check_circle_rounded, size: 22, color: pal.ink1)
                else
                  Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: pal.ink3),
              ]),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, thickness: 1, color: pal.line),
                  const SizedBox(height: 14),
                  Text(item.text(hi),
                      style: pvFraunces(
                          fontSize: 18, height: 1.45, color: pal.ink1)),
                  // ---- the breath: a minute she can follow on the ring ----
                  if (item.part == TtcRitualPart.breath) ...[
                    const SizedBox(height: 16),
                    // Kept for revert (2026-09-28): 'Use this one-minute
                    // timer if it helps.'
                    Text('Use the one-minute timer below if you like.',
                        textAlign: TextAlign.center,
                        style: pvManrope(fontSize: 12.5, color: pal.ink3)),
                    const SizedBox(height: 8),
                    TtcPracticeSession.sit(
                      seconds: 60,
                      onFinished: () => _finishBreath(context),
                    ),
                  ],
                  // ---- somewhere to put the answer ----------------------
                  // Kept for revert (2026-09-28, journal out of TTC):
                  //   if (kind != null) ...[
                  //     const SizedBox(height: 12),
                  //     Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: TextButton.icon(
                  //         onPressed: () => writeTtcEntry(context,
                  //             kind: kind, prompt: item.text(hi)),
                  //         icon: Icon(Icons.edit_outlined,
                  //             size: 17, color: pal.ink1),
                  //         label: Text('Write about it in our journal', ...),
                  //       ),
                  //     ),
                  //   ],
                  const SizedBox(height: 12),
                  // ---- the tick: ink when it is still to do --------------
                  InkWell(
                    onTap: () => TtcRitualStore.instance.toggle(item.part),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done ? pal.surfaceAlt : pal.ink1,
                        borderRadius: BorderRadius.circular(999),
                        border: done ? Border.all(color: pal.line) : null,
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            done
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 17,
                            color: done ? pal.ink1 : Colors.white),
                        const SizedBox(width: 8),
                        Text(done ? t.ritualDone : t.ritualMarkDone,
                            style: pvManrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: done ? pal.ink1 : Colors.white)),
                      ]),
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(height: 7),
                    Center(
                      child: Text('Tap again to undo.',
                          style: pvManrope(fontSize: 12, color: pal.ink3)),
                    ),
                  ],
                ]),
          ),
      ]),
    );
  }

  static IconData _icon(TtcRitualPart part) => switch (part) {
        TtcRitualPart.reflection => Icons.psychology_outlined,
        TtcRitualPart.breath => Icons.air_rounded,
        TtcRitualPart.conversation => Icons.forum_outlined,
        TtcRitualPart.gratitude => Icons.wb_sunny_outlined,
        TtcRitualPart.action => Icons.task_alt_rounded,
      };
}

// =============================================================================
//  Kept for revert (2026-09-27): the page as it was this morning
// =============================================================================

// ⚠️ TICKS ONLY, ONE PART OPEN AT A TIME (tools pass, 2026-09-27).
//  The "0/5" count and the progress bar pulled against the promise that there
//  is no way to fail: an empty bar at night reads as a score. Five cards fully
//  open was a long scroll for something sold as five minutes. Now the header
//  says what this is and that any one part is enough (which is how the store
//  already counts a day); each part is a row with its title, its reason and a
//  tick when done; tapping a row opens it, and only one is open at a time.
//  Mobbin: Noom "Today's plan" (rows with a tick each, no bar), Garmin
//  Connect workout steps (a step opens in place).
/// The ritual page before the 2026-09-27 rebuild. Kept for revert; nothing
/// pushes it.
class TtcRitualScreenClassic extends StatefulWidget {
  const TtcRitualScreenClassic({super.key, required this.chapter, this.focus});

  final TtcChapter chapter;

  /// Which part was tapped to get here - opened on arrival.
  final TtcRitualPart? focus;

  @override
  State<TtcRitualScreenClassic> createState() =>
      _TtcRitualScreenClassicState();
}

class _TtcRitualScreenClassicState extends State<TtcRitualScreenClassic> {
  /// The one open part. Starts on the part she tapped to get here, else on
  /// the first part not done yet, so the page opens on something to do.
  TtcRitualPart? _open;
  bool _openSet = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcRitualStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcRitualStore.instance;
        final chapter = widget.chapter;
        final items = ttcRituals[chapter] ?? const <TtcRitualItem>[];
        if (!_openSet) {
          _openSet = true;
          _open = widget.focus ??
              items
                  .where((i) => !store.isDone(i.part))
                  .map((i) => i.part)
                  .firstOrNull;
        }
        final doneParts = [
          for (final i in items)
            if (store.isDone(i.part)) i.part.title(hi),
        ];
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.ritualTitle),
                const SizedBox(height: 18),

                // What this is, first. The chapter this ritual belongs to is
                // named under it, so it never reads as generic wellness
                // content bolted on.
                // ⚠️ THE TOOLS' LIGHT FIELD, INK TYPE (2026-09-29): see
                // `TtcHeroFieldCard`. Kept for revert (2026-09-29): a
                // Container, padding 18, decorated with
                //   LinearGradient(begin: topLeft, end: bottomRight,
                //       colors: [ttcPurple, ttcPurpleDeep]);
                // every line and the tick in white (the body at 93%, the
                // "Picked for" line at 80%).
                TtcHeroFieldCard(
                  hue: ttcChapterFieldHue(chapter),
                  variant: TtcChapter.values.indexOf(chapter) + 1,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kept for revert (2026-09-27): the chapter name was
                        // the heading. It said where she is, not what the
                        // page is.
                        //   Text(chapter.title(hi), style: ttcFraunces(21,
                        //       w: FontWeight.w600, color: Colors.white)),
                        Text('Five small things for today',
                            style: ttcFraunces(21,
                                w: FontWeight.w600, color: ttcInk)),
                        const SizedBox(height: 7),
                        // Kept for revert (2026-09-27): an "it isn't X" line
                        // (TTC-VOICE rule 10) that said what this is not.
                        //   Text(t.dailyRitualBody, style: ...),
                        Text(
                            "Each one takes about a minute. Do any one and "
                            "that's enough for today. Tap a part to open it.",
                            style: ttcBody(13, color: ttcInk, h: 1.5)),
                        const SizedBox(height: 10),
                        // ⚠️ NO CHAPTER NAME ON ITS OWN (the user,
                        // 2026-09-27: "Trying Together... that word is not
                        // making any sense"). The part of her month is said
                        // in plain words instead. Kept for revert:
                        //   'Picked for where you are now: ${chapter.title(hi)}'
                        Text(
                            // Kept for revert (2026-09-28): 'Picked for this
                            // part of your month. '
                            'Picked for where you are in your month. '
                            '${ttcChapterPlainPart(chapter)}',
                            style: ttcBody(12,
                                color: ttcInk, w: FontWeight.w700, h: 1.4)),
                        // Kept for revert (2026-09-27): the "0/5" count and
                        // the progress bar, a score on a page that promises
                        // no way to fail.
                        //   Row(children: [
                        //     Text('${store.completedToday()}/${store.total}'),
                        //     Expanded(child: TtcProgressBar(
                        //         value: store.completedToday() / store.total)),
                        //   ]),
                        if (doneParts.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 15, color: ttcInk),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                  'Done today: ${doneParts.join(', ')}',
                                  style: ttcBody(12.5,
                                      color: ttcInk,
                                      w: FontWeight.w700,
                                      h: 1.4)),
                            ),
                          ]),
                        ],
                      ]),
                ),
                const SizedBox(height: 20),

                for (final item in items) ...[
                  _RitualPartCard(
                    item: item,
                    t: t,
                    done: store.isDone(item.part),
                    // Kept for revert (2026-09-27): every card open.
                    //   expanded: focus == null || focus == item.part,
                    expanded: _open == item.part,
                    onHeaderTap: () => setState(() =>
                        _open = _open == item.part ? null : item.part),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RitualPartCard extends StatelessWidget {
  const _RitualPartCard({
    required this.item,
    required this.t,
    required this.done,
    required this.expanded,
    required this.onHeaderTap,
  });

  final TtcRitualItem item;
  final TtcS t;
  final bool done;
  final bool expanded;
  final VoidCallback onHeaderTap;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // The row: title, reason, and a tick when done. A tap opens or
        // closes the part.
        Semantics(
          button: true,
          expanded: expanded,
          child: GestureDetector(
            onTap: onHeaderTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: ttcPanel, shape: BoxShape.circle),
                  child: Icon(_icon(item.part), size: 19, color: ttcTitleInk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.part.title(hi), style: ttcJakarta(15.5)),
                        const SizedBox(height: 2),
                        Text(item.part.why(hi), style: ttcBody(11.5)),
                      ]),
                ),
                const SizedBox(width: 8),
                if (done)
                  const Icon(Icons.check_circle_rounded,
                      size: 22, color: ttcTitleInk)
                else
                  Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: ttcMuted),
              ]),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.text(hi),
                      style: ttcBody(14.5, color: ttcInk, h: 1.68)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => TtcRitualStore.instance.toggle(item.part),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: done ? ttcPanel : ttcTitleInk,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            done
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 17,
                            color: done ? ttcTitleInk : Colors.white),
                        const SizedBox(width: 8),
                        Text(done ? t.ritualDone : t.ritualMarkDone,
                            style: ttcBody(13.5,
                                color: done ? ttcTitleInk : Colors.white,
                                w: FontWeight.w800)),
                      ]),
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(height: 7),
                    Center(
                      child: Text('Tap again to undo.',
                          style: ttcBody(11.5, color: ttcMuted)),
                    ),
                  ],
                ]),
          ),
      ]),
    );
  }

  IconData _icon(TtcRitualPart part) {
    switch (part) {
      case TtcRitualPart.reflection:
        return Icons.psychology_outlined;
      case TtcRitualPart.breath:
        return Icons.air_rounded;
      case TtcRitualPart.conversation:
        return Icons.forum_outlined;
      case TtcRitualPart.gratitude:
        return Icons.wb_sunny_outlined;
      case TtcRitualPart.action:
        return Icons.task_alt_rounded;
    }
  }
}
