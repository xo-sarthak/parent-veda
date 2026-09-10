// =============================================================================
//  Signs to get help the same day
// -----------------------------------------------------------------------------
//  What "See all of these" opens from the Complications door's pinned flag.
//
//  ⚠️ IT IS THE SAME FIVE LINES, WITH ROOM. The pinned flag on the tab is
//  deliberately compact — it has to fit above the rails without pushing them
//  off the screen. This is the version with the condition each line came from
//  named on it, so she can see WHY a line is on the list and go straight to the
//  page it was assembled from.
//
//  ⚠️ NOT A SIXTH LIST. Both render `kSameDaySigns`; there is no copy here and
//  no line this screen carries that the flag does not. The brief's rule for
//  this surface is assemble-only, and adding a line at the screen level would
//  be authoring one where nobody would look for it.
//
//  ⚠️ AND IT NEVER SAYS "WAIT". Every row ends at a phone call or a page that
//  ends at one. The footer says out loud that a list cannot be exhaustive —
//  *"if something feels wrong and it is not on this list, call anyway"* — which
//  is the one sentence that stops a list of five becoming a permission slip to
//  ignore a sixth thing.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/conditions_data.dart';
import '../../localization/app_language.dart';
import '../../data/same_day_signs_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../conditions/condition_detail_screen.dart';
import '../doors/pv_door_chrome.dart';
import '../v2/v2_palette.dart';

/// The complications bracket's hue.
const double _hue = 186;

class SameDaySignsScreen extends StatelessWidget {
  const SameDaySignsScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  void _open(BuildContext context, String conditionId) {
    ConditionEntry? entry;
    for (final e in kAllConditions) {
      if (e.id == conditionId) entry = e;
    }
    if (entry == null) return; // the wiring test makes this unreachable
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'conditions/$conditionId'),
      builder: (_) => ConditionDetailScreen(entry: entry!, pregnancy: pregnancy),
    ));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final lang = pregnancy.language;

          return PvDoorToolScaffold(
            hue: _hue,
            eyebrow: 'Get help now',
            title: 'Signs to get help the same day',
            intro: 'Five things that mean today rather than your next '
                'appointment. Each one opens the page it comes from.',
            children: [
              for (final s in kSameDaySigns) ...[
                pvDoorPad(_SignRow(
                  sign: s,
                  p: p,
                  // ⚠️ THE PLAIN LINE OF THE CONDITION IT CAME FROM, NOT ITS
                  // NAME. The brief forbids a bare medical word on a red-flag
                  // line, and that holds for the label under one too: "the
                  // placenta is sitting low" belongs here and "placenta previa"
                  // belongs on the page.
                  from: _plainLineFor(s.because)?.of(lang),
                  onTap: () => _open(context, s.conditionId),
                )),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              pvDoorPad(Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPvUrgentTint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(kSameDayFooter,
                    style: pvManrope(
                        fontSize: 13.5, height: 1.6, color: p.ink1)),
              )),
              const SizedBox(height: 22),
              pvDoorPad(PvDoorDisclaimer(p: p)),
            ],
          );
        },
      );
}

/// The plain line of the condition a sign was assembled from, or null.
///
/// ⚠️ NULL IS UNREACHABLE FROM ANYTHING THAT SHIPS — every `because` in
/// `kSameDaySigns` is asserted against `kAllConditions` by
/// `test/pv_door_complications_test.dart`. It is nullable rather than `!` so a
/// bad id renders one row without its source line instead of crashing a safety
/// screen.
LocalizedText? _plainLineFor(String conditionId) {
  for (final e in kAllConditions) {
    if (e.id == conditionId) return e.plainLine;
  }
  return null;
}

class _SignRow extends StatelessWidget {
  const _SignRow({
    required this.sign,
    required this.p,
    required this.from,
    required this.onTap,
  });

  final SameDaySign sign;
  final V2Palette p;
  final String? from;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: PvDoorCard(
          p: p,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: kPvUrgentInk, shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sign.line,
                      style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  if (from != null) ...[
                    const SizedBox(height: 6),
                    Text('Read about it — $from',
                        style: pvManrope(
                            fontSize: 12, height: 1.45, color: p.ink3)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      );
}
