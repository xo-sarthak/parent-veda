// =============================================================================
//  The pregnancy calendar's shared pieces (2026-10-17)
// -----------------------------------------------------------------------------
//  The card, the item row, the date block and the quiet pill every screen of
//  the rebuilt calendar uses, so the hub, Coming up and Whole journey read as
//  one thing. The look mirrors TTC's cycle hub (white card, radius 22, the
//  hairline, a soft shadow), read for shape only: stages stay isolated, so
//  nothing here imports a TTC widget.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart' show PvPress;
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../doors/pv_list_row.dart' show PvMarkWell;
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import 'preg_cal_data.dart';

/// The calendar's grey ground for chips, date blocks and the week band.
const Color kPregCalTint = Color(0xFFF4F4F2);

/// The pale band across the week she is in.
const Color kPregCalWeekTint = Color(0xFFF1EFE9);

/// The one card: white, radius 22, the hairline, a soft shadow.
class PregCalCard extends StatelessWidget {
  const PregCalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kPvLine),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

TextStyle pregCalSerif(double size) => pvFraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.12,
    letterSpacing: -0.3,
    color: pvStorePalette.ink1);

TextStyle pregCalBody(
        {double size = 14,
        FontWeight weight = FontWeight.w500,
        Color? color,
        double height = 1.35}) =>
    pvManrope(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? pvStorePalette.ink1);

/// Small grey caps: "TODAY · SAT 17 OCT", group labels.
TextStyle pregCalEyebrow() => pvManrope(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
    color: pvStorePalette.ink3);

/// A kind's drawn mark in its hue.
Widget pregCalMark(PregCalKind k, {double size = 34}) => PvMarkWell(
    p: pvStorePalette, hue: pregCalMeta(k).hue, size: size, mark: pregCalMeta(k).mark);

/// A neutral drawn mark (reminders, programs, nav rows).
Widget pregCalPlainMark(IntentMark m, {double size = 34, double hue = 40}) =>
    PvMarkWell(p: pvStorePalette, hue: hue, size: size, mark: m);

/// A tap that answers the finger: the 2% settle (`PvPress`) around the
/// detector, as tap_feedback_guard_test.dart asks of every plain tap.
Widget pregCalTap({required VoidCallback? onTap, required Widget child}) =>
    PvPress(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque, onTap: onTap, child: child));

/// The quiet pill: hairline or ink.
class PregCalPill extends StatelessWidget {
  const PregCalPill({
    super.key,
    required this.label,
    required this.onTap,
    this.ink = false,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final bool ink;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = ink ? Colors.white : kPvInk;
    return Semantics(
      button: true,
      child: pregCalTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: ink ? kPvInk : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: ink ? null : Border.all(color: kPvLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
          ]),
        ),
      ),
    );
  }
}

/// One item as a row: its mark, title, detail, chevron.
class PregCalItemRow extends StatelessWidget {
  const PregCalItemRow({
    super.key,
    required this.item,
    required this.onTap,
    this.first = false,
  });
  final PregCalItem item;
  final VoidCallback onTap;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return pregCalTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: kPvLine)),
        ),
        child: Row(children: [
          pregCalMark(item.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pregCalBody(weight: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(item.detail.isEmpty ? item.meta.label : item.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pregCalBody(size: 12.5, color: p.ink3)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// A date block and a line of Coming up: "SAT / 28" on the left, the countdown
/// eyebrow, title and a kind chip on the right. An open usual check shows its
/// first week instead ("WK / 24") in a dashed block: a window, not a date.
class PregCalUpcomingRow extends StatelessWidget {
  const PregCalUpcomingRow({
    super.key,
    required this.u,
    required this.today,
    required this.onTap,
    this.first = false,
  });
  final PregUpcoming u;
  final DateTime today;
  final VoidCallback onTap;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final meta = pregCalMeta(u.kind);
    return pregCalTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: kPvLine)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PregCalDateBlock(
            top: u.around ? 'WK' : pregWeekdayCaps(u.date),
            big: u.around ? '${u.check!.fromWeek}' : '${u.date.day}',
            dashed: u.around,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pregCountdown(u, today).toUpperCase(), style: pregCalEyebrow()),
              const SizedBox(height: 2),
              Text(u.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pregCalBody(size: 14.5, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                PregCalKindChip(kind: u.kind, label: meta.label),
                if (u.detail.isNotEmpty)
                  Text(u.detail,
                      style: pregCalBody(size: 12.5, color: p.ink3)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class PregCalDateBlock extends StatelessWidget {
  const PregCalDateBlock(
      {super.key, required this.top, required this.big, this.dashed = false});
  final String top;
  final String big;
  final bool dashed;

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: dashed ? Colors.white : kPregCalTint,
          borderRadius: BorderRadius.circular(14),
          border: dashed ? Border.all(color: kPvLine) : null,
        ),
        child: Column(children: [
          Text(top,
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: pvStorePalette.ink3)),
          Text(big, style: pregCalSerif(22)),
        ]),
      );
}

class PregCalKindChip extends StatelessWidget {
  const PregCalKindChip({super.key, required this.kind, required this.label});
  final PregCalKind kind;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: kPregCalTint, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: pregCalMeta(kind).color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: pvStorePalette.ink2)),
        ]),
      );
}

/// The sheet shell every calendar sheet uses: white, radius 28, a grab bar.
Future<T?> showPregCalSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: kPvLine,
                          borderRadius: BorderRadius.circular(99))),
                ),
                const SizedBox(height: 14),
                builder(ctx),
              ],
            ),
          ),
        ),
      ),
    );

/// ⓘ: three short lines, each with its icon. Never a block of text.
Future<void> showPregCalInfo(
    BuildContext context, String title, List<(IconData, String)> lines) {
  return showPregCalSheet<void>(
    context,
    (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: pregCalSerif(22)),
      const SizedBox(height: 8),
      for (final (icon, text) in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 20, color: kPvInk),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: pregCalBody(size: 14, height: 1.45))),
          ]),
        ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: kPvInk,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ),
    ]),
  );
}

/// The ink filled button, full width.
Widget pregCalSaveButton(String label, VoidCallback onPressed) => SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: kPvInk,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: onPressed,
        child: Text(label,
            style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
