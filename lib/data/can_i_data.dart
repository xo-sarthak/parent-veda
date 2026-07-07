// =============================================================================
//  Can I?™  - curated seed database
// -----------------------------------------------------------------------------
//  A hand-picked set of the most common, well-established questions (covering
//  all six "popular searches" + a spread across Eat / Drink / Take / Do). This
//  is GENERAL educational guidance, written carefully and conservatively - it is
//  not a medical review, and every answer defers to the mother's own doctor.
//
//  English-first: every entry carries en + hi (today hi mirrors en) so Hindi can
//  be authored later without touching any screen. The schema scales to the full
//  250-item list unchanged.
// =============================================================================

import '../localization/app_language.dart';
import '../models/can_i_entry.dart';

/// Compact bilingual helper for the expanded library (English-first; hi mirrors
/// en until Hindi is authored).
LocalizedText _t(String s) => LocalizedText(en: s, hi: s);

/// Popular-search chips on the Can I? home (emoji + label → entry id).
const List<({String emoji, String label, String id})> kCanIPopular = [
  (emoji: '🍍', label: 'Pineapple', id: 'pineapple'),
  (emoji: '☕', label: 'Coffee', id: 'coffee'),
  (emoji: '💊', label: 'Crocin', id: 'paracetamol'),
  (emoji: '✈️', label: 'Flight travel', id: 'flight_travel'),
  (emoji: '🎨', label: 'Hair colour', id: 'hair_color'),
  (emoji: '❤️', label: 'Sex', id: 'sex'),
];

final List<CanIEntry> kCanIEntries = [
  // ===========================================================================
  //  EAT
  // ===========================================================================
  CanIEntry(
    id: 'papaya',
    name: LocalizedText(en: 'Papaya', hi: 'Papaya'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Ripe papaya in small amounts is generally considered fine. Raw or unripe papaya is usually advised against.',
      hi: 'Ripe papaya in small amounts is generally considered fine. Raw or unripe papaya is usually advised against.',
    ),
    why: LocalizedText(
      en: 'Fully ripe papaya is a nutritious fruit. Unripe or semi-ripe papaya contains more latex (papain), which is traditionally avoided in pregnancy. The riper it is, the gentler it is.',
      hi: 'Fully ripe papaya is a nutritious fruit. Unripe or semi-ripe papaya contains more latex (papain), which is traditionally avoided in pregnancy. The riper it is, the gentler it is.',
    ),
    t1: LocalizedText(
      en: 'Many mothers prefer to be extra cautious in the first trimester and skip raw papaya entirely.',
      hi: 'Many mothers prefer to be extra cautious in the first trimester and skip raw papaya entirely.',
    ),
    indian: LocalizedText(
      en: 'Raw papaya turns up in salads and some sabzis - that is the form to be careful with. Ripe, sweet papaya as fruit is the safer choice.',
      hi: 'Raw papaya turns up in salads and some sabzis - that is the form to be careful with. Ripe, sweet papaya as fruit is the safer choice.',
    ),
    related: ['pineapple', 'mango', 'street_food'],
    aliases: ['papita', 'raw papaya', 'ripe papaya'],
  ),
  CanIEntry(
    id: 'pineapple',
    name: LocalizedText(en: 'Pineapple', hi: 'Pineapple'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Pineapple in normal food amounts is generally fine. Only very large quantities are best avoided.',
      hi: 'Pineapple in normal food amounts is generally fine. Only very large quantities are best avoided.',
    ),
    why: LocalizedText(
      en: 'Pineapple contains an enzyme called bromelain, but the amount in a normal serving is tiny. You would need to eat a lot for it to matter, so everyday portions are considered okay.',
      hi: 'Pineapple contains an enzyme called bromelain, but the amount in a normal serving is tiny. You would need to eat a lot for it to matter, so everyday portions are considered okay.',
    ),
    indian: LocalizedText(
      en: 'A few slices or a glass of fresh juice is fine. Skip the giant bowl-a-day habit.',
      hi: 'A few slices or a glass of fresh juice is fine. Skip the giant bowl-a-day habit.',
    ),
    related: ['papaya', 'mango', 'banana'],
    aliases: ['ananas'],
  ),
  CanIEntry(
    id: 'mango',
    name: LocalizedText(en: 'Mango', hi: 'Mango'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Mango is a nutritious fruit and fine in moderation.',
      hi: 'Mango is a nutritious fruit and fine in moderation.',
    ),
    why: LocalizedText(
      en: 'Mango is rich in vitamins A and C and folate. It is also high in natural sugar, so keep portions reasonable - especially if your doctor is watching your blood sugar.',
      hi: 'Mango is rich in vitamins A and C and folate. It is also high in natural sugar, so keep portions reasonable - especially if your doctor is watching your blood sugar.',
    ),
    indian: LocalizedText(
      en: 'Wash well and enjoy in season. If you have (or are at risk of) gestational diabetes, ask your doctor about quantity.',
      hi: 'Wash well and enjoy in season. If you have (or are at risk of) gestational diabetes, ask your doctor about quantity.',
    ),
    related: ['pineapple', 'banana', 'papaya'],
    aliases: ['aam'],
  ),
  CanIEntry(
    id: 'banana',
    name: LocalizedText(en: 'Banana', hi: 'Banana'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Bananas are a great, easy pregnancy snack.',
      hi: 'Bananas are a great, easy pregnancy snack.',
    ),
    why: LocalizedText(
      en: 'They give quick energy and potassium, can settle early-pregnancy nausea, and help with constipation. A simple, reliable choice.',
      hi: 'They give quick energy and potassium, can settle early-pregnancy nausea, and help with constipation. A simple, reliable choice.',
    ),
    related: ['mango', 'curd', 'pineapple'],
    aliases: ['kela'],
  ),
  CanIEntry(
    id: 'paneer',
    name: LocalizedText(en: 'Paneer', hi: 'Paneer'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Paneer made from pasteurised milk and eaten fresh or cooked is fine. Avoid unpasteurised soft cheese.',
      hi: 'Paneer made from pasteurised milk and eaten fresh or cooked is fine. Avoid unpasteurised soft cheese.',
    ),
    why: LocalizedText(
      en: 'The concern with some soft cheeses is listeria, a bacteria that can grow in unpasteurised dairy. Paneer from pasteurised milk - cooked or freshly made - sidesteps that.',
      hi: 'The concern with some soft cheeses is listeria, a bacteria that can grow in unpasteurised dairy. Paneer from pasteurised milk - cooked or freshly made - sidesteps that.',
    ),
    indian: LocalizedText(
      en: 'Branded and most home-made paneer uses pasteurised milk. When in doubt, cook it (paneer bhurji, palak paneer) rather than eating it raw.',
      hi: 'Branded and most home-made paneer uses pasteurised milk. When in doubt, cook it (paneer bhurji, palak paneer) rather than eating it raw.',
    ),
    related: ['curd', 'milk', 'street_food'],
    aliases: ['cheese', 'cottage cheese'],
  ),
  CanIEntry(
    id: 'curd',
    name: LocalizedText(en: 'Curd / Yoghurt', hi: 'Curd / Yoghurt'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Curd is safe and good for you in pregnancy.',
      hi: 'Curd is safe and good for you in pregnancy.',
    ),
    why: LocalizedText(
      en: 'Made from pasteurised milk, it is a good source of calcium and protein, and the probiotics can help digestion. Set curd at home or use packaged dahi.',
      hi: 'Made from pasteurised milk, it is a good source of calcium and protein, and the probiotics can help digestion. Set curd at home or use packaged dahi.',
    ),
    related: ['paneer', 'milk', 'banana'],
    aliases: ['dahi', 'yogurt', 'yoghurt'],
  ),
  CanIEntry(
    id: 'chocolate',
    name: LocalizedText(en: 'Chocolate', hi: 'Chocolate'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Chocolate is fine to enjoy in moderation.',
      hi: 'Chocolate is fine to enjoy in moderation.',
    ),
    why: LocalizedText(
      en: 'Chocolate contains a little caffeine, so it counts towards your daily caffeine total. A few squares are a lovely treat - just keep the overall amount sensible.',
      hi: 'Chocolate contains a little caffeine, so it counts towards your daily caffeine total. A few squares are a lovely treat - just keep the overall amount sensible.',
    ),
    related: ['coffee', 'ice_cream', 'tea'],
    aliases: ['cocoa'],
  ),
  CanIEntry(
    id: 'street_food',
    name: LocalizedText(en: 'Street Food', hi: 'Street Food'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'It depends entirely on hygiene and freshness - the risk is contamination, not the dish itself.',
      hi: 'It depends entirely on hygiene and freshness - the risk is contamination, not the dish itself.',
    ),
    why: LocalizedText(
      en: 'Pregnancy lowers your resistance to food-borne infections. Hot, freshly-cooked food from a busy, clean stall is far safer than anything sitting out, raw, or rinsed in tap water.',
      hi: 'Pregnancy lowers your resistance to food-borne infections. Hot, freshly-cooked food from a busy, clean stall is far safer than anything sitting out, raw, or rinsed in tap water.',
    ),
    indian: LocalizedText(
      en: 'The usual culprits are golgappa/pani-puri water, cut fruit, and chutneys made with unfiltered water. Piping-hot tikki or dosa, freshly made, is lower risk.',
      hi: 'The usual culprits are golgappa/pani-puri water, cut fruit, and chutneys made with unfiltered water. Piping-hot tikki or dosa, freshly made, is lower risk.',
    ),
    related: ['papaya', 'paneer', 'water'],
    aliases: ['chaat', 'golgappa', 'pani puri', 'outside food'],
  ),
  CanIEntry(
    id: 'honey',
    name: LocalizedText(en: 'Honey', hi: 'Honey'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Honey is fine for you during pregnancy.',
      hi: 'Honey is fine for you during pregnancy.',
    ),
    why: LocalizedText(
      en: 'The well-known honey caution is for babies under one year, not for mothers. As an adult, your gut handles it normally. (Still mind the sugar.)',
      hi: 'The well-known honey caution is for babies under one year, not for mothers. As an adult, your gut handles it normally. (Still mind the sugar.)',
    ),
    related: ['chocolate', 'tea', 'ginger'],
    aliases: ['shahad'],
  ),
  CanIEntry(
    id: 'ginger',
    name: LocalizedText(en: 'Ginger', hi: 'Ginger'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Ginger in food and tea amounts is fine and can ease nausea.',
      hi: 'Ginger in food and tea amounts is fine and can ease nausea.',
    ),
    why: LocalizedText(
      en: 'Ginger is one of the better-studied natural remedies for morning sickness. Cooking-and-tea quantities are considered safe; very large supplement doses are not needed.',
      hi: 'Ginger is one of the better-studied natural remedies for morning sickness. Cooking-and-tea quantities are considered safe; very large supplement doses are not needed.',
    ),
    indian: LocalizedText(
      en: 'Adrak in chai or a little ginger-honey water is a gentle, traditional way to settle queasiness.',
      hi: 'Adrak in chai or a little ginger-honey water is a gentle, traditional way to settle queasiness.',
    ),
    related: ['honey', 'tea', 'banana'],
    aliases: ['adrak'],
  ),

  // ===========================================================================
  //  DRINK
  // ===========================================================================
  CanIEntry(
    id: 'coffee',
    name: LocalizedText(en: 'Coffee', hi: 'Coffee'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Up to about one cup a day (under ~200mg caffeine) is generally considered okay.',
      hi: 'Up to about one cup a day (under ~200mg caffeine) is generally considered okay.',
    ),
    why: LocalizedText(
      en: 'The usual guidance is to keep total caffeine under roughly 200mg a day. Remember it adds up across coffee, tea, cola and chocolate - not coffee alone.',
      hi: 'The usual guidance is to keep total caffeine under roughly 200mg a day. Remember it adds up across coffee, tea, cola and chocolate - not coffee alone.',
    ),
    t1: LocalizedText(
      en: 'Many mothers naturally go off coffee in the first trimester - listen to that.',
      hi: 'Many mothers naturally go off coffee in the first trimester - listen to that.',
    ),
    indian: LocalizedText(
      en: 'A strong South-Indian filter coffee can be higher in caffeine than you think - one a day is a reasonable ceiling.',
      hi: 'A strong South-Indian filter coffee can be higher in caffeine than you think - one a day is a reasonable ceiling.',
    ),
    related: ['tea', 'green_tea', 'soft_drinks'],
    aliases: ['caffeine', 'espresso', 'filter coffee'],
  ),
  CanIEntry(
    id: 'tea',
    name: LocalizedText(en: 'Tea / Chai', hi: 'Tea / Chai'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Regular tea in moderation is fine - just mind the caffeine total.',
      hi: 'Regular tea in moderation is fine - just mind the caffeine total.',
    ),
    why: LocalizedText(
      en: 'Tea has less caffeine than coffee but still counts towards your ~200mg daily limit. Two to three cups of normal chai is generally considered reasonable.',
      hi: 'Tea has less caffeine than coffee but still counts towards your ~200mg daily limit. Two to three cups of normal chai is generally considered reasonable.',
    ),
    indian: LocalizedText(
      en: 'Doodh-wali chai counts too. Some herbal teas are not recommended in pregnancy, so check before switching to a new one.',
      hi: 'Doodh-wali chai counts too. Some herbal teas are not recommended in pregnancy, so check before switching to a new one.',
    ),
    related: ['coffee', 'green_tea', 'ginger'],
    aliases: ['chai', 'doodh tea'],
  ),
  CanIEntry(
    id: 'green_tea',
    name: LocalizedText(en: 'Green Tea', hi: 'Green Tea'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'One to two cups a day is usually fine; just do not overdo it.',
      hi: 'One to two cups a day is usually fine; just do not overdo it.',
    ),
    why: LocalizedText(
      en: 'Green tea has caffeine and, in large amounts, can interfere with how your body uses folate (important early in pregnancy). A cup or two is fine; gallons are not.',
      hi: 'Green tea has caffeine and, in large amounts, can interfere with how your body uses folate (important early in pregnancy). A cup or two is fine; gallons are not.',
    ),
    related: ['tea', 'coffee', 'folic_acid'],
    aliases: ['herbal tea'],
  ),
  CanIEntry(
    id: 'coconut_water',
    name: LocalizedText(en: 'Coconut Water', hi: 'Coconut Water'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Coconut water is a great, hydrating choice.',
      hi: 'Coconut water is a great, hydrating choice.',
    ),
    why: LocalizedText(
      en: 'It is mostly water with natural electrolytes, so it helps with hydration and can be soothing if you feel queasy. Fresh is best.',
      hi: 'It is mostly water with natural electrolytes, so it helps with hydration and can be soothing if you feel queasy. Fresh is best.',
    ),
    indian: LocalizedText(
      en: 'Nariyal paani is widely recommended - drink it fresh from a tender coconut rather than a sugary packaged version.',
      hi: 'Nariyal paani is widely recommended - drink it fresh from a tender coconut rather than a sugary packaged version.',
    ),
    related: ['water', 'buttermilk', 'soft_drinks'],
    aliases: ['nariyal pani', 'tender coconut'],
  ),
  CanIEntry(
    id: 'buttermilk',
    name: LocalizedText(en: 'Buttermilk', hi: 'Buttermilk'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Buttermilk is safe, cooling and good for digestion.',
      hi: 'Buttermilk is safe, cooling and good for digestion.',
    ),
    why: LocalizedText(
      en: 'Made from curd, it offers calcium and probiotics, helps with acidity, and keeps you hydrated. A light, gut-friendly option.',
      hi: 'Made from curd, it offers calcium and probiotics, helps with acidity, and keeps you hydrated. A light, gut-friendly option.',
    ),
    indian: LocalizedText(
      en: 'Chaas with a little jeera and pudina is a great everyday drink, especially in summer.',
      hi: 'Chaas with a little jeera and pudina is a great everyday drink, especially in summer.',
    ),
    related: ['curd', 'coconut_water', 'water'],
    aliases: ['chaas', 'chaach', 'lassi'],
  ),
  CanIEntry(
    id: 'alcohol',
    name: LocalizedText(en: 'Alcohol', hi: 'Alcohol'),
    category: CanICategory.drink,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'No amount of alcohol is considered safe during pregnancy.',
      hi: 'No amount of alcohol is considered safe during pregnancy.',
    ),
    why: LocalizedText(
      en: 'Alcohol crosses the placenta to your baby, and no safe level or safe time has been established. The clear, simple advice is to avoid it completely.',
      hi: 'Alcohol crosses the placenta to your baby, and no safe level or safe time has been established. The clear, simple advice is to avoid it completely.',
    ),
    related: ['coffee', 'soft_drinks'],
    aliases: ['wine', 'beer', 'sharab', 'drinking'],
  ),
  CanIEntry(
    id: 'soft_drinks',
    name: LocalizedText(en: 'Soft Drinks / Soda', hi: 'Soft Drinks / Soda'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'An occasional one is okay, but they are high in sugar and caffeine.',
      hi: 'An occasional one is okay, but they are high in sugar and caffeine.',
    ),
    why: LocalizedText(
      en: 'Colas add caffeine to your daily total and most soft drinks are very sugary with little benefit. Fine as a once-in-a-while treat, not an everyday drink.',
      hi: 'Colas add caffeine to your daily total and most soft drinks are very sugary with little benefit. Fine as a once-in-a-while treat, not an everyday drink.',
    ),
    related: ['coffee', 'coconut_water', 'water'],
    aliases: ['cola', 'soda', 'cold drink', 'pepsi', 'coke'],
  ),
  CanIEntry(
    id: 'water',
    name: LocalizedText(en: 'Water (how much)', hi: 'Water (how much)'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Drink plenty - staying well hydrated is one of the simplest good habits.',
      hi: 'Drink plenty - staying well hydrated is one of the simplest good habits.',
    ),
    why: LocalizedText(
      en: 'Aim for roughly 8–10 glasses a day (more in heat or if active). Good hydration helps with constipation, swelling and those common Braxton-Hicks tightenings.',
      hi: 'Aim for roughly 8–10 glasses a day (more in heat or if active). Good hydration helps with constipation, swelling and those common Braxton-Hicks tightenings.',
    ),
    related: ['coconut_water', 'buttermilk', 'street_food'],
    aliases: ['hydration', 'pani'],
  ),

  // ===========================================================================
  //  TAKE (medicines / supplements)
  // ===========================================================================
  CanIEntry(
    id: 'paracetamol',
    name: LocalizedText(en: 'Paracetamol (Crocin / Dolo)', hi: 'Paracetamol (Crocin / Dolo)'),
    category: CanICategory.take,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Paracetamol is generally considered the preferred choice for fever or pain - lowest dose that helps, for the shortest time.',
      hi: 'Paracetamol is generally considered the preferred choice for fever or pain - lowest dose that helps, for the shortest time.',
    ),
    why: LocalizedText(
      en: 'It is the most widely used pain/fever medicine in pregnancy and is usually preferred over alternatives. Still, use it only when needed and let your doctor know if you are taking it often.',
      hi: 'It is the most widely used pain/fever medicine in pregnancy and is usually preferred over alternatives. Still, use it only when needed and let your doctor know if you are taking it often.',
    ),
    related: ['ibuprofen', 'combiflam', 'antibiotics'],
    aliases: ['crocin', 'dolo', 'dolo 650', 'fever', 'paracetamol', 'calpol'],
  ),
  CanIEntry(
    id: 'ibuprofen',
    name: LocalizedText(en: 'Ibuprofen', hi: 'Ibuprofen'),
    category: CanICategory.take,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'Generally avoided in pregnancy - especially in the third trimester. Ask your doctor first.',
      hi: 'Generally avoided in pregnancy - especially in the third trimester. Ask your doctor first.',
    ),
    why: LocalizedText(
      en: 'Ibuprofen is an anti-inflammatory (NSAID) that is usually not recommended in pregnancy, particularly later on. Paracetamol is normally suggested instead.',
      hi: 'Ibuprofen is an anti-inflammatory (NSAID) that is usually not recommended in pregnancy, particularly later on. Paracetamol is normally suggested instead.',
    ),
    t3: LocalizedText(
      en: 'In the third trimester it is best avoided altogether - it can affect the baby. Do not take it without your doctor.',
      hi: 'In the third trimester it is best avoided altogether - it can affect the baby. Do not take it without your doctor.',
    ),
    related: ['paracetamol', 'combiflam', 'aspirin'],
    aliases: ['brufen', 'advil', 'nsaid'],
  ),
  CanIEntry(
    id: 'combiflam',
    name: LocalizedText(en: 'Combiflam', hi: 'Combiflam'),
    category: CanICategory.take,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Best not taken on your own - it contains ibuprofen. Check with your doctor.',
      hi: 'Best not taken on your own - it contains ibuprofen. Check with your doctor.',
    ),
    why: LocalizedText(
      en: 'Combiflam combines paracetamol with ibuprofen, and the ibuprofen part is the one usually avoided in pregnancy. For fever or pain, plain paracetamol is the safer default.',
      hi: 'Combiflam combines paracetamol with ibuprofen, and the ibuprofen part is the one usually avoided in pregnancy. For fever or pain, plain paracetamol is the safer default.',
    ),
    related: ['ibuprofen', 'paracetamol', 'aspirin'],
    aliases: ['ibuprofen paracetamol'],
  ),
  CanIEntry(
    id: 'antibiotics',
    name: LocalizedText(en: 'Antibiotics', hi: 'Antibiotics'),
    category: CanICategory.take,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Some are safe in pregnancy and some are not - only take antibiotics your doctor prescribes.',
      hi: 'Some are safe in pregnancy and some are not - only take antibiotics your doctor prescribes.',
    ),
    why: LocalizedText(
      en: 'It depends entirely on which antibiotic. Several are used safely in pregnancy; a few are avoided. This is one to never self-prescribe or reuse from an old strip.',
      hi: 'It depends entirely on which antibiotic. Several are used safely in pregnancy; a few are avoided. This is one to never self-prescribe or reuse from an old strip.',
    ),
    related: ['paracetamol', 'combiflam'],
    aliases: ['amoxicillin', 'azithromycin', 'augmentin', 'antibiotic'],
  ),
  CanIEntry(
    id: 'folic_acid',
    name: LocalizedText(en: 'Folic Acid', hi: 'Folic Acid'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Folic acid is recommended in pregnancy - take it as your doctor advises.',
      hi: 'Folic acid is recommended in pregnancy - take it as your doctor advises.',
    ),
    why: LocalizedText(
      en: 'It supports your baby\'s early brain and spine development, which is why it is advised from before conception through early pregnancy. It is one of the few things actively encouraged.',
      hi: 'It supports your baby\'s early brain and spine development, which is why it is advised from before conception through early pregnancy. It is one of the few things actively encouraged.',
    ),
    t1: LocalizedText(
      en: 'Most important in the first trimester (and ideally before) - do not skip it.',
      hi: 'Most important in the first trimester (and ideally before) - do not skip it.',
    ),
    related: ['iron', 'calcium', 'vitamin_d'],
    aliases: ['folate', 'vitamin b9'],
  ),
  CanIEntry(
    id: 'iron',
    name: LocalizedText(en: 'Iron Supplements', hi: 'Iron Supplements'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Iron is commonly recommended - take the dose your doctor prescribes.',
      hi: 'Iron is commonly recommended - take the dose your doctor prescribes.',
    ),
    why: LocalizedText(
      en: 'Your blood volume rises in pregnancy, so iron needs go up and many mothers are advised supplements. It can cause constipation - fluids and fibre help.',
      hi: 'Your blood volume rises in pregnancy, so iron needs go up and many mothers are advised supplements. It can cause constipation - fluids and fibre help.',
    ),
    related: ['folic_acid', 'calcium', 'vitamin_d'],
    aliases: ['ferrous', 'haemoglobin', 'iron tablet'],
  ),
  CanIEntry(
    id: 'calcium',
    name: LocalizedText(en: 'Calcium Supplements', hi: 'Calcium Supplements'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Calcium is commonly recommended in pregnancy; follow your doctor\'s advice.',
      hi: 'Calcium is commonly recommended in pregnancy; follow your doctor\'s advice.',
    ),
    why: LocalizedText(
      en: 'It supports your baby\'s bones and teeth and protects your own stores. It is usually taken at a different time of day from iron, since they compete for absorption.',
      hi: 'It supports your baby\'s bones and teeth and protects your own stores. It is usually taken at a different time of day from iron, since they compete for absorption.',
    ),
    related: ['iron', 'folic_acid', 'vitamin_d'],
    aliases: ['calcium tablet'],
  ),
  CanIEntry(
    id: 'vitamin_d',
    name: LocalizedText(en: 'Vitamin D', hi: 'Vitamin D'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Vitamin D is commonly recommended; take the dose your doctor sets.',
      hi: 'Vitamin D is commonly recommended; take the dose your doctor sets.',
    ),
    why: LocalizedText(
      en: 'It helps your body absorb calcium and supports bone health for you and your baby. Many people are mildly deficient, so it is often prescribed.',
      hi: 'It helps your body absorb calcium and supports bone health for you and your baby. Many people are mildly deficient, so it is often prescribed.',
    ),
    related: ['calcium', 'folic_acid', 'iron'],
    aliases: ['vitamin d3', 'cholecalciferol'],
  ),

  // ===========================================================================
  //  DO (activities / beauty / lifestyle)
  // ===========================================================================
  CanIEntry(
    id: 'flight_travel',
    name: LocalizedText(en: 'Flight Travel', hi: 'Flight Travel'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Air travel is generally fine in an uncomplicated pregnancy - usually most comfortable in the second trimester.',
      hi: 'Air travel is generally fine in an uncomplicated pregnancy - usually most comfortable in the second trimester.',
    ),
    why: LocalizedText(
      en: 'Flying does not harm a low-risk pregnancy. On long flights, walk and stretch, keep hydrated, and wear your seatbelt low under the bump. Always clear travel with your doctor first.',
      hi: 'Flying does not harm a low-risk pregnancy. On long flights, walk and stretch, keep hydrated, and wear your seatbelt low under the bump. Always clear travel with your doctor first.',
    ),
    t2: LocalizedText(
      en: 'Usually the easiest window to travel - nausea has eased and the bump is still manageable.',
      hi: 'Usually the easiest window to travel - nausea has eased and the bump is still manageable.',
    ),
    t3: LocalizedText(
      en: 'Many airlines restrict travel after about 36 weeks and may ask for a doctor\'s note - check before booking.',
      hi: 'Many airlines restrict travel after about 36 weeks and may ask for a doctor\'s note - check before booking.',
    ),
    related: ['long_travel', 'walking', 'water'],
    aliases: ['flight', 'flying', 'air travel', 'airplane', 'plane'],
  ),
  CanIEntry(
    id: 'long_travel',
    name: LocalizedText(en: 'Long Road / Train Travel', hi: 'Long Road / Train Travel'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Usually fine - break the journey often to move, stretch and use the toilet.',
      hi: 'Usually fine - break the journey often to move, stretch and use the toilet.',
    ),
    why: LocalizedText(
      en: 'Sitting for hours can make legs swell and feel stiff. Stop every couple of hours, walk a little, stay hydrated, and keep the seatbelt below the bump. Avoid very bumpy roads late in pregnancy.',
      hi: 'Sitting for hours can make legs swell and feel stiff. Stop every couple of hours, walk a little, stay hydrated, and keep the seatbelt below the bump. Avoid very bumpy roads late in pregnancy.',
    ),
    related: ['flight_travel', 'walking', 'water'],
    aliases: ['car travel', 'train', 'road trip', 'bus'],
  ),
  CanIEntry(
    id: 'yoga',
    name: LocalizedText(en: 'Yoga', hi: 'Yoga'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Gentle prenatal yoga is wonderful; avoid intense poses, deep twists and lying flat on your back later on.',
      hi: 'Gentle prenatal yoga is wonderful; avoid intense poses, deep twists and lying flat on your back later on.',
    ),
    why: LocalizedText(
      en: 'Yoga helps with flexibility, breathing and calm, and can ease back pain. Choose a prenatal class or teacher, skip strong abdominal and twisting poses, and never push into discomfort.',
      hi: 'Yoga helps with flexibility, breathing and calm, and can ease back pain. Choose a prenatal class or teacher, skip strong abdominal and twisting poses, and never push into discomfort.',
    ),
    related: ['walking', 'swimming', 'sleeping_back'],
    aliases: ['prenatal yoga', 'pranayama', 'asana', 'exercise'],
  ),
  CanIEntry(
    id: 'swimming',
    name: LocalizedText(en: 'Swimming', hi: 'Swimming'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Swimming is one of the best pregnancy exercises.',
      hi: 'Swimming is one of the best pregnancy exercises.',
    ),
    why: LocalizedText(
      en: 'The water takes the weight off your joints and back while giving a gentle full-body workout. Avoid diving, very hot pools, and slippery edges.',
      hi: 'The water takes the weight off your joints and back while giving a gentle full-body workout. Avoid diving, very hot pools, and slippery edges.',
    ),
    related: ['walking', 'yoga'],
    aliases: ['pool', 'swim'],
  ),
  CanIEntry(
    id: 'walking',
    name: LocalizedText(en: 'Walking', hi: 'Walking'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Walking is safe and encouraged throughout pregnancy.',
      hi: 'Walking is safe and encouraged throughout pregnancy.',
    ),
    why: LocalizedText(
      en: 'It is gentle cardio that helps your mood, sleep, digestion and stamina for labour - with almost no downside. Comfortable shoes and a steady pace are all you need.',
      hi: 'It is gentle cardio that helps your mood, sleep, digestion and stamina for labour - with almost no downside. Comfortable shoes and a steady pace are all you need.',
    ),
    related: ['yoga', 'swimming', 'lifting'],
    aliases: ['walk', 'morning walk'],
  ),
  CanIEntry(
    id: 'hair_color',
    name: LocalizedText(en: 'Hair Colour / Dye', hi: 'Hair Colour / Dye'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Generally considered low-risk, especially from the second trimester. Many prefer ammonia-free dyes or highlights.',
      hi: 'Generally considered low-risk, especially from the second trimester. Many prefer ammonia-free dyes or highlights.',
    ),
    why: LocalizedText(
      en: 'Very little dye is absorbed through the scalp, so the risk is considered small. To be extra cautious, some wait past the first trimester, choose gentler formulas, and keep the room ventilated.',
      hi: 'Very little dye is absorbed through the scalp, so the risk is considered small. To be extra cautious, some wait past the first trimester, choose gentler formulas, and keep the room ventilated.',
    ),
    t1: LocalizedText(
      en: 'Many mothers choose to wait until after the first trimester, just for peace of mind.',
      hi: 'Many mothers choose to wait until after the first trimester, just for peace of mind.',
    ),
    indian: LocalizedText(
      en: 'Natural henna (mehndi) is a popular, gentler alternative for colour - patch-test first, and avoid "black henna" which can contain harsh chemicals.',
      hi: 'Natural henna (mehndi) is a popular, gentler alternative for colour - patch-test first, and avoid "black henna" which can contain harsh chemicals.',
    ),
    related: ['waxing', 'keratin', 'nail_polish'],
    aliases: ['hair dye', 'dye', 'colour', 'mehndi', 'henna'],
  ),
  CanIEntry(
    id: 'waxing',
    name: LocalizedText(en: 'Waxing', hi: 'Waxing'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Waxing is generally fine - your skin may just be more sensitive now.',
      hi: 'Waxing is generally fine - your skin may just be more sensitive now.',
    ),
    why: LocalizedText(
      en: 'There is no harm to the baby. Hormones can make skin more sensitive and prone to redness, so patch-test new products and tell your salon you are pregnant.',
      hi: 'There is no harm to the baby. Hormones can make skin more sensitive and prone to redness, so patch-test new products and tell your salon you are pregnant.',
    ),
    related: ['hair_color', 'nail_polish'],
    aliases: ['wax', 'threading', 'hair removal'],
  ),
  CanIEntry(
    id: 'nail_polish',
    name: LocalizedText(en: 'Nail Polish', hi: 'Nail Polish'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Occasional use is fine; just paint your nails in a ventilated room.',
      hi: 'Occasional use is fine; just paint your nails in a ventilated room.',
    ),
    why: LocalizedText(
      en: 'The exposure from painting your nails is tiny. Keep the window open or a fan on so you are not breathing fumes, and you are good to go.',
      hi: 'The exposure from painting your nails is tiny. Keep the window open or a fan on so you are not breathing fumes, and you are good to go.',
    ),
    related: ['hair_color', 'waxing'],
    aliases: ['nail paint', 'manicure', 'pedicure'],
  ),
  CanIEntry(
    id: 'sex',
    name: LocalizedText(en: 'Sex During Pregnancy', hi: 'Sex During Pregnancy'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Sex is safe in a normal, uncomplicated pregnancy.',
      hi: 'Sex is safe in a normal, uncomplicated pregnancy.',
    ),
    why: LocalizedText(
      en: 'Your baby is well protected by the womb and fluid, so intimacy will not harm them. Comfort changes as the bump grows - adjust as needed.',
      hi: 'Your baby is well protected by the womb and fluid, so intimacy will not harm them. Comfort changes as the bump grows - adjust as needed.',
    ),
    indian: LocalizedText(
      en: 'It is a common worry but a normal, healthy part of pregnancy. Your doctor may advise against it only in specific situations (such as bleeding or placenta previa).',
      hi: 'It is a common worry but a normal, healthy part of pregnancy. Your doctor may advise against it only in specific situations (such as bleeding or placenta previa).',
    ),
    related: ['walking', 'sleeping_back'],
    aliases: ['intercourse', 'intimacy', 'sex during pregnancy'],
  ),
  CanIEntry(
    id: 'sleeping_back',
    name: LocalizedText(en: 'Sleeping On Your Back', hi: 'Sleeping On Your Back'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Fine early on. From the second and third trimester, side-sleeping (preferably left) is usually advised.',
      hi: 'Fine early on. From the second and third trimester, side-sleeping (preferably left) is usually advised.',
    ),
    why: LocalizedText(
      en: 'As the womb grows heavier, lying flat on your back can press on a large vein and make you feel dizzy. Sleeping on your side keeps blood flowing comfortably to you and the baby.',
      hi: 'As the womb grows heavier, lying flat on your back can press on a large vein and make you feel dizzy. Sleeping on your side keeps blood flowing comfortably to you and the baby.',
    ),
    t2: LocalizedText(
      en: 'A good time to get used to side-sleeping - tuck a pillow behind your back and between your knees.',
      hi: 'A good time to get used to side-sleeping - tuck a pillow behind your back and between your knees.',
    ),
    t3: LocalizedText(
      en: 'Prefer the left side. If you wake up on your back, just turn over - no need to panic.',
      hi: 'Prefer the left side. If you wake up on your back, just turn over - no need to panic.',
    ),
    related: ['yoga', 'sex', 'lifting'],
    aliases: ['sleep position', 'sleeping side', 'back sleeping'],
  ),
  CanIEntry(
    id: 'mosquito_repellent',
    name: LocalizedText(en: 'Mosquito Repellent', hi: 'Mosquito Repellent'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Use them - mosquito-borne illness is the bigger risk - but prefer gentler options and good ventilation.',
      hi: 'Use them - mosquito-borne illness is the bigger risk - but prefer gentler options and good ventilation.',
    ),
    why: LocalizedText(
      en: 'Dengue, malaria and chikungunya are genuinely risky in pregnancy, so protection matters. Creams and roll-ons used as directed are considered fine; air out the room if you use liquid vaporisers or coils.',
      hi: 'Dengue, malaria and chikungunya are genuinely risky in pregnancy, so protection matters. Creams and roll-ons used as directed are considered fine; air out the room if you use liquid vaporisers or coils.',
    ),
    indian: LocalizedText(
      en: 'Especially important in the monsoon. Prefer creams/patches and nets over breathing in coil or All-Out fumes in a closed room.',
      hi: 'Especially important in the monsoon. Prefer creams/patches and nets over breathing in coil or All-Out fumes in a closed room.',
    ),
    related: ['dental', 'xray'],
    aliases: ['odomos', 'all out', 'mosquito coil', 'repellent'],
  ),
  CanIEntry(
    id: 'dental',
    name: LocalizedText(en: 'Dental Treatment', hi: 'Dental Treatment'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Routine dental care is safe and important - just tell your dentist you are pregnant.',
      hi: 'Routine dental care is safe and important - just tell your dentist you are pregnant.',
    ),
    why: LocalizedText(
      en: 'Gums often become tender and bleed in pregnancy, so cleanings and necessary treatment matter. Most procedures are fine; dental X-rays use a shield and a tiny, focused dose.',
      hi: 'Gums often become tender and bleed in pregnancy, so cleanings and necessary treatment matter. Most procedures are fine; dental X-rays use a shield and a tiny, focused dose.',
    ),
    t2: LocalizedText(
      en: 'The most comfortable window for any planned dental work.',
      hi: 'The most comfortable window for any planned dental work.',
    ),
    related: ['xray', 'paracetamol', 'antibiotics'],
    aliases: ['dentist', 'tooth', 'root canal', 'scaling'],
  ),
  CanIEntry(
    id: 'xray',
    name: LocalizedText(en: 'X-Ray', hi: 'X-Ray'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Avoid routine X-rays. If one is medically needed, your doctor will shield you and keep it minimal.',
      hi: 'Avoid routine X-rays. If one is medically needed, your doctor will shield you and keep it minimal.',
    ),
    why: LocalizedText(
      en: 'Elective imaging is usually postponed during pregnancy. When an X-ray is genuinely needed (say after an injury), the dose is small and your abdomen is shielded - always tell the team you are pregnant.',
      hi: 'Elective imaging is usually postponed during pregnancy. When an X-ray is genuinely needed (say after an injury), the dose is small and your abdomen is shielded - always tell the team you are pregnant.',
    ),
    related: ['dental', 'mosquito_repellent'],
    aliases: ['radiograph', 'scan', 'ct scan'],
  ),
  CanIEntry(
    id: 'sauna',
    name: LocalizedText(en: 'Sauna / Hot Tub', hi: 'Sauna / Hot Tub'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'Best avoided - getting overheated is not recommended in pregnancy.',
      hi: 'Best avoided - getting overheated is not recommended in pregnancy.',
    ),
    why: LocalizedText(
      en: 'Saunas, steam rooms and hot tubs can raise your core temperature too much, especially early on. A warm (not hot) bath or shower is the comfortable, safe alternative.',
      hi: 'Saunas, steam rooms and hot tubs can raise your core temperature too much, especially early on. A warm (not hot) bath or shower is the comfortable, safe alternative.',
    ),
    related: ['swimming', 'walking'],
    aliases: ['steam', 'hot tub', 'jacuzzi', 'hot bath'],
  ),
  CanIEntry(
    id: 'lifting',
    name: LocalizedText(en: 'Lifting Heavy Things', hi: 'Lifting Heavy Things'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Light lifting is fine; avoid straining and very heavy loads.',
      hi: 'Light lifting is fine; avoid straining and very heavy loads.',
    ),
    why: LocalizedText(
      en: 'Pregnancy hormones loosen your ligaments and your balance shifts, so heavy or awkward lifting risks your back more than the baby. Bend at the knees, hold things close, and ask for help with the heavy stuff.',
      hi: 'Pregnancy hormones loosen your ligaments and your balance shifts, so heavy or awkward lifting risks your back more than the baby. Bend at the knees, hold things close, and ask for help with the heavy stuff.',
    ),
    t3: LocalizedText(
      en: 'Take extra care now - your centre of gravity is well forward and strain is easier.',
      hi: 'Take extra care now - your centre of gravity is well forward and strain is easier.',
    ),
    related: ['walking', 'yoga', 'sleeping_back'],
    aliases: ['lifting weights', 'heavy lifting', 'carrying'],
  ),
  CanIEntry(
    id: 'fasting',
    name: LocalizedText(en: 'Fasting', hi: 'Fasting'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Talk to your doctor before fasting - whether it is okay depends on your health and stage.',
      hi: 'Talk to your doctor before fasting - whether it is okay depends on your health and stage.',
    ),
    why: LocalizedText(
      en: 'Steady nutrition and hydration matter a lot in pregnancy. Some shorter or partial fasts may be okay for some mothers; long or strict fasts are often advised against. It is very individual.',
      hi: 'Steady nutrition and hydration matter a lot in pregnancy. Some shorter or partial fasts may be okay for some mothers; long or strict fasts are often advised against. It is very individual.',
    ),
    indian: LocalizedText(
      en: 'For festival vrats, many mothers keep a fruit-and-milk (phalahar) fast rather than a nirjala one - but please confirm with your doctor first.',
      hi: 'For festival vrats, many mothers keep a fruit-and-milk (phalahar) fast rather than a nirjala one - but please confirm with your doctor first.',
    ),
    related: ['water', 'street_food'],
    aliases: ['vrat', 'upvas', 'roza', 'navratri'],
  ),

  // ==========================================================================
  //  EXPANDED LIBRARY (toward the ~250-item set). Concise general guidance,
  //  English-first, PENDING MEDICAL REVIEW. Tone matches the curated set.
  // ==========================================================================

  // ---- EAT ----
  CanIEntry(id: 'apple', name: LocalizedText(en: 'Apple', hi: 'Apple'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Apples are a great everyday fruit in pregnancy.'), why: _t('Good fibre and vitamins that help digestion and energy. Wash well before eating.'), aliases: ['seb', 'apple']),
  CanIEntry(id: 'orange', name: LocalizedText(en: 'Orange / Citrus', hi: 'Orange / Citrus'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oranges and citrus fruits are a healthy choice.'), why: _t('Rich in vitamin C and water, they support immunity and hydration.'), aliases: ['santra', 'citrus', 'mosambi']),
  CanIEntry(id: 'grapes', name: LocalizedText(en: 'Grapes', hi: 'Grapes'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Grapes are fine in moderation, washed well.'), why: _t('A good source of vitamins; rinse thoroughly and keep portions modest due to natural sugar.'), aliases: ['angur']),
  CanIEntry(id: 'watermelon', name: LocalizedText(en: 'Watermelon', hi: 'Watermelon'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Watermelon is hydrating and safe.'), why: _t('Mostly water with helpful minerals; great in heat. Eat it freshly cut at home, not pre-cut from outside.'), aliases: ['tarbooj']),
  CanIEntry(id: 'muskmelon', name: LocalizedText(en: 'Muskmelon', hi: 'Muskmelon'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Muskmelon is a safe, hydrating fruit.'), why: _t('Light and water-rich; wash the rind and eat it freshly cut at home.'), aliases: ['kharbooja']),
  CanIEntry(id: 'guava', name: LocalizedText(en: 'Guava', hi: 'Guava'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Guava is a nutritious, high-fibre fruit.'), why: _t('Rich in fibre and vitamin C; helps with constipation. Wash well.'), aliases: ['amrood']),
  CanIEntry(id: 'pomegranate', name: LocalizedText(en: 'Pomegranate', hi: 'Pomegranate'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pomegranate is a healthy choice in pregnancy.'), why: _t('Full of iron-supporting nutrients and antioxidants; a gentle, nourishing fruit.'), aliases: ['anar']),
  CanIEntry(id: 'chikoo', name: LocalizedText(en: 'Chikoo (Sapota)', hi: 'Chikoo (Sapota)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chikoo is fine in moderation.'), why: _t('Sweet and energy-giving; enjoy in modest amounts as it is high in natural sugar.'), aliases: ['sapota', 'chiku']),
  CanIEntry(id: 'custard_apple', name: LocalizedText(en: 'Custard Apple', hi: 'Custard Apple'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Custard apple is fine in moderation.'), why: _t('Nutritious and energy-rich; keep portions modest due to its sweetness.'), aliases: ['sitaphal', 'sharifa']),
  CanIEntry(id: 'litchi', name: LocalizedText(en: 'Litchi', hi: 'Litchi'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Litchi is fine in small amounts.'), why: _t('Refreshing and sweet; eat ripe ones in moderation and not on an empty stomach.'), aliases: ['lychee']),
  CanIEntry(id: 'jackfruit', name: LocalizedText(en: 'Jackfruit', hi: 'Jackfruit'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ripe jackfruit is fine in moderation.'), why: _t('Enjoy ripe jackfruit in modest amounts; there is no good reason to fear it in normal quantities.'), aliases: ['kathal']),
  CanIEntry(id: 'dates', name: LocalizedText(en: 'Dates', hi: 'Dates'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dates are a wonderful pregnancy snack.'), why: _t('Rich in iron and natural energy, and often suggested later in pregnancy. Enjoy a few a day.'), aliases: ['khajoor']),
  CanIEntry(id: 'figs', name: LocalizedText(en: 'Figs', hi: 'Figs'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Figs are nutritious and safe.'), why: _t('Good for fibre, calcium and iron, and helpful for digestion. Fresh or soaked dried figs both work.'), aliases: ['anjeer']),
  CanIEntry(id: 'berries', name: LocalizedText(en: 'Berries', hi: 'Berries'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Strawberries and berries are a healthy choice.'), why: _t('Rich in vitamin C and antioxidants; wash thoroughly before eating.'), aliases: ['strawberry', 'blueberry']),
  CanIEntry(id: 'kiwi', name: LocalizedText(en: 'Kiwi', hi: 'Kiwi'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Kiwi is a safe, vitamin-rich fruit.'), why: _t('High in vitamin C and fibre, and gentle on digestion.'), aliases: ['kiwi']),
  CanIEntry(id: 'pear', name: LocalizedText(en: 'Pear', hi: 'Pear'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pears are a safe, gentle fruit.'), why: _t('Good fibre and hydration, and easy on the stomach. Wash well.'), aliases: ['nashpati']),
  CanIEntry(id: 'dry_fruits', name: LocalizedText(en: 'Dry Fruits & Nuts', hi: 'Dry Fruits & Nuts'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dried fruits and nuts are a great snack.'), why: _t('Nutrient-dense energy with iron and good fats; keep portions sensible.'), aliases: ['mewa', 'dry fruits']),
  CanIEntry(id: 'almonds', name: LocalizedText(en: 'Almonds', hi: 'Almonds'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Almonds are a healthy daily snack.'), why: _t('Good fats, protein and vitamin E; a handful a day is lovely. Soaked almonds are easy to digest.'), aliases: ['badam']),
  CanIEntry(id: 'walnuts', name: LocalizedText(en: 'Walnuts', hi: 'Walnuts'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Walnuts are nourishing in pregnancy.'), why: _t('A good source of omega-3 fats that support development; a few a day is plenty.'), aliases: ['akhrot']),
  CanIEntry(id: 'cashews', name: LocalizedText(en: 'Cashews', hi: 'Cashews'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Cashews are fine in moderation.'), why: _t('Tasty and nutritious; keep to a small handful as they are calorie-rich.'), aliases: ['kaju']),
  CanIEntry(id: 'peanuts', name: LocalizedText(en: 'Peanuts', hi: 'Peanuts'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Peanuts are safe unless you are allergic.'), why: _t('A good plant protein; avoid only if you have a known peanut allergy.'), aliases: ['moongphali', 'groundnut']),
  CanIEntry(id: 'makhana', name: LocalizedText(en: 'Makhana', hi: 'Makhana'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Makhana (fox nuts) is a great light snack.'), why: _t('Low in fat and good for a roasted, guilt-free nibble.'), aliases: ['fox nuts', 'lotus seeds']),
  CanIEntry(id: 'sabudana', name: LocalizedText(en: 'Sabudana', hi: 'Sabudana'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Sabudana is safe and easy to digest.'), why: _t('A gentle source of energy, popular during fasts; cook it well.'), aliases: ['tapioca', 'sago']),
  CanIEntry(id: 'spinach', name: LocalizedText(en: 'Spinach & Greens', hi: 'Spinach & Greens'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spinach and leafy greens are excellent.'), why: _t('Rich in iron and folate; wash very well and cook it. Great for pregnancy.'), aliases: ['palak', 'greens', 'saag']),
  CanIEntry(id: 'drumstick', name: LocalizedText(en: 'Drumstick (Moringa)', hi: 'Drumstick (Moringa)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Drumstick is fine cooked in moderation.'), why: _t('Nutritious in cooked dishes like sambar; enjoy in normal food amounts.'), aliases: ['moringa', 'sahjan']),
  CanIEntry(id: 'brinjal', name: LocalizedText(en: 'Brinjal', hi: 'Brinjal'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Brinjal is safe, cooked well.'), why: _t('A normal vegetable; cook it properly. There is no need to avoid it.'), aliases: ['baingan', 'eggplant']),
  CanIEntry(id: 'potato', name: LocalizedText(en: 'Potato', hi: 'Potato'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Potato is safe in pregnancy.'), why: _t('A staple carbohydrate; just balance it with vegetables and protein.'), aliases: ['aloo']),
  CanIEntry(id: 'tomato', name: LocalizedText(en: 'Tomato', hi: 'Tomato'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Tomatoes are safe and healthy.'), why: _t('Rich in vitamins; wash well. Fine raw in salads made at home, or cooked.'), aliases: ['tamatar']),
  CanIEntry(id: 'carrot', name: LocalizedText(en: 'Carrot', hi: 'Carrot'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Carrots are a healthy, safe vegetable.'), why: _t('Good for vitamin A and fibre; wash and peel before eating raw.'), aliases: ['gajar']),
  CanIEntry(id: 'beetroot', name: LocalizedText(en: 'Beetroot', hi: 'Beetroot'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Beetroot is safe and nourishing.'), why: _t('Supports iron levels and adds natural colour; wash well.'), aliases: ['chukandar']),
  CanIEntry(id: 'sprouts', name: LocalizedText(en: 'Sprouts', hi: 'Sprouts'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Sprouts are best eaten cooked, not raw.'), why: _t('Raw sprouts can carry bacteria; lightly steaming or cooking them makes them much safer.'), aliases: ['moong sprouts', 'sprout']),
  CanIEntry(id: 'raw_salad', name: LocalizedText(en: 'Raw Salad', hi: 'Raw Salad'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Salads are healthy if washed very well.'), why: _t('Raw vegetables are good, but wash them thoroughly with clean water; outside salads are the main risk.'), aliases: ['salad', 'raw vegetables']),
  CanIEntry(id: 'mushroom', name: LocalizedText(en: 'Mushroom', hi: 'Mushroom'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Cooked mushrooms are safe.'), why: _t('Common edible mushrooms are fine when cooked well; avoid wild or unfamiliar ones.'), aliases: ['mushroom']),
  CanIEntry(id: 'egg', name: LocalizedText(en: 'Egg', hi: 'Egg'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked eggs are a great protein.'), why: _t('Cook until both white and yolk are firm; avoid runny or raw eggs.'), aliases: ['anda', 'eggs']),
  CanIEntry(id: 'chicken', name: LocalizedText(en: 'Chicken', hi: 'Chicken'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked chicken is safe and nourishing.'), why: _t('A good protein; cook it thoroughly until no pink remains.'), aliases: ['murga', 'chicken']),
  CanIEntry(id: 'mutton', name: LocalizedText(en: 'Mutton', hi: 'Mutton'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Well-cooked mutton is fine in moderation.'), why: _t('A good iron source; cook it thoroughly and keep portions reasonable as it is heavy.'), aliases: ['red meat', 'mutton']),
  CanIEntry(id: 'fish', name: LocalizedText(en: 'Fish', hi: 'Fish'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Most cooked fish is healthy; limit high-mercury types.'), why: _t('Low-mercury fish like rohu are good for development; limit large fish such as king mackerel and shark.'), aliases: ['machli']),
  CanIEntry(id: 'prawns', name: LocalizedText(en: 'Prawns', hi: 'Prawns'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked prawns are safe.'), why: _t('Fully cooked prawns and shrimp are fine; avoid raw or undercooked seafood.'), aliases: ['shrimp', 'jhinga']),
  CanIEntry(id: 'high_mercury_fish', name: LocalizedText(en: 'High-Mercury Fish', hi: 'High-Mercury Fish'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Large high-mercury fish are best avoided.'), why: _t('Shark, swordfish and king mackerel can be high in mercury; choose smaller fish instead.'), aliases: ['mercury fish', 'shark', 'swordfish']),
  CanIEntry(id: 'dal', name: LocalizedText(en: 'Dal & Lentils', hi: 'Dal & Lentils'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dal and lentils are excellent in pregnancy.'), why: _t('A staple plant protein with fibre and iron; eat freely.'), aliases: ['lentils', 'pulses']),
  CanIEntry(id: 'soya', name: LocalizedText(en: 'Soya', hi: 'Soya'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Soya is fine in moderation.'), why: _t('A useful protein in tofu, soya chunks or milk; keep to normal food amounts.'), aliases: ['soy', 'soya chunks']),
  CanIEntry(id: 'rajma_chana', name: LocalizedText(en: 'Rajma & Chana', hi: 'Rajma & Chana'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Rajma and chana are healthy, protein-rich foods.'), why: _t('Beans and chickpeas give protein, fibre and iron; soak and cook well.'), aliases: ['kidney beans', 'chickpeas', 'chole']),
  CanIEntry(id: 'milk', name: LocalizedText(en: 'Milk', hi: 'Milk'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pasteurised milk is great in pregnancy.'), why: _t('A good source of calcium and protein; choose pasteurised or boiled milk.'), aliases: ['doodh']),
  CanIEntry(id: 'cheese', name: LocalizedText(en: 'Cheese', hi: 'Cheese'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Hard and pasteurised cheeses are fine; avoid soft unpasteurised ones.'), why: _t('Cheddar and processed cheese are safe; avoid mould-ripened or unpasteurised soft cheeses.'), aliases: ['cheese']),
  CanIEntry(id: 'ghee', name: LocalizedText(en: 'Ghee & Butter', hi: 'Ghee & Butter'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ghee and butter are fine in moderate amounts.'), why: _t('Normal food fats that are fine in cooking; just keep the quantity sensible.'), aliases: ['ghee', 'makkhan', 'butter']),
  CanIEntry(id: 'mawa_sweets', name: LocalizedText(en: 'Mithai (Mawa Sweets)', hi: 'Mithai (Mawa Sweets)'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Enjoy mithai from pasteurised mawa, in moderation.'), why: _t('Khoya sweets are fine occasionally if fresh and hygienic; the concern is adulteration, freshness and sugar.'), aliases: ['mithai', 'khoya', 'barfi', 'sweets']),
  CanIEntry(id: 'oats', name: LocalizedText(en: 'Oats', hi: 'Oats'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oats are a wonderful pregnancy breakfast.'), why: _t('High in fibre, they help digestion and keep you full; pair with milk and fruit.'), aliases: ['oats', 'oatmeal']),
  CanIEntry(id: 'poha', name: LocalizedText(en: 'Poha', hi: 'Poha'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Poha is a light, safe meal.'), why: _t('Easy to digest and can be made iron-rich; a gentle everyday option.'), aliases: ['poha']),
  CanIEntry(id: 'instant_noodles', name: LocalizedText(en: 'Instant Noodles', hi: 'Instant Noodles'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Instant noodles are fine as an occasional treat.'), why: _t('Low in nutrition and high in salt; enjoy once in a while, ideally with added veg and egg.'), aliases: ['maggi', 'noodles']),
  CanIEntry(id: 'fried_snacks', name: LocalizedText(en: 'Fried Snacks', hi: 'Fried Snacks'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Samosa, pakora and the like are fine occasionally.'), why: _t('Tasty but oily; enjoy now and then, ideally freshly made and hygienic.'), aliases: ['samosa', 'pakora', 'kachori', 'fried']),
  CanIEntry(id: 'maida', name: LocalizedText(en: 'Maida (Refined Flour)', hi: 'Maida (Refined Flour)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Foods made of maida are fine in moderation.'), why: _t('Refined flour has little fibre; balance it with whole grains and vegetables.'), aliases: ['refined flour', 'white flour']),
  CanIEntry(id: 'pickle', name: LocalizedText(en: 'Pickle (Achar)', hi: 'Pickle (Achar)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Pickle is fine in small amounts.'), why: _t('It adds flavour but is very high in salt and oil; a little is okay.'), aliases: ['achar']),
  CanIEntry(id: 'saffron', name: LocalizedText(en: 'Saffron (Kesar)', hi: 'Saffron (Kesar)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('A few strands of saffron are fine.'), why: _t('Saffron in milk in tiny culinary amounts is fine; there is no need for large quantities.'), aliases: ['kesar', 'saffron']),
  CanIEntry(id: 'turmeric_milk', name: LocalizedText(en: 'Turmeric / Haldi Doodh', hi: 'Turmeric / Haldi Doodh'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Haldi doodh in normal amounts is comforting and safe.'), why: _t('Turmeric in cooking and a cup of haldi milk is fine; avoid very large supplement doses.'), aliases: ['haldi', 'turmeric', 'golden milk']),
  CanIEntry(id: 'jaggery', name: LocalizedText(en: 'Jaggery (Gud)', hi: 'Jaggery (Gud)'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Jaggery is a fine natural sweetener in moderation.'), why: _t('Often preferred over white sugar and may support iron; still a sugar, so keep it moderate.'), aliases: ['gud', 'gur']),
  CanIEntry(id: 'spices', name: LocalizedText(en: 'Spices & Herbs', hi: 'Spices & Herbs'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Everyday cooking spices and herbs are safe.'), why: _t('Normal culinary amounts of jeera, dhania, ajwain, hing and garlic are fine; only avoid very large medicinal doses.'), aliases: ['jeera', 'cumin', 'ajwain', 'hing', 'garlic', 'dhania', 'masala']),
  CanIEntry(id: 'salt', name: LocalizedText(en: 'Salt', hi: 'Salt'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Use normal amounts of salt; avoid excess.'), why: _t('Some salt is needed, but high salt can worsen swelling and blood pressure; use iodised salt.'), aliases: ['namak', 'sodium']),
  CanIEntry(id: 'sugar', name: LocalizedText(en: 'Sugar', hi: 'Sugar'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Sugar is fine in moderation.'), why: _t('Enjoy sweet things in modest amounts; too much adds empty calories and affects blood sugar.'), aliases: ['cheeni', 'sugar']),
  CanIEntry(id: 'sushi', name: LocalizedText(en: 'Sushi (Raw Fish)', hi: 'Sushi (Raw Fish)'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw-fish sushi is best avoided.'), why: _t('Raw seafood can carry bacteria and parasites; cooked or vegetarian sushi is a safer choice.'), aliases: ['raw fish', 'sushi']),
  CanIEntry(id: 'raw_meat', name: LocalizedText(en: 'Raw / Undercooked Meat', hi: 'Raw / Undercooked Meat'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw or undercooked meat should be avoided.'), why: _t('It can carry infections like toxoplasma; always cook meat thoroughly.'), aliases: ['undercooked meat', 'rare meat']),
  CanIEntry(id: 'deli_meat', name: LocalizedText(en: 'Cold Cuts / Deli Meat', hi: 'Cold Cuts / Deli Meat'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Heat cold cuts until steaming before eating.'), why: _t('Ready-to-eat cold meats can carry listeria; heating them through makes them safer.'), aliases: ['cold cuts', 'salami', 'ham']),
  CanIEntry(id: 'leftovers', name: LocalizedText(en: 'Leftover Food', hi: 'Leftover Food'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Leftovers are fine if stored and reheated properly.'), why: _t('Refrigerate promptly and reheat until piping hot; avoid food that has been left out for long.'), aliases: ['leftovers', 'stale food']),
  CanIEntry(id: 'spicy_food', name: LocalizedText(en: 'Spicy Food', hi: 'Spicy Food'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spicy food is fine if it agrees with you.'), why: _t('It will not harm the baby; it may worsen heartburn for some, so adjust to your comfort.'), aliases: ['spicy', 'teekha']),
  CanIEntry(id: 'chyawanprash', name: LocalizedText(en: 'Chyawanprash', hi: 'Chyawanprash'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chyawanprash is generally fine in small daily amounts.'), why: _t('A traditional tonic that is usually okay; check with your doctor if unsure about the ingredients.'), aliases: ['chyawanprash']),

  // ---- DRINK ----
  CanIEntry(id: 'milkshake', name: LocalizedText(en: 'Milkshake', hi: 'Milkshake'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Homemade milkshakes are a nice, safe treat.'), why: _t('Made with pasteurised milk and fruit they are nourishing; go easy on added sugar.'), aliases: ['shake', 'milkshake']),
  CanIEntry(id: 'fresh_juice', name: LocalizedText(en: 'Fresh Juice', hi: 'Fresh Juice'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Freshly made juice at home is fine.'), why: _t('Drink it fresh and hygienically made; whole fruit is even better for the fibre.'), aliases: ['juice', 'fresh juice']),
  CanIEntry(id: 'packaged_juice', name: LocalizedText(en: 'Packaged Juice', hi: 'Packaged Juice'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Packaged juices are okay occasionally.'), why: _t('They are high in sugar and low in fibre; fresh fruit or fresh juice is better.'), aliases: ['tetra pack juice', 'packaged juice']),
  CanIEntry(id: 'lemon_water', name: LocalizedText(en: 'Lemon Water', hi: 'Lemon Water'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lemon water is safe and refreshing.'), why: _t('Hydrating and can ease nausea; a lovely everyday drink.'), aliases: ['nimbu pani', 'shikanji']),
  CanIEntry(id: 'sugarcane_juice', name: LocalizedText(en: 'Sugarcane Juice', hi: 'Sugarcane Juice'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Sugarcane juice is fine if hygienic and fresh.'), why: _t('Refreshing and energy-giving; the concern is roadside hygiene, so prefer clean, fresh sources.'), aliases: ['ganne ka ras']),
  CanIEntry(id: 'lassi', name: LocalizedText(en: 'Lassi', hi: 'Lassi'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lassi made from fresh curd is safe and cooling.'), why: _t('A probiotic, calcium-rich drink; sweet or salted, made hygienically.'), aliases: ['lassi']),
  CanIEntry(id: 'energy_drinks', name: LocalizedText(en: 'Energy Drinks', hi: 'Energy Drinks'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Energy drinks are best avoided.'), why: _t('They are high in caffeine and stimulants that are not recommended in pregnancy.'), aliases: ['red bull', 'energy drink']),
  CanIEntry(id: 'herbal_tea', name: LocalizedText(en: 'Herbal Tea', hi: 'Herbal Tea'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Check each herbal tea before drinking.'), why: _t('Some herbs are not advised in pregnancy; ginger and mild ones are usually fine, but confirm the blend.'), aliases: ['herbal tea', 'tulsi tea']),
  CanIEntry(id: 'smoothie', name: LocalizedText(en: 'Smoothie', hi: 'Smoothie'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Homemade fruit smoothies are nourishing.'), why: _t('A great way to get fruit, curd and nuts; make them fresh and hygienic.'), aliases: ['smoothie']),
  CanIEntry(id: 'kombucha', name: LocalizedText(en: 'Kombucha', hi: 'Kombucha'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Kombucha is best avoided in pregnancy.'), why: _t('It is fermented, sometimes unpasteurised and slightly alcoholic, so it is safer to skip.'), aliases: ['kombucha']),
  CanIEntry(id: 'diet_soda', name: LocalizedText(en: 'Diet Soda', hi: 'Diet Soda'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Diet sodas are okay occasionally.'), why: _t('Artificial sweeteners are generally considered fine in small amounts, but these drinks add little value.'), aliases: ['diet coke', 'zero soda']),
  CanIEntry(id: 'aam_panna', name: LocalizedText(en: 'Aam Panna', hi: 'Aam Panna'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Aam panna is a safe, cooling summer drink.'), why: _t('Hydrating and good for the heat; make it fresh and hygienically.'), aliases: ['aam panna']),
  CanIEntry(id: 'badam_milk', name: LocalizedText(en: 'Badam Milk', hi: 'Badam Milk'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Badam milk is a nourishing, safe drink.'), why: _t('Milk with almonds gives calcium and good fats; lovely warm or cold.'), aliases: ['almond milk', 'badam milk']),
  CanIEntry(id: 'decaf_coffee', name: LocalizedText(en: 'Decaf Coffee', hi: 'Decaf Coffee'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Decaf coffee is a good low-caffeine choice.'), why: _t('It has very little caffeine, so it is gentle; a nice swap if you miss coffee.'), aliases: ['decaf']),
  CanIEntry(id: 'jaljeera', name: LocalizedText(en: 'Jaljeera', hi: 'Jaljeera'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Jaljeera is safe and aids digestion.'), why: _t('A cumin-based drink that can settle the stomach; make it hygienically.'), aliases: ['jaljeera']),
  CanIEntry(id: 'ors', name: LocalizedText(en: 'ORS / Electrolytes', hi: 'ORS / Electrolytes'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('ORS and electrolyte drinks help when you are dehydrated.'), why: _t('Useful in heat, vomiting or weakness; use standard ORS as directed.'), aliases: ['ors', 'electral', 'glucose water']),

  // ---- TAKE (medicines / supplements) ----
  CanIEntry(id: 'aspirin', name: LocalizedText(en: 'Aspirin', hi: 'Aspirin'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Only take aspirin if your doctor prescribes it.'), why: _t('Low-dose aspirin is sometimes prescribed in pregnancy, but it should never be self-started.'), aliases: ['aspirin', 'disprin', 'ecosprin']),
  CanIEntry(id: 'cetirizine', name: LocalizedText(en: 'Antihistamines (Cetirizine)', hi: 'Antihistamines (Cetirizine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Ask your doctor before taking allergy medicines.'), why: _t('Some antihistamines are used in pregnancy, but confirm the choice and dose with your doctor.'), aliases: ['cetirizine', 'allergy', 'antihistamine', 'avil']),
  CanIEntry(id: 'antacids', name: LocalizedText(en: 'Antacids', hi: 'Antacids'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Most simple antacids are fine for heartburn.'), why: _t('Calcium or magnesium based antacids are commonly used; follow the label, and your doctor if you need them often.'), aliases: ['digene', 'eno', 'gelusil', 'acidity']),
  CanIEntry(id: 'pantoprazole', name: LocalizedText(en: 'Acidity Tablets (Pantoprazole)', hi: 'Acidity Tablets (Pantoprazole)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Acidity tablets like pantoprazole need your doctor okay.'), why: _t('These are sometimes used in pregnancy; take them on medical advice rather than on your own.'), aliases: ['pan', 'omeprazole', 'pantoprazole', 'rabeprazole']),
  CanIEntry(id: 'vitamin_c', name: LocalizedText(en: 'Vitamin C', hi: 'Vitamin C'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin C from food or a prescribed dose is fine.'), why: _t('Helpful for immunity and iron absorption; avoid very high supplement doses unless advised.'), aliases: ['vitamin c']),
  CanIEntry(id: 'multivitamin', name: LocalizedText(en: 'Prenatal Multivitamin', hi: 'Prenatal Multivitamin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Prenatal multivitamins are usually recommended.'), why: _t('Take a pregnancy-specific multivitamin as advised; avoid stacking extra high-dose vitamins on top.'), aliases: ['multivitamin', 'prenatal vitamin']),
  CanIEntry(id: 'omega3', name: LocalizedText(en: 'Omega-3 (DHA)', hi: 'Omega-3 (DHA)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Omega-3 (DHA) supplements are commonly recommended.'), why: _t('They support brain and eye development; take a pregnancy-safe one as advised.'), aliases: ['dha', 'fish oil', 'omega 3']),
  CanIEntry(id: 'b12', name: LocalizedText(en: 'Vitamin B12', hi: 'Vitamin B12'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin B12 is fine and often recommended.'), why: _t('Important for you and your baby, especially on a vegetarian diet; take it as advised.'), aliases: ['b12', 'cobalamin']),
  CanIEntry(id: 'ondansetron', name: LocalizedText(en: 'Anti-Nausea (Ondansetron)', hi: 'Anti-Nausea (Ondansetron)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Anti-nausea medicines should be doctor-prescribed.'), why: _t('Medicines like ondansetron are used for severe vomiting, but only on medical advice.'), aliases: ['ondansetron', 'emeset', 'vomiting tablet']),
  CanIEntry(id: 'doxylamine', name: LocalizedText(en: 'Morning-Sickness Tablet (Doxylamine)', hi: 'Morning-Sickness Tablet (Doxylamine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Doxylamine for morning sickness needs a prescription.'), why: _t('A common, doctor-prescribed option for nausea, often with vitamin B6; use as directed.'), aliases: ['doxinate', 'doxylamine', 'morning sickness tablet']),
  CanIEntry(id: 'cough_syrup', name: LocalizedText(en: 'Cough Syrup', hi: 'Cough Syrup'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check with your doctor before any cough syrup.'), why: _t('Some contain ingredients best avoided in pregnancy; your doctor can suggest a safe one.'), aliases: ['cough syrup', 'benadryl']),
  CanIEntry(id: 'lozenges', name: LocalizedText(en: 'Throat Lozenges', hi: 'Throat Lozenges'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Plain throat lozenges are generally fine.'), why: _t('Simple menthol or honey-lemon lozenges are okay for a sore throat; avoid medicated ones without advice.'), aliases: ['throat lozenge', 'strepsils']),
  CanIEntry(id: 'vicks_balm', name: LocalizedText(en: 'Vicks / Balm', hi: 'Vicks / Balm'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vicks and balms for external use are generally fine.'), why: _t('Applied on the skin or used for steam they are usually okay; do not swallow them.'), aliases: ['vicks', 'balm', 'vaporub', 'zandu balm']),
  CanIEntry(id: 'laxative', name: LocalizedText(en: 'Laxatives', hi: 'Laxatives'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Try diet and fluids first; ask before laxatives.'), why: _t('Fibre, water and isabgol help constipation; stronger laxatives need medical advice.'), aliases: ['laxative', 'dulcolax', 'cremaffin']),
  CanIEntry(id: 'isabgol', name: LocalizedText(en: 'Isabgol (Psyllium)', hi: 'Isabgol (Psyllium)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Isabgol is a safe option for constipation.'), why: _t('A gentle fibre that eases constipation; take it with plenty of water.'), aliases: ['psyllium', 'isabgol', 'fibre']),
  CanIEntry(id: 'probiotics', name: LocalizedText(en: 'Probiotics', hi: 'Probiotics'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Probiotics are generally considered safe.'), why: _t('Curd and probiotic supplements can help digestion; choose a reputable one.'), aliases: ['probiotic']),
  CanIEntry(id: 'ashwagandha', name: LocalizedText(en: 'Ashwagandha', hi: 'Ashwagandha'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Ashwagandha is best avoided in pregnancy.'), why: _t('This herb is traditionally not recommended during pregnancy; skip it unless your doctor says otherwise.'), aliases: ['ashwagandha']),
  CanIEntry(id: 'ayurvedic_medicine', name: LocalizedText(en: 'Ayurvedic / Herbal Medicine', hi: 'Ayurvedic / Herbal Medicine'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check any ayurvedic or herbal medicine with your doctor.'), why: _t('Natural does not always mean safe in pregnancy, and product quality varies; confirm first.'), aliases: ['ayurvedic', 'herbal medicine', 'kadha', 'churan']),
  CanIEntry(id: 'homeopathy', name: LocalizedText(en: 'Homeopathy', hi: 'Homeopathy'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Discuss homeopathic remedies with your doctor.'), why: _t('If you use homeopathy, let your doctor know; do not stop prescribed medicines for it.'), aliases: ['homeopathy']),
  CanIEntry(id: 'sleeping_pills', name: LocalizedText(en: 'Sleeping Pills', hi: 'Sleeping Pills'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Avoid sleeping pills unless prescribed.'), why: _t('Most sedatives are not recommended; speak to your doctor about safe ways to sleep better.'), aliases: ['sleeping pills', 'sedative', 'melatonin']),
  CanIEntry(id: 'diclofenac', name: LocalizedText(en: 'Diclofenac / Nimesulide', hi: 'Diclofenac / Nimesulide'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('These painkillers are generally avoided in pregnancy.'), why: _t('They are anti-inflammatories usually not advised, especially later; paracetamol is preferred.'), aliases: ['diclofenac', 'voveran', 'nimesulide']),
  CanIEntry(id: 'antifungal_cream', name: LocalizedText(en: 'Antifungal / Antiseptic Cream', hi: 'Antifungal / Antiseptic Cream'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check skin creams like antifungals with your doctor.'), why: _t('Many topical creams are used in pregnancy, but confirm the specific one is suitable.'), aliases: ['antifungal', 'candid', 'betadine', 'antiseptic']),
  CanIEntry(id: 'deworming', name: LocalizedText(en: 'Deworming Tablet', hi: 'Deworming Tablet'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Deworming should be timed and approved by your doctor.'), why: _t('Some deworming medicines are delayed in pregnancy; let your doctor decide the timing.'), aliases: ['deworming', 'albendazole']),
  CanIEntry(id: 'thyroid_medicine', name: LocalizedText(en: 'Thyroid Medicine', hi: 'Thyroid Medicine'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Continue your thyroid medicine as prescribed.'), why: _t('Thyroid tablets are important and usually continued in pregnancy; your doctor will adjust the dose.'), aliases: ['thyronorm', 'thyroid', 'eltroxin']),
  CanIEntry(id: 'bp_medicine', name: LocalizedText(en: 'Blood Pressure Medicine', hi: 'Blood Pressure Medicine'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Never stop or change BP medicine on your own.'), why: _t('Some BP medicines are switched in pregnancy; your doctor will choose a safe one and adjust it.'), aliases: ['blood pressure medicine', 'bp tablet']),
  CanIEntry(id: 'insulin', name: LocalizedText(en: 'Insulin', hi: 'Insulin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Insulin is safe and often used in pregnancy.'), why: _t('It does not cross to the baby and is the usual treatment when needed; take it as prescribed.'), aliases: ['insulin']),
  CanIEntry(id: 'vaccines', name: LocalizedText(en: 'Vaccines (TT / Flu / COVID)', hi: 'Vaccines (TT / Flu / COVID)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Recommended pregnancy vaccines are safe and protective.'), why: _t('Tetanus (TT/Tdap), flu and COVID vaccination are advised in pregnancy; follow your doctor for timing.'), aliases: ['tt', 'tdap', 'tetanus', 'flu shot', 'covid vaccine', 'vaccine']),

  // ---- DO (activities, beauty, lifestyle) ----
  CanIEntry(id: 'driving', name: LocalizedText(en: 'Driving', hi: 'Driving'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Driving is fine while you are comfortable.'), why: _t('Safe in an uncomplicated pregnancy; keep the seatbelt low under the bump and take breaks on long drives.'), aliases: ['driving', 'car']),
  CanIEntry(id: 'cycling', name: LocalizedText(en: 'Cycling', hi: 'Cycling'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle cycling is okay early on if you are used to it.'), why: _t('Balance changes as the bump grows, so many switch to a stationary bike later. Avoid busy traffic and falls.'), aliases: ['cycling', 'bicycle']),
  CanIEntry(id: 'running', name: LocalizedText(en: 'Running / Jogging', hi: 'Running / Jogging'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Light running is okay if you already run; listen to your body.'), why: _t('Continue gently if you are used to it; stop if you feel pain, dizziness or pressure, and stay hydrated.'), aliases: ['running', 'jogging', 'jog']),
  CanIEntry(id: 'dancing', name: LocalizedText(en: 'Dancing', hi: 'Dancing'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Gentle dancing is a joyful, safe way to move.'), why: _t('Light dancing is great; avoid jumps, spins and falls, especially later on.'), aliases: ['dance', 'garba']),
  CanIEntry(id: 'household_chores', name: LocalizedText(en: 'Household Chores', hi: 'Household Chores'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Normal household work is fine; avoid strain.'), why: _t('Everyday chores are good light activity; avoid heavy lifting, strong chemicals and standing on stools.'), aliases: ['housework', 'chores', 'cleaning']),
  CanIEntry(id: 'climbing_stairs', name: LocalizedText(en: 'Climbing Stairs', hi: 'Climbing Stairs'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Climbing stairs is safe; just go steadily.'), why: _t('Use the railing and take your time; there is no need to avoid stairs in a normal pregnancy.'), aliases: ['stairs', 'steps']),
  CanIEntry(id: 'standing_long', name: LocalizedText(en: 'Standing Long Hours', hi: 'Standing Long Hours'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Long standing is okay but take regular breaks.'), why: _t('Standing for hours can cause swelling and back ache; sit, move and put your feet up when you can.'), aliases: ['standing']),
  CanIEntry(id: 'amusement_rides', name: LocalizedText(en: 'Amusement Rides', hi: 'Amusement Rides'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip roller coasters and jerky rides.'), why: _t('Sudden jolts and forces are best avoided; gentle rides without big drops are a safer choice.'), aliases: ['roller coaster', 'rides']),
  CanIEntry(id: 'trekking', name: LocalizedText(en: 'Trekking / Hiking', hi: 'Trekking / Hiking'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Easy treks are okay; avoid high altitude and rough trails.'), why: _t('Gentle walks in nature are lovely; avoid steep, slippery routes, high altitude and exhaustion.'), aliases: ['trekking', 'hiking']),
  CanIEntry(id: 'gym', name: LocalizedText(en: 'Gym Workouts', hi: 'Gym Workouts'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Continue gentle gym workouts with guidance.'), why: _t('Light strength and cardio are fine if you are used to them; avoid heavy weights, lying flat later, and overheating.'), aliases: ['gym', 'workout', 'exercise']),
  CanIEntry(id: 'keratin', name: LocalizedText(en: 'Keratin / Straightening', hi: 'Keratin / Straightening'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip keratin and chemical straightening for now.'), why: _t('These treatments can contain strong chemicals like formaldehyde; many prefer to wait until after pregnancy.'), aliases: ['keratin', 'smoothening', 'rebonding']),
  CanIEntry(id: 'facial', name: LocalizedText(en: 'Facial / Clean-up', hi: 'Facial / Clean-up'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A gentle facial is fine; skip strong treatments.'), why: _t('Basic facials are relaxing; avoid harsh peels, strong actives and electrical treatments without advice.'), aliases: ['facial', 'clean up', 'hair spa']),
  CanIEntry(id: 'chemical_peel', name: LocalizedText(en: 'Chemical Peel', hi: 'Chemical Peel'), category: CanICategory.doActivity, verdict: CanIVerdict.askDoctor, short: _t('Check chemical peels with your doctor or dermatologist.'), why: _t('Mild peels may be okay, but stronger acids are often postponed; confirm first.'), aliases: ['peel', 'chemical peel']),
  CanIEntry(id: 'botox_fillers', name: LocalizedText(en: 'Botox / Fillers', hi: 'Botox / Fillers'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Botox and fillers are best avoided in pregnancy.'), why: _t('They are elective with limited safety data, so most advise waiting until afterwards.'), aliases: ['botox', 'fillers', 'dermal filler']),
  CanIEntry(id: 'laser_hair', name: LocalizedText(en: 'Laser Hair Removal', hi: 'Laser Hair Removal'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone laser hair removal.'), why: _t('It is not known to be harmful, but skin is more sensitive and it is elective, so waiting is common.'), aliases: ['laser']),
  CanIEntry(id: 'pedicure', name: LocalizedText(en: 'Pedicure / Manicure', hi: 'Pedicure / Manicure'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A pedicure or manicure is a lovely, safe treat.'), why: _t('Enjoy it; choose a clean salon and a gentle calf massage rather than strong pressure points.'), aliases: ['pedicure', 'manicure']),
  CanIEntry(id: 'makeup', name: LocalizedText(en: 'Makeup', hi: 'Makeup'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Everyday makeup is fine.'), why: _t('Normal cosmetics are safe; remove them before bed and patch-test new products as skin can be sensitive.'), aliases: ['makeup', 'cosmetics']),
  CanIEntry(id: 'sunscreen', name: LocalizedText(en: 'Sunscreen', hi: 'Sunscreen'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Sunscreen is safe and a good idea.'), why: _t('It protects skin that can pigment more easily now; mineral sunscreens are a gentle choice.'), aliases: ['sunscreen', 'spf']),
  CanIEntry(id: 'retinol', name: LocalizedText(en: 'Retinol Creams', hi: 'Retinol Creams'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid retinol and strong vitamin-A creams.'), why: _t('Topical retinoids are usually advised against in pregnancy; switch to gentler skincare.'), aliases: ['retinol', 'retinoid', 'anti aging cream']),
  CanIEntry(id: 'perfume', name: LocalizedText(en: 'Perfume / Deodorant', hi: 'Perfume / Deodorant'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Perfume is fine; strong scents may trigger nausea.'), why: _t('It is safe to wear; you may just find heavy fragrances bothersome early on.'), aliases: ['perfume', 'deodorant']),
  CanIEntry(id: 'hair_oil', name: LocalizedText(en: 'Hair Oiling (Champi)', hi: 'Hair Oiling (Champi)'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Oiling your hair is safe and soothing.'), why: _t('A traditional, relaxing routine; a gentle champi is perfectly fine.'), aliases: ['champi', 'hair oil']),
  CanIEntry(id: 'tattoo', name: LocalizedText(en: 'Tattoo / Piercing', hi: 'Tattoo / Piercing'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone new tattoos and piercings.'), why: _t('The main concern is infection risk and unknowns; most prefer to wait until after pregnancy.'), aliases: ['tattoo', 'piercing']),
  CanIEntry(id: 'gel_nails', name: LocalizedText(en: 'Gel / Acrylic Nails', hi: 'Gel / Acrylic Nails'), category: CanICategory.doActivity, verdict: CanIVerdict.moderation, short: _t('Gel or acrylic nails are okay occasionally.'), why: _t('Generally low risk; ensure a ventilated salon, and note nails may be checked during labour.'), aliases: ['gel nails', 'acrylic']),
  CanIEntry(id: 'smoking', name: LocalizedText(en: 'Smoking', hi: 'Smoking'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Smoking should be avoided completely.'), why: _t('It reduces oxygen and nutrients to your baby; stopping at any point helps. Ask for support if you need it.'), aliases: ['smoking', 'cigarette']),
  CanIEntry(id: 'secondhand_smoke', name: LocalizedText(en: 'Secondhand Smoke', hi: 'Secondhand Smoke'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid secondhand smoke as much as you can.'), why: _t('Breathing in others smoke is also harmful; ask people not to smoke around you.'), aliases: ['passive smoking', 'secondhand smoke']),
  CanIEntry(id: 'vaping', name: LocalizedText(en: 'Vaping', hi: 'Vaping'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Vaping and e-cigarettes are best avoided.'), why: _t('They still contain nicotine and other substances that are not safe for the baby.'), aliases: ['vape', 'e cigarette']),
  CanIEntry(id: 'hot_water_bath', name: LocalizedText(en: 'Very Hot Bath', hi: 'Very Hot Bath'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Warm baths are lovely; very hot water is not advised.'), why: _t('Avoid very hot baths that raise your body temperature; keep the water comfortably warm.'), aliases: ['hot bath', 'hot water']),
  CanIEntry(id: 'ac_use', name: LocalizedText(en: 'Air Conditioning', hi: 'Air Conditioning'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Air conditioning is completely fine.'), why: _t('Staying cool and comfortable is good; just avoid sitting directly in a cold draught for long.'), aliases: ['ac', 'air conditioner']),
  CanIEntry(id: 'incense', name: LocalizedText(en: 'Incense (Agarbatti)', hi: 'Incense (Agarbatti)'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use agarbatti and dhoop in a ventilated space.'), why: _t('Occasional use is fine; avoid breathing heavy smoke in a closed room for long periods.'), aliases: ['agarbatti', 'dhoop', 'incense']),
  CanIEntry(id: 'cleaning_chemicals', name: LocalizedText(en: 'Strong Cleaning Chemicals', hi: 'Strong Cleaning Chemicals'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use strong cleaners with care and ventilation.'), why: _t('Wear gloves, open windows and do not mix chemicals; switch to milder products where you can.'), aliases: ['bleach', 'phenyl', 'cleaning chemicals']),
  CanIEntry(id: 'paint_fumes', name: LocalizedText(en: 'Paint Fumes', hi: 'Paint Fumes'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Avoid heavy paint fumes; ventilate well.'), why: _t('Brief exposure is unlikely to harm, but avoid painting projects and strong solvent fumes in closed rooms.'), aliases: ['paint', 'fumes', 'solvent']),
  CanIEntry(id: 'pesticides', name: LocalizedText(en: 'Pesticides / Sprays', hi: 'Pesticides / Sprays'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid pesticides and strong sprays.'), why: _t('Keep away from spraying and treated areas; choose safer pest control and ventilate well.'), aliases: ['pesticide', 'spray']),
  CanIEntry(id: 'pet_cats', name: LocalizedText(en: 'Cats / Litter', hi: 'Cats / Litter'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('You can keep your cat; avoid the litter box.'), why: _t('The concern is toxoplasma from cat faeces, so let someone else clean the litter and wash your hands well.'), aliases: ['cat', 'kitten', 'litter']),
  CanIEntry(id: 'pet_dogs', name: LocalizedText(en: 'Dogs / Pets', hi: 'Dogs / Pets'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Keeping dogs and pets is absolutely fine.'), why: _t('Pets are wonderful company; just wash your hands and keep their vaccinations and hygiene up to date.'), aliases: ['dog', 'pet']),
  CanIEntry(id: 'gardening', name: LocalizedText(en: 'Gardening', hi: 'Gardening'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gardening is fine; wear gloves and wash up.'), why: _t('Soil can carry toxoplasma, so wear gloves and wash your hands well afterwards.'), aliases: ['gardening', 'soil']),
  CanIEntry(id: 'public_transport', name: LocalizedText(en: 'Public Transport', hi: 'Public Transport'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Buses, trains and the metro are fine to use.'), why: _t('Travel as usual; ask for a seat, hold the supports carefully and avoid the most crowded rush hours if you can.'), aliases: ['bus', 'metro', 'train', 'public transport']),
  CanIEntry(id: 'crowded_places', name: LocalizedText(en: 'Crowded Places', hi: 'Crowded Places'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Crowded places are okay; protect against infection.'), why: _t('No special harm, but it is wise to keep distance during illness seasons and wash your hands often.'), aliases: ['crowd', 'festival', 'mela']),
  CanIEntry(id: 'high_heels', name: LocalizedText(en: 'High Heels', hi: 'High Heels'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Low, stable shoes are safer than high heels.'), why: _t('Balance and posture change in pregnancy; flats or small heels reduce the risk of falls and back ache.'), aliases: ['heels', 'high heels']),
  CanIEntry(id: 'tight_clothes', name: LocalizedText(en: 'Tight Clothes', hi: 'Tight Clothes'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Choose comfortable, loose clothing.'), why: _t('Very tight clothing can be uncomfortable and restrict circulation; soft, roomy fits feel better.'), aliases: ['tight clothes']),
  CanIEntry(id: 'massage', name: LocalizedText(en: 'Massage', hi: 'Massage'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle massage is fine; choose a prenatal therapist.'), why: _t('Relaxing for back and legs; avoid strong abdominal pressure and go to someone experienced with pregnancy.'), aliases: ['massage', 'body massage', 'prenatal massage']),
  CanIEntry(id: 'spa', name: LocalizedText(en: 'Spa / Sauna', hi: 'Spa / Sauna'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Enjoy gentle spa treatments; skip heat therapies.'), why: _t('Relaxing massages and facials are fine; avoid saunas, steam rooms and hot tubs that overheat you.'), aliases: ['spa', 'sauna', 'steam']),
  CanIEntry(id: 'meditation', name: LocalizedText(en: 'Meditation', hi: 'Meditation'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Meditation is wonderful in pregnancy.'), why: _t('It eases stress and helps sleep and connection with your baby; practise as often as you like.'), aliases: ['meditation', 'mindfulness', 'pranayam']),
  CanIEntry(id: 'mobile_phone', name: LocalizedText(en: 'Mobile / Microwave', hi: 'Mobile / Microwave'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Using your phone and microwave is safe.'), why: _t('There is no evidence everyday phone use or microwaves harm the baby; just take breaks for your neck and eyes.'), aliases: ['mobile', 'phone', 'radiation', 'microwave']),
  CanIEntry(id: 'stress', name: LocalizedText(en: 'Stress', hi: 'Stress'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Some stress is normal; ongoing stress is worth easing.'), why: _t('Occasional worry is natural; if you feel constantly anxious, rest, talk to someone and tell your doctor.'), aliases: ['stress', 'anxiety', 'tension']),
];

// ---------------------------------------------------------------------------
//  Lookup helpers
// ---------------------------------------------------------------------------

CanIEntry? canIById(String id) {
  for (final e in kCanIEntries) {
    if (e.id == id) return e;
  }
  return null;
}

List<CanIEntry> canIByCategory(CanICategory c) =>
    kCanIEntries.where((e) => e.category == c).toList();

/// Prefix-first search across name + aliases. Returns prefix matches before
/// looser "contains" matches, each group alphabetical.
List<CanIEntry> canISearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final prefix = <CanIEntry>[];
  final contains = <CanIEntry>[];
  for (final e in kCanIEntries) {
    final terms = <String>[e.name.en.toLowerCase(), ...e.aliases.map((a) => a.toLowerCase())];
    if (terms.any((t) => t.startsWith(q))) {
      prefix.add(e);
    } else if (terms.any((t) => t.contains(q))) {
      contains.add(e);
    }
  }
  int byName(CanIEntry a, CanIEntry b) =>
      a.name.en.toLowerCase().compareTo(b.name.en.toLowerCase());
  prefix.sort(byName);
  contains.sort(byName);
  return [...prefix, ...contains];
}
