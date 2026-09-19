// =============================================================================
//  The doctor Home's three photographs — and why there are three
// -----------------------------------------------------------------------------
//  Mobbin audit #8b (2026-09-19, docs/DOCTOR-APP-AUDIT.md §7): the provider
//  homes that read as real rather than bland put a PHOTOGRAPH OF A PLACE
//  behind the greeting and let the first card overlap it — Calm, Air NZ,
//  Airbnb's host home, Bloom. None of them shows a face there; the place is
//  the point. For a clinician the place is a desk, a window, a lamp.
//
//  Three, not one, by the parent hero's own argument (v3_hero_field.dart):
//  a band identical every morning is wallpaper by the second week. Morning,
//  afternoon and evening each get their own light, so the app looks like it
//  knows what time it is.
//
//  Sourced like the reads (read_images.dart): Openverse, `source=stocksnap`,
//  CC0. Bundled rather than fetched, because the hero must be there before
//  the network is — a doctor opening the app in a lift should not see a
//  grey band. Cropped to 1.35:1 at 1080 wide, under 130 KB each. No
//  stethoscope, no laptop, no stock doctor: those read as a template, and
//  the brief was the opposite of a template.
//
//  Credits are shown under Profile → About. CC0 does not require them; we
//  show them anyway, the way the reads do.
// =============================================================================

class DoctorHeroImage {
  const DoctorHeroImage({required this.asset, required this.title, required this.creator, required this.source});
  final String asset;
  final String title;
  final String creator;
  final String source;
}

const kDoctorHeroImages = <String, DoctorHeroImage>{
  'morning': DoctorHeroImage(
    asset: 'assets/doctor/hero_morning.jpg',
    title: 'Window light',
    creator: 'Olu Eletu',
    source: 'StockSnap (CC0)',
  ),
  'afternoon': DoctorHeroImage(
    asset: 'assets/doctor/hero_afternoon.jpg',
    title: 'A desk, a notebook',
    creator: 'Ylanite Koppens',
    source: 'StockSnap (CC0)',
  ),
  'evening': DoctorHeroImage(
    asset: 'assets/doctor/hero_evening.jpg',
    title: 'Reading lamp',
    creator: 'Aaron Burden',
    source: 'StockSnap (CC0)',
  ),
};

/// Which photograph the hour gets: morning until noon, afternoon until five,
/// evening after — the same boundaries as the greeting, so the picture and
/// the words never disagree.
DoctorHeroImage doctorHeroFor(DateTime now) {
  final h = now.hour;
  return kDoctorHeroImages[h < 12 ? 'morning' : h < 17 ? 'afternoon' : 'evening']!;
}
