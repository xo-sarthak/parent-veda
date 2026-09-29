// =============================================================================
//  The parts the TTC look-up tools share: Medical tests, Can I...?, This
//  week's food ideas, the Journey map and the Family timeline
// -----------------------------------------------------------------------------
//  Added 2026-09-27, night, in the tool rebuild. The user, walking build 13:
//  "old tools in new clothes... poor functionality". These five tools had
//  moved onto the tool shell earlier that day, but inside the sheet they were
//  still the V1 page: a stack of `TtcCard`s with drop shadows, a violet
//  "Read more" under every card, brown caution boxes and a purple search ring.
//  Opening a card grew it in place, so the list she was scanning jumped.
//
//  ⚠️ LIST, THEN DETAIL, THE WAY EVERY LOOK-UP APP DOES IT. Mobbin:
//    · Yuka "Additives" (https://mobbin.com/screens/5e756797-34ea-465d-814c-c139ce62a34f):
//      unboxed rows, the name, one grey line, the verdict word, a chevron;
//      the detail is its own page.
//    · DoorDash Dasher help (https://mobbin.com/screens/a768d9ac-8235-4bd8-89b6-81eb2a7bc677):
//      a search field first, headings, each question a row with a chevron.
//    · Beli FAQ search (https://mobbin.com/screens/69d9b3a0-71c2-4418-a4ef-1c371f6c1848):
//      a way to ask a person at the foot of the results.
//    · Bumble "Your report" / Hers "Consultation"
//      (https://mobbin.com/screens/09426d05-9e3c-4a74-b206-da7d04e07ba4,
//      https://mobbin.com/screens/f2441dba-a083-45a2-897a-1dd84d0b8fb4):
//      a progress trail as a hairline rail with a filled dot for done and a
//      ring for ahead, text beside it, no boxes.
//  So the rows here sit on the page gutter between hairlines (PvRowGroup,
//  DESIGN-SYSTEM §4.13 "Lists are not boxed"), and the detail opens in the
//  one reader (CLAUDE.md, "One reader") through `lib/ttc/ttc_lookup_reads.dart`.
//
//  ⚠️ NO VIOLET AT REST OR ON TAP. The search field is white with a hairline
//  and a grey lens, like `PvSearchBar`; a chosen segment is ink, like
//  `TtcToolOptions`. Colour is not how any of these says "chosen".
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_can_i_data.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk;

/// A live search field for a look-up list. White, hairline, grey lens, a
/// clear button once there is something to clear.
class TtcLookupSearchField extends StatelessWidget {
  const TtcLookupSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: p.line),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: pvManrope(fontSize: 14.5, color: p.ink1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: pvManrope(fontSize: 14.5, color: p.ink3),
        prefixIcon: Icon(Icons.search_rounded, size: 21, color: p.ink3),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                key: const ValueKey('ttc_lookup_search_clear'),
                tooltip: 'Clear search',
                icon: Icon(Icons.close_rounded, size: 18, color: p.ink3),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: border,
        enabledBorder: border,
        // The same hairline, a step darker, when she is typing. Never violet.
        focusedBorder: border.copyWith(
            borderSide: BorderSide(color: p.ink3, width: 1.2)),
      ),
    );
  }
}

/// Two equal choices, the chosen one in ink. "For her / For him".
class TtcLookupTwoWay extends StatelessWidget {
  const TtcLookupTwoWay({
    super.key,
    required this.left,
    required this.right,
    required this.rightOn,
    required this.onPick,
  });

  final String left;
  final String right;
  final bool rightOn;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    Widget seg(String label, bool on, bool value) => Expanded(
          child: Semantics(
            button: true,
            selected: on,
            child: GestureDetector(
              onTap: () {
                pvCommitFeedback();
                onPick(value);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: on ? ttcTitleInk : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label,
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: on ? p.surface : p.ink2)),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.line),
      ),
      child: Row(children: [
        seg(left, !rightOn, false),
        seg(right, rightOn, true),
      ]),
    );
  }
}

/// A small capitals heading over a group of rows.
class TtcLookupHeading extends StatelessWidget {
  const TtcLookupHeading(this.text, {super.key, this.top = 22});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 8),
      child: Text(text.toUpperCase(),
          style: pvManrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: p.ink3)),
    );
  }
}

/// One unboxed row: an optional leading mark, a title, any number of short
/// lines under it, and a chevron. The caller puts rows in a `PvRowGroup`.
class TtcLookupRow extends StatelessWidget {
  const TtcLookupRow({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.lines = const [],
    this.trailing,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final List<Widget> lines;

  /// Replaces the chevron. Null keeps the chevron when the row taps.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final body = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (leading != null) ...[
            Padding(padding: const EdgeInsets.only(top: 2), child: leading!),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: p.ink1)),
                for (final l in lines) ...[
                  const SizedBox(height: 4),
                  l,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child:
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ),
          ],
        ]),
      ),
    );
    if (onTap == null) return body;
    return PvPress(child: InkWell(onTap: onTap, child: body));
  }
}

/// A grey line under a row title.
Widget ttcLookupLine(String text,
    {int maxLines = 2, IconData? icon, bool strong = false}) {
  final p = V2PaletteStore.instance.current;
  final style = pvManrope(
      fontSize: strong ? 12.5 : 12.5,
      height: 1.4,
      fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
      color: strong ? p.ink1 : p.ink2);
  final t = Text(text,
      maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
  if (icon == null) return t;
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(top: 1.5),
      child: Icon(icon, size: 13.5, color: p.ink2),
    ),
    const SizedBox(width: 6),
    Expanded(child: t),
  ]);
}

/// A row that does something: a tinted well with a line icon, a label, an
/// arrow. "Ask Veda", "Your results", "Write in the journal".
class TtcLookupActionRow extends StatelessWidget {
  const TtcLookupActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.line,
    this.hue = 104,
  });

  final IconData icon;
  final String label;
  final String? line;
  final VoidCallback onTap;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue % 360, p);
    return TtcLookupRow(
      title: label,
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: tint, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: p.ink1),
      ),
      lines: [if (line != null) ttcLookupLine(line!)],
      trailing: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Icon(Icons.arrow_forward_rounded, size: 18, color: p.ink2),
      ),
    );
  }
}

/// The one quiet "this is information" line at the foot of a look-up.
class TtcLookupNote extends StatelessWidget {
  const TtcLookupNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
      const SizedBox(width: 9),
      Expanded(
        child: Text(text,
            style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
      ),
    ]);
  }
}

/// The verdict's mark, drawn in ink so it survives greyscale and a
/// colour-blind eye: a full dot is yes, a half dot is yes with a limit, a ring
/// is ask your doctor, a ring with a bar is better not. The WORD always sits
/// beside it; the mark only makes a column of answers scannable.
class TtcVerdictMark extends StatelessWidget {
  const TtcVerdictMark(this.verdict, {super.key, this.size = 11, this.color});

  final TtcVerdict verdict;
  final double size;

  /// The mark's colour; null is ink, as before. Added 2026-09-29 for the
  /// Can I...? verdict tag, which draws the mark in its tint's deeper shade
  /// (ttc_can_i_parts.dart).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return SizedBox(
      width: size,
      height: size,
      // Kept for revert (2026-09-29): _VerdictPainter(verdict, p.ink1)
      child: CustomPaint(painter: _VerdictPainter(verdict, color ?? p.ink1)),
    );
  }
}

class _VerdictPainter extends CustomPainter {
  _VerdictPainter(this.v, this.ink);

  final TtcVerdict v;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 0.75;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()..color = ink;
    switch (v) {
      case TtcVerdict.safe:
        canvas.drawCircle(c, r, fill);
      case TtcVerdict.moderate:
        canvas.drawCircle(c, r, stroke);
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), -1.5708, 3.1416,
            true, fill);
      case TtcVerdict.askDoctor:
        canvas.drawCircle(c, r, stroke);
      case TtcVerdict.avoid:
        canvas.drawCircle(c, r, stroke);
        canvas.drawLine(Offset(c.dx - r * 0.7, c.dy + r * 0.7),
            Offset(c.dx + r * 0.7, c.dy - r * 0.7), stroke);
    }
  }

  @override
  bool shouldRepaint(_VerdictPainter old) => old.v != v || old.ink != ink;
}

/// The verdict as a row line: its mark, its word, and its limit where it has
/// one ("Yes, with a limit · about 200mg of caffeine a day").
Widget ttcVerdictLine(TtcCanI item, bool hi) {
  final p = V2PaletteStore.instance.current;
  final limit = item.limit(hi);
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.only(top: 3),
      child: TtcVerdictMark(item.verdict),
    ),
    const SizedBox(width: 7),
    Expanded(
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: item.verdict.label(hi),
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                  color: p.ink1)),
          if (limit != null)
            TextSpan(
                text: ' · $limit',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: p.ink1)),
        ]),
      ),
    ),
  ]);
}

/// A plain sentence set as a small title, for an empty result.
TextStyle ttcLookupTitle(V2Palette p) => pvManrope(
    fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1);

/// A plain body sentence on a look-up page.
TextStyle ttcLookupBody(V2Palette p) =>
    pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2);
