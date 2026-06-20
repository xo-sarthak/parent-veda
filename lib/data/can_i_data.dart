// =============================================================================
//  Can I?™  — curated seed database
// -----------------------------------------------------------------------------
//  A hand-picked set of the most common, well-established questions (covering
//  all six "popular searches" + a spread across Eat / Drink / Take / Do). This
//  is GENERAL educational guidance, written carefully and conservatively — it is
//  not a medical review, and every answer defers to the mother's own doctor.
//
//  English-first: every entry carries en + hi (today hi mirrors en) so Hindi can
//  be authored later without touching any screen. The schema scales to the full
//  250-item list unchanged.
// =============================================================================

import '../localization/app_language.dart';
import '../models/can_i_entry.dart';

/// Popular-search chips on the Can I? home (emoji + label → entry id).
const List<({String emoji, String label, String id})> kCanIPopular = [
  (emoji: '🍍', label: 'Pineapple', id: 'pineapple'),
  (emoji: '☕', label: 'Coffee', id: 'coffee'),
  (emoji: '💊', label: 'Crocin', id: 'paracetamol'),
  (emoji: '✈️', label: 'Flight travel', id: 'flight_travel'),
  (emoji: '🎨', label: 'Hair colour', id: 'hair_color'),
  (emoji: '❤️', label: 'Sex', id: 'sex'),
];

const List<CanIEntry> kCanIEntries = [
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
      en: 'Raw papaya turns up in salads and some sabzis — that is the form to be careful with. Ripe, sweet papaya as fruit is the safer choice.',
      hi: 'Raw papaya turns up in salads and some sabzis — that is the form to be careful with. Ripe, sweet papaya as fruit is the safer choice.',
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
      en: 'Mango is rich in vitamins A and C and folate. It is also high in natural sugar, so keep portions reasonable — especially if your doctor is watching your blood sugar.',
      hi: 'Mango is rich in vitamins A and C and folate. It is also high in natural sugar, so keep portions reasonable — especially if your doctor is watching your blood sugar.',
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
      en: 'The concern with some soft cheeses is listeria, a bacteria that can grow in unpasteurised dairy. Paneer from pasteurised milk — cooked or freshly made — sidesteps that.',
      hi: 'The concern with some soft cheeses is listeria, a bacteria that can grow in unpasteurised dairy. Paneer from pasteurised milk — cooked or freshly made — sidesteps that.',
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
      en: 'Chocolate contains a little caffeine, so it counts towards your daily caffeine total. A few squares are a lovely treat — just keep the overall amount sensible.',
      hi: 'Chocolate contains a little caffeine, so it counts towards your daily caffeine total. A few squares are a lovely treat — just keep the overall amount sensible.',
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
      en: 'It depends entirely on hygiene and freshness — the risk is contamination, not the dish itself.',
      hi: 'It depends entirely on hygiene and freshness — the risk is contamination, not the dish itself.',
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
      en: 'The usual guidance is to keep total caffeine under roughly 200mg a day. Remember it adds up across coffee, tea, cola and chocolate — not coffee alone.',
      hi: 'The usual guidance is to keep total caffeine under roughly 200mg a day. Remember it adds up across coffee, tea, cola and chocolate — not coffee alone.',
    ),
    t1: LocalizedText(
      en: 'Many mothers naturally go off coffee in the first trimester — listen to that.',
      hi: 'Many mothers naturally go off coffee in the first trimester — listen to that.',
    ),
    indian: LocalizedText(
      en: 'A strong South-Indian filter coffee can be higher in caffeine than you think — one a day is a reasonable ceiling.',
      hi: 'A strong South-Indian filter coffee can be higher in caffeine than you think — one a day is a reasonable ceiling.',
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
      en: 'Regular tea in moderation is fine — just mind the caffeine total.',
      hi: 'Regular tea in moderation is fine — just mind the caffeine total.',
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
      en: 'Nariyal paani is widely recommended — drink it fresh from a tender coconut rather than a sugary packaged version.',
      hi: 'Nariyal paani is widely recommended — drink it fresh from a tender coconut rather than a sugary packaged version.',
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
      en: 'Drink plenty — staying well hydrated is one of the simplest good habits.',
      hi: 'Drink plenty — staying well hydrated is one of the simplest good habits.',
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
      en: 'Paracetamol is generally considered the preferred choice for fever or pain — lowest dose that helps, for the shortest time.',
      hi: 'Paracetamol is generally considered the preferred choice for fever or pain — lowest dose that helps, for the shortest time.',
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
      en: 'Generally avoided in pregnancy — especially in the third trimester. Ask your doctor first.',
      hi: 'Generally avoided in pregnancy — especially in the third trimester. Ask your doctor first.',
    ),
    why: LocalizedText(
      en: 'Ibuprofen is an anti-inflammatory (NSAID) that is usually not recommended in pregnancy, particularly later on. Paracetamol is normally suggested instead.',
      hi: 'Ibuprofen is an anti-inflammatory (NSAID) that is usually not recommended in pregnancy, particularly later on. Paracetamol is normally suggested instead.',
    ),
    t3: LocalizedText(
      en: 'In the third trimester it is best avoided altogether — it can affect the baby. Do not take it without your doctor.',
      hi: 'In the third trimester it is best avoided altogether — it can affect the baby. Do not take it without your doctor.',
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
      en: 'Best not taken on your own — it contains ibuprofen. Check with your doctor.',
      hi: 'Best not taken on your own — it contains ibuprofen. Check with your doctor.',
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
      en: 'Some are safe in pregnancy and some are not — only take antibiotics your doctor prescribes.',
      hi: 'Some are safe in pregnancy and some are not — only take antibiotics your doctor prescribes.',
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
      en: 'Folic acid is recommended in pregnancy — take it as your doctor advises.',
      hi: 'Folic acid is recommended in pregnancy — take it as your doctor advises.',
    ),
    why: LocalizedText(
      en: 'It supports your baby\'s early brain and spine development, which is why it is advised from before conception through early pregnancy. It is one of the few things actively encouraged.',
      hi: 'It supports your baby\'s early brain and spine development, which is why it is advised from before conception through early pregnancy. It is one of the few things actively encouraged.',
    ),
    t1: LocalizedText(
      en: 'Most important in the first trimester (and ideally before) — do not skip it.',
      hi: 'Most important in the first trimester (and ideally before) — do not skip it.',
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
      en: 'Iron is commonly recommended — take the dose your doctor prescribes.',
      hi: 'Iron is commonly recommended — take the dose your doctor prescribes.',
    ),
    why: LocalizedText(
      en: 'Your blood volume rises in pregnancy, so iron needs go up and many mothers are advised supplements. It can cause constipation — fluids and fibre help.',
      hi: 'Your blood volume rises in pregnancy, so iron needs go up and many mothers are advised supplements. It can cause constipation — fluids and fibre help.',
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
      en: 'Air travel is generally fine in an uncomplicated pregnancy — usually most comfortable in the second trimester.',
      hi: 'Air travel is generally fine in an uncomplicated pregnancy — usually most comfortable in the second trimester.',
    ),
    why: LocalizedText(
      en: 'Flying does not harm a low-risk pregnancy. On long flights, walk and stretch, keep hydrated, and wear your seatbelt low under the bump. Always clear travel with your doctor first.',
      hi: 'Flying does not harm a low-risk pregnancy. On long flights, walk and stretch, keep hydrated, and wear your seatbelt low under the bump. Always clear travel with your doctor first.',
    ),
    t2: LocalizedText(
      en: 'Usually the easiest window to travel — nausea has eased and the bump is still manageable.',
      hi: 'Usually the easiest window to travel — nausea has eased and the bump is still manageable.',
    ),
    t3: LocalizedText(
      en: 'Many airlines restrict travel after about 36 weeks and may ask for a doctor\'s note — check before booking.',
      hi: 'Many airlines restrict travel after about 36 weeks and may ask for a doctor\'s note — check before booking.',
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
      en: 'Usually fine — break the journey often to move, stretch and use the toilet.',
      hi: 'Usually fine — break the journey often to move, stretch and use the toilet.',
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
      en: 'It is gentle cardio that helps your mood, sleep, digestion and stamina for labour — with almost no downside. Comfortable shoes and a steady pace are all you need.',
      hi: 'It is gentle cardio that helps your mood, sleep, digestion and stamina for labour — with almost no downside. Comfortable shoes and a steady pace are all you need.',
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
      en: 'Natural henna (mehndi) is a popular, gentler alternative for colour — patch-test first, and avoid "black henna" which can contain harsh chemicals.',
      hi: 'Natural henna (mehndi) is a popular, gentler alternative for colour — patch-test first, and avoid "black henna" which can contain harsh chemicals.',
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
      en: 'Waxing is generally fine — your skin may just be more sensitive now.',
      hi: 'Waxing is generally fine — your skin may just be more sensitive now.',
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
      en: 'Your baby is well protected by the womb and fluid, so intimacy will not harm them. Comfort changes as the bump grows — adjust as needed.',
      hi: 'Your baby is well protected by the womb and fluid, so intimacy will not harm them. Comfort changes as the bump grows — adjust as needed.',
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
      en: 'A good time to get used to side-sleeping — tuck a pillow behind your back and between your knees.',
      hi: 'A good time to get used to side-sleeping — tuck a pillow behind your back and between your knees.',
    ),
    t3: LocalizedText(
      en: 'Prefer the left side. If you wake up on your back, just turn over — no need to panic.',
      hi: 'Prefer the left side. If you wake up on your back, just turn over — no need to panic.',
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
      en: 'Use them — mosquito-borne illness is the bigger risk — but prefer gentler options and good ventilation.',
      hi: 'Use them — mosquito-borne illness is the bigger risk — but prefer gentler options and good ventilation.',
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
      en: 'Routine dental care is safe and important — just tell your dentist you are pregnant.',
      hi: 'Routine dental care is safe and important — just tell your dentist you are pregnant.',
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
      en: 'Elective imaging is usually postponed during pregnancy. When an X-ray is genuinely needed (say after an injury), the dose is small and your abdomen is shielded — always tell the team you are pregnant.',
      hi: 'Elective imaging is usually postponed during pregnancy. When an X-ray is genuinely needed (say after an injury), the dose is small and your abdomen is shielded — always tell the team you are pregnant.',
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
      en: 'Best avoided — getting overheated is not recommended in pregnancy.',
      hi: 'Best avoided — getting overheated is not recommended in pregnancy.',
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
      en: 'Take extra care now — your centre of gravity is well forward and strain is easier.',
      hi: 'Take extra care now — your centre of gravity is well forward and strain is easier.',
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
      en: 'Talk to your doctor before fasting — whether it is okay depends on your health and stage.',
      hi: 'Talk to your doctor before fasting — whether it is okay depends on your health and stage.',
    ),
    why: LocalizedText(
      en: 'Steady nutrition and hydration matter a lot in pregnancy. Some shorter or partial fasts may be okay for some mothers; long or strict fasts are often advised against. It is very individual.',
      hi: 'Steady nutrition and hydration matter a lot in pregnancy. Some shorter or partial fasts may be okay for some mothers; long or strict fasts are often advised against. It is very individual.',
    ),
    indian: LocalizedText(
      en: 'For festival vrats, many mothers keep a fruit-and-milk (phalahar) fast rather than a nirjala one — but please confirm with your doctor first.',
      hi: 'For festival vrats, many mothers keep a fruit-and-milk (phalahar) fast rather than a nirjala one — but please confirm with your doctor first.',
    ),
    related: ['water', 'street_food'],
    aliases: ['vrat', 'upvas', 'roza', 'navratri'],
  ),
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
