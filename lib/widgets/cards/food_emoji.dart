// =============================================================================
//  Food imagery
// -----------------------------------------------------------------------------
//  A curated, comforting food glyph for each week's size comparison. Emoji are
//  used as lightweight, offline, recognisable "images" of the specific
//  fruit/vegetable — closest produce match where an exact one doesn't exist.
//  (Swap any of these for illustrated PNG/SVG assets later without touching the
//  card layout — just point [foodEmojiForWeek] at your asset map instead.)
// =============================================================================

// Each glyph is matched to that week's `babySnapshot.size.fruit` text in
// weekContent.json (the PDF source of truth), in both English and Hinglish.
// Where no exact produce emoji exists, the closest in shape/colour is used and
// noted — never a contradicting one.
const Map<int, String> _foodEmojiByWeek = {
  4: '🌱',  // a poppy seed (poppy seed) — seed
  5: '🌱',  // an apple seed (seb ka beej) — seed
  6: '🌱',  // a pomegranate seed (anaar ka daana) — seed
  7: '🫐',  // a blueberry (blueberry)
  8: '🫘',  // a kidney bean (rajma)
  9: '🫒',  // a green olive (hari olive)
  10: '🍓', // a strawberry (strawberry)
  11: '🫐', // a fig (anjeer) — closest; no fig emoji
  12: '🍋', // a lime (nimbu) — citrus; no dedicated lime emoji
  13: '🍋', // a lemon (nimbu)
  14: '🍑', // a peach (aadu)
  15: '🍎', // an apple (seb)
  16: '🥑', // an avocado (avocado)
  17: '🍐', // a pear (nashpati)
  18: '🍠', // a sweet potato (shakarkandi)
  19: '🥭', // a mango (aam)
  20: '🍌', // a banana (kela)
  21: '🥕', // a carrot (gajar)
  22: '🎃', // a spaghetti squash (spaghetti squash) — squash; no squash emoji
  23: '🥭', // a large mango (bada aam)
  24: '🌽', // an ear of corn (bhutta)
  25: '🥔', // a rutabaga (shalgam) — root veg; no rutabaga emoji
  26: '🥬', // a red cabbage (laal patta gobhi)
  27: '🥦', // a cauliflower (gobhi) — closest; no cauliflower emoji
  28: '🍆', // a large eggplant (bada baingan)
  29: '🎃', // a butternut squash (butternut squash) — squash
  30: '🥬', // a large cabbage (badi gobhi)
  31: '🥥', // a coconut (nariyal)
  32: '🥔', // a jicama (jicama) — root bulb; no jicama emoji
  33: '🍍', // a pineapple (ananas)
  34: '🍈', // a cantaloupe (kharbooja)
  35: '🍈', // a honeydew melon (honeydew melon)
  36: '🥭', // a papaya (papita) — closest; no papaya emoji
  37: '🍈', // a winter melon (petha) — melon/gourd
  38: '🎃', // a pumpkin (kaddu)
  39: '🍉', // a watermelon (tarbooz)
  40: '🍉', // a small watermelon (chhota tarbooz)
};

/// Returns the food glyph for a given week, falling back to a gentle sprout.
String foodEmojiForWeek(int week) => _foodEmojiByWeek[week] ?? '🌱';
