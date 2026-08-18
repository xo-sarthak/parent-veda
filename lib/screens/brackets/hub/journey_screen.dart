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
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_placeholders.dart';
import '../../v2/v2_palette.dart';
import 'hub_solution_cards.dart';
import 'journey_config.dart';

class JourneyScreen extends StatelessWidget {
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 44),
            children: [
              Text(config.intro.of(lang),
                  style: pvManrope(
                      fontSize: 14.5, height: 1.55, color: p.ink2)),
              const SizedBox(height: 30),

              for (final step in config.steps) ...[
                // The heading IS her question.
                Text(step.question.of(lang),
                    style: pvFraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: p.ink1)),
                const SizedBox(height: 12),

                for (final e in step.elements) ...[
                  // ⚠️ AN OWED VIDEO OR ARTICLE RENDERS AS THE THING IT WILL BE,
                  // NOT AS A ROW SAYING ITS NAME.
                  //
                  //   "Right now you have just returned the video name in a bar.
                  //    You should basically show complete thumbnail and write the
                  //    head in the way it will appear."
                  //
                  // The reason it matters here in particular: a journey is judged
                  // on its RHYTHM — does the reading come before the doing, is
                  // one step carrying too much. A 16:9 video occupies about four
                  // times the height of a text row, so a journey reviewed with
                  // rows in place of videos is a different screen from the one
                  // that ships. Reviewing the shape ahead of the content is the
                  // whole reason for building ahead of it.
                  //
                  // Owed TOOLS and COURSES stay as `SolutionCard`: a tool has no
                  // canonical shape to occupy, and a card IS what a course looks
                  // like when it is real.
                  if (e.owed && e.type == SolutionType.watch)
                    PvVideoPlaceholder(
                      title: e.title.of(lang),
                      subtitle: e.value.of(lang),
                      duration: e.meta?.of(lang),
                      hue: 344,
                      slotId: 'journey/${config.doorId}/${e.title.en}',
                    )
                  else if (e.owed && e.type == SolutionType.read)
                    PvReadPlaceholder(
                      title: e.title.of(lang),
                      subtitle: e.value.of(lang),
                      readingTime: e.meta?.of(lang),
                      hue: 206,
                      slotId: 'journey/${config.doorId}/${e.title.en}',
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
                      // ⚠️ AN OWED ELEMENT IS NOT TAPPABLE. A placeholder that
                      // looks tappable and does nothing teaches her that taps do
                      // nothing — everywhere else in the app, not just here.
                      onTap: e.owed
                          ? null
                          : () {
                              if (e.action != null) {
                                onAction(context, e.action!);
                              } else if (e.surfaceId != null) {
                                onSurface(context, e.surfaceId!);
                              }
                            },
                    ),
                  const SizedBox(height: 10),
                ],

                if (step.note != null) ...[
                  const SizedBox(height: 2),
                  Text(step.note!.of(lang),
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink3)),
                ],
                const SizedBox(height: 30),
              ],

              // ⚠️ READING COMES AFTER THE WALK, NOT INSIDE IT.
              //
              // A rotating pool of topics, three at a time, changing by the day —
              // see `JourneyConfig.reads` for why this is not a step. It sits
              // below the last question because it is the one thing here that is
              // optional: she has finished the journey by the time she reaches
              // it, and this is what keeps her coming back to a page she has
              // already completed.
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
                const SizedBox(height: 12),
                for (final r in reads) ...[
                  PvReadPlaceholder(
                    title: r.title.of(lang),
                    subtitle: r.value.of(lang),
                    readingTime: r.minutes?.of(lang),
                    hue: 42,
                    slotId: 'journey/${config.doorId}/read/${r.title.en}',
                    onTap: r.surfaceId == null
                        ? null
                        : () => onSurface(context, r.surfaceId!),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 22),
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
                          fontSize: 12.5, height: 1.5, color: p.ink3)),
                ),
            ],
          ),
        );
      },
    );
  }
}
