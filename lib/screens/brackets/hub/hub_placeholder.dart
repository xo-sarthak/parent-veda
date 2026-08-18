// =============================================================================
//  HubPlaceholder — spec P0 #5, and §7's rule about what a placeholder says
// -----------------------------------------------------------------------------
//  ⚠️ "COMING SOON" ALONE IS BANNED. §7 is explicit, and the reason is worth
//  keeping: a bare chip tells her nothing, so the only thing she learns is that
//  the app is unfinished. A placeholder that explains the future VALUE teaches
//  her what will be here — which is useful on its own, and is also the honest
//  version of a promise.
//
//    Bad   "Coming soon"
//
//    Good  Understanding your fertile window
//          A short expert explanation of when you are most fertile.
//          [Video coming soon]
//
//  So this widget cannot render without a value sentence. It is a required
//  argument, not an optional one.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT IS NOT TAPPABLE, AND THAT IS THE DESIGN
//  ---------------------------------------------------------------------------
//
//  A tappable placeholder opens a sheet that says "coming soon" again, which is
//  a dead end wearing a gesture. Worse, it teaches her that rows in this app may
//  not do anything — and that doubt spreads to the rows that DO work.
//
//  So: no ink, no chevron, no ripple. It reads as information about the future,
//  which is what it is. The moment content lands, the same slot becomes a real
//  row and gains all three.
//
//  ---------------------------------------------------------------------------
//  ⚠️ VISUALLY QUIETER THAN A REAL ROW, NEVER BROKEN-LOOKING
//  ---------------------------------------------------------------------------
//
//  Dashed borders, grey blocks and "under construction" styling make a screen
//  look abandoned. This is the same card as a live row at lower contrast: same
//  size, same radius, same rhythm — so the section keeps its shape and the eye
//  reads a coherent list with one item not yet arrived.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../theme/pv_fonts.dart';
import '../../v2/v2_palette.dart';
import 'hub_config.dart';

class HubPlaceholder extends StatelessWidget {
  const HubPlaceholder({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.p,
    required this.lang,
    this.kind,
  });

  /// What this will be, named as she would name it.
  final LocalizedText title;

  /// ⚠️ REQUIRED — §7. One sentence on what it will do for her.
  final LocalizedText value;

  final SlotStatus status;
  final LocalizedText? kind;
  final V2Palette p;
  final AppLanguage lang;

  /// "Video coming soon" · "Tool coming soon" · "Coming soon".
  ///
  /// Derived from the status when the config does not name a kind, so a slot
  /// author cannot forget it — and so the wording stays consistent across
  /// forty hubs rather than becoming forty phrasings.
  String _chip() {
    if (kind != null) {
      return lang.isEnglish
          ? '${kind!.en} coming soon'
          : '${kind!.hi} जल्द आ रहा है';
    }
    return switch (status) {
      SlotStatus.newTool =>
        lang.isEnglish ? 'Tool coming soon' : 'Tool जल्द आ रहा है',
      SlotStatus.newSupply =>
        lang.isEnglish ? 'Coming soon' : 'जल्द आ रहा है',
      _ => lang.isEnglish ? 'Coming soon' : 'जल्द आ रहा है',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        // `surfaceAlt`, not `surface`: a shade back from the live rows beside
        // it, without a dashed border or any other "broken" signal.
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.of(lang),
            style: pvFraunces(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: -0.3,
                color: p.ink2)),
        const SizedBox(height: 5),
        Text(value.of(lang),
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: p.ink3.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(_chip().toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
        ),
      ]),
    );
  }
}
