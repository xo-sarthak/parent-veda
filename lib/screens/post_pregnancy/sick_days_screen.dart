// =============================================================================
//  SickDaysScreen - Recipes · Sick-day meals (parenting · S15·sick)
// -----------------------------------------------------------------------------
//  Comfort meals for when the child is unwell - gentle, settling foods filtered
//  by what's troubling him (constipation / loose motion / cough & cold / fever),
//  with an ⓘ safety note (these support recovery, not medical remedies).
//  Faithful build of Claude Design · S15·sick. Reached from Recipes → Sick mode.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_recipe_widgets.dart';
import 'pp_recipes_data.dart';

class SickDaysScreen extends StatefulWidget {
  const SickDaysScreen({super.key});

  @override
  State<SickDaysScreen> createState() => _SickDaysScreenState();
}

class _SickDaysScreenState extends State<SickDaysScreen> {
  bool _noteOpen = false;
  String _situation = 'Constipation';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  static const Map<String, IconData> _icons = {
    'Constipation': Icons.eco_outlined,
    'Loose motion': Icons.water_drop_outlined,
    'Cough & cold': Icons.masks_outlined,
    'Fever': Icons.thermostat,
  };

  @override
  Widget build(BuildContext context) {
    final list = sickRecipes(_situation);
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
            _pad(Text("Gentle, settling foods for when Aarav's under the weather - soft, mild, and easy on a poorly tummy. Pick what's troubling him.",
                style: ppBody(15))),

            if (_noteOpen) ...[
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF6F4F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                child: Text(
                    "These are wholesome meals to support Aarav's recovery, not medical remedies. Keep offering fluids, and check with your paediatrician if you're unsure. Reviewed by a paediatric nutritionist and always age-appropriate for him.",
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
                for (int i = 0; i < list.length; i++)
                  PpRecipeRow(list[i], warm: true, top: i > 0, bottom: i == list.length - 1),
              ])),

            const SizedBox(height: 26),
            _pad(Text('Reviewed by a paediatric nutritionist. Always age-appropriate for Aarav.',
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
