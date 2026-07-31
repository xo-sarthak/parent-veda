// =============================================================================
//  ExpertStore — the consulting catalogue, from the panel.
// -----------------------------------------------------------------------------
//  The app's half of migration 0072. Until it, adding a doctor who takes
//  appointments meant editing `pp_experts_data.dart` and shipping a release —
//  which made the whole onboarding flow panel-driven right up to the point it
//  mattered, then dropped off a cliff into a code change.
//
//  SEEDED, NOT SERVER-ONLY, and the difference is deliberate. ProgrammeStore
//  ships nothing (`serverOnly: true`) because there are no masterclasses until
//  somebody schedules one, and an empty list is the honest starting state.
//  Doctors are the opposite: a booking screen with no clinicians on it is
//  indistinguishable from a broken fetch, and it would be broken on a slow
//  network for someone who has already paid. So the bundled catalogue stays the
//  offline floor and the server merges over it — see mergedExperts().
//
//  `timings` IS NOT A COLUMN, and carries two facts instead. It is what
//  BookingCatalog uses to decide bookability, so it is derived from
//  takes_consults rather than typed:
//
//    * false → empty → no consult offering is derived, which is how an
//      organisation that only teaches sits in the catalogue without being
//      offered as a 1:1 — no branch on entity type anywhere in the app;
//    * true  → a placeholder, because a doctor's real availability comes from
//      their own schedule in ParentVeda+ (DoctorScheduleStore), never from a
//      string an editor typed.
//
//  So publishing a row makes someone appear. It does not invent time for them.
// =============================================================================

import '../screens/post_pregnancy/pp_experts_data.dart';
import 'content_store.dart';

class ExpertStore extends ContentStore<Expert> {
  ExpertStore._()
      : super(
          table: 'expert_profiles',
          cacheKey: 'content_experts_v1',
          seed: kExperts,
        );

  static final ExpertStore instance = ExpertStore._();

  @override
  Expert fromMap(Map<String, dynamic> row) {
    // WHOLE RUPEES (0074). It used to be paise and be divided here — the
    // conversion moved to the Razorpay boundary, which is the only place that
    // needs minor units, rather than living in an editor's head.
    final rupees = (row['fee_inr'] as num?)?.toInt() ?? 0;
    final rating = (row['rating'] as num?)?.toDouble() ?? 0;

    return Expert(
      id: _text(row['expert_id']),
      name: _text(row['name']),
      credential: _text(row['credential']),
      // Not a column: the back-bar label is chrome, derived from the category
      // so an editor never has to think about it.
      backLabel: _text(row['category']),
      location: _text(row['location']),
      rating: rating == 0 ? '' : rating.toStringAsFixed(1),
      reviewsCount: '${(row['reviews_count'] as num?)?.toInt() ?? 0} reviews',
      mid: ('', ''),
      fee: (rupees == 0 ? 'Free' : '₹$rupees', 'consult'),
      whyHeading: _text(row['why_heading']),
      why: _text(row['why']),
      tags: _list(row['tags']),
      // Reviews stay bundled. They are testimony about a named clinician and
      // should not become a free-text box an editor can put words into.
      reviews: const [],
      ctaPrice: rupees == 0 ? 'Free' : '₹$rupees',
      ctaSub: (row['video_consult'] == false) ? 'in person' : 'video consult',
      ctaLabel: 'Book a consultation',
      disclaimer:
          'A private consultation, booked and held inside ParentVeda.',
      topPick: row['top_pick'] == true,
      category: _text(row['category']),
      blurb: _text(row['blurb']),
      // `timings` is BookingCatalog's bookability gate, and it carries two
      // facts at once here.
      //
      // takes_consults false → empty → no consult offering is derived at all.
      // That is how an organisation which only teaches appears in the
      // catalogue without being offered as a 1:1 appointment, with no branch
      // on entity type anywhere in the app.
      //
      // And when it IS true, the value is a placeholder rather than real
      // hours: a doctor's availability comes from their own schedule in
      // ParentVeda+, never from a string an editor typed. Publishing a row
      // makes someone appear; it does not invent time for them.
      timings: row['takes_consults'] == false ? '' : 'By schedule',
      availableToday: true,
      videoConsult: row['video_consult'] != false,
      priceValue: rupees,
      ratingValue: rating,
    );
  }

  /// Cached in the DATABASE's shape, not the model's, so [fromMap] is the only
  /// mapper and a cached row and a live row cannot diverge. Every column
  /// fromMap reads has to appear here — a field left out reads as empty after
  /// a restart and as correct before one, which is the worst kind of bug to
  /// reproduce.
  @override
  Map<String, dynamic> toCacheMap(Expert e) => <String, dynamic>{
        'expert_id': e.id,
        'name': e.name,
        'credential': e.credential,
        'category': e.category,
        'location': e.location,
        'blurb': e.blurb,
        'fee_inr': e.priceValue,
        'rating': e.ratingValue,
        'reviews_count': _digits(e.reviewsCount),
        'why_heading': e.whyHeading,
        'why': e.why,
        'tags': e.tags,
        'top_pick': e.topPick,
        'video_consult': e.videoConsult,
        // The bookability gate, round-tripped: an org that only teaches must
        // still not be offered as a consult after a restart.
        'takes_consults': e.timings.trim().isNotEmpty,
      };

  /// "312 reviews" -> 312. The model carries the display string; the cache
  /// carries the number, because fromMap rebuilds the string from it.
  static int _digits(String s) =>
      int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static String _text(Object? v) => (v ?? '').toString().trim();

  static List<String> _list(Object? v) => v is List
      ? v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
      : const [];
}

/// Everything published in the admin panel, plus the bundled catalogue.
///
/// A published expert WINS over a bundled one with the same id, so a bundled
/// stub can be superseded by a real, editable version without deleting the Dart
/// (this repo comments out rather than deletes).
///
/// Every consulting surface must call this rather than `kExperts` directly —
/// the booking catalogue, the doctor directory, find-help, the profile screens.
/// Wiring them separately is how one gets missed and a doctor added in the
/// panel appears in three places out of five.
List<Expert> mergedExperts() {
  final live = ExpertStore.instance.all;
  if (live.isEmpty) return List<Expert>.of(kExperts);
  final liveIds = {for (final e in live) e.id};
  return [
    ...live,
    ...kExperts.where((e) => !liveIds.contains(e.id)),
  ];
}
