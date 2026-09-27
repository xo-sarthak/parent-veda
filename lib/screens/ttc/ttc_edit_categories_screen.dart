// =============================================================================
//  TtcEditCategoriesScreen — which categories she wants to see
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE "EDIT" SHIPPED AS A LABEL THAT DID NOTHING.
//
//  The logger had an "Edit" beside the Categories heading — coral, borrowed
//  straight off the reference — and tapping it did nothing at all. That is
//  worse than not having it: a control styled as a control that does not
//  respond teaches the reader that taps in this app are unreliable, and she
//  carries that lesson to every other tap on the screen.
//
//  So either the affordance goes or it works. It works.
//
//  ---------------------------------------------------------------------------
//  ⚠️ HIDING, NOT DELETING
//  ---------------------------------------------------------------------------
//
//  Turning a category off removes it from the logging screen and nothing else.
//  Days already logged against it are untouched, still counted in the report,
//  still on the calendar — because the alternative is a settings toggle that
//  silently destroys data, which is the single worst thing a preference can do.
//
//  Turning it back on brings the old entries back into view with it. Nothing
//  was ever removed; it simply was not being drawn.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ttc/ttc_symptom_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_symptom_mark.dart';
import 'ttc_tool_chrome.dart';

/// The page's title, and the logger's link to it: one name for one thing.
const String kTtcEditCategoriesTitle = 'Show or hide';

/// Which categories the logger draws.
///
/// ⚠️ LOCAL, NOT SYNCED, AND THAT IS THE RIGHT SCOPE. This is "what I want on
/// my logging screen", which is a preference about a surface rather than a fact
/// about the family — the same reading the launch promo and the intro gate take.
class TtcCategoryPrefs extends ChangeNotifier {
  TtcCategoryPrefs._();
  static final TtcCategoryPrefs instance = TtcCategoryPrefs._();

  static const _key = 'ttc_hidden_symptom_categories';

  final Set<String> _hidden = {};
  bool _loaded = false;

  Set<String> get hidden => Set.unmodifiable(_hidden);

  bool isHidden(String id) => _hidden.contains(id);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final p = await SharedPreferences.getInstance();
    _hidden
      ..clear()
      ..addAll(p.getStringList(_key) ?? const []);
    notifyListeners();
  }

  Future<void> setHidden(String id, bool hidden) async {
    if (hidden) {
      // ⚠️ NEVER ALL OF THEM. A logger with every category off is a screen with
      // nothing on it and no obvious way back — the reader would have to guess
      // that "Edit" is where her app went.
      if (_hidden.length >= kTtcCategoryGroups.length - 1) return;
      _hidden.add(id);
    } else {
      _hidden.remove(id);
    }
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, _hidden.toList());
  }

  void resetForTest() {
    _hidden.clear();
    _loaded = false;
  }
}

class TtcEditCategoriesScreen extends StatefulWidget {
  const TtcEditCategoriesScreen({super.key});

  @override
  State<TtcEditCategoriesScreen> createState() =>
      _TtcEditCategoriesScreenState();
}

class _TtcEditCategoriesScreenState extends State<TtcEditCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    TtcCategoryPrefs.instance.load();
  }

  // ⚠️ REBUILT INTO THE TOOL SHELL (tool rebuild, 2026-09-27, night). It was
  // a plain page with a back bar and a list of bare switches whose names were
  // all it said: "The rest of the day" gave no clue what was in it, and the
  // one switch that would not turn off (the last card on) said nothing about
  // why. Clue's "Customize tracking" is the shape: a mark per category, a
  // switch, and one line on what the page does
  // (https://mobbin.com/screens/3325e5ac-e4d3-455e-9965-e302b2f620a4).
  // Now each row names what is in the card, a locked row says why, and "Show
  // all" puts every card back in one tap.
  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();

    return AnimatedBuilder(
      animation: TtcCategoryPrefs.instance,
      builder: (context, _) {
        final prefs = TtcCategoryPrefs.instance;
        final onlyOneLeft =
            prefs.hidden.length >= kTtcCategoryGroups.length - 1;
        final groups = kTtcCategoryGroups;

        return TtcToolScaffold(
          hue: 172,
          variant: 4,
          // The logger's own name, so she knows where she is.
          eyebrow: 'Symptoms and mood',
          // The same words as the link that opens it.
          title: kTtcEditCategoriesTitle,
          intro: t.editCategoriesBody,
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ttcLine),
                  ),
                  child: Column(children: [
                    for (var i = 0; i < groups.length; i++) ...[
                      _Row(
                        group: groups[i],
                        on: !prefs.isHidden(groups[i].id),
                        // The last visible one cannot be switched off.
                        locked: onlyOneLeft && !prefs.isHidden(groups[i].id),
                        onChanged: (v) =>
                            prefs.setHidden(groups[i].id, !v),
                      ),
                      if (i != groups.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 64),
                          child: ttcDivider(),
                        ),
                    ],
                  ]),
                ),
                if (prefs.hidden.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  TtcToolSecondary(
                    key: const ValueKey('ttc_categories_show_all'),
                    label: kTtcCategoriesShowAll,
                    onTap: () {
                      for (final id in prefs.hidden.toList()) {
                        prefs.setHidden(id, false);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Text(t.editCategoriesKeeps,
                    style: ttcBody(12, color: ttcMuted, h: 1.5)),
              ],
            )),
          ],
        );
      },
    );
  }

  // Kept for revert (2026-09-27, tool rebuild): the plain page with a back
  // bar and bare switches.
  // @override
  // Widget build(BuildContext context) {
  //   final t = TtcS.current();
  //
  //   return AnimatedBuilder(
  //     animation: TtcCategoryPrefs.instance,
  //     builder: (context, _) {
  //       final prefs = TtcCategoryPrefs.instance;
  //       final onlyOneLeft =
  //           prefs.hidden.length >= kTtcCategoryGroups.length - 1;
  //
  //       return Scaffold(
  //         backgroundColor: ttcBg,
  //         body: SafeArea(
  //           child: ListView(
  //             padding: const EdgeInsets.fromLTRB(
  //                 ttcGutter, 8, ttcGutter, ttcBottomInset),
  //             children: [
  //               // The same words as the link that opens it (tools pass,
  //               // 2026-09-27). Kept for revert: title: t.editCategoriesTitle.
  //               TtcBackBar(title: kTtcEditCategoriesTitle),
  //               const SizedBox(height: 10),
  //               Text(t.editCategoriesBody,
  //                   style: ttcBody(13.5, color: ttcSoft, h: 1.55)),
  //               const SizedBox(height: 20),
  //
  //               Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(ttcCardRadius),
  //                 ),
  //                 child: Column(children: [
  //                   for (var i = 0; i < kTtcCategoryGroups.length; i++) ...[
  //                     _Row(
  //                       group: kTtcCategoryGroups[i],
  //                       on: !prefs.isHidden(kTtcCategoryGroups[i].id),
  //                       // The last visible one cannot be switched off.
  //                       locked: onlyOneLeft &&
  //                           !prefs.isHidden(kTtcCategoryGroups[i].id),
  //                       onChanged: (v) => prefs.setHidden(
  //                           kTtcCategoryGroups[i].id, !v),
  //                     ),
  //                     if (i != kTtcCategoryGroups.length - 1)
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 16),
  //                         child: ttcDivider(),
  //                       ),
  //                   ],
  //                 ]),
  //               ),
  //               const SizedBox(height: 16),
  //               Text(t.editCategoriesKeeps,
  //                   style: ttcBody(12, color: ttcMuted, h: 1.5)),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}

/// "Show all", under the list, when anything is hidden.
const String kTtcCategoriesShowAll = 'Show all';

/// Under a row whose switch will not turn off.
const String kTtcCategoriesKeepOne = 'Keep at least one on';

/// "Cramping, Sore breasts, Headache and 9 more": what a card holds, so a
/// name like "The rest of the day" is not all she has to go on.
String ttcCategorySample(TtcSymptomGroup g) {
  final names = [for (final s in g.symptoms.take(3)) s.label];
  final more = g.symptoms.length - names.length;
  return more > 0 ? '${names.join(', ')} and $more more' : names.join(', ');
}

// Kept for revert (2026-09-27, tool rebuild): the row was the card's name and
// a switch, and a locked switch said nothing about why.
// class _Row extends StatelessWidget {
//   const _Row({required this.group, required this.on, required this.locked,
//       required this.onChanged});
//   ...
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.fromLTRB(16, 4, 10, 4),
//         child: Row(children: [
//           Expanded(child: Text(group.title, style: ttcBody(14.5, color: ttcInk))),
//           Switch(value: on, activeThumbColor: Colors.white,
//               activeTrackColor: ttcPurple, inactiveTrackColor: ttcPanel,
//               onChanged: locked ? null : onChanged),
//         ]),
//       );
// }
class _Row extends StatelessWidget {
  const _Row({
    required this.group,
    required this.on,
    required this.locked,
    required this.onChanged,
  });

  final TtcSymptomGroup group;
  final bool on;
  final bool locked;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(group.hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.5)
        .withLightness(0.40)
        .toColor();
    return Padding(
      key: ValueKey('ttc_category_row_${group.id}'),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(children: [
        // The card's own colour and its first chip's mark, so a row here
        // looks like the card it switches.
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: group.symptoms.isEmpty
              ? null
              : TtcSymptomMark(
                  symptom: group.symptoms.first, size: 18, ink: deep),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.title,
                    style: ttcBody(14.5,
                        color: ttcTitleInk, w: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    locked
                        ? kTtcCategoriesKeepOne
                        : ttcCategorySample(group),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(12, color: ttcMuted, h: 1.35)),
              ]),
        ),
        Switch(
          value: on,
          // Purple, because a switch is the interactive thing in its row and
          // that is what purple is for here.
          activeThumbColor: Colors.white,
          activeTrackColor: ttcPurple,
          inactiveTrackColor: ttcPanel,
          onChanged: locked ? null : onChanged,
        ),
      ]),
    );
  }
}
