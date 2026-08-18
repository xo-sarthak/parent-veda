// =============================================================================
//  GroundPicker — four whites, on the phone, once
// -----------------------------------------------------------------------------
//  ⚠️ SANDBOX CHROME. It goes the moment one of the four wins, and the winner
//  becomes `_baseline` in v2_palette.dart.
//
//  It replaces the two toggles that used to float here (Classic|Focus|V3 and
//  Rendered|Drawn), both of which had served their purpose and were clipping
//  the door labels behind them. One question at a time on the screen.
//
//  It sits BOTTOM-LEFT because bottom-right belongs to the Ask FAB, and it is
//  deliberately the plainest control in the app: this is a question about the
//  page, so the control must not be the loudest thing on it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

class GroundPicker extends StatelessWidget {
  const GroundPicker({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final store = V2PaletteStore.instance;
          final p = store.current;

          Widget seg(GroundOption g) {
            final on = store.ground == g;
            final spec = kGrounds[g]!;
            return InkWell(
              onTap: () => store.setGround(g),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: on ? p.ink1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  // A swatch of the actual ground, so the control shows the
                  // thing rather than describing it.
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: spec.ground,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: on
                              ? Colors.white24
                              : const Color(0x33000000),
                          width: 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(spec.label,
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                          color: on ? Colors.white : p.ink2)),
                ]),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
              boxShadow: [
                BoxShadow(
                  // Tinted to the ground, never black.
                  color: const Color(0xFFD0C8DC).withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (final g in GroundOption.values) seg(g),
            ]),
          );
        },
      );
}
