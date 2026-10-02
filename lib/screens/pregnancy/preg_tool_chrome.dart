// =============================================================================
//  The shell every pregnancy tool wears — 2026-09-30
// -----------------------------------------------------------------------------
//  WHY THIS EXISTS. The user, walking the pregnancy Tools: "I don't want any
//  stale UI lingering ... ParentVeda should look like a single application."
//  Trying to conceive builds every tool's front page on one shell
//  (`TtcToolScaffold`, lib/screens/ttc/ttc_tool_chrome.dart): the soft tinted
//  field, a round back button floating on it, the tool's own drawn mark, a small
//  eyebrow, one serif title, one sentence saying what the tool does, and a
//  white sheet sliding up over the field with the content in it. Pregnancy's
//  tools each drew their own app bar and page title, so ten tools looked like
//  ten screens. This is the same shell for pregnancy.
//
//  ⚠️ A COPY, NOT AN IMPORT, ON PURPOSE. Pregnancy files may not import from
//  lib/screens/ttc (the stages are isolated and ship separately), so this file
//  rebuilds the shell from the shared parts both stages already use: the V3
//  hero field (lib/screens/v2/v3_hero_field.dart), the palette, and the drawn
//  marks (`PvMarkWell` + `IntentMark`). The trade-off, named: two copies can
//  drift. What holds them together is that the numbers here (40 mark, 26 serif,
//  a 28 radius sheet, an 18 gutter) are TTC's, and that the field, the palette
//  and the marks are the shared ones. **If the TTC shell changes, change this.**
//
//  THE PARTS, and why each is there:
//   · A round BACK button, never an X: a tool is opened from a list, so it goes
//     back to it (Mobbin, the reference the TTC shell cites: Noom, Ro, Flo's
//     onboarding all put a round back on the field).
//   · The tool's MARK above the eyebrow: the same object she tapped on the Tools
//     row, so the row and the page it opens read as one thing. Only on a tool's
//     FRONT page, never on a detail page.
//   · The INTRO sentence: what the tool is, and what it is not. Above the first
//     input, because a screen that could be mistaken for a diagnosis needs to
//     say so before she has decided what it is.
//   · One optional ACTION opposite the back button, for "Add" on a list.
//   · The SHEET owns the bottom clearance for the floating Ask Veda button, so
//     the last card is never under it and the field never shows through.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../ttc/ttc_tool_marks.dart' show ttcFamilyMarkForIntent;
import '../products/pv_store_chrome.dart' show kPvInk;
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';

/// The gutter every tool page uses, so two tools cannot disagree by two points.
Widget pregToolPad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

/// The round back button that floats on the field. Its own semantics node, so
/// the word, the button role and the tap are one thing a screen reader can press.
class PregToolBack extends StatelessWidget {
  const PregToolBack({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      container: true,
      button: true,
      label: 'Back',
      child: InkWell(
        key: const ValueKey('preg_tool_back'),
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_rounded, size: 19, color: kPvInk),
        ),
      ),
    );
  }
}

/// Field, hero and sheet, in one call.
class PregToolScaffold extends StatelessWidget {
  const PregToolScaffold({
    super.key,
    required this.hue,
    required this.eyebrow,
    required this.title,
    required this.children,
    this.mark,
    this.intro,
    this.variant = 2,
    this.action,
    this.scrollController,
  });

  /// The hue of the tool's group on the Tools hub, so the field and the row she
  /// tapped are the same colour.
  final double hue;

  /// Small, letterspaced, above the title. The tool's name or its group.
  final String eyebrow;

  /// One serif line. What this page is.
  final String title;

  /// One sentence: what the tool does, and what it does not.
  final String? intro;

  /// The tool's drawn mark, the object on its Tools row. Front pages only.
  final IntentMark? mark;

  /// Everything inside the sheet.
  final List<Widget> children;

  /// Which composition the field draws. Vary it between a tool's pages so a flow
  /// is not one page repeated.
  final int variant;

  /// One control opposite the back button, for "Add" and almost nothing else. A
  /// hero with two actions in it is a toolbar.
  final Widget? action;

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    // A hue is an angle: `v2BlockTint` asserts hue <= 360.
    final h = hue % 360;
    final accent = v2BlockTint(h, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child: V3HeroField(
              accent: accent, ground: p.ground, variant: variant, chroma: v3FieldChroma(h)),
        ),
        ListView(
          controller: scrollController,
          // Zero: the sheet owns the bottom clearance, so the last screen-height
          // of scroll is never transparent (the field's lower arc showed through
          // it as a bloom under the last card on TTC's tools, 2026-09-17).
          padding: EdgeInsets.zero,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const PregToolBack(),
                    if (action != null) ...[const Spacer(), action!],
                  ]),
                  const SizedBox(height: 14),
                  if (mark != null) ...[
                    // ⚠️ THE TTC FAMILY'S OBJECT (2026-10-02, the user: the
                    // tool's front page should wear the same mark as its row
                    // on the Tools list, which is TTC's now). The drawn disc,
                    // bare, 40, in the field's own tint, as `TtcToolScaffold`
                    // draws its header mark. A mark with no counterpart keeps
                    // the well. Kept for revert: the `PvMarkWell` alone.
                    ExcludeSemantics(
                      child: SizedBox(
                        key: const ValueKey('preg_tool_header_mark'),
                        width: 40,
                        height: 40,
                        child: ttcFamilyMarkForIntent(mark, accent) ??
                            PvMarkWell(p: p, hue: h, size: 40, mark: mark),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Ink on the field, not ink2: on a tinted ground every ink tier
                  // moves one step darker (DESIGN-SYSTEM §4.0 rule (b)).
                  Text(eyebrow.toUpperCase(),
                      style: pvManrope(
                          fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink1)),
                  const SizedBox(height: 8),
                  Semantics(
                    header: true,
                    child: Text(title,
                        style: pvFraunces(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: p.ink1)),
                  ),
                  if (intro case final line?) ...[
                    const SizedBox(height: 10),
                    Text(line, style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1)),
                  ],
                ]),
              ),
            ),
            _Sheet(p: p, children: children),
          ],
        ),
      ]),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        // A full screen tall, so the field's lower arc never bleeds through.
        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 22, bottom: kAskFabReserve),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

/// The round ink "add" control that sits opposite the back button ([PregToolScaffold.action]).
/// One copy for the tools written from here on; Weight and Medicines still carry
/// private copies from the Tools audit that can move onto this (STILL-OPEN §81.15).
class PregToolAddAction extends StatelessWidget {
  const PregToolAddAction({super.key, required this.label, required this.onTap});

  /// What the button does, for a screen reader ("Add a reading").
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
          ),
        ),
      );
}
