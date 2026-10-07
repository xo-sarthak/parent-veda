// =============================================================================
//  SickDaysScreen - Recipes · Sick-day meals (the Sick-mode doorway)
// -----------------------------------------------------------------------------
//  Comfort meals for when the child is unwell - gentle, settling foods filtered
//  by what's troubling him (constipation / loose motion / cough & cold / fever),
//  with an ⓘ safety note (these support recovery, not medical remedies). Now on
//  the unified FoodRecipe model: each meal opens the data-driven FoodRecipeScreen.
//  Reached from the unified Recipes home → Sick mode.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_phases_data.dart' show ppFillChild;
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, kPvInk, pvStorePalette;
import 'pp_care_parts.dart' show ppCareHeading;

class SickDaysScreen extends StatefulWidget {
  const SickDaysScreen({super.key});

  @override
  State<SickDaysScreen> createState() => _SickDaysScreenState();
}

class _SickDaysScreenState extends State<SickDaysScreen> {
  bool _noteOpen = false;
  String _situation = 'Constipation';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  static const Map<String, IconData> _icons = {
    'Constipation': Icons.eco_outlined,
    'Loose motion': Icons.water_drop_outlined,
    'Cough & cold': Icons.masks_outlined,
    'Fever': Icons.thermostat,
  };

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  Sick-day meals on the shell the Recipes page and every recipe wear (hue 96,
  //  the cook mark): the safety note behind the round (i) opposite back, the
  //  situations as hairline PvChips, the meals as one PvRowGroup. Same filter,
  //  same recipes, same FoodRecipeScreen. `_buildBeforeShell` is the page
  //  before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final list = sickFoodRecipes(_situation);
    final p = pvStorePalette;
    final name = ChildProfileStore.instance.nameMid;
    return PregToolScaffold(
      hue: 96,
      eyebrow: 'Comfort meals',
      mark: IntentMark.cookMark,
      title: 'Sick-day meals',
      intro: ppFillChild(
          "Gentle, settling foods for when $name's under the weather - soft, mild, and easy on a poorly tummy. Pick what's troubling him."),
      action: Semantics(
        button: true,
        label: _noteOpen ? 'Hide the safety note' : 'Show the safety note',
        child: InkWell(
          key: const ValueKey('sick_days_info'),
          onTap: () => setState(() => _noteOpen = !_noteOpen),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _noteOpen ? kPvInk : p.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
            child: Icon(Icons.info_outline_rounded, size: 19, color: _noteOpen ? Colors.white : kPvInk),
          ),
        ),
      ),
      children: [
        if (_noteOpen) ...[
          pregToolPad(Container(
            key: const ValueKey('sick_days_note'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
            child: Text(
                ppFillChild(
                    "These are wholesome meals to support $name's recovery, not medical remedies. Keep offering fluids, and check with your paediatrician if you're unsure. Reviewed by a paediatric nutritionist and always age-appropriate for him."),
                style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1)),
          )),
          const SizedBox(height: 18),
        ],
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: kSickSituations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = kSickSituations[i];
              return Center(
                child: PvChip(
                  key: ValueKey('sick_days_chip_$s'),
                  label: s,
                  leading: _icons[s],
                  selected: _situation == s,
                  onTap: () => setState(() => _situation = s),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        pregToolPad(ppCareHeading('For ${_situation.toLowerCase()}')),
        const SizedBox(height: 4),
        pregToolPad(Text(sickBlurb(_situation), style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),
        const SizedBox(height: 12),
        if (list.isEmpty)
          pregToolPad(Text('More comfort meals coming soon.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
        else
          pregToolPad(PvRowGroup(p: p, children: [
            for (final r in list)
              PvListRow(
                key: ValueKey('sick_days_${r.id}'),
                p: p,
                leading: PvMarkWell(p: p, hue: 96, size: 40, mark: IntentMark.cookMark),
                title: r.title,
                line: ppFill(r.subtitle),
                meta: '${r.prepMin + r.cookMin} min',
                onTap: () => _push(FoodRecipeScreen(recipe: r)),
              ),
          ])),
        const SizedBox(height: 22),
        pregToolPad(Text(ppFillChild('Reviewed by a paediatric nutritionist. Always age-appropriate for $name.'),
            style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink3))),
      ],
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final list = sickFoodRecipes(_situation);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Recipes')),

            // header
            const SizedBox(height: 22),
            _pad(ppEyebrow('Comfort meals', color: ppPurple)),
            const SizedBox(height: 10),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text('Sick-day meals', style: ppFraunces(32, h: 1.12))),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _noteOpen = !_noteOpen),
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: ppLine)),
                  child: const Icon(Icons.info_outline, size: 16, color: ppPurple),
                ),
              ),
            ])),
            const SizedBox(height: 12),
            _pad(Text("Gentle, settling foods for when ${ChildProfileStore.instance.nameMid}'s under the weather - soft, mild, and easy on a poorly tummy. Pick what's troubling him.",
                style: ppBody(15))),

            if (_noteOpen) ...[
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF6F4F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                child: Text(
                    "These are wholesome meals to support ${ChildProfileStore.instance.nameMid}'s recovery, not medical remedies. Keep offering fluids, and check with your paediatrician if you're unsure. Reviewed by a paediatric nutritionist and always age-appropriate for him.",
                    style: ppBody(13, h: 1.6)),
              )),
            ],

            // situation filter
            const SizedBox(height: 20),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [for (final s in kSickSituations) _sitChip(s)],
              ),
            ),

            // section
            const SizedBox(height: 26),
            _pad(Text('For ${_situation.toLowerCase()}', style: ppJakarta(16))),
            const SizedBox(height: 4),
            _pad(Text(sickBlurb(_situation), style: ppBody(12))),
            const SizedBox(height: 14),
            if (list.isEmpty)
              _pad(Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: Text('More comfort meals coming soon.', style: ppBody(13, color: ppMuted)),
              ))
            else
              _pad(Column(children: [
                for (final r in list) FoodListCard(recipe: r, warm: true, onTap: () => _push(FoodRecipeScreen(recipe: r))),
              ])),

            const SizedBox(height: 26),
            _pad(Text('Reviewed by a paediatric nutritionist. Always age-appropriate for ${ChildProfileStore.instance.nameMid}.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _sitChip(String s) {
    final on = _situation == s;
    return GestureDetector(
      onTap: () => setState(() => _situation = s),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_icons[s], size: 14, color: on ? Colors.white : ppSoft),
          const SizedBox(width: 6),
          Text(s, style: ppBody(13, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
        ]),
      ),
    );
  }
}
