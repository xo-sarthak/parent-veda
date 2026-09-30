// =============================================================================
//  DeveloperSwitches — the three home-version pills, moved off the homes
// -----------------------------------------------------------------------------
//  V3 is final (2026-09-16) and the default (2026-09-17). The Classic / V3
//  pills that sat on each home were reviewer controls; a final screen should
//  not carry a switch (BASE-UI-DECISIONS §2.2, the user chose "move it into
//  Profile → Developer"). This is that section: three rows, one per stage,
//  reading the same session-only stores the pills read. Nothing is persisted,
//  exactly as before — every launch starts on V3.
//
//  The pills' own widgets stay in their files, commented at the mount, kept
//  for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/pv_fonts.dart';
import 'post_pregnancy/pp_home_version.dart';
import 'today_home_screen.dart' show TodayVersion, TodayVersionStore;
import 'ttc/ttc_home_version.dart';
import 'v2/v2_palette.dart';

class DeveloperSwitches extends StatelessWidget {
  const DeveloperSwitches({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TodayVersionStore.instance,
        PpHomeVersionStore.instance,
        TtcHomeVersionStore.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line, width: 1.2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DEVELOPER',
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: p.ink1.withValues(alpha: 0.85))),
            const SizedBox(height: 4),
            Text('Home versions. V3 is what ships; the others are kept for comparison and reset on every launch.',
                style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
            const SizedBox(height: 12),
            _row(p, 'Pregnancy home', [
              ('Classic', TodayVersionStore.instance.version == TodayVersion.classic,
                  () => TodayVersionStore.instance.set(TodayVersion.classic)),
              ('V3', TodayVersionStore.instance.version == TodayVersion.v3,
                  () => TodayVersionStore.instance.set(TodayVersion.v3)),
            ]),
            const SizedBox(height: 8),
            _row(p, 'Parenting home', [
              ('Current', PpHomeVersionStore.instance.version == PpHomeVersion.v1,
                  () => PpHomeVersionStore.instance.set(PpHomeVersion.v1)),
              ('V3', PpHomeVersionStore.instance.version == PpHomeVersion.v3,
                  () => PpHomeVersionStore.instance.set(PpHomeVersion.v3)),
            ]),
            const SizedBox(height: 8),
            _row(p, 'Trying home', [
              ('V1', TtcHomeVersionStore.instance.version == TtcHomeVersion.v1,
                  () => TtcHomeVersionStore.instance.set(TtcHomeVersion.v1)),
              ('V3', TtcHomeVersionStore.instance.version == TtcHomeVersion.v3,
                  () => TtcHomeVersionStore.instance.set(TtcHomeVersion.v3)),
            ]),
          ]),
        );
      },
    );
  }

  Widget _row(V2Palette p, String label, List<(String, bool, VoidCallback)> segs) {
    return Row(children: [
      Expanded(
        child: Text(label, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink1)),
      ),
      for (final s in segs) ...[
        InkWell(
          onTap: s.$3,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.$2 ? p.ink1 : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: s.$2 ? p.ink1 : p.line, width: 1.2),
            ),
            child: Text(s.$1,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: s.$2 ? p.surface : p.ink2)),
          ),
        ),
        const SizedBox(width: 6),
      ],
    ]);
  }
}
