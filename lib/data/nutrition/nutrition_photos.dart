// =============================================================================
//  Nutrition — a photo for a dish named in prose
// -----------------------------------------------------------------------------
//  A chart meal is a sentence — "Poha with peanuts and a glass of milk" — not
//  an id, so it cannot key a photo table directly. This maps the first dish
//  word found in the sentence to a photo id (`nut_<dish>` in
//  read_images.dart). Order matters: the specific before the general, so
//  "ragi dosa" lands on dosa-with-ragi before "dosa", and "curd rice" on the
//  dish before "curd". A sentence with no known dish gets the slot's line
//  icon in a neutral well, never a blank.
//
//  About forty dishes cover the fifty-eight worked days and seventeen
//  recipes; the photos themselves are picked by eye (STILL-OPEN §69) and
//  ride on the same hosts as every other read photo until R2.
// =============================================================================

import '../reads/read_images.dart';

/// (keyword in the sentence, photo id). Checked in order, case-insensitive.
const List<(String, String)> kNutritionDishKeys = [
  ('ragi dosa', 'ragi_dosa'), ('curd rice', 'curd_rice'), ('palak paneer', 'palak_paneer'),
  ('macher jhol', 'fish_curry'), ('fish curry', 'fish_curry'), ('shukto', 'shukto'),
  ('kanji', 'ragi_kanji'), ('ragi', 'ragi_porridge'), ('sambar', 'sambar'), ('rajma', 'rajma'),
  ('dhokla', 'dhokla'), ('khichdi', 'khichdi'), ('varan', 'dal_rice'), ('thalipeeth', 'thalipeeth'),
  ('kadhi', 'kadhi'), ('chilla', 'chilla'), ('daliya', 'daliya'), ('dalia', 'daliya'),
  ('poha', 'poha'), ('upma', 'upma'), ('idli', 'idli'), ('dosa', 'dosa'), ('paratha', 'paratha'),
  ('roti', 'roti_sabzi'), ('chapati', 'roti_sabzi'), ('phulka', 'roti_sabzi'),
  ('oats', 'oats'), ('porridge', 'oats'), ('egg', 'boiled_eggs'), ('omelette', 'omelette'),
  ('paneer', 'paneer'), ('dal', 'dal'), ('sprouts', 'sprouts'), ('chana', 'chana'),
  ('chole', 'chana'), ('sabzi', 'roti_sabzi'), ('rice', 'dal_rice'), ('curd', 'curd'),
  ('dahi', 'curd'), ('lassi', 'lassi'), ('buttermilk', 'buttermilk'), ('chaas', 'buttermilk'),
  ('milk', 'milk'), ('fruit', 'fruit_bowl'), ('banana', 'banana'), ('apple', 'apple'),
  ('nuts', 'nuts'), ('almond', 'nuts'), ('dates', 'dates'), ('soup', 'soup'),
  ('salad', 'salad'), ('coconut water', 'coconut_water'), ('chicken', 'chicken_curry'),
  ('fish', 'fish_curry'), ('makhana', 'makhana'), ('roasted chana', 'chana'),
  ('khakhra', 'khakhra'), ('sandwich', 'sandwich'), ('smoothie', 'smoothie'), ('juice', 'juice'),
  ('tea', 'chai'), ('chai', 'chai'),
];

/// The photo id for a meal sentence, or null.
String? nutritionDishIdFor(String sentence) {
  final s = sentence.toLowerCase();
  for (final (k, id) in kNutritionDishKeys) {
    if (s.contains(k)) return 'nut_$id';
  }
  return null;
}

/// The photo URL for a meal sentence, or null when nothing in the sentence
/// is a dish we have a picture of.
String? nutritionPhotoFor(String sentence) {
  final id = nutritionDishIdFor(sentence);
  return id == null ? null : readImageFor(id);
}

/// A recipe's photo (`nut_r_<recipeId>`), falling back to a dish in its name.
String? nutritionRecipePhoto(String recipeId, String name) =>
    readImageFor('nut_r_$recipeId') ?? nutritionPhotoFor(name);
