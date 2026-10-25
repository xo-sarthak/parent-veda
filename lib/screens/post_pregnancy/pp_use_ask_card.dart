// =============================================================================
//  The "may we use this?" card (tools pass T0, 2026-10-25)
// -----------------------------------------------------------------------------
//  Shown once per kind of information, on the tool that collected it, after
//  the first save, until she answers. Two buttons and one line of why. Her
//  answer lives in PpUseConsent and can be changed in You › Data and privacy.
//  Mobbin: Flo's "you're always in control" consent line, a plain question
//  with the reason beside it rather than a settings toggle she has to find.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pp_use_consent.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show PvCommit, PvSecondary;
import '../v2/v2_palette.dart';
import 'pp_care_parts.dart' show ppCareSaved;

class PpUseAskCard extends StatelessWidget {
  const PpUseAskCard({super.key, required this.kind, required this.question});
  final PpUseKind kind;

  /// The question in this tool's words, e.g. "Use your feed log to suggest pages?"
  final String question;

  @override
  Widget build(BuildContext context) {
    final consent = PpUseConsent.instance;
    return ListenableBuilder(
      listenable: consent,
      builder: (context, _) {
        if (!consent.unasked(kind)) return const SizedBox.shrink();
        final p = V2PaletteStore.instance.current;
        return Container(
          key: ValueKey('pp_use_ask_${kind.name}'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(question, style: pvManrope(fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
            const SizedBox(height: 6),
            Text(kind.why, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            const SizedBox(height: 4),
            Text('You can change this any time in You › Data and privacy.',
                style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
            const SizedBox(height: 14),
            PvCommit(
              key: ValueKey('pp_use_yes_${kind.name}'),
              label: 'Yes, use it',
              onTap: () {
                consent.set(kind, true);
                ppCareSaved(context, 'Thank you. ${kind.label} now helps choose what you see first.');
              },
            ),
            const SizedBox(height: 8),
            PvSecondary(
              key: ValueKey('pp_use_no_${kind.name}'),
              label: 'Not now',
              onTap: () {
                consent.set(kind, false);
                ppCareSaved(context, 'Okay. ${kind.label} stays in this tool only.');
              },
            ),
          ]),
        );
      },
    );
  }
}
