// =============================================================================
//  PvVideoPlaceholder / PvReadPlaceholder — a coming-soon that looks like the
//  thing it will become
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE OF ONE PIECE OF FEEDBACK THAT IS RIGHT ABOUT EVERY
//  PLACEHOLDER IN THE APP:
//
//    "Who have added videos, dummy videos sections? Right now you have just
//     returned the video name in a bar. You should basically show complete
//     thumbnail and write the head in the way it will appear. Finally only the
//     video will get added later."
//
//  A one-line row saying "Explainer video · 6 MIN" tells a reviewer nothing
//  about the screen. It does not occupy the space the video will occupy, it does
//  not sit at the aspect ratio the video will sit at, and it does not let anyone
//  judge whether the section is balanced. So the screen cannot actually be
//  reviewed until the content arrives — which is backwards, because the whole
//  point of building ahead of content is to review the shape first.
//
//  ⚠️ THE RULE, THEN: **a placeholder occupies the real geometry.** 16:9 for a
//  video, a real thumbnail block, a play control, the title set in the type it
//  will use, the duration where it sits. What is missing is the FILE, and only
//  the file.
//
//  ⚠️ AND IT MUST STILL BE HONEST. Looking real is not the same as pretending to
//  be real: it carries a quiet "coming soon" mark and it is NOT tappable, so
//  nobody taps a play button that plays nothing. A placeholder that looks
//  tappable and does nothing teaches her that taps do nothing — everywhere in
//  the app, not just here.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/v2/v2_palette.dart';
import '../theme/pv_fonts.dart';

/// A video, at the size and shape the real one will be.
class PvVideoPlaceholder extends StatelessWidget {
  const PvVideoPlaceholder({
    super.key,
    required this.title,
    this.subtitle,
    this.duration,
    this.hue = 268,
    this.slotId,
    this.onTap,
    this.episodeCount = 1,
    this.flat = false,
    this.overlayTitle = false,
  });

  /// Put the title INSIDE the 16:9 frame and drop the strip beneath it.
  ///
  /// ⚠️ THE STRIP IS THE PROBLEM THIS SOLVES, and the objection was precise:
  /// *"that white strip looked so odd… it's just increasing the space of the
  /// video placeholder. When I think of a real video there will be a thumbnail
  /// and everything."*
  ///
  /// That is exactly right, and it is a placeholder-specific failure. On a card
  /// in a rail the strip is correct — a title under a thumbnail is how a video
  /// list works. At the head of a page, where the thumbnail is already the
  /// hero, the strip adds sixty vertical points of white to say something the
  /// heading two lines above it has usually just said. Worse, it makes the
  /// placeholder TALLER than the real video will be, so the layout everyone is
  /// reviewing is not the layout that ships.
  ///
  /// So: title over the thumbnail behind a scrim, the way every video player
  /// does it, and the card becomes exactly its own 16:9.
  ///
  /// ⚠️ OPT-IN, DEFAULT OFF. Pregnancy and parenting use this widget inside
  /// fixed-height horizontal rails — the comment further down about a subtitle
  /// overflowing the Feel tab's card by 165px is what happens when this card's
  /// height changes under a layout that assumed it. Their cards are untouched.
  final bool overlayTitle;

  /// Drops the diagonal gradient for a single flat tint and a hairline.
  ///
  /// ⚠️ ADDED FOR THE READER, AND OFF BY DEFAULT so no existing screen moves.
  /// The gradient is right on a hub or a bracket page, where a thumbnail is
  /// competing with tiles and needs presence. It is wrong at the head of a
  /// long-form article, where the page is trying to read as editorial and a
  /// diagonal colour wash is the loudest thing on it — the reviewer's word was
  /// "gimmicky", and on that surface it is.
  ///
  /// ⚠️ ONE COMPONENT WITH TWO SKINS, NOT A SECOND COMPONENT. The whole reason
  /// this file exists is that placeholders kept being re-rolled per screen; the
  /// reader growing its own video block would be the fifth one.
  final bool flat;

  /// What the video will be called, set in the type it will actually use.
  final String title;

  /// One line on what it covers.
  final String? subtitle;

  /// "6 MIN". Shown on the thumbnail exactly where a real one shows it.
  final String? duration;

  /// The thumbnail's tint, off the controlled wheel — so a page with three
  /// placeholders does not read as three grey boxes.
  final double hue;

  /// ⚠️ The id a real file gets mapped to later. Carried here so the wiring is
  /// declared at the same moment the placeholder is, rather than being worked
  /// out again when the video arrives.
  final String? slotId;

  /// Non-null only once a real video exists.
  final VoidCallback? onTap;

  /// How many films this slot holds. 1 renders a single video; more than 1
  /// renders the series treatment.
  ///
  /// ⚠️ ONE CARD FOR A SERIES, NOT A ROW OF THEM — the YouTube playlist shape,
  /// and it is the right one for two reasons beyond familiarity. A rail of six
  /// thumbnails on a condition page reads as homework at the moment she is
  /// least able to face it, and it also spends the whole width of the page on
  /// the least useful information: she does not need to see episode four to
  /// decide to start. One cover, an honest count, one tap.
  final int episodeCount;

  bool get _live => onTap != null;

  bool get _isSeries => episodeCount > 1;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.42)
        .withLightness(0.52)
        .toColor();

    return Semantics(
      label: _live ? 'Video: $title' : 'Video coming soon: $title',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // ⚠️ NO BORDER, AND THE SHADOW DEFINES THE EDGE INSTEAD.
          //
          // This carried a 1px `p.line` hairline, which is calibrated for the
          // neutral ground the reader sits on. On the hub hero — a tinted
          // gradient — the same hairline has contrast on the dark side of the
          // gradient and none on the light side, so the card appeared to have
          // an edge on two corners and not on the other two. Reported as
          // "out of focus and not symmetric", which is exactly what a border
          // that fades across its own length looks like.
          //
          // A shadow does not have this problem: it darkens whatever is behind
          // it, so it reads equally on white, on a tint and on a photograph.
          // Slightly deepened here to carry the edge on its own.
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB9AECB).withValues(alpha: 0.42),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- THE THUMBNAIL, AT 16:9 -------------------------------------
              // The single most important line in this file. A video's shape is
              // most of its presence on a page; a text row has none of it.
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: flat ? tint : null,
                        gradient: flat
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [tint, deep],
                              ),
                      ),
                    ),
                    // A play control, drawn as the real one will be.
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            size: 30, color: deep),
                      ),
                    ),
                    if (duration != null)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(duration!,
                              style: pvManrope(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    // ⚠️ THE SERIES CORNER — "1 / 4", the shape a playlist has
                    // everywhere she has already seen one.
                    //
                    // It sits top-RIGHT, opposite the duration, because the two
                    // answer different questions ("how long is this one" vs
                    // "how much is there") and stacking them in one corner
                    // makes both read as one number.
                    if (_isSeries)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.playlist_play_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text('1 / $episodeCount',
                                style: pvManrope(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ]),
                        ),
                      ),
                    // ⚠️ THE SCRIM EXISTS ONLY WHERE TYPE SITS ON THE IMAGE.
                    // A full-frame scrim would dim the whole thumbnail to
                    // protect two lines; a top band protects the type and
                    // leaves the picture alone.
                    if (overlayTitle)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.52),
                                Colors.black.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (overlayTitle)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 10,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_live)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text('COMING SOON',
                                      style: pvManrope(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.9,
                                          color: deep)),
                                ),
                              const SizedBox(height: 7),
                              Text(title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvManrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      height: 1.25,
                                      color: Colors.white)),
                            ]),
                      ),
                    // ⚠️ HONEST, NOT HIDDEN. Looking real is not pretending to
                    // be real.
                    if (!_live && !overlayTitle)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('COMING SOON',
                              style: pvManrope(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                  color: deep)),
                        ),
                      ),
                  ],
                ),
              ),

              // ---- THE HEADING, IN THE TYPE IT WILL USE ----------------------
              if (!overlayTitle)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: pvFraunces(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      // ⚠️ CAPPED AT TWO LINES. A caption is a caption; one
                      // that wraps to five is a bug wherever it appears, and
                      // here it was a real one: inside the Feel tab's
                      // horizontal video rail the card is fixed-height, so a
                      // long subtitle overflowed the box by 165px and Flutter
                      // painted the yellow-and-black stripe over it on a
                      // phone. Capping is the right fix rather than growing
                      // the box, because the box is fixed for a good reason
                      // (a rail whose cards are different heights reads as
                      // broken) and because five lines of caption was never
                      // the intent anywhere.
                      Text(subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 13, height: 1.45, color: p.ink2)),
                    ],
                    // ⚠️ THE COUNT IS SAID IN WORDS AS WELL AS DRAWN.
                    //
                    // The "1 / 4" corner is a convention, and a convention only
                    // works on someone who already knows it. This line is for
                    // everyone else — and it is also what makes the tap target
                    // honest, because a card that opens a list rather than a
                    // film should say so before she taps it, not after.
                    if (_isSeries) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.playlist_play_rounded,
                            size: 16, color: deep),
                        const SizedBox(width: 6),
                        Text('$episodeCount-part series  ·  see all',
                            style: pvManrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: deep)),
                      ]),
                    ],
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

/// An audio track, at the size and shape the real one will be.
///
/// ⚠️ THE ROW IS THE REAL SHAPE HERE, and that is not the same concession as the
/// video's 16:9. A video's presence on a page is mostly its rectangle, so a text
/// row misrepresents it badly. A track in a playlist genuinely IS a row — cover,
/// title, category, length, play affordance — so occupying the real geometry
/// means occupying a row. Copying the video's big thumbnail would have made a
/// twelve-track sleep-sounds list twelve screens long.
class PvAudioPlaceholder extends StatelessWidget {
  const PvAudioPlaceholder({
    super.key,
    required this.title,
    this.category,
    this.length,
    this.hue = 268,
    this.slotId,
    this.onTap,
  });

  final String title;
  final String? category;
  final String? length;
  final double hue;

  /// The id a real file gets mapped to later.
  final String? slotId;
  final VoidCallback? onTap;

  bool get _live => onTap != null;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.44)
        .withLightness(0.46)
        .toColor();

    return Semantics(
      label: _live ? 'Play $title' : 'Audio coming soon: $title',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            // The cover art's space, with a play control on it — the two things
            // a real track row shows before you read anything.
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tint, deep.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  _live ? Icons.play_arrow_rounded : Icons.graphic_eq_rounded,
                  size: 24,
                  color: Colors.white.withValues(alpha: 0.95)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (category != null)
                      Text(category!.toUpperCase(),
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: p.ink3)),
                    if (category != null && length != null)
                      Text('  ·  ',
                          style: pvManrope(fontSize: 9.5, color: p.ink3)),
                    if (length != null)
                      Text(length!,
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: p.ink3)),
                    if (!_live) ...[
                      Text('  ·  ',
                          style: pvManrope(fontSize: 9.5, color: p.ink3)),
                      Text('COMING SOON',
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: p.ink3)),
                    ],
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// An article, at the size and shape the real one will be.
///
/// Same rule as the video: a real thumbnail block, the title in its own type,
/// the reading time where it will sit. What is missing is the words.
class PvReadPlaceholder extends StatelessWidget {
  const PvReadPlaceholder({
    super.key,
    required this.title,
    this.subtitle,
    this.readingTime,
    this.hue = 42,
    this.slotId,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? readingTime;
  final double hue;
  final String? slotId;
  final VoidCallback? onTap;

  bool get _live => onTap != null;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.40)
        .withLightness(0.44)
        .toColor();

    return Semantics(
      label: _live ? title : 'Article coming soon: $title',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A real cover block, not a glyph in a circle. An article card in
              // this app has a picture; the placeholder has the picture's space.
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tint, deep.withValues(alpha: 0.55)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded,
                    size: 26, color: Colors.white.withValues(alpha: 0.92)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvFraunces(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12.5, height: 1.4, color: p.ink2)),
                    ],
                    const SizedBox(height: 7),
                    Row(children: [
                      if (readingTime != null)
                        Text(readingTime!,
                            style: pvManrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: p.ink3)),
                      if (readingTime != null && !_live)
                        Text('  ·  ',
                            style: pvManrope(fontSize: 10, color: p.ink3)),
                      if (!_live)
                        Text('COMING SOON',
                            style: pvManrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: p.ink3)),
                    ]),
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
