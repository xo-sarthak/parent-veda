// =============================================================================
//  Expert — the one person-shaped type the whole app names people with
// -----------------------------------------------------------------------------
//  ⚠️ THIS TYPE MOVED OUT OF A STAGE FOLDER, AND THE MOVE IS THE POINT.
//
//  It used to live in `lib/screens/post_pregnancy/pp_experts_data.dart`, which
//  was accurate when only Parenting named experts and stopped being accurate
//  some time ago: `lib/booking/`, `lib/services/expert_store.dart`, the doctor
//  app and now the Pregnancy "Prepare" tab all resolve people through it. A
//  cross-stage type parked inside one stage is how the OTHER stage ends up
//  inventing its own — which is exactly what Pregnancy had done, with `Coach`,
//  `Specialist` and three separate `instructorName` strings, none of which
//  could be tapped and none of which could be checked against anything.
//
//  `pp_experts_data.dart` now re-exports this file, so all thirty-odd existing
//  importers are untouched. Nothing had to be renamed to gain a second stage.
//
//  ⚠️ ENGLISH IS THE IDENTITY. HINDI IS AN OVERLAY.
//  Every field on `Expert` is the English value, and it is the one that gets
//  persisted, compared, matched by name and written by the panel. `hi` carries
//  the Hindi rendering of the handful of fields that are prose, and the `*Now`
//  getters pick between them. This mirrors the `.en` / `.now` rule in
//  CLAUDE.md: reaching for the display value where identity was meant has cost
//  this repo eight bugs, so the identity field keeps the plain name and the
//  display value is the one you have to ask for.
//
//  A missing overlay is not an error. Parenting is not translated yet (see
//  CLAUDE.md — that is DEBT, not a third language), so `hi` is null for every
//  parenting expert and each getter falls back to English.
// =============================================================================

import '../localization/app_language.dart';

/// The Hindi rendering of an expert's prose fields.
///
/// Deliberately NOT a mirror of the whole class. Names stay Latin in both
/// languages (`Dr. Ananya Rao` is `Dr. Ananya Rao`), ratings and fees are
/// numerals, and ids are identity. Only the sentences a mother reads need a
/// second script — which is also why every field here defaults to empty:
/// translating half a profile is normal, and the half that is done should show.
class ExpertHindi {
  const ExpertHindi({
    this.credential = '',
    this.location = '',
    this.blurb = '',
    this.whyHeading = '',
    this.why = '',
    this.experience = '',
    this.practisesAt = '',
    this.qualifications = const [],
    this.tags = const [],
  });

  final String credential;
  final String location;
  final String blurb;
  final String whyHeading;
  final String why;
  final String experience;
  final String practisesAt;
  final List<String> qualifications;

  /// Hindi for the `tags` list, POSITIONALLY MATCHED to it.
  ///
  /// ⚠️ A SHORTER LIST IS PADDED FROM THE ENGLISH RATHER THAN TRUNCATING IT, so
  /// a half-translated tag list still shows every specialty. See
  /// [Expert.tagsNow].
  final List<String> tags;
}

/// One expert / doctor / coach, shaped to fill the profile layout.
class Expert {
  const Expert({
    required this.id,
    required this.name,
    required this.credential,
    required this.backLabel,
    required this.rating,
    required this.reviewsCount,
    required this.mid,
    required this.fee,
    required this.whyHeading,
    required this.why,
    required this.tags,
    required this.reviews,
    required this.ctaPrice,
    required this.ctaSub,
    required this.ctaLabel,
    required this.disclaimer,
    this.topPick = false,
    this.topPickLabel = 'ParentVeda top pick',
    this.seeded = false,
    this.location = '',
    // --- credentials block (all optional; the profile hides what is empty) ---
    this.qualifications = const [],
    this.experience = '',
    this.practisesAt = '',
    this.registration = '',
    this.memberships = const [],
    this.hi,
    // --- Find-help / results fields (all optional, safe defaults) ------------
    this.category = '',
    this.blurb = '',
    this.timings = '',
    this.availableToday = true,
    this.videoConsult = false,
    this.priceValue = 0,
    this.ratingValue = 0,
  });

  final String id;
  final String name; // "Dr. Ananya Rao"
  final String credential; // "Paediatrician · 15 years"
  final String backLabel; // top back-bar label, e.g. "Masterclass expert"

  /// ⚠️ A PLACEHOLDER PERSON, KEPT DISTINGUISHABLE FROM A REAL ONE.
  ///
  /// Six categories had no supply at all, so the doors that named a sleep
  /// coach, a nutritionist, a physio, a postnatal counsellor or a development
  /// expert could not be filtered without landing a parent on an empty list.
  /// The decision was to build the whole path as though the expert exists, so
  /// that real supply is a data edit rather than a build.
  ///
  /// This flag is what stops that being a lie you cannot find later. It is the
  /// difference between "we have twelve more experts" and "we have twelve
  /// placeholders and here they are". `kSeededExpertIds` lists them,
  /// `test/pp_consult_filter_test.dart` counts them, and any screen that needs
  /// to behave differently for real supply has one boolean to read.
  ///
  /// ⚠️ IT IS NOT RENDERED TO A PARENT ANYWHERE, and that is a deliberate
  /// choice rather than an oversight: a "not a real expert" badge on a booking
  /// screen would be worse than either shipping or not shipping the door. The
  /// honest control is that booking is stubbed anyway — see the booking
  /// engine — so nobody can pay a placeholder.
  final bool seeded;

  final bool topPick;
  final String topPickLabel;
  final String location; // "Delhi NCR · online" - shown under the name on the profile
  final String rating; // "4.9"
  final String reviewsCount; // "1,020 reviews"
  final (String, String) mid; // (value, label) - e.g. ("12k+", "parents taught")
  final (String, String) fee; // (value, label) - e.g. ("₹1,499", "per class")
  final String whyHeading; // "Why ParentVeda picks her"
  final String why; // paragraph
  final List<String> tags; // languages & specialties
  final List<(String, String, String)> reviews; // (name, who, quote)
  final String ctaPrice; // "₹1,499"
  final String ctaSub; // "via ParentVeda"
  final String ctaLabel; // "View sessions"
  final String disclaimer;

  // ---------------------------------------------------------------------------
  //  Credentials
  // ---------------------------------------------------------------------------
  //  ⚠️ WHY THIS IS A LIST AND NOT A LONGER `credential` STRING. The one-line
  //  credential ("Paediatrician · 15 years") is a LABEL — it sits under a name
  //  on a card and has to stay one line. What a mother actually wants before
  //  handing over ₹1,499 is the boring stuff: which degree, from where, how
  //  long, which council. Cramming that into the label makes every card ugly;
  //  keeping it separate lets the card stay short and the profile go deep,
  //  which is the whole difference between a credit and a profile.
  //
  //  ⚠️ EVERY ONE OF THESE IS A CLAIM ABOUT A REAL PERSON. They are seeded here
  //  today, but the moment a real clinician is onboarded they must come from
  //  her own verified record (`expert_profiles`; the columns do not exist yet —
  //  see docs/STILL-OPEN.md). Nothing in the app may ever COMPUTE a credential.

  /// Degrees and certifications, most-significant first.
  /// e.g. `['MBBS, MD (Obstetrics & Gynaecology)', 'DNB — Sitaram Bhartia']`
  final List<String> qualifications;

  /// The one-line experience claim: `'15 years · 3,000+ deliveries'`.
  final String experience;

  /// Where she actually practises: `'Sitaram Bhartia Institute, New Delhi'`.
  /// Distinct from [location], which is the locality shown under the name.
  final String practisesAt;

  /// Council / board registration — `'DMC Reg. 45120'`, `'IBCLC L-32118'`.
  ///
  /// ⚠️ SHOWN, NEVER VERIFIED BY THE APP. It is a number an expert supplies and
  /// an operator checks; rendering it must not imply ParentVeda validated it,
  /// which is why the profile prints it under a plain "Registration" label and
  /// makes no claim about it.
  final String registration;

  /// Professional bodies: `['FOGSI', 'Indian Academy of Paediatrics']`.
  final List<String> memberships;

  /// Hindi for the prose fields. Null means "not translated yet".
  final ExpertHindi? hi;

  // --- Find-help / results fields (optional; power the "Browse by need" flow) -
  final String category; // maps to a FindHelpNeed, e.g. "Pediatrician"
  final String blurb; // 1-2 line qualification desc for the results card
  final String timings; // e.g. "9-12 PM · 4-6 PM"
  final bool availableToday;
  final bool videoConsult;
  final int priceValue; // numeric mirror of the fee, for price sorting
  final double ratingValue; // numeric mirror of the rating, for rating sorting

  // ---------------------------------------------------------------------------
  //  Display getters — Hindi where we have it, English where we do not.
  // ---------------------------------------------------------------------------
  //  ⚠️ NEVER PERSIST, COMPARE OR MATCH ON THESE. They answer "what should this
  //  screen print right now", which changes the moment a mother flips the
  //  language. `expertByName` matches on `name`, `BookingCatalog` keys on `id`,
  //  and the panel writes `credential` — all identity, none of it through here.

  static String _pick(String? hindi, String english) =>
      (S.current.isHindi && (hindi ?? '').trim().isNotEmpty) ? hindi! : english;

  String get credentialNow => _pick(hi?.credential, credential);
  String get locationNow => _pick(hi?.location, location);
  String get blurbNow => _pick(hi?.blurb, blurb);
  String get whyHeadingNow => _pick(hi?.whyHeading, whyHeading);
  String get whyNow => _pick(hi?.why, why);
  String get experienceNow => _pick(hi?.experience, experience);
  String get practisesAtNow => _pick(hi?.practisesAt, practisesAt);

  List<String> get qualificationsNow =>
      (S.current.isHindi && (hi?.qualifications.isNotEmpty ?? false))
          ? hi!.qualifications
          : qualifications;

  /// [tags] with each entry swapped for its Hindi at the same index.
  ///
  /// Positional rather than a map because a tag list is short, ordered and
  /// authored in one place; a map keyed on the English string would break the
  /// day somebody fixes a typo in the English.
  List<String> get tagsNow {
    final t = hi?.tags ?? const <String>[];
    if (!S.current.isHindi || t.isEmpty) return tags;
    return [
      for (var i = 0; i < tags.length; i++)
        (i < t.length && t[i].trim().isNotEmpty) ? t[i] : tags[i],
    ];
  }

  /// True when there is enough here to be worth opening a profile for.
  ///
  /// ⚠️ THE GUARD THAT STOPS A TAP BEING A DISAPPOINTMENT. A name that opens a
  /// page repeating only the name teaches a mother that expert names do
  /// nothing, which is the failure `pp_expert_link.dart` was written to end.
  bool get hasProfile =>
      credential.trim().isNotEmpty ||
      blurb.trim().isNotEmpty ||
      why.trim().isNotEmpty ||
      qualifications.isNotEmpty;
}
