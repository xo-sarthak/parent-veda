// =============================================================================
//  TTC - "What is this?" sheets
// -----------------------------------------------------------------------------
//  2026-09-30, the user: "we should be giving a good looking i button that
//  actually explains what is your cycle report, what is your cycle
//  companion… it should not feel like a text thrown at them, not a big text
//  blob." And: "we need to be very strict with the wordings… so that the user
//  knows what to click upon, when to see what."
//
//  So each ⓘ opens the same small sheet: the screen's one name, three short
//  lines each with its own mark (what it shows, where it comes from, what to
//  do), the quiet disclaimer last and small, and one button to the other
//  screen by its exact name. Three lines, never a paragraph: a line she can
//  read in a glance is a line she reads.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'ttc_common.dart';
import 'ttc_surface_router.dart' show openTtcSurface;

/// The one name for each screen, used on its header, its ⓘ and every link.
const String kTtcCycleCompanionName = 'Cycle companion';
const String kTtcCycleReportName = 'Cycle report';

class TtcWhatIsLine {
  const TtcWhatIsLine(this.icon, this.text);
  final IconData icon;
  final String text;
}

class TtcWhatIs {
  const TtcWhatIs({
    required this.title,
    required this.lines,
    required this.note,
    this.linkLabel,
    this.linkSurface,
    this.contentKey,
  });

  final String title;
  final List<TtcWhatIsLine> lines;
  final String note;
  final String? linkLabel;
  final String? linkSurface;
  final Key? contentKey;
}

const TtcWhatIs kTtcWhatIsCompanion = TtcWhatIs(
  title: 'What is the $kTtcCycleCompanionName?',
  lines: [
    TtcWhatIsLine(Icons.water_drop_outlined,
        'It keeps your period dates. Add, change or remove them here.'),
    TtcWhatIsLine(Icons.today_outlined,
        'It counts your cycle day and shows where you are in your cycle.'),
    TtcWhatIsLine(Icons.trending_up_rounded,
        'The more periods you log, the better its estimates get.'),
  ],
  note: 'Estimates come from your own dates. They are never a diagnosis.',
  linkLabel: 'Open your cycle report',
  linkSurface: 'ttc_cycle_report',
);

TtcWhatIs ttcWhatIsReport({required String note}) => TtcWhatIs(
      title: 'What is the $kTtcCycleReportName?',
      lines: const [
        TtcWhatIsLine(Icons.donut_large_rounded,
            'One whole cycle, start to finish, in four parts.'),
        TtcWhatIsLine(Icons.swap_horiz_rounded,
            'The arrows at the top step back to earlier cycles.'),
        TtcWhatIsLine(Icons.event_available_outlined,
            'It needs two periods logged before the parts can show.'),
      ],
      note: note,
      linkLabel: 'Open your cycle companion',
      linkSurface: 'ttc_cycle',
      contentKey: const ValueKey('ttc_report_about'),
    );

/// The ⓘ button every one of these screens puts in its header.
class TtcWhatIsButton extends StatelessWidget {
  const TtcWhatIsButton({super.key, required this.what, this.color});

  final TtcWhatIs what;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
        key: const ValueKey('ttc_what_is_this'),
        icon: const Icon(Icons.info_outline_rounded, size: 21),
        color: color ?? ttcInk,
        tooltip: what.title,
        // The default 48-point target made the Cycle companion's header 8
        // points too tall at 360 (a test caught it, 2026-10-01). The back
        // arrow beside it is 38.
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 38),
        // Material 3 buttons take their size from the style, not `constraints`.
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(40, 38),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => showTtcWhatIs(context, what),
      );
}

Future<void> showTtcWhatIs(BuildContext context, TtcWhatIs what) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'ttc/what_is_this'),
      builder: (sheet) => SafeArea(
        top: false,
        child: Container(
          key: what.contentKey,
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ttcLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(what.title,
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: ttcTitleInk)),
              const SizedBox(height: 16),
              for (final l in what.lines) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ttcLine),
                    ),
                    child: Icon(l.icon, size: 17, color: ttcTitleInk),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(l.text,
                          style: ttcBody(14,
                              color: ttcTitleInk, h: 1.4, w: FontWeight.w600)),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 2),
              Text(what.note, style: ttcBody(12, color: ttcSoft, h: 1.45)),
              if (what.linkLabel != null && what.linkSurface != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: ttcTitleInk,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      key: const ValueKey('ttc_what_is_link'),
                      customBorder: const StadiumBorder(),
                      onTap: () {
                        Navigator.of(sheet).pop();
                        openTtcSurface(context, what.linkSurface!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(what.linkLabel!,
                              style: ttcBody(14,
                                  color: Colors.white, w: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

// =============================================================================
//  The home hero's tools row (2026-09-30)
// -----------------------------------------------------------------------------
//  The user: "the cycle companion is not at all visible anywhere… just that
//  click [the dates pill] which is not even indicating that it's a cycle
//  companion", and the cycle report sat at the far end of the insight rail.
//  So under the hero's dates: the two tools by their one name each, and the
//  ⓘ that says what the Today screen holds. A new user sees all three
//  without scrolling.
// =============================================================================

const TtcWhatIs kTtcWhatIsToday = TtcWhatIs(
  title: 'What is on your Today screen?',
  lines: [
    TtcWhatIsLine(Icons.wb_sunny_outlined,
        'The big line says where you are in your cycle today.'),
    TtcWhatIsLine(Icons.loop_rounded,
        '$kTtcCycleCompanionName keeps your period dates and counts your days.'),
    TtcWhatIsLine(Icons.donut_large_rounded,
        '$kTtcCycleReportName shows one whole cycle in four parts.'),
    TtcWhatIsLine(Icons.touch_app_outlined,
        'The four round buttons log a period, symptoms, sex or a test.'),
  ],
  note: 'Everything here comes from the dates you log. It is never a '
      'diagnosis.',
  linkLabel: 'Open your cycle companion',
  linkSurface: 'ttc_cycle',
);

/// ⚠️ NOT ON THE HOME SINCE THE SAME DAY (2026-09-30, the user: "seems very
/// cluttered… remove those two pill buttons"). The insights rail carries the
/// two tools and the hero's dates pill names the companion. Kept for revert;
/// nothing builds it now.
class TtcHeroToolsRow extends StatelessWidget {
  const TtcHeroToolsRow({super.key, required this.onCompanion});

  /// The hero's own way into the companion, so both doors are one door.
  final VoidCallback onCompanion;

  @override
  Widget build(BuildContext context) => Row(children: [
        Flexible(
          child: _ToolPill(
            key: const ValueKey('ttc_hero_companion'),
            icon: Icons.water_drop_outlined,
            label: kTtcCycleCompanionName,
            onTap: onCompanion,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ToolPill(
            key: const ValueKey('ttc_hero_report'),
            icon: Icons.donut_large_rounded,
            label: kTtcCycleReportName,
            onTap: () => openTtcSurface(context, 'ttc_cycle_report'),
          ),
        ),
        const SizedBox(width: 4),
        Material(
          color: Colors.white.withValues(alpha: 0.72),
          shape: const CircleBorder(side: BorderSide(color: ttcLine)),
          child: InkWell(
            key: const ValueKey('ttc_hero_what_is'),
            customBorder: const CircleBorder(),
            onTap: () => showTtcWhatIs(context, kTtcWhatIsToday),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.info_outline_rounded,
                  size: 19, color: ttcTitleInk),
            ),
          ),
        ),
      ]);
}

class _ToolPill extends StatelessWidget {
  const _ToolPill(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Open your ${label.toLowerCase()}',
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: Colors.white.withValues(alpha: 0.72),
          shape: const StadiumBorder(side: BorderSide(color: ttcLine)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 38),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 0, 8, 0),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 16, color: ttcTitleInk),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ttcBody(13,
                            color: ttcTitleInk, w: FontWeight.w800)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 17, color: ttcTitleInk),
                ]),
              ),
            ),
          ),
        ),
      );
}
