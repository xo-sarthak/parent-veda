// =============================================================================
//  ParentVeda Tools Kit - shared building blocks for the four "Journey" tools
// -----------------------------------------------------------------------------
//  Growth, Feeding, Sleep and the Milestone Checklist are built from the same
//  Claude Design prompts and share one visual grammar: an emotional Hero, a
//  <10-second Quick Log, a plain-language insight card, "Learn while tracking"
//  rows, calm empty states, and a soft timeline. This file holds those common
//  pieces + the small time/duration formatters, so the four tool screens stay
//  consistent and DRY. Pure UI over the pp_common palette - no state of its own.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pp_common.dart';

// ---- section padding --------------------------------------------------------
Widget ppToolPad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

// ---- tool header (back · eyebrow · serif title · subtitle) ------------------
/// The standard top of every tool screen. Returns the widgets as a list so the
/// caller can splat them into a ListView.
List<Widget> ppToolHeader(
  BuildContext context, {
  required String title,
  required String subtitle,
  String back = 'Tools',
  Widget? trailing,
}) =>
    [
      ppToolPad(Row(children: [
        Expanded(child: ppBack(context, back)),
        ?trailing,
      ])),
      const SizedBox(height: 18),
      ppToolPad(ppEyebrow('ParentVeda', color: ppPurple)),
      const SizedBox(height: 8),
      ppToolPad(Text(title, style: ppFraunces(30, h: 1.1))),
      const SizedBox(height: 8),
      ppToolPad(Text(subtitle, style: ppBody(14, h: 1.55))),
    ];

// ---- big primary "log" button ----------------------------------------------
Widget ppLogButton(String label, VoidCallback onTap, {IconData icon = Icons.add_rounded}) =>
    GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: ppCardShadow),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
        ]),
      ),
    );

// A softer secondary action (outline).
Widget ppGhostButton(String label, VoidCallback onTap, {IconData? icon}) => GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18, color: ppPurple), const SizedBox(width: 8)],
          Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w700)),
        ]),
      ),
    );

// ---- section header (title · optional trailing) -----------------------------
Widget ppSectionHead(String title, {String? trailing}) => Row(children: [
      Expanded(child: Text(title, style: ppJakarta(16))),
      if (trailing != null) Text(trailing, style: ppBody(12, color: ppMuted)),
    ]);

// ---- plain-language insight card (the "AI insight" / pattern voice) ---------
//  Soft lavender panel, small sparkle glyph, reassuring body. This is the tool's
//  interpretive voice - observations, never diagnoses.
Widget ppInsightCard(String text, {String tag = 'Insight', IconData icon = Icons.auto_awesome_outlined}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ppStripeB, Color(0xFFF0E9F7)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: ppPurple),
          const SizedBox(width: 7),
          Text(tag.toUpperCase(), style: ppBody(10, color: ppPurple, w: FontWeight.w800).copyWith(letterSpacing: 0.9)),
        ]),
        const SizedBox(height: 10),
        Text(text, style: ppBody(14, color: ppInk, h: 1.6)),
      ]),
    );

// ---- "Learn while tracking" row (opens an inline answer, never a dead end) ---
Widget ppLearnRow(BuildContext context, String title, {bool top = false, bool bottom = false}) => GestureDetector(
      onTap: () => ppFaqSheet(context, title),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
            border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        )),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book_outlined, size: 16, color: ppPurple),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: ppBody(13.5, color: ppInk, h: 1.4))),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );

// A whole "Learn while tracking" block: heading + rows.
Widget ppLearnBlock(BuildContext context, List<String> titles) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learn while you track', style: ppJakarta(16)),
        const SizedBox(height: 4),
        Text('Short, calm reads — tap to open.', style: ppBody(13)),
        const SizedBox(height: 6),
        for (int i = 0; i < titles.length; i++) ppLearnRow(context, titles[i], top: i != 0),
      ],
    );

// ---- calm empty state -------------------------------------------------------
Widget ppEmptyCard(IconData icon, String text) => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: ppPurple),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: ppBody(13, h: 1.5))),
      ]),
    );

// ---- choice chip (used in log sheets) ---------------------------------------
Widget ppChoiceChip(String label, bool on, VoidCallback onTap, {IconData? icon, bool expand = true}) {
  final chip = GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: icon != null ? 11 : 11, horizontal: icon != null ? 6 : 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? ppPurple : Colors.white,
        borderRadius: BorderRadius.circular(icon != null ? 14 : 12),
        border: Border.all(color: on ? ppPurple : ppLine),
      ),
      child: icon != null
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 18, color: on ? Colors.white : ppPurple),
              const SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center, style: ppBody(11.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
            ])
          : Text(label, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
    ),
  );
  return expand ? Expanded(child: chip) : chip;
}

// ---- label + text field for log sheets --------------------------------------
Widget ppFieldLabel(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
    );

Widget ppToolTextField(TextEditingController c, String label, {int maxLines = 1, bool number = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppFieldLabel(label),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: c,
            maxLines: maxLines,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: ppBody(14, color: ppInk),
            decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ]),
    );

// ---- bottom-sheet scaffold for a log sheet ----------------------------------
//  Handles the drag handle, keyboard inset, safe area and scroll. Pass a builder
//  that returns the sheet's column children given the sheet's setState.
void ppLogSheet(
  BuildContext context, {
  required String title,
  required List<Widget> Function(StateSetter setSheet) body,
  required String saveLabel,
  required VoidCallback onSave,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text(title, style: ppJakarta(18)),
              const SizedBox(height: 16),
              ...body(setSheet),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  onSave();
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                  child: Text(saveLabel, style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}

// ---- delete confirmation sheet ----------------------------------------------
void ppConfirmRemove(BuildContext context, String title, VoidCallback onConfirm) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: ppJakarta(16)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                  child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  onConfirm();
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)),
                  child: Text('Remove', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    ),
  );
}

// ---- a plain time-field trigger (opens the OS time picker) ------------------
Widget ppTimeField(String label, TimeOfDay value, VoidCallback onTap) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ppFieldLabel(label),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            child: Row(children: [
              const Icon(Icons.schedule_rounded, size: 16, color: ppPurple),
              const SizedBox(width: 8),
              Flexible(child: Text(ppFmtTod(value), style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      ],
    );

// ---- formatters -------------------------------------------------------------
String ppRelative(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.isNegative) return 'just now';
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m == 0 ? '${h}h ago' : '${h}h ${m}m ago';
  }
  return '${diff.inDays}d ago';
}

String ppClock(DateTime t) {
  final ampm = t.hour < 12 ? 'AM' : 'PM';
  var h = t.hour % 12;
  if (h == 0) h = 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
}

String ppFmtTod(TimeOfDay t) {
  final ampm = t.hour < 12 ? 'AM' : 'PM';
  var h = t.hour % 12;
  if (h == 0) h = 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
}

/// "2h 15m" / "45m" / "3h" from a minute count.
String ppDur(int mins) {
  if (mins <= 0) return '0m';
  final h = mins ~/ 60;
  final m = mins % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// A short date like "12 Jul" for timelines.
const List<String> ppMonthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String ppShortDate(DateTime d) => '${d.day} ${ppMonthsShort[d.month - 1]}';

/// True when [d] falls on today's calendar date.
bool ppIsToday(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}
