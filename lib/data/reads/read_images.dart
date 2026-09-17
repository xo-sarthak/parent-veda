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
const Map<String, String> kReadImageUrls = {
  'preg_week_read_managing_nausea':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHg3NjA5NTAtaW1hZ2Uta3d2eGU1Z3UuanBn.jpg',
  'preg_week_read_first_scan':
      'https://images.rawpixel.com/image_1300/cHJpdmF0ZS9zdGF0aWMvaW1hZ2Uvd2Vic2l0ZS8yMDIyLTA0L2xyL2ZsNTA2OTM5ODI0NzItaW1hZ2Uta3VxcDJ2cGkuanBn.jpg',
  'preg_week_read_first_trimester':
      'https://live.staticflickr.com/168/455643284_16fb61b0b2_b.jpg',
  'preg_week_read_nutrition_t2':
      'https://live.staticflickr.com/7274/7654718986_d184cc7fd1_b.jpg',
  'preg_week_read_partner_support':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZmwzMzE5OTYxMjc5OC1pbWFnZS1reWJlaWJiZy5qcGc.jpg',
  'preg_week_read_halfway':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZnJiYWJ5X2JlbGx5X2JvZHlfYm95LWltYWdlLWt5YmU2N3M2LmpwZw.jpg',
  'preg_week_read_anomaly_scan':
      'https://live.staticflickr.com/7003/6721335809_fbaa640952_b.jpg',
  'preg_week_read_baby_sound':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZmw0NDM3Njc2MDU5MS1pbWFnZS1reWJlaXFydi5qcGc.jpg',
  'preg_week_read_talking_baby':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvdXB3azYyMjcwNjAwLXdpa2ltZWRpYS1pbWFnZS1rb3dyeThwZC5qcGc.jpg',
  'preg_week_read_back_pain':
      'https://live.staticflickr.com/5506/25354114919_295acda6b0_b.jpg',
  'preg_week_read_third_tri_prep':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9zdGF0aWMvaW1hZ2Uvd2Vic2l0ZS8yMDIyLTA0L2xyL2ZyYmFieV9iZWxseV9ib2R5X2dpcmwtaW1hZ2Uta3liZTZjajcuanBn.jpg',
  'preg_week_read_movement_awareness':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHg3Mjc0NDktaW1hZ2Uta3d5b3B4Y2MuanBn.jpg',
  'preg_week_read_hospital_bag':
      'https://live.staticflickr.com/2164/2284764037_df5b9bf8cf_b.jpg',
  'preg_week_read_labour_prep':
      'https://live.staticflickr.com/2028/32027398583_b6bb331ab2_b.jpg',
  'preg_week_read_first_24h':
      'https://live.staticflickr.com/2731/4434436315_da2cd858cc_b.jpg',
  'preg_week_read_exp_priya':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHg2MzY1MzItaW1hZ2Uta3d2eGxrcGouanBn.jpg',
  'preg_week_read_exp_meera':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAzL2ZsNTEzNjAwOTg4NDQtaW1hZ2UuanBn.jpg',
  'preg_week_read_res_voices':
      'https://live.staticflickr.com/158/423505105_d77db0ba17_b.jpg',
  'preg_week_read_res_stress':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL25zNjM3My1pbWFnZS5qcGc.jpg',
  'preg_scan_read_sex_law':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvdXB3azYxNzkxOTgwLXdpa2ltZWRpYS1pbWFnZS1rb3dsOXI2ZC5qcGc.jpg',
  'preg_scan_read_costs':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9zdGF0aWMvaW1hZ2Uvd2Vic2l0ZS8yMDIyLTA0L2xyL2ZyaW5kaWFuX2N1cnJlbmN5X21vbmV5X3J1cGVlcy1pbWFnZS1reWJiOWhtYS5qcGc.jpg',
  'preg_scan_read_every_scan':
      'https://images.rawpixel.com/image_1300/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZmw1MDY5NDAwMjcyNy1pbWFnZS1rdXFwMzVmZi5qcGc.jpg',
  'preg_scan_read_keep':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHg5OTA0MTQtaW1hZ2Uta3d5bnVwOHguanBn.jpg',
  'preg_scan_read_take_along':
      'https://images.rawpixel.com/image_1300/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZmw1MDY5NDAwMjcyNy1pbWFnZS1rdXFwMzVmZi5qcGc.jpg',
  'preg_cond_read_bp_dangerous':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvZmw1MDY2NjM3MTU0Ni1pbWFnZS1reWNpb3c2eC5qcGc.jpg',
  'preg_cond_read_bleeding':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L2ZyaG9zcGl0YWxfY29ycmlkb3Jfb3BlcmF0aW5nX3Jvb20taW1hZ2Uta3liZGduaGsuanBn.jpg',
  'preg_cond_read_less_movement':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHgxMzM0ODIyLWltYWdlLWt3eXFvcmtrLmpwZw.jpg',
  'preg_cond_read_sugar_india':
      'https://live.staticflickr.com/5095/5478130842_48de60e3bb_b.jpg',
  'preg_cond_read_thyroid_tablet':
      'https://images.rawpixel.com/editor_1024/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcHg1NTQ4MzctaW1hZ2Uta3d2eHBvaTcuanBn.jpg',
  'preg_cond_read_iron':
      'https://live.staticflickr.com/4043/4264803251_44d8827693_b.jpg',
  'preg_diet_read_add_now':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9zdGF0aWMvaW1hZ2Uvd2Vic2l0ZS8yMDIyLTA0L2xyL2ZmNjIxOS1pbWFnZS1rd3Z5aXVhMS5qcGc.jpg',
  'preg_labour_read_pain_relief':
      'https://images.rawpixel.com/editor_1024/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL2ZsNTE1MDQ0OTA5MTItaW1hZ2UuanBn.jpg',
};

/// Read id → licence · source · creator, for the credit line.
const Map<String, String> kReadImageCredits = {
  'preg_week_read_managing_nausea': 'CC0 · rawpixel · ',
  'preg_week_read_first_scan': 'CC0 · rawpixel · U.S. Agency for International Development',
  'preg_week_read_first_trimester': 'CC BY-SA · flickr · viralbus',
  'preg_week_read_nutrition_t2': 'CC BY · flickr · shankar s.',
  'preg_week_read_partner_support': 'CC0 · rawpixel · ',
  'preg_week_read_halfway': 'CC0 · rawpixel · ',
  'preg_week_read_anomaly_scan': 'CC BY · flickr · mwcarruthers',
  'preg_week_read_baby_sound': 'CC0 · rawpixel · ',
  'preg_week_read_talking_baby': 'CC0 · rawpixel · ',
  'preg_week_read_back_pain': 'CC BY · flickr · gm.esthermax',
  'preg_week_read_third_tri_prep': 'CC0 · rawpixel · ',
  'preg_week_read_movement_awareness': 'CC0 · rawpixel · ',
  'preg_week_read_hospital_bag': 'CC BY · flickr · Joe Shlabotnik',
  'preg_week_read_labour_prep': 'CC BY · flickr · SimpleSkye',
  'preg_week_read_first_24h': 'CC BY-SA · flickr · Krisztina.Konczos',
  'preg_week_read_exp_priya': 'CC0 · rawpixel · ',
  'preg_week_read_exp_meera': 'CC0 · rawpixel · U.S. Department of Agriculture',
  'preg_week_read_res_voices': 'CC BY-SA · flickr · Hammer51012',
  'preg_week_read_res_stress': 'CC0 · rawpixel · ',
  'preg_scan_read_sex_law': 'CC0 · rawpixel · ',
  'preg_scan_read_costs': 'CC0 · rawpixel · ',
  'preg_scan_read_every_scan': 'CC0 · rawpixel · U.S. Agency for International Development',
  'preg_scan_read_keep': 'CC0 · rawpixel · ',
  'preg_scan_read_take_along': 'CC0 · rawpixel · U.S. Agency for International Development',
  'preg_cond_read_bp_dangerous': 'CC0 · rawpixel · ',
  'preg_cond_read_bleeding': 'CC0 · rawpixel · ',
  'preg_cond_read_less_movement': 'CC0 · rawpixel · ',
  'preg_cond_read_sugar_india': 'CC BY-SA · flickr · mitpatterson2010',
  'preg_cond_read_thyroid_tablet': 'CC0 · rawpixel · ',
  'preg_cond_read_iron': 'CC BY · flickr · jencu',
  'preg_diet_read_add_now': 'CC0 · rawpixel · ',
  'preg_labour_read_pain_relief': 'CC0 · rawpixel · U.S. Agency for International Development',
};

/// The picture for a read: its own, else the table's, else none.
String? readImageFor(String readId, {String? own}) =>
    (own != null && own.isNotEmpty) ? own : kReadImageUrls[readId];
