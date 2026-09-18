// =============================================================================
//  Talk to someone — the safety off-ramp, at the foot of every child screen
// -----------------------------------------------------------------------------
//  The Feelings brief: "Talk to someone: a trusted adult and a real child
//  helpline, always one tap away … a first-class, always-present 'talk to
//  someone' … not buried, present on every screen of this door." And:
//  "Ask-for-help is a skill, not an alarm … the off-ramp to real help is
//  always right there, framed as normal, before anything is ever wrong."
//
//  So this is a calm bar, not a red button. It sits at the foot of the
//  door, every activity, every lesson page, the journal and the keepsake —
//  any child screen whose door content carries an `SkSafety`. Doors without
//  one draw nothing (`skSafetyBarFor` returns null).
//
//  ⚠️ UNGATED, ON PURPOSE, ON THE RECORD. Every other link off a child
//  screen sits behind the grown-up check. This one does not: the child who
//  needs a helpline may be the child who cannot ask a parent first. The
//  user's call (2026-09-18, 4a). It is the only `tel:` in the skilling tree
//  and the only `launchUrl` outside `skAskGrownUp`; the sanity test holds
//  that.
//
//  ⚠️ NOTHING IS WRITTEN DOWN. Opening the sheet records nothing, anywhere.
//  A child asking for help must never leave a trace she did not choose.
//
//  ⚠️ THE NUMBERS ARE FLAGGED VERIFY. Childline 1098 and Tele-MANAS 14416
//  are real Indian helplines as of writing; a lawyer and a clinician confirm
//  the numbers and the wording before anything ships (the user's call, 2a).
//  The stage is behind `kDebugMode`; nothing reaches a child yet.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_door_content.dart';

/// The bar for a door, or null for a door with no off-ramp. Every child
/// Scaffold in the skilling tree passes this as its `bottomNavigationBar`.
Widget? skSafetyBarFor(String doorId) {
  final safety = skDoorContentFor(doorId)?.safety;
  if (safety == null) return null;
  return SkTalkToSomeoneBar(safety: safety);
}

class SkTalkToSomeoneBar extends StatelessWidget {
  const SkTalkToSomeoneBar({super.key, required this.safety});
  final SkSafety safety;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          return Material(
            color: p.surface,
            child: SafeArea(
              top: false,
              child: InkWell(
                key: const Key('sk-talk-to-someone'),
                onTap: () => skShowTalkToSomeone(context, safety),
                child: Container(
                  height: kSkTap,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: Row(children: [
                    Icon(Icons.favorite_border_rounded, size: 22, color: p.action),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Talk to someone',
                          style: pvManrope(
                              fontSize: kSkButtonSize,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ),
                    Text('Always okay',
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink3)),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
                  ]),
                ),
              ),
            ),
          );
        },
      );
}

/// The sheet: the trusted-adult line first, then each helpline with a
/// tap-to-call. In a release build a helpline still marked `verify` is not
/// shown at all — a wrong number is worse than none.
Future<void> skShowTalkToSomeone(BuildContext context, SkSafety safety) {
  final p = V2PaletteStore.instance.current;
  const release = bool.fromEnvironment('dart.vm.product');
  final lines = [
    for (final h in safety.helplines)
      if (!release || !h.verify) h,
  ];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Talk to someone',
                style: pvFraunces(
                    fontSize: kSkTitleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(safety.trustedAdultLine,
                style: pvManrope(
                    fontSize: kSkLeadSize,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink1)),
            const SizedBox(height: 18),
            for (final h in lines) ...[
              _HelplineRow(h: h, p: p),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            Text('Asking for help is a normal thing to do. Nothing you say '
                'here is written down.',
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: p.ink3)),
          ],
        ),
      ),
    ),
  );
}

class _HelplineRow extends StatelessWidget {
  const _HelplineRow({required this.h, required this.p});
  final SkHelpline h;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Material(
        color: p.ground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: Key('sk-helpline-${h.number}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // The ungated way out. Nothing recorded.
            try {
              await launchUrl(Uri(scheme: 'tel', path: h.number));
            } catch (_) {}
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: kSkTap),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(Icons.call_rounded, size: 22, color: p.action),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${h.name}  ·  ${h.number}',
                          style: pvManrope(
                              fontSize: kSkBodySize,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                      const SizedBox(height: 2),
                      Text(h.note,
                          style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: p.ink2)),
                    ]),
              ),
            ]),
          ),
        ),
      );
}
