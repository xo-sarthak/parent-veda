// =============================================================================
//  Read images — one picture per article, by read id
// -----------------------------------------------------------------------------
//  The reader draws a picture frame on every article (`PvRead.imageUrl`, else
//  this table, else the tinted band). The user, 2026-09-18: "put the images,
//  no worries… fetch those images from the Internet from free resources."
//
//  ⚠️ EVERY ENTRY IS A FREE-LICENCE PHOTOGRAPH WITH ITS CREDIT KEPT. Sourced
//  through the Openverse API (openverse.org) from rawpixel (CC0) and Flickr
//  (CC BY / CC BY-SA / CC0) — the licence and creator sit beside each URL in
//  `kReadImageCredits`, because a CC BY picture without its credit is not a
//  free picture. Chosen for SUBJECT, not mood: the piece about the anomaly
//  scan shows a scan; the piece about iron shows lentils.
//
//  ⚠️ A LOOKUP BY ID, NOT A FIELD ON EVERY READ, so a picture can be chosen
//  or changed without touching a content file, and a read written tomorrow
//  gets one by adding a line here. A read with no line draws the band — never
//  a broken frame. Reads that still want a better picture are listed in
//  docs/DOOR-CONTENT-OWED.md.
// =============================================================================

/// Read id → image URL.
// ⚠️ NO RAWPIXEL — 2026-09-19. Twenty-two entries were
// `images.rawpixel.com/image_1300/…` previews, and rawpixel tiles its logo
// across a preview (seen on the phone, STILL-OPEN §63.13). Replaced through
// Openverse with `source=stocksnap` (CC0, served clean at 960px). The ten
// Flickr files went the same way on 2026-09-19: Flickr's CDN resets the
// connection from Indian networks (checked: all ten failed, all 86 others
// served), so one host — StockSnap — for the whole table.
const Map<String, String> kReadImageUrls = {
  // ---- Garbh Sanskar pillars (2026-09-23) --------------------------------
  // Were hotlinked straight from Unsplash in home_v3_screen.dart — no mirror,
  // no licence line. Shravan (a tabla) and Samvad (a heart held on a bump)
  // kept, mirrored; Buddhi (a man with his arms flung wide at a sunset) and
  // Kriya (cupped hands in the dark) replaced by eye with puzzle pieces and a
  // lit diya — "a few quiet minutes that are yours" and a still flame.
  'garbh_pillar_shravan':
      'https://images.unsplash.com/photo-1633411988188-6e63354a9019?w=960&q=80',
  'garbh_pillar_samvad':
      'https://images.unsplash.com/photo-1541956799312-3f9df99e0006?w=960&q=80',
  'garbh_pillar_buddhi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Red_jigsaw_puzzle_pieces_2.jpg/960px-Red_jigsaw_puzzle_pieces_2.jpg',
  'garbh_pillar_kriya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/A_lit_Diyo.jpg/960px-A_lit_Diyo.jpg',
  // ---- Symptoms: THE THING THAT HELPS, never her body (2026-09-23) ------
  // The user, walking By symptom: "we should be using real images of
  // course". Photographs of pregnant bodies are stock-fake or clinical, and
  // Commons does objects well and people badly, so every read shows what
  // helps: ginger tea for nausea, a glass of milk for heartburn, a
  // hot-water bottle for the back. Picked by eye from contact sheets, the
  // square crop checked (it is what a row shows). Two keep their drawn mark
  // because nothing was good enough: nosebleeds and round ligament.
  'symptom_nausea':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Lemon_and_ginger_tea_%2CTanzania.jpg/960px-Lemon_and_ginger_tea_%2CTanzania.jpg',
  'symptom_heartburn':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Glass_of_Milk_%2833657535532%29.jpg/960px-Glass_of_Milk_%2833657535532%29.jpg',
  'symptom_constipation':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Starr-170114-6478-Smallanthus_sonchifolius-fruit_bowl_with_watermelon_white_pineapple_papaya_Ice_Cream_and_Apple_banana_Cara_Cara_and_Washington_Navel_Orange-Hawea_Pl_Olinda-Maui_%2832425883706%29.jpg/960px-thumbnail.jpg',
  'symptom_fatigue':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Pillows_on_a_hotel_bed.jpg/960px-Pillows_on_a_hotel_bed.jpg',
  'symptom_backPain':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Knitted_hot_water_bottle_cover.jpg/960px-Knitted_hot_water_bottle_cover.jpg',
  'symptom_headache':
      'https://upload.wikimedia.org/wikipedia/commons/c/c4/Glass_of_Water_-_Flickr_-_Greg_Riegler_Photography.jpg',
  'symptom_troubleSleeping':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Night_light_ball.jpg/960px-Night_light_ball.jpg',
  'symptom_moodSwings':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Tea_with_a_view_of_Nilgiris%2C_Jomsom%2C_Nepal_%289412928589%29.jpg/960px-Tea_with_a_view_of_Nilgiris%2C_Jomsom%2C_Nepal_%289412928589%29.jpg',
  'symptom_swelling':
      'https://upload.wikimedia.org/wikipedia/commons/1/15/Puff_Redondo_Baixo_2.jpg',
  'symptom_legCramps':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Banana_bunch_in_a_banana_farm_at_Chinawal.jpg/960px-Banana_bunch_in_a_banana_farm_at_Chinawal.jpg',
  'symptom_babyHiccups':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Norse-Borgen_Solid_Pink_Baby_Booties_%28Girl%27s%29_%284264764477%29.jpg/960px-Norse-Borgen_Solid_Pink_Baby_Booties_%28Girl%27s%29_%284264764477%29.jpg',
  'symptom_braxtonHicks':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Ref._913_HEUER_S.A.V.I.C_stopwatch.jpg/960px-Ref._913_HEUER_S.A.V.I.C_stopwatch.jpg',
  'symptom_bloating':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Moroccan_Mint_Tea_-_1.jpg/960px-Moroccan_Mint_Tea_-_1.jpg',
  'symptom_metallicTaste':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Zitrone_--_2025_--_7294.jpg/960px-Zitrone_--_2025_--_7294.jpg',
  'symptom_foodAversions':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Plain_Curd_Rice.jpg/960px-Plain_Curd_Rice.jpg',
  'symptom_dizziness':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Liat_Portal_for_Foodie_Disorder_-_Tu_B%E2%80%99Shevat_Fruit_Plate.jpg/960px-Liat_Portal_for_Foodie_Disorder_-_Tu_B%E2%80%99Shevat_Fruit_Plate.jpg',
  'symptom_breathlessness':
      'https://upload.wikimedia.org/wikipedia/commons/0/04/Cottage_window_with_curtains_and_flowers_-_geograph.org.uk_-_1157347.jpg',
  'symptom_blockedNose':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Ultrasonic_humidifier.jpg/960px-Ultrasonic_humidifier.jpg',
  'symptom_pelvicGirdle':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Pregnancy_pillow.jpg/960px-Pregnancy_pillow.jpg',
  'symptom_carpalTunnel':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Wrist_brace.jpg/960px-Wrist_brace.jpg',
  'symptom_varicoseVeins':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Mediven550_dk8518.jpg/960px-Mediven550_dk8518.jpg',
  'symptom_ribPain':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Kitten_among_sofa_cushions_%282010%29.jpg/960px-Kitten_among_sofa_cushions_%282010%29.jpg',
  'symptom_restlessLegs':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Kid_friendly_green_smoothie_in_a_personalized_glass_with_spinach%2C_Greek_yogurt%2C_frozen_blueberries%2C_blackberries_and_strawberries_and_berries%2C_banana_in_a_glass_bowl_on_a_wood_table_%2816225943125%29.jpg/960px-thumbnail.jpg',
  'symptom_vividDreams':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Moleskine_Evernote_Smart_Notebook_and_pen_%288401944314%29.jpg/960px-Moleskine_Evernote_Smart_Notebook_and_pen_%288401944314%29.jpg',
  'symptom_itching':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Coconut_oil_bottle_in_the_background_of_coconuts_from_Kaleeswari_Farm.jpg/960px-Coconut_oil_bottle_in_the_background_of_coconuts_from_Kaleeswari_Farm.jpg',
  'symptom_bleedingGums':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Toothbrush_20050716_004.jpg/960px-Toothbrush_20050716_004.jpg',
  'symptom_hairSkin':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Cut_Aloe_Vera_Leaf.jpg/960px-Cut_Aloe_Vera_Leaf.jpg',
  'symptom_hotFlushes':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Hand_fan_1_%28_mahuci%29.jpg/960px-Hand_fan_1_%28_mahuci%29.jpg',
  'symptom_smellSensitivity':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Mint_leaves_raster.jpg/960px-Mint_leaves_raster.jpg',
  'symptom_frequentUrination':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Metal_Water_Bottles.jpeg/960px-Metal_Water_Bottles.jpeg',
  'symptom_pelvicPressure':
      'https://upload.wikimedia.org/wikipedia/commons/2/29/Exercise_ball.jpg',

  // Nutrition — 2026-09-20. A photo per dish word (`nut_<dish>`, matched
  // from a chart meal's sentence by nutrition_photos.dart) and per recipe
  // (`nut_r_<id>`), picked by eye from Wikidata-tagged and Commons text
  // candidates. Placeholders until R2 (STILL-OPEN §69.3).
  'nut_ragi_dosa':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Ragi_Dosa_Mumbai.jpg/960px-Ragi_Dosa_Mumbai.jpg',
  'nut_curd_rice':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Curd_Rice.jpg/960px-Curd_Rice.jpg',
  // Was "Palak paneer ON ROTINI, with curry powder and peanuts —
  // Massachusetts": pasta. Picked by eye 2026-09-22.
  'nut_palak_paneer':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Palak_Paneer_%28Cottage_cheese_in_spinach_gravy%29.jpg/960px-Palak_Paneer_%28Cottage_cheese_in_spinach_gravy%29.jpg',
  'nut_fish_curry':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Bengali_bata_fish_curry.jpg/960px-Bengali_bata_fish_curry.jpg',
  // Was a generic StockSnap plate that was not shukto at all.
  'nut_shukto':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Shukto%2C_a_Bengali_dish.jpg/960px-Shukto%2C_a_Bengali_dish.jpg',
  'nut_ragi_porridge':
      'https://upload.wikimedia.org/wikipedia/commons/6/6f/Raagi_koozh.jpg',
  'nut_sambar':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Idli_Sambar-Noida-UP-SP004.jpg/960px-Idli_Sambar-Noida-UP-SP004.jpg',
  'nut_rajma':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Rajma_Chawal_by_Rama_Bhave.jpg/960px-Rajma_Chawal_by_Rama_Bhave.jpg',
  'nut_dhokla':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Khaman_Dhokla_Gujrati.jpg/960px-Khaman_Dhokla_Gujrati.jpg',
  // ⚠️ WAS "Spicy Khichdi" WITH A BOWL OF RAW ONION BESIDE IT — and this
  // photo is the one the Jain kadhi khichdi ("made without onion or garlic")
  // resolves to. Seen on the phone 2026-09-23. The replacement is plain
  // khichdi on a steel thali; the prettier candidate had potato in it, which
  // Jain cooking also avoids, so it would have been the same mistake again.
  'nut_khichdi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/MoongDal_Khichdi.jpg/960px-MoongDal_Khichdi.jpg',
  // ⚠️ WAS A FISH CURRY THALI — on varan bhaat, which is the vegetarian
  // Maharashtrian dal-and-rice. A meat photograph on a vegetarian dish is
  // not a styling slip; for a Jain or vegetarian mother it is the app
  // getting her food wrong. Picked by eye 2026-09-22.
  'nut_dal_rice':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Varan_Bhat.jpg/960px-Varan_Bhat.jpg',
  'nut_thalipeeth':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Thalipeeth_-_Maharashtra.jpg/960px-Thalipeeth_-_Maharashtra.jpg',
  // Was a whole Gujarati thali, in which the kadhi is one small bowl.
  'nut_kadhi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Gujaratikadhi.jpg/960px-Gujaratikadhi.jpg',
  'nut_chilla':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Chilla_besan.JPG/960px-Chilla_besan.JPG',
  'nut_daliya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Daliya_khichdi.jpg/960px-Daliya_khichdi.jpg',
  'nut_poha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Kanda_Poha-Diu-DSC003.jpg/960px-Kanda_Poha-Diu-DSC003.jpg',
  'nut_upma':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Upma_South_India.JPG/960px-Upma_South_India.JPG',
  'nut_idli':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Idli_Sambar-Noida-UP-SP004.jpg/960px-Idli_Sambar-Noida-UP-SP004.jpg',
  'nut_dosa':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Masala_dosa_01.jpg/960px-Masala_dosa_01.jpg',
  'nut_paratha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Paratha_is_a_dough_fried_flatbread_of_India_and_Pakistan.jpg/960px-Paratha_is_a_dough_fried_flatbread_of_India_and_Pakistan.jpg',
  'nut_roti_sabzi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/A_thali_with_daal_roti_bhindi_ki_sabzi_and_mango_pickle.jpg/960px-A_thali_with_daal_roti_bhindi_ki_sabzi_and_mango_pickle.jpg',
  'nut_oats':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Oatmeal_porridge_1-minute_with_additional_ingredients.jpg/960px-Oatmeal_porridge_1-minute_with_additional_ingredients.jpg',
  'nut_boiled_eggs':
      'https://cdn.stocksnap.io/img-thumbs/960w/7ICUECNY4R.jpg',
  'nut_omelette':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/FoodOmelete.jpg/960px-FoodOmelete.jpg',
  'nut_paneer':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Homemade_Paneer_Bhurji_cooked_in_pan_India.jpg/960px-Homemade_Paneer_Bhurji_cooked_in_pan_India.jpg',
  'nut_dal':
      'https://cdn.stocksnap.io/img-thumbs/960w/WOZ7PQGMMI.jpg',
  'nut_sprouts':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Sprouted_Moong_Salad.JPG/960px-Sprouted_Moong_Salad.JPG',
  'nut_chana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Chana_Masala_in_Paul%C3%ADnia%2C_2023-10-16.jpg/960px-Chana_Masala_in_Paul%C3%ADnia%2C_2023-10-16.jpg',
  'nut_curd':
      'https://cdn.stocksnap.io/img-thumbs/960w/QL0I5DPNGX.jpg',
  'nut_lassi':
      'https://cdn.stocksnap.io/img-thumbs/960w/BNCZWVYVMQ.jpg',
  'nut_fruit_bowl':
      'https://cdn.stocksnap.io/img-thumbs/960w/4MUZH41WMD.jpg',
  'nut_banana':
      'https://cdn.stocksnap.io/img-thumbs/960w/63ZQSDZUPT.jpg',
  'nut_apple':
      'https://cdn.stocksnap.io/img-thumbs/960w/OQGVJXG77S.jpg',
  'nut_nuts':
      'https://cdn.stocksnap.io/img-thumbs/960w/4EXMQZWRDQ.jpg',
  'nut_dates':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Date_Fruit.jpg/960px-Date_Fruit.jpg',
  'nut_soup':
      'https://cdn.stocksnap.io/img-thumbs/960w/WOZ7PQGMMI.jpg',
  'nut_salad':
      'https://cdn.stocksnap.io/img-thumbs/960w/PLOA1CWIRK.jpg',
  'nut_coconut_water':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Klappermelk_kelapa_muda.jpg/960px-Klappermelk_kelapa_muda.jpg',
  'nut_chicken_curry':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Pan_Chicken_Curry.jpg/960px-Pan_Chicken_Curry.jpg',
  'nut_makhana':
      'https://cdn.stocksnap.io/img-thumbs/960w/885S4Q0UVA.jpg',
  'nut_khakhra':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJQJJ8RWHJ.jpg',
  'nut_sandwich':
      'https://cdn.stocksnap.io/img-thumbs/960w/K5T076FWTJ.jpg',
  'nut_smoothie':
      'https://cdn.stocksnap.io/img-thumbs/960w/8X2LVKANB9.jpg',
  'nut_juice':
      'https://cdn.stocksnap.io/img-thumbs/960w/UR1JSQIAUN.jpg',
  'nut_chai':
      'https://cdn.stocksnap.io/img-thumbs/960w/0ZS74TCOME.jpg',
  'nut_r_pcos_moong_chilla':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Chilla_besan.JPG/960px-Chilla_besan.JPG',
  'nut_r_bengali_macher_jhol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Bata_macher_jhol-MB03.jpg/960px-Bata_macher_jhol-MB03.jpg',
  'nut_r_bengali_shukto':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Shukto%2C_a_Bengali_dish.jpg/960px-Shukto%2C_a_Bengali_dish.jpg',
  'nut_r_punjabi_palak_paneer':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Palakpaneer_Rayagada_Odisha_0009.jpg/960px-Palakpaneer_Rayagada_Odisha_0009.jpg',
  'nut_r_gujarati_dhokla':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Dhokla_6.jpg/960px-Dhokla_6.jpg',
  'nut_r_gujarati_khichdi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Masala_Khichadi.jpg/960px-Masala_Khichadi.jpg',
  'nut_r_south_indian_ragi_dosa':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Ragi_Dosa_Mumbai.jpg/960px-Ragi_Dosa_Mumbai.jpg',
  'nut_r_south_indian_curd_rice':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Curd_Rice.jpg/960px-Curd_Rice.jpg',
  'nut_r_maharashtrian_varan_bhaat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Varan_Bhat.jpg/960px-Varan_Bhat.jpg',
  'nut_r_maharashtrian_thalipeeth':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Thalipeeth_-_Maharashtra.jpg/960px-Thalipeeth_-_Maharashtra.jpg',
  // ⚠️ WAS "Kadhi and Khichdi of Bardoli" — with a bowl of raw onion beside
  // a dish sold as "made without onion or garlic". Seen on the phone
  // 2026-09-23. This is the recipe's OWN photo, which wins over the shared
  // `nut_khichdi` (`nutritionRecipePhoto` checks `nut_r_<id>` first) — so
  // fixing the shared one alone changed nothing on this card.
  'nut_r_jain_kadhi_khichdi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/MoongDal_Khichdi.jpg/960px-MoongDal_Khichdi.jpg',
  'nut_r_besan_chilla':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Chilla_besan.JPG/960px-Chilla_besan.JPG',
  'nut_r_vegetable_daliya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Daliya_khichdi.jpg/960px-Daliya_khichdi.jpg',
  'nut_r_tamil_sambar':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Idli_Sambar-Noida-UP-SP004.jpg/960px-Idli_Sambar-Noida-UP-SP004.jpg',
  'nut_r_punjabi_rajma':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Rajma_Chawal_by_Rama_Bhave.jpg/960px-Rajma_Chawal_by_Rama_Bhave.jpg',
  'nut_r_tamil_ragi_kanji':
      'https://upload.wikimedia.org/wikipedia/commons/6/6f/Raagi_koozh.jpg',
  'nut_ragi_kanji':
      'https://upload.wikimedia.org/wikipedia/commons/6/6f/Raagi_koozh.jpg',
  'nut_buttermilk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Lassi_1.jpg/960px-Lassi_1.jpg',
  // Is it safe? — 2026-09-19. One photo per Can I entry (`cani_<id>`) and
  // one per shelf (`cani_shelf_<category>`), picked by hand from contact
  // sheets of Wikimedia Commons and StockSnap candidates. Placeholders on
  // their way to cut-outs on R2 (STILL-OPEN §68.4); a missing id falls
  // back to the category icon in the tile.
  'cani_papaya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/03_Preparing_papaya_fruit_-_papaya_peeled_and_cut_in_half.jpg/960px-03_Preparing_papaya_fruit_-_papaya_peeled_and_cut_in_half.jpg',
  'cani_pineapple':
      'https://upload.wikimedia.org/wikipedia/commons/1/17/Pineapple1.JPG',
  'cani_mango':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Mangos_-_single_and_halved.jpg/960px-Mangos_-_single_and_halved.jpg',
  'cani_banana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Bunch_of_bananas_on_sale.jpg/960px-Bunch_of_bananas_on_sale.jpg',
  'cani_curd':
      'https://upload.wikimedia.org/wikipedia/commons/f/fc/Bread_Dahi_Vada_Naivaidya.jpg',
  'cani_chocolate':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Green_and_Black%27s_dark_chocolate_bar_2.jpg/960px-Green_and_Black%27s_dark_chocolate_bar_2.jpg',
  'cani_street_food':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Golgappa_Pani_Puri_India.jpg/960px-Golgappa_Pani_Puri_India.jpg',
  'cani_honey':
      'https://cdn.stocksnap.io/img-thumbs/960w/TPZVAKR2HA.jpg',
  'cani_ginger':
      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Ginger_Plant_vs.jpg',
  'cani_coffee':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/960px-A_small_cup_of_coffee.JPG',
  'cani_tea':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Mix_Masala_Tea.jpg/960px-Mix_Masala_Tea.jpg',
  'cani_green_tea':
      'https://cdn.stocksnap.io/img-thumbs/960w/04E3HNGAKH.jpg',
  'cani_coconut_water':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Tender_coconut_water_02.jpg/960px-Tender_coconut_water_02.jpg',
  'cani_buttermilk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Plain_Lassi_in_a_glass.jpg/960px-Plain_Lassi_in_a_glass.jpg',
  'cani_alcohol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Schwappender_Wein.jpg/960px-Schwappender_Wein.jpg',
  'cani_soft_drinks':
      'https://cdn.stocksnap.io/img-thumbs/960w/H57MU5YDCI.jpg',
  'cani_water':
      'https://cdn.stocksnap.io/img-thumbs/960w/SVHF6MUWVZ.jpg',
  'cani_paracetamol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Tylenol_paracetamol_sustained_release_tablets%2C_Chinese_version_%2820221212120513%29.jpg/960px-Tylenol_paracetamol_sustained_release_tablets%2C_Chinese_version_%2820221212120513%29.jpg',
  'cani_ibuprofen':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/200mg_ibuprofen_tablets.jpg/960px-200mg_ibuprofen_tablets.jpg',
  'cani_combiflam':
      'https://cdn.stocksnap.io/img-thumbs/960w/TPI078T0IS.jpg',
  'cani_antibiotics':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Co-fluampicil_capsules_and_container.jpg/960px-Co-fluampicil_capsules_and_container.jpg',
  'cani_folic_acid':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Prenatal_vitamin_tablets.jpg/960px-Prenatal_vitamin_tablets.jpg',
  'cani_calcium':
      'https://upload.wikimedia.org/wikipedia/commons/8/89/Calcium-Tablets-2007.jpg',
  'cani_vitamin_d':
      'https://upload.wikimedia.org/wikipedia/commons/7/75/%D0%A0%D1%8B%D0%B1%D0%B8%D0%B9_%D0%B6%D0%B8%D1%80_%D0%B2_%D0%BA%D0%B0%D0%BF%D1%81%D1%83%D0%BB%D0%B0%D1%85.jpg',
  'cani_flight_travel':
      'https://cdn.stocksnap.io/img-thumbs/960w/J9FFZI8YC0.jpg',
  'cani_long_travel':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZR6M4FRGPN.jpg',
  'cani_yoga':
      'https://cdn.stocksnap.io/img-thumbs/960w/W23EUNXBCG.jpg',
  'cani_swimming':
      'https://cdn.stocksnap.io/img-thumbs/960w/EQOZK44067.jpg',
  'cani_walking':
      'https://cdn.stocksnap.io/img-thumbs/960w/RIUG2ATBWT.jpg',
  'cani_hair_color':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Dyeing_hair_purple.png/960px-Dyeing_hair_purple.png',
  'cani_waxing':
      'https://cdn.stocksnap.io/img-thumbs/960w/CUGFVFAI24.jpg',
  'cani_nail_polish':
      'https://cdn.stocksnap.io/img-thumbs/960w/S6RLOBPAOZ.jpg',
  'cani_sex':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'cani_sleeping_back':
      'https://cdn.stocksnap.io/img-thumbs/960w/46BMYP2BDJ.jpg',
  'cani_mosquito_repellent':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Portable_Mosquito_Coil_Holder_-_Lion_Chemical.jpg/960px-Portable_Mosquito_Coil_Holder_-_Lion_Chemical.jpg',
  'cani_dental':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Dentist-gd569d444b_1920.jpg/960px-Dentist-gd569d444b_1920.jpg',
  'cani_xray':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Tube_%C3%A0_Rayon_X_dans_un_h%C3%B4pital_au_B%C3%A9nin_05.jpg/960px-Tube_%C3%A0_Rayon_X_dans_un_h%C3%B4pital_au_B%C3%A9nin_05.jpg',
  'cani_sauna':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Sauna_of_the_spa_at_Amantaka_luxury_Resort_%26_Hotel_in_Luang_Prabang_Laos.jpg/960px-Sauna_of_the_spa_at_Amantaka_luxury_Resort_%26_Hotel_in_Luang_Prabang_Laos.jpg',
  'cani_fasting':
      'https://cdn.stocksnap.io/img-thumbs/960w/AMW6XPP8AT.jpg',
  'cani_apple':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Red_Apple.jpg/960px-Red_Apple.jpg',
  'cani_orange':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Blood_orange_slice.jpg/960px-Blood_orange_slice.jpg',
  'cani_grapes':
      'https://cdn.stocksnap.io/img-thumbs/960w/3DC9F8D017.jpg',
  'cani_watermelon':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Watermelon_slice%2C_May_2024.jpg/960px-Watermelon_slice%2C_May_2024.jpg',
  'cani_muskmelon':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Muskmelon_in_summer.jpg/960px-Muskmelon_in_summer.jpg',
  'cani_guava':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Goiaba_vermelha.jpg/960px-Goiaba_vermelha.jpg',
  'cani_pomegranate':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Pomegranate_arils.jpg/960px-Pomegranate_arils.jpg',
  'cani_chikoo':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Chiku_fruit.jpg/960px-Chiku_fruit.jpg',
  'cani_litchi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Lychee_fruits_and_seed.jpg/960px-Lychee_fruits_and_seed.jpg',
  'cani_jackfruit':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Jackfruit_Flesh.jpg/960px-Jackfruit_Flesh.jpg',
  'cani_dates':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Dates_10-8-09-101309_copy.jpg/960px-Dates_10-8-09-101309_copy.jpg',
  'cani_figs':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Fig_%28Ficus_carica%29_fruit_halved.jpg/960px-Fig_%28Ficus_carica%29_fruit_halved.jpg',
  'cani_berries':
      'https://cdn.stocksnap.io/img-thumbs/960w/4WN4U4DM5L.jpg',
  'cani_kiwi':
      'https://cdn.stocksnap.io/img-thumbs/960w/QLO68U090J.jpg',
  'cani_pear':
      'https://cdn.stocksnap.io/img-thumbs/960w/QIXV1AILYQ.jpg',
  'cani_dry_fruits':
      'https://cdn.stocksnap.io/img-thumbs/960w/4EXMQZWRDQ.jpg',
  'cani_almonds':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Liat_Portal_for_Foodie_Disorder_-_Raw_almonds_in_a_bowl.jpg/960px-Liat_Portal_for_Foodie_Disorder_-_Raw_almonds_in_a_bowl.jpg',
  'cani_walnuts':
      'https://cdn.stocksnap.io/img-thumbs/960w/DCAJ3SUL76.jpg',
  'cani_cashews':
      'https://cdn.stocksnap.io/img-thumbs/960w/B5YN5OPOU5.jpg',
  'cani_peanuts':
      'https://cdn.stocksnap.io/img-thumbs/960w/CI7RAD5RGJ.jpg',
  'cani_sabudana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Sabudana_Khichdi_with_Sweet_curd.JPG/960px-Sabudana_Khichdi_with_Sweet_curd.JPG',
  'cani_spinach':
      'https://upload.wikimedia.org/wikipedia/commons/f/fc/A_pot_of_cut_spinach_leaves_with_carrots_and_onions.jpg',
  'cani_drumstick':
      'https://cdn.stocksnap.io/img-thumbs/960w/TMTU3V2Z30.jpg',
  'cani_brinjal':
      'https://cdn.stocksnap.io/img-thumbs/960w/CPA2WXSFA2.jpg',
  'cani_potato':
      'https://cdn.stocksnap.io/img-thumbs/960w/RYSFFCA1QV.jpg',
  'cani_tomato':
      'https://cdn.stocksnap.io/img-thumbs/960w/GB9LU1L8RG.jpg',
  'cani_carrot':
      'https://cdn.stocksnap.io/img-thumbs/960w/VXT0GH53QR.jpg',
  'cani_beetroot':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Beetroots_in_a_basket.jpg/960px-Beetroots_in_a_basket.jpg',
  'cani_sprouts':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Mung_beans_%28Vigna_radiata%29.jpg/960px-Mung_beans_%28Vigna_radiata%29.jpg',
  'cani_raw_salad':
      'https://cdn.stocksnap.io/img-thumbs/960w/PLOA1CWIRK.jpg',
  'cani_mushroom':
      'https://cdn.stocksnap.io/img-thumbs/960w/J6O7SG69BZ.jpg',
  'cani_egg':
      'https://cdn.stocksnap.io/img-thumbs/960w/Z05D72KD5S.jpg',
  'cani_chicken':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Chicken_Curry_9.jpg/960px-Chicken_Curry_9.jpg',
  'cani_mutton':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Odia_Mutton_Curry_%28Mansha_Tarkari%29.jpg/960px-Odia_Mutton_Curry_%28Mansha_Tarkari%29.jpg',
  'cani_fish':
      'https://cdn.stocksnap.io/img-thumbs/960w/FWJC3SUNGR.jpg',
  'cani_prawns':
      'https://cdn.stocksnap.io/img-thumbs/960w/30DIV2QY3M.jpg',
  'cani_high_mercury_fish':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Xiphias_gladius_stuffed.jpg/960px-Xiphias_gladius_stuffed.jpg',
  'cani_dal':
      'https://cdn.stocksnap.io/img-thumbs/960w/WOZ7PQGMMI.jpg',
  'cani_soya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Rotini_with_vegetable_tikka_masala%2C_textured_vegetable_protein%2C_peanuts%2C_and_black_pepper_-_Massachusetts.jpg/960px-Rotini_with_vegetable_tikka_masala%2C_textured_vegetable_protein%2C_peanuts%2C_and_black_pepper_-_Massachusetts.jpg',
  'cani_rajma_chana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Rajma_Chawal_by_Rama_Bhave.jpg/960px-Rajma_Chawal_by_Rama_Bhave.jpg',
  'cani_cheese':
      'https://cdn.stocksnap.io/img-thumbs/960w/IDWG2ABOTY.jpg',
  'cani_ghee':
      'https://cdn.stocksnap.io/img-thumbs/960w/NS5Q6MVMZQ.jpg',
  'cani_mawa_sweets':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Kaju_katli_dessert_-_side_view.jpg/960px-Kaju_katli_dessert_-_side_view.jpg',
  'cani_oats':
      'https://cdn.stocksnap.io/img-thumbs/960w/F7TE35CV6D.jpg',
  'cani_poha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Indian_breakfast-_Poha.jpg/960px-Indian_breakfast-_Poha.jpg',
  'cani_instant_noodles':
      'https://cdn.stocksnap.io/img-thumbs/960w/MOCF3JR8J4.jpg',
  'cani_fried_snacks':
      'https://cdn.stocksnap.io/img-thumbs/960w/MU88DSXA3X.jpg',
  'cani_pickle':
      'https://cdn.stocksnap.io/img-thumbs/960w/29BCBF9B37.jpg',
  'cani_turmeric_milk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Golden_Milk.jpg/960px-Golden_Milk.jpg',
  'cani_jaggery':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Jaggery_cubes.jpg/960px-Jaggery_cubes.jpg',
  'cani_spices':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ASMNGB3YI.jpg',
  'cani_sugar':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/W%C3%BCrfelzucker_--_2018_--_3564.jpg/960px-W%C3%BCrfelzucker_--_2018_--_3564.jpg',
  'cani_sushi':
      'https://cdn.stocksnap.io/img-thumbs/960w/R6DB535ZZA.jpg',
  'cani_raw_meat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Steak_Tartare_in_Dresden.jpg/960px-Steak_Tartare_in_Dresden.jpg',
  'cani_deli_meat':
      'https://cdn.stocksnap.io/img-thumbs/960w/7VWFM9893J.jpg',
  'cani_leftovers':
      'https://cdn.stocksnap.io/img-thumbs/960w/AE3F359626.jpg',
  'cani_spicy_food':
      'https://cdn.stocksnap.io/img-thumbs/960w/7OHAJSJDVW.jpg',
  'cani_milkshake':
      'https://cdn.stocksnap.io/img-thumbs/960w/BNCZWVYVMQ.jpg',
  'cani_fresh_juice':
      'https://cdn.stocksnap.io/img-thumbs/960w/UR1JSQIAUN.jpg',
  'cani_lemon_water':
      'https://cdn.stocksnap.io/img-thumbs/960w/O1HJS7EOAJ.jpg',
  'cani_sugarcane_juice':
      'https://cdn.stocksnap.io/img-thumbs/960w/UR1JSQIAUN.jpg',
  'cani_lassi':
      'https://cdn.stocksnap.io/img-thumbs/960w/BNCZWVYVMQ.jpg',
  'cani_energy_drinks':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Energy_Drink_Battery_Cans.jpg/960px-Energy_Drink_Battery_Cans.jpg',
  'cani_herbal_tea':
      'https://cdn.stocksnap.io/img-thumbs/960w/UASWOBMBJ0.jpg',
  'cani_smoothie':
      'https://cdn.stocksnap.io/img-thumbs/960w/4L8M6ANLZL.jpg',
  'cani_kombucha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Wild_Kombucha_logo.jpg/500px-Wild_Kombucha_logo.jpg',
  'cani_diet_soda':
      'https://cdn.stocksnap.io/img-thumbs/960w/XA721L883R.jpg',
  'cani_aam_panna':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/%C4%80m_pann%C4%81_at_Kitchen_of_Awadh%2C_DLF_Phase_4%2C_Gurgaon_%282025-09-28%29.jpg/960px-%C4%80m_pann%C4%81_at_Kitchen_of_Awadh%2C_DLF_Phase_4%2C_Gurgaon_%282025-09-28%29.jpg',
  'cani_badam_milk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Bapatla_Badam_Milk.jpg/960px-Bapatla_Badam_Milk.jpg',
  'cani_decaf_coffee':
      'https://cdn.stocksnap.io/img-thumbs/960w/WZKGHBRQIB.jpg',
  'cani_jaljeera':
      'https://cdn.stocksnap.io/img-thumbs/960w/9Y7B28HZD1.jpg',
  'cani_ors':
      'https://cdn.stocksnap.io/img-thumbs/960w/EBUJNKRBLV.jpg',
  'cani_aspirin':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Regular_strength_enteric_coated_aspirin_tablets.jpg/960px-Regular_strength_enteric_coated_aspirin_tablets.jpg',
  'cani_cetirizine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Cetirizine_tablets_under_the_brand_name_%C2%AB%D0%97%D0%BE%D0%B4%D0%B0%D0%BA%C2%BB.jpg/960px-Cetirizine_tablets_under_the_brand_name_%C2%AB%D0%97%D0%BE%D0%B4%D0%B0%D0%BA%C2%BB.jpg',
  'cani_antacids':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Antacid-L478.jpg/960px-Antacid-L478.jpg',
  'cani_pantoprazole':
      'https://upload.wikimedia.org/wikipedia/commons/6/63/Pantoprazole_20mg.jpg',
  'cani_multivitamin':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/New_Reference_Material_Can_Improve_testing_of_Multivitamin_Tablets_%285880985736%29.jpg/960px-New_Reference_Material_Can_Improve_testing_of_Multivitamin_Tablets_%285880985736%29.jpg',
  'cani_omega3':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Cod_Liver_Oil_Capsules.jpg/960px-Cod_Liver_Oil_Capsules.jpg',
  'cani_b12':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Mecobalamin_tablets.jpg/960px-Mecobalamin_tablets.jpg',
  'cani_ondansetron':
      'https://upload.wikimedia.org/wikipedia/commons/5/5c/000817lg_Zofran_8_MG_Oral_Tablet.jpg',
  'cani_doxylamine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Prenatal_vitamin_tablets.jpg/960px-Prenatal_vitamin_tablets.jpg',
  'cani_cough_syrup':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Vintage_Turkish_pediatric_cough_syrup_bottle.png/960px-Vintage_Turkish_pediatric_cough_syrup_bottle.png',
  'cani_lozenges':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Hustenbonbons_01.jpg/960px-Hustenbonbons_01.jpg',
  'cani_vicks_balm':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Vicks_VapoRub_%2851013600352%29_%28cropped%29.jpg/960px-Vicks_VapoRub_%2851013600352%29_%28cropped%29.jpg',
  'cani_isabgol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Culinary_psyllium%2C_Russian_market_13.jpg/960px-Culinary_psyllium%2C_Russian_market_13.jpg',
  'cani_probiotics':
      'https://upload.wikimedia.org/wikipedia/commons/0/04/Biogaia_Lactobacillus_Reuteri_Product.jpg',
  'cani_ashwagandha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Ashwagandha_Powder_and_Root_on_Spoons_-_50191697031.jpg/960px-Ashwagandha_Powder_and_Root_on_Spoons_-_50191697031.jpg',
  'cani_homeopathy':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Homeopathy_globules.jpg/960px-Homeopathy_globules.jpg',
  'cani_diclofenac':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Diclofenac_Natrium_50mg_Aurobindo.jpg/960px-Diclofenac_Natrium_50mg_Aurobindo.jpg',
  'cani_antifungal_cream':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Canesten.jpg/960px-Canesten.jpg',
  'cani_deworming':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Anterone_%28cyproterone_acetate%29_tablets_in_Australia%2C_with_three_blister_packs.jpg/960px-Anterone_%28cyproterone_acetate%29_tablets_in_Australia%2C_with_three_blister_packs.jpg',
  'cani_thyroid_medicine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Levothyroxine_25mcg_Tablets.jpg/960px-Levothyroxine_25mcg_Tablets.jpg',
  'cani_bp_medicine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/2020_Sfigmomanometr_elektroniczny.jpg/960px-2020_Sfigmomanometr_elektroniczny.jpg',
  'cani_insulin':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Insulin_pen_%28labeled%29.jpg/960px-Insulin_pen_%28labeled%29.jpg',
  'cani_vaccines':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Comirnaty_Omicron_XBB.1.5_vial_and_influenza_vaccine_2023.jpg/960px-Comirnaty_Omicron_XBB.1.5_vial_and_influenza_vaccine_2023.jpg',
  'cani_driving':
      'https://cdn.stocksnap.io/img-thumbs/960w/G8GSBPQZUB.jpg',
  'cani_cycling':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Cycling_Amsterdam_03.jpg/960px-Cycling_Amsterdam_03.jpg',
  'cani_running':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Jogging_Woman_in_Grass.jpg/960px-Jogging_Woman_in_Grass.jpg',
  'cani_dancing':
      'https://cdn.stocksnap.io/img-thumbs/960w/N9WJOUYWZ3.jpg',
  'cani_household_chores':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Our_Father%27s_House_Soup_Kitchen_dishwashing-vertical.jpg/960px-Our_Father%27s_House_Soup_Kitchen_dishwashing-vertical.jpg',
  'cani_climbing_stairs':
      'https://cdn.stocksnap.io/img-thumbs/960w/O1SC8XTWTL.jpg',
  'cani_standing_long':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/All_devotees_standing_in_a_queue_for_darshan.jpg/960px-All_devotees_standing_in_a_queue_for_darshan.jpg',
  'cani_amusement_rides':
      'https://cdn.stocksnap.io/img-thumbs/960w/VBAMVNWQRS.jpg',
  'cani_trekking':
      'https://cdn.stocksnap.io/img-thumbs/960w/5LXBN8H2CQ.jpg',
  'cani_gym':
      'https://cdn.stocksnap.io/img-thumbs/960w/00RNNUWGLM.jpg',
  'cani_keratin':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/365-2011-049-_Ava%27s_Haircut.jpg/960px-365-2011-049-_Ava%27s_Haircut.jpg',
  'cani_facial':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Facial_mask.jpg/960px-Facial_mask.jpg',
  'cani_chemical_peel':
      'https://cdn.stocksnap.io/img-thumbs/960w/HIZNJOUVSY.jpg',
  'cani_botox_fillers':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Dr_Braun_Performs_a_Botox_Injection_%284035273577%29.jpg/960px-Dr_Braun_Performs_a_Botox_Injection_%284035273577%29.jpg',
  'cani_laser_hair':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Laser-hair-removal-face-ama-regenerative-medicine.jpg/960px-Laser-hair-removal-face-ama-regenerative-medicine.jpg',
  'cani_pedicure':
      'https://cdn.stocksnap.io/img-thumbs/960w/XX356Q6EI4.jpg',
  'cani_makeup':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Makeup_weapons_Brushes_.jpg/960px-Makeup_weapons_Brushes_.jpg',
  'cani_sunscreen':
      'https://cdn.stocksnap.io/img-thumbs/960w/5O2GOIJXYE.jpg',
  'cani_retinol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Person_applies_cream_for_skin_from_a_jar_closeup.jpg/960px-Person_applies_cream_for_skin_from_a_jar_closeup.jpg',
  'cani_perfume':
      'https://cdn.stocksnap.io/img-thumbs/960w/KFMR70XLYS.jpg',
  'cani_hair_oil':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Baroy_Lanao_Hair_conditioner_serum_Jasminum_essential_virgin_coconut_oil1.jpg/960px-Baroy_Lanao_Hair_conditioner_serum_Jasminum_essential_virgin_coconut_oil1.jpg',
  'cani_tattoo':
      'https://cdn.stocksnap.io/img-thumbs/960w/UIJTQRCQWL.jpg',
  'cani_gel_nails':
      'https://cdn.stocksnap.io/img-thumbs/960w/XX356Q6EI4.jpg',
  'cani_smoking':
      'https://cdn.stocksnap.io/img-thumbs/960w/XK7QYY8NQV.jpg',
  'cani_secondhand_smoke':
      'https://cdn.stocksnap.io/img-thumbs/960w/2E7DE661A5.jpg',
  'cani_vaping':
      'https://cdn.stocksnap.io/img-thumbs/960w/JLDXQBNPWC.jpg',
  'cani_hot_water_bath':
      'https://cdn.stocksnap.io/img-thumbs/960w/CUGFVFAI24.jpg',
  'cani_ac_use':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Air_conditioner_2.jpg/960px-Air_conditioner_2.jpg',
  'cani_incense':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Incense_stick.JPG/960px-Incense_stick.JPG',
  'cani_cleaning_chemicals':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/2022-07-08_Albert_%C5%A0estka_interi%C3%A9r_drogerie.jpg/960px-2022-07-08_Albert_%C5%A0estka_interi%C3%A9r_drogerie.jpg',
  'cani_paint_fumes':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Paint_roller_4.jpg/960px-Paint_roller_4.jpg',
  'cani_pesticides':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Spraying_pesticide_04.jpg/960px-Spraying_pesticide_04.jpg',
  'cani_pet_cats':
      'https://cdn.stocksnap.io/img-thumbs/960w/OU5O7ZUVH7.jpg',
  'cani_pet_dogs':
      'https://cdn.stocksnap.io/img-thumbs/960w/2Q8CXYKKAZ.jpg',
  'cani_gardening':
      'https://cdn.stocksnap.io/img-thumbs/960w/WV6Q25F8ZJ.jpg',
  'cani_public_transport':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Delhi_Metro_train_red_line_at_Shaheed_Sthal_metro_station.jpg/960px-Delhi_Metro_train_red_line_at_Shaheed_Sthal_metro_station.jpg',
  'cani_crowded_places':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Hopelessly_crowded%21_%287937793806%29.jpg/960px-Hopelessly_crowded%21_%287937793806%29.jpg',
  'cani_high_heels':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_high-heeled_shoes_for_flight_attendants_at_CAMC_%2820240518150910%29.jpg/960px-Black_high-heeled_shoes_for_flight_attendants_at_CAMC_%2820240518150910%29.jpg',
  'cani_tight_clothes':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Polygonum_shastense_jeans_2-vein_leaf.jpg/960px-Polygonum_shastense_jeans_2-vein_leaf.jpg',
  'cani_massage':
      'https://cdn.stocksnap.io/img-thumbs/960w/VH22RVC5UT.jpg',
  'cani_spa':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/%D0%A1%D0%9F%D0%90_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D0%B4%D1%83%D1%80%D1%8B_%D0%B2_%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B9_%D0%9F%D0%BE%D0%BB%D1%8F%D0%BD%D0%B5.jpg/960px-%D0%A1%D0%9F%D0%90_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D0%B4%D1%83%D1%80%D1%8B_%D0%B2_%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B9_%D0%9F%D0%BE%D0%BB%D1%8F%D0%BD%D0%B5.jpg',
  'cani_meditation':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Sinemorec_-_Butamiata_beach_%28by_Pudelek%29.JPG/960px-Sinemorec_-_Butamiata_beach_%28by_Pudelek%29.JPG',
  'cani_mobile_phone':
      'https://cdn.stocksnap.io/img-thumbs/960w/DLITZEAVJJ.jpg',
  'cani_stress':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Stressed_and_depressed_woman_covers_her_face_with_hands.jpg/960px-Stressed_and_depressed_woman_covers_her_face_with_hands.jpg',
  'cani_paneer':
      'https://upload.wikimedia.org/wikipedia/commons/a/a5/Malai_Paneer_Tikka%2C_PK_007.jpg',
  'cani_milk':
      'https://cdn.stocksnap.io/img-thumbs/960w/P2QSUXKCN5.jpg',
  'cani_saffron':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Saffron_threads_in_a_glass_jar_%28_Viora_Saffron_packaging%29.jpg/960px-Saffron_threads_in_a_glass_jar_%28_Viora_Saffron_packaging%29.jpg',
  'cani_makhana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Foxnut_Makhana_-_Nawada_District_-_Bihar_-_1.jpg/960px-Foxnut_Makhana_-_Nawada_District_-_Bihar_-_1.jpg',
  'cani_salt':
      'https://cdn.stocksnap.io/img-thumbs/960w/6HO3GQMD6J.jpg',
  'cani_maida':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/All-Purpose_Flour_%284107895947%29.jpg/960px-All-Purpose_Flour_%284107895947%29.jpg',
  'cani_custard_apple':
      'https://upload.wikimedia.org/wikipedia/commons/3/3d/Atemola_%28cross_of_Annona_cherimola_and_Annona_squamosa%29.jpg',
  'cani_sleeping_pills':
      'https://cdn.stocksnap.io/img-thumbs/960w/TPI078T0IS.jpg',
  'cani_ayurvedic_medicine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Ayurvedic_herbs_02.jpg/960px-Ayurvedic_herbs_02.jpg',
  'cani_packaged_juice':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/20240814Satona_Kartonger.jpg/960px-20240814Satona_Kartonger.jpg',
  'cani_vitamin_c':
      'https://cdn.stocksnap.io/img-thumbs/960w/SVKP65LN31.jpg',
  'cani_shelf_eat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Golgappa_Pani_Puri_India.jpg/960px-Golgappa_Pani_Puri_India.jpg',
  'cani_shelf_drink':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Mix_Masala_Tea.jpg/960px-Mix_Masala_Tea.jpg',
  'cani_shelf_take':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/New_Reference_Material_Can_Improve_testing_of_Multivitamin_Tablets_%285880985736%29.jpg/960px-New_Reference_Material_Can_Improve_testing_of_Multivitamin_Tablets_%285880985736%29.jpg',
  'cani_shelf_doActivity':
      'https://cdn.stocksnap.io/img-thumbs/960w/RIUG2ATBWT.jpg',
  // The seven "See more" conditions, missed on the first pass (audit 2026-09-19).
  'condition_icp_cholestasis':
      'https://cdn.stocksnap.io/img-thumbs/960w/8E0DHVSNK8.jpg',
  'condition_hellp':
      'https://cdn.stocksnap.io/img-thumbs/960w/YG98MVAAAF.jpg',
  'condition_vasa_previa':
      'https://cdn.stocksnap.io/img-thumbs/960w/URMURJLZOO.jpg',
  'condition_rh_negative':
      'https://cdn.stocksnap.io/img-thumbs/960w/9M1HWW2JFV.jpg',
  'condition_pre_existing':
      'https://cdn.stocksnap.io/img-thumbs/960w/WTWX4BZ4FD.jpg',
  'condition_covid_pregnancy':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ENSM2NM1P.jpg',
  'condition_dengue_pregnancy':
      'https://pd.w.org/2023/05/826647086692c87d2.91927625-2048x1367.jpg',
  // The 27 report findings and 20 conditions (`finding_<id>`,
  // `condition_<id>`) — 2026-09-19, so the decoder's and Complications'
  // rows carry a picture. Placeholders from the same CC0 pool, chosen for
  // tone (a woman, a clinic, a newborn), not for the finding; a photo per
  // finding is a content job for the medical desk.
  'finding_low_lying_placenta':
      'https://cdn.stocksnap.io/img-thumbs/960w/40B226DC63.jpg',
  'finding_breech':
      'https://cdn.stocksnap.io/img-thumbs/960w/URMURJLZOO.jpg',
  'finding_nuchal_cord':
      'https://cdn.stocksnap.io/img-thumbs/960w/CSJVVRW2WA.jpg',
  'finding_gestational_diabetes':
      'https://cdn.stocksnap.io/img-thumbs/960w/GXKGNGWFHJ.jpg',
  'finding_low_fluid':
      'https://cdn.stocksnap.io/img-thumbs/960w/YTSDRKIDZP.jpg',
  'finding_preeclampsia':
      'https://cdn.stocksnap.io/img-thumbs/960w/R0HDABKHWA.jpg',
  'finding_high_fluid':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZLEPU3SIR.jpg',
  'finding_short_cervix':
      'https://cdn.stocksnap.io/img-thumbs/960w/9E4A810C8L.jpg',
  'finding_placental_calcification':
      'https://cdn.stocksnap.io/img-thumbs/960w/8E0DHVSNK8.jpg',
  'finding_twin_pregnancy':
      'https://cdn.stocksnap.io/img-thumbs/960w/4GGMTEBZY9.jpg',
  'finding_anemia':
      'https://cdn.stocksnap.io/img-thumbs/960w/0RYWABOQID.jpg',
  'finding_reduced_movements':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'finding_braxton_hicks':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ENSM2NM1P.jpg',
  'finding_high_bp':
      'https://cdn.stocksnap.io/img-thumbs/960w/B6BMB1BLFT.jpg',
  'finding_placenta_resolved':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJ8M7LUVLT.jpg',
  'finding_small_baby':
      'https://cdn.stocksnap.io/img-thumbs/960w/0B4LRPC8QF.jpg',
  'finding_large_baby':
      'https://cdn.stocksnap.io/img-thumbs/960w/MWJBXJDRPO.jpg',
  'finding_subchorionic_hematoma':
      'https://cdn.stocksnap.io/img-thumbs/960w/4UF03CU9M7.jpg',
  'finding_vanishing_twin':
      'https://cdn.stocksnap.io/img-thumbs/960w/IFKNZQ3CZE.jpg',
  'finding_marginal_cord':
      'https://cdn.stocksnap.io/img-thumbs/960w/KN1OCKC4Y2.jpg',
  'finding_single_umbilical_artery':
      'https://cdn.stocksnap.io/img-thumbs/960w/5YUFL6LC0E.jpg',
  'finding_ventriculomegaly':
      'https://cdn.stocksnap.io/img-thumbs/960w/XTPQ1UMFH1.jpg',
  'finding_eif':
      'https://cdn.stocksnap.io/img-thumbs/960w/EDI8LWKSBB.jpg',
  'finding_soft_markers':
      'https://cdn.stocksnap.io/img-thumbs/960w/WTWX4BZ4FD.jpg',
  'finding_fibroids':
      'https://cdn.stocksnap.io/img-thumbs/960w/6C4YTOELUE.jpg',
  'finding_group_b_strep':
      'https://cdn.stocksnap.io/img-thumbs/960w/P9LLUXMARB.jpg',
  'finding_rh_negative':
      'https://cdn.stocksnap.io/img-thumbs/960w/9M1HWW2JFV.jpg',
  'condition_gdm':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZLEPU3SIR.jpg',
  'condition_thyroid':
      'https://cdn.stocksnap.io/img-thumbs/960w/8E0DHVSNK8.jpg',
  'condition_anemia':
      'https://cdn.stocksnap.io/img-thumbs/960w/0RYWABOQID.jpg',
  'condition_pcos':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ENSM2NM1P.jpg',
  'condition_hyperemesis':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJ8M7LUVLT.jpg',
  'condition_placenta_previa':
      'https://cdn.stocksnap.io/img-thumbs/960w/MWJBXJDRPO.jpg',
  'condition_high_bp':
      'https://cdn.stocksnap.io/img-thumbs/960w/IFKNZQ3CZE.jpg',
  'condition_ectopic':
      'https://cdn.stocksnap.io/img-thumbs/960w/5YUFL6LC0E.jpg',
  'condition_miscarriage':
      'https://cdn.stocksnap.io/img-thumbs/960w/EDI8LWKSBB.jpg',
  'condition_preeclampsia':
      'https://cdn.stocksnap.io/img-thumbs/960w/6C4YTOELUE.jpg',
  'condition_placental_abruption':
      'https://cdn.stocksnap.io/img-thumbs/960w/9M1HWW2JFV.jpg',
  'condition_iugr':
      'https://cdn.stocksnap.io/img-thumbs/960w/0DCSAGJ9CM.jpg',
  'condition_low_amniotic_fluid':
      'https://cdn.stocksnap.io/img-thumbs/960w/VKCF2FYI3D.jpg',
  'condition_polyhydramnios':
      'https://pd.w.org/2023/05/826647086692c87d2.91927625-2048x1367.jpg',
  'condition_breech':
      'https://cdn.stocksnap.io/img-thumbs/960w/4UF03CU9M7.jpg',
  'condition_cervical_incompetence':
      'https://cdn.stocksnap.io/img-thumbs/960w/0B4LRPC8QF.jpg',
  'condition_uti':
      'https://cdn.stocksnap.io/img-thumbs/960w/B6BMB1BLFT.jpg',
  'condition_piles':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'condition_varicose_veins':
      'https://cdn.stocksnap.io/img-thumbs/960w/4GGMTEBZY9.jpg',
  'condition_fibroids':
      'https://cdn.stocksnap.io/img-thumbs/960w/9E4A810C8L.jpg',
  // The nine scan reads (`scan_<id>`, pvReadFromScan) and the calm read —
  // added 2026-09-19 so no written row and no scan page opens without a
  // picture (the user: "use images, don't skip on them").
  'scan_blood_tests':
      'https://cdn.stocksnap.io/img-thumbs/960w/9M1HWW2JFV.jpg',
  'scan_dating_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/MU4EHC71DU.jpg',
  'scan_nt_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZLEPU3SIR.jpg',
  'scan_nipt':
      'https://cdn.stocksnap.io/img-thumbs/960w/RAW1RLRTM7.jpg',
  'scan_anomaly_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/40B226DC63.jpg',
  'scan_ogtt':
      'https://cdn.stocksnap.io/img-thumbs/960w/XRSJ1LVRGM.jpg',
  'scan_growth_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/4UF03CU9M7.jpg',
  'scan_doppler':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJ8M7LUVLT.jpg',
  'scan_gbs':
      'https://pd.w.org/2023/05/826647086692c87d2.91927625-2048x1367.jpg',
  'preg_scan_read_calm':
      'https://cdn.stocksnap.io/img-thumbs/960w/MWJBXJDRPO.jpg',
  'preg_week_read_managing_nausea':
      'https://cdn.stocksnap.io/img-thumbs/960w/B6BMB1BLFT.jpg',
  'preg_week_read_first_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/MU4EHC71DU.jpg',
  'preg_week_read_first_trimester':
      'https://cdn.stocksnap.io/img-thumbs/960w/W6KDUGJ4LR.jpg',
  'preg_week_read_nutrition_t2':
      'https://cdn.stocksnap.io/img-thumbs/960w/G8QICMKLUV.jpg',
  'preg_week_read_partner_support':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'preg_week_read_halfway':
      'https://cdn.stocksnap.io/img-thumbs/960w/4UF03CU9M7.jpg',
  'preg_week_read_anomaly_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/MU4EHC71DU.jpg',
  'preg_week_read_baby_sound':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJ8M7LUVLT.jpg',
  'preg_week_read_talking_baby':
      'https://cdn.stocksnap.io/img-thumbs/960w/0RYWABOQID.jpg',
  'preg_week_read_back_pain':
      'https://cdn.stocksnap.io/img-thumbs/960w/0B4LRPC8QF.jpg',
  'preg_week_read_third_tri_prep':
      'https://cdn.stocksnap.io/img-thumbs/960w/SITUKGWGWJ.jpg',
  'preg_week_read_movement_awareness':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZLEPU3SIR.jpg',
  'preg_week_read_hospital_bag':
      'https://cdn.stocksnap.io/img-thumbs/960w/SITUKGWGWJ.jpg',
  'preg_week_read_labour_prep':
      'https://cdn.stocksnap.io/img-thumbs/960w/4GGMTEBZY9.jpg',
  'preg_week_read_first_24h':
      'https://cdn.stocksnap.io/img-thumbs/960w/ILUIZBPPTT.jpg',
  'preg_week_read_exp_priya':
      'https://cdn.stocksnap.io/img-thumbs/960w/0B4LRPC8QF.jpg',
  'preg_week_read_exp_meera':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ENSM2NM1P.jpg',
  'preg_week_read_res_voices':
      'https://cdn.stocksnap.io/img-thumbs/960w/0RYWABOQID.jpg',
  'preg_week_read_res_stress':
      'https://cdn.stocksnap.io/img-thumbs/960w/MWJBXJDRPO.jpg',
  'preg_scan_read_sex_law':
      'https://cdn.stocksnap.io/img-thumbs/960w/40B226DC63.jpg',
  'preg_scan_read_costs':
      'https://cdn.stocksnap.io/img-thumbs/960w/5YUFL6LC0E.jpg',
  'preg_scan_read_every_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/URMURJLZOO.jpg',
  'preg_scan_read_keep':
      'https://cdn.stocksnap.io/img-thumbs/960w/AB4F938C85.jpg',
  'preg_scan_read_take_along':
      'https://cdn.stocksnap.io/img-thumbs/960w/EDI8LWKSBB.jpg',
  'preg_cond_read_bp_dangerous':
      'https://cdn.stocksnap.io/img-thumbs/960w/WTWX4BZ4FD.jpg',
  'preg_cond_read_bleeding':
      'https://cdn.stocksnap.io/img-thumbs/960w/M38DGA9LK7.jpg',
  'preg_cond_read_less_movement':
      'https://cdn.stocksnap.io/img-thumbs/960w/8E0DHVSNK8.jpg',
  'preg_cond_read_sugar_india':
      'https://cdn.stocksnap.io/img-thumbs/960w/KRX6BEOKGM.jpg',
  'preg_cond_read_thyroid_tablet':
      'https://cdn.stocksnap.io/img-thumbs/960w/LKM1T38B6S.jpg',
  'preg_cond_read_iron':
      'https://cdn.stocksnap.io/img-thumbs/960w/8OY1EZZVXX.jpg',
  'preg_diet_read_add_now':
      'https://cdn.stocksnap.io/img-thumbs/960w/KRX6BEOKGM.jpg',
  'preg_labour_read_pain_relief':
      'https://cdn.stocksnap.io/img-thumbs/960w/4GGMTEBZY9.jpg',
  'nut_milk':
      'https://cdn.stocksnap.io/img-thumbs/960w/P2QSUXKCN5.jpg',
  'cani_chyawanprash':
      'https://cdn.stocksnap.io/img-thumbs/960w/RV2WZOWKSO.jpg',
  'cani_laxative':
      'https://cdn.stocksnap.io/img-thumbs/960w/1ZOMOXPNDS.jpg',
  'nutrition_hero':
      'https://cdn.stocksnap.io/img-thumbs/960w/7UZYSYUAX7.jpg',
  'cani_hero':
      'https://cdn.stocksnap.io/img-thumbs/960w/VBQSBXBAO8.jpg',
  'nut_orange':
      'https://cdn.stocksnap.io/img-thumbs/960w/SVKP65LN31.jpg',
  'nut_r_vegetable_poha':
      'https://live.staticflickr.com/116/305698269_7ab5752616_b.jpg',
  'nut_r_vegetable_upma':
      'https://live.staticflickr.com/65535/49712703693_7326f27281_b.jpg',
  'nut_r_peanut_jaggery_chikki':
      'https://live.staticflickr.com/4016/4289423176_c6ca559bfc_b.jpg',
  'nut_r_jaggery_kheer':
      'https://live.staticflickr.com/181/481045627_71fc48f652_b.jpg',
  'nut_r_ginger_lemon_tea':
      'https://live.staticflickr.com/4023/4242146993_23dd82fc6c.jpg',
  'nut_r_badam_milk':
      'https://live.staticflickr.com/128/349994358_8b9d099c55_b.jpg',
  'nut_r_moong_dal_soup':
      'https://live.staticflickr.com/3444/3210281474_f3950cb1c0_b.jpg',
  'nut_r_tomato_carrot_soup':
      'https://live.staticflickr.com/7051/6973566295_153eaef49e_b.jpg',
  'nut_r_egg_curry':
      'https://live.staticflickr.com/6134/5931058622_23be744086_b.jpg',
  'nut_r_dal_palak':
      'https://live.staticflickr.com/2466/3751603633_33224e092a_b.jpg',
  // ---- Trying to conceive: the Fertile window door, every card (2026-09-28)
  // The user, on the one card that had a photo ("How conception works"):
  // "that looks clean… I like that card", and the text-only cards beside it
  // "look empty". So every card on the door has one: picked by eye from
  // contact sheets of StockSnap (CC0, through Openverse) and Wikimedia
  // Commons, and checked again cropped to the card (150 x 176). Objects and
  // scenes only: no faces, no bodies, nothing clinical beyond a test stick,
  // a thermometer or a stethoscope. `ttc_read_*` is the read's own picture,
  // so the card and the page it opens show one image; `ttc_tile_*` is a
  // card that opens no read, keyed by its title (`ttcTilePhotoId`).
  // Your best days
  'ttc_tile_your_best_days_this_month':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZI905NZJY1.jpg',
  // Which days
  'ttc_tile_which_days_can_you_get_pregnant':
      'https://cdn.stocksnap.io/img-thumbs/960w/9TFTNGHT2I.jpg',
  // Body shows days
  'ttc_tile_how_the_body_shows_the_right_days':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bf/Medical_mercury_thermometer_with_velvet-lined_cardboard_box_-_focus_stack_%282020-05-25%29.jpg/1280px-Medical_mercury_thermometer_with_velvet-lined_cardboard_box_-_focus_stack_%282020-05-25%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ovulation kits
  'ttc_read_ovulation_kits':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/Ovulatietest.jpg/1280px-Ovulatietest.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Kits irregular
  'ttc_read_ovulation_tests_irregular':
      'https://cdn.stocksnap.io/img-thumbs/960w/2FS8R15QYN.jpg',
  // Morning temperature (2026-09-28, a new read on this tab). A morning
  // bedroom, not a thermometer: "How the body shows the right days" already
  // carries a glass thermometer on the same tab, and the read's point is
  // "first thing, before you get up".
  'ttc_read_morning_temperature':
      'https://cdn.stocksnap.io/img-thumbs/960w/XWI13131WH.jpg',
  // Buy a kit
  'ttc_tile_buy_an_ovulation_kit':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/73/Small_pharmacy_in_Kerala.jpg/1280px-Small_pharmacy_in_Kerala.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // How often is best
  'ttc_read_timing_myths':
      'https://cdn.stocksnap.io/img-thumbs/960w/0NBHTCNTAH.jpg',
  // Every day or not?
  'ttc_tile_every_day_or_not':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/60/2011-03-05_The_little_guy%27s_special_day.jpg/1280px-2011-03-05_The_little_guy%27s_special_day.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Positions
  'ttc_tile_do_positions_matter':
      'https://cdn.stocksnap.io/img-thumbs/960w/M0YZ9Q79DZ.jpg',
  // Lie down after?
  'ttc_tile_should_you_lie_down_after':
      'https://cdn.stocksnap.io/img-thumbs/960w/OE0F9BHXJQ.jpg',
  // Orgasm?
  'ttc_tile_do_you_need_to_orgasm':
      'https://cdn.stocksnap.io/img-thumbs/960w/S8KD5HJXKW.jpg',
  // Six myths film
  'ttc_tile_six_myths_about_timing_one_by_one':
      'https://cdn.stocksnap.io/img-thumbs/960w/EIW9MO2ZFG.jpg',
  // Can stress stop it
  'ttc_read_stress_fertility':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6a/Masala_Chai.jpg/1280px-Masala_Chai.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Just relax film
  'ttc_tile_why_just_relax_is_the_wrong_advice':
      'https://cdn.stocksnap.io/img-thumbs/960w/L3L066B299.jpg',
  // Cycle film
  'ttc_tile_your_cycle_drawn_out_step_by_step':
      'https://cdn.stocksnap.io/img-thumbs/960w/CXWBTVSHPC.jpg',
  // Two-week wait
  'ttc_read_two_week_wait':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/38/Hourglass_with_sand.jpg/1280px-Hourglass_with_sand.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Early signs
  'ttc_read_early_signs':
      'https://cdn.stocksnap.io/img-thumbs/960w/4VHE7E68OE.jpg',
  // Implantation
  'ttc_read_implantation_bleeding':
      'https://cdn.stocksnap.io/img-thumbs/960w/YXEVX6593D.jpg',
  // Should I test?
  'ttc_tile_should_i_test':
      'https://cdn.stocksnap.io/img-thumbs/960w/7HUKLFKXGU.jpg',
  // When to test
  'ttc_read_when_to_test':
      'https://cdn.stocksnap.io/img-thumbs/960w/NP4PTJZ6C3.jpg',
  // How to test
  'ttc_read_how_to_test':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Pregnancy_test_36068237046.jpg/1280px-Pregnancy_test_36068237046.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Faint line
  'ttc_read_faint_line':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/02/Urine_Pregnancy_Test_Positive_and_Negative.jpg/1280px-Urine_Pregnancy_Test_Positive_and_Negative.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Late negative
  'ttc_read_late_negative':
      'https://cdn.stocksnap.io/img-thumbs/960w/A3GM7T9ZDV.jpg',
  // Feeling pregnant
  'ttc_read_feeling_pregnant':
      'https://cdn.stocksnap.io/img-thumbs/960w/SC7APHV0JX.jpg',
  // Homework
  'ttc_read_sex_homework':
      'https://cdn.stocksnap.io/img-thumbs/960w/V7HFIL2OWA.jpg',
  // Low desire
  'ttc_read_low_desire':
      'https://cdn.stocksnap.io/img-thumbs/960w/OVEFAJUOXU.jpg',
  // Staying close
  'ttc_read_keeping_close':
      'https://cdn.stocksnap.io/img-thumbs/960w/MVYHPT6H7C.jpg',
  // Pain during sex
  'ttc_read_pain_vaginismus':
      'https://cdn.stocksnap.io/img-thumbs/960w/7Q5EDMWILQ.jpg',
  // Lubricants
  'ttc_read_lubricants':
      'https://cdn.stocksnap.io/img-thumbs/960w/W6OK3HV9FW.jpg',
  // Sex after window
  'ttc_read_sex_after_window':
      'https://cdn.stocksnap.io/img-thumbs/960w/YHL08ZTV8H.jpg',
  // How sperm made
  'ttc_tile_how_sperm_are_made':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZWH3M2EJAX.jpg',
  // His numbers film
  'ttc_tile_three_things_that_really_change_his_numbers':
      'https://cdn.stocksnap.io/img-thumbs/960w/2USDVKPSWS.jpg',
  // Testing early
  'ttc_read_case_for_testing':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b0/Binocular_compound_microscope%2C_Carl_Zeiss_Jena%2C_1914_%286779276516%29.jpg/1280px-Binocular_compound_microscope%2C_Carl_Zeiss_Jena%2C_1914_%286779276516%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Heat habits
  'ttc_read_heat_habits':
      'https://cdn.stocksnap.io/img-thumbs/960w/0D06E5728E.jpg',
  // 3 things for you
  'ttc_tile_3_things_for_you':
      'https://cdn.stocksnap.io/img-thumbs/960w/UZIR6LIWHX.jpg',
  // Eat and avoid
  'ttc_read_three_months_before':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/60/Vegetarian_thali-MB-42.jpg/1280px-Vegetarian_thali-MB-42.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Folic acid
  'ttc_read_folic_acid':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9d/Aloo_Palak_%28Spinach_with_Potatoes%29.JPG/1280px-Aloo_Palak_%28Spinach_with_Potatoes%29.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What to cut
  'ttc_read_what_to_cut':
      'https://cdn.stocksnap.io/img-thumbs/960w/F61SSKYWMD.jpg',
  // Weight kindly
  'ttc_read_weight_kindly':
      'https://cdn.stocksnap.io/img-thumbs/960w/9RT9BHFJGX.jpg',
  // Many months?
  'ttc_read_when_to_seek_help':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/01/Stethoscope_No.120.JPG/1280px-Stethoscope_No.120.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // How many months
  'ttc_read_how_long_it_takes':
      'https://cdn.stocksnap.io/img-thumbs/960w/5CCRTPAWLM.jpg',
  // Signs not to wait
  'ttc_tile_signs_not_to_wait':
      'https://cdn.stocksnap.io/img-thumbs/960w/QKNVDENHQP.jpg',
  // Talk to a doctor
  'ttc_tile_talk_to_a_doctor':
      'https://cdn.stocksnap.io/img-thumbs/960w/RAW1RLRTM7.jpg',  // ---- Trying to conceive: the other eight doors and the home's reads
  // (2026-09-28, launch sanity D1 / H10). The same pipeline as the Fertile
  // window above: picked by eye from contact sheets of StockSnap (CC0,
  // through Openverse) and Wikimedia Commons (CC0, CC BY, CC BY-SA and
  // public domain only), then checked again cropped to the card. Objects
  // and scenes, no pregnant bellies, no brand packs, nothing clinical
  // beyond a test tube, a scan machine or a stethoscope; After a loss is
  // light, water, feathers, benches and tea. A `ttc_read_*` line is the
  // read's own picture, shared by every card that opens that read; a
  // `ttc_tile_*` line is a card that opens no read, or a second card on
  // a read that already shows its photo on the same tab.
  // -- PCOS
  // PCOS, explained in five minutes
  'ttc_tile_pcos_explained_in_five_minutes':
      'https://cdn.stocksnap.io/img-thumbs/960w/2H0QPGDVGZ.jpg',
  // PCOS and your cycle
  'ttc_read_pcos_cycle':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0d/Phases_moon_avg2.jpg/1280px-Phases_moon_avg2.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Irregular periods, explained
  'ttc_read_pcos_irregular':
      'https://cdn.stocksnap.io/img-thumbs/960w/2FRRD2PUVA.jpg',
  // How common is PCOS?
  'ttc_tile_how_common_is_pcos':
      'https://cdn.stocksnap.io/img-thumbs/960w/T5J75YI5H0.jpg',
  // PCOS or ovarian cysts
  'ttc_tile_pcos_or_ovarian_cysts':
      'https://cdn.stocksnap.io/img-thumbs/960w/F6TBSCOKEI.jpg',
  // PCOS or thyroid
  'ttc_tile_pcos_or_thyroid':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/VOYAGER_adjustable_tip_spacing_pipette.jpg/1280px-VOYAGER_adjustable_tip_spacing_pipette.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Hair changes, explained
  'ttc_tile_hair_changes_explained':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c6/Egyptian_-_Wooden_Comb_-_Walters_61306.jpg/1280px-Egyptian_-_Wooden_Comb_-_Walters_61306.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // If a doctor says PCOS
  'ttc_read_pcos_diagnosed':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8c/Stethoscope_in_use.jpg/1280px-Stethoscope_in_use.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What a PCOS-friendly Indian plate looks like
  'ttc_tile_what_a_pcos_friendly_indian_plate_looks_like':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/%E0%A4%AE%E0%A5%87%E0%A4%B0%E0%A5%80_%E0%A4%AA%E0%A5%8D%E0%A4%AF%E0%A4%B0%E0%A5%80_%E0%A4%AE%E0%A4%BE%E0%A4%81_%E0%A4%95%E0%A5%87_%E0%A4%B9%E0%A4%BE%E0%A4%A5_%E0%A4%95%E0%A4%BE_%E0%A4%96%E0%A4%BE%E0%A4%A8%E0%A4%BE.jpg/1280px-%E0%A4%AE%E0%A5%87%E0%A4%B0%E0%A5%80_%E0%A4%AA%E0%A5%8D%E0%A4%AF%E0%A4%B0%E0%A5%80_%E0%A4%AE%E0%A4%BE%E0%A4%81_%E0%A4%95%E0%A5%87_%E0%A4%B9%E0%A4%BE%E0%A4%A5_%E0%A4%95%E0%A4%BE_%E0%A4%96%E0%A4%BE%E0%A4%A8%E0%A4%BE.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Eating for steadier blood sugar, with nothing banned
  'ttc_read_pcos_insulin':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/Ordinary_chickpeas_in_a_ceramic_bowl.jpg/1280px-Ordinary_chickpeas_in_a_ceramic_bowl.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // A day of eating, with PCOS
  'ttc_read_pcos_food':
      'https://upload.wikimedia.org/wikipedia/commons/f/f4/Poha%2C_a_snack_made_of_flattened_rice.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled',
  // Moong dal chilla with curd
  'ttc_tile_moong_dal_chilla_with_curd':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/aa/Moonglet_chilla_with_curd_and_hot_tea.jpg/1280px-Moonglet_chilla_with_curd_and_hot_tea.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Do you have to give up rice?
  'ttc_tile_do_you_have_to_give_up_rice':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/12/Rajma_Chawal_by_Rama_Bhave.jpg/1280px-Rajma_Chawal_by_Rama_Bhave.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Inositol: what the studies show
  'ttc_read_pcos_inositol':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/58/Nortriptyline_HCL_capsules_-_50mg_and_25mg.JPG/1280px-Nortriptyline_HCL_capsules_-_50mg_and_25mg.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Worth it or hype?
  'ttc_tile_worth_it_or_hype':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/94/Cod_Liver_Oil_Capsules.jpg/1280px-Cod_Liver_Oil_Capsules.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Myo-inositol
  'ttc_tile_myo_inositol':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Pills_Vitamines_Capsules.JPG/1280px-Pills_Vitamines_Capsules.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Weight and PCOS, said kindly
  'ttc_read_pcos_weight':
      'https://cdn.stocksnap.io/img-thumbs/960w/BKSLYECRJN.jpg',
  // Sleep, movement and insulin
  'ttc_tile_sleep_movement_and_insulin':
      'https://cdn.stocksnap.io/img-thumbs/960w/N5MVFW5G8F.jpg',
  // Yoga, and your mood
  'ttc_tile_yoga_and_your_mood':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d3/Nelumno_nucifera_open_flower_-_botanic_garden_adelaide2.jpg/1280px-Nelumno_nucifera_open_flower_-_botanic_garden_adelaide2.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Gentle movement for PCOS
  'ttc_tile_gentle_movement_for_pcos':
      'https://cdn.stocksnap.io/img-thumbs/960w/EWQYYB0G5A.jpg',
  // PCOS and ovulation
  'ttc_read_pcos_ovulation':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/86/Nelumbo_nucifera%2C_also_known_as_Indian_lotus_in_bud_stage_%28Image_6_of_7%29.jpg/1280px-Nelumbo_nucifera%2C_also_known_as_Indian_lotus_in_bud_stage_%28Image_6_of_7%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Cycles without ovulation
  'ttc_tile_cycles_without_ovulation':
      'https://cdn.stocksnap.io/img-thumbs/960w/PQXYMRLH8S.jpg',
  // Getting pregnant with PCOS: what to expect
  'ttc_read_pcos_timelines':
      'https://cdn.stocksnap.io/img-thumbs/960w/XSIP9B3GAB.jpg',
  // The PCOS treatments your doctor may offer
  'ttc_tile_the_pcos_treatments_your_doctor_may_offer':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/56/2023_Kasetka_z_lekami.jpg/1280px-2023_Kasetka_z_lekami.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Before any tablet
  'ttc_read_pcos_treatment':
      'https://cdn.stocksnap.io/img-thumbs/960w/F8B73CPSBK.jpg',
  // Letrozole, metformin and the usual order
  'ttc_read_pcos_meds':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0b/Alprazolam_orally_disintegrating_tablets%2C_blister_packs.jpg/1280px-Alprazolam_orally_disintegrating_tablets%2C_blister_packs.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Cycle Companion
  'ttc_tile_cycle_companion':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/09/Manual_scrollable_wooden_wall_calendar.jpg/1280px-Manual_scrollable_wooden_wall_calendar.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Log your symptoms
  'ttc_tile_log_your_symptoms':
      'https://cdn.stocksnap.io/img-thumbs/960w/DPKNIIN5X3.jpg',
  // What your cycle shows
  'ttc_tile_what_your_cycle_shows':
      'https://cdn.stocksnap.io/img-thumbs/960w/ASEQPBZMMX.jpg',
  // When to see a doctor
  'ttc_tile_when_to_see_a_doctor':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/de/Instrumentos_medicos_de_uso_en_Cardiolog%C3%ADa.jpg/1280px-Instrumentos_medicos_de_uso_en_Cardiolog%C3%ADa.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // When to see a specialist
  'ttc_tile_when_to_see_a_specialist':
      'https://cdn.stocksnap.io/img-thumbs/960w/EJAXI7R4TB.jpg',
  // Talk to a PCOS specialist
  'ttc_tile_talk_to_a_pcos_specialist':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/2023_Stetoskop.jpg/1280px-2023_Stetoskop.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // The PCOS programme
  'ttc_tile_the_pcos_programme':
      'https://cdn.stocksnap.io/img-thumbs/960w/S059QDGBOG.jpg',
  // -- IVF and IUI
  // Should I seek fertility help?
  'ttc_tile_should_i_seek_fertility_help':
      'https://cdn.stocksnap.io/img-thumbs/960w/TJL5H02YIP.jpg',
  // Speak to a fertility specialist
  'ttc_tile_speak_to_a_fertility_specialist':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9c/Stethoscope-ja-2019.jpg/1280px-Stethoscope-ja-2019.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // An IVF cycle, start to finish
  'ttc_tile_an_ivf_cycle_start_to_finish':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZISUDDTDF.jpg',
  // What IUI and IVF involve
  'ttc_read_ivf_explained':
      'https://cdn.stocksnap.io/img-thumbs/960w/CN63QSUO8C.jpg',
  // IUI or IVF, and when to move from one to the other
  'ttc_tile_iui_or_ivf_and_when_to_move_from_one_to_the_other':
      'https://cdn.stocksnap.io/img-thumbs/960w/UGFCFONZQA.jpg',
  // ICSI: when it's needed, and when it's just routine
  'ttc_read_ivf_icsi':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Scientist_with_a_Petri_dish_%28Unsplash%29.jpg/1280px-Scientist_with_a_Petri_dish_%28Unsplash%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What a fertility check involves
  'ttc_read_ivf_workup':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/16/Stainless_Steel_Test_Tube_Rack.JPG/1280px-Stainless_Steel_Test_Tube_Rack.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // His side of the tests
  'ttc_read_semen_analysis':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bb/Test_tubes.jpg/1280px-Test_tubes.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Words your clinic uses
  'ttc_read_clinic_glossary':
      'https://cdn.stocksnap.io/img-thumbs/960w/9Z7XRBK4N5.jpg',
  // Ovulation tablets, in plain words
  'ttc_read_ovulation_tablets':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/A_blister_pack_of_Androcur_50mg_tablets_in_Turkey_%28obverse%29.jpg/1280px-A_blister_pack_of_Androcur_50mg_tablets_in_Turkey_%28obverse%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Follicle scans
  'ttc_read_follicle_scans':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f6/A_medical_ultrasound_linear_array_probe%2C_scan_head%2C_transducer.jpg/1280px-A_medical_ultrasound_linear_array_probe%2C_scan_head%2C_transducer.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Donor eggs and sperm
  'ttc_read_donor_eggs_sperm':
      'https://cdn.stocksnap.io/img-thumbs/960w/D8RFKPCP0G.jpg',
  // Surrogacy in India
  'ttc_read_surrogacy_india':
      'https://cdn.stocksnap.io/img-thumbs/960w/Z1TKDI29FZ.jpg',
  // Trying after 35
  'ttc_read_age_after_35':
      'https://cdn.stocksnap.io/img-thumbs/960w/WXREXGYBC6.jpg',
  // Trying after 40
  'ttc_read_age_after_40':
      'https://cdn.stocksnap.io/img-thumbs/960w/TASW0BHYNY.jpg',
  // Harder the second time?
  'ttc_read_second_baby':
      'https://cdn.stocksnap.io/img-thumbs/960w/CCKX20IAFE.jpg',
  // Egg freezing in India
  'ttc_read_egg_freezing':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/42/Liquid_nitrogen_tank.jpg/1280px-Liquid_nitrogen_tank.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What IVF really costs in India
  'ttc_read_ivf_costs':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a8/Some_Coins_%2820823589%29.jpeg/1280px-Some_Coins_%2820823589%29.jpeg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What a package leaves out
  'ttc_read_ivf_package':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/Security_edges_of_the_Indian_5_Rupee_coins.jpg/1280px-Security_edges_of_the_Indian_5_Rupee_coins.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // How to read a clinic's success rate
  'ttc_read_ivf_success_rates':
      'https://cdn.stocksnap.io/img-thumbs/960w/G0V362YTA5.jpg',
  // Questions to ask before you sign up
  'ttc_tile_questions_to_ask_before_you_sign_up':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e4/Clipboard_on_a_table_with_steps_listed_on_it.jpg/1280px-Clipboard_on_a_table_with_steps_listed_on_it.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // The injections: what they're really like
  'ttc_read_ivf_injections':
      'https://upload.wikimedia.org/wikipedia/commons/6/69/Needle_and_syringe.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled',
  // OHSS: when to call the clinic
  'ttc_read_ivf_ohss':
      'https://cdn.stocksnap.io/img-thumbs/960w/AQZQ7RGC7R.jpg',
  // Your first visit: the baseline scan
  'ttc_read_tx_baseline_scan':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e4/A_modern_medical_ultrasound_scanner.jpg/1280px-A_modern_medical_ultrasound_scanner.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Monitoring scans
  'ttc_read_tx_monitoring_scans':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b8/Sonography_Machine_Donation_from_Raleigh_Radiology-21.jpg/1280px-Sonography_Machine_Donation_from_Raleigh_Radiology-21.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // The trigger injection
  'ttc_read_tx_trigger_shot':
      'https://cdn.stocksnap.io/img-thumbs/960w/1HDO9I6J22.jpg',
  // IUI day
  'ttc_read_tx_iui_day':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/Nelumbo_nucifera-IMG_5613.jpg/1280px-Nelumbo_nucifera-IMG_5613.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Day 1, day 3, day 5
  'ttc_read_tx_embryo_days':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7c/Agar_plates_different_types.jpg/1280px-Agar_plates_different_types.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Fresh or frozen transfer
  'ttc_read_tx_fresh_or_frozen':
      'https://cdn.stocksnap.io/img-thumbs/960w/2C1MRCDUXL.jpg',
  // Frozen embryo transfer, step by step
  'ttc_read_tx_frozen_transfer':
      'https://cdn.stocksnap.io/img-thumbs/960w/P0NXH7XVCS.jpg',
  // Transfer day, and the progesterone after
  'ttc_read_tx_transfer_day':
      'https://cdn.stocksnap.io/img-thumbs/960w/MUNCW5ZFUZ.jpg',
  // The two-week wait after IVF or IUI
  'ttc_read_tx_wait_after_treatment':
      'https://cdn.stocksnap.io/img-thumbs/960w/NNEZM4UXE6.jpg',
  // Getting through the two-week wait
  'ttc_tile_getting_through_the_two_week_wait':
      'https://cdn.stocksnap.io/img-thumbs/960w/3AKFOCTZEQ.jpg',
  // The beta test
  'ttc_read_tx_beta_test':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3c/Test_tubes_in_rack.jpg/1280px-Test_tubes_in_rack.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // When the test is negative
  'ttc_read_tx_negative_after_treatment':
      'https://cdn.stocksnap.io/img-thumbs/960w/3768B774EC.jpg',
  // Your review appointment
  'ttc_read_tx_review_appointment':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c0/Wood-clipboard.jpg/1280px-Wood-clipboard.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Is egg retrieval painful?
  'ttc_read_ivf_retrieval':
      'https://cdn.stocksnap.io/img-thumbs/960w/7D54868965.jpg',
  // Does bed rest after transfer help?
  'ttc_tile_does_bed_rest_after_transfer_help':
      'https://cdn.stocksnap.io/img-thumbs/960w/CUGR92OCUB.jpg',
  // Can I work through a cycle?
  'ttc_read_ivf_working':
      'https://cdn.stocksnap.io/img-thumbs/960w/DU0O1PCIMH.jpg',
  // Track this treatment cycle
  'ttc_tile_track_this_treatment_cycle':
      'https://cdn.stocksnap.io/img-thumbs/960w/IU6HNPC2NT.jpg',
  // Keep your reports together
  'ttc_tile_keep_your_reports_together':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f5/Document_File_Folders_%2823665323559%29.jpg/1280px-Document_File_Folders_%2823665323559%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Your medicines and timings
  'ttc_tile_your_medicines_and_timings':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/41/Pill_Box_%2832636946385%29.jpg/1280px-Pill_Box_%2832636946385%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // -- Getting ready
  // When to start what, and how early
  'ttc_read_supplement_timing':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Pill_Organizer_With_Vitamins_And_Medicines.jpg/1280px-Pill_Organizer_With_Vitamins_And_Medicines.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Folic acid and preconception supplements
  'ttc_tile_folic_acid_and_preconception_supplements':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d5/Pills_and_medicines_01.jpg/1280px-Pills_and_medicines_01.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // A week of Indian meals for trying
  'ttc_read_meal_plan_week':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a6/Dal_Chana_Tarka.JPG/1280px-Dal_Chana_Tarka.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ten everyday recipes
  'ttc_read_everyday_recipes':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4b/Rajmamasala.jpg/1280px-Rajmamasala.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Plan your own week
  'ttc_tile_plan_your_own_week':
      'https://cdn.stocksnap.io/img-thumbs/960w/QUDRF9ALH7.jpg',
  // Iron before pregnancy
  'ttc_read_iron_before_pregnancy':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/69/Amla_%28Indian_Gooseberry%29_Juice.JPG/1280px-Amla_%28Indian_Gooseberry%29_Juice.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Omega-3 without fish
  'ttc_read_omega3_without_fish':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b2/Walnuts_-_whole_and_open_with_halved_kernel.jpg/1280px-Walnuts_-_whole_and_open_with_halved_kernel.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ask a dietitian: ten questions
  'ttc_read_ask_dietitian':
      'https://cdn.stocksnap.io/img-thumbs/960w/FY87BH4RPX.jpg',
  // Tests and vaccines worth doing first
  'ttc_read_preconception_tests':
      'https://cdn.stocksnap.io/img-thumbs/960w/TVEUBLIOSK.jpg',
  // The carrier screening that matters in India
  'ttc_read_carrier_screening':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5a/Laboratory_pipettes.jpg/1280px-Laboratory_pipettes.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Check your vaccinations
  'ttc_tile_check_your_vaccinations':
      'https://cdn.stocksnap.io/img-thumbs/960w/TBJ9OPDGMK.jpg',
  // The full test library
  'ttc_tile_the_full_test_library':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/92/File_Folder_with_Documents_%2823909830671%29.jpg/1280px-File_Folder_with_Documents_%2823909830671%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Habits worth building now
  'ttc_tile_habits_worth_building_now':
      'https://cdn.stocksnap.io/img-thumbs/960w/645GI8G1W4.jpg',
  // Track what you're working on
  'ttc_tile_track_what_you_re_working_on':
      'https://cdn.stocksnap.io/img-thumbs/960w/FFFK9P5EI6.jpg',
  // Coming off birth control
  'ttc_read_coming_off_birth_control':
      'https://cdn.stocksnap.io/img-thumbs/960w/UMIOY6CVUM.jpg',
  // Medicines and conditions to check with a doctor
  'ttc_read_meds_and_conditions':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b6/Pill_Box_%2824888074919%29.jpg/1280px-Pill_Box_%2824888074919%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // His part
  'ttc_read_whose_side':
      'https://cdn.stocksnap.io/img-thumbs/960w/8X6QDD1S5F.jpg',
  // Your first gynaecologist visit
  'ttc_read_first_gyn_visit':
      'https://cdn.stocksnap.io/img-thumbs/960w/KMGC56X3AO.jpg',
  // Can a past abortion affect trying now?
  'ttc_read_after_abortion':
      'https://cdn.stocksnap.io/img-thumbs/960w/A1ADA3D0D9.jpg',
  // Money before a baby
  'ttc_read_money_before_baby':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/One_Rupee_Indian_coins.JPG/1280px-One_Rupee_Indian_coins.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Your pre-pregnancy checklist
  'ttc_tile_your_pre_pregnancy_checklist':
      'https://cdn.stocksnap.io/img-thumbs/960w/EEJM42JAOO.jpg',
  // Talk to someone before you start
  'ttc_tile_talk_to_someone_before_you_start':
      'https://cdn.stocksnap.io/img-thumbs/960w/NDIQFBYIHR.jpg',
  // Talk to a nutritionist
  'ttc_tile_talk_to_a_nutritionist':
      'https://cdn.stocksnap.io/img-thumbs/960w/FAJTBOD01P.jpg',
  // -- His side
  // Does his age matter?
  'ttc_read_his_age':
      'https://cdn.stocksnap.io/img-thumbs/960w/L9R4MMVFVJ.jpg',
  // Why his side gets tested last
  'ttc_tile_why_his_side_gets_tested_last':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d4/3_Hourglasses_Wellcome_L0011331.jpg/1280px-3_Hourglasses_Wellcome_L0011331.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Reading a semen report
  'ttc_tile_reading_a_semen_report':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/36/Microscope_toy.jpg/1280px-Microscope_toy.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Read your semen report
  'ttc_tile_read_your_semen_report':
      'https://cdn.stocksnap.io/img-thumbs/960w/CBOLBKWDV5.jpg',
  // Have the report read properly
  'ttc_tile_have_the_report_read_properly':
      'https://cdn.stocksnap.io/img-thumbs/960w/UP9J4EZYNJ.jpg',
  // Keep his reports with yours
  'ttc_tile_keep_his_reports_with_yours':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/Manila_folder.jpg/1280px-Manila_folder.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // The words on the report, in plain English
  'ttc_read_report_words':
      'https://cdn.stocksnap.io/img-thumbs/960w/8Y0EDX4VP9.jpg',
  // If the result is normal
  'ttc_read_result_normal':
      'https://cdn.stocksnap.io/img-thumbs/960w/FSKMJDOOMB.jpg',
  // If the first test is abnormal
  'ttc_read_result_abnormal':
      'https://cdn.stocksnap.io/img-thumbs/960w/EIQTJEJYF6.jpg',
  // If no sperm is found
  'ttc_read_azoospermia':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZJE4KHCDWE.jpg',
  // What three months looks like
  'ttc_read_three_months':
      'https://cdn.stocksnap.io/img-thumbs/960w/BOTAC2JQYV.jpg',
  // Zinc and CoQ10, honestly
  'ttc_read_zinc_coq10':
      'https://cdn.stocksnap.io/img-thumbs/960w/B9461G0UUU.jpg',
  // Zinc
  'ttc_tile_zinc':
      'https://cdn.stocksnap.io/img-thumbs/960w/RWAQYSF8BH.jpg',
  // CoQ10
  'ttc_tile_coq10':
      'https://cdn.stocksnap.io/img-thumbs/960w/HWP9X99UM3.jpg',
  // The half nobody talks about
  'ttc_tile_the_half_nobody_talks_about':
      'https://cdn.stocksnap.io/img-thumbs/960w/Y4P32I1G1K.jpg',
  // What he can track
  'ttc_tile_what_he_can_track':
      'https://cdn.stocksnap.io/img-thumbs/960w/DB7F22291B.jpg',
  // Talk to an andrologist
  'ttc_tile_talk_to_an_andrologist':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e2/Doctors_stethoscope_1.jpg/1280px-Doctors_stethoscope_1.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // When sex is hard for him under pressure
  'ttc_read_his_side_pressure':
      'https://cdn.stocksnap.io/img-thumbs/960w/CNO1FTRUAP.jpg',
  // When he goes quiet
  'ttc_read_bringing_him_in':
      'https://cdn.stocksnap.io/img-thumbs/960w/SNK7GS7JV9.jpg',
  // -- After a loss
  // Physical recovery, in plain terms
  'ttc_read_loss_recovery':
      'https://cdn.stocksnap.io/img-thumbs/960w/M3GQO6FMSG.jpg',
  // What the next few weeks look like
  'ttc_tile_what_the_next_few_weeks_look_like':
      'https://cdn.stocksnap.io/img-thumbs/960w/DKICLDWSO6.jpg',
  // What normal bleeding and spotting looks like
  'ttc_tile_what_normal_bleeding_and_spotting_looks_like':
      'https://cdn.stocksnap.io/img-thumbs/960w/0YT5EYDBHG.jpg',
  // Ectopic signs that need a hospital today
  'ttc_read_ectopic_pregnancy':
      'https://upload.wikimedia.org/wikipedia/commons/b/b7/Littmann_Stethoscope.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled',
  // Rh status and retained tissue
  'ttc_tile_rh_status_and_retained_tissue':
      'https://cdn.stocksnap.io/img-thumbs/960w/DFI72VNWPP.jpg',
  // Can you ovulate before your first period?
  'ttc_tile_can_you_ovulate_before_your_first_period':
      'https://cdn.stocksnap.io/img-thumbs/960w/LS018JTVBT.jpg',
  // It almost certainly couldn't have been prevented
  'ttc_read_trying_again':
      'https://cdn.stocksnap.io/img-thumbs/960w/CD2134E2DD.jpg',
  // What causes a miscarriage, and what doesn't
  'ttc_read_miscarriage_causes':
      'https://cdn.stocksnap.io/img-thumbs/960w/FVIYKRN6CI.jpg',
  // When to ask for tests
  'ttc_tile_when_to_ask_for_tests':
      'https://cdn.stocksnap.io/img-thumbs/960w/42HBC4OR23.jpg',
  // Recurrent miscarriage
  'ttc_read_recurrent_miscarriage':
      'https://cdn.stocksnap.io/img-thumbs/960w/OG5I0BYUD3.jpg',
  // Does one miscarriage mean another?
  'ttc_tile_does_one_miscarriage_mean_another':
      'https://cdn.stocksnap.io/img-thumbs/960w/X5DVA1HQNU.jpg',
  // Chemical pregnancy
  'ttc_read_chemical_pregnancy':
      'https://cdn.stocksnap.io/img-thumbs/960w/B6LL39821V.jpg',
  // Do you have to wait six months?
  'ttc_tile_do_you_have_to_wait_six_months':
      'https://cdn.stocksnap.io/img-thumbs/960w/XJDAD39WSS.jpg',
  // What to do differently next time
  'ttc_tile_what_to_do_differently_next_time':
      'https://cdn.stocksnap.io/img-thumbs/960w/XX0FZY0UPY.jpg',
  // Trying again: the feelings
  'ttc_read_loss_feelings':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2c/Candle_light_projected_through_a_glass_orb.jpg/1280px-Candle_light_projected_through_a_glass_orb.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Your Care Circle
  'ttc_tile_your_care_circle':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7a/Rackets_Court_wooden_bench_in_Copped_Hall_Gardens%2C_Epping%2C_Essex%2C_England.jpg/1280px-Rackets_Court_wooden_bench_in_Copped_Hall_Gardens%2C_Epping%2C_Essex%2C_England.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Someone who knows this kind of loss
  'ttc_tile_someone_who_knows_this_kind_of_loss':
      'https://cdn.stocksnap.io/img-thumbs/960w/YGNEZY5VY9.jpg',
  // After a loss, four sessions
  'ttc_tile_after_a_loss_four_sessions':
      'https://cdn.stocksnap.io/img-thumbs/960w/K5WYLRGPNB.jpg',
  // -- Mind and body
  // Talk it through
  'ttc_tile_talk_it_through':
      'https://cdn.stocksnap.io/img-thumbs/960w/O4V3KXZI1T.jpg',
  // What today means, and what it doesn't
  'ttc_read_period_came':
      'https://cdn.stocksnap.io/img-thumbs/960w/LMUGL3LQ7X.jpg',
  // When other people's pregnancy news is hard
  'ttc_read_others_news':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d7/Yello_tea_in_a_cup.jpg/1280px-Yello_tea_in_a_cup.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Should you tell family you're trying?
  'ttc_read_telling_family':
      'https://cdn.stocksnap.io/img-thumbs/960w/FLK579G86Z.jpg',
  // Three answers for "Koi good news?"
  'ttc_read_good_news_answers':
      'https://cdn.stocksnap.io/img-thumbs/960w/XQ1YOBCHVT.jpg',
  // When family keeps asking
  'ttc_read_family_asking':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/15/Tea_on_hand.JPG/1280px-Tea_on_hand.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // When trying takes over your life
  'ttc_read_trying_takes_over':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c7/Tea_cup_%28Unsplash%29.jpg/1280px-Tea_cup_%28Unsplash%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Coping when month after month doesn't work
  'ttc_read_month_after_month':
      'https://cdn.stocksnap.io/img-thumbs/960w/3K6AA85P52.jpg',
  // Will it happen if you stop thinking about it?
  'ttc_tile_will_it_happen_if_you_stop_thinking_about_it':
      'https://cdn.stocksnap.io/img-thumbs/960w/YBNJZEPAKM.jpg',
  // Where stress does have a real effect
  'ttc_tile_where_stress_does_have_a_real_effect':
      'https://cdn.stocksnap.io/img-thumbs/960w/2XTL98GVVF.jpg',
  // Preconception garbh sanskar, honestly
  'ttc_read_garbh_sanskar':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8b/Diya%2C_an_oil_lamp.jpg/1280px-Diya%2C_an_oil_lamp.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // The eight sessions, taught
  'ttc_tile_the_eight_sessions_taught':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/ca/Diye_ki_thali_01.jpg/1280px-Diye_ki_thali_01.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Does it make a smarter baby?
  'ttc_tile_does_it_make_a_smarter_baby':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f8/Marigold-flowers.jpg/1280px-Marigold-flowers.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // And if you're not religious
  'ttc_tile_and_if_you_re_not_religious':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/ce/Orange_Marigold_Flowers.jpg/1280px-Orange_Marigold_Flowers.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // What a daily practice is for
  'ttc_tile_what_a_daily_practice_is_for':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f5/Lotus_flower_%28978659%29.jpg/1280px-Lotus_flower_%28978659%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Five minutes, and not as a target
  'ttc_tile_five_minutes_and_not_as_a_target':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0d/Nelumbo_nucifera_01.JPG/1280px-Nelumbo_nucifera_01.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Loosen-up: neck, shoulders, side bends
  'ttc_tile_loosen_up_neck_shoulders_side_bends':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZEBBDL3QI3.jpg',
  // Hip openers: butterfly and slow lunge
  'ttc_tile_hip_openers_butterfly_and_slow_lunge':
      'https://cdn.stocksnap.io/img-thumbs/960w/4ZV39Y06ZJ.jpg',
  // A ten-minute walk
  'ttc_tile_a_ten_minute_walk':
      'https://cdn.stocksnap.io/img-thumbs/960w/F8IX8796HF.jpg',
  // Slow sun salutation, three rounds
  'ttc_tile_slow_sun_salutation_three_rounds':
      'https://cdn.stocksnap.io/img-thumbs/960w/XX8XHPLZMU.jpg',
  // Breathe in for 4, out for 6
  'ttc_tile_breathe_in_for_4_out_for_6':
      'https://cdn.stocksnap.io/img-thumbs/960w/XSWSE5GPTK.jpg',
  // Alternate nostril breathing
  'ttc_tile_alternate_nostril_breathing':
      'https://cdn.stocksnap.io/img-thumbs/960w/AYWO7QN7K7.jpg',
  // Box breathing
  'ttc_tile_box_breathing':
      'https://cdn.stocksnap.io/img-thumbs/960w/GJ7GTXIJZ2.jpg',
  // Two-minute body relaxation
  'ttc_tile_two_minute_body_relaxation':
      'https://cdn.stocksnap.io/img-thumbs/960w/06OAHLI7B4.jpg',
  // Two-minute calm listen
  'ttc_tile_two_minute_calm_listen':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ad/All_scales_of_Bansuris_in_a_set.jpg/1280px-All_scales_of_Bansuris_in_a_set.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ten slow breaths together
  'ttc_tile_ten_slow_breaths_together':
      'https://cdn.stocksnap.io/img-thumbs/960w/DSGMWWUKM8.jpg',
  // A longer session this week
  'ttc_tile_a_longer_session_this_week':
      'https://cdn.stocksnap.io/img-thumbs/960w/16FDCF0DFC.jpg',
  // The free garbh sanskar course, eight sessions
  'ttc_tile_the_free_garbh_sanskar_course_eight_sessions':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/10/Diwali_diyas.jpg/1280px-Diwali_diyas.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Why sleep matters when you're trying
  'ttc_read_sleep_trying':
      'https://cdn.stocksnap.io/img-thumbs/960w/CXH58XHXTI.jpg',
  // Setting a bedtime you can keep
  'ttc_read_bedtime':
      'https://cdn.stocksnap.io/img-thumbs/960w/72R81VRMM0.jpg',
  // A calming breath for bedtime
  'ttc_tile_a_calming_breath_for_bedtime':
      'https://cdn.stocksnap.io/img-thumbs/960w/SHPHVPLC7T.jpg',
  // Talk to a psychologist
  'ttc_tile_talk_to_a_psychologist':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/34/Wooden_bench%2C_Osterley_Park_-_geograph.org.uk_-_5763367.jpg/1280px-Wooden_bench%2C_Osterley_Park_-_geograph.org.uk_-_5763367.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // When home doesn't feel safe
  'ttc_read_relationship_safety':
      'https://cdn.stocksnap.io/img-thumbs/960w/36UBBAQB99.jpg',
  // -- Body and cycle
  // Symptoms and mood
  'ttc_tile_symptoms_and_mood':
      'https://cdn.stocksnap.io/img-thumbs/960w/9QEVP5YHO3.jpg',
  // Is there such a thing as a normal cycle?
  'ttc_read_normal_cycle':
      'https://cdn.stocksnap.io/img-thumbs/960w/IKJ76EHR6K.jpg',
  // What counts as a late period
  'ttc_read_late_period':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bb/WallCalendar.jpg/1280px-WallCalendar.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Irregular cycles when it isn't PCOS
  'ttc_read_irregular_not_pcos':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MOCM0IQIE.jpg',
  // Five kinds of bleeding
  'ttc_read_bleeding_kinds':
      'https://cdn.stocksnap.io/img-thumbs/960w/KWH9O122NJ.jpg',
  // Spotting between periods
  'ttc_read_spotting':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e1/A_Sanitary_Towel_on_White_Background.jpg/1280px-A_Sanitary_Towel_on_White_Background.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Heavy, light or long periods
  'ttc_read_heavy_flow':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/ad/Menstrual_cup_in_hand.jpg/1280px-Menstrual_cup_in_hand.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ovulation pain
  'ttc_read_ovulation_pain':
      'https://cdn.stocksnap.io/img-thumbs/960w/UWZZS1U30C.jpg',
  // Period pain
  'ttc_read_period_pain':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/Knitted_hot_water_bottle_cover.jpg/1280px-Knitted_hot_water_bottle_cover.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Is my discharge normal?
  'ttc_read_discharge_guide':
      'https://cdn.stocksnap.io/img-thumbs/960w/C237EE7B1D.jpg',
  // How to clean down there
  'ttc_read_intimate_washing':
      'https://cdn.stocksnap.io/img-thumbs/960w/RZGTIF02NB.jpg',
  // Itching, smells and bumps
  'ttc_read_intimate_worries':
      'https://cdn.stocksnap.io/img-thumbs/960w/KEXB4QOSTK.jpg',
  // Yeast infections and BV
  'ttc_read_yeast_bv':
      'https://cdn.stocksnap.io/img-thumbs/960w/T3HQNAXDJO.jpg',
  // Urine infections while trying
  'ttc_read_uti_trying':
      'https://cdn.stocksnap.io/img-thumbs/960w/AXKFEL7HBL.jpg',
  // A quick infection test before trying
  'ttc_read_sti_testing':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0a/Pipette_de_laboratoire_sur_fond_blanc_au_B%C3%A9nin_02.jpg/1280px-Pipette_de_laboratoire_sur_fond_blanc_au_B%C3%A9nin_02.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Seven things that can slow conception
  'ttc_read_slow_conception':
      'https://cdn.stocksnap.io/img-thumbs/960w/AVMRON1NHS.jpg',
  // Your thyroid and the TSH test
  'ttc_read_thyroid_tsh':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/16/Laboratory_Test_Tubes%3B_from_a_medical_laboratory_in_Abuja%2C_Nigeria.jpg/1280px-Laboratory_Test_Tubes%3B_from_a_medical_laboratory_in_Abuja%2C_Nigeria.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // High prolactin
  'ttc_read_high_prolactin':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/55/Plastic_Test_Tube_Rack.JPG/1280px-Plastic_Test_Tube_Rack.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Endometriosis and trying
  'ttc_read_endometriosis':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/74/Hot_Water_Bag.jpg/1280px-Hot_Water_Bag.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Fibroids and polyps
  'ttc_read_fibroids_polyps':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a5/Ultrasound_Machine_Cameroon.jpg/1280px-Ultrasound_Machine_Cameroon.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Ovarian cysts
  'ttc_read_ovarian_cysts':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/Color_Doppler_ultrasound_noise_artifact_abdomen.jpg/1280px-Color_Doppler_ultrasound_noise_artifact_abdomen.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Blocked tubes and the HSG test
  'ttc_read_blocked_tubes_hsg':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/63/Patient_room_with_hospital_bed.jpg/1280px-Patient_room_with_hospital_bed.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Pelvic infections (PID)
  'ttc_read_pelvic_infection':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/33/Pill_1.jpg/1280px-Pill_1.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Genital TB
  'ttc_read_genital_tb':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/19/A_collection_of_generic_medicine_pills_on_a_white_background.jpg/1280px-A_collection_of_generic_medicine_pills_on_a_white_background.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail',
  // Trying for many months?
  'ttc_tile_trying_for_many_months':
      'https://cdn.stocksnap.io/img-thumbs/960w/PA1WLIK8LY.jpg',
  // -- Trying but not pregnant yet
  // Is it time to see someone?
  'ttc_tile_is_it_time_to_see_someone':
      'https://cdn.stocksnap.io/img-thumbs/960w/C2799653AA.jpg',
  // Talk to a fertility doctor
  'ttc_tile_talk_to_a_fertility_doctor':
      'https://upload.wikimedia.org/wikipedia/commons/7/75/Stethoscope_1.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled',
};

/// Read id → licence · source · creator, for the credit line.
const Map<String, String> kReadImageCredits = {
  'garbh_pillar_shravan': 'Unsplash License · Unsplash',
  'garbh_pillar_samvad': 'Unsplash License · Unsplash',
  'garbh_pillar_buddhi': 'CC0 · Wikimedia Commons · Profpcde',
  'garbh_pillar_kriya': 'CC BY-SA 4.0 · Wikimedia Commons · BRPever',
  // Symptoms (2026-09-23)
  'symptom_nausea': 'CC BY-SA 4.0 · Wikimedia Commons · Erasmus Kamugisha',
  'symptom_heartburn': 'CC BY 2.0 · Wikimedia Commons · NIAID',
  'symptom_constipation': 'CC BY 3.0 us · Wikimedia Commons · Forest and Kim Starr',
  'symptom_fatigue': 'CC BY-SA 4.0 · Wikimedia Commons · Amin',
  'symptom_backPain': 'CC BY 2.0 · Wikimedia Commons · Kara Babcock',
  'symptom_headache': 'CC BY 2.0 · Wikimedia Commons · Greg Riegler from Pensacola, FL, USA',
  'symptom_troubleSleeping': 'CC0 · Wikimedia Commons · J.Doniyorovich',
  'symptom_moodSwings': 'CC BY 2.0 · Wikimedia Commons · Sharada Prasad CS from Bangalore, India',
  'symptom_swelling': 'CC BY 3.0 · Wikimedia Commons · Rodrigomariadafe',
  'symptom_legCramps': 'CC BY-SA 3.0 · Wikimedia Commons · abhiriksh',
  'symptom_babyHiccups': 'CC BY 2.0 · Wikimedia Commons · marie smith',
  'symptom_braxtonHicks': 'CC BY-SA 4.0 · Wikimedia Commons · Ikonicstopwatch',
  'symptom_bloating': 'CC BY-SA 4.0 · Wikimedia Commons · Sarkar Sayantan',
  'symptom_metallicTaste': 'CC BY-SA 4.0 · Wikimedia Commons · Dietmar Rabich',
  'symptom_foodAversions': 'CC BY-SA 4.0 · Wikimedia Commons · 5boi38',
  'symptom_dizziness': 'CC BY-SA 4.0 · Wikimedia Commons · HaJunkiyada',
  'symptom_breathlessness': 'CC BY-SA 2.0 · Wikimedia Commons · Joseph Mischyshyn',
  'symptom_blockedNose': 'Public domain · Wikimedia Commons · MaxSem',
  'symptom_pelvicGirdle': 'CC BY-SA 4.0 · Wikimedia Commons · Panek',
  'symptom_carpalTunnel': 'CC BY 3.0 · Wikimedia Commons · zyang',
  'symptom_varicoseVeins': 'CC BY-SA 3.0 · Wikimedia Commons · DrKssn',
  'symptom_ribPain': 'CC BY 2.0 · Wikimedia Commons · Feliciano Guimarães from Guimarães,',
  'symptom_restlessLegs': 'CC BY 2.0 · Wikimedia Commons · Personal Creations',
  'symptom_vividDreams': 'CC BY-SA 2.0 · Wikimedia Commons · Guy Sie from Utrecht, Netherlands',
  'symptom_itching': 'CC BY-SA 4.0 · Wikimedia Commons · deadrat',
  'symptom_bleedingGums': 'Public domain · Wikimedia Commons · Jonas Bergsten',
  'symptom_hairSkin': 'CC BY 2.0 · Wikimedia Commons · Rae Allen',
  'symptom_hotFlushes': 'CC BY-SA 4.0 · Wikimedia Commons · Bashir Shatima Mustapha',
  'symptom_smellSensitivity': 'CC0 · Wikimedia Commons · Aviavlad',
  'symptom_frequentUrination': 'CC0 · Wikimedia Commons · Amraepowell',
  'symptom_pelvicPressure': 'CC BY 2.0 · Wikimedia Commons · Spiralz from England',
  'nut_ragi_dosa': 'CC BY-SA 4.0 · Wikimedia Commons · Pradeep717',
  'nut_curd_rice': 'CC BY-SA 4.0 · Wikimedia Commons · Sudharshan Shanmugasundaram',
  'nut_palak_paneer': 'CC BY-SA 4.0 · Wikimedia Commons · DreamyFlutura11',
  'nut_fish_curry': 'CC BY-SA 4.0 · Wikimedia Commons · Billjones94',
  'nut_shukto': 'CC BY-SA 4.0 · Wikimedia Commons · Billjones94',
  'nut_ragi_porridge': 'CC BY-SA 4.0 · Wikimedia Commons · Narmadhaa',
  'nut_sambar': 'CC BY-SA 4.0 · Wikimedia Commons · Sutapa Pal',
  'nut_rajma': 'CC BY-SA 4.0 · Wikimedia Commons · Shreya151994',
  'nut_dhokla': 'CC BY-SA 4.0 · Wikimedia Commons · Mrudit161187',
  'nut_khichdi': 'CC BY-SA 4.0 · Wikimedia Commons · Mrudit161187',
  'nut_dal_rice': 'CC BY-SA 4.0 · Wikimedia Commons · Kashmira3091',
  'nut_thalipeeth': 'CC BY-SA 4.0 · Wikimedia Commons · Avinashvh1n1',
  'nut_kadhi': 'Public domain · Wikimedia Commons · Mowglee',
  'nut_chilla': 'CC BY-SA 4.0 · Wikimedia Commons · Kamalsahansi',
  'nut_daliya': 'CC0 · Wikimedia Commons · QueerEcofeminist',
  'nut_poha': 'CC BY-SA 4.0 · Wikimedia Commons · Mahi Gajwani',
  'nut_upma': 'CC BY-SA 4.0 · Wikimedia Commons · Intodustin',
  'nut_idli': 'CC BY-SA 4.0 · Wikimedia Commons · Sutapa Pal',
  'nut_dosa': 'CC BY-SA 4.0 · Wikimedia Commons · Marajozkee',
  'nut_paratha': 'CC BY-SA 4.0 · Wikimedia Commons · Shahzaib Damn Cruze',
  'nut_roti_sabzi': 'CC BY-SA 2.0 · Wikimedia Commons · Devika',
  'nut_oats': 'CC BY-SA 4.0 · Wikimedia Commons · UserTwoSix',
  'nut_boiled_eggs': 'CC0 · StockSnap · Foodie Girl',
  'nut_omelette': 'Public domain · Wikimedia Commons · Renee Comet (photographer)',
  'nut_paneer': 'CC BY-SA 4.0 · Wikimedia Commons · Status 401',
  'nut_dal': 'CC0 · StockSnap · Foodie Girl',
  'nut_sprouts': 'CC BY-SA 4.0 · Wikimedia Commons · Abhijit Patil',
  'nut_chana': 'CC BY-SA 4.0 · Wikimedia Commons · Parzeus',
  'nut_curd': 'CC0 · StockSnap · Jamie Hamel-Smith',
  'nut_lassi': 'CC0 · StockSnap · Burst',
  'nut_fruit_bowl': 'CC0 · StockSnap · Suzy Hazelwood',
  'nut_banana': 'CC0 · StockSnap · Piotr Lohunko',
  'nut_apple': 'CC0 · StockSnap · Mali Maeder',
  'nut_nuts': 'CC0 · StockSnap · Jonas Svidras',
  'nut_dates': 'CC BY-SA 4.0 · Wikimedia Commons · Lebron jay',
  'nut_soup': 'CC0 · StockSnap · Foodie Girl',
  'nut_salad': 'CC0 · StockSnap · FOCA Stock',
  'nut_coconut_water': 'CC BY-SA 2.0 · Wikimedia Commons · mararie',
  'nut_chicken_curry': 'CC BY-SA 4.0 · Wikimedia Commons · Asinha631',
  'nut_makhana': 'CC0 · StockSnap · Alex Munsell',
  'nut_khakhra': 'CC0 · StockSnap · Anita Peeples',
  'nut_sandwich': 'CC0 · StockSnap · Jay Mantri',
  'nut_smoothie': 'CC0 · StockSnap · Tohm Brigitte',
  'nut_juice': 'CC0 · StockSnap · JESHOOTS.com',
  'nut_chai': 'CC0 · StockSnap · Andrew E Weber',
  'nut_r_pcos_moong_chilla': 'CC BY-SA 4.0 · Wikimedia Commons · Kamalsahansi',
  'nut_r_bengali_macher_jhol': 'CC BY-SA 4.0 · Wikimedia Commons · Rajeeb Dutta',
  'nut_r_bengali_shukto': 'CC BY-SA 4.0 · Wikimedia Commons · Billjones94',
  'nut_r_punjabi_palak_paneer': 'CC BY-SA 4.0 · Wikimedia Commons · Lopanayak',
  'nut_r_gujarati_dhokla': 'CC BY-SA 4.0 · Wikimedia Commons · Yakshitha',
  'nut_r_gujarati_khichdi': 'CC BY-SA 4.0 · Wikimedia Commons · Dkgohil',
  'nut_r_south_indian_ragi_dosa': 'CC BY-SA 4.0 · Wikimedia Commons · Pradeep717',
  'nut_r_south_indian_curd_rice': 'CC BY-SA 4.0 · Wikimedia Commons · Sudharshan Shanmugasundaram',
  'nut_r_maharashtrian_varan_bhaat': 'CC BY-SA 4.0 · Wikimedia Commons · Kashmira3091',
  'nut_r_maharashtrian_thalipeeth': 'CC BY-SA 4.0 · Wikimedia Commons · Avinashvh1n1',
  'nut_r_jain_kadhi_khichdi': 'CC BY-SA 4.0 · Wikimedia Commons · Mrudit161187',
  'nut_r_besan_chilla': 'CC BY-SA 4.0 · Wikimedia Commons · Kamalsahansi',
  'nut_r_vegetable_daliya': 'CC0 · Wikimedia Commons · QueerEcofeminist',
  'nut_r_tamil_sambar': 'CC BY-SA 4.0 · Wikimedia Commons · Sutapa Pal',
  'nut_r_punjabi_rajma': 'CC BY-SA 4.0 · Wikimedia Commons · Shreya151994',
  'nut_r_tamil_ragi_kanji': 'CC BY-SA 4.0 · Wikimedia Commons · Narmadhaa',
  'nut_ragi_kanji': 'CC BY-SA 4.0 · Wikimedia Commons · Narmadhaa',
  'nut_buttermilk': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_papaya': 'CC BY 3.0 · Wikimedia Commons · Marek Ślusarczyk (Tupungato) Photo portf',
  'cani_pineapple': 'CC BY-SA 3.0 · Wikimedia Commons · MANOJTV at English Wikipedia',
  'cani_mango': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_banana': 'CC0 · Wikimedia Commons · Wilfredor',
  'cani_curd': 'CC BY-SA 4.0 · Wikimedia Commons · Shruthi Gaurav Alva',
  'cani_chocolate': 'CC0 · Wikimedia Commons · Mx. Granger',
  'cani_street_food': 'CC BY 2.0 · Wikimedia Commons · Yusuke Kawasaki',
  'cani_honey': 'CC0 · StockSnap · Roberta Sorge',
  'cani_ginger': 'CC BY-SA 3.0 · Wikimedia Commons · Venkatx5',
  'cani_coffee': 'CC BY-SA 2.0 · Wikimedia Commons · Julius Schorzman',
  'cani_tea': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_green_tea': 'CC0 · StockSnap · Jorge Garcia',
  'cani_coconut_water': 'CC BY-SA 4.0 · Wikimedia Commons · Vis M',
  'cani_buttermilk': 'CC BY-SA 4.0 · Wikimedia Commons · Kyu3a',
  'cani_alcohol': 'CC BY 3.0 de · Wikimedia Commons · Stefan Krause, Germany',
  'cani_soft_drinks': 'CC0 · StockSnap · Agnieszka Bladzik',
  'cani_water': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_paracetamol': 'CC BY-SA 4.0 · Wikimedia Commons · N509FZ',
  'cani_ibuprofen': 'CC BY-SA 3.0 · Wikimedia Commons · Ragesoss',
  'cani_combiflam': 'CC0 · StockSnap · Martin Vorel',
  'cani_antibiotics': 'CC BY-SA 4.0 · Wikimedia Commons · Whispyhistory',
  'cani_folic_acid': 'CC BY-SA 3.0 · Wikimedia Commons · Ragesoss',
  'cani_calcium': 'CC BY 3.0 · Wikimedia Commons · Kham Tran - www.khamtran.com',
  'cani_vitamin_d': 'CC BY-SA 4.0 · Wikimedia Commons · Schekinov Alexey Victorovich',
  'cani_flight_travel': 'CC0 · StockSnap · The Pic Pac',
  'cani_long_travel': 'CC0 · StockSnap · Mike Wilson',
  'cani_yoga': 'CC0 · StockSnap · Burst',
  'cani_swimming': 'CC0 · StockSnap · Ian Prince',
  'cani_walking': 'CC0 · StockSnap · Matt Moloney',
  'cani_hair_color': 'CC BY-SA 4.0 · Wikimedia Commons · WhatamIdoing',
  'cani_waxing': 'CC0 · StockSnap · Authentic Stock',
  'cani_nail_polish': 'CC0 · StockSnap · Sarah Pflug',
  'cani_sex': 'CC0 · StockSnap · William Stitt',
  'cani_sleeping_back': 'CC0 · StockSnap · Alexandre Vanier',
  'cani_mosquito_repellent': 'CC BY-SA 4.0 · Wikimedia Commons · Quercus acuta',
  'cani_dental': 'CC0 · Wikimedia Commons · Michal Jarmoluk',
  'cani_xray': 'CC BY-SA 4.0 · Wikimedia Commons · Adoscam',
  'cani_sauna': 'CC BY-SA 4.0 · Wikimedia Commons · Basile Morin',
  'cani_fasting': 'CC0 · StockSnap · The World is a Stage',
  'cani_apple': 'CC BY 2.0 · Wikimedia Commons · Abhijit Tembhekar from Mumbai, India',
  'cani_orange': 'CC BY-SA 4.0 · Wikimedia Commons · Rhododendrites',
  'cani_grapes': 'CC0 · StockSnap · Skitter Photo',
  'cani_watermelon': 'CC BY-SA 4.0 · Wikimedia Commons · Ralff Nestor Nacor',
  'cani_muskmelon': 'CC BY-SA 4.0 · Wikimedia Commons · Peachyeung316',
  'cani_guava': 'CC BY-SA 4.0 · Wikimedia Commons · Rodrigo.Argenton',
  'cani_pomegranate': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_chikoo': 'CC BY-SA 4.0 · Wikimedia Commons · பிருந்தா சுப்ரமணி',
  'cani_litchi': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_jackfruit': 'CC BY-SA 3.0 · Wikimedia Commons · Mullookkaaran',
  'cani_dates': 'Public domain · Wikimedia Commons · Loorie Cooper',
  'cani_figs': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_berries': 'CC0 · StockSnap · Lukas',
  'cani_kiwi': 'CC0 · StockSnap · Piotr Lohunko',
  'cani_pear': 'CC0 · StockSnap · Foodie Girl',
  'cani_dry_fruits': 'CC0 · StockSnap · Jonas Svidras',
  'cani_almonds': 'CC BY-SA 4.0 · Wikimedia Commons · HaJunkiyada',
  'cani_walnuts': 'CC0 · StockSnap · Nordwood Themes',
  'cani_cashews': 'CC0 · StockSnap · Jakub Kapusnak',
  'cani_peanuts': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_sabudana': 'CC BY-SA 4.0 · Wikimedia Commons · Dheerajk88',
  'cani_spinach': 'CC BY-SA 4.0 · Wikimedia Commons · Olgatladi2020',
  'cani_drumstick': 'CC0 · StockSnap · fireskystudios.com',
  'cani_brinjal': 'CC0 · StockSnap · Peter Hershey',
  'cani_potato': 'CC0 · StockSnap · Maciej Szlachta',
  'cani_tomato': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_carrot': 'CC0 · StockSnap · Suzy Hazelwood',
  'cani_beetroot': 'CC BY-SA 4.0 · Wikimedia Commons · W.carter',
  'cani_sprouts': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_raw_salad': 'CC0 · StockSnap · FOCA Stock',
  'cani_mushroom': 'CC0 · StockSnap · Marcin Czaja',
  'cani_egg': 'CC0 · StockSnap · Peter Belch',
  'cani_chicken': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_mutton': 'CC BY-SA 4.0 · Wikimedia Commons · Satwik Cuttack',
  'cani_fish': 'CC0 · StockSnap · Malidate Van',
  'cani_prawns': 'CC0 · StockSnap · Tim Sullivan',
  'cani_high_mercury_fish': 'CC BY-SA 3.0 · Wikimedia Commons · Citron',
  'cani_dal': 'CC0 · StockSnap · Foodie Girl',
  'cani_soya': 'CC0 · Wikimedia Commons · Daderot',
  'cani_rajma_chana': 'CC BY-SA 4.0 · Wikimedia Commons · Shreya151994',
  'cani_cheese': 'CC0 · StockSnap · Foodie Girl',
  'cani_ghee': 'CC0 · StockSnap · Brooke Cagle',
  'cani_mawa_sweets': 'CC BY-SA 3.0 · Wikimedia Commons · Unknomics',
  'cani_oats': 'CC0 · StockSnap · Andrew Pons',
  'cani_poha': 'CC BY-SA 4.0 · Wikimedia Commons · Medhi jyoti',
  'cani_instant_noodles': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_fried_snacks': 'CC0 · StockSnap · Mike Moloney',
  'cani_pickle': 'CC0 · StockSnap · JESHOOTS.com',
  'cani_turmeric_milk': 'CC BY-SA 4.0 · Wikimedia Commons · మురళీకృష్ణ ముసునూరి',
  'cani_jaggery': 'CC BY-SA 4.0 · Wikimedia Commons · Mangosapiens',
  'cani_spices': 'CC0 · StockSnap · Patrycja Tomaszczyk',
  'cani_sugar': 'CC BY-SA 4.0 · Wikimedia Commons · Dietmar Rabich',
  'cani_sushi': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_raw_meat': 'CC BY-SA 4.0 · Wikimedia Commons · Dr. Bernd Gross',
  'cani_deli_meat': 'CC0 · StockSnap · Jessica Ruscello',
  'cani_leftovers': 'CC0 · StockSnap · Jeffrey Betts',
  'cani_spicy_food': 'CC0 · StockSnap · ela haney',
  'cani_milkshake': 'CC0 · StockSnap · Burst',
  'cani_fresh_juice': 'CC0 · StockSnap · JESHOOTS.com',
  'cani_lemon_water': 'CC0 · StockSnap · Healthy Living',
  'cani_sugarcane_juice': 'CC0 · StockSnap · JESHOOTS.com',
  'cani_lassi': 'CC0 · StockSnap · Burst',
  'cani_energy_drinks': 'CC BY-SA 3.0 · Wikimedia Commons · Klooni',
  'cani_herbal_tea': 'CC0 · StockSnap · Marina Pershina',
  'cani_smoothie': 'CC0 · StockSnap · WDnet Studio',
  'cani_kombucha': 'CC BY-SA 4.0 · Wikimedia Commons · Jmb195',
  'cani_diet_soda': 'CC0 · StockSnap · Skitter Photo',
  'cani_aam_panna': 'CC BY-SA 4.0 · Wikimedia Commons · Contrapunctus-1',
  'cani_badam_milk': 'CC BY-SA 4.0 · Wikimedia Commons · Saiphani02',
  'cani_decaf_coffee': 'CC0 · StockSnap · Negative Space',
  'cani_jaljeera': 'CC0 · StockSnap · Toa Heftiba',
  'cani_ors': 'CC0 · StockSnap · Steve Johnson',
  'cani_aspirin': 'CC BY-SA 4.0 · Wikimedia Commons · Ragesoss',
  'cani_cetirizine': 'CC0 · Wikimedia Commons · Issuial',
  'cani_antacids': 'CC BY 2.5 · Wikimedia Commons · Midnightcomm',
  'cani_pantoprazole': 'Public domain · Wikimedia Commons · NLM',
  'cani_multivitamin': 'Public domain · Wikimedia Commons · National Institute of Standards and Tech',
  'cani_omega3': 'CC BY-SA 3.0 · Wikimedia Commons · Orange-kun',
  'cani_b12': 'CC0 · Wikimedia Commons · Vack Xu',
  'cani_ondansetron': 'Public domain · Wikimedia Commons · NLM',
  'cani_doxylamine': 'CC BY-SA 3.0 · Wikimedia Commons · Ragesoss',
  'cani_cough_syrup': 'CC0 · Wikimedia Commons · Necatorina',
  'cani_lozenges': 'CC BY-SA 4.0 · Wikimedia Commons · Kritzolina',
  'cani_vicks_balm': 'CC BY 2.0 · Wikimedia Commons · ajay_suresh',
  'cani_isabgol': 'CC0 · Wikimedia Commons · Retired electrician',
  'cani_probiotics': 'CC BY-SA 3.0 · Wikimedia Commons · Unknown authorUnknown author',
  'cani_ashwagandha': 'CC BY 2.0 · Wikimedia Commons · formulatehealth',
  'cani_homeopathy': 'CC BY-SA 4.0 · Wikimedia Commons · Dr. Moumita Sahana',
  'cani_diclofenac': 'CC BY 4.0 · Wikimedia Commons · Bluberryman',
  'cani_antifungal_cream': 'Public domain · Wikimedia Commons · Editor182',
  'cani_deworming': 'CC BY-SA 4.0 · Wikimedia Commons · BlankEclair',
  'cani_thyroid_medicine': 'Public domain · Wikimedia Commons · User:Ash',
  'cani_bp_medicine': 'CC BY-SA 4.0 · Wikimedia Commons · Jacek Halicki',
  'cani_insulin': 'CC BY 4.0 · Wikimedia Commons · User:Wesalius, labeled by User:Berchanhi',
  'cani_vaccines': 'CC BY-SA 4.0 · Wikimedia Commons · Whispyhistory',
  'cani_driving': 'CC0 · StockSnap · Burst',
  'cani_cycling': 'CC BY-SA 4.0 · Wikimedia Commons · Alfredo Borba',
  'cani_running': 'CC BY 2.0 · Wikimedia Commons · Mike Baird from Morro Bay, USAMike Baird',
  'cani_dancing': 'CC0 · StockSnap · Hudson Hintze',
  'cani_household_chores': 'Public domain · Wikimedia Commons · NancyHeise  talk',
  'cani_climbing_stairs': 'CC0 · StockSnap · Huney Co',
  'cani_standing_long': 'CC BY-SA 4.0 · Wikimedia Commons · Yash26M12',
  'cani_amusement_rides': 'CC0 · StockSnap · Sergei Gussev',
  'cani_trekking': 'CC0 · StockSnap · Joshua Earle',
  'cani_gym': 'CC0 · StockSnap · Khusen Rustamov',
  'cani_keratin': 'CC BY-SA 2.0 · Wikimedia Commons · jason gessner',
  'cani_facial': 'CC BY 2.0 · Wikimedia Commons · Sérgio (Savaman) Savarese',
  'cani_chemical_peel': 'CC0 · StockSnap · Authentic Stock',
  'cani_botox_fillers': 'CC BY-SA 2.0 · Wikimedia Commons · Dr. Braun from Vancouver, Canada',
  'cani_laser_hair': 'CC BY-SA 4.0 · Wikimedia Commons · Amaregenmed (Alice Pien, MD)',
  'cani_pedicure': 'CC0 · StockSnap · Freestocks.org',
  'cani_makeup': 'CC BY-SA 4.0 · Wikimedia Commons · Makeupweapons',
  'cani_sunscreen': 'CC0 · StockSnap · Kristin Hardwick',
  'cani_retinol': 'CC BY 2.0 · Wikimedia Commons · Shixart1985',
  'cani_perfume': 'CC0 · StockSnap · Jess Watters',
  'cani_hair_oil': 'CC BY-SA 4.0 · Wikimedia Commons',
  'cani_tattoo': 'CC0 · StockSnap · Tim Gouw',
  'cani_gel_nails': 'CC0 · StockSnap · Freestocks.org',
  'cani_smoking': 'CC0 · StockSnap · Emma Leigh Parker',
  'cani_secondhand_smoke': 'CC0 · StockSnap · Carli Jean',
  'cani_vaping': 'CC0 · StockSnap · Isabella Mendes',
  'cani_hot_water_bath': 'CC0 · StockSnap · Authentic Stock',
  'cani_ac_use': 'CC BY-SA 4.0 · Wikimedia Commons · Solijon Solayev',
  'cani_incense': 'CC BY-SA 4.0 · Wikimedia Commons · AntanO',
  'cani_cleaning_chemicals': 'CC BY-SA 4.0 · Wikimedia Commons · Realeklas',
  'cani_paint_fumes': 'CC BY 2.0 · Wikimedia Commons · Michael Cory',
  'cani_pesticides': 'CC BY-SA 4.0 · Wikimedia Commons · Azorbli',
  'cani_pet_cats': 'CC0 · StockSnap · Snapwire',
  'cani_pet_dogs': 'CC0 · StockSnap · Alex Blăjan',
  'cani_gardening': 'CC0 · StockSnap · Neslihan Gunaydin',
  'cani_public_transport': 'CC BY-SA 4.0 · Wikimedia Commons · Ravi Dwivedi',
  'cani_crowded_places': 'CC BY 2.0 · Wikimedia Commons · shankar s. from Poona (pune), India, Ind',
  'cani_high_heels': 'CC BY-SA 4.0 · Wikimedia Commons · N509FZ',
  'cani_tight_clothes': 'CC BY 3.0 · Wikimedia Commons · Dcrjsr',
  'cani_massage': 'CC0 · StockSnap · Authentic Stock',
  'cani_spa': 'CC BY-SA 4.0 · Wikimedia Commons · Паша Бунин',
  'cani_meditation': 'CC BY-SA 3.0 · Wikimedia Commons · Pudelek (Marcin Szala)',
  'cani_mobile_phone': 'CC0 · StockSnap · JESHOOTS.com',
  'cani_stress': 'CC BY 2.0 · Wikimedia Commons · Shixart1985',
  'cani_paneer': 'CC BY-SA 4.0 · Wikimedia Commons · PallaviKhale',
  'cani_milk': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_saffron': 'CC0 · Wikimedia Commons · ulleo',
  'cani_makhana': 'CC BY-SA 4.0 · Wikimedia Commons · FacetsOfNonStickPans',
  'cani_salt': 'CC0 · StockSnap · Birch Landing Home',
  'cani_maida': 'CC BY-SA 2.0 · Wikimedia Commons · Veganbaking.net from USA',
  'cani_custard_apple': 'CC BY-SA 3.0 · Wikimedia Commons',
  'cani_sleeping_pills': 'CC0 · StockSnap · Martin Vorel',
  'cani_ayurvedic_medicine': 'CC BY-SA 4.0 · Wikimedia Commons · Vis M',
  'cani_packaged_juice': 'CC BY-SA 4.0 · Wikimedia Commons · Kolbkorr',
  'cani_vitamin_c': 'CC0 · StockSnap · Daria Nepriakhina',
  'cani_shelf_eat': 'CC BY 2.0 · Wikimedia Commons · Yusuke Kawasaki',
  'cani_shelf_drink': 'CC0 · StockSnap · Andrew E Weber',
  'cani_shelf_take': 'Public domain · Wikimedia Commons · National Institute of Standards and Tech',
  'cani_shelf_doActivity': 'CC0 · StockSnap · Matt Moloney',
  'condition_icp_cholestasis': 'CC0 · stocksnap · Freestocks.org',
  'condition_hellp': 'CC0 · stocksnap · Direct Media',
  'condition_vasa_previa': 'CC0 · stocksnap · Candace McDaniel',
  'condition_rh_negative': 'CC0 · stocksnap · Negative Space',
  'condition_pre_existing': 'CC0 · stocksnap · Direct Media',
  'condition_covid_pregnancy': 'CC0 · stocksnap · Brodie Vissers',
  'condition_dengue_pregnancy': 'CC0 · wordpress · sreejagroups',
  'finding_low_lying_placenta': 'CC0 · stocksnap · Skitter Photo',
  'finding_breech': 'CC0 · stocksnap · Candace McDaniel',
  'finding_nuchal_cord': 'CC0 · stocksnap · Matt Bango',
  'finding_gestational_diabetes': 'CC0 · stocksnap · Matt Bango',
  'finding_low_fluid': 'CC0 · stocksnap · Candace McDaniel',
  'finding_preeclampsia': 'CC0 · stocksnap · Candace McDaniel',
  'finding_high_fluid': 'CC0 · stocksnap · Candace McDaniel',
  'finding_short_cervix': 'CC0 · stocksnap · Candace McDaniel',
  'finding_placental_calcification': 'CC0 · stocksnap · Freestocks.org',
  'finding_twin_pregnancy': 'CC0 · stocksnap · Freestocks.org',
  'finding_anemia': 'CC0 · stocksnap · Suhyeon Choi',
  'finding_reduced_movements': 'CC0 · stocksnap · William Stitt',
  'finding_braxton_hicks': 'CC0 · stocksnap · Brodie Vissers',
  'finding_high_bp': 'CC0 · stocksnap · Josh Willink',
  'finding_placenta_resolved': 'CC0 · stocksnap · Freestocks.org',
  'finding_small_baby': 'CC0 · stocksnap · Mel Elías',
  'finding_large_baby': 'CC0 · stocksnap · Marcos Moraes',
  'finding_subchorionic_hematoma': 'CC0 · stocksnap · Freestocks.org',
  'finding_vanishing_twin': 'CC0 · stocksnap · Arteida MjESHTRI',
  'finding_marginal_cord': 'CC0 · stocksnap · Direct Media',
  'finding_single_umbilical_artery': 'CC0 · stocksnap · Oles kanebckuu',
  'finding_ventriculomegaly': 'CC0 · stocksnap · Direct Media',
  'finding_eif': 'CC0 · stocksnap · Direct Media',
  'finding_soft_markers': 'CC0 · stocksnap · Direct Media',
  'finding_fibroids': 'CC0 · stocksnap · Mali Maeder',
  'finding_group_b_strep': 'CC0 · stocksnap · Direct Media',
  'finding_rh_negative': 'CC0 · stocksnap · Negative Space',
  'condition_gdm': 'CC0 · stocksnap · Candace McDaniel',
  'condition_thyroid': 'CC0 · stocksnap · Freestocks.org',
  'condition_anemia': 'CC0 · stocksnap · Suhyeon Choi',
  'condition_pcos': 'CC0 · stocksnap · Brodie Vissers',
  'condition_hyperemesis': 'CC0 · stocksnap · Freestocks.org',
  'condition_placenta_previa': 'CC0 · stocksnap · Marcos Moraes',
  'condition_high_bp': 'CC0 · stocksnap · Arteida MjESHTRI',
  'condition_ectopic': 'CC0 · stocksnap · Oles kanebckuu',
  'condition_miscarriage': 'CC0 · stocksnap · Direct Media',
  'condition_preeclampsia': 'CC0 · stocksnap · Mali Maeder',
  'condition_placental_abruption': 'CC0 · stocksnap · Negative Space',
  'condition_iugr': 'CC0 · stocksnap · Direct Media',
  'condition_low_amniotic_fluid': 'CC0 · stocksnap · Direct Media',
  'condition_polyhydramnios': 'CC0 · wordpress · sreejagroups',
  'condition_breech': 'CC0 · stocksnap · Freestocks.org',
  'condition_cervical_incompetence': 'CC0 · stocksnap · Mel Elías',
  'condition_uti': 'CC0 · stocksnap · Josh Willink',
  'condition_piles': 'CC0 · stocksnap · William Stitt',
  'condition_varicose_veins': 'CC0 · stocksnap · Freestocks.org',
  'condition_fibroids': 'CC0 · stocksnap · Candace McDaniel',
  'scan_blood_tests': 'CC0 · stocksnap · Negative Space',
  'scan_dating_scan': 'CC0 · stocksnap · Candace McDaniel',
  'scan_nt_scan': 'CC0 · stocksnap · Candace McDaniel',
  'scan_nipt': 'CC0 · stocksnap · Negative Space',
  'scan_anomaly_scan': 'CC0 · stocksnap · Skitter Photo',
  'scan_ogtt': 'CC0 · stocksnap · Djordje Popovic',
  'scan_growth_scan': 'CC0 · stocksnap · Freestocks.org',
  'scan_doppler': 'CC0 · stocksnap · Freestocks.org',
  'scan_gbs': 'CC0 · wordpress · sreejagroups',
  'preg_scan_read_calm': 'CC0 · stocksnap · Marcos Moraes',
  'preg_week_read_managing_nausea': 'CC0 · stocksnap · Josh Willink',
  'preg_week_read_first_scan': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_first_trimester': 'CC0 · stocksnap · Djordje Popovic',
  'preg_week_read_nutrition_t2': 'CC0 · stocksnap · Dana Tentis',
  'preg_week_read_partner_support': 'CC0 · stocksnap · William Stitt',
  'preg_week_read_halfway': 'CC0 · stocksnap · Freestocks.org',
  'preg_week_read_anomaly_scan': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_baby_sound': 'CC0 · stocksnap · Freestocks.org',
  'preg_week_read_talking_baby': 'CC0 · stocksnap · Suhyeon Choi',
  'preg_week_read_back_pain': 'CC0 · stocksnap · Mel Elías',
  'preg_week_read_third_tri_prep': 'CC0 · stocksnap · Matt Bango',
  'preg_week_read_movement_awareness': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_hospital_bag': 'CC0 · stocksnap · Matt Bango',
  'preg_week_read_labour_prep': 'CC0 · stocksnap · Freestocks.org',
  'preg_week_read_first_24h': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_exp_priya': 'CC0 · stocksnap · Mel Elías',
  'preg_week_read_exp_meera': 'CC0 · stocksnap · Brodie Vissers',
  'preg_week_read_res_voices': 'CC0 · stocksnap · Suhyeon Choi',
  'preg_week_read_res_stress': 'CC0 · stocksnap · Marcos Moraes',
  'preg_scan_read_sex_law': 'CC0 · stocksnap · Skitter Photo',
  'preg_scan_read_costs': 'CC0 · stocksnap · Oles kanebckuu',
  'preg_scan_read_every_scan': 'CC0 · stocksnap · Candace McDaniel',
  'preg_scan_read_keep': 'CC0 · stocksnap · Daria Nepriakhina',
  'preg_scan_read_take_along': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_bp_dangerous': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_bleeding': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_less_movement': 'CC0 · stocksnap · Freestocks.org',
  'preg_cond_read_sugar_india': 'CC0 · stocksnap · Burst',
  'preg_cond_read_thyroid_tablet': 'CC0 · stocksnap · Michal Jarmoluk',
  'preg_cond_read_iron': 'CC0 · stocksnap · Tim Sullivan',
  'preg_diet_read_add_now': 'CC0 · stocksnap · Burst',
  'preg_labour_read_pain_relief': 'CC0 · stocksnap · Freestocks.org',
  'nut_milk': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'cani_chyawanprash': 'CC0 · StockSnap · Markus Spiske',
  'cani_laxative': 'CC0 · StockSnap · Freestocks.org',
  'nutrition_hero': 'CC0 · StockSnap · Nordwood Themes',
  'cani_hero': 'CC0 · StockSnap · Agnieszka Walędziak',
  'nut_orange': 'CC0 · StockSnap · Daria Nepriakhina',
  'nut_r_vegetable_poha': 'CC BY · Flickr · rovingI',
  'nut_r_vegetable_upma': 'CC BY · Flickr · spurekar',
  'nut_r_peanut_jaggery_chikki': 'CC BY · Flickr · Vegan Feast Catering',
  'nut_r_jaggery_kheer': 'CC BY · Flickr · RBerteig',
  'nut_r_ginger_lemon_tea': 'CC BY · Flickr · noahbloom',
  'nut_r_badam_milk': 'CC BY · Flickr · jules:stonesoup',
  'nut_r_moong_dal_soup': 'CC BY · Flickr · bobjudge',
  'nut_r_tomato_carrot_soup': 'CC BY · Flickr · emmadiscovery',
  'nut_r_egg_curry': 'CC BY-SA · Flickr · Rameshng',
  'nut_r_dal_palak': 'CC BY-SA · Flickr · avlxyz',
  // Trying to conceive, the Fertile window door (2026-09-28).
  'ttc_tile_your_best_days_this_month': 'CC0 · StockSnap · Jeff Sheldon',
  'ttc_tile_which_days_can_you_get_pregnant': 'CC0 · StockSnap · Mona Magnussen',
  'ttc_tile_how_the_body_shows_the_right_days': 'CC BY-SA 4.0 · Wikimedia Commons · Franz van Duns',
  'ttc_read_ovulation_kits': 'Public domain · Wikimedia Commons · Sapp',
  'ttc_read_ovulation_tests_irregular': 'CC0 · StockSnap · Lia Leslie',
  'ttc_read_morning_temperature': 'CC0 · StockSnap · Mary Whitney',
  'ttc_tile_buy_an_ovulation_kit': 'CC BY-SA 4.0 · Wikimedia Commons · Rathfelder',
  'ttc_read_timing_myths': 'CC0 · StockSnap · Icons8 team',
  'ttc_tile_every_day_or_not': 'CC BY 2.0 · Wikimedia Commons · george ruiz',
  'ttc_tile_do_positions_matter': 'CC0 · StockSnap · Jay Mantri',
  'ttc_tile_should_you_lie_down_after': 'CC0 · StockSnap · Burst',
  'ttc_tile_do_you_need_to_orgasm': 'CC0 · StockSnap · The World is a Stage',
  'ttc_tile_six_myths_about_timing_one_by_one': 'CC0 · StockSnap · Jiyeon Park',
  'ttc_read_stress_fertility': 'CC BY-SA 4.0 · Wikimedia Commons · Ganesh Mohan T',
  'ttc_tile_why_just_relax_is_the_wrong_advice': 'CC0 · StockSnap · Freestocks.org',
  'ttc_tile_your_cycle_drawn_out_step_by_step': 'CC0 · StockSnap · Free Nature Stock',
  'ttc_read_two_week_wait': 'CC BY 2.0 · Wikimedia Commons · John Morgan',
  'ttc_read_early_signs': 'CC0 · StockSnap · Lia Leslie',
  'ttc_read_implantation_bleeding': 'CC0 · StockSnap · Ina Soulis',
  'ttc_tile_should_i_test': 'CC0 · StockSnap · Top Down Tech',
  'ttc_read_when_to_test': 'CC0 · StockSnap · Noah Silliman',
  'ttc_read_how_to_test': 'CC BY 2.0 · Wikimedia Commons · Wutthichai Charoenburi',
  'ttc_read_faint_line': 'CC BY-SA 4.0 · Wikimedia Commons · Ajay Kumar Chaurasiya',
  'ttc_read_late_negative': 'CC0 · StockSnap · AJ Montpetit',
  'ttc_read_feeling_pregnant': 'CC0 · StockSnap · Beauty and Fashion',
  'ttc_read_sex_homework': 'CC0 · StockSnap · Words as Pictures',
  'ttc_read_low_desire': 'CC0 · StockSnap · Christian Mackie',
  'ttc_read_keeping_close': 'CC0 · StockSnap · Candace McDaniel',
  'ttc_read_pain_vaginismus': 'CC0 · StockSnap · Alisa Anton',
  'ttc_read_lubricants': 'CC0 · StockSnap · George Becker',
  'ttc_read_sex_after_window': 'CC0 · StockSnap · Kari Shea',
  'ttc_tile_how_sperm_are_made': 'CC0 · StockSnap · Markus Spiske',
  'ttc_tile_three_things_that_really_change_his_numbers': 'CC0 · StockSnap · kinkate',
  'ttc_read_case_for_testing': 'CC BY-SA 2.0 · Wikimedia Commons · Chad Anderson, staff photographer for SFO Museum',
  'ttc_read_heat_habits': 'CC0 · StockSnap · Leeroy',
  'ttc_tile_3_things_for_you': 'CC0 · StockSnap · Nordwood Themes',
  'ttc_read_three_months_before': 'CC BY-SA 4.0 · Wikimedia Commons · Rajeeb Dutta',
  'ttc_read_folic_acid': 'CC0 · Wikimedia Commons · Miansari66',
  'ttc_read_what_to_cut': 'CC0 · StockSnap · Healthy Living',
  'ttc_read_weight_kindly': 'CC0 · StockSnap · Gaelle Marcel',
  'ttc_read_when_to_seek_help': 'CC0 · Wikimedia Commons · Tama998',
  'ttc_read_how_long_it_takes': 'CC0 · StockSnap · Seacoast Sage',
  'ttc_tile_signs_not_to_wait': 'CC0 · StockSnap · Negative Space',
  'ttc_tile_talk_to_a_doctor': 'CC0 · StockSnap · Negative Space',  // Trying to conceive, the other eight doors and the home's reads (2026-09-28).
  'ttc_tile_pcos_explained_in_five_minutes': 'CC0 · StockSnap · Negative Space',
  'ttc_read_pcos_cycle': 'CC BY-SA 4.0 · Wikimedia Commons · AbvanG',
  'ttc_read_pcos_irregular': 'CC0 · StockSnap · Kristin Hardwick',
  'ttc_tile_how_common_is_pcos': 'CC0 · StockSnap · Andrew Ridley',
  'ttc_tile_pcos_or_ovarian_cysts': 'CC0 · StockSnap · Foodie Girl',
  'ttc_tile_pcos_or_thyroid': 'CC BY-SA 4.0 · Wikimedia Commons · Labrat879',
  'ttc_tile_hair_changes_explained': 'Public domain · Wikimedia Commons · Anonymous (Egypt)Unknown author',
  'ttc_read_pcos_diagnosed': 'CC BY-SA 3.0 · Wikimedia Commons · Stethoscopes',
  'ttc_tile_what_a_pcos_friendly_indian_plate_looks_like': 'CC BY-SA 4.0 · Wikimedia Commons · Keshwani.pradeep',
  'ttc_read_pcos_insulin': 'CC BY-SA 4.0 · Wikimedia Commons · AlixSaz',
  'ttc_read_pcos_food': 'CC BY 2.0 · Wikimedia Commons · rovingI',
  'ttc_tile_moong_dal_chilla_with_curd': 'CC BY-SA 4.0 · Wikimedia Commons · RekhaY07',
  'ttc_tile_do_you_have_to_give_up_rice': 'CC BY-SA 4.0 · Wikimedia Commons · Shreya151994',
  'ttc_read_pcos_inositol': 'CC0 · Wikimedia Commons · INeverCry',
  'ttc_tile_worth_it_or_hype': 'CC BY-SA 3.0 · Wikimedia Commons · Orange-kun',
  'ttc_tile_myo_inositol': 'CC BY-SA 4.0 · Wikimedia Commons · Revital Salomon',
  'ttc_read_pcos_weight': 'CC0 · StockSnap · Studio 7042',
  'ttc_tile_sleep_movement_and_insulin': 'CC0 · StockSnap · Brandi Redd',
  'ttc_tile_yoga_and_your_mood': 'CC BY-SA 4.0 · Wikimedia Commons · Peripitus',
  'ttc_tile_gentle_movement_for_pcos': 'CC0 · StockSnap · Bruno Nascimento',
  'ttc_read_pcos_ovulation': 'CC BY-SA 4.0 · Wikimedia Commons · Subhrajyoti07',
  'ttc_tile_cycles_without_ovulation': 'CC0 · StockSnap · NASA',
  'ttc_read_pcos_timelines': 'CC0 · StockSnap · Bob Richards',
  'ttc_tile_the_pcos_treatments_your_doctor_may_offer': 'CC BY-SA 4.0 · Wikimedia Commons · Jacek Halicki',
  'ttc_read_pcos_treatment': 'CC0 · StockSnap · Jamie Hamel-Smith',
  'ttc_read_pcos_meds': 'CC0 · Wikimedia Commons · Tmeers91',
  'ttc_tile_cycle_companion': 'CC0 · Wikimedia Commons · Amitbalani',
  'ttc_tile_log_your_symptoms': 'CC0 · StockSnap · Cathryn Lavery',
  'ttc_tile_what_your_cycle_shows': 'CC0 · StockSnap · Shotstash.com',
  'ttc_tile_when_to_see_a_doctor': 'CC BY-SA 4.0 · Wikimedia Commons · Ivan2010',
  'ttc_tile_when_to_see_a_specialist': 'CC0 · StockSnap · World Maps',
  'ttc_tile_talk_to_a_pcos_specialist': 'CC BY-SA 4.0 · Wikimedia Commons · Jacek Halicki',
  'ttc_tile_the_pcos_programme': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'ttc_tile_should_i_seek_fertility_help': 'CC0 · StockSnap · Kristin Hardwick',
  'ttc_tile_speak_to_a_fertility_specialist': 'CC BY-SA 4.0 · Wikimedia Commons · melvil',
  'ttc_tile_an_ivf_cycle_start_to_finish': 'CC0 · StockSnap · Ylanite Koppens',
  'ttc_read_ivf_explained': 'CC0 · StockSnap · Aaron Burden',
  'ttc_tile_iui_or_ivf_and_when_to_move_from_one_to_the_other': 'CC0 · StockSnap · Vintage RS',
  'ttc_read_ivf_icsi': 'CC0 · Wikimedia Commons · Drew Hays drew_hays',
  'ttc_read_ivf_workup': 'CC BY-SA 4.0 · Wikimedia Commons · Sth.niv',
  'ttc_read_semen_analysis': 'CC BY 2.5 · Wikimedia Commons · Jeffrey M. Vinocur',
  'ttc_read_clinic_glossary': 'CC0 · StockSnap · Leeroy',
  'ttc_read_ovulation_tablets': 'CC0 · Wikimedia Commons · 沈澄心',
  'ttc_read_follicle_scans': 'CC BY 4.0 · Wikimedia Commons · Harrison Keely',
  'ttc_read_donor_eggs_sperm': 'CC0 · StockSnap · Gabriel Ghnassia',
  'ttc_read_surrogacy_india': 'CC0 · StockSnap · WDnet Studio',
  'ttc_read_age_after_35': 'CC0 · StockSnap · FreePhotos',
  'ttc_read_age_after_40': 'CC0 · StockSnap · Nature Backgrounds',
  'ttc_read_second_baby': 'CC0 · StockSnap · Kristin Hardwick',
  'ttc_read_egg_freezing': 'CC BY-SA 3.0 · Wikimedia Commons · GOKLuLe 盧樂',
  'ttc_read_ivf_costs': 'CC BY 3.0 · Wikimedia Commons · Jnunoferreira',
  'ttc_read_ivf_package': 'CC BY-SA 4.0 · Wikimedia Commons · Billjones94',
  'ttc_read_ivf_success_rates': 'CC0 · StockSnap · Negative Space',
  'ttc_tile_questions_to_ask_before_you_sign_up': 'CC0 · Wikimedia Commons · RyanT27',
  'ttc_read_ivf_injections': 'CC0 · Wikimedia Commons · Abdsomod',
  'ttc_read_ivf_ohss': 'CC0 · StockSnap · Negative Space',
  'ttc_read_tx_baseline_scan': 'CC BY 4.0 · Wikimedia Commons · Harrison Keely',
  'ttc_read_tx_monitoring_scans': 'CC0 · Wikimedia Commons · waketechcc',
  'ttc_read_tx_trigger_shot': 'CC0 · StockSnap · Aphiwat Chuangchoem',
  'ttc_read_tx_iui_day': 'CC BY-SA 3.0 · Wikimedia Commons · C T Johansson',
  'ttc_read_tx_embryo_days': 'CC BY-SA 3.0 · Wikimedia Commons · Lilly_M',
  'ttc_read_tx_fresh_or_frozen': 'CC0 · StockSnap · Ryan Pohanic',
  'ttc_read_tx_frozen_transfer': 'CC0 · StockSnap · Ian Schneider',
  'ttc_read_tx_transfer_day': 'CC0 · StockSnap · Kristin Hardwick',
  'ttc_read_tx_wait_after_treatment': 'CC0 · StockSnap · Krzysztof Puszczyński',
  'ttc_tile_getting_through_the_two_week_wait': 'CC0 · StockSnap · Pawel Kadysz',
  'ttc_read_tx_beta_test': 'CC BY-SA 4.0 · Wikimedia Commons · J.N. Eskra',
  'ttc_read_tx_negative_after_treatment': 'CC0 · StockSnap · Jon Phillips',
  'ttc_read_tx_review_appointment': 'Public domain · Wikimedia Commons · Evan-amos',
  'ttc_read_ivf_retrieval': 'CC0 · StockSnap · Ryan McGuire',
  'ttc_tile_does_bed_rest_after_transfer_help': 'CC0 · StockSnap · Travel Photographer',
  'ttc_read_ivf_working': 'CC0 · StockSnap · Raymond Sam',
  'ttc_tile_track_this_treatment_cycle': 'CC0 · StockSnap · Negative Space',
  'ttc_tile_keep_your_reports_together': 'CC BY-SA 2.0 · Wikimedia Commons · Tony Webster from Portland, Oregon',
  'ttc_tile_your_medicines_and_timings': 'CC BY 2.0 · Wikimedia Commons · NIAID',
  'ttc_read_supplement_timing': 'CC0 · Wikimedia Commons · Stevepb',
  'ttc_tile_folic_acid_and_preconception_supplements': 'CC BY-SA 4.0 · Wikimedia Commons · BuhaM',
  'ttc_read_meal_plan_week': 'CC0 · Wikimedia Commons · Miansari66',
  'ttc_read_everyday_recipes': 'CC BY-SA 4.0 · Wikimedia Commons · Monali.mishra',
  'ttc_tile_plan_your_own_week': 'CC0 · StockSnap · Martin Vorel',
  'ttc_read_iron_before_pregnancy': 'CC BY-SA 4.0 · Wikimedia Commons · Deviselvam',
  'ttc_read_omega3_without_fish': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'ttc_read_ask_dietitian': 'CC0 · StockSnap · Monoar Rahman',
  'ttc_read_preconception_tests': 'CC0 · StockSnap · Freestocks.org',
  'ttc_read_carrier_screening': 'CC BY-SA 4.0 · Wikimedia Commons · J.N. Eskra',
  'ttc_tile_check_your_vaccinations': 'CC0 · StockSnap · Glenn Carstens-Peters',
  'ttc_tile_the_full_test_library': 'CC BY-SA 2.0 · Wikimedia Commons · Tony Webster from Portland, Oregon',
  'ttc_tile_habits_worth_building_now': 'CC0 · StockSnap · JESHOOTS.com',
  'ttc_tile_track_what_you_re_working_on': 'CC0 · StockSnap · Raymond Sam',
  'ttc_read_coming_off_birth_control': 'CC0 · StockSnap · Brooke Lark',
  'ttc_read_meds_and_conditions': 'CC BY 2.0 · Wikimedia Commons · NIAID',
  'ttc_read_whose_side': 'CC0 · StockSnap · Words as Pictures',
  'ttc_read_first_gyn_visit': 'CC0 · StockSnap · Tran Mau Tri Tam',
  'ttc_read_after_abortion': 'CC0 · StockSnap · Leeroy',
  'ttc_read_money_before_baby': 'CC BY-SA 3.0 · Wikimedia Commons · Reserve Bank of India / Kshitij Gupta',
  'ttc_tile_your_pre_pregnancy_checklist': 'CC0 · StockSnap · Startup Stock Photos',
  'ttc_tile_talk_to_someone_before_you_start': 'CC0 · StockSnap · Burst',
  'ttc_tile_talk_to_a_nutritionist': 'CC0 · StockSnap · Healthy Living',
  'ttc_read_his_age': 'CC0 · StockSnap · Wil Stewart',
  'ttc_tile_why_his_side_gets_tested_last': 'CC BY 4.0 · Wikimedia Commons · Wellcome Collection',
  'ttc_tile_reading_a_semen_report': 'CC BY-SA 4.0 · Wikimedia Commons · Talita Oliveira',
  'ttc_tile_read_your_semen_report': 'CC0 · StockSnap · Jeffrey Betts',
  'ttc_tile_have_the_report_read_properly': 'CC0 · StockSnap · Châu Thông Phan',
  'ttc_tile_keep_his_reports_with_yours': 'CC BY 2.0 · Wikimedia Commons · allispossible.org.uk',
  'ttc_read_report_words': 'CC0 · StockSnap · Green Chameleon',
  'ttc_read_result_normal': 'CC0 · StockSnap · Solo Shutter',
  'ttc_read_result_abnormal': 'CC0 · StockSnap · Altered Reality',
  'ttc_read_azoospermia': 'CC0 · StockSnap · Frank Oschatz',
  'ttc_read_three_months': 'CC0 · StockSnap · Altered Reality',
  'ttc_read_zinc_coq10': 'CC0 · StockSnap · Mira Bozhko',
  'ttc_tile_zinc': 'CC0 · StockSnap · Patryk Dziejma',
  'ttc_tile_coq10': 'CC0 · StockSnap · Rachael Gorjestani',
  'ttc_tile_the_half_nobody_talks_about': 'CC0 · StockSnap · Caio Resende',
  'ttc_tile_what_he_can_track': 'CC0 · StockSnap · Daria Nepriakhina',
  'ttc_tile_talk_to_an_andrologist': 'CC BY-SA 3.0 · Wikimedia Commons · Stethoscopes',
  'ttc_read_his_side_pressure': 'CC0 · StockSnap · Ylanite Koppens',
  'ttc_read_bringing_him_in': 'CC0 · StockSnap · Words as Pictures',
  'ttc_read_loss_recovery': 'CC0 · StockSnap · Irene Lasus',
  'ttc_tile_what_the_next_few_weeks_look_like': 'CC0 · StockSnap · Ethan Brooke',
  'ttc_tile_what_normal_bleeding_and_spotting_looks_like': 'CC0 · StockSnap · Travel Photographer',
  'ttc_read_ectopic_pregnancy': 'CC0 · Wikimedia Commons · Hanabishi',
  'ttc_tile_rh_status_and_retained_tissue': 'CC0 · StockSnap · George Becker',
  'ttc_tile_can_you_ovulate_before_your_first_period': 'CC0 · StockSnap · Robert De Bock',
  'ttc_read_trying_again': 'CC0 · StockSnap · Philipp Reiner',
  'ttc_read_miscarriage_causes': 'CC0 · StockSnap · Rachel Davis',
  'ttc_tile_when_to_ask_for_tests': 'CC0 · StockSnap · Daniel Roe',
  'ttc_read_recurrent_miscarriage': 'CC0 · StockSnap · Johannes Plenio',
  'ttc_tile_does_one_miscarriage_mean_another': 'CC0 · StockSnap · Ian Livesey',
  'ttc_read_chemical_pregnancy': 'CC0 · StockSnap · Aaron Burden',
  'ttc_tile_do_you_have_to_wait_six_months': 'CC0 · StockSnap · Tricia Gray',
  'ttc_tile_what_to_do_differently_next_time': 'CC0 · StockSnap · eberhard grossgasteiger',
  'ttc_read_loss_feelings': 'CC BY-SA 4.0 · Wikimedia Commons · W.carter',
  'ttc_tile_your_care_circle': 'CC BY-SA 4.0 · Wikimedia Commons · Acabashi',
  'ttc_tile_someone_who_knows_this_kind_of_loss': 'CC0 · StockSnap · Maria Shanina',
  'ttc_tile_after_a_loss_four_sessions': 'CC0 · StockSnap · Aaron Burden',
  'ttc_tile_talk_it_through': 'CC0 · StockSnap · Negative Space',
  'ttc_read_period_came': 'CC0 · StockSnap · Nathan Fertig',
  'ttc_read_others_news': 'CC BY-SA 4.0 · Wikimedia Commons · مجتبیٰ',
  'ttc_read_telling_family': 'CC0 · StockSnap · Seth Doyle',
  'ttc_read_good_news_answers': 'CC0 · StockSnap · Michal Jarmoluk',
  'ttc_read_family_asking': 'CC BY-SA 4.0 · Wikimedia Commons · IshakHerock',
  'ttc_read_trying_takes_over': 'CC0 · Wikimedia Commons · Sylwia Bartyzel sylwiabartyzel',
  'ttc_read_month_after_month': 'CC0 · StockSnap · Pawel Kadysz',
  'ttc_tile_will_it_happen_if_you_stop_thinking_about_it': 'CC0 · StockSnap · Sudarshan Bhat',
  'ttc_tile_where_stress_does_have_a_real_effect': 'CC0 · StockSnap · Lia Leslie',
  'ttc_read_garbh_sanskar': 'CC BY 2.0 · Wikimedia Commons · siddarth varanasi',
  'ttc_tile_the_eight_sessions_taught': 'CC BY-SA 4.0 · Wikimedia Commons · Suyash Dwivedi',
  'ttc_tile_does_it_make_a_smarter_baby': 'CC BY 4.0 · Wikimedia Commons · Chronos.Zx',
  'ttc_tile_and_if_you_re_not_religious': 'CC0 · Wikimedia Commons · Jesselikesweather',
  'ttc_tile_what_a_daily_practice_is_for': 'CC0 · Wikimedia Commons · Hong Zhang (jennyzhh2008)',
  'ttc_tile_five_minutes_and_not_as_a_target': 'CC BY-SA 3.0 · Wikimedia Commons · Prenn',
  'ttc_tile_loosen_up_neck_shoulders_side_bends': 'CC0 · StockSnap · Matthew Henry',
  'ttc_tile_hip_openers_butterfly_and_slow_lunge': 'CC0 · StockSnap · Matthew Henry',
  'ttc_tile_a_ten_minute_walk': 'CC0 · StockSnap · Michal Kulesza',
  'ttc_tile_slow_sun_salutation_three_rounds': 'CC0 · StockSnap · Matthew Henry',
  'ttc_tile_breathe_in_for_4_out_for_6': 'CC0 · StockSnap · Tim Sullivan',
  'ttc_tile_alternate_nostril_breathing': 'CC0 · StockSnap · Matthew Henry',
  'ttc_tile_box_breathing': 'CC0 · StockSnap · Jay Mantri',
  'ttc_tile_two_minute_body_relaxation': 'CC0 · StockSnap · Eduard Militaru',
  'ttc_tile_two_minute_calm_listen': 'CC BY-SA 4.0 · Wikimedia Commons · Vamsivadrevu',
  'ttc_tile_ten_slow_breaths_together': 'CC0 · StockSnap · Anggoro Sakti',
  'ttc_tile_a_longer_session_this_week': 'CC0 · StockSnap · Daria Nepriakhina',
  'ttc_tile_the_free_garbh_sanskar_course_eight_sessions': 'CC BY-SA 4.0 · Wikimedia Commons · PilotChicago',
  'ttc_read_sleep_trying': 'CC0 · StockSnap · Kelly Ishmael',
  'ttc_read_bedtime': 'CC0 · StockSnap · Negative Space',
  'ttc_tile_a_calming_breath_for_bedtime': 'CC0 · StockSnap · Burst',
  'ttc_tile_talk_to_a_psychologist': 'CC BY-SA 2.0 · Wikimedia Commons · Jim Osley',
  'ttc_read_relationship_safety': 'CC0 · StockSnap · Olu Eletu',
  'ttc_tile_symptoms_and_mood': 'CC0 · StockSnap · Negative Space',
  'ttc_read_normal_cycle': 'CC0 · StockSnap · Chris Lawton',
  'ttc_read_late_period': 'Public domain · Wikimedia Commons · Claudio Elias',
  'ttc_read_irregular_not_pcos': 'CC0 · StockSnap · Antonio Grosz',
  'ttc_read_bleeding_kinds': 'CC0 · StockSnap · Romanos Kalamatianos',
  'ttc_read_spotting': 'CC BY 4.0 · Wikimedia Commons · Linn.KnowSex',
  'ttc_read_heavy_flow': 'CC BY-SA 4.0 · Wikimedia Commons · Vulvani',
  'ttc_read_ovulation_pain': 'CC0 · StockSnap · Aaron Burden',
  'ttc_read_period_pain': 'CC BY 2.0 · Wikimedia Commons · Kara Babcock',
  'ttc_read_discharge_guide': 'CC0 · StockSnap · Jeffrey Betts',
  'ttc_read_intimate_washing': 'CC0 · StockSnap · Paweł Chrząszczewski',
  'ttc_read_intimate_worries': 'CC0 · StockSnap · Jess Watters',
  'ttc_read_yeast_bv': 'CC0 · StockSnap · Daria Shevtsova',
  'ttc_read_uti_trying': 'CC0 · StockSnap · Candace McDaniel',
  'ttc_read_sti_testing': 'CC BY-SA 4.0 · Wikimedia Commons · Adoscam',
  'ttc_read_slow_conception': 'CC0 · StockSnap · Austin Neill',
  'ttc_read_thyroid_tsh': 'CC0 · Wikimedia Commons · Frankincense Diala',
  'ttc_read_high_prolactin': 'CC BY-SA 4.0 · Wikimedia Commons · Sth.niv',
  'ttc_read_endometriosis': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'ttc_read_fibroids_polyps': 'CC BY-SA 4.0 · Wikimedia Commons · Happi Raphael',
  'ttc_read_ovarian_cysts': 'CC BY 4.0 · Wikimedia Commons · Goleisureintl',
  'ttc_read_blocked_tubes_hsg': 'Public domain · Wikimedia Commons · Diane A. Reid (Photographer)',
  'ttc_read_pelvic_infection': 'CC0 · Wikimedia Commons · Pixabay',
  'ttc_read_genital_tb': 'CC BY-SA 4.0 · Wikimedia Commons · Subhrajyoti07',
  'ttc_tile_trying_for_many_months': 'CC0 · StockSnap · Aaron Burden',
  'ttc_tile_is_it_time_to_see_someone': 'CC0 · StockSnap · Ales Krivec',
  'ttc_tile_talk_to_a_fertility_doctor': 'CC BY-SA 2.0 · Wikimedia Commons · ernstl',
};

/// ⚠️ OUR OWN HOST, ONCE IT EXISTS — 2026-09-20. Every URL in the table
/// above points at a free host (Wikimedia Commons, StockSnap), and the free
/// hosts throttle by IP: a phone behind a carrier's shared address saw all
/// but one photo refused in one session. The fix is to serve them
/// ourselves. `tools/read_images/fetch_read_images.py` downloads every id
/// in the table into one folder (`<id>.jpg`); the folder goes up to a
/// Cloudflare R2 bucket as-is; and this constant becomes that bucket's
/// public URL (with a trailing slash). From then on `readImageFor` builds
/// `<base><id>.jpg` and the table's URLs are only the credits' provenance
/// and a fallback for an id the bucket lacks.
///
/// Empty = not set up yet: the table's URLs are used directly, as before.
// 2026-09-21: the R2 bucket `parentveda-images` on its r2.dev development
// URL — 368 files, uploaded by tools/read_images/upload_to_r2.py. A custom
// domain (img.parentveda.com) replaces this string later; nothing else
// changes. Empty = the table's URLs, as before.
const String kReadImageBase = 'https://pub-bfbc0773e60e4c5c851b535f08b384bc.r2.dev/';

/// The picture for a read: its own, else ours (R2), else the table's, else
/// none. An id that is in the table is assumed to be in the bucket once
/// the base is set — the fetch script mirrors the whole table.
String? readImageFor(String readId, {String? own}) {
  if (own != null && own.isNotEmpty) return own;
  final url = kReadImageUrls[readId];
  if (url == null) return null;
  if (kReadImageBase.isNotEmpty) return '$kReadImageBase$readId.jpg';
  final ov = kOpenverseIds[readId];
  if (ov != null && (url.contains('stocksnap.io') || url.contains('staticflickr.com'))) return openverseImageUrl(ov);
  return url;
}

/// ⚠️ STOPGAP UNTIL R2 — 2026-09-20. `cdn.stocksnap.io` sits behind a
/// Cloudflare rule that answers 403 to anything that is not a browser tab:
/// the phone got 403 for every StockSnap URL in the table, with a Dart user
/// agent and with Chrome's, so 196 of the 357 photos had never drawn on the
/// device. (It was read as Wikimedia throttling for a week; it was not.)
/// Openverse indexes StockSnap and proxies each image by its own id, and
/// that proxy answers the phone. `tools/read_images/openverse_ids.json`
/// holds the same map for the mirror script; this constant is generated
/// from it and dies with the StockSnap URLs the day `kReadImageBase` is
/// set — the R2 branch above runs first.
String openverseImageUrl(String id) => 'https://api.openverse.org/v1/images/$id/thumb/?full_size=true';

const Map<String, String> kOpenverseIds = {
  'cani_amusement_rides': '46049d46-f815-4a18-949b-c171c13fae33',
  'cani_berries': 'd5093f91-7788-4414-814c-956c360dec0f',
  'cani_brinjal': '57b8347d-4d83-4fd3-ba6d-236b989c2b53',
  'cani_carrot': 'c43f202b-ab6c-439b-8b0b-f22b9f1c66ef',
  'cani_cashews': '8a90bf17-a7ee-4c9b-8a58-8466b5d0f7c9',
  'cani_cheese': '910473e2-3e36-4eb2-8837-5578952dca7d',
  'cani_chemical_peel': 'ff075f38-71f8-4dc0-b930-5e383c2bc8a7',
  'cani_chyawanprash': '0d02bce8-f553-42ba-941a-67cffad43c20',
  'cani_climbing_stairs': '88db6723-0d25-40c0-8a26-e70463ec0b65',
  'cani_combiflam': '1c472723-e3b3-4612-8c79-79c2805cae6d',
  'cani_dal': '50f4cd72-f300-4259-b0e9-51ad7d7971dc',
  'cani_dancing': 'f5e60e84-a3a5-431a-a797-3ab1485b9952',
  'cani_decaf_coffee': '18bfb8f5-81b4-4fb1-b312-d1593ae61424',
  'cani_deli_meat': '1299b96f-49ca-49a0-b2e6-1e1efcdef5ee',
  'cani_diet_soda': '2108e20d-ba2d-4f9d-b812-0f6551b486a2',
  'cani_driving': '0e66fa6f-bd61-4790-b72c-0b7408c4bfd5',
  'cani_drumstick': '76134dba-39fd-461b-b8c2-402fb486be42',
  'cani_dry_fruits': '2dd6863e-c162-4c83-88ad-df933278a7dc',
  'cani_egg': '4f77f9e4-1b31-402a-978d-2900d17bb446',
  'cani_fasting': 'ad60eeb8-7f1b-4e03-8045-22e79c7611a1',
  'cani_fish': 'd6e74b4a-395c-4799-a141-90c1b586643a',
  'cani_flight_travel': 'e54a8258-1cef-48bc-8667-e57d2ee28e26',
  'cani_fresh_juice': 'a34f4595-28ed-4f4f-b740-a99f5687b69b',
  'cani_fried_snacks': 'fb4d9dfc-8630-4fbe-8b38-4c7d582427f9',
  'cani_gardening': 'a17b99f4-5429-4a30-92e5-1e81107d7e1f',
  'cani_gel_nails': 'a71bfd77-9f7e-45bb-a4dd-875d2fbc35e5',
  'cani_ghee': '089f2f2b-4a68-4de3-bc9f-e0f879432348',
  'cani_grapes': '79d03177-e94f-44a3-938c-691af8e3a512',
  'cani_green_tea': '0368d3b1-fd76-42ec-b49d-5cb96381d362',
  'cani_gym': 'a9541001-99a6-4fd4-ac30-78a90dfdfe94',
  'cani_herbal_tea': '87b3b06d-8c26-4ae5-a277-071aba1177f3',
  'cani_hero': '7b37f6ce-7d0f-4ab9-9e95-5519e117adda',
  'cani_honey': '60a2315e-ed23-4964-95ed-25f44ff38de9',
  'cani_hot_water_bath': '82be117b-6b7c-47df-b9ea-a151d97fe08d',
  'cani_instant_noodles': '27359dfa-a384-478a-bd7f-63a278291bda',
  'cani_jaljeera': 'afeb23f6-2cf4-45e0-bbfa-fd51548cca2a',
  'cani_kiwi': '2c738119-0120-4671-b2d9-55b38d206a8c',
  'cani_lassi': '81d320bd-d504-43ca-9ea8-a6101bd3b9da',
  'cani_laxative': 'ca66e2e7-3ad9-4112-b70a-092e3594f1cf',
  'cani_leftovers': 'ad5a5edc-3763-47bc-8f92-d325c56a564c',
  'cani_lemon_water': '3cca783c-d3a4-45a6-8cf9-026c8dfe473e',
  'cani_long_travel': 'a6942b3d-6090-4fae-9c6a-cba9fc75b9f0',
  'cani_massage': 'edff9d5d-cbc5-49d5-a5ae-f55cb8b55671',
  'cani_milk': '35e968c1-06c3-439d-819c-6eb28c339317',
  'cani_milkshake': '81d320bd-d504-43ca-9ea8-a6101bd3b9da',
  'cani_mobile_phone': '11cd1d83-581a-46ba-b047-3f04abd3dc74',
  'cani_mushroom': '96c26d06-1a17-4d77-bca7-5dff163f0b1b',
  'cani_nail_polish': 'b6238c19-3c99-4051-a48e-88237fa195ff',
  'cani_oats': '3d1c8a78-4558-468a-ae05-5923000743f5',
  'cani_ors': 'eeddfed2-237f-4f06-8828-c8dd928fe339',
  'cani_peanuts': 'bc5be522-5f0f-41a0-82b5-ed0cf428f7c9',
  'cani_pear': '777a46aa-fc78-4299-bb39-f217e6f278bf',
  'cani_pedicure': 'a71bfd77-9f7e-45bb-a4dd-875d2fbc35e5',
  'cani_perfume': '3355869e-3376-4c0b-8a24-de58701024e0',
  'cani_pet_cats': '81f5ecc8-98f9-4819-87cd-dce74e8564ff',
  'cani_pet_dogs': '82fbd49f-595e-44e1-a18b-49c2b57050aa',
  'cani_pickle': '556264d1-6969-4224-abfe-cf78eeb99e4c',
  'cani_potato': '51b6f763-82e8-4cf4-97a2-db8f260392ed',
  'cani_prawns': 'ce238aa0-538f-48ad-818c-d40b0023e186',
  'cani_raw_salad': 'a516f54b-9d2f-442a-9308-471fe2a62d55',
  'cani_salt': '68f9ddd2-a573-43b9-b5b9-67e1059c2d90',
  'cani_secondhand_smoke': '796a59c5-63bd-4903-8d9b-675e22c9c377',
  'cani_sex': '8f82d802-8224-4f7b-b3fd-5cfe59805227',
  'cani_shelf_doActivity': '15ba125e-f2a9-4abb-bf10-a44aedacb215',
  'cani_sleeping_back': '635a480d-2365-4ef4-b0f9-665abf04dac3',
  'cani_sleeping_pills': '1c472723-e3b3-4612-8c79-79c2805cae6d',
  'cani_smoking': 'e6c37601-a2e5-4d00-9ff3-cf97a1763b35',
  'cani_smoothie': 'bcf85173-49f4-430a-95cb-f274e64679a6',
  'cani_soft_drinks': '3a6ff63b-db66-4ac0-839d-a9573bce60b1',
  'cani_spices': 'e055a32b-1685-43ed-8f23-4784363f62b4',
  'cani_spicy_food': 'c8a2e427-59b5-465e-b099-50c9c1ec7222',
  'cani_sugarcane_juice': 'a34f4595-28ed-4f4f-b740-a99f5687b69b',
  'cani_sunscreen': '49a87548-7cb0-41f0-864e-b9651e923590',
  'cani_sushi': '32b3de63-06fb-42b5-ab80-bf2862332f27',
  'cani_swimming': 'aaf2363f-5838-44c6-8bc5-780605f91d52',
  'cani_tattoo': '3143ff33-a2b8-4fb3-ab27-a5e948e911c1',
  'cani_tomato': '6c3af578-f403-4214-9b44-5b9b2ed36aea',
  'cani_trekking': '39431e7d-eb28-4579-af86-c7be7cff55ba',
  'cani_vaping': 'ee6b1a71-c3fc-47e5-8f82-a3253f705cf3',
  'cani_vitamin_c': '9d9a78eb-5337-48b9-9d69-b91f17bed226',
  'cani_walking': '15ba125e-f2a9-4abb-bf10-a44aedacb215',
  'cani_walnuts': '694540c2-46ac-458f-b261-c4c616e9e001',
  'cani_water': 'ed36b19e-675d-490b-9a19-8d72a6643f9e',
  'cani_waxing': '82be117b-6b7c-47df-b9ea-a151d97fe08d',
  'cani_yoga': '126d6729-71c2-4ad8-823f-cd77f9fb3a09',
  'condition_anemia': 'e84ea250-d502-45e2-910d-d8b28de7bc28',
  'condition_breech': 'a4614b33-8f42-452b-9714-840376f5c92f',
  'condition_cervical_incompetence': '99ae4ccb-24c6-4582-86fb-a70e800108db',
  'condition_covid_pregnancy': '03ab9ba4-47a6-477a-9b67-b806a06be1dd',
  'condition_ectopic': '373a2ccd-73e0-4e8c-bd07-b0d611b7ac6e',
  'condition_fibroids': '8a38e220-3c17-4c22-8f78-272eec927ed4',
  'condition_gdm': '0431bd03-8fce-44f8-ac2a-230088a318da',
  'condition_hellp': '679f9d68-20b0-42b2-8326-4d6b93f82bda',
  'condition_high_bp': '124e8a79-a8c9-4fee-b01a-3c8e681e8014',
  'condition_hyperemesis': '4084d766-5e2e-4d7d-a21c-e6fb07637968',
  'condition_icp_cholestasis': '062c169c-e5c0-4647-85f9-b894092e7fea',
  'condition_iugr': '8c822fc9-1b37-46a2-9184-141b36317829',
  'condition_low_amniotic_fluid': '27c8d660-7526-4bf6-ad44-3cd1ef3bdcac',
  'condition_miscarriage': 'a4724431-6805-4b40-a80d-d878491dfedc',
  'condition_pcos': '03ab9ba4-47a6-477a-9b67-b806a06be1dd',
  'condition_piles': '8f82d802-8224-4f7b-b3fd-5cfe59805227',
  'condition_placenta_previa': '4767df3d-924b-49b0-a300-ddcd04b1bc2b',
  'condition_placental_abruption': 'e7d58d39-6f6e-454a-a195-e82dfa5a6f79',
  'condition_pre_existing': '5dc948d9-4dfd-4576-9203-a88c86dd4999',
  'condition_preeclampsia': 'dab1d2b0-961a-4b5b-9d6e-c7cb27fb3c22',
  'condition_rh_negative': 'e7d58d39-6f6e-454a-a195-e82dfa5a6f79',
  'condition_thyroid': '062c169c-e5c0-4647-85f9-b894092e7fea',
  'condition_uti': '44054c98-cfba-4040-ae87-db2081fcb3f1',
  'condition_varicose_veins': '4ce285bb-2b9b-4697-a915-40fc80d7affb',
  'condition_vasa_previa': 'c956881c-f7a6-478a-a516-9cb2aa9b6aae',
  'finding_anemia': 'e84ea250-d502-45e2-910d-d8b28de7bc28',
  'finding_braxton_hicks': '03ab9ba4-47a6-477a-9b67-b806a06be1dd',
  'finding_breech': 'c956881c-f7a6-478a-a516-9cb2aa9b6aae',
  'finding_eif': 'a4724431-6805-4b40-a80d-d878491dfedc',
  'finding_fibroids': 'dab1d2b0-961a-4b5b-9d6e-c7cb27fb3c22',
  'finding_gestational_diabetes': '6753390e-9c55-48db-90e6-89ae0a51d37c',
  'finding_group_b_strep': '5f205b17-28fc-4810-8501-1a90c22e7a25',
  'finding_high_bp': '44054c98-cfba-4040-ae87-db2081fcb3f1',
  'finding_high_fluid': '0431bd03-8fce-44f8-ac2a-230088a318da',
  'finding_large_baby': '4767df3d-924b-49b0-a300-ddcd04b1bc2b',
  'finding_low_fluid': 'a19cca0a-9578-48e0-a129-b86744dc2965',
  'finding_low_lying_placenta': 'e0636dfa-fb16-4fbe-9e56-2e1537eefcea',
  'finding_marginal_cord': '5f0e95e2-2b69-46b1-a85f-69c9cb75fb47',
  'finding_nuchal_cord': '3a63007a-cf37-4b25-8289-8bf37b7eb9c8',
  'finding_placenta_resolved': '4084d766-5e2e-4d7d-a21c-e6fb07637968',
  'finding_placental_calcification': '062c169c-e5c0-4647-85f9-b894092e7fea',
  'finding_preeclampsia': 'a6fb8f84-aeb3-45b2-9805-e891ddd1fb9f',
  'finding_reduced_movements': '8f82d802-8224-4f7b-b3fd-5cfe59805227',
  'finding_rh_negative': 'e7d58d39-6f6e-454a-a195-e82dfa5a6f79',
  'finding_short_cervix': '8a38e220-3c17-4c22-8f78-272eec927ed4',
  'finding_single_umbilical_artery': '373a2ccd-73e0-4e8c-bd07-b0d611b7ac6e',
  'finding_small_baby': '99ae4ccb-24c6-4582-86fb-a70e800108db',
  'finding_soft_markers': '5dc948d9-4dfd-4576-9203-a88c86dd4999',
  'finding_subchorionic_hematoma': 'a4614b33-8f42-452b-9714-840376f5c92f',
  'finding_twin_pregnancy': '4ce285bb-2b9b-4697-a915-40fc80d7affb',
  'finding_vanishing_twin': '124e8a79-a8c9-4fee-b01a-3c8e681e8014',
  'finding_ventriculomegaly': 'd37fbb94-5a81-4b4e-9608-3721ae040a68',
  'nut_apple': '0bdcc5c5-244b-4099-8580-e4ecc8801a3d',
  'nut_banana': '78d976ea-2eee-43bf-9159-dfc377e202bb',
  'nut_boiled_eggs': 'c5c30020-e879-4fb5-a61b-8c9663662598',
  'nut_chai': 'a6757fb0-8f93-483e-8d9e-69178a2befbf',
  'nut_dal': '50f4cd72-f300-4259-b0e9-51ad7d7971dc',
  'nut_fruit_bowl': '48d77962-04c1-4cb3-9ca7-1e50ba8fbd5c',
  'nut_juice': 'a34f4595-28ed-4f4f-b740-a99f5687b69b',
  'nut_khakhra': '32c4069d-3b5f-4525-84d6-b85caf2ba838',
  'nut_lassi': '81d320bd-d504-43ca-9ea8-a6101bd3b9da',
  'nut_makhana': '1eeef039-e25b-43b9-8465-e6c91926629c',
  'nut_milk': '35e968c1-06c3-439d-819c-6eb28c339317',
  'nut_nuts': '2dd6863e-c162-4c83-88ad-df933278a7dc',
  'nut_salad': 'a516f54b-9d2f-442a-9308-471fe2a62d55',
  'nut_sandwich': '36011e8e-c7f6-4d85-aed2-a77d952c59f4',
  'nut_shukto': 'a01ecc5c-176b-4d1f-a445-655ff2184e3a',
  'nut_smoothie': '7fdd4d38-6b50-4bca-934a-bc33f52ac3c9',
  'nut_soup': '50f4cd72-f300-4259-b0e9-51ad7d7971dc',
  'nutrition_hero': '100c77dd-4fdb-4f87-bfe8-61c1185a71c9',
  'preg_cond_read_bleeding': '41411a68-de90-4e05-a9e2-4aa4dacc4d2b',
  'preg_cond_read_bp_dangerous': '5dc948d9-4dfd-4576-9203-a88c86dd4999',
  'preg_cond_read_iron': 'fcd27b05-eef9-4a13-bc55-38a4d36cd8f8',
  'preg_cond_read_less_movement': '062c169c-e5c0-4647-85f9-b894092e7fea',
  'preg_cond_read_sugar_india': 'e900b133-5f79-46e0-99d9-a21a2a6ebf59',
  'preg_cond_read_thyroid_tablet': '43ad449f-d284-4387-8aa7-fd4ae0f36bed',
  'preg_diet_read_add_now': 'e900b133-5f79-46e0-99d9-a21a2a6ebf59',
  'preg_labour_read_pain_relief': '4ce285bb-2b9b-4697-a915-40fc80d7affb',
  'preg_scan_read_calm': '4767df3d-924b-49b0-a300-ddcd04b1bc2b',
  'preg_scan_read_costs': '373a2ccd-73e0-4e8c-bd07-b0d611b7ac6e',
  'preg_scan_read_every_scan': 'c956881c-f7a6-478a-a516-9cb2aa9b6aae',
  'preg_scan_read_keep': '212437f5-df50-456b-99ed-4b1a448f1c8a',
  'preg_scan_read_sex_law': 'e0636dfa-fb16-4fbe-9e56-2e1537eefcea',
  'preg_scan_read_take_along': 'a4724431-6805-4b40-a80d-d878491dfedc',
  'preg_week_read_anomaly_scan': '967fef0f-50f9-4409-8373-f8a0b8849027',
  'preg_week_read_baby_sound': '4084d766-5e2e-4d7d-a21c-e6fb07637968',
  'preg_week_read_back_pain': '99ae4ccb-24c6-4582-86fb-a70e800108db',
  'preg_week_read_exp_meera': '03ab9ba4-47a6-477a-9b67-b806a06be1dd',
  'preg_week_read_exp_priya': '99ae4ccb-24c6-4582-86fb-a70e800108db',
  'preg_week_read_first_24h': '1f6e6288-bb1e-4530-8955-626fdf8d60db',
  'preg_week_read_first_scan': '967fef0f-50f9-4409-8373-f8a0b8849027',
  'preg_week_read_first_trimester': 'f2e7bacc-e460-4672-bf15-fbed7a7156fa',
  'preg_week_read_halfway': 'a4614b33-8f42-452b-9714-840376f5c92f',
  'preg_week_read_hospital_bag': 'c13553e4-6a18-43eb-afd3-9dc57dc66aa1',
  'preg_week_read_labour_prep': '4ce285bb-2b9b-4697-a915-40fc80d7affb',
  'preg_week_read_managing_nausea': '44054c98-cfba-4040-ae87-db2081fcb3f1',
  'preg_week_read_movement_awareness': '0431bd03-8fce-44f8-ac2a-230088a318da',
  'preg_week_read_nutrition_t2': '73c66a67-4ee0-4bc2-8c81-428a5691192b',
  'preg_week_read_partner_support': '8f82d802-8224-4f7b-b3fd-5cfe59805227',
  'preg_week_read_res_stress': '4767df3d-924b-49b0-a300-ddcd04b1bc2b',
  'preg_week_read_res_voices': 'e84ea250-d502-45e2-910d-d8b28de7bc28',
  'preg_week_read_talking_baby': 'e84ea250-d502-45e2-910d-d8b28de7bc28',
  'preg_week_read_third_tri_prep': 'c13553e4-6a18-43eb-afd3-9dc57dc66aa1',
  'scan_anomaly_scan': 'e0636dfa-fb16-4fbe-9e56-2e1537eefcea',
  'scan_blood_tests': 'e7d58d39-6f6e-454a-a195-e82dfa5a6f79',
  'scan_dating_scan': '967fef0f-50f9-4409-8373-f8a0b8849027',
  'scan_doppler': '4084d766-5e2e-4d7d-a21c-e6fb07637968',
  'scan_growth_scan': 'a4614b33-8f42-452b-9714-840376f5c92f',
  'scan_nipt': '029d8b5c-0500-49f2-86ba-0052ceddbe5a',
  'scan_nt_scan': '0431bd03-8fce-44f8-ac2a-230088a318da',
  'scan_ogtt': '7e215a27-2711-4f99-85dd-dd65177792b9',
  'nut_curd': 'ac661033-2077-40d2-aabc-b3d84a43e923',
  'nut_orange': '9d9a78eb-5337-48b9-9d69-b91f17bed226',
  'nut_r_vegetable_poha': 'f6cd04a9-bc36-4f5d-8627-297fa40b5dec',
  'nut_r_vegetable_upma': '8b89caf2-88d2-462e-96da-b126d276eac5',
  'nut_r_peanut_jaggery_chikki': '8a751b3c-0bf1-49bb-8713-385285cecf90',
  'nut_r_jaggery_kheer': '63e8c09c-90f7-46fa-a029-aa3b5801b0d5',
  'nut_r_ginger_lemon_tea': '189e1f65-29ea-4148-b437-3a26991ce18e',
  'nut_r_badam_milk': '666b8268-e4dd-4276-a35b-7377b2a7b763',
  'nut_r_moong_dal_soup': '9d6a71fe-2687-477e-a06d-b5c6cee3f163',
  'nut_r_tomato_carrot_soup': '93b20b43-7f23-4f3c-aeba-819e85b47a66',
  'nut_r_egg_curry': 'f47eecc9-df62-48fe-ab4b-0a4cdcbe323c',
  'nut_r_dal_palak': 'b59dd853-0f80-4f15-a532-f4c2c4e396f1',
  'ttc_tile_your_best_days_this_month': '58bb06b5-39e6-495a-8b8d-19197354f028',
  'ttc_tile_which_days_can_you_get_pregnant': '8e04d180-a59d-4ad9-8e9c-e28ec05436e6',
  'ttc_read_ovulation_tests_irregular': 'c0f443d2-b7c5-436a-afb8-b674f3148186',
  'ttc_read_morning_temperature': '002abe42-35a8-4c24-a10b-9e15a2fb9357',
  'ttc_read_timing_myths': '667e30e4-6586-4219-90ab-781e79a8c836',
  'ttc_tile_do_positions_matter': '1ce9f84d-a670-40cb-be37-ec0600f435ad',
  'ttc_tile_should_you_lie_down_after': 'ec36e194-3b62-43da-996e-d06206dd2160',
  'ttc_tile_do_you_need_to_orgasm': '2993f204-e988-46b5-b5d0-4c3fb550b538',
  'ttc_tile_six_myths_about_timing_one_by_one': '4467a0d6-c0d7-4fa1-ad7d-2dbfa4feda55',
  'ttc_tile_why_just_relax_is_the_wrong_advice': 'efa46762-aaee-4226-9f8a-141c491d5e98',
  'ttc_tile_your_cycle_drawn_out_step_by_step': '13e15975-b656-4287-9b3f-036ec47a409b',
  'ttc_read_early_signs': 'b459a3f4-5a46-4ba1-970c-1c48394874f6',
  'ttc_read_implantation_bleeding': '20036644-8c36-4a18-978c-749f258935ad',
  'ttc_tile_should_i_test': 'aa8ea888-ea80-4cd6-9b6c-a88cec7f0ae5',
  'ttc_read_when_to_test': '6e9198b0-517a-4c39-a0b9-0a8b3806126a',
  'ttc_read_late_negative': '8911fc2e-4d02-4fe4-8612-beb699f4eeb4',
  'ttc_read_feeling_pregnant': 'b0133742-f256-4d2d-98f4-630f5abdc259',
  'ttc_read_sex_homework': 'a9caf667-e353-4d7f-bdfc-f71886dc030c',
  'ttc_read_low_desire': 'ba60ce91-031c-4528-987e-78e01316e9bc',
  'ttc_read_keeping_close': '7d7ae375-7962-42e8-a272-e023ee4519ea',
  'ttc_read_pain_vaginismus': '8ce32f08-f097-4342-a2a6-8f379825d657',
  'ttc_read_lubricants': 'f5de2671-5929-49fb-a7fa-2fcdf1023d0e',
  'ttc_read_sex_after_window': 'd3015af2-1253-422b-bbb6-7526cae51496',
  'ttc_tile_how_sperm_are_made': '1755a863-5905-4205-8230-6b5e5a8c6e49',
  'ttc_tile_three_things_that_really_change_his_numbers': 'c8b3a7fd-b989-4925-ae52-531643803041',
  'ttc_read_heat_habits': 'ec474e45-2bd7-4209-b3ac-f17e36488840',
  'ttc_tile_3_things_for_you': '4402f19c-ea62-4378-8083-76f0f5c1e77b',
  'ttc_read_what_to_cut': '715ba181-10c4-47a4-bd01-d4d986451006',
  'ttc_read_weight_kindly': 'a76cd716-e2c8-4e68-bfb0-2d7e1664f177',
  'ttc_read_how_long_it_takes': 'f1e59205-176c-45f8-9fef-4c92164f7ce5',
  'ttc_tile_signs_not_to_wait': 'bb1b833b-127e-4c9f-ac29-e3aca8b77c50',
  'ttc_tile_talk_to_a_doctor': '029d8b5c-0500-49f2-86ba-0052ceddbe5a',  'ttc_tile_pcos_explained_in_five_minutes': '6ec1ddb3-d77f-46a0-982c-205f40cb5be8',
  'ttc_read_pcos_irregular': '0fd12f2a-5497-4577-ba8f-e8b0a5d32407',
  'ttc_tile_how_common_is_pcos': '451656ca-6363-44d9-82f9-89bbe4e50e8a',
  'ttc_tile_pcos_or_ovarian_cysts': '1add87ee-e542-4055-86fb-02104b4a923d',
  'ttc_read_pcos_weight': '9623beb0-382a-4141-96e7-965431ae4c9a',
  'ttc_tile_sleep_movement_and_insulin': '36b5ca5d-49b7-4656-b73d-9cb33bfad493',
  'ttc_tile_gentle_movement_for_pcos': 'ee443ce4-ac25-4b9d-9b27-f1292f2a266e',
  'ttc_tile_cycles_without_ovulation': '1ec3ce94-14b4-4192-814f-113e890982a1',
  'ttc_read_pcos_timelines': 'b85b3dba-7942-42f8-b30e-92f68ac4de66',
  'ttc_read_pcos_treatment': '053c96d9-f115-43f2-b3a9-fdf48ed5c8ae',
  'ttc_tile_log_your_symptoms': '6d55483a-ac31-4291-bf17-5e4d52b6e34c',
  'ttc_tile_what_your_cycle_shows': '664632ba-ba46-473c-b9d4-be9a54d94fcd',
  'ttc_tile_when_to_see_a_specialist': '1905415b-85ab-4c26-b4a2-686aea8b84b7',
  'ttc_tile_the_pcos_programme': '0fda2134-4308-4a47-9c4e-1fe444829255',
  'ttc_tile_should_i_seek_fertility_help': 'd7ce78ab-a518-41da-9903-636ee5b332b5',
  'ttc_tile_an_ivf_cycle_start_to_finish': 'f6a7c409-16af-45a8-bd81-675a194787d0',
  'ttc_read_ivf_explained': '1b756ad3-4bfc-4ea1-89f7-ba46c389d80a',
  'ttc_tile_iui_or_ivf_and_when_to_move_from_one_to_the_other': '2f1351c8-892d-488f-951c-2abe4aec86c1',
  'ttc_read_clinic_glossary': '130ea816-f58e-49db-9251-7dd9fd8454c6',
  'ttc_read_donor_eggs_sperm': 'b8204e67-cc7d-411c-bc52-3eaec515a142',
  'ttc_read_surrogacy_india': 'deb7b5c9-590d-41e2-9b6c-7c7196d45f7d',
  'ttc_read_age_after_35': 'bc3405db-a046-4206-852a-284040c6fcc4',
  'ttc_read_age_after_40': 'c5b30ec2-8951-4e1f-9fab-da2a073f8566',
  'ttc_read_second_baby': '22eb0691-ff70-4d92-812a-42f195ceeb51',
  'ttc_read_ivf_success_rates': '0e900b09-e596-46ea-99ec-e197783781cf',
  'ttc_read_ivf_ohss': '92207ae5-1bf6-41d7-bf86-9886a711535d',
  'ttc_read_tx_trigger_shot': '3d9aa8ee-b37d-4c54-a2ad-e04473d9bf46',
  'ttc_read_tx_fresh_or_frozen': 'ba8cceb3-64ca-4c40-97dd-7006e101ee87',
  'ttc_read_tx_frozen_transfer': 'e393776a-9f6a-4306-8046-37d8b5e741c4',
  'ttc_read_tx_transfer_day': 'd1eb442c-37dc-41b5-81e8-7e183450eacd',
  'ttc_read_tx_wait_after_treatment': 'fe79f01a-b13a-42f1-82f7-ae2aa65ae29f',
  'ttc_tile_getting_through_the_two_week_wait': 'd1483b12-215f-49bb-b3cc-0e85178dc23b',
  'ttc_read_tx_negative_after_treatment': '7a750519-ade9-4d47-8ce5-84ec82f3eae1',
  'ttc_read_ivf_retrieval': '5bfa8e78-8c79-4859-93a4-c9e2882bdc8c',
  'ttc_tile_does_bed_rest_after_transfer_help': '5e1ac595-11df-4e66-829c-e3a309fb3621',
  'ttc_read_ivf_working': 'bb5e9f36-ef13-4cf8-87bd-1feca44ec68c',
  'ttc_tile_track_this_treatment_cycle': '89a7263a-ae30-4970-993d-7a9fd5bcf998',
  'ttc_tile_plan_your_own_week': 'cb6a84a8-8878-44da-85d1-e6303295671f',
  'ttc_read_ask_dietitian': 'b8f86641-0944-4478-83e3-dcbb278cf925',
  'ttc_read_preconception_tests': 'c56ed723-5221-435c-87f4-8facada16e06',
  'ttc_tile_check_your_vaccinations': 'e069bf08-07a3-4330-bd99-d939d419ce14',
  'ttc_tile_habits_worth_building_now': '1767fab5-2a9b-4a8a-9658-702397ee8d03',
  'ttc_tile_track_what_you_re_working_on': '3f16069a-5dce-4b63-8348-5233bcb67c1a',
  'ttc_read_coming_off_birth_control': '787c44e7-94bb-417b-8346-e02d709e948d',
  'ttc_read_whose_side': '399afaf2-4780-46df-8e74-82ade3f585de',
  'ttc_read_first_gyn_visit': '23b62d71-a070-408f-8a9b-5d3aa94d440a',
  'ttc_read_after_abortion': '63c4376d-7222-4b99-a96f-aea259c9134d',
  'ttc_tile_your_pre_pregnancy_checklist': '3ed07a55-8c9d-4cde-a6af-12716edfd015',
  'ttc_tile_talk_to_someone_before_you_start': 'e523e59c-781b-4c14-8100-6043c7c24826',
  'ttc_tile_talk_to_a_nutritionist': '0f0a76a1-1d24-41ef-b9b3-955da96e24eb',
  'ttc_read_his_age': 'b95bee5b-f1ab-45b2-95c8-7b879e6712e7',
  'ttc_tile_read_your_semen_report': 'abd72f53-2d87-4bac-a3e9-a72d070588d2',
  'ttc_tile_have_the_report_read_properly': 'b3be6880-561e-4926-bc94-de401f44d115',
  'ttc_read_report_words': '39c6bb74-dbb6-4415-9345-c9be3fa9e686',
  'ttc_read_result_normal': '57485e01-52da-457f-9eb3-9561be669f0c',
  'ttc_read_result_abnormal': 'c2ad67e6-7ec5-4598-8ca2-b05b493a82bc',
  'ttc_read_azoospermia': '31956d43-402f-461a-a07a-964e8b7594a9',
  'ttc_read_three_months': '977e7537-8280-4ba1-895b-75aa8a157ce3',
  'ttc_read_zinc_coq10': '3aaa11e3-edf2-4c7b-80c1-af17a313c55d',
  'ttc_tile_zinc': 'd0e8a556-e61e-46fd-9f00-788307b68738',
  'ttc_tile_coq10': 'cd977f38-8de4-4291-ab9f-1d73205d2859',
  'ttc_tile_the_half_nobody_talks_about': '79f0ee78-b1c8-4d3c-9512-f0adcf965c9f',
  'ttc_tile_what_he_can_track': '94537cac-5105-451e-b762-2268679ff847',
  'ttc_read_his_side_pressure': 'd650b0f3-7a23-433d-ab26-bb3c179d7784',
  'ttc_read_bringing_him_in': 'a2d65d81-2c17-4e0e-b01c-ddd1db65ddf8',
  'ttc_read_loss_recovery': 'e4250807-e3fa-49f3-bb0f-fc4ca1cb3164',
  'ttc_tile_what_the_next_few_weeks_look_like': 'e9855f3c-80b8-4cc9-9aaa-da4ad6321e0d',
  'ttc_tile_what_normal_bleeding_and_spotting_looks_like': '23774a1e-29f5-44b2-9a9e-cf100cd86b02',
  'ttc_tile_rh_status_and_retained_tissue': '4b2d7ca1-caf3-4678-b058-b580e46de518',
  'ttc_tile_can_you_ovulate_before_your_first_period': 'ae9f7562-caec-4f0e-91f0-af2bc39ff9bc',
  'ttc_read_trying_again': '8f3ffafe-eae9-42b8-951a-e6d73b668b1a',
  'ttc_read_miscarriage_causes': '05c6354c-2148-4bd1-89c4-27e47db8dc31',
  'ttc_tile_when_to_ask_for_tests': 'a1bc0d5e-e9a7-483c-a45d-3f7660609adf',
  'ttc_read_recurrent_miscarriage': '233e2a02-f678-48ea-ac8f-b0cb89d04ad6',
  'ttc_tile_does_one_miscarriage_mean_another': '24efb5b5-448a-49dc-8836-2d5b30951a15',
  'ttc_read_chemical_pregnancy': 'c0cfe96f-df8d-44c6-9593-9229270df731',
  'ttc_tile_do_you_have_to_wait_six_months': '2423b5ea-665d-45d4-9b2e-aeed4eabab6a',
  'ttc_tile_what_to_do_differently_next_time': '4764ce10-c68b-445f-8721-6a7088ee1cd5',
  'ttc_tile_someone_who_knows_this_kind_of_loss': 'c34debbe-5bf2-4d9e-861f-f0a4dfebed5d',
  'ttc_tile_after_a_loss_four_sessions': 'b7324adc-869c-49ee-acaf-c909e1265fbc',
  'ttc_tile_talk_it_through': '3c06b4e4-0516-4d07-9ecb-5aae7085481a',
  'ttc_read_period_came': '1f384bfb-b95e-467b-9d42-8ad7c1df2f10',
  'ttc_read_telling_family': '1afd12a3-c325-4076-b153-685cde42faac',
  'ttc_read_good_news_answers': 'a5ff71fd-4812-4d3f-a79a-90b8f5bd1e74',
  'ttc_read_month_after_month': '283324ef-7504-4581-b60a-61dbfac01399',
  'ttc_tile_will_it_happen_if_you_stop_thinking_about_it': '89d654b2-9610-4ac2-9a6d-cd3db705446d',
  'ttc_tile_where_stress_does_have_a_real_effect': 'd2117e64-a588-4e85-86d7-4941d2295743',
  'ttc_tile_loosen_up_neck_shoulders_side_bends': '847a6b3c-bbad-4003-9e66-b4ab85d91721',
  'ttc_tile_hip_openers_butterfly_and_slow_lunge': '6436c1c9-bfb9-42c7-83c7-d1f64b174b4e',
  'ttc_tile_a_ten_minute_walk': '3306b512-fb02-4588-a35a-21e7e39a62df',
  'ttc_tile_slow_sun_salutation_three_rounds': '1e52fe18-c1a5-4814-bc18-ed9cfb7b52e9',
  'ttc_tile_breathe_in_for_4_out_for_6': 'a2296d6c-8c53-4d09-b6e5-005bd8ed34e4',
  'ttc_tile_alternate_nostril_breathing': '54a57105-56f2-4224-9bef-7561fd09868a',
  'ttc_tile_box_breathing': '7c791596-a49d-4c9b-b4bb-c40f5f8a6e4c',
  'ttc_tile_two_minute_body_relaxation': '75882951-79a9-4b24-97df-10198fab7031',
  'ttc_tile_ten_slow_breaths_together': 'a726ce7b-9de4-46e5-917c-ee06e5ffa134',
  'ttc_tile_a_longer_session_this_week': '5542c15d-ffb8-48e5-8d71-34ee51b1bb1e',
  'ttc_read_sleep_trying': '2eeeb60c-253d-475f-812b-d72a852fc266',
  'ttc_read_bedtime': 'c67a2633-4f4e-462d-8216-9cbae40ce2c4',
  'ttc_tile_a_calming_breath_for_bedtime': '2e0de908-0431-40a1-b0fb-d0fa616f4ade',
  'ttc_read_relationship_safety': '08815549-8f45-4ba3-9cf5-26345f6a6151',
  'ttc_tile_symptoms_and_mood': 'f368a34d-5149-4c8d-8fd7-d59f6adc13de',
  'ttc_read_normal_cycle': '15c29763-6088-432a-8246-9475f1672eb2',
  'ttc_read_irregular_not_pcos': '59edc939-b6bf-4420-90ba-217269227b4b',
  'ttc_read_bleeding_kinds': 'c2cdacef-2585-44ef-9bda-d2c1612d7c27',
  'ttc_read_ovulation_pain': '9c679d59-eeed-4c3a-8c9e-7e7cc426ddcd',
  'ttc_read_discharge_guide': '5de1d354-9c9f-427a-b636-1a6f94bce9e5',
  'ttc_read_intimate_washing': '17b91b65-7ad9-46d7-bbe8-a87e36b8222f',
  'ttc_read_intimate_worries': '62852637-6c75-4646-8ac1-d2ca2d0a24a0',
  'ttc_read_yeast_bv': 'd13d0284-42bc-4af8-a936-c95e7cd61009',
  'ttc_read_uti_trying': 'cada1708-32ed-454a-8900-f54709b1823f',
  'ttc_read_slow_conception': '8fcff628-35df-4714-84eb-4af4d8f82572',
  'ttc_tile_trying_for_many_months': '269674b0-ea4b-4022-9c33-6b6f1a2ba4c6',
  'ttc_tile_is_it_time_to_see_someone': '1eb1f9b1-37ad-4cca-830a-328ca5de88b7',
};
