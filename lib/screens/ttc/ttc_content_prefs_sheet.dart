// =============================================================================
//  "What you see" - the one TTC content switch, as a small sheet
// -----------------------------------------------------------------------------
//  Added 2026-09-26 (gap analysis, "Behind: Settings", P2). Many phones in
//  India are shared with family. One switch, "Hide sex and intimacy content",
//  leaves out the Sex and closeness tab, the intimacy reads in Learn and on
//  the home, and the closeness card on the daily rail. Timing information is
//  never hidden: it is not the private part, and it is what she came for.
//
//  ⚠️ A SHEET, NOT A NEW ROW TYPE ON THE YOU SCREEN. `PvYouScreen` is shared by
//  every stage and its skeleton is pinned by `test/pv_you_test.dart`; its data
//  model has no switch row. So the TTC "Your things" list gains one row that
//  opens this sheet, which is additive and touches no other stage.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../v2/v2_palette.dart';

const String kTtcWhatYouSee = 'What you see';
const String kTtcHideIntimate = 'Hide sex and intimacy content';
const String kTtcHideIntimateLine =
    'Useful on a shared phone. Timing information stays. Only the more '
    'personal pieces are hidden.';

Future<void> showTtcContentPrefsSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const TtcContentPrefsSheet(),
    );

class TtcContentPrefsSheet extends StatelessWidget {
  const TtcContentPrefsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return ListenableBuilder(
      listenable: TtcContentPrefs.instance,
      // A `Material`, not a decorated `Container`: the switch row is a
      // `ListTile`, which paints its ink on the nearest Material, and a
      // coloured box in between would hide the ripple.
      builder: (context, _) => Material(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 16, 22),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kTtcWhatYouSee,
                      style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: p.ink1)),
                  const SizedBox(height: 14),
                  // The one TTC switch row, shared with Messages
                  // (2026-09-26, review M3 and Q2). Kept for revert: a
                  // SwitchListTile.adaptive built here with the same words.
                  TtcSwitchRow(
                    key: const ValueKey('ttc_hide_intimate_switch'),
                    title: kTtcHideIntimate,
                    sub: kTtcHideIntimateLine,
                    value: TtcContentPrefs.instance.hideIntimate,
                    onChanged: TtcContentPrefs.instance.setHideIntimate,
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

/// THE settings switch on the TTC side (2026-09-26, review M3 and Q2): the
/// theme's adaptive switch with its own colours, a bold title and one line
/// saying what it does, and the whole row tappable. Messages and this sheet
/// used two styles (an ink-track Material switch, and this tile); both use
/// this now, so a switch looks and behaves the same wherever she meets one.
///
/// Mobbin: Shop and Polarsteps notification settings, a title, one grey line
/// on when it arrives, a switch at the right
/// (https://mobbin.com/screens/78faace6-eebb-4d4e-a8f4-7dd4b9b3e75f,
/// https://mobbin.com/screens/e4147f7a-cf1f-42d1-98a0-ce6784cab8bb).
class TtcSwitchRow extends StatelessWidget {
  const TtcSwitchRow({
    super.key,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    // A Material of its own, so the tile's ripple shows on any ground.
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title,
            style: pvManrope(
                fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(sub,
              style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
        ),
      ),
    );
  }
}
