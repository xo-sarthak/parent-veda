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
import 'ttc_common.dart';
import 'ttc_strings.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();

    return AnimatedBuilder(
      animation: TtcCategoryPrefs.instance,
      builder: (context, _) {
        final prefs = TtcCategoryPrefs.instance;
        final onlyOneLeft =
            prefs.hidden.length >= kTtcCategoryGroups.length - 1;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.editCategoriesTitle),
                const SizedBox(height: 10),
                Text(t.editCategoriesBody,
                    style: ttcBody(13.5, color: ttcSoft, h: 1.55)),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                  ),
                  child: Column(children: [
                    for (var i = 0; i < kTtcCategoryGroups.length; i++) ...[
                      _Row(
                        group: kTtcCategoryGroups[i],
                        on: !prefs.isHidden(kTtcCategoryGroups[i].id),
                        // The last visible one cannot be switched off.
                        locked: onlyOneLeft &&
                            !prefs.isHidden(kTtcCategoryGroups[i].id),
                        onChanged: (v) => prefs.setHidden(
                            kTtcCategoryGroups[i].id, !v),
                      ),
                      if (i != kTtcCategoryGroups.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ttcDivider(),
                        ),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                Text(t.editCategoriesKeeps,
                    style: ttcBody(12, color: ttcMuted, h: 1.5)),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 10, 4),
        child: Row(children: [
          Expanded(child: Text(group.title, style: ttcBody(14.5, color: ttcInk))),
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
