// =============================================================================
//  Is it safe? — the groups, the "asked most" dozen, and the swaps
// -----------------------------------------------------------------------------
//  2026-09-19, the Is it safe? door. The 193 entries in `can_i_data.dart`
//  carry four categories (eat / drink / take / do) and nothing finer, so the
//  category screen was 74 rows under "Eat". This file is the finer grain,
//  kept OUT of the entries on purpose: a grouping is one editable table, so
//  moving "Sabudana" from Grains to Fasting is one line here and no entry is
//  touched. A test holds the invariant that every entry is in exactly one
//  group, so a new entry cannot land ungrouped by accident.
//
//  The verdict never lives here. This file says where a thing sits on the
//  shelf; the entry says whether she may have it.
// =============================================================================

import '../localization/app_language.dart';
import '../models/can_i_entry.dart';
import 'can_i_data.dart';

class CanIGroup {
  const CanIGroup({
    required this.id,
    required this.label,
    required this.category,
    required this.entryIds,
  });

  final String id;
  final String label;
  final CanICategory category;
  final List<String> entryIds;
}

const List<CanIGroup> kCanIGroups = [
  // ---- EAT ------------------------------------------------------------------
  CanIGroup(id: 'fruits', label: 'Fruits', category: CanICategory.eat, entryIds: [
    'papaya', 'pineapple', 'mango', 'banana', 'apple', 'orange', 'grapes',
    'watermelon', 'muskmelon', 'guava', 'pomegranate', 'chikoo', 'custard_apple',
    'litchi', 'jackfruit', 'dates', 'figs', 'berries', 'kiwi', 'pear',
  ]),
  CanIGroup(id: 'nuts', label: 'Nuts and dry fruits', category: CanICategory.eat, entryIds: [
    'dry_fruits', 'almonds', 'walnuts', 'cashews', 'peanuts', 'makhana',
  ]),
  CanIGroup(id: 'vegetables', label: 'Vegetables and greens', category: CanICategory.eat, entryIds: [
    'spinach', 'drumstick', 'brinjal', 'potato', 'tomato', 'carrot', 'beetroot',
    'sprouts', 'raw_salad', 'mushroom',
  ]),
  CanIGroup(id: 'protein', label: 'Eggs, meat and fish', category: CanICategory.eat, entryIds: [
    'egg', 'chicken', 'mutton', 'fish', 'prawns', 'high_mercury_fish', 'sushi',
    'raw_meat', 'deli_meat',
  ]),
  CanIGroup(id: 'dairy', label: 'Dairy', category: CanICategory.eat, entryIds: [
    'paneer', 'curd', 'milk', 'cheese', 'ghee',
  ]),
  CanIGroup(id: 'grains', label: 'Grains and dal', category: CanICategory.eat, entryIds: [
    'dal', 'soya', 'rajma_chana', 'oats', 'poha', 'sabudana', 'maida',
  ]),
  CanIGroup(id: 'sweets_snacks', label: 'Sweets and snacks', category: CanICategory.eat, entryIds: [
    'chocolate', 'honey', 'mawa_sweets', 'instant_noodles', 'fried_snacks',
    'pickle', 'jaggery', 'sugar', 'chyawanprash',
  ]),
  CanIGroup(id: 'spices', label: 'Spices and the kitchen', category: CanICategory.eat, entryIds: [
    'ginger', 'saffron', 'turmeric_milk', 'spices', 'salt', 'spicy_food',
  ]),
  CanIGroup(id: 'eating_out', label: 'Street food and eating out', category: CanICategory.eat, entryIds: [
    'street_food', 'leftovers',
  ]),
  // ---- DRINK ----------------------------------------------------------------
  CanIGroup(id: 'tea_coffee', label: 'Tea and coffee', category: CanICategory.drink, entryIds: [
    'coffee', 'tea', 'green_tea', 'decaf_coffee', 'herbal_tea',
  ]),
  CanIGroup(id: 'cool_drinks', label: 'Cool drinks', category: CanICategory.drink, entryIds: [
    'water', 'coconut_water', 'buttermilk', 'lassi', 'lemon_water', 'aam_panna',
    'jaljeera', 'badam_milk', 'ors', 'smoothie', 'milkshake',
  ]),
  CanIGroup(id: 'juices', label: 'Juices', category: CanICategory.drink, entryIds: [
    'fresh_juice', 'packaged_juice', 'sugarcane_juice',
  ]),
  CanIGroup(id: 'soda_alcohol', label: 'Soda, energy drinks and alcohol', category: CanICategory.drink, entryIds: [
    'alcohol', 'soft_drinks', 'diet_soda', 'energy_drinks', 'kombucha',
  ]),
  // ---- TAKE -----------------------------------------------------------------
  CanIGroup(id: 'pain_fever', label: 'Pain and fever', category: CanICategory.take, entryIds: [
    'paracetamol', 'ibuprofen', 'combiflam', 'aspirin', 'diclofenac',
  ]),
  CanIGroup(id: 'cold_cough', label: 'Cold, cough and allergy', category: CanICategory.take, entryIds: [
    'cetirizine', 'cough_syrup', 'lozenges', 'vicks_balm', 'antibiotics',
  ]),
  CanIGroup(id: 'stomach', label: 'Stomach and nausea', category: CanICategory.take, entryIds: [
    'antacids', 'pantoprazole', 'ondansetron', 'doxylamine', 'laxative',
    'isabgol', 'probiotics', 'deworming', 'antifungal_cream',
  ]),
  CanIGroup(id: 'supplements', label: 'Supplements', category: CanICategory.take, entryIds: [
    'folic_acid', 'iron', 'calcium', 'vitamin_d', 'vitamin_c', 'multivitamin',
    'omega3', 'b12',
  ]),
  CanIGroup(id: 'ongoing', label: 'Ongoing conditions and vaccines', category: CanICategory.take, entryIds: [
    'thyroid_medicine', 'bp_medicine', 'insulin', 'vaccines', 'sleeping_pills',
  ]),
  CanIGroup(id: 'herbal', label: 'Ayurvedic and herbal', category: CanICategory.take, entryIds: [
    'ashwagandha', 'ayurvedic_medicine', 'homeopathy',
  ]),
  // ---- DO -------------------------------------------------------------------
  CanIGroup(id: 'travel', label: 'Travel and getting about', category: CanICategory.doActivity, entryIds: [
    'flight_travel', 'long_travel', 'driving', 'public_transport', 'crowded_places',
    'amusement_rides',
  ]),
  CanIGroup(id: 'exercise', label: 'Exercise and effort', category: CanICategory.doActivity, entryIds: [
    'yoga', 'swimming', 'walking', 'cycling', 'running', 'dancing', 'gym', 'trekking',
    'climbing_stairs', 'lifting', 'standing_long', 'household_chores',
  ]),
  CanIGroup(id: 'beauty', label: 'Hair, skin and beauty', category: CanICategory.doActivity, entryIds: [
    'hair_color', 'waxing', 'nail_polish', 'keratin', 'facial', 'chemical_peel',
    'botox_fillers', 'laser_hair', 'pedicure', 'makeup', 'sunscreen', 'retinol',
    'perfume', 'hair_oil', 'tattoo', 'gel_nails', 'high_heels', 'tight_clothes',
  ]),
  CanIGroup(id: 'home', label: 'Around the house', category: CanICategory.doActivity, entryIds: [
    'mosquito_repellent', 'ac_use', 'incense', 'cleaning_chemicals', 'paint_fumes',
    'pesticides', 'pet_cats', 'pet_dogs', 'gardening', 'mobile_phone',
    'hot_water_bath', 'sauna', 'spa', 'massage',
  ]),
  CanIGroup(id: 'rest', label: 'Rest, intimacy and mind', category: CanICategory.doActivity, entryIds: [
    'sleeping_back', 'sex', 'meditation', 'stress', 'fasting',
  ]),
  CanIGroup(id: 'smoke', label: 'Smoke', category: CanICategory.doActivity, entryIds: [
    'smoking', 'secondhand_smoke', 'vaping',
  ]),
  CanIGroup(id: 'clinic', label: 'Dentist and X-ray', category: CanICategory.doActivity, entryIds: [
    'dental', 'xray',
  ]),
];

/// The twelve on the welcome grid — the questions every pregnancy asks in
/// its first month, in the order they get asked. The old six-chip
/// `kCanIPopular` (emoji + label) is superseded; it stays in
/// `can_i_data.dart` for revert.
const List<String> kCanIAskedMost = [
  'papaya', 'coffee', 'paracetamol', 'pineapple', 'tea', 'flight_travel',
  'sex', 'hair_color', 'paneer', 'street_food', 'sleeping_back', 'mango',
];

Map<String, CanIGroup>? _groupByEntry;

/// The group an entry sits in, or null when it is ungrouped (a test makes
/// that unreachable for the entries that ship).
CanIGroup? canIGroupOf(String entryId) {
  _groupByEntry ??= {
    for (final g in kCanIGroups)
      for (final id in g.entryIds) id: g,
  };
  return _groupByEntry![entryId];
}

List<CanIGroup> canIGroupsIn(CanICategory c) =>
    [for (final g in kCanIGroups) if (g.category == c) g];

/// "Instead, try" — what she can have when the answer was not a plain yes.
///
/// The `related` list on an entry was written as "also asked", so it holds
/// the *safe* neighbours and the risky ones alike; the swap is the safe ones
/// only. Where the entry names none, the shelf it sits on fills in (a safe
/// fruit for a fruit), so an "Avoid" is never a dead end. Empty for an entry
/// that is already safe — there is nothing to swap a banana for.
List<CanIEntry> canIInsteadOf(CanIEntry e, {int max = 4}) {
  if (e.verdict == CanIVerdict.safe) return const [];
  final out = <CanIEntry>[];
  void add(String id) {
    if (id == e.id || out.any((x) => x.id == id)) return;
    final x = canIById(id);
    if (x != null && x.verdict == CanIVerdict.safe) out.add(x);
  }

  for (final id in e.related) {
    add(id);
  }
  if (out.length < 2) {
    for (final id in canIGroupOf(e.id)?.entryIds ?? const <String>[]) {
      if (out.length >= max) break;
      add(id);
    }
  }
  // A shelf with nothing safe on it (Smoke, Soda and alcohol, Pain and
  // fever) borrows from its category — water for alcohol, a walk for a
  // cigarette. Never an empty rail under an "Avoid".
  if (out.isEmpty) {
    for (final x in canIByCategory(e.category)) {
      if (out.length >= 3) break;
      add(x.id);
    }
  }
  return out.take(max).toList();
}

/// The one trimester note that applies to her week — the answer for *her*,
/// not for pregnancy in general. Weeks 1–13 read `t1`, 14–27 `t2`, 28 on
/// `t3`. Null when the entry has no note for that trimester.
LocalizedText? canINoteForWeek(CanIEntry e, int week) => switch (canITrimester(week)) {
      1 => e.t1,
      2 => e.t2,
      _ => e.t3,
    };

int canITrimester(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

/// The entries that have something to say about her trimester in
/// particular — the door's "For your weeks" rail. Ordered as the data is.
List<CanIEntry> canIForTrimester(int week) =>
    [for (final e in kCanIEntries) if (canINoteForWeek(e, week) != null) e];
