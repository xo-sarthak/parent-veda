// =============================================================================
//  Category photos — the store front's tiles, as pictures of the object
// -----------------------------------------------------------------------------
//  The user (2026-09-20): the category squares under the hero band used line
//  icons and read as a static wireframe next to a photographed hero — "make
//  them look the way actual product applications do; real images; make this
//  page look real, not static." Blinkit's grammar (Mobbin, 2026-09-20): a
//  soft-tinted rounded square with the object's photo inside and a two-line
//  label beneath.
//
//  ⚠️ PICKED BY EYE, NOT BY ID. The first cut mapped Unsplash ids from memory
//  and the user found a cat in a blanket under "Books" and a sofa under
//  "Stretch mark care" — an id remembered is not a photo seen. Every photo
//  below was searched on Wikimedia Commons by the object's name, laid out on
//  a contact sheet, looked at, and chosen: a pregnancy pillow IS a pregnancy
//  pillow. Same host as every read photo (`read_images.dart`), 500-px thumbs (Wikimedia renders a fixed set of widths; 640 is refused),
//  until R2 (STILL-OPEN §63.18). A failed load falls through to the icon tile.
//
//  To replace one: search Commons for the object, look at the candidates,
//  paste the thumb URL. Never an id from memory.
// =============================================================================

String _c(String path) =>
    'https://upload.wikimedia.org/wikipedia/commons/$path';

final Map<String, String> _byCategory = {
  // ---- trying to conceive ----
  'ttc_supplements': _c(
    'thumb/4/42/Prenatal_vitamin_tablets.jpg/500px-Prenatal_vitamin_tablets.jpg',
  ),
  'ttc_kits': _c('9/97/Positieve_LH-test_-_detail_kleur.jpg'),
  'ttc_tests': _c(
    'thumb/b/bc/Test_de_grossesse_ouvert.jpg/500px-Test_de_grossesse_ouvert.jpg',
  ),
  'ttc_books': _c(
    'thumb/2/2b/Stack_of_multicolored_books_on_a_table.jpg/500px-Stack_of_multicolored_books_on_a_table.jpg',
  ),
  'ttc_wellness': _c('thumb/9/91/Herbal_Tea_05.jpg/500px-Herbal_Tea_05.jpg'),
  // ---- pregnancy ----
  'pregnancy_pillow': _c(
    'thumb/6/62/Pregnancy_pillow.jpg/500px-Pregnancy_pillow.jpg',
  ),
  'stretch_care': _c('d/d8/Pure_Body_Butters_Cocoa_Butter_Moisturiser.jpg'),
  'maternity_wear': _c(
    'thumb/c/cc/Pregnant_woman_wearing_green_and_yellow_ombr%C3%A9_maternity_dress.jpg/500px-Pregnant_woman_wearing_green_and_yellow_ombr%C3%A9_maternity_dress.jpg',
  ),
  'belly_band': _c(
    'thumb/6/6b/Gennie%27s_maternity_supporting_belt.jpg/500px-Gennie%27s_maternity_supporting_belt.jpg',
  ),
  'compression_socks': _c(
    'thumb/7/76/Knee-high_and_thigh-high_anti-embolism_compression_stockings.jpg/500px-Knee-high_and_thigh-high_anti-embolism_compression_stockings.jpg',
  ),
  'nursing_bra': _c(
    'f/f9/Lataly_Womens_Sleeping_Nursing_Bra_Wirefree_Breastfeeding_Maternity_Bralette_Pack_of_5.jpg',
  ),
  'breast_pump': _c(
    'thumb/7/78/Breast_Pump_%2850265746936%29.jpg/500px-Breast_Pump_%2850265746936%29.jpg',
  ),
  'swaddle': _c(
    'thumb/3/3b/3_week_old_swaddled_infant.png/500px-3_week_old_swaddled_infant.png',
  ),
  // ---- parenting ----
  'sleep': _c(
    'thumb/2/2f/Sleeping_baby_in_crib.jpg/500px-Sleeping_baby_in_crib.jpg',
  ),
  'skincare': _c(
    'thumb/a/ad/Baby_Shampoo_%2850841206943%29.jpg/500px-Baby_Shampoo_%2850841206943%29.jpg',
  ),
  'feeding': _c(
    'thumb/2/29/Baby_and_baby_milk_bottle%2C_Baby_feeding_schedule%2C_Moscow%2C_Russia.jpg/500px-Baby_and_baby_milk_bottle%2C_Baby_feeding_schedule%2C_Moscow%2C_Russia.jpg',
  ),
  'play_and_development': _c(
    'thumb/b/b3/Playing_with_colorful_building_blocks_and_toys_on_the_floor_in_a_cozy_indoor_setting.jpg/500px-Playing_with_colorful_building_blocks_and_toys_on_the_floor_in_a_cozy_indoor_setting.jpg',
  ),
  'health_and_safety': _c(
    'thumb/3/3d/Parent_checks_child%27s_temperature_with_thermometer_in_a_cozy_indoor_setting_during_winter.jpg/500px-Parent_checks_child%27s_temperature_with_thermometer_in_a_cozy_indoor_setting_during_winter.jpg',
  ),
  'on_the_move': _c(
    'thumb/0/04/Dzieci_w_fotelikach_samochodowych.JPG/500px-Dzieci_w_fotelikach_samochodowych.JPG',
  ),
};

/// The photo for a category, or null for one the map does not know (a
/// Directus category added later) — the tile then draws its icon.
String? pvCategoryImageFor(String categoryId) => _byCategory[categoryId];
