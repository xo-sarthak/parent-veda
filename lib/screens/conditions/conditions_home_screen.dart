// =============================================================================
//  ConditionsHomeScreen — "Understand my condition", entered through a door
// -----------------------------------------------------------------------------
//  Backs the "Understand my condition" need on `kPgComplications` (see
//  `pregnancy_hubs.dart`) and the `kPgActConditionLibrary` action currently
//  wired in `home_v3_screen.dart` to the tests/scans reference screen.
//
//  ⚠️ INTEGRATION NOTE — READ BEFORE WIRING.
//  This file cannot edit `home_v3_screen.dart`, so it exports a top-level
//  `conditionsHomeScreen(pregnancy: ...)` for the integrator to route
//  `kPgActConditionLibrary` to, in place of the current
//  `_openSurfaceScreen(context, 'tests_scans')` call. `pregnancy` is required
//  — the screen needs it for language and to pass through to the medicine
//  reminder tool it can open — so the call site is
//  `conditionsHomeScreen(pregnancy: pregnancy)`, not the zero-argument form.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE DOOR COMES BEFORE ANYTHING ELSE
//  ---------------------------------------------------------------------------
//  "Has your doctor mentioned a condition, or do you just want to learn?" is
//  asked once, persisted, and gates one thing only: whether "Add to my
//  journey" appears on a condition page. A curious visit stays read-only and
//  saves nothing — see `ConditionsStore` in `conditions_data.dart`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ COMPONENTS ARE REUSED, NOT REINVENTED
//  ---------------------------------------------------------------------------
//  Condition tiles are `SolutionCard`s (type `read` — the honest description
//  of what tapping one does) grouped with `SolutionGroup`, both from
//  `hub_solution_cards.dart`. The "see more" toggle and the door buttons reuse
//  `HubPill` from `problem_hub_screen.dart`. Nothing here is a new card
//  family.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/conditions_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../brackets/hub/problem_hub_screen.dart' show HubPill;
import '../v2/v2_palette.dart';
import 'condition_detail_screen.dart';

/// Top-level entry point for the integrator — see the file header.
Widget conditionsHomeScreen({required PregnancyController pregnancy}) =>
    ConditionsHomeScreen(pregnancy: pregnancy);

class ConditionsHomeScreen extends StatefulWidget {
  const ConditionsHomeScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<ConditionsHomeScreen> createState() => _ConditionsHomeScreenState();
}

class _ConditionsHomeScreenState extends State<ConditionsHomeScreen> {
  final _search = TextEditingController();
  bool _seeMore = false;
  bool _showGate = false;

  @override
  void initState() {
    super.initState();
    ConditionsStore.instance.init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCondition(ConditionEntry e) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'conditions/${e.id}'),
      builder: (_) =>
          ConditionDetailScreen(entry: e, pregnancy: widget.pregnancy),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.pregnancy.language;

    return AnimatedBuilder(
      animation: ConditionsStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = ConditionsStore.instance;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(
                const LocalizedText(
                        en: 'Complications & conditions',
                        hi: 'Complications & conditions')
                    .of(lang),
                style: pvJakarta(
                    fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          body: !store.answered || _showGate
              ? _DoorGate(p: p, lang: lang, onAnswered: () {
                  setState(() => _showGate = false);
                })
              : _Browse(
                  p: p,
                  lang: lang,
                  store: store,
                  search: _search,
                  seeMore: _seeMore,
                  onToggleSeeMore: () => setState(() => _seeMore = !_seeMore),
                  onChangeDoor: () => setState(() => _showGate = true),
                  onOpen: _openCondition,
                ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  The two-way door
// -----------------------------------------------------------------------------
//  ⚠️ NOT A DIAGNOSIS PROMPT. It never asks WHAT the condition is here — only
//  whether the visit is diagnosed-real or curiosity. Asking for the condition
//  name at this point would push her toward typing something frightening
//  before she has even seen that the section is calm.
class _DoorGate extends StatelessWidget {
  const _DoorGate({required this.p, required this.lang, required this.onAnswered});
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onAnswered;

  void _choose(ConditionDoorAnswer a) {
    ConditionsStore.instance.setDoor(a);
    onAnswered();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                const LocalizedText(
                        en: 'Has your doctor mentioned a condition, or do '
                            'you just want to learn?',
                        hi: 'Has your doctor mentioned a condition, or do '
                            'you just want to learn?')
                    .of(lang),
                textAlign: TextAlign.center,
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                const LocalizedText(
                        en: 'This only changes whether we offer to add it to '
                            'your journey. Nothing is saved either way '
                            'unless you choose to.',
                        hi: 'This only changes whether we offer to add it to '
                            'your journey. Nothing is saved either way '
                            'unless you choose to.')
                    .of(lang),
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            const SizedBox(height: 26),
            HubPill(
              label: const LocalizedText(
                      en: 'My doctor mentioned something',
                      hi: 'My doctor mentioned something')
                  .of(lang),
              icon: Icons.medical_information_outlined,
              p: p,
              fullWidth: true,
              onTap: () => _choose(ConditionDoorAnswer.diagnosed),
            ),
            const SizedBox(height: 12),
            HubPill(
              label: const LocalizedText(
                      en: 'I just want to understand',
                      hi: 'I just want to understand')
                  .of(lang),
              icon: Icons.menu_book_outlined,
              p: p,
              fullWidth: true,
              onTap: () => _choose(ConditionDoorAnswer.curious),
            ),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  Browse — search, the common 8, the two quiet high-anxiety links, and
//  "see more" grouped behind a toggle
// -----------------------------------------------------------------------------
class _Browse extends StatelessWidget {
  const _Browse({
    required this.p,
    required this.lang,
    required this.store,
    required this.search,
    required this.seeMore,
    required this.onToggleSeeMore,
    required this.onChangeDoor,
    required this.onOpen,
  });

  final V2Palette p;
  final AppLanguage lang;
  final ConditionsStore store;
  final TextEditingController search;
  final bool seeMore;
  final VoidCallback onToggleSeeMore;
  final VoidCallback onChangeDoor;
  final void Function(ConditionEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: search,
      builder: (context, _) {
        final query = search.text.trim();
        final searching = query.isNotEmpty;
        final results =
            searching ? kAllConditions.where((c) => c.matches(query)).toList() : const <ConditionEntry>[];

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 44),
          children: [
            _DoorChip(store: store, p: p, lang: lang, onTap: onChangeDoor),
            const SizedBox(height: 16),
            _SearchField(controller: search, p: p, lang: lang),
            const SizedBox(height: 22),
            if (searching) ...[
              _SearchResults(results: results, p: p, lang: lang, onOpen: onOpen),
            ] else ...[
              SolutionGroup(
                title: ConditionGroup.common.title,
                p: p,
                lang: lang,
                cards: [
                  for (final c in kCommonConditions)
                    SolutionCard(
                      type: SolutionType.read,
                      title: c.name,
                      value: c.reassurance,
                      p: p,
                      lang: lang,
                      onTap: () => onOpen(c),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              SolutionGroup(
                title: ConditionGroup.highAnxiety.title,
                p: p,
                lang: lang,
                cards: [
                  for (final c in kHighAnxietyConditions)
                    SolutionCard(
                      type: SolutionType.read,
                      title: c.name,
                      value: c.reassurance,
                      p: p,
                      lang: lang,
                      onTap: () => onOpen(c),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              HubPill(
                label: seeMore
                    ? const LocalizedText(en: 'See less', hi: 'See less')
                        .of(lang)
                    : const LocalizedText(en: 'See more', hi: 'See more')
                        .of(lang),
                icon: seeMore
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                p: p,
                fullWidth: true,
                onTap: onToggleSeeMore,
              ),
              if (seeMore) ...[
                const SizedBox(height: 22),
                for (final entry in kSeeMoreGroups.entries) ...[
                  SolutionGroup(
                    title: entry.key.title,
                    p: p,
                    lang: lang,
                    cards: [
                      for (final c in entry.value)
                        SolutionCard(
                          type: SolutionType.read,
                          title: c.name,
                          value: c.reassurance,
                          p: p,
                          lang: lang,
                          onTap: () => onOpen(c),
                        ),
                    ],
                  ),
                  if (entry.key != kSeeMoreGroups.keys.last)
                    const SizedBox(height: 22),
                ],
              ],
            ],
          ],
        );
      },
    );
  }
}

class _DoorChip extends StatelessWidget {
  const _DoorChip({required this.store, required this.p, required this.lang, required this.onTap});
  final ConditionsStore store;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = store.isDiagnosed
        ? const LocalizedText(en: 'My doctor told me · change', hi: 'My doctor told me · change')
        : const LocalizedText(en: 'Just exploring · change', hi: 'Just exploring · change');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label.of(lang),
            style: pvManrope(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.p, required this.lang});
  final TextEditingController controller;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 19, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              style: pvManrope(fontSize: 14, color: p.ink1),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: const LocalizedText(
                        en: 'Search a condition',
                        hi: 'Search a condition')
                    .of(lang),
                hintStyle: pvManrope(fontSize: 14, color: p.ink3),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: controller.clear,
              child: Icon(Icons.close_rounded, size: 17, color: p.ink3),
            ),
        ]),
      );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.p, required this.lang, required this.onOpen});
  final List<ConditionEntry> results;
  final V2Palette p;
  final AppLanguage lang;
  final void Function(ConditionEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
            const LocalizedText(
                    en: "Nothing matched. Try a different word, or browse "
                        "the list below.",
                    hi: "Nothing matched. Try a different word, or browse "
                        "the list below.")
                .of(lang),
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink3)),
      );
    }
    return SolutionGroup(
      title: LocalizedText(
          en: '${results.length} match${results.length == 1 ? '' : 'es'}',
          hi: '${results.length} match${results.length == 1 ? '' : 'es'}'),
      p: p,
      lang: lang,
      cards: [
        for (final c in results)
          SolutionCard(
            type: SolutionType.read,
            title: c.name,
            value: c.reassurance,
            p: p,
            lang: lang,
            onTap: () => onOpen(c),
          ),
      ],
    );
  }
}
