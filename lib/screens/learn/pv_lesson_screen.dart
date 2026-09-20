// =============================================================================
//  PvLessonScreen — one lesson of a recorded thing, and the list around it
// -----------------------------------------------------------------------------
//  MasterClass's lesson page and Udemy's player, one component (audit §3.9):
//  the film on top, the title, who, a small action row, *Up next*, then the
//  whole list with ticks. `CourseLessonScreen` and the TTC session screen
//  were two players; the TTC one stays (it runs practice players, not a
//  film) and is reached through `PvLearnLesson.open` — this screen never
//  renders for it.
//
//  ⚠️ HONEST ABOUT THE FILM. No lesson has a video yet — the film engine is
//  keyed by watch-library id, and the courses were written as outlines. So
//  the top of this page is the cover with "FILM · ARRIVING" and the lesson's
//  notes, exactly as `CourseLessonScreen` said it. The day a lesson carries
//  `videoUrl`, the poster becomes `PvVideoPlayer`; nothing else moves.
//
//  Progress is `PvLearnProgressStore`: opening a lesson records it as the
//  place to continue from; "Done" marks it. Local, hers.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../services/pv_learn_progress_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_learn_chrome.dart';
import 'pv_learn_flow.dart';
import 'pv_offering_content.dart';

const String kPvLessonRoutePrefix = 'learn/lesson/';

/// Opens lesson [index] of [v] — the lesson's own opener when it has one.
void pvOpenLesson(BuildContext context, PvOfferingView v, int index) {
  if (index < 0 || index >= v.lessons.length) return;
  final l = v.lessons[index];
  PvLearnProgressStore.instance.opened(v.id, l.id);
  if (l.open != null) {
    l.open!(context);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '$kPvLessonRoutePrefix${v.id}/${l.id}'),
      builder: (_) => PvLessonScreen(view: v, index: index),
    ),
  );
}

/// Is lesson [i] behind the purchase? The first lesson is always the
/// preview; the rest wait for the recording to be hers.
bool pvLessonGated(PvOfferingView v, int i) {
  if (i == 0 || v.isFree || v.offering == null) return false;
  return pvLearnStateFor(v) != PvLearnState.watching;
}

class PvLessonScreen extends StatefulWidget {
  const PvLessonScreen({super.key, required this.view, required this.index});
  final PvOfferingView view;
  final int index;

  @override
  State<PvLessonScreen> createState() => _PvLessonScreenState();
}

class _PvLessonScreenState extends State<PvLessonScreen> {
  late int _i = widget.index;

  PvOfferingView get v => widget.view;
  PvLearnLesson get lesson => v.lessons[_i];

  void _go(int i) {
    if (pvLessonGated(v, i)) {
      pvLearnCommit(context, v);
      return;
    }
    final l = v.lessons[i];
    if (l.open != null) {
      PvLearnProgressStore.instance.opened(v.id, l.id);
      l.open!(context);
      return;
    }
    setState(() => _i = i);
    PvLearnProgressStore.instance.opened(v.id, l.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PvLearnProgressStore.instance,
      builder: (context, _) {
        final progress = PvLearnProgressStore.instance;
        final done = progress.isDone(lesson.id);
        final next = _i + 1 < v.lessons.length ? _i + 1 : null;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PvLearnTopBar(
                  title: v.title,
                  eyebrow: 'Lesson ${_i + 1} of ${v.lessons.length}',
                ),
              ),
              // ---- the film, honestly -----------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PvLearnCover(view: v),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: PvKindTag(
                          lesson.videoUrl == null ? 'Film · arriving' : 'Film',
                        ),
                      ),
                      if (lesson.minutes > 0)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: PvKindTag(
                            '${lesson.minutes} min',
                            onPhoto: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: pvFraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${v.expert.name} · ${v.expert.role}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 13, color: p.ink2),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        lesson.blurb ??
                            (lesson.videoUrl == null
                                ? 'The outline of this lesson is final and the film is in review. It lands here the day it is ready; your place in the course is kept.'
                                : ''),
                        style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PvSecondary(
                              label: done ? 'Done' : 'Mark as done',
                              icon: done
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              onTap: () => done
                                  ? progress.markUndone(v.id, lesson.id)
                                  : progress.markDone(v.id, lesson.id),
                            ),
                          ),
                          if (next != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: PvCommit(
                                label: 'Next lesson',
                                icon: Icons.arrow_forward_rounded,
                                onTap: () {
                                  if (!done) progress.markDone(v.id, lesson.id);
                                  _go(next);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ---- up next ----------------------------------------------------------------------
              if (next != null) ...[
                const SliverToBoxAdapter(child: PvLearnHead('Up next')),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PvLessonRow(
                      index: next + 1,
                      lesson: v.lessons[next],
                      gated: pvLessonGated(v, next),
                      done: progress.isDone(v.lessons[next].id),
                      onTap: () => _go(next),
                    ),
                  ),
                ),
              ],
              // ---- the list ---------------------------------------------------------------------
              SliverToBoxAdapter(
                child: PvLearnHead(
                  pvStructureTitle(v),
                  lead:
                      '${progress.doneCount(v.id)} of ${v.lessons.length} done',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (var i = 0; i < v.lessons.length; i++)
                        PvLessonRow(
                          index: i + 1,
                          lesson: v.lessons[i],
                          current: i == _i,
                          done: progress.isDone(v.lessons[i].id),
                          gated: pvLessonGated(v, i),
                          onTap: () => _go(i),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}
