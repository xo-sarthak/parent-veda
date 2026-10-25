// =============================================================================
//  Food safety, shared by the three Food tools (tools pass 22-24, 2026-10-25)
// -----------------------------------------------------------------------------
//  What to feed, Can my baby eat this? and Recipes each told a parent to bring
//  in egg, peanut and fish early, and none of them said what a reaction looks
//  like or when it is an emergency. One block says it, in one voice, wherever
//  a common allergen appears. Same for the disclaimer and the sources line.
//
//  And the child's allergies on file (Health record, `HealthStore`, per child)
//  were never read: Egg said "Yes" for a child with an egg allergy saved. The
//  user's decision D2: ALWAYS WARN. It is safety, not personalisation, so it
//  needs no "use this?" ask, and it hides or reorders nothing: it adds a calm
//  line that sends her to her doctor.
//
//  ⚠️ NEVER A DIAGNOSIS. Nothing here says "allergic". It says what to watch,
//  and who decides. REQUIRED_REVIEW: the red-flag wording and the keywords.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_health_data.dart';

/// The common food allergens, each with the words that name it in an Indian
/// kitchen. A food or recipe "has" an allergen when one of the words appears
/// in its name, aliases or ingredients. REQUIRED_REVIEW.
const Map<String, List<String>> kPpFoodAllergens = {
  'egg': ['egg', 'anda', 'eggs'],
  'peanut': ['peanut', 'groundnut', 'moongphali', 'mungfali', 'chikki'],
  'tree nut': ['nut', 'badam', 'almond', 'kaju', 'cashew', 'walnut', 'akhrot', 'pista', 'pistachio'],
  'milk': ['milk', 'doodh', 'curd', 'dahi', 'paneer', 'cheese', 'butter', 'ghee', 'khoa', 'mawa', 'yoghurt', 'yogurt', 'kheer', 'chaas', 'lassi', 'milkshake'],
  'fish': ['fish', 'machli', 'macch', 'meen'],
  'shellfish': ['prawn', 'shrimp', 'jhinga', 'crab', 'lobster', 'shellfish'],
  'wheat': ['wheat', 'atta', 'maida', 'suji', 'sooji', 'rava', 'semolina', 'dalia', 'roti', 'chapati'],
  'soy': ['soy', 'soya', 'tofu'],
  'sesame': ['sesame', 'til', 'gingelly'],
};

/// A whole word, plural allowed: "nuts" and "eggs" match, "nutmeg" and
/// "tilapia" do not.
bool _hasWord(String text, String word) =>
    RegExp('(^|[^a-z])${RegExp.escape(word)}(s|es)?([^a-z]|\$)', caseSensitive: false).hasMatch(text);

/// The allergen groups [texts] mention (food name, aliases, ingredients).
Set<String> ppAllergensIn(Iterable<String> texts) {
  final all = texts.join(' | ').toLowerCase();
  return {
    for (final e in kPpFoodAllergens.entries)
      if (e.value.any((w) => _hasWord(all, w))) e.key,
  };
}

/// The words an allergy on file stands for: its own name, plus every word of
/// any allergen group the name mentions ("Cow's milk protein" → the milk words).
List<String> _allergyWords(Allergy a) {
  final n = a.name.toLowerCase().trim();
  return [
    if (n.isNotEmpty) n,
    for (final e in kPpFoodAllergens.entries)
      if (_hasWord(n, e.key) || e.value.any((w) => _hasWord(n, w))) ...e.value,
  ];
}

/// The first allergy on [allergies] that [texts] (a food's name and aliases,
/// or a recipe's ingredients) touch. Null when none does.
Allergy? ppAllergyMatchIn(List<Allergy> allergies, Iterable<String> texts) {
  final all = texts.join(' | ').toLowerCase();
  for (final a in allergies) {
    if (_allergyWords(a).any((w) => w.isNotEmpty && _hasWord(all, w))) return a;
  }
  return null;
}

/// The same, against the active child's known allergies (`HealthStore`).
Allergy? ppAllergyMatch(Iterable<String> texts) =>
    ppAllergyMatchIn(HealthStore.instance.knownAllergies, texts);

/// What to say when a food or dish touches an allergy on file.
String ppAllergyLine(Allergy a, String childName) =>
    'On $childName\'s health record as an allergy (${a.name}). '
    'Ask your doctor before offering this.';

/// The disclaimer and the sources, at the foot of each Food tool.
const String kPpFoodDisclaimer =
    'General guidance, drawn from IAP, WHO and AAP advice on feeding young '
    'children. It is not medical advice for your child; your paediatrician '
    'knows them best.';

/// A calm line on the record: "on her health record as an allergy".
class PpAllergyCallout extends StatelessWidget {
  const PpAllergyCallout({super.key, required this.allergy, required this.childName});
  final Allergy allergy;
  final String childName;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      key: const ValueKey('pp_allergy_callout'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.ink1, width: 1.2),
      ),
      child: Text(ppAllergyLine(allergy, childName),
          style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.5, color: p.ink1)),
    );
  }
}

/// What a reaction looks like, and when it is an emergency. Shown under the
/// food list and on the sheet of every common allergen.
class PpAllergyRedFlags extends StatelessWidget {
  const PpAllergyRedFlags({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final body = pvManrope(fontSize: 13, height: 1.55, color: p.ink1);
    return Container(
      key: const ValueKey('pp_allergy_red_flags'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('If a new food brings a reaction',
            style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
        const SizedBox(height: 8),
        Text('A few hives or some redness around the mouth: stop that food, note it under Tried it, '
            'and tell your doctor before you offer it again.', style: body),
        const SizedBox(height: 8),
        Text('Swelling of the lips, face or tongue, trouble breathing, a hoarse cry, repeated vomiting, '
            'or turning pale and floppy: this is an emergency. Call 108 or 112, or go to the nearest '
            'emergency now.', style: body.copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// The disclaimer and the sources, in the tools' small grey type.
class PpFoodDisclaimer extends StatelessWidget {
  const PpFoodDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Text(kPpFoodDisclaimer,
        key: const ValueKey('pp_food_disclaimer'),
        style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3));
  }
}
