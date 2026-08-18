// =============================================================================
//  Content slots — the tagging layer the reconciliation says is missing
// -----------------------------------------------------------------------------
//  The Excel's Inventory Snapshot, verbatim:
//
//    "Content tagging is currently absent | Content needs problem/sub-problem/
//     intent/format tags to auto-populate hubs."
//
//  This file is that tag. A slot says: *at this point in this journey, a video
//  of this kind belongs here, and here is what it will be worth.* Filling it
//  later is a URL and a thumbnail — a data change, not a code change, which is
//  exactly how `pv_video_config.dart` already treats the parenting catalogue.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY A MAPPING TABLE, AND NOT A `bracketId` FIELD ON EACH CONTENT MODEL
//  ---------------------------------------------------------------------------
//  The obvious move is to add `bracketId` + `step` to `ReadItem`, `WatchVideo`
//  and the FAQ shapes. It is the wrong one, for four reasons that all bite
//  later rather than now:
//
//   1. **Content lives in at least three models.** Tagging in place means three
//      edits, three sets of defaults, and three places to forget when a fourth
//      format arrives.
//   2. **One article legitimately serves two problems.** A field forces one
//      owner; a mapping is many-to-many for free. "Is it safe in pregnancy?"
//      and "Nutrition & diet" will want the same piece.
//   3. **⚠️ The slot must be able to exist BEFORE the content does.** That is
//      the whole point of the request. A field on a content row cannot describe
//      a row that does not exist yet, so the promise could never ship ahead of
//      the video — and the promise is what makes the screen honest instead of
//      empty.
//   4. **It is what the CMS will model anyway.** Directus/Supabase would
//      express this as a join table with foreign keys. Matching that shape now
//      means the migration is a copy, not a redesign.
//
//  The cost, stated honestly: a mapping table can point at content that has
//  been deleted, which a foreign key would have caught. `test/content_slots_test.dart`
//  is what stands in for that constraint until there is a real database.
//
//  ⚠️ ENGLISH ONLY FOR NOW. Every string below is English in both slots,
//  which is a Hindi debt, not a completed pair — see docs/SCANS-HUB-RECONCILIATION.md.
// =============================================================================

import '../localization/app_language.dart';

enum ContentFormat { video, article, faq }

/// A place in a journey where a piece of content belongs.
///
/// Unfilled is a first-class state, not an error. An unfilled slot still
/// renders — it states what it will hold and what that is worth — because a
/// feature is never hidden and a placeholder that states its value is honest,
/// while a blank space is just missing.
class ContentSlot {
  const ContentSlot({
    required this.bracketId,
    required this.step,
    required this.format,
    required this.title,
    required this.value,
    this.topic,
    this.readId,
    this.videoId,
    this.videoUrl,
    this.thumbUrl,
    this.duration,
  });

  /// Which problem hub. Matches `Bracket.id`, e.g. 'pregnancy_scans_tests'.
  final String bracketId;

  /// Which journey step inside that hub. See the `kStep*` constants below.
  final String step;

  /// Optional sub-problem. For scans this is a scan id ('anomaly_scan'); null
  /// means the slot serves every topic in the step.
  final String? topic;

  final ContentFormat format;

  /// What it is, in her words. Required even when unfilled — this is the
  /// promise, and it is the thing that has to be true before anything is shot.
  final LocalizedText title;

  /// ⚠️ ONE LINE ON WHY IT IS WORTH HER TIME. A slot with a title and no reason
  /// is a link, and a list of links is the catalogue this whole restructure
  /// replaced.
  final LocalizedText value;

  // ---- Fill these and the slot goes live -----------------------------------
  //
  // ⚠️ THIS IS THE "just swap a thumbnail and a link" SURFACE. Nothing else in
  // the app needs to change when a video is delivered: set `videoUrl` (or
  // `videoId` once it is in the catalogue) and `thumbUrl`, and the card stops
  // being a promise and starts being a tap.

  /// A `ReadItem.id` for an article that already exists in the app.
  final String? readId;

  /// A `WatchVideo.id` in the catalogue, once it is listed there.
  final String? videoId;

  /// Or a direct MP4/HLS URL on our own storage. In production this arrives
  /// signed, per request — see `pv_video_repository.dart`.
  final String? videoUrl;

  /// Poster image. Null renders the calm placeholder poster, never a broken
  /// image box.
  final String? thumbUrl;

  /// "6 MIN", shown on the chip. Null while unknown.
  final String? duration;

  /// ⚠️ THE ONE PREDICATE EVERYTHING ELSE READS. Kept here rather than in each
  /// screen so "filled" cannot come to mean two different things on two
  /// screens — which is precisely how a placeholder ends up tappable.
  bool get isFilled =>
      (readId != null && readId!.isNotEmpty) ||
      (videoId != null && videoId!.isNotEmpty) ||
      (videoUrl != null && videoUrl!.isNotEmpty);
}

// -----------------------------------------------------------------------------
//  Journey step ids
// -----------------------------------------------------------------------------
//  ⚠️ THESE ARE IDENTITY, NOT COPY. They are compared, never rendered, so they
//  stay English regardless of the app's language — the `.en` is identity, `.now`
//  is display rule, applied to a plain string.

/// Scans & tests, journey step 2 — "Understand this scan".
const String kStepUnderstandScan = 'understand_scan';

/// Scans & tests, journey step 5 — "What happens next?".
const String kStepAfterScan = 'after_scan';

// -----------------------------------------------------------------------------
//  The table
// -----------------------------------------------------------------------------
//  Seeded for Pregnancy → Scans & tests only, because that is the one hub on
//  the new model. Every entry below is UNFILLED on purpose: the Excel asks for
//  Video + Article + FAQs at step 2, the FAQs already ship inside
//  ScanDetailScreen, and the video and article are what is genuinely owed.
//
//  ⚠️ WRITE THE PROMISE BEFORE THE CONTENT EXISTS, AND MEAN IT. Every `value`
//  line below is a commitment about what that video has to earn. A slot whose
//  promise cannot be kept should be deleted, not filled with something weaker.

/// The Scans & tests bracket. Declared here so a data file never has to
/// import a screen to know which problem it is describing.
const String kScansHubBracketId = 'pregnancy_scans_tests';
const String _scans = kScansHubBracketId;

const List<ContentSlot> kContentSlots = [
  // ---- Anomaly scan — the highest-volume entry point in the product --------
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    topic: 'anomaly_scan',
    format: ContentFormat.video,
    title: LocalizedText(
        en: 'What the anomaly scan actually looks at',
        hi: 'What the anomaly scan actually looks at'),
    value: LocalizedText(
        en: 'The forty minutes, explained by someone who does them.',
        hi: 'The forty minutes, explained by someone who does them.'),
    duration: '6 MIN',
  ),
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    topic: 'anomaly_scan',
    format: ContentFormat.article,
    title: LocalizedText(
        en: 'Going in for the anomaly scan',
        hi: 'Going in for the anomaly scan'),
    value: LocalizedText(
        en: 'What to carry, how long it takes, and why being called back is '
            'routine.',
        hi: 'What to carry, how long it takes, and why being called back is '
            'routine.'),
    duration: '4 MIN',
  ),

  // ---- Dating scan --------------------------------------------------------
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    topic: 'dating_scan',
    format: ContentFormat.video,
    title: LocalizedText(
        en: 'Your first scan, start to finish',
        hi: 'Your first scan, start to finish'),
    value: LocalizedText(
        en: 'What you will see, and what it is too early to see.',
        hi: 'What you will see, and what it is too early to see.'),
    duration: '5 MIN',
  ),

  // ---- NT scan ------------------------------------------------------------
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    topic: 'nt_scan',
    format: ContentFormat.video,
    title: LocalizedText(
        en: 'The NT scan, and what a screening result is',
        hi: 'The NT scan, and what a screening result is'),
    value: LocalizedText(
        en: 'Why a screening number is not a diagnosis — the distinction that '
            'causes the most fear.',
        hi: 'Why a screening number is not a diagnosis — the distinction that '
            'causes the most fear.'),
    duration: '7 MIN',
  ),

  // ---- OGTT ---------------------------------------------------------------
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    topic: 'ogtt',
    format: ContentFormat.video,
    title: LocalizedText(
        en: 'The glucose test, and getting through it',
        hi: 'The glucose test, and getting through it'),
    value: LocalizedText(
        en: 'The fasting, the drink, the wait — and what the numbers mean.',
        hi: 'The fasting, the drink, the wait — and what the numbers mean.'),
    duration: '5 MIN',
  ),

  // ---- Any scan, step 2 ---------------------------------------------------
  ContentSlot(
    bracketId: _scans,
    step: kStepUnderstandScan,
    format: ContentFormat.article,
    title: LocalizedText(
        en: 'What a sonographer can and cannot tell you',
        hi: 'What a sonographer can and cannot tell you'),
    value: LocalizedText(
        en: 'Why they go quiet, why they will not discuss the sex, and who '
            'gives you the result.',
        hi: 'Why they go quiet, why they will not discuss the sex, and who '
            'gives you the result.'),
    duration: '4 MIN',
  ),

  // ---- Step 5 · after the scan --------------------------------------------
  ContentSlot(
    bracketId: _scans,
    step: kStepAfterScan,
    format: ContentFormat.video,
    title: LocalizedText(
        en: 'Your report came back with a note on it',
        hi: 'Your report came back with a note on it'),
    value: LocalizedText(
        en: 'What a finding usually means, and how often it changes nothing.',
        hi: 'What a finding usually means, and how often it changes nothing.'),
    duration: '6 MIN',
  ),
];

/// Slots for a point in a journey, most specific first.
///
/// ⚠️ TOPIC-SPECIFIC SLOTS SORT ABOVE GENERAL ONES. A mother on the anomaly
/// scan page should be offered the anomaly scan video before the general one;
/// the general slot is a floor, not a peer.
///
/// Filled slots sort above unfilled ones for the same reason — a promise is
/// worth showing, and it is not worth showing first.
List<ContentSlot> slotsFor(
  String bracketId,
  String step, {
  String? topic,
  ContentFormat? format,
}) {
  final out = kContentSlots.where((s) {
    if (s.bracketId != bracketId || s.step != step) return false;
    if (format != null && s.format != format) return false;
    if (s.topic == null) return true;
    return topic != null && s.topic == topic;
  }).toList();

  out.sort((a, b) {
    if (a.isFilled != b.isFilled) return a.isFilled ? -1 : 1;
    final at = a.topic != null ? 0 : 1;
    final bt = b.topic != null ? 0 : 1;
    return at.compareTo(bt);
  });
  return out;
}

/// True when a step has anything to show at all — filled or promised.
bool hasContentFor(String bracketId, String step, {String? topic}) =>
    slotsFor(bracketId, step, topic: topic).isNotEmpty;
