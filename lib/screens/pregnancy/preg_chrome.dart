// =============================================================================
//  Pregnancy chrome — the "one ParentVeda" pieces, 2026-09-30
// -----------------------------------------------------------------------------
//  Main's rules for every stage (docs/DESIGN-SYSTEM.md §4.2 addendum and the
//  one-ParentVeda list): one ink #2F2C30 for everything pressable; ink text on
//  light grounds; no violet or plum chrome; no tinted block behind text (a tint
//  is for a tag, a pill or a mark's well); drawn marks on rows that open
//  somewhere, line icons only for controls; ONE section heading, the serif at
//  21 / w600 / −0.45; a small grey caps label only as a group label inside a
//  list or a form.
//
//  Trying to conceive holds these in `ttc_common.dart` and `ttc_more_tab.dart`.
//  Pregnancy does not import them (the stages stay code-isolated), so the
//  same numbers live here, once, for every pregnancy screen built on this
//  branch: More, Tools, Learn, Messages, the due date and the hero's card.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// The one section heading: the serif, 21 / w600 / −0.45, ink.
TextStyle pregSectionHeadingStyle() => pvFraunces(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.45,
      color: pvStorePalette.ink1,
    );

/// A small grey caps label: a group label inside a list or a form, never a
/// page section.
TextStyle pregGroupLabelStyle() => pvManrope(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      color: pvStorePalette.ink2,
    );

/// A page section's heading, announced as one to a screen reader.
class PregSectionHeading extends StatelessWidget {
  const PregSectionHeading(this.title, {super.key, this.lead, this.link, this.onLink});
  final String title;

  /// One grey line under it.
  final String? lead;

  /// A link on the lead's row, on the right ("See all consults"). It names
  /// what it opens.
  final String? link;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Semantics(header: true, child: Text(title, style: pregSectionHeadingStyle())),
      if (lead != null || (link != null && onLink != null)) ...[
        const SizedBox(height: 3),
        LayoutBuilder(
          builder: (context, box) => Row(children: [
            Expanded(
              child: lead == null
                  ? const SizedBox.shrink()
                  : Text(lead!, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
            ),
            if (link != null && onLink != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.6),
                child: InkWell(
                  onTap: onLink,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                        child: Text(link!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: p.ink2),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ],
    ]);
  }
}

/// What an offering costs, when a price is not the whole answer.
enum PregOfferTagKind { free, openingSoon }

class PregOfferTag extends StatelessWidget {
  const PregOfferTag(this.kind, {super.key});
  final PregOfferTagKind kind;

  static String label(PregOfferTagKind k) => switch (k) {
        PregOfferTagKind.free => 'Free',
        PregOfferTagKind.openingSoon => 'Opening soon',
      };

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final soon = kind == PregOfferTagKind.openingSoon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: soon ? p.surfaceAlt : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: soon ? null : Border.all(color: kPvLine),
      ),
      child: Text(label(kind), style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, color: p.ink2)),
    );
  }
}

/// One row that opens somewhere: a drawn mark in its section's tint, a name,
/// one grey line, and (for an offering) its price or tag on the right.
class PregOfferRow extends StatelessWidget {
  const PregOfferRow({
    super.key,
    required this.mark,
    required this.hue,
    required this.title,
    required this.line,
    required this.onTap,
    this.price,
    this.tag,
    this.badge,
    this.leading,
  });

  final IntentMark mark;

  /// A mark of the TTC family in place of the well (2026-10-02, the user:
  /// match More to TTC's marks). Drawn in a 44 box, as the TTC More rows draw
  /// theirs. Null keeps the well, so every other caller draws as before.
  final Widget? leading;
  final double hue;
  final String title;
  final String line;
  final VoidCallback onTap;
  final String? price;
  final PregOfferTagKind? tag;

  /// A count after the title (unread messages). Ink, never the brand colour.
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final big = MediaQuery.textScalerOf(context).scale(10) / 10 > 1.3;
    final hasPrice = price != null || tag != null;
    final priceBlock = Column(
      crossAxisAlignment: big ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (price != null)
          Text(price!, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
        if (price != null && tag != null) const SizedBox(height: 4),
        if (tag != null) PregOfferTag(tag!),
      ],
    );
    return Semantics(
      button: true,
      container: true,
      label: [title, line, ?price, if (tag != null) PregOfferTag.label(tag!)].join('. '),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(children: [
            leading != null
                ? SizedBox(width: 44, height: 44, child: leading)
                : PvMarkWell(p: p, hue: hue, size: 44, mark: mark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
                  ),
                  if (badge != null && badge! > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: kPvInk, borderRadius: BorderRadius.circular(999)),
                      child: Text('$badge',
                          style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink3)),
                if (big && hasPrice) ...[const SizedBox(height: 6), priceBlock],
              ]),
            ),
            if (!big && hasPrice) ...[const SizedBox(width: 10), priceBlock],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// A white card of rows with hairlines between them, indented past the mark.
class PregRowCard extends StatelessWidget {
  const PregRowCard({super.key, required this.children, this.empty});
  final List<Widget> children;

  /// What the card says when it has nothing (a feature is never hidden).
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // A Material rather than a decorated Container, so a row's InkWell has a
    // surface of its own to paint the press on (behind a white box it is lost).
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kPvLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: children.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(empty ?? '', style: pvManrope(fontSize: 13, height: 1.4, color: p.ink3)),
            )
          : Column(children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine, indent: 72, endIndent: 16),
                children[i],
              ],
            ]),
    );
  }
}

/// The one filled button: the ink, white words, a stadium.
ButtonStyle pregFilledStyle() => FilledButton.styleFrom(
      backgroundColor: kPvInk,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
    );

/// A white card with the page hairline: the one surface for a group of
/// content. Never a tinted block behind text.
class PregCard extends StatelessWidget {
  const PregCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), side: const BorderSide(color: kPvLine)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// A quiet note: a small line icon (a control-sized glyph) and grey words, on
/// the page itself. What a lavender "info banner" becomes.
class PregNote extends StatelessWidget {
  const PregNote(this.text, {super.key, this.icon = Icons.info_outline_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, size: 16, color: p.ink3),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2))),
    ]);
  }
}

/// The page title on a pushed tool page: the serif at 26, ink. The AppBar
/// above it carries only the back arrow.
TextStyle pregPageTitleStyle() => pvFraunces(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -0.5,
      color: pvStorePalette.ink1,
    );
