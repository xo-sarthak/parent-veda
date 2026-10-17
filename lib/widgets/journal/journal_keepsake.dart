// =============================================================================
//  The journal keepsake: one book, two stages (2026-10-17)
// -----------------------------------------------------------------------------
//  The user: the pregnancy journal and the parenting journal "look as separate
//  things… it looks like something else was built." The data was already one
//  system (one JournalStore, one `journal_entries` table; a parenting memory is
//  a JournalEntry tagged `pp_child:` / `pp_kind:`, BACKEND-PATTERNS §16x). Only
//  the drawing was two. This file is the drawing, once:
//
//    · JournalCover        the painted or photographed cover, "Dear …,"
//    · JournalDotStrip     where she is in it: 40 weeks, or a child's 12 months
//    · JournalQuestionCard a question for this week / this month
//    · JournalSectionHead  a week's or a month's heading, the photo version too
//    · JournalPageRow      one memory as a row on the page
//    · JournalPhotos       one photo wide, or a row of squares
//    · JournalRise         the staggered opening
//    · JournalPaperScaffold the writing page, on the same paper
//
//  These were private classes in `screens/journal/pv_journal_screen.dart`
//  (2026-09-23). They moved here with every value kept, so the pregnancy
//  journal draws exactly as it did; what each stage SAYS stays in its own
//  screen (weeks and voice notes there, age and letters in
//  `post_pregnancy/journal_v2/`).
//
//  THE TRADE-OFF, named: a change to the cover now lands in both stages at
//  once. That is the point — the two drifting apart was the bug.
// =============================================================================

import 'package:flutter/material.dart';

import '../../screens/v2/v2_palette.dart';
import '../../screens/v2/v3_tip_art.dart' show V3TipArt;
import '../../theme/pv_fonts.dart';
import '../pv_feedback.dart';
import '../storage_image.dart';

/// The journal's paper. ⚠️ THE ONE PAGE THAT IS NOT WHITE, ON PURPOSE: a
/// keepsake is paper (5 Minute Journal, the storybook journal's `jvPaper`), and
/// the white cards on it read as pages laid on a table. One constant — white
/// again is one edit.
const Color kJournalPaper = Color(0xFFFAF7F2);

/// The painting's warm accent — the tip card's sun.
const Color kJournalWarm = Color(0xFFC9831F);

const List<String> kJournalMonths = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];
const List<String> kJournalDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const List<String> kJournalWeekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
  'Sunday',
];

/// The Hero tag a single-photo entry's picture flies under, from its row to
/// its page.
String journalHeroTag(String entryId) => 'journal_photo_$entryId';

// =============================================================================
//  The opening
// =============================================================================

/// Rise into place in turn: the [index]th item fades and lifts 18pt, starting
/// a beat after the one before. Only the first few are staggered — anything
/// further down is off screen when the page opens and simply appears.
class JournalRise extends StatelessWidget {
  const JournalRise(
      {super.key, required this.open, required this.index, required this.child});
  final Animation<double> open;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (0.35 + 0.08 * index.clamp(0, 6)).clamp(0.0, 0.85);
    final a = CurvedAnimation(
        parent: open,
        curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, 18 * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }
}

// =============================================================================
//  The cover
// =============================================================================

/// Her newest photograph when she has one; else the stage's painting
/// ([painting], a URL from the image table); else the drawn sky
/// ([artVariant] of V3TipArt). Over it: [eyebrow], the [salutation] in italic
/// serif, and the [signoff].
class JournalCover extends StatelessWidget {
  const JournalCover({
    super.key,
    required this.pal,
    required this.photo,
    required this.painting,
    required this.artVariant,
    required this.eyebrow,
    required this.salutation,
    required this.signoff,
  });

  final V2Palette pal;
  final String? photo;
  final String? painting;
  final int artVariant;
  final String eyebrow;
  final String salutation;
  final String signoff;

  @override
  Widget build(BuildContext context) {
    final dark = photo != null || painting != null;
    final ink = dark ? Colors.white : pal.ink1;
    final soft = dark ? Colors.white.withValues(alpha: 0.82) : pal.ink2;

    return Stack(fit: StackFit.expand, children: [
      if (photo != null)
        StorageImage(photo!, fit: BoxFit.cover)
      else if (painting != null)
        Image.network(painting!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                V3TipArt(variant: artVariant, ink: pal.ink1, accent: kJournalWarm))
      else
        V3TipArt(variant: artVariant, ink: pal.ink1, accent: kJournalWarm),
      if (dark)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.3, 0.55, 1],
              colors: [
                Color(0x59000000),
                Color(0x00000000),
                Color(0x14000000),
                Color(0xB3000000),
              ],
            ),
          ),
        )
      else
        // The painting fades into the paper, so the page continues from it.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.55, 1],
              colors: [Color(0x00FAF7F2), kJournalPaper],
            ),
          ),
        ),
      Positioned(
        left: 22,
        right: 22,
        bottom: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow,
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: soft)),
            const SizedBox(height: 8),
            Text(salutation,
                style: pvFraunces(
                    fontSize: 40,
                    height: 1.05,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.6,
                    color: ink)),
            const SizedBox(height: 10),
            Text(signoff, style: pvManrope(fontSize: 15, height: 1.4, color: soft)),
          ],
        ),
      ),
    ]);
  }
}

// =============================================================================
//  Where she is in it
// =============================================================================

/// One dot per week (pregnancy, 40) or per month (a child's year, 12): ink
/// where she kept something, ringed for now. ⚠️ NOT A STREAK — it never counts
/// a gap, never says "missed".
class JournalDotStrip extends StatelessWidget {
  const JournalDotStrip({
    super.key,
    required this.pal,
    required this.count,
    required this.perRow,
    required this.current,
    required this.kept,
    required this.open,
    required this.headline,
    required this.headlineMuted,
    required this.right,
    required this.keptLegend,
    required this.nowLegend,
    this.dotSize = 11,
  });

  final V2Palette pal;
  final int count;
  final int perRow;

  /// 1-based: the ringed dot.
  final int current;

  /// 1-based dots she kept something in.
  final Set<int> kept;
  final Animation<double> open;

  /// "Week 24" + " of 40"; "4 months" + " old".
  final String headline;
  final String headlineMuted;

  /// Right-aligned, gives way first. Empty draws nothing.
  final String right;
  final String keptLegend;
  final String nowLegend;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final rows = (count / perRow).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: headline, style: pvFraunces(fontSize: 22, color: pal.ink1)),
                    TextSpan(text: headlineMuted, style: pvFraunces(fontSize: 22, color: pal.ink3)),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(right,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13, color: pal.ink2)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Each dot pops in on its own beat as the page opens — the first 40%
          // of the opening clock.
          LayoutBuilder(builder: (context, box) {
            final gap = (box.maxWidth - perRow * dotSize) / (perRow - 1);
            return Column(children: [
              for (var row = 0; row < rows; row++) ...[
                if (row > 0) const SizedBox(height: 10),
                Row(children: [
                  for (var i = 0; i < perRow && row * perRow + i < count; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    _dot(row * perRow + i + 1),
                  ],
                ]),
              ],
            ]);
          }),
          const SizedBox(height: 12),
          Wrap(spacing: 14, runSpacing: 6, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              _key(pal.ink1, filled: true),
              const SizedBox(width: 6),
              Flexible(child: Text(keptLegend, style: pvManrope(fontSize: 11.5, color: pal.ink3))),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _key(pal.action, filled: false),
              const SizedBox(width: 6),
              Flexible(child: Text(nowLegend, style: pvManrope(fontSize: 11.5, color: pal.ink3))),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _key(Color c, {required bool filled}) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: filled ? c : null,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: c, width: 1.6),
        ),
      );

  Widget _dot(int w) {
    final isNow = w == current;
    // A dot not yet reached cannot hold something she kept — a dot there
    // would read as a mistake (it was one: test data dated ahead of her).
    final has = w <= current && kept.contains(w);
    final past = w < current;
    final t = (w - 1) / count * 0.4;
    final a = CurvedAnimation(
        parent: open,
        curve: Interval(t, (t + 0.18).clamp(0.0, 1.0), curve: Curves.easeOutBack));
    final Color fill = has
        ? pal.ink1
        : (past ? pal.ink3.withValues(alpha: 0.28) : Colors.transparent);
    return AnimatedBuilder(
      animation: a,
      builder: (_, _) => Transform.scale(
        scale: a.value.clamp(0.0, 1.2),
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isNow && !has ? null : fill,
            shape: BoxShape.circle,
            border: isNow
                ? Border.all(color: pal.action, width: 2)
                : (past || has
                    ? null
                    : Border.all(color: pal.ink3.withValues(alpha: 0.35))),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  The question
// =============================================================================

/// A question for now: a painting, the [eyebrow], the [question] in serif, an
/// optional [sub] line, and Write it (plus Say it when [onSay] is given).
class JournalQuestionCard extends StatelessWidget {
  const JournalQuestionCard({
    super.key,
    required this.pal,
    required this.eyebrow,
    required this.question,
    required this.art,
    required this.artVariant,
    required this.canTurn,
    required this.skip,
    required this.onWrite,
    required this.onAnother,
    this.sub,
    this.onSay,
  });

  final V2Palette pal;
  final String eyebrow;
  final String question;
  final String? art;
  final int artVariant;

  /// More than one question to turn to.
  final bool canTurn;

  /// How many times "another" was asked: turns the arrow.
  final int skip;
  final ValueChanged<String> onWrite;
  final VoidCallback onAnother;
  final String? sub;
  final VoidCallback? onSay;

  @override
  Widget build(BuildContext context) {
    final q = question;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: art != null
                  ? Image.network(art!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => V3TipArt(
                          variant: artVariant, ink: pal.ink1, accent: kJournalWarm))
                  : V3TipArt(variant: artVariant, ink: pal.ink1, accent: kJournalWarm),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(eyebrow,
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: pal.action)),
                    ),
                    if (canTurn)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          tooltip: 'Another question',
                          padding: EdgeInsets.zero,
                          onPressed: onAnother,
                          icon: AnimatedRotation(
                            turns: skip * 0.5,
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            child: Icon(Icons.refresh_rounded,
                                size: 20, color: pal.ink2),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 6),
                  // Another question turns in: the old one slides up and out,
                  // the new one rises into its place.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0, 0.25), end: Offset.zero)
                            .animate(a),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: Text(q,
                        key: ValueKey(q),
                        style: pvFraunces(
                            fontSize: 23,
                            height: 1.3,
                            letterSpacing: -0.2,
                            color: pal.ink1)),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 10),
                    Text(sub!,
                        style: pvManrope(
                            fontSize: 13.5,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: pal.ink2)),
                  ],
                  const SizedBox(height: 18),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton(
                      onPressed: () {
                        pvCommitFeedback();
                        onWrite(q);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: pal.ink1,
                        foregroundColor: pal.surface,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: const StadiumBorder(),
                        textStyle: pvManrope(
                            fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Write it'),
                    ),
                    if (onSay != null)
                      OutlinedButton.icon(
                        onPressed: onSay,
                        icon: const Icon(Icons.mic_none_rounded, size: 18),
                        label: const Text('Say it'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: pal.ink1,
                          side: BorderSide(color: pal.line),
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: const StadiumBorder(),
                          textStyle: pvManrope(
                              fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  A week's or a month's heading
// =============================================================================

/// With a [photo], stoic.'s week card: the section IS its photograph, the
/// [photoEyebrow] / [title] / [summary] over it. Without, the [title] in
/// serif, [currentLabel] when [current], the [range] on the right, and an
/// optional italic [subtitle].
class JournalSectionHead extends StatelessWidget {
  const JournalSectionHead({
    super.key,
    required this.pal,
    required this.title,
    required this.current,
    required this.currentLabel,
    required this.range,
    required this.photoEyebrow,
    required this.summary,
    this.photo,
    this.subtitle,
  });

  final V2Palette pal;
  final String title;
  final bool current;

  /// "THIS WEEK" / "THIS MONTH".
  final String currentLabel;
  final String range;
  final String photoEyebrow;
  final String summary;
  final String? photo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Stack(fit: StackFit.expand, children: [
            StorageImage(photo!, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1],
                  colors: [Color(0x00000000), Color(0xA6000000)],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(photoEyebrow,
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 4),
                  Text(title,
                      style: pvFraunces(
                          fontSize: 32, height: 1.1, color: Colors.white)),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(summary,
                        style: pvManrope(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ],
              ),
            ),
          ]),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Flexible, so a long month ("September 2025") or a large text
            // size shortens with an ellipsis instead of overflowing.
            Flexible(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                      fontSize: 28, letterSpacing: -0.3, color: pal.ink1)),
            ),
            const SizedBox(width: 10),
            if (current)
              Flexible(
                child: Text(currentLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: pal.action)),
              ),
            // The range gives way first — the title never does.
            Expanded(
              child: Text(range,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12.5, color: pal.ink3)),
            ),
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!,
                style: pvFraunces(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    color: pal.ink3)),
          ),
      ],
    );
  }
}

// =============================================================================
//  One memory, as a row on the page
// =============================================================================

/// The date block (5 Minute Journal's), a small grey [eyebrow], the [title]
/// in serif, the [body], its [photos], and anything else the stage adds
/// ([extras]: voice notes, a place). [quiet] draws an auto entry smaller.
class JournalPageRow extends StatelessWidget {
  const JournalPageRow({
    super.key,
    required this.pal,
    required this.date,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.photos,
    required this.heroId,
    required this.onTap,
    this.quiet = false,
    this.empty = false,
    this.extras = const [],
  });

  final V2Palette pal;
  final DateTime date;
  final String eyebrow;
  final String title;
  final String body;
  final List<String> photos;
  final String heroId;
  final VoidCallback onTap;
  final bool quiet;
  final bool empty;
  final List<Widget> extras;

  @override
  Widget build(BuildContext context) {
    final d = date;
    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Column(children: [
                  Text(kJournalDays[d.weekday - 1],
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: pal.ink3)),
                  Text('${d.day}',
                      style: pvFraunces(
                          fontSize: 24, height: 1.15, color: pal.ink1)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow,
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: pal.ink3)),
                    const SizedBox(height: 5),
                    if (empty)
                      Text('A page with nothing on it yet — tap to add words '
                          'or a photo.',
                          style: pvManrope(
                              fontSize: 14,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                              color: pal.ink3)),
                    if (title.isNotEmpty)
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(
                              fontSize: quiet ? 16.5 : 18.5,
                              height: 1.3,
                              color: pal.ink1)),
                    if (body.isNotEmpty) ...[
                      if (title.isNotEmpty) const SizedBox(height: 4),
                      Text(body,
                          maxLines: quiet ? 2 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 14, height: 1.5, color: pal.ink2)),
                    ],
                    if (photos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      JournalPhotos(paths: photos, heroId: heroId),
                    ],
                    ...extras,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One photo wide; two or three as a row of squares.
class JournalPhotos extends StatelessWidget {
  const JournalPhotos({super.key, required this.paths, required this.heroId});
  final List<String> paths;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    if (paths.length == 1) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        // The photo travels into the entry page (`journalHeroTag`).
        child: Hero(
          tag: journalHeroTag(heroId),
          child: StorageImage(paths.first,
              fit: BoxFit.cover, borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return Row(children: [
      for (var i = 0; i < paths.length && i < 3; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: StorageImage(paths[i],
                fit: BoxFit.cover, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ]);
  }
}

// =============================================================================
//  The writing page
// =============================================================================

/// The page a memory is written on: the journal's paper, a plain back arrow,
/// a small-caps [eyebrow], the [title] in serif (italic when it is a question
/// or a letter's salutation), an optional [intro], then the fields.
///
/// Mobbin (journal composer): the prompt as a serif heading over the writing
/// area, one dark commit — Stoic (mobbin.com/screens/031adb37-b0a4-4362-a7e6-10c535b883b8).
class JournalPaperScaffold extends StatelessWidget {
  const JournalPaperScaffold({
    super.key,
    required this.pal,
    required this.eyebrow,
    required this.title,
    required this.children,
    this.intro,
    this.italic = false,
  });

  final V2Palette pal;
  final String eyebrow;
  final String title;
  final String? intro;
  final bool italic;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kJournalPaper,
      appBar: AppBar(
        backgroundColor: kJournalPaper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: pal.ink1,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 40),
        children: [
          journalPad(Text(eyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: pal.ink3))),
          const SizedBox(height: 8),
          journalPad(Text(title,
              style: pvFraunces(
                  fontSize: 30,
                  height: 1.18,
                  letterSpacing: -0.4,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  color: pal.ink1))),
          if (intro != null) ...[
            const SizedBox(height: 10),
            journalPad(Text(intro!,
                style: pvManrope(fontSize: 15, height: 1.5, color: pal.ink2))),
          ],
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

/// The page's side margin: 20, the same as the journal's sections.
Widget journalPad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);
