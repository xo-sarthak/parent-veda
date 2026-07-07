// =============================================================================
//  VedaResultView - the ONE shared Ask Veda result UI (both sides of the app)
// -----------------------------------------------------------------------------
//  Renders the neutral VedaAnswerView (the fixed 7-section result) so pregnancy
//  and parenting show the SAME interface - never two designs for the same thing.
//  It's driven entirely by data + a theme + routing callbacks:
//    • VedaViewTheme supplies the colours (each app passes its own palette),
//    • VedaContentRef.typeLabel already carries the human label (plug-and-play -
//      a new content type needs no switch here),
//    • the host screen supplies what a tap DOES (routing needs its Navigator).
//  Empty sections are omitted. Typography (Fraunces + Manrope) is shared by both
//  apps, so it lives here. No app imports - only flutter + google_fonts + core.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'veda_core.dart';

/// The per-app palette for the shared result UI.
class VedaViewTheme {
  const VedaViewTheme({
    required this.bg,
    required this.ink,
    required this.soft,
    required this.muted,
    required this.accent,
    required this.coral,
    required this.panel,
    required this.hair,
  });
  final Color bg;
  final Color ink;
  final Color soft;
  final Color muted;
  final Color accent; // primary (purple)
  final Color coral; // emotional / urgent
  final Color panel; // soft fill
  final Color hair; // hairline border
}

class VedaResultView extends StatelessWidget {
  const VedaResultView({
    super.key,
    required this.view,
    required this.theme,
    this.disclaimer =
        'General guidance for your stage - not a diagnosis, and never a substitute for your doctor.',
    this.onOpenContent,
    this.onOpenProducts,
    this.onOpenServices,
    this.onOpenCommunity,
    this.onAction,
  });

  final VedaAnswerView view;
  final VedaViewTheme theme;
  final String disclaimer;
  final void Function(VedaContentRef ref)? onOpenContent;
  final VoidCallback? onOpenProducts;
  final VoidCallback? onOpenServices;
  final VoidCallback? onOpenCommunity;
  final void Function(int index)? onAction;

  // Icon per kind - a small map with a sensible default, so adding a kind never
  // forces an edit here (the label already comes from the doc).
  static const Map<VedaKind, IconData> _icons = {
    VedaKind.canI: Icons.help_outline_rounded,
    VedaKind.symptom: Icons.healing_rounded,
    VedaKind.weekBaby: Icons.child_care_rounded,
    VedaKind.weekMother: Icons.favorite_rounded,
    VedaKind.read: Icons.menu_book_rounded,
    VedaKind.trimesterTip: Icons.lightbulb_outline_rounded,
    VedaKind.spiritual: Icons.self_improvement_rounded,
    VedaKind.readToBaby: Icons.auto_stories_rounded,
    VedaKind.garbh: Icons.spa_rounded,
    VedaKind.bodyChange: Icons.accessibility_new_rounded,
    VedaKind.tool: Icons.build_rounded,
    VedaKind.scan: Icons.monitor_heart_rounded,
    VedaKind.recipe: Icons.restaurant_menu_rounded,
    VedaKind.expert: Icons.verified_user_outlined,
    VedaKind.activity: Icons.extension_outlined,
    VedaKind.health: Icons.monitor_heart_outlined,
  };

  TextStyle get _serif => GoogleFonts.fraunces(color: theme.ink);
  TextStyle get _body => GoogleFonts.manrope(color: theme.soft, height: 1.6);

  Widget _eyebrow(String t) => Text(
        t.toUpperCase(),
        style: GoogleFonts.manrope(
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: theme.accent),
      );

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];
    void gap() => sections.add(const SizedBox(height: 24));

    // S1 - Veda answer (hero)
    sections.add(_answer());

    // S2 - What this means for you
    if (view.meaning.trim().isNotEmpty) {
      gap();
      sections.add(_meaning());
    }

    // S3 - Recommended actions
    if (view.actions.isNotEmpty) {
      gap();
      sections.add(_actions());
    }

    // S4 - ParentVeda content
    if (view.content.isNotEmpty) {
      gap();
      sections.add(_content());
    }

    // S5 - Community insight (social proof)
    if (view.community != null && view.community!.trim().isNotEmpty) {
      gap();
      sections.add(_community(view.community!));
    }

    // S6 - Products
    if (view.products.isNotEmpty) {
      gap();
      sections.add(_list('Products', view.products, Icons.shopping_bag_outlined, onOpenProducts));
    }

    // S7 - Services
    if (view.services.isNotEmpty) {
      gap();
      sections.add(_list('Services', view.services, Icons.handshake_outlined, onOpenServices));
    }

    // Disclaimer
    gap();
    sections.add(Text(disclaimer,
        style: GoogleFonts.manrope(fontSize: 11.5, height: 1.5, color: theme.muted)));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  // ---- S1 -----------------------------------------------------------------
  Widget _answer() {
    final parts = view.answer.trim().split('\n\n');
    final head = parts.first.trim();
    final rest = parts.length > 1 ? parts.sublist(1).join('\n\n').trim() : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.panel, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (view.urgent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: theme.coral.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: theme.coral),
              const SizedBox(width: 6),
              Text('Worth checking with a doctor',
                  style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: theme.coral)),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        _eyebrow('Veda answer'),
        const SizedBox(height: 12),
        Text(head, style: _serif.copyWith(fontSize: 21, fontWeight: FontWeight.w600, height: 1.25)),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(rest, style: _body.copyWith(fontSize: 14.5, color: theme.ink)),
        ],
      ]),
    );
  }

  // ---- S2 -----------------------------------------------------------------
  Widget _meaning() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _eyebrow('What this means for you'),
        const SizedBox(height: 10),
        Text(view.meaning.trim(), style: _body.copyWith(fontSize: 14.5, color: theme.ink)),
      ]);

  // ---- S3 -----------------------------------------------------------------
  Widget _actions() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _eyebrow('Recommended actions'),
        const SizedBox(height: 12),
        for (int i = 0; i < view.actions.length; i++)
          GestureDetector(
            onTap: onAction == null ? null : () => onAction!(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(view.actions[i], style: _body.copyWith(fontSize: 14, color: theme.ink))),
              ]),
            ),
          ),
      ]);

  // ---- S4 -----------------------------------------------------------------
  Widget _content() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _eyebrow('From ParentVeda'),
        const SizedBox(height: 12),
        for (final ref in view.content) ...[
          _contentCard(ref),
          const SizedBox(height: 10),
        ],
      ]);

  Widget _contentCard(VedaContentRef ref) => GestureDetector(
        onTap: onOpenContent == null ? null : () => onOpenContent!(ref),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: theme.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.hair)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: theme.accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(11)),
              child: Icon(_icons[ref.kind] ?? Icons.menu_book_rounded, size: 18, color: theme.accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ref.typeLabel.toUpperCase(),
                    style: GoogleFonts.manrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: theme.accent)),
                const SizedBox(height: 3),
                Text(ref.title,
                    style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25, color: theme.ink),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(ref.snippet, style: _body.copyWith(fontSize: 12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: theme.muted),
          ]),
        ),
      );

  // ---- S5 -----------------------------------------------------------------
  Widget _community(String line) => GestureDetector(
        onTap: onOpenCommunity,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.panel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(Icons.groups_rounded, size: 18, color: theme.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(line, style: _body.copyWith(fontSize: 13, color: theme.ink))),
            if (onOpenCommunity != null) Icon(Icons.chevron_right_rounded, size: 20, color: theme.muted),
          ]),
        ),
      );

  // ---- S6 / S7 ------------------------------------------------------------
  Widget _list(String title, List<String> items, IconData icon, VoidCallback? onOpen) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _eyebrow(title),
        const SizedBox(height: 12),
        for (final it in items)
          GestureDetector(
            onTap: onOpen,
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: theme.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.hair)),
              child: Row(children: [
                Icon(icon, size: 18, color: theme.accent),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(it,
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: theme.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                if (onOpen != null) Icon(Icons.chevron_right_rounded, size: 20, color: theme.muted),
              ]),
            ),
          ),
      ]);
}
