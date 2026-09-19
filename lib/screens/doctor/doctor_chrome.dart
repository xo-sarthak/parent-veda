// =============================================================================
//  Doctor chrome — the few pieces every ParentVeda+ screen is built from
// -----------------------------------------------------------------------------
//  ParentVeda+ is used by clinicians who are mostly in their forties or older,
//  on a phone between patients. So this file is DESIGN-SYSTEM §4.0 (ink for
//  actions, brand as a small accent, colour only inside wells) with the type
//  and the targets TIGHTENED rather than loosened:
//
//    body 15.5 not 12.5 · meta 13 not 10.5 · rows ≥ 56 · targets ≥ 48
//    a chevron on every row that opens · numbers grouped the Indian way
//    no gesture-only actions · one commit button per screen, ink pill
//
//  Tokens come from V2PaletteStore (the app's palette), type from pv_fonts,
//  press feedback from pv_feedback — the same three sources as every V3 screen,
//  so the two apps are one brand. `pp_common.dart` is deliberately NOT
//  imported: it belongs to the parenting stage and another terminal.
//
//  The commit button is the onboarding one (ObPrimary / ObSecondary), re-
//  exported under a doctor name. "There is one button" (§4.3) — a second
//  implementation of the same pill would be the drift this file exists to stop.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';

export '../auth/onboarding/onboarding_chrome.dart' show ObPrimary, ObSecondary;

/// The palette every doctor widget reads. The doctor app never switches
/// ground, so a getter beats threading `p` through forty constructors.
V2Palette get dcP => V2PaletteStore.instance.current;

// ---- type ----------------------------------------------------------------

TextStyle dcTitle(double size, {Color? color, double h = 1.15}) => pvFraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -size * 0.02,
    height: h,
    color: color ?? dcP.ink1);

TextStyle dcNum(double size, {Color? color}) => pvFraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -size * 0.015,
    height: 1.05,
    color: color ?? dcP.ink1);

TextStyle dcBody(double size,
        {Color? color, FontWeight w = FontWeight.w500, double h = 1.45}) =>
    pvManrope(fontSize: size, fontWeight: w, height: h, color: color ?? dcP.ink1);

TextStyle dcStrong(double size, {Color? color}) =>
    pvManrope(fontSize: size, fontWeight: FontWeight.w700, height: 1.3, color: color ?? dcP.ink1);

TextStyle dcMeta(double size, {Color? color}) =>
    pvManrope(fontSize: size, fontWeight: FontWeight.w500, height: 1.35, color: color ?? dcP.ink2);

TextStyle dcEyebrow({Color? color}) => pvManrope(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: color ?? dcP.ink3);

// ---- money ---------------------------------------------------------------

/// ₹ with Indian grouping: 1,20,000 not 120,000. Paise in, rupees out. A
/// negative amount (a reversal) keeps its sign in front of the symbol.
String dcRupees(int paise, {bool showPaise = false}) {
  final neg = paise < 0;
  final abs = paise.abs();
  final r = showPaise ? abs ~/ 100 : (abs / 100).round();
  var s = r.toString();
  if (s.length > 3) {
    final tail = s.substring(s.length - 3);
    var head = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    s = '${parts.join(',')},$tail';
  }
  final p = showPaise ? '.${(abs % 100).toString().padLeft(2, '0')}' : '';
  return '${neg ? '−' : ''}₹$s$p';
}

/// "80%" from basis points; "82.5%" when it is not whole.
String dcPercent(int bps) {
  if (bps % 100 == 0) return '${bps ~/ 100}%';
  return '${(bps / 100).toStringAsFixed(1)}%';
}

const _mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String dcDate(DateTime d, {bool year = false}) {
  final l = d.toLocal();
  return '${l.day} ${_mo[l.month - 1]}${year ? ' ${l.year}' : ''}';
}

String dcDayDate(DateTime d) {
  final l = d.toLocal();
  return '${_wd[l.weekday - 1]} ${l.day} ${_mo[l.month - 1]}';
}

String dcTime(DateTime d) {
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '$h:$m ${l.hour < 12 ? 'am' : 'pm'}';
}

String dcMonth(DateTime d) => '${_mo[d.month - 1]} ${d.year}';

// ---- page frames ---------------------------------------------------------

/// A tab body inside DoctorScaffold: title, optional trailing, scrolling
/// children. Pull-to-refresh when [onRefresh] is given.
class DcTab extends StatelessWidget {
  const DcTab({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.onRefresh,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: dcTitle(30)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: dcMeta(14)),
              ],
            ]),
          ),
          ?trailing,
        ]),
        const SizedBox(height: 18),
        ...children,
      ],
    );
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, color: dcP.ink1, child: list);
  }
}

/// A pushed screen: white ground, back arrow, title, scrolling body, an
/// optional commit button pinned at the bottom.
class DcScreen extends StatelessWidget {
  const DcScreen({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.bottom,
    this.trailing,
    this.onRefresh,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final Widget? trailing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    Widget list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Text(title, style: dcTitle(28)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: dcMeta(14)),
        ],
        const SizedBox(height: 18),
        ...children,
      ],
    );
    if (onRefresh != null) {
      list = RefreshIndicator(onRefresh: onRefresh!, color: p.ink1, child: list);
    }
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: 48,
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                tooltip: 'Back',
              ),
              const Spacer(),
              ?trailing,
            ]),
          ),
          Expanded(child: list),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: bottom,
            ),
        ]),
      ),
    );
  }
}

// ---- sections and rows ---------------------------------------------------

class DcSectionHead extends StatelessWidget {
  const DcSectionHead(this.eyebrow, {super.key, this.title, this.note, this.onNote});
  final String eyebrow;
  final String? title;
  final String? note;
  final VoidCallback? onNote;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(eyebrow.toUpperCase(), style: dcEyebrow(color: p.action.withValues(alpha: 0.85))),
          const Spacer(),
          if (note != null)
            InkWell(
              onTap: onNote,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(note!,
                    style: dcStrong(13, color: onNote == null ? p.ink3 : p.action)),
              ),
            ),
        ]),
        if (title != null) ...[
          const SizedBox(height: 4),
          Text(title!, style: dcTitle(21)),
        ],
      ]),
    );
  }
}

/// A white card with a hairline. Elevation in this system is a line.
class DcCard extends StatelessWidget {
  const DcCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.tint});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return PvPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: box),
      ),
    );
  }
}

/// The list row: optional icon well, title, subtitle, a trailing value or a
/// chevron. ≥ 56 tall. Rows stack with hairlines between them inside a
/// DcRowGroup, or stand alone as a card.
class DcRow extends StatelessWidget {
  const DcRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.hue,
    this.trailing,
    this.trailingText,
    this.trailingSub,
    this.onTap,
    this.chevron = true,
    this.titleColor,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final double? hue;
  final Widget? trailing;
  final String? trailingText;
  final String? trailingSub;
  final VoidCallback? onTap;
  final bool chevron;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hue == null ? p.surfaceAlt : v2BlockTint(hue!, p),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: p.ink1),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: dcStrong(15.5, color: titleColor), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: dcMeta(13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
        if (trailingText != null) ...[
          const SizedBox(width: 12),
          // Capped, not flexed: a Flexible here takes a flex SHARE of the row
          // and squeezes the value to a quarter width (walked 2026-09-18:
          // "Obstetricia / n"). A cap lets a sum or two-line hours sit at
          // their natural width and only wraps the genuinely long.
          LayoutBuilder(
            builder: (ctx, _) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.44),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(trailingText!, style: dcStrong(15), textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (trailingSub != null) ...[
                  const SizedBox(height: 2),
                  Text(trailingSub!, style: dcMeta(12, color: p.ink3), textAlign: TextAlign.right),
                ],
              ]),
            ),
          ),
        ],
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        if (onTap != null && chevron) ...[
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 24, color: p.ink3),
        ],
      ]),
    );
    if (onTap == null) return row;
    return PvPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: row),
      ),
    );
  }
}

/// A label and its value: the label short and fixed, the value taking the
/// rest and wrapping. For "what parents see" and a payout's particulars —
/// the opposite shape from DcRow, where the title is the long side.
class DcKeyValue extends StatelessWidget {
  const DcKeyValue(this.label, this.value, {super.key, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(label, style: dcMeta(14.5))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: dcStrong(15).copyWith(fontFeatures: mono ? const [FontFeature.tabularFigures()] : null)),
          ),
        ]),
      );
}

/// Rows in one hairlined card, separated by hairlines.
class DcRowGroup extends StatelessWidget {
  const DcRowGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: p.line, indent: 16, endIndent: 16),
          children[i],
        ],
      ]),
    );
  }
}

/// Label small and above, value large and below — never the reverse (§4.10).
class DcStat extends StatelessWidget {
  const DcStat(this.label, this.value, {super.key, this.sub, this.valueColor});
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: dcEyebrow()),
          const SizedBox(height: 6),
          Text(value, style: dcNum(24, color: valueColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub!, style: dcMeta(12.5)),
          ],
        ],
      );
}

/// Two or three stats side by side in one card.
class DcStatRow extends StatelessWidget {
  const DcStatRow(this.stats, {super.key});
  final List<DcStat> stats;

  @override
  Widget build(BuildContext context) => DcCard(
        child: Row(children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) Container(width: 1, height: 44, color: dcP.line, margin: const EdgeInsets.symmetric(horizontal: 14)),
            Expanded(child: stats[i]),
          ],
        ]),
      );
}

/// The blocker / attention card — Airbnb's "Account info is needed — Required
/// to get paid". One thing, one action. Amber well because it is a notice,
/// never a fill.
class DcAttention extends StatelessWidget {
  const DcAttention({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
    this.icon = Icons.info_outline_rounded,
    this.urgent = false,
  });
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;
  final IconData icon;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final well = v2BlockTint(urgent ? 344 : 42, p);
    return DcCard(
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: well, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 21, color: p.ink1),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: dcStrong(15.5)),
            const SizedBox(height: 3),
            Text(body, style: dcMeta(13.5)),
            const SizedBox(height: 8),
            Text(action, style: dcStrong(14, color: p.action)),
          ]),
        ),
        Icon(Icons.chevron_right_rounded, size: 24, color: p.ink3),
      ]),
    );
  }
}

/// A receipt line: label left, value right. [strong] for the total.
class DcReceiptLine extends StatelessWidget {
  const DcReceiptLine(this.label, this.value, {super.key, this.strong = false, this.muted = false, this.note});
  final String label;
  final String value;
  final bool strong;
  final bool muted;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final c = muted ? p.ink2 : p.ink1;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: strong ? 10 : 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: strong ? dcStrong(16) : dcBody(15, color: c))),
          Text(value, style: strong ? dcNum(20) : dcStrong(15, color: c)),
        ]),
        if (note != null) ...[
          const SizedBox(height: 3),
          Text(note!, style: dcMeta(12.5, color: p.ink3)),
        ],
      ]),
    );
  }
}

/// Segmented control: hairline pills, selected = ink fill (§4.0 chip).
/// [expand] shares the width equally and never scrolls — for two or three
/// segments that must all be visible on a 360px phone (Today · Upcoming ·
/// Past). A segment a clinician cannot see is a tab that does not exist.
class DcSegments extends StatelessWidget {
  const DcSegments({super.key, required this.labels, required this.index, required this.onChanged, this.expand = false});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    Widget pill(int i) => PvPress(
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: expand ? 6 : 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == index ? p.ink1 : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: i == index ? p.ink1 : p.line),
              ),
              child: Text(labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dcStrong(expand ? 13.5 : 14, color: i == index ? p.surface : p.ink1)),
            ),
          ),
        );
    if (expand) {
      return Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: pill(i)),
        ],
      ]);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          pill(i),
        ],
      ]),
    );
  }
}

/// A status word in a hairline pill. Colour only as a tinted well.
class DcStatusPill extends StatelessWidget {
  const DcStatusPill(this.label, {super.key, this.hue});
  final String label;
  final double? hue;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hue == null ? p.surfaceAlt : v2BlockTint(hue!, p),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: dcStrong(12, color: p.ink1)),
    );
  }
}

/// The empty state — the feature's advertisement, never a blank.
class DcEmpty extends StatelessWidget {
  const DcEmpty(this.title, this.body, {super.key, this.icon = Icons.inbox_outlined, this.action, this.onAction});
  final String title;
  final String body;
  final IconData icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return DcCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 26, color: p.ink3),
        const SizedBox(height: 12),
        Text(title, style: dcStrong(16)),
        const SizedBox(height: 4),
        Text(body, style: dcMeta(14)),
        if (action != null && onAction != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(action!, style: dcStrong(14, color: p.action)),
            ),
          ),
        ],
      ]),
    );
  }
}

/// A switch row: label + optional sub on the left, the switch on the right.
/// The switch's on-state is one of the five places violet may appear.
class DcSwitchRow extends StatelessWidget {
  const DcSwitchRow({super.key, required this.title, required this.value, required this.onChanged, this.subtitle, this.icon});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => DcRow(
        title: title,
        subtitle: subtitle,
        icon: icon,
        chevron: false,
        onTap: () => onChanged(!value),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: dcP.action,
        ),
      );
}

/// A text input in the onboarding field's clothes: label above, hairline box.
class DcInput extends StatelessWidget {
  const DcInput({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.obscure = false,
    this.onSubmitted,
    this.autofocus = false,
    this.capitals = false,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final bool obscure;
  final bool autofocus;
  final bool capitals;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: dcEyebrow()),
      const SizedBox(height: 7),
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        autofocus: autofocus,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: capitals ? TextCapitalization.characters : TextCapitalization.none,
        style: dcBody(16),
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: dcBody(16, color: p.ink3),
          filled: true,
          fillColor: p.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.line, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.ink1, width: 1.4),
          ),
        ),
      ),
    ]);
  }
}

/// A notice well — the calm callout. Sand for information, rose for a
/// problem. Never a fill of the action colour.
class DcNotice extends StatelessWidget {
  const DcNotice(this.text, {super.key, this.problem = false});
  final String text;
  final bool problem;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: v2BlockTint(problem ? 344 : 42, p),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: dcBody(14, h: 1.45)),
    );
  }
}

/// The app's sheet: ground, top radius 24, close top-right (§4.0).
Future<T?> dcSheet<T>(BuildContext context, {required String title, required Widget child, bool scrollable = true}) {
  final p = dcP;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
              child: Row(children: [
                Expanded(child: Text(title, style: dcTitle(22))),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icon(Icons.close_rounded, color: p.ink1),
                  tooltip: 'Close',
                ),
              ]),
            ),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: child,
                    )
                  : Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), child: child),
            ),
          ]),
        ),
      ),
    ),
  );
}

/// Every commit tap answers (DESIGN-SYSTEM §4.0c).
void dcToast(BuildContext context, String text) {
  pvCommitFeedback();
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(text, style: dcBody(14, color: Colors.white)),
      backgroundColor: dcP.ink1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}
