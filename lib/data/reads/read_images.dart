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
      'https://cdn.stocksnap.io/img-thumbs/960w/97LJAKWL36.jpg',
  'cani_ginger':
      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Ginger_Plant_vs.jpg',
  'cani_coffee':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/960px-A_small_cup_of_coffee.JPG',
  'cani_tea':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/25/Mix_Masala_Tea.jpg/960px-Mix_Masala_Tea.jpg',
  'cani_green_tea':
      'https://cdn.stocksnap.io/img-thumbs/960w/04E3HNGAKH.jpg',
  'cani_coconut_water':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Tender_coconut_water_02.jpg/960px-Tender_coconut_water_02.jpg',
  'cani_buttermilk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Plain_Lassi_in_a_glass.jpg/960px-Plain_Lassi_in_a_glass.jpg',
  'cani_alcohol':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4e/Schwappender_Wein.jpg/960px-Schwappender_Wein.jpg',
  'cani_soft_drinks':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Glass_cola.jpg/960px-Glass_cola.jpg',
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
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/dc/Dyeing_hair_purple.png/960px-Dyeing_hair_purple.png',
  'cani_waxing':
      'https://cdn.stocksnap.io/img-thumbs/960w/CUGFVFAI24.jpg',
  'cani_nail_polish':
      'https://cdn.stocksnap.io/img-thumbs/960w/S6RLOBPAOZ.jpg',
  'cani_sex':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'cani_sleeping_back':
      'https://cdn.stocksnap.io/img-thumbs/960w/46BMYP2BDJ.jpg',
  'cani_mosquito_repellent':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/05/Portable_Mosquito_Coil_Holder_-_Lion_Chemical.jpg/960px-Portable_Mosquito_Coil_Holder_-_Lion_Chemical.jpg',
  'cani_dental':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/76/Dentist-gd569d444b_1920.jpg/960px-Dentist-gd569d444b_1920.jpg',
  'cani_xray':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1c/Tube_%C3%A0_Rayon_X_dans_un_h%C3%B4pital_au_B%C3%A9nin_05.jpg/960px-Tube_%C3%A0_Rayon_X_dans_un_h%C3%B4pital_au_B%C3%A9nin_05.jpg',
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
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/09/Muskmelon_in_summer.jpg/960px-Muskmelon_in_summer.jpg',
  'cani_guava':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Goiaba_vermelha.jpg/960px-Goiaba_vermelha.jpg',
  'cani_pomegranate':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Pomegranate_arils.jpg/960px-Pomegranate_arils.jpg',
  'cani_chikoo':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b2/Chiku_fruit.jpg/960px-Chiku_fruit.jpg',
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
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Four_pears.jpg/960px-Four_pears.jpg',
  'cani_dry_fruits':
      'https://cdn.stocksnap.io/img-thumbs/960w/4EXMQZWRDQ.jpg',
  'cani_almonds':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Liat_Portal_for_Foodie_Disorder_-_Raw_almonds_in_a_bowl.jpg/960px-Liat_Portal_for_Foodie_Disorder_-_Raw_almonds_in_a_bowl.jpg',
  'cani_walnuts':
      'https://cdn.stocksnap.io/img-thumbs/960w/KQK5TLH6E1.jpg',
  'cani_cashews':
      'https://cdn.stocksnap.io/img-thumbs/960w/HWP9X99UM3.jpg',
  'cani_peanuts':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Roasted_Peanuts_with_shell.jpg/960px-Roasted_Peanuts_with_shell.jpg',
  'cani_sabudana':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Sabudana_Khichdi_with_Sweet_curd.JPG/960px-Sabudana_Khichdi_with_Sweet_curd.JPG',
  'cani_spinach':
      'https://upload.wikimedia.org/wikipedia/commons/f/fc/A_pot_of_cut_spinach_leaves_with_carrots_and_onions.jpg',
  'cani_drumstick':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Moringa_oleifera_drumstick_pods.JPG/960px-Moringa_oleifera_drumstick_pods.JPG',
  'cani_brinjal':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Solanum_melongena_24_08_2012_%281%29.JPG/960px-Solanum_melongena_24_08_2012_%281%29.JPG',
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
      'https://cdn.stocksnap.io/img-thumbs/960w/Z0133GNPXT.jpg',
  'cani_mushroom':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/2016-01_Agaricus_bisporus_07.jpg/960px-2016-01_Agaricus_bisporus_07.jpg',
  'cani_egg':
      'https://cdn.stocksnap.io/img-thumbs/960w/M9KEI36GNT.jpg',
  'cani_chicken':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Chicken_Curry_9.jpg/960px-Chicken_Curry_9.jpg',
  'cani_mutton':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fe/Odia_Mutton_Curry_%28Mansha_Tarkari%29.jpg/960px-Odia_Mutton_Curry_%28Mansha_Tarkari%29.jpg',
  'cani_fish':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Meen_curry_2.JPG/960px-Meen_curry_2.JPG',
  'cani_prawns':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/82/Cafe_La_Haye_-_2019_August_-_Sarah_Stierch_03.jpg/960px-Cafe_La_Haye_-_2019_August_-_Sarah_Stierch_03.jpg',
  'cani_high_mercury_fish':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Xiphias_gladius_stuffed.jpg/960px-Xiphias_gladius_stuffed.jpg',
  'cani_dal':
      'https://cdn.stocksnap.io/img-thumbs/960w/WOZ7PQGMMI.jpg',
  'cani_soya':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Rotini_with_vegetable_tikka_masala%2C_textured_vegetable_protein%2C_peanuts%2C_and_black_pepper_-_Massachusetts.jpg/960px-Rotini_with_vegetable_tikka_masala%2C_textured_vegetable_protein%2C_peanuts%2C_and_black_pepper_-_Massachusetts.jpg',
  'cani_rajma_chana':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/12/Rajma_Chawal_by_Rama_Bhave.jpg/960px-Rajma_Chawal_by_Rama_Bhave.jpg',
  'cani_cheese':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/de/Le_Chat_Apt_Salade_de_tomate%2C_ch%C3%A8vre_et_basilic.jpg/960px-Le_Chat_Apt_Salade_de_tomate%2C_ch%C3%A8vre_et_basilic.jpg',
  'cani_ghee':
      'https://cdn.stocksnap.io/img-thumbs/960w/NS5Q6MVMZQ.jpg',
  'cani_mawa_sweets':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ec/Kaju_katli_dessert_-_side_view.jpg/960px-Kaju_katli_dessert_-_side_view.jpg',
  'cani_oats':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Rolled_oats_in_bowl_2.jpg/960px-Rolled_oats_in_bowl_2.jpg',
  'cani_poha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Indian_breakfast-_Poha.jpg/960px-Indian_breakfast-_Poha.jpg',
  'cani_instant_noodles':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Lobster_instant_noodle.jpg/960px-Lobster_instant_noodle.jpg',
  'cani_fried_snacks':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/2013_Sechsel%C3%A4uten_-_%27Samosa%27_und_%27Pakora%27_-_Limmatquai_2013-04-14_17-35-59_%28P7700%29.JPG/960px-2013_Sechsel%C3%A4uten_-_%27Samosa%27_und_%27Pakora%27_-_Limmatquai_2013-04-14_17-35-59_%28P7700%29.JPG',
  'cani_pickle':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/69/Iskus_Ko_Achar.jpg/960px-Iskus_Ko_Achar.jpg',
  'cani_turmeric_milk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Golden_Milk.jpg/960px-Golden_Milk.jpg',
  'cani_jaggery':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/Jaggery_cubes.jpg/960px-Jaggery_cubes.jpg',
  'cani_spices':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Indian_Spices_%2849696133942%29.jpg/960px-Indian_Spices_%2849696133942%29.jpg',
  'cani_sugar':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/W%C3%BCrfelzucker_--_2018_--_3564.jpg/960px-W%C3%BCrfelzucker_--_2018_--_3564.jpg',
  'cani_sushi':
      'https://cdn.stocksnap.io/img-thumbs/960w/BBD3AU9NSR.jpg',
  'cani_raw_meat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Steak_Tartare_in_Dresden.jpg/960px-Steak_Tartare_in_Dresden.jpg',
  'cani_deli_meat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Cold_cuts.jpg/960px-Cold_cuts.jpg',
  'cani_leftovers':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Open_refrigerator_with_food_at_night.jpg/960px-Open_refrigerator_with_food_at_night.jpg',
  'cani_spicy_food':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9a/%D0%A2%D0%B0%D0%B2%D1%87%D0%B5_%D0%93%D1%80%D0%B0%D0%B2%D1%87%D0%B5.jpg/960px-%D0%A2%D0%B0%D0%B2%D1%87%D0%B5_%D0%93%D1%80%D0%B0%D0%B2%D1%87%D0%B5.jpg',
  'cani_milkshake':
      'https://cdn.stocksnap.io/img-thumbs/960w/BNCZWVYVMQ.jpg',
  'cani_fresh_juice':
      'https://cdn.stocksnap.io/img-thumbs/960w/VWZSB0VCZ8.jpg',
  'cani_lemon_water':
      'https://cdn.stocksnap.io/img-thumbs/960w/SE6LA5BXBG.jpg',
  'cani_sugarcane_juice':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/44/Sugarcane_Juice_in_Ogan_Ilir.jpg/960px-Sugarcane_Juice_in_Ogan_Ilir.jpg',
  'cani_lassi':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Lassi_1.jpg/960px-Lassi_1.jpg',
  'cani_energy_drinks':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Energy_Drink_Battery_Cans.jpg/960px-Energy_Drink_Battery_Cans.jpg',
  'cani_herbal_tea':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/Infusi%C3%B3_de_Tim%C3%B3.jpg/960px-Infusi%C3%B3_de_Tim%C3%B3.jpg',
  'cani_smoothie':
      'https://cdn.stocksnap.io/img-thumbs/960w/HWFUPZEHMO.jpg',
  'cani_kombucha':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Wild_Kombucha_logo.jpg/500px-Wild_Kombucha_logo.jpg',
  'cani_diet_soda':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Can_of_Diet_Sierra_Mist_lemon-lime_soda%2C_2011.jpg/960px-Can_of_Diet_Sierra_Mist_lemon-lime_soda%2C_2011.jpg',
  'cani_aam_panna':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/35/%C4%80m_pann%C4%81_at_Kitchen_of_Awadh%2C_DLF_Phase_4%2C_Gurgaon_%282025-09-28%29.jpg/960px-%C4%80m_pann%C4%81_at_Kitchen_of_Awadh%2C_DLF_Phase_4%2C_Gurgaon_%282025-09-28%29.jpg',
  'cani_badam_milk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Bapatla_Badam_Milk.jpg/960px-Bapatla_Badam_Milk.jpg',
  'cani_decaf_coffee':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/cf/Decaf_latte_-_Trading_Post_Coffee_Roasters_2025-03-09.jpg/960px-Decaf_latte_-_Trading_Post_Coffee_Roasters_2025-03-09.jpg',
  'cani_jaljeera':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Two_Indian_Drinks.jpg/960px-Two_Indian_Drinks.jpg',
  'cani_ors':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Ors_sachet.jpg/960px-Ors_sachet.jpg',
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
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/94/Cod_Liver_Oil_Capsules.jpg/960px-Cod_Liver_Oil_Capsules.jpg',
  'cani_b12':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Mecobalamin_tablets.jpg/960px-Mecobalamin_tablets.jpg',
  'cani_ondansetron':
      'https://upload.wikimedia.org/wikipedia/commons/5/5c/000817lg_Zofran_8_MG_Oral_Tablet.jpg',
  'cani_doxylamine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Prenatal_vitamin_tablets.jpg/960px-Prenatal_vitamin_tablets.jpg',
  'cani_cough_syrup':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Vintage_Turkish_pediatric_cough_syrup_bottle.png/960px-Vintage_Turkish_pediatric_cough_syrup_bottle.png',
  'cani_lozenges':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/Hustenbonbons_01.jpg/960px-Hustenbonbons_01.jpg',
  'cani_vicks_balm':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Vicks_VapoRub_%2851013600352%29_%28cropped%29.jpg/960px-Vicks_VapoRub_%2851013600352%29_%28cropped%29.jpg',
  'cani_isabgol':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/16/Culinary_psyllium%2C_Russian_market_13.jpg/960px-Culinary_psyllium%2C_Russian_market_13.jpg',
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
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e8/Incense_stick.JPG/960px-Incense_stick.JPG',
  'cani_cleaning_chemicals':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/74/2022-07-08_Albert_%C5%A0estka_interi%C3%A9r_drogerie.jpg/960px-2022-07-08_Albert_%C5%A0estka_interi%C3%A9r_drogerie.jpg',
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
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ef/%D0%A1%D0%9F%D0%90_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D0%B4%D1%83%D1%80%D1%8B_%D0%B2_%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B9_%D0%9F%D0%BE%D0%BB%D1%8F%D0%BD%D0%B5.jpg/960px-%D0%A1%D0%9F%D0%90_%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D0%B4%D1%83%D1%80%D1%8B_%D0%B2_%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%BE%D0%B9_%D0%9F%D0%BE%D0%BB%D1%8F%D0%BD%D0%B5.jpg',
  'cani_meditation':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d2/Sinemorec_-_Butamiata_beach_%28by_Pudelek%29.JPG/960px-Sinemorec_-_Butamiata_beach_%28by_Pudelek%29.JPG',
  'cani_mobile_phone':
      'https://cdn.stocksnap.io/img-thumbs/960w/DLITZEAVJJ.jpg',
  'cani_stress':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Stressed_and_depressed_woman_covers_her_face_with_hands.jpg/960px-Stressed_and_depressed_woman_covers_her_face_with_hands.jpg',
  'cani_paneer':
      'https://upload.wikimedia.org/wikipedia/commons/a/a5/Malai_Paneer_Tikka%2C_PK_007.jpg',
  'cani_milk':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Milk_bottle_and_two_doughnuts.jpg/960px-Milk_bottle_and_two_doughnuts.jpg',
  'cani_saffron':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1c/Saffron_threads_in_a_glass_jar_%28_Viora_Saffron_packaging%29.jpg/960px-Saffron_threads_in_a_glass_jar_%28_Viora_Saffron_packaging%29.jpg',
  'cani_makhana':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0e/Foxnut_Makhana_-_Nawada_District_-_Bihar_-_1.jpg/960px-Foxnut_Makhana_-_Nawada_District_-_Bihar_-_1.jpg',
  'cani_salt':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Seasalt.jpg/960px-Seasalt.jpg',
  'cani_maida':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/All-Purpose_Flour_%284107895947%29.jpg/960px-All-Purpose_Flour_%284107895947%29.jpg',
  'cani_custard_apple':
      'https://upload.wikimedia.org/wikipedia/commons/3/3d/Atemola_%28cross_of_Annona_cherimola_and_Annona_squamosa%29.jpg',
  'cani_sleeping_pills':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Lorafen_%28lorazepamum%29_tablets%2C_1_mg.jpg/960px-Lorafen_%28lorazepamum%29_tablets%2C_1_mg.jpg',
  'cani_ayurvedic_medicine':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Ayurvedic_herbs_02.jpg/960px-Ayurvedic_herbs_02.jpg',
  'cani_packaged_juice':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/20240814Satona_Kartonger.jpg/960px-20240814Satona_Kartonger.jpg',
  'cani_vitamin_c':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/54/Fruit_plate_with_fresh_fruits.jpg/960px-Fruit_plate_with_fresh_fruits.jpg',
  'cani_shelf_eat':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Golgappa_Pani_Puri_India.jpg/960px-Golgappa_Pani_Puri_India.jpg',
  'cani_shelf_drink':
      'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/25/Mix_Masala_Tea.jpg/960px-Mix_Masala_Tea.jpg',
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
};

/// Read id → licence · source · creator, for the credit line.
const Map<String, String> kReadImageCredits = {
  'cani_papaya': 'CC BY 3.0 · Wikimedia Commons · Marek Ślusarczyk (Tupungato) Photo portf',
  'cani_pineapple': 'CC BY-SA 3.0 · Wikimedia Commons · MANOJTV at English Wikipedia',
  'cani_mango': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_banana': 'CC0 · Wikimedia Commons · Wilfredor',
  'cani_curd': 'CC BY-SA 4.0 · Wikimedia Commons · Shruthi Gaurav Alva',
  'cani_chocolate': 'CC0 · Wikimedia Commons · Mx. Granger',
  'cani_street_food': 'CC BY 2.0 · Wikimedia Commons · Yusuke Kawasaki',
  'cani_honey': 'CC0 · StockSnap · Krzysztof%20Puszczy%u0144ski',
  'cani_ginger': 'CC BY-SA 3.0 · Wikimedia Commons · Venkatx5',
  'cani_coffee': 'CC BY-SA 2.0 · Wikimedia Commons · Julius Schorzman',
  'cani_tea': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_green_tea': 'CC0 · StockSnap · Jorge Garcia',
  'cani_coconut_water': 'CC BY-SA 4.0 · Wikimedia Commons · Vis M',
  'cani_buttermilk': 'CC BY-SA 4.0 · Wikimedia Commons · Kyu3a',
  'cani_alcohol': 'CC BY 3.0 de · Wikimedia Commons · Stefan Krause, Germany',
  'cani_soft_drinks': 'Public domain · Wikimedia Commons · pic_p_ter',
  'cani_water': 'CC0 · StockSnap · Krzysztof%20Puszczy%u0144ski',
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
  'cani_pear': 'CC BY-SA 4.0 · Wikimedia Commons · Rhododendrites',
  'cani_dry_fruits': 'CC0 · StockSnap · Jonas Svidras',
  'cani_almonds': 'CC BY-SA 4.0 · Wikimedia Commons · HaJunkiyada',
  'cani_walnuts': 'CC0 · StockSnap · Krzysztof%20Puszczy%u0144ski',
  'cani_cashews': 'CC0 · StockSnap · Rachael Gorjestani',
  'cani_peanuts': 'CC BY-SA 4.0 · Wikimedia Commons · Sanjay Acharya',
  'cani_sabudana': 'CC BY-SA 4.0 · Wikimedia Commons · Dheerajk88',
  'cani_spinach': 'CC BY-SA 4.0 · Wikimedia Commons · Olgatladi2020',
  'cani_drumstick': 'CC BY-SA 4.0 · Wikimedia Commons · Erector',
  'cani_brinjal': 'CC BY-SA 3.0 · Wikimedia Commons · Joydeep',
  'cani_potato': 'CC0 · StockSnap · Maciej Szlachta',
  'cani_tomato': 'CC0 · StockSnap · Krzysztof%20Puszczy%u0144ski',
  'cani_carrot': 'CC0 · StockSnap · Suzy Hazelwood',
  'cani_beetroot': 'CC BY-SA 4.0 · Wikimedia Commons · W.carter',
  'cani_sprouts': 'CC BY-SA 4.0 · Wikimedia Commons · Ivar Leidus',
  'cani_raw_salad': 'CC0 · StockSnap · Jeffrey Betts',
  'cani_mushroom': 'CC BY-SA 4.0 · Wikimedia Commons · 0x010C',
  'cani_egg': 'CC0 · StockSnap · Patryk Dziejma',
  'cani_chicken': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_mutton': 'CC BY-SA 4.0 · Wikimedia Commons · Satwik Cuttack',
  'cani_fish': 'CC BY-SA 2.5 · Wikimedia Commons · Kalakki at Malayalam Wikipedia',
  'cani_prawns': 'CC BY 4.0 · Wikimedia Commons · Missvain',
  'cani_high_mercury_fish': 'CC BY-SA 3.0 · Wikimedia Commons · Citron',
  'cani_dal': 'CC0 · StockSnap · Foodie Girl',
  'cani_soya': 'CC0 · Wikimedia Commons · Daderot',
  'cani_rajma_chana': 'CC BY-SA 4.0 · Wikimedia Commons · Shreya151994',
  'cani_cheese': 'CC BY-SA 4.0 · Wikimedia Commons · Marianne Casamance',
  'cani_ghee': 'CC0 · StockSnap · Brooke Cagle',
  'cani_mawa_sweets': 'CC BY-SA 3.0 · Wikimedia Commons · Unknomics',
  'cani_oats': 'CC BY-SA 4.0 · Wikimedia Commons · Bodhi Peace',
  'cani_poha': 'CC BY-SA 4.0 · Wikimedia Commons · Medhi jyoti',
  'cani_instant_noodles': 'CC BY 2.0 · Wikimedia Commons · Ruocaled',
  'cani_fried_snacks': 'CC BY-SA 3.0 · Wikimedia Commons · Roland zh',
  'cani_pickle': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_turmeric_milk': 'CC BY-SA 4.0 · Wikimedia Commons · మురళీకృష్ణ ముసునూరి',
  'cani_jaggery': 'CC BY-SA 4.0 · Wikimedia Commons · Mangosapiens',
  'cani_spices': 'CC BY 2.0 · Wikimedia Commons · Ajay Suresh from New York, NY, USA',
  'cani_sugar': 'CC BY-SA 4.0 · Wikimedia Commons · Dietmar Rabich',
  'cani_sushi': 'CC0 · StockSnap · Chevanon',
  'cani_raw_meat': 'CC BY-SA 4.0 · Wikimedia Commons · Dr. Bernd Gross',
  'cani_deli_meat': 'CC BY-SA 4.0 · Wikimedia Commons · مانفی',
  'cani_leftovers': 'CC BY-SA 4.0 · Wikimedia Commons · W.carter',
  'cani_spicy_food': 'CC BY-SA 4.0 · Wikimedia Commons · Cuklev',
  'cani_milkshake': 'CC0 · StockSnap · Burst',
  'cani_fresh_juice': 'CC0 · StockSnap · WDnet Studio',
  'cani_lemon_water': 'CC0 · StockSnap · Healthy Living',
  'cani_sugarcane_juice': 'CC BY-SA 4.0 · Wikimedia Commons · Firzafp',
  'cani_lassi': 'CC BY-SA 4.0 · Wikimedia Commons · Gaurav Dhwaj Khadka',
  'cani_energy_drinks': 'CC BY-SA 3.0 · Wikimedia Commons · Klooni',
  'cani_herbal_tea': 'CC BY-SA 4.0 · Wikimedia Commons · Francesc Fort',
  'cani_smoothie': 'CC0 · StockSnap · Patryk Dziejma',
  'cani_kombucha': 'CC BY-SA 4.0 · Wikimedia Commons · Jmb195',
  'cani_diet_soda': 'CC0 · Wikimedia Commons · DimiTalen',
  'cani_aam_panna': 'CC BY-SA 4.0 · Wikimedia Commons · Contrapunctus-1',
  'cani_badam_milk': 'CC BY-SA 4.0 · Wikimedia Commons · Saiphani02',
  'cani_decaf_coffee': 'CC0 · Wikimedia Commons · Andy Li',
  'cani_jaljeera': 'CC BY-SA 2.0 · Wikimedia Commons · Nick Gray',
  'cani_ors': 'CC BY-SA 4.0 · Wikimedia Commons · Shubjt',
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
  'cani_pet_dogs': 'CC0 · StockSnap · Alex%20Bl%u0103jan',
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
  'cani_milk': 'CC0 · Wikimedia Commons · www.Pixel.la Free Stock Photos',
  'cani_saffron': 'CC0 · Wikimedia Commons · ulleo',
  'cani_makhana': 'CC BY-SA 4.0 · Wikimedia Commons · FacetsOfNonStickPans',
  'cani_salt': 'CC BY-SA 4.0 · Wikimedia Commons · Relativity',
  'cani_maida': 'CC BY-SA 2.0 · Wikimedia Commons · Veganbaking.net from USA',
  'cani_custard_apple': 'CC BY-SA 3.0 · Wikimedia Commons',
  'cani_sleeping_pills': 'CC BY 3.0 · Wikimedia Commons · Żółwiciel',
  'cani_ayurvedic_medicine': 'CC BY-SA 4.0 · Wikimedia Commons · Vis M',
  'cani_packaged_juice': 'CC BY-SA 4.0 · Wikimedia Commons · Kolbkorr',
  'cani_vitamin_c': 'CC BY-SA 4.0 · Wikimedia Commons · Marc-Lautenbacher',
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
};

/// The picture for a read: its own, else the table's, else none.
String? readImageFor(String readId, {String? own}) =>
    (own != null && own.isNotEmpty) ? own : kReadImageUrls[readId];
