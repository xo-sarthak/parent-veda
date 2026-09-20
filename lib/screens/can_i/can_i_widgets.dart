// =============================================================================
//  Is it safe? — the pieces the door, the group page and the answer share
// -----------------------------------------------------------------------------
//  2026-09-19. Three widgets and one rule.
//
//  THE RULE: a verdict is a 7pt dot and a word. Never a painted tile, never a
//  tinted box behind the name (DESIGN-SYSTEM §4.0 addendum 1). Yuka's item
//  rows are the reference: the dot carries the colour, the word carries the
//  meaning, the photo carries the appeal, and nothing fights.
//
//  THE TILE (`CanICutoutTile`): the thing's photo, square, on the white
//  ground with a hairline — Uber Eats' Safeway grid, Shipt, Thrive Market.
//  The verdict pill sits on the photo's corner so a grid of twelve reads as
//  a verdict map without a tap. No photo yet → the group's line icon in a
//  neutral well, never a blank.
//
//  THE ROW (`CanIRow`): a 44pt thumbnail, the name, the dot and the word.
//  The search result and the recents list.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/reads/can_i_read.dart';
import '../../data/reads/read_images.dart';
import '../../models/can_i_entry.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';

/// The photo for an entry, from the one read-image table (`cani_<id>`).
String? canIImageFor(String entryId) => readImageFor('$kCanIReadPrefix$entryId');

/// The dot's colour. The only colour a verdict is allowed to wear.
Color canIVerdictColor(CanIVerdict v, V2Palette p) => switch (v) {
      CanIVerdict.safe => const Color(0xFF2E9E5B),
      CanIVerdict.moderation => const Color(0xFFD99A1E),
      CanIVerdict.depends => const Color(0xFFD99A1E),
      CanIVerdict.avoid => const Color(0xFFE0475F),
      CanIVerdict.askDoctor => p.ink1,
    };

IconData canICategoryIcon(CanICategory c) => switch (c) {
      CanICategory.eat => Icons.restaurant_outlined,
      CanICategory.drink => Icons.local_cafe_outlined,
      CanICategory.take => Icons.medication_outlined,
      CanICategory.doActivity => Icons.directions_walk_outlined,
    };

String canICategoryLabel(CanICategory c) => switch (c) {
      CanICategory.eat => 'Eat',
      CanICategory.drink => 'Drink',
      CanICategory.take => 'Take',
      CanICategory.doActivity => 'Do',
    };

/// A photo that tries again. The free hosts throttle by IP — Wikimedia
/// answered 429 to a phone sharing an IP with a script, 2026-09-19 — and a
/// tile that gives up on the first refusal is blank for the whole visit.
/// One retry at 2 s, one at 5 s, then the fallback. The end state is our
/// own host (R2, STILL-OPEN §68.4), where none of this is needed.
class CanIPhoto extends StatefulWidget {
  const CanIPhoto({super.key, required this.url, required this.fallback, this.fit = BoxFit.cover});
  final String url;
  final Widget fallback;
  final BoxFit fit;

  @override
  State<CanIPhoto> createState() => _CanIPhotoState();
}

class _CanIPhotoState extends State<CanIPhoto> {
  int _attempt = 0;
  // A retry is a Timer, not a Future.delayed, so a card scrolled away (or
  // a page popped) cancels it rather than firing into a dead widget.
  Timer? _retry;

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }
  // Four tries over about a minute, not two over seven seconds. A door
  // opens thirty photos at once and the free hosts answer the burst with
  // 429 for longer than five seconds; on the phone (2026-09-20) the grid's
  // second row had given up for good while curl on the same phone fetched
  // every one of them. Jitter spreads the retries so they are not a second
  // burst. R2 (`kReadImageBase`) is the fix; this is the meantime.
  static const _delays = [
    Duration(seconds: 2),
    Duration(seconds: 6),
    Duration(seconds: 15),
    Duration(seconds: 40),
  ];

  @override
  Widget build(BuildContext context) => Image.network(
        widget.url,
        key: ValueKey('${widget.url}#$_attempt'),
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) {
          if (_attempt < _delays.length) {
            final next = _attempt + 1;
            final jitter = Duration(milliseconds: widget.url.hashCode.abs() % 1500);
            _retry?.cancel();
            _retry = Timer(_delays[_attempt] + jitter, () {
              if (mounted && _attempt == next - 1) setState(() => _attempt = next);
            });
          }
          return widget.fallback;
        },
      );
}

/// The dot and the word, inline.
class CanIVerdictLine extends StatelessWidget {
  const CanIVerdictLine({super.key, required this.verdict, required this.p, this.size = 12.5});
  final CanIVerdict verdict;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        CanIVerdictDot(verdict: verdict, p: p),
        const SizedBox(width: 6),
        Text(canIVerdictWord(verdict),
            style: pvManrope(fontSize: size, fontWeight: FontWeight.w700, color: p.ink2)),
      ]);
}

class CanIVerdictDot extends StatelessWidget {
  const CanIVerdictDot({super.key, required this.verdict, required this.p, this.size = 7});
  final CanIVerdict verdict;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: canIVerdictColor(verdict, p)),
      );
}

/// The white pill on a photo's corner: dot + word, hairline, no tint.
class CanIVerdictPill extends StatelessWidget {
  const CanIVerdictPill({super.key, required this.verdict, required this.p});
  final CanIVerdict verdict;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(7, 4, 8, 4),
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CanIVerdictDot(verdict: verdict, p: p, size: 6),
          const SizedBox(width: 5),
          Text(canIVerdictWord(verdict),
              style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.2, color: p.ink1)),
        ]),
      );
}

/// A square photo with the name under it and the verdict on its corner.
class CanICutoutTile extends StatelessWidget {
  const CanICutoutTile({super.key, required this.entry, required this.p, required this.onTap});
  final CanIEntry entry;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = canIImageFor(entry.id);
    return PvPress(
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(fit: StackFit.expand, children: [
                if (url != null) CanIPhoto(url: url, fallback: _well(p)) else _well(p),
                Positioned(left: 6, bottom: 6, child: CanIVerdictPill(verdict: entry.verdict, p: p)),
              ]),
            ),
          ),
          const SizedBox(height: 7),
          Text(entry.name.now,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
        ]),
      ),
    );
  }

  Widget _well(V2Palette p) => Center(
        child: Icon(canICategoryIcon(entry.category), size: 30, color: p.ink3),
      );
}

/// A row: thumbnail, name, dot and word. Optional trailing (a chevron, an
/// "asked" time).
class CanIRow extends StatelessWidget {
  const CanIRow({super.key, required this.entry, required this.p, required this.onTap, this.last = false});
  final CanIEntry entry;
  final V2Palette p;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final url = canIImageFor(entry.id);
    return InkWell(
      onTap: () {
        pvCommitFeedback();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: last ? null : Border(bottom: BorderSide(color: p.line))),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: url != null
                ? CanIPhoto(url: url, fallback: Icon(canICategoryIcon(entry.category), size: 20, color: p.ink3))
                : Icon(canICategoryIcon(entry.category), size: 20, color: p.ink3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.name.now,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
              const SizedBox(height: 3),
              CanIVerdictLine(verdict: entry.verdict, p: p, size: 12),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// A section heading in the door's type.
Widget canIHeading(V2Palette p, String text, {String? sub}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: pvFraunces(
                fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.45, color: p.ink1)),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(sub, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
        ],
      ],
    );

/// An ink chip — a sub-group, a recent, a scope.
class CanIChip extends StatelessWidget {
  const CanIChip({super.key, required this.label, required this.p, required this.onTap, this.selected = false, this.leading});
  final String label;
  final V2Palette p;
  final VoidCallback onTap;
  final bool selected;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => PvPress(
        child: Material(
          color: selected ? p.ink1 : p.surface,
          shape: StadiumBorder(side: BorderSide(color: selected ? p.ink1 : p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(leading == null ? 14 : 6, 8, 14, 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Text(label,
                    style: pvManrope(
                        fontSize: 13, fontWeight: FontWeight.w700, color: selected ? p.ground : p.ink1)),
              ]),
            ),
          ),
        ),
      );
}
