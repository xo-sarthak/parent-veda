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
// Openverse with `source=stocksnap` (CC0, served clean at 960px); the ten
// Flickr `_b.jpg` files were fine and stay.
const Map<String, String> kReadImageUrls = {
  'preg_week_read_managing_nausea':
      'https://cdn.stocksnap.io/img-thumbs/960w/B6BMB1BLFT.jpg',
  'preg_week_read_first_scan':
      'https://cdn.stocksnap.io/img-thumbs/960w/MU4EHC71DU.jpg',
  'preg_week_read_first_trimester':
      'https://live.staticflickr.com/168/455643284_16fb61b0b2_b.jpg',
  'preg_week_read_nutrition_t2':
      'https://live.staticflickr.com/7274/7654718986_d184cc7fd1_b.jpg',
  'preg_week_read_partner_support':
      'https://cdn.stocksnap.io/img-thumbs/960w/0MLHM34HE1.jpg',
  'preg_week_read_halfway':
      'https://cdn.stocksnap.io/img-thumbs/960w/4UF03CU9M7.jpg',
  'preg_week_read_anomaly_scan':
      'https://live.staticflickr.com/7003/6721335809_fbaa640952_b.jpg',
  'preg_week_read_baby_sound':
      'https://cdn.stocksnap.io/img-thumbs/960w/HJ8M7LUVLT.jpg',
  'preg_week_read_talking_baby':
      'https://cdn.stocksnap.io/img-thumbs/960w/0RYWABOQID.jpg',
  'preg_week_read_back_pain':
      'https://live.staticflickr.com/5506/25354114919_295acda6b0_b.jpg',
  'preg_week_read_third_tri_prep':
      'https://cdn.stocksnap.io/img-thumbs/960w/SITUKGWGWJ.jpg',
  'preg_week_read_movement_awareness':
      'https://cdn.stocksnap.io/img-thumbs/960w/ZZLEPU3SIR.jpg',
  'preg_week_read_hospital_bag':
      'https://live.staticflickr.com/2164/2284764037_df5b9bf8cf_b.jpg',
  'preg_week_read_labour_prep':
      'https://live.staticflickr.com/2028/32027398583_b6bb331ab2_b.jpg',
  'preg_week_read_first_24h':
      'https://live.staticflickr.com/2731/4434436315_da2cd858cc_b.jpg',
  'preg_week_read_exp_priya':
      'https://cdn.stocksnap.io/img-thumbs/960w/0B4LRPC8QF.jpg',
  'preg_week_read_exp_meera':
      'https://cdn.stocksnap.io/img-thumbs/960w/6ENSM2NM1P.jpg',
  'preg_week_read_res_voices':
      'https://live.staticflickr.com/158/423505105_d77db0ba17_b.jpg',
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
      'https://live.staticflickr.com/5095/5478130842_48de60e3bb_b.jpg',
  'preg_cond_read_thyroid_tablet':
      'https://cdn.stocksnap.io/img-thumbs/960w/LKM1T38B6S.jpg',
  'preg_cond_read_iron':
      'https://live.staticflickr.com/4043/4264803251_44d8827693_b.jpg',
  'preg_diet_read_add_now':
      'https://cdn.stocksnap.io/img-thumbs/960w/KRX6BEOKGM.jpg',
  'preg_labour_read_pain_relief':
      'https://cdn.stocksnap.io/img-thumbs/960w/4GGMTEBZY9.jpg',
};

/// Read id → licence · source · creator, for the credit line.
const Map<String, String> kReadImageCredits = {
  'preg_week_read_managing_nausea': 'CC0 · stocksnap · Josh Willink',
  'preg_week_read_first_scan': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_first_trimester': 'CC BY-SA · flickr · viralbus',
  'preg_week_read_nutrition_t2': 'CC BY · flickr · shankar s.',
  'preg_week_read_partner_support': 'CC0 · stocksnap · William Stitt',
  'preg_week_read_halfway': 'CC0 · stocksnap · Freestocks.org',
  'preg_week_read_anomaly_scan': 'CC BY · flickr · mwcarruthers',
  'preg_week_read_baby_sound': 'CC0 · stocksnap · Freestocks.org',
  'preg_week_read_talking_baby': 'CC0 · stocksnap · Suhyeon Choi',
  'preg_week_read_back_pain': 'CC BY · flickr · gm.esthermax',
  'preg_week_read_third_tri_prep': 'CC0 · stocksnap · Matt Bango',
  'preg_week_read_movement_awareness': 'CC0 · stocksnap · Candace McDaniel',
  'preg_week_read_hospital_bag': 'CC BY · flickr · Joe Shlabotnik',
  'preg_week_read_labour_prep': 'CC BY · flickr · SimpleSkye',
  'preg_week_read_first_24h': 'CC BY-SA · flickr · Krisztina.Konczos',
  'preg_week_read_exp_priya': 'CC0 · stocksnap · Mel Elías',
  'preg_week_read_exp_meera': 'CC0 · stocksnap · Brodie Vissers',
  'preg_week_read_res_voices': 'CC BY-SA · flickr · Hammer51012',
  'preg_week_read_res_stress': 'CC0 · stocksnap · Marcos Moraes',
  'preg_scan_read_sex_law': 'CC0 · stocksnap · Skitter Photo',
  'preg_scan_read_costs': 'CC0 · stocksnap · Oles kanebckuu',
  'preg_scan_read_every_scan': 'CC0 · stocksnap · Candace McDaniel',
  'preg_scan_read_keep': 'CC0 · stocksnap · Daria Nepriakhina',
  'preg_scan_read_take_along': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_bp_dangerous': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_bleeding': 'CC0 · stocksnap · Direct Media',
  'preg_cond_read_less_movement': 'CC0 · stocksnap · Freestocks.org',
  'preg_cond_read_sugar_india': 'CC BY-SA · flickr · mitpatterson2010',
  'preg_cond_read_thyroid_tablet': 'CC0 · stocksnap · Michal Jarmoluk',
  'preg_cond_read_iron': 'CC BY · flickr · jencu',
  'preg_diet_read_add_now': 'CC0 · stocksnap · Burst',
  'preg_labour_read_pain_relief': 'CC0 · stocksnap · Freestocks.org',
};

/// The picture for a read: its own, else the table's, else none.
String? readImageFor(String readId, {String? own}) =>
    (own != null && own.isNotEmpty) ? own : kReadImageUrls[readId];
