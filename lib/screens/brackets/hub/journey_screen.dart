// =============================================================================
//  JourneyScreen — renders a JourneyConfig
// -----------------------------------------------------------------------------
//  One renderer for every journey in the app, so a journey is data. Adding one
//  is a config; changing how journeys look is one file.
//
//  The shape is `ScanDetailScreen`'s, which was arrived at the hard way: HER
//  QUESTION AS THE HEADING, and under each one the single thing that answers
//  it. An earlier version of that screen had grouped sections — "Before you
//  go", "While you are here" — and it was still inventory UX in friendlier
//  clothes, because the groups existed because we had things to put in them,
//  not because she had asked anything.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THE FIRST BUILD GOT WRONG, AND WHAT CHANGED
//  ---------------------------------------------------------------------------
//
//  Question-as-heading is still right. Everything under it was not.
//
//  Walked on a device, "Understand my PCOS" read as seven full-width bands
//  stacked down a page with no way to see the shape of it. The reviewer's
//  words, and they name two separate faults:
//
//    · "the user has to scroll till the very bottom to see what they want"
//    · "the representation ... is not very pleasant to the eyes"
//
//  Two fixes, and neither of them abandons the question:
//
//  1. **AN INDEX AT THE TOP.** Every question, listed, tappable, jumping to its
//     own answer. Someone arriving with ONE specific doubt — which is most
//     people who open a condition page — now sees all seven questions in a
//     glance instead of discovering the seventh after six screens of scroll.
//     Deliberately the same component idea as the reader's "In this read",
//     which reviewed well; two surfaces that both say "here is the shape of
//     this" should say it the same way.
//
//  2. **ARTICLES BECOME A GRID.** A run of reads renders two to a row as
//     `PvReadTile` rather than as stacked full-width rows — see that file for
//     why a list is read in order and a grid is scanned. Tools, courses and
//     consults keep `SolutionCard`, because a grid of mixed KINDS is a jumble
//     and those are actions rather than reading.
//
//  ⚠️ THE QUESTIONS ARE NOT FROM THE WORKBOOK. The Excel gives one Content cell
//  per bracket — a topic list, no structure. These come from the approved TTC
//  hub-door audit, and the workbook is the check on COVERAGE, not on order.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../widgets/global_ask_fab.dart';

import '../../../localization/app_language.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_placeholders.dart';
import '../../../widgets/pv_read_tile.dart';
import '../../v2/v2_palette.dart';
import 'hub_solution_cards.dart';
import 'journey_config.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({
    super.key,
    required this.config,
    required this.onSurface,
    required this.onAction,
  });

  final JourneyConfig config;
  final void Function(BuildContext, String surfaceId) onSurface;
  final void Function(BuildContext, String action) onAction;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  final ScrollController _sc = ScrollController();

  /// One key per step, so the index can scroll to it.
  final Map<int, GlobalKey> _stepKeys = {};

  JourneyConfig get config => widget.config;

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _jumpTo(int i) {
    final ctx = _stepKeys[i]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: 0.08);
    } else if (_sc.hasClients) {
      // Null when the step is far enough down that it has never been built.
      _sc.animateTo(_sc.position.maxScrollExtent * (i / config.steps.length),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        // ⚠️ RESOLVED ONCE PER BUILD, NOT PER READ. Calling `shownReads` inside
        // the loop would re-derive the window for every row; harmless today
        // because it is pure, and exactly the kind of thing that stops being
        // harmless the moment someone makes it read a store.
        final reads = config.shownReads(DateTime.now());

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(config.title.of(lang),
                style: pvManrope(
                    fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          body: ListView(
            controller: _sc,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, kAskFabReserve + 24),
            children: [
              Text(config.intro.of(lang),
                  style:
                      pvManrope(fontSize: 14.5, height: 1.6, color: p.ink2)),
              const SizedBox(height: 24),

              // ---- THE INDEX ---------------------------------------------
              if (config.steps.length > 2) ...[
                _index(p, lang),
                const SizedBox(height: 30),
              ],

              for (var i = 0; i < config.steps.length; i++)
                ..._step(p, lang, i, config.steps[i]),

              // ⚠️ READING COMES AFTER THE WALK, NOT INSIDE IT.
              //
              // A rotating pool of topics, three at a time, changing by the day
              // — see `JourneyConfig.reads` for why this is not a step. It sits
              // below the last question because it is the one thing here that
              // is optional: she has finished the journey by the time she
              // reaches it, and this is what keeps her coming back to a page
              // she has already completed.
              if (reads.isNotEmpty) ...[
                Text(lang.isEnglish ? 'More on this' : 'इस पर और',
                    style: pvFraunces(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
                const SizedBox(height: 4),
                Text(
                    lang.isEnglish
                        ? 'New topics here through the week.'
                        : 'हफ़्ते भर नए विषय।',
                    style:
                        pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
                const SizedBox(height: 14),
                _grid([
                  for (var i = 0; i < reads.length; i++)
                    PvReadTile(
                      title: reads[i].title.of(lang),
                      minutes: reads[i].minutes?.of(lang),
                      hue: 42,
                      seed: reads[i].title.en.hashCode,
                      onTap: reads[i].surfaceId == null
                          ? null
                          : () =>
                              widget.onSurface(context, reads[i].surfaceId!),
                    ),
                ]),
                const SizedBox(height: 26),
              ],

              if (config.closesWhen != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(config.closesWhen!.of(lang),
                      style: pvManrope(
                          fontSize: 12.5, height: 1.55, color: p.ink3)),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  The index
  // ---------------------------------------------------------------------------

  /// ⚠️ OPEN, NOT COLLAPSED — the opposite call to the reader's "In this read",
  /// and for a reason worth stating rather than looking like an inconsistency.
  ///
  /// In an article she has already decided to read; the contents strip is a
  /// convenience and its cost is pushing the first paragraph down the page. On
  /// a journey she has decided NOTHING yet — the list of questions IS the
  /// content of this screen, and hiding it behind a tap hides the only thing
  /// that tells her whether her question is answered here at all.
  Widget _index(V2Palette p, AppLanguage lang) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
            color: p.surfaceAlt,
            child: Text(
                lang.isEnglish ? 'WHAT THIS ANSWERS' : 'YE KYA JAWAB DETA HAI',
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink2)),
          ),
          for (var i = 0; i < config.steps.length; i++)
            GestureDetector(
              onTap: () => _jumpTo(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 13, 13, 13),
                decoration:
                    BoxDecoration(border: Border(top: BorderSide(color: p.line))),
                child: Row(children: [
                  Expanded(
                    child: Text(config.steps[i].question.of(lang),
                        style: pvManrope(
                            fontSize: 14, height: 1.42, color: p.ink1)),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_downward_rounded, size: 15, color: p.ink3),
                ]),
              ),
            ),
        ]),
      );

  // ---------------------------------------------------------------------------
  //  One step
  // ---------------------------------------------------------------------------

  List<Widget> _step(
      V2Palette p, AppLanguage lang, int index, JourneyStep step) {
    final key = _stepKeys.putIfAbsent(index, () => GlobalKey());

    // ⚠️ READS ARE SPLIT OUT AND GRIDDED; EVERYTHING ELSE KEEPS ITS ROW.
    //
    // Partitioned rather than sorted, so a step's non-reading elements stay in
    // the order the journey author wrote them. Reading first, because when a
    // step offers both, the article is the answer and the consult is the
    // escalation.
    final reads = [for (final e in step.elements) if (e.type == SolutionType.read) e];
    final rest = [for (final e in step.elements) if (e.type != SolutionType.read) e];

    return [
      Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: 12),
        // The heading IS her question.
        child: Text(step.question.of(lang),
            style: pvFraunces(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                height: 1.28,
                color: p.ink1)),
      ),

      // ⚠️ ONE READ IS A ROW, TWO OR MORE ARE A GRID — AND THIS WAS WRONG ON
      // THE DEVICE.
      //
      // Walked on a phone, a step holding a single article rendered as a
      // half-width tile with the other half empty. The reasoning behind that
      // was sound in isolation (a lone tile stretched to full width gets a
      // cover at twice the size and reads as "this one matters more"), but the
      // result looked like a layout bug rather than a decision.
      //
      // A grid of one is not a grid. `PvReadPlaceholder` is the app's existing
      // full-width article row — cover on the left, title and reason on the
      // right — and it is exactly the right shape for an article standing
      // alone. See the note in `pv_read_tile.dart`: the row was never wrong,
      // it is simply for a different situation.
      if (reads.length == 1) ...[
        PvReadPlaceholder(
          title: reads.first.title.of(lang),
          subtitle: reads.first.value.of(lang),
          readingTime: reads.first.meta?.of(lang),
          hue: 206,
          slotId: 'journey/${config.doorId}/${reads.first.title.en}',
          onTap: reads.first.owed
              ? null
              : () {
                  final e = reads.first;
                  if (e.action != null) {
                    widget.onAction(context, e.action!);
                  } else if (e.surfaceId != null) {
                    widget.onSurface(context, e.surfaceId!);
                  }
                },
        ),
        const SizedBox(height: 14),
      ] else if (reads.length > 1) ...[
        _grid([
          for (final e in reads)
            PvReadTile(
              title: e.title.of(lang),
              minutes: e.meta?.of(lang) ??
                  (lang.isEnglish ? 'READ' : 'PADHEIN'),
              hue: 206,
              seed: e.title.en.hashCode,
              onTap: e.owed
                  ? null
                  : () {
                      if (e.action != null) {
                        widget.onAction(context, e.action!);
                      } else if (e.surfaceId != null) {
                        widget.onSurface(context, e.surfaceId!);
                      }
                    },
            ),
        ]),
        const SizedBox(height: 14),
      ],

      for (final e in rest) ...[
        // ⚠️ AN OWED VIDEO RENDERS AS THE THING IT WILL BE, NOT AS A ROW SAYING
        // ITS NAME.
        //
        //   "Right now you have just returned the video name in a bar. You
        //    should basically show complete thumbnail and write the head in the
        //    way it will appear."
        //
        // The reason it matters here in particular: a journey is judged on its
        // RHYTHM — does the reading come before the doing, is one step carrying
        // too much. A 16:9 video occupies about four times the height of a text
        // row, so a journey reviewed with rows in place of videos is a
        // different screen from the one that ships.
        //
        // Owed TOOLS and COURSES stay as `SolutionCard`: a tool has no
        // canonical shape to occupy, and a card IS what a course looks like
        // when it is real.
        if (e.type == SolutionType.watch)
          PvVideoPlaceholder(
            title: e.title.of(lang),
            subtitle: e.value.of(lang),
            duration: e.meta?.of(lang),
            hue: 344,
            // The declared slot when the film is real data; the generated
            // one only when it is not. See `JourneyElement.videoSlot`.
            slotId: e.videoSlot ?? 'journey/${config.doorId}/${e.title.en}',
            onTap: e.owed
                ? null
                : () {
                    if (e.action != null) {
                      widget.onAction(context, e.action!);
                    } else if (e.surfaceId != null) {
                      widget.onSurface(context, e.surfaceId!);
                    }
                  },
          )
        else
          SolutionCard(
            type: e.type,
            title: e.title,
            value: e.value,
            meta: e.meta,
            p: p,
            lang: lang,
            comingSoon: e.owed,
            // ⚠️ AN OWED ELEMENT IS NOT TAPPABLE. A placeholder that looks
            // tappable and does nothing teaches her that taps do nothing —
            // everywhere else in the app, not just here.
            onTap: e.owed
                ? null
                : () {
                    if (e.action != null) {
                      widget.onAction(context, e.action!);
                    } else if (e.surfaceId != null) {
                      widget.onSurface(context, e.surfaceId!);
                    }
                  },
          ),
        const SizedBox(height: 10),
      ],

      if (step.note != null) ...[
        const SizedBox(height: 2),
        Text(step.note!.of(lang),
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3)),
      ],
      const SizedBox(height: 30),
    ];
  }

  /// Two columns, and the last odd tile does NOT stretch to full width.
  ///
  /// ⚠️ `Expanded` on a lone final tile would give it double the width of every
  /// other tile and a cover at twice the size, which reads as "this one is more
  /// important" — a ranking nobody intended. It takes its half and leaves the
  /// other half empty.
  Widget _grid(List<Widget> tiles) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final left = tiles[i];
      final right = i + 1 < tiles.length ? tiles[i + 1] : null;
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < tiles.length ? 18 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 14),
            Expanded(child: right ?? const SizedBox.shrink()),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}
